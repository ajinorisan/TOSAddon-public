-- ability_price.lua

function SET_ADDITOINAL_LOCK_FUNCTION(pc, groupClass)
    local max = TryGetProp(groupClass, "Add_UnlockJobNum", -1);
    if max < 0 then
        return "LOCK_GRADE";
    end

    local AddStr = "Add_UnlockArgStr"
    for i = 0, max - 1 do
        local unlockFuncName = groupClass.UnlockScr;
        local AddProp = AddStr..i;
        local AddLockArgStr = TryGetProp(groupClass, AddProp, "None");
        if unlockFuncName ~= 'None' then
            local scp = _G[unlockFuncName];
            local ret = scp(pc, AddLockArgStr, groupClass.UnlockArgNum, abilIES);
            if ret ~= "LOCK_GRADE" then
                return ret;
            end
        else
            return nil;
        end
    end
    return "LOCK_GRADE"
end

function ABIL_1RANK_NORMAL_PRICE(pc, abilName, abilLevel, maxLevel)

--    local price = 1 + (4 - maxLevel + abilLevel) * 1;
    local price = 1
--    local time = 4 + (4 - maxLevel + abilLevel) * 4;
	local time = 0

    return price, time;
    
end

function ABIL_2RANK_NORMAL_PRICE(pc, abilName, abilLevel, maxLevel)

--    local price = 2 + (4 - maxLevel + abilLevel) * 1;
    local price = 1
--    local time = 8 + (4 - maxLevel + abilLevel) * 4;
    local time = 0

    return price, time;
    
end

function ABIL_3RANK_NORMAL_PRICE(pc, abilName, abilLevel, maxLevel)

--    local price = 5 + (4 - maxLevel + abilLevel) * 1;
    local price = 1
--    local time = 12 + (4 - maxLevel + abilLevel) * 4;
    local time = 0

    return price, time;
    
end

function ABIL_4RANK_NORMAL_PRICE(pc, abilName, abilLevel, maxLevel)

--    local price = 11 + (4 - maxLevel + abilLevel) * 1;
    local price = 1
--    local time = 16 + (4 - maxLevel + abilLevel) * 4;
    local time = 0

    return price, time;
    
end

function ABIL_5RANK_NORMAL_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = 22 + (4 - maxLevel + abilLevel) * 2;
--    local time = 20 + (4 - maxLevel + abilLevel) * 4;
    local time = 0

    return price, time;
    
end


function ABIL_6RANK_NORMAL_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = 41 + (4 - maxLevel + abilLevel) * 3;
--    local time = 24 + (4 - maxLevel + abilLevel) * 4;
    local time = 0

    return price, time;
    
end

function ABIL_7RANK_NORMAL_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = 70 + (4 - maxLevel + abilLevel) * 7;
--    local time = 28 + (4 - maxLevel + abilLevel) * 4;
    local time = 0

    return price, time;
    
end

function ABIL_8RANK_NORMAL_PRICE(pc, abilName, abilLevel, maxLevel)

--    local price = 571 + (4 - maxLevel + abilLevel) * 71;
    local price = 480 + (4 - maxLevel + abilLevel) * 45
--    local time = 240 + (4 - maxLevel + abilLevel) * 100;
    local time = 0

    return price, time;
    
end

function ABIL_9RANK_NORMAL_PRICE(pc, abilName, abilLevel, maxLevel)
    local price = 720 + (4 - maxLevel + abilLevel) * 67
--    local time = 360 + (4 - maxLevel + abilLevel) * 120;
    local time = 0
    
    return price, time;
end

function ABIL_10RANK_NORMAL_PRICE(pc, abilName, abilLevel, maxLevel)
    local price = 1080 + (4 - maxLevel + abilLevel) * 100
--    local time = 400 + (4 - maxLevel + abilLevel) * 200;
    local time = 0
    
    return price, time;
end

function ABIL_1RANK_BUFF_PRICE(pc, abilName, abilLevel, maxLevel)

--    local price = 1 + (abilLevel - 1) * 1;
    local price = 1
--    local time = 4 + (abilLevel - 1);
    local time = 0

    return price, time;
    
end

function ABIL_2RANK_BUFF_PRICE(pc, abilName, abilLevel, maxLevel)

--    local price = 2 + (abilLevel - 1) * 1;
    local price = 1
