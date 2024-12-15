local max_view = 3
function ADVENTURE_BOOK_ACHIEVE_MAIN_TAB_SELECTED(parent, mainPage)
    ADVENTURE_BOOK_ACHIEVE_MAIN_INIT(mainPage);
end

-- 메인 초기화
function ADVENTURE_BOOK_ACHIEVE_MAIN_INIT(mainPage)
    if mainPage == nil then 
        local frame = ui.GetFrame("adventure_book")
        local gb_achieve = frame:GetChild('gb_achieve')
        mainPage = gb_achieve:GetChild('page_achieve_main')
    end
    
    ADVENTURE_BOOK_ACHIEVE_INIT_LEVEL_REWARD() -- 업적 레벨 보상
    ADVENTURE_BOOK_ACHIEVE_MAIN_INIT_MY_CHAR_INFO(mainPage) -- 캐릭터 정보
    ADVENTURE_BOOK_ACHIEVE_MAIN_INIT_CUR_STATUS(mainPage) -- 업적 현황
    ADVENTURE_BOOK_ACHIEVE_MAIN_INIT_EXCHANGE_EVENT(mainPage) -- 업적 교환 이벤트
    ADVENTURE_BOOK_ACHIEVE_MAIN_INIT_HIGH_PROGRESS(mainPage) -- 진행도가 높은 업적
    ADVENTURE_BOOK_ACHIEVE_MAIN_INIT_NEW_ACHIEVE(mainPage) -- 신규 업적
end

function ADVENTURE_BOOK_ACHIEVE_MAIN_UPDATE(msg)
    local frame = ui.GetFrame("adventure_book")
    local gb_achieve = frame:GetChild('gb_achieve')
    mainPage = gb_achieve:GetChild('page_achieve_main')

    if msg == "MY_CHAR_INFO" then  -- 캐릭터 정보
        ADVENTURE_BOOK_ACHIEVE_MAIN_INIT_MY_CHAR_INFO(mainPage)
    elseif msg == "CUR_STATUS" then  -- 업적 현황
        ADVENTURE_BOOK_ACHIEVE_MAIN_INIT_CUR_STATUS(mainPage)
    elseif msg == "EXCHANGE_EVENT" then  -- 업적 교환 이벤트
        ADVENTURE_BOOK_ACHIEVE_MAIN_INIT_EXCHANGE_EVENT(mainPage)
    elseif msg == "HIGH_PROGRESS" then  -- 진행도가 높은 업적
        ADVENTURE_BOOK_ACHIEVE_MAIN_INIT_HIGH_PROGRESS(mainPage)
    elseif msg == "NEW_ACHIEVE" then  -- 신규 업적
        ADVENTURE_BOOK_ACHIEVE_MAIN_INIT_NEW_ACHIEVE(mainPage)
    end
end

function ADVENTURE_BOOK_ACHIEVE_MAIN_INIT_MY_CHAR_INFO(mainPage)
    local page_achieve_main_left = GET_CHILD(mainPage, "page_achieve_main_left")
    local page_achieve_main_info = GET_CHILD(page_achieve_main_left, "page_achieve_main_info")

    -- job info
    local myHandle = session.GetMyHandle();
    local jobClassID = info.GetJob(myHandle);
    local etc = GetMyEtcObject();
    if etc.RepresentationClassID ~= 'None' then
        local repreJobCls = GetClassByType('Job', etc.RepresentationClassID);
        if repreJobCls ~= nil then
            jobClassID = repreJobCls.ClassID;            
        end
    end
    
    local jobCls = GetClassByType('Job', jobClassID);
    local jobIcon = TryGetProp(jobCls, 'Icon');
    if jobIcon == nil then
        return;
    end

    local mySession = session.GetMySession();
    local chariconPic = GET_CHILD(page_achieve_main_info, 'achieve_main_chariconPic');
    chariconPic:SetImage(jobIcon);
    if PARTY_JOB_TOOLTIP_BY_CID ~= nil then -- adventure book의 로드 시점이 partyinfo보다 빨라서 예외처리함
        PARTY_JOB_TOOLTIP_BY_CID(mySession:GetCID(), chariconPic, jobCls);
    end

    -- name
    local teamname_text = GET_CHILD(page_achieve_main_info, 'achieve_main_text');
    teamname_text:SetTextByKey('value', info.GetFamilyName(myHandle));

    -- level
    local achieve_main_level = GET_CHILD(page_achieve_main_info, 'achieve_main_level');

    local achieve_level = 0
    achieve_main_level:SetTextByKey('achieve_level', achieve_level)

    local account = session.barrack.GetMyAccount()
    local team_level = account:GetTeamLevel()
    local achieve_level = GetAchieveLevel()
    local achieve_level_Max = GetAchieveMaxLevel()
    achieve_main_level:SetTextByKey('team_level', team_level)
    achieve_main_level:SetTextByKey('achieve_level', achieve_level)

    -- exp
    local achieve_main_exp = GET_CHILD(page_achieve_main_info, "achieve_main_exp", "ui::CRichText")
    local gauge_achieve_exp = GET_CHILD(page_achieve_main_info, "gauge_achieve_exp", "ui::CGauge")

    local exp_value = GetAchieveCurLevelExp()

    local xpCls = GetClassByType("XP_Achieve", achieve_level)
    local exp_maxvalue = TryGetProp(xpCls, 'TotalXp')

    if achieve_level >= achieve_level_Max then
        achieve_main_exp:SetTextByKey('value', "")
        achieve_main_exp:SetTextByKey('maxvalue', "Max")
        gauge_achieve_exp:SetPoint(1, 1)
    else
        achieve_main_exp:SetTextByKey('value', exp_value)
        achieve_main_exp:SetTextByKey('maxvalue', exp_maxvalue)
        gauge_achieve_exp:SetPoint(exp_value, exp_maxvalue)
    end
    
