-- shared_popoboost
local item_list = nil
local ticket_item_list = nil
local maxProgress = 3;
function popoboost_table()
    if item_list == nil then
        item_list = {}
    end

    local IsPAPAYA = GET_POPOBOOST_SERVER();

    item_list['Normal0'] = {}
    item_list['Normal0']['Event_JobexpCard_BOX'] = 1
    item_list['Normal0']['Ability_Point_Stone_100000'] = 20
    item_list['Normal0']['HiddenAbility_MasterPiece_Fragment_Event'] = 120
    item_list['Normal0']['open_ticket_cabinet_vibora_lv4'] = 1
    item_list['Normal0']['open_ticket_cabinet_goddess_lv3'] = 4

    item_list['Normal1'] = {}
    item_list['Normal1']['misc_transmutationSpreader_NoTrade'] = 50
    item_list['Normal1']['misc_leatherFalouros_NoTrade'] = 50
    item_list['Normal1']['Ticket_TurbulentCore_Auto_Enter_NoTrade'] = 2
    item_list['Normal1']['selectbox_Gem_Relic_Cyan'] = 1
    item_list['Normal1']['selectbox_Gem_Relic_Magenta'] = 1
    item_list['Normal1']['selectbox_Gem_Relic_Black'] = 1
    item_list['Normal1']['VakarineCertificateCoin_50000p'] = 2

    item_list['Normal2'] = {}
    item_list['Normal2']['misc_transmutationSpreader_NoTrade'] = 350
    item_list['Normal2']['misc_leatherFalouros_NoTrade'] = 350
    item_list['Normal2']['Ticket_TurbulentCore_Auto_Enter_NoTrade'] = 5
    item_list['Normal2']['Event_ChallengeModeReset_6'] = 5
    item_list['Normal2']['relicgem_lvup_scroll_lv7'] = 3
    item_list['Normal2']['VakarineCertificateCoin_50000p'] = 2

    item_list['Normal3'] = {}
    item_list['Normal3']['misc_transmutationSpreader_NoTrade'] = 700
    item_list['Normal3']['Ticket_TurbulentCore_Auto_Enter_NoTrade'] = 5
    item_list['Normal3']['Event_ChallengeModeReset_6'] = 5
    item_list['Normal3']['VakarineCertificateCoin_50000p'] = 2

    item_list['Normal4'] = {}
    item_list['Normal4']['misc_leatherFalouros_NoTrade'] = 700
    item_list['Normal4']['Ticket_TurbulentCore_Auto_Enter_NoTrade'] = 5
    item_list['Normal4']['Event_ChallengeModeReset_6'] = 5
    item_list['Normal4']['VakarineCertificateCoin_50000p'] = 2

    item_list['Normal5'] = {}
    item_list['Normal5']['misc_ribbonRoze_NoTrade'] = 600
    item_list['Normal5']['Ticket_Rozethemisterable_Auto_Enter_NoTrade'] = 5
    item_list['Normal5']['Event_ChallengeModeReset_6'] = 5
    item_list['Normal5']['VakarineCertificateCoin_50000p'] = 2

    item_list['Normal6'] = {}
    item_list['Normal6']['Event_Roulette_Coin_PoPo_2404'] = 5
    item_list['Normal6']['piece_fierce_shoulder_high_NoTrade_Belonging'] = 1
    item_list['Normal6']['piece_penetration_belt_high_Belonging'] = 1
    item_list['Normal6']['ChallengeExpertModeCountUp_Ev_1'] = 5
    item_list['Normal6']['RadaCertificateCoin_50000p'] = 4
    item_list['Normal6']['damage_font_skin_cherryblossom'] = 1

    
    -- 프리미엄 보상

    item_list['Premium0']={}
    item_list['Premium0']['emoticonItem_2404_popo'] = 1
    item_list['Premium0']['class_unlock_achievement_select'] = 1
    item_list['Premium0']['open_ticket_cabinet_vibora_lv4'] = 2
    item_list['Premium0']['misc_Ether_Gem_Socket_480_NoTrade'] = 4
    item_list['Premium0']['selectbox_Gem_High_480'] = 4
    item_list['Premium0']['lv480_aether_lvup_scroll_lv100'] = 4

    item_list['Premium1']={}
    item_list['Premium1']['misc_transmutationSpreader_NoTrade'] = 50
    item_list['Premium1']['misc_leatherFalouros_NoTrade'] = 50
    item_list['Premium1']['Multiple_Token_ChallengeMode_Auto_NoTrade'] = 5
    item_list['Premium1']['misc_reinforce_percentUp_500_NoTrade'] = 50
    item_list['Premium1']['RadaCertificateCoin_50000p'] = 2
    item_list['Premium2']={}
    item_list['Premium2']['misc_transmutationSpreader_NoTrade'] = 100
    item_list['Premium2']['misc_leatherFalouros_NoTrade'] = 100
    item_list['Premium2']['Multiple_Token_ChallengeMode_Auto_NoTrade'] = 5
    item_list['Premium2']['misc_reinforce_percentUp_500_NoTrade'] = 50
    item_list['Premium2']['RadaCertificateCoin_50000p'] = 2

    item_list['Premium3']={}
    item_list['Premium3']['misc_transmutationSpreader_NoTrade'] = 200
    item_list['Premium3']['Multiple_Token_ChallengeMode_Auto_NoTrade'] = 5
    item_list['Premium3']['misc_reinforce_percentUp_500_NoTrade'] = 50
    item_list['Premium3']['RadaCertificateCoin_50000p'] = 2

    item_list['Premium4']={}
    item_list['Premium4']['misc_leatherFalouros_NoTrade'] = 200
    item_list['Premium4']['Multiple_Token_ChallengeMode_Auto_NoTrade'] = 5
    item_list['Premium4']['misc_reinforce_percentUp_500_NoTrade'] = 50
    item_list['Premium4']['RadaCertificateCoin_50000p'] = 2

    item_list['Premium5']={}
    item_list['Premium5']['misc_ribbonRoze_NoTrade'] = 200
    item_list['Premium5']['Multiple_Token_Rozethemisterable_Solo_NoTrade'] = 5
    item_list['Premium5']['misc_reinforce_percentUp_500_NoTrade'] = 50
    item_list['Premium5']['RadaCertificateCoin_50000p'] = 2

    item_list['Premium6']={}
    item_list['Premium6']['Event_Roulette_Coin_PoPo_2404'] = 5
    item_list['Premium6']['EVENT_2404_dream_of_a_popolion'] = 1
    item_list['Premium6']['piece_GabijaEarring_select_job_NoTrade_Belonging'] = 1
    item_list['Premium6']['EP12_EXPERT_MODE_MULTIPLE_NoTrade'] = 5
    item_list['Premium6']['RadaCertificateCoin_50000p'] = 4
    
    
    return item_list
