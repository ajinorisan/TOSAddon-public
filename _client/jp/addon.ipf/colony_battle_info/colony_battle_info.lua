local json = require 'json_imc'
local has_claim = nil
local colony_map_list = nil
local _open_flag = nil

function COLONY_BATTLE_INFO_ON_INIT(addon, frame)
    addon:RegisterMsg('GAME_START', 'CHECK_ENABLE_COLONY_BATTLE_INFO')
    addon:RegisterMsg('IN_COLONYWAR_STATE', 'CHECK_ENABLE_COLONY_BATTLE_INFO')
    addon:RegisterMsg('COLONY_STATE_UPDATE', 'CHECK_ENABLE_COLONY_BATTLE_INFO')

    addon:RegisterMsg('OPEN_COLONY_POINT', 'OPEN_COLONY_BATTLE_UI')
    addon:RegisterMsg('UPDATE_OTHER_GUILD_EMBLEM', 'COLONY_BATTLE_INFO_UPDATE_EMBLEM')
    addon:RegisterMsg('COLONY_OCCUPATION_INFO_UPDATE', 'COLONY_BATTLE_INFO_INIT_OCCUPATION')

    addon:RegisterMsg('COLONY_BUILD_ICON_UPDATE', 'COLONY_BATTLE_BUILD_ICON_UPDATE')
    addon:RegisterMsg('COLONY_BUILD_ICON_REMOVE', 'COLONY_BUILD_ICON_REMOVE')

    addon:RegisterMsg('USE_COLONY_ZONE_CLEAR', 'ON_USE_COLONY_ZONE_CLEAR')
    
    g_COLONY_BUILD_GROUPNAME_OCCUPY = { 'Defense', 'Interrupt' }
    g_COLONY_BUILD_GROUPNAME_NOT_OCCUPY = { 'Offense', 'Divine_Flag' }
    
    g_COLONY_BUILD_OFFENSE = {}
    g_COLONY_BUILD_DEFENSE = {}
    g_COLONY_BUILD_DIVINE_FLAG = {}
    g_COLONY_BUILD_INTERRUPT = {}

    INIT_COLONY_BATTLE_INFO_TIMER(frame)
end

local function is_guild_leader()
    local guild = session.party.GetPartyInfo(PARTY_GUILD)
    if guild == nil then
        return false
    end

    local leader_aid = guild.info:GetLeaderAID()
    local my_aid = session.loginInfo.GetAID()
    if leader_aid == my_aid then
        return true
    else
        return false
    end
end

local function make_colony_map_list()
    if colony_map_list ~= nil then return end

    colony_map_list = {}

    local cls_list, cnt = GetClassList('guild_colony')
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(cls_list, i)
        if cls ~= nil then
            local cls_name = TryGetProp(cls, 'ZoneClassName', 'None')
            local return_city = TryGetProp(cls, 'ReturnCityZoneClassName', 'None')
            if cls_name ~= 'None' and return_city ~= 'None' then
                local map_cls = GetClass('Map', cls_name)
                local city_cls = GetClass('Map', return_city)
                if map_cls ~= nil and city_cls ~= nil then
                    local map_id = TryGetProp(map_cls, 'ClassID', 0)
                    local map_name = dic.getTranslatedStr(TryGetProp(map_cls, 'Name', 'None'))
                    local city_name = dic.getTranslatedStr(TryGetProp(city_cls, 'Name', 'None'))
                    local map_info = {
                        MapID = map_id,
                        MapClassName = cls_name,
                        MapName = map_name,
                        CityName = city_name,
                    }
                    table.insert(colony_map_list, map_info)
                end
            end
        end
    end
end

local function get_colony_map_list()
    if colony_map_list == nil then
        make_colony_map_list()
    end

    return colony_map_list
end

local function get_colony_map_info(index)
    if colony_map_list == nil then
        make_colony_map_list()
    end

    return colony_map_list[index]
end

