local currentIndex = 0;
local IsMinimizeHighlight = false;
--init
function POPOBOOST_ON_INIT(addon, frame)
    addon:RegisterMsg('POPOBOOST_REWARD_RSET', 'POPOBOOST_RESET_ITEM_REWARD');
    addon:RegisterMsg('POPOBOOST_PARTICIPATE_RESET', 'POPOBOOST_RESET_PARTICIPATE');

    -- local pc = GetMyPCObject();
    -- if POPOBOOST_POPOBUFF_REMINE_TIME(pc) == false then
    -- end
end


-------- local function



--이번 시즌에 해당하는 프로그래스를 넘긴다.
local function POPOBOOSET_GET_PROGRESS_INFORMATION(index)
    local list, cnt = GetClassList("popoboost_inforamation");
    local AccountProp = GET_POPOBOOST_ACCPROP();
    local count = 0;
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(list,i);
        if cls ~= nil then
            local seasonprop = TryGetProp(cls, "SeasonProperty", "None")
            if seasonprop == AccountProp then
                if count == index then
                    return cls;
                end
                count = count + 1;
            end
        end
    end
    return nil;
end

local function POPOBOOST_GET_REWARD_INFO(pc, index)
    local progressInfo = POPOBOOSET_GET_PROGRESS_INFORMATION(index);
    if progressInfo == nil then
        return;
    end
    if pc == nil then
        return;
    end
    local acc = GetMyAccountObj(pc);
    if acc == nil then
        return;
    end
    local progress = TryGetProp(acc,progressInfo.AccountProp,-1);

    return progress;
end


local function POPOBOOST_CHECK_EVENT_PARTICIPATE()
	local pc = GetMyPCObject()
    if pc == nil then
        return false;
    end
	local aobj = GetMyAccountObj(pc)
    if aobj == nil then
        return false;
    end
    local etc = GetMyEtcObject(pc);
    if etc == nil then
        return false;
    end
    local AccProp = GET_CURRENT_SEASCON_POPOBOST_INFO();
    local participate = TryGetProp(aobj, AccProp, 0);

    local etcProp = GET_POPOBOOST_ETCPROP();
    local isParticipatePC = TryGetProp(etc, etcProp, 0);    
    --pc_etc에서 참가 캐릭터인지도 체크를 해줘야한다.
    if (participate == 1 or participate == 3) and isParticipatePC == 1 then
        return true;
    end
    return false;
end


local function POPOBOOST_GET_PROGRESS()
    return tonumber(currentIndex);
end

local function POPOBOOST_IS_PREMIUM()
    local myPC = GetMyPCObject()
    if myPC == nil then
        return false;
    end
	local aobj = GetMyAccountObj(myPC)
    if aobj == nil then
        return false;
    end
    local AccProp = GET_POPOBOOST_ACCPROP();

    local premium = TryGetProp(aobj, AccProp, 0);
    if premium >= 2 then
        return true;
    end
    return false;
end 



local function POPOBOOST_CHECK_PARTICIPATE(frame, pc)
    local mainbox = frame:GetChild('MainBox');
    local previewBox = mainbox:GetChild('PreviewGBox');
    previewBox:ShowWindow(0);

    local acc = GetMyAccountObj(pc);
    if acc == nil then
        return;
    end
    local AccProp = GET_POPOBOOST_ACCPROP();
    local popoProp = TryGetProp(acc, AccProp, "None");

    if popoProp == 0 or popoProp == 2 then
        previewBox:ShowWindow(1);
    else 
        previewBox:ShowWindow(0);
    end
end

local function POPOBOOST_SET_REWARD_ICON(frame, ctrlset, itemCls, itemName, itemCount, isRecieve)
    local num_text = GET_CHILD(ctrlset, "num")
    local gb = GET_CHILD(ctrlset, "gb")
    local gb_slot = GET_CHILD(ctrlset, "gb_slot")
    local slot_consume = GET_CHILD(gb_slot, "slot_consume")
    local disable_shadow = GET_CHILD(ctrlset,"disable_shadow");

    local icon = CreateIcon(slot_consume)
    if itemName ~= "None" then
        icon:SetImage(itemName)
        SET_ITEM_TOOLTIP_BY_NAME(icon, itemCls.ClassName)
        icon:SetTooltipOverlap(1)
        num_text:SetTextByKey("value", itemCount)
        if isRecieve == true then
            disable_shadow:ShowWindow(1);
        else
            disable_shadow:ShowWindow(0);
        end
    end

