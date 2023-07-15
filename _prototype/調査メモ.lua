-- invItemはGET_PC_ITEM_BY_GUID()でGUIDを取得する必要ある
function ACCOUNT_WAREHOUSE_INV_RBTN(itemObj, slot)

    local frame = ui.GetFrame("accountwarehouse");
    local icon = slot:GetIcon();
    local iconInfo = icon:GetInfo();
    local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());
    local obj = GetIES(invItem:GetObject());
    if CHECK_EMPTYSLOT(frame, obj) == 1 then
        return
    end

    local fromFrame = slot:GetTopParentFrame();
    if fromFrame:GetName() == "inventory" then
        PUT_ACCOUNT_ITEM_TO_WAREHOUSE_BY_INVITEM(frame, invItem, nil, fromFrame)
    end
end

-- これのsession.AddItemID(iconInfo:GetIESID(), slot:GetSelectCount());を書き換えたらいけそう
function ACCOUNT_WAREHOUSE_RECEIVE_ITEM(parent, slot)
    local frame = parent:GetTopParentFrame();
    local slotset = GET_CHILD_RECURSIVELY(frame, "slotset");
    if slotset == nil then
        local gbox_warehouse = GET_CHILD_RECURSIVELY(frame, "gbox_warehouse");
        slotset = GET_CHILD_RECURSIVELY(frame, "slotset");
    end
    session.ResetItemList();
    AUTO_CAST(slotset);
    for i = 0, slotset:GetSelectedSlotCount() - 1 do
        local slot = slotset:GetSelectedSlot(i)
        local Icon = slot:GetIcon();
        local iconInfo = Icon:GetInfo();

        session.AddItemID(iconInfo:GetIESID(), slot:GetSelectCount());

    end

    if session.GetItemIDList():Count() == 0 then
        ui.MsgBox(ScpArgMsg("SelectItemByMouseLeftButton"));
        return;
    end

    local str = ScpArgMsg("TradeCountWillBeConsumedBy{Value}_Continue?", "Value", "1");
    local msgbox = ui.MsgBox(str, "_EXEC_ACCOUNT_WAREHOUSE_RECEIVE_ITEM", "None");
    SET_MODAL_MSGBOX(msgbox)
end

-- CHATGPT
session.ResetItemList() -- アイテムリストをリセット

local itemA_IESID = "アイテムAのIESID" -- アイテムAのIESIDを取得する方法に応じて置き換える
local itemB_IESID = "アイテムBのIESID" -- アイテムBのIESIDを取得する方法に応じて置き換える

session.AddItemID(itemA_IESID) -- アイテムAのIESIDをアイテムリストに追加
session.AddItemID(itemB_IESID) -- アイテムBのIESIDをアイテムリストに追加

local itemList = session.GetItemIDList() -- アイテムリストを取得

-- アイテムリストを使用してアイテムを処理するなどの操作を行う
for i = 0, itemList:Count() - 1 do
    local itemID = itemList:GetItemIDByIndex(i)
    -- アイテムの処理を行う
end

for i = 0, warehouseCount - 1 do -- gemidからIESIDを取得するコード。合ってるんか？
    local item = warehouse:GetItemByIndex(i)
    local itemIESID = item.ClassID -- IESIDの取得　tonumber(g.gemid)
    -- itemIESIDを使って個別の処理を行う
    -- 例: CHAT_SYSTEM(itemIESID)
end
