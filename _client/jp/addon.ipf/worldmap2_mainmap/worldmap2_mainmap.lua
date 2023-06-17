-- worldmap2_mainmap.lua

function WORLDMAP2_MAINMAP_ON_INIT(addon, frame)
    addon:RegisterMsg('UPDATE_OTHER_GUILD_EMBLEM', 'ON_UPDATE_OTHER_GUILD_EMBLEM_WORLDMAP2_MAINMAP')
    addon:RegisterMsg('UPDATE_FIELDBOSS_INFO', 'ON_UPDATE_MAINMAP_FIELDBOSS_INFO')
    addon:RegisterMsg('TOGGLE_FAVORITE_MAP', 'WORLDMAP2_MAINMAP_BOOKMARK')
end

-- OPEN/ClOSE
function OPEN_WORLDMAP2_MAINMAP(frame)
    WORLDMAP2_MAINMAP_DRAW(frame)
    WORLDMAP2_MAINMAP_DRAW_BASE(frame)
    WORLDMAP2_MAINMAP_DRAW_COLONY(frame)
    WORLDMAP2_MAINMAP_INIT(frame)
end

function CLOSE_WORLDMAP2_MAINMAP(frame)
    WORLDMAP2_MAINMAP_EXIT(frame)
    WORLDMAP2_MAINMAP_CLEANUP(frame)
end

-- INIT/EXIT
function WORLDMAP2_MAINMAP_INIT(frame)
    -- 카테고리
    WORLDMAP2_CATEGORY_INIT(frame)

    -- 이펙트
    WORLDMAP2_MAINMAP_EFFECT_ON()

    -- 필드보스
    WORLDMAP2_MAINMAP_FIELDBOSS(frame)

    -- 즐겨찾기
    WORLDMAP2_MAINMAP_BOOKMARK(frame)

    -- 필드보스 정보 요청
    world.ReqExistFieldBossInfo()

    -- 컨트롤 제한
    control.EnableControl(0, 1)

    -- 단축키 제한
    for i = 1, 8 do
        keyboard.EnableHotKeyByID("F"..i, false)
    end

    frame:RunUpdateScript("WORLDMAP2_MAINMAP_UPDATE", 0, 0, 0, 1)
end

function WORLDMAP2_MAINMAP_EXIT(frame)
    -- 이펙트
    WORLDMAP2_MAINMAP_EFFECT_OFF()

    -- 컨트롤 제한 해제
    control.EnableControl(1)

    -- 단축키 제한 해제
    for i = 1, 8 do
        keyboard.EnableHotKeyByID("F"..i, true)
    end
end

-- UPDATE
function WORLDMAP2_MAINMAP_UPDATE(frame)
    if ui.GetFrame('worldmap2_submap'):IsVisible() == 1 then
        return 1
    end

    for i = 1, 8 do
        if keyboard.IsKeyDown("F"..i) == 1 then
            WORLDMAP2_MAINMAP_BOOKMARK_CLICK(frame, AUTO_CAST(frame:GetChild("bookmark_btn_"..i)), argStr, argNum)
            return 1
        end
    end

	return 1
end

-- DRAW/CLEANUP
function WORLDMAP2_MAINMAP_DRAW_BASE(frame)
    local mainmapTip = AUTO_CAST(frame:GetChild("mainmap_tip"))
    local mainmapTipText = AUTO_CAST(mainmapTip:GetChild("mainmap_tip_text"))

    -- 토큰이동 안내문 표기 옵션
    if session.loginInfo.IsPremiumState(ITEM_TOKEN) and GET_WARP_MAP_TYPE() == "None" then
        mainmapTip:ShowWindow(1)
    else
        mainmapTip:ShowWindow(0)
    end

    mainmapTip:Resize(mainmapTipText:GetWidth() + 20, mainmapTip:GetHeight())
end

function WORLDMAP2_MAINMAP_DRAW(frame)
	local list, cnt = GetClassList("worldmap2_data")
	for i = 0, cnt-1 do
		local cls = GetClassByIndexFromList(list, i)

		if cls.Type == "city" then
			WORLDMAP2_MAINMAP_DRAW_CITY(frame, cls)
		end
		if cls.Type == "episode" then
			WORLDMAP2_MAINMAP_DRAW_EPISODE(frame, cls)
		end
		if cls.Type == "sub_episode" then
			WORLDMAP2_MAINMAP_DRAW_SUB_EPISODE(frame, cls)
		end
    end
