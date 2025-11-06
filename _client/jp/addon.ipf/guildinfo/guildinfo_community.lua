local current_channel = ""
local joining_to = ""
local context_channel = ""
local context_message = ""
local context_member = ""
local next_load_available_time = 0
local cur_ch_page = 1
local has_claim = {
    create_channel = false,
    delete_channel = false,
    pin_message = false,
    delete_message = false,
    gag_member = false,
}
local pending_claimcheck = 0
local NUM_CHANNELS_PER_PAGE = 15

function GUILDINFO_COMMUNITY_INIT()
    local check = function(code, name)
        CheckClaim("GCM_UPDATE_CLAIM", code, {name})
        pending_claimcheck = pending_claimcheck + 1
    end
    check(209, "create_channel")
    check(210, "delete_channel")
    check(211, "pin_message")
    check(212, "delete_message")
    check(213, "gag_member")
    
    local frame = ui.GetFrame("guildinfo")
    local communityPanel = GET_CHILD_RECURSIVELY(frame, "communitypanel")
    communityPanel:SetEventScript(ui.MOUSEWHEEL, "GCM_ON_WHEEL_MSGPANEL")

    local chat_edit = GET_CHILD_RECURSIVELY(frame, "chat_edit")
    chat_edit:SetEventScript(ui.ENTERKEY, "GCM_SEND_CHAT")
    chat_edit:SetTypingScp("GCM_ON_TYPING_CHAT")
    
	local btn_emo = GET_CHILD_RECURSIVELY(frame, "chat_button_emo")
	btn_emo:SetEventScript(ui.MOUSEMOVE, "EMO_OPEN")
	btn_emo:SetEventScript(ui.LBUTTONUP, "EMO_OPEN_MENU")
end

function GCM_UPDATE_CLAIM(code, ret_json, args)
    has_claim[args[1]] = string.lower(ret_json) == "true"
    pending_claimcheck = math.max(pending_claimcheck - 1, 0)
    if pending_claimcheck == 0 then
        GCM_UPDATE_CHANNEL_LIST()
    end
end

function GCM_NEW_CHANNEL()
    ui.OpenFrame("guildcomm_newch")
end

function GCM_ON_TYPING_CHAT(parent, editctrl)
    local emoticon, newtext = ui.UpdateChatEmoticon(editctrl:GetText())
    if emoticon ~= "" then
        CHAT_CHECK_EMOTICON(newtext, emoticon, editctrl)
    end
end

function GCM_MARK_CHANNEL_AS_READ(channel, is_read)
    local frame = ui.GetFrame("guildinfo")
    local channels = GET_CHILD_RECURSIVELY(frame, "communitypanel_channels")
    local chbtn = GET_CHILD_RECURSIVELY(channels, channel)
    if chbtn then
        local newicon = GET_CHILD_RECURSIVELY(chbtn, "newicon")
        newicon:SetVisible(is_read and 0 or 1)
    end
    if is_read then
        gcm_MarkChannelAsRead(channel)
    end
end

function GCM_COPY_MESSAGE(parent, panel)
    ui.WriteClipboardText(panel:GetNormalText())
    ui.MsgBox(ClMsg("CopiedToClipboard"))
end

function GCM_ON_WHEEL_MSGPANEL(parent, panel, argstr, wheel)
    if current_channel == "" then return end

    if wheel > 0 then -- 위로
        if next_load_available_time > os.clock() then return end
        if current_channel == "" or panel:GetScrollCurPos() ~= 0 then return end
        
        local oldest = GET_FIRST_CHILD(panel, "ui::CControlSet", function(obj) return obj:GetName():sub(1,1) ~= "@" end)
        gcm_LoadMessages(current_channel, 10, oldest and oldest:GetName() or "") -- 로드 완료되면 GCM_ON_LOAD_MESSAGES 호출
        next_load_available_time = os.clock() + 1 -- 1초 후 다시 로드 가능
    elseif wheel < 0 then -- 아래로
        if panel:GetScrollBarMaxPos() == panel:GetScrollCurPos() then
            GCM_MARK_CHANNEL_AS_READ(current_channel, true)
        end
    end
end

