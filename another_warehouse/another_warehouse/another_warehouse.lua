-- v1.0.0 Yet Another Account Inventoryの焼き直し。保守しやすい様、自分用にシンプルにした。
local addonName = "ANOTHER_WAREHOUSE"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.logpath = string.format('../addons/%s/log.txt', addonNameLower)

local acutil = require("acutil")
local json = require('json')
local os = require("os")
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

function another_warehouse_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end
    if not settings then
        settings = {}
    end
    g.settings = settings

    another_warehouse_save_settings()

end

function another_warehouse_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function ANOTHER_WAREHOUSE_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.settings = g.settings or {}

    another_warehouse_load_settings()
    addon:RegisterMsg("OPEN_DLG_ACCOUNTWAREHOUSE", "another_warehouse_OPEN_DLG_ACCOUNTWAREHOUSE");
    addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_LIST", "another_warehouse_on_msg");
    addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_ADD", "another_warehouse_on_msg");
    addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_REMOVE", "another_warehouse_on_msg");
    addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_CHANGE_COUNT", "another_warehouse_on_msg");
    addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_IN", "another_warehouse_on_msg");

    addon:RegisterMsg('ESCAPE_PRESSED', 'another_warehouse_accountwarehouse_close');

    acutil.setupEvent(addon, 'ACCOUNTWAREHOUSE_OPEN', "another_warehouse_accountwarehouse_open")
    acutil.setupEvent(addon, 'ACCOUNTWAREHOUSE_CLOSE', "another_warehouse_accountwarehouse_close")

    local functionName = "YAACCOUNTINVENTORY_ON_INIT" -- チェックしたい関数の名前を文字列として指定します
    if type(_G[functionName]) == "function" then
        addon:RegisterMsg("GAME_START_3SEC", "another_warehouse_notice");

    end

end

function another_warehouse_notice()
    local msg = "Notice from [another warehouse]"
    NICO_CHAT(msg)
    local msg2 = "[Yet Another Account Inventory] add-on is installed and will not function properly."
    NICO_CHAT(msg2)
    --[[ui.SysMsg(
        "Notice from [another warehouse]{nl}The [Yet Another Account Inventory] add-on is installed and will not function properly.")]]
end

function another_warehouse_accountwarehouse_close()

    another_warehouse_deactive_mousebutton()
    local msframe = ui.GetFrame("monstercardslot")
    msframe:SetLayerLevel(96)

    local overlap = ui.GetFrame("another_warehouse")
    overlap:ShowWindow(0)

end

--[[function another_warehouse_accountwarehouse_save()
    local frame = ui.GetFrame("accountwarehouse")
    local tab = GET_CHILD(frame, "accountwarehouse_tab");
    local accountObj = GetMyAccountObj();
    local basecount = accountObj.BasicAccountWarehouseSlotCount + accountObj.MaxAccountWarehouseCount +
                          accountObj.AccountWareHouseExtend + accountObj.AccountWareHouseExtendByItem +
                          ADDITIONAL_SLOT_COUNT_BY_TOKEN

    for i = 0, 4 do
        if i == 0 then
            tab:SelectTab(i)
            local slotset = GET_CHILD_RECURSIVELY(frame, "slotset")
            for j = 1, basecount do
                local slot = slotset:GetSlotByIndex(j)
                AUTO_CAST(slot)
                local icon = slot:GetIcon()
                if icon == nil then

                    local iconInfo = icon:GetInfo();
                    local invItem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iconInfo:GetIESID());
                end

            end
        end
    end
end]]

function another_warehouse_item_count()
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidlist = itemList:GetSortedGuidList();
    local cnt = itemList:Count();
    local rcnt = 0
    for i = 0, cnt - 1 do
        local guid = guidlist:Get(i);
        local invItem = itemList:GetItemByGuid(guid)
        if (invItem ~= nil) then
            local invItem_obj = GetIES(invItem:GetObject());
            if invItem_obj.ClassName ~= MONEY_NAME then
                rcnt = rcnt + 1
            end
        end
    end

    return rcnt
end

