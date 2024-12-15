function CUPOLE_EXTERNAL_ADDON_ON_INIT(addon, frame)
    addon:RegisterMsg('CUPOLE_EQUIP_COMPLELTE', 'TOGGLE_CUPOLE_EXTERNAL_ADDON');
end

function TOGGLE_CUPOLE_EXTERNAL_ADDON(frame, msg, argStr, argNum)
    local list = StringSplit(argStr, ';')
    local index = tonumber(list[1])
    local itemid = GET_CUPOLE_SPECIAL_ITEMS(nil, index)
    if itemid < 0  then
        frame:ShowWindow(0)
    else
        frame:ShowWindow(1)
    end
end