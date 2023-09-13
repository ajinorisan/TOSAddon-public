-- YAI
local addonName = "YAACCOUNTINVENTORY"
local addonNameLower = string.lower(addonName)
-- 作者名
local author = 'ebisuke'

-- アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')

-- ライブラリ読み込み

function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function EBI_IsNoneOrNil(val)
    return val == nil or val == "None" or val == "nil"
end

local function DBGOUT(msg)

    EBI_try_catch {
        try = function()
            if (g.debug == true) then
                CHAT_SYSTEM(msg)

                print(msg)
                local fd = io.open(g.logpath, "a")
                fd:write(msg .. "\n")
                fd:flush()
                fd:close()

            end
        end,
        catch = function(error)
        end
    }

end
local function ERROUT(msg)
    EBI_try_catch {
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }

end

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

function YAIREPLACEMENT_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()

        end,
        catch = function(error)
            ERROUT(error)
        end
    }
    addon:RegisterMsg("OPEN_DLG_ACCOUNTWAREHOUSE", "YAI_ON_OPEN_ACCOUNTWAREHOUSE");
    g.SetupHook(YAI_NORI_PUT_ACCOUNT_ITEM_TO_WAREHOUSE_BY_INVITEM_MSG_YESSCP,
                "PUT_ACCOUNT_ITEM_TO_WAREHOUSE_BY_INVITEM_MSG_YESSCP")
    g.SetupHook(YAI_NORI_PUT_ACCOUNT_ITEM_TO_WAREHOUSE_BY_INVITEM, "PUT_ACCOUNT_ITEM_TO_WAREHOUSE_BY_INVITEM")
    g.SetupHook(YAI_NORI_EXEC_PUT_ITEM_TO_ACCOUNT_WAREHOUSE, "EXEC_PUT_ITEM_TO_ACCOUNT_WAREHOUSE")

end

local new_add_item = {}
local new_stack_add_item = {}
local max_slot_per_tab = account_warehouse.get_max_slot_per_tab()

function YAI_NORI_CHECK_ACCOUNT_WAREHOUSE_SLOT_COUNT_TO_PUT(insertItem)
    local index = YAI_get_valid_index()
    local account = session.barrack.GetMyAccount();
    local slotCount = account:GetAccountWarehouseSlotCount();
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

    if is_exist_stack_item == false and (slotCount <= itemCnt and index < max_slot_per_tab) then
        CHAT_SYSTEM("test1")
        ui.SysMsg(ClMsg('CannotPutBecauseMaxSlot'));
        return false;
    end

    if is_exist_stack_item == false and (slotCount <= index and index < max_slot_per_tab) then
        CHAT_SYSTEM("test2")
        ui.SysMsg(ClMsg('CannotPutBecauseMaxSlot'));
        return false;
    end
    return true;
end

function YAI_NORI_EXEC_PUT_ITEM_TO_ACCOUNT_WAREHOUSE(frame, count, inputframe)
    inputframe:ShowWindow(0);
    local iesid = inputframe:GetUserValue("ArgString");
    local insertItem = GetObjectByGuid(iesid);
    if YAI_NORI_CHECK_ACCOUNT_WAREHOUSE_SLOT_COUNT_TO_PUT(insertItem) == false then
        return;
    end

    -- godl_index
    local goal_index = YAI_get_valid_index()
    local exist, index = YAI_get_exist_item_index(insertItem)
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

function YAI_NORI_PUT_ACCOUNT_ITEM_TO_WAREHOUSE_BY_INVITEM_MSG_YESSCP(guid, count)
    local frame = ui.GetFrame("accountwarehouse");
    local invItem = GET_PC_ITEM_BY_GUID(guid);
    if invItem == nil then
        return;
    end

    local obj = GetIES(invItem:GetObject());

    if YAI_NORI_CHECK_ACCOUNT_WAREHOUSE_SLOT_COUNT_TO_PUT(obj) == false then
        return;
    end

    if CHECK_EMPTYSLOT(frame, obj) == 1 then
        return
    end

    local goal_index = YAI_get_valid_index()
    item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, guid, count, frame:GetUserIValue("HANDLE"), goal_index)
