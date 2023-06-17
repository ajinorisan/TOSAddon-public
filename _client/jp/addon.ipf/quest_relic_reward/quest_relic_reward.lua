-- quest_relic_reward.lua

function QUEST_RELIC_REWARD_ON_INIT(addon, frame)
    addon:RegisterMsg('RELIC_REWARD_CLEAR', 'QUEST_RELIC_REWARD_FRAME_CLOSE')
end

function QUEST_RELIC_REWARD_INFO(questName, xPos, prop)
    local frame = ui.GetFrame('quest_relic_reward')
    local gbBody = frame:GetChild('gbBody')
	tolua.cast(gbBody, "ui::CGroupBox")
	gbBody:DeleteAllControl()

    local relicRewardIES = GetClass("Relic_Reward", questName)
    if relicRewardIES == nil or TryGetProp(relicRewardIES, 'Reward_1', 'None') == 'None' then
        return
    end

    local relicQuestIES = GetClass("Relic_Quest", questName)
    local relicCategoryIES = nil
    if relicQuestIES ~= nil and relicQuestIES.Category ~= 'None' then
        relicCategoryIES = GetClass("Relic_Quest", relicQuestIES.Category)
    end

    local pcObj = GetMyPCObject()
    local result = SCR_RELIC_QUEST_CHECK(pcObj, relicRewardIES.ClassName)

    -- 퀘스트 이름 텍스트
    local questNameText = GET_CHILD_RECURSIVELY(frame, "questNameText")
    questNameText:SetTextByKey("name", relicQuestIES.Name)

    if relicCategoryIES ~= nil then
        questNameText:SetTextByKey("name", relicQuestIES.Name.."{s10}{nl} {nl}{@st42b}{s18}{ds}".. relicCategoryIES.Name)
    end

	local y = 0
	local spaceY = 10
    local x = 10
    
    -- 보상
    y = y + QUEST_RELIC_REWARD_MAKE_REWARD_CTRL(gbBody, x, y, relicRewardIES) + spaceY
    
    gbBody:Resize(gbBody:GetWidth(), y)
    local gbBottom = GET_CHILD_RECURSIVELY(frame, "gbBottom")
    y = y + gbBottom:GetHeight()
    
    -- 버튼에 arg 전달
    local btnReward = GET_CHILD_RECURSIVELY(frame, "btnReward")
    btnReward:SetEventScriptArgString(ui.LBUTTONUP, relicRewardIES.ClassName)
    btnReward:SetSkinName("test_red_button")
    btnReward:SetEnable(1)
    if result ~= 'Reward' then
        btnReward:SetSkinName("test_gray_button")
        btnReward:SetEnable(0)
    end

    frame:Resize(xPos, frame:GetY(), frame:GetWidth(), y + 200)
    frame:ShowWindow(1)
	frame:Invalidate()
end

function QUEST_RELIC_REWARD_FRAME_CLOSE(frame)
    ui.CloseFrame('quest_relic_reward')
end

-- 보상 컨트롤
function QUEST_RELIC_REWARD_MAKE_REWARD_CTRL(gbBody, x, y, relicRewardIES)
    local height = 0
    local topFrame = gbBody:GetTopParentFrame()
    local titleText = topFrame:GetUserConfig('QUEST_REWARD_TEXT')
    if titleText == nil then
        titleText =  ScpArgMsg("Auto_{@st41}BoSang")
    end

    height = height +  QUESTDETAIL_BOX_CREATE_RICHTEXT(gbBody, x, y + height, gbBody:GetWidth() - 30, 20, "t_addreward", titleText) -- 타이틀
	height = height +  QUEST_RELIC_REWARD_MAKE_REWARD_ITEM_CTRL(gbBody, x, y + height, relicRewardIES) -- 아이템 (최대 5개)

    return height
end

-- 보상 - 아이템
function QUEST_RELIC_REWARD_MAKE_REWARD_ITEM_CTRL(gbBody, x, y, relicRewardIES)
    local height = 0
    local rewardList = SCR_STRING_CUT(relicRewardIES.Reward_1, ';')
    for i = 1, #rewardList do
        local propList = SCR_STRING_CUT(rewardList[i], '/')
        local rewardName = propList[1]
        local rewardCount = propList[2]

        if IS_SEASON_SERVER() == 'YES' and rewardName == 'Relic_exp_token' then
            rewardCount = tonumber(rewardCount) * 10
        end

        if rewardName ~= "None" then
            height = height + QUESTDETAIL_MAKE_ITEM_TAG_TEXT_CTRL(gbBody, x, y + height, 'reward_item', rewardName, rewardCount, i)
        end
    end
	return height
end

function CLICK_RELIC_REWARD_BTN(parent,ctrl, rewardClassName ,argNum)
    local pcObj = GetMyPCObject()
	local result = SCR_RELIC_QUEST_CHECK(pcObj, rewardClassName)
	if result == "Reward" then
        pc.ReqExecuteTx("SCR_TX_RELIC_QUEST_REWARD", rewardClassName)
    end
end
