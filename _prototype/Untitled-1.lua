acutil.setupEvent(addon, "ON_OPEN_ACCOUNTWAREHOUSE", "another_warehouse_get_itemlist")

function another_warehouse_get_itemlist()
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetSortedGuidList();
    local sortedCnt = sortedGuidList:Count();
    local temp_warehouse = {}
    for i = 0, sortedCnt - 1 do
        local guid = sortedGuidList:Get(i);
        local Item = itemList:GetItemByGuid(guid);
        local obj = GetIES(Item:GetObject())
        if obj.ClassName == MONEY_NAME then
            temp_warehouse[0] = {
                clsid = obj.ClassID,
                clsname = obj.ClassName,
                count = Item.count,
                iesid = Item:GetIESID()
            }
        else
            temp_warehouse[i + 1] = {
                clsid = obj.ClassID,
                clsname = obj.ClassName,
                count = Item.count,
                iesid = Item:GetIESID()
            }
        end
    end

    -- temp_warehouseの中身を表示する
    for index, item in pairs(temp_warehouse) do
        print(string.format("Index: %d, ClassID: %d, ClassName: %s, Count: %d, IESID: %s", index, item.clsid,
                            item.clsname, item.count, item.iesid))
    end

end
