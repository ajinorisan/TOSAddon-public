-- quest_relic.lua
local relicStateInfo = {
	Reward = 1,		-- 보상 받기 가능
	Progress = 2,	-- 진행중
	Clear = 3,		-- 완료
}

local reward_exist = false

local relicQuestList = nil
local function _CLEAR_RELIC_QUEST_LIST()
	relicQuestList = {}
	reward_exist = false
end

local function _GET_RELIC_QUEST_LIST()

	if relicQuestList == nil then
		relicQuestList = {}
	end

	return relicQuestList
end

local function _GET_RELIC_TITLE_INFO(titleName)
	local list = _GET_RELIC_QUEST_LIST()
	if list == nil then
		return nil
	end
	
	for index, titleInfo in pairs(list) do
		if titleInfo.ClassName == titleName then
			return titleInfo
		end
	end

	return nil
end

function GET_RELIC_TITLE_INFO(titleName)
	return _GET_RELIC_TITLE_INFO(titleName)
end

local function _SET_RELIC_QUEST_INFO(titleName, questInfo)
	local titleInfo = _GET_RELIC_TITLE_INFO(titleName)
	local titleCurCount = 0
	if titleInfo == nil then
		-- titleInfo가 없으면 생성
		local list = _GET_RELIC_QUEST_LIST()
		local titleCls = GetClass('Relic_Quest', titleName)
		local rewardCls = GetClass('Relic_Reward', titleName)
		if titleCls == nil or rewardCls == nil then
			return
		end
		local acc = GetMyAccountObj()
		if acc == nil then
			return
		end
		local current, clear = SCR_RELIC_QUEST_CHECK_C(acc, titleCls)
		local makeTitleInfo = {
			ClassName = titleName,
			Name = dic.getTranslatedStr(titleCls.Name),
			Desc = dic.getTranslatedStr(titleCls.Desc),
			Current = current,
			Goal = titleCls.GoalCount1,
			Clear = clear,
			questInfoList = {}
		}
		local index = #list
		list[index + 1] = makeTitleInfo
		titleInfo = list[index + 1]

		-- 보상 수령 가능한 퀘스트가 존재하면 버튼 활성화
		if clear == relicStateInfo.Reward then
			reward_exist = true
		end
	end

	-- 이미 들어 있으면 갱신
	for index, info in pairs(titleInfo.questInfoList) do
		if info.QuestClassID == questInfo.QuestClassID then
			info.Current = questInfo.Current
			return
		end
	end

	-- 없으면 끝에 추가
	local questIndex = #titleInfo.questInfoList
	titleInfo.questInfoList[questIndex + 1] = questInfo
end

-- 세부 항목 현재 진행도 체크
function SCR_RELIC_QUEST_CHECK_C(account, relicCls)
	local curCount = TryGetProp(account, relicCls.AccountProperty, 0)
	local goalCount = relicCls.GoalCount1
	local clear = relicStateInfo.Progress

	local rewardCls = GetClass('Relic_Reward', relicCls.ClassName)
	if rewardCls ~= nil then
		local clearCheck = TryGetProp(account, rewardCls.ClearProperty, 0)
		if clearCheck ~= 0 then
			curCount = goalCount
			clear = relicStateInfo.Clear
		elseif curCount >= goalCount then
			curCount = goalCount
			clear = relicStateInfo.Reward
		end
	end

	return curCount, clear
end

function SET_RELIC_QUEST_INFO(relicCls, questInfo)
	_SET_RELIC_QUEST_INFO(relicCls.Category, questInfo, relicRewardCls)
end

