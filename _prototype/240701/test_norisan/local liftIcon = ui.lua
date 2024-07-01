local liftIcon = ui.GetLiftIcon()
local iconInfo = liftIcon:GetInfo();
local guid = iconInfo:GetIESID();
local invItem = GET_ITEM_BY_GUID(guid);
local obj = GetIES(invItem:GetObject());
for i = 1, 3 do
    local propName = "HatPropName_" .. i;
    local propValue = "HatPropValue_" .. i;
    print(tostring(obj[propName]))
    print(tostring(obj[propValue]))
end