--    local time = 8 + (abilLevel - 1);
    local time = 0

    return price, time;
    
end

function ABIL_3RANK_BUFF_PRICE(pc, abilName, abilLevel, maxLevel)

--    local price = 5 + (abilLevel - 1) * 1;
    local price = 1
--    local time = 12 + (abilLevel - 1);
    local time = 0

    return price, time;
    
end

function ABIL_4RANK_BUFF_PRICE(pc, abilName, abilLevel, maxLevel)

--    local price = 11 + (abilLevel - 1) * 1;
    local price = 1
--    local time = 16 + (abilLevel - 1);
    local time = 0

    return price, time;
    
end

function ABIL_5RANK_BUFF_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = 22 + (abilLevel - 1) * 2;
--    local time = 20 + (abilLevel - 1);
    local time = 0

    return price, time;
    
end

function ABIL_6RANK_BUFF_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = 41 + (abilLevel - 1) * 3;
--    local time = 24 + (abilLevel - 1);
    local time = 0

    return price, time;
    
end

function ABIL_7RANK_BUFF_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = 70 + (abilLevel - 1) * 7;
--    local time = 28 + (abilLevel - 1);
    local time = 0

    return price, time;
    
end

function ABIL_8RANK_BUFF_PRICE(pc, abilName, abilLevel, maxLevel)

--    local price = 571 + (abilLevel - 1) * 71;
    local price = 500 + (abilLevel - 1) * 55
--    local time = 240 + (abilLevel - 1) * 20;
    local time = 0

    return price, time;
    
end

function ABIL_9RANK_BUFF_PRICE(pc, abilName, abilLevel, maxLevel)
    local price = 600 + (abilLevel - 1) * 65
--    local time = 360 + (abilLevel - 1) * 30;
    local time = 0
    
    return price, time;
end

function ABIL_10RANK_BUFF_PRICE(pc, abilName, abilLevel, maxLevel)
    local price = 700 + (abilLevel - 1) * 75
--    local time = 400 + (abilLevel - 1) * 50;
    local time = 0
    
    return price, time;
end

function ABIL_1RANK_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = math.floor(1.07^(abilLevel-1) * 1);
    local time = 0;

    return price, time;
    
end

function ABIL_2RANK_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = math.floor(1.07^(abilLevel-1) * 2);
    local time = 0;

    return price, time;
    
end

function ABIL_3RANK_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = math.floor(1.07^(abilLevel-1) * 3);
    local time = 0;

    return price, time;
    
end

function ABIL_4RANK_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = math.floor(1.07^(abilLevel-1) * 4);
    local time = 0;

    return price, time;
    
end

function ABIL_5RANK_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = math.floor(1.07^(abilLevel-1) * 5);
    local time = 0;

    return price, time;
    
end

function ABIL_6RANK_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = math.floor(1.07^(abilLevel-1) * 6);
    local time = 0;

    return price, time;
    
end

function ABIL_7RANK_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = math.floor(1.07^(abilLevel-1) * 7);
    local time = 0;

    return price, time;
    
end

function ABIL_8RANK_PRICE(pc, abilName, abilLevel, maxLevel)

--    local price = math.floor(1.085^(abilLevel-1) * 8);
    local price = math.floor(1.0822^(abilLevel-1) * 8)
    local time = 0;

    return price, time;
    
end

function ABIL_9RANK_PRICE(pc, abilName, abilLevel, maxLevel)
    local price = math.floor(1.0822^(abilLevel-1) * 8.5)
    local time = 0;
    
    return price, time;
end

function ABIL_10RANK_PRICE(pc, abilName, abilLevel, maxLevel)
    local price = math.floor(1.0822^(abilLevel-1) * 9)
    local time = 0;
    
    return price, time;
end

function ABIL_10RANK_FOR67_PRICE(pc, abilName, abilLevel, maxLevel)
    local price = 250 + (abilLevel-1) * 250
    local time = 0
    
    return price, time;
end

function ABIL_3RANK_MASTER_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = 3
    local time = 0;

    return price, time;
    
end

function ABIL_BASE_PRICE(pc, abilName, abilLevel, maxLevel)
    local price = 1
    local time = 0
    
    return price, time;
end

