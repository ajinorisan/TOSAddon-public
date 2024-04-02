function another_warehouse_item()

    local warehouseFrame = ui.GetFrame('accountwarehouse')
    local handle = warehouseFrame:GetUserIValue('HANDLE')

    local ivframe = ui.GetFrame("inventory");
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList();
    local cnt = guidList:Count();

    local itemProcessed = false -- アイテムが処理されたかどうかを示すフラグ
    local putitemtbl = {} -- アイテム情報を格納するテーブル
    local takeitemtbl = {}

    for k, v in pairs(g.settings.items) do
        local clsID = v.clsid
        local count = v.count
        if warehouseFrame:IsVisible() == 1 then
            for i = 0, cnt - 1 do
                local guid = guidList:Get(i)
                local invItem = invItemList:GetItemByGuid(guid)
                local itemobj = GetIES(invItem:GetObject())
                local invClsID = itemobj.ClassID
                local itemCls = GetClassByType('Item', invClsID)

                if clsID == invClsID then

                    if count == 0 then

                        putitemtbl[clsID] = {
                            iesid = guid,
                            count = invItem.count,
                            handle = handle

                        } -- アイテム情報をテーブルに格納
                        itemProcessed = true -- アイテムが処理されたことをフラグに記録
                        break -- 内側のループを抜ける

                    end

                    local item_count = 0

                    if count ~= 0 then
                        item_count = invItem.count - count
                        if invItem.count > count then

                            putitemtbl[clsID] = {
                                iesid = guid,
                                count = item_count,
                                handle = handle

                            }
                            itemProcessed = true -- アイテムが処理されたことをフラグに記録
                            break -- 内側のループを抜ける

                        elseif invItem.count < count then

                            takeitemtbll[guid] = item_count
                            itemProcessed = true -- アイテムが処理されたことをフラグに記録
                            break -- 内側のループを抜ける

                        end
                    end
                end
            end
        else
            return
        end

        if itemProcessed then
            ReserveScript("another_warehouse_item_tooltip_close()", 3.0)
            break -- 外側のループも抜ける
        end
    end

end

item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, guid, tostring(invItem.count), handle, goal_index)
another_warehouse_item_tooltip(itemCls, invItem)

