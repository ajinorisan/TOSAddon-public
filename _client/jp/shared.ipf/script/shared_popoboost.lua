-- shared_popoboost
local item_list = nil
local ticket_item_list = nil
local maxProgress = 3;
local BuffExceptMapList = nil
            
-- 캐시된 서버 타입
local cached_server_type = nil

-- 전역 캐시 테이블
local cache = {
    server_type = nil,
    season_info = nil,
    current_time = nil,
    item_lists = {},
    progress_info = {}
}
            
-- 캐시 관리 함수 통합
local function get_cached(key, fetch_func, timeout)
    local data = cache[key]
    if data and data.expires > os.time() then
        return data.value
    end
        
    if fetch_func then
        local value = fetch_func()
        cache[key] = {
            value = value,
            expires = os.time() + (timeout or 300) -- 기본 5분
        }
        return value
    end
    return nil
end
            
local item_data = {
    normal = {
        [0] = {
            open_ticket_cabinet_goddess_lv3 = 4,
            Event_JobexpCard_BOX = 1,
            Event_Drug_RedApple20 = 20,
            Event_Drug_BlueApple20 = 20,
            Ability_Point_Stone_100000 = 20,
            HiddenAbility_MasterPiece_Fragment_Event = 120
            
        },
        [1] = {
            open_ticket_cabinet_vibora_lv4 = 3,
            Premium_boostToken05_14d = 1,
            Exchange_Weapon_Book_520_1d = 4,
            misc_pvp_mine2_NotLimit_10000 = 4
        },
        [2] = {
            misc_boss_CrystalGolem_NoTrade = 180,
            misc_reinforce_percentUp_520_NoTrade = 70,
            JurateCertificateCoin_50000p = 2,
            Ticket_Golem_Auto_Enter_LimitTime = 2
        },
        [3] = {
            misc_boss_CrystalGolem_NoTrade = 540,
            misc_reinforce_percentUp_520_NoTrade = 205,
            JurateCertificateCoin_50000p = 4,
            Ticket_Golem_Auto_Enter_LimitTime = 2
        },
        [4] = {
            misc_boss_DarkNeringa_NoTrade = 720,
            misc_reinforce_percentUp_520_NoTrade = 270,
            JurateCertificateCoin_50000p = 5,
            Ticket_Neringa_Auto_Enter_LimitTime = 2,
        },
        [5] = {
            misc_merregina_blackpearl_NoTrade = 520,
            misc_reinforce_percentUp_520_NoTrade = 205,
            JurateCertificateCoin_50000p = 4,
            Ticket_DespairIsland_Auto_Enter_LimitTime = 2,
        },
        [6] = {
            EP16_fierce_shoulder_event_box_NoTrade = 1,
            EP16_penetration_belt_event_box_NoTrade = 1,
            selectbox_specialclass_allinone3 = 1,
            Event_Roulette_Coin_PoPo_2512 = 5
        }
    },
    premium = {
        [0] = {
            emoticonItem_2512_popo = 1,
            class_unlock_achievement_select = 1,
            EVENT_2403_Friend_Invite_Coin = 8,
            misc_Ether_Gem_Socket_520_NoTrade = 4,
            Piece_Gem_High_520 = 4,
            lv520_aether_lvup_scroll_lv100 = 4
        },
        [1] = {
            Gem_Select_Box_Color = 8,
            misc_gemExpStone12_NoTrade = 8,
            Exchange_Weapon_Book_520 = 4,
            misc_pvp_mine2_NotLimit_10000 = 4
        },
        [2] = {
            misc_boss_CrystalGolem_NoTrade = 75,
            misc_reinforce_percentUp_520_NoTrade = 30,
            misc_Premium_reinforce_percentUp_460 = 15,
            misc_pvp_mine2_NotLimit_10000 = 4
        },
        [3] = {
            misc_boss_CrystalGolem_NoTrade = 225,
            misc_reinforce_percentUp_520_NoTrade = 85,
            misc_Premium_reinforce_percentUp_460 = 15,
            misc_pvp_mine2_NotLimit_10000 = 4
        },
        [4] = {
            misc_boss_DarkNeringa_NoTrade = 300,
            misc_reinforce_percentUp_520_NoTrade = 115,
            misc_Premium_reinforce_percentUp_460 = 15,
            misc_pvp_mine2_NotLimit_10000 = 4,
        },
        [5] = {
            misc_merregina_blackpearl_NoTrade = 220,
            misc_reinforce_percentUp_520_NoTrade = 85,
            misc_Premium_reinforce_percentUp_460 = 15,
            misc_pvp_mine2_NotLimit_10000 = 4,
        },
        [6] = {
            plate_shade_of_the_decennial_tree = 1,
            Event_Roulette_Coin_PoPo_2512 = 5,
            piece_GabijaEarring_select_job_NoTrade_Belonging = 1,
            AustejaCertificateCoin_50000p = 5,
        }
    },
    papaya = {
        [0] = {
            open_ticket_cabinet_goddess_lv3 = 4,
            Event_JobexpCard_BOX = 1,
            Event_Drug_RedApple20 = 20,
            Event_Drug_BlueApple20 = 20,
            Ability_Point_Stone_100000 = 20,
            HiddenAbility_MasterPiece_Fragment_Event = 120
            
        },
        [1] = {
            open_ticket_cabinet_vibora_lv4 = 3,
            Premium_boostToken05_14d = 1,
            Exchange_Weapon_Book_500_1d = 4,
            misc_pvp_mine2_NotLimit_10000 = 4
        },
        [2] = {
            misc_upinis_wing_NoTrade = 180,
            misc_reinforce_percentUp_510_NoTrade = 70,
            RadaCertificateCoin_50000p = 2,
            Ticket_DreamyForest_Auto_Enter_LimitTime = 2
        },
        [3] = {
            misc_upinis_wing_NoTrade = 540,
            misc_reinforce_percentUp_510_NoTrade = 205,
            RadaCertificateCoin_50000p = 4,
            Ticket_DreamyForest_Auto_Enter_LimitTime = 2
        },
        [4] = {
            misc_slogutis_fragments_NoTrade = 720,
            misc_reinforce_percentUp_510_NoTrade = 270,
            RadaCertificateCoin_50000p = 5,
            Ticket_AbyssalObserver_Auto_Enter_LimitTime = 2,
        },
        [5] = {
            misc_merregina_blackpearl_NoTrade = 520,
            misc_reinforce_percentUp_510_NoTrade = 205,
            RadaCertificateCoin_50000p = 4,
            Ticket_DespairIsland_Auto_Enter_LimitTime = 2,
        },
        [6] = {
            piece_fierce_shoulder_high_NoTrade_Belonging = 1,
            piece_penetration_belt_high_Belonging = 1,
            selectbox_specialclass_allinone = 1,
            Event_Roulette_Coin_PoPo_2506 = 5
        }
    },
    papaya_premium = {
        [0] = {
            emoticonItem_2503_popo = 1,
            class_unlock_achievement_select = 1,
            EVENT_2403_Friend_Invite_Coin = 8,
            misc_Ether_Gem_Socket_500_NoTrade = 4,
            Piece_Gem_High_500 = 4,
            lv500_aether_lvup_scroll_lv100 = 4
        },
        [1] = {
            Gem_Select_Box_Color = 8,
            misc_gemExpStone12_NoTrade = 8,
            Exchange_Weapon_Book_500 = 4,
            misc_pvp_mine2_NotLimit_10000 = 4
        },
        [2] = {
            misc_upinis_wing_NoTrade = 75,
            misc_reinforce_percentUp_510_NoTrade = 30,
            misc_Premium_reinforce_percentUp_460 = 15,
            misc_pvp_mine2_NotLimit_10000 = 43
        },
        [3] = {
            misc_upinis_wing_NoTrade = 225,
            misc_reinforce_percentUp_510_NoTrade = 85,
            misc_Premium_reinforce_percentUp_460 = 15,
            misc_pvp_mine2_NotLimit_10000 = 4
        },
        [4] = {
            misc_slogutis_fragments_NoTrade = 300,
            misc_reinforce_percentUp_510_NoTrade = 115,
            misc_Premium_reinforce_percentUp_460 = 15,
            misc_pvp_mine2_NotLimit_10000 = 4,
        },
        [5] = {
            misc_merregina_blackpearl_NoTrade = 220,
            misc_reinforce_percentUp_510_NoTrade = 85,
            misc_Premium_reinforce_percentUp_460 = 15,
            misc_pvp_mine2_NotLimit_10000 = 4,
        },
        [6] = {
            Event_Roulette_Coin_PoPo_2506 = 5,
            plate_achieve_First_Emperor = 1,
            piece_GabijaEarring_select_job_NoTrade_Belonging = 1,
            JurateCertificateCoin_50000p = 5,
        }
    }
}
            
