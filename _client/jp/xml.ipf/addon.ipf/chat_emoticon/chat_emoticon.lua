local parent_button
local target_textedit

function CHAT_EMOTICON_ON_INIT(addon, frame)
	addon:RegisterOpenOnlyMsg("ADD_CHAT_EMOTICON", "CHAT_EMOTICON_MAKELIST")
end

function EMO_OPEN(button)
	target_textedit = nil
	parent_button = button
	
	local chat = button:GetParent() or button:GetTopParentFrame()
	local num = chat:GetChildCount()
	for i = 0, num - 1 do
		local child = AUTO_CAST(chat:GetChildByIndex(i))
		if child:GetClassString() == "ui::CEditControl" then
			target_textedit = child
			break
		end
	end

	local emo_frame = ui.GetFrame("chat_emoticon")
	local x_max = button:GetGlobalX() + button:GetWidth()
	emo_frame:SetPos(x_max - emo_frame:GetWidth() - 15, button:GetGlobalY() - emo_frame:GetHeight())
	emo_frame:ShowWindow(1)
end

function EMO_OPEN_MENU(button)
	local context = ui.CreateContextMenu("EMOTICON_MENU", "", 0, 0, 80, 60)
	for i = 0, #g_emoticonTypelist - 1 do
		local group = g_emoticonTypelist[i + 1]
		local scp = string.format("EMO_SET_GROUP(\"%s\")", group)
		ui.AddContextMenuItem(context, ClMsg("emoticon_" .. group), scp)
	end
	ui.OpenContextMenu(context)
end

function EMO_SET_GROUP(group)
	if not parent_button then return end
	local emo_frame = ui.GetFrame("chat_emoticon")
	emo_frame:ShowWindow(0)
	emo_frame:SetUserValue("EMOTICON_GROUP", group)
	EMO_OPEN(parent_button)
end

function ON_CHAT_EMOTICON_OPEN(frame)
	local list, listCnt = GetClassList("chat_emoticons")
	local emoticons = GET_CHILD_RECURSIVELY(frame, "emoticons")
	emoticons:SetColRow(emoticons:GetCol(), math.ceil(listCnt/10))
	emoticons:CreateSlots()
	
	CHAT_EMOTICON_MAKELIST(frame)
	frame:RunUpdateScript("_CHAT_EMOTICON_UPDATE", 0.001)
	frame:SetDuration(3)
end
	
function EMT_CLOSE(frame)
	frame = frame or ui.GetFrame("chat_emoticon")
	frame:ShowWindow(0)
end

function _CHAT_EMOTICON_UPDATE(frame, ctrl)
	if 1 == keyboard.IsKeyPressed("ESCAPE") then
		frame:ShowWindow(0)	
	end
	
	if keyboard.IsKeyDown("ENTER") == 1 or keyboard.IsKeyDown("PADENTER") == 1 then
		frame:ShowWindow(0)	
	end

	return 1
end

function CHAT_EMOTICON_ADDDURATION()
	local emo_frame = ui.GetFrame("chat_emoticon")
	emo_frame:SetDuration(3)
end

function CHAT_EMOTICON_MAKELIST(frame)

	local emoticons = GET_CHILD_RECURSIVELY(frame, "emoticons")
	local cnt = emoticons:GetSlotCount()	
	local acc = GetMyAccountObj()		
	local index = 0
	local list, listCnt = GetClassList("chat_emoticons")

	-- 아이콘 타입 확인 : 일반, 모션
	local iconGroup = frame:GetUserValue("EMOTICON_GROUP")
	local curCnt = frame:GetUserIValue("CURCNT")
	if iconGroup == "None" then
		iconGroup = "Normal"
	end

	for i = 0 , listCnt - 1 do
		acc = GetMyAccountObj()
		local slot = emoticons:GetSlotByIndex(index)
		slot:SetEventScript(ui.MOUSEMOVE, "CHAT_EMOTICON_ADDDURATION")	
		slot:SetOverSound("button_over")
		slot:SetClickSound("button_click_chat")
		if index < cnt then
			local cls = GetClassByIndexFromList(list, i)

			if TryGetProp(cls, 'HaveUnit', 'None') == 'PC' then
				acc = GetMyEtcObject()
			else
				acc = GetMyAccountObj()
			end

			if cls.IconGroup == iconGroup then
				if cls.CheckServer == 'YES' then
					-- check session emoticons
					local haveEmoticon = TryGetProp(acc, 'HaveEmoticon_' .. cls.ClassID)
					if haveEmoticon > 0 then
						local icon = CreateIcon(slot)
						local namelist = StringSplit(cls.ClassName, "motion_")
						local imageName = namelist[1]
						if 1 < #namelist then
							imageName = namelist[2]
						end
						
						icon:SetImage(imageName)
						local tooltipText = string.format( "%s%s" , "/" ,cls.IconTokken)
						icon:SetTextTooltip(tooltipText)

						index = index + 1				
						slot:ShowWindow(1)
					end
				else
					local icon = CreateIcon(slot)
					local namelist = StringSplit(cls.ClassName, "motion_")
					local imageName = namelist[1]
					if 1 < #namelist then
						imageName = namelist[2]
					end
						
					icon:SetImage(imageName)
					local tooltipText = string.format( "%s%s" , "/" ,cls.IconTokken)
					icon:SetTextTooltip(tooltipText)
					index = index + 1				
					slot:ShowWindow(1)
				end				
			end
		end
	end

	if curCnt ~= 0 then
		for i = index , curCnt - 1 do
			local slot = emoticons:GetSlotByIndex(i)
			slot:ClearIcon()
		end
	end

	frame:SetUserValue("CURCNT", index)