function GCM_SEND_CHAT(parent, control)
    CHAT_CHECK_EMOTICON_WITH_ENTER(control)
    local txt = control:GetText()
    if txt ~= "" then
        gcm_SendChat(current_channel, txt)
        control:ClearText()

        local frame = ui.GetFrame("guildinfo")
        local panel = GET_CHILD_RECURSIVELY(frame, "communitypanel")
        panel:SetScrollPos(panel:GetScrollBarMaxPos())
    end
end

function GCM_ALIGN_MESSAGES()
    local frame = ui.GetFrame("guildinfo")
    local panel = GET_CHILD_RECURSIVELY(frame, "communitypanel")
    local offset = panel:GetScrollBarMaxPos() - panel:GetScrollCurPos()

    GBOX_AUTO_ALIGN{
        gbox = panel,
        starty = 0,
        spacey = 0,
        gboxaddy = 0
    }

    panel:UpdateData() -- ScrollBarMaxPos 재계산
    panel:SetScrollPos(panel:GetScrollBarMaxPos() - offset)
end

function GCM_ADD_MESSAGE(msg, isPushFront)
    local frame = ui.GetFrame("guildinfo")
    local panel = GET_CHILD_RECURSIVELY(frame, "communitypanel")
    local add_sysmsg = function(txt, id)
        local msgctrl = panel:CreateOrGetControlSet("channel_system_message", id, 0, 0)
        GET_CHILD_RECURSIVELY(msgctrl, "text"):SetText(txt)
    end

    local dateid = "@" .. msg.date
    if isPushFront then
        panel:SetChildPushDirection(ui.CPD_FRONT)

        local datetxt = GET_FIRST_CHILD(panel, "ui::CControlSet")
        if datetxt and datetxt:GetName() == dateid then
            panel:RemoveChild(dateid)
        end
    else
        local msgctrl = GET_LAST_CHILD(panel, "ui::CControlSet")
        local prevmsg = msgctrl and gcm_GetMessage(current_channel, msgctrl:GetName())
        if not prevmsg or prevmsg.date ~= msg.date then
            add_sysmsg(msg.date, dateid)
        end
    end

    if msg.sender then
        local msgctrl = panel:CreateOrGetControlSet("community_card_layout", msg.id, 0, 0)
        local txt = GET_CHILD_RECURSIVELY(msgctrl, "mainText")
        local mainBg = GET_CHILD_RECURSIVELY(msgctrl, "mainBg")

        local offset = txt:GetHeight()
        txt:SetTextByKey('text', msg.text)
        offset = txt:GetHeight() - offset
        msgctrl:Resize(msgctrl:GetWidth(), msgctrl:GetHeight() + offset)
        mainBg:Resize(mainBg:GetWidth(), mainBg:GetHeight() + offset)

        GET_CHILD_RECURSIVELY(msgctrl, "date"):SetText(msg.time)
        GET_CHILD_RECURSIVELY(msgctrl, "pin"):SetVisible(gcm_IsPinned(current_channel, msg.id) and 1 or 0)
        -- GET_CHILD_RECURSIVELY(msgctrl, "replyPic"):SetImage("guild_comment_off")

        local info = session.party.GetPartyMemberInfoByAID(PARTY_GUILD, msg.sender)
        GET_CHILD_RECURSIVELY(msgctrl, "writerName"):SetText(
            (info and info:GetAID() == session.loginInfo.GetAID() and "{@st66d_y}" or "{@st66d}") ..
            (info and info:GetName() or ClMsg("Unknown")) .. "{/}"
        )
    else
        add_sysmsg(msg.text, msg.id)
    end

    if isPushFront then
        add_sysmsg(msg.date, dateid)
        panel:SetChildPushDirection(ui.CPD_BACK)
    end
end

-- GuildCommCl.cpp에서 호출
function GCM_ON_LOAD_MESSAGES(channel, messages)
    if channel ~= current_channel then return end

    for i, msg in pairs(messages) do
        GCM_ADD_MESSAGE(msg, true)
    end

    GCM_ALIGN_MESSAGES()
    next_load_available_time = 0
end

-- GuildCommCl.cpp에서 호출
function GCM_ON_BROADCAST_CHAT(ch, msg)
    if ch == current_channel then
        local frame = ui.GetFrame("guildinfo")
        local panel = GET_CHILD_RECURSIVELY(frame, "communitypanel")
        GCM_ADD_MESSAGE(msg)
        GCM_ALIGN_MESSAGES()
        GCM_MARK_CHANNEL_AS_READ(ch, panel:GetScrollBarMaxPos() <= panel:GetScrollCurPos())
    else
        GCM_MARK_CHANNEL_AS_READ(ch, false)
    end