--아이템 아이커 계승
local function check_equipment_inheritance(pc, equip_list, config)
    local count = 0
    local prop_value = GET_POPOBOOST_ITEMPROP()
        
    for _, item in ipairs(equip_list) do
        if item and TryGetProp(item, "popoboost", 0) == prop_value and 
           table.find(config.types, item.EquipGroup) >= 1 and 
           TryGetProp(item, "InheritanceItemName", "None") ~= "None" then
            count = count + 1
        end
    end

    return count >= config.required_count
end

local function check_equipment_upgrade_inheritance(pc, groupname, config)
    if table.find(config.types, groupname) > 0 then
        return true;
    end

    return false;
end

local progress_checks = {
    [1] = function(pc, equip_list)
        return check_equipment_inheritance(pc, equip_list, {
            types = {"SHIRT",
            "PANTS",
            "BOOTS",
            "GLOVES"},
            required_count = 4
        })
    end,
    [2] = function(pc, equip_list)
        return check_equipment_inheritance(pc, equip_list, {
            types = {"Weapon", "SubWeapon", "THWeapon", "Armor"},
            required_count = 4
        })
    end,
    [3] = function(pc, groupname)
        return check_equipment_upgrade_inheritance(pc, groupname, {
            types = {"Armor"}
        })
    end,
    [4] = function(pc, groupname)
        return check_equipment_upgrade_inheritance(pc, groupname, {
            types = {"Armor"}
        })
    end,
    [5] = function(pc, groupname)
        return check_equipment_upgrade_inheritance(pc, groupname, {
            types = {"Weapon", "SubWeapon", "THWeapon"}
        })
    end
}
            