end

function WORLDMAP2_MAINMAP_DRAW_COLONY(frame)
    local colonyDataList = GET_COLONY_MAP_LIST()

    for i = 1, #colonyDataList do
        local colonyData = colonyDataList[i]

        local mapName = string.gsub(colonyData.ZoneClassName, "GuildColony_", "")
        local episode = GET_EPISODE_BY_MAPNAME(mapName)
        local episodeData =  GetClass("worldmap2_data", episode)

        if episodeData.Type == "city" then
			WORLDMAP2_MAINMAP_DRAW_COLONY_CITY(frame, mapName, episode, colonyData)
		end
		if episodeData.Type == "episode" then
			WORLDMAP2_MAINMAP_DRAW_COLONY_EPISODE(frame, mapName, episode, colonyData)
		end
		if episodeData.Type == "sub_episode" then
			WORLDMAP2_MAINMAP_DRAW_COLONY_SUB_EPISODE(frame, mapName, episode, colonyData)
		end
    end
end

function WORLDMAP2_MAINMAP_CLEANUP(frame)
    WORLDMAP2_MAINMAP_CLEANUP_CHILD(frame)
    WORLDMAP2_MAINMAP_CLEANUP_DATA(frame)
end

-- DRAW 세부 함수
function WORLDMAP2_MAINMAP_DRAW_CITY(frame, mapData)
	local episode = mapData.ClassName
	local x = mapData.Coordinate_X
	local y = mapData.Coordinate_Y

	local imageName = mapData.ImageName
	local imageSize = ui.GetSkinImageSize(imageName)

	local cityset = frame:CreateOrGetControlSet("city_set", episode, ui.CENTER_HORZ, ui.CENTER_VERT, x, y, 0, 0)
	local cityImg = AUTO_CAST(cityset:GetChild("city_img"))
	local cityBtn = AUTO_CAST(cityset:GetChild("city_btn"))
    local cityEpisodeText = AUTO_CAST(cityset:GetChild("city_episode_text"))

	-- 사이즈 조정
	cityset:Resize(imageSize.x + 80, imageSize.y + 150)

	-- 이미지
    cityImg:SetImage(imageName)
    cityImg:SetUserValue("EPISODE", episode)

	-- 마을 버튼
	cityBtn:SetMargin(0, imageSize.y/2, 0, 0)
	cityBtn:SetText("{@st100white_24}"..mapData.CityName)
	cityBtn:SetTextOffset(0, -12)
	cityBtn:SetUserValue("EPISODE", episode)

    -- 에피소드 버튼
	cityEpisodeText:SetMargin(20, 27 + imageSize.y/2, 0, 0)
    cityEpisodeText:SetText("{@st100white_16}"..mapData.Name)
    cityEpisodeText:AdjustFontSizeByWidth(100)
    cityEpisodeText:EnableHitTest(0);

	-- 내 위치 표기
	local myPosImg = AUTO_CAST(cityset:GetChild("pc_pos"))
	local myMapName, myEpisode = GET_MY_POSITION()

    if myEpisode == episode then
        frame:SetUserValue("MY_POS", episode)

        myPosImg:SetMargin(-2, -19 -imageSize.y/2, 0, 0)
        myPosImg:ShowWindow(1)
	else
		myPosImg:ShowWindow(0)
    end

    -- 마지막 워프 위치 표기
    local lobbyImg = AUTO_CAST(cityset:GetChild("last_warp_pos"))
    local lobbyEpisode = GET_MY_LAST_WARP_EPISODE()

    if lobbyEpisode ~= nil and lobbyEpisode == episode then
        lobbyImg:SetMargin(30 -imageSize.x/2, 30 -imageSize.y/2, 0, 0)
        lobbyImg:ShowWindow(1)
	else
		lobbyImg:ShowWindow(0)
    end

    -- 필드보스 표기
    local fieldBossText = frame:CreateOrGetControl('richtext', 'fieldboss_text_'..episode, 0, 0, 100, 100)

    fieldBossText:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    fieldBossText:SetMargin(x + 45, y + 55 + imageSize.y/2, 0, 0)
    fieldBossText:ShowWindow(0)
