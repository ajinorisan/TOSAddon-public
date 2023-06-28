ITEM_EQUIP(argNum); -- 2101

function GetInvIndexByIESID(iesID)
    local itemList = session.GetInvItemList()
    local count = itemList:size()
    for i = 0, count - 1 do
        local invItem = itemList:GetItemByIndex(i)
        if invItem:GetIESID() == iesID then
            return invItem.index -- 'Index' の先頭の文字を小文字に修正
        end
    end
    return 0 -- 該当のアイテムが見つからなかった場合は適切な値を返します
end

local index = GetInvIndexByIESID(g.rh_guid)
ITEM_EQUIP(index);

-- https://github.com/ajinorisan/TOSAddon-public/blob/db59a3570688bf3a4ab391312c5c3fc6ac3e01fb/_client/jp/ui.ipf/uiscp/lib_inventory.lua#L17
function GET_SLOT_ITEM(slot)
    slot = AUTO_CAST(slot);
    local icon = slot:GetIcon();
    if icon == nil then
        return nil;
    end

    local iconInfo = icon:GetInfo();
    if iconInfo:GetIESID() ~= "0" then
        return GET_PC_ITEM_BY_GUID(iconInfo:GetIESID()), iconInfo.count
    else
        return GET_PC_ITEM_BY_GUID(slot:GetTooltipIESID()), iconInfo.count
    end
end

function GET_PC_ITEM_BY_GUID(guid)
    local invItem = session.GetInvItemByGuid(guid);
    if invItem ~= nil then
        return invItem, nil;
    end

    local eqpItem = session.GetEquipItemByGuid(guid);
    if eqpItem ~= nil then
        return eqpItem, 1;
    end
    return nil;

end