function _UPDATE_RELIC_QUEST_INFO(account, relicCls)
	if relicCls == nil then
		return
	end

	local curCount, clear = SCR_RELIC_QUEST_CHECK_C(account, relicCls) -- 퀘스트 상태
	local questInfo = {
		QuestClassID = relicCls.ClassID,
		Name = dic.getTranslatedStr(relicCls.Name),
		ResetType = relicCls.ResetType,
		Current = curCount,
		Goal = relicCls.GoalCount1,
		Clear = clear,
		Desc = dic.getTranslatedStr(relicCls.Desc)
	}
	SET_RELIC_QUEST_INFO(relicCls, questInfo)

	-- 보상 수령 가능한 퀘스트가 존재하면 버튼 활성화
	if clear == relicStateInfo.Reward then
		reward_exist = true
	end
end

-- 세부 항목 정렬
function RELIC_QUEST_LIST_SORT(a, b)
	if a.Clear ~= b.Clear then
		return a.Clear < b.Clear
	else
		if a.ResetType ~= b.ResetType then
			return a.ResetType < b.ResetType
		else
			return a.QuestClassID < b.QuestClassID
		end
	end
end

function UPDATE_RELIC_QUEST_LIST()
	frame = ui.GetFrame("quest")

	local acc = GetMyAccountObj()
	if acc == nil then
		return
	end

	-- 퀘스트 리스트를 삭제.
	_CLEAR_RELIC_QUEST_LIST()

	-- 퀘스트 정보 업데이트
	local clsList, cnt = GetClassList("Relic_Quest")
	for i = 0, cnt - 1 do
		local relicCls = GetClassByIndexFromList(clsList, i)
		local questType = TryGetProp(relicCls, 'QuestType', 'None')
		if questType ~= 'None' and questType ~= 'Category' then
			_UPDATE_RELIC_QUEST_INFO(acc, relicCls)
		end
	end

	-- 초기화 타입 및 완료 여부 등으로 세부 항목을 정렬
	local list = _GET_RELIC_QUEST_LIST()
	for _, titleInfo in pairs(list) do
		table.sort(titleInfo.questInfoList, RELIC_QUEST_LIST_SORT)
	end

	-- draw
	DRAW_RELIC_QUEST_LIST(frame)

	-- 일괄 수령 버튼 활성화 유무
	local relic_reward_all = GET_CHILD_RECURSIVELY(frame, 'relic_reward_all')
	if reward_exist == true then
		relic_reward_all:SetEnable(1)
	else
		relic_reward_all:SetEnable(0)
	end
end

local function _MAKE_BLACK_SCREEN(frame)
	local gb_body_relic = GET_CHILD_RECURSIVELY(frame, 'gb_body_relic')
	if GET_CHILD(gb_body_relic, 'black_box') ~= nil then
		gb_body_relic:RemoveChild('black_box')
	end

	local black_box = gb_body_relic:CreateControl('groupbox', 'black_box', gb_body_relic:GetWidth(), gb_body_relic:GetHeight(), ui.LEFT, ui.TOP, 0, 0, 0, 0)
	black_box = tolua.cast(black_box, 'ui::CGroupBox')
	black_box:EnableDrawFrame(0)

	local black_screen = black_box:CreateControl('picture', 'black_screen', black_box:GetWidth(), black_box:GetHeight(), ui.LEFT, ui.TOP, 0, 0, 0, 0)
	black_screen = tolua.cast(black_screen, 'ui::CPicture')
	black_screen:SetImage('fullblack')
	black_screen:SetEnableStretch(1)
	black_screen:SetAlpha(90)
	
	--90501 : 길티네가 남긴 것
	local questIES = GetClassByType('QuestProgressCheck', 90501)
	local QuestName = questIES.Name

	local cant_open = black_box:CreateControl('richtext', 'cant_open_text', black_box:GetWidth(), 30, ui.CENTER_HORZ, ui.CENTER_VERT, 0, 0, 0, 0)
	local txt = ScpArgMsg("Relic_Quest_CANT_1", "QUESTNAME", QuestName)
	cant_open:SetTextFixWidth(1)
	cant_open:SetTextAlign('center', 'center')
	cant_open:SetText(txt)
end

