-- inuninfo.lua
function INDUNINFO_ON_INIT(addon, frame)
    addon:RegisterMsg('CHAT_INDUN_UI_OPEN', 'INDUNINFO_CHAT_OPEN');    
    addon:RegisterMsg('WEEKLY_BOSS_UI_UPDATE', 'WEEKLY_BOSS_UI_UPDATE');
    addon:RegisterMsg('FIELD_BOSS_MONSTER_UPDATE', 'ON_FIELD_BOSS_MONSTER_UPDATE');
    addon:RegisterMsg('FIELD_BOSS_RANKING_UPDATE', 'ON_FIELD_BOSS_RANKING_UPDATE');
    addon:RegisterMsg('BORUTA_RANKING_UI_UPDATE', 'BORUTA_RANKING_UI_UPDATE');
    addon:RegisterMsg("PVP_STATE_CHANGE", "INDUNINFO_TEAM_BATTLE_STATE_CHANGE");
    addon:RegisterMsg("FAVORITE_CHANGE","INDUN_INFO_UPDATE_FAVORITE");
    addon:RegisterMsg("PVP_PC_INFO", "INDUNINFO_UPDATE_PVP_RESULT");
	g_selectedIndunTable = {};
    g_selected_indun_category_table = {}; 
end

local NOT_SELECTED_BOX_SKIN = "chat_window_2";

g_pvpIndunCategoryList = {600, 700, 900};
--[[
    기존의 카테고리 리스트에 들어가는 자료형을 스트링으로 바꿈
    어떠한 카테고리로 묶고 싶다면 GroupID 칼럼 값을 통일시키면 됨(스트링 사용)
    카테고리 안의 탭들(디테일 컨트롤)에 주/일 횟수를 표시하고 싶다면
    ㄴ> Difficulty에 값을 넣어주면 됨(스트링); 난이도나 모드, 간결화된 이름을 넣길 권장;
]]
g_indunCategoryList = {"Indun","Uphill","Solo_dungeon","Raid_Solo","Challenge","Unique", "Unique_Solo", "Gtower", "Velcoffer"};

--[[
    프던 보스 카운트 및 챌린지 모드 정보 표시하려고 추가함
    contents_info.xml 데이터 중에서 ResetGroupID임
    indun.xml의 PlayPerResetType과 중복을 피하기 위해 음수로 추가해보았음
]] 
g_contentsCategoryList = { }

g_weeklyBossCategory = 804

