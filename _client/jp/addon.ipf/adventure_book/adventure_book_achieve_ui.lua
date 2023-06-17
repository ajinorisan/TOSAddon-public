ADVENTURE_BOOK_ACHIEVE = {};
ADVENTURE_BOOK_ACHIEVE_LIST_INFO = {}
local ADVENTURE_BOOK_ACHIEVE_LIST_MAX_SHOW = 10

function ADVENTURE_BOOK_ACHIEVE.RENEW(category, isRenewInfo)
	ADVENTURE_BOOK_ACHIEVE.CLEAR(category)
	local achieve_list = ADVENTURE_BOOK_ACHIEVE.FILL_LIST(category)

	local frame = ui.GetFrame("adventure_book")
	local gb_achieve = frame:GetChild('gb_achieve')

	local page = gb_achieve:GetChild("page_achieve_list_"..category)
	if page == nil then return end

	local page_right = page:GetChild("page_achieve_list_"..category.."_right")
	if page_right == nil then return end

	if isRenewInfo ~= nil and isRenewInfo == 1 then
		ADVENTURE_BOOK_ACHIEVE.FILL_INFO(category, achieve_list[1])
	end
end

function ADVENTURE_BOOK_ACHIEVE.CLEAR(category)
	local frame = ui.GetFrame('adventure_book');
	local gb_achieve = GET_CHILD(frame, "gb_achieve")

	local page = GET_CHILD(gb_achieve, "page_achieve_list_"..category, "ui::CGroupBox");
	local page_left = GET_CHILD(page, "page_achieve_list_"..category.."_left", "ui::CGroupBox");
	local list_box = GET_CHILD(page_left, "list_achieve_"..category, "ui::CGroupBox");
	
	list_box:RemoveAllChild();
end

function ADVENTURE_BOOK_ACHIEVE.FILL_LIST(category)
	local frame = ui.GetFrame('adventure_book');
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local page = GET_CHILD(gb_achieve, "page_achieve_list_"..category, "ui::CGroupBox");
	local page_left = GET_CHILD(page, "page_achieve_list_"..category.."_left", "ui::CGroupBox");
	local list_box = GET_CHILD(page_left, "list_achieve_"..category, "ui::CGroupBox");

	local subCategory = ADVENTURE_BOOK_ACHIEVE_GET_SELECT_SUBCATEGORY(category)
	local achieve_list = {}

	local category_name
	if category == "search" then
		category_name = category
		local change_search_option = page_left:GetUserIValue("CHANGE_SEARCH_OPTION")
		if change_search_option == 1 then
			achieve_list = ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_ALL(category)
			page_left:SetUserValue("CHANGE_SEARCH_OPTION", "0")
		else
			if ADVENTURE_BOOK_ACHIEVE_LIST_INFO["search"] ~= nil and
			   ADVENTURE_BOOK_ACHIEVE_LIST_INFO["search"][2] ~= nil then
				achieve_list = ADVENTURE_BOOK_ACHIEVE_LIST_INFO["search"][2]
			else
				achieve_list = ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_ALL(category)
			end
		end
	else
		category_name = category.."_"..subCategory
		achieve_list = ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_ALL(category, subCategory, 1)
	end

	ADVENTURE_BOOK_ACHIEVE.FILL_LIST_CONTROL(achieve_list, list_box, category_name)
	list_box:SetScrollPos(0)

	local text_desc = GET_CHILD(page_left, "text_desc", "ui::CRichText");
	if #achieve_list == 0 then
		text_desc:SetVisible(1)
	else
		text_desc:SetVisible(0)
	end

	if category ~= "search" then
		local is_reward = 0
		for i = 1, #achieve_list do
			local clsID = achieve_list[i]
			if ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_HAVE_REWARD(clsID) == 1 and
			   ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_COMPLETE(clsID) == 1 then
				is_reward = 1
				break
			end
		end

		local btn_reward_all = GET_CHILD(page_left, "btn_"..category.."_reward_all")
		btn_reward_all:SetEnable(is_reward)
		
		if btn_reward_all ~= nil then
			btn_reward_all:SetUserValue("MainCategory", category)
			btn_reward_all:SetUserValue("SubCategory", subCategory)
		end
	end

	return achieve_list
end