function IS_COLONY_PROGRESS()
    local guildObj = GET_MY_GUILD_OBJECT()
    if guildObj == nil then
        return false
    end

    if guildObj.EnableEnterColonyWar == 0 then
        return false
    end

    if session.colonywar.GetIsColonyWarMap() == true or session.colonywar.GetProgressState() == true then
        return true
    end

    return false
end

function CHECK_ENABLE_COLONY_BATTLE_INFO(frame, msg, arg_str, arg_num)
    if _open_flag == nil then
        if session.colonywar.GetIsColonyWarMap() == true then
            _open_flag = 'open'
        else
            _open_flag = 'close'
        end
    end

    if msg == 'GAME_START' or msg == 'IN_COLONYWAR_STATE' then
        frame:ShowWindow(BoolToNumber(IS_COLONY_PROGRESS() and _open_flag == 'open'))
    elseif msg == 'COLONY_STATE_UPDATE' then
        frame:ShowWindow(BoolToNumber(IS_COLONY_PROGRESS() and _open_flag == 'open' and arg_num == 1))
    end
end

function INIT_COLONY_BATTLE_INFO_TIMER(frame)
    local timer = GET_CHILD_RECURSIVELY(frame, 'addontimer')
    timer:SetUpdateScript('COLONY_BATTLE_INFO_UPDATE')
    timer:Start(0.45);
end

function OPEN_COLONY_BATTLE_UI(frame, msg)
    CHASEINFO_CLOSE_FRAME()

    if has_claim == nil then
        local arg_list = {}
        CheckClaim('CALLBACK_OPEN_COLONY_BATTLE_UI', 304, arg_list)
    else
        _OPEN_COLONY_BATTLE_UI(frame)
    end
end

function CLOSE_COLONY_BATTLE_UI(frame)
    _open_flag = 'close'
end

function CALLBACK_OPEN_COLONY_BATTLE_UI(code, ret_json, args)
    if code ~= 200 then
        local arg_list = {}
        CheckClaim('CALLBACK_OPEN_COLONY_BATTLE_UI', 304, arg_list)
        return
    end

    has_claim = string.lower(ret_json)
    if is_guild_leader() == true then
        has_claim = 'master'
    end

    local frame = ui.GetFrame('colony_battle_info')
    _OPEN_COLONY_BATTLE_UI(frame)
end

function _OPEN_COLONY_BATTLE_UI(frame)
    if has_claim == nil then
        local arg_list = {}
        CheckClaim('CALLBACK_OPEN_COLONY_BATTLE_UI', 304, arg_list)
        return
    end

    if IS_COLONY_PROGRESS() == false then return end

    make_colony_map_list()

    if has_claim == 'master' then
        local acc = GetMyAccountObj()
        if acc ~= nil then
            frame:SetUserValue('START_TIME', TryGetProp(acc, 'GuildMaster_Colony_Zone_Clear_DateTime', 'None'))
        end
    end

    COLONY_BATTLE_INFO_INIT(frame)
    COLONY_BATTLE_INFO_INIT_OCCUPATION(frame)
    COLONY_BATTLE_INFO_RESET(frame)
    COLONY_BATTLE_INFO_INIT_TIMER(frame)
    COLONY_BATTLE_INFO_SET_SAVED_OFFSET(frame)

    frame:ShowWindow(1)

    COLONY_BATTLE_BUILD_ICON_UPDATE()
    COLONY_BATTLE_OCCUPY_COUNT_UPDATE(frame)

    _open_flag = 'open'
end

function COLONY_BATTLE_INFO_INIT(frame)
    COLONY_BATTLE_INFO_EXPAND_CLICK(frame)
end

function COLONY_BATTLE_INFO_MINIMIZE_CLICK(parent, ctrl)
    local frame = parent:GetTopParentFrame()
    local expandBtn = GET_CHILD_RECURSIVELY(frame, 'expandBtn')
    local infoBox = GET_CHILD_RECURSIVELY(frame, 'infoBox')
    expandBtn:ShowWindow(1)
    infoBox:ShowWindow(0)

    frame:Resize(frame:GetWidth(), expandBtn:GetY() + expandBtn:GetHeight())
