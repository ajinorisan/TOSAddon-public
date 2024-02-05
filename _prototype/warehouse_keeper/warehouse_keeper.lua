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

    addon:RegisterMsg('OPEN_DLG_ACCOUNTWAREHOUSE', 'warehouse_keeper_reserve')
    warehouse_keeper_load_settings()
    ReserveScript('warehouse_keeper_4sec()', 4.0)

end

function warehouse_keeper_reserve()

    ReserveScript('warehouse_keeper_silver()', 0.5)
    ReserveScript('warehouse_keeper_item()', 1.0)
end

function warehouse_keeper_get_goal_index(frame)
    local tab = GET_CHILD(frame, "accountwarehouse_tab");
    local gbox = GET_CHILD_RECURSIVELY(frame, "gbox")
    local index = 0
    local left0 = 0
    local right0 = 0
    tab:SelectTab(0)
    local itemcnt = GET_CHILD(gbox, "itemcnt")
    local length = #itemcnt:GetText()
    print(itemcnt:GetText())
    right0 = string.sub(itemcnt:GetText(), length - 4, length - 3) * 1 -- 左側の数字を取得
    if length == 14 then
        left0 = string.sub(itemcnt:GetText(), length - 6, length - 6) * 1 -- 左側の数字を取得
    else
        left0 = string.sub(itemcnt:GetText(), length - 7, length - 6) * 1 -- 左側の数字を取得
    end

    for i = 4, 0, -1 do
        print("i")
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

            if left4 < 70 then
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

            if left3 < 70 then
                index = right0 + 210
                return index
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

            if left2 < 70 then
                index = right0 + 140
                return index
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

            if left1 < 70 then
                index = right0 + 70
                return index
            end
        elseif i == 0 then
            tab:SelectTab(0)
            if left0 < right0 then
                index = left0
                return index
            end
        else
            ui.SysMsg(ClMsg('CannotPutBecauseMaxSlot'));
            return
        end
    end

end

function warehouse_keeper_item()

    local frame = ui.GetFrame("accountwarehouse");
    local fromFrame = ui.GetFrame("inventory");
    local handle = frame:GetUserIValue('HANDLE')

    if frame:IsVisible() == 1 then
        -- print("test")
        local goal_index = warehouse_keeper_get_goal_index(frame)

        for key, value in pairs(g.settings.items) do
            -- print("Key:" .. key)
            for k, v in pairs(value) do
                print("  " .. k .. ":" .. v)
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
                        print(count .. "aaa")
                        item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, iesid, tostring(count), handle, goal_index)
                        session.ResetItemList()
                        ReserveScript("warehouse_keeper_item()", 0.3)
                        -- break
                        return
                    end
                    -- 
                end
            end
        end
    end

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

function warehouse_keeper_4sec()
    print("4sec")
    warehouse_keeper_warehouseframe_setting()
end

-- Deposit --Withdraw
function warehouse_keeper_warehouseframe_setting()
    print("setting")
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
        print("Key:" .. key)
        for k, v in pairs(value) do
            print("  " .. k .. ":" .. v .. ":" .. type)
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

    print(tostring(type))
    print(tostring(index))

    print(count)
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
    print(tostring(g.settings.silver))
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
