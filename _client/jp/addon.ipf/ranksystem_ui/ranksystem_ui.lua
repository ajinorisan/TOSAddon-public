function RANKSYSTEM_UI_ON_INIT(addon, frame)
    addon:RegisterMsg('UPDATE_OTHER_GUILD_EMBLEM', 'ON_RANK_SYSTEM_UPDATE_GUILD_EMBLEM')
    addon:RegisterMsg('RANK_SYSTEM_TIMETABLE', 'ON_RANK_SYSTEM_TIMETABLE')
    addon:RegisterMsg('RANK_SYSTEM_MY_DATA', 'ON_RANK_SYSTEM_MY_DATA')
    addon:RegisterMsg('RANK_SYSTEM_DATA', 'ON_RANK_SYSTEM_DATA')
end

-- id list
local curContents_id = 0
local contents_id = 0
local season_id = ""

local function GET_RANK_ICON(tier)
    if tier == 0 then
        return "hero_icon_gradeHigh"
    elseif tier == 1 then
        return "hero_icon_gradeMiddle"
    elseif tier == 2 then
        return "hero_icon_gradeLow"
    else
        return ""
    end
end

-- AddOnMsg

--WEEKLY_BOSS_DATA_REUQEST


function REQUEST_RANK_SYSTEM(id, targetFrame, prev)
    contents_id = id
    RequestRankSystemTimeTable(contents_id)
    local frame = ui.GetFrame("ranksystem_ui");
    frame:SetUserValue("PREV", prev)
end

function OPEN_RANKSYSTEM_UI(parent, ctrl, argStr, argNum)
    REQUEST_RANK_SYSTEM(argNum, "ranksystem_ui", 0)
    local frame = ui.GetFrame("ranksystem_ui")
    local tab = GET_CHILD_RECURSIVELY(frame,"season_tab")
    tab:ChangeTab(0)
end

function ON_RANK_SYSTEM_TIMETABLE(parent, ctrl, argStr, argNum)
    if curContents_id ~= 1 then
        local frame = ui.GetFrame("induninfo")
        INDUNINFO_CREATE_CATEGORY(frame)
    end

    curContents_id = argNum
    
    if curContents_id ~= contents_id then
        return
    end

    local prev = parent:GetUserIValue("PREV")
    season_id = session.rank.GetPrevSeason(contents_id, prev)
    RequestRankSystemMyData(contents_id, season_id)
    RequestRankSystemRankList(0, contents_id, season_id)
end

function ON_RANK_SYSTEM_DATA(parent, ctrl, argStr, argNum)
    if curContents_id ~= contents_id then
        return
    end

    local max_page = 1
    local now_page = 1
    if argStr ~= "NO_DATA" then
        max_page = math.min(math.ceil(tonumber(argStr) / 10), 10)
        if max_page > 5 then
            max_page = 5
        end
        now_page = argNum
    end

    ui.OpenFrame('ranksystem_ui')
    RANKSYSTEM_UI_INIT(now_page, max_page, argStr)
end

function ON_RANK_SYSTEM_MY_DATA(parent, msg, argStr, argNum)
    if curContents_id ~= contents_id then
        return
    end
    
    ui.OpenFrame('ranksystem_ui')

    RANKSYSTEM_MY_DATA_INIT(argStr)
end

function ON_RANK_SYSTEM_UPDATE_GUILD_EMBLEM(frame, msg, argStr, argNum)
    local frame = ui.GetFrame("ranksystem_ui")
    if frame == nil then
        return
    end

    local worldID = session.party.GetMyWorldIDStr()
    local emblemImgName = guild.GetEmblemImageName(argStr, worldID)

    if emblemImgName == 'None' then
        return
    end

    local myCtrl = GET_CHILD_RECURSIVELY(frame, "my_rank_info")
    if myCtrl ~= nil and myCtrl:GetUserValue("GUILD_ID") == argStr then
        GET_CHILD_RECURSIVELY(myCtrl, "rank_guild_icon"):SetFileName(emblemImgName)
    end

    for idx = 0, 9 do
        local ctrl = GET_CHILD_RECURSIVELY(frame, "rank_info_"..idx)
        if ctrl ~= nil and ctrl:GetUserValue("GUILD_ID") == argStr then
            GET_CHILD_RECURSIVELY(ctrl, "rank_guild_icon"):SetFileName(emblemImgName)
        end
    end