end

function GET_TICKET_ITEM_LIST(AccProp)
    if ticket_item_list == nil then
        ticket_item_list = {}
    end

    ticket_item_list["EVENT_2023_POPOBOOST"] ={}
    ticket_item_list["EVENT_2023_POPOBOOST"]["emoticonItem_summer_popo_1"] = 1
    ticket_item_list["EVENT_2023_POPOBOOST"]["class_unlock_achievement_select"] = 1
    ticket_item_list["EVENT_2023_POPOBOOST"]["open_ticket_cabinet_vibora_lv4"] = 2
    ticket_item_list["EVENT_2023_POPOBOOST"]["misc_Ether_Gem_Socket_480_NoTrade"] = 2
    ticket_item_list["EVENT_2023_POPOBOOST"]["selectbox_Gem_High_480"] = 2
    ticket_item_list["EVENT_2023_POPOBOOST"]["lv480_aether_lvup_scroll_lv100"] = 2

    ticket_item_list["EVENT_2312_POPOBOOST"] ={}
    ticket_item_list["EVENT_2312_POPOBOOST"]["emoticonItem_2312_popo"] = 1
    ticket_item_list["EVENT_2312_POPOBOOST"]["class_unlock_achievement_select"] = 1
    ticket_item_list["EVENT_2312_POPOBOOST"]["open_ticket_cabinet_vibora_lv4"] = 2
    ticket_item_list["EVENT_2312_POPOBOOST"]["misc_Ether_Gem_Socket_480_NoTrade"] = 2
    ticket_item_list["EVENT_2312_POPOBOOST"]["selectbox_Gem_High_480"] = 2
    ticket_item_list["EVENT_2312_POPOBOOST"]["lv480_aether_lvup_scroll_lv100"] = 2

    ticket_item_list["EVENT_2404_POPOBOOST"] ={}
    ticket_item_list["EVENT_2404_POPOBOOST"]["emoticonItem_2404_popo"] = 1
    ticket_item_list["EVENT_2404_POPOBOOST"]["class_unlock_achievement_select"] = 1
    ticket_item_list["EVENT_2404_POPOBOOST"]["open_ticket_cabinet_vibora_lv4"] = 2
    ticket_item_list["EVENT_2404_POPOBOOST"]["misc_Ether_Gem_Socket_480_NoTrade"] = 4
    ticket_item_list["EVENT_2404_POPOBOOST"]["selectbox_Gem_High_480"] = 4
    ticket_item_list["EVENT_2404_POPOBOOST"]["lv480_aether_lvup_scroll_lv100"] = 4
    
    return ticket_item_list;
