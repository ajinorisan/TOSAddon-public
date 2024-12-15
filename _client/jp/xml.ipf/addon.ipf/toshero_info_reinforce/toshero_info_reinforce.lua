function TOSHERO_INFO_REINFORCE_ON_INIT(addon, frame)
    addon:RegisterMsg('TOSHERO_INFO_GET', 'ON_TOSHERO_INFO_REINFORCE_GET')
    addon:RegisterMsg('TOSHERO_INFO_POINT', 'ON_TOSHERO_INFO_REINFORCE_POINT')
end

-- AddOnMsg
function ON_TOSHERO_INFO_REINFORCE_GET()
    TOSHERO_INFO_REINFORCE_SET()
    TOSHERO_INFO_REINFORCE_SET_POINT()
end

function ON_TOSHERO_INFO_REINFORCE_POINT()
    TOSHERO_INFO_REINFORCE_SET_POINT()
end

-- Open/Close
function TOSHERO_INFO_REINFORCE_OPEN()
    TOSHERO_INFO_REINFORCE_SET_POINT()
    TOSHERO_INFO_REINFORCE_REMOVE_EQUIP()
end

function TOSHERO_INFO_REINFORCE_SET()
    local frame = ui.GetFrame('toshero_info_reinforce')
    if frame == nil then
        return TOSHERO_INFO_REINFORCE_CLEAR()
    end

    local slot = GET_CHILD_RECURSIVELY(frame, "equip")
    local icon = slot:GetIcon()
    if icon == nil then
        return TOSHERO_INFO_REINFORCE_CLEAR()
    end

    local iconInfo = icon:GetInfo()
    local invItem = GET_ITEM_BY_GUID(iconInfo:GetIESID())
    local invItemObj = GetIES(invItem:GetObject())

    local height = tonumber(frame:GetUserConfig("BASE_HEIGHT"))
    local enableReinforce = true

    for idx = 1, 2 do
        local controlSet = GET_CHILD_RECURSIVELY(frame, "tooltip_set_"..idx)
        local optionText = GET_CHILD_RECURSIVELY(controlSet, "option_text")
        local optionButton = GET_CHILD_RECURSIVELY(controlSet, "option_button")
        local TOSHeroEquipOption = TryGetProp(invItemObj, 'TOSHeroEquipOption_' .. tostring(idx), 'None')
        
        if TOSHeroEquipOption ~= 'None' then
            local cls = GetClass('TOSHeroEquipOption', TOSHeroEquipOption)
            local text = TryGetProp(cls, 'EffectDesc', 'None')

            optionText:SetText(text)

            optionButton:SetImage(frame:GetUserConfig("OPTION_CHANGE_BUTTON"))
            optionButton:SetVisible(1)
            optionButton:SetEventScript(ui.LBUTTONUP, 'TOSHERO_INFO_REINFORCE_REQUEST_CHANGE')
            optionButton:SetEventScriptArgNumber(ui.LBUTTONUP, idx - 1)
            optionButton:SetTextTooltip(_G["TOSHERO_EQUIP_OPTION_CHANGE_PRICE"]..ClMsg("POINT"))
        else
            if enableReinforce == true then
                optionText:SetText(frame:GetUserConfig("DEFAULT_TEXT"))

                optionButton:SetImage(frame:GetUserConfig("OPTION_ADD_BUTTON"))
                optionButton:SetVisible(1)
                optionButton:SetEventScript(ui.LBUTTONUP, 'TOSHERO_INFO_REINFORCE_REQUEST_ADD')
                optionButton:SetTextTooltip(_G["TOSHERO_EQUIP_OPTION_OPEN_SLOT_"..idx.."_PRICE"]..ClMsg("POINT"))

                enableReinforce = false
            else
                optionText:SetText(" ")
                optionButton:SetVisible(0)
            end
        end

        controlSet:Resize(controlSet:GetWidth(), optionText:GetHeight() + 20)
        controlSet:SetMargin(0, height, 0, 0)

        height = height + optionText:GetHeight() + 30
    end

    frame:Resize(frame:GetWidth(), height + 50)
end

function TOSHERO_INFO_REINFORCE_SET_POINT()
    local frame = ui.GetFrame('toshero_info_reinforce')
    if frame == nil then
        return
    end

    local point = GET_CHILD_RECURSIVELY(frame, 'point_info')
    local nowPoint = GetTOSHeroPoint()

    point:SetTextByKey("point", GET_COMMAED_STRING(nowPoint))
end

