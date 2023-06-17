-- quest_episode.lua
function UPDATE_EPISODE_QUEST_LIST();
	UpdateEpisodeQuest();
end

-- titleinfo 정보를 가지고 컨트롤을 생성함.
function DRAW_EPISODE_QUEST_CTRL(bgCtrl, titleInfo_episodeName, titleInfo_name, titleInfo_number, titleInfo_isOpened, titleInfo_questCount, titleInfo_questID, titleInfo_questState, y)
	if bgCtrl == nil then
		return 0;
	end

	local titleCtrlSet = bgCtrl:CreateOrGetControlSet('episode_list_title', titleInfo_episodeName, 0, y );
	if titleCtrlSet == nil then
		return 0;
	end
	titleCtrlSet = tolua.cast(titleCtrlSet, "ui::CControlSet");


	local pcObj = GetMyPCObject();

	-- 보상 상태
	-- 1. 락
	-- 2. 클리어 - 모두 완료했고 보상을 가져갔음
	-- 3. 보상 받기 가능
	-- 4. 진행중
	-- 5. 최신 에피소드
	local episodeState = geQuest.episode.GetState(titleInfo_episodeName);
	local colorTone = "FFFFFFFF";
	local backGroundSkinName = titleCtrlSet:GetUserConfig("NORMAL_SKIN");

	local textToolTip = nil;

	-- 이 아래는 locked, Clear일 때는 그릴 필요가 없음.
	local questMapTitleGbox = GET_CHILD_RECURSIVELY(titleCtrlSet, "questMapTitleGbox")
	local questListGbox = GET_CHILD_RECURSIVELY(titleCtrlSet, "questListGbox")
	local questCtrlTitleHeight = 0;
	local questCtrlTotalHeight =0;


	if TUTORIAL_CLEAR_CHECK(pcObj) == true then
		if episodeState == geQuest.episode.eLocked then
			colorTone = titleCtrlSet:GetUserConfig("LOCK_COLORTONE");
			backGroundSkinName = titleCtrlSet:GetUserConfig("LOCK_SKIN");
		elseif episodeState == geQuest.episode.eNext then
			colorTone = titleCtrlSet:GetUserConfig("LOCK_COLORTONE");
			backGroundSkinName = titleCtrlSet:GetUserConfig("LOCK_SKIN");
		elseif episodeState == geQuest.episode.eClear then
			colorTone = titleCtrlSet:GetUserConfig("CLEAR_COLORTONE");
		end

		
		if episodeState == geQuest.episode.eLocked then
			textToolTip = ScpArgMsg("EpisodeLockMsg")
		elseif episodeState == geQuest.episode.eNew then
			local Msg = '_'..titleInfo_episodeName
			textToolTip = ScpArgMsg("NewEpisodeLockMsg"..Msg)
		elseif episodeState == geQuest.episode.eNext then
			textToolTip = ScpArgMsg("NextEpisodeLockMsg")
		elseif episodeState == geQuest.episode.eClear then
			textToolTip = ScpArgMsg("EpisodeClearMsg")
		end 
	
		-- title 정보 설정
		local episodeGbox = GET_CHILD_RECURSIVELY(titleCtrlSet, "episodeGbox")
		local episodeNameText = GET_CHILD_RECURSIVELY(titleCtrlSet, "episodeNameText")
		local questNameText = GET_CHILD_RECURSIVELY(titleCtrlSet, "questNameText")
		episodeGbox:SetSkinName(backGroundSkinName);
		episodeGbox:SetColorTone(colorTone);
		episodeNameText:SetTextByKey("name", titleInfo_number);
		episodeNameText:SetColorTone(colorTone);
		questNameText:SetTextByKey("name", titleInfo_name);
		questNameText:SetColorTone(colorTone);

		if textToolTip ~= nil then
			episodeGbox:SetTextTooltip(textToolTip)
			episodeGbox:EnableHitTest(1);
		end


		-- 상태 이미지 처리
		local clearMark = GET_CHILD_RECURSIVELY(titleCtrlSet, "clearMark")	
		local lockMark = GET_CHILD_RECURSIVELY(titleCtrlSet, "lockMark")
		clearMark:ShowWindow(0);
		lockMark:ShowWindow(0);
		if episodeState == geQuest.episode.eLocked then
			lockMark:ShowWindow(1);
			if textToolTip ~= nil then
				lockMark:SetTextTooltip(textToolTip)
			end
		elseif episodeState == geQuest.episode.eClear then
			clearMark:ShowWindow(1);
			clearMark:SetEventScriptArgString(ui.LBUTTONUP, titleInfo_episodeName); -- episode name
			clearMark:SetEventScript(ui.LBUTTONUP, 'CLICK_EPISODE_REWARD');
			clearMark:EnableHitTest(1);
			if textToolTip ~= nil then
				clearMark:SetTextTooltip(textToolTip)
			end
		end

		-- 보상상자
		local rewardBtn = GET_CHILD_RECURSIVELY(titleCtrlSet, "rewardBtn")	
		local rewardStepBox = GET_CHILD_RECURSIVELY(titleCtrlSet, "rewardStepBox")	
		local rewardDigitNotice = GET_CHILD_RECURSIVELY(titleCtrlSet, "rewardDigitNotice")	
		rewardStepBox:ShowWindow(0);
		rewardDigitNotice:ShowWindow(0);
		rewardBtn:ShowWindow(1);
		rewardBtn:SetEventScriptArgString(ui.LBUTTONUP, titleInfo_episodeName); -- episode name
		if episodeState == geQuest.episode.eReward then
			rewardStepBox:ShowWindow(1);
			rewardDigitNotice:ShowWindow(1);
			rewardBtn:SetColorTone(colorTone);
		elseif episodeState == geQuest.episode.eClear then
			rewardBtn:SetImage(titleCtrlSet:GetUserConfig("CLEAR_REWARD_BOX"));
			rewardBtn:SetColorTone(colorTone);
			rewardBtn:ShowWindow(0);
		elseif episodeState == geQuest.episode.eLocked then
			rewardBtn:SetImage(titleCtrlSet:GetUserConfig("LOCK_REWARD_BOX"));
		elseif episodeState == geQuest.episode.eNew then
			rewardBtn:SetImage(titleCtrlSet:GetUserConfig("LOCK_REWARD_BOX"));
		elseif episodeState == geQuest.episode.eNext then
			rewardBtn:SetImage(titleCtrlSet:GetUserConfig("LOCK_REWARD_BOX"));
		else
			rewardBtn:SetColorTone(colorTone);
		end




		if episodeState ~= geQuest.episode.eLocked and episodeState ~= geQuest.episode.eNext then
			-- 퀘스트 목록 제목
			local openMark = GET_CHILD_RECURSIVELY(titleCtrlSet, "openMark")	
			openMark:SetImage(titleCtrlSet:GetUserConfig("OPENED_CTRL_IMAGE"))
			-- 오픈 마크 처리.
			if titleInfo_isOpened == true then
				openMark:SetImage(titleCtrlSet:GetUserConfig("CLOSED_CTRL_IMAGE"))
			end

			questCtrlTitleHeight = titleCtrlSet:GetUserConfig("QUEST_CTRL_TITLE_HEIGHT");
			
			-- 퀘스트 목록
			local drawTargetCount = 0
			local controlSetType = "episode_list_oneline"
			local controlsetHeight = ui.GetControlSetAttribute(controlSetType, 'height');

			if questListGbox ~= nil and titleInfo_isOpened == true then -- 트리가 열려있을 때만 컨트롤 생성
				-- 퀘스트 목록 순회.
				local questInfoCount = titleInfo_questCount;
				for index = 1, questInfoCount do
					local ctrlName = "_Q_" .. tostring(titleInfo_questID[index]);
					local Quest_Ctrl = questListGbox:CreateOrGetControlSet(controlSetType, ctrlName, 5, controlsetHeight * (drawTargetCount));			
					
					-- 배경 설정.
					if index % 2 == 1 then
						Quest_Ctrl:SetSkinName("chat_window_2");
					else
						Quest_Ctrl:SetSkinName('None');
					end
					
					-- detail 설정
					UPDATE_EPISODE_QUEST_CTRL(Quest_Ctrl, titleInfo_questID[index], titleInfo_questState[index] );

					questCtrlTotalHeight = questCtrlTotalHeight + Quest_Ctrl:GetHeight();
					drawTargetCount = drawTargetCount +1
				end
			end
		end
	else
		colorTone = titleCtrlSet:GetUserConfig("LOCK_COLORTONE");
		backGroundSkinName = titleCtrlSet:GetUserConfig("LOCK_SKIN");

		textToolTip = ScpArgMsg("EpisodeLockMsg_TUTO")
	
		-- title 정보 설정
		local episodeGbox = GET_CHILD_RECURSIVELY(titleCtrlSet, "episodeGbox")
		local episodeNameText = GET_CHILD_RECURSIVELY(titleCtrlSet, "episodeNameText")
		local questNameText = GET_CHILD_RECURSIVELY(titleCtrlSet, "questNameText")
		episodeGbox:SetSkinName(backGroundSkinName);
		episodeGbox:SetColorTone(colorTone);
		episodeNameText:SetTextByKey("name", titleInfo_number);
		episodeNameText:SetColorTone(colorTone);
		questNameText:SetTextByKey("name", titleInfo_name);
		questNameText:SetColorTone(colorTone);

		if textToolTip ~= nil then
			episodeGbox:SetTextTooltip(textToolTip)
			episodeGbox:EnableHitTest(1);
		end


		-- 상태 이미지 처리
		local clearMark = GET_CHILD_RECURSIVELY(titleCtrlSet, "clearMark")	
		local lockMark = GET_CHILD_RECURSIVELY(titleCtrlSet, "lockMark")
		clearMark:ShowWindow(0);
		lockMark:ShowWindow(0);

		lockMark:ShowWindow(1);
		if textToolTip ~= nil then
			lockMark:SetTextTooltip(textToolTip)
		end


		-- 보상상자
		local rewardBtn = GET_CHILD_RECURSIVELY(titleCtrlSet, "rewardBtn")	
		local rewardStepBox = GET_CHILD_RECURSIVELY(titleCtrlSet, "rewardStepBox")	
		local rewardDigitNotice = GET_CHILD_RECURSIVELY(titleCtrlSet, "rewardDigitNotice")	
		rewardStepBox:ShowWindow(0);
		rewardDigitNotice:ShowWindow(0);
		rewardBtn:ShowWindow(1);
		rewardBtn:SetEventScriptArgString(ui.LBUTTONUP, titleInfo_episodeName); -- episode name

		rewardBtn:SetImage(titleCtrlSet:GetUserConfig("LOCK_REWARD_BOX"));


	end
	titleCtrlSet:Resize(titleCtrlSet:GetWidth(),titleCtrlSet:GetHeight() + questCtrlTitleHeight + questCtrlTotalHeight )
	questMapTitleGbox:Resize(questMapTitleGbox:GetWidth(), questCtrlTitleHeight)
	questListGbox:Resize(questListGbox:GetWidth(), questCtrlTotalHeight)
	titleCtrlSet:Invalidate();
	return titleCtrlSet:GetHeight()