-- category: maincategory_subcategory, ADVENTURE_BOOK_ACHIEVE_LIST_INFO에서 사용
function ADVENTURE_BOOK_ACHIEVE.FILL_LIST_CONTROL(list, list_box, category)
	list_box:RemoveAllChild()

	local y = 0
	local drawGroup = {}
	local drawCnt = 0
	local idxLast = 0
	for idx = 1, #list do
		local clsID = list[idx]
		local cls = GetClassByType("Achieve", clsID);
		local info = ADVENTURE_BOOK_ACHIEVE_CONTENT.ACHIEVE_INFO(clsID)

		local isDraw = false
		if info['level_group_name'] == nil then -- 레벨 그룹 정보가 없음
			isDraw = true
		else -- 레벨 그룹 정보가 있음
			if drawGroup[info['level_group_name']] == nil then
				-- 이전 레벨에 받을 수 있는 보상이 있으면 보상이 있는걸 먼저 보여줌
				-- 이전 레벨에 받을 수 있는 보상이 없으면 그룹의 가장 높은 레벨 하나만 보여줌
				local groupCnt = GetLevelAchieveCount(info['level_group_name'])
				if groupCnt > 0 then
					local viewID = 0
					for i = 1, groupCnt do
						local ClassID = GetAchieveByGroupLevel(info['level_group_name'], i)
						if ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_COMPLETE(ClassID) == 1 then
							if ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_HAVE_REWARD(ClassID) == 1 then
								viewID = ClassID
								break
							end
						else
							viewID = GetCurProgressLevelAchieve(info['level_group_name'])
							break
						end
					end
					drawGroup[info['level_group_name']] = viewID
					if viewID ~= 0 then
						isDraw = true
						if viewID ~= clsID then
							-- ID가 다르면 정보 다시 가져옴
							clsID = viewID
							cls = GetClassByType("Achieve", clsID);
							info = ADVENTURE_BOOK_ACHIEVE_CONTENT.ACHIEVE_INFO(clsID)
						end
					end
				end
			end
		end

		if isDraw == true and cls ~= nil and info ~= nil then
			local ctrlSet = list_box:CreateOrGetControlSet("adventure_book_achieve_summary", "list_achieve_"..clsID, ui.LEFT, ui.TOP, 0, y, 0, 0)
			y = ADVENTURE_BOOK_ACHIEVE.UPDATE_LIST_CONTROLSET(cls, clsID, info, ctrlSet, y)
			drawCnt = drawCnt + 1
			idxLast = idx
			if drawCnt >= ADVENTURE_BOOK_ACHIEVE_LIST_MAX_SHOW then
				break
			end
		end
	end

	ADVENTURE_BOOK_ACHIEVE_LIST_INFO[category] = { idxLast, list, drawGroup }
	list_box:SetUserValue("CATEGORY", category)
	list_box:SetEventScript(ui.SCROLL, "ADVENTURE_BOOK_ACHIEVE_ON_SCROLL")
end

function ADVENTURE_BOOK_ACHIEVE_ON_SCROLL(frame, ctrl, argstr, argnum)
	if (ctrl:GetScrollCurPos() <= 0) or (ctrl:GetScrollCurPos() < ctrl:GetScrollBarMaxPos()) then
		return
	end
	
	local category = ctrl:GetUserValue("CATEGORY")
	if ADVENTURE_BOOK_ACHIEVE_LIST_INFO[category] == nil then return end

	local idxLast = ADVENTURE_BOOK_ACHIEVE_LIST_INFO[category][1]
	local list = ADVENTURE_BOOK_ACHIEVE_LIST_INFO[category][2]
	local drawGroup = ADVENTURE_BOOK_ACHIEVE_LIST_INFO[category][3]
	if idxLast == nil or list == nil or drawGroup == nil then return end
	if idxLast < ADVENTURE_BOOK_ACHIEVE_LIST_MAX_SHOW or idxLast >= #list then return end
	
	local drawStart = idxLast
	local ctrlSetLast = ctrl:GetChildByIndex(ctrl:GetChildCount() - 1)
	if ctrlSetLast == nil then
		return
	end
	local drawCnt = 0
	local y = ctrlSetLast:GetY() + ctrlSetLast:GetHeight()
	for i = idxLast + 1, #list do
		local idx = i
		local clsID = list[idx]
		if clsID == nil then
			break
		end
		local cls = GetClassByType("Achieve", clsID);
		local info = ADVENTURE_BOOK_ACHIEVE_CONTENT.ACHIEVE_INFO(clsID)

		local isDraw = false
		if info['level_group_name'] == nil then -- 레벨 그룹 정보가 없음
			isDraw = true
		else -- 레벨 그룹 정보가 있음
			-- 그룹의 가장 높은 레벨 하나만 보여줌
			if drawGroup[info['level_group_name']] == nil then
				local progressID = GetCurProgressLevelAchieve(info['level_group_name'])
				drawGroup[info['level_group_name']] = progressID
				if progressID ~= 0 then
					isDraw = true
					if progressID ~= clsID then
						-- ID가 다르면 정보 다시 가져옴
						clsID = progressID
						cls = GetClassByType("Achieve", clsID);
						info = ADVENTURE_BOOK_ACHIEVE_CONTENT.ACHIEVE_INFO(clsID)
					end
				end
			end
		end

		if isDraw == true and cls ~= nil and info ~= nil then
			local ctrlSet = ctrl:CreateOrGetControlSet("adventure_book_achieve_summary", "list_achieve_"..clsID, ui.LEFT, ui.TOP, 0, y, 0, 0)
			y = ADVENTURE_BOOK_ACHIEVE.UPDATE_LIST_CONTROLSET(cls, clsID, info, ctrlSet, y)
			drawCnt = drawCnt + 1
			idxLast = idx
			if drawCnt >= ADVENTURE_BOOK_ACHIEVE_LIST_MAX_SHOW then
				break
			end
		end
	end
	ADVENTURE_BOOK_ACHIEVE_LIST_INFO[category] = { idxLast, list, drawGroup }
end