function DRAW_RELIC_QUEST_LIST(frame)
	if frame == nil then
		frame = ui.GetFrame('quest')
	end

	-- 퀘스트 창이 닫혀 있다면 갱신하지 않고 리턴
	if frame:IsVisible() == 0 then
		return
	end

	local bgCtrl = GET_CHILD_RECURSIVELY(frame, 'relicGbox')
	if bgCtrl == nil then
		return
	end
	
	bgCtrl:RemoveAllChild()

	local acc = GetMyAccountObj()
	if acc == nil then
		return
	end
	local unlockValue = TryGetProp(acc, 'RQ_UnLock_1', 0)
	local lv = GETMYPCLEVEL()
	if lv < 458 or unlockValue < 1 then
		_MAKE_BLACK_SCREEN(frame)
		return
	end

	local y = 0
	local questList = _GET_RELIC_QUEST_LIST()
	for _, titleInfo in pairs(questList) do
		y = y + DRAW_RELIC_QUEST_TITLE(bgCtrl, titleInfo, y)
	end

	bgCtrl:Invalidate()
	frame:Invalidate()
end

-- titleinfo 정보를 가지고 컨트롤을 생성함.
function DRAW_RELIC_QUEST_TITLE(bgCtrl, titleInfo, y)
	if bgCtrl == nil then
		return 0
	end

	local titleCtrlSet = bgCtrl:CreateOrGetControlSet('relic_quest_title', titleInfo.Name, 0, y)
	if titleCtrlSet == nil then
		return 0
	end
	titleCtrlSet = tolua.cast(titleCtrlSet, "ui::CControlSet")

	local clearState = titleInfo.Clear
	local colorTone = "FFFFFFFF"
	local backGroundSkinName = titleCtrlSet:GetUserConfig("NORMAL_SKIN")
	
	-- title 정보 설정
	local relicTitleGbox = GET_CHILD_RECURSIVELY(titleCtrlSet, "relicTitleGbox")
	relicTitleGbox:SetSkinName(backGroundSkinName)
	relicTitleGbox:SetColorTone(colorTone)
	
	local categoryNameTxt = GET_CHILD_RECURSIVELY(titleCtrlSet, "categoryNameTxt")
	categoryNameTxt:SetTextByKey("name", titleInfo.Name)
	categoryNameTxt:SetColorTone(colorTone)
	categoryNameTxt:SetTextTooltip(titleInfo.Desc)
	
	local totalProgressTxt = GET_CHILD_RECURSIVELY(titleCtrlSet, "totalProgressTxt")
	totalProgressTxt:SetTextByKey("name", math.floor((titleInfo.Current / titleInfo.Goal) * 100) .. '%')
	totalProgressTxt:SetColorTone(colorTone)
	totalProgressTxt:SetTextTooltip(titleInfo.Current .. '/' .. titleInfo.Goal)

	-- 보상상자
	local rewardBtn = GET_CHILD_RECURSIVELY(titleCtrlSet, "rewardBtn")
	local rewardStepBox = GET_CHILD_RECURSIVELY(titleCtrlSet, "rewardStepBox")	
	local rewardDigitNotice = GET_CHILD_RECURSIVELY(titleCtrlSet, "rewardDigitNotice")	
	rewardStepBox:ShowWindow(0)
	rewardDigitNotice:ShowWindow(0)
	rewardBtn:ShowWindow(1)
	rewardBtn:SetEventScriptArgString(ui.LBUTTONUP, titleInfo.ClassName)
	if clearState == relicStateInfo.Reward then
		rewardBtn:SetImage(titleCtrlSet:GetUserConfig("NORMAL_REWARD_BOX"))
		rewardStepBox:ShowWindow(1)
		rewardDigitNotice:ShowWindow(1)
		rewardBtn:SetColorTone(colorTone)
	elseif clearState == relicStateInfo.Clear then
		rewardBtn:SetImage(titleCtrlSet:GetUserConfig("CLEAR_REWARD_BOX"))
		rewardBtn:SetColorTone("FF777777")
	else
		rewardBtn:SetImage(titleCtrlSet:GetUserConfig("LOCK_REWARD_BOX"))
		rewardBtn:SetColorTone(colorTone)
	end

	-- 세부 항목
	local questListGbox = GET_CHILD_RECURSIVELY(titleCtrlSet, "questListGbox")
	local questCtrlTotalHeight = 0

	local drawTargetCount = 0
	local controlSetType = "relic_quest_oneline"
	local controlsetHeight = ui.GetControlSetAttribute(controlSetType, 'height')

	if questListGbox ~= nil then
		-- 퀘스트 목록 순회.
		local questInfoCount = #titleInfo.questInfoList;
		local cnt = 1
		for index = 1, questInfoCount do
			local questInfo = titleInfo.questInfoList[index]
			local ctrlName = "_Q_" .. questInfo.QuestClassID
			local Quest_Ctrl = questListGbox:CreateOrGetControlSet(controlSetType, ctrlName, 5, controlsetHeight * (drawTargetCount))
			
			-- 배경 설정.
			if cnt % 2 == 1 then
				Quest_Ctrl:SetSkinName("chat_window_2")
			else
				Quest_Ctrl:SetSkinName('None')
			end
			cnt = cnt + 1
			
			-- detail 설정
			UPDATE_RELIC_QUEST_CTRL(Quest_Ctrl, questInfo)

			questCtrlTotalHeight = questCtrlTotalHeight + Quest_Ctrl:GetHeight()

			drawTargetCount = drawTargetCount + 1
		end
	end

	titleCtrlSet:Resize(titleCtrlSet:GetWidth(), titleCtrlSet:GetHeight() + questCtrlTotalHeight)
	questListGbox:Resize(questListGbox:GetWidth(), questCtrlTotalHeight)
	titleCtrlSet:Invalidate()

	return titleCtrlSet:GetHeight()