function ABIL_REINFORCE_PRICE(pc, abilName, abilLevel, maxLevel)    

    local baseFactor = 1.07
    local increseFactorList = { 1, 2, 3, 4, 5, 
                                6, 7, 8, 8.5, 9 }
    
    local index = math.ceil(abilLevel / 10)
    local increseFactor = 0;
    
    if index > 0 and index <= #increseFactorList then
        increseFactor = increseFactorList[index];
    end
    
    local price = math.floor(baseFactor^(abilLevel - 1) * increseFactorList[index])
    local time = 0;    

    return price, time;
    
end

function ABIL_ABOVE_NORMAL_PRICE(pc, abilName, abilLevel, maxLevel)
    local price = 60 + (abilLevel - 1) * 5;
    local time = 0
    
    return price, time;
end

function ABIL_COMMON_PRICE(pc, abilName, abilLevel, maxLevel, factor1, factor2)
    local minimumFactor = factor1;
    local increseFactor = factor2;
    
    if minimumFactor == nil then
        minimumFactor = 0
    end
    
    if increseFactor == nil then
        increseFactor = 0
    end
    
    local price = minimumFactor + (4 - maxLevel + abilLevel) * increseFactor;
    
    if price < 1 then
        price = 1;
    end
    
    local time = 0;
    
    return price, time;
end

function ABIL_COMMON_PRICE_1LV(pc, abilName, abilLevel, maxLevel, factor1, factor2)
    local price, time = ABIL_COMMON_PRICE(pc, abilName, abilLevel, maxLevel, 11, 1)
    return price, time;
end

function ABIL_COMMON_PRICE_100LV(pc, abilName, abilLevel, maxLevel, factor1, factor2)
    local price, time = ABIL_COMMON_PRICE(pc, abilName, abilLevel, maxLevel, 22, 2)
    return price, time;
end

function ABIL_COMMON_PRICE_150LV(pc, abilName, abilLevel, maxLevel, factor1, factor2)
    local price, time = ABIL_COMMON_PRICE(pc, abilName, abilLevel, maxLevel, 34, 3)
    return price, time;
end

function ABIL_COMMON_PRICE_200LV(pc, abilName, abilLevel, maxLevel, factor1, factor2)
    local price, time = ABIL_COMMON_PRICE(pc, abilName, abilLevel, maxLevel, 48, 4)
    return price, time;
end

function ABIL_COMMON_PRICE_250LV(pc, abilName, abilLevel, maxLevel, factor1, factor2)
    local price, time = ABIL_COMMON_PRICE(pc, abilName, abilLevel, maxLevel, 63, 5)
    return price, time;
end

function ABIL_COMMON_PRICE_300LV(pc, abilName, abilLevel, maxLevel, factor1, factor2)
    local price, time = ABIL_COMMON_PRICE(pc, abilName, abilLevel, maxLevel, 84, 6)
    return price, time;
end

function ABIL_COMMON_PRICE_350LV(pc, abilName, abilLevel, maxLevel, factor1, factor2)
    local price, time = ABIL_COMMON_PRICE(pc, abilName, abilLevel, maxLevel, 115, 7)
    return price, time;
end

function ABIL_COMMON_PRICE_400LV(pc, abilName, abilLevel, maxLevel, factor1, factor2)
    local price, time = ABIL_COMMON_PRICE(pc, abilName, abilLevel, maxLevel, 240, 45)
    return price, time;
end

function ABIL_SWAPWEAPON_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = 3
--    local time = 10;
    local time = 0

    return price, time;
    
end

function ABIL_MASTERY_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = 3 + 1 * (abilLevel - 1);
--    local time = 30;
    local time = 0

    return price, time;
    
end

function ABIL_UNIQUEMASTERY_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = 6 + 1 * (abilLevel - 1);
--    local time = 60;
    local time = 0

    return price, time;
    
end

function ABIL_BOKOR21_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = 60 + math.floor(1.05^(abilLevel-1) * 7);
--    local time = math.floor(1 + (abilLevel * 0.1));
    local time = 0

    return price, time;
    
end

function ABIL_BOKOR22_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = 60 + math.floor(1.05^(abilLevel-1) * 7);
--    local time = math.floor(1 + (abilLevel * 0.1));
    local time = 0

    return price, time;
    
end

function ABIL_SAVEPOISON_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = math.floor(1.07^(abilLevel-1) * 6);
    local time = 0;

    return price, time;
    