function ADVENTURE_BOOK_ACHIEVE.UPDATE_LIST_CONTROLSET(cls, clsID, info, ctrlSet, y)
	ctrlSet:SetUserValue("clsID", clsID)

	-- 그룹박스
	local gb = GET_CHILD(ctrlSet, "gb")
	gb:SetEventScript(ui.LBUTTONUP, "ADVENTURE_BOOK_ACHIEVE_SELECT")
	gb:SetEventScriptArgNumber(ui.LBUTTONUP, clsID)

	-- 카테고리 아이콘
	local clsAchieveInfo = GetClassByStrProp("AchieveInfo", "ClassName", cls.MainCategory);
	local icon_pic = GET_CHILD(ctrlSet, "icon_pic", "ui::CPicture")
	icon_pic:SetImage(TryGetProp(clsAchieveInfo, "Icon", "None"))

	-- 시계 아이콘
	local icon_clock = GET_CHILD(ctrlSet, "icon_clock", "ui::CPicture")
	local isEnableTime, remainsec = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_REMAIN_TIME(clsID)
	icon_clock:SetVisible(isEnableTime)
		
	if isEnableTime == 1 then
		local endtime = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_END_TIME(clsID)
		local impendenceTime = 3 * 24 * 60 * 60
		if impendenceTime > remainsec then
			icon_clock:SetImage("achievement_time_attack02")
		end
		icon_clock:SetTextTooltip(ScpArgMsg("adventure_book_achieve_endtime_tooltip", "ENDTIME", endtime))
	end

	-- 텍스트
	local desc = GET_CHILD(ctrlSet, "desc", "ui::CRichText")
	SET_TEXT(ctrlSet, "title", "title", info['title'])

	local desclist = StringSplit(info['desc'], '{nt}')
	SET_TEXT(ctrlSet, "desc", "value", desclist[1])

	if info['level_group_name'] == nil then
		if info['is_complete'] == 1 then
			SET_TEXT(ctrlSet, "title", "level", "Max")
		else
			SET_TEXT(ctrlSet, "title", "level", "1")
		end
	else
		if info['is_complete'] == 1 and (GetGroupAchieveMaxLevel(info['level_group_name']) == tonumber(info['group_level'])) then
			SET_TEXT(ctrlSet, "title", "level", "Max")
		else
			SET_TEXT(ctrlSet, "title", "level", info['group_level'])
		end
	end

	local yoffset = 0
	if desc:GetHeight() > 45 then
		yoffset = desc:GetHeight() - 45 + 10
	end

	-- 추적
	local chase = GET_CHILD(ctrlSet, "chase", "ui::CButton")
	local chase_enable = 1

	if ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_COMPLETE(argNum) == 1 then chase_enable = 0 end
	if ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_TIME_END(argNum) == 1 then chase_enable = 0 end
	if info['main_category'] == "Event" and info['sub_category'] == "End" then chase_enable = 0 end

	if chase_enable == 1 then
		chase:SetEventScript(ui.LBUTTONUP, "ADVENTURE_BOOK_ACHIEVE_CLICK_CHASE_BTN");
		chase:SetEventScriptArgNumber(ui.LBUTTONUP, clsID);
		ADVENTURE_BOOK_ACHIEVE_CHECK_CHASE_B(chase, info['is_chase'])
	else
		chase:SetEventScript(ui.LBUTTONUP, "");
		chase:SetEventScriptArgNumber(ui.LBUTTONUP, 0);
		ADVENTURE_BOOK_ACHIEVE_CHECK_CHASE_B(chase, 0)
	end
	
	--  게이지
	local gauge = GET_CHILD(ctrlSet, "gauge_score", "ui::CGauge")
	
	local point = 0
	local maxpoint = 0
	if info['level_group_name'] ~= nil then
		local prev_needpoint = GetPrevLevelAchieveNeedCount(clsID)
		point = math.max(0, info['point'] - prev_needpoint)
		maxpoint = info['need_count'] - prev_needpoint
	else
		point = info['point']
		maxpoint = info['need_count']
	end
	gauge:SetPoint(point, maxpoint)
	gauge:SetTextStat(0, GET_COMMAED_STRING(point).." / "..GET_COMMAED_STRING(maxpoint))

	local colortone_enable = "FFFFFFFF"
	local colortone_disable = "FF333333"

	-- 보상 슬롯
	local reward_cnt = 0
	local slotset = GET_CHILD(ctrlSet, "slotset_reward")

	-- 보상: 칭호
	if info['name'] ~= nil then
		local icon = CreateIcon(slotset:GetSlotByIndex(reward_cnt))
		icon:SetTextTooltip(ScpArgMsg("adventure_book_achieve_reward_name_tooltip", "NAME", info['name']))
		icon:SetImage("icon_item_holyark");
		reward_cnt = reward_cnt + 1
	end

	-- 보상: 구보상 (무조건 1개만 들어가는 것으로 가정함)
	if info['reward'] ~= nil then
		if info['reward_type'] == "Item" then
			local ItemInfo = StringSplit(info['reward'], '/')
			local cls = GetClassByStrProp("Item", "ClassName", ItemInfo[1])
			if cls ~= nil then
				local icon = CreateIcon(slotset:GetSlotByIndex(reward_cnt))
				
				iconName = BEAUTYSHOP_SIMPLELIST_ICONNAME_CHECK(TryGetProp(cls, "Icon", "None"), TryGetProp(cls, "UseGender", "None"))
				icon:SetImage(iconName)

				SET_ITEM_TOOLTIP_BY_NAME(icon, cls.ClassName);
				icon:SetTooltipOverlap(1);
				reward_cnt = reward_cnt + 1
			end
		elseif info['reward_type'] == "HairColor" then
			local icon = CreateIcon(slotset:GetSlotByIndex(reward_cnt))
			icon:SetImage(info['reward_icon'])
			icon:SetTextTooltip(info['reward'])
			reward_cnt = reward_cnt + 1
		end
	end
	-- 보상: 신보상
	if info['reward_count'] ~= nil and info['reward_count'] > 0  then
		for i = 1, math.min(info['reward_count'], slotset:GetSlotCount()) do
			local icon = CreateIcon(slotset:GetSlotByIndex(reward_cnt))
			local cls = GetClassByStrProp("Item", "ClassName", info['reward_item'..i])
			
			if cls ~= nil then
				iconName = BEAUTYSHOP_SIMPLELIST_ICONNAME_CHECK(TryGetProp(cls, "Icon", "None"), TryGetProp(cls, "UseGender", "None"))
				icon:SetImage(iconName)

				SET_ITEM_TOOLTIP_BY_NAME(icon, cls.ClassName);
				icon:SetTooltipOverlap(1);
			end
			reward_cnt = reward_cnt + 1				
		end

	end

	-- 아이콘 색상
	local icon_colortone = "FFFFFF"
	if info['is_complete'] == 1 or info['is_timeend'] == 1 then
		if info['is_reward'] == 1 then
			icon_colortone = "FFFFFFFF"
		else
			icon_colortone = "FF333333"
		end
	elseif info['main_category'] == "Event" and info['sub_category'] == 'End' then
		icon_colortone = "FF333333"
	else
		icon_colortone = "FF777777"
	end

	for i = 0, reward_cnt - 1 do
		local icon = slotset:GetIconByIndex(i)
		icon:SetColorTone(icon_colortone)
	end

	local slotCount = slotset:GetSlotCount()
	for i = 0, slotCount - 1 do
		local slot = slotset:GetSlotByIndex(i)
		if info['is_complete'] == 1 and info['is_reward'] == 1 then
			slot:SetSkinName('None')
		else
			slot:SetSkinName('slot')
		end
	end

	-- 완료 색상
	local colortone = colortone_enable
	if info['is_reward'] == 0 then
		if info['is_complete'] == 1 or
			info['is_timeend'] == 1 or
			info['main_category'] == "Event" and info['sub_category'] == 'End' then
			colortone = colortone_disable
		end
	end
	
	GET_CHILD(ctrlSet, "gb"):SetColorTone(colortone)
	GET_CHILD(ctrlSet, "icon_pic"):SetColorTone(colortone)
	GET_CHILD(ctrlSet, "gauge_score"):SetColorTone(colortone)
	GET_CHILD(ctrlSet, "chase"):SetColorTone(colortone)
	GET_CHILD(ctrlSet, "title"):SetColorTone(colortone)
	GET_CHILD(ctrlSet, "titlebg"):SetColorTone(colortone)
	icon_clock:SetColorTone(colortone)

	-- Set Cls ID
	ctrlSet:SetUserValue('BtnArg', clsID);

	gb:Resize(gb:GetWidth(), gb:GetHeight() + yoffset)
	ctrlSet:Resize(ctrlSet:GetWidth(), ctrlSet:GetHeight() + yoffset)
	return y + ctrlSet:GetHeight()