end

function WORLDMAP2_MAINMAP_DRAW_EPISODE(frame, mapData)
	local episode = mapData.ClassName
	local x = mapData.Coordinate_X
	local y = mapData.Coordinate_Y

	local imageName = mapData.ImageName
	local imageSize = ui.GetSkinImageSize(imageName)

	local episodeSet = frame:CreateOrGetControlSet("episode_set", episode, ui.CENTER_HORZ, ui.CENTER_VERT, x, y, 0, 0)
	local episodeImg = AUTO_CAST(episodeSet:GetChild("episode_img"))
	local episodeBtn = AUTO_CAST(episodeSet:GetChild("episode_btn"))

	-- 사이즈 조정
	if config.GetServiceNation() == 'KOR' then
		episodeSet:Resize(imageSize.x + 60, imageSize.y + 60)
	else
		episodeSet:Resize(imageSize.x + 100, imageSize.y + 100)
	end
	-- 이미지
    episodeImg:SetImage(imageName)
    episodeImg:SetUserValue("EPISODE", episode)

    -- 버튼
	episodeBtn:SetMargin(0, 2 + imageSize.y/2, 0, 0)
	episodeBtn:SetText("{@st100white_16}"..mapData.Name)
	episodeBtn:SetTextOffset(0, 4)
	
	if config.GetServiceNation() == 'KOR' then
    episodeBtn:AdjustFontSizeByWidth(100)
	else
		episodeBtn:AdjustFontSizeByWidth(200)
	end
    episodeBtn:SetUserValue("EPISODE", episode)

	-- 내 위치 표기
	local myPosImg = AUTO_CAST(episodeSet:GetChild("pc_pos"))
	local myMapName, myEpisode = GET_MY_POSITION()

    if myEpisode == episode then
        frame:SetUserValue("MY_POS", episode)
        myPosImg:SetMargin(-2, -4 -imageSize.y/2, 0, 0)
        myPosImg:ShowWindow(1)
	else
		myPosImg:ShowWindow(0)
    end

    -- 마지막 워프 위치 표기
    local lobbyImg = AUTO_CAST(episodeSet:GetChild("last_warp_pos"))
    local lobbyEpisode = GET_MY_LAST_WARP_EPISODE()

    if lobbyEpisode ~= nil and lobbyEpisode == episode then
        lobbyImg:SetMargin(20 -imageSize.x/2, 30 -imageSize.y/2, 0, 0)
        lobbyImg:ShowWindow(1)
    else
        lobbyImg:ShowWindow(0)
    end

    -- 필드보스 표기
    local fieldBossText = frame:CreateOrGetControl('richtext', 'fieldboss_text_'..episode, 0, 0, 100, 100)

    fieldBossText:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    fieldBossText:SetMargin(x + 3, y + 32 + imageSize.y/2, 0, 0)
    fieldBossText:ShowWindow(0)
end

function WORLDMAP2_MAINMAP_DRAW_SUB_EPISODE(frame, mapData)
	local episode = mapData.ClassName
	local x = mapData.Coordinate_X
	local y = mapData.Coordinate_Y

	local subEpisodeSet = frame:CreateOrGetControlSet("sub_episode_set", episode, ui.CENTER_HORZ, ui.CENTER_VERT, x, y, 0, 0)
	local subEpisodeBtn = AUTO_CAST(subEpisodeSet:GetChild("sub_episode_btn"))

    -- 버튼
	subEpisodeBtn:SetText("{@st100lblue_16}"..mapData.Name)
	subEpisodeBtn:SetTextOffset(0, -11)
    subEpisodeBtn:AdjustFontSizeByWidth(120)
    subEpisodeBtn:SetUserValue("EPISODE", episode)

	-- 내 위치 표기
	local myPosImg = AUTO_CAST(subEpisodeSet:GetChild("pc_pos"))
	local myMapName, myEpisode = GET_MY_POSITION()

    if myEpisode == episode then
        frame:SetUserValue("MY_POS", episode)

        myPosImg:SetMargin(-2, -44, 0, 0)
        myPosImg:ShowWindow(1)
	else
		myPosImg:ShowWindow(0)
    end

    -- 마지막 워프 위치 표기
    local lobbyImg = AUTO_CAST(subEpisodeSet:GetChild("last_warp_pos"))
    local lobbyEpisode = GET_MY_LAST_WARP_EPISODE()

    if lobbyEpisode ~= nil and lobbyEpisode == episode then
        lobbyImg:SetMargin(-55, -30, 0, 0)
        lobbyImg:ShowWindow(1)
    else
        lobbyImg:ShowWindow(0)
    end

    -- 필드보스 표기
    local fieldBossText = frame:CreateOrGetControl('richtext', 'fieldboss_text_'..episode, 0, 0, 100, 100)

    fieldBossText:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    fieldBossText:SetMargin(x, y + 25, 0, 0)
    fieldBossText:ShowWindow(0)
