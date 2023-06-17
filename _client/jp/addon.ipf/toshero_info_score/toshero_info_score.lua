function TOSHERO_INFO_SCORE_ON_INIT(addon, frame)
    addon:RegisterMsg('TOSHERO_INFO_SCORE_GET', 'ON_TOSHERO_INFO_SCORE_GET')
end

function ON_TOSHERO_INFO_SCORE_GET(frame, msg, argStr, argNum)
    ui.OpenFrame("toshero_info_score")

    local pointList = StringSplit(argStr, "/")
    local pointTotal = 0

    for idx = 1, #pointList do
        local text = GET_CHILD_RECURSIVELY(frame, "info_text_"..idx)
        if text == nil then
            return
        end

        local pointText = ""
        local point = tonumber(pointList[idx])

        if point >= 0 then
            pointText = frame:GetUserConfig("NORMAL_TEXT_STYLE") .. GET_COMMAED_STRING(point)
        else
            pointText = frame:GetUserConfig("ALTER_TEXT_STYLE") .. GET_COMMAED_STRING(point)
        end

        text:SetText(pointText)

        pointTotal = pointTotal + point
    end

    GET_CHILD_RECURSIVELY(frame, "this_score_text"):SetText(GET_COMMAED_STRING(pointTotal))
end