end

function ABIL_SORCERER2_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = math.floor(1.05^(abilLevel-1) * 35);
    local time = 0;

    return price, time;
    
end

function ABIL_SQUIRE_TOUCHUP_PRICE(pc, abilName, abilLevel, maxLevel)
    
    local price = math.floor(1.04^(abilLevel-1) * 15);
    local time = 0;
    
    return price, time;
    
end

function ABIL_SQUIRE_FOODTABLE_PRICE(pc, abilName, abilLevel, maxLevel)
    
    local price = 10 + 10 * (abilLevel - 1);
--    local time = 10;
    local time = 0
    
    return price, time;
    
end

function ABIL_BOKOR17_PRICE(pc, abilName, abilLevel, maxLevel)
    
    local price = math.floor(1.04^(abilLevel-1) * 10);
    local time = 0;
    
    return price, time;
    
end


function ABIL_PARDONER5_PRICE(pc, abilName, abilLevel, maxLevel)
    
    local price = abilLevel * 1 + IMCRandom(0, 99)
    local time = 0;
    
    return price, time;
    
end

function ABIL_TINCTURINGPOTION_PRICE(pc, abilName, abilLevel, maxLevel)
    local price = abilLevel * 10;
--    local time = 60 + abilLevel * 4;
    local time = 0
    
    return price, time;
end


function ABIL_HIGHLANDER28_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = 15;
    local time = 0;

    return price, time;
    
end

function ABIL_CATAPHRACT28_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = 70;
    local time = 0;

    return price, time;
    
end

function ABIL_CATAPHRACT30_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = 100;
    local time = 0;

    return price, time;
    
end

function ABIL_NECROMANCER8_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = 80 + math.floor(1.05^(abilLevel-1) * 9);
--    local time = math.floor(1 + (abilLevel * 0.1));
    local time = 0

    return price, time;
    
end

function ABIL_PROVOKE_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = 1 + (abilLevel-1) * 1
    local time = 0

    return price, time;
    
end

function ABIL_UNLOCKCHEST_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = 32 * abilLevel
--    local time = 1;
    local time = 0

    return price, time;
    
end

function ABIL_FEATHERFOOTBLOOD_PRICE(pc, abilName, abilLevel, maxLevel)
    
    local price = math.floor(1.055^(abilLevel-1) * 20);
--    local time = 1;
    local time = 0
    
    return price, time;
    
end

function ABIL_FEATHERFOOTREGENERATE_PRICE(pc, abilName, abilLevel, maxLevel)
    
    local price = 500;
--    local time = 40 + (abilLevel-1) * 5;
    local time = 0
    
    return price, time;
    
end

function ABIL_QUARRELSHOOTER9_PRICE(pc, abilName, abilLevel, maxLevel)
    
    local price = 1 + (abilLevel-1) * 1;
--    local time = 60 + (abilLevel-1) * 10;
    local time = 0
    
    return price, time;
    
end

function ABIL_RODELERO29_PRICE(pc, abilName, abilLevel, maxLevel)
    
    local price = 41 + (abilLevel - 1) * 3;
--    local time = 24 + (abilLevel - 1) * 4;
    local time = 0
    
    return price, time;
    
end

function ABIL_CLERIC18_PRICE(pc, abilName, abilLevel, maxLevel)
    
    local price = 2 + (abilLevel - 1) * 1;
--    local time = 1;
    local time = 0
    
    return price, time;
    
end

function ABIL_ADDBUFFCOUNT_PRICE(pc, abilName, abilLevel, maxLevel)
    local price = 10
    local time = 0

    return price, time;
end

function ABIL_DOPPELSOELDNER20_PRICE(pc, abilName, abilLevel, maxLevel)
    local price = 713
--    local time = 1440
    local time = 0
    
    return price, time;
end

function ABIL_ALCHEMIST10_PRICE(pc, abilName, abilLevel, maxLevel)
    local price = 3000
--    local time = 3000
    local time = 0
    
    return price, time;
end

function ABIL_TOTALDEADPARTS_PRICE(pc, abilName, abilLevel, maxLevel)
    local price = 1670 + (abilLevel - 1) * 200;
--    local time = 300 * abilLevel;
    local time = 0
    
    return price, time;
end