function another_warehouse_checkvalid(iesid)
    local invItem = session.GetInvItemByGuid(iesid)

    local obj = GetIES(invItem:GetObject())
    local itemcnt = another_warehouse_item_count()
    local maxcount = another_warehouse_get_maxcount()

    if maxcount <= itemcnt then

        ui.SysMsg(ClMsg('CannotPutBecauseMaxSlot'));
        return;
    end
    if true == invItem.isLockState then

        ui.SysMsg(ClMsg("MaterialItemIsLock"));

        return;
    end

    local itemCls = GetClassByType("Item", obj.ClassID);
    if itemCls.ItemType == 'Quest' then

        ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"));

        return;
    end

    local enableTeamTrade = TryGetProp(itemCls, "TeamTrade");
    if enableTeamTrade ~= nil and enableTeamTrade == "NO" then

        ui.SysMsg(ClMsg("ItemIsNotTradable"));

        return;

    end

end

function another_warehouse_get_exist_item_index(itemObj)
    local ret1 = false
    local ret2 = -1

    if geItemTable.IsStack(itemObj.ClassID) == 1 then
        local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
        local sortedGuidList = itemList:GetGuidList();
        local sortedCnt = sortedGuidList:Count();

        for i = 0, sortedCnt - 1 do
            local guid = sortedGuidList:Get(i);
            local invItem = itemList:GetItemByGuid(guid)
            local invItem_obj = GetIES(invItem:GetObject());
            if itemObj.ClassID == invItem_obj.ClassID then
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

function another_warehouse_get_goal_index()
    local frame = ui.GetFrame("accountwarehouse")
    local tab = GET_CHILD(frame, "accountwarehouse_tab");
    local gbox = GET_CHILD_RECURSIVELY(frame, "gbox")

    local accountObj = GetMyAccountObj();
    local basecount = accountObj.BasicAccountWarehouseSlotCount + accountObj.MaxAccountWarehouseCount +
                          accountObj.AccountWareHouseExtend + accountObj.AccountWareHouseExtendByItem +
                          ADDITIONAL_SLOT_COUNT_BY_TOKEN

    local invItemCount = another_warehouse_item_count()
    local maxcount = another_warehouse_get_maxcount()
    local index = 0

    if invItemCount < maxcount then
        for i = 4, 0, -1 do
            -- for i = 0, 4 do
            if i == 4 then
                tab:SelectTab(i)
                local itemcnt = GET_CHILD(gbox, "itemcnt")
                local length = #itemcnt:GetText()
                local left = 0

                if length == 14 then
                    left = string.sub(itemcnt:GetText(), length - 6, length - 6) * 1 -- 左側の数字を取得
                else
                    left = string.sub(itemcnt:GetText(), length - 7, length - 6) * 1 -- 左側の数字を取得
                end

                if left < 70 then
                    index = basecount + 210 + left + 1
                    return index
                end
            elseif i == 3 then
                tab:SelectTab(i)
                local itemcnt = GET_CHILD(gbox, "itemcnt")
                local length = #itemcnt:GetText()
                local left = 0

                if length == 14 then
                    left = string.sub(itemcnt:GetText(), length - 6, length - 6) * 1 -- 左側の数字を取得
                else
                    left = string.sub(itemcnt:GetText(), length - 7, length - 6) * 1 -- 左側の数字を取得
                end

                if left < 70 then
                    index = basecount + 140 + left + 1
                    return index
                end
            elseif i == 2 then
                tab:SelectTab(i)
                local itemcnt = GET_CHILD(gbox, "itemcnt")
                local length = #itemcnt:GetText()
                local left = 0

                if length == 14 then
                    left = string.sub(itemcnt:GetText(), length - 6, length - 6) * 1 -- 左側の数字を取得
                else
                    left = string.sub(itemcnt:GetText(), length - 7, length - 6) * 1 -- 左側の数字を取得
                end

                if left < 70 then
                    index = basecount + 70 + left + 1
                    return index
                end
            elseif i == 1 then
                tab:SelectTab(i)
                local itemcnt = GET_CHILD(gbox, "itemcnt")
                local length = #itemcnt:GetText()
                local left = 0

                if length == 14 then
                    left = string.sub(itemcnt:GetText(), length - 6, length - 6) * 1 -- 左側の数字を取得
                else
                    left = string.sub(itemcnt:GetText(), length - 7, length - 6) * 1 -- 左側の数字を取得
                end

                if left < 70 then
                    index = basecount + left + 1
                    return index
                end

            elseif i == 0 then
                tab:SelectTab(i)
                local slotset = GET_CHILD_RECURSIVELY(frame, "slotset")
                for j = 1, basecount do
                    local slot = slotset:GetSlotByIndex(j)
                    AUTO_CAST(slot)
                    local icon = slot:GetIcon()
                    if icon == nil then
                        index = j + 1
                        return index
                    end

                end

            end
        end
    else
        ui.SysMsg(ClMsg('CannotPutBecauseMaxSlot'));
        return
    end

