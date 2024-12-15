
-- questinfoset_2, achieveinfoset용 더미 UI
function CHASEINFO_ON_INIT(addon, frame)
    addon:RegisterMsg('GAME_START', 'ON_INIT_CHASEINFO');
    addon:RegisterMsg('OPEN_FRAME', 'CHASEINFO_OPEN_FRAME');
    addon:RegisterMsg('CLOSE_FRAME', 'CHASEINFO_CLOSE_FRAME');
end

function ON_INIT_CHASEINFO()
    local achieveFrame = ui.GetFrame("achieveinfoset")
    
    local frame = ui.GetFrame("chaseinfo")
    local openMarkAchieve = GET_CHILD(frame, "openMark_achieve")
    local openMarkQuest = GET_CHILD(frame, "openMark_quest")

    local lastOpen = 0
    local myPCetc = GetMyEtcObject();
    if myPCetc ~= nil then
        lastOpen = myPCetc["LastInforsetUIOpen"]
    end
    CHASEINFO_SET_ACHIEVE_INFOSET_FOLD(1)
    CHASEINFO_SET_QUEST_INFOSET_FOLD(1)

    ON_UPDATE_ACHIEVEINFOSET()
    ON_UPDATE_QUESTINFOSET_2(nil, "GAME_START")

    frame:SetUserValue("LastOpen", lastOpen)

    CHASEINFO_UPDATE()
end

-- 다른 Addon에서 추적 Open 원할 때 호출
function CHASEINFO_OPEN_FRAME()
    CHASEINFO_UPDATE()
end

-- 다른 Addon에서 추적 전체 Close 원할 때 호출
function CHASEINFO_CLOSE_FRAME()
    ui.CloseFrame("chaseinfo")
    ui.CloseFrame("achieveinfoset")
    ui.CloseFrame("questinfoset_2")
end

function CHASEINFO_IS_SHOW()
    if UI_CHECK_NOT_PVP_MAP() == 0 then
        return 0
    end

    local bountyhunt_milestone_frame = ui.GetFrame("bountyhunt_milestone")
    if bountyhunt_milestone_frame:IsVisible() == 1 then
        return 0
    end

    local achieveCnt = ACHIEVEINFOSET_IS_VALID_ACHIEVE()
    local questCnt = QUESTINFOSET_2_IS_VALID_QUEST()
    if achieveCnt + questCnt == 0 then
        return 0
    end

    return 1
end

function CHASEINFO_UPDATE()
    local frame = ui.GetFrame("chaseinfo")
    if CHASEINFO_IS_SHOW() == 0 then
        CHASEINFO_CLOSE_FRAME()
        return
    end

    frame:ShowWindow(1)

    -- Toggle
    local lastOpen = frame:GetUserIValue("LastOpen")
    if lastOpen == 1 then -- achieveinfoset
        TOGGLE_ACHIEVE_INFOSET_FOLD(0)
    elseif lastOpen == 2 then -- questinfoset_2
        TOGGLE_QUEST_INFOSET_FOLD(0)
    else -- 안열림
        lastOpen = 0
        TOGGLE_ACHIEVE_INFOSET_FOLD(1)
        TOGGLE_QUEST_INFOSET_FOLD(1)
    end
    CHASEINFO_SET_LASTINFO_OPEN(lastOpen)
end

-- 업적 토글 버튼 보이기/안보이기
function CHASEINFO_SHOW_ACHIEVE_TOGGLE(show)
    local frame = ui.GetFrame("chaseinfo")
    local openMark = GET_CHILD(frame, "openMark_achieve")
    local name = GET_CHILD(frame, "name_achieve")

    if show == 1 or show == "true" or show == true then
        frame:ShowWindow(1)
        openMark:ShowWindow(1)
        name:ShowWindow(1)
    else
        local isValidQuest = QUESTINFOSET_2_IS_VALID_QUEST()
        if isValidQuest == 1 then
            frame:ShowWindow(1)
        else
            frame:ShowWindow(0)
        end
        openMark:ShowWindow(0)
        name:ShowWindow(0)
    end
end

-- 퀘스트 토글 버튼 보이기/안보이기
function CHASEINFO_SHOW_QUEST_TOGGLE(show)
	local frame = ui.GetFrame("chaseinfo")
    local openMark = GET_CHILD(frame, "openMark_quest")
    local name = GET_CHILD(frame, "name_quest")

    if show == 1 or show == "true" or show == true then
        frame:ShowWindow(1)
        openMark:ShowWindow(1)
        name:ShowWindow(1)
    else
        local num = ACHIEVEINFOSET_GET_CHASE_NUM()
        if num > 0 then
            frame:ShowWindow(1)
        else
            frame:ShowWindow(0)
        end
        openMark:ShowWindow(0)
        name:ShowWindow(0)
    end
    
end