end

function ADVENTURE_BOOK_ACHIEVE.FILL_INFO(category, clsID)
	if category == nil then return end
	
	local achieve_info_func = ADVENTURE_BOOK_ACHIEVE_CONTENT["ACHIEVE_INFO"]
	local info = achieve_info_func(clsID)
	if info == nil then return end

	local cls = GetClassByType("Achieve", clsID)
	if cls == nil then return end

	local frame = ui.GetFrame("adventure_book")
	local gb_achieve = frame:GetChild('gb_achieve')
	
	local page = gb_achieve:GetChild("page_achieve_list_"..category)
	if page == nil then return end

	local page_right = page:GetChild("page_achieve_list_"..category.."_right")
	if page_right == nil then return end
	
	page_right:RemoveAllChild()
	
	local ctrlSet = page_right:CreateOrGetControlSet("adventure_book_achieve_info", "achieve_info", ui.LEFT, ui.TOP, 0, 0, 0, 0)
	page_right:SetUserValue("clsID", clsID)

	local gb_title = GET_CHILD(ctrlSet, "gb_title")

	-- 카테고리
	local gb_category = GET_CHILD(gb_title, "gb_category")
	local icon_category_main = GET_CHILD(gb_category, "icon_category_main", "ui::CPicture")
	local text_category_main = GET_CHILD(gb_category, "text_category_main", "ui::CRichText")
	local text_category_sub = GET_CHILD(gb_category, "text_category_sub", "ui::CRichText")
	local text_category_arrow = GET_CHILD(gb_category, "text_category_arrow", "ui::CRichText")

	if info['main_category'] ~= nil then
		icon_category_main:SetImage(info['main_category_icon'])
		text_category_main:SetText(ClMsg(info['main_category_name']))
		ctrlSet:SetUserValue("MainCategory", info['main_category'])
		
		if category == "search" then
			text_category_main:SetFontName("blue_16_b")
			text_category_main:SetEventScript(ui.LBUTTONUP, "ADVENTURE_BOOK_ACHIEVE_SELECT")
			text_category_main:SetEventScriptArgString(ui.LBUTTONUP, "SearchLink")
			text_category_main:SetEventScriptArgNumber(ui.LBUTTONUP, clsID)
		end
	else
		icon_category_main:SetImage("")
		text_category_main:SetText("")
	end


	if info['sub_category'] ~= nil then
		text_category_sub:SetText(ClMsg(info['sub_category_name']))
		ctrlSet:SetUserValue("SubCategory", info['sub_category'])
		
		if category == "search" then
			text_category_sub:SetFontName("blue_16_b")
			text_category_sub:SetEventScript(ui.LBUTTONUP, "ADVENTURE_BOOK_ACHIEVE_SELECT")
			text_category_sub:SetEventScriptArgString(ui.LBUTTONUP, "SearchLink")
			text_category_sub:SetEventScriptArgNumber(ui.LBUTTONUP, clsID)
		end
	else
		text_category_sub:SetText("")
	end

	text_category_main:Resize(text_category_main:GetTextWidth(), text_category_main:GetHeight())
	text_category_sub:Resize(text_category_sub:GetTextWidth(), text_category_sub:GetHeight())
	text_category_arrow:Resize(text_category_arrow:GetTextWidth(), text_category_arrow:GetHeight())

	text_category_arrow:SetMargin(
		text_category_main:GetMargin().left + text_category_main:GetWidth(),
		text_category_arrow:GetMargin().top,
		0, 0
	)
	text_category_sub:SetMargin(
		text_category_arrow:GetMargin().left + text_category_arrow:GetWidth(),
		text_category_sub:GetMargin().top,
		0, 0
	)
	gb_category:Resize(
		text_category_sub:GetMargin().left + text_category_sub:GetWidth(),
		gb_category:GetHeight()
	)

	-- 마스터 업적 안내문
	local gb_notice = GET_CHILD(gb_title, "gb_notice")
	if info['sub_category'] == "MasterQuest" then
		gb_notice:SetVisible(1)
	else
		gb_notice:SetVisible(0)
	end

	-- 기간
	local gb_lifetime = GET_CHILD(gb_title, "gb_lifetime")
	local icon_clock = GET_CHILD(gb_lifetime, "icon_clock", "ui::CPicture")
	local text_lifetime = GET_CHILD(gb_lifetime, "text_lifetime", "ui::CRichText")

	local isEnableTime, remainsec = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_REMAIN_TIME(clsID)
	icon_clock:SetVisible(isEnableTime)
	text_lifetime:SetVisible(isEnableTime)

	if isEnableTime == 1 then
		local endtime = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_END_TIME(clsID)
		if endtime ~= "None" then
			icon_clock:SetTextTooltip(ScpArgMsg("adventure_book_achieve_endtime_tooltip", "ENDTIME", endtime))
		end

		if remainsec > 0 then
			local day =  math.floor(remainsec/86400)
			local hour = math.floor(remainsec/3600) - (day * 24)
			local min = math.floor(remainsec/60) - (day * 24 * 60) - (hour * 60)
			local sec = math.floor(remainsec%60)

			local time = string.format("%02d:%02d:%02d", hour, min, sec)
			text_lifetime:SetText(ScpArgMsg("adventure_book_achieve_period_remaining_time", "DAY", day, "TIME", time))
		else
			text_lifetime:SetText(ScpArgMsg("adventure_book_achieve_period_end"))
		end

		local impendenceTime = 3 * 24 * 60 * 60
		if impendenceTime > remainsec then
			icon_clock:SetImage("achievement_time_attack02")
			text_lifetime:SetFontName("limitedsale_14")
		end
	end

	-- 타이틀
	local text_title = GET_CHILD(gb_title, "text_title", "ui::CRichText")
	text_title:SetText(info['title'])

	-- 레벨
	local gb_level = GET_CHILD(gb_title, "gb_level")
	local text_level = GET_CHILD(gb_level, "text_level", "ui::CRichText")

	if info['level_group_name'] == nil then
		if info['is_complete'] == 1 then
			text_level:SetText("Max")
		else
			text_level:SetText("Lv. "..1)
		end
	else
		if info['is_complete'] == 1 and (GetGroupAchieveMaxLevel(info['level_group_name']) == tonumber(info['group_level'])) == true then
			text_level:SetText("Max")
		else
			text_level:SetText("Lv. "..info['group_level'])
		end
	end
	
	local btn_level_prev = GET_CHILD(gb_level, 'btn_level_prev', "ui::CButton")
	local btn_level_next = GET_CHILD(gb_level, 'btn_level_next', "ui::CButton")

	if info['level_group_name'] ~= nil then
		btn_level_prev:SetEventScript(ui.LBUTTONUP, "ADVENTURE_BOOK_ACHIEVE_INFO_LEVEL_PREV")
		btn_level_prev:SetEventScriptArgNumber(ui.LBUTTONUP, clsID)
		
		btn_level_next:SetEventScript(ui.LBUTTONUP, "ADVENTURE_BOOK_ACHIEVE_INFO_LEVEL_NEXT")
		btn_level_next:SetEventScriptArgNumber(ui.LBUTTONUP, clsID)
	end

	-- 달성률 게이지
	local gauge_score = GET_CHILD(gb_title, "gauge_score", "ui::CGauge")
	local point = 0
	local maxpoint = 0
	if info['level_group_name'] ~= nil then
		local prev_needpoint = GetPrevLevelAchieveNeedCount(clsID)
		point = math.max(0, info['point'] - prev_needpoint)
		maxpoint = info['need_count'] - prev_needpoint
	else
		point = info['point']
		maxpoint = info['need_count']
	end
	gauge_score:SetPoint(point, maxpoint)
	gauge_score:SetTextStat(0, GET_COMMAED_STRING(point).." / "..GET_COMMAED_STRING(maxpoint))


	-- 보상 수령 버튼 (수령 가능할 때에만 활성화)
	local btn_reward = GET_CHILD(gb_title, "btn_reward", "ui::CButton")
	if info['is_complete'] == 1 and info['is_reward'] == 1 then
		btn_reward:SetEnable(1)
	else
		btn_reward:SetEnable(0)
	end
	btn_reward:SetUserValue("BtnArg", clsID)
	
	-- 설명
	local gb_goal = GET_CHILD(ctrlSet, "gb_goal", "ui::CGauge")
	gb_goal:RemoveAllChild()

	local y = 0
	local content_space = 20
	local desclist = StringSplit(info['desc'], '{nt}')
	for i = 1, #desclist do
		local ctrlSet_goal = gb_goal:CreateOrGetControlSet("adventure_book_achieve_info_goal", "achieve_goal_desc"..i, ui.LEFT, ui.TOP, 0, y, 0, 0)
		local text_content = GET_CHILD(ctrlSet_goal, "text_content", "ui::CRichText")
		local icon_pic = GET_CHILD(ctrlSet_goal, "icon_pic")
		text_content:SetText(desclist[i])
		ctrlSet_goal:Resize(ctrlSet_goal:GetWidth(), math.max(text_content:GetHeight(), icon_pic:GetHeight()))
		y = y + ctrlSet_goal:GetHeight() + content_space
	end

	-- 보상: 아이템
	local gb_reward = GET_CHILD(ctrlSet, "gb_reward")
	local gb_reward_item = GET_CHILD(gb_reward, "gb_reward_item")
	local gb_reward_item_content_bg = GET_CHILD(gb_reward_item, "gb_reward_item_content_bg")
	local gb_reward_item_content_slot_bg = GET_CHILD(gb_reward_item_content_bg, "gb_reward_item_content_slot_bg")
	local left_btn = GET_CHILD(gb_reward_item_content_bg, "left_btn")
	local right_btn = GET_CHILD(gb_reward_item_content_bg, "right_btn")
	local slotset = GET_CHILD(gb_reward_item_content_slot_bg, "slotset_list_reward", "ui::CSlotSet")
	
	local rewardCnt = 0
	local oldRewardCnt = 0
	local slotMaxCnt = slotset:GetSlotCount()
	local max_view = 5
	-- 보상: 구보상 (무조건 1개만 들어가는 것으로 가정함)
	if info['reward'] ~= nil then
		if info['reward_type'] == "Item" then
			local ItemInfo = StringSplit(info['reward'], '/')
			local cls = GetClassByStrProp("Item", "ClassName", ItemInfo[1])
			if cls ~= nil then
				local slot = slotset:GetSlotByIndex(0)
				local icon = CreateIcon(slotset:GetSlotByIndex(rewardCnt))
				
				SET_SLOT_COUNT_TEXT(slot, ItemInfo[2])

				iconName = BEAUTYSHOP_SIMPLELIST_ICONNAME_CHECK(TryGetProp(cls, "Icon", "None"), TryGetProp(cls, "UseGender", "None"))
				icon:SetImage(iconName)

				SET_ITEM_TOOLTIP_BY_NAME(icon, cls.ClassName);
				icon:SetTooltipOverlap(1);
				rewardCnt = rewardCnt + 1
				oldRewardCnt = oldRewardCnt + 1
			end
		elseif info['reward_type'] == "HairColor" then
			local icon = CreateIcon(slotset:GetSlotByIndex(rewardCnt))
			icon:SetImage(info['reward_icon'])
			icon:SetTextTooltip(info['reward'])
			rewardCnt = rewardCnt + 1
		end
	end
	-- 보상: 신보상
	if info['reward_count'] ~= nil and info['reward_count'] > 0  then
		for i = 1, info['reward_count'] do
			local slot;
			if rewardCnt >= slotMaxCnt then
				slotMaxCnt = slotMaxCnt + 1
				slot = slotset:AddSlot("slot"..slotMaxCnt, (slotset:GetSlotWidth() + slotset:GetSpcX()) * (slotMaxCnt - 1), 0, slotset:GetSlotWidth(), slotset:GetSlotHeight())
				slot:SetSkinName("invenslot2")
			else
				slot = slotset:GetSlotByIndex(i - 1 + oldRewardCnt)
			end
			
			local icon = CreateIcon(slotset:GetSlotByIndex(rewardCnt))
			local cls = GetClassByStrProp("Item", "ClassName", info['reward_item'..i])
			SET_SLOT_COUNT_TEXT(slot, info['reward_count'..i])

			if cls ~= nil then
				iconName = BEAUTYSHOP_SIMPLELIST_ICONNAME_CHECK(TryGetProp(cls, "Icon", "None"), TryGetProp(cls, "UseGender", "None"))
				icon:SetImage(iconName)

				SET_ITEM_TOOLTIP_BY_NAME(icon, cls.ClassName);
				icon:SetTooltipOverlap(1);
			end
			rewardCnt = rewardCnt + 1				
		end
	end

	gb_reward_item_content_slot_bg:SetUserValue("pos", 1)
	gb_reward_item_content_slot_bg:SetUserValue("max_view", max_view)
	left_btn:SetEnable(0)

	if rewardCnt > max_view then
		right_btn:SetEnable(1)
	else
		right_btn:SetEnable(0)
	end

	-- 보상: 칭호
	local gb_reward_name = GET_CHILD(gb_reward, "gb_reward_name")
	SET_TEXT(gb_reward_name, "text_reward_name_content", "value", info['name'])

	-- 보상: 업적 EXP
	local gb_reward_exp = GET_CHILD(gb_reward, "gb_reward_exp")
	SET_TEXT(gb_reward_exp, "text_reward_exp_content", "value", info['exp'])