end

local function SET_POPOBOOST_GUIDE_TEXT(frame)
    local MainBox = GET_CHILD(frame, "MainBox");
    local InfoGBox = GET_CHILD(MainBox, "InfoGBox");
    local GuideGBox = GET_CHILD(InfoGBox, "GuideGBox");
    local guideText = GET_CHILD(GuideGBox, "guideText", "ui::CRichText");

    guideText:SetTextByKey("value","testetsetestsetsetsetsetse");
end


local function POPOBOOST_SET_CONTENT_IMAGE(frame)
    local recommandContent = GET_CHILD_RECURSIVELY(frame,"recommandContent");
    if recommandContent == nil then
        return ;
    end
    local progress = POPOBOOST_GET_PROGRESS();

    local popo_info_cls = POPOBOOSET_GET_PROGRESS_INFORMATION(progress);
    if popo_info_cls == nil then
        return;
    end
    local GuideImage = TryGetProp(popo_info_cls,"GuideImage","None");

    recommandContent:SetImage(GuideImage);
end

local function POPOBOOST_SET_GUIDE_TEXT(frame)
    local guideText = GET_CHILD_RECURSIVELY(frame,"guideText");
    local guideTextAlret = GET_CHILD_RECURSIVELY(frame,"guideTextAlret");

    if guideText == nil then
        return ;
    end
    if guideTextAlret == nil then
        return ;
    end
    local progress = POPOBOOST_GET_PROGRESS();

    local popo_info_cls = POPOBOOSET_GET_PROGRESS_INFORMATION(progress);
    if popo_info_cls == nil then
        return;
    end
    local GuideText = TryGetProp(popo_info_cls,"GuideText","None");
    local GuideItem = TryGetProp(popo_info_cls,"GuideItem","None");
    local ClientMsg = TryGetProp(popo_info_cls,"ClientMsg","None");

    if progress == 0 then
        guideText:SetTextByKey('value', ScpArgMsg(ClientMsg, "QUEST", GuideText) );
        guideTextAlret:SetTextByKey('value', ClMsg("EVENT_2308_W_POPOBOOST_GUIDE_MESSAGE_ARLET_QUEST"));
    else
        guideText:SetTextByKey('value', ScpArgMsg(ClientMsg, "CONTENT", GuideText, "ITEM", GuideItem) );
        guideTextAlret:SetTextByKey('value', ClMsg("EVENT_2308_W_POPOBOOST_GUIDE_MESSAGE_ARLET"));
    end
    
end

local function POPOBOOST_SET_PREMIUM_BOX(frame)
    local RewardGBox = GET_CHILD_RECURSIVELY(frame,"RewardGBox");
    local premiumRewardUnActive = GET_CHILD_RECURSIVELY(RewardGBox,"premiumRewardUnActive");
    if premiumRewardUnActive == nil then
        return ;
    end

    local isPremium = POPOBOOST_IS_PREMIUM();
    if isPremium == true then
        premiumRewardUnActive:ShowWindow(0);
    else
        premiumRewardUnActive:ShowWindow(1);
    end

end


