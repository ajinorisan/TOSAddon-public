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