end

-- Open/Close
function RANKSYSTEM_UI_OPEN()

end

function RANKSYSTEM_UI_CLOSE(frame)
    contents_id = 0
end

-- Init
function RANKSYSTEM_MY_DATA_INIT(argStr)
    local frame = ui.GetFrame("ranksystem_ui")
    if frame == nil then
        return
    end

    local myBG = GET_CHILD_RECURSIVELY(frame, "my_bg")
    if myBG == nil then
        return
    end

    -- 길드 데이터 세팅
    local guildID = ""
    local guildName = ""
    local guildInfo = session.party.GetPartyInfo(PARTY_GUILD)

    if guildInfo ~= nil then
        guildID = guildInfo.info:GetPartyID()
        guildName = guildInfo.info.name
    end

    -- 랭크 데이터 세팅
    local rank = 0
    local tier = 0
    local time = 0
    local damage = 0
    local teamName = info.GetFamilyName(session.GetMyHandle())

    if argStr ~= "NO_DATA" then
        rank = session.rank.GetMyRank()
        tier = session.rank.GetMyTier()
        time = session.rank.GetMyTime()
        damage = session.rank.GetMyDamage()
    end

    -- 기본값 처리
    if time == 0 then
        time = "--"
    end

    if damage == 0 then
        damage = "--"
    end

    if guildName == "" then
        guildName = "--"
    end

    -- 서체 처리
    local style = frame:GetUserConfig("STYLE_NORMAL")

    -- 컨트롤셋 세팅
    local controlset = myBG:CreateOrGetControlSet('ranksystem_ui_info', 'my_rank_info', ui.CENTER_HORZ, ui.TOP, 0, 1, 0 ,0)

    if argStr ~= "NO_DATA" then
        GET_CHILD_RECURSIVELY(controlset, "rank_icon"):SetImage(GET_RANK_ICON(tier))
    else
        GET_CHILD_RECURSIVELY(controlset, "rank_icon"):SetImage("")
    end
    GET_CHILD_RECURSIVELY(controlset, "rank_text"):SetTextByKey("rank", rank)
    GET_CHILD_RECURSIVELY(controlset, "rank_team_text"):SetTextByKey("name", style..teamName)
    GET_CHILD_RECURSIVELY(controlset, "rank_guild_text"):SetTextByKey("name", style..guildName)
    
    -- 컨텐츠별 세팅
    if contents_id == 1 then
        GET_CHILD_RECURSIVELY(controlset, "rank_score_text"):SetTextByKey("score", damage)
    end

    -- 길드 아이콘 세팅
    local iconPic = GET_CHILD_RECURSIVELY(controlset, "rank_guild_icon")

    local worldID = session.party.GetMyWorldIDStr()
    local emblemImgName = guild.GetEmblemImageName(guildID, worldID)

    if emblemImgName ~= 'None' then
        iconPic:SetFileName(emblemImgName)
    elseif guildID ~= '' then
        guild.ReqEmblemImage(guildID, worldID)
    end

    controlset:SetUserValue("GUILD_ID", guildID)
end