end

function UPDATE_RELIC_QUEST_CTRL(ctrl, questInfo)
	local Quest_Ctrl = 	tolua.cast(ctrl, "ui::CControlSet")
	
	-- 타입(일간, 주간)
	SET_RELIC_QUEST_CTRL_MARK(Quest_Ctrl, questInfo)

	-- 목표, 진행도
	SET_RELIC_QUEST_CTRL_TEXT(Quest_Ctrl, questInfo)

	-- 버튼 설정
	SET_RELIC_QUEST_CTRL_BTN(Quest_Ctrl, questInfo)

	-- 컨트롤 설정
	Quest_Ctrl:SetUserValue("QUEST_CLASSID", questInfo.QuestClassID)

	Quest_Ctrl:ShowWindow(1)
	Quest_Ctrl:EnableHitTest(1)
end


function SET_RELIC_QUEST_CTRL_MARK(ctrl, questInfo)
	local Quest_Ctrl = 	tolua.cast(ctrl, "ui::CControlSet")
	local typePic = GET_CHILD(Quest_Ctrl, "typePic", "ui::CPicture")
	local typePicName = "indun_icon_day_s"

	local type = questInfo.ResetType
	if type == relicResetType.Day then
		typePicName = "indun_icon_day_s"
	elseif type == relicResetType.Week then
		typePicName = "indun_icon_week_s"
    end
    
    if config.GetServiceNation() ~= 'KOR' then
        typePicName = typePicName..'_eng'
    end
	
	typePic:ShowWindow(1)
	typePic:SetImage(typePicName)
end