function INDUNINFO_PUSH_BACK_TABLE(list,cateType)
    if table.find(list,cateType) == 0 then
        list[#list + 1] = cateType;
    end
end

function UI_TOGGLE_INDUN()
    if app.IsBarrackMode() == true then
        return;
    end
    ui.ToggleFrame('induninfo');
end

function INDUNINFO_CHAT_OPEN(frame, msg, argStr, argNum)
    if nil ~= frame then
        frame:ShowWindow(1);
    else
        ui.OpenFrame("induninfo");
    end
end

function INDUNINFO_UI_OPEN(frame, index, selectIndun)
    if TUTORIAL_CLEAR_CHECK(GetMyPCObject()) == false then
        ui.SysMsg(ClMsg('CanUseAfterTutorialClear'))
        frame:ShowWindow(0)
        return
    end

    if index == nil then
        index = 0
    end

    local now_time = geTime.GetServerSystemTime()
    local weekly_boss_endtime = session.weeklyboss.GetWeeklyBossEndTime()
    if session.weeklyboss.GetNowWeekNum() == 0 then
        weekly_boss.RequestWeeklyBossNowWeekNum();                  -- 현재 week_num 요청
    elseif imcTime.IsLaterThan(now_time,weekly_boss_endtime) ~= 0 then
        weekly_boss.RequestWeeklyBossEndTime(session.weeklyboss.GetNowWeekNum());                
        weekly_boss.RequestWeeklyBossNowWeekNum();                  -- 현재 week_num 요청
	end

    local boruta_endtime = session.boruta_ranking.GetBorutaEndTime();
    if session.boruta_ranking.GetNowWeekNum() == 0 then
        boruta.RequestBorutaNowWeekNum();                    
    elseif imcTime.IsLaterThan(now_time, boruta_endtime) ~= 0 then
        boruta.RequestBorutaEndTime(session.boruta_ranking.GetNowWeekNum())
        boruta.RequestBorutaNowWeekNum();                    
    end

    RequestRankSystemTimeTable(1)
    ui.CloseFrame("squad_manager")


    local tab = GET_CHILD_RECURSIVELY(frame, "tab");
    tab:SelectTab(index);
    TOGGLE_INDUNINFO(frame,index)
    
    if selectIndun ~= nil then
        frame:SetUserValue('CONTENTS_ALERT', 'TRUE')
    else
        frame:SetUserValue('CONTENTS_ALERT', 'FALSE')
    end

    INDUNINFO_RESET_USERVALUE(frame);
    INDUNINFO_CREATE_CATEGORY(frame,selectIndun);
    pc.ReqExecuteTx('GUIDE_QUEST_OPEN_UI', frame:GetName())
end

function SET_WEEKLYBOSS_INDUN_COUNT(frame)
    local button = GET_CHILD_RECURSIVELY(frame,"joinenter")
    local indunCls = GetClassByNumProp("Indun","PlayPerResetType",g_weeklyBossCategory)
    local acc_obj = GetMyAccountObj()
    button:SetTextByKey('cur', acc_obj['IndunWeeklyEnteredCount_'..g_weeklyBossCategory]);
    button:SetTextByKey('max', indunCls.PlayPerReset);
end

function TOGGLE_INDUNINFO(frame,type)
	--indun
    do
		local isShow = BoolToNumber(0 == type or 1 == type or 2 == type)
		local indunbox = GET_CHILD_RECURSIVELY(frame,'indunbox')
		indunbox:ShowWindow(isShow)
		local lvAscendRadio = GET_CHILD_RECURSIVELY(frame,'lvAscendRadio')
		lvAscendRadio:ShowWindow(isShow)
		local lvDescendRadio = GET_CHILD_RECURSIVELY(frame,'lvDescendRadio')
		lvDescendRadio:ShowWindow(isShow)
		local bottomBox = GET_CHILD_RECURSIVELY(frame, 'bottomBox')
		bottomBox:ShowWindow(isShow)
	end
	--weeklyboss rank
	do
		local isShow = BoolToNumber(3 == type)
		local WeeklyBossbox = GET_CHILD_RECURSIVELY(frame, 'WeeklyBossbox')
		WeeklyBossbox:ShowWindow(isShow)

		if isShow == 0 then
			ui.CloseFrame('induninfo_class_selector')
		end
	end
	--field boss
	do
		local isShow = BoolToNumber(4 == type)
		local field_boss_box = GET_CHILD_RECURSIVELY(frame, 'field_boss_box')
		field_boss_box:ShowWindow(isShow)
    end
	--boruta rank
	do
		local isShow = BoolToNumber(5 == type)
		local boruta_box = GET_CHILD_RECURSIVELY(frame, 'boruta_box')
		boruta_box:ShowWindow(isShow)
	end
	--pvp
	do
		local isShow = BoolToNumber(6 == type)
		local pvpBox = GET_CHILD_RECURSIVELY(frame,'pvpbox')
		pvpBox:ShowWindow(isShow)
	end
	--pvp and indun common
	do
		local isShow = BoolToNumber(6 == type or 0 == type or 1 == type or 2 == type)
		local categoryBox = GET_CHILD_RECURSIVELY(frame, 'categoryBox')
		categoryBox:ShowWindow(isShow)
		local contentBox = GET_CHILD_RECURSIVELY(frame, 'contentBox')
        contentBox:ShowWindow(isShow)
	end
    --raid rank
	do
		local isShow = BoolToNumber(7 == type)
		local raidrankingBox = GET_CHILD_RECURSIVELY(frame, 'raidrankingBox');
		raidrankingBox:ShowWindow(isShow);
	end
end

function INDUNINFO_UI_CLOSE(frame)
    INDUNMAPINFO_UI_CLOSE();
    ui.CloseFrame('induninfo');
    ui.CloseFrame('indun_char_status');
    ui.CloseFrame('weeklyboss_patterninfo');
    ui.CloseFrame('induninfo_pvpreward');
    ui.CloseFrame('induninfo_class_selector');
end

function INDUNINFO_ADD_COUNT(table,index)
    if table[index] == nil then
        table[index] = 1
    else
        table[index] = table[index] + 1
    end
end


local weekendevent_list = nil

function IS_WEEKENDEVENT_CONTENTS(name)
    if weekendevent_list == nil then
        weekendevent_list = {}
        local list, cnt = GetClassList('weekendevent_list_client')
        for i = 0, cnt - 1 do
            local cls = GetClassByIndexFromList(list, i)
            local con_name = TryGetProp(cls, 'ContentsName', 'None')
            if con_name ~= 'None' then
                local buff_name = TryGetProp(cls, 'BuffName', 'None')
                weekendevent_list[buff_name] = con_name
            end
        end
    end
    
    for buff_name, con_name in pairs(weekendevent_list) do
        if IsBuffApplied(GetMyPCObject(), buff_name) == "YES" then
            local token = StringSplit(con_name, '/')
            for k, v in pairs(token) do
                if v == name then
                    return true
                end
             end
        end
    end

    return false
end

function IS_WEEKENDEVENT_CATEGORY(name)
    if weekendevent_list == nil then
        weekendevent_list = {}
        local list, cnt = GetClassList('weekendevent_list_client')
        for i = 0, cnt - 1 do
            local cls = GetClassByIndexFromList(list, i)
            local con_name = TryGetProp(cls, 'ContentsName', 'None')
            if con_name ~= 'None' then
                local buff_name = TryGetProp(cls, 'BuffName', 'None')
                weekendevent_list[buff_name] = con_name
            end
        end
    end
    
    for buff_name, con_name in pairs(weekendevent_list) do
        if IsBuffApplied(GetMyPCObject(), buff_name) == "YES" then
            local token = StringSplit(con_name, '/')
            for k, v in pairs(token) do
                local cls = GetClass('Indun', v)            
                local cate_1 = TryGetProp(cls, 'Category', 'None')
                if cate_1 ~= 'None'  then
                    if cate_1 == name then
                        return true
                    end
                end
             end
        end
    end

    return false
end


function INDUNINFO_CREATE_CATEGORY(frame, selectIndun)
    local categoryBox = GET_CHILD_RECURSIVELY(frame, 'categoryBox');
    categoryBox:RemoveAllChild();
    local cycleCtrlPic = GET_CHILD_RECURSIVELY(frame, 'cycleCtrlPic')
    cycleCtrlPic:ShowWindow(0);
    
    local SCROLL_WIDTH = 20;
    local categoryBtnWidth = categoryBox:GetWidth() - SCROLL_WIDTH;
    local firstBtn = nil;
    local groupTable = {};
    local missionIndunSet = {};

    local tab = GET_CHILD_RECURSIVELY(frame, "tab")
    local isRaidTab = (tab:GetSelectItemIndex() == 2)
    local isFavoriteTab = (tab:GetSelectItemIndex() == 0)
    local favorite_indunlist = INDUNINFO_GET_FAVORITE_INDUN_LIST();

    local enableCreate = function(dungeonType)
        local isRaid = (dungeonType == 'UniqueRaid' or dungeonType == 'Raid' or dungeonType == 'GTower' or dungeonType == "MythicDungeon_Auto" or dungeonType == "MythicDungeon_Auto_Hard") or dungeonType == "EarringRaid"
        return ((isRaid == true and isRaidTab == true) or (isRaid == false and isRaidTab == false) or isFavoriteTab == true)
    end
    -- 카테고리 버튼 생성 함수
    local createCategory = function(groupID,cls, is_weekend_contents)
        if is_weekend_contents == nil then
            is_weekend_contents = false
        end
            
        local categoryCtrl = categoryBox:GetChild('CATEGORY_CTRL_'..groupID);
        if categoryCtrl ~= nil then
            return nil
        end

        local category = cls.Category;
        categoryCtrl = categoryBox:CreateOrGetControlSet('indun_cate_ctrl', 'CATEGORY_CTRL_'..groupID, 0, 0);
        local name = categoryCtrl:GetChild("name");
        local btn = categoryCtrl:GetChild("button");
        local countText = categoryCtrl:GetChild('countText');
      
        -- 주/일 횟수 텍스트
        local countText = categoryCtrl:GetChild('countText');
        -- 주/일 표시 이미지
        local cyclePicImg = GET_CHILD_RECURSIVELY(categoryCtrl, 'cycleCtrlPic')   

        local favorite_img = GET_CHILD_RECURSIVELY(categoryCtrl, "favorite");

        if table.find(favorite_indunlist, groupID) ~= 0 then 
            favorite_img:SetImage("star_in_arrow")
        else
            favorite_img:SetImage("star_out_arrow")
        end
        
        btn:Resize(categoryBtnWidth, categoryCtrl:GetHeight());

        local prefix = ''
        if IS_WEEKENDEVENT_CATEGORY(category) then
            prefix = '{@st41b}{#00ee00}'
            btn:SetTextTooltip(ClMsg("WeekendEventContents"))
        end
        name:SetTextByKey("value", prefix .. category);

        if TryGetProp(cls,"Difficulty","None")  ~= "None" then
            countText:ShowWindow(0);
            cyclePicImg:ShowWindow(0);
        else
            -------횟수제한 값 불러오는 부분-------
            local temp;
            -- 어시스터 던전, 차원 붕괴 지점 예외 처리 
            if TryGetProp(cls,"GroupID","None") == "Rift" then temp = -300;
            elseif TryGetProp(cls,"GroupID","None")  == "Ancient" then temp = -500;
            else temp = cls.PlayPerResetType; end

            if temp == 5000 then -- 영웅담 예외처리
                countText:SetText(ScpArgMsg('ChallengeMode_HardMode_Count', 'Count', GET_CURRENT_ENTERANCE_COUNT(temp)));
                countText:ShowWindow(0);
                cyclePicImg:ShowWindow(0);
            else
            countText:SetTextByKey('current', GET_CURRENT_ENTERANCE_COUNT(temp));
            countText:SetTextByKey('max', GET_INDUN_MAX_ENTERANCE_COUNT(temp));
        INDUNINFO_SET_CYCLE_PIC(cyclePicImg,cls,'_s')
        end
        end

        categoryCtrl:SetUserValue('RESET_GROUP_ID', groupID);

        if firstBtn == nil then
            firstBtn = btn;
        end

        local dungeonType = TryGetProp(cls, "DungeonType", "None")
        local selectCls = GetClass("Indun", selectIndun)

        if selectIndun == dungeonType then -- MythicDungeon_Auto  이 경우는 이것밖에 없음
            firstBtn = btn;
        elseif selectIndun ~= nil then
            if TryGetProp(selectCls, "GroupID", "None") == TryGetProp(cls, "GroupID", "None") then
                firstBtn = btn
            end
        end
    end
    local isFavorite = function(groupID)
        local isfavorite = table.find(favorite_indunlist, groupID) ~= 0
        return ((isfavorite == true and isFavoriteTab == true) or isFavoriteTab == false)
    end

    local indunClsList, cnt = GetClassList('Indun');
    for i = 0, cnt - 1 do
        local indunCls = GetClassByIndexFromList(indunClsList, i);
        if indunCls ~= nil and indunCls.Category ~= 'None' and enableCreate(indunCls.DungeonType) == true then
            local groupID = TryGetProp(indunCls,"GroupID","None");
            if groupID ~= 'None' and isFavorite(groupID) == true then
                local is_weekend_contents = IS_WEEKENDEVENT_CONTENTS(indunCls.ClassName)
                if indunCls.DungeonType == 'MissionIndun' then
                    INDUNINFO_ADD_COUNT(missionIndunSet,groupID)
                    INDUNINFO_PUSH_BACK_TABLE(g_indunCategoryList, groupID)
                    createCategory(groupID, indunCls, is_weekend_contents)                    
			    elseif string.find(indunCls.DungeonType, "MythicDungeon") == 1 then
			    	local pattern_info = mythic_dungeon.GetPattern(mythic_dungeon.GetCurrentSeason())
			    	local mapCls = GetClassByType("Map",pattern_info.mapID)
                    -- "성물 레이드 : 레이드 이름" 으로 표현하기 위해서는 생성 함수를 각각 줄 수 밖에 없었음
			    	if TryGetProp(mapCls,"ClassName") == indunCls.MapName then
                        INDUNINFO_ADD_COUNT(groupTable, groupID)
                        INDUNINFO_PUSH_BACK_TABLE(g_indunCategoryList, groupID)
                        createCategory(groupID, indunCls, is_weekend_contents)                        
			    	end
                elseif string.find(indunCls.DungeonType, "TOSHero") == 1 then
                    local dungeonType = session.rank.GetCurrentDungeon(1)
                    if dungeonType == indunCls.MapName then
                        INDUNINFO_ADD_COUNT(groupTable, groupID)
                        INDUNINFO_PUSH_BACK_TABLE(g_indunCategoryList, groupID)
                        createCategory(groupID, indunCls, is_weekend_contents)                        
                    end
                else
                    INDUNINFO_ADD_COUNT(groupTable, groupID)
                    INDUNINFO_PUSH_BACK_TABLE(g_indunCategoryList, groupID)
                    createCategory(groupID, indunCls, is_weekend_contents)                    
			    end
            end
        end
    end

    for key,_ in pairs(missionIndunSet) do
        INDUNINFO_ADD_COUNT(groupTable,key)
    end

    -- -- 인던 외 컨텐츠 표시를 일단 인던과 같이 하는데, 나중에 탭 형식으로 변경 필요함
    if isRaidTab == false then
        local contentsClsList, count = GetClassList('contents_info')
        for i = 0, count - 1 do
            local contentsCls = GetClassByIndexFromList(contentsClsList, i)
            if contentsCls ~= nil and contentsCls.Category ~='None' then
                local groupID = TryGetProp(contentsCls,"GroupID","None") 
                if isFavorite(groupID) == true then
                    INDUNINFO_ADD_COUNT(groupTable,groupID)
                    INDUNINFO_PUSH_BACK_TABLE(g_contentsCategoryList,groupID);
                    createCategory(groupID,contentsCls)
                end
            end
        end
    end

    INDUNINFO_CATEGORY_ALIGN_DEFAULT(categoryBox);
    -- default select
    local infoBox = GET_CHILD_RECURSIVELY(frame, 'infoBox');
    local resetText = GET_CHILD_RECURSIVELY(frame, "resetInfoText");
    local resetText_week = GET_CHILD_RECURSIVELY(frame, "resetInfoText_Week");
    local canNotEnterText = GET_CHILD_RECURSIVELY(frame, "canNotEnterText");
    
    if firstBtn == nil then
        infoBox:ShowWindow(0);
        resetText:ShowWindow(0);
        resetText_week:ShowWindow(0);
        canNotEnterText:ShowWindow(0)
    else
        infoBox:ShowWindow(1);
        resetText:ShowWindow(1);
        resetText_week:ShowWindow(0);
        INDUNINFO_CATEGORY_LBTN_CLICK(firstBtn:GetParent(), firstBtn, selectIndun);
        INDUNINFO_FAVORITE_TAB_FIRST_BTN(favorite_indunlist, categoryBox, tab);
    end
end

function INDUNINFO_CATEGORY_ALIGN_DEFAULT(categoryBox)
    local frame = categoryBox:GetTopParentFrame();
    local selectedGroupID = frame:GetUserIValue('SELECT');
    local y = 0;
    local spacey = -6;

    for i = 1,#g_pvpIndunCategoryList do
        local resetGroupID = g_pvpIndunCategoryList[i];
        local categoryCtrl = GET_CHILD_RECURSIVELY(categoryBox, 'CATEGORY_CTRL_'..resetGroupID);
        if categoryCtrl ~= nil then
            categoryCtrl:SetOffset(categoryCtrl:GetX(), y);            
            y = y + categoryCtrl:GetHeight() + spacey;
        end

        if resetGroupID == selectedGroupID then
            local indunListBox = GET_CHILD(categoryBox, 'INDUN_LIST_BOX');
            if indunListBox ~= nil then
                indunListBox:SetOffset(indunListBox:GetX(), y);                
                y = y + indunListBox:GetHeight() + spacey;
            end
        end
    end
    
    selectedGroupID = frame:GetUserValue('SELECT');
    for i = 1, #g_indunCategoryList do
        local resetGroupID = g_indunCategoryList[i];
        local categoryCtrl = GET_CHILD_RECURSIVELY(categoryBox, 'CATEGORY_CTRL_'..resetGroupID);
        if categoryCtrl ~= nil then
            categoryCtrl:SetOffset(categoryCtrl:GetX(), y);            
            y = y + categoryCtrl:GetHeight() + spacey;
        end

        if resetGroupID == selectedGroupID then
            local indunListBox = GET_CHILD(categoryBox, 'INDUN_LIST_BOX');
            if indunListBox ~= nil then
                indunListBox:SetOffset(indunListBox:GetX(), y);                
                y = y + indunListBox:GetHeight() + spacey;
            end
        end
    end
    for i = 1, #g_contentsCategoryList do
        local resetGroupID = g_contentsCategoryList[i]
        local categoryCtrl = GET_CHILD_RECURSIVELY(categoryBox, 'CATEGORY_CTRL_'..resetGroupID);
        if categoryCtrl ~= nil then
            categoryCtrl:SetOffset(categoryCtrl:GetX(), y);
            y = y + categoryCtrl:GetHeight() + spacey;
        end

        if resetGroupID == selectedGroupID then
            local indunListBox = GET_CHILD(categoryBox, 'INDUN_LIST_BOX');
            if indunListBox ~= nil then
                indunListBox:SetOffset(indunListBox:GetX(), y);
                y = y + indunListBox:GetHeight() + spacey;
            end
        end
    end
end

function INDUNINFO_RESET_USERVALUE(frame)
    frame:SetUserValue('SELECT', 'None');
end

function INDUNINFO_DRAW_CATEGORY_DETAIL_LIST(indunListBox, cls, is_weekly_reset, selectIndun)
    local is_weekend_contents = IS_WEEKENDEVENT_CONTENTS(cls.ClassName)

    local indunDetailCtrl = indunListBox:CreateOrGetControlSet('indun_detail_ctrl', 'DETAIL_CTRL_' .. cls.ClassID, 0, 0);
    indunDetailCtrl = tolua.cast(indunDetailCtrl, 'ui::CControlSet');
    indunDetailCtrl:SetUserValue('INDUN_CLASS_ID', cls.ClassID);
    indunDetailCtrl:SetEventScript(ui.LBUTTONUP, 'INDUNINFO_DETAIL_LBTN_CLICK');
    indunDetailCtrl:SetEventScriptArgString(ui.LBUTTONUP, "click");

    local infoText = indunDetailCtrl:GetChild('infoText');
    local nameText = indunDetailCtrl:GetChild('nameText');
    local countText = indunDetailCtrl:GetChild('countText');

    local onlinePic = GET_CHILD(indunDetailCtrl,'onlinePic')
    local cyclePic = GET_CHILD(indunDetailCtrl,'cycleCtrlPic')
    if TryGetProp(cls,"DungeonType","None") == "Ancient" then
        onlinePic:ShowWindow(1)
        local acc_obj = GetMyAccountObj()
        if TryGetProp(acc_obj,"ANCIENT_SOLO_STAGE_WEEK",0) >= GET_ANCIENT_STAGE_OF_CLASS(cls) then
            onlinePic:SetImage('guild_online')
        end
    else
        onlinePic:ShowWindow(0)
    end
    
    local prefix = ''
    if is_weekend_contents then
        prefix = '{@st31b}{#00ee00}'
        indunDetailCtrl:SetTextTooltip(ClMsg("WeekendEventContents"))
    end

    infoText:SetTextByKey('level', cls.Level);
    --해당 칼럼에 값이 없으면, 디테일 컨트롤에 주/일 횟수 표시 필요 없음
    if TryGetProp(cls,"Difficulty","None") == "None" then
        nameText:SetTextByKey('name', prefix .. cls.Name);        
        countText:ShowWindow(0)
        cyclePic:ShowWindow(0)
    else
        nameText:SetTextByKey('name', prefix .. cls.Difficulty)        
        -- if resetGroupID == -101 or resetGroupID == 816 or resetGroupID == 817 or resetGroupID == 813 then
        -- 분열 특이점, 성물레이드, 성물레이드 도전모드 예외 처리; 
        -- -101 : contents_info에 있는 분열특이점, 챌린지모드는 어따 쓰는지 모르겠음 일단 현황판 탭에서는 안쓰이는중
        if TryGetProp(cls, 'TicketingType', 'None') == 'Entrance_Ticket' then        
            countText:SetText(ScpArgMsg('ChallengeMode_HardMode_Count', 'Count', GET_CURRENT_ENTERANCE_COUNT(cls.PlayPerResetType)))
            cyclePic:ShowWindow(0);
        else
            countText:SetTextByKey('current', GET_CURRENT_ENTERANCE_COUNT(cls.PlayPerResetType));
            countText:SetTextByKey('max', GET_INDUN_MAX_ENTERANCE_COUNT(cls.PlayPerResetType));
            INDUNINFO_SET_CYCLE_PIC(cyclePic,cls,'_s')
        end
    end

    if #g_selectedIndunTable == 0 then -- 디폴트는 리스트의 첫번째
        indunListBox:SetUserValue('FIRST_INDUN_ID', cls.ClassID)
        INDUNINFO_DETAIL_LBTN_CLICK(indunListBox, indunDetailCtrl);
    end

    local className = TryGetProp(cls,"ClassName","None") 
    local dungeonType = TryGetProp(cls,"DungeonType","None")

    if (dungeonType == selectIndun) or selectIndun == className then
        INDUNINFO_DETAIL_LBTN_CLICK(indunListBox, indunDetailCtrl);
    end

    table.insert(g_selectedIndunTable,cls)
    INDUNINFO_DRAW_CATEGORY_DETAIL_LIST_SET_WEEKLY_ENTERANCE(indunListBox, cls, dungeonType, is_weekly_reset);

    -- 주간 입장 텍스트 설정
    local topFrame = indunListBox:GetTopParentFrame()
    local canNotEnterText = GET_CHILD_RECURSIVELY(topFrame, 'canNotEnterText');         --랭킹 집계로 인해 토요일 오전 0시부터 오전 6시 사이에는 입장이 불가능합니다.    
    local resetInfoText = GET_CHILD_RECURSIVELY(topFrame, 'resetInfoText');             --"입장 횟수는 매일 %s시에 초기화 됩니다."
    local resetInfoText_Week = GET_CHILD_RECURSIVELY(topFrame, 'resetInfoText_Week');   --"입장 횟수는 매주 월요일 %s시에 초기화 됩니다."

    local resetTime = INDUN_RESET_TIME % 12;
    local ampm = ClMsg('AM');
    if INDUN_RESET_TIME > 12 then
        ampm = ClMsg('PM');
    end
    --event 예외처리
    if dungeonType == "Event" then
        if cls.ResetTime > 12 then
            ampm = ClMsg('PM');
        end
        resetTime = cls.ResetTime % 12;
    end

    if dungeonType == 'ChallengeMode_HardMode' then
        resetInfoText:ShowWindow(0)
        resetInfoText_Week:ShowWindow(0)
        return
    end

    if dungeonType == 'TOSHero' then
        canNotEnterText:ShowWindow(1);
        resetInfoText:ShowWindow(0)
        resetInfoText_Week:ShowWindow(0)
        return
    end


    canNotEnterText:ShowWindow(0);
    if is_weekly_reset == true then
        --주간
        local resetText_wkeely = string.format('%s %s', ampm, resetTime);
        resetInfoText_Week:SetTextByKey('resetTime', resetText_wkeely);
        resetInfoText:ShowWindow(0);
        resetInfoText_Week:ShowWindow(1);
    else
        --일간
        local resetText = string.format('%s %s', ampm, resetTime);
        resetInfoText:SetTextByKey('resetTime', resetText);
        resetInfoText_Week:ShowWindow(0);
        resetInfoText:ShowWindow(1);
    end
end

function INDUNINFO_CATEGORY_LBTN_CLICK(categoryCtrl, ctrl, selectIndun)
    -- set button skin
    local topFrame = categoryCtrl:GetTopParentFrame();
    local preSelectType = topFrame:GetUserIValue('SELECT');
    local selectedGroupID = categoryCtrl:GetUserValue('RESET_GROUP_ID');
    if preSelectType == selectedGroupID then
        return;
    end

    categoryCtrl = tolua.cast(categoryCtrl, 'ui::CControlSet');
    INDUNINFO_CHANGE_CATEGORY_BUTTON_SKIN(topFrame, categoryCtrl);

    -- make indunlist
    local categoryBox = GET_CHILD_RECURSIVELY(topFrame, 'categoryBox');
    local SCROLL_WIDTH = 20;
    local listBoxWidth = categoryBox:GetWidth() - SCROLL_WIDTH;
    categoryBox:RemoveChild('INDUN_LIST_BOX');

    g_selectedIndunTable = {};
    g_selected_indun_category_table = {};

    local indunListBox = INDUNINFO_RESET_INDUN_LISTBOX(categoryBox)
    if table.find(g_contentsCategoryList,selectedGroupID) ~= 0  then
        local contentsClsList, count = GetClassList('contents_info')
        for i = 0, count - 1 do
            local contentsCls = GetClassByIndexFromList(contentsClsList, i)
            if contentsCls ~= nil and TryGetProp(contentsCls,"GroupID","None")  == selectedGroupID and contentsCls.Category ~= 'None' then
                local is_weekly_reset = BoolToNumber(contentsCls.ResetPer == 'WEEK')
                INDUNINFO_DRAW_CATEGORY_DETAIL_LIST(indunListBox, contentsCls, is_weekly_reset, selectIndun)
            end
        end
    else
        local indunClsList, cnt = GetClassList('Indun');    
        local missionIndunCnt = 0; -- 신규 레벨던전 7곳의 로테이션은 해당 인던의 클래스가 indun.xml에 들어 있는 순서대로 일 ~ 토로 배정됨
        for i = 0, cnt - 1 do
            local indunCls = GetClassByIndexFromList(indunClsList, i);
            local add_flag = false;
            if TryGetProp(indunCls,"GroupID","None")  == selectedGroupID and indunCls.Category ~= 'None' then
                local dungeonType = TryGetProp(indunCls, 'DungeonType')
                if dungeonType == 'MissionIndun' then
                    local sysTime = geTime.GetServerSystemTime();
                    -- 오늘 요일의 던전만 세부항목에 추가한다
                    if missionIndunCnt == sysTime.wDayOfWeek then
                        add_flag = true;
                    end
					missionIndunCnt = missionIndunCnt + 1;
				elseif string.find(indunCls.DungeonType,"MythicDungeon") == 1 then
					local pattern_info = mythic_dungeon.GetPattern(mythic_dungeon.GetCurrentSeason())
					local mapCls = GetClassByType("Map",pattern_info.mapID)
					if TryGetProp(mapCls,"ClassName") == indunCls.MapName then
						add_flag = true;
					end
                elseif string.find(indunCls.DungeonType,"TOSHero") == 1 then
                    local dungeonType = session.rank.GetCurrentDungeon(1)
                    if dungeonType == indunCls.MapName then
						add_flag = true;
                    end
                else
                    add_flag = true;
                end
            end

            if add_flag == true then
                local class_name = TryGetProp(indunCls, "ClassName", "None");
                local is_weekend_contents = IS_WEEKENDEVENT_CONTENTS(class_name);
                local id = TryGetProp(indunCls, "ClassID", 0);
                if is_weekend_contents == true then 
                    indunListBox:SetUserValue("weekend_contents_id", id);
                end

				local is_weekly_reset = (indunCls.WeeklyEnterableCount ~= nil and indunCls.WeeklyEnterableCount > 0)
				if indunCls.DungeonType == "Solo_dungeon" or indunCls.DungeonType == "MythicDungeon_Auto_Hard" or indunCls.DungeonType == "TOSHero" then
					is_weekly_reset = true
                end
                
                if IS_CHANGEABLE_INDUNINFO_CATEGORY(indunCls) == true then
                    INDUNINFO_DRAW_CATEGORY_DETAIL_LIST_BY_CATEGORY_TYPE(indunListBox, indunCls, is_weekly_reset, selectIndun);
                else
                INDUNINFO_DRAW_CATEGORY_DETAIL_LIST(indunListBox, indunCls, is_weekly_reset, selectIndun)
            end
        end
    end
    end
    GBOX_AUTO_ALIGN(indunListBox, 0, 2, 0, true, true);
    -- category box align
    INDUNINFO_CATEGORY_ALIGN_DEFAULT(categoryBox);
    local category_type = indunListBox:GetUserValue("CATEGORY_TYPE");
    if category_type ~= "None" then
        INDUNINFO_DRAW_CATEGORY_DETAIL_LIST_SORT(indunListBox, category_type);
        INDUNINFO_DRAW_CATEGORY_DETAIL_LIST_SKIN_SET(indunListBox, category_type);
        INDUNINFO_DEATIL_FIRST_LBTN_CLICK_BY_RAID_TYPE(indunListBox);
        local id = indunListBox:GetUserValue("weekend_contents_id");
        if id ~= nil and id ~= 0 then
            INDUNINFO_DRAW_CATEGORY_DETAIL_LIST_WEEKEND_CONTENTS(indunListBox, id);
        end
        return;
    else
    INDUNINFO_SORT_BY_LEVEL(topFrame);
end
end
    
function GET_CURRENT_ENTERANCE_COUNT(resetGroupID)
    local etc = GetMyEtcObject();
    local acc_obj = GetMyAccountObj()
    if etc == nil or acc_obj == nil then
        return 0;
    end

    if resetGroupID < 0 then
        local contentsClsList, count = GetClassList('contents_info')
        local contentsCls = nil
        for i = 0, count - 1 do
            contentsCls = GetClassByIndexFromList(contentsClsList, i)
            if contentsCls ~= nil and contentsCls.ResetGroupID == resetGroupID and contentsCls.Category ~= 'None' then
                break
            end
        end

        if contentsCls.UnitPerReset == 'PC' then
            return etc[contentsCls.ResetType]
        else
            return acc_obj[contentsCls.ResetType]
        end
    end
    
    local indunClsList, cnt = GetClassList('Indun');
    local indunCls = nil;
    for i = 0, cnt - 1 do
        indunCls = GetClassByIndexFromList(indunClsList, i);
        if indunCls ~= nil and indunCls.PlayPerResetType == resetGroupID and indunCls.Category ~= 'None' then
            break;
        end
    end

    if indunCls.WeeklyEnterableCount ~= nil and indunCls.WeeklyEnterableCount ~= "None" and indunCls.WeeklyEnterableCount ~= 0 then
        if indunCls.UnitPerReset == 'PC' then
            return(etc['IndunWeeklyEnteredCount_'..resetGroupID]) --매주 남은 횟수
        else     
            if indunCls.DungeonType == "EarringRaid" and indunCls.ClassName ~= 'EarringRaid_Extreme' then
                return acc_obj[TryGetProp(indunCls, "CheckCountName", "None")];
            end            
            return(acc_obj['IndunWeeklyEnteredCount_'..resetGroupID]) --매주 남은 횟수
        end        
    else 
        if indunCls.UnitPerReset == 'PC' then
            return etc['InDunCountType_'..resetGroupID]; --매일 남은 횟수
        else -- 'ACCOUNT'            
            if TryGetProp(indunCls, 'CheckCountName', 'None') ~= 'None' then
                return acc_obj[TryGetProp(indunCls, 'CheckCountName', 'None')]
            end

            if indunCls.DungeonType == "Challenge_Auto" or indunCls.DungeonType == "Challenge_Solo" then
                if string.find(indunCls.ClassName, "Challenge_Division") == nil then
                    -- 챌린지 자동매칭 남은 횟수
                    return etc["ChallengeModeCompleteCount"]; 
                end
            else
                return acc_obj['InDunCountType_'..resetGroupID]; --매일 남은 횟수
            end
        end
    end
end

function GET_INDUN_MAX_ENTERANCE_COUNT(resetGroupID)
    local etc = GetMyEtcObject();
    if etc == nil then
        return 0;
    end
    
    if resetGroupID < 0 then
        local contentsClsList, count = GetClassList('contents_info')
        local contentsCls = nil
        for i = 0, count - 1 do
            contentsCls = GetClassByIndexFromList(contentsClsList, i)
            if contentsCls ~= nil and contentsCls.ResetGroupID == resetGroupID and contentsCls.Category ~= 'None' then
                break
            end
        end
        local ret = contentsCls.EnterableCount
        if ret == 0 then
            ret = "{img infinity_text 20 10}"
        end
        return ret
    else
        local indunClsList, cnt = GetClassList('Indun');
        local indunCls = nil;
        for i = 0, cnt - 1 do
            indunCls = GetClassByIndexFromList(indunClsList, i);
            if indunCls ~= nil and indunCls.PlayPerResetType == resetGroupID and indunCls.Category ~= 'None' then
                break;
            end
        end
        
        local infinity = TryGetProp(indunCls, 'EnableInfiniteEnter', 'NO')
        if indunCls.AdmissionItemName ~= "None" or infinity == 'YES' then
            local a = "{img infinity_text 20 10}"
            if indunCls.DungeonType == "Raid" or indunCls.DungeonType == "GTower" then
                if indunCls.WeeklyEnterableCount > TryGetProp(etc, "IndunWeeklyEnteredCount_"..tostring(TryGetProp(indunCls, "PlayPerResetType"))) then
                    return indunCls.WeeklyEnterableCount;
                end
            end
            return a;
        end

        if indunCls.WeeklyEnterableCount ~= nil and indunCls.WeeklyEnterableCount ~= "None" and indunCls.WeeklyEnterableCount ~= 0 then
            return indunCls.WeeklyEnterableCount;  --매주 max
        else
            return indunCls.PlayPerReset;          --매일 max
        end
    end
end

function INDUNINFO_SET_CYCLE_PIC(ctrl, cls, postFix)
    local imageName = GET_RESET_CYCLE_PIC_TYPE(cls, postFix)
    if imageName == 'None' then
        ctrl:ShowWindow(0);
        return
    end
    ctrl:SetImage(GET_INDUN_ICON_NAME(imageName, postFix));
    if imageName == 'event' then
        local margin = ctrl:GetOriginalMargin();
        ctrl:SetMargin(margin.left, margin.top, margin.right - 6, margin.bottom);
        ctrl:Resize(ctrl:GetOriginalWidth() + 11, ctrl:GetOriginalHeight());
    end
    ctrl:ShowWindow(1)
end

function GET_RESET_CYCLE_PIC_TYPE(cls,postFix)
    local idSpace = GetIDSpace(cls)
    local cyclePicType = 'None';  --week, day, event, None
    if idSpace == 'contents_info' then
        local contentsCls = cls
        if contentsCls.ResetPer == 'WEEK' then
            cyclePicType = 'week'
        elseif contentsCls.ResetPer == 'DAY' then
            cyclePicType = 'day'
        else
            cyclePicType = 'None'
        end
    elseif idSpace == "Indun" then
        local indunCls = cls
        local etc = nil
        do
            if indunCls.UnitPerReset == 'ACCOUNT' then
                etc = GetMyAccountObj()
            else
                etc = GetMyEtcObject();
            end
            if etc == nil then
                return 0;
            end
        end
        
        local enterableCount = tonumber(indunCls.WeeklyEnterableCount)
        if INDUNINFO_IS_EVENT_CATEGORY(indunCls) then
            cyclePicType = 'event'
        elseif  enterableCount ~= nil and enterableCount > 0 then
			cyclePicType = 'week';
		elseif indunCls.DungeonType == "Solo_dungeon" then
			cyclePicType = 'week';
        elseif string.find(indunCls.ClassName, "Challenge_Division_Auto") ~= nil then
            cyclePicType = "None";
        elseif string.find(indunCls.ClassName, "Legend_Raid_Giltine") ~= nil then
            cyclePicType = "None";
        else
            cyclePicType = 'day';
        end

        local dungeonType = TryGetProp(indunCls, "DungeonType");
        if dungeonType == 'MissionIndun' then
            local sysTime = geTime.GetServerSystemTime();
            local dayOfWeekStr = string.lower(GET_DAYOFWEEK_STR(sysTime.wDayOfWeek));
            cyclePicType = dayOfWeekStr;
        elseif dungeonType == "UniqueRaid" then
            cyclePicType = 'None';
        elseif string.find(dungeonType, "MythicDungeon_Auto_Hard") ~= nil then
            cyclePicType = "None";
        elseif string.find(dungeonType, "MythicDungeon") ~= nil then
            cyclePicType = "week";
        elseif string.find(dungeonType, "TOSHero") ~= nil then
            cyclePicType = "None";
        elseif indunCls.DungeonType == "EarringRaid" then
            cyclePicType = "None";
        end
    elseif idSpace == 'PVPIndun' then
        local indunCls = cls
        cyclePicType = indunCls.Day
    end
    
    return cyclePicType;
end

function INDUNINFO_IS_EVENT_CATEGORY(indunCls)
    if indunCls.DungeonType == 'UniqueRaid' then
        local pc = GetMyPCObject()
        if IsBuffApplied(pc, "Event_Unique_Raid_Bonus") == "YES" then
			return true
        elseif IsBuffApplied(pc, "Event_Unique_Raid_Bonus_Limit") == "YES" then
            local accountObject = GetMyAccountObj(pc)
            if TryGetProp(accountObject ,"EVENT_UNIQUE_RAID_BONUS_LIMIT") > 0 then
                return true
            end
        end
    elseif indunCls.DungeonType == "Event" then
        return true
    end
    return false
end

function GET_INDUN_ICON_NAME(name,postFix)
    if ui.IsImageExist(name) == false then
        name = 'indun_icon_'..name
        if ui.IsImageExist(name) == false and postFix ~= nil then
            name = name .. postFix
        end
    end
    if config.GetServiceNation() ~= 'KOR' then
        name = name..'_eng'
    end
    return name
end

function INDUNINFO_DETAIL_LBTN_CLICK(parent, detailCtrl, clicked)
    local indunClassID = detailCtrl:GetUserIValue('INDUN_CLASS_ID');
    local preSelectedDetail = parent:GetUserIValue('SELECTED_DETAIL');
    if indunClassID == preSelectedDetail then
        return;
    end
    
    if clicked == "click" then
        imcSound.PlaySoundEvent("button_click_7");        
    end
    
    -- set skin
    local SELECTED_BOX_SKIN = detailCtrl:GetUserConfig('SELECTED_BOX_SKIN');
    local preSelectedCtrl = parent:GetChild('DETAIL_CTRL_'..preSelectedDetail);
    if preSelectedCtrl ~= nil then
        local index = 0
        for i = 1,#g_selectedIndunTable do
            if g_selectedIndunTable[i].ClassID == preSelectedDetail then
                index = i
                break
            end
        end
        INDUNINFO_DETAIL_SET_SKIN(preSelectedCtrl,index)
    end
    local skinBox = GET_CHILD(detailCtrl, 'skinBox');
    skinBox:SetSkinName(SELECTED_BOX_SKIN);
    parent:SetUserValue('SELECTED_DETAIL', indunClassID);
    
    local topFrame = parent:GetTopParentFrame();
    local tab = GET_CHILD_RECURSIVELY(topFrame, "tab");
    local index = tab:GetSelectItemIndex();

    -- 인스턴스 던전 정보 처리를 위한 임시 처리 시작 --
    -- INDUNINFO_DROPBOX_ITEM_LIST 에서 parent의 SELECTED_DETAIL 값을 불러올 수 있도록 같은 프레임을 호출하도록 변경해야 함 --
    local categoryBox = GET_CHILD_RECURSIVELY(topFrame,'categoryBox')
    local indunListBox = GET_CHILD_RECURSIVELY(categoryBox, 'INDUN_LIST_BOX');
    indunListBox:SetUserValue('SELECTED_DETAIL', indunClassID);
    -- 인스턴스 던전 정보 처리를 위한 임시 처리 끝 --
    local resetGroupID = topFrame:GetUserValue('SELECT')
    if index == 6 then
        PVP_INDUNINFO_MAKE_DETAIL_INFO_BOX(topFrame, indunClassID);
    elseif table.find(g_contentsCategoryList,resetGroupID) ~= 0 then
        INDUNINFO_MAKE_DETAIL_INFO_BOX_OTHER(topFrame, indunClassID)
    elseif indunClassID > 0 then
        INDUNINFO_MAKE_DETAIL_INFO_BOX(topFrame, indunClassID);
    end
end

-- induninfo와 indunenter에서 보상 드랍박스 만드는 데 완전 동일한 로직 사용중이고 또 너무 길어보여서 리스트에 아이템 채우는 부분만 분리했음
function CHECK_AND_FILL_REWARD_DROPBOX(list, itemName)
    local item = GetClass('Item', itemName);
    if item ~= nil then   -- 있다면 아이템 --
        local itemType = TryGetProp(item, 'GroupName');
        local itemClassType = TryGetProp(item, 'ClassType');
        if itemType == 'Recipe' then
            local recipeItemCls = GetClass('Recipe', item.ClassName);
            local targetItem = TryGetProp(recipeItemCls, 'TargetItem');
            if targetItem ~= nil then
                local targetItemCls = GetClass('Item', targetItem);
                if targetItemCls ~= nil then
                    itemType = TryGetProp(targetItemCls, 'GroupName');
                    itemClassType = TryGetProp(targetItemCls, 'ClassType');
                end
            end
        end
        if itemType ~= nil then
            if itemType == 'Weapon' then
                if IS_EXIST_CLASSNAME_IN_LIST(list['weaponBtn'],item.ClassName) == false and IS_EXIST_CLASSNAME_IN_LIST(list['subweaponBtn'],item.ClassName) == false then
                    list['weaponBtn'][#list['weaponBtn'] + 1] = item;
                end
            elseif itemType == 'SubWeapon' then
                if itemClassType == 'Armband' then
                    if IS_EXIST_CLASSNAME_IN_LIST(list['accBtn'],item.ClassName) == false then
                        list['accBtn'][#list['accBtn'] + 1] = item;
                    end
                else 
                    if IS_EXIST_CLASSNAME_IN_LIST(list['subweaponBtn'],item.ClassName) == false then
                        list['subweaponBtn'][#list['subweaponBtn'] + 1] = item;
                    end
                end
            elseif itemType == 'Armor' then
                if itemClassType == 'Neck' or itemClassType == 'Ring' then
                    if IS_EXIST_CLASSNAME_IN_LIST(list['accBtn'],item.ClassName) == false then
                        list['accBtn'][#list['accBtn'] + 1] = item;
                    end
                elseif itemClassType == 'Shield' then
                    if IS_EXIST_CLASSNAME_IN_LIST(list['subweaponBtn'],item.ClassName) == false then
                        list['subweaponBtn'][#list['subweaponBtn'] + 1] = item;
                    end
                else
                    if IS_EXIST_CLASSNAME_IN_LIST(list['armourBtn'],item.ClassName) == false then
                        list['armourBtn'][#list['armourBtn'] + 1] = item;
                    end
                end
            else
                if IS_EXIST_CLASSNAME_IN_LIST(list['materialBtn'],item.ClassName) == false then
                    list['materialBtn'][#list['materialBtn'] + 1] = item;
                end
            end
        end
    end
end

function INDUNINFO_DROPBOX_ITEM_LIST(parent, control)
    local topFrame = parent:GetTopParentFrame();
    local selectType = topFrame:GetUserIValue('SELECT');
    local categoryBox = GET_CHILD_RECURSIVELY(topFrame,'categoryBox')
    local indunListBox = GET_CHILD_RECURSIVELY(categoryBox, 'INDUN_LIST_BOX');
    local indunClassID = indunListBox:GetUserIValue('SELECTED_DETAIL');
    local preSelectedCtrl = indunListBox:GetChild('DETAIL_CTRL_'..indunClassID);
    
    local controlName = control:GetName();
    -- 여기서 부터
    local indunCls = nil
    local dungeonType = nil
    local indunRewardItem = nil
    local groupList = nil
    if selectType < 0 then
        indunCls = GetClassByType('contents_info', indunClassID)
        indunRewardItem = TryGetProp(indunCls, 'RewardItem')
    else
        indunCls = GetClassByType('Indun', indunClassID);
        dungeonType = TryGetProp(indunCls, 'DungeonType')
        indunRewardItem = TryGetProp(indunCls, 'Reward_Item')
    end
    
    if indunRewardItem ~= nil and indunRewardItem ~= 'None' then
        groupList = SCR_STRING_CUT(indunRewardItem, '/')
    end
    
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
        local dropListFrame = ui.MakeDropListFrame(control, 0, 0, 300, 600, 1, ui.LEFT, "INDUNINFO_DROPBOX_AFTER_BTN_DOWN",nil,nil);
        ui.AddDropListItem(ClMsg('IndunRewardItem_Empty'))
        return;
    elseif #indunRewardItemList[controlName] ~= 0 and #indunRewardItemList[controlName] < 10 then
        local dropListSize = #indunRewardItemList[controlName] * 1
        local dropListFrame = ui.MakeDropListFrame(control, 0, 0, 300, 600, dropListSize, ui.LEFT, "GET_INDUNINFO_DROPBOX_LIST_TOOLTIP_VIEW","GET_INDUNINFO_DROPBOX_LIST_MOUSE_OVER","GET_INDUNINFO_DROPBOX_LIST_MOUSE_OUT");
    else
        local dropListFrame = ui.MakeDropListFrame(control, 0, 0, 300, 600, 10, ui.LEFT, "GET_INDUNINFO_DROPBOX_LIST_TOOLTIP_VIEW","GET_INDUNINFO_DROPBOX_LIST_MOUSE_OVER","GET_INDUNINFO_DROPBOX_LIST_MOUSE_OUT");
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

function INDUNINFO_MAKE_PATTERN_BOX(frame,indunCls)
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

function GET_INDUN_PATTERN_ID_LIST(indunCls)
	local ret = {};
    local dungeonType = TryGetProp(indunCls, "DungeonType");
	if string.find(dungeonType,"MythicDungeon") == 1 then
		local pattern_info = mythic_dungeon.GetPattern(mythic_dungeon.GetCurrentSeason());
		local cnt = pattern_info:GetPatternSize();
		if dungeonType == 'MythicDungeon_Auto' then
			cnt = math.min(3, cnt);
        elseif dungeonType == 'MythicDungeon_Auto_Hard' then
            cnt = math.min(4, cnt);
        end

		for i = 0,cnt-1 do
			local patternID = pattern_info:GetPattern(i);
			table.insert(ret,patternID);
		end
	end
	return ret;
end

function INDUNINFO_PATTERN_BOX_ADD_ICON(gbox,pattern,index)
	local x = 68*(index-1)
	local slot = gbox:GetSlotByIndex(index-1)
	local icon = CreateIcon(slot)
	icon:SetImage("icon_"..pattern.Icon)
	icon:SetTextTooltip(pattern.ToolTip)
end

function INDUNINFO_MAKE_DROPBOX(parent, control)
    local frame = ui.GetFrame('induninfo');
    local rewardBox = GET_CHILD_RECURSIVELY(frame, 'rewardBox');
    local controlName = control:GetName();

    local btnList, imgList = GET_INDUNINFO_MAKE_DROPBOX_BTN_LIST();
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
    INDUNINFO_DROPBOX_ITEM_LIST(parent, control)
end

function GET_INDUNINFO_MAKE_DROPBOX_BTN_LIST()
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

function INDUNINFO_DROPBOX_AFTER_BTN_DOWN(index, classname)
    local frame = ui.GetFrame('induninfo');
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

function GET_INDUNINFO_DROPBOX_LIST_MOUSE_OVER(index, classname)
    local induninfoFrame = ui.GetFrame("induninfo")
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
    currentFrame:SetLayerLevel(102);

    if induninfoFrame ~= nil then
        itemFrame:SetOffset(induninfoFrame:GetX()+1090,induninfoFrame:GetY())
    end
    INDUNINFO_DROPBOX_AFTER_BTN_DOWN(index, classname)
end

function GET_INDUNINFO_DROPBOX_LIST_TOOLTIP_VIEW(index, classname)
    local induninfoFrame = ui.GetFrame("induninfo")
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
    
    if induninfoFrame ~= nil then
        itemFrame:SetOffset(induninfoFrame:GetX()+1090,induninfoFrame:GetY())
    end
    INDUNINFO_DROPBOX_AFTER_BTN_DOWN(index, classname)
    itemFrame:SetUserValue('MouseClickedCheck','YES')
    
end

function GET_INDUNINFO_DROPBOX_LIST_MOUSE_OUT()
    local induninfoframe = ui.GetFrame('induninfo');
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

function INDUNINFO_MAKE_DETAIL_INFO_BOX(frame, indunClassID)
    local indunCls = GetClassByType('Indun', indunClassID);
    if indunCls == nil then
        return;
    end

    local resetGroupID = indunCls.PlayPerResetType;
    INDUNINFO_MAKE_DETAIL_COMMON_INFO(frame,indunCls,resetGroupID);
    INDUNINFO_SET_ENTERANCE_COUNT(frame,resetGroupID)
	INDUNINFO_SET_RESTRICT(frame,indunCls)
    INDUNINFO_SET_ADMISSION_ITEM(frame,indunCls)
    INDUNENTER_MAKE_MONLIST(frame, indunCls);
end

function INDUNINFO_MAKE_DETAIL_INFO_BOX_OTHER(frame, indunClassID)
    local contentsCls = GetClassByType('contents_info', indunClassID)
    if contentsCls == nil then
        return;
    end
    local resetGroupID = contentsCls.ResetGroupID
    INDUNINFO_MAKE_DETAIL_COMMON_INFO(frame,contentsCls,resetGroupID)
    
    INDUNINFO_SET_ENTERANCE_COUNT(frame,resetGroupID)
	INDUNINFO_SET_RESTRICT(frame,contentsCls)
    INDUNINFO_SET_ADMISSION_ITEM(frame,contentsCls)
    INDUNENTER_MAKE_MONLIST(frame, contentsCls);
end

function PVP_INDUNINFO_MAKE_DETAIL_INFO_BOX(frame, indunClassID)
    local indunCls = GetClassByType('PVPIndun', indunClassID);
    if indunCls == nil then
        return;
    end

    local resetGroupID = indunCls.GroupID;       
    INDUNINFO_MAKE_DETAIL_COMMON_INFO(frame,indunCls,resetGroupID)
    INDUNINFO_SET_RESTRICT(frame,indunCls)
    INDUNINFO_SET_ENTERANCE_TIME(frame, indunCls)
    --pvp info
    local pvpInfoSet = GET_CHILD_RECURSIVELY(frame, 'pvpInfoBox');
    pvpInfoSet:ShowWindow(0)
    if TryGetProp(indunCls,'WorldPVPType',0) ~= 0 then
        local pvpCls = GetClassByType('WorldPVPType',indunCls.WorldPVPType)
        INDUNINVO_SET_PVP_RESULT(frame,pvpCls)
    end

    frame:SetUserValue("INDUN_NAME",indunCls.ClassName)
end

---------------start draw indun tab detail ui---------------------
function INDUNINVO_SET_PVP_RESULT(frame, pvpCls)
    local pvp_info_set = GET_CHILD_RECURSIVELY(frame, 'pvpInfoBox');
    pvp_info_set:ShowWindow(1);

    local aid = session.loginInfo.GetAID();
    local pvp_obj = session.worldPVP.GetTeamBattlePVPObject(aid);
    if pvp_obj ~= nil then
        local pvp_class_name = TryGetProp(pvpCls, "ClassName", "None");
        
		local pvp_info = GET_CHILD(pvp_info_set, 'pvpInfoValue')
		local pvp_score = GET_CHILD(pvp_info_set, 'pvpScoreValue')
        
		local win = pvp_obj:GetPropValue(pvp_class_name.."_WIN", 0);
		pvp_info:SetTextByKey('win', win);
		
		local lose = pvp_obj:GetPropValue(pvp_class_name.."_LOSE", 0);
		pvp_info:SetTextByKey('lose', lose);
		
        local prop_value = win + lose;
		pvp_info:SetTextByKey('total', prop_value);
		prop_value = pvp_obj:GetPropValue(pvp_class_name.."_RP", 0);
        pvp_score:SetTextByKey('score', prop_value);
    end
    pvp_info_set:Invalidate();
    frame:Invalidate();
end

function INDUNINFO_UPDATE_PVP_RESULT(frame, msg, arg_str, arg_num)
    local pvp_name = arg_str;
    local pvp_cls = GetClass("PVPIndun", pvp_name);
    if pvp_cls ~= nil then
        local world_pvp_type = TryGetProp(pvp_cls, "WorldPVPType", 0);
        local world_pvp_cls = GetClassByType("WorldPVPType", world_pvp_type);
        if world_pvp_cls ~= nil then
            local aid = session.loginInfo.GetAID();
            local pvp_obj = session.worldPVP.GetTeamBattlePVPObject(aid);
            if pvp_obj ~= nil then
                local pvp_info_set = GET_CHILD_RECURSIVELY(frame, "pvpInfoBox");
                local pvp_info = GET_CHILD_RECURSIVELY(pvp_info_set, "pvpInfoValue");
                local pvp_score = GET_CHILD_RECURSIVELY(pvp_info_set, "pvpScoreValue");
                local world_pvp_cls_name = TryGetProp(world_pvp_cls, "ClassName", "None");
                if world_pvp_cls_name ~= "None" then
                    local win = pvp_obj:GetPropValue(world_pvp_cls_name.."_WIN", 0);
                    pvp_info:SetTextByKey("win", win);
                    
                    local lose = pvp_obj:GetPropValue(world_pvp_cls_name.."_LOSE", 0);
                    pvp_info:SetTextByKey("lose", lose);
                    
                    local prop_value = win + lose;
                    pvp_info:SetTextByKey("total", prop_value);

                    prop_value = pvp_obj:GetPropValue(world_pvp_cls_name.."_RP", 0);
                    pvp_score:SetTextByKey("score", prop_value);
                end
                pvp_info_set:Invalidate();
                frame:Invalidate();
            end
        end
    end
end

function INDUNINFO_MAKE_DETAIL_COMMON_INFO(frame, indunCls, resetGroupID)
    -- name
    local nameBox = GET_CHILD_RECURSIVELY(frame, 'nameBox');
    local nameText = nameBox:GetChild('nameText');    
    nameText:SetTextByKey('name', indunCls.Name);
    
    -- picture
    local indunPic = GET_CHILD_RECURSIVELY(frame, 'indunPic');
    indunPic:RemoveAllChild();
    indunPic:SetImage(indunCls.MapImage);

    -- level
    local lvData = GET_CHILD_RECURSIVELY(frame, 'lvData');
    lvData:SetText(indunCls.Level);

        -- position
        local posBox = GET_CHILD_RECURSIVELY(frame, 'posBox');
    DESTROY_CHILD_BYNAME(posBox, "MAP_CTRL_");
        posBox:ShowWindow(0);

        -- score
        local scoreBox = GET_CHILD_RECURSIVELY(frame, 'scoreBox');
        scoreBox:ShowWindow(0);

    local dungeon_type = TryGetProp(indunCls, "DungeonType", "None");
    local sub_type = TryGetProp(indunCls, "SubType", "None");
    if dungeon_type == "TOSHero" then
        scoreBox:ShowWindow(1);
    else
        -- notice text
        local map_box = GET_CHILD_RECURSIVELY(frame, "mapBox");
        if map_box ~= nil then
            local notice_text = GET_CHILD_RECURSIVELY(map_box, "noticeText");
            if notice_text ~= nil then
                if dungeon_type == "Solo_dungeon" then
                    notice_text:ShowWindow(1);
                    notice_text:SetTextByKey("text", ClMsg("InduninfoSoloDungeonNotice"));
                else
                    notice_text:ShowWindow(0);
                end
            end
        end

        local raid_time_box = GET_CHILD_RECURSIVELY(frame, "raid_time_box");
        if raid_time_box ~= nil then 
        raid_time_box:ShowWindow(0);
        end
        
        local mapList = StringSplit(TryGetProp(indunCls, "StartMap", ""), '/');
        -- 챌린지 분열 특이점 모드 & 분열 특이점 모드 자동매칭 예외처리
        if resetGroupID == -101 or resetGroupID == 816 then
            local sysTime = geTime.GetServerSystemTime();
            -- 오늘 요일의 맵만 표시
            local curMapName = mapList[sysTime.wDayOfWeek + 1]
            mapList = { curMapName }
        end
        -- 레벨 던전 체크
        local is_level_dungeon = false;
        if (dungeon_type == "Indun" or dungeon_type == "MissionIndun") and sub_type == "Level" then
            is_level_dungeon = true;
        end
        -- 시작 맵 생성
        for i = 1, #mapList do
            local map_cls = GetClass('Map', mapList[i]);    
            if map_cls ~= nil then
                local map_class_id = TryGetProp(map_cls, "ClassID", 0);
                local map_name = TryGetProp(map_cls, "Name", "None");
                local map_ctrlset_name = "indun_pos_ctrl";
                if is_level_dungeon == true then
                    map_ctrlset_name = "indun_pos_ctrl_leveldungeon";
        end

                local map_ctrl_set = posBox:CreateOrGetControlSet(map_ctrlset_name, "MAP_CTRL_"..map_class_id, 0, 0);
                if map_ctrl_set ~= nil then
                    if is_level_dungeon == true then
                        map_ctrl_set:SetGravity(ui.LEFT, ui.TOP);
                        map_ctrl_set:SetOffset(100 + (i - 1) * 100, 10);
                        map_ctrl_set:SetUserValue("INDUN_CLASS_ID", indunClassID);
                        map_ctrl_set:SetUserValue("INDUN_START_MAP_ID", map_class_id);
                        local map_name_text = GET_CHILD_RECURSIVELY(map_ctrl_set, "text_map_name");
                        if map_name_text ~= nil then
                            map_name_text:SetText(map_name);
                        end
                        local world_map_btn = GET_CHILD_RECURSIVELY(map_ctrl_set, "btn_world_map");
                        if world_map_btn ~= nil then
                            world_map_btn:SetMargin(map_name_text:GetWidth(), 0, 0, 0);
                        end
                    else
                        map_ctrl_set:SetGravity(ui.RIGHT, ui.TOP);
                        map_ctrl_set:SetOffset(0, 10 + (10 + map_ctrl_set:GetHeight()) * (i-1));
                        map_ctrl_set:SetUserValue('INDUN_CLASS_ID', indunClassID);
                        map_ctrl_set:SetUserValue('INDUN_START_MAP_ID', map_class_id);
                        local map_name_text = map_ctrl_set:GetChild('mapNameText');
                        if map_name_text ~= nil then
                            map_name_text:SetText(map_name);
                        end
                    end
                end
            end
        end
        posBox:ShowWindow(1);
    end
    INDUNINFO_SET_BUTTONS(frame,indunCls)
    INDUNINFO_MAKE_PATTERN_BOX(frame,indunCls)
end

function INDUNINFO_SET_ENTERANCE_TIME_BY_RAID(frame, indunCls)
    local raid_time_box = GET_CHILD_RECURSIVELY(frame, "raid_time_box");
    raid_time_box:ShowWindow(1);

    local raid_time_data = GET_CHILD_RECURSIVELY(raid_time_box, "raid_time_data");
    local start_time, end_time = "None", "None";
    if indunCls.DungeonType == "MythicDungeon_Auto_Hard" then
        local cls = GetClass("mythic_rule", "myrhic_hard");
        if cls ~= nil then
            start_time = string.format("%02d:%02d", TryGetProp(cls, "ClientStartHour", 0), 0);
            end_time = string.format("%02d:%02d", TryGetProp(cls, "ClientEndHour", 0), 0);
        end
    end
    raid_time_data:SetTextByKey("start", start_time);
    raid_time_data:SetTextByKey("end", end_time);

    local raid_day_pic = GET_CHILD_RECURSIVELY(raid_time_box, "raid_day_pic");
    raid_day_pic:ShowWindow(1);
    INDUNINFO_SET_CYCLE_PIC(raid_day_pic, indunCls, '_l');
end

function INDUNINFO_SET_ENTERANCE_TIME(frame,indunCls)
    --time
    local pvpbox = GET_CHILD_RECURSIVELY(frame, 'pvpbox');
    local timeData = GET_CHILD_RECURSIVELY(pvpbox,'timeData')
    if GetServerNation() == "GLOBAL" then
        local appendStr = ""
        local ruleCls = GetClass("pvp_teambattle_rule", "pvp_teambattle_rule_steam_"..GetServerGroupID())
        if ruleCls ~= nil then
            indunCls = ruleCls
        else
            appendStr = "Global"
        end
        local start_time = string.format("%02d:%02d", TryGetProp(indunCls, appendStr.."StartHour", 0), TryGetProp(indunCls, appendStr.."StartMin", 0));
        local end_time = string.format("%02d:%02d", TryGetProp(indunCls, appendStr.."EndHour", 0), TryGetProp(indunCls, appendStr.."EndMin", 0));
        timeData:SetTextByKey("start", start_time);
        timeData:SetTextByKey("end", end_time);        
    else
        local startTime = string.format("%02d:%02d",TryGetProp(indunCls,"StartHour",0),TryGetProp(indunCls,"StartMin",0))
        local endTime = string.format("%02d:%02d",TryGetProp(indunCls,"EndHour",0),TryGetProp(indunCls,"EndMin",0))
        timeData:SetTextByKey('start', startTime);
        timeData:SetTextByKey('end', endTime);
    end

    local dayPic = GET_CHILD_RECURSIVELY(frame,'dayPic')
    dayPic:ShowWindow(1)
    INDUNINFO_SET_CYCLE_PIC(dayPic,indunCls,'_l')
	
    if config.GetServiceNation() == 'GLOBAL' then
        local margin = dayPic:GetOriginalMargin();
        dayPic:SetMargin(margin.left+25, margin.top, margin.right, margin.bottom)
    end
end

function INDUNINFO_SET_ENTERANCE_COUNT(frame, resetGroupID)
    --todo
    local count_box = GET_CHILD_RECURSIVELY(frame, "countBox");
    count_box:ShowWindow(1);
    local dungeon_restrict_category_box = GET_CHILD_RECURSIVELY(frame, "gbox_ct_dungeon_restrict")dungeon_restrict_category_box:ShowWindow(0);
    local countData = GET_CHILD_RECURSIVELY(frame, 'countData');
    local countData2 = GET_CHILD_RECURSIVELY(frame, 'countData2');
    if resetGroupID == -101 or resetGroupID == 816 or resetGroupID == 817 or resetGroupID == 813 or resetGroupID == 807 or resetGroupID == 5000 or resetGroupID == 820 then
        countData2:SetTextByKey('now', GET_CURRENT_ENTERANCE_COUNT(resetGroupID))
        countData:ShowWindow(0)
        countData2:ShowWindow(1)
    else
        countData:SetTextByKey('now', GET_CURRENT_ENTERANCE_COUNT(resetGroupID));
        countData:SetTextByKey('max', GET_INDUN_MAX_ENTERANCE_COUNT(resetGroupID));
        countData2:ShowWindow(0)
        countData:ShowWindow(1)
    end
    INDUNENTER_MAKE_MONLIST(frame, indunCls);
end

function INDUNINFO_SET_RESTRICT(frame,indunCls)
	INDUNINFO_SET_RESTRICT_SKILL(frame,indunCls)
    INDUNINFO_SET_RESTRICT_ITEM(frame,indunCls)
    INDUNINFO_SET_RESTRICT_DUNGEON(frame,indunCls)
    local restrictBox = GET_CHILD_RECURSIVELY(frame, 'restrictBox');
    restrictBox:EnableScrollBar(0);
    GBOX_AUTO_ALIGN(restrictBox, 2, 2, 0, true, true,true);
end

function INDUNINFO_SET_RESTRICT_SKILL(frame,indunCls)
    -- skill restriction
	local restrictSkillBox = GET_CHILD_RECURSIVELY(frame, 'restrictSkillBox');
    restrictSkillBox:ShowWindow(0);
    local mapName = TryGetProp(indunCls, "MapName");
    local dungeonType = TryGetProp(indunCls, "DungeonType");
    local isLegendRaid = BoolToNumber(dungeonType == "Raid" or dungeonType == "GTower" or string.find(dungeonType, "MythicDungeon") == 1);

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

function INDUNINFO_SET_RESTRICT_ITEM(frame,indunCls)
    local restrictItemBox = GET_CHILD_RECURSIVELY(frame, 'restrictItemBox');
    restrictItemBox:ShowWindow(0);
	local cls = GetClassByStrProp("ItemRestrict", "Category", indunCls.ClassName)
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

function INDUNINFO_SET_RESTRICT_DUNGEON(frame,indunCls)
    local restrictDungeonBox = GET_CHILD_RECURSIVELY(frame, 'restrictDungeonBox');
    restrictDungeonBox:ShowWindow(0);
    local cls = GetClassByStrProp("dungeon_restrict", "Category", indunCls.ClassName)    
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

function INDUNINFO_SET_BUTTONS_FIND_CLASS(indunCls, subTypeCompare)
    local btnInfoCls = nil;
    if indunCls ~= nil then
        local dungeonType = TryGetProp(indunCls, "DungeonType", "None");
        local subType = TryGetProp(indunCls, "SubType", "None");
        if dungeonType == nil or subType == nil then 
            return nil; 
        end

        local list, cnt = GetClassList("IndunInfoButton");
        if list ~= nil then
            for i = 0, cnt - 1 do
                local cls = GetClassByIndexFromList(list, i);
                if cls ~= nil then
                    local dungeon_type = TryGetProp(cls, "DungeonType", "None");
                    if dungeon_type == "MoveEnterNPC" and dungeon_type == "Raid_MoveEnterNPC" or dungeon_type == "Raid_HardEnter" then
                        dungeon_type = "Raid";
                    end

                    if dungeon_type ~= nil and dungeon_type ~= "None" and (dungeon_type == dungeonType or subType == "MoveEnterNPC" or subType == "Pilgrim" or dungeonType == "GTower" or subType == "Hard") then
                        local sub_type = TryGetProp(cls, "SubType", "None");
                        if sub_type ~= nil and sub_type ~= "None" and sub_type == subType then
                            btnInfoCls = cls;
                            break;
                        end
                    end

                    if subTypeCompare == true then
                        local sub_type = TryGetProp(cls, "SubType", "None");
                        if dungeon_type == dungeonType and sub_type == subType then
                            btnInfoCls = cls;
                            break;
                        end
                    end
                end
            end
        end
    end 
    return btnInfoCls;
end

function INDUNINFO_SET_BUTTONS(frame, indunCls)
    local buttonBox = GET_CHILD_RECURSIVELY(frame, 'buttonBox');
    local dungeonType = TryGetProp(indunCls, "DungeonType", "None");
    local btnInfoCls = GetClassByStrProp("IndunInfoButton", "DungeonType", dungeonType);

    GET_CHILD_RECURSIVELY(buttonBox, 'recordButton'):ShowWindow(0);

    if dungeonType == "TOSHero" then
        GET_CHILD_RECURSIVELY(buttonBox, 'tinyButton'):ShowWindow(1);
    else
        GET_CHILD_RECURSIVELY(buttonBox, 'tinyButton'):ShowWindow(0);
    end

    local mGameName = TryGetProp(indunCls, "MGame", "None")
    local raidCls = GetClass("raid_record_list", mGameName)

    if raidCls ~= nil then
        local recordBtn = GET_CHILD_RECURSIVELY(buttonBox, 'recordButton');
        recordBtn:ShowWindow(1)
        recordBtn:SetEventScript(ui.LBUTTONUP, TryGetProp(raidCls, "ButtonScp", "None"));
        recordBtn:SetEventScriptArgString(ui.LBUTTONUP, mGameName);
        INDUNINFO_RESIZE_BY_BUTTONS(frame,1)
    end

    if btnInfoCls == nil then
        local redButton = GET_CHILD_RECURSIVELY(buttonBox,'RedButton')
        redButton:ShowWindow(0)
        for i = 1, 3 do
            local button = GET_CHILD_RECURSIVELY(buttonBox,'Button'..i)
            button:ShowWindow(0)
        end
        if raidCls == nil then
        INDUNINFO_RESIZE_BY_BUTTONS(frame,0)
        end
        return;
    end
    
    if dungeonType == "Raid" then
        if indunCls.SubType ~= "Casual" and indunCls.SubType ~= "Auto" and indunCls.SubType ~= "MoveEnterNPC" and indunCls.SubType ~= "Hard" and indunCls.SubType ~= "Pilgrim" then
            local redButton = GET_CHILD_RECURSIVELY(buttonBox,'RedButton')
            redButton:ShowWindow(0)
            for i = 1, 3 do
                local button = GET_CHILD_RECURSIVELY(buttonBox,'Button'..i)
                button:ShowWindow(0)
            end
            if raidCls == nil then
            INDUNINFO_RESIZE_BY_BUTTONS(frame,0)
            end
            return;
        end
        btnInfoCls = INDUNINFO_SET_BUTTONS_FIND_CLASS(indunCls);
    elseif string.find(dungeonType, "MythicDungeon") ~= nil then
        btnInfoCls = INDUNINFO_SET_BUTTONS_FIND_CLASS(indunCls, true);
    elseif dungeonType == "EarringRaid" and indunCls.SubType == "Pilgrim" then
        btnInfoCls = INDUNINFO_SET_BUTTONS_FIND_CLASS(indunCls);
        local recordBtn = GET_CHILD_RECURSIVELY(buttonBox, 'recordButton');
        recordBtn:ShowWindow(0);
    elseif (dungeonType == "Indun" or dungeonType == "MissionIndun") and indunCls.SubType == "Level" then
        btnInfoCls = INDUNINFO_SET_BUTTONS_FIND_CLASS(indunCls);
    end

    local type = 0
    local redButtonScp = TryGetProp(btnInfoCls,"RedButtonScp")
    local redButton = GET_CHILD_RECURSIVELY(buttonBox,'RedButton')
    local redButtonText = GET_CHILD_RECURSIVELY(redButton,'RedButtonText')
    if redButtonScp ~= 'None' then
        redButton:SetEventScript(ui.LBUTTONUP,redButtonScp)        
		redButton:SetUserValue('MOVE_INDUN_CLASSID', indunCls.ClassID);
		redButton:ShowWindow(1)
		redButton:SetEnable(1)
        redButtonText:SetTextByKey("btnText", btnInfoCls.RedButtonText)
        redButtonText:ShowWindow(1)
        type = 1
    else
        redButton:ShowWindow(0)
    end
    for i = 1,3 do
        local button = GET_CHILD_RECURSIVELY(buttonBox,'Button'..i)
        local buttonText = GET_CHILD_RECURSIVELY(button,'Button'..i.."Text")
        local buttonScp = TryGetProp(btnInfoCls,"Button"..i.."Scp")
        if buttonScp ~= 'None' then
            local text = TryGetProp(btnInfoCls,"Button"..i.."Text","None")
            button:SetEventScript(ui.LBUTTONUP,buttonScp)
			button:SetEventScriptArgString(ui.LBUTTONUP,indunCls.ClassName)
            button:ShowWindow(1)
            buttonText:SetTextByKey("btnText",text)
            buttonText:ShowWindow(1)
            type = math.max(BoolToNumber(i<=2)+1,type)
        else
            button:ShowWindow(0)
        end
    end
    -- if config.GetServiceNation() == 'GLOBAL' then
    --     moveBtn:SetTextByKey('btnText', 'Warp')
    -- end
	INDUNINFO_RESIZE_BY_BUTTONS(frame,type)
	if indunCls.ClassName == "Indun_teamBattle" then
		INDUNINFO_TEAM_BATTLE_STATE_CHANGE(frame,redButton,argStr,argNum)
	end
end

function INDUNINFO_SET_ADMISSION_ITEM(frame,indunCls)
    -- count
    local countItemData = GET_CHILD_RECURSIVELY(frame, 'countItemData');
    local countBox = GET_CHILD_RECURSIVELY(frame, 'countBox');
    local countText = GET_CHILD_RECURSIVELY(countBox, 'countText');
    local cycleCtrlPic = GET_CHILD_RECURSIVELY(countBox, 'cycleCtrlPic');
    local countData = GET_CHILD_RECURSIVELY(frame, 'countData');
    local countData2 = GET_CHILD_RECURSIVELY(frame, 'countData2');
    local cycleImage = GET_CHILD_RECURSIVELY(frame, 'cyclePic');
    local nowAdmissionItemCount = GET_INDUN_ADMISSION_ITEM_COUNT(indunCls)
    if nowAdmissionItemCount <= 0 then
        countText:SetText(ScpArgMsg("IndunAdmissionItemReset"))
        if indunCls.DungeonType == 'ChallengeMode_HardMode' or string.find(indunCls.ClassName, "Challenge_Division_Auto") ~= nil or indunCls.DungeonType == "MythicDungeon_Auto_Hard" or indunCls.DungeonType == "MythicDungeon" or TryGetProp(indunCls, "PlayPerResetType",-1) == 807 or indunCls.DungeonType == 'TOSHero' or indunCls.DungeonType == "EarringRaid" then
            countData:ShowWindow(0);
            countData2:ShowWindow(1);
        else
            countData2:ShowWindow(0);
            countData:ShowWindow(1);
        end
        countItemData:ShowWindow(0);
        INDUNINFO_SET_CYCLE_PIC(cycleImage,indunCls,'_l')
        cycleCtrlPic:ShowWindow(0)
    else
        countText:SetText(ScpArgMsg("IndunAdmissionItem"))
        countData:ShowWindow(0);
        countItemData:ShowWindow(1);
        INDUNINFO_SET_CYCLE_PIC(cycleCtrlPic, indunCls, '_l')
        cycleImage:ShowWindow(0);

        if nowAdmissionItemCount >= 100 then
            local margin = cycleCtrlPic:GetOriginalMargin();
            cycleCtrlPic:SetMargin(margin.left, margin.top, margin.right + 10, margin.bottom);
        end

        local admissionItemName = TryGetProp(indunCls, "AdmissionItemName");
        local admissionItemCls = GetClass('Item', admissionItemName);
        local admissionItemIcon = TryGetProp(admissionItemCls, "Icon");
        countItemData:SetTextByKey('admissionitem', '  {img '..admissionItemIcon..' 30 30}  '..nowAdmissionItemCount..'')
    end
end

function GET_INDUN_ADMISSION_ITEM_COUNT(indunCls)
    local etc = GetMyEtcObject();
    if TryGetProp(indunCls,"UnitPerReset","None") == 'ACCOUNT' then
        etc = GetMyAccountObj()
    end
    local admissionItemName = TryGetProp(indunCls, "AdmissionItemName");
    if admissionItemName == nil or admissionItemName == "None" then
        return 0;
    end
    local resetGroupID = indunCls.PlayPerResetType;
    if ((indunCls.DungeonType == "Raid" or indunCls.DungeonType == "GTower") and (indunCls.WeeklyEnterableCount > GET_CURRENT_ENTERANCE_COUNT(resetGroupID))) then
        return 0
    end
    local admissionPlayAddItemCount = TryGetProp(indunCls, "AdmissionPlayAddItemCount");
    local addCount = TryGetProp(etc, "InDunCountType_"..tostring(TryGetProp(indunCls, "PlayPerResetType")));
    if indunCls.WeeklyEnterableCount ~= 0 then
        addCount = GET_CURRENT_ENTERANCE_COUNT(resetGroupID) - indunCls.WeeklyEnterableCount;
        if addCount < 0 then
            addCount = 0;
        end
    end
    addCount = math.floor(addCount * admissionPlayAddItemCount)

    local pc = GetMyPCObject()
    local accountObject = GetMyAccountObj()
    local admissionItemCount = TryGetProp(indunCls, "AdmissionItemCount",0);
    local nowAdmissionItemCount = admissionItemCount + addCount
    if indunCls.DungeonType == 'UniqueRaid' then
        if IsBuffApplied(pc, "Event_Unique_Raid_Bonus") == "YES" then
			nowAdmissionItemCount  = admissionItemCount
        elseif IsBuffApplied(pc, "Event_Unique_Raid_Bonus_Limit") == "YES" and TryGetProp(accountObject,"EVENT_UNIQUE_RAID_BONUS_LIMIT") > 0 then
            nowAdmissionItemCount  = admissionItemCount
        end
    end
    return nowAdmissionItemCount;
end

function INDUNINFO_RESIZE_BY_BUTTONS(frame,type)
    local resizeHeight = 0
    --set resize height
    if type > 0 then
        resizeHeight = tonumber(frame:GetUserConfig('HEIGHT_RESIZE_FOR_BUTTON'));
    end
    --resize
    local posBox = GET_CHILD_RECURSIVELY(frame, 'posBox');
    posBox:Resize(posBox:GetWidth(), posBox:GetOriginalHeight() - resizeHeight);

    local monBox = GET_CHILD_RECURSIVELY(frame, 'monBox');
    local mon_margin = monBox:GetOriginalMargin();
    monBox:SetMargin(mon_margin.left, mon_margin.top - resizeHeight, mon_margin.right, mon_margin.bottom);

    local rewardBox = GET_CHILD_RECURSIVELY(frame, 'rewardBox');
    local reward_margin = rewardBox:GetOriginalMargin();
    rewardBox:SetMargin(reward_margin.left, reward_margin.top - resizeHeight, reward_margin.right, reward_margin.bottom);

    local patternBox = GET_CHILD_RECURSIVELY(frame, 'patternBox');
    local reward_margin = patternBox:GetOriginalMargin();
	patternBox:SetMargin(reward_margin.left, reward_margin.top - resizeHeight, reward_margin.right, reward_margin.bottom);
end
---------------end draw indun tab detail ui---------------------
function INDUNINFO_SORT_BY_LEVEL(parent, ctrl)
    local topFrame = parent:GetTopParentFrame();
    local infoBox = GET_CHILD_RECURSIVELY(topFrame, "infoBox");
    if infoBox:IsVisible() == 0 then 
        return;
    end

    local tab = GET_CHILD(topFrame, "tab");
    local index = tab:GetSelectItemIndex();
    
    local groupID = topFrame:GetUserValue('SELECT')
    local radioBtn = GET_CHILD_RECURSIVELY(topFrame, 'lvAscendRadio');
    local selectedBtn = radioBtn:GetSelectedButton();
    if selectedBtn:GetName() == 'lvAscendRadio' then
        if groupID ~= "Challenge" then
            table.sort(g_selectedIndunTable, SORT_BY_LEVEL_BASE_NAME);
        end

        local is_raid_tab = index == 2 or index == 0;
        if is_raid_tab == true and groupID ~= "Gtower" then
            table.sort(g_selectedIndunTable, SORT_RAID_BY_RAID_TYPE);
        end
    else
        table.sort(g_selectedIndunTable, SORT_BY_LEVEL_REVERSE);
    end

    local SCROLL_WIDTH = 20
    if index == 6 then
        SCROLL_WIDTH = 0
    end
    local MARGIN = 18
    local indunListBox = GET_CHILD_RECURSIVELY(topFrame, 'INDUN_LIST_BOX');    
    local startY = 0;    
    local firstChild = indunListBox:GetChild('DETAIL_CTRL_'..indunListBox:GetUserValue('FIRST_INDUN_ID'));
    if firstChild ~= nil then
    firstChild = tolua.cast(firstChild, 'ui::CControlSet');
        startY = firstChild:GetY();    
    end
    
    for i = 1, #g_selectedIndunTable do
        local indunCls = g_selectedIndunTable[i];        
        local detailCtrl = indunListBox:GetChild('DETAIL_CTRL_'..indunCls.ClassID);    
        if detailCtrl ~= nil then
            detailCtrl:SetOffset(detailCtrl:GetX(), startY + detailCtrl:GetHeight()*(i-1));                
            INDUNINFO_DETAIL_SET_SKIN(detailCtrl,i)
            local skinBox = GET_CHILD(detailCtrl, 'skinBox');
            skinBox:Resize(detailCtrl:GetWidth() - SCROLL_WIDTH - MARGIN, skinBox:GetHeight());
            if i == 1 then
                indunListBox:SetUserValue('FIRST_INDUN_ID', indunCls.ClassID)
            end
        end
    end
    
    local firstSelectedID = indunListBox:GetUserIValue('FIRST_INDUN_ID');
    if table.find(g_contentsCategoryList,groupID) ~= 0 then
        INDUNINFO_MAKE_DETAIL_INFO_BOX_OTHER(topFrame, firstSelectedID)
    elseif topFrame:GetUserValue('CONTENTS_ALERT') ~= 'TRUE' then
        INDUNINFO_MAKE_DETAIL_INFO_BOX(topFrame, firstSelectedID);
    end
    
    if topFrame:GetUserValue('CONTENTS_ALERT') ~= 'TRUE' then
        indunListBox:SetUserValue('SELECTED_DETAIL', firstSelectedID);
    end
    topFrame:SetUserValue('CONTENTS_ALERT', 'FALSE')
end

function SORT_BY_LEVEL_BASE_NAME(a, b)
    if TryGetProp(a, "Level") == nil or TryGetProp(b, "Level") == nil then
        return false;
    end

    -- Legend Raid Glacier : Easy / Noraml / Hard
    -- if string.find(a.ClassName, "Legend_Raid_Glacier") ~= nil and string.find(b.ClassName, "Legend_Raid_Glacier") ~= nil then
    --     return false;
    -- end

    if tonumber(a.Level) < tonumber(b.Level) then
        return true
    elseif tonumber(a.Level) == tonumber(b.Level) then
        return a.ClassID < b.ClassID
    else
        return false
    end
end

function SORT_BY_LEVEL(a, b)
    if TryGetProp(a, "Level") == nil or TryGetProp(b, "Level") == nil then
        return false;
    end
    return tonumber(a.Level) < tonumber(b.Level)
end

function SORT_BY_LEVEL_REVERSE(a, b)
    if TryGetProp(a, "Level") == nil or TryGetProp(b, "Level") == nil then
        return false;
    end
    if tonumber(a.Level) == tonumber(b.Level) then
        return a.Name < b.Name
    end
    return tonumber(a.Level) > tonumber(b.Level)
end

function SORT_RAID_BY_RAID_TYPE(a, b)
    if TryGetProp(a, "RaidType", "None") == "None" or TryGetProp(b, "RaidType", "None") == "None" then
        return false;
    end

    local function substitution_raid_type(raid_type)
        if raid_type == "Solo" then return 1;
        elseif raid_type == "SoloHard" then return 2;
        elseif raid_type == "AutoNormal" then return 3;
        elseif raid_type == "AutoHard" then return 4; 
        elseif raid_type == "PartyNormal" then return 5;
        elseif raid_type == "PartyHard" then return 6;
        elseif raid_type == 'PartyExtreme' then return 7
        end
    end
    
    local difficulty_a = substitution_raid_type(TryGetProp(a, "RaidType", "None"));
    local difficulty_b = substitution_raid_type(TryGetProp(b, "RaidType", "None"));
    return difficulty_a < difficulty_b;
end

function INDUNINFO_OPEN_INDUN_MAP(parent, ctrl)
    local mapID = parent:GetUserValue('INDUN_START_MAP_ID')
    local mapName = GetClassByType("Map", mapID).ClassName
    local episode = GET_EPISODE_BY_MAPNAME(mapName)
 
    if episode == nil then
        return
    end
    
    ui.OpenFrame("worldmap2_mainmap")

    WORLDMAP2_OPEN_SUBMAP_FROM_MAINMAP_BY_EPISODE(episode)
    WORLDMAP2_SUBMAP_ZONE_CHECK(mapName)
end

function INDUN_CANNOT_YET(...)
    ui.SysMsg(ScpArgMsg(...));
    ui.OpenFrame("party");
end

function INDUNINFO_TAB_CHANGE(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	local tab = GET_CHILD_RECURSIVELY(frame, "tab");
	local index = tab:GetSelectItemIndex();
    if index == 0 or index == 1 or index == 2 then
		INDUNINFO_UI_OPEN(frame, index);
    elseif index == 3 then
        WEEKLYBOSSINFO_UI_OPEN(frame);
    elseif index == 4 then
		FIELD_BOSS_UI_OPEN(frame);
	elseif index == 5 then
        BORUTA_RANKING_UI_OPEN(frame);
    elseif index == 6 then
        PVP_INDUNINFO_UI_OPEN(frame);
	elseif index == 7 then
        RAID_RANKING_UI_OPEN(frame);
	end
	TOGGLE_INDUNINFO(frame,index)
end

function PVP_INDUNINFO_UI_OPEN(frame)
	INDUNINFO_RESET_USERVALUE(frame);
	worldPVP.RequestPVPInfo();
	local categoryBox = GET_CHILD_RECURSIVELY(frame, 'categoryBox');
	categoryBox:RemoveAllChild();

    local infoBox = GET_CHILD_RECURSIVELY(frame, 'infoBox')
    infoBox:ShowWindow(1)
    
    local categoryBtnWidth = categoryBox:GetWidth();
    local resetGroupTable = {};
    local indunClsList, cnt = GetClassList('PVPIndun');
    local firstBtn = nil
    for i = 0, cnt - 1 do
        local indunCls = GetClassByIndexFromList(indunClsList, i);
        if indunCls ~= nil and TryGetProp(indunCls,"Category","None") ~= 'None' then
            local groupID = indunCls.GroupID;
            local categoryCtrl = categoryBox:GetChild('CATEGORY_CTRL_'..groupID);      
            if categoryCtrl == nil then
                categoryCtrl = categoryBox:CreateOrGetControlSet('pvp_indun_cate_ctrl', 'CATEGORY_CTRL_'..groupID, 0, i * 50);
                local btn = categoryCtrl:GetChild("button");
                btn:Resize(categoryBtnWidth, categoryCtrl:GetHeight());
                local name = categoryCtrl:GetChild("name");
                local category = indunCls.Category;
                name:SetTextByKey("value", category);
                categoryCtrl:SetUserValue('RESET_GROUP_ID', groupID);
                if firstBtn == nil then
                    firstBtn = GET_CHILD(categoryCtrl,"button")
                end
            end
            INDUNINFO_ADD_COUNT(resetGroupTable,groupID)
            do --time setting
                local timeText = categoryCtrl:GetChild("timeText");
                if GetServerNation() == "GLOBAL" then
                    local appendStr = ""
                    local ruleCls = GetClass("pvp_teambattle_rule", "pvp_teambattle_rule_steam_"..GetServerGroupID())
                    if ruleCls ~= nil then
                        indunCls = ruleCls
                    else
                        appendStr = "Global"
                    end
                    local start_time = string.format("%02d:%02d", TryGetProp(indunCls, appendStr.."StartHour", 0), TryGetProp(indunCls, appendStr.."StartMin", 0));
                    local end_time = string.format("%02d:%02d", TryGetProp(indunCls, appendStr.."EndHour", 0), TryGetProp(indunCls, appendStr.."EndMin", 0));
                    timeText:SetTextByKey("start", start_time);
                    timeText:SetTextByKey("end", end_time);                     
                else
                    local startTime = string.format("%02d:%02d",indunCls.StartHour,indunCls.StartMin)
                    if startTime < timeText:GetTextByKey("start") then
                        timeText:SetTextByKey("start",startTime)
                    end
                    local endTime = string.format("%02d:%02d",indunCls.EndHour,indunCls.EndMin)
                    if endTime > timeText:GetTextByKey("end") then
                        timeText:SetTextByKey("end",endTime)
                    end
                end
            end
        end
    end
    INDUNINFO_CATEGORY_ALIGN_DEFAULT(categoryBox);

    -- default select
    PVP_INDUNINFO_CATEGORY_LBTN_CLICK(firstBtn:GetParent(), firstBtn);
end

function PVP_INDUNINFO_CATEGORY_LBTN_CLICK(categoryCtrl, ctrl)
    local topFrame = categoryCtrl:GetTopParentFrame();
    local preSelectType = topFrame:GetUserIValue('SELECT');
    local selectedResetGroupID = categoryCtrl:GetUserIValue('RESET_GROUP_ID');
    if preSelectType == selectedResetGroupID then    
        return;
    end
    -- set button skin
    INDUNINFO_CHANGE_CATEGORY_BUTTON_SKIN(topFrame,categoryCtrl)

    -- make indunlist
    local categoryBox = GET_CHILD_RECURSIVELY(topFrame, 'categoryBox');
    local indunListBox = INDUNINFO_RESET_INDUN_LISTBOX(categoryBox)
    local indunClsList, cnt = GetClassList('PVPIndun');    
    local firstBtn = nil
    for i = 0, cnt - 1 do
        local indunCls = GetClassByIndexFromList(indunClsList, i);
        if indunCls.GroupID == selectedResetGroupID and indunCls.Category ~= 'None' then
            local indunDetailCtrl = indunListBox:CreateOrGetControlSet('indun_detail_ctrl', 'DETAIL_CTRL_'..indunCls.ClassID, 0, 0);
            indunDetailCtrl = tolua.cast(indunDetailCtrl, 'ui::CControlSet');
            indunDetailCtrl:SetUserValue('INDUN_CLASS_ID', indunCls.ClassID);
            indunDetailCtrl:SetEventScript(ui.LBUTTONUP, 'INDUNINFO_DETAIL_LBTN_CLICK');

            local infoText = indunDetailCtrl:GetChild('infoText');
            local nameText = indunDetailCtrl:GetChild('nameText');
            local infoTextrect = infoText:GetMargin();
            indunDetailCtrl:GetChild('countText'):ShowWindow(0);
            indunDetailCtrl:GetChild('cycleCtrlPic'):ShowWindow(0);
            nameText:SetMargin(infoTextrect.left,infoTextrect.top,infoTextrect.right,infoTextrect.bottom)
            nameText:SetTextByKey('name', indunCls.Name);
            indunDetailCtrl:RemoveChild('infoText')

            PVP_INDUNINFO_DETAIL_SET_ONLINE_PIC(indunDetailCtrl)

            INDUNINFO_PUSH_BACK_TABLE(g_selectedIndunTable,indunCls)
            INDUNINFO_DETAIL_SET_SKIN(indunDetailCtrl,#g_selectedIndunTable)
            if firstBtn == nil then
                firstBtn = indunDetailCtrl
            end
        end
    end
    GBOX_AUTO_ALIGN(indunListBox, 0, 2, 0, true, true);

    -- category box align
    INDUNINFO_CATEGORY_ALIGN_DEFAULT(categoryBox);
    INDUNINFO_DETAIL_LBTN_CLICK(firstBtn:GetParent(),firstBtn);
end 

function PVP_INDUNINFO_DETAIL_SET_ONLINE_PIC(indunDetailCtrl)
    local indunClsID = indunDetailCtrl:GetUserValue('INDUN_CLASS_ID');
	local indunCls = GetClassByType("PVPIndun", indunClsID);
    local startTime = geTime.GetServerSystemTime();
    local endTime = geTime.GetServerSystemTime();
    local start_hour, start_min, end_hour, end_min;
    if GetServerNation() == "GLOBAL" then
        start_hour = TryGetProp(indunCls, "GlobalStartHour", 0);
        start_min = TryGetProp(indunCls, "GlobalStartMin", 0);
        end_hour = TryGetProp(indunCls, "GlobalEndHour", 0);
        end_min =  TryGetProp(indunCls, "GlobalEndMin", 0);
    else
        start_hour = TryGetProp(indunCls, "StartHour", 0);
        start_min = TryGetProp(indunCls, "StartMin", 0);
        end_hour = TryGetProp(indunCls, "EndHour", 0);
        end_min =  TryGetProp(indunCls, "EndMin", 0);
    end

    startTime.wHour = start_hour;
    startTime.wMinute = start_min;
    startTime.wSecond = 0;
    endTime.wHour = end_hour;
    if end_hour >= 24 then
        endTime.wDay = endTime.wDay + 1
        endTime.wHour = endTime.wHour - 24;
    elseif end_hour < start_hour then
        endTime.wDay = endTime.wDay + 1;
    elseif end_hour == start_hour and end_min < start_min then
        endTime.wDay = endTime.wDay + 1;
    end
    endTime.wMinute = end_min;
    endTime.wSecond = 0;

    if imcTime.GetDiffSecFromNow(startTime) >= 0 then
        if imcTime.GetDiffSecFromNow(endTime) < 0 then
            local onlinePic = indunDetailCtrl:GetChild('onlinePic');
            AUTO_CAST(onlinePic);
            onlinePic:SetImage('guild_online');
        end
    end
end

function INDUNINFO_CHANGE_CATEGORY_BUTTON_SKIN(frame,categoryCtrl)
    local preSelectType = frame:GetUserValue('SELECT');
    local selectedGroupID = categoryCtrl:GetUserValue('RESET_GROUP_ID');
    categoryCtrl = tolua.cast(categoryCtrl, 'ui::CControlSet');

    local SELECTED_BTN_SKIN = categoryCtrl:GetUserConfig('SELECTED_BTN_SKIN');
    local NOT_SELECTED_BTN_SKIN = categoryCtrl:GetUserConfig('NOT_SELECTED_BTN_SKIN');
    local preSelect = GET_CHILD_RECURSIVELY(frame, "CATEGORY_CTRL_" .. preSelectType);
    if nil ~= preSelect then
        local button = preSelect:GetChild("button");
        button:SetSkinName(NOT_SELECTED_BTN_SKIN);
    end
    frame:SetUserValue('SELECT', selectedGroupID);
    local ctrl = categoryCtrl:GetChild("button");
    ctrl:SetSkinName(SELECTED_BTN_SKIN);
end



function INDUNINFO_RESET_INDUN_LISTBOX(categoryBox)
    local listBoxWidth = categoryBox:GetWidth() - 20;
    categoryBox:RemoveChild('INDUN_LIST_BOX');
    g_selectedIndunTable = {};
    g_selected_indun_category_table = {};
    local indunListBox = categoryBox:CreateControl('groupbox', 'INDUN_LIST_BOX', 5, 0, listBoxWidth, 30);
    indunListBox = tolua.cast(indunListBox, 'ui::CGroupBox');
    indunListBox:EnableDrawFrame(0);
    indunListBox:EnableScrollBar(0);
    return indunListBox
end

function INDUNINFO_DETAIL_SET_SKIN(indunDetailCtrl,index)
    local skinBox = GET_CHILD(indunDetailCtrl, 'skinBox');
    if index % 2 == 0 then
        skinBox:SetSkinName(NOT_SELECTED_BOX_SKIN);
    else
        skinBox:SetSkinName('None');
    end
end

function ON_PVPMINE_HELP(parent,ctrl,argStr,argNum)
    local piphelp = ui.GetFrame("piphelp");
	PIPHELP_MSG(piphelp, "FORCE_OPEN", argStr,  551)
end

function ON_TEAMBATTLE_HELP(parent,ctrl,argStr,argNum)
    local piphelp = ui.GetFrame("piphelp");
	PIPHELP_MSG(piphelp, "FORCE_OPEN", argStr,  19)
end

function ON_JOIN_PVP_MINE(parent,ctrl,argStr,argNum)
	local classID = ctrl:GetUserValue('MOVE_INDUN_CLASSID')
	local yesScp = string.format("_ON_JOIN_PVP_MINE(%d)",classID)
    ui.MsgBox(ClMsg('EnterRightNow'), yesScp, 'None');
end

function _ON_JOIN_PVP_MINE(classID)
	local cls = GetClassByType("PVPIndun",classID)
	pc.ReqExecuteTx("SCR_PVP_MINE_ENTER",cls.ClassName)
end

function ON_JOIN_TEAM_BATTLE(parent,ctrl)
	if IS_TEAM_BATTLE_ENABLE() == 0 then
		ctrl:SetEnable(0)
		return
	end
    local adventure_book = ui.GetFrame('adventure_book')
    local adventure_book_btn = GET_CHILD_RECURSIVELY(adventure_book,"teamBattleMatchingBtn")
	ADVENTURE_BOOK_JOIN_WORLDPVP(adventure_book_btn:GetParent(),adventure_book_btn)
end

function INDUNINFO_TEAM_BATTLE_STATE_CHANGE(frame,ctrl,argStr,argNum)
	local state = session.worldPVP.GetState();
	local stateText = GetPVPStateText(state);
	local viewText = ClMsg( "PVP_State_".. stateText );
    local join = GET_CHILD_RECURSIVELY(frame, 'RedButton');
    if join ~= nil then
        local join_text = GET_CHILD_RECURSIVELY(join, "RedButtonText");
        join_text:SetTextByKey("btnText", viewText);
        join:SetEnable(IS_TEAM_BATTLE_ENABLE());
    end
end

function INDUNINFO_MOVE_TO_ENTER_NPC(frame, ctrl)
    local pc = GetMyPCObject();
    
    -- 매칭 던전중이거나 pvp존이면 이용 불가
    if session.world.IsIntegrateServer() == true or IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end

    -- 퀘스트나 챌린지 모드로 인해 레이어 변경되면 이용 불가
    if world.GetLayer() ~= 0 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end

    -- 프리던전 맵에서 이용 불가
    local curMap = GetClass('Map', session.GetMapName());
    local mapType = TryGetProp(curMap, 'MapType');
    if mapType == 'Dungeon' then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end

    -- 레이드 지역에서 이용 불가
    local zoneKeyword = TryGetProp(curMap, 'Keyword', 'None')
    local keywordTable = StringSplit(zoneKeyword, ';')
    if table.find(keywordTable, 'IsRaidField') > 0 or table.find(keywordTable, 'WeeklyBossMap') > 0 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'))
        return
    end

    local indunClsID = ctrl:GetUserValue('MOVE_INDUN_CLASSID');
    control.CustomCommand('MOVE_TO_ENTER_NPC', indunClsID, 0, 0);
end

function INDUNINFO_MOVE_TO_ENTER_HARD(frame, ctrl)
    local pc = GetMyPCObject();
    
    -- 매칭 던전중이거나 pvp존이면 이용 불가
    if session.world.IsIntegrateServer() == true or IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end

    -- 퀘스트나 챌린지 모드로 인해 레이어 변경되면 이용 불가
    if world.GetLayer() ~= 0 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end

    -- 프리던전 맵에서 이용 불가
    local curMap = GetClass('Map', session.GetMapName());
    local mapType = TryGetProp(curMap, 'MapType');
    if mapType == 'Dungeon' then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end

    -- 레이드 지역에서 이용 불가
    local zoneKeyword = TryGetProp(curMap, 'Keyword', 'None')
    local keywordTable = StringSplit(zoneKeyword, ';')
    if table.find(keywordTable, 'IsRaidField') > 0 or table.find(keywordTable, 'WeeklyBossMap') > 0 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'))
        return
    end

    local indunClsID = ctrl:GetUserValue('MOVE_INDUN_CLASSID');
    control.CustomCommand('MOVE_TO_ENTER_HARD', indunClsID, 0, 0);
    ui.CloseFrame('induninfo')
end

function INDUNINFO_MOVE_TO_SOLO_DUNGEON(parent,ctrl)
    local indun_cls_id = ctrl:GetUserValue('MOVE_INDUN_CLASSID');
    local indun_cls = GetClassByType("Indun", indun_cls_id);
    if indun_cls ~= nil then
        local name = TryGetProp(indun_cls, "Name", "None");
        local account_obj = GetMyAccountObj();
        if account_obj ~= nil then
            local stage = TryGetProp(account_obj, "SOLO_DUNGEON_MINI_CLEAR_STAGE", 0);
            local yesScp = "INDUNINFO_MOVE_TO_SOLO_DUNGEON_PRECHECK";
            local title = ScpArgMsg("Select_Stage_SoloDungeon", "Stage", stage + 5); 
            INDUN_EDITMSGBOX_FRAME_OPEN(indun_cls_id, title, "", yesScp, "", 1, stage + 5, 1);
        end
    end
end

function INDUNINFO_MOVE_TO_SOLO_DUNGEON_PRECHECK(type, num)
    if type ~= nil and num ~= nil then
        local msg = ScpArgMsg("SoloDungeonSelectStageEnterMsg", "Stage", num);
        local yes_scp = string.format("_INDUNINFO_MOVE_TO_DUNGEON(\"%s\",\"%s\",\"%s\")", type, 0, num);
        ui.MsgBox(msg, yes_scp, "None");
    end
end

function INDUNINFO_MOVE_TO_ANCIENT_DUNGEON(parent,ctrl)
    local cls = GetClass("Indun","Ancient_Solo_dungeon")
    local indunClsID = ctrl:GetUserValue('MOVE_INDUN_CLASSID');
    local indunCls = GetClassByType('contents_info',indunClsID)
    local selectStage = GET_ANCIENT_STAGE_OF_CLASS(indunCls)
    local yesScp = string.format("_INDUNINFO_MOVE_TO_DUNGEON(%d,%d)",cls.ClassID,selectStage)
    ui.MsgBox(ClMsg('EnterRightNow'), yesScp, 'None');
end

function GET_ANCIENT_STAGE_OF_CLASS(indunCls)
    local strList = StringSplit(indunCls.ClassName,'_')
    local stage = tonumber(strList[#strList])
    local selectStage = 1 + (stage-1)*5
    return selectStage
end

function _INDUNINFO_MOVE_TO_DUNGEON(type, argNum, argNum2)
    ReqEnterSoloIndun(tonumber(type), tonumber(argNum), tonumber(argNum2));
    ui.CloseFrame('induninfo')
end

function SCR_OPEN_OBSERVE_TEAMBATTLE()
    ui.OpenFrame('adventure_book')
    ON_EVENTBANNER_DETAIL_BTN_TEAMBATTLE()
    ui.CloseFrame('induninfo')
end

function REQ_OPEN_SOLO_DUNGEON_RANKING_UI()
    if session.world.IsIntegrateServer() == true or IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end
    pc.ReqExecuteTx("SEND_SOLO_DUNGEON_RANKING_FULL","None")
    ui.CloseFrame('induninfo')
end

function SCR_OPEN_INDUNINFO_PVPREWARD(parent,ctrl,argStr,argNum)
    local frame = parent:GetTopParentFrame()
    local x = frame:GetX() + frame:GetWidth()
    local y = frame:GetY()

	local rewardFrame = ui.GetFrame('induninfo_pvpreward')
	local typeTable = {
		Ancient_Solo_dungeon="Ancient_Dungeon_Reward_Info",
		pvp_Mine="PVP_Mine_Reward_Info",
		teamBattle="TEAM_BATTLE_Reward_Info"}
	for key,val in pairs(typeTable) do
		if string.find(argStr,key) ~= nil then
			INIT_INDUNINFO_PVPREWARD(rewardFrame,val)
			break
		end
	end
    rewardFrame:ShowWindow(1)
    rewardFrame:SetOffset(x,y)
end

function INDUNINFO_SELECT_CATEGORY(index)
	local frame = ui.GetFrame('induninfo')
    local categoryBox = GET_CHILD_RECURSIVELY(frame, 'categoryBox');
    local ctrl = categoryBox:GetChildByIndex(index);
    local button = GET_CHILD(ctrl, "button")
    if button ~= nil then
        PVP_INDUNINFO_CATEGORY_LBTN_CLICK(button:GetParent(), button);
    end
end
--------------------------------- 주간 보스 레이드 --------------------------------- 
function  WEEKLYBOSSINFO_UI_OPEN(frame)
    WEEKLY_BOSS_DATA_REUQEST();

    local frame = ui.GetFrame('induninfo');
    
	SET_WEEKLYBOSS_INDUN_COUNT(frame)
end

function WEEKLY_BOSS_SEASON_SELECT(frame,ctrl)

end

function WEEKLY_BOSS_DATA_REUQEST()
    local frame = ui.GetFrame("induninfo")
    local rank_gb = GET_CHILD_RECURSIVELY(frame, "rank_gb");
    rank_gb:EnableHitTest(0);
    ReserveScript("HOLD_RANKUI_UNFREEZE()", 1);

    local week_num = WEEKLY_BOSS_RANK_WEEKNUM_NUMBER();
    if week_num < 1 then
        return;
    end
    weekly_boss.RequestWeeklyBossAbsoluteRewardList(week_num);  -- 누적대미지 보상 목록 요청
    weekly_boss.RequestWeeklyBossRankingRewardList(week_num);   -- 랭킹 보상 목록 요청
    weekly_boss.RequestGetReceiveAbsoluteReward(week_num);      -- 내가 수령한 누적대미지 보상 정보 요청
    weekly_boss.RequestGetReceiveRankingReward(week_num);       -- 내가 수령한 랭킹 보상 정보 요청
    weekly_boss.RequestGetReceiveClassRankingReward(week_num);  -- 내가 수령한 클래스 랭킹 보상 정보 요청
    weekly_boss.RequestEnableClassRankRewardSeason(week_num);   -- 클래스 랭킹 보상 가능 여부 확인 요청.

    -- 랭킹 정보
    local jobID = WEEKLY_BOSS_RANK_JOBID_NUMBER();
    WEEKLYBOSS_REWARD_CLASS_SELECT_JOB_ID(jobID);
    weekly_boss.RequestWeeklyBossClassRankingRewardList(week_num, jobID); -- 클래스 랭킹 보상 목록 요청.

    weekly_boss.RequestWeeklyBossRankingInfoList(week_num, jobID);
    INDUNINFO_CLASS_SELECTOR_FILL_CLASS(jobID)

    -- 보스 정보
    weekly_boss.RequestWeeklyBossStartTime(week_num);           -- 해당 주간 보스 시작 시간 정보 요청
    weekly_boss.RequestWeeklyBossEndTime(week_num);             -- 해당 주간 보스 종료 시간 정보 요청
    weekly_boss.RequestWeeklyBossPatternInfo(week_num);             -- 해당 주간 보스 종료 시간 정보 요청
    
    local rankListBox = GET_CHILD_RECURSIVELY(frame, "rankListBox", "ui::CGroupBox");
	rankListBox:RemoveAllChild();
end

function HOLD_RANKUI_UNFREEZE()
    local frame = ui.GetFrame("induninfo");    
    local rank_gb = GET_CHILD_RECURSIVELY(frame, "rank_gb");
	rank_gb:EnableHitTest(1);
end

-- 갱신된 정보에 맞게 UI 수정 
function WEEKLY_BOSS_UI_UPDATE(frame, msg, arg_str, arg_num)
    local frame = ui.GetFrame("induninfo")
    local week_num = WEEKLY_BOSS_RANK_WEEKNUM_NUMBER();

    -- 몬스터 정보
    local weeklybossPattern = session.weeklyboss.GetPatternInfo();
    local monClsName = weeklybossPattern.MonsterClassName
    
	--티니 삼형제
	if string.find(monClsName,"weekly_boss_Tiny") ~= nil then
		monClsName = "weekly_boss_Tiny_ThreeBrothers"
    end
    
    local monCls = GetClass("Monster",monClsName)
    if monCls ~= nil then
        local monster_icon_pic = GET_CHILD_RECURSIVELY(frame, 'monster_icon_pic');
        monster_icon_pic:SetImage(monCls.Icon);
        
        local monster_attr1 = GET_CHILD_RECURSIVELY(frame, "monster_attr1", "ui::CControlSet");
        local monster_attr2 = GET_CHILD_RECURSIVELY(frame, "monster_attr2", "ui::CControlSet");
        local monster_attr3 = GET_CHILD_RECURSIVELY(frame, "monster_attr3", "ui::CControlSet");
        local monster_attr4 = GET_CHILD_RECURSIVELY(frame, "monster_attr4", "ui::CControlSet");
        local monster_attr5 = GET_CHILD_RECURSIVELY(frame, "monster_attr5", "ui::CControlSet");
        local monster_attr6 = GET_CHILD_RECURSIVELY(frame, "monster_attr6", "ui::CControlSet");
        
        SET_TEXT(monster_attr1, "attr_name_text", "value", ScpArgMsg('Name'));
        SET_TEXT(monster_attr2, "attr_name_text", "value", ScpArgMsg('RaceType'));
        SET_TEXT(monster_attr3, "attr_name_text", "value", ScpArgMsg('Attribute'));
        SET_TEXT(monster_attr4, "attr_name_text", "value", ScpArgMsg('MonInfo_ArmorMaterial'));
        SET_TEXT(monster_attr5, "attr_name_text", "value", ScpArgMsg('Level'));
        SET_TEXT(monster_attr6, "attr_name_text", "value", ScpArgMsg('Area'));

        SET_TEXT(monster_attr1, "attr_value_text", "value", monCls.Name);
        SET_TEXT(monster_attr2, "attr_value_text", "value", ScpArgMsg(weeklybossPattern.RaceType));
        SET_TEXT(monster_attr3, "attr_value_text", "value", ScpArgMsg("MonInfo_Attribute_"..weeklybossPattern.Attribute));
        SET_TEXT(monster_attr4, "attr_value_text", "value", ScpArgMsg(weeklybossPattern.ArmorMaterial));
        SET_TEXT(monster_attr5, "attr_value_text", "value", monCls.Level);
        local attr5_value_text = GET_CHILD_RECURSIVELY(monster_attr6,"attr_value_text")
        local mapCls = GetClassByType("Map",weeklybossPattern.mapClassID)
        if mapCls ~= nil then
            SET_TEXT(monster_attr6, "attr_value_text", "value", mapCls.Name);
        end
    end
    
    -- 전투 정보
    local myrank = session.weeklyboss.GetMyRankInfo(week_num);          -- 계열 등수
    local totalcnt = session.weeklyboss.GetTotalRankCount(week_num);    -- 계열별 전체 도전 유저
    local myrank_p = (myrank/totalcnt) * 100;
    myrank_p = string.format("%.2f",myrank_p)
    if totalcnt <= 0 then
        myrank_p = 0;
    end
    local mydamage = session.weeklyboss.GetMyDamageInfoToString(week_num);                  -- 도전 1회 최고 점수
    local accumulateDamage = session.weeklyboss.GetWeeklyBossAccumulatedDamage(week_num);   -- 누적 대미지
    local battle_info_attr = GET_CHILD_RECURSIVELY(frame, "battle_info_attr", "ui::CControlSet");
    SET_TEXT(battle_info_attr, "attr_value_text_1", "rank", myrank);
    SET_TEXT(battle_info_attr, "attr_value_text_1", "rank_p", myrank_p);
    SET_TEXT(battle_info_attr, "attr_value_text_2", "value", STR_KILO_CHANGE(mydamage));
    SET_TEXT(battle_info_attr, "attr_value_text_3", "value", STR_KILO_CHANGE(accumulateDamage));
    
    -- 제한 시간     
    local starttime = session.weeklyboss.GetWeeklyBossStartTime();
    local endtime = session.weeklyboss.GetWeeklyBossEndTime();
    local durtime = imcTime.GetDifSec(endtime, starttime);
    local systime = geTime.GetServerSystemTime();
    local difsec = imcTime.GetDifSec(endtime, systime);

    local gauge = GET_CHILD_RECURSIVELY(frame, "gauge", "ui::CGauge");
    local battle_info_time_text = GET_CHILD_RECURSIVELY(frame, "battle_info_time_text", "ui::CRichText");
    
    if 0 < difsec then
        gauge:SetPoint(durtime - difsec, durtime);
        local textstr = GET_TIME_TXT(difsec) .. ClMsg("After_Exit");
        battle_info_time_text:SetTextByKey("value", textstr);
        battle_info_time_text:SetUserValue("REMAINSEC", difsec);
        battle_info_time_text:SetUserValue("STARTSEC", imcTime.GetAppTime());
        battle_info_time_text:RunUpdateScript("WEEKLY_BOSS_REMAIN_END_TIME");
    elseif difsec < 0 then
        gauge:SetPoint(1, 1);
        local textstr = ClMsg("Already_Exit_Raid");
        battle_info_time_text:SetTextByKey("value", textstr);
        battle_info_time_text:StopUpdateScript("WEEKLY_BOSS_REMAIN_END_TIME");
    end

    -- 입장 횟수
    -- 입장 제한
    local joinButton = GET_CHILD_RECURSIVELY(frame,"joinenter")
    if week_num ~= session.weeklyboss.GetNowWeekNum() then
        joinButton:SetEnable(0)
    else
        joinButton:SetEnable(1)
    end

    --시즌 갱신
    WEEKLY_BOSS_SEASON_UPDATE();
    -- 랭킹 LIST 갱신
    WEEKLY_BOSS_RANK_UPDATE();
end

function WEEKLY_BOSS_SEASON_UPDATE()
    local weekNum = session.weeklyboss.GetNowWeekNum();
    local frame = ui.GetFrame("induninfo")
    local tabControl = GET_CHILD_RECURSIVELY(frame, "season_tab", "ui::CTabControl");
    local cnt = tabControl:GetItemCount()
    for i = 0,cnt-1 do
        if weekNum - i > 0 then
            tabControl:ChangeCaption(i,"{@st42b}{s16}"..tostring(weekNum - i), false)
        else
            tabControl:ChangeCaption(i,"{@st42b}{s16}-", false)
        end
    end
end

-- 주간 보스 남은시간 표시
function WEEKLY_BOSS_REMAIN_END_TIME(ctrl)
	local elapsedSec = imcTime.GetAppTime() - ctrl:GetUserIValue("STARTSEC");
	local startSec = ctrl:GetUserIValue("REMAINSEC");
    startSec = startSec - elapsedSec;
	if 0 > startSec then
		ctrl:SetFontName("red_18");
        ctrl:StopUpdateScript("WEEKLY_BOSS_REMAIN_END_TIME");
        ctrl:ShowWindow(0);
        return 0;
	end 
    
	local timeTxt = GET_TIME_TXT(startSec);
    ctrl:SetTextByKey("value", timeTxt);
    
	return 1;
end

-- rank list 
function WEEKLY_BOSS_RANK_UPDATE()
    local frame = ui.GetFrame("induninfo")
    local rankListBox = GET_CHILD_RECURSIVELY(frame, "rankListBox", "ui::CGroupBox");
    rankListBox:RemoveAllChild();

    local cnt = session.weeklyboss.GetRankInfoListSize();
    if cnt == 0 then
        return;
    end

    local Width = frame:GetUserConfig("SCROLL_BAR_TRUE_WIDTH");
    if cnt < 6 then
        Width = frame:GetUserConfig("SCROLL_BAR_FALSE_WIDTH");
    end
    
    for i = 1, cnt do
        local ctrlSet = rankListBox:CreateControlSet("content_status_board_rank_attribute", "CTRLSET_" .. i,  ui.LEFT, ui.TOP, 0, (i - 1) * 73, 0, 0);
        ctrlSet:Resize(Width, ctrlSet:GetHeight());
        local attr_bg = GET_CHILD(ctrlSet, "attr_bg");
        attr_bg:Resize(Width, attr_bg:GetHeight());

        local rankpic = GET_CHILD(ctrlSet, "attr_rank_pic");
        local attr_rank_text = GET_CHILD(ctrlSet, "attr_rank_text");

        if i <= 3 then
            rankpic:SetImage('raid_week_rank_0'..i)
            rankpic:ShowWindow(1);

            attr_rank_text:ShowWindow(0);
        else
            rankpic:ShowWindow(0);

            attr_rank_text:SetTextByKey("value", i);
            attr_rank_text:ShowWindow(1);
        end

        local damage = session.weeklyboss.GetRankInfoDamage(i - 1);
        local teamname = session.weeklyboss.GetRankInfoTeamName(i - 1);
        local guildID = session.weeklyboss.GetRankInfoGuildID(i - 1)
        if guildID ~= "0" then
            ctrlSet:SetUserValue("GUILD_IDX",guildID)
            GetGuildEmblemImage("WEEKLY_BOSS_EMBLEM_IMAGE_SET",guildID)
        end

        local name = GET_CHILD(ctrlSet, "attr_name_text", "ui::CRichText");
        name:SetTextByKey("value", teamname);

        local value = GET_CHILD(ctrlSet, "attr_value_text", "ui::CRichText");
        value:SetTextByKey("value", STR_KILO_CHANGE(damage));
    
    end

end

function WEEKLY_BOSS_EMBLEM_IMAGE_SET(code, return_json)
    if code ~= 200 then
        if code == 400 or code == 404 then
            return
        else
            SHOW_GUILD_HTTP_ERROR(code, return_json, "WEEKLY_BOSS_EMBLEM_IMAGE_SET")
            return
        end
    end
    
    local guild_idx = return_json
    emblemFolderPath = filefind.GetBinPath("GuildEmblem"):c_str()
    local emblemPath = emblemFolderPath .. "\\" .. guild_idx .. ".png";

    local frame = ui.GetFrame('induninfo')
    local rankListBox = GET_CHILD_RECURSIVELY(frame, "rankListBox", "ui::CGroupBox");
    for i = 0,rankListBox:GetChildCount()-1 do
        local controlset = rankListBox:GetChildByIndex(i)
        if controlset:GetUserValue("GUILD_IDX") == guild_idx then
            local picture = tolua.cast(controlset:GetChildRecursively("attr_emblem_pic"), "ui::CPicture");
            ui.SetImageByPath(emblemPath, picture);        
        end
    end
end

-- 페이지 컨트롤 page
function WEEKLY_BOSS_RANK_WEEKNUM_NUMBER()
    local frame = ui.GetFrame('induninfo');
    local tabcontrol = GET_CHILD_RECURSIVELY(frame, "season_tab", "ui::CTabControl");
	if tabcontrol == nil then
		return 0;
    end
    
    local tabidx = tabcontrol:GetSelectItemIndex();
	return session.weeklyboss.GetNowWeekNum() - tabidx;
end

-- 계열 탭 jobid 
function WEEKLY_BOSS_RANK_JOBID_NUMBER()
    local frame = ui.GetFrame('induninfo');
    local classtype_tab = GET_CHILD_RECURSIVELY(frame, "classtype_tab", "ui::CTabControl");
    local index = classtype_tab:GetSelectItemIndex();

    jobID = string.format('%s001', index+1);
    return tonumber(jobID);
end

function WEEKLY_BOSS_PATTERN_UI_OPEN()
    -- ui.ToggleFrame("weeklyboss_patterninfo");
end

function BOSS_PATTERN_UI_OPEN()
    ui.ToggleFrame("weeklyboss_patterninfo");
end

-- 누적 대미지 보상 버튼 클릭
function WEEKLY_BOSS_TOTAL_DAMAGE_REWARD_CLICK()
    local week_num = WEEKLY_BOSS_RANK_WEEKNUM_NUMBER();
    WEEKLYBOSSREWARD_SHOW(1);
end

-- 클래스 순위 보상
function WEEKLY_BOSS_TOTAL_CLASS_RANK_REWARD_CLICK()
    WEEKLYBOSS_REWARD_CLASS_SELECT_OPEN();
end

-- 계열 순위 보상 버튼 클릭
function WEEKLY_BOSS_RANK_REWARD_CLICK()
    local week_num = WEEKLY_BOSS_RANK_WEEKNUM_NUMBER();
    WEEKLYBOSSREWARD_SHOW(0);
end

-- 영웅담 보상 버튼 클릭
function TOSHERO_REWARD_CLICK()
    TOSHEROREWARD_SHOW(3,0);
end


-- 입장하기 버튼 클릭
function WEEKLY_BOSS_JOIN_ENTER_CLICK(parent,ctrl)
    local pc = GetMyPCObject()
    
    local str = SCR_REPUTAION_WEEKQUEST_POSSIBLECHECK(pc, 'P_W_EP13_12', 1)
    local str2 = ClMsg('EnterRightNow')
    if str ~= nil then
        str2 = str..str2
    end
    ui.MsgBox(str2, 'WEEKLY_BOSS_JOIN_ENTER_CLICK_MSG(0)', 'None');
end

-- 연습모드 버튼 클릭
function WEEKLY_BOSS_JOIN_PRACTICE_ENTER_CLICK(parent,ctrl)
    ui.MsgBox(ClMsg('EnterRightNow'), 'WEEKLY_BOSS_JOIN_ENTER_CLICK_MSG(1)', 'None');
end     


function WEEKLY_BOSS_JOIN_ENTER_CLICK_MSG(type)
    local frame = ui.GetFrame("induninfo");
    local ctrl = GET_CHILD_RECURSIVELY(frame,"joinenter")
    if type == 1 then
        ReqEnterWeeklyBossIndun(type)
    elseif ctrl:GetTextByKey('cur') < ctrl:GetTextByKey('max') or session.weeklyboss.GetNowWeekNum() == 1 or session.weeklyboss.GetNowWeekNum() == 2 then
        ReqEnterWeeklyBossIndun(type)
    else
        ui.SysMsg(ScpArgMsg('IRREDIAN1131_DLG_LANG_1_CANT'));
    end
end
--------------------------------- 주간 보스 레이드 ---------------------------------

--------------------------------- 레이드 랭킹 ---------------------------------
local json = require "json_imc";
local curPage = 1;
local infolistY = 0;
local finishedLoading = false;
local scrolledTime = 0;
local raidrankingcategory = {};

function RAID_RANKING_UI_OPEN(frame)
    RAID_RANKING_CATEGORY_INIT(frame);
end

function RAID_RANKING_CATEGORY_SORT_BY_LEVEL()
    raidrankingcategory = {}

    local clsList, cnt = GetClassList("raid_ranking_category");
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(clsList, i);
        raidrankingcategory[#raidrankingcategory + 1] = cls;
    end

    --table.sort(raidrankingcategory, SORT_BY_LEVEL_BASE_NAME);
end

function RAID_RANKING_CATEGORY_INIT(frame)
    frame:SetUserValue('SELECTED_DETAIL', 0);

    local raidcategoryBox = GET_CHILD_RECURSIVELY(frame, 'raidcategoryBox');
    raidcategoryBox:RemoveAllChild();
    raidcategoryBox:EnableHitTest(1);
    
    local raidrankinglist = GET_CHILD_RECURSIVELY(frame, 'raidrankinglist');
    raidrankinglist:RemoveAllChild();
    raidrankinglist:SetScrollPos(0);
    raidrankinglist:SetEventScript(ui.SCROLL, "RAID_RANKING_INFO_SCROLL");

    infolistY = 0;
    curPage = 1;
    scrolledTime = 0;

    RAID_RANKING_CATEGORY_SORT_BY_LEVEL();
    local clsList, cnt = GetClassList("raid_ranking_category");

    local y = 0;
    local width = 350;
    if 8 < cnt then 
        width = 330; 
    end

    for i = 1, #raidrankingcategory do
        local cls = raidrankingcategory[i]
        local ctrl = raidcategoryBox:CreateOrGetControlSet("raid_ranking_category_info", "RAID_RANKING_CTRL"..cls.ClassID, 0, y);

        local btnctrl = GET_CHILD(ctrl, "button");
        btnctrl:SetUserValue('RAID_RANKING_CLASS_ID', cls.ClassID);
        btnctrl:SetEventScript(ui.LBUTTONUP, 'RAID_RANKING_CATEGORY_CLICK');

        local levelctrl = GET_CHILD(ctrl, "level");
        local namectrl = GET_CHILD(ctrl, "name");

        levelctrl:SetTextByKey("value", cls.Level);
        namectrl:SetTextByKey("value", ClMsg(cls.ClassName));  -- 콘텐츠 이름
        namectrl:SetUserValue('RAID_RANKING_CLASS_ID', cls.ClassID);
        namectrl:SetEventScript(ui.LBUTTONUP, 'RAID_RANKING_CATEGORY_CLICK');

        y = y + ctrl:GetHeight() - 5;
    end

end

function RAID_RANKING_CATEGORY_CLICK(parent, detailCtrl)
    local frame = parent:GetTopParentFrame();

    local indunClassID = detailCtrl:GetUserIValue('RAID_RANKING_CLASS_ID');
    local preSelectedDetail = frame:GetUserIValue('SELECTED_DETAIL');
    if indunClassID == preSelectedDetail then
        return;
    end
    
    local raidcategoryBox = GET_CHILD_RECURSIVELY(frame, 'raidcategoryBox');
    raidcategoryBox:EnableHitTest(0);
    ReserveScript("RAID_RANKING_CATEGORY_UI_UNFREEZE()", 1.0);
    
    local raidrankinglist = GET_CHILD_RECURSIVELY(frame, 'raidrankinglist');
    raidrankinglist:RemoveAllChild();
    raidrankinglist:SetScrollPos(0);

    -- set skin
    local preSelectedCtrl = GET_CHILD_RECURSIVELY(frame, 'RAID_RANKING_CTRL'..preSelectedDetail);
    if preSelectedCtrl ~= nil then
        local preBtnCtrl = GET_CHILD(preSelectedCtrl, "button");
        preBtnCtrl:SetSkinName("base_btn");
    end

    detailCtrl:SetSkinName("baseyellow_btn");
    frame:SetUserValue('SELECTED_DETAIL', indunClassID);

    infolistY = 0;
    curPage = 1;
    scrolledTime = imcTime.GetAppTime();

    local rankCls = GetClassByType("raid_ranking_category", indunClassID);
    GetRaidRanking('RAID_RANKING_INFO_UPDATE', rankCls.ClassName, curPage, TryGetProp(rankCls, "Order", "asc"));
end

function RAID_RANKING_INFO_UPDATE(code, ret_json)    
    finishedLoading = true;
    
    if code ~= 200 then
        if code == 500 then
            ui.SysMsg(ScpArgMsg('CantExecInThisArea'));
        end
        
        local frame = ui.GetFrame("induninfo");
        RAID_RANKING_CATEGORY_INIT(frame);
        return;
    end

    local parsed = json.decode(ret_json);
    local count = parsed['count'];
    if tonumber(count) == 0 then
        return;
    end

    local list = parsed['list'];
    for k, v in pairs(list) do
        local rank = v['rank'];
        local time = v['score'];
        local member = v['member'];

        if 100 < rank then
            return;
        end

        infolistY = RAID_RANKING_INFO_DETAIL(infolistY, rank, time, member);
    end
end

function RAID_RANKING_INFO_DETAIL(y, rank, time, member)
    local frame = ui.GetFrame("induninfo");
    local myParty = false;

    local gb = GET_CHILD_RECURSIVELY(frame, 'raidrankinglist');
    
    local ctrl = gb:CreateOrGetControlSet("raid_ranking_info", "RAID_RANKING_DETAIL_"..rank, 5, y);

    local rankCtrl = GET_CHILD(ctrl, 'rank');
    rankCtrl:SetTextByKey("value", rank);

    local timetext = GET_RAID_RANKING_TIME_TXT(time);
    local timeCtrl = GET_CHILD(ctrl, 'time');
    timeCtrl:SetTextByKey("value", timetext);

    local membergb = GET_CHILD(ctrl, 'membergb');
    membergb:RemoveAllChild();

    local pic = GET_CHILD(ctrl, 'pic');

    if rank <= 3 then
        pic:SetImage('raid_week_rank_0'..rank)
        pic:ShowWindow(1);

        rankCtrl:ShowWindow(0);
    else
        pic:ShowWindow(0);
        rankCtrl:ShowWindow(1);
    end

    local memberstrlist = StringSplit(member, ', ');
    local memberCnt = #memberstrlist;
    
    local membery = 20;
    for i = 1, memberCnt do
        local infostrlist = StringSplit(memberstrlist[i], ' ');
        local end_count = #infostrlist

        local teamname = "";
        local guildname = "";
        local memberCtrl = membergb:CreateOrGetControlSet("raid_ranking_info_member", "member_"..i, 0, membery);
        if 1 < #infostrlist then
            for j = 1, end_count - 1 do
                if j == 1 then
                    guildname = infostrlist[j]
                else
                    guildname = guildname .. ' ' .. infostrlist[j];
                end
            end
                        
            teamname = infostrlist[end_count];

            local guildCtrl = GET_CHILD(memberCtrl, "guild");
            guildCtrl:SetText(guildname);
        else
            teamname = infostrlist[1];
        end
        
        local teamCtrl = GET_CHILD(memberCtrl, "team");
        teamCtrl:SetText(teamname);

        local myHandle = session.GetMyHandle();
        if teamname == info.GetFamilyName(myHandle) then
            myParty = true;
        end

        membery = membery + (memberCtrl:GetHeight() * 1.5);
    end
   

    membergb:Resize(membergb:GetWidth(), membery + 15);
    local height = ctrl:GetHeight();
    
    if ctrl:GetHeight() < membergb:GetHeight() then
        height = membergb:GetHeight();
    end
    
    ctrl:Resize(ctrl:GetWidth(), height);

    if myParty == true then
        ctrl:SetSkinName("guildbattle_win_bg");
    end

    y = y + ctrl:GetHeight();
    return y;
end

function GET_RAID_RANKING_TIME_TXT(time)
	if time == 0.0 then
		return "";
	end

    local sec = time / 1000;
    
	local hour = math.floor(sec / 3600);
	if hour < 0 then
		hour = 0;
	end

	sec = sec - hour * 3600;

	local min = math.floor(sec / 60);
	if min < 0 then
		min = 0;
	end

	sec = math.floor(sec - min * 60);
	if sec < 0 then
		sec = 0;
	end

    local hourtext = hour;
    if hour < 10 then
        hourtext = string.format("0%s", hour);
	end

    local mintext = min;
    if min < 10 then
        mintext = string.format("0%s", min);
    end
    
    local sectext = sec;
    if sec < 10 then
        sectext = string.format("0%s", sec);
    end
    
    local final_text = ''
    
    if hourtext ~= '00' then
        final_text = hourtext..ScpArgMsg("Auto_SiKan").." "..mintext..ScpArgMsg("Auto_Bun").." "..sectext..ScpArgMsg("Auto_Cho");
    elseif mintext ~= '00' then
        final_text = mintext..ScpArgMsg("Auto_Bun").." "..sectext..ScpArgMsg("Auto_Cho")
    else
        final_text = sectext..ScpArgMsg("Auto_Cho")
    end

    return final_text
end

function RAID_RANKING_INFO_SCROLL(parent, ctrl)
    local frame = ui.GetFrame("induninfo");

    if ctrl:IsScrollEnd() == true and finishedLoading == true then       
        local classID = frame:GetUserIValue('SELECTED_DETAIL');

        local rankCls = GetClassByType("raid_ranking_category", classID);
        if rankCls == nil then
            return;
        end

        local now = imcTime.GetAppTime();
        local dif = now - scrolledTime;

        if 2 < dif then
            curPage = curPage + 1;
            GetRaidRanking('RAID_RANKING_INFO_UPDATE', rankCls.ClassName, curPage, TryGetProp(rankCls, 'Order', 'asc'));
            scrolledTime = now
            finishedLoading = false;
        end
    end
end

function RAID_RANKING_CATEGORY_UI_UNFREEZE()
    local frame = ui.GetFrame("induninfo");

    local raidcategoryBox = GET_CHILD_RECURSIVELY(frame, 'raidcategoryBox');
    raidcategoryBox:EnableHitTest(1);    
end

--------------------------------- 레이드 랭킹 ---------------------------------

--------------------------------- 봉쇄전 랭킹 ---------------------------------
function BORUTA_RANKING_UI_OPEN(frame)
    BORUTA_RANKING_DATA_REQUEST()
end

function BORUTA_RANKING_SEASON_SELECT(frame,ctrl)

end

function BORUTA_RANKING_DATA_REQUEST()
    local frame = ui.GetFrame("induninfo")
    local ranking_gb = GET_CHILD_RECURSIVELY(frame, "ranking_gb")
    ranking_gb:EnableHitTest(0)
    ReserveScript("HOLD_BORUTA_RANKING_UI_UNFREEZE()", 1)

    local week_num = BORUTA_RANKING_WEEKNUM_NUMBER()
    if week_num < 1 then
        return
    end

    local event_type = BORUTA_RANKING_EVENT_TYPE()
    
    -- 시간 정보
    boruta.RequestBorutaStartTime(week_num) -- 시작 시간 정보 요청
    boruta.RequestBorutaEndTime(week_num) -- 종료 시간 정보 요청

    boruta.RequestBorutaRankList(week_num, event_type) -- 랭킹 정보 요청
    boruta.RequestBorutaAcceptedRewardInfo(week_num) -- 랭킹 보상 수령 여부 요청
    
    local rankingBox = GET_CHILD_RECURSIVELY(frame, "ranking_list_box", "ui::CGroupBox")
    rankingBox:RemoveAllChild()
end

function HOLD_BORUTA_RANKING_UI_UNFREEZE()
    local frame = ui.GetFrame("induninfo")
    local ranking_gb = GET_CHILD_RECURSIVELY(frame, "ranking_gb")
    ranking_gb:EnableHitTest(1)
end

function BORUTA_RANKING_UI_UPDATE()
    local frame = ui.GetFrame("induninfo")
    local guild_info_attr = GET_CHILD_RECURSIVELY(frame, "guild_info_attr", "ui::CControlSet")

    local week_num = BORUTA_RANKING_WEEKNUM_NUMBER()
    local guild_id = 0
    local guild_rank = 0
    local guild_info = GET_MY_GUILD_INFO()
    if guild_info ~= nil then
        guild_id = guild_info.info:GetPartyID()   -- 길드 랭킹 정보
        guild_rank = session.boruta_ranking.GetGuildRank(guild_id)    -- 순위
    end

    if guild_rank > 0 then
        local clear_time_str = session.boruta_ranking.GetRankInfoClearTime(guild_rank - 1)
        local clear_time_ms = tonumber(clear_time_str)
        local clear_hour = math.floor(clear_time_ms / (60 * 60 * 1000))
        local clear_min = math.floor(clear_time_ms / (60 * 1000)) - (clear_hour * 60)
        local clear_sec = math.floor(clear_time_ms / 1000) - ((clear_hour * 60 + clear_min) * 60)
        local clear_ms = math.fmod(clear_time_ms, 1000)
        if clear_ms < 0 then
            clear_ms = 0
        end
        local time_txt = "-"
        if clear_hour > 0 then
            time_txt = string.format("%d:%02d:%02d.%03d", clear_hour, clear_min, clear_sec, clear_ms)
        else
            time_txt = string.format("%02d:%02d.%03d", clear_min, clear_sec, clear_ms)
        end
        
        SET_TEXT(guild_info_attr, "rank_value_text", "rank", guild_rank)
		SET_TEXT(guild_info_attr, "time_value_text", "value", time_txt)
    else
        SET_TEXT(guild_info_attr, "rank_value_text", "rank", "0")
		SET_TEXT(guild_info_attr, "time_value_text", "value", ClMsg("HaveNoClearInfo"))
	end
	--번역 문제 수정
	if config.GetServiceNation() == 'GLOBAL' then
		SET_TEXT(guild_info_attr, "time_text", "value", "Time")
    end
    
    -- 제한 시간
    local starttime = session.boruta_ranking.GetBorutaStartTime()
    local endtime = session.boruta_ranking.GetBorutaEndTime()
    local durtime = imcTime.GetDifSec(endtime, starttime)
    local systime = geTime.GetServerSystemTime()
    local difsec = imcTime.GetDifSec(endtime, systime)

    local gauge = GET_CHILD_RECURSIVELY(frame, "time_gauge", "ui::CGauge")
    local guild_info_time_text = GET_CHILD_RECURSIVELY(frame, "guild_info_time_text", "ui::CRichText")
    
    if 0 < difsec then
        gauge:SetPoint(durtime - difsec, durtime)
        
        local textstr = GET_TIME_TXT(difsec) .. ClMsg("After_Exit")
        guild_info_time_text:SetTextByKey("value", textstr)
        
        guild_info_time_text:SetUserValue("REMAINSEC", difsec)
        guild_info_time_text:SetUserValue("STARTSEC", imcTime.GetAppTime())
        guild_info_time_text:RunUpdateScript("BORUTA_RANKING_REMAIN_END_TIME")
    elseif difsec < 0 then
        gauge:SetPoint(1, 1)
        
        local textstr = ClMsg("Already_Exit_Raid")
        guild_info_time_text:SetTextByKey("value", textstr)
        guild_info_time_text:StopUpdateScript("BORUTA_RANKING_REMAIN_END_TIME")
    end

    local now_week_num = session.boruta_ranking.GetNowWeekNum()
    local reward_btn = GET_CHILD_RECURSIVELY(frame, 'boruta_reward_btn')
    if week_num < now_week_num and guild_rank > 0 and session.boruta_ranking.RewardAccepted(week_num) == 0 then
        reward_btn:SetEnable(1)
    else
        reward_btn:SetEnable(0)
    end

    -- 보스 데이터 갱신
    BORUTA_RANKING_BOSS_UPDATE()
    -- 시즌 갱신
    BORUTA_RANKING_SEASON_UPDATE()
    -- 랭킹 LIST 갱신
    BORUTA_RANKING_UPDATE()
end

function BORUTA_RANKING_BOSS_UPDATE()
    local frame = ui.GetFrame("induninfo")
    local event_type, monClsName = BORUTA_RANKING_EVENT_TYPE()
    
    local move_btn = GET_CHILD_RECURSIVELY(frame, 'boruta_move_btn')
    if move_btn ~= nil then
        move_btn:SetUserValue('MOVE_INDUN_CLASSID', event_type)
    end

    -- 보스 정보
    local monCls = GetClass("Monster", monClsName)
    if monCls ~= nil then
        local boss_icon_pic = GET_CHILD_RECURSIVELY(frame, 'boss_icon_pic')
        boss_icon_pic:SetImage(monCls.Icon)
        
        local boss_attr1 = GET_CHILD_RECURSIVELY(frame, "boss_attr1", "ui::CControlSet")
        local boss_attr2 = GET_CHILD_RECURSIVELY(frame, "boss_attr2", "ui::CControlSet")
        local boss_attr3 = GET_CHILD_RECURSIVELY(frame, "boss_attr3", "ui::CControlSet")
        local boss_attr4 = GET_CHILD_RECURSIVELY(frame, "boss_attr4", "ui::CControlSet")
        local boss_attr5 = GET_CHILD_RECURSIVELY(frame, "boss_attr5", "ui::CControlSet")
        local boss_attr6 = GET_CHILD_RECURSIVELY(frame, "boss_attr6", "ui::CControlSet")
        
        SET_TEXT(boss_attr1, "attr_name_text", "value", ScpArgMsg('Name'))
        SET_TEXT(boss_attr2, "attr_name_text", "value", ScpArgMsg('RaceType'))
        SET_TEXT(boss_attr3, "attr_name_text", "value", ScpArgMsg('Attribute'))
        SET_TEXT(boss_attr4, "attr_name_text", "value", ScpArgMsg('MonInfo_ArmorMaterial'))
        SET_TEXT(boss_attr5, "attr_name_text", "value", ScpArgMsg('Level'))
        SET_TEXT(boss_attr6, "attr_name_text", "value", ScpArgMsg('Area'))

        SET_TEXT(boss_attr1, "attr_value_text", "value", monCls.Name)
        SET_TEXT(boss_attr2, "attr_value_text", "value", ScpArgMsg(monCls.RaceType))
        SET_TEXT(boss_attr3, "attr_value_text", "value", ScpArgMsg("MonInfo_Attribute_"..monCls.Attribute))
        SET_TEXT(boss_attr4, "attr_value_text", "value", ScpArgMsg(monCls.ArmorMaterial))
        SET_TEXT(boss_attr5, "attr_value_text", "value", monCls.Level)
        local attr5_value_text = GET_CHILD_RECURSIVELY(boss_attr6,"attr_value_text")
        local mapClsName = "d_limestonecave_70_1_guild"
        if event_type == 501 then
            mapClsName = "raid_giltine_AutoGuild"
        elseif event_type == 502 then
            mapClsName = "guild_ep14_2_d_castle_2";
        end
        local mapCls = GetClass("Map", mapClsName)
        if mapCls ~= nil then
            SET_TEXT(boss_attr6, "attr_value_text", "value", mapCls.Name)
        end
    end
end

function BORUTA_RANKING_SEASON_UPDATE()
    local weekNum = session.boruta_ranking.GetNowWeekNum()
    local frame = ui.GetFrame("induninfo")
    local tabControl = GET_CHILD_RECURSIVELY(frame, "boruta_season_tab", "ui::CTabControl")
    local cnt = tabControl:GetItemCount()
    for i = 0, cnt - 1 do
        if weekNum - i > 0 then
            tabControl:ChangeCaption(i,"{@st42b}{s16}"..tostring(weekNum - i), false)
        else
            tabControl:ChangeCaption(i,"{@st42b}{s16}-", false)
        end
    end
end

-- 봉쇄전 종료까지 남은시간 표시
function BORUTA_RANKING_REMAIN_END_TIME(ctrl)
	local elapsedSec = imcTime.GetAppTime() - ctrl:GetUserIValue("STARTSEC")
	local startSec = ctrl:GetUserIValue("REMAINSEC")
    startSec = startSec - elapsedSec
	if 0 > startSec then
		ctrl:SetFontName("red_18")
        ctrl:StopUpdateScript("BORUTA_RANKING_REMAIN_END_TIME")
        ctrl:ShowWindow(0)
        return 0
	end 
    
	local timeTxt = GET_TIME_TXT(startSec)
    ctrl:SetTextByKey("value", timeTxt)
    
	return 1
end

-- rank list 
function BORUTA_RANKING_UPDATE()
    local frame = ui.GetFrame("induninfo")
    local ranking_list_box = GET_CHILD_RECURSIVELY(frame, "ranking_list_box", "ui::CGroupBox")
    ranking_list_box:RemoveAllChild()

    local cnt = session.boruta_ranking.GetRankInfoListSize()
    if cnt == 0 then
        return
    end

    local Width = frame:GetUserConfig("SCROLL_BAR_TRUE_WIDTH");
    if cnt < 6 then
        Width = frame:GetUserConfig("SCROLL_BAR_FALSE_WIDTH");
    end
    
    for i = 1, cnt do
        local ctrlSet = ranking_list_box:CreateControlSet("boruta_ranking_attribute", "CTRLSET_" .. i, ui.LEFT, ui.TOP, 0, (i - 1) * 73, 0, 0)
        ctrlSet:Resize(Width, ctrlSet:GetHeight())
        local attr_bg = GET_CHILD(ctrlSet, "attr_bg")
        attr_bg:Resize(Width, attr_bg:GetHeight())

        local rankpic = GET_CHILD(ctrlSet, "attr_rank_pic")
        local attr_rank_text = GET_CHILD(ctrlSet, "attr_rank_text")

        if i <= 3 then
            rankpic:SetImage('raid_week_rank_0'..i)
            rankpic:ShowWindow(1)

            attr_rank_text:ShowWindow(0)
        else
            rankpic:ShowWindow(0)

            attr_rank_text:SetTextByKey("value", i)
            attr_rank_text:ShowWindow(1)
        end

        local clear_time_str = session.boruta_ranking.GetRankInfoClearTime(i - 1)
        local clear_time_ms = tonumber(clear_time_str)
        local clear_hour = math.floor(clear_time_ms / (60 * 60 * 1000))
        local clear_min = math.floor(clear_time_ms / (60 * 1000)) - (clear_hour * 60)
        local clear_sec = math.floor(clear_time_ms / 1000) - ((clear_hour * 60 + clear_min) * 60)
        local clear_ms = math.fmod(clear_time_ms, 1000)
        if clear_ms < 0 then
            clear_ms = 0
        end
        local time_txt = "-"
        if clear_hour > 0 then
            time_txt = string.format("%d:%02d:%02d.%03d", clear_hour, clear_min, clear_sec, clear_ms)
        else
            time_txt = string.format("%02d:%02d.%03d", clear_min, clear_sec, clear_ms)
        end
        local guild_name = session.boruta_ranking.GetRankInfoGuildName(i - 1)
        local guildID = session.boruta_ranking.GetRankInfoGuildID(i - 1)
        if guildID ~= "0" then
            ctrlSet:SetUserValue("GUILD_IDX", guildID)
            GetGuildEmblemImage("BORUTA_RANKING_EMBLEM_IMAGE_SET", guildID)
        end

        local name = GET_CHILD(ctrlSet, "attr_name_text", "ui::CRichText")
        name:SetTextByKey("value", guild_name)

        local value = GET_CHILD(ctrlSet, "attr_value_text", "ui::CRichText")
        value:SetTextByKey("time", time_txt)
    end
end

function BORUTA_RANKING_EMBLEM_IMAGE_SET(code, return_json)
    if code ~= 200 then
        if code == 400 or code == 404 then
            return
        else
            SHOW_GUILD_HTTP_ERROR(code, return_json, "BORUTA_RANKING_EMBLEM_IMAGE_SET")
            return
        end
    end
    
    local guild_idx = return_json
    emblemFolderPath = filefind.GetBinPath("GuildEmblem"):c_str()
    local emblemPath = emblemFolderPath .. "\\" .. guild_idx .. ".png"

    local frame = ui.GetFrame('induninfo')
    local rankListBox = GET_CHILD_RECURSIVELY(frame, "ranking_list_box", "ui::CGroupBox")
    for i = 0,rankListBox:GetChildCount()-1 do
        local controlset = rankListBox:GetChildByIndex(i)
        if controlset:GetUserValue("GUILD_IDX") == guild_idx then
            local picture = tolua.cast(controlset:GetChildRecursively("attr_emblem_pic"), "ui::CPicture")
            ui.SetImageByPath(emblemPath, picture)
        end
    end
end

-- 페이지 컨트롤 page
function BORUTA_RANKING_WEEKNUM_NUMBER()
    local frame = ui.GetFrame('induninfo')
    local tabcontrol = GET_CHILD_RECURSIVELY(frame, "boruta_season_tab", "ui::CTabControl")
	if tabcontrol == nil then
		return 0
    end
    
    local tabidx = tabcontrol:GetSelectItemIndex()
	return session.boruta_ranking.GetNowWeekNum() - tabidx
end

-- 봉쇄전 종류
function BORUTA_RANKING_EVENT_TYPE()
    local frame = ui.GetFrame('induninfo')
    local classtype_tab = GET_CHILD_RECURSIVELY(frame, "eventtype_tab", "ui::CTabControl")
    local index = classtype_tab:GetSelectItemIndex()
    eventID = '50'..index;
    local monClsName = 'Guild_boss_Boruta'
    if index == 1 then
        monClsName = 'Legend_Boss_Giltine_Guild'
    elseif index == 2 then
        monClsName = 'Guild_npc_baubas2'
    end
    return tonumber(eventID), monClsName;
end

-- 보상 버튼 클릭
function BORUTA_RANKING_REWARD_CLICK()
    local week_num = BORUTA_RANKING_WEEKNUM_NUMBER()
    local event_type = BORUTA_RANKING_EVENT_TYPE()
    boruta.RequestBorutaReward(week_num, event_type)
end

-- 이동하기 버튼 클릭
function BORUTA_ZONE_MOVE_CLICK(parent, ctrl)
    local indunClsID = ctrl:GetUserValue('MOVE_INDUN_CLASSID');
    ui.MsgBox(ClMsg('Auto_JiyeogeuLo{nl}_iDongHaSiKessSeupNiKka?'), '_BORUTA_ZONE_MOVE_CLICK('.. indunClsID ..')', 'None')
end

function _BORUTA_ZONE_MOVE_CLICK(indunClsID)
    local pc = GetMyPCObject()
    
    -- 매칭 던전중이거나 pvp존이면 이용 불가
    if session.world.IsIntegrateServer() == true or IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'))
        return
    end

    -- 퀘스트나 챌린지 모드로 인해 레이어 변경되면 이용 불가
    if world.GetLayer() ~= 0 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'))
        return
    end

    -- 프리던전 맵에서 이용 불가
    local curMap = GetClass('Map', session.GetMapName())
    local mapType = TryGetProp(curMap, 'MapType')
    if mapType == 'Dungeon' then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'))
        return;
    end

    -- 레이드 지역에서 이용 불가
    local zoneKeyword = TryGetProp(curMap, 'Keyword', 'None')
    local keywordTable = StringSplit(zoneKeyword, ';')
    if table.find(keywordTable, 'IsRaidField') > 0 or table.find(keywordTable, 'WeeklyBossMap') > 0 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'))
        return
    end

    control.CustomCommand('MOVE_TO_ENTER_NPC', indunClsID, 1, 0);
end
--------------------------------- 봉쇄전 랭킹 ---------------------------------

--------------------------------- 필드 보스 ---------------------------------
function FIELD_BOSS_UI_OPEN(frame)
	FIELD_BOSS_TIME_TAB_SETTING(frame)
	FIELD_BOSS_MY_RANK_TEXT_SETTING(frame)
	FIELD_BOSS_ENTER_TIMER_SETTING(frame)
	local ctrlSet = GET_CHILD_RECURSIVELY(frame,"field_boss_my_rank_control")
	ctrlSet:RunUpdateScript("FIELD_BOSS_ENTER_TIMER_SETTING",1)
	FIELD_BOSS_DATA_REQUEST_DAY();
end

function FIELD_BOSS_GET_SCHEDULE_CLASS()
	local nation = config.GetServiceNation()
	if nation ~= "GLOBAL" then
		return GetClass("fieldboss_worldevent_schedulel",nation)
	else
		return GetClass("fieldboss_worldevent_schedulel",GetServerGroupID())
	end
	return nil
end

function FIELD_BOSS_MY_RANK_TEXT_SETTING(frame)
	local ctrlSet = GET_CHILD_RECURSIVELY(frame,"field_boss_my_rank_control")
	local battle_info_attr = GET_CHILD_RECURSIVELY(ctrlSet,"battle_info_attr")
	local attr_name_text_1 = GET_CHILD_RECURSIVELY(battle_info_attr,"attr_name_text_1")
	attr_name_text_1:SetTextByKey("value",ClMsg("Ranking_2"))
	local attr_name_text_2 = GET_CHILD_RECURSIVELY(battle_info_attr,"attr_name_text_2")
	attr_name_text_2:SetTextByKey("value",ClMsg("ClearTime"))
	local attr_name_text_3 = GET_CHILD_RECURSIVELY(battle_info_attr,"attr_name_text_3")
	attr_name_text_3:SetTextByKey("value",ClMsg("AccumulatedDamage"))
end

function FIELD_BOSS_TIME_TAB_SETTING(frame)
	local ctrlSet = GET_CHILD_RECURSIVELY(frame,"field_boss_ranking_control")
	local now_time = geTime.GetServerSystemTime()
	local wDayOfWeek = now_time.wDayOfWeek
	if wDayOfWeek == 0 then
		wDayOfWeek = 7
	end
	local first_time = imcTime.AddSec(now_time,-1*3600*24*(wDayOfWeek-1))
	local season_tab = GET_CHILD_RECURSIVELY(ctrlSet,"season_tab")
	local season_tab_idx = 0
	DELETE_ALL_TAB_ITEM(season_tab)
	for i = 1,7 do
		local time = imcTime.AddSec(first_time,3600*24*(i-1))
		local date_str = string.format("%02d/%02d",time.wMonth,time.wDay)
		season_tab:AddItem("{@st42b}{s16}"..date_str, true, "", "cooperation_war_date_btn", "cooperation_war_date_btn_cursoron", "cooperation_war_date_btn_clicked","", false)
		if time.wDay == now_time.wDay then
			season_tab_idx = i-1
		end
	end
	season_tab:SelectTab(season_tab_idx)

	local sub_tab = GET_CHILD_RECURSIVELY(ctrlSet,"sub_tab")
	DELETE_ALL_TAB_ITEM(sub_tab)
	local nation = config.GetServiceNation()
	local cls = FIELD_BOSS_GET_SCHEDULE_CLASS()
	local hour_tab_idx = 0
	for i = 1,10 do
		local hour = TryGetProp(cls,"StartHour_"..i) 
		if hour == nil then
			break
		end
		local hour_str = string.format("%02d:00",hour)
		sub_tab:AddItem("{@st42b}{s16}"..hour_str, true, "", "cooperation_war_time_btn", "cooperation_war_time_btn_cursoron", "cooperation_war_time_btn_clicked","", false)
		if hour > now_time.wHour then
			hour_tab_idx = i
		end
	end
	hour_tab_idx = math.min(hour_tab_idx,sub_tab:GetItemCount()-1)
	sub_tab:SelectTab(hour_tab_idx)
end

function ON_FIELD_BOSS_MONSTER_UPDATE(frame,msg,argStr,argNum)
	local ctrlSet = GET_CHILD_RECURSIVELY(frame,"field_boss_boss_control")
    -- 몬스터 정보
	local fieldbossPattern = session.fieldboss.GetPatternInfo();
	local monClsName = fieldbossPattern.MonsterClassName
	local monCls = GetClass("Monster",monClsName)
	if monCls ~= nil then
        local monster_icon_pic = GET_CHILD_RECURSIVELY(ctrlSet, 'monster_icon_pic');
        monster_icon_pic:SetImage(monCls.Icon);
        
        local monster_attr1 = GET_CHILD_RECURSIVELY(ctrlSet, "monster_attr1", "ui::CControlSet");
        local monster_attr2 = GET_CHILD_RECURSIVELY(ctrlSet, "monster_attr2", "ui::CControlSet");
        local monster_attr3 = GET_CHILD_RECURSIVELY(ctrlSet, "monster_attr3", "ui::CControlSet");
        local monster_attr4 = GET_CHILD_RECURSIVELY(ctrlSet, "monster_attr4", "ui::CControlSet");
        local monster_attr5 = GET_CHILD_RECURSIVELY(ctrlSet, "monster_attr5", "ui::CControlSet");
        local monster_attr6 = GET_CHILD_RECURSIVELY(ctrlSet, "monster_attr6", "ui::CControlSet");
        
        SET_TEXT(monster_attr1, "attr_name_text", "value", ScpArgMsg('Name'));
        SET_TEXT(monster_attr2, "attr_name_text", "value", ScpArgMsg('RaceType'));
        SET_TEXT(monster_attr3, "attr_name_text", "value", ScpArgMsg('Attribute'));
        SET_TEXT(monster_attr4, "attr_name_text", "value", ScpArgMsg('MonInfo_ArmorMaterial'));
        SET_TEXT(monster_attr5, "attr_name_text", "value", ScpArgMsg('Level'));
        SET_TEXT(monster_attr6, "attr_name_text", "value", ScpArgMsg('Area'));

        SET_TEXT(monster_attr1, "attr_value_text", "value", monCls.Name);
        SET_TEXT(monster_attr2, "attr_value_text", "value", ScpArgMsg(fieldbossPattern.RaceType));
        SET_TEXT(monster_attr3, "attr_value_text", "value", ScpArgMsg("MonInfo_Attribute_"..fieldbossPattern.Attribute));
        SET_TEXT(monster_attr4, "attr_value_text", "value", ScpArgMsg(fieldbossPattern.ArmorMaterial));
        SET_TEXT(monster_attr5, "attr_value_text", "value", monCls.Level);
        local attr5_value_text = GET_CHILD_RECURSIVELY(monster_attr6,"attr_value_text")
        local mapCls = GetClassByType("Map",fieldbossPattern.mapClassID)
        if mapCls ~= nil then
            SET_TEXT(monster_attr6, "attr_value_text", "value", mapCls.Name);
		end
	end
end

function ON_FIELD_BOSS_RANKING_UPDATE(frame,msg,argStr,argNum)
	local time = GET_FIELD_BOSS_DATE()
	local myscore = session.fieldboss.GetMyScore(time)
	local myrank = session.fieldboss.GetMyRank(time)
	local myDamage = "0";
	local myKillTime = 0;
	local argList = StringSplit(myscore,'/')
	if argList[1] == 'time' then
		local killTimeArg = argList[2]
		local ms = killTimeArg%1000
		killTimeArg = math.floor(killTimeArg/1000)
		local sec = killTimeArg%60
		local min = math.floor(killTimeArg/60)
		myKillTime = string.format("%02d:%02d.%03d",min,sec,ms)
	elseif argList[1] == 'damage' then
		myDamage = argList[2]
	end
	local totalcnt = session.fieldboss.GetTotalRankCount(time);	-- 계열별 전체 도전 유저
	local myrank_p = (myrank/totalcnt) * 100;
	myrank_p = string.format("%.2f",myrank_p)
	if totalcnt <= 0 then
		myrank_p = 0;
	end
	local ctrlSet = GET_CHILD_RECURSIVELY(frame,"field_boss_my_rank_control")
	local battle_info_attr = GET_CHILD_RECURSIVELY(ctrlSet, "battle_info_attr", "ui::CControlSet");
	SET_TEXT(battle_info_attr, "attr_value_text_1", "rank", myrank);
	SET_TEXT(battle_info_attr, "attr_value_text_1", "rank_p", myrank_p);
	SET_TEXT(battle_info_attr, "attr_value_text_2", "value", STR_KILO_CHANGE(myKillTime));
	SET_TEXT(battle_info_attr, "attr_value_text_3", "value", STR_KILO_CHANGE(myDamage));
	
	FIELD_BOSS_RANKING_LIST_UPDATE(frame)
end

function FIELD_BOSS_RANKING_LIST_UPDATE(frame)
	local time = GET_FIELD_BOSS_DATE()
	local ctrlSet = GET_CHILD_RECURSIVELY(frame,"field_boss_ranking_control")
	local rankbox = GET_CHILD_RECURSIVELY(ctrlSet,"rankbox")
	local Width = rankbox:GetWidth()
	local totalcnt = session.fieldboss.GetTotalRankCount(time);	-- 계열별 전체 도전 유저
	if totalcnt >= 6 then
		Width = Width - 20
	end
	local rankListBox = GET_CHILD_RECURSIVELY(ctrlSet, "rankListBox", "ui::CGroupBox");
	rankListBox:RemoveAllChild()
	for i = 1,totalcnt do
		local score = session.fieldboss.GetRankInfoScore(time,i);
		if score == "None" then
			break
		end

		local ctrlSet = rankListBox:CreateControlSet("content_status_board_rank_attribute_type2", "CTRLSET_" .. i,  ui.LEFT, ui.TOP, 0, (i - 1) * 73, 0, 0);
		ctrlSet:Resize(Width, ctrlSet:GetHeight());
		local attr_bg = GET_CHILD(ctrlSet, "attr_bg");
		attr_bg:Resize(Width, attr_bg:GetHeight());

		local rankpic = GET_CHILD(ctrlSet, "attr_rank_pic");
		local attr_rank_text = GET_CHILD(ctrlSet, "attr_rank_text");

		if i <= 3 then
			rankpic:SetImage('raid_week_rank_0'..i)
			rankpic:ShowWindow(1);
			attr_rank_text:ShowWindow(0);
		else
			rankpic:ShowWindow(0);
			attr_rank_text:SetTextByKey("value", i);
			attr_rank_text:ShowWindow(1);
		end

		local scoreArgList = StringSplit(score,'/')

		local attr_damage_text = GET_CHILD(ctrlSet, "attr_damage_text", "ui::CRichText");
		local attr_time_text = GET_CHILD(ctrlSet, "attr_time_text", "ui::CRichText");
		local attr_kill_pic = GET_CHILD(ctrlSet, "attr_kill_pic");
		local killTime = '-';
		local damage = "Kill";
		if scoreArgList[1] == 'time' then
			local killTimeArg = scoreArgList[2]
			local ms = killTimeArg%1000
			killTimeArg = math.floor(killTimeArg/1000)
			local sec = killTimeArg%60
			local min = math.floor(killTimeArg/60)
			killTime = string.format("%02d:%02d.%03d",min,sec,ms)
			attr_damage_text:SetVisible(0)
		elseif scoreArgList[1] == 'damage' then
			damage = scoreArgList[2]
			attr_kill_pic:SetVisible(0)
		end
		attr_damage_text:SetTextByKey("value", STR_KILO_CHANGE(damage));
		attr_time_text:SetTextByKey("value", killTime);
	end
end

function FIELD_BOSS_DATA_REQUEST_DAY()
	local frame = ui.GetFrame("induninfo")
	local ctrlSet = GET_CHILD_RECURSIVELY(frame, "field_boss_ranking_control");
	local rank_gb = GET_CHILD_RECURSIVELY(ctrlSet, "rank_gb");
	rank_gb:EnableHitTest(0);
	ReserveScript("HOLD_FIELDBOSS_RANKUI_UNFREEZE()", 1);

	FIELD_BOSS_RESET_RANKING_INFO(frame)
	local field_date =  GET_FIELD_BOSS_DATE();
	field_boss.RequestFieldBossPatternInfo(field_date);
	field_boss.RequestFieldBossRankingInfo(field_date);
end

function FIELD_BOSS_DATA_REQUEST_HOUR()
	local frame = ui.GetFrame("induninfo")
	local ctrlSet = GET_CHILD_RECURSIVELY(frame,"field_boss_ranking_control")
	local rank_gb = GET_CHILD_RECURSIVELY(ctrlSet, "rank_gb");
	rank_gb:EnableHitTest(0);
	ReserveScript("HOLD_FIELDBOSS_RANKUI_UNFREEZE()", 1);
	
	FIELD_BOSS_RESET_RANKING_INFO(frame)
	local field_date =  GET_FIELD_BOSS_DATE();
	field_boss.RequestFieldBossRankingInfo(field_date);
end

function FIELD_BOSS_RESET_RANKING_INFO(frame)
	local ctrlSet_list = GET_CHILD_RECURSIVELY(frame,"field_boss_ranking_control")
	local rankListBox = GET_CHILD_RECURSIVELY(ctrlSet_list, "rankListBox", "ui::CGroupBox");
	rankListBox:RemoveAllChild()

	local ctrlSet_my = GET_CHILD_RECURSIVELY(frame,"field_boss_my_rank_control")
	local battle_info_attr = GET_CHILD_RECURSIVELY(ctrlSet_my, "battle_info_attr", "ui::CControlSet");
	SET_TEXT(battle_info_attr, "attr_value_text_1", "rank", 0);
	SET_TEXT(battle_info_attr, "attr_value_text_1", "rank_p", 0);
	SET_TEXT(battle_info_attr, "attr_value_text_2", "value", 0);
	SET_TEXT(battle_info_attr, "attr_value_text_3", "value", 0);
end

function FIELD_BOSS_ENTER_TIMER_SETTING(ctrlSet)
	local gauge = GET_CHILD_RECURSIVELY(ctrlSet,"gauge")
	local battle_info_time_text = GET_CHILD_RECURSIVELY(ctrlSet,"battle_info_time_text")
	local now_time = geTime.GetServerSystemTime()
	local enter_time = GET_FIELD_BOSS_DATE()
	local diff = imcTime.GetDifSec(now_time,enter_time)
	local textstr;
	local btn = GET_CHILD_RECURSIVELY(ctrlSet:GetTopParentFrame(),"field_boss_joinenter")
	btn:SetEnable(0)
	if now_time.wDay ~= enter_time.wDay then
		gauge:SetPoint(0,100)
		gauge:SetSkinName("test_gauge_barrack_defence")
		textstr = ClMsg("NotAddmittableDay");
	elseif diff < 0 then
		gauge:SetPoint(enter_time.wHour*3600+diff,enter_time.wHour*3600)
		gauge:SetSkinName("gauge_barrack_defence")
		textstr = GET_TIME_TXT(-diff) .." ".. ClMsg("After_Start");
	elseif diff > 0 then
		local cls = FIELD_BOSS_GET_SCHEDULE_CLASS()
		local dur = TryGetProp(cls,"EnteranceDurationSecond",1)
		gauge:SetPoint(diff,dur)
		gauge:SetSkinName("test_gauge_barrack_defence")
		if diff < dur then
			textstr = GET_TIME_TXT(dur-diff) .." ".. ClMsg("After_Exit");
			btn:SetEnable(1)
		else
			textstr = ClMsg("Already_Exit");
		end
	end
	battle_info_time_text:SetTextByKey("value", textstr);
	return 1
end

function GET_FIELD_BOSS_DATE()
	local now_time = geTime.GetServerSystemTime()
	local frame = ui.GetFrame('induninfo');
	local ctrlSet = GET_CHILD_RECURSIVELY(frame,"field_boss_ranking_control")
    local tabcontrol = GET_CHILD_RECURSIVELY(ctrlSet, "season_tab", "ui::CTabControl");
	if tabcontrol == nil then
		return now_time;
    end
	local tabidx = tabcontrol:GetSelectItemIndex();
	local wDayOfWeek = now_time.wDayOfWeek
	if wDayOfWeek == 0 then
		wDayOfWeek = 7
	end
	now_time = imcTime.AddSec(now_time, 86400 * (tabidx-wDayOfWeek+1));

	local hour_tabcontrol = GET_CHILD_RECURSIVELY(ctrlSet,"sub_tab")
	if hour_tabcontrol == nil then
		return now_time;
	end
	local hour_tabidx = hour_tabcontrol:GetSelectItemIndex();
	local cls = FIELD_BOSS_GET_SCHEDULE_CLASS()
	local hour = TryGetProp(cls,"StartHour_"..(hour_tabidx+1)) 
	now_time.wHour = hour
	now_time.wMinute = 0
	now_time.wSecond = 0
	now_time.wMilliseconds = 0
	return now_time
end

-- 입장하기 버튼 클릭
function FIELD_BOSS_JOIN_ENTER_CLICK(parent,ctrl)
    local pc = GetMyPCObject()

    local str = SCR_REPUTAION_WEEKQUEST_POSSIBLECHECK(pc, 'P_W_EP13_13', 1)
    local str2 = ClMsg('EnterRightNow')
    if str ~= nil then
        str2 = str..str2
    end
    ui.MsgBox(str2, 'FIELD_BOSS_JOIN_ENTER_CLICK_MSG()', 'None');
end

function FIELD_BOSS_JOIN_ENTER_CLICK_MSG()
	ReqEnterFieldBossIndun()
end

function HOLD_FIELDBOSS_RANKUI_UNFREEZE()
	local frame = ui.GetFrame("induninfo");   
	local ctrlSet = GET_CHILD_RECURSIVELY(frame, "field_boss_ranking_control");
	local rank_gb = GET_CHILD_RECURSIVELY(ctrlSet, "rank_gb");
    rank_gb:EnableHitTest(1);
end
--------------------------------- 필드 보스 ---------------------------------
function DELETE_ALL_TAB_ITEM(tab)
	local cnt = tab:GetItemCount()
	for i = 1,cnt do
		tab:DeleteTab(0)
	end
end

function REQ_CHALLENGE_AUTO_UI_OPEN(frame, ctrl)
    -- 매칭 던전중이거나 pvp존이면 이용 불가
    if session.world.IsIntegrateServer() == true or IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'))
        return
    end

    -- 퀘스트나 챌린지 모드로 인해 레이어 변경되면 이용 불가
    if world.GetLayer() ~= 0 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'))
        return
    end

    -- 레이드 지역에서 이용 불가
    local curMap = GetClass('Map', session.GetMapName());
    local zoneKeyword = TryGetProp(curMap, 'Keyword', 'None')
    local keywordTable = StringSplit(zoneKeyword, ';')
    if table.find(keywordTable, 'IsRaidField') > 0 or table.find(keywordTable, 'WeeklyBossMap') > 0 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'))
        return;
    end

    local challengeType = 0
    local indunClsID = tonumber(ctrl:GetUserValue('MOVE_INDUN_CLASSID'))
    local indunCls = GetClassByType('Indun', indunClsID)
    local dungeonType = TryGetProp(indunCls, 'DungeonType', 'None');
    if dungeonType ~= "Challenge_Auto" and dungeonType ~= "Challenge_Solo" then
        return;
    end
    ui.CloseFrame('induninfo');
    ReqChallengeAutoUIOpen(indunClsID);
end

function REQ_RAID_AUTO_UI_OPEN(frame, ctrl)
    -- 매칭 던전중이거나 pvp존이면 이용 불가
    if session.world.IsIntegrateServer() == true or IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end

    -- 퀘스트나 챌린지 모드로 인해 레이어 변경되면 이용 불가
    if world.GetLayer() ~= 0 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end
    
    -- 레이드 지역에서 이용 불가
    local map = GetClass('Map', session.GetMapName());
    local keyword = TryGetProp(map, 'Keyword', 'None');
    local keyword_table = StringSplit(keyword, ';');
    if table.find(keyword_table, 'IsRaidField') > 0 or table.find(keyword_table, 'WeeklyBossMap') > 0 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end

    local indun_classid = tonumber(ctrl:GetUserValue("MOVE_INDUN_CLASSID"));
	local indun_cls = GetClassByType("Indun", indun_classid);
	local dungeon_type = TryGetProp(indun_cls, "DungeonType", "None")
    if dungeon_type ~= "Raid" and string.find(dungeon_type, "MythicDungeon") ~= 1 then
        return;
    end

    ui.CloseFrame("induninfo");
    ReqRaidAutoUIOpen(indun_classid);
end

function REQ_RAID_SOLO_UI_OPEN(frame, ctrl)
    if session.world.IsIntegrateServer() == true or IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end

    if world.GetLayer() ~= 0 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end

    local map = GetClass('Map', session.GetMapName());
    local keyword = TryGetProp(map, 'Keyword', 'None');
    local keyword_table = StringSplit(keyword, ';');
    if table.find(keyword_table, 'IsRaidField') > 0 or table.find(keyword_table, 'WeeklyBossMap') > 0 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end

    local indun_classid = tonumber(ctrl:GetUserValue("MOVE_INDUN_CLASSID"));
    local indun_cls = GetClassByType("Indun", indun_classid);
    local dungeon_type = TryGetProp(indun_cls, "DungeonType", "None");
    local sub_type = TryGetProp(indun_cls, "SubType", "None");
    if dungeon_type ~= "Raid" and sub_type ~= "Casual" then
        return;
    end

    ui.CloseFrame("induninfo");
    ReqRaidSoloUIOpen(indun_classid);
end

function REQ_TOSHERO_ENTER(frame, ctrl)    
    local pc = GetMyPCObject();
    if GetTotalJobCount(pc) < 4 then
        ui.SysMsg(ScpArgMsg('ClassCountIsNotFull'));
        return
    end
    
    -- 매칭 던전중이거나 pvp존이면 이용 불가
    if session.world.IsIntegrateServer() == true or IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end

    -- 퀘스트나 챌린지 모드로 인해 레이어 변경되면 이용 불가
    if world.GetLayer() ~= 0 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end
    
    -- 레이드 지역에서 이용 불가
    local map = GetClass('Map', session.GetMapName());
    local keyword = TryGetProp(map, 'Keyword', 'None');
    local keyword_table = StringSplit(keyword, ';');
    if table.find(keyword_table, 'IsRaidField') > 0 or table.find(keyword_table, 'WeeklyBossMap') > 0 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end

    local indunClassID = 652
	local indunClass = GetClassByType("Indun", indunClassID);
	local dungeonType = TryGetProp(indunClass, "DungeonType", "None")
    if dungeonType ~= "TOSHero" then
        return;
    end
    
    ReqTOSHeroEnter(indunClassID);
end

function INDUNINFO_FAVORITE_BUTTON(parent, ctrl)
    local frame = parent:GetTopParentFrame();
    local ctrl_name = parent:GetName();
    local groupID = string.gsub(ctrl_name,"CATEGORY_CTRL_","");
    local favorite_list = INDUNINFO_GET_FAVORITE_INDUN_LIST();
    if table.find(favorite_list, groupID) ~= 0 then
        ui.SetFavoriteIndun(groupID, true)
    else
        if #favorite_list < 10 then
            ui.SetFavoriteIndun(groupID, false)
        end
    end
end

function INDUN_INFO_UPDATE_FAVORITE(frame, msg, groupID)
    local frame = ui.GetFrame("induninfo")
    local tab = GET_CHILD_RECURSIVELY(frame, "tab");
    local categoryBox = GET_CHILD_RECURSIVELY(frame,"categoryBox")
    local favorite_list = INDUNINFO_GET_FAVORITE_INDUN_LIST();
    local tab_idx = tab:GetSelectItemIndex()

    if INDUNINFO_FAVORITE_TAB_FIRST_BTN(favorite_list, categoryBox, tab) == false then
        categoryBox:RemoveAllChild();
        GET_CHILD_RECURSIVELY(frame,"infoBox"):ShowWindow(0);
        GET_CHILD_RECURSIVELY(frame,"resetInfoText"):ShowWindow(0);
        GET_CHILD_RECURSIVELY(frame,"resetInfoText_Week"):ShowWindow(0);
    else 
        if tab_idx == 0 then
            local ctrl_name = GET_CHILD(categoryBox,"CATEGORY_CTRL_"..groupID):GetName();
            categoryBox:RemoveChild(ctrl_name);
            INDUNINFO_CATEGORY_ALIGN_DEFAULT(categoryBox);
        else
            INDUNINFO_CHANGE_FAVORITE_IMG(categoryBox, groupID)
        end
    end
end


function INDUNINFO_GET_FAVORITE_INDUN_LIST()
    local list = {};
    local aObj = GetMyAccountObj();
    for i = 1, 10 do
        local induninfo = TryGetProp(aObj, "FAVORITE_INDUN_"..i, "None");
        if induninfo ~= "None" then
            table.insert(list, induninfo);
        end
    end
    return list;
end

function INDUNINFO_FAVORITE_TAB_FIRST_BTN(favorite_list, categoryBox, tab)
    if tab:GetSelectItemIndex() == 0 then
        for k,v in pairs(g_indunCategoryList) do
            if table.find(favorite_list, v) ~= 0 then
                local ctrl = categoryBox:GetChild("CATEGORY_CTRL_"..v);
                if ctrl ~= nil then
                    local btn = ctrl:GetChild("button");
                    INDUNINFO_CATEGORY_LBTN_CLICK(ctrl, btn);
                    return true;
                end
            end
        end
        for k,v in pairs(g_contentsCategoryList) do
            if table.find(favorite_list, v) ~= 0 then
                local ctrl = categoryBox:GetChild("CATEGORY_CTRL_"..v);
                local btn = ctrl:GetChild("button");
                INDUNINFO_CATEGORY_LBTN_CLICK(ctrl, btn);
                return true;
            end
        end
        return false;
    end
end

function INDUNINFO_CHANGE_FAVORITE_IMG(categoryBox, groupID)
    local categoryCtrl = categoryBox:GetChild("CATEGORY_CTRL_"..groupID);
    local favorite_img = GET_CHILD_RECURSIVELY(categoryCtrl, "favorite");
    if favorite_img:GetImageName() == "star_in_arrow" then
        favorite_img:SetImage("star_out_arrow");
    else
        favorite_img:SetImage("star_in_arrow")
    end
end

function PVP_INDUNINFO_OPEN_SHOP(frame, btn)
    REQ_TEAM_BATTLE_SHOP_OPEN()
    return;
end

function PVP_INDUNINFO_CHARACTER_REGIST(parent, btn)
    CHARACTER_CHANGE_REGISTER_OPEN();
end

function REQ_EARRING_RAID_UI_OPEN(frame, ctrl)
    if session.world.IsIntegrateServer() == true or IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end

    if world.GetLayer() ~= 0 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end

    local map = GetClass('Map', session.GetMapName());
    local keyword = TryGetProp(map, 'Keyword', 'None');
    local keyword_table = StringSplit(keyword, ';');
    if table.find(keyword_table, 'IsRaidField') > 0 or table.find(keyword_table, 'WeeklyBossMap') > 0 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end

    local indun_classid = tonumber(ctrl:GetUserValue("MOVE_INDUN_CLASSID"));
    local indun_cls = GetClassByType("Indun", indun_classid);
    local dungeon_type = TryGetProp(indun_cls, "DungeonType", "None");
    local sub_type = TryGetProp(indun_cls, "SubType", "None");
    if dungeon_type ~= "EarringRaid" then
        return;
    end

    ui.CloseFrame("induninfo");
    ReqEarringRaidEnter(indun_classid);
end

function REQ_LEVEL_DUNGEON_UI_OPEN(parent, ctrl)
    if session.world.IsIntegrateServer() == true or IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end

    if world.GetLayer() ~= 0 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end

    local map = GetClass('Map', session.GetMapName());
    local keyword = TryGetProp(map, 'Keyword', 'None');
    local keyword_table = StringSplit(keyword, ';');
    if table.find(keyword_table, 'IsRaidField') > 0 or table.find(keyword_table, 'WeeklyBossMap') > 0 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end

    local indun_classid = tonumber(ctrl:GetUserValue("MOVE_INDUN_CLASSID"));
    local indun_cls = GetClassByType("Indun", indun_classid);
    local dungeon_type = TryGetProp(indun_cls, "DungeonType", "None");
    local sub_type = TryGetProp(indun_cls, "SubType", "None");
    if dungeon_type ~= "Indun" and dungeon_type ~= "MissionIndun" and sub_type ~= "Level" then
        return;
    end

    ui.CloseFrame("induninfo");
    ReqLevelDungeonEnter(indun_classid);
end

-- ** pilgrim mode ** --
-- dialog open
function REQ_RAID_PILGRIM_UI_OPEN(frame, ctrl)
    -- 매칭 던전중이거나 pvp존이면 이용 불가
    if session.world.IsIntegrateServer() == true or IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end

    -- 퀘스트나 챌린지 모드로 인해 레이어 변경되면 이용 불가
    if world.GetLayer() ~= 0 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end
    
    -- 레이드 지역에서 이용 불가
    local map = GetClass('Map', session.GetMapName());
    local keyword = TryGetProp(map, 'Keyword', 'None');
    local keyword_table = StringSplit(keyword, ';');
    if table.find(keyword_table, 'IsRaidField') > 0 or table.find(keyword_table, 'WeeklyBossMap') > 0 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end

    local indun_classid = tonumber(ctrl:GetUserValue("MOVE_INDUN_CLASSID"));
	local indun_cls = GetClassByType("Indun", indun_classid);
    local dungeon_type = TryGetProp(indun_cls, "DungeonType", "None")
    local sub_type = TryGetProp(indun_cls, "SubType", "None");
    if dungeon_type ~= "Raid" and dungeon_type ~= "EarringRaid" and string.find(dungeon_type, "MythicDungeon") ~= 1 and sub_type ~= "Pilgrim" then
        return;
    end

    ui.CloseFrame("induninfo");
    ReqPilgrimModeEnter(indun_classid);
end

-- pilgrim mode rank
function ON_RAID_PILGRIM_TRIBULATION_INDUNINFO_OPEN(frame, ctrl)
    if frame ~= nil then
        help.RequestAddHelp('TUTO_PILGRIM_2')

        local red_button = GET_CHILD_RECURSIVELY(frame, "RedButton");
        if red_button ~= nil then
            local indun_class_id = tonumber(red_button:GetUserValue("MOVE_INDUN_CLASSID"));
            local indun_cls = GetClassByType("Indun", indun_class_id);
            if indun_cls ~= nil then
                local mgame_name = TryGetProp(indun_cls, "MGame", "None");
                PILGRIM_TRIBULATION_INDUNINFO_REQ(mgame_name);
            end
        end
    end
end

-- 주간 입장 텍스트 설정
function INDUNINFO_DRAW_CATEGORY_DETAIL_LIST_SET_WEEKLY_ENTERANCE(indun_list_box, indun_cls, dungeon_type, is_weekly_reset)
    local top_frame = indun_list_box:GetTopParentFrame();
    if top_frame ~= nil then
        local cannot_enter_text = GET_CHILD_RECURSIVELY(top_frame, "canNotEnterText"); --랭킹 집계로 인해 토요일 오전 0시부터 오전 6시 사이에는 입장이 불가능합니다.    
        local reset_info_text = GET_CHILD_RECURSIVELY(top_frame, "resetInfoText"); --"입장 횟수는 매일 %s시에 초기화 됩니다."
        local reset_info_text_week = GET_CHILD_RECURSIVELY(top_frame, "resetInfoText_Week"); --"입장 횟수는 매주 월요일 %s시에 초기화 됩니다."
    
        local reset_time = INDUN_RESET_TIME % 12;
        local am_pm = ClMsg("AM");
        if INDUN_RESET_TIME > 12 then am_pm = ClMsg("PM"); end
        
        -- event 예외처리
        if dungeon_type == "Event" then
            local cls_reset_time = TryGetProp(indun_cls, "ResetTime", 0);
            if cls_reset_time > 12 then am_pm = ClMsg("PM"); end
            reset_time = cls_reset_time % 12;
        end
    
        if dungeon_type == "ChallengeMode_HardMode" then
            reset_info_text:ShowWindow(0);
            reset_info_text_week:ShowWindow(0);
            return; 
        end
    
        if dungeon_type == "TOSHero" then
            cannot_enter_text:ShowWindow(1);
            reset_info_text:ShowWindow(0);
            reset_info_text_week:ShowWindow(0);
            return;
        end
        cannot_enter_text:ShowWindow(0);
    
        if is_weekly_reset == true then 
            -- 주간
            reset_info_text:ShowWindow(0);
            local reset_text_weekly = string.format("%s %s", am_pm, reset_time);
            reset_info_text_week:SetTextByKey("resetTime", reset_text_weekly);
            reset_info_text_week:ShowWindow(1);
        else
            -- 일간
            reset_info_text_week:ShowWindow(0);
            local reset_text = string.format("%s %s", am_pm, reset_time);
            reset_info_text:SetTextByKey("resetTime", reset_text);
            reset_info_text:ShowWindow(1);
        end
    end
end