end

function COLONY_BATTLE_INFO_EXPAND_CLICK(parent, ctrl)
    local frame = parent:GetTopParentFrame()
    local expandBtn = GET_CHILD_RECURSIVELY(frame, 'expandBtn')
    local infoBox = GET_CHILD_RECURSIVELY(frame, 'infoBox')
    expandBtn:ShowWindow(0)
    infoBox:ShowWindow(1)
    COLONY_BATTLE_BUILD_ICON_UPDATE()
    frame:Resize(frame:GetWidth(), infoBox:GetY() + infoBox:GetHeight())
end

function COLONY_BATTLE_INFO_INIT_OCCUPATION(frame)
    local occupyGuildBox = GET_CHILD_RECURSIVELY(frame, 'occupyGuildBox')
    local noColonyZoneBox = GET_CHILD_RECURSIVELY(frame, 'noColonyZoneBox')

    local mapClassName = GetZoneName()
    local colony_cls = GetClassByStrProp('guild_colony', 'ZoneClassName', mapClassName)
    if colony_cls ~= nil then
        noColonyZoneBox:ShowWindow(0)
        occupyGuildBox:ShowWindow(1)

        local mapCls = GetClass('Map', mapClassName)
        local occupyInfo = session.colonywar.GetOccupationInfoByMapID(mapCls.ClassID)
        if occupyInfo ~= nil then
            local occupyGuildNameText = GET_CHILD_RECURSIVELY(frame, 'occupyGuildNameText')
            local guildID = occupyInfo:GetGuildID()
            GetGuildEmblemImage('COLONY_GUILD_EMBLEM_IMAGE_GET', guildID)
            
            frame:SetUserValue('OCCUPATION_GUILD_ID', guildID)
            occupyGuildNameText:SetText(occupyInfo:GetGuildName())
        end
    else
        occupyGuildBox:ShowWindow(0)
        noColonyZoneBox:ShowWindow(1)
    end

    COLONY_BATTLE_BUILD_ICON_UPDATE()
end

function COLONY_GUILD_EMBLEM_IMAGE_GET(code, return_json)
    local frame = ui.GetFrame('colony_battle_info')
    local occupyGuildEmblemPic = GET_CHILD_RECURSIVELY(frame, 'occupyGuildEmblemPic')
    occupyGuildEmblemPic:SetImage('')
    if code ~= 200 then
        if code == 400 or code == 404 then
            return
        else
            SHOW_GUILD_HTTP_ERROR(code, return_json, 'COLONY_GUILD_EMBLEM_IMAGE_GET')
            return
        end
    end

    local mapClassName = GetZoneName()
    local mapCls = GetClass('Map', mapClassName)
    local occupyInfo = session.colonywar.GetOccupationInfoByMapID(mapCls.ClassID)
    if occupyInfo ~= nil then
        local guildID = occupyInfo:GetGuildID()
        local worldID = session.party.GetMyWorldIDStr()
        local emblemImgName = guild.GetEmblemImageName(guildID,worldID)

        occupyGuildEmblemPic:SetFileName(emblemImgName)
    end
end

function COLONY_BATTLE_INFO_RESET(frame)
    if has_claim == nil then
        local arg_list = {}
        CheckClaim('CALLBACK_OPEN_COLONY_BATTLE_UI', 304, arg_list)
        return
    end

    local map_list = get_colony_map_list()
    for i = 1, #map_list do
        local map_info = map_list[i]
        local ctrlset = GET_CHILD_RECURSIVELY(frame, 'retreatctrl_' .. i)
        if ctrlset ~= nil then
            ctrlset:SetUserValue('MAP_INFO_INDEX', i)

            local btn = GET_CHILD(ctrlset, 'retreat_btn')
            local pic = GET_CHILD(ctrlset, 'disable_pic')
            local nameText = GET_CHILD(ctrlset, 'nameText')
            local countText = GET_CHILD(ctrlset, 'countText')
            local disableText = GET_CHILD(ctrlset, 'disableText')

            nameText:SetText(map_info.MapName)
            btn:ShowWindow(BoolToNumber(has_claim == 'master'))
            pic:ShowWindow(BoolToNumber(has_claim ~= 'master'))
            countText:ShowWindow(BoolToNumber((has_claim == 'master') or (has_claim == 'true')))
            disableText:ShowWindow(BoolToNumber((has_claim ~= 'master') and (has_claim ~= 'true')))
        end
    end
