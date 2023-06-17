local target_channel = ""

function GCM_OPEN_CHANNEL_CONFIG(channel)
    target_channel = channel
    ui.OpenFrame("guildcomm_chcfg")
    
    local frame = ui.GetFrame("guildcomm_chcfg")
    local edit_name = GET_CHILD_RECURSIVELY(frame, "edit_name")
    local edit_pw = GET_CHILD_RECURSIVELY(frame, "edit_pw")
    edit_name:SetText(gcm_GetChannelName(channel))
    edit_pw:ClearText()
    GCM_CHCFG_ENABLE_PW(frame, gcm_HasPassword(channel))
    edit_name:Focus()
end

function GCM_CLOSE_CHANNEL_CONFIG()
    ui.CloseFrame("guildcomm_chcfg")
end

function GCM_CHCFG_APPLY(frame)
    local edit_name = GET_CHILD_RECURSIVELY(frame, "edit_name")
    local edit_pw = GET_CHILD_RECURSIVELY(frame, "edit_pw")
    local check_pw = GET_CHILD_RECURSIVELY(frame, "check_pw")
    if not GCM_VALIDATE_CHCFG(edit_name, edit_pw, check_pw) then return end

    gcm_EditChannel(
        target_channel,
        edit_name:GetText(),
        check_pw:IsChecked() ~= 0 and edit_pw:GetText() or ""
    )
    GCM_CLOSE_CHANNEL_CONFIG()
end

function GCM_CHCFG_TOGGLE_PW(frame, check_pw)
    GCM_CHCFG_ENABLE_PW(frame, check_pw:IsChecked() ~= 0)
end

function GCM_CHCFG_ENABLE_PW(frame, enable)
    local edit_pw = GET_CHILD_RECURSIVELY(frame, "edit_pw")
    local check_pw = GET_CHILD_RECURSIVELY(frame, "check_pw")
    edit_pw:SetAlpha(enable and 100 or 90)
    edit_pw:SetEnable(enable and 1 or 0)
    if enable then edit_pw:Focus() end
    check_pw:SetCheck(enable and 1 or 0)
end

