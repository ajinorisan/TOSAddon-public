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

    if not settings then
        g.settings = {
            silver = 1000000
        }
        warehouse_keeper_save_settings()
    else
        g.settings = settings
    end

end

if not g.loded then
    g.settings = {
        silver = 1000000
    }
    warehouse_keeper_save_settings()
end

function WAREHOUSE_KEEPER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    if not g.loded then
        g.loded = true
    end
    addon:RegisterMsg('OPEN_DLG_ACCOUNTWAREHOUSE', 'warehouse_keeper_arrange')
    ReserveScript('warehouse_keeper_4sec()', 4.0)

end

local function get_valid_index(i)
    local max_slot_per_tab = account_warehouse.get_max_slot_per_tab()

    print("test")
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetSortedGuidList();
    local sortedCnt = sortedGuidList:Count();

    local start_index = (i * max_slot_per_tab)
    local last_index = (start_index + max_slot_per_tab) - 1

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

function warehouse_keeper_arrange()
    ReserveScript('warehouse_keeper_arrange_silver()', 0.5)
end

function warehouse_keeper_arrange_silver()

    for i = 0, 4 do
        local goal_index = get_valid_index(i);
        print(goal_index)
    end
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
    warehouse_keeper_warehouseframe_setting()
end

-- Deposit --Withdraw
function warehouse_keeper_warehouseframe_setting()
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
    team_slotset:SetColRow(17, 10) -- スロットの配置と個数
    team_slotset:SetSpc(0, 0)
    team_slotset:SetSkinName('slot')
    team_slotset:CreateSlots()

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

    -- team_slotset:SetColRow(5, 4); -- (5x4 grid)

end