end

function COLONY_BATTLE_INFO_UPDATE_EMBLEM(frame, msg, argStr, argNum)
    local emblemCtrl = GET_CHILD_RECURSIVELY(frame, 'occupyGuildEmblemPic')
    if emblemCtrl ~= nil then
        local worldID = session.party.GetMyWorldIDStr()
        local emblemImgName = guild.GetEmblemImageName(argStr, worldID)
        emblemCtrl:SetImage('')
        emblemCtrl:SetFileName('')

        if emblemImgName ~= 'None' then           
            emblemCtrl:SetFileName(emblemImgName)
            emblemCtrl:Invalidate()
        else
            GetGuildEmblemImage('COLONY_BATTLE_INFO_UPDATE_EMBLEM_GET_IMAGE', argStr)
        end
    end
end

function COLONY_BATTLE_INFO_UPDATE_EMBLEM_GET_IMAGE(code, ret_json)
    if code ~= 200 then
        if code == 400 or code == 404 then
            return
        else
            SHOW_GUILD_HTTP_ERROR(code, return_json, 'COLONY_BATTLE_INFO_UPDATE_EMBLEM_GET_IMAGE')
            return
        end
    end
end

function COLONY_BATTLE_INFO_INIT_TIMER(frame)
    if session.colonywar.IsUpdatedEndTime() == false then
        session.colonywar.RequestColonyWarEndTime()
    end

    local remainTimeText = GET_CHILD_RECURSIVELY(frame, 'remainTimeText')
    remainTimeText:RunUpdateScript('COLONY_BATTLE_INFO_UPDATE_TIMER', 0.5)
end

function COLONY_BATTLE_INFO_UPDATE_TIMER(remainTimeText)
    if session.colonywar.IsUpdatedEndTime() == false then
        session.colonywar.RequestColonyWarEndTime()
        return 1
    end

    local endTime = session.colonywar.GetEndTime()
    local remainTime = -1 * imcTime.GetDiffSecFromNow(endTime.wHour, endTime.wMinute, 0)
    if remainTime <= 0 then
        return 0
    end

    local remainMin = math.floor(remainTime / 60)
    local remainSec = remainTime % 60
    local remainTimeStr = string.format('%d:%02d', remainMin, remainSec)
    remainTimeText:SetTextByKey('time', remainTimeStr)

    return 1
end

function COLONY_BATTLE_INFO_LBTN_UP(frame, ctrl)
    if session.colonywar.GetIsColonyWarMap() == false then
        return
    end

    SET_CONFIG_HUD_OFFSET(frame)
end

function COLONY_BATTLE_INFO_TAB_LBTN_UP(frame, ctrl)
    COLONY_BATTLE_BUILD_ICON_UPDATE()
end

function COLONY_BATTLE_INFO_SET_SAVED_OFFSET(frame)  
    if session.colonywar.GetIsColonyWarMap() == false then
        return
    end

    local channel = ui.GetFrame('channel')
    local defaultX = channel:GetGlobalX()
    local savedX, savedY = GET_CONFIG_HUD_OFFSET(frame, defaultX, frame:GetOriginalY())
    savedX, savedY = GET_OFFSET_IN_SCREEN(savedX, savedY, frame:GetWidth(), frame:GetHeight())
    frame:SetOffset(savedX, savedY)
end