end

function GET_POPOBOOST_PARTICIPATE_MAX_PROGRESS()
    return maxProgress;
end


function POPOBOOST_CHECK_ELIGIBILITY(lv, gearscore)
    if lv >= 10 then
        return false;
    end

    return true;
end


function POPOBOOST_SET_MAX_GEARSCORE(pc)
    --server only
    if pc == nil then
        return ;
    end
    local etc = GetETCObject(pc);
    if etc == nil then
        return;
    end
    local maxprop = GET_POPOBOOST_MAXPROP();
	local maxGearScore = TryGetProp(etc,maxprop,0);
    local currentGearScore = POPOBOOST_GET_GEARSCORE(pc);

    if IsServerSection(pc) ~= 1 then
        return;
    end
    if currentGearScore > maxGearScore then
        local etc = GetETCObject(pc);
        if etc == nil then
            return ;
        end
    
        local tx = TxBegin(pc);
        if tx == nil then
            return;
        end
        local maxprop = GET_POPOBOOST_MAXPROP();
	    TxSetIESProp(tx, etc, maxprop, currentGearScore);

        local ret = TxCommit(tx)

        if ret == "SUCCESS" then
        end
    end
    local equipList = GetEquipItemList(pc)        
    local itemcnt = 0;
    for i = 1, #equipList do
        local itemobj = equipList[i]
        if itemobj ~= nil then
            local PopoItemProp = GET_POPOBOOST_ITEMPROP();
            local popoboostProp = TryGetProp(itemobj,"popoboost", 0)
            
            if PopoItemProp > 0 and popoboostProp == PopoItemProp then 
                itemcnt = itemcnt + 1;               
            end
        end
    end
    if itemcnt >= 11 then
        RunScript("TX_EVENT_STAMP_TOUR_PROP_SET_POPOBOOST",pc,5,itemcnt,"POPO_EVENT_STAMP")
    end

end

function POPOBOOST_GET_MAX_GEARSCORE(pc)
    if pc == nil then
        return 0;
    end
    local etcObj
    if IsServerSection(pc) == 1 then
        etcObj = GetETCObject(pc);
    else
        etcObj = GetMyEtcObject();
    end
    if etcObj == nil then
        return 0;
    end
    local maxprop = GET_POPOBOOST_MAXPROP();
	local maxGearScore = TryGetProp(etcObj,maxprop,0);
    local currentGearScore = POPOBOOST_GET_GEARSCORE(pc);

    if maxGearScore > currentGearScore then
        return maxGearScore;
    end
    return currentGearScore;
