function INDUNENTER_ON_INIT(addon, frame)
    addon:RegisterMsg('MOVE_ZONE', 'INDUNENTER_CLOSE');
    addon:RegisterMsg('CLOSE_UI', 'INDUNENTER_CLOSE');
    addon:RegisterMsg('ESCAPE_PRESSED', 'INDUNENTER_ON_ESCAPE_PRESSED');
	addon:RegisterMsg('UPDATE_MYTHIC_DUNGEON_PATTERN', 'INDUNENTER_MAKE_PATTERN_BOX');    
    addon:RegisterMsg('FAIL_START_PARTY_MATCHING', 'FAIL_START_PARTY_MATCHING');
    addon:RegisterMsg('FAIL_REGISTER_PARTY_MATCHING', 'FAIL_REGISTER_PARTY_MATCHING');
    PC_INFO_COUNT = 5;
end

function is_invalid_indun_multiple_item()
    local name = 'Adventure_dungeoncount_01'
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList();
    local cnt = guidList:Count();    
    local check_cnt = 0
    for i = 0, cnt - 1 do
        local guid = guidList:Get(i);
        local invItem = invItemList:GetItemByGuid(guid);
        if invItem ~= nil and invItem:GetObject() ~= nil then
            local itemObj = GetIES(invItem:GetObject());
            if TryGetProp(itemObj, 'ClassName', 'None') == name then
                check_cnt = check_cnt + 1
                if check_cnt >= 2 then
                    return true
                end
            end
        end
    end
    return false
end

function INDUNENTER_ON_ESCAPE_PRESSED(frame, msg, argStr, argNum)
    if frame:GetUserValue('AUTOMATCH_MODE') == 'NO' then
        INDUNENTER_CLOSE(frame, msg, argStr, argNum);
    end
end

function INDUNENTER_CLOSEBUTTON_PRESSED(frame, msg, argStr, argNum)
    local topFrame = ui.GetFrame('indunenter');
    if topFrame:GetUserValue('FRAME_MODE') == 'SMALL' then
        INDUNENTER_SMALLMODE_CLOSE();
    else
        INDUNENTER_CLOSE(frame, msg, argStr, argNum);
    end
end

function INDUNENTER_SMALLMODE_CLOSE()
    INDUNENTER_AUTOMATCH_CANCEL();
end

function INDUNENTER_CLOSE(frame, msg, argStr, argNum)
    INDUNENTER_AUTOMATCH_CANCEL();
    INDUNENTER_PARTYMATCH_CANCEL();
    INDUNENTER_MULTI_CANCEL(frame);
    
    ui.CloseFrame("toshero_info_monster")
    ui.CloseFrame('indunenter');
    CloseIndunEnterDialog();
end

function INDUNENTER_UI_RESET(frame)
    local topFrame = ui.GetFrame('indunenter');

    if config.GetServiceNation() == 'GLOBAL_JP' then        
        local img = GET_CHILD_RECURSIVELY(topFrame, 'RatoImg')
        img:SetImage('indun_info_E')
        local rateValue = GET_CHILD_RECURSIVELY(topFrame, "RateValue");
        rateValue:SetMargin(0, 10, 0, 0)
    elseif config.GetServiceNation() == 'GLOBAL' or config.GetServiceNation() == 'PAPAYA' then        
        local img = GET_CHILD_RECURSIVELY(topFrame, 'RatoImg')
        img:SetImage('indun_info_E')
    end

    local rewardBox = GET_CHILD_RECURSIVELY(topFrame, 'rewardBox');
    local weaponBtn = GET_CHILD_RECURSIVELY(rewardBox, 'weaponBtn');
    local materialBtn = GET_CHILD_RECURSIVELY(rewardBox, 'materialBtn');
    local accBtn = GET_CHILD_RECURSIVELY(rewardBox, 'accBtn');
    local armourBtn = GET_CHILD_RECURSIVELY(rewardBox, 'armourBtn');
    local subweaponBtn = GET_CHILD_RECURSIVELY(rewardBox, 'subweaponBtn');

    weaponBtn:SetImage("indun_weapon")
    frame:SetUserValue('weaponBtn','NO')
    materialBtn:SetImage("indun_material")
    frame:SetUserValue('materialBtn','NO')
    accBtn:SetImage("indun_acc")
    frame:SetUserValue('accBtn','NO')
    armourBtn:SetImage("indun_armour")
    frame:SetUserValue('armourBtn','NO')
    subweaponBtn:SetImage("indun_shield")
    frame:SetUserValue('subweaponBtn','NO')
end

function INDUNENTER_AUTOMATCH_CANCEL()
    local frame = ui.GetFrame('indunenter');
    packet.SendCancelIndunMatching();
    INDUNENTER_UPDATE_PC_COUNT(frame, nil, "None", 0);
end

function SHOW_INDUNENTER_DIALOG(indunType, isAlreadyPlaying, enableAutoMatch, enableEnterRight, enablePartyMatch)       
    local frame = ui.GetFrame('indunenter');   
    INDUNENTER_MULTI_CANCEL(frame);

    local big_mode = GET_CHILD_RECURSIVELY(frame, "bigmode");
    local no_picture_box = GET_CHILD_RECURSIVELY(big_mode, 'noPicBox');
    local small_mode = GET_CHILD_RECURSIVELY(frame, "smallmode");
    local small_btn = GET_CHILD_RECURSIVELY(frame, "smallBtn");
    local with_btn = GET_CHILD_RECURSIVELY(frame, "withBtn");
    local enter_btn = GET_CHILD_RECURSIVELY(frame, "enterBtn");
    local auto_math_text = GET_CHILD_RECURSIVELY(frame, "autoMatchText");
    if frame:IsVisible() == 1 then return; end
    
    local pc = GetMyPCObject();
    local etc_object = GetMyEtcObject();
    if pc == nil or etc_object == nil then return; end

local indun_cls = GetClassByType("Indun", indunType);
    if indun_cls == nil then return; end

    if string.find(indun_cls.DungeonType, "TOSHero") == 1 then        
        indunType = 652;
    end

    local admission_item_name = TryGetProp(indun_cls, "AdmissionItemName");
    local admission_item_count = TryGetProp(indun_cls, "AdmissionItemCount");
    local admission_play_add_item_count = TryGetProp(indun_cls, "AdmissionPlayAddItemCount");

    local indun_admission_item_image = nil;
    local admission_item_cls = GetClass("Item", admission_item_name);
    if admission_item_cls ~= nil then 
        indun_admission_item_image = TryGetProp(admission_item_cls, "Icon");
    end
    
    local is_token = session.loginInfo.IsPremiumState(ITEM_TOKEN);
    if is_token == true then 
        is_token = TryGetProp(indun_cls, "PlayPerReset_Token");
    else
        is_token = 0; 
    end

    if indun_cls.UnitPerReset == "ACCOUNT" then
        etc_object = GetMyAccountObj();
        if etc_object == nil then return; end
    end
    
    local play_per_reset_type = TryGetProp(indun_cls, "PlayPerResetType", 0);
    local now_count = TryGetProp(etc_object, "InDunCountType_"..tostring(play_per_reset_type), 0);
    
    local add_count = math.floor(now_count * admission_play_add_item_count);
    if indun_cls.WeeklyEnterableCount ~= 0 then
        now_count = TryGetProp(etc_object, "IndunWeeklyEnteredCount_"..tostring(play_per_reset_type), 0);
        add_count = math.floor((now_count - indun_cls.WeeklyEnterableCount) * admission_play_add_item_count);
        if add_count < 0 then add_count = 0; end
    end
    
    local now_admission_item_count = 0;

    if  IsBuffApplied(pc, "Event_Steam_New_World_Buff") == "YES" and admission_item_name == "Dungeon_Key01_NoTrade" then
        now_admission_item_count = 1
    elseif IsBuffApplied(pc, "Event_Unique_Raid_Bonus") == "YES" and admission_item_name == "Dungeon_Key01_NoTrade" then
        now_admission_item_count = admission_item_count;
    elseif IsBuffApplied(pc, "Event_Unique_Raid_Bonus_Limit") == "YES" and admission_item_name == "Dungeon_Key01_NoTrade" then
        local account_obj = GetMyAccountObj();
        if account_obj ~= nil then
            local event_unique_raid_bonus_limit = TryGetProp(account_obj, "EVENT_UNIQUE_RAID_BONUS_LIMIT", 0);
            if event_unique_raid_bonus_limit > 0 then
                now_admission_item_count = admission_item_count;
        else
                now_admission_item_count = admission_item_count + add_count - is_token;
            end
        end
    else
        now_admission_item_count = admission_item_count + add_count - is_token;
    end
    
    if admission_item_name ~= "None" and admission_item_name ~= nil then
        if indun_cls.DungeonType == "Raid" or indun_cls.DungeonType == "GTower" then
            if now_count >= indun_cls.WeeklyEnterableCount then
                auto_math_text:SetTextByKey("image", '  {img '..indun_admission_item_image..' 24 24} - '..now_admission_item_count..'')
                enter_btn:SetTextByKey("image", '  {img '..indun_admission_item_image..' 24 24} - '..now_admission_item_count..'')
            else
                auto_math_text:SetTextByKey("image", "")
                enter_btn:SetTextByKey("image", "")
            end
        else
            auto_math_text:SetTextByKey("image", '  {img '..indun_admission_item_image..' 24 24} - '..now_admission_item_count..'')
            enter_btn:SetTextByKey("image", '  {img '..indun_admission_item_image..' 24 24} - '..now_admission_item_count..'')
        end
    else
        auto_math_text:SetTextByKey("image", "")
        enter_btn:SetTextByKey("image", "")
    end
    
    -- set user value
    frame:SetUserValue('INDUN_TYPE', indunType);
    frame:SetUserValue('FRAME_MODE', 'BIG');
    frame:SetUserValue('INDUN_NAME', indun_cls.Name);
    frame:SetUserValue('AUTOMATCH_MODE', 'NO');
    frame:SetUserValue('WITHMATCH_MODE', 'NO');
    frame:SetUserValue('AUTOMATCH_FIND', 'NO');
    frame:SetUserValue("multipleCount", 0);
    
    -- make controls
    INDUNENTER_MAKE_HEADER(frame);
    INDUNENTER_MAKE_PICTURE(frame, indun_cls);
    INDUNENTER_MAKE_ALERT(frame, indun_cls);
    INDUNENTER_MAKE_COUNT_BOX(frame, no_picture_box, indun_cls);
    INDUNENTER_MAKE_LEVEL_BOX(frame, no_picture_box, indun_cls);
    INDUNENTER_MAKE_MULTI_BOX(frame, indun_cls);
    INDUNENTER_UPDATE_PC_COUNT(frame, nil, "None", 0);
    INDUNENTER_MAKE_MONLIST(frame, indun_cls);
    INDUNENTER_MAKE_ETCINFO_BOX(frame, indun_cls);
    INDUNENTER_REQUEST_PATTERN(frame, indun_cls);
    
    -- setting
	INDUNENTER_INIT_MEMBERBOX(frame);
    INDUNENTER_AUTOMATCH_TYPE(0);
    INDUNENTER_AUTOMATCH_PARTY(0);
    INDUNENTER_SET_MEMBERCNTBOX();
    INDUNENTER_INIT_REENTER_UNDERSTAFF_BUTTON(frame, isAlreadyPlaying);
    with_btn:SetTextTooltip(ClMsg("PartyMatchInfo_Req"));

    local enable_multi = 1;
    if enableAutoMatch == 0 then enable_multi = 0; end

    frame:SetUserValue('ENABLE_ENTERRIGHT', enableEnterRight);
    frame:SetUserValue('ENABLE_AUTOMATCH', enableAutoMatch);
    frame:SetUserValue('ENABLE_PARTYMATCH', enablePartyMatch);
    INDUNENTER_SET_ENABLE(enableEnterRight, enableAutoMatch, enablePartyMatch, enable_multi);

    -- 해외 UI 세팅
    if config.GetServiceNation() ~= "KOR" and config.GetServiceNation() ~= "GLOBAL_KOR" then
        INDUNENTER_GLOBAL_UI_SETTING(frame);
    end

    -- show
    frame:ShowWindow(1);
    big_mode:ShowWindow(1);
    small_mode:ShowWindow(0);
end

function INDUNENTER_GLOBAL_UI_SETTING(frame)
    local btn1 = GET_CHILD_RECURSIVELY(frame, 'autoMatchBtn')
    local btn2 = GET_CHILD_RECURSIVELY(frame, 'reEnterBtn')
    local btn3 = GET_CHILD_RECURSIVELY(frame, 'understaffEnterAllowBtn')
    local btn4 = GET_CHILD_RECURSIVELY(frame, 'multiBtn')
    local btn5 = GET_CHILD_RECURSIVELY(frame, 'multiCancelBtn')

    btn1:SetTextFixWidth(1)
    btn2:SetTextFixWidth(1)
    btn3:SetTextFixWidth(1)
    btn4:SetTextFixWidth(1)
    btn5:SetTextFixWidth(1)
end

function INDUNENTER_INIT_REENTER_UNDERSTAFF_BUTTON(frame, enableReenter)
    if enableReenter == nil then
        enableReenter = frame:GetUserIValue('ENABLE_REENTER');
    end
    local reEnterBtn = GET_CHILD_RECURSIVELY(frame, 'reEnterBtn');
    local understaffEnterAllowBtn = GET_CHILD_RECURSIVELY(frame, 'understaffEnterAllowBtn');
    local smallUnderstaffEnterAllowBtn = GET_CHILD_RECURSIVELY(frame, 'smallUnderstaffEnterAllowBtn');
    
    reEnterBtn:ShowWindow(enableReenter);
    if enableReenter == 1 then
        understaffEnterAllowBtn:ShowWindow(0);
    else
        understaffEnterAllowBtn:ShowWindow(1);
        understaffEnterAllowBtn:SetEnable(0);
    end
    smallUnderstaffEnterAllowBtn:ShowWindow(1);    
    frame:SetUserValue('ENABLE_REENTER', enableReenter);
