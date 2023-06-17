-- reputation_quest_info.lua

local reputation_group_list = {'EP13'}

function REPUTATION_QUEST_INFO_OPEN()
    REPUTATION_QUEST_INFO_INIT()
end

function REPUTATION_QUEST_INFO_CLOSE()
end

local function GET_GROUP()
    local frame = ui.GetFrame('reputation_quest_info')
    local dropList = GET_CHILD_RECURSIVELY(frame, 'episode_droplist')

    return dropList:GetSelItemKey()
end

local function SET_QUEST_STATE_TEXT(set, state)
    local statetxt = GET_CHILD(set, "state", "ui::CRichText")
    statetxt:SetText(ClMsg("QUEST_STATE_"..state))

    local textFont = ""
	local textColor = ""

    textFont = set:GetUserConfig("REPEAT_FONT")
    textColor = set:GetUserConfig("REPEAT_COLOR")

    statetxt:SetText(textFont .. textColor .. ClMsg('QUEST_STATE_'..state))

    local isEnable = 1
    if state == "SUCCESS" or state == "IMPOSSIBLE" then
        isEnable = 0
    end

    local nametxt = GET_CHILD(set, "name", "ui::CRichText")
    local leveltxt = GET_CHILD(set, "level", "ui::CRichText")
    local questMark = GET_CHILD(set, "questmark", "ui::CPicture")

    nametxt:SetEnable(isEnable)
    leveltxt:SetEnable(isEnable)
    statetxt:SetEnable(isEnable)
    questMark:SetEnable(isEnable)
end

function REPUTATION_QUEST_INFO_INIT()
    REPUTATION_QUEST_INFO_INIT_DROPLIST()
    REPUTATION_QUEST_INFO_INIT_WEEKLY()
    REPUTATION_QUEST_INFO_INIT_DAILY()
    REPUTATION_QUEST_INFO_INIT_REP()
end

function REPUTATION_QUEST_INFO_INIT_DROPLIST()
    local frame = ui.GetFrame('reputation_quest_info')
    local dropList = GET_CHILD_RECURSIVELY(frame, 'episode_droplist')

    dropList:ClearItems()

    for i = 1, #reputation_group_list do
        dropList:AddItem(reputation_group_list[i], "  {@st104bright_14}{s16}"..reputation_group_list[i])
    end

    dropList:SelectItemByKey(0)
    dropList:SetVisibleLine(#reputation_group_list)

    dropList:SetFrameScrollBarOffset(-3, 0)
    dropList:SetFrameScrollBarSkinName("worldmap2_scrollbar")
    dropList:EnableTextOmitByWidth(true)

    local bgWeekly = GET_CHILD_RECURSIVELY(frame, 'bg_sub_weekly')
    local bgDaily = GET_CHILD_RECURSIVELY(frame, 'bg_sub_daily')
    local bgRep = GET_CHILD_RECURSIVELY(frame, 'bg_sub_rep')

    bgWeekly:CreateOrGetControlSet('reputation_quest_info', "dummy", 481, 137)
    bgDaily:CreateOrGetControlSet('reputation_quest_info', "dummy", 481, 137)
    bgRep:CreateOrGetControlSet('reputation_quest_info', "dummy", 481, 137)
end

function REPUTATION_QUEST_INFO_INIT_WEEKLY()
    local frame = ui.GetFrame('reputation_quest_info')
    local bg = GET_CHILD_RECURSIVELY(frame, 'bg_sub_weekly')

    local questList = GET_REPUTATION_QUEST_LIST()
    local questCount = 0

    for i = 1, #questList do
        local questName = questList[i]
        local questClass = GetClass('QuestProgressCheck', questName)

        local set = bg:CreateOrGetControlSet('reputation_quest_info', questName, 0, questCount * 41)

        local pc = GetMyPCObject()
        local aObj = GetMyAccountObj()
        local state = SCR_QUEST_CHECK_C(pc, questName)

        if TryGetProp(aObj, "REPUTATION_QUEST_CLEAR_"..questName, 1) > 0 then
            state = "SUCCESS"
        end

        -- 퀘스트 마크 설정
        SET_QUEST_CTRL_MARK(set, questClass, state)

        -- 레벨, 이름 설정
        SET_QUEST_CTRL_TEXT(set, questClass)

        -- 상태 설정
        SET_QUEST_STATE_TEXT(set, state)

        questCount = questCount + 1
    end

    bg:CreateOrGetControlSet('reputation_quest_info', "scroll_dummy", 481, questCount * 41 - 27)
end

function REPUTATION_QUEST_INFO_INIT_DAILY()
    local frame = ui.GetFrame('reputation_quest_info')
    local bg = GET_CHILD_RECURSIVELY(frame, 'bg_sub_daily')

    local list, count = GetClassList('reputation_quest')
    local questCount = 0

    for i = 0, count-1 do
        local class = GetClassByIndexFromList(list, i)

        if class.ReputationGroup == GET_GROUP() and class.ResetType == "DAY" then
            local questName = class.ClassName
            local questClass = GetClass('QuestProgressCheck', questName)

            local set = bg:CreateOrGetControlSet('reputation_quest_info', questName, 0, questCount * 41)

            local pc = GetMyPCObject()
            local aObj = GetMyAccountObj()
            local state = SCR_QUEST_CHECK_C(pc, questName)
    
            if TryGetProp(aObj, "REPUTATION_QUEST_CLEAR_"..questName, 1) > 0 then
                state = "SUCCESS"
            end

            -- 퀘스트 마크 설정
            SET_QUEST_CTRL_MARK(set, questClass, state)

            -- 레벨, 이름 설정
            SET_QUEST_CTRL_TEXT(set, questClass)

            -- 상태 설정
            SET_QUEST_STATE_TEXT(set, state)

            questCount = questCount + 1
        end
    end

    bg:CreateOrGetControlSet('reputation_quest_info', "scroll_dummy", 481, questCount * 41 - 27)
end

function REPUTATION_QUEST_INFO_INIT_REP()
    local frame = ui.GetFrame('reputation_quest_info')
    local bg = GET_CHILD_RECURSIVELY(frame, 'bg_sub_rep')

    local list, count = GetClassList('reputation_quest')
    local questCount = 0

    for i = 0, count-1 do
        local class = GetClassByIndexFromList(list, i)

        if class.ReputationGroup == GET_GROUP() and class.ResetType == "REPEAT" then
            local questName = class.ClassName
            local questClass = GetClass('QuestProgressCheck', questName)

            local set = bg:CreateOrGetControlSet('reputation_quest_info', questName, 0, questCount * 41)

            local pc = GetMyPCObject()
            local state = SCR_QUEST_CHECK_C(pc, questName)

            -- 퀘스트 마크 설정
            SET_QUEST_CTRL_MARK(set, questClass, state)

            -- 레벨, 이름 설정
            SET_QUEST_CTRL_TEXT(set, questClass)

            -- 상태 설정
            SET_QUEST_STATE_TEXT(set, state)

            questCount = questCount + 1
        end
    end

    bg:CreateOrGetControlSet('reputation_quest_info', "scroll_dummy", 481, questCount * 41 - 27)
end