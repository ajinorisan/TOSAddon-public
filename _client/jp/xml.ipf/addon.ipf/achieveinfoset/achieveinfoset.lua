
function ACHIEVEINFOSET_ON_INIT(addon, frame)
	-- addon:RegisterMsg('GAME_START', 'ON_UPDATE_ACHIEVEINFOSET'); -- chaseinfo로 이동
	addon:RegisterMsg('ACHIEVE_POINT', 'ON_UPDATE_ACHIEVEINFOSET');
end

function ACHIEVEINFOSET_GET_CHASE_NUM()
	return achieve.GetChaseAchieveCount();
end

function ACHIEVEINFOSET_IS_VALID_ACHIEVE()
	local achieveNum = ACHIEVEINFOSET_GET_CHASE_NUM()
	if achieveNum > 0 then
		return 1
	end

	return 0
end

-- questinfoset_2 보여줄건지 여부
function ACHIEVEINFOSET_IS_DRAW()
	local frame = ui.GetFrame("achieveinfoset")

	-- PVP 맵에서는 출력하지 않음
	if UI_CHECK_NOT_PVP_MAP() == 0 then
        return 0
    end
	
	if ACHIEVEINFOSET_IS_VALID_ACHIEVE() == 0 then
		return 0
	end
	
	return 1
end

function ON_UPDATE_ACHIEVEINFOSET()
	local frame = ui.GetFrame("achieveinfoset")

	if CHASEINFO_IS_SHOW() == 0 then
		CHASEINFO_CLOSE_FRAME()
		return
	end

	-- Toggle Button / Fold
	CHASEINFO_SHOW_QUEST_TOGGLE(QUESTINFOSET_2_IS_DRAW())
	CHASEINFO_SHOW_ACHIEVE_TOGGLE(ACHIEVEINFOSET_IS_DRAW())

	if ACHIEVEINFOSET_IS_DRAW() == 0 then
		frame:ShowWindow(0)
		return
	else
		if QUESTINFOSET_2_IS_DRAW() == 1 then
			if CHASEINFO_IS_QUEST_FOLD() == 0 then
				CHASEINFO_SET_ACHIEVE_INFOSET_FOLD(1)
			else
				if CHASEINFO_IS_ACHIEVE_FOLD() == 1 then
					CHASEINFO_SET_ACHIEVE_INFOSET_FOLD(1)
				else
					CHASEINFO_SET_ACHIEVE_INFOSET_FOLD(0)
				end
			end
		else
			CHASEINFO_SET_ACHIEVE_INFOSET_FOLD(0)
		end
	end
	
	-- Frame
	if QUESTINFOSET_2_IS_VALID_QUEST() == 1 and CHASEINFO_IS_QUEST_FOLD() == 0 then
		frame:ShowWindow(0)
		return
	elseif CHASEINFO_IS_ACHIEVE_FOLD() == 1 then
		frame:ShowWindow(0)
		return
	else
		frame:ShowWindow(1)
	end
    
	-- 모든 자식 리스트 삭제
	local GroupCtrl = GET_CHILD(frame, "member", "ui::CGroupBox");
    GroupCtrl:DeleteAllControl();
	
	-- 그리기
	MAKE_ACHIEVE_INFO(GroupCtrl);
end

function MAKE_ACHIEVE_INFO(gBox)
	local y = 0 
	local cnt = ACHIEVEINFOSET_GET_CHASE_NUM();
	for i = 0 , cnt - 1 do
        local achieveID = achieve.GetChaseAchieve(i);
		local achieveCls = GetClassByType("Achieve", achieveID);
		if achieveCls == nil then
			break
		end

		if ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_COMPLETE(achieveID) == 1 then
			ADVENTURE_BOOK_ACHIEVE.OFF_CHASE_BTN(achieveID)
		else
			local ctrlname = "_A_" .. achieveCls.ClassID;
			y = y + MAKE_ACHIEVE_INFO_BASE_CTRL(gBox, ctrlname, 0, y, achieveCls);
		end
	end
	gBox:Resize(gBox:GetWidth(), 500)