end

function another_warehouse_putitem(iesid, count)

    another_warehouse_checkvalid(iesid)

    local invItem = session.GetInvItemByGuid(iesid)
    local invItem_obj = GetIES(invItem:GetObject());

    local exist, index = another_warehouse_get_exist_item_index(invItem_obj)

    local goal_index = another_warehouse_get_goal_index()

    if exist == true and index >= 0 then
        goal_index = index
    end

    local frame = ui.GetFrame("accountwarehouse")

    item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, iesid, tostring(math.min(count or invItem.count, invItem.count)),
        frame:GetUserIValue("HANDLE"), goal_index)

end

function another_warehouse_accountwarehouse_open()

    another_warehouse_active_mousebutton()

    local frame = ui.GetFrame("accountwarehouse")
    local accountwarehousefilter = GET_CHILD_RECURSIVELY(frame, "accountwarehousefilter")
    accountwarehousefilter:SetMargin(490, 705)
end

function another_warehouse_active_mousebutton()

    if (ui.GetFrame("accountwarehouse"):IsVisible() == 1) then

        local invframe = ui.GetFrame("inventory")
        INVENTORY_SET_CUSTOM_RBTNDOWN("another_warehouse_inv_rbtn")

        SET_INV_LBTN_FUNC(invframe, "another_warehouse_inv_lbtn")
    end
end

function another_warehouse_inv_lbtn(frame, invItem, dumm)

    local iesid = invItem:GetIESID()
    -- print(tostring(iesid))
    if keyboard.IsKeyPressed("LSHIFT") == 1 then

        local frame = ui.GetFrame("accountwarehouse")
        local obj = GetIES(invItem:GetObject())

        local maxCnt = invItem.count;
        local belongingCount = TryGetProp(obj, 'BelongingCount', 0)
        if belongingCount > 0 then
            maxCnt = invItem.count - obj.BelongingCount;
            if maxCnt <= 0 then
                maxCnt = 0;
            end
        end

        if invItem.count > 1 or geItemTable.IsStack(obj.ClassID) == 1 then
            INPUT_NUMBER_BOX(frame, ScpArgMsg("InputCount"), "EXEC_PUT_ITEM_TO_ACCOUNT_WAREHOUSE", maxCnt, 1, maxCnt,
                nil, tostring(invItem:GetIESID()));
        else
            another_warehouse_putitem(iesid, 10)
        end
    else
        another_warehouse_putitem(iesid, 10)
    end
end

function another_warehouse_inv_rbtn(itemObj, slot)

    local icon = slot:GetIcon();
    local iconInfo = icon:GetInfo();
    local iesid = iconInfo:GetIESID()
    local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());

    if nil == invItem then
        return;
    end

    if keyboard.IsKeyPressed("LSHIFT") == 1 then

        local frame = ui.GetFrame("accountwarehouse")
        local obj = GetIES(invItem:GetObject())

        local maxCnt = invItem.count;
        local belongingCount = TryGetProp(obj, 'BelongingCount', 0)
        if belongingCount > 0 then
            maxCnt = invItem.count - obj.BelongingCount;
            if maxCnt <= 0 then
                maxCnt = 0;
            end
        end

        if invItem.count > 1 or geItemTable.IsStack(obj.ClassID) == 1 then
            INPUT_NUMBER_BOX(frame, ScpArgMsg("InputCount"), "EXEC_PUT_ITEM_TO_ACCOUNT_WAREHOUSE", maxCnt, 1, maxCnt,
                nil, tostring(invItem:GetIESID()));
        else
            another_warehouse_putitem(iesid, invItem.count)
        end
    else
        another_warehouse_putitem(iesid, invItem.count)
    end

    -- !YAI_HANDLE_ACTION(invItem, "R", true)