end

-- clsID:
-- nil인 경우 현재 선택중인 페이지가 갱신됨
-- clsID가 있는 경우 현재 선택중인 페이지와 ClsID가 같을 경우 갱신해줌
function ADVENTURE_BOOK_ACHIEVE.FILL_INFO_RENEW(mainCategory, clsID)
	local frame = ui.GetFrame("adventure_book")
	local gb_achieve = frame:GetChild('gb_achieve')
	
	local page = gb_achieve:GetChild("page_achieve_list_"..mainCategory)
	if page == nil then return end

	local page_right = page:GetChild("page_achieve_list_"..mainCategory.."_right")
	if page_right == nil then return end
	
	local ctrlSet = page_right:CreateOrGetControlSet("adventure_book_achieve_info", "achieve_info", ui.LEFT, ui.TOP, 0, 0, 0, 0)
	local curClsID = page_right:GetUserIValue("clsID")

	if clsID == nil then
		clsID = curClsID
	else
		if clsID ~= curClsID then return end
	end
	
	local cls = GetClassByType("Achieve", clsID)
	if cls == nil then return end
	
	ADVENTURE_BOOK_ACHIEVE.FILL_INFO(mainCategory, clsID)
end

function ADVENTURE_BOOK_ACHIEVE.SET_SCROLL_POS(category, clsID)
	local frame = ui.GetFrame("adventure_book")
	local gb_achieve = frame:GetChild('gb_achieve')
	
	local page = gb_achieve:GetChild("page_achieve_list_"..category)
	if page == nil then return end

	local page_left = page:GetChild("page_achieve_list_"..category.."_left")
	if page_left == nil then return end

	local list_box = page_left:GetChild("list_achieve_"..category)
	if list_box == nil then return end
	AUTO_CAST(list_box)
	
	if clsID == nil then
		return
	elseif clsID == 0 then
		list_box:SetScrollPos(0)
	else
		local ctrlset = GET_CHILD(list_box, "list_achieve_"..clsID)
		if ctrlset ~= nil then
			list_box:SetScrollPos(ctrlset:GetY())
		end
	end