local function POPOBOOST_GEARSCORE_BTN_SET(frame)
    if frame == nil then
        return;
    end
    local pc = GetMyPCObject();
    if pc == nil then
        return ; 
    end
    local acc = GetMyAccountObj(pc);
    if acc == nil then
        return;
    end


    local ScoreGBox = GET_CHILD_RECURSIVELY(frame,"ScoreGBox");

    local offsetX = 185
    local offsetY = 0
    local index = 6

    local gearscore = POPOBOOST_GET_MAX_GEARSCORE(pc);
    for i = 0, index do
        local ctrlName = string.format("popoboost_gearscore_btn%d",i);
        local score = ScoreGBox:CreateOrGetControlSet('popoboost_gearscore_btn',ctrlName, i * offsetX, offsetY);
        local gearscorePic = GET_CHILD(score,"gearscorePic");
        local gearscoreBtn = GET_CHILD(score,"gearscoreBtn");
        local highlight = GET_CHILD(score,"highlight");

        
        local rewardClass = POPOBOOSET_GET_PROGRESS_INFORMATION(i);
        local score = TryGetProp(rewardClass,"RewardScore", 300000);

        highlight:ShowWindow(0);
        gearscoreBtn:SetEventScript(ui.LBUTTONUP,"POPOBOOST_REWARD_CHANGE_BY_GEARSCORE");
		gearscoreBtn:SetEventScriptArgNumber(ui.LBUTTONUP, i);

        local ProgressProp = GET_POPOBOOST_PROGRESPROP();
        if ProgressProp == "None" then
            return;
        end
        local propName = string.format("%s%d",ProgressProp,i)
        local progress = TryGetProp(acc,propName,-2);
        local isPremium = POPOBOOST_IS_PREMIUM();

        IsMinimizeHighlight = false;
        if gearscore >= score then
            local imageName = string.format("popoboost_gearscore_reach_%d",i);
            gearscorePic:SetImage(imageName);
            if progress == 1 and isPremium == true then
                highlight:ShowWindow(1);
                IsMinimizeHighlight = true;
            elseif progress == -1 then
                highlight:ShowWindow(1);
                IsMinimizeHighlight = true;
            elseif progress == 0 then
                highlight:ShowWindow(1);
                IsMinimizeHighlight = true;
            end
    
        else
            local imageName = string.format("popoboost_gearscore_%d",i);
            gearscorePic:SetImage(imageName);
        end

    end
end

local function POPOBOOST_IS_OVER_GEARSCORE()
    local pc = GetMyPCObject();
    if pc == nil then
        return ; 
    end
    local Progress = POPOBOOST_GET_PROGRESS();
    local rewardClass = POPOBOOSET_GET_PROGRESS_INFORMATION(Progress);
    local gearscore = POPOBOOST_GET_MAX_GEARSCORE(pc);
    local destScore = TryGetProp(rewardClass,"RewardScore","30000");
    if tonumber(gearscore) >= tonumber(destScore) then
        return true;
    end
    return false;
end

local function POPOBOOST_IS_OVER_GEARSCORE_BY_INDEX(progress)
    local pc = GetMyPCObject();
    if pc == nil then
        return ; 
    end
    local rewardClass = POPOBOOSET_GET_PROGRESS_INFORMATION(progress);
    local gearscore = POPOBOOST_GET_MAX_GEARSCORE(pc);
    local destScore = TryGetProp(rewardClass,"RewardScore","30000");
    if gearscore >= destScore then
        return true;
    end
    return false;
end

local function POPOBOOST_SET_GEARSCORE_BTN_STATE(frame)
    if frame == nil then
        return ;
    end
    local ScoreGBox = GET_CHILD_RECURSIVELY(frame,"ScoreGBox")
    
    local index = POPOBOOST_GET_PROGRESS();
    local maxidx = 6
    local offsetX = 185
    local offsetY = 15

    for i = 0, maxidx do
        local ctrlName = string.format("popoboost_gearscore_btn%d",i);
        local score = ScoreGBox:CreateOrGetControlSet('popoboost_gearscore_btn',ctrlName, i * offsetX, offsetY);
        local gearscoreBtn = GET_CHILD(score,"gearscoreBtn");
        if i == index then
            gearscoreBtn:SetImage("popoboost_gearscore_arrow_cursoron");
        else
            gearscoreBtn:SetImage("popoboost_gearscore_arrow");
        end
    end
end