end

function GCM_SET_VISIBLE_FIRSTTIME(is_visible)
    local frame = ui.GetFrame("guildinfo")

    local firsttime = GET_CHILD_RECURSIVELY(frame, "firsttime")
    local cnt = firsttime:GetChildCount()
    for i = 1, cnt - 1 do
        firsttime:GetChildByIndex(i):SetVisible(is_visible and 1 or 0)
    end

    local chat = GET_CHILD_RECURSIVELY(frame, "chat_bg")
    local cnt = chat:GetChildCount()
    for i = 0, cnt - 1 do
        chat:GetChildByIndex(i):SetVisible(is_visible and 0 or 1)
    end
    chat:SetVisible(is_visible and 0 or 1)

    local noticepanel = GET_CHILD_RECURSIVELY(frame, "noticepanel")
    local cnt = noticepanel:GetChildCount()
    for i = 0, cnt - 1 do
        noticepanel:GetChildByIndex(i):SetVisible(is_visible and 0 or 1)
    end
    noticepanel:SetVisible(is_visible and 0 or 1)

    if is_visible then
        local panel = GET_CHILD_RECURSIVELY(frame, "communitypanel")
        panel:RemoveAllChild()
    end
end

function GCM_CHANNEL_PREVPAGE()
    cur_ch_page = cur_ch_page - 1
    GCM_UPDATE_CHANNEL_LIST()
end

function GCM_CHANNEL_NEXTPAGE()
    cur_ch_page = cur_ch_page + 1
    GCM_UPDATE_CHANNEL_LIST()
end

-- GuildCommCl.cpp에서 호출
function GCM_UPDATE_CHANNEL_LIST(has_deleted)
    local frame = ui.GetFrame("guildinfo")
    local channels = GET_CHILD_RECURSIVELY(frame, "communitypanel_channels")
    channels:RemoveAllChild()

    local num_pages = gcm_GetChannelPageCount(NUM_CHANNELS_PER_PAGE)
    cur_ch_page = math.min(math.max(cur_ch_page, 1), num_pages)
    GET_CHILD_RECURSIVELY(frame, "txt_channel_page"):SetText(cur_ch_page .. " / " .. num_pages)

    for i, ch in pairs(gcm_GetChannelList(cur_ch_page, NUM_CHANNELS_PER_PAGE)) do
        local chbtn = channels:CreateControlSet("community_channel", ch.id, 2, 0)
        chbtn:SetTextByKey("name", ch.label)

        local favorite = GET_CHILD_RECURSIVELY(chbtn, "favorite")
        favorite:SetVisible(ch.isJoined and 1 or 0)
        if ch.isFavorite then
            favorite:SetImage("guild_community_favorite_clicked")
        end

        local password = GET_CHILD_RECURSIVELY(chbtn, "password")
        password:SetVisible(ch.hasPassword and 1 or 0)

        local newicon = GET_CHILD_RECURSIVELY(chbtn, "newicon")
        newicon:SetVisible(ch.isRead and 0 or 1)
    end

    local addbtn
    if has_claim.create_channel then
        addbtn = channels:CreateControl("button", "button_create_channel", 4, 0, 216, 42)
        addbtn = AUTO_CAST(addbtn)
        addbtn:SetImage("guild_community_tab_add")
        addbtn:SetEventScript(ui.LBUTTONUP, "GCM_NEW_CHANNEL")
    end

    GBOX_AUTO_ALIGN{
        gbox = channels,
        starty = 2,
        spacey = 2.5,
        gboxaddy = 0
    }
    if addbtn then addbtn:Move(0, 3) end

    if joining_to == "" or not GCM_SELECT_CHANNEL(joining_to) then
        if not GCM_SELECT_CHANNEL(current_channel, not has_deleted) then
            if not GCM_SELECT_CHANNEL(0) then
                current_channel = ""
                GCM_SET_VISIBLE_FIRSTTIME(true)
                GCM_UPDATE_CHANNEL_MEMBER()
                return
            end
        end
    end
    GCM_SET_VISIBLE_FIRSTTIME(false)
end