end

-- questinfoset_2에 정의되어있음
local DEFAULT_START_X = 30
local CTRLSET_BODY_OFFSET_X = 60
local CTRLSET_TITLE_SPACE_Y = 10
local CTRLSET_MARGIN_BOTTOM = 10
local SCROLL_WIDTH = 30
local SCROLL_WIDTH_TITLE = 90
function MAKE_ACHIEVE_INFO_BASE_CTRL(gBox, ctrlname, x, y, cls)
	local clsID = cls.ClassID
	local info = ADVENTURE_BOOK_ACHIEVE_CONTENT.ACHIEVE_INFO(clsID)

	local ctrlset = gBox:CreateOrGetControlSet('emptyset2', ctrlname, x, y);
	tolua.cast(ctrlset, 'ui::CControlSet');
	local topFrame = ui.GetFrame('achieveinfoset');
	topFrame:EnableHitTest(1)
	-- 배경
	ctrlset:SetSkinName("quest_bg_black_op_50");
	ctrlset:SetAlpha(GET_QUESTINFOSET_TRANSPARENCY());
	ctrlset:Resize(gBox:GetWidth() - gBox:GetX(), ctrlset:GetHeight());

	local titleX = DEFAULT_START_X
	local bodyX = titleX + CTRLSET_BODY_OFFSET_X

	-- 아이콘
	local picture = ctrlset:CreateOrGetControl('picture', "icon", titleX+10, 15, 30, 30);
	tolua.cast(picture, "ui::CPicture");
	picture:EnableHitTest(0);
	picture:SetImage(info['main_category_icon']);
	picture:SetEnableStretch(1);

	local x = titleX + 50
	local titleY = 17
	local y = titleY

	-- 업적 이름
	local title = ctrlset:CreateOrGetControl('richtext', 'title', x, y, ctrlset:GetWidth() - x - SCROLL_WIDTH_TITLE, 30);
	AUTO_CAST(title)
	title:EnableEllipsisTextTooltip(1)
	title:EnableTextOmitByWidth(1)
	title:SetTextFixWidth(1)
	title:SetText(QUEST_TITLE_FONT..info['title']);
	y = y + title:GetHeight()

	y = y + CTRLSET_TITLE_SPACE_Y

	-- 목표: 목표
	local desclist = StringSplit(info['desc'], '{nt}')
	local desc = desclist[1]

	local content = ctrlset:CreateOrGetControl('richtext', 'goal', bodyX, y, ctrlset:GetWidth() - x - SCROLL_WIDTH , 10);
	content:EnableHitTest(0);
	content:SetTextFixWidth(1);
	content:SetText('{@st42b}'..desc);
	y = y + content:GetHeight()+5;

	-- 게이지
	local gauge = ctrlset:CreateOrGetControl('gauge', "gauge", bodyX, y, ctrlset:GetWidth() - x - SCROLL_WIDTH, 20);
	tolua.cast(gauge, "ui::CGauge");
	gauge:AddStat("%v/%m"); 				-- 게이지 위에 v/m 의 형태로 표현한다.
	gauge:SetStatFont(0,"white_14_ol");	-- 폰트
	gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT); -- 정렬
	gauge:SetSkinName("gauge_produce_gold");
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

	gauge:SetPoint(point, maxpoint);
	y = y + gauge:GetHeight();

	local iconX = 22;
	local iconY = titleY;
	local iconSize = 22;

	-- 버튼: chase
	local chaseBtn = ctrlset:CreateOrGetControl('checkbox', "chaseBtn", iconSize, iconSize, ui.RIGHT, ui.TOP, 0, iconY - 1, iconX, 0);
	tolua.cast(chaseBtn, "ui::CCheckBox");
	chaseBtn:SetSkinName("checkbox_fav");
	chaseBtn:SetEventScript(ui.LBUTTONUP, "ADVENTURE_BOOK_ACHIEVE_CLICK_REMOVE_ACHIEVE_CHASE");
	chaseBtn:SetEventScriptArgNumber(ui.LBUTTONUP, cls.ClassID);
	chaseBtn:SetCheck(1)
	chaseBtn:EnableHitTest(1)
	chaseBtn:ShowWindow(1)
	
	iconX = iconX + iconSize + 6;

	-- 버튼: 업적 UI
	local shortcutBtn = ctrlset:CreateOrGetControl('button', "shortcutBtn", iconSize, iconSize, ui.RIGHT, ui.TOP, 0, iconY, iconX, 0);
	tolua.cast(shortcutBtn, "ui::CButton");
	shortcutBtn:SetImage("achievement_ui_open_btn");
	shortcutBtn:SetEventScript(ui.LBUTTONUP, "ADVENTURE_BOOK_ACHIEVE_SELECT")
	shortcutBtn:SetEventScriptArgNumber(ui.LBUTTONUP, cls.ClassID)
	shortcutBtn:SetEventScriptArgString(ui.LBUTTONUP, "Chase");
	shortcutBtn:EnableHitTest(1)
	shortcutBtn:ShowWindow(1);

	y = y + CTRLSET_MARGIN_BOTTOM

	ctrlset:Resize(gBox:GetWidth(), y);

	return y