local function POPOBOOST_SET_BANNER(frame)
    local bannerList, bannerCnt = GetClassList("popoboost_banner")
    local bannerImg = GET_CHILD_RECURSIVELY(frame,"bannerImg");
    for i = 0, bannerCnt -1 do
        local bannerCls = GetClassByIndexFromList(bannerList,i);
        local banner_nation = TryGetProp(bannerCls, 'Nation', 'None')
		if banner_nation == 'None' or banner_nation == config.GetServiceNation() then
			local showtype = TryGetProp(banner, "ShowType", "None");

            local start_date_time = TryGetProp(bannerCls, 'StartDateTime', 'None')
            
            local end_date_time = TryGetProp(bannerCls, 'EndDateTime', 'None')
            local start_ret_time = nil
            local end_ret_time = nil
            if start_date_time ~= 'None' and end_date_time ~= 'None' then
                use_start_date_time = true
                local lua_time = date_time.get_lua_datetime_from_str(start_date_time)
                start_ret_time = os.date('*t', lua_time)
                lua_time = date_time.get_lua_datetime_from_str(end_date_time)
                end_ret_time = os.date('*t', lua_time)
                
                local tail = (string.format('%02d%02d%02d', start_ret_time['day'], start_ret_time['hour'], start_ret_time['min']))
                remainStartTime = CHECK_EVENTBANNER_REMAIN_TIME(string.format('%04d%02d', start_ret_time['year'], start_ret_time['month']), tail)	
                
                remainNewTime = CHECK_EVENTBANNER_REMAIN_TIME(string.format('%04d%02d', start_ret_time['year'], start_ret_time['month']), 
                string.format('%02d%02d%02d', start_ret_time['day'], start_ret_time['hour'], start_ret_time['min']))
                remainDeadlineTime = CHECK_EVENTBANNER_REMAIN_TIME(string.format('%04d%02d', end_ret_time['year'], end_ret_time['month']), 
                string.format('%02d%02d%02d', end_ret_time['day'], end_ret_time['hour'], end_ret_time['min']))
                remainEndTime = CHECK_EVENTBANNER_REMAIN_TIME(string.format('%04d%02d', end_ret_time['year'], end_ret_time['month']), 
                string.format('%02d%02d%02d', end_ret_time['day'], end_ret_time['hour'], end_ret_time['min']))
                remainExchangeTime = CHECK_EVENTBANNER_REMAIN_TIME(0, 0)
                if remainEndTime ~= nil and remainEndTime >= 0 then
                    local ImagePath = TryGetProp(bannerCls, 'ImagePath', 'None');
                    bannerImg:SetImage(ImagePath);
                end
            end
        end
    end
end

-------- main function

--오픈 시 호출
function OPEN_POPOBOOST()
    local frame = ui.GetFrame('popoboost');
    if frame == nil then
        return;
    end

    local pc = GetMyPCObject();
    if pc == nil then
        return ; 
    end
    local score = GET_PLAYER_GEAR_SCORE(pc)
    local lv = pc.Lv;

    --account property를 받아와서 이벤트 진행중인지 체크해야함.
    POPOBOOST_CHECK_PARTICIPATE(frame, pc);
    POPOBOOST_SET_PREMIUM_BOX(frame);
    POPOBOOST_GEARSCORE_BTN_SET(frame);
    POPOBOOST_SET_BANNER(frame)

    local btn = GET_CHILD_RECURSIVELY(frame,"participate")
    btn:EnableHitTest(1);

    if lv <= 480 and score <= 8000 then
        --이벤트 버튼 활성화
        btn:EnableHitTest(1);
    end
    --현재 기어스코어 달성률에 따라서 아이템 정보를 가져와야 한다.
    --서버에서 가져와야하는거 아닌가??

    POPOBOOST_RESET_ITEM_REWARD(frame)
    --POPO_GUIDE_QUEST_RED_DOT(frame)
end

----- 기어스코어 게이지 업데이트
function POPOBOOST_GEARSCOREGAUGE_UPDATE(frame)
    local pc = GetMyPCObject();
    if pc == nil then
        return ; 
    end
    local GearScoreGauge = GET_CHILD_RECURSIVELY(frame,"GearScoreGauge");
    local currentScore = POPOBOOST_GET_MAX_GEARSCORE(pc);
    local maxScore = 19000; 
    local startScore = 14000;
    if currentScore <= startScore then
        local percente = (currentScore) / (startScore) * 0.16;
        GearScoreGauge:SetPoint(percente, 1);
    else
        GearScoreGauge:SetPoint(currentScore - 13047, maxScore - 13047);
    end 