function GCM_SELECT_CHANNEL(channel, no_reload)
    if session.party.GetAllMemberCount(PARTY_GUILD) == 0 then
        -- 아직 로딩중임
        return false
    end

    local frame = ui.GetFrame("guildinfo")
    local channels = GET_CHILD_RECURSIVELY(frame, "communitypanel_channels")

    if type(channel) == "string" then
        channel = channels:GetChild(channel)
    elseif type(channel) == "number" then
        channel = channels:GetChildByIndex(channel)
    end
    if not channel or not gcm_IsJoinedChannel(channel:GetName()) then return false end

    local setbtn = function(ch, set)
        local btn = GET_CHILD_RECURSIVELY(ch, "button")
        if btn then btn:SetForceClicked(set) end
    end

	local cnt = channels:GetChildCount()
	for i = 0, cnt - 1 do
		local ch = channels:GetChildByIndex(i)
        setbtn(ch, false)
	end
    setbtn(channel, true)
    current_channel = channel:GetName()

    local panel = GET_CHILD_RECURSIVELY(frame, "communitypanel")
    local cnt = panel:GetChildCount()
    if not no_reload or cnt <= 1 then
        panel:RemoveAllChild()
        panel:UpdateData() -- 스크롤 위치 초기화를 위함
        gcm_LoadMessages(current_channel) -- GCM_ON_LOAD_MESSAGES
    else
        -- 메시지 고정여부 갱신
        for i = 0, cnt - 1 do
            local msg = panel:GetChildByIndex(i)
            local pin = GET_CHILD_RECURSIVELY(msg, "pin")
            if pin then
                pin:SetVisible(gcm_IsPinned(current_channel, msg:GetName()) and 1 or 0)
            end
        end
    end

    GCM_UPDATE_PINNED()
    GCM_UPDATE_CHANNEL_MEMBER()
    GCM_MARK_CHANNEL_AS_READ(current_channel, true)
    joining_to = ""

    local chat_edit = GET_CHILD_RECURSIVELY(frame, "chat_edit")
    if chat_edit:IsHaveFocus() == 0 then
        chat_edit:Focus()
    end

    return true
end

function GCM_UPDATE_PINNED()
    local noticepanel = GET_CHILD_RECURSIVELY(ui.GetFrame("guildinfo"), "noticepanel_contents")
    noticepanel:RemoveAllChild()
    for k, v in pairs(gcm_GetPinnedMessages(current_channel)) do
        local msg = noticepanel:CreateControlSet("gcm_notice", v.id, 0, 0)
        local txt = GET_CHILD_RECURSIVELY(msg, "txt")
        txt:SetTextByKey("text", v.text)
        if k == 1 then
            local bg = GET_CHILD_RECURSIVELY(msg, "bg")
            bg:Resize(bg:GetOriginalWidth() - 45, bg:GetHeight())
            txt:SetMaxWidth(txt:GetOriginalWidth() - 45)
        end
    end
    GCM_UPDATE_NOTICE_PANEL()
end

function GCM_ON_CLICKED_CHANNEL(channel)
    if GCM_SELECT_CHANNEL(channel) then return end

    joining_to = channel:GetName()
    if gcm_HasPassword(joining_to) then
        EDITMSGBOX_FRAME_OPEN(ClMsg("EnterPassword"), "GCM_JOIN_CHANNEL", "GCM_CANCEL_JOIN")
    else
	    ui.MsgBox(ClMsg("JoinChannel"), "GCM_JOIN_CHANNEL", "GCM_CANCEL_JOIN")
    end
end

function GCM_JOIN_CHANNEL(pw)
    gcm_JoinChannel(joining_to, pw)
end

function GCM_CANCEL_JOIN()
    joining_to = ""
end

function GCM_LEAVE_CHANNEL()
    gcm_LeaveChannel(context_channel)
end

function GCM_DELETE_CHANNEL()
    gcm_DeleteChannel(context_channel)
end

function GCM_KICK_MEMBER()
    gcm_KickMember(current_channel, context_member)
end