end

function REFRESH_REENTER_UNDERSTAFF_BUTTON(isEnableReEnter)
    local frame = ui.GetFrame('indunenter');

    INDUNENTER_INIT_REENTER_UNDERSTAFF_BUTTON(frame, isEnableReEnter);
end

function INDUNENTER_INIT_MEMBERBOX(frame)
    INDUNENTER_INIT_MY_INFO(frame, 'NO');
    INDUNENTER_UPDATE_PC_COUNT(frame, nil, "None", 0);
end

function INDUNENTER_INIT_MY_INFO(frame, understaff)
    local pc = GetMyPCObject();
    local aid = session.loginInfo.GetAID();
    local mySession = session.GetMySession();
    local etcObject = GetMyEtcObject();
    local jobID = TryGetProp(etcObject, "RepresentationClassID");
    local lv = TryGetProp(pc, "Lv");
    if pc == nil or jobID == nil or lv ==  nil or mySession == nil then
        return;
    end
    local cid = mySession:GetCID();

    frame:SetUserValue('MEMBER_INFO', aid..'/'..tostring(jobID)..'/'..tostring(lv)..'/'..cid..'/'..understaff);
end

function INDUNENTER_MAKE_PICTURE(frame, indunCls)
    local map_image = TryGetProp(indunCls, 'MapImage');
    if frame == nil or map_image == nil then return; end
    local indunPic = GET_CHILD_RECURSIVELY(frame, 'indunPic');
    if map_image ~= 'None' then
        indunPic:SetImage(map_image);
    end
end

-- 스킬 제한 경고문
function INDUNENTER_MAKE_ALERT(frame, indunCls)    
	INDUNENTER_MAKE_SKILL_ALERT(frame, indunCls)
    INDUNENTER_MAKE_ITEM_ALERT(frame, indunCls)
    INDUNENTER_MAKE_DUNGEON_ALERT(frame, indunCls)
	local restrictBox = GET_CHILD_RECURSIVELY(frame, 'restrictBox');
    GBOX_AUTO_ALIGN(restrictBox, 2, 2, 0, true, true,true);
end
function INDUNENTER_MAKE_SKILL_ALERT(frame, indunCls)
	local restrictSkillBox = GET_CHILD_RECURSIVELY(frame, 'restrictSkillBox');
    restrictSkillBox:ShowWindow(0);

    local mapName = TryGetProp(indunCls, "MapName");
    if mapName == nil then mapName = TryGetProp(indunCls, "StartMap"); end

    local isLegendRaid = 0;
    local dungeonType = TryGetProp(indunCls, "DungeonType");
    if dungeonType == "Raid" or dungeonType == "GTower" or string.find(dungeonType, "MythicDungeon") == 1 then
        isLegendRaid = 1;
    end    

    if mapName ~= nil and mapName ~= "None" then
        local indunMap = GetClass("Map", mapName);
        local mapKeyword = TryGetProp(indunMap, "Keyword");        
        if mapKeyword ~= nil and string.find(mapKeyword, "IsRaidField") ~= nil then
            restrictSkillBox:ShowWindow(1);
            restrictSkillBox:SetTooltipOverlap(1);
            local TOOLTIP_POSX = frame:GetUserConfig("TOOLTIP_POSX");
            local TOOLTIP_POSY = frame:GetUserConfig("TOOLTIP_POSY");
            restrictSkillBox:SetPosTooltip(TOOLTIP_POSX, TOOLTIP_POSY);
            restrictSkillBox:SetTooltipType("skillRestrictList");
            restrictSkillBox:SetTooltipArg("IsRaidField", isLegendRaid);
        end
    end
end
function INDUNENTER_MAKE_ITEM_ALERT(frame, indunCls)
    local restrictItemBox = GET_CHILD_RECURSIVELY(frame, 'restrictItemBox');
    restrictItemBox:ShowWindow(0);
	local cls = GetClassByStrProp("ItemRestrict","Category",indunCls.ClassName)
    if cls ~= nil then
		restrictItemBox:ShowWindow(1);
		restrictItemBox:SetTooltipOverlap(1);
		local TOOLTIP_POSX = frame:GetUserConfig("TOOLTIP_POSX");
		local TOOLTIP_POSY = frame:GetUserConfig("TOOLTIP_POSY");
		restrictItemBox:SetPosTooltip(TOOLTIP_POSX, TOOLTIP_POSY);
		restrictItemBox:SetTooltipType("itemRestrictList");
		restrictItemBox:SetTooltipArg(indunCls.ClassName);
    end
end

function INDUNENTER_MAKE_DUNGEON_ALERT(frame, indunCls)    
    local restrictDungeonBox = GET_CHILD_RECURSIVELY(frame, 'restrictDungeonBox');
    restrictDungeonBox:ShowWindow(0);
	local cls = GetClassByStrProp("dungeon_restrict","Category",indunCls.ClassName)
    if cls ~= nil then
		restrictDungeonBox:ShowWindow(1);
		restrictDungeonBox:SetTooltipOverlap(1);
		local TOOLTIP_POSX = frame:GetUserConfig("TOOLTIP_POSX");
		local TOOLTIP_POSY = frame:GetUserConfig("TOOLTIP_POSY");
		restrictDungeonBox:SetPosTooltip(TOOLTIP_POSX, TOOLTIP_POSY);
		restrictDungeonBox:SetTooltipType("dungeonRestrictList");
		restrictDungeonBox:SetTooltipArg(indunCls.ClassName);
    end
end

function INDUNENTER_MAKE_CHALLENGE_DIVISION_HELP_TEXT(frame)
    if frame == nil then return; end
    INDUNENTER_SHOW_WINDOW_MONBOX(frame, 0);
    INDUNENTER_SHOW_WINDOW_REWARDBOX(frame, 0);

    local map_help_text = GET_CHILD_RECURSIVELY(frame, "mapHelpText");        
    if map_help_text ~= nil then
        map_help_text:ShowWindow(0)
        local mapHelpBox = GET_CHILD_RECURSIVELY(frame, 'mapHelpBox')
        mapHelpBox:ShowWindow(0)
    end

    for i = 1, 7 do
        local map_text = GET_CHILD_RECURSIVELY(frame, "mapText" .. i);
        if map_text ~= nil then
            map_text:ShowWindow(0)
        end        
    end

    local indun_cls = GetClass("contents_info", "ChallengeMode_HardMode");
    if indun_cls == nil then return; end

    local map_list = StringSplit(TryGetProp(indun_cls, "StartMap", ""), '/');
    if map_list ~= nil then
        local map_help_text = GET_CHILD_RECURSIVELY(frame, "mapHelpText");        
        map_help_text:SetTextByKey("text", ClMsg("challenge_auto_division_mode_day_help_text"));
        for i = 1, 3 do
            local map_text = GET_CHILD_RECURSIVELY(frame, "mapText" .. i);
            map_text:SetTextFixWidth(0)
            map_text:EnableTextOmitByWidth(0)
            map_text:Resize(350, map_text:GetHeight())
            map_text:SetText(GetClass("Map", map_list[i]).Name);
        end

        for i = 4, 7 do
            local map_text = GET_CHILD_RECURSIVELY(frame, "mapText" .. i);
            map_text:ShowWindow(0)
        end
    end
end

function INDUNENTER_SHOW_WINDOW_MONBOX(frame, isVisible)
    local mon_slot_set = GET_CHILD_RECURSIVELY(frame, 'monSlotSet');
    local mon_right_btn = GET_CHILD_RECURSIVELY(frame, 'monRightBtn');
    local mon_left_btn = GET_CHILD_RECURSIVELY(frame, 'monLeftBtn');
    local mon_text = GET_CHILD_RECURSIVELY(frame, "monText");
    local mon_pic = GET_CHILD_RECURSIVELY(frame, "monPic");
    mon_slot_set:ShowWindow(isVisible);
    mon_right_btn:ShowWindow(isVisible);
    mon_left_btn:ShowWindow(isVisible);
    mon_text:ShowWindow(isVisible);
    mon_pic:ShowWindow(isVisible);

    for i = 1, 7 do
        local map_help_box = GET_CHILD_RECURSIVELY(frame, "mapHelpBox");
        if map_help_box ~= nil then
            if isVisible == 0 then map_help_box:ShowWindow(1);
            elseif isVisible == 1 then map_help_box:ShowWindow(0); end
        end

        local map_help_text = GET_CHILD_RECURSIVELY(frame, "mapHelpText");
        if map_help_text ~= nil then
            if isVisible == 0 then map_help_text:ShowWindow(1);
            elseif isVisible == 1 then map_help_text:ShowWindow(0); end
        end

        local map_text = GET_CHILD_RECURSIVELY(frame, "mapText"..i);
        if map_text ~= nil then
            if isVisible == 0 then map_text:ShowWindow(1);
            elseif isVisible == 1 then map_text:ShowWindow(0); end
        end
    end
end

function INDUNENTER_SHOW_WINDOW_REWARDBOX(frame, isVisible)
	local reward_box = GET_CHILD_RECURSIVELY(frame, "rewardBox");
    reward_box:ShowWindow(isVisible);
end

function INDUNENTER_SHOW_WINDOW_MAPINFO(frame, indunCls, isVisible)

    -- 몬스터 정보 슬롯셋 제거
    local monBox = GET_CHILD_RECURSIVELY(frame, "monBox")
    local monSlotSet = GET_CHILD_RECURSIVELY(monBox, "monSlotSet")
    local monLeftBtn = GET_CHILD_RECURSIVELY(monBox, "monLeftBtn")
    local monRightBtn = GET_CHILD_RECURSIVELY(monBox, "monRightBtn")
    local mon_list_box = GET_CHILD_RECURSIVELY(frame, "monListBtn");

    if isVisible == 1 then
        monSlotSet:ShowWindow(0)
        monLeftBtn:ShowWindow(0)
        monRightBtn:ShowWindow(0)
        mon_list_box:ShowWindow(1)
        mon_list_box:SetEventScriptArgString(ui.LBUTTONUP, indunCls.ClassName)
    else
        mon_list_box:ShowWindow(0)
    end

    -- 맵 정보
    local mapInfoBox = GET_CHILD_RECURSIVELY(frame, "mapInfoBox")

    if isVisible == 1 then
        local height = 10
        local infoClass = GetClass("TOSHeroIndunInfo", indunCls.ClassName)

        -- 미션
        local missionTitle = GET_CHILD_RECURSIVELY(mapInfoBox, "mapInfoMission")

        missionTitle:SetMargin(10, height - 1, 0, 0)

        local missionText = GET_CHILD_RECURSIVELY(mapInfoBox, "mapInfoMissionText")

        missionText:SetTextByKey("text", infoClass.Desc_Mission)
        missionText:SetMargin(75, height, 0, 0)

        height = height + missionText:GetHeight() + 10

        -- 맵 패턴
        local patternTitle = GET_CHILD_RECURSIVELY(mapInfoBox, "mapInfoPattern")

        patternTitle:SetMargin(10, height - 1, 0, 0)

        for i = 1, 3 do
            local patternText = GET_CHILD_RECURSIVELY(mapInfoBox, "mapInfoPatternText"..i)
            local textData = TryGetProp(infoClass, "Desc_MapPattern"..i, "")

            if textData == "None" then
                patternText:SetTextByKey("text", "")
                patternText:SetMargin(75, height, 0, 0)
            else
                patternText:SetTextByKey("text", textData)
                patternText:SetMargin(75, height, 0, 0)

                height = height + patternText:GetHeight() + 5
            end
        end

        height = height + 13

        -- 공백용 더미
        local dummy = GET_CHILD_RECURSIVELY(mapInfoBox, "mapInfoDummy")
        dummy:SetMargin(mapInfoBox:GetWidth(), height, 0, 0)
    end

    mapInfoBox:ShowWindow(isVisible)
end