end

-------이벤트 참여 ui 팝업
function POPOBOOST_PRESS_EVENT_PARTICIPATE(frame)
    local pc = GetMyPCObject();
    if pc == nil then
        return ; 
    end
    local acc = GetMyAccountObj(pc);
    if acc == nil then
        return;
    end

    local myLv = TryGetProp(pc, 'Lv', 0);
    local myGearScore = GET_PLAYER_GEAR_SCORE(pc);

    if POPOBOOST_CHECK_ELIGIBILITY(myLv,myGearScore) == false then
        ui.SysMsg(ClMsg('EVENT_2308_W_POPOBOOST_EVENT_PARTICIPATE_CHECK_ALRET'));
        return ;
    end
    local opt = { CompareTextDesc = ClMsg('RellayWantParticipatePoPoBoost') }
    WARNINGMSGBOX_EX_FRAME_OPEN(frame, 'None', 'popoboostparticipate;CantRollbackEventParticipate/POPOBOOST_SUCCESS_EVENT_PARTICIPATE', 0, opt);
end

--이벤트 참여 세팅
function POPOBOOST_SUCCESS_EVENT_PARTICIPATE(frame)
    local mypc = GetMyPCObject();
    if mypc == nil then
        return ; 
    end
    --MoveZone(pc, 'c_orsha', -25, 176, 274);

    local AccessoryCategory = 0;
    local WeaponCategory = 0;

    local mySession = session.GetMySession();
    local jobHistory = mySession:GetPCJobInfo();
    local jobHistoryCnt = jobHistory:GetJobCount();
    for i = 0, jobHistoryCnt - 1 do
		local jobInfo = jobHistory:GetJobInfoByIndex(i);
        --소드맨
        if 1001 == jobInfo.jobID then 
            WeaponCategory = 1;
            AccessoryCategory = 1;
        --위자드
        elseif 2001 == jobInfo.jobID then 
            WeaponCategory = 2;
            AccessoryCategory = 2;
        --아처
        elseif 3001 == jobInfo.jobID then 
            WeaponCategory = 3;
            AccessoryCategory = 1;
        --클레릭
        elseif 4001 == jobInfo.jobID then 
            WeaponCategory = 4;  
            AccessoryCategory = 2;
        --스카우트
        elseif 5001 == jobInfo.jobID then 
            WeaponCategory = 5;  
            AccessoryCategory = 1;
        end
    end
    pc.ReqExecuteTx_Item("POPOBOOST_PARTICIPATE_EVENT", WeaponCategory, AccessoryCategory);
    ui.CloseFrame('popoboost');
end

function POPOBOOST_EVENT_START(frame,arg,arg1,arg2)
    local pc = GetMyPCObject();
    if pc == nil then
        return ; 
    end
    local acc = GetMyAccountObj(pc);
    if acc == nil then
        return;
    end
    local AccProp = GET_POPOBOOST_ACCPROP();
    local popoProp = TryGetProp(acc,AccProp,"None");

    local tx = TxBegin(pc)
    if tx == nil then return end

    if popoProp == 2 then
        TxSetIESProp(tx, acc, AccProp, 3)
    else
        TxSetIESProp(tx, acc, AccProp, 1)
    end
    
    local ret = TxCommit(tx)
    if ret == "SUCCESS" then
        return;
    end
end