function GCM_OPEN_MEMBER_CONTEXT(parent, control)
    local myaid = session.loginInfo.GetAID()
    local target = (control:GetClassString() == "ui::CControlSet" and control or parent):GetName()

    local canKick = target ~= myaid and (gcm_IsOwnedChannel(current_channel) or session.party.IsLeader(PARTY_GUILD, myaid))
    local isGagged = gcm_IsMemberGagged(current_channel, target)
    local canGag = has_claim.gag_member and (isGagged or target ~= myaid)
    if not (canKick or canGag) then return end

    context_member = target
    local context = ui.CreateContextMenu("MEMBER_CONTEXT_MENU", "", 0, 0, 190, 100)

    if canKick then
        ui.AddContextMenuItem(
            context,
            "{img context_chat_goout 17 16} " .. ClMsg("Ban"),
            "ui.MsgBox(ClMsg('KickConfirm'), 'GCM_KICK_MEMBER', '')"
        )
    end
    if canGag then
        if isGagged then
            ui.AddContextMenuItem(
                context,
                "{img context_conversation_delete 18 17} " .. ClMsg("UngagMember"),
                "GCM_SET_MEMBER_GAGGED(false)"
            )
        else
            ui.AddContextMenuItem(
                context,
                "{img context_conversation_delete 18 17} " .. ClMsg("GagMember"),
                "GCM_SET_MEMBER_GAGGED(true)"
            )
        end
    end
    ui.OpenContextMenu(context)
end

function GCM_OPEN_CHANNEL_MENU(channel)
    local name = channel:GetName()
    local context = ui.CreateContextMenu("CHANNEL_CONTEXT_MENU", "", 0, 0, 190, 100)
    local show = false

    local is_joined = gcm_IsJoinedChannel(name)
    local is_owned = gcm_IsOwnedChannel(name)
    if is_joined then
        ui.AddContextMenuItem(
            context,
            "{img context_chat_goout 17 16} " .. ClMsg("LeaveChannel"),
	        "ui.MsgBox(ClMsg('LeaveChannelConfirm'), 'GCM_LEAVE_CHANNEL', '')"
        )
        show = true
    end

    if --[[is_joined or]] is_owned then
        ui.AddContextMenuItem(
            context,
            "{img context_setting 16 16} " .. ClMsg("Settings"),
            "GCM_OPEN_CHANNEL_CONFIG('" .. name .. "')"
        )
        show = true
    end

    if has_claim.delete_channel or is_owned then
        ui.AddContextMenuItem(
            context,
            "{img context_chat_delete 18 16} " .. ClMsg("Delete"),
            "ui.MsgBox(ClMsg('AskReallyDelete'), 'GCM_DELETE_CHANNEL', '')"
        )
        show = true
    end

    if show then
        context_channel = name
        ui.OpenContextMenu(context)
    end
end

function GCM_OPEN_MESSAGE_MENU(msg)
    while msg:GetClassString() ~= "ui::CControlSet" do
        msg = msg:GetParent()
        if not msg then return end
    end
    context_message = msg:GetName()

    local context = ui.CreateContextMenu("MESSAGE_CONTEXT_MENU", "", 0, 0, 190, 100)
    ui.AddContextMenuItem(
        context,
        "{img context_conversation_delete 18 17} " .. ClMsg("Delete"),
        "ui.MsgBox(ClMsg('DeleteMessageDesc'), 'GCM_DELETE_MESSAGE_LOCAL', 'None')"
    )
    if has_claim.delete_message then
        ui.AddContextMenuItem(
            context,
            "{img context_conversation_delete 18 17} " .. ClMsg("DeleteMessageFromEveryone"),
            "ui.MsgBox(ClMsg('DeleteMessageFromEveryoneDesc'), 'GCM_DELETE_MESSAGE_GLOBAL', 'None')"
        )
    end
    if has_claim.pin_message or gcm_IsOwnedChannel(current_channel) then
        if gcm_IsPinned(current_channel, context_message) then
            ui.AddContextMenuItem(context, "{img context_notice 20 23} " .. ClMsg("UnpinMessage"), "GCM_SET_MESSAGE_PINNED(false)")
        else
            ui.AddContextMenuItem(context, "{img context_notice 20 23} " .. ClMsg("PinMessage"), "GCM_SET_MESSAGE_PINNED(true)")
        end
    end
    ui.OpenContextMenu(context)
end

function GCM_OPEN_NOTICE_MENU(msg)
    context_message = msg:GetName()
    if has_claim.pin_message or gcm_IsOwnedChannel(current_channel) then
        local context = ui.CreateContextMenu("NOTICE_CONTEXT_MENU", "", 0, 0, 190, 100)
        ui.AddContextMenuItem(context, "{img context_notice 20 23} " .. ClMsg("UnpinMessage"), "GCM_SET_MESSAGE_PINNED(false)")
        ui.OpenContextMenu(context)
    end
