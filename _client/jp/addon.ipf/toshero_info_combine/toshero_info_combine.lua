function TOSHERO_INFO_COMBINE_OPEN()
    local frame = ui.GetFrame("toshero_info_combine")
    if frame == nil then
        return
    end

    local bg = GET_CHILD_RECURSIVELY(frame, "info_bg")
    if bg == nil then
        return
    end

    local height = 0
	local classList, count = GetClassList('TOSHeroBuff')
	for i = 0, count - 1 do
        local class = GetClassByIndexFromList(classList, i)
        if class == nil then
            return
        end

        if class.Material_Buff_1 ~= "None" and class.Material_Buff_2 ~= "None" and class.Material_Buff_3 ~= "None" then
            local controlSet = bg:CreateOrGetControlSet("toshero_combine_info", "combine_info"..i, ui.LEFT, ui.TOP, 10, height, 0, 0)

            for idx = 1, 3 do
                local material = TryGetProp(class, "Material_Buff_"..idx)
                local buffClass = GetClass("Buff", material)

                local slot = GET_CHILD_RECURSIVELY(controlSet, "combine_slot_"..idx)
                local name = GET_CHILD_RECURSIVELY(controlSet, "combine_name_"..idx)

                slot:SetImage("icon_"..buffClass.Icon)
                slot:SetTextTooltip(buffClass.ToolTip)

                name:SetTextByKey("name", buffClass.Name)
            end

            local result = class.ClassName
            local buffClass = GetClass("Buff", result)

            local slot = GET_CHILD_RECURSIVELY(controlSet, "combine_result")
            local name = GET_CHILD_RECURSIVELY(controlSet, "combine_name_result")

            slot:SetImage("icon_"..buffClass.Icon)
            slot:SetTextTooltip(buffClass.ToolTip)

            name:SetTextByKey("name", buffClass.Name)

            height = height + controlSet:GetHeight() - 30
        end
	end
end