---보상 설정
function POPOBOOST_SET_REWARD(frame, name)
	local pc = GetMyPCObject();

    if pc == nil then
        return;
    end
    local acc = GetMyAccountObj(pc);
    if acc == nil then
        return;
    end

    local rewardBG = GET_CHILD_RECURSIVELY(frame,name);
    local tag = 0;
    local rewardNum = 0;

    local Progress = POPOBOOST_GET_PROGRESS();

    if name == "normalReward" then
        tag = string.format("Normal%d", Progress);
        rewardNum = 0;
    elseif name == "premiumReward" then
        tag = string.format("Premium%d", Progress);
        rewardNum = 1;
    end


    
    local item_list = popoboost_table()
    if item_list[tag] == nil then
        return;
    end
    local itemCnt = 0;
    for k, v in pairs(item_list[tag]) do
        itemCnt = itemCnt + 1;
    end
    local maxitem = 4;
    local i = 0;
    local j = 0;
    local offsetX = 80;
    local offsetY = 75;
    local offset = 20;
    local defaultOffset = 50;
    if itemCnt > maxitem then
        defaultOffset = 10;
    end

    rewardBG:RemoveAllChild();

    local index = POPOBOOST_GET_PROGRESS();
    local ProgressProp = GET_POPOBOOST_PROGRESPROP();
    if ProgressProp == "None" then
        return;
    end
    local propName = string.format("%s%d", ProgressProp,index);
    local progress = TryGetProp(acc,propName,-2);
    local isRecieve = false;
    if name == "normalReward" and (progress == 1 or progress == 3)then
        isRecieve = true;
    elseif name == "premiumReward" and (progress == 2 or progress == 3)then
        isRecieve = true;
    end

    for k, v in pairs(item_list[tag]) do
        local value = i * 10 + j;
        local targetItem = GetClass("Item", k);
        local ctrlName = string.format("%sset%d",name,value);
        local rewards = rewardBG:CreateOrGetControlSet('popoboost_reward',ctrlName, i * offsetX + offset, j * offsetY + defaultOffset);
        POPOBOOST_SET_REWARD_ICON(frame,rewards,targetItem,targetItem.Icon,v,isRecieve)
        i = i + 1;
        if i == maxitem then
            j = j + 1;
            i = 0 ;
        end
    end

end

function POPOBOOST_CREATE_REWARD(frame)
    POPOBOOST_SET_REWARD(frame,"normalReward")
    POPOBOOST_SET_REWARD(frame,"premiumReward")
end

--현재 기어스코어, 현재 단계, 프리미엄 상태인지
function POPOBOOST_TAKE_REWEARD_BTN(frame)
    local progress = POPOBOOST_GET_PROGRESS();

    local isOver = POPOBOOST_IS_OVER_GEARSCORE();
    local isPremium = POPOBOOST_IS_PREMIUM();
    local premium = 0;
    if isPremium == true then
        premium = 1;
    end
    if isOver == true then 
        local popoboost_info = string.format("%d %d", progress, premium);
        pc.ReqExecuteTx_Item('POPOBOOST_REAWRD_REQUEST', "None", popoboost_info);
    end
end

--보상 받기 후 리셋
function POPOBOOST_RESET_ITEM_REWARD(frame, msg, argStr, argNum)
    POPOBOOST_GEARSCOREGAUGE_UPDATE(frame);
    POPOBOOST_CREATE_REWARD(frame);
    SET_POPOBOOST_GUIDE_TEXT(frame);
    POPOBOOST_SET_CONTENT_IMAGE(frame)
    POPOBOOST_SET_GUIDE_TEXT(frame)
    POPOBOOST_SET_GEARSCORE_BTN_STATE(frame);
    POPOBOOST_GEARSCORE_BTN_SET(frame);
    POPOBOOST_ALRET();
end
--참여 여부 리셋
function POPOBOOST_RESET_PARTICIPATE(frame, msg, argStr, argNum)
	local pc = GetMyPCObject();
    POPOBOOST_CHECK_PARTICIPATE(frame, pc);
    SET_POPOBOOST_GUIDE_TEXT(frame);
    POPOBOOST_SET_GUIDE_TEXT(frame)
end

function POPOBOOST_OPEN_TP_SHOP(frame)
	local tpitem = ui.GetFrame('tpitem');
	TP_SHOP_DO_OPEN(tpitem);
end

function POPOBOOST_OPEN_INDUN_SHORTCUT(frame,msg,argStr,argNum)
    local progress = POPOBOOST_GET_PROGRESS();
    local popo_info_cls = POPOBOOSET_GET_PROGRESS_INFORMATION(progress);
    if popo_info_cls == nil then
        return;
    end
    local ShortcutScriptName = TryGetProp(popo_info_cls,"ShortcutScriptName","None");
    local ShortcutParam = TryGetProp(popo_info_cls,"ShortcutParam", 0);

    local script = _G[ShortcutScriptName];
    if progress == 0 then
        --script(nil,nil,nil,ShortcutParam);
    else
        script(ShortcutParam,0,1,1,0)
    end