end

-- GuildCommCl.cpp에서 호출
function GCM_ON_MESSAGE_DELETE(id)
    local frame = ui.GetFrame("guildinfo")
    local panel = GET_CHILD_RECURSIVELY(frame, "communitypanel")

    local idx = panel:GetChildIndex(id)
    if idx == -1 then return end

    -- 필요 없는 날짜 표기 삭제
    local prev = panel:GetChildByIndex(idx - 1)
    local next = panel:GetChildByIndex(idx + 1)
    if (not next or next:GetName():sub(1,1) == "@") and prev:GetName():sub(1,1) == "@" then
        panel:RemoveChildByIndex(idx - 1)
    end

    panel:RemoveChild(id)
    GCM_ALIGN_MESSAGES()
    GCM_UPDATE_PINNED()
end

function GCM_SET_MEMBER_GAGGED(isGagged)
    gcm_SetMemberGagged(current_channel, context_member, isGagged)
end

function GCM_DELETE_MESSAGE_LOCAL()
    gcm_DeleteMessageLocal(current_channel, context_message) -- GCM_ON_MESSAGE_DELETE
end

function GCM_DELETE_MESSAGE_GLOBAL()
    gcm_DeleteMessageGlobal(current_channel, context_message) -- GCM_ON_MESSAGE_DELETE
end

function GCM_SET_MESSAGE_PINNED(isPinned)
    gcm_SetMessagePinned(current_channel, context_message, isPinned)
end

function GCM_TOGGLE_FAVORITE(channel)
    local name = channel:GetName()
    gcm_ChannelFavorite(name, not gcm_ChannelFavorite(name))
end