-- Achieve Fold 버튼 클릭
function CHASEINFO_TOGGLE_ACHIEVE_INFOSET_FOLDER(parent, ctrl, argStr, argNum)
    local frame = ui.GetFrame("chaseinfo")
    local LastOpen = 1
    if CHASEINFO_IS_ACHIEVE_FOLD() == 0 then
        TOGGLE_ACHIEVE_INFOSET_FOLD(1)
        LastOpen = 0
	else
		TOGGLE_ACHIEVE_INFOSET_FOLD(0)
    end
    CHASEINFO_SET_LASTINFO_OPEN(LastOpen)
end

-- Quest Fold 버튼 클릭
function CHASEINFO_TOGGLE_QUEST_INFOSET_FOLDER(parent, ctrl, argStr, argNum)
    local frame = ui.GetFrame("chaseinfo")
    local LastOpen = 2
	if CHASEINFO_IS_QUEST_FOLD() == 0 then
		TOGGLE_QUEST_INFOSET_FOLD(1)
        LastOpen = 0
	else
		TOGGLE_QUEST_INFOSET_FOLD(0)
    end
    CHASEINFO_SET_LASTINFO_OPEN(LastOpen)
end

function CHASEINFO_IS_ACHIEVE_FOLD() -- Achieve Fold 여부
	local frame = ui.GetFrame("chaseinfo")
    local openMark = GET_CHILD(frame, "openMark_achieve")
    local uiFold = openMark:GetUserIValue('UI_FOLD');
    if uiFold == nil or uiFold == 0 then
        return 0
    else
        return 1
    end
end

function CHASEINFO_SET_ACHIEVE_INFOSET_FOLD(fold)
	local frame = ui.GetFrame("chaseinfo")
    local infoFrame = ui.GetFrame("achieveinfoset")
    local openMark = GET_CHILD(frame, "openMark_achieve")

    if fold == 1 then
        openMark:SetUserValue('UI_FOLD', 1);
        openMark:SetImage("quest_arrow_l_btn");
        infoFrame:ShowWindow(0)
        if CHASEINFO_IS_QUEST_FOLD() == 1 then
            CHASEINFO_SET_LASTINFO_OPEN(0)
        else
            CHASEINFO_SET_LASTINFO_OPEN(2)
        end
    else
        openMark:SetUserValue('UI_FOLD', 0);
        openMark:SetImage("quest_arrow_r_btn");
        infoFrame:ShowWindow(1)
        if CHASEINFO_IS_QUEST_FOLD() == 0 then
            CHASEINFO_SET_QUEST_INFOSET_FOLD(1)
        end
        CHASEINFO_SET_LASTINFO_OPEN(1)
    end
end

function TOGGLE_ACHIEVE_INFOSET_FOLD(fold) -- Achieve Fold
    CHASEINFO_SET_ACHIEVE_INFOSET_FOLD(fold)

    if fold == 0 then
        ON_UPDATE_ACHIEVEINFOSET()
    end
end

function CHASEINFO_IS_QUEST_FOLD() -- Quest Fold 여부
	local frame = ui.GetFrame("chaseinfo")
    local openMark = GET_CHILD(frame, "openMark_quest")
    local uiFold = openMark:GetUserIValue('UI_FOLD');
    if uiFold == nil or uiFold == 0 then
        return 0
    else
        return 1
    end
end

function CHASEINFO_SET_QUEST_INFOSET_FOLD(fold)
	local frame = ui.GetFrame("chaseinfo")
    local infoFrame = ui.GetFrame("questinfoset_2")
	local openMark = GET_CHILD(frame, 'openMark_quest');
    
    if fold == 1 then
        openMark:SetUserValue('UI_FOLD', 1);
        openMark:SetImage("quest_arrow_l_btn");
        infoFrame:ShowWindow(0)
        if CHASEINFO_IS_ACHIEVE_FOLD() == 1 then
            CHASEINFO_SET_LASTINFO_OPEN(0)
        else
            CHASEINFO_SET_LASTINFO_OPEN(1)
        end
    else
        openMark:SetUserValue('UI_FOLD', 0);
        openMark:SetImage("quest_arrow_r_btn");
        infoFrame:ShowWindow(1)
        if CHASEINFO_IS_ACHIEVE_FOLD() == 0 then
            CHASEINFO_SET_ACHIEVE_INFOSET_FOLD(1)
        end
        CHASEINFO_SET_LASTINFO_OPEN(2)
    end
end

function TOGGLE_QUEST_INFOSET_FOLD(fold) -- Quest Fold
    CHASEINFO_SET_QUEST_INFOSET_FOLD(fold)
    
    if fold == 0 then
        ON_UPDATE_QUESTINFOSET_2(); 
    end
end

-- 0: X
-- 1: achieve
-- 2: quest
function CHASEINFO_SET_LASTINFO_OPEN(idx)
    local frame = ui.GetFrame("chaseinfo")
    frame:SetUserValue("LastOpen", idx)
	control.CustomCommand("LAST_INFOSET_OPEN", idx);
end