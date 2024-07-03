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

function GET_LIMITATION_TO_BUY(tpItemID)
    local tpItemObj = GetClassByType('TPitem', tpItemID);
    if IS_SEASON_SERVER() == 'YES' then
        tpItemObj = GetClassByType('TPitem_SEASON', tpItemID);
    elseif GetServerNation() == 'PAPAYA' then
        tpItemObj = GetClassByType('TPitem_PAPAYA', tpItemID);
    end

    if tpItemObj == nil then
        return 'NO', 0;
    end

    local accountLimitCount = TryGetProp(tpItemObj, 'AccountLimitCount');
    if accountLimitCount ~= nil and accountLimitCount > 0 then
        return 'ACCOUNT', accountLimitCount;
    end

    local monthLimitCount = TryGetProp(tpItemObj, 'MonthLimitCount');    
    if monthLimitCount ~= nil and monthLimitCount > 0 then
        return 'MONTH', monthLimitCount;
    end

    local weeklyCount = TryGetProp(tpItemObj, 'AccountLimitWeeklyCount', 0)    
    if weeklyCount > 0 then
        return 'WEEKLY', weeklyCount
    end

    local customCount = TryGetProp(tpItemObj, 'AccountLimitCustomCount', 0)    
    if customCount > 0 then
        return 'CUSTOM', customCount
    end

    local dailyCount = TryGetProp(tpItemObj, "AccountLimitDailyCount", 0);
    if dailyCount > 0 then
        return 'DAILY', dailyCount;
    end

    return 'NO', 0;
end

function GET_LIMITATION_TO_BUY_WITH_SHOPTYPE(tpItemID, shopType)
    local tpItemObj = nil
    -- shopType normal(0), return User(1), newbie(2)
    if shopType == 1 then
        tpItemObj = GetClassByType('TPitem_Return_User', tpItemID);
        if GetServerNation() == "PAPAYA" then 
            tpItemObj = GetClassByType('TPitem_Return_User_PAPAYA', tpItemID);
        end
    elseif shopType == 2 then
        tpItemObj = GetClassByType('TPitem_User_New', tpItemID);
        if GetServerNation() == "PAPAYA" then 
            tpItemObj = GetClassByType('TPitem_User_New_PAPAYA', tpItemID);
        end
    else
        tpItemObj = GetClassByType('TPitem', tpItemID);
        if IS_SEASON_SERVER() == 'YES' then
            tpItemObj = GetClassByType('TPitem_SEASON', tpItemID);
        elseif GetServerNation() == 'PAPAYA' then
            tpItemObj = GetClassByType('TPitem_PAPAYA', tpItemID);
        end
    end
    
    if tpItemObj == nil then
        return 'NO', 0;
    end
    
    local accountLimitCount = TryGetProp(tpItemObj, 'AccountLimitCount');
    if accountLimitCount ~= nil and accountLimitCount > 0 then
        return 'ACCOUNT', accountLimitCount;
    end

    local monthLimitCount = TryGetProp(tpItemObj, 'MonthLimitCount');
    if monthLimitCount ~= nil and monthLimitCount > 0 then
        return 'MONTH', monthLimitCount;
    end

    local weeklyCount = TryGetProp(tpItemObj, 'AccountLimitWeeklyCount', 0)
    if weeklyCount > 0 then
        return 'WEEKLY', weeklyCount
    end

    local customCount = TryGetProp(tpItemObj, 'AccountLimitCustomCount', 0)    
    if customCount > 0 then
        return 'CUSTOM', customCount
    end

    local dailyCount = TryGetProp(tpItemObj, "AccountLimitDailyCount", 0);
    if dailyCount > 0 then
        return 'DAILY', dailyCount;
    end

    return 'NO', 0;
end

itemOptCheckTable = nil;
function CREATE_ITEM_OPTION_TABLE()
    --추가할 프로퍼티가 존재한다면 밑에다가 추가하면 됨.
    itemOptCheckTable = {
    "Reinforce_2", -- 강화
    "Transcend", -- 초월
    "IsAwaken", -- 각성
    "RandomOptionRareValue",
    }
end