end

-- DRAW_COLONY 세부 함수
function WORLDMAP2_MAINMAP_DRAW_COLONY_CITY(frame, mapName, episode, colonyData)
    -- 더미
end

function WORLDMAP2_MAINMAP_DRAW_COLONY_EPISODE(frame, mapName, episode, colonyData)
    local controlSet = AUTO_CAST(frame:GetChild(episode))
    local count = controlSet:GetUserValue("COLONY_COUNT")

    if count == "None" then
        count = 0
    end

    local cls =  GetClass("worldmap2_data", episode)

    local imageName = cls.ImageName
    local imageSize = ui.GetSkinImageSize(imageName)
    
    local colonyImg = AUTO_CAST(controlSet:CreateControl('picture', 'colony_img_'..mapName, imageSize.x/2 - 10, imageSize.y/2 - 35 - count * 50, 50, 50))

    colonyImg:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    colonyImg:SetEnableStretch(1)
    colonyImg:ShowWindow(1)

    WORLDMAP2_MAINMAP_DRAW_COLONY_IMAGE(controlSet, colonyImg, colonyData)

    controlSet:SetUserValue("COLONY_COUNT", count + 1)
end

function WORLDMAP2_MAINMAP_DRAW_COLONY_SUB_EPISODE(frame, mapName, episode, colonyData)
    local controlSet = AUTO_CAST(frame:GetChild(episode))
    local count = controlSet:GetUserValue("COLONY_COUNT")

    if count == "None" then
        count = 0
    end

    local colonyImg = AUTO_CAST(controlSet:CreateControl('picture', 'colony_img_'..mapName, 55, count * 50 + 5, 50, 50))

    colonyImg:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    colonyImg:SetEnableStretch(1)
    colonyImg:ShowWindow(1)

    WORLDMAP2_MAINMAP_DRAW_COLONY_IMAGE(controlSet, colonyImg, colonyData)

    controlSet:SetUserValue("COLONY_COUNT", count + 1)
end