end

function YAI_NORI_PUT_ACCOUNT_ITEM_TO_WAREHOUSE_BY_INVITEM(frame, invItem, slot, fromFrame)
    local obj = GetIES(invItem:GetObject())
    if YAI_NORI_CHECK_ACCOUNT_WAREHOUSE_SLOT_COUNT_TO_PUT(obj) == false then
        return;
    end

    if CHECK_EMPTYSLOT(frame, obj) == 1 then
        return
    end

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
            INPUT_NUMBER_BOX(frame, ScpArgMsg("InputCount"), "EXEC_PUT_ITEM_TO_ACCOUNT_WAREHOUSE", maxCnt, 1, maxCnt,
                             nil, tostring(invItem:GetIESID()));
        else
            if maxCnt <= 0 then
                ui.SysMsg(ClMsg("ItemIsNotTradable"));
                return;
            end

            -- goal_index
            local goal_index = YAI_get_valid_index()

            -- Check Life Time
            if invItem.hasLifeTime == true then
                local yesscp = string.format('PUT_ACCOUNT_ITEM_TO_WAREHOUSE_BY_INVITEM_MSG_YESSCP("%s", "%s")',
                                             invItem:GetIESID(), tostring(invItem.count));
                ui.MsgBox(ScpArgMsg('PutLifeTimeItemInWareHouse{NAME}', 'NAME', itemCls.Name), yesscp, 'None');
                return;
            end

            -- 아이템 입고 요청
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, invItem:GetIESID(), tostring(invItem.count),
                                    frame:GetUserIValue("HANDLE"), goal_index)

            -- new 표시
            new_add_item[#new_add_item + 1] = invItem:GetIESID()
            if geItemTable.IsStack(obj.ClassID) == 1 then
                new_stack_add_item[#new_stack_add_item + 1] = obj.ClassID
            end
        end
    else
        if slot ~= nil then
            AUTO_CAST(slot);
            local iconSlot = liftIcon:GetParent();
            AUTO_CAST(iconSlot);
            item.SwapSlotIndex(IT_ACCOUNT_WAREHOUSE, slot:GetSlotIndex(), iconSlot:GetSlotIndex());
            ON_ACCOUNT_WAREHOUSE_ITEM_LIST(frame);
        end
    end
end

local function L_(str)
    if (g.notrans) then
        return str
    end
    if (IsJpn() and YETANOTHERACCOUNTINVENTORY_LANGUAGE_DATA[str]) then
        return YETANOTHERACCOUNTINVENTORY_LANGUAGE_DATA[str].jpn
    elseif (YETANOTHERACCOUNTINVENTORY_LANGUAGE_DATA[str] and YETANOTHERACCOUNTINVENTORY_LANGUAGE_DATA[str].eng) then
        return YETANOTHERACCOUNTINVENTORY_LANGUAGE_DATA[str].eng
    else
        return str
    end
end

function YAI_ON_OPEN_ACCOUNTWAREHOUSE()
    EBI_try_catch {
        try = function()
            local frame = ui.GetFrame("accountwarehouse")
            local overlap = ui.GetFrame("yaireplacement")
            overlap:SetSkinName("None")
            overlap:ShowWindow(1)
            if (g.debug) then
                overlap:SetOffset(10, 600)
                -- タブ非表示
                frame:GetChildRecursively("accountwarehouse_tab"):ShowWindow(1)
                frame:GetChildRecursively("slotgbox"):ShowWindow(1)
                frame:GetChildRecursively("slotset"):ShowWindow(1)
                frame:GetChildRecursively("receiveitem"):ShowWindow(1)
            else
                overlap:SetOffset(10, 200)
                -- タブ非表示
                frame:GetChildRecursively("accountwarehouse_tab"):ShowWindow(0)
                frame:GetChildRecursively("slotgbox"):ShowWindow(0)
                frame:GetChildRecursively("slotset"):ShowWindow(0)
                frame:GetChildRecursively("receiveitem"):ShowWindow(0)
            end

            overlap:EnableHitTest(1)
            overlap:EnableHittestFrame(1)
            -- fix height
            g.h = frame:GetHeight() - 1080 + 570
            local w = g.w
            local h = g.h
            overlap:Resize(w, h + 300)
            frame:SetLayerLevel(94)
            overlap:EnableHittestFrame(false)

            overlap:SetLayerLevel(95)
            local gbox = overlap:GetChild("inventoryGbox")
            AUTO_CAST(gbox)
            local gbox2 = overlap:GetChildRecursively("inventoryitemGbox")
            AUTO_CAST(gbox2)

            gbox:Resize(w, h - 5)
            gbox2:Resize(w - 32, h - 5)
            -- gbox2:SetFrameScrollBarOffset(0, -200)

            -- search gbox
            --[[
                <groupbox name="searchSkin" parent="searchGbox" rect="0 0 350 30" margin="5 0 0 5" layout_gravity="right bottom" draw="true" hittestbox="true" resizebyparent="false" scrollbar="false" skin="test_edit_skin"/>
                <edit name="ItemSearch" parent="searchSkin" rect="0 0 270 26" margin="2 0 0 0" layout_gravity="left center" OffsetForDraw="0 -1" clicksound="button_click_big" drawbackground="false" fontname="white_18_ol" maxlen="40" oversound="button_over" skin="None" textalign="left top" typingscp="SEARCH_ITEM_INVENTORY_KEY" typingsound="chat_typing"/>
                <button name="inventory_serch" parent="searchSkin" rect="0 0 60 38" margin="0 0 0 0" layout_gravity="right center" LBtnUpArgNum="" LBtnUpScp="SEARCH_ITEM_INVENTORY" MouseOffAnim="btn_mouseoff" MouseOnAnim="btn_mouseover" clicksound="button_click_big" image="inven_s" oversound="button_over" stretch="true" texttooltip="{@st59}입력한 이름으로 검색합니다{/}"/>
                
                
            ]]
            --[[!local searchgbox = overlap:CreateOrGetControl("groupbox", "searchGbox", 10, h - 35, w, 35)

            local searchSkin = searchgbox:CreateOrGetControl("groupbox", "searchSkin", 0, 5, w, 30)
            AUTO_CAST(searchgbox)
            AUTO_CAST(searchSkin)
            searchSkin:SetSkinName("test_edit_skin")
            local ItemSearch = searchSkin:CreateOrGetControl("edit", "ItemSearch", 0, 0, w - 60, 30)
            AUTO_CAST(ItemSearch)
            ItemSearch:SetFontName("white_18_ol")
            ItemSearch:SetTypingSound("chat_typing")
            ItemSearch:SetOverSound("button_over")
            ItemSearch:SetSkinName("None")
            ItemSearch:SetEventScript(ui.ENTERKEY, "YAI_ON_ENTER_SEARCH")
            local inventory_serch = searchSkin:CreateOrGetControl("button", "inventory_serch", w - 58, -2, 60, 30)
            AUTO_CAST(inventory_serch)
            inventory_serch:SetOverSound("button_over")
            inventory_serch:SetClickSound("button_click_big")
            inventory_serch:SetImage("inven_s")
            inventory_serch:EnableImageStretch(true)
            inventory_serch:SetEventScript(ui.LBUTTONUP, "YAI_ON_SEARCH")]]
            -- YAI config
            local btn = frame:CreateOrGetControl("button", "yaiconfig", 400, 80 + 40, 100, 30)
            AUTO_CAST(btn)
            btn:SetText("{ol}" .. L_("YAI Config"))
            btn:SetEventScript(ui.LBUTTONUP, "YAI_OPEN_CONFIG")
            -- !g.searcher = libsearch.Searcher()
            -- !g.suggester = libsearch.SuggestLister():init(g.searcher, ItemSearch, "yaisearch")

            new_add_item = {}
            new_stack_add_item = {}

            YAI_UPDATE()

        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