end

function another_warehouse_deactive_mousebutton()

    INVENTORY_SET_CUSTOM_RBTNDOWN("None")
    SET_INV_LBTN_FUNC(ui.GetFrame("inventory"), "None");

end

function another_warehouse_on_msg(frame, msg, argStr, argNum)

    if msg == 'ACCOUNT_WAREHOUSE_ITEM_LIST' then
        another_warehouse_frame_update()
    elseif msg == 'ACCOUNT_WAREHOUSE_ITEM_IN' then
        -- no op
    elseif msg == 'ACCOUNT_WAREHOUSE_ITEM_ADD' then
        DebounceScript("another_warehouse_frame_update", 1.0, 0)

    elseif msg == 'ACCOUNT_WAREHOUSE_ITEM_REMOVE' then

        another_warehouse_remove_targeted(argStr)
        DebounceScript("another_warehouse_frame_update", 3.0, 0)

    elseif msg == 'ACCOUNT_WAREHOUSE_ITEM_CHANGE_COUNT' then
        another_warehouse_remove_targeted(argStr)
        -- DebounceScript("another_warehouse_frame_update", 0.5, 0)
        -- DebounceScript("another_warehouse_frame_update", 3.0, 0)
        another_warehouse_frame_update()
    else
        another_warehouse_frame_update()
    end

end

function another_warehouse_remove_targeted(itemguid)

    local frame = ui.GetFrame("another_warehouse")

    another_warehouse_remove_recurse_guid(frame, itemguid)

end
function another_warehouse_remove_recurse_guid(parent, guid)

    for i = 0, parent:GetChildCount() - 1 do
        local child = parent:GetChildByIndex(i)

        if (string.find(child:GetClassString(), "CSlotSet")) then
            AUTO_CAST(child)
            for j = 0, child:GetSlotCount() - 1 do
                local slot = child:GetSlotByIndex(j)
                local icon = slot:GetIcon();
                if (icon ~= nil) then
                    local iconInfo = icon:GetInfo();

                    if (iconInfo:GetIESID() == guid) then
                        slot:ClearIcon()
                        slot:SetSkinName("invenslot2")
                        slot:SetText("")
                        slot:RemoveAllChild()

                        break
                    end

                end
            end
        else
            another_warehouse_remove_recurse_guid(child, guid)
        end

    end

end

function another_warehouse_OPEN_DLG_ACCOUNTWAREHOUSE()

    local msframe = ui.GetFrame("monstercardslot")
    msframe:SetLayerLevel(98)

    local frame = ui.GetFrame("accountwarehouse")
    local accountwarehouse_tab = GET_CHILD_RECURSIVELY(frame, "accountwarehouse_tab")
    accountwarehouse_tab:SetMargin(0, 240) -- margin="0 120 0 0"
    local richtext_1 = GET_CHILD_RECURSIVELY(frame, "richtext_1")
    richtext_1:SetMargin(30, 133) --  margin="30 73 0 0"
    local itemcnt = GET_CHILD_RECURSIVELY(frame, "itemcnt")
    itemcnt:SetMargin(0, 133, 190, 0) --  margin="0 73 190 0"

    local maxcount = another_warehouse_get_maxcount()
    local itemcount = another_warehouse_item_count()

    local grupbox = GET_CHILD_RECURSIVELY(frame, "gbox")

    local count_text = grupbox:CreateOrGetControl("richtext", "count_text", 0, 0, 200, 24)
    AUTO_CAST(count_text)
    count_text:SetMargin(420, 73, 0, 0)
    count_text:SetText("{@st42}" .. itemcount .. "/" .. maxcount .. "{/}")
    count_text:SetFontName("white_16_ol")
    count_text:ShowWindow(1)

    local awclose = grupbox:CreateOrGetControl("button", "awclose", 10, 0, 100, 43)
    AUTO_CAST(awclose)
    awclose:SetText("{@st66b}AW CLOSE")
    awclose:SetEventScript(ui.LBUTTONUP, "another_warehouse_frame_close")
    awclose:SetMargin(10, 60, 0, 0)
    awclose:SetSkinName("test_pvp_btn")
    awclose:ShowWindow(1)

    local name_text = grupbox:CreateOrGetControl("richtext", "name_text", 15, 0, 200, 24)
    local LoginName = session.GetMySession():GetPCApc():GetName()
    name_text:SetMargin(10, 5, 0, 0)
    name_text:SetText("{ol}{s18}" .. LoginName .. "{/}")

    local overlap = ui.GetFrame("another_warehouse")
    overlap:SetSkinName("None")

    overlap:SetOffset(0, 200)
    overlap:Resize(670, 570)

    local height = overlap:GetHeight()
    local gbox = overlap:GetChild("inventoryGbox")
    AUTO_CAST(gbox)
    gbox:Resize(650, height - 15)
    gbox:SetOffset(10, 5)
    gbox:SetSkinName("test_frame_low")

    local gbox2 = overlap:GetChildRecursively("inventoryitemGbox")
    AUTO_CAST(gbox2)
    gbox2:Resize(650 - 32, height - 15)
    gbox2:SetOffset(35, 0)

    overlap:EnableHitTest(1)
    overlap:EnableHittestFrame(1)
    overlap:SetLayerLevel(97)

    overlap:ShowWindow(1)
    another_warehouse_frame_update()

    -- another_warehouse_get_maxcount()
