function GUILDCOMM_NEWCH_ON_INIT(addon, frame)
end

function GCNC_ON_OPEN(frame)
    local edit_name = GET_CHILD_RECURSIVELY(frame, "edit_name")
    edit_name:Focus()
end

function GCNC_CLOSE()
    local frame = ui.GetFrame("guildcomm_newch")
    local edit_name = GET_CHILD_RECURSIVELY(frame, "edit_name")
    edit_name:ClearText()
    GCNC_SET_PRIVATE(frame, false)
    ui.CloseFrame("guildcomm_newch")
end

function GCNC_CREATE(frame)
    local edit_name = GET_CHILD_RECURSIVELY(frame, "edit_name")
    local edit_pw = GET_CHILD_RECURSIVELY(frame, "edit_pw")
    local check_pw = GET_CHILD_RECURSIVELY(frame, "check_private")
    if not GCM_VALIDATE_CHCFG(edit_name, edit_pw, check_pw) then return end
    
    gcm_CreateChannel(edit_name:GetText(), check_pw:IsChecked() ~= 0 and edit_pw:GetText() or "")
    GCNC_CLOSE()
end

function GCM_VALIDATE_CHCFG(edit_name, edit_pw, check_pw)
    local name = edit_name:GetText()
    if name == "" then
        ui.MsgBox_OneBtnScp(ClMsg("InputName"), "")
        return false
    end

    local pw = edit_pw:GetText()
    if check_pw:IsChecked() ~= 0 and string.len(pw) < 4 then
        ui.MsgBox_OneBtnScp(ClMsg("PasswordTooShort"), "")
        return false
    end

    return true
end

function GCNC_TOGGLE_PRIVATE(frame, checkbox)
    local visible = checkbox:IsChecked()
    GCNC_SET_PRIVATE(frame, visible ~= 0)
end

function GCNC_SET_PRIVATE(frame, is_private)
    local enterpw = GET_CHILD_RECURSIVELY(frame, "enterpw")
    local edit_pw = GET_CHILD_RECURSIVELY(frame, "edit_pw")
    local check_private = GET_CHILD_RECURSIVELY(frame, "check_private")
    enterpw:SetVisible(is_private and 1 or 0)
    edit_pw:SetVisible(is_private and 1 or 0)
    edit_pw:ClearText()
    check_private:SetCheck(is_private and 1 or 0)
    frame:Resize(frame:GetWidth(), is_private and 352 or frame:GetOriginalHeight())

    local focus = is_private and edit_pw or GET_CHILD_RECURSIVELY(frame, "edit_name")
    focus:Focus()
end

