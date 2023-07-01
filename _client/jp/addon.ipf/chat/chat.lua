

CHAT_LINE_HEIGHT = 100
g_emoticonTypelist = {"Normal", "Motion"}

function CHAT_ON_INIT(addon, frame)	
	
	-- 마우스 호버링을 위한 마우스 업할때 닫기 이벤트 설정 부분.
	local btn_emo = GET_CHILD(frame, "button_emo")
	btn_emo:SetEventScript(ui.MOUSEMOVE, "EMO_OPEN")
	btn_emo:SetEventScript(ui.LBUTTONUP, "EMO_OPEN_MENU")

	local btn_type = GET_CHILD(frame, "button_type")
	btn_type:SetEventScript(ui.MOUSEMOVE, "CHAT_OPEN_TYPE")	

end

function CHAT_OPEN_INIT()
	--'채팅 타입'에 따른 채팅바의 '채팅타입 버튼 목록'이 결정된다.
	if config.GetServiceNation() == "GLOBAL_JP" or config.GetServiceNation() == "GLOBAL" or config.GetServiceNation() == "IDN" then
		local frame = ui.GetFrame('chat')	
		local chatEditCtrl = frame:GetChild('mainchat')
		local btn_emo = GET_CHILD(frame, "button_emo")
		local titleCtrl = GET_CHILD(frame,'edit_to_bg')	
		chatEditCtrl:Resize((chatEditCtrl:GetOriginalWidth()- 23) - btn_emo:GetWidth() - titleCtrl:GetWidth() - 28, chatEditCtrl:GetOriginalHeight())
	end
end

function CHAT_CLOSE_SCP()
	CHAT_CLICK_CHECK()
end

function CHAT_WHISPER_INVITE(ctrl, ctrlset, roomID, artNum)
	ctrl:SetUserValue("ROOM_ID",roomID)
	INPUT_STRING_BOX_CB(frame, ScpArgMsg("PlzInputInviteName"), "EXED_GROUPCHAT_ADD_MEMBER2", "",nil,roomID,20)
end

function CHAT_NOTICE(msg)
	session.ui.GetChatMsg():AddNoticeMsg(ScpArgMsg("NoticeFrameName"), msg, true) 
end

function CHAT_SYSTEM(msg, color)
	session.ui.GetChatMsg():AddSystemMsg(msg, true, 'System', color)
end


--채팅타입에 따라 '채팅바의 입력기' 위치와 크기 설정. 
function CHAT_SET_TO_TITLENAME(chatType, targetName)
	local frame = ui.GetFrame('chat')
	local chatEditCtrl = frame:GetChild('mainchat')
	local titleCtrl = GET_CHILD(frame,'edit_to_bg')
	local editbg = GET_CHILD(frame,'edit_bg')
	local name  = GET_CHILD(titleCtrl,'title_to')		
	local btn_ChatType = GET_CHILD(frame,'button_type')

	-- 귓속말 ctrl의 시작위치는 type btn 뒤쪽에.
	titleCtrl:SetOffset(btn_ChatType:GetOriginalWidth(), titleCtrl:GetOriginalY())
	local offsetX = btn_ChatType:GetOriginalWidth() -- 시작 offset은 type btn 넓이 다음으로.
	local titleText = ''
	local isVisible = 0

	if targetName ~= "" then
		if chatType == CT_WHISPER or chatType == CT_GUILD then -- 귓말 / 길드 커뮤니티 채널
			isVisible = 1
			titleText = ScpArgMsg('WhisperChat','Who',targetName)
		elseif chatType == CT_GROUP then -- 그룹채팅
			isVisible = 1
			titleText = session.chat.GetRoomConfigTitle(targetName)
			if titleText == "" or titleText == nil then
				return
			end
		end
	end
		
	-- 이름을 먼저 설정해줘야 크기와 위치 설정이 이루어진다.
	name:SetText(titleText)	
	if titleText ~= '' then
		titleCtrl:Resize(name:GetWidth() + 20, titleCtrl:GetOriginalHeight())
	else
		titleCtrl:Resize(name:GetWidth(), titleCtrl:GetOriginalHeight())
	end
		
	if isVisible == 1 then
		titleCtrl:SetVisible(1)
		offsetX = offsetX + titleCtrl:GetWidth()
	else
		titleCtrl:SetVisible(0)
	end
		
	local width = chatEditCtrl:GetOriginalWidth() - titleCtrl:GetWidth() - btn_ChatType:GetWidth()
	chatEditCtrl:Resize(width, chatEditCtrl:GetOriginalHeight())
	
	chatEditCtrl:SetOffset(offsetX, chatEditCtrl:GetOriginalY())	
end

-- 채팅창의 이모티콘선택창과 옵션창이 열려있을 경우에 다른 곳 클릭시 해당 창들을 Close
function CHAT_CLICK_CHECK(frame)
	local type_frame = ui.GetFrame('chattypelist')
	local emo_frame = ui.GetFrame('chat_emoticon')
	local opt_frame = ui.GetFrame('chat_option')
	emo_frame:ShowWindow(0)
	opt_frame:ShowWindow(0)
	type_frame:ShowWindow(0)
end

function CHAT_OPEN_OPTION(frame)
	local opt_frame = ui.GetFrame('chat_option')
	opt_frame:SetPos(frame:GetX() + frame:GetWidth() - 35, frame:GetY() - opt_frame:GetHeight())
	opt_frame:ShowWindow(1)
end

-- 채팅창의 '타입 목록 열기 버튼'을 클릭시 '타입 목록'의 위치를 채팅바에 따라 교정하고 Open
function CHAT_OPEN_TYPE()
	local chatFrame = ui.GetFrame('chat')
	local frame = ui.GetFrame('chattypelist')
	frame:SetPos(chatFrame:GetX() + 10, chatFrame:GetY() - frame:GetHeight())	
	frame:ShowWindow(1)	
	frame:SetDuration(3)
end