function INDUNENTER_MAKE_MONLIST(frame, indunCls)    
    if frame == nil then
        return;
    end

    local monSlotSet = GET_CHILD_RECURSIVELY(frame, 'monSlotSet');
    local monRightBtn = GET_CHILD_RECURSIVELY(frame, 'monRightBtn');
    local monLeftBtn = GET_CHILD_RECURSIVELY(frame, 'monLeftBtn');
    local monText = GET_CHILD_RECURSIVELY(frame, "monText");    
    local monPic = GET_CHILD_RECURSIVELY(frame, "monPic");
    local scoreBtn = GET_CHILD_RECURSIVELY(frame, "scoreBtn");
    local dungeonType = TryGetProp(indunCls,"DungeonType","None")
    local is_mythic_dungeon = string.find(dungeonType, "MythicDungeon") == 1
    local is_toshero_dungeon = string.find(dungeonType, "TOSHero") == 1
    local is_solo_dungeon = dungeonType == "Solo_dungeon";
    local is_earring_dungeon = string.find(dungeonType, "EarringRaid") == 1 or dungeonType == "SeasonEarringRaid";
    if scoreBtn ~= nil then
        if is_toshero_dungeon then 
            scoreBtn:ShowWindow(1)
        else
            scoreBtn:ShowWindow(0)
        end
    end
    
    local is_four_buttons = false
		local buttonCls = GetClass("IndunInfoButton",dungeonType)
		if buttonCls ~= nil then
        if (TryGetProp(buttonCls,"RedButtonText","None") ~= "None" or TryGetProp(buttonCls,"Button3Text","None") ~= "None") 
        and (TryGetProp(buttonCls,"Button2Text","None") ~= "None" or TryGetProp(buttonCls,"Button1Text","None") ~= "None") then
				is_four_buttons = true
			end
		end

        INDUNENTER_SHOW_WINDOW_MONBOX(frame, 1);
        if is_earring_dungeon == true then
            INDUNENTER_SHOW_WINDOW_REWARDBOX(frame, 1);            
        else
            INDUNENTER_SHOW_WINDOW_REWARDBOX(frame, BoolToNumber(is_mythic_dungeon == false and is_toshero_dungeon == false and is_four_buttons == false and is_solo_dungeon == false));
        end

    INDUNENTER_SHOW_WINDOW_MAPINFO(frame, indunCls, BoolToNumber(is_toshero_dungeon))

    -- init
    monSlotSet:ClearIconAll();
    monSlotSet:SetUserValue('CURRENT_SLOT', 1);
    monSlotSet:SetOffset(monSlotSet:GetOriginalX(), monSlotSet:GetY());

    -- data set
    local bossList = TryGetProp(indunCls, 'BossList');
    if bossList == nil or bossList == 'None' then
        return;
    end
    local bossTable = StringSplit(bossList, '/');
    frame:SetUserValue('MON_SLOT_CNT', #bossTable);

    for i = 1, #bossTable do
        local monIcon = nil;
        local monCls = nil;
        if bossTable[i] == "Random" then
            monIcon = frame:GetUserConfig('RANDOM_ICON');
        else
            monCls = GetClass('Monster', bossTable[i]);
            monIcon = TryGetProp(monCls, 'Icon');
        end

        if monIcon ~= nil then
            local slot = monSlotSet:GetSlotByIndex(i - 1);
            if slot ~= nil then
                local slotIcon = CreateIcon(slot);
                slotIcon:SetImage(monIcon);
                if monCls ~= nil then -- set tooltip
                    slotIcon:SetImage(GET_MON_ILLUST(monCls));
                    slotIcon:SetTooltipType("mon_simple");
                    slotIcon:SetTooltipArg(bossTable[i]);
                    slotIcon:SetTooltipOverlap(1);
                end
            end
        end
    end

    if #bossTable > 5 then
        monRightBtn:SetEnable(1);
        monLeftBtn:SetEnable(0);
    else
        monRightBtn:SetEnable(0);
        monLeftBtn:SetEnable(0);
    end
end

function INDUNENTER_MAKE_ETCINFO_BOX(frame, indunCls)
    local etcInfoBox = GET_CHILD_RECURSIVELY(frame, 'etcInfoGbox')
    local dungeonType = TryGetProp(indunCls, 'DungeonType', 'None')
    if dungeonType == 'Indun' or dungeonType == 'MissionIndun' then
        etcInfoBox:ShowWindow(1)
    else
        etcInfoBox:ShowWindow(0)
    end
end

function INDUNENTER_REQUEST_PATTERN(frame,indunCls)
	local dungeonType = TryGetProp(indunCls,"DungeonType")
	local patternBox = GET_CHILD_RECURSIVELY(frame, 'patternBox');
	local rewardBox = GET_CHILD_RECURSIVELY(frame, 'rewardBox');
	if string.find(dungeonType,"MythicDungeon") == 1 then
		mythic_dungeon.RequestCurrentSeason();
		patternBox:ShowWindow(1)
	else
		patternBox:ShowWindow(0)
	end
end

function INDUNENTER_MAKE_PATTERN_BOX(frame,msg,argStr,argNum)
	local indunType = frame:GetUserIValue('INDUN_TYPE');
	local indunCls = GetClassByType("Indun",indunType)
	if indunCls == nil then
		return
	end
	local patternBox = GET_CHILD_RECURSIVELY(frame, 'patternBox');
	local gbox = GET_CHILD_RECURSIVELY(patternBox,"patternSlotSet")
	patternBox:ShowWindow(1)
	
	local pattern_list = GET_INDUN_PATTERN_ID_LIST(indunCls)
	if #pattern_list == 0 then
		patternBox:ShowWindow(0)
		return
	end
	gbox:ClearIconAll();
	for i = 1,#pattern_list do
		local patternID = pattern_list[i]
		local pattern = GetClassByType("boss_pattern",patternID)
		INDUNINFO_PATTERN_BOX_ADD_ICON(gbox,pattern,i)
	end
	gbox:SetUserValue('CURRENT_SLOT', 1);
	gbox:SetUserValue('MAX_SLOT', #pattern_list);
	local margin = gbox:GetOriginalMargin();
    gbox:SetMargin(margin.left, margin.top, margin.right, margin.bottom);
	local patternRightBtn = GET_CHILD(patternBox,"patternRightBtn")
	local patternLeftBtn = GET_CHILD(patternBox,"patternLeftBtn")
	patternRightBtn:SetEnable(BoolToNumber(#pattern_list>5))
	patternLeftBtn:SetEnable(0)
end

-- 큐브 재개봉 시스템 개편에 따른 변경사항으로 보상 아이템 목록 보여주는 부분 큐브 대신 구성품으로 풀어서 보여주도록 변경함(2019.2.27 변경)
function INDUNENTER_DROPBOX_ITEM_LIST(parent, control)
    local frame = ui.GetFrame('indunenter');
    local rewardBox = GET_CHILD_RECURSIVELY(frame, 'rewardBox');
    local controlName = control:GetName();
    -- 여기서 부터
    local topFrame = frame:GetTopParentFrame();
    local indunType = topFrame:GetUserValue('INDUN_TYPE');
    local indunCls = GetClassByType('Indun', indunType);
    local dungeonType = TryGetProp(indunCls, 'DungeonType')
    local indunRewardItem = TryGetProp(indunCls, 'Reward_Item')
    local groupList = SCR_STRING_CUT(indunRewardItem, '/')
    
    local indunRewardItemList = { };
    indunRewardItemList['weaponBtn'] = { };
    indunRewardItemList['subweaponBtn'] = { };
    indunRewardItemList['armourBtn'] = { };
    indunRewardItemList['accBtn'] = { };
    indunRewardItemList['materialBtn'] = { };

    local allIndunRewardItemList, allIndunRewardItemCount = GetClassList('reward_indun');
    
    if groupList ~= nil then
        for i = 1, #groupList do
            -- 신규 레벨던전의 경우 'ClassName;1'의 형식으로 보상 이름이 들어가있을 수 있어서 ';'으로 파싱 한번 더해줌
            local strList = SCR_STRING_CUT(groupList[i], ';')
            local itemName = strList[1]
            local itemCls = GetClass('Item', itemName)
            local itemGroupName = TryGetProp(itemCls, 'GroupName')
            if itemGroupName == 'Cube' then
                -- 큐브 재개봉 시스템 개편에 따른 변경사항으로 보상 아이템 목록 보여주는 부분 큐브 대신 구성품으로 풀어서 보여주도록 변경함
                local itemStringArg = TryGetProp(itemCls, 'StringArg')
                for j = 0, allIndunRewardItemCount - 1  do
                    local indunRewardItemClass = GetClassByIndexFromList(allIndunRewardItemList, j);
                    if indunRewardItemClass ~= nil and TryGetProp(indunRewardItemClass, 'Group') == itemStringArg then
                        CHECK_AND_FILL_REWARD_DROPBOX(indunRewardItemList, indunRewardItemClass.ItemName)
                    end
                end
            else
                CHECK_AND_FILL_REWARD_DROPBOX(indunRewardItemList, itemName)
            end
        end
    end
    
    if #indunRewardItemList[controlName] == 0 then
        local dropListFrame = ui.MakeDropListFrame(control, 0, 0, 300, 600, 1, ui.LEFT, "INDUNENTER_DROPBOX_AFTER_BTN_DOWN",nil,nil);
            ui.AddDropListItem(ClMsg('IndunRewardItem_Empty'))
        return;
    elseif #indunRewardItemList[controlName] ~= 0 and #indunRewardItemList[controlName] < 10 then
        local dropListSize = #indunRewardItemList[controlName] * 1
        local dropListFrame = ui.MakeDropListFrame(control, 0, 0, 300, 600, dropListSize, ui.LEFT, "GET_INDUNENTER_DROPBOX_LIST_TOOLTIP_VIEW","GET_INDUNENTER_DROPBOX_LIST_MOUSE_OVER","GET_INDUNENTER_DROPBOX_LIST_MOUSE_OUT");
    else
        local dropListFrame = ui.MakeDropListFrame(control, 0, 0, 300, 600, 10, ui.LEFT, "GET_INDUNENTER_DROPBOX_LIST_TOOLTIP_VIEW","GET_INDUNENTER_DROPBOX_LIST_MOUSE_OVER","GET_INDUNENTER_DROPBOX_LIST_MOUSE_OUT");
    end

    if #indunRewardItemList[controlName] >= 1 then
        for l = 1, #indunRewardItemList[controlName] do
            local dropBoxItem = indunRewardItemList[controlName][l];
            ui.AddDropListItem(dropBoxItem.Name, nil, dropBoxItem.ClassName)
        end
    end
    
    local itemFrame = ui.GetFrame("wholeitem_link");
    if itemFrame == nil then
        itemFrame = ui.GetNewToolTip("wholeitem_link", "wholeitem_link");
    end
    itemFrame:SetUserValue('MouseClickedCheck','NO')
    -- 여기까지
end 

function INDUNENTER_MAKE_DROPBOX(parent, control)
    local frame = ui.GetFrame('indunenter');
    local rewardBox = GET_CHILD_RECURSIVELY(frame, 'rewardBox');
    local controlName = control:GetName();
    
    local btnList, imgList = GET_INDUNENTER_MAKE_DROPBOX_BTN_LIST();
    for i = 1, #btnList do
        local btnName = btnList[i];
        local imgName = imgList[i];
        
        if controlName == btnName then
            if control:GetUserValue(btnName) == 'NO' then
                control:SetImage(imgName .. '_clicked');
                control:SetUserValue(btnName, 'YES');
            else
                control:SetImage(imgName);
                control:SetUserValue(btnName, 'NO');
            end
        else
            local btn = GET_CHILD_RECURSIVELY(rewardBox, btnName);
            btn:SetImage(imgName);
            btn:SetUserValue(btnName, 'NO');
        end
        if control:GetUserValue(btnName) == 'NO' then
            return ;
        end
    end
    INDUNENTER_DROPBOX_ITEM_LIST(parent, control)
end

function GET_INDUNENTER_MAKE_DROPBOX_BTN_LIST()
    local btnList = {
                        'weaponBtn',
                        'subweaponBtn',
                        'armourBtn',
                        'accBtn',
                        'materialBtn'
                    };
    
    local imgList = {
                        'indun_weapon',
                        'indun_shield',
                        'indun_armour',
                        'indun_acc',
                        'indun_material'
                    };
    
    return btnList, imgList;
end

function INDUNENTER_DROPBOX_AFTER_BTN_DOWN(index, classname)
    local frame = ui.GetFrame('indunenter');
    local rewardBox = GET_CHILD_RECURSIVELY(frame, 'rewardBox');
    local weaponBtn = GET_CHILD_RECURSIVELY(rewardBox, 'weaponBtn');
    local materialBtn = GET_CHILD_RECURSIVELY(rewardBox, 'materialBtn');
    local accBtn = GET_CHILD_RECURSIVELY(rewardBox, 'accBtn');
    local armourBtn = GET_CHILD_RECURSIVELY(rewardBox, 'armourBtn');
    local subweaponBtn = GET_CHILD_RECURSIVELY(rewardBox, 'subweaponBtn');
    
    weaponBtn:SetImage("indun_weapon")
    frame:SetUserValue('weaponBtn','NO')
    materialBtn:SetImage("indun_material") 
    frame:SetUserValue('materialBtn','NO')
    accBtn:SetImage("indun_acc")
    frame:SetUserValue('accBtn','NO')
    armourBtn:SetImage("indun_armour")
    frame:SetUserValue('armourBtn','NO')
    subweaponBtn:SetImage("indun_shield")
    frame:SetUserValue('subweaponBtn','NO')
end

function GET_INDUNENTER_DROPBOX_LIST_MOUSE_OVER(index, classname)
    local indunenterFrame = ui.GetFrame("indunenter")
    local itemFrame = ui.GetFrame("wholeitem_link");
    if itemFrame == nil then
        itemFrame = ui.GetNewToolTip("wholeitem_link", "wholeitem_link");
    end
    tolua.cast(itemFrame, 'ui::CTooltipFrame');

    local newobj = CreateIES('Item', classname);
    itemFrame:SetTooltipType('wholeitem');
    newobj = tolua.cast(newobj, 'size_t');
    itemFrame:SetToolTipObject(newobj);

    currentFrame = itemFrame;
    currentFrame:RefreshTooltip();
    currentFrame:ShowWindow(1);
    if indunenterFrame ~= nil then
        itemFrame:SetOffset(indunenterFrame:GetX()+720,indunenterFrame:GetY())
    end
    INDUNENTER_DROPBOX_AFTER_BTN_DOWN(index, classname)
end

function GET_INDUNENTER_DROPBOX_LIST_TOOLTIP_VIEW(index, classname)
    local indunenterFrame = ui.GetFrame("indunenter")
    local itemFrame = ui.GetFrame("wholeitem_link");
    if itemFrame == nil then
        itemFrame = ui.GetNewToolTip("wholeitem_link", "wholeitem_link");
    end
    tolua.cast(itemFrame, 'ui::CTooltipFrame');

    local newobj = CreateIES('Item', classname);
    itemFrame:SetTooltipType('wholeitem');
    newobj = tolua.cast(newobj, 'size_t');
    itemFrame:SetToolTipObject(newobj);

    currentFrame = itemFrame;
    currentFrame:RefreshTooltip();
    currentFrame:ShowWindow(1);

    if indunenterFrame ~= nil then
        itemFrame:SetOffset(indunenterFrame:GetX()+720,indunenterFrame:GetY())
    end
    INDUNENTER_DROPBOX_AFTER_BTN_DOWN(index, classname)
    itemFrame:SetUserValue('MouseClickedCheck','YES')
    
end

function GET_INDUNENTER_DROPBOX_LIST_MOUSE_OUT()
    local indunenterframe = ui.GetFrame('indunenter');
    local itemFrame = ui.GetFrame("wholeitem_link");
    if itemFrame == nil then
        itemFrame = ui.GetNewToolTip("wholeitem_link", "wholeitem_link");
    end
    if itemFrame:GetUserValue('MouseClickedCheck') == 'NO' then
        itemFrame:ShowWindow(0)
    end
    if  itemFrame:GetUserValue('MouseClickedCheck') == 'YES' then
        itemFrame:ShowWindow(1)
        itemFrame:SetUserValue('MouseClickedCheck','NO')
    end
end

function GET_MY_INDUN_MULTIPLE_ITEM_COUNT()
    local count = 0;
    local multipleItemList = GET_INDUN_MULTIPLE_ITEM_LIST();
    for i = 1, #multipleItemList do
        local itemClassName = multipleItemList[i];
        count = count + GET_INVENTORY_ITEM_COUNT_BY_NAME(itemClassName);
    end
    return count;
end

function INDUNENTER_MAKE_MULTI_BOX(frame, indunCls)
    if frame == nil then
        return;
    end
    local multiBox = GET_CHILD_RECURSIVELY(frame, 'multiBox');
    local multiBtn = GET_CHILD_RECURSIVELY(frame, 'multiBtn');
    local arrow = GET_CHILD_RECURSIVELY(frame, 'arrow');
    local indunType = TryGetProp(indunCls, "PlayPerResetType");
    local viewBOX = false;
    
    -- view setting 
    multiBtn:ShowWindow(1);
    multiBtn:SetEnable(1);
    if indunType == 100 or indunType == 200 then
        viewBOX = true;
    end

    local multipleItemCount = GET_MY_INDUN_MULTIPLE_ITEM_COUNT();
    if viewBOX == false or multipleItemCount == 0 then
        multiBtn:SetEnable(0);
        local dungeon_type = TryGetProp(indunCls, "DungeonType", "None"); 
        if dungeon_type ~= "Indun" and dungeon_type ~= "MissionIndun" then
            multiBox:ShowWindow(0);
            arrow:ShowWindow(0);
        else
            multiBox:ShowWindow(1);
            arrow:ShowWindow(1);
        end
        return;
    end

    local multiEdit = GET_CHILD_RECURSIVELY(frame, 'multiEdit');
    local maxMultiCnt = INDUN_MULTIPLE_USE_MAX_COUNT - 1; --frame:GetUserIValue('MAX_MULTI_CNT');
    local multiDefault = frame:GetUserConfig('MULTI_DEFAULT');
    
    multiEdit:SetText(multiDefault);
    multiEdit:SetMaxNumber(maxMultiCnt);
    multiBox:ShowWindow(1);
    arrow:ShowWindow(1);
    
    local multiCancelBtn = GET_CHILD_RECURSIVELY(frame, "multiCancelBtn");
    multiCancelBtn:ShowWindow(0);
end

function INDUNENTER_MAKE_HEADER(frame)
    if frame == nil then return; end
    local header = frame:GetChild('header');
    local bigModeWidth = header:GetOriginalWidth();
    local smallModeWidth = tonumber(frame:GetUserConfig('SMALLMODE_WIDTH'));
    local indunName = header:GetChild('indunName');
    local indunNameTxt = frame:GetUserValue('INDUN_NAME');
    if frame:GetUserValue('FRAME_MODE') == "BIG" then
        header:Resize(bigModeWidth, header:GetHeight());
        indunName:SetText(indunNameTxt);
    else
        header:Resize(smallModeWidth, header:GetHeight());
        indunName:SetText(ClMsg("AutoMatchIng"));
    end
end

function INDUNENTER_MAKE_COUNT_BOX(frame, noPicBox, indunCls)
    if frame == nil or noPicBox == nil or indunCls == nil then return; end
    local countData = GET_CHILD_RECURSIVELY(frame, 'countData');
    local countData2 = GET_CHILD_RECURSIVELY(frame, "countData2");
    local countItemData = GET_CHILD_RECURSIVELY(frame, 'countItemData');
    local cycleCtrlPic = GET_CHILD_RECURSIVELY(frame, 'cycleCtrlPic');
    cycleCtrlPic:ShowWindow(0);

    local etc = GetMyEtcObject();
    if indunCls.UnitPerReset == 'ACCOUNT' then 
        etc = GetMyAccountObj();
    end

    if etc == nil then
        return;
    end

    local admissionItemName = TryGetProp(indunCls, "AdmissionItemName");
    local admissionItemCls = GetClass('Item', admissionItemName);
    local admissionItemIcon = TryGetProp(admissionItemCls, "Icon");
    local admissionPlayAddItemCount = TryGetProp(indunCls, "AdmissionPlayAddItemCount", 0);
    local indunAdmissionItemImage = admissionItemIcon
    local WeeklyEnterableCount = TryGetProp(indunCls, "WeeklyEnterableCount");
    local admissionItemCount = TryGetProp(indunCls, "AdmissionItemCount");
    if admissionItemCount == nil then
        admissionItemCount = 0;
    end
    admissionItemCount = math.floor(admissionItemCount);

    if admissionItemName == "None" or admissionItemName == nil then
        -- now play count
        local resetGroupID = TryGetProp(indunCls, "PlayPerResetType");
        local nowCount = TryGetProp(etc, "InDunCountType_"..tostring(resetGroupID), 0);

        if WeeklyEnterableCount ~= nil and WeeklyEnterableCount ~= "None" and WeeklyEnterableCount ~= 0 then            
            nowCount = GET_CURRENT_ENTERANCE_COUNT(resetGroupID);
        end

        local is_season_challenge = resetGroupID == 904 or resetGroupID == 905 or resetGroupID == 906 or resetGroupID == 907 or resetGroupID == 908;

        local is_use_count2 = is_season_challenge == true or resetGroupID == 817 or resetGroupID == 813 or resetGroupID == 807 or resetGroupID == 5000 or resetGroupID == 832 or resetGroupID == 837 or resetGroupID == 909 or resetGroupID == 910;        
        if is_use_count2 == true then
                nowCount = GET_CURRENT_ENTERANCE_COUNT(resetGroupID); 
            countData2:SetTextByKey("now", nowCount);
            countData:ShowWindow(0);
            countData2:ShowWindow(1);
            countItemData:ShowWindow(0);
        else
        -- add count
        local addCount = math.floor(nowCount * admissionPlayAddItemCount);
        countData:SetTextByKey("now", nowCount);

        -- max play count
        local maxCount = TryGetProp(indunCls, 'PlayPerReset');
        if WeeklyEnterableCount ~= nil and WeeklyEnterableCount ~= "None" and WeeklyEnterableCount ~= 0 then
            maxCount = WeeklyEnterableCount
        end

        if session.loginInfo.IsPremiumState(ITEM_TOKEN) == true then
                maxCount = maxCount + TryGetProp(indunCls, 'PlayPerReset_Token')
        end
            
        local maxText = maxCount
        local infinity = TryGetProp(indunCls, 'EnableInfiniteEnter', 'NO')
        if indunCls.AdmissionItemName ~= "None" or infinity == 'YES' then
            maxText = "{img infinity_text 20 10}"
        end
        
        countData:SetTextByKey("max", maxText);
        -- set min/max multi count
        local minCount = frame:GetUserConfig('MULTI_MIN');
        frame:SetUserValue("MIN_MULTI_CNT", minCount);
        frame:SetUserValue("MAX_MULTI_CNT", maxCount - nowCount);

        local countText = GET_CHILD_RECURSIVELY(frame, 'countText');
            countData:ShowWindow(1);
            countData2:ShowWindow(0);
            countItemData:ShowWindow(0);

            local dungeon_type = TryGetProp(indunCls, 'DungeonType', 'None')
            if string.find(dungeon_type, 'Challenge_') ~= nil then
                countData:ShowWindow(0);
                countData2:ShowWindow(1);
                if nowCount == 0 then
                    nowCount = 1
                else
                    nowCount = 0
                end
                countData2:SetTextByKey("now", nowCount);
            end
        end
    else
        local pc = GetMyPCObject();
        if pc == nil then return; end

        -- now play count
        local nowCount = TryGetProp(etc, "InDunCountType_"..tostring(TryGetProp(indunCls, "PlayPerResetType")), 0)        
        if WeeklyEnterableCount ~= nil and WeeklyEnterableCount ~= "None" and WeeklyEnterableCount ~= 0 then            
            nowCount = GET_CURRENT_ENTERANCE_COUNT(TryGetProp(indunCls, "PlayPerResetType"))
        end

        if indunCls.DungeonType == "Raid" or indunCls.DungeonType =="GTower" then
            if nowCount >= WeeklyEnterableCount then
                local invAdmissionItemCount = GetInvItemCount(pc, admissionItemName)
                countItemData:SetTextByKey("ivnadmissionitem",  '  {img '..indunAdmissionItemImage..' 30 30}  '..invAdmissionItemCount ..'')
    
                local countText = GET_CHILD_RECURSIVELY(frame, 'countText');
                countText:SetText(ScpArgMsg("IndunAdmissionItemPossession"))
                countItemData:ShowWindow(1);
                countData:ShowWindow(0);
                countData2:ShowWindow(0);
    
                if indunCls.DungeonType == 'UniqueRaid' then
                    if IsBuffApplied(pc, "Event_Unique_Raid_Bonus") == "YES"and admissionItemName == "Dungeon_Key01_NoTrade" then
                        cycleCtrlPic:ShowWindow(1);
                    elseif IsBuffApplied(pc, "Event_Unique_Raid_Bonus_Limit") == "YES" and admissionItemName == "Dungeon_Key01_NoTrade" then
                        local accountObject = GetMyAccountObj(pc)
                        if TryGetProp(accountObject, "EVENT_UNIQUE_RAID_BONUS_LIMIT") > 0 then
                            cycleCtrlPic:ShowWindow(1);
                        end
                    end
                end
            else
                local addCount = math.floor(nowCount * admissionPlayAddItemCount);
                countData:SetTextByKey("now", nowCount);

                -- max play count
                local maxCount = TryGetProp(indunCls, 'PlayPerReset');
                if WeeklyEnterableCount ~= nil and WeeklyEnterableCount ~= "None" and WeeklyEnterableCount ~= 0 then
                    maxCount = WeeklyEnterableCount
                end
            
                if session.loginInfo.IsPremiumState(ITEM_TOKEN) == true then
                    maxCount = maxCount + TryGetProp(indunCls, 'PlayPerReset_Token', 0)
                end
                countData:SetTextByKey("max", maxCount);
            
                -- set min/max multi count
                local minCount = frame:GetUserConfig('MULTI_MIN');
                frame:SetUserValue("MIN_MULTI_CNT", minCount);
                frame:SetUserValue("MAX_MULTI_CNT", maxCount - nowCount);
            
                local countText = GET_CHILD_RECURSIVELY(frame, 'countText');
                countData:ShowWindow(1)
                countData2:ShowWindow(0);
                countItemData:ShowWindow(0)
            end
        else
            local invAdmissionItemCount = GetInvItemCount(pc, admissionItemName)
            countItemData:SetTextByKey("ivnadmissionitem",  '  {img '..indunAdmissionItemImage..' 30 30}  '..invAdmissionItemCount ..'')
    
            local countText = GET_CHILD_RECURSIVELY(frame, 'countText');
            countText:SetText(ScpArgMsg("IndunAdmissionItemPossession"))
            countItemData:ShowWindow(1)
            countData:ShowWindow(0)
            countData2:ShowWindow(0);

            local pc = GetMyPCObject()
            if indunCls.DungeonType == 'UniqueRaid' then
                if IsBuffApplied(pc, "Event_Unique_Raid_Bonus") == "YES" and admissionItemName == "Dungeon_Key01_NoTrade"then
                    cycleCtrlPic:ShowWindow(1);
                elseif IsBuffApplied(pc, "Event_Unique_Raid_Bonus_Limit") == "YES" and admissionItemName == "Dungeon_Key01_NoTrade" then
                    local accountObject = GetMyAccountObj(pc)
                    if TryGetProp(accountObject, "EVENT_UNIQUE_RAID_BONUS_LIMIT") > 0 then
                        cycleCtrlPic:ShowWindow(1);
                    end
                end
            end
        end
    end
end

function INDUNENTER_MAKE_LEVEL_BOX(frame, noPicBox, indunCls)
    if frame == nil or frame == noPicBox or indunCls == nil then
        return;
    end
    local lvData = GET_CHILD_RECURSIVELY(noPicBox, 'lvData');
    lvData:SetText(TryGetProp(indunCls, 'Level'));
end

function INDUNENTER_MAKE_PARTY_CONTROLSET(pcCount, memberTable, understaffCount)
    local frame = ui.GetFrame('indunenter');
    local partyLine = GET_CHILD_RECURSIVELY(frame, 'partyLine');
    local memberBox = GET_CHILD_RECURSIVELY(frame, 'memberBox');
    local memberCnt = #memberTable / PC_INFO_COUNT;

    if pcCount < 1 then -- member초기??해주자
        memberCnt = 0;
    end

    local prevPcCnt = frame:GetUserIValue('UI_PC_COUNT');
    frame:SetUserValue('UI_PC_COUNT', pcCount);
    
    if prevPcCnt < pcCount then
        local MEMBER_FINDED_SOUND = frame:GetUserConfig('MEMBER_FINDED_SOUND');
        imcSound.PlaySoundEvent(MEMBER_FINDED_SOUND);
    end
    
    local previousUnderstaffCount = frame:GetUserIValue('UI_UNDERSTAFF_COUNT');
    frame:SetUserValue('UI_UNDERSTAFF_COUNT', understaffCount);
    
    if previousUnderstaffCount < understaffCount then
        local UNDERSTAFF_CHECK_SOUND = frame:GetUserConfig('UNDERSTAFF_CHECK_SOUND');
        imcSound.PlaySoundEvent(UNDERSTAFF_CHECK_SOUND);
    end
    
    if memberCnt > 1 then 
        partyLine:Resize(58 * (memberCnt - 1), 15);
        partyLine:ShowWindow(1);
    else
        partyLine:ShowWindow(0);
    end
    DESTROY_CHILD_BYNAME(memberBox, 'MEMBER_');
    
    local understaffShowCount = 0;
    local maxMatchingCount = GET_MAX_MATCHING_COUNT(frame);
    for i = 1, maxMatchingCount do
        local memberCtrlSet = memberBox:CreateOrGetControlSet('indunMember', 'MEMBER_'..tostring(i), 10 * i + 47 * (i - 1), 0);
        memberCtrlSet:ShowWindow(1);

        -- default setting
        local leaderImg = memberCtrlSet:GetChild('leader_img');
        local levelText = memberCtrlSet:GetChild('level_text');
        local jobIcon = GET_CHILD_RECURSIVELY(memberCtrlSet, 'jobportrait');
        local matchedIcon = GET_CHILD_RECURSIVELY(memberCtrlSet, 'matchedIcon');
        local NO_MATCH_SKIN = frame:GetUserConfig('NO_MATCH_SKIN');
        local understaffAllowImg = memberCtrlSet:GetChild('understaffAllowImg');

        levelText:ShowWindow(0);
        leaderImg:ShowWindow(0);
        jobIcon:SetImage(NO_MATCH_SKIN);
        matchedIcon:ShowWindow(0);
        understaffAllowImg:ShowWindow(0);

        if i <= pcCount then -- 참여????원만큼 보여주는 부??
            if i * PC_INFO_COUNT <= #memberTable then -- ??티??인 경우      
                -- show leader
                local aid = memberTable[i * PC_INFO_COUNT - (PC_INFO_COUNT - 1)];
                local pcparty = session.party.GetPartyInfo(PARTY_NORMAL);
                if pcparty ~= nil and pcparty.info:GetLeaderAID() == aid then
                    leaderImg:ShowWindow(1);
                end

                -- show job icon
                local jobCls = GetClassByType("Job", tonumber(memberTable[i * PC_INFO_COUNT - (PC_INFO_COUNT - 2)]));
                local jobIconData = TryGetProp(jobCls, 'Icon');
                if jobIconData ~= nil then
                    jobIcon:SetImage(jobIconData);
                end

                -- show level
                local lv = memberTable[i * PC_INFO_COUNT - (PC_INFO_COUNT - 3)];
                levelText:SetText(lv);
                levelText:ShowWindow(1);

                -- set tooltip
                local cid = memberTable[i * PC_INFO_COUNT - (PC_INFO_COUNT - 4)];
                PARTY_JOB_TOOLTIP_BY_CID(cid, jobIcon, jobCls);

                -- show understaff
                local understaffAllowMember = memberTable[i * PC_INFO_COUNT - (PC_INFO_COUNT - 5)];
                if understaffAllowMember == 'YES' then
                    understaffAllowImg:ShowWindow(1);
                    understaffShowCount = understaffShowCount + 1;
                end
            else -- ??티???? ??닌??매칭????람
                jobIcon:ShowWindow(0);
                matchedIcon:ShowWindow(1);

                -- show understaff
                if understaffShowCount < understaffCount then
                    understaffAllowImg:ShowWindow(1);
                    understaffShowCount = understaffShowCount + 1;
                end
            end
            
        end
    end
end

function INDUNENTER_MULTI_UP(frame, ctrl)
    if frame == nil or ctrl == nil then
        return;
    end
    local multiEdit = GET_CHILD(frame, 'multiEdit');
    local nowCnt = multiEdit:GetNumber();
    local topFrame = frame:GetTopParentFrame();
    --local maxCnt = topFrame:GetUserIValue('MAX_MULTI_CNT');
    local maxCnt = INDUN_MULTIPLE_USE_MAX_COUNT;
    
    local multipleItemList = GET_INDUN_MULTIPLE_ITEM_LIST();
    for i = 1, #multipleItemList do
        local itemName = multipleItemList[i];
        local invItem = session.GetInvItemByName(itemName);
        if invItem ~= nil and invItem.isLockState then
            ui.SysMsg(ClMsg("MaterialItemIsLock"));
            return;
        end
    end
       
    local itemCount = GET_MY_INDUN_MULTIPLE_ITEM_COUNT();    
    if itemCount == 0 then
        return;
    end

    nowCnt = nowCnt + 1;

    local etc = GetMyEtcObject();
    local indunType = topFrame:GetUserValue('INDUN_TYPE');
    local indunCls = GetClassByType('Indun', indunType);
    if indunCls == nil then
        return;
    end

    local nowCount = TryGetProp(etc, "InDunCountType_"..tostring(TryGetProp(indunCls, "PlayPerResetType")));

    local maxCount = TryGetProp(indunCls, 'PlayPerReset');
    if session.loginInfo.IsPremiumState(ITEM_TOKEN) == true then
		maxCount = maxCount + TryGetProp(indunCls, 'PlayPerReset_Token');
    end

    local remainCount = maxCount - nowCount;

    if nowCnt >= remainCount then
        nowCnt = remainCount - 1;
        ui.SysMsg(ScpArgMsg('NotEnoughIndunEnterCount'));
    elseif nowCnt == maxCnt then
        ui.SysMsg(ScpArgMsg('IndunMultipleMAX'));
        return
    end
    
    if nowCnt - 1 >= itemCount then
        ui.SysMsg(ScpArgMsg('NotEnoughIndunMultipleItem'));
        return;
    end

    if nowCnt < 0 then
        return;
    end

    local rateValue = GET_CHILD_RECURSIVELY(topFrame, "RateValue");
    local imgName = string.format("indun_x%d", nowCnt + 1);
    rateValue:SetImage(imgName);
    multiEdit:SetText(tostring(nowCnt));
end

function INDUNENTER_MULTI_DOWN(frame, ctrl)
    if frame == nil or ctrl == nil then
        return;
    end
    local multiEdit = GET_CHILD(frame, 'multiEdit');
    local nowCnt = multiEdit:GetNumber();
    local topFrame = frame:GetTopParentFrame();
    local minCnt = topFrame:GetUserIValue('MIN_MULTI_CNT');

    nowCnt = nowCnt - 1;
    if nowCnt < minCnt then
        nowCnt = minCnt;
    end

    local rateValue = GET_CHILD_RECURSIVELY(topFrame, "RateValue");
    local imgName = string.format("indun_x%d", nowCnt + 1);
    rateValue:SetImage(imgName);
    multiEdit:SetText(tostring(nowCnt));
end

function INDUNENTER_SMALL(frame, ctrl, forceSmall)
    if frame == nil then
        return;
    end
    local topFrame = frame:GetTopParentFrame();
    local bigmode = topFrame:GetChild('bigmode');
    local smallmode = topFrame:GetChild('smallmode');
    local header = topFrame:GetChild('header');

    if forceSmall == true and topFrame:GetUserValue('FRAME_MODE') == 'SMALL' then
        return;
    end
    
    if topFrame:GetUserValue('FRAME_MODE') == "BIG" then    -- to small mode
        if topFrame:GetUserValue('AUTOMATCH_MODE') == 'NO' then
            ui.SysMsg(ScpArgMsg('EnableWhenAutoMatching'));
            return;
        end
        bigmode:ShowWindow(0);
        smallmode:ShowWindow(1);
        topFrame:SetUserValue('FRAME_MODE', 'SMALL');
        topFrame:Resize(smallmode:GetWidth(), smallmode:GetHeight());
    else                                            -- to big mode
        bigmode:ShowWindow(1);
        smallmode:ShowWindow(0);
        topFrame:SetUserValue('FRAME_MODE', 'BIG');
        topFrame:Resize(bigmode:GetWidth(), bigmode:GetHeight());

        INDUNENTER_AMEND_OFFSET(topFrame);
    end
    INDUNENTER_MAKE_HEADER(topFrame);

    frame:ShowWindow(1);
end

function INDUNENTER_ENTER(frame, ctrl)    
    local topFrame = frame:GetTopParentFrame();
    local useCount = tonumber(topFrame:GetUserValue("multipleCount"));
    local indunType = topFrame:GetUserValue('INDUN_TYPE');
    local indunCls = GetClassByType('Indun', indunType);
    local indunMinPCRank = TryGetProp(indunCls, 'PCRank')
    local totaljobcount = session.GetPcTotalJobGrade()
    
    if indunMinPCRank ~= nil then
        if indunMinPCRank > totaljobcount and indunMinPCRank ~= totaljobcount then
            ui.SysMsg(ScpArgMsg('IndunEnterNeedPCRank', 'NEED_RANK', indunMinPCRank))
            return;
        end
    end
   
    if useCount > 0 then
        local multipleItemList = GET_INDUN_MULTIPLE_ITEM_LIST();
        for i = 1, #multipleItemList do
        local itemName = multipleItemList[i];
            local invItem = session.GetInvItemByName(itemName);
            if invItem ~= nil and invItem.isLockState then
                ui.SysMsg(ClMsg("MaterialItemIsLock"));
            return;
        end        
    end
    end
    
    local topFrame = frame:GetTopParentFrame();
    if INDUNENTER_CHECK_ADMISSION_ITEM(topFrame, 1) == false then
        return;
    end

    local playerCnt = TryGetProp(indunCls, 'PlayerCnt');
    local party = session.party.GetPartyMemberList(PARTY_NORMAL);
    local cnt = party:Count();
    if cnt > playerCnt then
        ui.SysMsg(ClMsg("OverIndunMaxPC"));
        return;
    end

    local textCount = topFrame:GetUserIValue("multipleCount");
    local yesScript = string.format("ReqMoveToIndun(%d,%d)", 1, textCount);
    ui.MsgBox(ScpArgMsg("EnterRightNow"), yesScript, "None");
end

function INDUNENTER_AUTOMATCH(frame, ctrl)
    local topFrame = frame:GetTopParentFrame();
    local useCount = tonumber(topFrame:GetUserValue("multipleCount"));
    local indunType = topFrame:GetUserValue('INDUN_TYPE');
    local indunCls = GetClassByType('Indun', indunType);
    local indunMinPCRank = TryGetProp(indunCls, 'PCRank')
    local totaljobcount = session.GetPcTotalJobGrade()

    if indunMinPCRank ~= nil then
        if indunMinPCRank > totaljobcount and indunMinPCRank ~= totaljobcount then
            ui.SysMsg(ScpArgMsg('IndunEnterNeedPCRank', 'NEED_RANK', indunMinPCRank))
            return;
        end
    end
    
    if useCount > 0 then
        local multipleItemList = GET_INDUN_MULTIPLE_ITEM_LIST();
        for i = 1, #multipleItemList do
            local itemName = multipleItemList[i];
            local invItem = session.GetInvItemByName(itemName);
            if invItem ~= nil and invItem.isLockState then
                ui.SysMsg(ClMsg("MaterialItemIsLock"));
            return;
        end        
    end
    end
    
    local textCount = topFrame:GetUserIValue("multipleCount");
    if topFrame:GetUserValue('AUTOMATCH_MODE') == 'NO' then
        if INDUNENTER_CHECK_ADMISSION_ITEM(topFrame, 2) == false then
            return;
        end
        ReqMoveToIndun(2, textCount);
    else
        INDUNENTER_AUTOMATCH_CANCEL();
    end
end

function INDUNENTER_PARTYMATCH(frame, ctrl)        
    local topFrame = frame:GetTopParentFrame();
    local useCount = tonumber(topFrame:GetUserValue("multipleCount"));
    local indunType = topFrame:GetUserValue('INDUN_TYPE');
    local indunCls = GetClassByType('Indun', indunType);
    local indunMinPCRank = TryGetProp(indunCls, 'PCRank')
    local totaljobcount = session.GetPcTotalJobGrade()
    
    if indunMinPCRank ~= nil then
        if indunMinPCRank > totaljobcount and indunMinPCRank ~= totaljobcount then
            ui.SysMsg(ScpArgMsg('IndunEnterNeedPCRank', 'NEED_RANK', indunMinPCRank))
            return;
        end
    end
    
    if useCount > 0 then
        local multipleItemList = GET_INDUN_MULTIPLE_ITEM_LIST();
        for i = 1, #multipleItemList do
            local itemName = multipleItemList[i];
            local invItem = session.GetInvItemByName(itemName);
            if invItem ~= nil and invItem.isLockState then
                ui.SysMsg(ClMsg("MaterialItemIsLock"));
            return;
        end        
    end
    end
    
    if session.party.GetPartyInfo(PARTY_NORMAL) == nil then 
        ui.SysMsg(ClMsg('HadNotMyParty'));
        return;
    end

    local topFrame = frame:GetTopParentFrame();
    if INDUNENTER_CHECK_ADMISSION_ITEM(topFrame) == false then
        return;
    end

    local textCount = topFrame:GetUserIValue("multipleCount");
    local partyAskText = GET_CHILD_RECURSIVELY(topFrame, "partyAskText");
    local understaffEnterAllowBtn = GET_CHILD_RECURSIVELY(topFrame, 'understaffEnterAllowBtn');
    
    local enableReenter = frame:GetUserIValue('ENABLE_REENTER');

    if topFrame:GetUserValue('WITHMATCH_MODE') == 'NO' then
        ReqMoveToIndun(3, textCount);        
        ctrl:SetTextTooltip(ClMsg("PartyMatchInfo_Go"));
        if enableReenter == true then
            understaffEnterAllowBtn:ShowWindow(1);
        else
            understaffEnterAllowBtn:ShowWindow(0);
        end
        INDUNENTER_SET_ENABLE(0, 0, 1, 0);
    else
        ReqRegisterToIndun(topFrame:GetUserIValue('INDUN_TYPE'));
        ctrl:SetTextTooltip(ClMsg("PartyMatchInfo_Req"));
        INDUNENTER_SET_ENABLE(0, 1, 0, 0);
    end
end

function INDUNENTER_PARTYMATCH_CANCEL()
    local frame = ui.GetFrame('indunenter');
    local indunType = frame:GetUserIValue("INDUN_TYPE");
    local indunCls = GetClassByType('Indun', indunType);
    if frame ~= nil and indunCls ~= nil then
        packet.SendCancelIndunPartyMatching();
    end
    local withTime = GET_CHILD_RECURSIVELY(frame, 'withTime');
    withTime:SetText(ClMsg('MatchWithParty'));
end

function INDUNENTER_SET_WAIT_PC_COUNT(pcCount)
    local frame = ui.GetFrame('indunenter');
    if frame == nil or frame:IsVisible() ~= 1 then
        return;
    end
    local memberCntText = GET_CHILD_RECURSIVELY(frame, 'memberCntText');
    memberCntText:SetTextByKey('cnt', pcCount..ClMsg('PersonCountUnit'));
end

function INDUNENTER_SET_MEMBERCNTBOX()
    local frame = ui.GetFrame('indunenter');
    local memberCntBox = GET_CHILD_RECURSIVELY(frame, 'memberCntBox');
    local memberCntText = GET_CHILD_RECURSIVELY(frame, 'memberCntText');
    local partyAskText = GET_CHILD_RECURSIVELY(frame, 'partyAskText');
    
    if frame:GetUserValue('WITHMATCH_MODE') == 'YES' then
        memberCntText:ShowWindow(0);
        partyAskText:ShowWindow(1);
    elseif frame:GetUserValue('AUTOMATCH_MODE') == 'YES' then
        memberCntText:ShowWindow(1);
        partyAskText:ShowWindow(0);
    else
        memberCntBox:ShowWindow(0);
        return;
    end
    memberCntBox:ShowWindow(1);
end

function INDUNENTER_AUTOMATCH_TYPE(indunType, needUnderstaffAllow)    
    if needUnderstaffAllow == nil then
        needUnderstaffAllow = 1;
    end
    local frame = ui.GetFrame("indunenter");
    local memberCntBox = GET_CHILD_RECURSIVELY(frame, 'memberCntBox');
    local autoMatchText = GET_CHILD_RECURSIVELY(frame, 'autoMatchText');
    local autoMatchTime = GET_CHILD_RECURSIVELY(frame, 'autoMatchTime');
    local withBtn = GET_CHILD_RECURSIVELY(frame, 'withBtn');
    local smallBtn = GET_CHILD_RECURSIVELY(frame, 'smallBtn');
    local smallmode = GET_CHILD_RECURSIVELY(frame, 'smallmode');
    local cancelAutoMatch = GET_CHILD_RECURSIVELY(frame, 'cancelAutoMatch');
    local understaffEnterAllowBtn = GET_CHILD_RECURSIVELY(frame, 'understaffEnterAllowBtn');

    if indunType == 0 then
        frame:SetUserValue('AUTOMATCH_MODE', 'NO');
        frame:SetUserValue('EXCEPT_CLOSE_TARGET', 'NO');
        autoMatchText:ShowWindow(1);
        autoMatchTime:ShowWindow(0);

        INDUNENTER_SET_ENABLE(1, 1, 1, 1);
        INDUNENTER_INIT_MEMBERBOX(frame);
        INDUNENTER_INIT_REENTER_UNDERSTAFF_BUTTON(frame);

        if frame:GetUserValue('FRAME_MODE') == "SMALL" then
            INDUNENTER_SMALL(frame, smallBtn);
        end        
    elseif frame:GetUserValue('AUTOMATCH_MODE') ~= 'YES' then
        local indunCls = GetClassByType('Indun', indunType)        
        if indunCls ~= nil then
            if TryGetProp(indunCls, 'EnableUnderStaffEnter', 'None') ~= 'YES' then
                needUnderstaffAllow = 0;
            end
        end        

        frame:SetUserValue('AUTOMATCH_MODE', 'YES');
        frame:SetUserValue('EXCEPT_CLOSE_TARGET', 'YES');
        autoMatchText:ShowWindow(0);
        cancelAutoMatch:SetEnable(1);
        understaffEnterAllowBtn:ShowWindow(1);

        INDUNENTER_UNDERSTAFF_BTN_ENABLE(frame, needUnderstaffAllow);
        INDUNENTER_AUTOMATCH_TIMER_START(frame);
        INDUNENTER_SET_ENABLE(0, 1, 0, 0);
        INDUNENTER_MAKE_SMALLMODE(frame, false);
    end
    
    INDUNENTER_SET_MEMBERCNTBOX();
end

function INDUNENTER_AUTOMATCH_TIMER_START(frame)
    local autoMatchTime = GET_CHILD_RECURSIVELY(frame, 'autoMatchTime');
    autoMatchTime:ShowWindow(1);

    frame:SetUserValue("START_TIME", os.time());
    frame:RunUpdateScript("_INDUNENTER_AUTOMATCH_UPDATE_TIME", 0.5);
    _INDUNENTER_AUTOMATCH_UPDATE_TIME(frame);
end

function _INDUNENTER_AUTOMATCH_UPDATE_TIME(frame)
    local elaspedSec = os.time() - frame:GetUserIValue("START_TIME");
    local minute = math.floor(elaspedSec / 60);
    local second = elaspedSec % 60;
    local txt = string.format("%02d:%02d", minute, second);

    local autoMatchTime = GET_CHILD_RECURSIVELY(frame, 'autoMatchTime');
    local smallMatchTime = GET_CHILD_RECURSIVELY(frame, 'matchTime');
    autoMatchTime:SetText(txt);
    smallMatchTime:SetText(txt);

    if frame:GetUserValue('AUTOMATCH_MODE') == 'NO' or frame:GetUserValue('AUTOMATCH_FIND') == 'YES' then
        autoMatchTime:ShowWindow(0);
        return 0;
    end

    return 1;
end

function INDUNENTER_SMALLMODE_CANCEL(frame, ctrl)
    INDUNENTER_SMALLMODE_CLOSE();
end

function INDUNENTER_AUTOMATCH_PARTY(numWaiting, level, limit, indunLv, indunName, elapsedTime)
    local frame = ui.GetFrame("indunenter");
    local withText = GET_CHILD_RECURSIVELY(frame, 'withText');
    local withTime = GET_CHILD_RECURSIVELY(frame, 'withTime');
    local memberCntBox = GET_CHILD_RECURSIVELY(frame, 'memberCntBox');
    local partyAskText = GET_CHILD_RECURSIVELY(frame, 'partyAskText');
    
    if numWaiting == 0 then -- party match cancel
        frame:SetUserValue('WITHMATCH_MODE', 'NO');
        withText:ShowWindow(1);
        withTime:ShowWindow(0);
    else                    -- party match start
        -- level info
        local lowerBound = level - limit;
        local upperBound = level + limit;
        if lowerBound < indunLv then
            lowerBound = indunLv;
        end
        if upperBound > PC_MAX_LEVEL then
            upperBound = PC_MAX_LEVEL;
        end 
        partyAskText:SetTextByKey("value", ScpArgMsg("MatchWithParty").."(Lv."..tostring(lowerBound)..'~'..tostring(upperBound)..")");  

        -- frame info
        frame:SetUserValue('WITHMATCH_MODE', 'YES');
        withText:ShowWindow(0);
        withTime:ShowWindow(1);
        INDUNENTER_SET_ENABLE(0, 0, 1, 0);
        INDUNENTER_UNDERSTAFF_BTN_ENABLE(frame, 1);
    end

    INDUNENTER_SET_MEMBERCNTBOX();
end

function INDUNENTER_SET_ENABLE_MULTI(enable)
    local frame = ui.GetFrame('indunenter');
    local multiBtn = GET_CHILD_RECURSIVELY(frame, 'multiBtn');
    local multiCancelBtn = GET_CHILD_RECURSIVELY(frame, 'multiCancelBtn');
    local upBtn = GET_CHILD_RECURSIVELY(frame, 'upBtn');
    local downBtn = GET_CHILD_RECURSIVELY(frame, 'downBtn');
    
    multiBtn:SetEnable(enable);
    multiCancelBtn:SetEnable(enable);
    upBtn:SetEnable(enable);
    downBtn:SetEnable(enable);
end

function INDUNENTER_SET_ENABLE(enter, autoMatch, withParty, multi)
    local frame = ui.GetFrame('indunenter');
    local enterBtn = GET_CHILD_RECURSIVELY(frame, 'enterBtn');
local autoMatchBtn = GET_CHILD_RECURSIVELY(frame, 'autoMatchBtn');
    local withPartyBtn = GET_CHILD_RECURSIVELY(frame, 'withBtn');
    local multiBtn = GET_CHILD_RECURSIVELY(frame, 'multiBtn');
    local multiCancelBtn = GET_CHILD_RECURSIVELY(frame, 'multiCancelBtn');
    local reEnterBtn = GET_CHILD_RECURSIVELY(frame, 'reEnterBtn');
    
    if frame:GetUserIValue('ENABLE_ENTERRIGHT') == 0 and enter == 1 then
        enter = 0;
    end
    if frame:GetUserIValue('ENABLE_AUTOMATCH') == 0 and autoMatch == 1 then
        autoMatch = 0;
    end
    if frame:GetUserIValue('ENABLE_PARTYMATCH') == 0 and withParty == 1 then
        withParty = 0;
    end

    enterBtn:SetEnable(enter);
    autoMatchBtn:SetEnable(autoMatch);
    _INDUNENTER_SET_ENABLE_PARTYMATCHBTN(frame, withParty);
    INDUNENTER_SET_ENABLE_MULTI(multi);

    -- multi btn: 배수?�큰 ?�어???�용 가?? ?�던/?�뢰??미션�??�용가??
    local indunCls = GetClassByType('Indun', frame:GetUserIValue('INDUN_TYPE'));
    local resetType = TryGetProp(indunCls, 'PlayPerResetType');
    local itemCount = GET_INDUN_MULTIPLE_ITEM_LIST();
    if itemCount == 0 or (resetType ~= 100 and resetType ~= 200) then
        INDUNENTER_SET_ENABLE_MULTI(0);
    end
end

function _INDUNENTER_SET_ENABLE_PARTYMATCHBTN(frame, enable)
    local withPartyBtn = GET_CHILD_RECURSIVELY(frame, 'withBtn');
    local withText = GET_CHILD_RECURSIVELY(frame, 'withText');
    withPartyBtn:SetEnable(enable);
    withText:SetEnable(enable);
end

function INDUNENTER_UPDATE_PC_COUNT(frame, msg, infoStr, pcCount, understaffCount) -- infoStr: aid/jobID/level/CID/understaffAllow(YES/NO)
    if frame == nil then
        return;
    end
    if understaffCount == nil then
        understaffCount = 0;
    end
    
    -- update pc count
    if infoStr == nil then
        infoStr = "None";
    end

    local memberInfo = frame:GetUserValue('MEMBER_INFO');
    if infoStr ~= "None" then -- update party member info
        memberInfo = infoStr;
        frame:SetUserValue('MEMBER_INFO', memberInfo);
    end

    local memberTable = StringSplit(memberInfo, '/');
    INDUNENTER_MAKE_PARTY_CONTROLSET(pcCount, memberTable, understaffCount);
    INDUNENTER_UPDATE_SMALLMODE_PC(pcCount, understaffCount);
end

function GET_MAX_MATCHING_COUNT(frame)
    local maxMatchingCount = INDUN_AUTOMATCHING_PCCOUNT;
    local indunCls = GetClassByType('Indun', frame:GetUserIValue('INDUN_TYPE'));
    if indunCls == nil then
        return 0;
    end
    if maxMatchingCount ~= indunCls.PlayerCnt then
        maxMatchingCount = indunCls.PlayerCnt;
    end
    return maxMatchingCount;
end

function INDUNENTER_UPDATE_SMALLMODE_PC(pcCount, understaffCount)
    local frame = ui.GetFrame("indunenter");
    local YES_MATCH_SKIN = frame:GetUserConfig('YES_MATCH_SKIN');

    local matchPCBox = GET_CHILD_RECURSIVELY(frame, 'matchPCBox');
    matchPCBox:RemoveAllChild();
    local notWaitingCount = GET_MAX_MATCHING_COUNT(frame) - pcCount;
    local pictureIndex = 0;
    local understaffShowCount = 0;
    for i = 0 , pcCount - 1 do
        local ctrlset = matchPCBox:CreateOrGetControlSet("smallIndunMember", "MAN_PICTURE_" .. pictureIndex, 0, 0);
        ctrlset:SetGravity(ui.LEFT, ui.CENTER_VERT);
        local pic = ctrlset:GetChild('pcImg');
        local understaffAllowPic = ctrlset:GetChild('understaffAllowImg');
        AUTO_CAST(pic);
        pic:SetEnableStretch(1);
        pic:SetImage(YES_MATCH_SKIN);
        if understaffShowCount < understaffCount then
            understaffAllowPic:ShowWindow(1);
            understaffShowCount = understaffShowCount + 1;
        else
            understaffAllowPic:ShowWindow(0);
        end
        pictureIndex = pictureIndex + 1;
    end

    for i = 0 , notWaitingCount - 1 do
        local ctrlset = matchPCBox:CreateOrGetControlSet("smallIndunMember", "MAN_PICTURE_" .. pictureIndex, 0, 0);
        ctrlset:SetGravity(ui.LEFT, ui.CENTER_VERT);
        local pic = ctrlset:GetChild('pcImg');
        local understaffAllowPic = ctrlset:GetChild('understaffAllowImg');
        AUTO_CAST(pic);
        pic:SetEnableStretch(1);
        pic:SetColorTone("FF222222");
        pic:SetImage(YES_MATCH_SKIN);
        understaffAllowPic:ShowWindow(0);
        pictureIndex = pictureIndex + 1;
    end
    
    GBOX_AUTO_ALIGN_HORZ(matchPCBox, 0, 0, 0, true, true);
end

function INDUNENTER_MAKE_SMALLMODE(frame, isSuccess)
    local matchSuccBox = GET_CHILD_RECURSIVELY(frame, 'matchSuccBox');
    local autoMatchBox = GET_CHILD_RECURSIVELY(frame, 'autoMatchBox');

    if isSuccess == false then
        matchSuccBox:ShowWindow(0);
        autoMatchBox:ShowWindow(1);
    else
        matchSuccBox:ShowWindow(1);
        autoMatchBox:ShowWindow(0);
    end     
end

function INDUNENTER_AUTOMATCH_FINDED()
    local frame = ui.GetFrame('indunenter');
    local cancelAutoMatch = GET_CHILD_RECURSIVELY(frame, 'cancelAutoMatch');
    local autoMatchText = GET_CHILD_RECURSIVELY(frame, 'autoMatchText');
    local autoMatchTime = GET_CHILD_RECURSIVELY(frame, 'autoMatchTime');
    local indunName = GET_CHILD_RECURSIVELY(frame, 'indunName');

    cancelAutoMatch:SetEnable(0);
    indunName:SetText(ClMsg('AutoMatchComplete'));
    frame:SetUserValue('AUTOMATCH_FIND', 'YES');
    autoMatchText:SetText(ClMsg('PILGRIM41_1_SQ07_WATER'));
    autoMatchTime:ShowWindow(0);
    autoMatchText:ShowWindow(1);

    -- play matching sound
    local MATCH_FINDED_SOUND = frame:GetUserConfig('MATCH_FINDED_SOUND');
    imcSound.PlaySoundEvent(MATCH_FINDED_SOUND);

    app.SetWindowTopMost();

    INDUNENTER_SET_ENABLE(0, 0, 0, 0);
    INDUNENTER_MAKE_SMALLMODE(frame, true);
    INDUNENTER_AUTOMATCH_FIND_TIMER_START(frame);
end

function INDUNENTER_AUTOMATCH_FIND_TIMER_START(frame)
    local gaugeBar = GET_CHILD_RECURSIVELY(frame, 'gaugeBar');
    gaugeBar:SetPoint(5, 5);

    frame:SetUserValue("START_TIME", os.time());
    frame:RunUpdateScript("_INDUNENTER_AUTOMATCH_FIND_UPDATE_TIME", 0.1);
    _INDUNENTER_AUTOMATCH_FIND_UPDATE_TIME(frame);
end

function _INDUNENTER_AUTOMATCH_FIND_UPDATE_TIME(frame)
    local elapsedSec = os.time() - frame:GetUserIValue("START_TIME");
    local gaugeBar = GET_CHILD_RECURSIVELY(frame, 'gaugeBar');
    gaugeBar:SetPointWithTime(0, 5 - elapsedSec);
    return 1;   
end

function INDUNENTER_AUTOMATCH_PARTY_SET_COUNT(memberCnt, memberInfo, understaffCount)
    local frame = ui.GetFrame('indunenter');
    INDUNENTER_UPDATE_PC_COUNT(frame, nil, memberInfo, memberCnt, understaffCount);
end

function INDUNENTER_REENTER(frame, ctrl)
    local topFrame = frame:GetTopParentFrame();
    local textCount = topFrame:GetUserIValue("multipleCount");
    local indunType = topFrame:GetUserValue('INDUN_TYPE');
    local indunCls = GetClassByType('Indun', indunType);
    local indunMinPCRank = TryGetProp(indunCls, 'PCRank')
    local totaljobcount = session.GetPcTotalJobGrade()
    
    if indunMinPCRank ~= nil then
        if indunMinPCRank > totaljobcount and indunMinPCRank ~= totaljobcount then
            ui.SysMsg(ScpArgMsg('IndunEnterNeedPCRank', 'NEED_RANK', indunMinPCRank))
            return;
        end
    end
    
    if textCount > 0 then
        local yesscp = string.format('ReqMoveToIndun(4, %d)', textCount);
        ui.MsgBox(ClMsg('ReenterMultipleNotAllowed'), yesscp, 'None');
        return;
    end
    ReqMoveToIndun(4, textCount);
end

function INDUNENTER_MON_CLICK_RIGHT(parent, ctrl)
    local topFrame = parent:GetTopParentFrame();
    local monSlotCnt = topFrame:GetUserIValue('MON_SLOT_CNT');
    if monSlotCnt < 6 then
        return;
    end

    local monSlotSet = GET_CHILD_RECURSIVELY(topFrame, 'monSlotSet');
    local currentSlot = monSlotSet:GetUserIValue('CURRENT_SLOT');
    if currentSlot + 4 == monSlotCnt then
        return;
    end
            
    UI_PLAYFORCE(monSlotSet, "slotsetLeftMove_1");
    monSlotSet:SetUserValue('CURRENT_SLOT', currentSlot + 1);

    -- button enable
    if currentSlot + 5 == monSlotCnt then
       ctrl:SetEnable(0);
    end
    local leftBtn = GET_CHILD_RECURSIVELY(topFrame, 'monLeftBtn');
    leftBtn:SetEnable(1);
end

function INDUNENTER_MON_CLICK_LEFT(parent, ctrl)
    local topFrame = parent:GetTopParentFrame();
    local monSlotCnt = topFrame:GetUserIValue('MON_SLOT_CNT');
    if monSlotCnt < 6 then
        return;
    end

    local monSlotSet = GET_CHILD_RECURSIVELY(topFrame, 'monSlotSet');
    local currentSlot = monSlotSet:GetUserIValue('CURRENT_SLOT');
    if currentSlot == 1 then
        return;
    end
        
    UI_PLAYFORCE(monSlotSet, "slotsetRightMove_1");
    monSlotSet:SetUserValue('CURRENT_SLOT', currentSlot - 1);

     -- button enable
    if currentSlot - 1 == 1 then
       ctrl:SetEnable(0);
    end
    local rightBtn = GET_CHILD_RECURSIVELY(topFrame, 'monRightBtn');
    rightBtn:SetEnable(1);
end

function INDUNENTER_PATTERN_CLICK_RIGHT(parent,ctrl)
    local topFrame = parent:GetTopParentFrame();

    local patternSlotSet = GET_CHILD_RECURSIVELY(topFrame, 'patternSlotSet');
	local currentSlot = patternSlotSet:GetUserIValue('CURRENT_SLOT');
	local slotCnt = patternSlotSet:GetUserIValue('MAX_SLOT');
    if currentSlot + 4 >= slotCnt then
        return;
    end
            
	UI_PLAYFORCE(patternSlotSet, "slotsetLeftMove_1");
    patternSlotSet:SetUserValue('CURRENT_SLOT', currentSlot + 1);

    -- button enable
    if currentSlot + 5 >= slotCnt then
       ctrl:SetEnable(0);
    end
    local leftBtn = GET_CHILD_RECURSIVELY(topFrame, 'patternLeftBtn');
    leftBtn:SetEnable(1);
end

function INDUNENTER_PATTERN_CLICK_LEFT(parent,ctrl)
    local topFrame = parent:GetTopParentFrame();

    local patternSlotSet = GET_CHILD_RECURSIVELY(topFrame, 'patternSlotSet');
    local currentSlot = patternSlotSet:GetUserIValue('CURRENT_SLOT');
    if currentSlot == 1 then
        return
    end
        
    UI_PLAYFORCE(patternSlotSet, "slotsetRightMove_1");
    patternSlotSet:SetUserValue('CURRENT_SLOT', currentSlot - 1);

     -- button enable
    if currentSlot - 1 == 1 then
       ctrl:SetEnable(0);
    end
    local rightBtn = GET_CHILD_RECURSIVELY(topFrame, 'patternRightBtn');
    rightBtn:SetEnable(1);
end

function INDUNENTER_REWARD_CLICK_RIGHT(parent, ctrl)
    local topFrame = parent:GetTopParentFrame();
    local rewardSlotCnt = topFrame:GetUserIValue('REWARD_SLOT_CNT');
    if rewardSlotCnt < 6 then
        return;
    end

    local rewardSlotSet = GET_CHILD_RECURSIVELY(topFrame, 'rewardSlotSet');
    local currentSlot = rewardSlotSet:GetUserIValue('CURRENT_SLOT');
    if currentSlot + 4 == rewardSlotCnt then
        return;
    end
        
    UI_PLAYFORCE(rewardSlotSet, "slotsetLeftMove_1");
    rewardSlotSet:SetUserValue('CURRENT_SLOT', currentSlot + 1);

    -- button enable
    if currentSlot + 5 == rewardSlotCnt then
       ctrl:SetEnable(0);
    end
    local leftBtn = GET_CHILD_RECURSIVELY(topFrame, 'rewardLeftBtn');
    leftBtn:SetEnable(1);   
end

function INDUNENTER_REWARD_CLICK_LEFT(parent, ctrl)    
    local topFrame = parent:GetTopParentFrame();
    local rewardSlotCnt = topFrame:GetUserIValue('REWARD_SLOT_CNT');   
    if rewardSlotCnt < 6 then
        return;
    end

    local rewardSlotSet = GET_CHILD_RECURSIVELY(topFrame, 'rewardSlotSet');
    local currentSlot = rewardSlotSet:GetUserIValue('CURRENT_SLOT');
    if currentSlot == 1 then
        return;
    end
        
    UI_PLAYFORCE(rewardSlotSet, "slotsetRightMove_1");
    rewardSlotSet:SetUserValue('CURRENT_SLOT', currentSlot - 1);

    -- button enable
    if currentSlot - 1 == 1 then
       ctrl:SetEnable(0);
    end
    local rightBtn = GET_CHILD_RECURSIVELY(topFrame, 'rewardRightBtn');
    rightBtn:SetEnable(1);
end

function INDUNENTER_MULTI_EXEC(frame, ctrl)    
    local multipleItemList = GET_INDUN_MULTIPLE_ITEM_LIST();
    for i = 1, #multipleItemList do
        local itemName = multipleItemList[i];
        local invItem = session.GetInvItemByName(itemName);
        if invItem ~= nil and invItem.isLockState then
            ui.SysMsg(ClMsg("MaterialItemIsLock"));
            return;
        end
    end
    
    local indunenterFrame = ui.GetFrame('indunenter');
    local indunType = indunenterFrame:GetUserValue('INDUN_TYPE');

    local multiEdit = GET_CHILD_RECURSIVELY(frame, 'multiEdit');
    local textCount = multiEdit:GetNumber();

    if textCount == 0 then
        return;
    end

    if textCount >= INDUN_MULTIPLE_USE_MAX_COUNT then
        multiEdit:SetText(tostring(0));
        return;
    end

    if tonumber(textCount) > 1 then
        if is_invalid_indun_multiple_item() == true then
            ui.SysMsg(ClMsg("IndunMultipleItemError"))
            return
        end
    end

    local indunCls = GetClassByType('Indun', indunType);
    if indunCls == nil then
        return;
    end

    local etc = GetMyEtcObject();

    local nowCount = TryGetProp(etc, "InDunCountType_"..tostring(TryGetProp(indunCls, "PlayPerResetType")));
    --
    local maxCount = TryGetProp(indunCls, 'PlayPerReset');
    if session.loginInfo.IsPremiumState(ITEM_TOKEN) == true then
		maxCount = maxCount + TryGetProp(indunCls, 'PlayPerReset_Token');
    end
    
    local remainCount = maxCount - nowCount;    
    if textCount >= remainCount then
        ui.SysMsg(ScpArgMsg('NotEnoughIndunEnterCount'));
        return;
    end

    local itemCount = GET_MY_INDUN_MULTIPLE_ITEM_COUNT();    
    if itemCount < textCount then
        ui.SysMsg(ScpArgMsg('NotEnoughIndunMultipleItem'));
        return;
    end

    local topFrame = frame:GetTopParentFrame();
    topFrame:SetUserValue("multipleCount", textCount);

    local multiCancelBtn = GET_CHILD_RECURSIVELY(frame, "multiCancelBtn");
    multiCancelBtn:ShowWindow(1);
    local multiBtn = GET_CHILD_RECURSIVELY(frame, "multiBtn");
    multiBtn:ShowWindow(0);
end

function INDUN_MULTIPLE_CHECK_NUMBER(frame)    
    local multipleItemList = GET_INDUN_MULTIPLE_ITEM_LIST();
    for i = 1, #multipleItemList do
        local itemName = multipleItemList[i];
        local invItem = session.GetInvItemByName(itemName);
        if invItem ~= nil and invItem.isLockState then
            ui.SysMsg(ClMsg("MaterialItemIsLock"));
            return;
        end
    end

    local multiEdit = GET_CHILD_RECURSIVELY(frame, 'multiEdit');
    local textCount = multiEdit:GetNumber();
    if textCount >= INDUN_MULTIPLE_USE_MAX_COUNT then
        multiEdit:SetText(tostring(0));
        return;
    end
    local topFrame = frame:GetTopParentFrame(); 

    local rateValue = GET_CHILD_RECURSIVELY(topFrame, "RateValue");
    local imgName = string.format("indun_x%d", textCount + 1);
    rateValue:SetImage(imgName);
end

function INDUNENTER_MULTI_CANCEL(frame, ctrl)
    local topFrame = frame:GetTopParentFrame(); 
    local multiEdit = GET_CHILD_RECURSIVELY(topFrame, 'multiEdit');
    multiEdit:SetText(tostring(0));

    local rateValue = GET_CHILD_RECURSIVELY(topFrame, "RateValue");
    rateValue:SetImage("indun_x1");

    topFrame:SetUserValue("multipleCount", 0);

    local multiCancelBtn = GET_CHILD_RECURSIVELY(topFrame, "multiCancelBtn");
    multiCancelBtn:ShowWindow(0);
    local multiBtn = GET_CHILD_RECURSIVELY(topFrame, "multiBtn");
    multiBtn:ShowWindow(1);
end

function GET_INVENTORY_ITEM_COUNT_BY_NAME(name)
    if name == nil or name == "" then
        return 0;
    end

    local invItemList = session.GetInvItemList();
    local count = GET_INV_ITEM_COUNT_BY_PROPERTY({
        {Name = 'ClassName', Value = name}
    }, false, invItemList);
    return count;
end

function INDUNENTER_AMEND_OFFSET(frame)
    local left = frame:GetX();
    local top = frame:GetY();
    if left < 0 then
        left = 0;
    end
    if top < 0 then
        top = 0;
    end
        
    local rightDiff = left + frame:GetWidth() - option.GetClientWidth();
    local bottomDiff = top + frame:GetHeight() - option.GetClientHeight();
    if rightDiff > 0 then
        left = left - rightDiff;
    end
    if bottomDiff > 0 then
        top = top - bottomDiff;
    end

    frame:SetOffset(left, top); 
end

function INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW(parent, ctrl)
    local topFrame = parent:GetTopParentFrame();
    local useCount = tonumber(topFrame:GetUserValue("multipleCount"));
    if useCount > 0 then
        local multipleItemList = GET_INDUN_MULTIPLE_ITEM_LIST();
        for i = 1, #multipleItemList do
            local itemName = multipleItemList[i];
            local invItem = session.GetInvItemByName(itemName);
            if invItem ~= nil and invItem.isLockState then
                ui.SysMsg(ClMsg("MaterialItemIsLock"));
            return;
        end        
    end
    end

    local withMatchMode = topFrame:GetUserValue('WITHMATCH_MODE');
    if topFrame:GetUserValue('AUTOMATCH_MODE') ~= 'YES' and withMatchMode == 'NO' then
        ui.SysMsg(ScpArgMsg('EnableWhenAutoMatching'));
        return;
    end

    local indunType = topFrame:GetUserIValue('INDUN_TYPE');
    local indunCls = GetClassByType('Indun', indunType);
    local UnderstaffEnterAllowMinMember = TryGetProp(indunCls, 'UnderstaffEnterAllowMinMember');
    if UnderstaffEnterAllowMinMember == nil then
        return;
    end
        
    -- ??티??과 ??동매칭??경우 처리
    local yesScpStr = '_INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW()';
    local clientMsg = ScpArgMsg('ReallyAllowUnderstaffMatchingWith{MIN_MEMBER}?', 'MIN_MEMBER', UnderstaffEnterAllowMinMember);
    if INDUNENTER_CHECK_UNDERSTAFF_MODE_WITH_PARTY(topFrame) == true then
        clientMsg = ClMsg('CancelUnderstaffMatching');
    end
    if withMatchMode == 'YES' then
        yesScpStr = 'ReqUnderstaffEnterAllowModeWithParty('..indunType..')';
    end
    ui.MsgBox(clientMsg, yesScpStr, "None");
end

function _INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW()
    local frame = ui.GetFrame('indunenter');

    ReqUnderstaffEnterAllowMode();
    INDUNENTER_INIT_MY_INFO(frame, 'YES');
    INDUNENTER_UNDERSTAFF_BTN_ENABLE(frame, 0);
end

function INDUNENTER_UNDERSTAFF_BTN_ENABLE(frame, enable)
    local understaffEnterAllowBtn = GET_CHILD_RECURSIVELY(frame, 'understaffEnterAllowBtn');
    local smallUnderstaffEnterAllowBtn = GET_CHILD_RECURSIVELY(frame, 'smallUnderstaffEnterAllowBtn');

    local indunCls = GetClassByType('Indun', frame:GetUserIValue('INDUN_TYPE'));
    if TryGetProp(indunCls, 'EnableUnderStaffEnter', 'YES') == 'NO' then
        enable = 0;
    end

    understaffEnterAllowBtn:SetEnable(enable);
    smallUnderstaffEnterAllowBtn:SetEnable(enable);

    if enable == 1 then
        understaffEnterAllowBtn:ShowWindow(1);
    end

    local reEnterBtn = GET_CHILD_RECURSIVELY(frame, 'reEnterBtn');
    if understaffEnterAllowBtn:IsVisible() == 1 then
        reEnterBtn:ShowWindow(0);
    end
end

function INDUNENTER_CHECK_UNDERSTAFF_MODE_WITH_PARTY(frame)
    local withMatchMode = frame:GetUserValue('WITHMATCH_MODE');
    if withMatchMode ~= 'YES' then
        return false;
    end
    
    local memberInfo = frame:GetUserValue('MEMBER_INFO');
    local memberInfoTable = StringSplit(memberInfo, '/');
    if #memberInfoTable < PC_INFO_COUNT then
        return false;
    end
    if memberInfoTable[PC_INFO_COUNT] ~= 'YES' then
        return false;
    end
    return true;
end

function INDUNENTER_CHECK_ADMISSION_ITEM(frame, matchType, indunInfoIndunType)
    local indunType = frame:GetUserIValue('INDUN_TYPE');
    if indunType == nil or indunType == 0 then
        if indunInfoIndunType ~= nil then
            indunType = indunInfoIndunType;
        end
    end
    
    local indunCls = GetClassByType('Indun', indunType);
    if matchType == nil then
        matchType = 1
    end
    
    if indunCls ~= nil and indunCls.AdmissionItemName ~= 'None' then
        local user = GetMyPCObject();
        local etc = GetMyEtcObject();
        if indunCls.UnitPerReset == 'ACCOUNT' then
            etc = GetMyAccountObj()
        end
        
        local isTokenState = session.loginInfo.IsPremiumState(ITEM_TOKEN);
        if isTokenState == true then
            isTokenState = TryGetProp(indunCls, "PlayPerReset_Token")
        else
            isTokenState = 0
        end

        local nowCount = TryGetProp(etc, "InDunCountType_"..tostring(TryGetProp(indunCls, "PlayPerResetType")));
        
        local admissionItemName = TryGetProp(indunCls, "AdmissionItemName");
        local admissionItemCount = TryGetProp(indunCls, "AdmissionItemCount");
        local admissionPlayAddItemCount = TryGetProp(indunCls, "AdmissionPlayAddItemCount");
        if indunCls.WeeklyEnterableCount ~= 0 then
            nowCount = TryGetProp(etc, "IndunWeeklyEnteredCount_"..tostring(TryGetProp(indunCls, "PlayPerResetType")));
        end
        local addCount = math.floor((nowCount - indunCls.WeeklyEnterableCount) * admissionPlayAddItemCount)
        local nowAdmissionItemCount = admissionItemCount + addCount - isTokenState

--        if SCR_RAID_EVENT_20190102(nil , false) and admissionItemName == "Dungeon_Key01_NoTrade" then
        -- if IsBuffApplied(user,"Event_Steam_New_World_Buff") == "YES" and admissionItemName == "Dungeon_Key01_NoTrade" then
		--     nowAdmissionItemCount = 1
		if IsBuffApplied(user, "Event_Unique_Raid_Bonus") == "YES" and admissionItemName == "Dungeon_Key01_NoTrade" then
            nowAdmissionItemCount = admissionItemCount
        elseif IsBuffApplied(user, "Event_Unique_Raid_Bonus_Limit") == "YES" and admissionItemName == "Dungeon_Key01_NoTrade" then
            local accountObject = GetMyAccountObj()
            if TryGetProp(accountObject, "EVENT_UNIQUE_RAID_BONUS_LIMIT") > 0 then
                nowAdmissionItemCount = admissionItemCount
            end
        end

        local cnt = GetInvItemCount(user, admissionItemName)
        local invItem = session.GetInvItemByName(indunCls.AdmissionItemName);
        
        if indunCls.DungeonType == "Raid" or indunCls.DungeonType == "GTower" then
            if nowCount < indunCls.WeeklyEnterableCount then
                return true;
            else
                local multipleCnt = frame:GetUserIValue("multipleCount");
                local yesScp = string.format("ReqMoveToIndun(%d,%d)", matchType, multipleCnt);
                local itemCls = GetClass("Item", admissionItemName);
                local itemName = TryGetProp(itemCls, "Name");

                if indunCls.SubType ~= 'Casual' then
                    if invItem == nil or cnt == nil or cnt < nowAdmissionItemCount then
                        ui.MsgBox(ScpArgMsg("HaveNoAdmissionItem", "Name", itemName), yesScp, "None");
                    elseif invItem.isLockState == true then
                        ui.MsgBox(ScpArgMsg("AdmissionItemIsLocked", "Name", itemName, "Count", nowAdmissionItemCount), yesScp, "None");
                    else
                        ui.MsgBox(ScpArgMsg("EnterWithAdmissionItem", "Name", itemName, "Count", nowAdmissionItemCount), yesScp, "None");
                    end
                    return false;
                else
                    if invItem == nil or cnt == nil or cnt < nowAdmissionItemCount then
                        
                    elseif invItem.isLockState == true then
                        
                    else
                        ui.MsgBox(ScpArgMsg("EnterWithAdmissionItem", "Name", itemName, "Count", nowAdmissionItemCount), yesScp, "None");
                        return false;
                    end
                end
            end
        end 

        if cnt == nil or cnt < nowAdmissionItemCount then
            ui.MsgBox_NonNested(ClMsg('CannotJoinIndunItemScarcity'), 0x00000000);
            return false;
        end
        
        if invItem == nil or invItem.isLockState == true then
            ui.MsgBox_NonNested(ClMsg('AdmissionItemLockMsg'), 0x00000000);
            return false;
        end
    elseif indunCls ~= nil and matchType == 2 and (indunCls.DungeonType == 'Raid' or indunCls.DungeonType == 'GTower') then
        local etc = GetMyEtcObject()
        if indunCls.UnitPerReset == 'ACCOUNT' then
            etc = GetMyAccountObj()
        end

        local nowCount = TryGetProp(etc, "InDunCountType_"..tostring(TryGetProp(indunCls, "PlayPerResetType")))
        if indunCls.WeeklyEnterableCount ~= 0 then
            nowCount = TryGetProp(etc, "IndunWeeklyEnteredCount_"..tostring(TryGetProp(indunCls, "PlayPerResetType")))
        end

        if nowCount < indunCls.WeeklyEnterableCount then
            return true
        else
            local multipleCnt = frame:GetUserIValue("multipleCount")
            local yesScp = string.format("ReqMoveToIndun(%d,%d)", matchType, multipleCnt)
            ui.MsgBox(ClMsg("HaveNoEnterableCount"), yesScp, "None")

            return false
        end
    end
    return true;
end

function INDUN_ALREADY_PLAYING()
    local yesScp = string.format("AnsGiveUpPrevPlayingIndun(%d)", 1);
    local noScp = string.format("AnsGiveUpPrevPlayingIndun(%d)", 0);
    ui.MsgBox(ClMsg("IndunAlreadyPlaying_AreYouGiveUp"), yesScp, noScp);
end

function INDUN_ALREADY_PLAYING_PARTY()
    local yes_scp = string.format("AnsGiveUpPrevPlayingIndunParty(%d)", 1);
    local no_scp = string.format("AnsGiveUpPrevPlayingIndunParty(%d)", 0);
    ui.MsgBox(ClMsg("IndunAlreadyPlaying_AreYouGiveUp"), yes_scp, no_scp);
end

function IS_EXIST_CLASSNAME_IN_LIST(list, value)
    for i =1, #list do
        if list[i].ClassName == value then
            return true;
        end
    end
    return false;
end

function IS_INDUN_AUTOMATCH_WAITING()
    local frame = ui.GetFrame('indunenter')
    if frame ~= nil then
        local waiting = frame:GetUserValue('AUTOMATCH_MODE')
        local with_party = frame:GetUserValue('WITHMATCH_MODE')
        local finded = frame:GetUserValue('AUTOMATCH_FIND')
        if waiting == 'YES' or with_party == 'YES' or finded == 'YES' then
            return true
        end
    end

    return false
end

function INDUNENTER_AUTOMATCH_TYPE_BY_CONTENTS(indun_type, need_under_staff_allow)
    if indun_type == nil then return; end
    local indun_cls = GetClassByType("Indun_contents", indun_type);
    if indun_cls ~= nil then
        local dungeon_type = TryGetProp(indun_cls, "DungeonType", "None");
        if dungeon_type == "AncientDefense" then
            ANCIENT_DEFENSE_AUTOMATCH(indun_type, need_under_staff_allow);
        end
    end
end

function INDUNENTER_SET_WAIT_PC_COUNT_BY_CONTENTS(indun_type, pc_count)
    if indun_type == nil then return; end
    local indun_cls = GetClassByType("Indun_contents", indun_type);
    if indun_cls ~= nil then
        local dungeon_type = TryGetProp(indun_cls, "DungeonType", "None");
        if dungeon_type == "AncientDefense" then
            ANCIENT_DEFENSE_WAIT_PC_COUNT(pc_count);
        end
    end
end

function INDUNENTER_AUTOMATCH_FINDED_BY_CONTENTS(indun_type)
    if indun_type == nil then return; end
    local indun_cls = GetClassByType("Indun_contents", indun_type);
    if indun_cls ~= nil then
        local dungeon_type = TryGetProp(indun_cls, "DungeonType", "None");
        if dungeon_type == "AncientDefense" then
            ANCIENT_DEFENSE_AUTOMATCH_FINDED();
        end
    end
end

function FAIL_START_PARTY_MATCHING(frame, msg, str, num)
    local topFrame = frame:GetTopParentFrame();
    local understaffEnterAllowBtn = GET_CHILD_RECURSIVELY(topFrame, 'understaffEnterAllowBtn');    
    understaffEnterAllowBtn:ShowWindow(1);    
    INDUNENTER_SET_ENABLE(0, 1, 1, 0);
end

function FAIL_REGISTER_PARTY_MATCHING(frame, msg, str, num)
    local topFrame = frame:GetTopParentFrame();
    local understaffEnterAllowBtn = GET_CHILD_RECURSIVELY(topFrame, 'understaffEnterAllowBtn');    
    understaffEnterAllowBtn:ShowWindow(1);    
    local withTime = GET_CHILD_RECURSIVELY(frame, 'withTime');
    withTime:SetEnable(1)
    INDUNENTER_SET_ENABLE(0, 0, 1, 0);
end