function ABIL_HIGHERROTTEN_PRICE(pc, abilName, abilLevel, maxLevel)
    local price = 2000
--    local time = 1500
    local time = 0
    
    return price, time;
end

function ABIL_WARLOCK14_PRICE(pc, abilName, abilLevel, maxLevel)

--    local price = 571 + math.floor(1.1^(abilLevel-1) * 80);
    local price = 450 + math.floor(1.1^(abilLevel-1) * 65)
--    local time = 600 + (abilLevel-1) * 100;
    local time = 0

    return price, time;
    
end

function ABIL_SAGE8_PRICE(pc, abilName, abilLevel, maxLevel)

--    local price = 2000
    local price = 1600
--    local time = 2000
    local time = 0

    return price, time;
    
end

function ABIL_SAGE9_PRICE(pc, abilName, abilLevel, maxLevel)

--    local price = 1600 + (abilLevel-1) * 100;
    local price = 1500 + (abilLevel-1) * 56
--    local time = 2000 + (abilLevel-1) * 200;
    local time = 0

    return price, time;
    
end

function ABIL_FALCONER11_PRICE(pc, abilName, abilLevel, maxLevel)
    local price = 1000 + (abilLevel-1) * 100;
--    local time = 1000 + (abilLevel-1) * 100;
    local time = 0

    return price, time;
end

function ABIL_SHINOBIARUKI_PRICE(pc, abilName, abilLevel, maxLevel)
    local price = 1800
--    local time = 1440;
    local time = 0

    return price, time;
end

function ABIL_SCHWARZEREITER17_PRICE(pc, abilName, abilLevel, maxLevel)
    local price = 1658
--    local time = 1440;
    local time = 0

    return price, time;
end

function ABIL_DRUID12_PRICE(pc, abilName, abilLevel, maxLevel)
    local price = 954 + (abilLevel-1) * 99;
--    local time = 700 + (abilLevel-1) * 100;
    local time = 0

    return price, time;
end

function ABIL_INQUISITOR9_PRICE(pc, abilName, abilLevel, maxLevel)
    local price = math.floor(1.09^(abilLevel-1) * 1000);
--    local time = 100;
    local time = 0

    return price, time;
end

function ABIL_CLERIC9_PRICE(pc, abilName, abilLevel, maxLevel)

    local price = 3 + (abilLevel - 1) * 1;
--    local time = 12 + (9 - maxLevel + abilLevel) * 4;
    local time = 0

    return price, time;
end

function HIDDENABIL_PRICE_COND_REINFORCE(pc, abilName, abilLevel, maxLevel)
    local price = 3057 * math.max(1, (math.pow(3, math.ceil(abilLevel/10) - 2)))
    local time = 0;
    
    return math.floor(price), time;
end

function HIDDENABIL_PRICE_COND_JOBLEVEL(pc, abilName, abilLevel, maxLevel)
    local price = 36000 / maxLevel;       -- EXPECT_TOTAL_PRICE : 36000
    local time = 0;
    
    return math.floor(price), time;
end

function GET_TOTAL_ABILITY_PRICE(pc, scrCalcPrice, abilName, abilLevel, maxLevel)
    local price = 0;
    if pc == nil or abilName == nil or abilLevel == nil or maxLevel == nil or scrCalcPrice == nil or scrCalcPrice == 'None' then
        return price;
    end

    for i = 1, abilLevel do
        local GetCalcPriceScript = _G[scrCalcPrice];
        price = price + GetCalcPriceScript(pc, abilName, i, maxLevel);
    end

    return price;
end

function GET_TOTAL_ABILITY_PRICE_BY_PRICE_COLUMN(abilGroup, abilName, abilLevel)
    local price = 0;
    if abilGroup == nil or abilName == nil or abilLevel == nil then
        return price;
    end
    
    local abilShopInfoCls = GetClass(abilGroup, abilName);
    if abilShopInfoCls == nil then
        IMC_LOG("ERROR_NULLPTR", "Not Exist Ability shop info- abilGroup["..abilGroup.."], abilName["..abilName.."]");
        return price;
    end

    for i = 1, abilLevel do
        local priceCol = TryGetProp(abilShopInfoCls, "Price"..i);
        if priceCol == nil then
            IMC_LOG("ERROR_NULLPTR", "Not Exist Price column- abilGroup["..abilGroup.."], abilName["..abilName.."], abilLevel["..i.."]");
        else
            price = price + priceCol;
        end
    end

    return price;