end

local function SET_CHAT_TEXT(txt, editctrl)
	editctrl = editctrl or target_textedit
	if editctrl then
		editctrl:SetText(txt)
		editctrl:AcquireFocus()
	end
end

local function CHAT_ADD_EMOTICON(imageName, editctrl)
	editctrl = editctrl or target_textedit
	local curLinkCount = editctrl:GetLinkCount()
	if curLinkCount >= 3 then
		ui.MsgBox(ScpArgMsg("Auto_LingKeuui_KaeSuNeun_3KaeLeul_Neomeul_Su_eopSeupNiDa."))
		return
	end

	local imgheight = 30
	local imgtag =  string.format("{img %s %d %d}{/}", imageName, imgheight, imgheight)
		
	local left = editctrl:GetCursurLeftText()
	local right = editctrl:GetCursurRightText()
	--이 함수 들어오는 시점에서 이미 스페이스키를 클릭한 상태이므로 추가해줌
	right = right .. " "
	local resultText = string.format("%s%s%s", left, imgtag, right)
	SET_CHAT_TEXT(resultText, editctrl)
	editctrl:SetCursorPos(#resultText)
end

local function CHAT_ADD_EMOTICON_MOTION(imageName, editctrl)
	editctrl = editctrl or target_textedit

	local curLinkCount = target_textedit:GetLinkCount()
	if curLinkCount >= 3 then
		ui.MsgBox(ScpArgMsg("Auto_LingKeuui_KaeSuNeun_3KaeLeul_Neomeul_Su_eopSeupNiDa."))
		return
	end
	
	-- 아이콘 클릭시에는 imageName이 아이콘 이미지 이름
	-- /IconTokken 으로 입력시에는 imageName이 ClassName
	if string.find(imageName, "motion_") == nil then
		imageName = "motion_"..imageName
	end

	local mainchat = GET_CHILD(GET_CHATFRAME(), "mainchat", "ui::CEditControl")
	if editctrl == mainchat and ui.GetChatType() == 1 then
		-- 외치기에서는 모션 이모티콘 사용 불가
		return
	end

	local spinetag =  string.format("{spine %s %d %d}{/}", imageName, 120, 120)
	SET_CHAT_TEXT(spinetag, editctrl)
	editctrl:RunEnterKeyScript();
	ui.ProcessReturnKey()
end

function CHAT_EMOTICON_SELECT(frame, ctrl)
	local emo_frame = ui.GetFrame("chat_emoticon")
	local iconGroup = emo_frame:GetUserValue("EMOTICON_GROUP")
	if iconGroup == "None" then
		iconGroup = "Normal"
	end

	if ctrl:GetClassName() == "slot" then
		if iconGroup == "Motion" then
			-- 모션 이모티콘			
			local slot = tolua.cast(ctrl, "ui::CSlot")
			local icon = slot:GetIcon()
			if icon ~= nil then
				local imageName = icon:GetInfo():GetImageName()
				if imageName ~= "" then					
					CHAT_ADD_EMOTICON_MOTION(imageName)
				end
			end
		else
			-- 일반 이모티콘
			local slot = tolua.cast(ctrl, "ui::CSlot")
			local icon = slot:GetIcon()
			if icon ~= nil then
				local imageName = icon:GetInfo():GetImageName()
				if imageName ~= "" then
					CHAT_ADD_EMOTICON(imageName)
				end
			end
	
			--Shift키를 누르면 연속적으로 선택하게.
			if 0 == keyboard.IsKeyPressed("LSHIFT") then
				EMT_CLOSE(emo_frame)
			else		
				emo_frame:SetDuration(3)
			end			
		end		
	end
end

function CHAT_CHECK_EMOTICON(newtext, imageName, editctrl)
	editctrl:SetText(newtext)

	local cls = GetClass("chat_emoticons", imageName)
	if cls.CheckServer == 'YES' then		
		local acc = GetMyAccountObj()
		if TryGetProp(cls, 'HaveUnit', 'None') == 'PC' then
			acc = GetMyEtcObject()
		else
			acc = GetMyAccountObj()
		end

		local haveEmoticon = TryGetProp(acc, 'HaveEmoticon_' .. cls.ClassID)
		if haveEmoticon <= 0 then
			return
		end
	end
	
	if cls.IconGroup == "Motion" then
		local chattype = ui.GetChatType()
		if chattype == 1 then
			-- 외치기에서는 모션 이모티콘 사용 불가
			return
		end
	
		-- 모션이모티콘
		CHAT_ADD_EMOTICON_MOTION(imageName, editctrl)
	else
		-- 일반 이모티콘
		CHAT_ADD_EMOTICON(imageName, editctrl)
	end		
end

g_chatEmoticonCacheTable = {} -- key: iconToken, valud: Class in idspace of "chat_emoticons"
function GET_EMOTICON_CLASS_BY_ICON_TOKEN(iconToken)	
	if g_chatEmoticonCacheTable[iconToken] ~= nil then		
		return g_chatEmoticonCacheTable[iconToken]
	end

	local clslist, cnt = GetClassList("chat_emoticons")
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(clslist, i)		
		local replacedByDic = dictionary.ReplaceDicIDInCompStr(cls.IconTokken)
		if replacedByDic == iconToken then
			g_chatEmoticonCacheTable[iconToken] = cls
			return cls
		end
	end
	return nil
end

function CHAT_CHECK_EMOTICON_WITH_ENTER(editctrl)
	local text = REPLACE_EMOTICON(editctrl:GetText())
	if text ~= nil then
		SET_CHAT_TEXT(text, editctrl)
	end
end

function REPLACE_EMOTICON(originText)
	local ret = ui.IsValidMacro(originText)
	
	if ret == 0 then
		return ""
	end

	if string.find(originText, '/') == nil then		
		return originText
	end

	local loopCount = 0

	local index = 1
	local totalLen = string.len(originText)
	while index < totalLen do
		local slashIndex = string.find(originText, '/', index)		
		if slashIndex == nil then
			break
		end

		-- get / started text
		local replaceTargetText = string.sub(originText, slashIndex, totalLen)		
		local whiteSpaceIndex = string.find(replaceTargetText, ' ')		
		if whiteSpaceIndex == nil then
			whiteSpaceIndex = string.len(replaceTargetText)
		else
			whiteSpaceIndex = whiteSpaceIndex - 1
		end

		if whiteSpaceIndex <= 0 then
			break
		end

		replaceTargetText = string.sub(replaceTargetText, 0, whiteSpaceIndex)
		
		-- get icon
		local iconToken = string.gsub(replaceTargetText, '/', '')
		local imageClass = GET_EMOTICON_CLASS_BY_ICON_TOKEN(iconToken)
		if imageClass ~= nil then
			if string.find(imageClass.ClassName, "motion_") ~= nil then
				local chatframe = ui.GetFrame("chat")
				local chattype = ui.GetChatType()
				if chattype == 1 and chatframe:IsVisible() == 1 then
					-- 외치기에서는 모션 이모티콘 사용 불가
					break
				end

				--모션 이모티콘
				local namelist = StringSplit(imageClass.ClassName, "motion_")
				local toText = string.format('{spine %s 120 120}{/}', imageClass.ClassName)
				
				return toText
			else
				--일반 이모티콘
				local toText = string.format('{img %s 30 30}{/}', imageClass.ClassName)			
				originText = string.gsub(originText, replaceTargetText, toText)
				totalLen = string.len(originText)
				index = index + string.len(toText)
			end
		else
			index = index + string.len(replaceTargetText)
		end

		loopCount = loopCount + 1
		if loopCount > 1000 then
			break
		end
	end

	return originText
end