function TOSHERO_INFO_REINFORCE_CLEAR()
    local frame = ui.GetFrame('toshero_info_reinforce')
    if frame == nil then
        return
    end

    local height = tonumber(frame:GetUserConfig("BASE_HEIGHT"))

    for idx = 1, 2 do
        frame:RemoveChild('tooltip_set_'..idx)

        local controlSet = frame:CreateOrGetControlSet("toshero_equip_tooltip", 'tooltip_set_'..idx, ui.CENTER_HORZ, ui.TOP, 0, height, 0, 0)
        local button = GET_CHILD_RECURSIVELY(controlSet, "option_button")

        button:SetVisible(0)
        height = height + 53
    end

    frame:Resize(frame:GetWidth(), height + 50)
end

function TOSHERO_INFO_REINFORCE_DROP_EQUIP(parent, self, argStr, argNum)
	if ui.CheckHoldedUI() == true then
		return
    end
    
	local liftIcon = ui.GetLiftIcon()
    local fromFrame = liftIcon:GetTopParentFrame()
    
    if fromFrame:GetName() == 'inventory' then
        local iconInfo = liftIcon:GetInfo()
        local itemID = iconInfo:GetIESID()

        local invItem = session.GetInvItemByGuid(itemID)
        if invItem == nil then
            return
        end

        if TryGetProp(GetIES(invItem:GetObject()), "StringArg", "None") ~= "TOSHeroEquip" then
            ui.SysMsg(ClMsg("TOSHeroCanNotReinforceItem"));
            return
        end

        local frame = ui.GetFrame('toshero_info_reinforce')
        local slot = GET_CHILD_RECURSIVELY(frame, "equip")

        SET_SLOT_ITEM(slot, invItem)
        TOSHERO_INFO_REINFORCE_SET()
	end
end

function TOSHERO_INFO_REINFORCE_REMOVE_EQUIP()
	if ui.CheckHoldedUI() == true then
		return
    end

    local frame = ui.GetFrame('toshero_info_reinforce')
    local slot = GET_CHILD_RECURSIVELY(frame, "equip")

    slot:ClearIcon()

    TOSHERO_INFO_REINFORCE_CLEAR()
end

-- Request
function OPEN_TOSHERO_INFO_REINFORCE()
    local frame = ui.GetFrame('toshero_info_reinforce')
    if frame == nil then
        return
    end

    if frame:IsVisible() == 0 then
        ui.OpenFrame('toshero_info_reinforce')
    else
        ui.CloseFrame('toshero_info_reinforce')
    end
end

function TOSHERO_INFO_REINFORCE_REQUEST_ADD()
    local frame = ui.GetFrame('toshero_info_reinforce')
    local slot = GET_CHILD_RECURSIVELY(frame, "equip")

    local icon = slot:GetIcon()
    if icon == nil then
        return
    end

    local info = icon:GetInfo()
    local itemID = info:GetIESID()
    local invItem = session.GetInvItemByGuid(itemID)

    if invItem == nil then
        return
    end

    g_toshero_reinforce_image = TryGetProp(GetIES(invItem:GetObject()), "Icon", "None") -- toshero_info.lua image setting

    toshero.RequestReinforce(itemID)
	
	imcSound.PlaySoundEvent("sys_class_change")
	slot:PlayUIEffect('UI_item_parts', 1.2, 'DO_SUCCESS_EFFECT')
	ReserveScript("_TOSHERO_INFO_REINFORCE_REQUEST_CHANGE()", 1)
end

function TOSHERO_INFO_REINFORCE_REQUEST_CHANGE(parent, self, argStr, index)
    local frame = ui.GetFrame('toshero_info_reinforce')
    local slot = GET_CHILD_RECURSIVELY(frame, "equip")

    local icon = slot:GetIcon()
    if icon == nil then
        return
    end

    local info = icon:GetInfo()
    local itemID = info:GetIESID()
    local invItem = session.GetInvItemByGuid(itemID)

    if invItem == nil then
        return
    end

    g_toshero_reinforce_image = TryGetProp(GetIES(invItem:GetObject()), "Icon", "None") -- toshero_info.lua image setting

    toshero.RequestChangeEquipOption(itemID, index)

	imcSound.PlaySoundEvent("sys_class_change")
	slot:PlayUIEffect('UI_item_parts', 1.2, 'DO_SUCCESS_EFFECT')
	ReserveScript("_TOSHERO_INFO_REINFORCE_REQUEST_CHANGE()", 1)
end

function _TOSHERO_INFO_REINFORCE_REQUEST_CHANGE()
	local frame = ui.GetFrame("toshero_info_reinforce")
	if frame:IsVisible() == 0 then
		return
	end
	
	local slot = GET_CHILD_RECURSIVELY(frame, 'equip')
	if slot == nil then
		return
	end
	
	slot:StopUIEffect('DO_SUCCESS_EFFECT', true, 0.5)
end