end

function UPDATE_EPISODE_QUEST_CTRL(ctrl, questClassID, questState)

	local Quest_Ctrl = 	tolua.cast(ctrl, "ui::CControlSet"); 

	local state = questState;
	local questID = questClassID;
	local questIES = GetClassByType('QuestProgressCheck',questID)
	
	-- 퀘스트 마크 설정
	SET_EPISODE_QUEST_CTRL_MARK(Quest_Ctrl, questIES, state);

	-- 레벨, 이름 설정.
	SET_EPISODE_QUEST_CTRL_TEXT(Quest_Ctrl, questIES, state)

	-- 버튼 설정
	SET_EPISODE_QUEST_CTRL_BTN(Quest_Ctrl, questIES, state)

	-- 컨트롤 설정
	Quest_Ctrl:SetUserValue("QUEST_CLASSID", questIES.ClassID);
	Quest_Ctrl:SetUserValue("QUEST_LEVEL", questIES.Level)

	Quest_Ctrl:ShowWindow(1);
	Quest_Ctrl:EnableHitTest(1);
	
end


function SET_EPISODE_QUEST_CTRL_MARK(ctrl, questIES, state)
	local Quest_Ctrl = 	tolua.cast(ctrl, "ui::CControlSet"); 
	local questIconImgName = "minimap_1_MAIN";
	local questMarkPic = GET_CHILD(Quest_Ctrl, "questmark", "ui::CPicture");
	if state == "COMPLETE" then
		questIconImgName = "minimap_clear"
	end
	
	questMarkPic:ShowWindow(1);
	questMarkPic:SetImage(questIconImgName);