end

-- function TOGGLE_ACHIEVE_INFOSET_FOLDER(parent, ctrl, argStr, argNum)
-- 	local frame = ui.GetFrame("achieveinfoset")

-- 	local member = GET_CHILD(frame, "member")
-- 	if member == nil then return end

-- 	local openMark = GET_CHILD_RECURSIVELY(frame, "openMark")
-- 	if openMark == nil then return end

-- 	local uiFold = frame:GetUserValue('UI_FOLD')
-- 	if uiFold == nil or uiFold == "false" then
-- 		TOGGLE_ACHIEVE_INFOSET_FOLD_ON()
-- 	else
-- 		TOGGLE_ACHIEVE_INFOSET_FOLD_OFF()
-- 		TOGGLE_QUEST_INFOSET_FOLD_ON()
-- 	end
-- end

-- function TOGGLE_ACHIEVE_INFOSET_FOLD_ON()
-- 	local frame = ui.GetFrame("achieveinfoset")
	
-- 	local member = GET_CHILD(frame, "member")
-- 	if member == nil then return end

-- 	local openMark = GET_CHILD_RECURSIVELY(frame, "openMark")
-- 	if openMark == nil then return end

-- 	frame:SetUserValue('UI_FOLD', "true");
-- 	frame:Resize(frame:GetWidth(), 25)
-- 	member:ShowWindow(0)
-- 	openMark:SetImage("quest_arrow_l_btn");
-- end

-- function TOGGLE_ACHIEVE_INFOSET_FOLD_OFF()
-- 	local frame = ui.GetFrame("achieveinfoset")
	
-- 	local member = GET_CHILD(frame, "member")
-- 	if member == nil then return end

-- 	local openMark = GET_CHILD_RECURSIVELY(frame, "openMark")
-- 	if openMark == nil then return end

-- 	frame:SetUserValue('UI_FOLD', "false");
-- 	member:ShowWindow(1)
-- 	member:EnableHitTest(1)
-- 	frame:EnableHittestFrame(1)
-- 	openMark:SetImage("quest_arrow_r_btn");

-- 	ON_UPDATE_ACHIEVEINFOSET()
-- end

-- 업적 추적창에서 추적 끔
-- argNum: Achieve ClassID
function ADVENTURE_BOOK_ACHIEVE_CLICK_REMOVE_ACHIEVE_CHASE(parent, ctrl, argStr, argNum)
	if achieve.IsChaseAchieve(argNum) == false then return end
	ADVENTURE_BOOK_ACHIEVE.OFF_CHASE_BTN(argNum)
end