function COLONY_BATTLE_INFO_DRAW_BUFF_ICON()
    local buffFrame = ui.GetFrame('buff')
    local colonyFrame = ui.GetFrame('colony_battle_info')
    if buffFrame == nil or colonyFrame == nil then
        return
    end

    if buffFrame:IsVisible() ~= 1 or colonyFrame:IsVisible() ~= 1 then
        return
    end

    local buffSlotset = GET_CHILD_RECURSIVELY(buffFrame, 'buffslot')
    local buffSlotCount = buffSlotset:GetSlotCount()

    local colonyBuffSlotset = GET_CHILD_RECURSIVELY(colonyFrame, 'buffSlotset')
    if buffSlotset == nil or colonyBuffSlotset == nil then
        return
    end

    colonyBuffSlotset:ClearIconAll()
    local colonyBuffCount = 0
    for i = 0, buffSlotCount - 1 do
        local buffSlot = buffSlotset:GetSlotByIndex(i)
        if buffSlot ~= nil then
            local buffIcon = buffSlot:GetIcon()
            if buffIcon ~= nil and buffSlot:IsVisible() == 1 then
                local buffIconInfo = buffIcon:GetInfo()
                local buffType = buffIconInfo.type
                local buffClass = GetClassByType('Buff', buffType)
                local buffKeyWord = TryGetProp(buffClass, 'Keyword')
                if buffKeyWord ~= nil then
                    local keyWordList = SCR_STRING_CUT(buffKeyWord, ';')
                    local isColonyBuff = 0
                    for i = 1, #keyWordList do
                        local searchWord = keyWordList[i]
                        if tostring(searchWord) == 'GuildColonyBuffMark' then
                            isColonyBuff = 1
                        end
                    end

                    if isColonyBuff == 1 then
                        local totalSlotCount = colonyBuffSlotset:GetSlotCount()
                        local slotIndex = totalSlotCount - colonyBuffCount - 1
                        if slotIndex < 0 then
                            slotIndex = 0 
                        end

                        local colonyBuffSlot = colonyBuffSlotset:GetSlotByIndex(slotIndex)
                        colonyBuffSlot:SetUserValue('buffType', buffType)    
                        local colonyBuffIcon = CreateIcon(colonyBuffSlot)
                        local imageName = 'icon_' .. buffClass.Icon

                        local handle = session.GetMyHandle()
                        if tonumber(handle) == nil then
                            return 
                        end

                        local buff = info.GetBuff(tonumber(handle), buffType)
                        if nil == buff then
                            return
                        end
                        
                        if buff.over > 1 then
                            colonyBuffSlot:SetText('{s13}{ol}{b}'..buff.over, 'count', ui.RIGHT, ui.BOTTOM, -5, -3)
                        else
                            colonyBuffSlot:SetText('')
                        end

                        colonyBuffIcon:SetTooltipType('buff')
                        colonyBuffIcon:SetTooltipArg(handle, buffType)
                        colonyBuffIcon:Set(imageName, 'BUFF', buffType, 0)

                        colonyBuffCount = colonyBuffCount + 1
                        -- colonyBuffSlot:Invalidate()
                    end
                end

            end
        end
    end
    -- colonyBuffSlotset:Invalidate()
end

