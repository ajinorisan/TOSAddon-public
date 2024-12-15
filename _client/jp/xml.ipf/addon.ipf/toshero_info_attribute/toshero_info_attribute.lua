function TOSHERO_INFO_ATTRIBUTE_ON_INIT(addon, frame)
    addon:RegisterMsg('TOSHERO_INFO_GET', 'ON_TOSHERO_INFO_ATTRIBUTE_GET')
end

-- AddOnMsg
function ON_TOSHERO_INFO_ATTRIBUTE_GET()
    TOSHERO_INFO_ATTRIBUTE_SET()
end

-- Open/Close
function TOSHERO_INFO_ATTRIBUTE_OPEN()
    TOSHERO_INFO_ATTRIBUTE_SET()
end

function TOSHERO_INFO_ATTRIBUTE_SET()
    local frame = ui.GetFrame('toshero_info_attribute')
    if frame == nil then
        return
    end

    local attribute = GetTOSHeroAttribute()

    for i = 2, 4 do
        if attribute == i then
            GET_CHILD_RECURSIVELY(frame, "attribute_"..i):SetColorTone("00000000")
        else
            GET_CHILD_RECURSIVELY(frame, "attribute_"..i):SetColorTone("FF333333")
        end
    end
end

-- Request
function OPEN_TOSHERO_INFO_ATTRIBUTE()
    local frame = ui.GetFrame('toshero_info_attribute')
    if frame == nil then
        return
    end

    if frame:IsVisible() == 0 then
        ui.OpenFrame('toshero_info_attribute')
    else
        ui.CloseFrame('toshero_info_attribute')
    end
end

function TOSHERO_INFO_ATTRIBUTE_REQUEST_SELECT(parent, self, argStr, attribute)
    if attribute ~= GetTOSHeroAttribute() then
        if 5 == GetTOSHeroAttribute() then
            local msg = ClMsg("TOSHeroSelectChaosAttribute");
            local yesscp = string.format('TOSHERO_INFO_ATTRIBUTE_SELECT_CHAOS(%d)', attribute);
            ui.MsgBox_NonNested(msg, parent:GetName(), yesscp, 'None');
        else
            toshero.RequestChangeAttribute(attribute)
        end
    else
        ui.SysMsg(ClMsg("TOSHeroAlreadySelectAttribute"));
    end
end

function TOSHERO_INFO_ATTRIBUTE_SELECT_CHAOS(type)
    toshero.RequestChangeAttribute(type)
end