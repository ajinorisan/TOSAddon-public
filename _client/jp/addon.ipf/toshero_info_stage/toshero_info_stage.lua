function TOSHERO_INFO_STAGE_ON_INIT(addon, frame)
    addon:RegisterMsg('TOSHERO_STAGE_START', 'ON_TOSHERO_STAGE_START')
end

function ON_TOSHERO_STAGE_START(frame, msg, argStr, stage)
    ui.OpenFrame("fulldark")
    ui.OpenFrame("toshero_info_stage")

    local frame = ui.GetFrame("toshero_info_stage")
    if frame == nil then
        return
    end

    -- 스테이지 표기
    local title = GET_CHILD_RECURSIVELY(frame, "title_txt")

    title:SetTextByKey("stage", stage)

    -- 속성 표기
    local argList = StringSplit(argStr, "/")
    local attribute = GET_CHILD_RECURSIVELY(frame, "attribute")
    local attributeClass = GetClass("TOSHeroAttribute", argList[1])

    attribute:SetImage(attributeClass.Image)

    -- 버프 표기
    local shadow = GET_CHILD_RECURSIVELY(frame, "shadow")
    local width = -48 * (#argList - 2)

    shadow:RemoveAllChild()

    for idx = 2, #argList do
        local buffClass = GetClass("Buff", argList[idx])
        local pic = shadow:CreateControl("picture", "buff_"..idx, 86, 86, ui.CENTER_HORZ, ui.CENTER_VERT, width, 0, 0, 0)

        pic = tolua.cast(pic, 'ui::CPicture')
        
        pic:SetEnableStretch(1)
        pic:SetImage("icon_"..buffClass.Icon)
        pic:SetTextTooltip(buffClass.ToolTip)

        width = width + 96
    end

    ReserveScript("CLOSE_TOSHERO_INFO_STAGE()", 3);

end

function TOSHERO_INFO_STAGE_CLOSE()
    ui.CloseFrame("fulldark")
end

function CLOSE_TOSHERO_INFO_STAGE()
    ui.CloseFrame("toshero_info_stage")
    ui.CloseFrame("fulldark")
end