local SERVER_TYPES = {
    PAPAYA = 1,
    TAIWAN = 2,
    GLOBAL = 3,
    DEFAULT = 0
}
            
local function get_server_type()
    if cache.server_type then 
        return cache.server_type 
    end

    local nation = IsServerSection() == 1 
        and GetServiceNation() 
        or config.GetServiceNation()
        
    cache.server_type = SERVER_TYPES[nation] or SERVER_TYPES.DEFAULT
    return cache.server_type
end
        
local function check_period(start_time, end_time)
    local current_time = get_cached("current_time", function()
        if IsServerSection() == 1 then
            return date_time.get_lua_now_datetime_str()
    else
            local serverTime = geTime.GetServerSystemTime()
            return string.format("%04d-%02d-%02d %02d:%02d:%02d", 
                serverTime.wYear, serverTime.wMonth, serverTime.wDay, 
                serverTime.wHour, serverTime.wMinute, serverTime.wSecond)
        end
    end, 60) -- 1분 캐싱

    return date_time.is_between_time(start_time, end_time, current_time)
end
            
function create_item_list(server_type)
    return get_cached("item_list_" .. server_type, function()
        local list = {}
        local normal_template = server_type == 1 and item_data.papaya or item_data.normal
        local premium_template = server_type == 1 and item_data.papaya_premium or item_data.premium
            
        for level = 0, 6 do
            list["Normal"..level] = normal_template[level]
            list["Premium"..level] = premium_template[level]
        end
            
        return list
    end, 3600) -- 1시간 캐싱
end
            