end 

function POPOBOOST_GODDESS_ROULETTE(frame,arg)
    ui.CloseFrame('popoboost');
    local frame = ui.GetFrame("goddess_roulette")
    GODDESS_ROULETTE_OPEN(frame, nil, nil, 4)
end

function POPOBOOST_REWARD_CHANGE_BY_GEARSCORE(frame, ctrl, str, num)
    local mainFrame = ui.GetFrame("popoboost");
    currentIndex = num;
    POPOBOOST_RESET_ITEM_REWARD(mainFrame)
end

--popoboost premium state apply  item  use
function POPOBOOST_PREMIUM_APPLY_ITEM_CLEINT_SCRIPT(invItem)
    local popobannerlist, cnt = GetClassList("popoboost_banner");
    if popobannerlist == nil then
        return;
    end
    if IS_POPOBOOST_END() == true then
        --기간이 지났을 경우 아이템 수령 로직.
        local itemIES = invItem:GetIESID();
        local itemobj = GetIES(invItem:GetObject());
        local className = itemobj.ClassName;
        pc.ReqExecuteTx_Item("POPOBOOST_PREMIUN_APPLY",itemIES, className);
        return;
    end

    local itemIES = invItem:GetIESID();
    local itemobj = GetIES(invItem:GetObject());
    local className = itemobj.ClassName;
    local str = ScpArgMsg("popoboost_premium_apply");
    local yesScp = string.format("pc.ReqExecuteTx_Item(\"%s\",\"%s\",\"%s\")", "POPOBOOST_PREMIUN_APPLY", itemIES, className);
    ui.MsgBox(str, yesScp, "None");

end


function GET_POPOBOOST_MINIMIZED_HIGHLIGHT()
    IsMinimizeHighlight = false;

    local pc = GetMyPCObject();
    if pc == nil then
        return IsMinimizeHighlight; 
    end
    local acc = GetMyAccountObj(pc);
    if acc == nil then
        return IsMinimizeHighlight;
    end

    local index = 6
    local gearscore = POPOBOOST_GET_MAX_GEARSCORE(pc);
    for i = 0, index do
        local rewardClass = POPOBOOSET_GET_PROGRESS_INFORMATION(i);
        local score = TryGetProp(rewardClass,"RewardScore", 300000);

        local ProgressProp = GET_POPOBOOST_PROGRESPROP();
        if ProgressProp == "None" then
            return IsMinimizeHighlight;
        end    
        local propName = string.format("%s%d",ProgressProp,i)
        local progress = TryGetProp(acc,propName,-2);
        local isPremium = POPOBOOST_IS_PREMIUM();
        if gearscore >= score then
            local imageName = string.format("popoboost_gearscore_reach_%d",i);
            if progress == 1 and isPremium == true then
                IsMinimizeHighlight = true;
            elseif progress == -1 then
                IsMinimizeHighlight = true;
            elseif progress == -2 then
                IsMinimizeHighlight = true;
            elseif progress == 0 then
                IsMinimizeHighlight = true;
            end
        end
    end
    return IsMinimizeHighlight;
end

function POPO_GUIDE_QUEST_OPEN(parent, ctrl, argStr, argNum)
    ON_POPOBOOST_EVENT_STAMP_TOUR_UI_OPEN_COMMAND();
    local frame = ui.GetFrame('popoboost');
    if frame ~= nil then
        frame:ShowWindow(0)
    end
end

function POPO_GUIDE_QUEST_RED_DOT(frame)
	local point = EVENT_STAMP_GET_RECEIVABLE_REWARD_COUNT_POPOBOOST(GetMyAccountObj())

	local notice = GET_CHILD_RECURSIVELY(frame, 'notice_bg')    

	if point > 0 then
		notice:ShowWindow(1)
        -- SYSMENU_NOTICE_TEXT_RESIZE(notice, point)
	elseif point == 0 then
		notice:ShowWindow(0)
	end
end