end
-- 현재 레벨까지의 특성 소모 특성 포인트를 가져온다.
-- 특성 활성화 조건을 만족하지 않았다면 0을 반환
function GET_ABILITY_POINT_BY_NAME(pc, name)
    local cls = GetClass('Ability', name)
    if cls == nil then
        return 0
    end

    local job_list = TryGetProp(cls, 'Job', 'None')
    if job_list == 'None' then        
        return 0
    end

    local need_skill = TryGetProp(cls, 'SkillCategory', 'None')
    if  need_skill ~= 'All' and need_skill ~= 'None' then
        local token = StringSplit(need_skill, ';')
        local exist = false
        for i = 1, #token do
            local skill_name = token[i];
            local skill = GetSkill(pc, skill_name);
            if skill ~= nil then
                exist = true
                break
            end            
        end
        
        if exist == false then            
            return 0
        end
    end

    local token = StringSplit(job_list, ';')
    for i = 1, #token do
        local job = token[i]
        local job_cls = GetClass('Job', job)
        if job_cls ~= nil then
            local suffix = TryGetProp(job_cls, 'EngName', 'None')
            local group_name = 'Ability_' .. suffix
            local shop_info = GetClass(group_name, name)
            if shop_info ~= nil then
                local abil = nil
                if IsServerSection() == 1 then
                    abil = GetAbilityIESObject(pc, TryGetProp(shop_info, 'ClassName', 'None'))
                else
                    abil = GetAbility(pc, TryGetProp(shop_info, 'ClassName', 'None'))
                end
                local level = TryGetProp(abil, 'Level', 0)                
                local func_name = TryGetProp(shop_info, 'ScrCalcPrice', 'None')
                local max_level = TryGetProp(shop_info, 'MaxLevel', 100)                

                local unlockFuncName = TryGetProp(shop_info, 'UnlockScr', 'None')
                local flag = true
                if unlockFuncName ~= 'None' then
                    local scp = _G[unlockFuncName];
                    if scp ~= nil then        
                        local ret = scp(pc, TryGetProp(shop_info, 'UnlockArgStr', 'None'), TryGetProp(shop_info, 'UnlockArgNum', 99), abil);
                        if ret ~= 'UNLOCK' then
                            -- flag = false
                            local addret = SET_ADDITOINAL_LOCK_FUNCTION(pc, shop_info)
                            if addret ~= 'UNLOCK' then
                                flag = false
                            end
                        end
                    end
                end
                if func_name ~= 'None' and flag == true then
                    local func = _G[func_name]   
                    if func ~= nil then
                        local point = 0                        
                        for j = 1, level do
                            local add = func(pc, name, j, max_level)
                            point = point + add                            
                        end
                        return point
                    end
                end
            end
        end
    end

    return 0
end

-- 특성 max레벨을 달성하기 위해 필요한 총 특성 포인트량
function GET_MAX_REQUIRED_ABILITY_POINT(pc, name)
    local cls = GetClass('Ability', name)
    if cls == nil then
        return nil
    end

    local job_list = TryGetProp(cls, 'Job', 'None')
    if job_list == 'None' then
        return nil
    end

    local token = StringSplit(job_list, ';')
    for i = 1, #token do
        local job = token[i]
        local job_cls = GetClass('Job', job)
        if job_cls ~= nil then
            local suffix = TryGetProp(job_cls, 'EngName', 'None')
            local group_name = 'Ability_' .. suffix
            local shop_info = GetClass(group_name, name)
            if shop_info ~= nil then
                local func_name = TryGetProp(shop_info, 'ScrCalcPrice', 'None')
                local max_level = TryGetProp(shop_info, 'MaxLevel', 100)                
                if func_name ~= 'None' then
                    local func = _G[func_name]                    
                    if func ~= nil then
                        local point = 0
                        for j = 1, max_level do
                            point = point + func(pc, name, j, max_level)
                        end
                        return point
                    end
                end
            end
        end
    end

    return nil
end
                

function ABIL_REINFORCE_PRICE_Pontifex_Gospel(pc, abilName, abilLevel, maxLevel)    
    return 100000, 0
end