end

function another_warehouse_get_maxcount()
    local accountObj = GetMyAccountObj();

    local maxcnt = 0
    if session.loginInfo.IsPremiumState(ITEM_TOKEN) == true then
        maxcnt = accountObj.BasicAccountWarehouseSlotCount + accountObj.MaxAccountWarehouseCount +
                     accountObj.AccountWareHouseExtend + accountObj.AccountWareHouseExtendByItem +
                     ADDITIONAL_SLOT_COUNT_BY_TOKEN + 280
        return maxcnt
    else
        maxcnt = accountObj.BasicAccountWarehouseSlotCount + accountObj.MaxAccountWarehouseCount +
                     accountObj.AccountWareHouseExtend + accountObj.AccountWareHouseExtendByItem +
                     ADDITIONAL_SLOT_COUNT_BY_TOKEN
        return maxcnt
    end

end

function another_warehouse_frame_close(frame, ctrl)
    local frame = ui.GetFrame("another_warehouse")
    frame:ShowWindow(0)

    local awframe = ui.GetFrame("accountwarehouse")
    local accountwarehouse_tab = GET_CHILD_RECURSIVELY(awframe, "accountwarehouse_tab")
    accountwarehouse_tab:SetMargin(0, 120, 0, 0) -- margin="0 120 0 0"
    local richtext_1 = GET_CHILD_RECURSIVELY(awframe, "richtext_1")
    richtext_1:SetMargin(30, 73, 0, 0) --  margin="30 73 0 0"
    local itemcnt = GET_CHILD_RECURSIVELY(awframe, "itemcnt")
    itemcnt:SetMargin(0, 73, 190, 0) --  margin="0 73 190 0"

    local awclose = GET_CHILD_RECURSIVELY(awframe, "awclose")
    awclose:ShowWindow(0)

    local count_text = GET_CHILD_RECURSIVELY(awframe, "count_text")
    count_text:ShowWindow(0)
    another_warehouse_deactive_mousebutton()
    INVENTORY_SET_CUSTOM_RBTNDOWN("ACCOUNT_WAREHOUSE_INV_RBTN")
end

local function IsBlackListedTabName(name)
    return name == 'Quest'
end

function another_warehouse_find_activegbox(frame)

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

function another_warehouse_get_slotset_name(baseidcls)

    local cls = baseidcls
    if cls == nil then
        return 'error'
    else
        local className = cls.ClassName
        if cls.MergedTreeTitle ~= "NO" then
            className = cls.MergedTreeTitle
        end
        return 'sset_' .. className
    end
end

function another_warehouse_make_inven_slotset(tree, name)

    local frame = ui.GetFrame('another_warehouse');

    local slotsize = 54
    local colcount = 10

    local newslotset = tree:CreateOrGetControl('slotset', name, 0, 0, 0, 0)
    tolua.cast(newslotset, "ui::CSlotSet");

    newslotset:EnablePop(1)
    newslotset:EnableDrag(1)
    newslotset:EnableDrop(1)
    newslotset:SetMaxSelectionCount(999)
    newslotset:SetSlotSize(slotsize, slotsize);
    newslotset:SetColRow(colcount, 1)
    newslotset:SetSpc(0, 0)
    newslotset:SetSkinName('invenslot')
    newslotset:EnableSelection(0)
    newslotset:CreateSlots();
    ui.inventory.AddInvenSlotSetName(name);
    return newslotset;