function WORLDMAP2_MAINMAP_DRAW_COLONY_IMAGE(frame, ctrl, colonyData)
    local controlName = ctrl:GetName()
    local mapName = string.gsub(colonyData.ZoneClassName, "GuildColony_", "")
    local mapData = GetClass("Map", mapName)

    -- 분쟁중
    if session.colonywar.GetProgressState() == true then
        ctrl:SetImage("worldmap2_map_colony_battle")

    -- 미분쟁중
	else
		local taxApplyMap = GetClass("Map", colonyData.TaxApplyCity)
		local taxRateInfo = session.colonytax.GetColonyTaxRate(taxApplyMap.ClassID)

		-- 점령 길드 존재
        if taxRateInfo ~= nil then

            -- 길드 이미지 설정
            local guildID = taxRateInfo:GetGuildID()
            local worldID = session.party.GetMyWorldIDStr()
            local emblemImgName = guild.GetEmblemImageName(guildID, worldID)

            local margin = ctrl:GetMargin()
            local pic = AUTO_CAST(frame:CreateControl('picture', controlName..guildID, margin.left-1, margin.top-1, 50, 50))

            pic:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
            pic:SetEnableStretch(1)
            pic:ShowWindow(1)

            if emblemImgName ~= 'None' then
                pic:SetFileName(emblemImgName)
            else
                guild.ReqEmblemImage(guildID, worldID)
            end

            pic:Resize(30, 30)

            -- 테두리 설정
            frame:RemoveChild(controlName)

            ctrl = AUTO_CAST(frame:CreateControl('picture', controlName, margin.left, margin.top, 50, 50))

            ctrl:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
            ctrl:SetEnableStretch(1)
            ctrl:ShowWindow(1)

            if colonyData.ColonyLeague == 1 then
                ctrl:SetImage("worldmap2_map_colony_champ_occu")
            else
                ctrl:SetImage("worldmap2_map_colony_chall_occu")
            end

		-- 점령 길드 미존재
        else
            if colonyData.ColonyLeague == 1 then
                ctrl:SetImage("worldmap2_map_colony_champ_non")
            else
                ctrl:SetImage("worldmap2_map_colony_chall_non")
            end
		end
    end
    
    -- 클릭시 스크립트 설정
    ctrl:SetUserValue("TARGET_MAP", mapName)
    ctrl:SetEventScript(ui.LBUTTONUP, 'WORLDMAP2_MAINMAP_MOVE_COLONYMAP')

    -- 툴팁
    ctrl:SetTextTooltip(ScpArgMsg("Check{COLONY}", "COLONY", mapData.Name))
end

-- CLEANUP 세부 함수
function WORLDMAP2_MAINMAP_CLEANUP_CHILD(frame)
    local cls = nil
    local list, cnt = GetClassList("worldmap2_data")

	for i = 0, cnt-1 do
        cls = GetClassByIndexFromList(list, i)
        frame:RemoveChild(cls.ClassName)
    end

    AUTO_CAST(frame:GetChild("search_edit")):SetText("")
end

function WORLDMAP2_MAINMAP_CLEANUP_DATA(frame)
    -- 내 위치 초기화
    frame:SetUserValue("MY_POS", "None")
    frame:SetUserValue("WARP_TYPE", "None")

    -- 워프 형태 & 아이템 초기화
    frame:SetUserValue("Type", "None")
    frame:SetUserValue('SCROLL_WARP', "None")

    -- 카테고리 초기화
    WORLDMAP2_CATEGORY_SET_SELECT1("None")
    WORLDMAP2_CATEGORY_SET_SELECT2("None")
end

-- EFFECT
function WORLDMAP2_MAINMAP_EFFECT_ON()
	local frame = ui.GetFrame('worldmap2_mainmap')
    local myPos = frame:GetUserValue("MY_POS")
    if myPos == nil or myPos == "None" then
        return
    end

    local myPosSet = frame:GetChild(myPos)
    local myPosArrow = myPosSet:GetChild("pc_pos")

	myPosArrow:PlayUIEffect("UI_worldmap_pos_01_loop", 8, "MY_POS")
end

function WORLDMAP2_MAINMAP_EFFECT_OFF()
    local frame = ui.GetFrame('worldmap2_mainmap')
    local myPos = frame:GetUserValue("MY_POS")

    if myPos == nil or myPos == "None" then
        return
    end

    local myPosSet = frame:GetChild(myPos)
    local myPosArrow = myPosSet:GetChild("pc_pos")
    
	myPosArrow:StopUIEffect("MY_POS", true, 0)
end

-- FIELDBOSS
function WORLDMAP2_MAINMAP_FIELDBOSS(frame)
    local count = session.world.GetExistFieldBossCount()

    for i = 1, count do
        local mapName = session.world.GetFieldBossMapNameByIndex(i)
        local bossName = session.world.GetFieldBossNameByIndex(i)

        local episode = GET_EPISODE_BY_MAPNAME(mapName)
        local fieldBossText = AUTO_CAST(frame:GetChild("fieldboss_text_"..episode))

        fieldBossText:SetText('{@st100red_16}'..ScpArgMsg('FieldBoss'))
        fieldBossText:ShowWindow(1)
    end
end

