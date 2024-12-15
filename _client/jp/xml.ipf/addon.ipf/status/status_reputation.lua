-- status_reputation.lua

function STATUS_REPUTATION_INIT()
    STATUS_REPUTATION_LIST_INIT()
end

function STATUS_REPUTATION_LIST_INIT()
    local frame = ui.GetFrame("status")
    if frame == nil then
        return
    end

    local aObj = GetMyAccountObj()
    local rankList = 
    {
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0,
        [5] = 0,
    }

    local gb = GET_CHILD_RECURSIVELY(frame, "reputationChildGBox")
    local dummy = gb:CreateOrGetControlSet('status_reputation_set', "dummy", 451, 580)

    -- 개별 스테이터스
    local pc = GetMyPCObject()
    local clsList, cnt = GetClassList("reputation")

    local reputationCount = 0
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(clsList, i)

        if IS_REPUTATION_OPEN(pc, cls.ClassName) then
            local set = gb:CreateOrGetControlSet('status_reputation_set', cls.ClassName, 0, reputationCount * 82)
            local point = TryGetProp(aObj, cls.ClassName, 0)

            local rank = GET_REPUTATION_RANK(point)

            -- 다음 평판까지 남은 퍼센트 표기
            local percent = 0
            local inteval_x = GET_REPUTATION_REQUIRE_POINT(rank)
            local inteval_y = GET_REPUTATION_REQUIRE_POINT(rank+1)

            if point ~= GET_REPUTATION_MAX() then
                percent = (point - inteval_x) / (inteval_y - inteval_x)
            else
                percent = 1
            end

            local rankImage = AUTO_CAST(set:GetChild("reputation_rank"))
            rankImage:SetImage("reputation0"..(rank+1))

            local text = AUTO_CAST(set:GetChild("reputation_text"))
            text:SetTextByKey('name', cls.Name)
            text:SetTextByKey('value', math.floor(percent * 100))

            local npc_btn = AUTO_CAST(set:GetChild("reputation_npc_btn"))
            npc_btn:SetEventScript(ui.LBUTTONUP, "STATUS_REPUTATION_SHOW_NPC")
            npc_btn:SetEventScriptArgString(ui.LBUTTONUP, cls.ClassName)

            local location_btn = AUTO_CAST(set:GetChild("reputation_location_btn"))
            location_btn:SetEventScript(ui.LBUTTONUP, "STATUS_REPUTATION_SHOW_LOCATION")
            location_btn:SetEventScriptArgString(ui.LBUTTONUP, cls.ClassName)

            set:ShowWindow(1)
            reputationCount = reputationCount + 1

            for j = 1, rank do
                rankList[j] = rankList[j] + 1
            end
        end
    end

    -- 열린 평판이 없을 시의 안내문
    local warningText = GET_CHILD_RECURSIVELY(frame, "reputationStatusWarningText")
    
    if reputationCount == 0 then
        warningText:ShowWindow(1)
    else
        warningText:ShowWindow(0)
    end
    
    -- 총합 스테이터스
    for i = 1, 5 do
        local text = GET_CHILD_RECURSIVELY(frame, 'reputationStatusText'..i)
        text:SetTextByKey("value", math.floor(rankList[i]*100/cnt))
    end
end

function STATUS_REPUTATION_SHOW_LOCATION(frame, msg, argStr, argNum)
    local class = GetClass("reputation", argStr)
    local mapName = class.MapName
    local episode = GET_EPISODE_BY_MAPNAME(mapName)
    
    if episode == nil then
        return
    end

    ui.OpenFrame("worldmap2_mainmap")
    
    WORLDMAP2_OPEN_SUBMAP_FROM_MAINMAP_BY_EPISODE(episode)
    WORLDMAP2_SUBMAP_ZONE_CHECK(mapName)
end

function STATUS_REPUTATION_SHOW_NPC(frame, msg, argStr, argNum)
    local class = GetClass("reputation", argStr)

    local mapName = class.MapName
    local x = class.minimap_X
    local z = class.minimap_Z

    SCR_SHOW_LOCAL_MAP(mapName, false, x, z)
end

function STATUS_REPUTATION_SEARCH(frame, ctrl)
    local frame = ui.GetFrame("status")
    if frame == nil then
        return
    end

    local gb = GET_CHILD_RECURSIVELY(frame, "reputationChildGBox")
    local searchEdit = GET_CHILD_RECURSIVELY(frame, "reputation_search")
    local searchText = searchEdit:GetText()

    if searchText == "" then
        STATUS_REPUTATION_LIST_INIT()
        return
    end

    local height = 0
    local clsList, cnt = GetClassList("reputation")
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(clsList, i)
        local set = gb:GetChild(cls.ClassName)

        if string.find(cls.Name, searchText) ~= nil then
            set:SetMargin(0, 0, 0, height * 82)
            height = height + 1
            set:ShowWindow(1)
        else
            set:ShowWindow(0)
        end
    end
end

function STATUS_REPUTATION_QUEST_INFO()
    local frame = ui.GetFrame("status")
    if frame == nil then
        return
    end

    if GET_CHILD_RECURSIVELY(frame, "reputationStatusWarningText"):IsVisible() == 0 then
        if ui.GetFrame('reputation_quest_info'):IsVisible() == 0 then
            ui.OpenFrame('reputation_quest_info')
        else
            ui.CloseFrame('reputation_quest_info')
        end
    end
end