function COLONY_BATTLE_BUILD_ICON_UPDATE()
    local colonyFrame = ui.GetFrame('colony_battle_info')
    if colonyFrame == nil then
        return
    end

    local isOccupy = 0
    local myHandle = session.GetMyHandle()
    if myHandle == nil then
        return
    end

    local colonyHUD = ui.GetFrame('COLONY_HUD_' .. myHandle)
    if colonyHUD == nil then
        return
    end

    local occupationPic = GET_CHILD_RECURSIVELY(colonyHUD, 'occupationPic')
    if occupationPic ~= nil and occupationPic:IsVisible() == 1 then
        isOccupy = 1
    end

    local viewBuildGroupList = {}
    if isOccupy == 0 then
        viewBuildGroupList = g_COLONY_BUILD_GROUPNAME_NOT_OCCUPY
    else
        viewBuildGroupList = g_COLONY_BUILD_GROUPNAME_OCCUPY
    end

    for i = 1, #viewBuildGroupList do
        local buildSlotsetName = 'buildSlotset' .. isOccupy + 1 .. '_' .. i
        local buildSlotset = GET_CHILD_RECURSIVELY(colonyFrame, buildSlotsetName)
        buildSlotset:ClearIconAll()
        local myBuildBox = GET_CHILD_RECURSIVELY(colonyFrame, 'occupynameBox' .. isOccupy + 3 .. '_' .. i)
        local hideBuildBox = GET_CHILD_RECURSIVELY(colonyFrame, 'occupynameBox' .. 4 - isOccupy .. '_' .. i)
        if buildSlotset == nil or myBuildBox == nil or hideBuildBox == nil then
            return
        end

        myBuildBox:ShowWindow(1)
        hideBuildBox:ShowWindow(0)

        local groupName = 'GuildColony_' .. viewBuildGroupList[i] .. '_Object'
        local cnt = session.guildbuilding.GetHandleCountByGroup(groupName)
        local slotIndex = 0

        local buildingList = {}
        for j = 0, cnt - 1 do
            local gbinfo = session.guildbuilding.GetHandleByGroup(groupName, j)
            if gbinfo ~= nil then
                local buildinginfo = session.guildbuilding.GetByHandle(gbinfo.handle)
                local guildID = buildinginfo:GetGuildID()
                local myGuild = GET_MY_GUILD_INFO()
                if myGuild ~= nil then
                    local myGuildID = myGuild.info:GetPartyID()
                    if guildID == myGuildID then
                        local isExistInList = 0
                        for classID, count in pairs(buildingList) do
                            if classID == gbinfo.classID then
                                buildingList[gbinfo.classID] = count + 1
                                
                                isExistInList = 1
                            end
                        end

                        if isExistInList == 0 then
                            buildingList[gbinfo.classID] = 1
                        end
                    end
                end
            end
        end

        local totalBuildingCount = 0
        for gbClassID, count in pairs(buildingList) do
            if gbClassID ~= nil then
                local gbCls = GetClassByType('Monster', gbClassID)
                if gbCls ~= nil then
                    local slot = buildSlotset:GetSlotByIndex(slotIndex)
                    if slot ~= nil then
                        local icon = CreateIcon(slot)
                        icon:SetImage(gbCls.Icon)
                        slot:SetText(count, 'count', ui.RIGHT, ui.BOTTOM, 2, 1)
                        slotIndex = slotIndex + 1
                        totalBuildingCount = totalBuildingCount + count
                    end
                end
            end
        end

        local buildingCountValueName = 'deploy' .. viewBuildGroupList[i] .. '_Value'
        local buildingCountValue = GET_CHILD_RECURSIVELY(colonyFrame, buildingCountValueName)

        local colonyRuleCls = GetClass('guild_colony_rule', 'GuildColony_Rule_Default')
        local maxCountProp = 'GuildColony_' .. viewBuildGroupList[i] .. '_Object_MaxCount'
        local maxCount = colonyRuleCls[maxCountProp]

        buildingCountValue:SetTextByKey('curCount', totalBuildingCount)
        buildingCountValue:SetTextByKey('maxCount', maxCount)
    end
end

function COLONY_BATTLE_OCCUPY_COUNT_UPDATE(frame)
    local map_list = get_colony_map_list()
    local count_by_index = {}
    for i = 1, #map_list do
        table.insert(count_by_index, 0)
    end

    local function get_member_zone_index(map_list, map_id)
        for i = 1, #map_list do
            if map_list[i].MapID == map_id then
                return i
            end
        end

        return 0
    end

    local member_list = session.party.GetOnlinePartyMemberList(PARTY_GUILD)
    local count = member_list:Count()
    for i = 0, count - 1 do
        local partyMemberInfo = member_list:Element(i)
        local map_id = partyMemberInfo:GetMapID()
        local index = get_member_zone_index(map_list, map_id)
        if index > 0 then
            count_by_index[index] = count_by_index[index] + 1
        end
    end

    for i = 1, #map_list do
        local ctrlset = GET_CHILD_RECURSIVELY(frame, 'retreatctrl_' .. i)
        if ctrlset ~= nil then
            local countText = GET_CHILD(ctrlset, 'countText')
            if countText ~= nil and countText:IsVisible() == 1 then
                countText:SetTextByKey('cur', count_by_index[i])
            end
        end
    end