function SET_RELIC_QUEST_CTRL_TEXT(ctrl, questInfo)
	local Quest_Ctrl = tolua.cast(ctrl, "ui::CControlSet")
	local targetTxt = GET_CHILD(Quest_Ctrl, "targetTxt", "ui::CRichText")
	local progressTxt = GET_CHILD(Quest_Ctrl, "progressTxt", "ui::CRichText")

	local textFont = Quest_Ctrl:GetUserConfig("NORMAL_FONT")
	local textColor = Quest_Ctrl:GetUserConfig("NORMAL_COLOR")
	if questInfo.Clear == relicStateInfo.Clear then
		textFont = Quest_Ctrl:GetUserConfig("COMP_FONT")
		textColor = Quest_Ctrl:GetUserConfig("COMP_COLOR")
	end

	-- 퀘스트 레벨과 이름의 폰트 및 색상 지정
	targetTxt:SetText(textFont .. textColor .. questInfo.Name)
	targetTxt:SetTextTooltip(questInfo.Desc)

	progressTxt:SetText(textColor .. textColor .. math.floor((questInfo.Current / questInfo.Goal) * 100) .. '%')
	progressTxt:SetTextTooltip(questInfo.Current .. '/' .. questInfo.Goal)
end

function SET_RELIC_QUEST_CTRL_BTN(ctrl, questInfo)
	local Quest_Ctrl = 	tolua.cast(ctrl, "ui::CControlSet")
	local rewardPic = GET_CHILD(Quest_Ctrl, "rewardPic", "ui::CPicture")
	local completePic = GET_CHILD(Quest_Ctrl, "completePic", "ui::CButton")
	if rewardPic == nil or completePic == nil then
		return
	end

	rewardPic:ShowWindow(0)
	completePic:ShowWindow(0)

	if questInfo.Clear == relicStateInfo.Clear then
		completePic:ShowWindow(1)
	else
		rewardPic:ShowWindow(1)
		rewardPic:SetEventScriptArgNumber(ui.LBUTTONUP, questInfo.QuestClassID)
		if questInfo.Clear == relicStateInfo.Progress then
			rewardPic:SetImage(Quest_Ctrl:GetUserConfig("LOCK_REWARD_BOX"))
		end
	end
end

-- 카테고리 보상
function CLICK_RELIC_CATEGORY_REWARD(ctrlSet, ctrl, strArg, numArg)
	if strArg == nil or strArg == '' then
		return
	end

	local relicRewardIES = GetClass('Relic_Reward', strArg)
	if relicRewardIES == nil then
		return
	end

	local frame = ctrlSet:GetTopParentFrame()
	local xPos = frame:GetWidth() - 50
    
    QUEST_RELIC_REWARD_INFO(strArg, xPos, {})
end

-- 세부 항목 보상
function CLICK_RELIC_QUEST_REWARD(ctrlSet, ctrl, strArg, numArg)
	if numArg == nil or numArg == 0 then
		return
	end

	local relicRewardIES = GetClassByType('Relic_Reward', numArg)
	if relicRewardIES == nil then
		return
	end

	local frame = ctrlSet:GetTopParentFrame()
	local xPos = frame:GetWidth() - 50
    
    QUEST_RELIC_REWARD_INFO(relicRewardIES.ClassName, xPos, {})
end

-- 보상 일괄 수령 버튼
function _CHECK_REWARD_ALL_BTN()
	local frame = ui.GetFrame('quest')
	local btn = GET_CHILD_RECURSIVELY(frame, 'relic_reward_all')
	
	if reward_exist == true then
		btn:SetEnable(1)
	end
end

function _DISABLE_REWARD_ALL_BTN()
	local frame = ui.GetFrame('quest')
	local btn = GET_CHILD_RECURSIVELY(frame, 'relic_reward_all')
	if btn ~= nil then
		ReserveScript('_CHECK_REWARD_ALL_BTN()', 1)
    	btn:SetEnable(0)
	end
end

function CLICK_RELIC_QUEST_REWARD_ALL(parent, ctrl)
	local argStr = ""
	_DISABLE_REWARD_ALL_BTN()
	pc.ReqExecuteTx("SCR_TX_RELIC_QUEST_REWARD_ALL", argStr)
end