function IS_MECHANICAL_ITEM(itemObject)
    if itemOptCheckTable == nil then
        CREATE_ITEM_OPTION_TABLE();
    end

    if itemOptCheckTable == nil or #itemOptCheckTable == 0 then
        return false;
    end 

    for i = 1, #itemOptCheckTable do
        local itemProp = TryGetProp(itemObject, itemOptCheckTable[i]);
        if itemProp ~= nil then
            if itemProp > 0 then
                return true;
            end
        end
    end

    local maxSocketCnt = TryGetProp(itemObject, 'MaxSocket', 0);
    if maxSocketCnt > 0 then
        if IsServerSection() == 0 then
            local invitem = GET_INV_ITEM_BY_ITEM_OBJ(itemObject);
            if invitem == nil then
                return false;
            end

            if itemObject.MaxSocket > 100 then itemObject.MaxSocket = 0 end
            for i = 0, itemObject.MaxSocket - 1 do
                if invitem:IsAvailableSocket(i) == true then
                    return true;
                end                
            end
        else
            if itemObject.MaxSocket > 100 then itemObject.MaxSocket = 0 end
            for i = 0, itemObject.MaxSocket - 1 do
                local equipGemID = GetItemSocketInfo(itemObject, i);
                if equipGemID ~= nil then
                    return true;
                end
            end
        end    
    end

    return false;
end

function GET_COMMON_SOCKET_TYPE()
	return 5;
end

local _anitiqueCache = {}; -- key: itemClassName, value: groupKey
local function _RETURN_ANTIQUE_INFO(itemClassName, groupKey, group, exchangeItemList, giveItemList, giveItemCntList, matItemList, matItemCntList)
    if groupKey == nil then
        return nil;
    end

    local anitiqueCacheKey = group..'_'..itemClassName;
    _anitiqueCache[anitiqueCacheKey] = groupKey;
    local giveList = {};
    for i = 1, #giveItemList do
        giveList[#giveList + 1] = {
            Name = giveItemList[i],
            Count = giveItemCntList[i]
        };
    end

    local matList = {};
    for i = 1, #matItemList do
        matList[#matList + 1] = {
            Name = matItemList[i],
            Count = matItemCntList[i]
        };
    end

    return {
        GroupKey = groupKey,
        ExchangeGroup = group,
        AddGiveItemList = giveList,
        ExchangeItemList = exchangeItemList,
        MatItemList = matList,
    };
end

function GET_EXCHANGE_ANTIQUE_INFO(exchangeGroupName, itemClassName)
    if itemClassName == nil then
        return nil;
    end

    local anitiqueCacheKey = exchangeGroupName..'_'..itemClassName;
    if _anitiqueCache[anitiqueCacheKey] ~= nil then
        return _RETURN_ANTIQUE_INFO(itemClassName, GetExchangeAntiqueInfoByGroupKey(_anitiqueCache[anitiqueCacheKey]));
    end
    return _RETURN_ANTIQUE_INFO(itemClassName, GetExchangeAntiqueInfoByItemName(exchangeGroupName, itemClassName));
end

function IS_ENABLE_EXCHANGE_ANTIQUE(srcItem, dstItem)
    if srcItem == nil or dstItem == nil then
        return false;
    end
    
    if srcItem.ClassID == dstItem.ClassID then
        return false;
    end

    if dstItem.ClassName == 'CAN05_101' or dstItem.ClassName == 'CAN05_102' then
        return false;
    end
    return true;
end

-- exchangeWeaponType : Check Data
function IS_EXCHANGE_WEAPONTYPE(exchangeGroupName, itemClassName)
    if exchangeGroupName == nil or itemClassName == nil then
        return false;
    end

    return IsExchangeWeaponType(exchangeGroupName, itemClassName);
end

-- exchangeWeaponType : Get Material / return materialNameList, materialCountList
function GET_EXCHANGE_WEAPONTYPE_MATERIAL(exchangeGroupName, itemClassName)
    if exchangeGroupName == nil or itemClassName == nil then
        return nil, nil;
    end

    return GetExChangeMeterialList(exchangeGroupName, itemClassName);
end

-- exchangeWeaponType : exchange enable check
function IS_ENABLE_EXCHANGE_WEAPONTYPE(scrItem, destItemID)
    if scrItem == nil or destItemID == nil then 
        return false; 
    end

    if scrItem.ClassID == destItemID then 
        return false; 
    end
    
    local scrItemGroup = TryGetProp(scrItem, "ExchangeGroup", "None");
    if IsExchangeWeaponType(scrItemGroup, scrItem.ClassName) == false or IsExchangeWeaponTypeByClassID(destItemID) == false then 
        return false; 
    end
    return true;
end

function IS_ICOR_ITEM(item)
	if TryGetProp(item, 'GroupName', 'None') == 'Icor' then
		return true;
	end
	return false;