function GCM_UPDATE_CHANNEL_MEMBER()
    local frame = ui.GetFrame("guildinfo")
    local panel = GET_CHILD_RECURSIVELY(frame, "community_users")
    panel:RemoveAllChild()

    if current_channel == "" then return end

    local add_member = function(member)
        local ctrlset = panel:CreateControlSet("channel_memberinfo", member:GetAID(), 0, 0)
        local txt_teamname = GET_CHILD_RECURSIVELY(ctrlset, "txt_teamname")
        local teamname = member:GetName()

        if gcm_IsMemberGagged(current_channel, member:GetAID()) then
            teamname = teamname .. " {img context_conversation_delete 18 17}"
        end

        ctrlset:SetEventScript(ui.RBUTTONUP, "GCM_OPEN_MEMBER_CONTEXT")
        txt_teamname:SetEventScript(ui.RBUTTONUP, "GCM_OPEN_MEMBER_CONTEXT")
        txt_teamname:SetText(teamname)

        if member:GetMapID() == 0 then
            GET_CHILD_RECURSIVELY(ctrlset, "pic_online"):SetImage("memory_4")
        else
            GET_CHILD_RECURSIVELY(ctrlset, "shadow"):SetVisible(0)
        end
    end
    local add_text = function(key, count)
        local ctrl = panel:CreateControlSet("channel_memberlist_title", key, 0, 0)
        ctrl = GET_CHILD_RECURSIVELY(ctrl, "text")
        ctrl:SetText(ScpArgMsg(key, "count", count))
    end

    local online, offline = gcm_GetChannelMembers(current_channel)
    if online and offline then
        add_text("OnlineUserCount", #online)
        for i, member in pairs(online) do add_member(member) end

        add_text("OfflineUserCount", #offline)
        for i, member in pairs(offline) do add_member(member) end

        GBOX_AUTO_ALIGN{
            gbox = panel,
            starty = 0,
            spacey = 0,
            gboxaddy = 0
        }
    end
end

function GCM_TOGGLE_NOTICE_PANEL()
    if GCM_IS_NOTICE_PANEL_OPENED() then 
        GCM_CLOSE_NOTICE_PANEL()
    else
        GCM_OPEN_NOTICE_PANEL()
    end
end

function GCM_UPDATE_NOTICE_PANEL()
    if GCM_IS_NOTICE_PANEL_OPENED() then 
        GCM_OPEN_NOTICE_PANEL()
    else
        GCM_CLOSE_NOTICE_PANEL()
    end
end

function GCM_IS_NOTICE_PANEL_OPENED()
    local panel = GET_CHILD_RECURSIVELY(ui.GetFrame("guildinfo"), "noticepanel")
    return panel:GetHeight() > panel:GetOriginalHeight()
end

function GCM_OPEN_NOTICE_PANEL()
    local panel = GET_CHILD_RECURSIVELY(ui.GetFrame("guildinfo"), "noticepanel")
    local contents = GET_CHILD_RECURSIVELY(panel, "noticepanel_contents")
    local cnt = contents:GetChildCount()

    local h_offset = 0
    for i=0, cnt-1 do
        local child = contents:GetChildByIndex(i)
        GCM_SET_EXPAND_NOTICE(child, child:GetHeight() > child:GetOriginalHeight(), true)
        h_offset = h_offset + child:GetHeight()
    end
    h_offset = math.max(1, h_offset - panel:GetOriginalHeight())
    GCM_SET_NOTICE_PANEL(h_offset, "close")
end

function GCM_CLOSE_NOTICE_PANEL()
    GCM_CONTRACT_NOTICE_ALL()
    GCM_SET_NOTICE_PANEL(0, "open")
end

function GCM_CONTRACT_NOTICE_ALL(except)
    local contents = GET_CHILD_RECURSIVELY(ui.GetFrame("guildinfo"), "noticepanel_contents")
    local cnt = contents:GetChildCount()
    for i = 0, cnt - 1 do
        local child = contents:GetChildByIndex(i)
        if child ~= except then
            GCM_SET_EXPAND_NOTICE(child, false, true)
        end
    end
end

function GCM_SET_NOTICE_PANEL(h_offset, btnimg)
    local frame = ui.GetFrame("guildinfo")
    local panel = GET_CHILD_RECURSIVELY(frame, "noticepanel")
    local contents = GET_CHILD_RECURSIVELY(panel, "noticepanel_contents")
    local orig_h = panel:GetOriginalHeight()
    local button = GET_CHILD_RECURSIVELY(panel, "toggleopen")
    local messages = GET_CHILD_RECURSIVELY(frame, "communitypanel")

    local h = orig_h + h_offset
    panel:Resize(panel:GetWidth(), h)
    contents:Resize(contents:GetWidth(), h)
    button:SetImage("guild_community_notice_" .. btnimg)

    local scroll_offset = messages:GetScrollBarMaxPos() - messages:GetScrollCurPos()
    local rect = messages:GetOriginalMargin()
    messages:SetMargin(rect.left, rect.top + h_offset, rect.right, rect.bottom)
    messages:Resize(messages:GetWidth(), messages:GetOriginalHeight() - h_offset)
    messages:UpdateData() -- ScrollBarMaxPos 재계산
    messages:SetScrollPos(messages:GetScrollBarMaxPos() - scroll_offset)
    GBOX_AUTO_ALIGN(contents, 0, 0, 0)
end

function GCM_TOGGLE_EXPAND_NOTICE(notice)
    GCM_SET_EXPAND_NOTICE(notice, notice:GetHeight() == notice:GetOriginalHeight())
end

function GCM_SET_EXPAND_NOTICE(notice, isExpand, no_update)
    local bg = GET_CHILD_RECURSIVELY(notice, "bg")
    local txt = GET_CHILD_RECURSIVELY(notice, "txt")

    if isExpand then
        txt:SetTextByKey("text", gcm_ResizeEmoticon(txt:GetTextByKey("text"), 3, 1))
        txt:EnableResizeByText(1)
        txt:CheckSurfaceSize()

        local h = notice:GetOriginalHeight() + (txt:GetHeight() - txt:GetOriginalHeight()) + 1
        notice:Resize(notice:GetWidth(), h)
        bg:Resize(bg:GetWidth(), h)

        GCM_CONTRACT_NOTICE_ALL(notice)

        if not no_update then
            GCM_OPEN_NOTICE_PANEL()
        end
    else
        txt:SetTextByKey("text", gcm_ResizeEmoticon(txt:GetTextByKey("text"), 0, 0, 20))
        txt:EnableResizeByText(0)
        txt:Resize(txt:GetWidth(), txt:GetOriginalHeight())
        notice:Resize(notice:GetWidth(), notice:GetOriginalHeight())
        bg:Resize(bg:GetWidth(), bg:GetOriginalHeight())

        if not no_update then
            GCM_UPDATE_NOTICE_PANEL()
        end
    end
end

