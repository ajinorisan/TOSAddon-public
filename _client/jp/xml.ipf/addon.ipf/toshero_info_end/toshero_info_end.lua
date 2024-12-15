function TOSHERO_INFO_END_ON_INIT(addon, frame)
    addon:RegisterMsg('TOSHERO_STAGE_END', 'ON_TOSHERO_STAGE_END')
end

function ON_TOSHERO_STAGE_END(frame, msg, type, size)
    ui.OpenFrame("fulldark")
    ui.OpenFrame("toshero_info_end")

    local frame = ui.GetFrame("toshero_info_end")
    if frame == nil then
        return
    end

    local image = nil
    local text = nil

    -- 타입 & 사이즈 설정
    if type == "Success" then
        if size == 0 then
            image = frame:GetUserConfig("SUCCESS_IMG_S")
        else
            image = frame:GetUserConfig("SUCCESS_IMG_L")
        end

        text = frame:GetUserConfig("SUCCESS_MSG")
    else
        if size == 0 then
            image = frame:GetUserConfig("FAIL_IMG_S")
        else
            image = frame:GetUserConfig("FAIL_IMG_L")
        end

        text = frame:GetUserConfig("FAIL_MSG")
    end

    -- 세팅
    GET_CHILD_RECURSIVELY(frame, "title_img"):SetImage(image)
    GET_CHILD_RECURSIVELY(frame, "title_txt"):SetTextByKey("value", text)

    -- 종료 스크립트 설정
    ReserveScript("CLOSE_TOSHERO_INFO_END()", 2);
end

function CLOSE_TOSHERO_INFO_END()
    ui.CloseFrame("toshero_info_end")
end

function TOSHERO_INFO_END_CLOSE()
    ui.CloseFrame("fulldark")
end