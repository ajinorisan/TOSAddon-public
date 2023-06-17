-- worldmap2_uiscp_search.lua

-- 월드맵 검색창 (Enter)
function WORLDMAP2_SEARCH(frame)
    local searchEdit = AUTO_CAST(frame:GetChild("search_edit"))
    local searchText = string.gsub(searchEdit:GetText(), " ", "")

    if string.len(searchText) <= 3 then
        return
    end

    local targetMap = nil
    local targetEpisode = nil

    local clsList, cnt = GetClassList('worldmap2_submap_data')
    for i = 0, cnt-1 do
        local cls = GetClassByIndexFromList(clsList, i)
        local mapData = GetClass('Map', cls.MapName)
        local mapName = string.gsub(dictionary.ReplaceDicIDInCompStr(mapData.Name), " ", "")

        if string.find(string.lower(mapName), string.lower(searchText)) ~= nil then
            targetMap = mapData.ClassName
            targetEpisode = GET_EPISODE_BY_MAPNAME(targetMap)
            break
        end
    end

    if targetMap == nil then
        return
    end

    WORLDMAP2_MINIMAP_OPEN_BY_MAPNAME(targetEpisode, targetMap)
    WORLDMAP2_SUBMAP_ZONE_CHECK(targetMap)
    
    searchEdit:ReleaseFocus()
end

-- 월드맵 검색창 (Text Input Update)
function WORLDMAP2_SEARCH_UPDATE(frame)
    local searchEdit = AUTO_CAST(frame:GetChild("search_edit"))
    local searchText = string.gsub(searchEdit:GetText(), " ", "")

    if searchText == "" then
        return
    end

    local mapList = {}

    local clsList, cnt = GetClassList('worldmap2_submap_data')
    for i = 0, cnt-1 do
        local cls = GetClassByIndexFromList(clsList, i)
        local mapData = GetClass('Map', cls.MapName)
        local mapName = string.gsub(dictionary.ReplaceDicIDInCompStr(mapData.Name), " ", "")

        if string.find(string.lower(mapName), string.lower(searchText)) ~= nil and cls.IsInEpisode == "YES" then
            mapList[#mapList+1] = {}
            mapList[#mapList][1] = mapData.Name
            mapList[#mapList][2] = mapData.ClassName
        end
    end

    if #mapList == 0 then
        return
    end

    ui.MakeDropListFrame(searchEdit, GET_SCENE_OFFSET_WIDTH() - 5, GET_SCENE_OFFSET_HEIGHT(), 326, 1000, math.min(10, #mapList), ui.LEFT, "WORLDMAP2_SEARCH_GO_TARGET_MAP", "WORLDMAP2_SEARCH_DROPLIST_MOUSEOVER", nil)
    
    WORLDMAP2_DROPLIST_SET_BY_UI_MANAGER(255)

    for i = 1, #mapList do
        ui.AddDropListItem(" {@st102_16_nobold}"..mapList[i][1], nil, mapList[i][2])
    end
end

function WORLDMAP2_SEARCH_DROPLIST_MOUSEOVER(index, key)
    local frame = ui.GetFrame('worldmap2_submap')

    if frame:IsVisible() == 0 then
        frame = ui.GetFrame('worldmap2_mainmap')
    end

    local searchEdit = AUTO_CAST(frame:GetChild("search_edit"))
    searchEdit:ReleaseFocus()
end

function WORLDMAP2_SEARCH_GO_TARGET_MAP(index, mapName)
    local episode = GET_EPISODE_BY_MAPNAME(mapName)

    WORLDMAP2_MINIMAP_OPEN_BY_MAPNAME(episode, mapName)
    WORLDMAP2_SUBMAP_ZONE_CHECK(mapName)
end