end

function POPOBOOST_GET_GEARSCORE(pc)
    local score = GET_PLAYER_POPOBOOST_GEAR_SCORE(pc);
    return score;
end

function POPOBOOST_POPOBUFF_REMINE_TIME(pc)
    if IS_SEASON_SERVER(pc) == 'YES' then
        return false
    end
    -- local IsPAPAYA = GET_POPOBOOST_SERVER();

    local end_time = GET_POPOBOOST_END_TIME();
    local gearscore = POPOBOOST_GET_MAX_GEARSCORE(pc);
    if gearscore >= 19000 then
        return true;
    end

    if GET_CURRENT_SEASCON_POPOBOST_INFO() == nil then
        return true;
    end

    return false;
end

function GET_POPOBOOST_END_TIME()
    local end_time ="0000-00-00 00:00:00";

    local popobannerlist , cnt = GetClassList("popoboost_banner");
    if popobannerlist == nil then
        return end_time;
    end

    for i = 0 , cnt - 1 do
        local popobannercls = GetClassByIndexFromList(popobannerlist, i);
        local Nation;
        if IsServerSection() == 1 then        
            Nation = GetServiceNation();
        else
            Nation = config.GetServiceNation();
        end
        if Nation == TryGetProp(popobannercls,"Nation","None") then
            local accprop = TryGetProp(popobannercls,"AccountProp","None");
            local PopoboostAccountProp = GET_POPOBOOST_ACCPROP();
            if accprop == PopoboostAccountProp then
                end_time = TryGetProp(popobannercls,"EndDateTime", "0000-00-00 00:00:00");
            end
        end
    end

    return end_time;
end

-- true == end /// false == not end
function IS_POPOBOOST_END()
    local cls = GET_CURRENT_SEASCON_POPOBOST_INFO();
    if cls == nil then
        return true;
    else
        return false;
    end

    -- if IsServerSection() == 1 then        
    --     local now = date_time.get_lua_now_datetime_str()
    --     local ret = date_time.is_later_than(now, end_time)	
    --     return ret
    -- else        
    --     local serverTime = geTime.GetServerSystemTime()
    --     local now = string.format("%04d-%02d-%02d %02d:%02d:%02d", serverTime.wYear, serverTime.wMonth, serverTime.wDay, serverTime.wHour, serverTime.wMinute, serverTime.wSecond)
    --     local ret = date_time.is_later_than(now, end_time)	        
    --     return ret
    -- end
end

local function POPOPBOOST_PREIODE_CHECK(start_time, end_time)
    if IsServerSection() == 1 then        
        local ret = date_time.is_between_time(start_time, end_time);
        if ret == true then
            return true;
        end
    else        
        local serverTime = geTime.GetServerSystemTime()
        local now = string.format("%04d-%02d-%02d %02d:%02d:%02d", serverTime.wYear, serverTime.wMonth, serverTime.wDay, serverTime.wHour, serverTime.wMinute, serverTime.wSecond)
        local EndRet = date_time.is_later_than(now, end_time)	        
        local StartRet = date_time.is_later_than(now, start_time)
        if EndRet == false and StartRet == true then
            return true;
        end
    end        
end

function GET_CURRENT_SEASCON_POPOBOST_INFO()
    local clsList, cnt = GetClassList("popoboost_season_info")
    if clsList == nil then
        return nil;
    end
    for i = 0, cnt do
        local info = GetClassByIndexFromList(clsList, i);
        if info ~= nil then
            local startprop = ""
            local endprop = ""
            local IsPAPAYA = GET_POPOBOOST_SERVER();

            if IsPAPAYA == 1 then
                startprop = "PAPAYAStartTime"
                endprop = "PAPAYAEndTime"
            elseif IsPAPAYA == 2 then
                startprop = "TAIWANStartTime"
                endprop = "TAIWANTEndTime"
            elseif IsPAPAYA == 3 then
                startprop = "GlobalStartTime"
                endprop = "GlobalEndTime"
            else
                startprop = "StartTime"
                endprop = "EndTime"
            end
            local start_time = TryGetProp(info, startprop, "0000-00-00 00:00:00");
            local end_time = TryGetProp(info, endprop, "0000-00-00 00:00:00");

            if POPOPBOOST_PREIODE_CHECK(start_time,end_time) == true then
                return info;    
            end        
        end
    end   
    return nil
