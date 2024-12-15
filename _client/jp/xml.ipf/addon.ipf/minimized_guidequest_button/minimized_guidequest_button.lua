function MINIMIZED_GUIDEQUEST_BUTTON_ON_INIT(addon, frame)
	addon:RegisterMsg('GAME_START', 'MINIMIZED_GUIDEQUEST_BUTTON_INIT')
	addon:RegisterMsg('ACHIEVE_REWARD', 'MINIMIZED_GUIDEQUEST_ON_MSG')
	addon:RegisterMsg('ACHIEVE_REWARD_ALL', 'MINIMIZED_GUIDEQUEST_ON_MSG')
	addon:RegisterMsg('ACHIEVE_NEW', 'MINIMIZED_GUIDEQUEST_ON_MSG')
end

function MINIMIZED_GUIDEQUEST_BUTTON_INIT(frame, msg, arg_str, arg_num)
	local mapprop = session.GetCurrentMapProp()
	local mapCls = GetClassByType('Map', mapprop.type)

	local housingPlaceClass = GetClass('Housing_Place', mapCls.ClassName)
	if housingPlaceClass ~= nil then
		ui.CloseFrame('minimized_guidequest_button')
		return
	end

	MINIMIZED_GUIDEQUEST_ON_MSG(frame, msg, arg_str, arg_num)
end

local function _GET_REWARD_ENABLE_GUIDEQUEST_ACHIEVE_LIST()
	local reward_list = {}
	local clsList, cnt = GetClassListByProp('Achieve', 'SubCategory', 'GuideQuest')
	for i = 1, cnt do
		local cls = clsList[i]
		local clsID = TryGetProp(cls, 'ClassID', 0)
		if ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_VISIBLE(clsID) == 1 then
			if ADVENTURE_BOOK_ACHIEVE_CONTENT.CHECK_COUNTRY(clsID) == 1 then
				if ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_COMPLETE(clsID) == 1 then  -- 성공 여부
					if ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_HAVE_REWARD(clsID) == 1 then -- 보상받을것 여부
						table.insert(reward_list, clsID) -- 성공O 보상받을것O
					end
				end
			end
		end
	end

	return reward_list
end

function MINIMIZED_GUIDEQUEST_ON_MSG(frame, msg, arg_str, arg_num)
	if frame:IsVisible() ~= 1 then return end

	if msg =='GAME_START' or msg == 'ACHIEVE_REWARD' or msg == 'ACHIEVE_REWARD_ALL' or msg == 'ACHIEVE_NEW' then
		MINIMIZED_GUIDEQUEST_NOTICE(frame)
	end
end

function MINIMIZED_GUIDEQUEST_NOTICE(frame)
	local list = _GET_REWARD_ENABLE_GUIDEQUEST_ACHIEVE_LIST()
	local point = #list

	local notice = GET_CHILD_RECURSIVELY(frame, 'notice_bg')    
	local noticeText = GET_CHILD(notice, 'notice_text')

	if point > 0 then
		notice:ShowWindow(1)
		noticeText:ShowWindow(1)
		noticeText:SetTextByKey('value',tostring(point))
        SYSMENU_NOTICE_TEXT_RESIZE(notice, point)
	elseif point == 0 then
		notice:ShowWindow(0)
		noticeText:ShowWindow(0)
	end
end

function MINIMIZED_GUIDEQUEST_NOTICE_TEXT_RESIZE(box, point)
    if point >= 10 and point < 100 then
		box:Resize(30, 22)
	elseif point >= 100 and point < 1000 then
		box:Resize(40, 22)
	else
		box:Resize(22, 22)
	end
end

function MINIMIZED_GUIDEQUEST_BUTTON_CLICK(parent, ctrl)
	ui.ToggleFrame('adventure_book')

	local adventure_book = ui.GetFrame('adventure_book')
	if adventure_book:IsVisible() == 1 then
		local tab_main = GET_CHILD_RECURSIVELY(adventure_book, 'mainTab')
		tab_main:SelectTab(0)

		local tab_achieve = GET_CHILD_RECURSIVELY(adventure_book, 'achieveTab')
		tab_achieve:SelectTab(2)

		ADVENTURE_BOOK_ACHIEVE_SELECT_SUBCATEGORY(nil, nil, 'GuideQuest', 1)
	end
end