end

function GET_GEM_PROTECT_NEED_COUNT(gemObj)
    if gemObj == nil then
        return 999999
    end
    
    local lv = TryGetProp(gemObj, "NumberArg1", 0)
    local cls = GetClassByType("item_gem_Extract_Protect", lv)
    return TryGetProp(cls, 'NeedCount', 999999)
end

function SCR_PRECHECK_TEST_DUMMY_SCR_USE_SCROLL(self)
    if OnKnockDown(self) == 'YES' then
        return 0;
	end
	
	local currentZone = GetZoneName(self)
	if currentZone ~= "c_Klaipe" and currentZone ~= "c_orsha" and currentZone ~= "c_fedimian" then
		SendAddOnMsg(self, "NOTICE_Dm_!", ScpArgMsg("AllowedInTown"), 3);
		return 0;
	end

	if IsMyPCFriendlyFighting(self) == 1 then
		SendAddOnMsg(self, "NOTICE_Dm_!", ScpArgMsg("Card_Summon_check_PVP"), 3);
		return 0;
	end

	local sObj = GetSessionObject(self, 'ssn_klapeda')
	if sObj == nil then
		return 0;
	end
	return 1;
end

-- goddess
function GET_GODDESS_EVOLVED_EFFECT_FACTOR_OFFSET(item_cls)
    local factor_offset = 0.0;
    if item_cls ~= nil then
        local item_class_name = TryGetProp(item_cls, "ClassName", "None");
        if item_class_name == "EP13_Artefact_040" then
            factor_offset = 4.0;
        elseif item_class_name == "EP13_Artefact_039" then
            factor_offset = 4.0;
        elseif item_class_name == "EP13_Artefact_047" then
            factor_offset = 2.0;
        end
    end
    return factor_offset;
end

function SET_GODDESS_EVOLVED_EFFECT_INFO(self, guid, equip)
    if IsServerSection() == 1 then
        if equip == true then
            local factor_offset = 0.0;
            local item = GetEquipItemByGuid(self, guid);
            if item ~= nil then
                local briquetting_index = TryGetProp(item, "BriquettingIndex", 0);
                if briquetting_index > 0 then
                    local briquetting_item_cls = GetClassByType("Item", briquetting_index);
                    if briquetting_item_cls ~= nil then
                        factor_offset = GET_GODDESS_EVOLVED_EFFECT_FACTOR_OFFSET(briquetting_item_cls);
                    end
                end
            end
            SetAuraInfoByItem(self, guid, "Goddess_Evolved_Color_Green", factor_offset);
        else
            SetAuraInfoByItem(self, guid, "");
        end
    end
end

-- dress room
function IS_REGISTER_ENABLE_COSTUME(item)
    if item == nil then
        return false
    end

    if TryGetProp(item, "TeamBelonging", 0) == 1 then
        local itemName =  TryGetProp(item, "StringArg", "None");
        if itemName == "snigo_costume" then
            return true;
        end
        return false, "CantRegisterCuzTeamBelonging"
    end

    return true
end

local nation_code_table = nil
local function make_nation_code_table()
    if nation_code_table ~= nil then return end

    nation_code_table = {};
    nation_code_table["GLOBAL_KOR"] = "ko"
    nation_code_table["GLOBAL"] = "en"
    nation_code_table["GLOBAL_JP"] = "ja"
    nation_code_table["TAIWAN"] = "zh-TW" -- 중국어-번체
    nation_code_table["PAPAYA"] = "en"

end
make_nation_code_table();

function GET_NATION_TRANSLATE_CODE(nationName)
    if nation_code_table == nil then print("nation_code_table is nil") return end
    local ret = nation_code_table[nationName]
    if ret ==nil then return end
    return ret
end

--@Desc
--추가 시 : PAPAGO 번역 지원 가능언어인지 확인 필요. 
--url : https://developers.naver.com/docs/papago/papago-nmt-overview.md 

-- 2023/04/13 기준 Papago 번역 지원 가능 언어
-- 번역 요청 언어(타깃) : 번역가능 언어 1(목적), 번역가능 언어 2(목적)..
-- 1  한국어 : 영어, 일본어, 중국어 간체, 중국어 번체(대만)..
-- 2. 영어   : 한국어, 일본어, 중국어 간체, 중국어 번체(대만)
-- 3. 일본어 : 한국어, 영어, 중국어 간체, 중국어 번체
-- 4. 중국어 간체 : 한국어, 영어, 번체, 일본어
-- 5. 중국어 번체(대만) : 한국어, 영어, 간체, 일본어
item_etc_shared = {}