function popoboost_table()
    return get_cached("item_list", function()
        local result = {}
        local server_type = GET_POPOBOOST_SERVER()

        -- 서버 타입에 따라 다른 아이템 리스트 사용
        local normal_template = server_type == 1 and item_data.papaya or item_data.normal
        local premium_template = server_type == 1 and item_data.papaya_premium or item_data.premium

        for level = 0, 6 do
            result['Normal'..level] = normal_template[level]
            result['Premium'..level] = premium_template[level]
    end
    
        return result
    end, 3600) -- 1시간 캐싱
end

function GET_BUFF_EXCEPTION_LIST()
    return get_cached("buff_except_list", function()
        return {
            "Raid_DarkNeringa",
            "Raid_CrystalGolem",
            "raid_kivotos_island"
        }
    end, 3600) -- 1시간 캐싱
end

function GET_TICKET_ITEM_LIST(AccProp)
    if ticket_item_list then
        return ticket_item_list
    end

    ticket_item_list = {
        ["EVENT_2023_POPOBOOST"] = {
            emoticonItem_summer_popo_1 = 1,
            class_unlock_achievement_select = 1,
            open_ticket_cabinet_vibora_lv4 = 2,
            misc_Ether_Gem_Socket_480_NoTrade = 2,
            selectbox_Gem_High_480 = 2,
            lv480_aether_lvup_scroll_lv100 = 2
        },
        ["EVENT_2312_POPOBOOST"] = {
            emoticonItem_2312_popo = 1,
            class_unlock_achievement_select = 1,
            open_ticket_cabinet_vibora_lv4 = 2,
            misc_Ether_Gem_Socket_480_NoTrade = 2,
            selectbox_Gem_High_480 = 2,
            lv480_aether_lvup_scroll_lv100 = 2
        },
        ["EVENT_2404_POPOBOOST"] = {
            emoticonItem_2404_popo = 1,
            class_unlock_achievement_select = 1,
            open_ticket_cabinet_vibora_lv4 = 2,
            misc_Ether_Gem_Socket_480_NoTrade = 4,
            selectbox_Gem_High_480 = 4,
            lv480_aether_lvup_scroll_lv100 = 4
        },
        ["EVENT_2412_POPOBOOST"] = {
            emoticonItem_2412_popo = 1,
            class_unlock_achievement_select = 1,
            misc_Ether_Gem_Socket_500_NoTrade = 4,
            Piece_Gem_High_500 = 4,
            lv500_aether_lvup_scroll_lv100 = 4
        },
        ["EVENT_2409_POPOBOOST"] = {
            emoticonItem_2409_popo = 1,
            class_unlock_achievement_select = 1,
            misc_Ether_Gem_Socket_500_NoTrade = 4,
            Piece_Gem_High_500 = 4,
            lv500_aether_lvup_scroll_lv100 = 4
        },
        ["EVENT_POPOBOOST_SPRING"] = {
            emoticonItem_2503_popo = 1,
            class_unlock_achievement_select = 1,
            open_ticket_cabinet_vibora_lv4 = 2,
            misc_Ether_Gem_Socket_480_NoTrade = 2,
            selectbox_Gem_High_480 = 2,
            lv480_aether_lvup_scroll_lv100 = 2,
            EVENT_2403_Friend_Invite_Coin = 8
        },
        ["EVENT_POPOBOOST_SUMMER"] = {
            emoticonItem_2506_popo = 1,
            class_unlock_achievement_select = 1,
            open_ticket_cabinet_vibora_lv4 = 2,
            misc_Ether_Gem_Socket_480_NoTrade = 2,
            selectbox_Gem_High_480 = 2,
            lv480_aether_lvup_scroll_lv100 = 2,
            EVENT_2403_Friend_Invite_Coin = 8
        },
        ["EVENT_POPOBOOST_SUMMER"] = {
            emoticonItem_2506_popo = 1,
            class_unlock_achievement_select = 1,
            misc_Ether_Gem_Socket_520_NoTrade = 4,
            selectbox_Gem_High_480 = 4,
            lv520_aether_lvup_scroll_lv100 = 4,
            EVENT_2403_Friend_Invite_Coin = 8
        },
        ["EVENT_POPOBOOST_AUTUMN"] = {
            emoticonItem_2510_popo = 1,
            class_unlock_achievement_select = 1,
            misc_Ether_Gem_Socket_520_NoTrade = 4,
            Piece_Gem_High_520 = 4,
            lv520_aether_lvup_scroll_lv100 = 4,
            EVENT_2403_Friend_Invite_Coin = 8
        }
    }
    
    return ticket_item_list