end

function ADVENTURE_BOOK_ACHIEVE.INIT_SCROLL_POS(category)
	ADVENTURE_BOOK_ACHIEVE.SET_SCROLL_POS(category, 0)
end

function ADVENTURE_BOOK_ACHIEVE.INIT_SEARCH_FILTER_OPTION()
	local frame = ui.GetFrame("adventure_book")
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local page_achieve_list_search = GET_CHILD(gb_achieve, "page_achieve_list_search")
	local page_achieve_list_search_left = GET_CHILD(page_achieve_list_search, "page_achieve_list_search_left")
	local droplist_option_maincategory = GET_CHILD(page_achieve_list_search_left, "droplist_option_maincategory", "ui::CDropList")
	droplist_option_maincategory:ClearItems()
	local droplist_option_subcategory = GET_CHILD(page_achieve_list_search_left, "droplist_option_subcategory", "ui::CDropList")
	droplist_option_subcategory:ClearItems()

	local listMain = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_SEARCH_FILTER_OPTION_LIST_MAINCATEGORY()
	for i = 1, #listMain do
		droplist_option_maincategory:AddItem(listMain[i][1], ClMsg(listMain[i][2]))
	end

	local listSub = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_SEARCH_FILTER_OPTION_LIST_SUBCATEGORY("All")

	for i = 1, #listSub do
		droplist_option_subcategory:AddItem(listSub[i][1], ClMsg(listSub[i][2]))
	end