local language_code_table = nil
local client_curr_language_set = nil
local curr_language_cnt = 0;
local function make_language_code_table()
    if language_code_table ~= nil then return end
    language_code_table = {};
    language_code_table["English"]      = "en"    --영어
    language_code_table["Chinese"]      = "zh-CN" --중국어-간체
    language_code_table["Japanese"]     = "ja"    --일본어
    language_code_table["Korean"]       = "ko"    --한국어
    language_code_table["Taiwanese"]    = "zh-TW" --중국어-번체

    for k,v  in pairs(language_code_table) do
        curr_language_cnt  = curr_language_cnt + 1
    end
end
make_language_code_table();

item_etc_shared.get_language_code_table = function()
    if language_code_table == nil then
        make_language_code_table();
    end
    return language_code_table
end

-- 세팅되어있는 번역 KEY 코드 가져오기
item_etc_shared.get_language_translate_code = function(tgt)
    if language_code_table == nil then
        make_language_code_table();
    end

    if tgt==nil and client_curr_language_set==nil then
        client_curr_language_set = "English"
        return language_code_table[client_curr_language_set]
    end

    if tgt ~= nil then 
        return language_code_table[tgt]
    else
        return language_code_table[client_curr_language_set]
    end
end

-- KEY 코드 세팅 (client)
item_etc_shared.set_language_translate_code = function(tgt)
    client_curr_language_set = tgt
end


-- 등록되어있는 언어 코드 갯수
item_etc_shared.get_language_table_cnt = function()
    if language_code_table == nil then
        make_language_code_table();
    end
    return curr_language_cnt
end

item_etc_shared.Is_Contain_LinkItem = function(str)
    local replaceTxt = nil;

    local searchCnt = 0
    local partyStr = '{img link_party 24 24}'
    local partyLinkCheck = string.find(str,partyStr)
    local deleteTgtText = nil
    if partyLinkCheck ~= nil then
        deleteTgtText = item_etc_shared.extractPartyLinkFormat(str)
    end

    while partyLinkCheck~=nil and searchCnt<10 do
        str= replace(str,deleteTgtText,'')
        searchCnt = searchCnt + 1;
        partyLinkCheck = string.find(str,partyStr)
    end

    if searchCnt > 0 then
        replaceTxt = str
    end

    local check1 =  string.find(str,'{a SLI')
    if check1 ~= nil then
        return true
    end
    local check2 = string.find(str,'{img')
    if check2 ~= nil then         
        return true
    end
 
    return false,replaceTxt
end

local savedFormat = nil
item_etc_shared.GetSavedPartyLinkFormat = function ()
    if savedFormat ~= nil then
        local tempstr = savedFormat
        savedFormat = nil
        return tempstr
    end
    return nil
end

item_etc_shared.SavePartyLinkFormat = function (str)
    if savedFormat == nil then
        savedFormat = item_etc_shared.extractPartyLinkFormat(str)
    else

    end
end

item_etc_shared.extractPartyLinkFormat = function(str)
    local check1 = '{a SLP'
    local check2 = '{img link_party 24 24}'
    local startindex = string.find(str,check1)
    local t1,endindex = string.find(str,check2)
    local formatStr = string.sub(str,startindex,endindex)
    return formatStr
end
-- item_etc_shared.Preserve_string_filtering_for_translation = function(str)
-- 	local temp = str;
-- 	local preserve_text =""
-- 	local from;
-- 	local to;
--     local cnt = 0;
-- 	while (string.find(temp,'{')~=nil and string.find(temp,'}')~=nil) do
-- 		from = string.find(temp,'{')
-- 		to = string.find(temp,'}')
-- 		local sub_text;
-- 		local f,t = string.find(temp,"FF}")
-- 		if to == t then 
-- 			local x, cuting_end = string.find(temp,"{/}")
-- 			sub_text = string.sub(temp,from,cuting_end)
-- 		else
-- 			sub_text = string.sub(temp,from,to)
-- 		end
-- 		preserve_text = preserve_text..sub_text
--         print(temp)
-- 		temp = replace(temp,sub_text,"");
--         print(temp)
--         cnt = cnt + 1 
--         if cnt > 10 then return str end;
-- 	end
-- 	return preserve_text,temp
-- end