end

function another_warehouse_inven_slotset_and_title(tree, treegroup, slotsetname, baseidcls)

    local slotsettitle = 'ssettitle_' .. baseidcls.ClassName;
    if baseidcls.MergedTreeTitle ~= "NO" then
        slotsettitle = 'ssettitle_' .. baseidcls.MergedTreeTitle
    end

    local newSlotsname = MAKE_INVEN_SLOTSET_NAME(tree, slotsettitle, baseidcls.TreeSSetTitle)
    local newSlots = another_warehouse_make_inven_slotset(tree, slotsetname)
    tree:Add(treegroup, newSlotsname, slotsettitle);
    local slotHandle = tree:Add(treegroup, newSlots, slotsetname);
    local slotNode = tree:GetNodeByTreeItem(slotHandle);
    slotNode:SetUserValue("IS_ITEM_SLOTSET", 1);
end

function another_warehouse_insert_item_to_tree(frame, tree, invItem, itemCls, baseidcls, typeStr)

    local treegroupname = baseidcls.TreeGroup

    local treegroup = tree:FindByValue(treegroupname);
    if tree:IsExist(treegroup) == 0 then
        treegroup = tree:Add(baseidcls.TreeGroupCaption, baseidcls.TreeGroup);
        local treeNode = tree:GetNodeByTreeItem(treegroup);
        treeNode:SetUserValue("BASE_CAPTION", baseidcls.TreeGroupCaption);

        -- ui.inventory.AddInvenGroupName(treegroupname);
    end

    -- 슬롯셋 없으면 만들기
    local slotsetname = another_warehouse_get_slotset_name(baseidcls)
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
        another_warehouse_inven_slotset_and_title(tree, treegroup, slotsetname, baseidcls);

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
    slot:SetEventScript(ui.LBUTTONUP, "another_warehouse_on_lbutton")
    slot:SetEventScript(ui.RBUTTONUP, "another_warehouse_on_rbutton")
    slotset:MakeSelectionList();
    -- slotset:EnableSelection(1)
end

function another_warehouse_take_item_from_warehouse(frame, count, inputframe)
    inputframe:ShowWindow(0);
    local iesid = inputframe:GetUserValue("ArgString");
    session.ResetItemList();
    session.AddItemID(iesid, count);
    item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), frame:GetUserIValue("HANDLE"));
end

function another_warehouse_on_lbutton(frame, slot, argstr, argnum)

    local awframe = ui.GetFrame("accountwarehouse");
    local icon = slot:GetIcon();
    if (icon == nil) then
        return

    end
    local iconInfo = icon:GetInfo();
    if (iconInfo == nil) then
        return
    end
    local invItem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iconInfo:GetIESID());
    local iesid = invItem:GetIESID()
    local obj = GetIES(invItem:GetObject())

    if keyboard.IsKeyPressed("LSHIFT") == 1 then
        local belongingCount = TryGetProp(obj, 'BelongingCount', 0)
        local maxCnt = invItem.count;
        if belongingCount > 0 then
            maxCnt = invItem.count - obj.BelongingCount;
            if maxCnt <= 0 then
                maxCnt = 0;
            end
        end

        if invItem.count > 1 or geItemTable.IsStack(obj.ClassID) == 1 then
            INPUT_NUMBER_BOX(awframe, ScpArgMsg("InputCount"), "another_warehouse_take_item_from_warehouse", maxCnt, 1,
                maxCnt, nil, iesid);
        else
            another_warehouse_takeitem(awframe, iesid, 1)

        end
    else
        if invItem.count > 1 or geItemTable.IsStack(obj.ClassID) == 1 then
            another_warehouse_takeitem(awframe, iesid, 10)
        else
            another_warehouse_takeitem(awframe, iesid, 1)
        end
    end
    -- another_warehouse_put_account_item_to_warehouse(frame, slot)
    -- another_warehouse_takeitem(awframe, iesid, 10)

end