end

function GET_POPOBOOST_PARTICIPATE_MAX_PROGRESS()
    return maxProgress;
end


function POPOBOOST_CHECK_ELIGIBILITY(lv, gearscore)
    -- if GET_POPOBOOST_SERVER() == 1 then
    -- if true then
    --     if lv >= 460 and lv <= 500 then
    --         return true;
    --     end
    --     return false;
    -- end
    
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
    if maxprop == "None" then
        return;
    end
    if IsServerSection(pc) ~= 1 then
        return;
    end
    if currentGearScore > maxGearScore then    
        local tx = TxBegin(pc);
        if tx == nil then
            return;
        end
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
    -- if itemcnt >= 11 then
    --     RunScript("TX_EVENT_STAMP_TOUR_PROP_SET_POPOBOOST",pc,5,itemcnt,"POPO_EVENT_STAMP")
    -- end

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

    --남은 기간 체크
    if GET_CURRENT_SEASCON_POPOBOST_INFO() == nil then
        return true;
    end

    return false;
end

local function replace(text, to_be_replaced, replace_with)
	local retText = text
	local strFindStart, strFindEnd = string.find(text, to_be_replaced)	
    if strFindStart ~= nil then
		local nStringCnt = string.len(text)		
		retText = string.sub(text, 1, strFindStart-1) .. replace_with ..  string.sub(text, strFindEnd+1, nStringCnt)		
    else
        retText = text
	end
	
    return retText
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
            local PopoboostAccountProp = GET_POPOBOOST_SEASONPROP();
            if accprop == PopoboostAccountProp then
                end_time = TryGetProp(popobannercls, "EndDateTime", "0000-00-00 00:00:00");
                end_time = replace(end_time, 'd', '');
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
    return get_cached("season_info", function()
    local clsList, cnt = GetClassList("popoboost_season_info")
        if not clsList then
            return nil
    end

        local server_type = GET_POPOBOOST_SERVER()
        local startprop = server_type == 1 and "PAPAYAStartTime" or
                         server_type == 2 and "TAIWANStartTime" or
                         server_type == 3 and "GlobalStartTime" or
                         "StartTime"
        local endprop = server_type == 1 and "PAPAYAEndTime" or
                       server_type == 2 and "TAIWANTEndTime" or
                       server_type == 3 and "GlobalEndTime" or
                       "EndTime"
            
        for i = 0, cnt do
            local info = GetClassByIndexFromList(clsList, i)
            if info then
                local start_time = TryGetProp(info, startprop, "0000-00-00 00:00:00")
                local end_time = TryGetProp(info, endprop, "0000-00-00 00:00:00")

                if POPOPBOOST_PREIODE_CHECK(start_time, end_time) then
                    return info
            end        
        end
    end   
    return nil
    end, 300) -- 5분 캐싱
end

function GET_POPOBOOST_SEASONITEM()
    local cls = GET_CURRENT_SEASCON_POPOBOST_INFO()
    if cls == nil then
        return "None"
    end
    local ItemBox = TryGetProp(cls, "ItemBox", "None");
    return ItemBox;
end


function GET_POPOBOOST_SEASONPROP()
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

    local accprop = GET_POPOBOOST_SEASONPROP()
    
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
    return get_cached("server_type", function()
        local nation
    if IsServerSection() == 1 then        
            nation = GetServiceNation()
        else
            nation = config.GetServiceNation()
        end
        
        local server_types = {
            PAPAYA = 1,
            TAIWAN = 2,
            GLOBAL = 3
        }
        
        return server_types[nation] or 0
    end, 3600) -- 1시간 캐싱
end

--이번 시즌에 해당하는 프로그래스를 넘긴다.
function POPOBOOSET_GET_PROGRESS_INFORMATION(index)
    local list, cnt = GetClassList("popoboost_inforamation");
    local AccountProp = GET_POPOBOOST_SEASONPROP();
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