-- BOOKMARK
function WORLDMAP2_MAINMAP_BOOKMARK(frame)
    local aObj = GetMyAccountObj()

    for i = 1, 8 do
        local mapName = TryGetProp(aObj, "FavoriteMap_"..i)
        local mapData = GetClass("Map", mapName)

        local btn = AUTO_CAST(frame:GetChild("bookmark_btn_"..i))

        if mapData ~= nil then
            btn:SetText('{@st106_br}{s16}'..mapData.Name)
            btn:SetUserValue("MAPNAME", mapName)
        else
            btn:SetText('{@st106_lbr}{s16}'..ScpArgMsg("NoFavoriteMap"))
            btn:SetUserValue("MAPNAME", "None")
        end

        btn:Resize(170, 25)

        if btn:IsTextOmitted() == true then
            btn:SetTextTooltip(mapData.Name)
        end
    end
end

function WORLDMAP2_MAINMAP_BOOKMARK_CLICK(frame, ctrl, argStr, argNum)
    local mapName = ctrl:GetUserValue("MAPNAME")
    local episode = GET_EPISODE_BY_MAPNAME(mapName)

    if mapName == "None" then
        return
    end

    if GET_WARP_MAP_TYPE() == "None" then
        if keyboard.IsKeyPressed("LSHIFT") == 1 then
            WORLDMAP2_TOKEN_WARP(mapName)
        else
            WORLDMAP2_OPEN_SUBMAP_FROM_MAINMAP_BY_EPISODE(episode)
            WORLDMAP2_OPEN_MINIMAP_FROM_SUBMAP_BY_MAPNAME(mapName)
        end
    else
        REQUEST_WARP_TO_AREA(mapName)
    end
end

-- LOBBY
function WORLDMAP2_MAINMAP_LOBBYMAP_CLICK(frame, ctrl, argStr, argNum)
    local mapName = GET_MY_LAST_WARP_POSITION()
    local episode = GET_EPISODE_BY_MAPNAME(mapName)

    if mapName == nil then
        return
    end

    if GET_WARP_MAP_TYPE() == "None" then
        WORLDMAP2_OPEN_SUBMAP_FROM_MAINMAP_BY_EPISODE(episode)
        WORLDMAP2_OPEN_MINIMAP_FROM_SUBMAP_BY_MAPNAME(mapName)
    else
        REQUEST_WARP_TO_AREA(mapName)
    end
end

-- SCRIPT LIST

-- 길드 이미지 업데이트 함수
function ON_UPDATE_OTHER_GUILD_EMBLEM_WORLDMAP2_MAINMAP(frame, msg, argStr, argNum)
    local worldID = session.party.GetMyWorldIDStr()
    local emblemImgName = guild.GetEmblemImageName(argStr, worldID)

    if emblemImgName == 'None' then
        return
    end

    local colonyDataList = GET_COLONY_MAP_LIST()

    for i = 1, #colonyDataList do
        local colonyData = colonyDataList[i]
        local mapName = string.gsub(colonyData.ZoneClassName, "GuildColony_", "")
        local episode = GET_EPISODE_BY_MAPNAME(mapName)

        local controlSet = AUTO_CAST(frame:GetChild(episode))
        local control = AUTO_CAST(controlSet:GetChild('colony_img_'..mapName..argStr))

        if control ~= nil then
            control:SetFileName(emblemImgName)
        end
    end
end

-- 필드보스 업데이트 함수
function ON_UPDATE_MAINMAP_FIELDBOSS_INFO(frame, msg, argStr, argNum)
    if frame:IsVisible() == 0 then
        return
    end

    WORLDMAP2_MAINMAP_FIELDBOSS(frame)
end

-- 서브맵 접근 함수 (내 위치)
function WORLDMAP2_MAINMAP_MOVE_MYPOS(frame, ctrl)
    local myMapName, myEpisode = GET_MY_POSITION()
    
    WORLDMAP2_OPEN_SUBMAP_FROM_MAINMAP_BY_EPISODE(myEpisode)
end

-- 콜로니 UI 접근 함수 (콜로니 위치)
function WORLDMAP2_MAINMAP_MOVE_COLONYMAP(frame, ctrl)
    local mapName = ctrl:GetUserValue("TARGET_MAP")
    local episode = GET_EPISODE_BY_MAPNAME(mapName)

    ui.OpenFrame("worldmap2_colonymap")
    WORLDMAP2_COLONYMAP_SET_PREVIEW(mapName)
end