end


function SET_EPISODE_QUEST_CTRL_TEXT(ctrl, questIES, state)
	local Quest_Ctrl = 	tolua.cast(ctrl, "ui::CControlSet"); 
	local nametxt = GET_CHILD(Quest_Ctrl, "name", "ui::CRichText");
	local leveltxt = GET_CHILD(Quest_Ctrl, "level", "ui::CRichText");


	local textFont = Quest_Ctrl:GetUserConfig("NORMAL_FONT")
	local textColor = Quest_Ctrl:GetUserConfig("NORMAL_COLOR")
	if state == "COMPLETE" then
		textFont =  Quest_Ctrl:GetUserConfig("COMP_FONT")
		textColor =  Quest_Ctrl:GetUserConfig("COMP_COLOR")
	end

	-- 퀘스트 레벨과 이름의 폰트 및 색상 지정.
	nametxt:SetText(textFont .. textColor .. questIES.Name)	
	leveltxt:SetText(textColor .. textColor .. "Lv " .. questIES.Level)
end

function SET_EPISODE_QUEST_CTRL_BTN(ctrl, questIES, state)
	local Quest_Ctrl = 	tolua.cast(ctrl, "ui::CControlSet"); 
	local questLink = GET_CHILD(Quest_Ctrl, "questLink", "ui::CCheckBox");
	local complete = GET_CHILD(Quest_Ctrl, "complete", "ui::CButton");
	if questLink == nil or complete == nil then
		return
	end

	questLink:ShowWindow(0);
	complete:ShowWindow(0);

	if state == "POSSIBLE" or state == "PROGRESS" or state == "SUCCESS" then
		questLink:ShowWindow(1);
		questLink:SetEventScriptArgNumber(ui.LBUTTONUP, questIES.ClassID);
	elseif state == "COMPLETE" then
		complete:ShowWindow(1);
	end
end

function SCR_LINK_EPISODE_QUEST(ctrlSet, ctrl, strArg, numArg)
	local questClassID = numArg; 

	ON_SERACH_QUEST_NAME(questClassID)
	ON_QUEST_GROUP_OPEN(questClassID)
	ON_MAIN_QUEST_FILTER();
	ON_CHANGE_QUEST_TAB()
	
end

function CLICK_EPISODE_REWARD(ctrlSet, ctrl, strArg, numArg)
	if strArg == nil or strArg =="" then
		return;
	end
	
	local frame = ctrlSet:GetTopParentFrame();
	local xPos = frame:GetWidth() -50;
    
    QUESTEPISODEREWARD_INFO(strArg, xPos, {} );
	
end