end

function ADVENTURE_BOOK_ACHIEVE_MAIN_INIT_CUR_STATUS(mainPage)
    local frame = ui.GetFrame("adventure_book")
    local gb_achieve = GET_CHILD(frame, "gb_achieve")
    local page_achieve_main = GET_CHILD(gb_achieve, "page_achieve_main")
    local page_achieve_main_left = GET_CHILD(page_achieve_main, "page_achieve_main_left")

    local listMainCategory = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_MAIN_CATEGORY_CLASS_LIST()
    local listAll = ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_ALL()
    
    for i = 1, #listMainCategory do
        local category = listMainCategory[i].ClassName
        local ctrlSet = GET_CHILD(page_achieve_main_left, "achieve_main_curstatus_"..category)

        local listFilter = ADVENTURE_BOOK_ACHIEVE_CONTENT.FILTER_CATEGORY(listAll, category)
        if category == "Event" then
            listFilter = ADVENTURE_BOOK_ACHIEVE_CONTENT.FILTER_PERIOD(listFilter, 1)
        else
            listFilter = ADVENTURE_BOOK_ACHIEVE_CONTENT.FILTER_NON_PERIOD(listFilter)
        end
        local listComplete = ADVENTURE_BOOK_ACHIEVE_CONTENT.FILTER_COMPLETE(listFilter)
        local listReward = ADVENTURE_BOOK_ACHIEVE_CONTENT.FILTER_REWARD(listFilter)

        local icon_pic = GET_CHILD(ctrlSet, "icon_pic", "ui::CPicture")
        icon_pic:SetImage(listMainCategory[i].Icon)

        local category_name = GET_CHILD(ctrlSet, "category_name", "ui::CRichText")
        category_name:SetText(ClMsg(listMainCategory[i].Name))
        -- local max = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_COUNT_MAX(category)
        local max = #listFilter
        -- local complete = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_COUNT_COMPLETE(category)
        local complete = #listComplete
        local gauge = GET_CHILD(ctrlSet, "gauge_score", "ui::CGauge")
        if max == 0 then
            gauge:SetPoint(0, 0)
        else
            gauge:SetPoint(complete/max*100, 100)
        end

        local shortcut = GET_CHILD(ctrlSet, "shortcut", "ui::CButton")
        shortcut:SetEventScript(ui.LBUTTONUP, "ADVENTURE_BOOK_ACHIEVE_LINK")
        shortcut:SetEventScriptArgString(ui.LBUTTONUP, category);
        
        local newreward = GET_CHILD(ctrlSet, "newreward")
        -- local count = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_COUNT_REWARD(category)
        local count = #listReward
        if count >= 1 then
            newreward:SetVisible(1)
        else
            newreward:SetVisible(0)
        end
    end
end