end

function ADVENTURE_BOOK_ACHIEVE.OFF_CHASE_BTN(clsID)
	if clsID == nil then return end
	
	ADVENTURE_BOOK_ACHIEVE_REMOVE_CHASE(clsID)
	ADVENTURE_BOOK_ACHIEVE.UPDATE_CTRL_INFO(clsID, 'is_chase')
	ON_UPDATE_ACHIEVEINFOSET()
end

-- 업데이트
-- updateInfo: 업데이트할 정보
function ADVENTURE_BOOK_ACHIEVE.UPDATE_CTRL_INFO(clsID, updateInfo)
	if clsID == nil then return end

	local frame = ui.GetFrame("adventure_book")
	local mainTab = GET_CHILD(frame, "mainTab")
	if mainTab:GetSelectItemName() ~= "tab_main_achieve" then
		return
	end

	local info = ADVENTURE_BOOK_ACHIEVE_CONTENT.ACHIEVE_INFO(clsID)

	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local achieveTab = GET_CHILD(gb_achieve, "achieveTab")
	local selectedTabName = achieveTab:GetSelectItemName()
	local page_list = {}

	if selectedTabName == "tab_achieve_main" then
	-- 메인 / 진행도가 높은 업적, 신규 업적
		local page_achieve_main = GET_CHILD(gb_achieve, "page_achieve_main")
		local achieve_main_high_progress_list = GET_CHILD(page_achieve_main, "achieve_main_high_progress_list")
		local achieve_main_new_achieve_list = GET_CHILD(page_achieve_main, "achieve_main_new_achieve_list")
		table.insert(page_list, achieve_main_high_progress_list)
		table.insert(page_list, achieve_main_new_achieve_list)

	elseif selectedTabName == "tab_achieve_search" then
	-- 검색
		local page_achieve_list_search = GET_CHILD(gb_achieve, "page_achieve_list_search")
		local page_achieve_list_search_left = GET_CHILD(page_achieve_list_search, "page_achieve_list_search_left")
		local list_achieve_search = GET_CHILD(page_achieve_list_search_left, "list_achieve_search")
		table.insert(page_list, list_achieve_search)

	elseif selectedTabName == "tab_achieve_list_"..info['main_category'] then
	-- 메인 카테고리 탭
		local page_achieve_list = GET_CHILD(gb_achieve, "page_achieve_list_"..info['main_category'])
		local page_achieve_list_left = GET_CHILD(page_achieve_list, "page_achieve_list_"..info['main_category'].."_left")
		local list_achieve = GET_CHILD(page_achieve_list_left, "list_achieve_"..info['main_category'])
		table.insert(page_list, list_achieve)
	end
	
	if updateInfo == 'is_chase' then
		for i = 1, #page_list do
			local ctrl = GET_CHILD(page_list[i], "list_achieve_"..clsID)
			ADVENTURE_BOOK_ACHIEVE_CHECK_CHASE_C(ctrl, info['is_chase'])
		end
	end