function RANKSYSTEM_UI_INIT(now_page, max_page, argStr)
    local frame = ui.GetFrame("ranksystem_ui")
    if frame == nil then
        return
    end

    -- 제목
    local title = GET_CHILD_RECURSIVELY(frame, "title")
    if title == nil then
        return
    end

    title:SetTextByKey("title", ClMsg("RankSystemTitle"..contents_id))

    -- 페이지
    local pageController = GET_CHILD_RECURSIVELY(frame, "page_controller")
    if pageController == nil then
        return
    end

    pageController:SetMaxPage(max_page)
    pageController:SetCurPage(now_page)

    -- 랭킹 보드
    local scoreBG = GET_CHILD_RECURSIVELY(frame, "score_bg")
    if scoreBG == nil then
        return
    end

    for idx = 0, 9 do
        scoreBG:RemoveChild('rank_info_'..idx)
    end

    local height = 40
    local myAID = session.loginInfo.GetAID()
    local tab = GET_CHILD_RECURSIVELY(frame, "season_tab")
    local tabCnt = tab:GetItemCount()

    for idx = 1, tabCnt do
        local season = session.rank.GetPrevSeason(contents_id, idx-1)
        local isNotSeason = season == "None"
        if season == "None" then
            tab:SetTabVisible(idx-1, false)
        else
            tab:SetTabVisible(idx-1, true)
        end
    end
    local season_num = session.rank.GetSeasonNum()
    for idx = 0, tabCnt - 1 do
        tab:ChangeCaptionOnly(idx, "{@st42b}{s16}"..(season_num - idx), false)
    end

    if argStr == "NO_DATA" then
        return;
    end

    for idx = 0, 9 do
        local rank = session.rank.GetRank(idx)
        if rank == 0 then
            return
        end

        local tier = session.rank.GetTier(idx)
        local aid = session.rank.GetAID(idx)
        local time = session.rank.GetTime(idx)
        local damage = session.rank.GetDamage(idx)
        local teamName = session.rank.GetTeamName(idx)
        local guildName = session.rank.GetGuildName(idx)

        -- 기본값 처리
        if time == 0 then
            time = "--"
        end

        if damage == 0 then
            damage = "--"
        end

        if guildName == "" then
            guildName = "--"
        end

        -- 서체 처리
        local style = ""

        if myAID == aid then
            style = frame:GetUserConfig("MY_STYLE")
        else
            style = frame:GetUserConfig("STYLE_NORMAL")
        end

        -- 컨트롤셋 세팅
        local controlset = scoreBG:CreateOrGetControlSet('ranksystem_ui_info', 'rank_info_'..idx, ui.CENTER_HORZ, ui.TOP, 0, height, 0 ,0)

        GET_CHILD_RECURSIVELY(controlset, "rank_icon"):SetImage(GET_RANK_ICON(tier))
        GET_CHILD_RECURSIVELY(controlset, "rank_text"):SetTextByKey("rank", rank)
        GET_CHILD_RECURSIVELY(controlset, "rank_team_text"):SetTextByKey("name", style..teamName)
        GET_CHILD_RECURSIVELY(controlset, "rank_guild_text"):SetTextByKey("name", style..guildName)

        -- 컨텐츠별 세팅
        if contents_id == 1 then
            GET_CHILD_RECURSIVELY(controlset, "rank_score_text"):SetTextByKey("score", damage)
        end

        -- 길드 아이콘 세팅
        local iconPic = GET_CHILD_RECURSIVELY(controlset, "rank_guild_icon")

        local guildID = session.rank.GetGuildID(idx)
        local worldID = session.party.GetMyWorldIDStr()
        local emblemImgName = guild.GetEmblemImageName(guildID, worldID)

        if emblemImgName ~= 'None' then
            iconPic:SetFileName(emblemImgName)
        else
            guild.ReqEmblemImage(guildID, worldID)
        end

        controlset:SetUserValue("GUILD_ID", guildID)

        -- 높이 조정
        height = height + controlset:GetHeight() - 4
    end
end

function RANKSYSTEM_UI_SEASON_SELECT(oarent, self)
    local index = self:GetSelectItemIndex()
    REQUEST_RANK_SYSTEM(contents_id, "ranksystem_ui", index)
end

-- Request
function RANKSYSTEM_UI_PAGE_SELECT(pageCtrl, ctrl)
    local frame = ui.GetFrame("ranksystem_ui")
    RequestRankSystemRankList(pageCtrl:GetCurPage(), contents_id, season_id)
end

function RANKSYSTEM_SEASON_REWARD(parent, self)
    local prev = parent:GetUserIValue("PREV")
    TOSHEROREWARD_SHOW(3, prev)
end