function another_warehouse_takeitem(frame, iesid, count)

    local invItem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iesid);

    session.ResetItemList();
    session.AddItemID(iesid, count);
    item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), frame:GetUserIValue("HANDLE"));

end

function another_warehouse_on_rbutton(frame, slot, argstr, argnum)

    local awframe = ui.GetFrame("accountwarehouse");
    local icon = slot:GetIcon();
    if (icon == nil) then
        return

    end
    local iconInfo = icon:GetInfo();
    if (iconInfo == nil) then
        return
    end
    local invItem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iconInfo:GetIESID());
    local iesid = invItem:GetIESID()
    local obj = GetIES(invItem:GetObject())
    local count = invItem.count

    if keyboard.IsKeyPressed("LSHIFT") == 1 then
        local belongingCount = TryGetProp(obj, 'BelongingCount', 0)
        local maxCnt = invItem.count;
        if belongingCount > 0 then
            maxCnt = invItem.count - obj.BelongingCount;
            if maxCnt <= 0 then
                maxCnt = 0;
            end
        end

        if invItem.count > 1 or geItemTable.IsStack(obj.ClassID) == 1 then
            INPUT_NUMBER_BOX(awframe, ScpArgMsg("InputCount"), "another_warehouse_take_item_from_warehouse", maxCnt, 1,
                maxCnt, nil, iesid);
        else
            another_warehouse_takeitem(awframe, iesid, 1)

        end
    else
        if invItem.count > 1 or geItemTable.IsStack(obj.ClassID) == 1 then
            another_warehouse_takeitem(awframe, iesid, count)
        else
            another_warehouse_takeitem(awframe, iesid, 1)
        end
    end
    -- another_warehouse_takeitem(awframe, iesid, count)
    -- !YAI_HANDLE_ACTION(invItem, "R", false)

end

function another_warehouse_frame_update()

    g.tree = {}
    local frame = ui.GetFrame("another_warehouse")

    local invenTypeStr = nil
    local invframe = ui.GetFrame("inventory")
    local awframe = ui.GetFrame("accountwarehouse")
    local blinkcolor = frame:GetUserConfig("TREE_SEARCH_BLINK_COLOR");
    local group = GET_CHILD_RECURSIVELY(frame, 'inventoryGbox', 'ui::CGroupBox')

    local etree_box = another_warehouse_find_activegbox(frame)
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
            -- local obj = GetIES(invItem:GetObject())
            -- local class = GetClassByType("Item", obj.ClassID)
            -- local realname = dictionary.ReplaceDicIDInCompStr(class.Name)

            if pass then
                invItem.index = index_count
                invItemList[index_count] = invItem
                index_count = index_count + 1
            end
        end
    end

    local sortType = 3

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
                                    another_warehouse_insert_item_to_tree(frame, tree, invItem, itemCls, baseidcls,
                                        typeStr);

                                end

                                local tree_box_all = GET_CHILD_RECURSIVELY(group, 'treeGbox_All', 'ui::CGroupBox')
                                local tree_all =
                                    GET_CHILD_RECURSIVELY(tree_box_all, 'inventree_All', 'ui::CTreeControl')
                                another_warehouse_insert_item_to_tree(frame, tree_all, invItem, itemCls, baseidcls,
                                    typeStr);

                            end
                        end
                    end
                end
            end

        end

    end
    local height = frame:GetHeight()
    for typeNo = 1, #g_invenTypeStrList do
        if not IsBlackListedTabName(g_invenTypeStrList[typeNo]) then
            local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox');
            local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo], 'ui::CTreeControl');

            tree_box:Resize(650 - 38, height - 5)

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

            tree:Resize(650 - 38, height - 5)
            tree:SetTextTooltip("Left click 10 each{nl}Right click all{nl}Hold Left Shift to specify quantity")
        end
    end
    local gbox = frame:GetChild("inventoryGbox")
    AUTO_CAST(gbox)
    gbox:Resize(650, height - 15)
    gbox:SetOffset(10, 5)
    gbox:SetSkinName("test_frame_low")

    local gbox2 = frame:GetChildRecursively("inventoryitemGbox")
    AUTO_CAST(gbox2)
    gbox2:Resize(650 - 32, height - 15)
    gbox2:SetOffset(35, 0)
end