end

function ADVENTURE_BOOK_ACHIEVE_CHECK_CHASE_C(ctrl, check)
	if ctrl == nil then return end
	local btn = GET_CHILD(ctrl, "chase", "ui::CButton")
	ADVENTURE_BOOK_ACHIEVE_CHECK_CHASE_B(btn, check)
end

function ADVENTURE_BOOK_ACHIEVE_CHECK_CHASE_B(btn, check)
	if btn == nil then return end

	if check == 1 or check == true then
		btn:SetImage("achievement_favicon_on")
		btn:SetUserValue("ON", "true")
		btn:Invalidate()
	else
		btn:SetImage("achievement_favicon")
		btn:SetUserValue("ON", "false")
		btn:Invalidate()
	end
end

-- argNum: Class ID
function ADVENTURE_BOOK_ACHIEVE_INFO_LEVEL_PREV(frame, msg, argStr, argNum)
	local clsIDPrev = GetPrevLevelAchieve(argNum)
	if clsIDPrev == argNum then
		return
	end
	local info = ADVENTURE_BOOK_ACHIEVE_CONTENT.ACHIEVE_INFO(clsIDPrev)

	local frame = ui.GetFrame('adventure_book')
    local gb_achieve = GET_CHILD(frame, 'gb_achieve');
	local achieveTab = GET_CHILD(gb_achieve, 'achieveTab');
	local selectedTabName = achieveTab:GetSelectItemName();

	local category = "";
	local selectedTabName = achieveTab:GetSelectItemName();
	if selectedTabName == "tab_achieve_search" then
		category = "search"
	else
		category = info['main_category']
	end

	ADVENTURE_BOOK_ACHIEVE.FILL_INFO(category, clsIDPrev)
end

-- argNum: Class ID
function ADVENTURE_BOOK_ACHIEVE_INFO_LEVEL_NEXT(frame, msg, argStr, argNum)
	local clsIDNext = GetNextLevelAchieve(argNum)
	if clsIDNext == argNum or clsIDNext == 0 then
		return
	end
	local info = ADVENTURE_BOOK_ACHIEVE_CONTENT.ACHIEVE_INFO(clsIDNext)

	local frame = ui.GetFrame('adventure_book')
    local gb_achieve = GET_CHILD(frame, 'gb_achieve');
	local achieveTab = GET_CHILD(gb_achieve, 'achieveTab');
	local selectedTabName = achieveTab:GetSelectItemName();

	local category = "";
	local selectedTabName = achieveTab:GetSelectItemName();
	if selectedTabName == "tab_achieve_search" then
		category = "search"
	else
		category = info['main_category']
	end

	ADVENTURE_BOOK_ACHIEVE.FILL_INFO(category, clsIDNext)
end