end

function GET_POPOBOOST_ACCPROP()
    local cls = GET_CURRENT_SEASCON_POPOBOST_INFO()
    if cls == nil then
        return "None"
    end
    local AccProp = TryGetProp(cls, "AccountProp", "None");
    return AccProp;
end

function GET_POPOBOOST_ETCPROP()
    local cls = GET_CURRENT_SEASCON_POPOBOST_INFO()
    if cls == nil then
        return "None"
    end
    local etcprop = TryGetProp(cls, "EtcProperty", "None");
    return etcprop;
end

function GET_POPOBOOST_MAXPROP()
    local cls = GET_CURRENT_SEASCON_POPOBOST_INFO()
    if cls == nil then
        return "None"
    end
    local MaxScoreProp = TryGetProp(cls, "MaxScoreProp", "None");
    return MaxScoreProp;
end

function GET_POPOBOOST_ITEMPROP()
    local cls = GET_CURRENT_SEASCON_POPOBOST_INFO()
    if cls == nil then
        return 0
    end
    local prop = TryGetProp(cls, "ItemPropValue", 0);
    return tonumber(prop);
end

function GET_POPOBOOST_PROGRESPROP()
    local cls = GET_CURRENT_SEASCON_POPOBOST_INFO()
    if cls == nil then
        return "None"
    end
    local prop = TryGetProp(cls, "GiveItemProp", "None");
    return prop;
end

----0 이상일 경우 참가 한 캐릭터
function IS_POPOBOOST_PARTICIPATE_CHARACTER(pc)
    if pc== nil then
        return false;
    end
    local etcObj
    if IsServerSection(pc) == 1 then
        etcObj = GetETCObject(pc);
    else
        etcObj = GetMyEtcObject(pc);
    end

    if etcObj == nil then
        return false;
    end

    local etcprop = GET_POPOBOOST_ETCPROP()
    local isParticipate = TryGetProp(etcObj, etcprop, -1);
    if isParticipate > 0 then
        return true;
    end

    return false;
end

-- 0 : 미참여
-- 1 : 참여
-- 2 : 프리미엄 티켓만 구매 (미참여)
-- 3 : 프리티엄 티켓 구매 참여
function IS_POPOBOOST_PARTICIPATE_ACCOUNT(pc)
    if pc== nil then
        return false;
    end
    local acc = nil;
    if IsServerSection() == 1 then
        acc = GetAccountObj(pc);
    else
        acc = GetMyAccountObj(pc);
    end
    if acc == nil then
        return false;
    end

    local accprop = GET_POPOBOOST_ACCPROP()
    
    local isParticipate = TryGetProp(acc, accprop, -1);
    if isParticipate == 1 or isParticipate == 3 then
        return true;
    end

    return false;
end

-- return server : 0  w
-- return server : 1 papaya
-- return server : 2 taiwan 
function GET_POPOBOOST_SERVER()
    if IsServerSection() == 1 then        
        if GetServiceNation() == "PAPAYA" then
            return 1;
        elseif GetServiceNation() == "TAIWAN" then
            return 2
        elseif GetServiceNation() =="GLOBAL" then
            return 3;
        else
            return 0;
        end
    else
        if config.GetServiceNation() == "PAPAYA" then
            return 1;
        elseif config.GetServiceNation() == "TAIWAN" then
            return 2
        elseif config.GetServiceNation() =="GLOBAL" then
            return 3;
        else
            return 0;
        end
    end
    return 0;
end