end

function COLONY_BATTLE_INFO_RETREAT_BTN_CLICK(parent, ctrl)
    if has_claim ~= 'master' then return end

    local info_index = parent:GetUserIValue('MAP_INFO_INDEX')
    local map_info = get_colony_map_info(info_index)
    if map_info == nil then return end

    local clmsg = ScpArgMsg('ReallyRetreatGuildMemberFrom{Zone}To{City}', 'Zone', map_info.MapName, 'City', map_info.CityName)
    local yesscp = string.format('REQ_FORCE_RETURN_TO_CITY(%d)', map_info.MapID)

    local msgbox = ui.MsgBox(clmsg, yesscp, 'None')
    SET_MODAL_MSGBOX(msgbox)
end

function REQ_FORCE_RETURN_TO_CITY(map_id)
    if has_claim ~= 'master' then return end
    local map_cls = GetClassByType('Map', map_id)
    if map_cls == nil then return end

    colonywar.RequestForceReturnToCity(map_id)
end

function COLONY_BATTLE_RETREAT_CTRL_UPDATE(frame)
    local cooltimeText = GET_CHILD_RECURSIVELY(frame, 'cooltimeText')
    if has_claim ~= 'master' then
        cooltimeText:SetText('')
        return
    end

    local map_list = get_colony_map_list()
    if map_list == nil then return end

    local flag = 0
    local alpha = 30
    local start_time = frame:GetUserValue('START_TIME')
    if start_time == 'None' then
        flag = 1
        alpha = 100
        cooltimeText:SetText('')
    else
        local cur = session.GetDBSysTime()
        local cur_time = date_time.get_lua_datetime(cur.wYear, cur.wMonth, cur.wDay, cur.wHour, cur.wMinute, cur.wSecond)
        local diffsec = date_time.get_diff_sec(date_time.lua_datetime_to_str(cur_time), start_time)
        local cooldown = tonumber(GUILDMASTER_COLONY_ZONE_CLEAR_COOLDOWN)
        if diffsec > cooldown then
            flag = 1
            alpha = 100
            cooltimeText:SetText('')
        else
            local time_str = GET_TIME_TXT_NO_LANG(cooldown - diffsec)
            cooltimeText:SetText(time_str)
        end
    end

    for i = 1, #map_list do
        local ctrlset = GET_CHILD_RECURSIVELY(frame, 'retreatctrl_' .. i)
        if ctrlset == nil then return end

        local btn = GET_CHILD(ctrlset, 'retreat_btn')
        btn:SetEnable(flag)
        btn:SetAlpha(alpha)
    end
end

function ON_USE_COLONY_ZONE_CLEAR(frame, msg, arg_str, arg_num)
    local cur = session.GetDBSysTime()
    local cur_time = date_time.get_lua_datetime(cur.wYear, cur.wMonth, cur.wDay, cur.wHour, cur.wMinute, cur.wSecond)
    frame:SetUserValue('START_TIME', date_time.lua_datetime_to_str(cur_time))
    COLONY_BATTLE_RETREAT_CTRL_UPDATE(frame)
end

function COLONY_BATTLE_INFO_UPDATE(frame, timer, argstr, argnum, passedtime)
    COLONY_BATTLE_RETREAT_CTRL_UPDATE(frame)

    local last_time = frame:GetUserIValue('LAST_MEMBER_UPDATE_TIME')
    if passedtime - last_time > 10 then
        COLONY_BATTLE_OCCUPY_COUNT_UPDATE(frame)
        frame:SetUserValue('LAST_MEMBER_UPDATE_TIME', math.floor(passedtime))
    end
end