function GET_POPOBOOST_PROGRESS_CHECK_PROP(progress)
    local ProgressInfo = POPOBOOSET_GET_PROGRESS_INFORMATION(progress);
    local CheckProp = TryGetProp(ProgressInfo, "PROGRESS_CHECK_PROPERTY", "None");
    local CheckCnt = TryGetProp(ProgressInfo, "PROGRESS_CHECK_COUNT", "0");

    return CheckProp, CheckCnt;
end

--완료 상태 체크 함수
function GET_POPOBOOST_PROGRESS_IS_CLEAR(pc, progress)
    local CheckProp, CheckCnt = GET_POPOBOOST_PROGRESS_CHECK_PROP(progress)
    local accObj = nil;

    -- 참가 여부 체크 
    if IS_POPOBOOST_PARTICIPATE_ACCOUNT(pc) == false then
        return false;
    end
    -- 참가 여부 체크
    if IS_POPOBOOST_PARTICIPATE_CHARACTER(pc) == false then
        return false;
    end

    if IsServerSection() == 1 then accObj = GetAccountObj(pc);
    else accObj = GetMyAccountObj(pc); end
    if not accObj then return false end


    local CurrentCheckCnt = TryGetProp(accObj, CheckProp, 0);
    if CurrentCheckCnt >= tonumber(CheckCnt) then
        return true;
    end
    return false;
end

function IS_POPOBOOST_PROGRESS_ALL_CLEAR(pc)
    for i = 0 , 6 do
        local IsClear = GET_POPOBOOST_PROGRESS_IS_CLEAR(pc, i)
        if IsClear == false then
            return false;
        end
    end

    return true;
end

--여기서 완료 상태인지 체크하고 완료 상태 아니면 tx로 넘어가는 형식으로 만들자.
function SCR_POPOBOOST_PROGRESS_SET(pc, progress, tx)
    local CheckProp, CheckCnt = GET_POPOBOOST_PROGRESS_CHECK_PROP(progress)
    local accObj = GetAccountObj(pc);
    if not accObj then return end

    local CurrentCheckCnt = TryGetProp(accObj, CheckProp, 0);
    if CurrentCheckCnt >= tonumber(CheckCnt) then
        return ;
    end
    TX_POPOBOOST_PROGRESS_SET(tx, pc, CheckProp);
end

function TX_POPOBOOST_PROGRESS_SET(tx, pc, CheckProp)
    local accObj = GetAccountObj(pc);
    if not accObj then return end

    if tx == nil then
    local tx = TxBegin(pc);
    TxAddIESProp(tx, accObj, CheckProp, 1);
    local ret = TxCommit(tx)
    else
        TxAddIESProp(tx, accObj, CheckProp, 1);
    end
end

----보상 달성 목표 체크 함수----
function CHECK_POPOBOOST_PROGRESS_CHECK_FUNC(pc, progress, GroupName, tx)
    if IsServerSection() ~= 1 then
        return; 
    end
    if GET_POPOBOOST_PROGRESS_IS_CLEAR(pc, progress) == true then
        return;
    end

    local equip_list = GetEquipItemList(pc)
    if progress_checks[progress] then
        if progress <= 2 then
        local checkfunc = progress_checks[progress];
            if checkfunc(pc, equip_list) then
                SCR_POPOBOOST_PROGRESS_SET(pc, progress, tx)
            end
        else 
            local checkfunc = progress_checks[progress];
            if checkfunc(pc, GroupName) then
                SCR_POPOBOOST_PROGRESS_SET(pc, progress, tx)
    end
        end
    else
        SCR_POPOBOOST_PROGRESS_SET(pc, progress, tx)
end
end

function RETURN_POPOBOOST_ACCOUNTPROP_TO_CHAR_BY_INT(value)
    if value == 0 then
        return "None"
    end
    if value == 1 then
        return "Normal"
    end
    if value == 2 then
        return "OnlyPremium"
    end
    if value == 3 then
        return "All"
    end
    return "None"
end