function ADVENTURE_BOOK_ACHIEVE_SORT_EXCHANGE_EVENT(a, b)
    -- 구매여부
    -- 레벨(내 레벨보다 낮은 내림차순, 내 레벨보다 높은 내림차순)
    -- 등급 내림차순
    -- 구입 비용 내림차순
    -- ClassID

    -- local noBuyList = {} 
    -- local BuyList = {}
    -- for i = 1, #list do
    --     local clsID = TryGetProp(list[i], "ClassID")
    --     if clsID ~= nil then
    --         if IS_GET_REWARD_ACHIEVE_EXCHANGE_EVENT(list.ClassID) == 0 then
    --             noBuyList[#noBuyList + 1] = noBuyList
    --         else
    --             BuyList[#BuyList + 1] = BuyList
    --         end
    --     end
    -- end

    local clsIDA = TryGetProp(a, "ClassID", 0)
    local clsIDB = TryGetProp(b, "ClassID", 0)
    local isGetRewardA = IS_GET_REWARD_ACHIEVE_EXCHANGE_EVENT(clsIDA)
    local isGetRewardB = IS_GET_REWARD_ACHIEVE_EXCHANGE_EVENT(clsIDB)

    if isGetRewardA == 0 and isGetRewardB == 1 then
        return true
    elseif isGetRewardA == 1 and isGetRewardB == 0 then
        return false
    end
    
    -- 레벨
    local achieveLevel = GetAchieveLevel()
    local LimitLevelA = TryGetProp(a, "Limit_Level", "None")
    local LimitLevelB = TryGetProp(b, "Limit_Level", "None")
    if LimitLevelA == "None" then
        LimitLevelA = "0"
    end
    LimitLevelA = tonumber(LimitLevelA)
    if LimitLevelB == "None" then
        LimitLevelB = "0"
    end
    LimitLevelB = tonumber(LimitLevelB)
    if achieveLevel < LimitLevelA and achieveLevel >= LimitLevelB then
        return false
    elseif achieveLevel < LimitLevelB and achieveLevel >= LimitLevelA then
        return true
    end

    if LimitLevelA > LimitLevelB then
        return true
    elseif LimitLevelA < LimitLevelB then
        return false
    end

    -- 등급
    local grade = { "SS", "S", "A", "B", "C" }
    local GradeA = TryGetProp(a, "Grade")
    local GradeB = TryGetProp(b, "Grade")
    local GradeNumA = 1
    local GradeNumB = 1
    for i = 1, #grade do
        if grade == GradeA then
            GradeNumA = i
            break
        end
    end
    for i = 1, #grade do
        if grade == GradeB then
            GradeNumB = i
            break
        end
    end

    if GradeNumA < GradeNumB then
        return true
    elseif GradeNumA > GradeNumB then
        return false
    end

    -- 비용
    local NeedCoinA = TryGetProp(a, "NeedCoin")
    local NeedCoinB = TryGetProp(b, "NeedCoin")
    
    if NeedCoinA > NeedCoinB then
        return true
    elseif NeedCoinA < NeedCoinB then
        return false
    end
    
    return clsIDA < clsIDB
end

function ADVENTURE_BOOK_ACHIEVE_MAIN_INIT_EXCHANGE_EVENT(mainPage)
    local page = GET_CHILD(mainPage, "page_achieve_main_left")
    local gb_list = GET_CHILD(page, "gb_achieve_main_exchangeevent_list")
    local gb = GET_CHILD(gb_list, "gb_achieve_main_exchangeevent_list_scroll")
    local renewal_text = GET_CHILD(page, "achieve_main_exchangeevent_nextrenewal_text")
    local coming_soon = GET_CHILD(page, "coming_soon")
    local left_btn = GET_CHILD(page, "left_btn")
    local right_btn = GET_CHILD(page, "right_btn")

    gb:RemoveAllChild()

    local cnt = 0
    local drawList = {}
    local eventSetCls = GetClassByStrProp("AchieveExchangeEvent", "ClassName", "AchieveExchangeEventSetting")
    if eventSetCls ~= nil then
        local eventState = TryGetProp(eventSetCls, "EventState", "0")
        if tostring(eventState) == "1" then
            local itemList = {}
            local itemListStr = session.achieve.GetAchieveExchangeEventItemList()
            if itemListStr == "None" then
                cnt = 0
            else
                local itemList = StringSplit(itemListStr, '/');
                for i = 1, #itemList do
                    local cls = GetClassByType("AchieveExchangeEventItem", tonumber(itemList[i]))
                    if cls ~= nil then
                        drawList[#drawList + 1] = cls;
                    end
                end
                cnt = #drawList;
            end
        end
    end

    -- 정렬
    table.sort(drawList, ADVENTURE_BOOK_ACHIEVE_SORT_EXCHANGE_EVENT)

    -- 그리기
    for i = 1, cnt do
        local cls = drawList[i]
        ADVENTURE_BOOK_ACHIEVE_MAIN_EXCHANGE_EVENT_INIT_CTRL(gb, i, cls)
    end
    
    -- 3개 이하인 경우 더미 출력
    for i = cnt + 1, max_view do
        ADVENTURE_BOOK_ACHIEVE_MAIN_EXCHANGE_EVENT_INIT_CTRL(gb, i, nil)
    end

    if cnt > 0 then
        coming_soon:SetVisible(0)
    else
        coming_soon:SetVisible(1)
    end

    left_btn:SetEnable(0)
    if cnt < max_view then
        cnt = max_view
        right_btn:SetEnable(0)
    else
        right_btn:SetEnable(1)
    end

    local icon_width = 120
    local icon_space = 10
    gb:Resize(icon_width * cnt + icon_space * (cnt - 1), gb:GetHeight())
    gb:SetMargin(0, 0, 0, 0)
    gb:SetUserValue("pos", 1)
    gb:SetUserValue("max_view", max_view)
    gb:SetUserValue("icon_width", icon_width)
    gb:SetUserValue("icon_space", icon_space)

    -- 남은 시간 표기
    local remainsec = ADVENTURE_BOOK_ACHIEVE_MAIN_GET_EXCHANGE_EVENT_REMAIN_SEC()

    local day = 0
    local hour = 0
    local min = 0
    local sec = 0
    if remainsec >= 0 then
        local day =  math.floor(remainsec/86400)
        local hour = math.floor(remainsec/3600) - (day * 24)
        local min = math.floor(remainsec/60) - (day * 24 * 60) - (hour * 60)
        local sec = math.floor(remainsec%60)
    end

    renewal_text:SetTextByKey('day', day);
    renewal_text:SetTextByKey('hour', hour);
    renewal_text:SetTextByKey('minute', min);
    renewal_text:SetTextByKey('second', sec);
end

function ADVENTURE_BOOK_ACHIEVE_MAIN_GET_EXCHANGE_EVENT_REMAIN_SEC()
    local nextTime = session.achieve.GetNextAchieveExchangeEventResetTime()
    if nextTime == "0" or nextTime == "None" then
        return 0
    end
	local getnow = geTime.GetServerSystemTime()
	local nowstr = string.format("%04d-%02d-%02d %02d:%02d:%02d", getnow.wYear, getnow.wMonth, getnow.wDay, getnow.wHour, getnow.wMinute, getnow.wSecond)
    
	local remainsec = date_time.get_lua_datetime_from_str(nextTime) - date_time.get_lua_datetime_from_str(nowstr)

	return remainsec
end

function ADVENTURE_BOOK_ACHIEVE_MAIN_EXCHANGE_EVENT_INIT_CTRL(gbox, idx, cls)
    if cls == nil then return end

	local ctrl_width = 120
    local ctrl_space = 10
    
    local x = ctrl_width * (idx - 1) + ctrl_space * (idx - 1)

    local ClassID = TryGetProp(cls, "ClassID", idx)
    local ctrlset = gbox:CreateOrGetControlSet("adventure_book_achieve_exchangeevent", "achieve_main_exchangeevent_"..ClassID, ui.LEFT, ui.TOP, x, 0, 0, 0)
    ADVENTURE_BOOK_ACHIEVE_MAIN_EXCHANGE_EVENT_UPDATE_CTRL(ClassID, ctrlset)
end

function ADVENTURE_BOOK_ACHIEVE_MAIN_EXCHANGE_EVENT_UPDATE_CTRL(ClassID, ctrlset)
    if ctrlset == nil then
        local frame = ui.GetFrame("adventure_book")
        local gb_achieve = GET_CHILD(frame, "gb_achieve")
        local mainPage = GET_CHILD(gb_achieve, "page_achieve_main")
        local page = GET_CHILD(mainPage, "page_achieve_main_left")
        local gb_list = GET_CHILD(page, "gb_achieve_main_exchangeevent_list")
        local gbox = GET_CHILD(gb_list, "gb_achieve_main_exchangeevent_list_scroll")
        ctrlset = GET_CHILD(gbox, "achieve_main_exchangeevent_"..ClassID)
    end 
    if ctrlset == nil then return end

    local cls = GetClassByType("AchieveExchangeEventItem", ClassID)

    local level_text = GET_CHILD(ctrlset, "level")
    local num_text = GET_CHILD(ctrlset, "num")
    local icon_consume = GET_CHILD(ctrlset, "icon_consume", "ui::CPicture")
    local consume_text = GET_CHILD(ctrlset, "consume", "ui::CRichText")
    local soldout = GET_CHILD(ctrlset, "icon_soldout")
    local disable_shadow = GET_CHILD(ctrlset, "disable_shadow")
    local gb = GET_CHILD(ctrlset, "gb")
    local gb_slot = GET_CHILD(ctrlset, "gb_slot")
    local slot_consume = GET_CHILD(gb_slot, "slot_consume")

    if cls == nil then
        level_text:SetVisible(0)
        num_text:SetVisible(0)
        icon_consume:SetVisible(0)
        consume_text:SetVisible(0)
        soldout:SetVisible(0)
        disable_shadow:SetVisible(1)
        return
    else
        level_text:SetVisible(1)
        num_text:SetVisible(1)
        icon_consume:SetVisible(1)
        consume_text:SetVisible(1)
    end
    
    -- 보상 여부
    local isGetReward = IS_GET_REWARD_ACHIEVE_EXCHANGE_EVENT(ClassID)

    disable_shadow:SetVisible(isGetReward)
    soldout:SetVisible(isGetReward)

    -- 보상 여부 스크립트
    if isGetReward == 0 then
        gb:SetEventScript(ui.LBUTTONUP, "ADVENTURE_BOOK_ACHIEVE_EXCHANGE_EVENT_REQUEST_REWARD")
        gb:SetEventScriptArgNumber(ui.LBUTTONUP, cls.ClassID)
        
        slot_consume:SetEventScript(ui.LBUTTONUP, "ADVENTURE_BOOK_ACHIEVE_EXCHANGE_EVENT_REQUEST_REWARD")
        slot_consume:SetEventScriptArgNumber(ui.LBUTTONUP, cls.ClassID)
    else
        gb:SetEventScript(ui.LBUTTONUP, "")
        gb:SetEventScriptArgNumber(ui.LBUTTONUP, 0)
        
        slot_consume:SetEventScript(ui.LBUTTONUP, "")
        slot_consume:SetEventScriptArgNumber(ui.LBUTTONUP, 0)
    end

    -- 보상
    local reward = TryGetProp(cls, "ClassName")
    if reward == nil then return 0 end

    local rewardImage = "None"
    local ItemCls = GetClassByStrProp("Item", "ClassName", reward)
    if ItemCls ~= nil then
        local icon = CreateIcon(slot_consume)
        iconName = BEAUTYSHOP_SIMPLELIST_ICONNAME_CHECK(TryGetProp(ItemCls, "Icon", "None"), TryGetProp(ItemCls, "UseGender", "None"))
        if iconName ~= "None" then
            icon:SetImage(iconName)
            SET_ITEM_TOOLTIP_BY_NAME(icon, ItemCls.ClassName)
            icon:SetTooltipOverlap(1)
        end
    end

    -- 레벨
    if cls.Limit_Level == "None" or cls.Limit_Level == "1" or cls.Limit_Level == nil then
        level_text:SetText("All")
    else
        level_text:SetText("Lv: "..cls.Limit_Level)
    end

    -- 갯수
    num_text:SetTextByKey("value", cls.Count)

    -- 재료 코인
    local coinType = TryGetProp(cls, "CoinType")
    if coinType == nil then return 0 end

    local iconImage = "None"
    if coinType == "AccountProp" then
        local accPropCls = GetClassByStrProp("accountprop_inventory_list", "ClassName", cls.CoinName)
        if accPropCls ~= nil then
            iconImage = accPropCls.Icon
            icon_consume:SetTextTooltip(ClMsg(accPropCls.ClassName))
        end
    elseif coinType == "Item" then
        local itemCls = GetClassByStrProp("Item", "ClassName", cls.CoinName)
        if itemCls ~= nil then
            iconImage = itemCls.Icon
            SET_ITEM_TOOLTIP_BY_NAME(icon_consume, itemCls.ClassName)
            icon_consume:SetTooltipOverlap(1)
        end
    end
    
    icon_consume:SetImage(iconImage)

    -- 재료 개수
    consume_text:SetText(GET_COMMAED_STRING(cls.NeedCoin))
end

function ADVENTURE_BOOK_ACHIEVE_MAIN_INIT_HIGH_PROGRESS(mainPage)
    local ExistHistoryList = {}
    local ExceptHistoryList = {}

    ExistHistoryList = ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_EXIST_HISTORY()
    table.sort(ExistHistoryList, ADVENTURE_BOOK_ACHIEVE_CONTENT['SORT_BY_PROGRESS_DES'])
    
    if #ExistHistoryList < 10 then
        ExceptHistoryList = ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_EXCEPT_HISTORY()
    end

    local drawList = {}

    local idx = 1
    while (#drawList) < 10 do
        if #ExistHistoryList < idx then break end
        drawList[#drawList + 1] = ExistHistoryList[idx]
        idx = idx + 1
    end

    idx = 1
    while (#drawList) < 10 do
        if #ExceptHistoryList < idx then break end
        drawList[#drawList + 1] = ExceptHistoryList[idx]
        idx = idx + 1
    end

    local list_box = GET_CHILD(mainPage, "achieve_main_high_progress_list", "ui::CGroupBox")
    ADVENTURE_BOOK_ACHIEVE.FILL_LIST_CONTROL(drawList, list_box, "MainPage_HighProgress")
end

function ADVENTURE_BOOK_ACHIEVE_MAIN_INIT_NEW_ACHIEVE(mainPage)
    local newAchieveList = ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_NEW_ACHIEVE()
    local drawList = ADVENTURE_BOOK_ACHIEVE_CONTENT.SORT_BY_ADDDATE_DES(newAchieveList)

    local list_box = GET_CHILD(mainPage, "achieve_main_new_achieve_list", "ui::CGroupBox")
    ADVENTURE_BOOK_ACHIEVE.FILL_LIST_CONTROL(drawList, list_box, "MainPage_NewAchieve")
end 

-- argnum: Achieve Exchange Reward Class ID
function ADVENTURE_BOOK_ACHIEVE_EXCHANGE_EVENT_REQUEST_REWARD(parent, ctrl, argStr, argNum)
    local cls = GetClassByType("AchieveExchangeEventItem", argNum)
    if cls == nil then return end

    local CoinType = TryGetProp(cls, "CoinType")
    if CoinType == nil then return end
    
    local itemClassName = TryGetProp(cls, "ClassName")
    if itemClassName == nil then return end

    local itemCls = GetClassByStrProp("Item", "ClassName", itemClassName)
    if itemCls == nil then return end

    local rewardItemName = TryGetProp(itemCls, "Name")
    if rewardItemName == nil then return end

    local consumeItemCount = TryGetProp(cls, "NeedCoin")
    if consumeItemCount == nil then return end

    local msg = ""
    if CoinType == "AccountProp" then
        local aObj = GetMyAccountObj()
        local coin = TryGetProp(aObj, cls.CoinName, "0")
        if coin == "None" then
            coin = 0
        end
        if consumeItemCount > tonumber(coin) then
            ui.MsgBox(ClMsg("achieve_exchange_event_reward_not_enough_coin"))
            return
        end

        msg = ScpArgMsg("achieve_exchange_event_reward_confirm_coin", "CONSUME", ClMsg(cls.CoinName), "NUM", consumeItemCount, "ITEM", rewardItemName)
    elseif CoinType == "Item" then
        local consumeItemClassName = TryGetProp(cls, "CoinName")
        if consumeItemClassName == nil then return end
        
        local ConsumeItemCls = GetClassByStrProp("Item", "ClassName", consumeItemClassName)
        if ConsumeItemCls == nil then return end

        if consumeItemCount > GET_TOTAL_ITEM_CNT(ConsumeItemCls.ClassID) then
            ui.MsgBox(ClMsg("achieve_exchange_event_reward_not_enough_item"))
            return 
        end

        local consumeItemName = TryGetProp(ConsumeItemCls, "Name")
        if consumeItemName == nil then return end
        
        msg = ScpArgMsg("achieve_exchange_event_reward_confirm_item", "CONSUME", consumeItemName, "NUM", consumeItemCount, "ITEM", rewardItemName)
    else
        return
    end

    ui.MsgBox(msg, "ADVENTURE_BOOK_ACHIEVE_EXCHANGE_EVENT_REQUEST_REWARD_ACCEPT("..argNum..")", "None")
end

function ADVENTURE_BOOK_ACHIEVE_EXCHANGE_EVENT_REQUEST_REWARD_ACCEPT(classID)
    session.ReqAchieveExchangeEventReward(classID)
end