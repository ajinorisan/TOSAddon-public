function SPECIAL_CREATE_TICKET_ON_INIT(addon, frame)
    addon:RegisterMsg('OPEN_SPECIAL_CREATE_TICKET', 'ON_OPEN_SPECIAL_CREATE_TICKET')
end

function ON_OPEN_SPECIAL_CREATE_TICKET(frame, msg, argStr, argNum)
    ui.OpenFrame('special_create_ticket')
end

function SPECIAL_CREATE_TICKET_OPEN(frame)
    -- local startTime, endTime = GET_SPECIAL_CREATE_TICKET_INFO()
    -- local year, month, day = GET_DATE_BY_DATE_STRING(endTime)
    -- local use_special_ticket = GET_CHILD_RECURSIVELY(frame, 'use_special_ticket')
    -- use_special_ticket:SetTextByKey('value', tostring(year))
    -- use_special_ticket:SetTextByKey('value2', tostring(month))
    -- use_special_ticket:SetTextByKey('value3', tostring(day))
end

function SPECIAL_CREATE_TICKET_CLOSE(frame)
end

function SPECIAL_CREATE_TICKET_GOTO_SELECT(parent, ctrl)
    local flag, reason = IS_ABLE_SPECIAL_CREATE_TICKET(GetMyPCObject())
    if flag == false then
        if reason ~= nil then
            ui.SysMsg(ClMsg(reason))
        end
        return
    end

    ui.CloseFrame('special_create_ticket')
    ui.OpenFrame('select_detail_class')
end

function SPECIAL_CREATE_TICKET_DISCARD_SELECT(parent, ctrl)
    local yesscp = '_SPECIAL_CREATE_TICKET_DISCARD_SELECT'
    local option = {}
	option.ChangeTitle = nil
	option.CompareTextColor = "{#ffa200}"
	option.CompareTextDesc = nil
    WARNINGMSGBOX_EX_FRAME_OPEN(frame, nil, 'ReallyDiscardSpecialCreateTicket' .. ';AgreeDiscardSpecialCreateTicket/' .. yesscp, 0, option)
end

function _SPECIAL_CREATE_TICKET_DISCARD_SELECT()
    ui.CloseFrame('special_create_ticket')
    control.CustomCommand('RESUME_FIRSTPLAY_TUTORIAL', 1)
end

function CHECK_SPECIAL_CREATE_TICKET_COUNT(invItem)
    local acc = GetMyAccountObj()
    if TryGetProp(acc, 'SPECIAL_CREATE_TICKET_COUNT', 0) > 1 then
        ui.SysMsg(ClMsg('HaveSpecialCreateTicketCountAlready'))
        return
    end

    if invItem.isLockState == true then
        ui.SysMsg(ClMsg('MaterialItemIsLock'))
        return
    end

    local itemObj = GetIES(invItem:GetObject())
    if TryGetProp(itemObj, 'StringArg', 'None') ~= 'SpecialCreateTicket' then
        return
    end

    if itemObj.ItemLifeTimeOver > 0 then
        ui.SysMsg(ClMsg('LessThanItemLifeTime'))
        return
    end

    local invFrame = ui.GetFrame('inventory')
    invFrame:SetUserValue('REQ_USE_ITEM_GUID', invItem:GetIESID())

    local clmsg = ScpArgMsg('ReallyUseSpecialCreateTicket{Name}', 'Name', dic.getTranslatedStr(TryGetProp(itemObj, 'Name', 'None')))

    ui.MsgBox_NonNested(clmsg, itemObj.Name, 'REQUEST_SUMMON_BOSS_TX', 'None')
end