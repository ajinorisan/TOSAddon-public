local PC_MAX_MSPD = 60


function GET_PVP_TARGET_COUNT(self, count)
    if IsPVPField(self) == 1 and count > 2 then
        count = math.floor((math.max(0, count-2) ^ 0.5)) + math.min(2, count)
    end

    return count
end


function SCR_GET_JOB_STAT_RATIO(pc, statName)
	local stat = 0;
	if statName == nil then
		return 1;
    end
    
    local jobList = GetJobHistoryList(pc);
    if jobList ~= nil then
		local totalStatRatio = 0;
        local jobCount = #jobList;
        for i = 1, jobCount do
            local jobClass = GetClassByType('Job', jobList[i]);
			if jobClass ~= nil then
                local tempStatName = statName
			    tempStatName = SCR_GET_JOB_STAT_CHANGE(pc, TryGetProp(jobClass, "ClassName", "None"), statName, jobClass[statName])
                totalStatRatio = totalStatRatio + jobClass[tempStatName];
            end
        end
		
		local statRatio = totalStatRatio / jobCount;
	    local lv = TryGetProp(pc, "Lv", 1);
		stat = (lv - 1) * (statRatio / 100);
	end
	
	return math.floor(stat);
end

function SCR_GET_JOB_STAT_CHANGE(pc, jobClassName, statName, statrate)
    local tempStatName = statName
    local propName = "CHANGE_STAT_"..jobClassName
    
    if GetExProp(pc ,propName) == 0 then
        return tempStatName
    else
        local abilCleric24 = GetAbility(pc, "Cleric24") -- 물리로 변경
        local abilCleric36 = GetAbility(pc, "Cleric36") -- 마법으로 변경
        if abilCleric24 ~= nil and TryGetProp(abilCleric24, "ActiveState", 0) == 1 then
            if tempStatName == "STR" then
                tempStatName = "INT"
            elseif tempStatName == "DEX" then
                tempStatName = "MNA"
            end

            if tempStatName == "INT" and statrate > 0 then
                tempStatName = "STR"
            elseif tempStatName == "MNA" and statrate > 0 then
                tempStatName = "DEX"
            end
        elseif abilCleric36 ~= nil and TryGetProp(abilCleric36, "ActiveState", 0) == 1 then
            if tempStatName == "INT"  then
                tempStatName = "STR"
            elseif tempStatName == "MNA" then
                tempStatName = "DEX"
            end

            if tempStatName == "STR" and statrate > 0 then
                tempStatName = "INT"
            elseif tempStatName == "DEX" and statrate > 0 then
                tempStatName = "MNA"
            end
        end
    end
    
    return tempStatName
end

function SCR_GET_JOB_STR(pc)
    local statName = 'STR'
    return SCR_GET_JOB_STAT_RATIO(pc, statName);
end

function SCR_GET_JOB_DEX(pc)
    local statName = 'DEX'
    return SCR_GET_JOB_STAT_RATIO(pc, statName);
end

function SCR_GET_JOB_CON(pc)
    local statName = 'CON'
    return SCR_GET_JOB_STAT_RATIO(pc, statName);
end

function SCR_GET_JOB_INT(pc)
    local statName = 'INT'
    return SCR_GET_JOB_STAT_RATIO(pc, statName);
end

function SCR_GET_JOB_MNA(pc)
    local statName = 'MNA'
    return SCR_GET_JOB_STAT_RATIO(pc, statName);
end

function SCR_GET_JOB_LUCK(pc)
    local statName = 'LUCK'
    return SCR_GET_JOB_STAT_RATIO(pc, statName);
end

function SCR_Get_Const(self)
    local lv = TryGetProp(self, "Lv")
    if lv == nil then
        lv = 1;
    end
    
    local value = (lv + 5) / math.pi
    
    return value;
end

function GET_STAT_POINT(pc)
--    local byLevel = TryGetProp(pc, "StatByLevel")
--    if byLevel == nil then
--        byLevel = 0;
--    end
    
    local byBonus = TryGetProp(pc, "StatByBonus")
    if byBonus == nil then
        byBonus = 0;
    end
    
    local usedStat = TryGetProp(pc, "UsedStat")
    if usedStat == nil then
        usedStat = 0;
    end
    
--    return math.floor(byLevel + byBonus - usedStat);
    return math.floor(byBonus - usedStat);
end

function SCR_GET_MAX_WEIGHT(pc)
    local defaultWeight = 8000;
    
    local byBonus = TryGetProp(pc, "MaxWeight_Bonus")
    if byBonus == nil then
        byBonus = 0;
    end
    
    local byBuff = TryGetProp(pc, "MaxWeight_BM")
    if byBuff == nil then
        byBuff = 0
    end
    
    local byRateBuff = TryGetProp(pc, "MaxWeight_RATE_BM")
    if byRateBuff == nil then
        byRateBuff = 0;
    end
    
    byRateBuff = defaultWeight * byRateBuff;
    
    local rewardProperty = GET_REWARD_PROPERTY(pc, "MaxWeight")
    
    local value = defaultWeight + byBonus + byBuff + byRateBuff + rewardProperty;
    
    return math.floor(value);
end

function SCR_GET_NOW_WEIGHT(pc)
    return GetTotalItemWeight(pc);
end

function SCR_GET_ADDSTAT(self, stat)
    -- 스탯 올릴 때 보너스로 올라가는 스탯 --
    -- 2017년 3월 3일 리밸런싱으로 삭제 --
    
    local addStat = 0;
    
    return math.floor(addStat);
end

function SCR_GET_JOB_DEFAULT_STAT(pc, prop)
    local jobObj = nil
    if IsServerObj(pc) == 1 then
        jobObj = GetJobObject(pc);
    else
        jobObj = GetJobObject();
    end

    local jobCtrlType = TryGetProp(jobObj, 'CtrlType')
    if jobCtrlType ~= nil then
		local stat = 1;
	    local ctrlTypeClass = GetClass("Stat_PC", jobCtrlType);
	    if ctrlTypeClass ~= nil then
	        stat = TryGetProp(ctrlTypeClass, prop, stat);
	    end
	    
	    if stat < 1 then
	    	stat = 1;
	    end
		
        return stat;
    end
	
    return 1;
end

function SCR_GET_JOB_RATIO_STAT(pc, prop)
    local jobObj = nil
    if IsServerObj(pc) == 1 then
        jobObj = GetJobObject(pc);
    else
        jobObj = GetJobObject();
    end

    local jobCtrlType = TryGetProp(jobObj, 'CtrlType')
    if jobCtrlType ~= nil then
		local ctrlTypeRate = 100;
	    local ctrlTypeClass = GetClass("Stat_PC", jobCtrlType);
	    if ctrlTypeClass ~= nil then
	        ctrlTypeRate = TryGetProp(ctrlTypeClass, prop, ctrlTypeRate);
	    end
	    
	    ctrlTypeRate = ctrlTypeRate / 100;
	    
	    if ctrlTypeRate < 0 then
	    	ctrlTypeRate = 0;
	    end
		
        return ctrlTypeRate;
    end
    
    return 1;
end

function SCR_GET_STR(self)
    -- self.STR_JOB : job.xml에 있는 "레벨 당 비율로 증가한 스탯" --
    -- self.STR_STAT : pc.xml에 있는 "직접 투자한 스탯" --
    -- self.STR_Bonus : pc_battle.xml에 있지만 0 --
    -- self.STR_ADD : 장비, 버프 등 가변적인 스탯 --
    -- GetExProp(self, "STR_TEMP") : 임시로 지정한 추가 스탯 (아마도 PVP 보정용?) --
    -- rewardProperty : 퀘스트 등에서 보상으로 지급한 스탯 (현재는 지급되는 곳 없음?) --
    -- ALLSTAT : 올 스탯 증가 --
    
    local statString = "STR";
    
    local defaultStat = SCR_GET_JOB_DEFAULT_STAT(self, statString);
    
    local byJob = SCR_GET_JOB_STR(self);
    if byJob == nil then
        byJob = 0;
    end
    
    local byStat = TryGetProp(self, statString.."_STAT");
    if byStat == nil then
        byStat = 0;
    end
    
    local byBonus = TryGetProp(self, statString.."_Bonus");
    if byBonus == nil then
        byBonus = 0;
    end
    
    local byAdd = TryGetProp(self, statString.."_ADD");
    if byAdd == nil then
        byAdd = 0;
    end
    
    local byTemp = GetExProp(self, statString.."_TEMP");
    if byTemp == nil then
        byTemp = 0;
    end

    local rewardProperty = GET_REWARD_PROPERTY(self, statString);
    
    local value = defaultStat + byJob + byStat + byBonus + byAdd + byTemp + rewardProperty;
    
    if value < 1 then
        value = 1;
    end
    
    return math.floor(value);
end

function SCR_GET_ADDSTR(self)
    local statString = "STR";
    
    local byItem = GetSumOfEquipItem(self, statString);
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(self, statString.."_BM");
    if byBuff == nil then
        byBuff = 0
    end
    
    local byItemBuff = TryGetProp(self, statString.."_ITEM_BM");
    if byItemBuff == nil then
        byItemBuff = 0
    end

    local byAllStat = TryGetProp(self, "ALLSTAT");
    if byAllStat == nil then
        byAllStat = 0;
    end

    local value = byItem + byBuff + byItemBuff + byAllStat;
    
    return math.floor(value);
end

function SCR_GET_DEX(self)
    local statString = "DEX";
        
    local defaultStat = SCR_GET_JOB_DEFAULT_STAT(self, statString);
    
    local byJob = TryGetProp(self, statString.."_JOB");
    if byJob == nil then
        byJob = 0;
    end
    
    local byStat = TryGetProp(self, statString.."_STAT");
    if byStat == nil then
        byStat = 0;
    end
    
    local byBonus = TryGetProp(self, statString.."_Bonus");
    if byBonus == nil then
        byBonus = 0;
    end
    
    local byAdd = TryGetProp(self, statString.."_ADD");
    if byAdd == nil then
        byAdd = 0;
    end
    
    local byTemp = GetExProp(self, statString.."_TEMP");
    if byTemp == nil then
        byTemp = 0;
    end
    
    local rewardProperty = GET_REWARD_PROPERTY(self, statString);
    
    local value = defaultStat + byJob + byStat + byBonus + byAdd + byTemp + rewardProperty;
    
    if value < 1 then
        value = 1;
    end
    
    return math.floor(value);
end

function SCR_GET_ADDDEX(self)
    local statString = "DEX";
    
    local byItem = GetSumOfEquipItem(self, statString);
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(self, statString.."_BM");
    if byBuff == nil then
        byBuff = 0
    end
    
    local byItemBuff = TryGetProp(self, statString.."_ITEM_BM");
    if byItemBuff == nil then
        byItemBuff = 0
    end
    
    local byAllStat = TryGetProp(self, "ALLSTAT");
    if byAllStat == nil then
        byAllStat = 0;
    end

    local value = byItem + byBuff + byItemBuff + byAllStat;
    
    return math.floor(value);
end


function SCR_GET_CON(self)
    local statString = "CON";
    
    local defaultStat = SCR_GET_JOB_DEFAULT_STAT(self, statString);
    
    local byJob = SCR_GET_JOB_CON(self);
    if byJob == nil then
        byJob = 0;
    end
    
    local byStat = TryGetProp(self, statString.."_STAT");
    if byStat == nil then
        byStat = 0;
    end
    
    local byBonus = TryGetProp(self, statString.."_Bonus");
    if byBonus == nil then
        byBonus = 0;
    end
    
    local byAdd = TryGetProp(self, statString.."_ADD");
    if byAdd == nil then
        byAdd = 0;
    end
    
    local byTemp = GetExProp(self, statString.."_TEMP");
    if byTemp == nil then
        byTemp = 0;
    end

    local rewardProperty = GET_REWARD_PROPERTY(self, statString);
    
    local byEnchant = 0;
    local enchantCount = CountEnchantItemEquip(self, 'ENCHANTARMOR_VOLITIVE');
    if enchantCount > 0 then
        local enchantStatString = "MNA";
        
        --local enchantByJob = TryGetProp(self, enchantStatString.."_JOB");
        --local enchantByBonus = TryGetProp(self, enchantStatString.."_Bonus");
        --local enchantByTemp = GetExProp(self, enchantStatString.."_TEMP");
        local enchantByStat = TryGetProp(self, enchantStatString);
        local enchantRewardProp = GET_REWARD_PROPERTY(self, statString);

        byEnchant = ((enchantByStat + enchantRewardProp) / 20) * enchantCount;
    end
    
    local value = defaultStat + byJob + byStat + byBonus + byAdd + byTemp + byEnchant + rewardProperty;
    
    if value < 1 then
        value = 1;
    end
    
    return math.floor(value);
end

function SCR_GET_ADDCON(self)
    local statString = "CON";
    
    local byItem = GetSumOfEquipItem(self, statString);
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(self, statString.."_BM");
    if byBuff == nil then
        byBuff = 0
    end
    
    local byItemBuff = TryGetProp(self, statString.."_ITEM_BM");
    if byItemBuff == nil then
        byItemBuff = 0
    end

    local byAllStat = TryGetProp(self, "ALLSTAT");
    if byAllStat == nil then
        byAllStat = 0;
    end
    
    local value = byItem + byBuff + byItemBuff + byAllStat;
    
    return math.floor(value);
end

function SCR_GET_INT(self)
    local statString = "INT";
    
    local defaultStat = SCR_GET_JOB_DEFAULT_STAT(self, statString);
    
    local byJob = SCR_GET_JOB_INT(self);
    if byJob == nil then
        byJob = 0;
    end
    
    local byStat = TryGetProp(self, statString.."_STAT");
    if byStat == nil then
        byStat = 0;
    end
    
    local byBonus = TryGetProp(self, statString.."_Bonus");
    if byBonus == nil then
        byBonus = 0;
    end
    
    local byAdd = TryGetProp(self, statString.."_ADD");
    if byAdd == nil then
        byAdd = 0;
    end
    
    local byTemp = GetExProp(self, statString.."_TEMP");
    if byTemp == nil then
        byTemp = 0;
    end

    local rewardProperty = GET_REWARD_PROPERTY(self, statString);
    
    local value = defaultStat + byJob + byStat + byBonus + byAdd + byTemp + rewardProperty;
    
    if value < 1 then
        value = 1;
    end
    
    return math.floor(value);
end

function SCR_GET_ADDINT(self)
    local statString = "INT";
    
    local byItem = GetSumOfEquipItem(self, statString);
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(self, statString.."_BM");
    if byBuff == nil then
        byBuff = 0
    end
    
    local byItemBuff = TryGetProp(self, statString.."_ITEM_BM");
    if byItemBuff == nil then
        byItemBuff = 0
    end

    local byAllStat = TryGetProp(self, "ALLSTAT");
    if byAllStat == nil then
        byAllStat = 0;
    end
    
    local value = byItem + byBuff + byItemBuff + byAllStat;
    
    return math.floor(value);
end

function SCR_GET_MNA(self)
    local statString = "MNA";
    
    local defaultStat = SCR_GET_JOB_DEFAULT_STAT(self, statString);
    
    local byJob = SCR_GET_JOB_MNA(self);
    if byJob == nil then
        byJob = 0;
    end
    
    local byStat = TryGetProp(self, statString.."_STAT");
    if byStat == nil then
        byStat = 0;
    end
    
    local byBonus = TryGetProp(self, statString.."_Bonus");
    if byBonus == nil then
        byBonus = 0;
    end
    
    local byAdd = TryGetProp(self, statString.."_ADD");
    if byAdd == nil then
        byAdd = 0;
    end
    
    local byTemp = GetExProp(self, statString.."_TEMP");
    if byTemp == nil then
        byTemp = 0;
    end
    
    local rewardProperty = GET_REWARD_PROPERTY(self, statString);
    
    local value = defaultStat + byJob + byStat + byBonus + byAdd + byTemp + rewardProperty;
    
    if value < 1 then
        value = 1;
    end
    
    return math.floor(value);
end

function SCR_GET_ADDMNA(self)
    local statString = "MNA";
    
    local byItem = GetSumOfEquipItem(self, statString);
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(self, statString.."_BM");
    if byBuff == nil then
        byBuff = 0
    end
    
    local byItemBuff = TryGetProp(self, statString.."_ITEM_BM");
    if byItemBuff == nil then
        byItemBuff = 0
    end

    local byAllStat = TryGetProp(self, "ALLSTAT");
    if byAllStat == nil then
        byAllStat = 0;
    end
    
    local value = byItem + byBuff + byItemBuff + byAllStat;
    
    return math.floor(value);
end

function SCR_GET_LUCK(self)
    local byJob = TryGetProp(self, "LUCK_JOB");
    if byJob == nil then
        byJob = 0;
    end
    
    local byStat = TryGetProp(self, "LUCK_STAT");
    if byStat == nil then
        byStat = 0;
    end
    
    local byAdd = TryGetProp(self, "LUCK_ADD");
    if byAdd == nil then
        byAdd = 0;
    end
    
    local value = math.floor(byJob + byStat + byAdd);
    
    return math.max(1, value);

end

function SCR_GET_ADDLUCK(self)
    local statString = "LUCK";
    
    local byItem = GetSumOfEquipItem(self, statString);
    local byBuff = TryGetProp(self, statString.."_BM");
    
    local byItemBuff = TryGetProp(self, statString.."_ITEM_BM");
    if byItemBuff == nil then
        byItemBuff = 0
    end
    
    local value = byItem + byBuff + byItemBuff;
    
    return math.floor(value);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ALLSTAT(self)
    local byStat = TryGetProp(self, "ALLSTAT_STAT");
    if byStat == nil then
        byStat = 0;
    end
    
    local byAdd = TryGetProp(self, "ALLSTAT_ADD");
    if byAdd == nil then
        byAdd = 0;
    end
    
    local value = math.floor(byStat + byAdd);
    return math.max(0, value);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ADDALLSTAT(self)
    local statString = "ALLSTAT";
    
    local byItem = GetSumOfEquipItem(self, statString);
    if byItem == nil then
        byItem = 0;
    end

    local byBuff = TryGetProp(self, statString.."_BM");
    if byBuff == nil then
        byBuff = 0
    end

    local byItemBuff = TryGetProp(self, statString.."_ITEM_BM");
    if byItemBuff == nil then
        byItemBuff = 0
    end

    local value = byItem + byBuff + byItemBuff;

    return math.floor(value);
end

function SCR_Get_RefreshHP(self)
    local valueMHP = TryGetProp(self, MHP)
    if valueMHP == nil then
        valueMHP = 1;
    end
    
    return valueMHP * 0.3;
end


function SCR_Get_MHP(self)
    local jobRate = SCR_GET_JOB_RATIO_STAT(self, "MHP");
    local jobMHP = 400 * jobRate;
    
    local lv = TryGetProp(self, "Lv");
    if lv == nil then
        lv = 1;
    end
    
    local stat = TryGetProp(self, "CON");
    if stat == nil then
        stat = 1;
    end
    
    local byLevel = math.floor(jobMHP + ((lv - 1) * 80 * jobRate));
    local byStat = math.floor(((stat * 0.003) + (math.floor(stat / 10) * 0.01)) * byLevel);

    local byBonus = TryGetProp(self, "MHP_Bonus");
    if byBonus == nil then
        byBonus = 0;
    end
    
    local itemRatio = GetSumOfEquipItem(self, 'MHPRatio');
    if itemRatio == nil then
        itemRatio = 0;
    end
    
    local byItemRatio = (byLevel + byStat) * (itemRatio * 0.01);
    local byItem = GetSumOfEquipItem(self, 'MHP');
    if byItem == nil then
        byItem = 0;
    end
    
    local rewardProperty = GET_REWARD_PROPERTY(self, "MHP");
    
    local value = byLevel + byStat + byBonus + byItemRatio + byItem + rewardProperty;
    
    local byBuff = TryGetProp(self, "MHP_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local byRateBuff = TryGetProp(self, "MHP_RATE_BM");
    if byRateBuff == nil then
        byRateBuff = 0;
    end
    
    byRateBuff = math.floor(value * byRateBuff);
    
    value = value + byBuff + byRateBuff;
    
    if value < 1 then
        value = 1;
    end
    
    return math.floor(value);
end

function SCR_Get_MSP(self)
	local jobRate = SCR_GET_JOB_RATIO_STAT(self, "MSP");
    local jobMSP = 200 * jobRate;
--	local defaultMSP = 1000;
    
    local lv = TryGetProp(self, "Lv");
    if lv == nil then
        lv = 1;
    end
    
    local stat = TryGetProp(self, "MNA", 1);    
    if stat == nil then
        stat = 1;
    end
    
    local byLevel = math.floor(jobMSP + ((lv - 1) * 18 * jobRate));
    local byStat = math.floor(((stat * 0.005) + (math.floor(stat / 10) * 0.015)) * byLevel);                    
    --local byStat = math.floor(((stat * 0.003) + (math.floor(stat / 10) * 0.01)) * byLevel)
    byStat = math.floor(byStat / 15)
    
    local byBonus = TryGetProp(self, "MSP_Bonus");
    if byBonus == nil then
        byBonus = 0;
    end
    
    local byItem = GetSumOfEquipItem(self, 'MSP');
    if byItem == nil then
        byItem = 0;
    end
    
    local rewardProperty = GET_REWARD_PROPERTY(self, "MSP");
    
--    local value = byLevel + byStat + byBonus + byItem + rewardProperty;
    local value = byLevel + byBonus + byItem + rewardProperty + byStat;    
--    local value = defaultMSP + byBonus + byItem + rewardProperty;
    
    local byBuff = TryGetProp(self, "MSP_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local byRateBuff = TryGetProp(self, "MSP_RATE_BM");
    if byRateBuff == nil then
        byRateBuff = 0;
    end
    
    byRateBuff = math.floor(value * byRateBuff);
    
    value = value + byBuff + byRateBuff;
    
    if value < 0 then
        value = 0;
    end
    
    return math.floor(value);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_DEFAULT_MINPATK(self)
    local defaultValue = 20;

    local lv = TryGetProp(self, "Lv");
    if lv == nil then
        lv = 1;
    end
    
    local byLevel = lv * 1;
    
    local stat = TryGetProp(self, "STR");
    if stat == nil then
        stat = 1;
    end
    
    local byStat = (stat * 2) + (math.floor(stat / 10) * (byLevel * 0.05));

    local byItem = 0;
    if tonumber(USE_SUBWEAPON_SLOT) == 1 then
        local rhAtk = 0
        local lhAtk = 0
        local rh_subAtk = 0
        local lh_subAtk = 0

        local rh = GetEquipItemForPropCalc(self, 'RH')
        if rh ~= nil then
            rhAtk = TryGetProp(rh, 'MINATK', 0)
        end
        
        local lh = GetEquipItemForPropCalc(self, 'LH')
        if lh ~= nil and IS_NO_EQUIPITEM(lh) ~= 1 then
            if TryGetProp(lh, "ClassType", 'None') == "Trinket" then
                lhAtk = TryGetProp(lh, 'MINATK', 0)
            else

                lhAtk = TryGetProp(lh, 'MINATK', 0) * 0.3
            end
        end

        byItem = rhAtk + lhAtk
        
        local rh_sub = GetEquipItemForPropCalc(self, 'RH_SUB')
        if rh_sub ~= nil and IS_NO_EQUIPITEM(rh_sub) ~= 1 then
            rh_subAtk = TryGetProp(rh_sub, 'MINATK', 0)

            local lh_sub = GetEquipItemForPropCalc(self, 'LH_SUB')
            if lh_sub ~= nil then
                if TryGetProp(lh_sub, "ClassType") == "Trinket" then
                    lh_subAtk = TryGetProp(lh_sub, 'MINATK', 0)
                else
                    lh_subAtk = TryGetProp(lh_sub, 'MINATK', 0) * 0.3
                end
            end

            local bySubItem = rh_subAtk + lh_subAtk
            byItem = byItem * 0.5 + bySubItem * 0.5
        end

        byItem = math.floor(byItem)
    end
    
    local byItemList = { "MINATK", "PATK", "ADD_MINATK" };
    for i = 1, #byItemList do
        local byItemTemp = GetSumOfEquipItem(self, byItemList[i]);
        if byItemTemp == nil then
            byItemTemp = 0;
        end
        byItem = byItem + byItemTemp;
    end

    local ori_rhAtk = TryGetProp(GetEquipItemForPropCalc(self, 'RH'), 'MINATK', 0)
    local ori_lhAtk = TryGetProp(GetEquipItemForPropCalc(self, 'LH'), 'MINATK', 0)
    local ori_trinketAtk = TryGetProp(GetEquipItemForPropCalc(self, 'TRINKET'), 'MINATK', 0)
    local ori_rh_subAtk = TryGetProp(GetEquipItemForPropCalc(self, 'RH_SUB'), 'MINATK', 0)
    local ori_lh_subAtk = TryGetProp(GetEquipItemForPropCalc(self, 'LH_SUB'), 'MINATK', 0)
    
    byItem = byItem - (ori_rhAtk + ori_lhAtk + ori_trinketAtk + ori_rh_subAtk + ori_lh_subAtk)

    byItem = byItem + TryGetProp(self, "EQUIP_PATK", 0) + TryGetProp(self, "EQUIP_PATK_MAIN", 0);

    local value = defaultValue + byLevel + byStat + byItem;

    return value
end


-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_MINPATK(self)
    local value = SCR_Get_DEFAULT_MINPATK(self)

    local byBuff = 0;
    local byBuffList = { "PATK_BM", "MINPATK_BM", "PATK_MAIN_BM", "MINPATK_MAIN_BM" };
    for i = 1, #byBuffList do
        local byBuffTemp = TryGetProp(self, byBuffList[i]);
        if byBuffTemp == nil then
            byBuffTemp = 0;
        end
        
        byBuff = byBuff + byBuffTemp;
    end
    
    local byRateBuff = 0;
    local byRateBuffList = { "PATK_RATE_BM", "MINPATK_RATE_BM", "PATK_MAIN_RATE_BM", "MINPATK_MAIN_RATE_BM" };
    for i = 1, #byRateBuffList do
        local byRateBuffTemp = TryGetProp(self, byRateBuffList[i]);
        if byRateBuffTemp == nil then
            byRateBuffTemp = 0;
        end
        
        byRateBuff = byRateBuff + byRateBuffTemp;
    end
    
    byRateBuff = math.floor(value * byRateBuff);
    
    value = value + byBuff + byRateBuff;

    local decRatio = TryGetProp(self, 'PATK_RATE_MUL_BM', 1);
    if decRatio < 0.5 then
        decRatio = 0.5
    end
    value = math.floor(value * decRatio)    
    
    local maxPATK = TryGetProp(self, "MAXPATK");
    if value > maxPATK then
        value = maxPATK;
    end
    
    if value < 1 then
    	value = 1;
    end

    local equip_list = { 'RH', 'LH', 'RH_SUB', 'LH_SUB' }
    local evolve_value = 0
    for k, v in pairs(equip_list) do
        local item = GetEquipItemForPropCalc(self, v)
        if item ~= nil then
            evolve_value = evolve_value + GET_EVOLVED_ATK(item)
        end
    end

    return math.floor(value) + evolve_value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_DEFAULT_MAXPATK(self)
    local defaultValue = 20;
    
    local lv = TryGetProp(self, "Lv");
    if lv == nil then
        lv = 1;
    end
    
    local byLevel = lv * 1;
    
    local stat = TryGetProp(self, "STR");
    if stat == nil then
        stat = 1;
    end
    
    local byStat = (stat * 2) + (math.floor(stat / 10) * (byLevel * 0.05));
    
    local byItem = 0;
    if tonumber(USE_SUBWEAPON_SLOT) == 1 then
        local rhAtk = 0
        local lhAtk = 0
        local rh_subAtk = 0
        local lh_subAtk = 0

        local rh = GetEquipItemForPropCalc(self, 'RH')
        if rh ~= nil then
            rhAtk = TryGetProp(rh, 'MAXATK', 0)
        end

        local lh = GetEquipItemForPropCalc(self, 'LH')
        if lh ~= nil and IS_NO_EQUIPITEM(lh) ~= 1 then
            if TryGetProp(lh, "ClassType") == "Trinket" then
                lhAtk = TryGetProp(lh, 'MAXATK', 0)
            else
                lhAtk = TryGetProp(lh, 'MAXATK', 0) * 0.3
            end
        end       

        byItem = rhAtk + lhAtk

        local rh_sub = GetEquipItemForPropCalc(self, 'RH_SUB')
        if rh_sub ~= nil and IS_NO_EQUIPITEM(rh_sub) ~= 1 then
            rh_subAtk = TryGetProp(rh_sub, 'MAXATK', 0)

            local lh_sub = GetEquipItemForPropCalc(self, 'LH_SUB')
            if TryGetProp(lh_sub, "ClassType") == "Trinket" then
                lh_subAtk = TryGetProp(lh_sub, 'MAXATK', 0)
            else
                lh_subAtk = TryGetProp(lh_sub, 'MAXATK', 0) * 0.3
            end

            local bySubItem = rh_subAtk + lh_subAtk
            byItem = byItem * 0.5 + bySubItem * 0.5
        end

        byItem = math.floor(byItem)
    end

    local byItemList = { "MAXATK", "PATK", "ADD_MAXATK" };
    for i = 1, #byItemList do
        local byItemTemp = GetSumOfEquipItem(self, byItemList[i]);
        if byItemTemp == nil then
            byItemTemp = 0;
        end
        byItem = byItem + byItemTemp;
    end

    local ori_rhAtk = TryGetProp(GetEquipItemForPropCalc(self, 'RH'), 'MAXATK', 0)
    local ori_lhAtk = TryGetProp(GetEquipItemForPropCalc(self, 'LH'), 'MAXATK', 0)
    local ori_trinketAtk = TryGetProp(GetEquipItemForPropCalc(self, 'TRINKET'), 'MAXATK', 0)
    local ori_rh_subAtk = TryGetProp(GetEquipItemForPropCalc(self, 'RH_SUB'), 'MAXATK', 0)
    local ori_lh_subAtk = TryGetProp(GetEquipItemForPropCalc(self, 'LH_SUB'), 'MAXATK', 0)
    
    byItem = byItem - (ori_rhAtk + ori_lhAtk + ori_trinketAtk + ori_rh_subAtk + ori_lh_subAtk)

    byItem = byItem + TryGetProp(self, "EQUIP_PATK", 0) + TryGetProp(self, "EQUIP_PATK_MAIN", 0);

    local value = defaultValue + byLevel + byStat + byItem;
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_MAXPATK(self)
    local value = SCR_Get_DEFAULT_MAXPATK(self)
    
    local byBuff = 0;
    local byBuffList = { "PATK_BM", "MAXPATK_BM", "PATK_MAIN_BM", "MAXPATK_MAIN_BM" };
    for i = 1, #byBuffList do
        local byBuffTemp = TryGetProp(self, byBuffList[i]);
        if byBuffTemp == nil then
            byBuffTemp = 0;
        end
        
        byBuff = byBuff + byBuffTemp;
    end
    
    local byRateBuff = 0;
    local byRateBuffList = { "PATK_RATE_BM", "MAXPATK_RATE_BM", "PATK_MAIN_RATE_BM", "MAXPATK_MAIN_RATE_BM" };
    for i = 1, #byRateBuffList do
        local byRateBuffTemp = TryGetProp(self, byRateBuffList[i]);
        if byRateBuffTemp == nil then
            byRateBuffTemp = 0;
        end
        
        byRateBuff = byRateBuff + byRateBuffTemp;
    end
    
    byRateBuff = math.floor(value * byRateBuff);
    
    value = value + byBuff + byRateBuff;

    local decRatio = TryGetProp(self, 'PATK_RATE_MUL_BM', 1);
    if decRatio < 0.5 then
        decRatio = 0.5
    end
    value = math.floor(value * decRatio)
    
    if value < 1 then
    	value = 1;
    end
    
    local equip_list = { 'RH', 'LH', 'RH_SUB', 'LH_SUB' }
    local evolve_value = 0
    for k, v in pairs(equip_list) do
        local item = GetEquipItemForPropCalc(self, v)
        if item ~= nil then
            evolve_value = evolve_value + GET_EVOLVED_ATK(item)
        end
    end

    return math.floor(value) + evolve_value;
end

function SCR_Get_DEFAULT_MINPATK_SUB(self)
    local defaultValue = 20;

    local lv = TryGetProp(self, "Lv");
    if lv == nil then
        lv = 1;
    end
    
    local byLevel = lv * 1;
    
    local stat = TryGetProp(self, "STR");
    if stat == nil then
        stat = 1;
    end
    
    local byStat = (stat * 2) + (math.floor(stat / 10) * (byLevel * 0.05));

    local byItem = 0;
    local byItemList = { "MINATK", "PATK", "ADD_MINATK" };
    for i = 1, #byItemList do
        local byItemTemp = GetSumOfEquipItem(self, byItemList[i]);
        if byItemTemp == nil then
            byItemTemp = 0;
        end

        byItem = byItem + byItemTemp;
    end
 
    byItem = byItem + TryGetProp(self, "EQUIP_PATK", 0) + TryGetProp(self, "EQUIP_PATK_SUB", 0);
   
    -- 20%
    byItem = math.floor(byItem * 0.3)

    local value = defaultValue + byLevel + byStat + byItem;

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_MINPATK_SUB(self)
    local value = SCR_Get_DEFAULT_MINPATK_SUB(self)
    
    local byBuff = 0;
    local byBuffList = { "PATK_BM", "MINPATK_BM", "PATK_SUB_BM", "MINPATK_SUB_BM" };
    for i = 1, #byBuffList do
        local byBuffTemp = TryGetProp(self, byBuffList[i]);
        if byBuffTemp == nil then
            byBuffTemp = 0;
        end
        
        byBuff = byBuff + byBuffTemp;
    end
    
    local byRateBuff = 0;
    local byRateBuffList = { "PATK_RATE_BM", "MINPATK_RATE_BM", "PATK_SUB_RATE_BM", "MINPATK_SUB_RATE_BM" };
    for i = 1, #byRateBuffList do
        local byRateBuffTemp = TryGetProp(self, byRateBuffList[i]);
        if byRateBuffTemp == nil then
            byRateBuffTemp = 0;
        end
        
        byRateBuff = byRateBuff + byRateBuffTemp;
    end
    
    byRateBuff = math.floor(value * byRateBuff);
    
    value = value + byBuff + byRateBuff;

    local decRatio = TryGetProp(self, 'PATK_RATE_MUL_BM', 1);
    if decRatio < 0.5 then
        decRatio = 0.5
    end
    value = math.floor(value * decRatio)
    
    local maxPATK_SUB = TryGetProp(self, "MAXPATK_SUB");
    if value > maxPATK_SUB then
        value = maxPATK_SUB;
    end

    if value < 1 then
    	value = 1;
    end

    return math.floor(value);
end

function SCR_Get_DEFAULT_MAXPATK_SUB(self)
    local defaultValue = 20;
    
    local lv = TryGetProp(self, "Lv");
    if lv == nil then
        lv = 1;
    end
    
    local byLevel = lv * 1;
    
    local stat = TryGetProp(self, "STR");
    if stat == nil then
        stat = 1;
    end
    
    local byStat = (stat * 2) + (math.floor(stat / 10) * (byLevel * 0.05));

    local byItem = 0;
    local byItemList = { "MAXATK", "PATK", "ADD_MAXATK" };
    for i = 1, #byItemList do
        local byItemTemp = GetSumOfEquipItem(self, byItemList[i]);
        if byItemTemp == nil then
            byItemTemp = 0;
        end
        byItem = byItem + byItemTemp;
    end

    byItem = byItem + TryGetProp(self, "EQUIP_PATK", 0) + TryGetProp(self, "EQUIP_PATK_SUB", 0);

    -- 20%
    byItem = math.floor(byItem * 0.3)

    local value = defaultValue + byLevel + byStat + byItem;
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_MAXPATK_SUB(self)
    local value = SCR_Get_DEFAULT_MAXPATK_SUB(self)
    
    local byBuff = 0;
    local byBuffList = { "PATK_BM", "MAXPATK_BM", "PATK_SUB_BM", "MAXPATK_SUB_BM" };
    for i = 1, #byBuffList do
        local byBuffTemp = TryGetProp(self, byBuffList[i]);
        if byBuffTemp == nil then
            byBuffTemp = 0;
        end
        
        byBuff = byBuff + byBuffTemp;
    end
    
    local byRateBuff = 0;
    local byRateBuffList = { "PATK_RATE_BM", "MAXPATK_RATE_BM", "PATK_SUB_RATE_BM", "MAXPATK_SUB_RATE_BM" };
    for i = 1, #byRateBuffList do
        local byRateBuffTemp = TryGetProp(self, byRateBuffList[i]);
        if byRateBuffTemp == nil then
            byRateBuffTemp = 0;
        end
        
        byRateBuff = byRateBuff + byRateBuffTemp;
    end
    
    byRateBuff = math.floor(value * byRateBuff);
    
    value = value + byBuff + byRateBuff;

    local decRatio = TryGetProp(self, 'PATK_RATE_MUL_BM', 1);
    if decRatio < 0.5 then
        decRatio = 0.5
    end
    value = math.floor(value * decRatio)
    
    if value < 1 then
    	value = 1;
    end

    return math.floor(value);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_DEFAULT_MINMATK(self)
    local defaultValue = 20;
    
    local lv = TryGetProp(self, "Lv");
    if lv == nil then
        lv = 1;
    end
    
    local byLevel = lv * 1;
    
    local stat = TryGetProp(self, "INT");
    local abilCleric37 = GetAbility(self, 'Cleric37');
    if abilCleric37 ~= nil and TryGetProp(abilCleric37, 'ActiveState', 0) == 1 then
        stat = TryGetProp(self, 'MNA');
    end
    if stat == nil then
        stat = 1;
    end
    
    local byStat = (stat * 2) + (math.floor(stat / 10) * (byLevel * 0.05));
    
    local byItem = 0;
    if tonumber(USE_SUBWEAPON_SLOT) == 1 then
        local rhAtk = 0
        local lhAtk = 0
        local rh_subAtk = 0
        local lh_subAtk = 0

        local rh = GetEquipItemForPropCalc(self, 'RH')
        if rh ~= nil then
            rhAtk = TryGetProp(rh, 'MATK', 0)
        end

        local lh = GetEquipItemForPropCalc(self, 'LH')
        if lh ~= nil and IS_NO_EQUIPITEM(lh) ~= 1 then
            if TryGetProp(lh, "ClassType") == "Trinket" then
                lhAtk = TryGetProp(lh, 'MATK', 0)
            else
                lhAtk = TryGetProp(lh, 'MINATK', 0) * 0.3
            end
            
        end

        byItem = rhAtk + lhAtk
        
        local rh_sub = GetEquipItemForPropCalc(self, 'RH_SUB')
        if rh_sub ~= nil and IS_NO_EQUIPITEM(rh_sub) ~= 1 then
            rh_subAtk = TryGetProp(rh_sub, 'MATK', 0)

            local lh_sub = GetEquipItemForPropCalc(self, 'LH_SUB')
            if lh_sub ~= nil then
                if TryGetProp(lh_sub, "ClassType") == "Trinket" then
                    lh_subAtk = TryGetProp(lh_sub, 'MATK', 0)
                else
                    lh_subAtk = TryGetProp(lh_sub, 'MINATK', 0) * 0.3
                end
            end

            local bySubItem = rh_subAtk + lh_subAtk
            byItem = byItem * 0.5 + bySubItem * 0.5
        end

        byItem = math.floor(byItem)
    end
    
    local byItemList = { "MATK", "ADD_MATK", "ADD_MINATK" };
    for i = 1, #byItemList do
        local byItemTemp = GetSumOfEquipItem(self, byItemList[i]);
        if byItemTemp == nil then
            byItemTemp = 0;
        end
        byItem = byItem + byItemTemp;
    end

    local ori_rhAtk = TryGetProp(GetEquipItemForPropCalc(self, 'RH'), 'MATK', 0)
    local ori_lhAtk = TryGetProp(GetEquipItemForPropCalc(self, 'LH'), 'MATK', 0)
    local ori_trinketAtk = TryGetProp(GetEquipItemForPropCalc(self, 'TRINKET'), 'MATK', 0)
    local ori_rh_subAtk = TryGetProp(GetEquipItemForPropCalc(self, 'RH_SUB'), 'MATK', 0)
    local ori_lh_subAtk = TryGetProp(GetEquipItemForPropCalc(self, 'LH_SUB'), 'MATK', 0)

    byItem = byItem - (ori_rhAtk + ori_lhAtk + ori_trinketAtk + ori_rh_subAtk + ori_lh_subAtk)

    byItem = byItem + TryGetProp(self, "EQUIP_MATK", 0);

    local value = defaultValue + byLevel + byStat + byItem;

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_MINMATK(self)
    local value = SCR_Get_DEFAULT_MINMATK(self)
    
    local byBuff = 0;
    local byBuffList = { "MATK_BM", "MINMATK_BM" };
    for i = 1, #byBuffList do
        local byBuffTemp = TryGetProp(self, byBuffList[i]);
        if byBuffTemp == nil then
            byBuffTemp = 0;
        end
        
        byBuff = byBuff + byBuffTemp;
    end
    
    local byRateBuff = 0;
    local byRateBuffList = { "MATK_RATE_BM", "MINMATK_RATE_BM" };
    for i = 1, #byRateBuffList do
        local byRateBuffTemp = TryGetProp(self, byRateBuffList[i]);
        if byRateBuffTemp == nil then
            byRateBuffTemp = 0;
        end
        
        byRateBuff = byRateBuff + byRateBuffTemp;
    end
    
    byRateBuff = math.floor(value * byRateBuff);
    
    value = value + byBuff + byRateBuff;

    local decRatio = TryGetProp(self, 'MATK_RATE_MUL_BM', 1);
    if decRatio < 0.5 then
        decRatio = 0.5
    end
    value = math.floor(value * decRatio)
    
    local maxMATK = TryGetProp(self, "MAXMATK");
    if value > maxMATK then
        value = maxMATK;
    end
    
    if value < 1 then
    	value = 1;
    end
    
    local equip_list = { 'RH', 'LH', 'RH_SUB', 'LH_SUB' }
    local evolve_value = 0
    for k, v in pairs(equip_list) do
        local item = GetEquipItemForPropCalc(self, v)
        if item ~= nil then
            evolve_value = evolve_value + GET_EVOLVED_ATK(item)
        end
    end

    return math.floor(value) + evolve_value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_DEFAULT_MAXMATK(self)
    local defaultValue = 20;
    
    local lv = TryGetProp(self, "Lv");
    if lv == nil then
        lv = 1;
    end
    
    local byLevel = lv * 1;
    
    local stat = TryGetProp(self, "INT");
    local abilCleric37 = GetAbility(self, 'Cleric37');
    if abilCleric37 ~= nil and TryGetProp(abilCleric37, 'ActiveState', 0) == 1 then
        stat = TryGetProp(self, 'MNA');
    end
    if stat == nil then
        stat = 1;
    end
    
    local byStat = (stat * 2) + (math.floor(stat / 10) * (byLevel * 0.05));

    local byItem = 0;
    if tonumber(USE_SUBWEAPON_SLOT) == 1 then
        local rhAtk = 0
        local lhAtk = 0
        local rh_subAtk = 0
        local lh_subAtk = 0

        local rh = GetEquipItemForPropCalc(self, 'RH')
        if rh ~= nil then
            rhAtk = TryGetProp(rh, 'MATK', 0)
        end

        local lh = GetEquipItemForPropCalc(self, 'LH')
        if lh ~= nil and IS_NO_EQUIPITEM(lh) ~= 1 then
            if TryGetProp(lh, "ClassType") == "Trinket" then
                lhAtk = TryGetProp(lh, 'MATK', 0)
            else
                lhAtk = TryGetProp(lh, 'MAXATK', 0) * 0.3
            end            
        end

        byItem = rhAtk + lhAtk

        local rh_sub = GetEquipItemForPropCalc(self, 'RH_SUB')
        if rh_sub ~= nil and IS_NO_EQUIPITEM(rh_sub) ~= 1 then
            rh_subAtk = TryGetProp(rh_sub, 'MATK', 0)

            local lh_sub = GetEquipItemForPropCalc(self, 'LH_SUB')
            if lh_sub ~= nil then
                if TryGetProp(lh_sub, "ClassType") == "Trinket" then
                    lh_subAtk = TryGetProp(lh_sub, 'MATK', 0)
                else
                    lh_subAtk = TryGetProp(lh_sub, 'MAXATK', 0) * 0.3
                end
            end

            local bySubItem = rh_subAtk + lh_subAtk
            byItem = byItem * 0.5 + bySubItem * 0.5
        end

        byItem = math.floor(byItem)
    end
    
    local byItemList = { "MATK", "ADD_MATK", "ADD_MAXATK" };
    for i = 1, #byItemList do
        local byItemTemp = GetSumOfEquipItem(self, byItemList[i]);
        if byItemTemp == nil then
            byItemTemp = 0;
        end
        byItem = byItem + byItemTemp;
    end

    local ori_rhAtk = TryGetProp(GetEquipItemForPropCalc(self, 'RH'), 'MATK', 0)
    local ori_lhAtk = TryGetProp(GetEquipItemForPropCalc(self, 'LH'), 'MATK', 0)
    local ori_trinketAtk = TryGetProp(GetEquipItemForPropCalc(self, 'TRINKET'), 'MATK', 0)
    local ori_rh_subAtk = TryGetProp(GetEquipItemForPropCalc(self, 'RH_SUB'), 'MATK', 0)
    local ori_lh_subAtk = TryGetProp(GetEquipItemForPropCalc(self, 'LH_SUB'), 'MATK', 0)

    byItem = byItem - (ori_rhAtk + ori_lhAtk + ori_trinketAtk + ori_rh_subAtk + ori_lh_subAtk)

    byItem = byItem + TryGetProp(self, "EQUIP_MATK", 0);

    local value = defaultValue + byLevel + byStat + byItem;
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_MAXMATK(self)
    local value = SCR_Get_DEFAULT_MAXMATK(self)
    
    local throwItemMaxMAtk = 0;
    local rightHand = GetEquipItemForPropCalc(self, 'RH');
    if IsBuffApplied(self, 'Warrior_RH_VisibleObject') == 'YES' and rightHand ~= nil then
        throwItemMaxMAtk = rightHand.MATK;
    end

    if IsServerSection(self) == 1 then
        REFRESH_ITEM(self, rightHand);
    end
    
    value = value - throwItemMaxMAtk;
    
    local byBuff = 0;
    local byBuffList = { "MATK_BM", "MAXMATK_BM" };
    for i = 1, #byBuffList do
        local byBuffTemp = TryGetProp(self, byBuffList[i]);
        if byBuffTemp == nil then
            byBuffTemp = 0;
        end
        
        byBuff = byBuff + byBuffTemp;
    end
    
    local byRateBuff = 0;
    local byRateBuffList = { "MATK_RATE_BM", "MAXMATK_RATE_BM" };
    for i = 1, #byRateBuffList do
        local byRateBuffTemp = TryGetProp(self, byRateBuffList[i]);
        if byRateBuffTemp == nil then
            byRateBuffTemp = 0;
        end
        
        byRateBuff = byRateBuff + byRateBuffTemp;
    end
    
    byRateBuff = math.floor(value * byRateBuff);
    
    value = value + byBuff + byRateBuff;

    local decRatio = TryGetProp(self, 'MATK_RATE_MUL_BM', 1);
    if decRatio < 0.5 then
        decRatio = 0.5
    end
    value = math.floor(value * decRatio)
    
    if value < 1 then
    	value = 1;
    end

    local equip_list = { 'RH', 'LH', 'RH_SUB', 'LH_SUB' }
    local evolve_value = 0
    for k, v in pairs(equip_list) do
        local item = GetEquipItemForPropCalc(self, v)
        if item ~= nil then
            evolve_value = evolve_value + GET_EVOLVED_ATK(item)
        end
    end

    return math.floor(value) + evolve_value;
end

function SCR_Get_DEF(self)
    local value = SCR_CALC_BASIC_DEF(self);
    
    local byBuff = TryGetProp(self, "DEF_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local byRateBuff = TryGetProp(self, "DEF_RATE_BM");
    if byRateBuff == nil then
        byRateBuff = 0;
    end
    
    byRateBuff = math.floor(value * byRateBuff);
    
    value = value + byBuff + byRateBuff;

    local decRatio = TryGetProp(self, 'DEF_RATE_MUL_BM', 1);
    if decRatio < 0.5 then
        decRatio = 0.5
    end
    value = math.floor(value * decRatio)
    
    local throwItemDef = 0;
    local leftHand = GetEquipItemForPropCalc(self, 'LH');
    if IsBuffApplied(self, 'Warrior_LH_VisibleObject') == 'YES' and leftHand ~= nil then
        throwItemDef = leftHand.DEF;
    end

    if IsServerSection(self) == 1 then
        REFRESH_ITEM(self, leftHand);
    end
    
    value = value - throwItemDef;

    local card_crystalgolem_pdef_rate = GetExProp(self, "card_crystalgolem_pdef_rate");
    if card_crystalgolem_pdef_rate > 0 then
        local rate = card_crystalgolem_pdef_rate * 0.08;
        local add_value = math.floor(value * rate);
        value = value + add_value;
    end
    
    if value < 0 then
        value = 0;
    end
    
    return math.floor(value);
end

function SCR_CALC_BASIC_DEF(self)
    local defaultValue = 20;
    
    local lv = TryGetProp(self, "Lv");
    if lv == nil then
        lv = 1;
    end
    
    local byLevel = lv * 1.0;
    
    local stat = TryGetProp(self, "CON");
    if stat == nil then
        stat = 1;
    end
    
    local byStat = (stat * 2) + (math.floor(stat / 10) * (byLevel * 0.05));
    
    local byItem = 0;
    if tonumber(USE_SUBWEAPON_SLOT) == 1 then
        if GetExProp(self, "IS_SHIELDSTRIKE_ABIL") == 0 then
            local lhItem = GetEquipItemForPropCalc(self, "LH")
            if lhItem ~= nil then
                byItem = TryGetProp(lhItem, "DEF", 0)
            end

            local rh_sub = GetEquipItemForPropCalc(self, "RH_SUB")
            local lh_sub = GetEquipItemForPropCalc(self, "LH_SUB")
            if IS_NO_EQUIPITEM(rh_sub) ~= 1 or IS_NO_EQUIPITEM(lh_sub) ~= 1 then
                local lhDef = TryGetProp(lhItem, "DEF", 0)
                local subDef = TryGetProp(lh_sub, "DEF", 0)
                byItem = math.floor((lhDef + subDef) / 2)
            end
        end
    end
    
    local byItemList = { "DEF", "ADD_DEF" };
    for i = 1, #byItemList do
        local byItemTemp = GetSumOfEquipItem(self, byItemList[i]);
        if byItemTemp == nil then
            byItemTemp = 0;
        end
        
        byItem = byItem + byItemTemp;
    end
    
    local ori_lhAtk = TryGetProp(GetEquipItemForPropCalc(self, 'LH'), 'DEF', 0)
    local ori_lh_subAtk = TryGetProp(GetEquipItemForPropCalc(self, 'LH_SUB'), 'DEF', 0)
    byItem  = byItem  - (ori_lhAtk + ori_lh_subAtk)

    local byBonus = TryGetProp(self, "MAXDEF_Bonus");
    if byBonus == nil then
        byBonus = 0;
    end
    
    local jobRate = SCR_GET_JOB_RATIO_STAT(self, "DEF");
    
    local value = defaultValue + ((byLevel + byStat) * jobRate) + byItem + byBonus;
    
    return value;
end

function SCR_Get_MDEF(self)
    local value = SCR_CALC_BASIC_MDEF(self);
    
    local byEnchant = 0;
    local enchantCount = CountEnchantItemEquip(self, 'ENCHANTARMOR_PROTECTIVE');
    if enchantCount > 0 then
        byEnchant = math.floor(value * (enchantCount * 0.05));
    end
    
    local byBuff = TryGetProp(self, "MDEF_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local byRateBuff = TryGetProp(self, "MDEF_RATE_BM");
    if byRateBuff == nil then
        byRateBuff = 0;
    end
    
    byRateBuff = math.floor(value * byRateBuff);
    
    value = value + byEnchant + byBuff + byRateBuff;

    local decRatio = TryGetProp(self, 'MDEF_RATE_MUL_BM', 1);
    if decRatio < 0.5 then
        decRatio = 0.5
    end
    value = math.floor(value * decRatio)

    local card_crystalgolem_mdef_rate = GetExProp(self, "card_crystalgolem_mdef_rate");
    if card_crystalgolem_mdef_rate > 0 then
        local rate = card_crystalgolem_mdef_rate * 0.08;
        local add_value = math.floor(value * rate);
        value = value + add_value;
    end
    
    return math.floor(value);
end

function SCR_CALC_BASIC_MDEF(self)
    local defaultValue = 20;
    
    local lv = TryGetProp(self, "Lv");
    if lv == nil then
        lv = 1;
    end
    
    local byLevel = lv * 1.0;
    
    local stat = TryGetProp(self, "CON");
    if stat == nil then
        stat = 1;
    end
    
    local byStat = (stat * 2) + (math.floor(stat / 10) * (byLevel * 0.05));
    
    local byItem = 0;
    if tonumber(USE_SUBWEAPON_SLOT) == 1 then
        if GetExProp(self, "IS_SHIELDSTRIKE_ABIL") == 0 then
            local lhItem = GetEquipItemForPropCalc(self, "LH")
            if lhItem ~= nil then
                byItem = TryGetProp(lhItem, "MDEF", 0)
            end

            local rh_sub = GetEquipItemForPropCalc(self, "RH_SUB")
            local lh_sub = GetEquipItemForPropCalc(self, "LH_SUB")
            if IS_NO_EQUIPITEM(rh_sub) ~= 1 or IS_NO_EQUIPITEM(lh_sub) ~= 1 then
                local lhDef = TryGetProp(lhItem, "MDEF", 0)
                local subDef = TryGetProp(lh_sub, "MDEF", 0)
                byItem = math.floor((lhDef + subDef) / 2)
            end
        end
    end
    
    local byItemList = { "MDEF", "ADD_MDEF" };
    for i = 1, #byItemList do
        local byItemTemp = GetSumOfEquipItem(self, byItemList[i]);
        if byItemTemp == nil then
            byItemTemp = 0;
        end
        
        byItem = byItem + byItemTemp;
    end
    
    local ori_lhAtk = TryGetProp(GetEquipItemForPropCalc(self, 'LH'), 'MDEF', 0)
    local ori_lh_subAtk = TryGetProp(GetEquipItemForPropCalc(self, 'LH_SUB'), 'MDEF', 0)
    byItem  = byItem  - (ori_lhAtk + ori_lh_subAtk)
    
    local jobRate = SCR_GET_JOB_RATIO_STAT(self, "MDEF");
    
    local value = defaultValue + ((byLevel + byStat) * jobRate) + byItem;
    
    return value;
end

function SCR_Get_BLKABLE(self)

    local value = 0

    local equipLH = GetEquipItem(self, 'LH');
    if TryGetProp(equipLH, 'ClassType') == 'Shield' then
        value = 2
    end

    local equipRH_SUB = GetEquipItem(self, 'RH_SUB');
    local equipLH_SUB = GetEquipItem(self, 'LH_SUB');
    if IS_NO_EQUIPITEM(equipRH_SUB) ~= 1 or IS_NO_EQUIPITEM(equipLH_SUB) ~= 1 then
        value = value / 2

        if TryGetProp(equipLH_SUB, 'ClassType') == 'Shield' then
            value = value + 1
        end
    end

    local enableBlockBuff = TryGetProp(self, "BLKABLE_BM", 0);
    if enableBlockBuff >= 1 then
        value = value + enableBlockBuff
    end

    if value > 2 then
        value = 2
    end

    if value < 0 then
        value = 0
    end

    return value;
end

function SCR_Get_BLK(self)
    local enableBlock = TryGetProp(self, "BLKABLE");
    if enableBlock == nil or enableBlock == 0 then
        return 0;
    end
    
    local lv = TryGetProp(self, "Lv");
    if lv == nil then
        lv = 1;
    end
    
    local jobRate = SCR_GET_JOB_RATIO_STAT(self, "BLK");
    local byLevel = lv * 1.0 * jobRate;
    
    local byItem = GetSumOfEquipItem(self, 'BLK');
    if byItem == nil then
        byItem = 0;
    end

    local byBlockRate = GetSumOfEquipItem(self, 'BlockRate');
    if byBlockRate == nil then
        byBlockRate = 0;
    end

    byBlockRate = byLevel * (byBlockRate * 0.01);
    
    local value = byLevel + byItem + byBlockRate;
    
    local byItemRareOption = TryGetProp(self, 'EnchantBlockRate');
    if byItemRareOption == nil then
        byItemRareOption = 0;
    end
    
    byItemRareOption = math.floor(value * (byItemRareOption / 1000));
    
    local byAbil = 0;
    
    local byBuff = TryGetProp(self, "BLK_BM", 0);
    
    local byRateBuff = TryGetProp(self, "BLK_RATE_BM", 0);
    byRateBuff = math.floor(value * byRateBuff);
    
    value = value + byItemRareOption + byAbil + byBuff + byRateBuff;
    
    if value < 0 then
        value = 0;
    end
    
    return math.floor(value);
end

function SCR_Get_BLK_BREAK(self)
    local lv = TryGetProp(self, "Lv");
    if lv == nil then
        lv = 1;
    end
    
    local jobRate = SCR_GET_JOB_RATIO_STAT(self, "BLK_BREAK");
    local byLevel = lv * 1.0 * jobRate;
    
    local byItem = GetSumOfEquipItem(self, 'BLK_BREAK');
    if byItem == nil then
        byItem = 0;
    end
    
    local value = byLevel + byItem;
    
    local byItemRareOption = TryGetProp(self, 'EnchantBlockBreakRate');
    if byItemRareOption == nil then
        byItemRareOption = 0;
    end
    
    byItemRareOption = math.floor(value * (byItemRareOption / 1000));
    
    local byBuff = TryGetProp(self, "BLK_BREAK_BM", 0);
    
    local byRateBuff = TryGetProp(self, "BLK_BREAK_RATE_BM", 0);
    byRateBuff = math.floor(value * byRateBuff);
    
    local byAbil = GetExProp(self, "ABIL_THMACE_BLKBLEAK", 0)
    
    local value = value + byItemRareOption + byBuff + byRateBuff + byAbil;
    
    if value < 0 then
    	value = 0;
    end
    
    return math.floor(value);
end

function SCR_Get_HR(self)
    local lv = TryGetProp(self, "Lv");
    if lv == nil then
        lv = 1;
    end
    
    local jobRate = SCR_GET_JOB_RATIO_STAT(self, "HR");
    local byLevel = lv * 1.0 * jobRate;
    
    local byItem = 0;
    local byItemList = { "HR", "ADD_HR" };
    for i = 1, #byItemList do
        local byItemTemp = GetSumOfEquipItem(self, byItemList[i]);
        if byItemTemp == nil then
            byItemTemp = 0;
        end
        
        byItem = byItem + byItemTemp;
    end
    
    local value = byLevel + byItem;
    
    local byItemRareOption = TryGetProp(self, 'EnchantHitRate');
    if byItemRareOption == nil then
        byItemRareOption = 0;
    end
    
    byItemRareOption = math.floor(value * (byItemRareOption / 1000));
    
    local byBuff = TryGetProp(self, "HR_BM", 0);
    
    local byRateBuff = TryGetProp(self, "HR_RATE_BM", 0);
    byRateBuff = math.floor(value * byRateBuff);
    
    value = value + byItemRareOption + byBuff + byRateBuff;

    if GetExProp(self, "IS_Hakkapeliter1_Abil") == 1 then
        local addhr = math.floor(value * 0.15)
        SetExProp(self, "IS_Hakkapeliter1_Value", addhr) 
        value = value - addhr
    end
    
    if value < 0 then
    	value = 0
    end
    
    return math.floor(value);
end

function SCR_Get_DR(self)
    local lv = TryGetProp(self, "Lv");
    if lv == nil then
        lv = 1;
    end
    
    local jobRate = SCR_GET_JOB_RATIO_STAT(self, "DR");
    local byLevel = lv * 1.0 * jobRate;
        
    local byItem = 0;
    local byItemList = { "DR", "ADD_DR" };
    for i = 1, #byItemList do
        local byItemTemp = GetSumOfEquipItem(self, byItemList[i]);
        if byItemTemp == nil then
            byItemTemp = 0;
        end
        
        byItem = byItem + byItemTemp;
    end
    
    local value = byLevel + byItem;
    
    local byItemRareOption = TryGetProp(self, 'EnchantDodgeRate');
    if byItemRareOption == nil then
        byItemRareOption = 0;
    end
    
    byItemRareOption = math.floor(value * (byItemRareOption / 1000));
    
    local byBuff = TryGetProp(self, "DR_BM", 0);
    
    local byRateBuff = TryGetProp(self, "DR_RATE_BM", 0);
    byRateBuff = math.floor(value * byRateBuff);
    
    value = value + byItemRareOption + byBuff + byRateBuff;
    
    if value < 0 then
    	value = 0;
    end
    
    return math.floor(value);
end

function SCR_Get_MHR(self)
--    local byItem = 0;
--    local byItemList = { "MHR", "ADD_MHR" };
--    for i = 1, #byItemList do
--        local byItemTemp = GetSumOfEquipItem(self, byItemList[i]);
--        if byItemTemp == nil then
--            byItemTemp = 0;
--        end
--        
--        byItem = byItem + byItemTemp;
--    end
--    
--    local byBuff = TryGetProp(self, "MHR_BM");
--    if byBuff == nil then
--        byBuff = 0;
--    end
--    
--    local value = byItem + byBuff;
--    
--    return math.floor(value);
    
    return 0;
end

function SCR_Get_CRTHR(self)
    local lv = TryGetProp(self, "Lv");
    if lv == nil then
        lv = 1;
    end
    
    local jobRate = SCR_GET_JOB_RATIO_STAT(self, "CRTHR");
    local byLevel = lv * 1.0 * jobRate;
    
    local byItem = GetSumOfEquipItem(self, 'CRTHR');
    if byItem == nil then
        byItem = 0;
    end
    
    local value = byLevel + byItem;
    
    local byItemRareOption = TryGetProp(self, 'EnchantCriticalHitRate');
    if byItemRareOption == nil then
        byItemRareOption = 0;
    end
    
    byItemRareOption = math.floor(value * (byItemRareOption / 1000));
    
    local byBuff = TryGetProp(self, "CRTHR_BM", 0);
	
    local byRateBuff = TryGetProp(self, "CRTHR_RATE_BM", 0);
    byRateBuff = math.floor(value * byRateBuff);
    
    value = value + byItemRareOption + byBuff + byRateBuff;
    
    if value < 0 then
    	value = 0;
    end
    
    return math.floor(value);
end

function SCR_Get_CRTDR(self)
    local lv = TryGetProp(self, "Lv");
    if lv == nil then
        lv = 1;
    end
    
    local jobRate = SCR_GET_JOB_RATIO_STAT(self, "CRTDR");
    local byLevel = lv * 1.0 * jobRate;
    
    local byItem = GetSumOfEquipItem(self, 'CRTDR');
    if byItem == nil then
        byItem = 0;
    end
    
    local value = byLevel + byItem;
    
    local byItemRareOption = TryGetProp(self, 'EnchantCriticalDodgeRate');
    if byItemRareOption == nil then
        byItemRareOption = 0;
    end
    
    byItemRareOption = math.floor(value * (byItemRareOption / 1000));
    
    local byBuff = TryGetProp(self, "CRTDR_BM", 0);
    
    local byRateBuff = TryGetProp(self, "CRTDR_RATE_BM", 0);
    byRateBuff = math.floor(value * byRateBuff);
    
    value = value + byItemRareOption + byBuff + byRateBuff;

    local decRatio = TryGetProp(self, 'CRTDR_RATE_MUL_BM', 1);
    if decRatio < 0.5 then
        decRatio = 0.5
    end
    value = math.floor(value * decRatio)
	
    if value < 0 then
    	value = 0;
    end
	
    return math.floor(value);
end

function SCR_Get_CRTATK(self)
    local lv = TryGetProp(self, "Lv");
    if lv == nil then
        lv = 1;
    end
    
    local byLevel = lv * 1.0;
	
    local stat = TryGetProp(self, "DEX");
    if stat == nil then
        stat = 1;
    end
    
    local byStat = (stat * 2) + (math.floor(stat / 10) * (byLevel * 0.05));
    
    local byItem = GetSumOfEquipItem(self, "CRTATK");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(self, "CRTATK_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byLevel + byStat + byItem + byBuff;
    
    return math.floor(value);
end

function SCR_Get_CRTMATK(self)
    local lv = TryGetProp(self, "Lv");
    if lv == nil then
        lv = 1;
    end
    
    local byLevel = lv * 1.0;
	
    local stat = TryGetProp(self, "MNA");
    local abilCleric37 = GetAbility(self, 'Cleric37');
    if abilCleric37 ~= nil and TryGetProp(abilCleric37, 'ActiveState', 0) == 1 then
        stat = TryGetProp(self, 'INT');
    end
    if stat == nil then
        stat = 1;
    end
    
    local byStat = (stat * 2) + (math.floor(stat / 10) * (byLevel * 0.05));
    
    local byItem = GetSumOfEquipItem(self, "CRTMATK");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(self, "CRTMATK_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byLevel + byStat + byItem + byBuff;
    
    return math.floor(value);
end

function SCR_Get_CRTDEF(self)
    return 0;
end

function SCR_Get_RHP(self)
    local buffKeywordList = { "Curse", "UnrecoverableHP" };
    for i = 1, #buffKeywordList do
        if GetBuffByProp(self, 'Keyword', buffKeywordList[i]) ~= nil then
            return 0;
        end
    end

    local baseMHP = TryGetProp(self, 'MHP', 1);
    
	local jobRate = SCR_GET_JOB_RATIO_STAT(self, "RHP");
	
	local defaultValue = math.floor(baseMHP * 0.01 * jobRate);
    
    local byItem = GetSumOfEquipItem(self, 'RHP');
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(self, "RHP_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = defaultValue + byItem + byBuff;

    if IsPVPServer(self) == 1 then
        value = value / 2
    end
    
    if value < 0 then
        value = 0;
    end
    
    if GetExProp(self, 'force_rhp_zero') > 0 then
        value = 0;
    end
    
    return math.floor(value);
end

function SCR_GET_RHPTIME(self)
    local defaultTime = 20000;
    
    local byItem = GetSumOfEquipItem(self, 'RHPTIME');
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(self, "RHPTIME_BM");
    if byBuff == nil then
        byBuff = 0;
    end

    local squireBuff = GetBuffByName(self, 'squire_food3_buff')
    if squireBuff ~= nil then
        defaultTime = math.floor(defaultTime * (1 - GetExProp(squireBuff, "SQUIRE_FOOD_ADD_RHPTIME")))
    end

    local value = defaultTime - byItem - byBuff;

    if IsBuffApplied(self, 'SitRest') == 'YES' then 
        value = value * 0.5;
    end
    
    if value < 1000 then
        value = 1000;
    end
    
    return math.floor(value);
end

function SCR_Get_RSP(self)
    local buffKeywordList = { "Curse", "Formation", "SpDrain", "UnrecoverableSP", "NoneRecoverableSP" };
    for i = 1, #buffKeywordList do
        if GetBuffByProp(self, 'Keyword', buffKeywordList[i]) ~= nil then
            return 0;
        end
    end
    
--    local jobObj = GetJobObject(self);  -- job
--    if jobObj == nil then
--        return 0;
--    end
	
    local baseMSP = TryGetProp(self, 'MSP', 1);
	
	local jobRate = SCR_GET_JOB_RATIO_STAT(self, "RSP");
	
	local defaultValue = math.floor(baseMSP * 0.03 * jobRate);
    
    local byItem = GetSumOfEquipItem(self, 'RSP');
    if byItem == nil then
        byItem = 0;
    end
    
    local byAbil = 0
    
    -- 1번 인자 : 특성 ClassName --
    -- 2번 인자 : 기반으로 곱연산 할 값(MaxSP, 기본 회복량 등..), nil 인 경우 곱연산이 아닌 3번째 인자값으로 합연산 처리 --
    -- 3번 인자 : 2번 인자를 기반으로 곱연산 할 계수 --
    local abilList = { { "Meditaion", baseMSP, 0.01 } }
    for i = 1, #abilList do
        local AbilTemp = GetAbility(self, abilList[i][1]);
        if AbilTemp ~= nil then
            if abilList[i][2] == nil or abilList[i][2] == "None" then
                byAbil = byAbil + abilList[i][3];
            else
                byAbil = byAbil + (AbilTemp.Level * (abilList[i][2] * abilList[i][3]));
            end
        end
    end
    
    local byBuff = TryGetProp(self, "RSP_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = defaultValue + byItem + byAbil + byBuff
    
    if value < 1 then
        value = 1;
    end
    
    return math.floor(value);
end

function SCR_GET_RSPTIME(self)
    local defaultTime = 20000;
    
    local byItem = GetSumOfEquipItem(self, 'RSPTIME');
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(self, "RSPTIME_BM");
    if byBuff == nil then
        byBuff = 0;
    end

    local servantBuff = GetBuffByName(self, 'ServantSP_Buff')
    if servantBuff ~= nil then
        defaultTime = math.floor(defaultTime * (1 - GetExProp(servantBuff, "ADD_RSPTIME")))
    end

    local squireBuff = GetBuffByName(self, 'squire_food4_buff')
    if squireBuff ~= nil then
        defaultTime = math.floor(defaultTime * (1 - GetExProp(squireBuff, "SQUIRE_FOOD_ADD_RSPTIME")))
    end

    -- 딥디르비 제미나 여신상도 처리 필요
    local zeminaBuff = GetBuffByName(self, 'CarveZemina_Buff')
    if zeminaBuff ~= nil then
        defaultTime = math.floor(defaultTime * (1 - GetExProp(zeminaBuff, "RSPTIME")))
    end

    local value = defaultTime - byItem - byBuff;
    
    if IsBuffApplied(self, 'SitRest') == 'YES' then 
        value = value * 0.5;
    end

    if GetExProp(self, 'reduce_rsp_time') > 0 then
        local rsp = GetExProp(self, 'reduce_rsp_time') * 0.01
        rsp = 1 - rsp
        value = value * rsp
    end

    if value < 1000 then
        value = 1000;
    end
    
    return math.floor(value);
end

function SCR_Get_StunRate(self)
    local byItem = GetSumOfEquipItem(self, "StunRate");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(self, "StunRate_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end


function SCR_Get_Revive(self)
    local byItem = GetSumOfEquipItem(self, 'Revive');
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(self, "Revive_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end
 
function SCR_Get_HitCount(self)
    local byItem = GetSumOfEquipItem(self, "HitCount");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(self, "HitCount_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_Get_BackHit(self) 
    local byItem = GetSumOfEquipItem(self, "BackHit");
    if byItem == nil then
        byItem = 0;
    end
    
    local value = byItem;
    return math.floor(value);
end
 
function SCR_Get_Aries_Bonus(self)
    local attrString = "Aries";
    
    local byItem = GetSumOfEquipItem(self, attrString);
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(self, attrString.."_Bonus_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_Get_Aries_Defence(self)
    local attrString = "Aries";
    
    local byItem = GetSumOfEquipItem(self, attrString.."DEF");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(self, "Def"..attrString.."_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return math.floor(value);
end

function SCR_Get_Slash_Bonus(self)
    local attrString = "Slash";
    
    local byItem = GetSumOfEquipItem(self, attrString);
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(self, attrString.."_Bonus_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_Get_Slash_Defence(self)
    local attrString = "Slash";
    
    local byItem = GetSumOfEquipItem(self, attrString.."DEF");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(self, "Def"..attrString.."_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return math.floor(value);
end

function SCR_Get_Strike_Bonus(self)
    local attrString = "Strike";
    
    local byItem = GetSumOfEquipItem(self, attrString);
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(self, attrString.."_Bonus_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_Get_Strike_Defence(self)
    local attrString = "Strike";
    
    local byItem = GetSumOfEquipItem(self, attrString.."DEF");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(self, "Def"..attrString.."_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return math.floor(value);
end

function SCR_Get_TR(self)
    local defaultValue = 50;
    
    local byBuff = TryGetProp(self, "TR_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = defaultValue + byBuff;
    
    return math.floor(value);
end

function SCR_Get_KDArmorType(self)
    local jobObj = GetJobObject(self);
    if jobObj == nil then
        return 0;
    end
    
    local value = 0;
    
    if jobObj.CtrlType == 'Warrior' then 
        value = 1;
    elseif jobObj.CtrlType == 'Wizard' then 
        value = 0;
    elseif jobObj.CtrlType == 'Archer' then 
        value = 0;
    elseif jobObj.CtrlType == 'Cleric' then 
        value = 1;
    end
    
    local buffList = { "Safe", "PainBarrier_Buff", "Lycanthropy_Buff", "Marschierendeslied_Buff", "Methadone_Buff", "Fluting_Buff", "Slithering_Buff", "Algiz_PainBarrier_Buff", "BullyPainBarrier_Buff", "CavalryCharge_Abil_Buff", "TOSHero_PainBarrier" };
    for i = 1, #buffList do
        if IsBuffApplied(self, buffList[i]) == 'YES' then
            value = 99999;
            break;
        end
    end
    
    -- colony buff --
    if IsBuffApplied(self, "GuildColony_BossMonsterBuff_DEF") == 'YES' then
        value = 99999;
    end
	
    return value;
end

function SCR_Get_CastingSpeed(self)
	local value = 100;
	
	if IsServerSection(self) == 1 then
	    local castingSpeedBuffList = GetCastingSpeedBuffInfoTable(self)
	    if castingSpeedBuffList ~= nil then
	        for k, v in pairs(castingSpeedBuffList) do
	            if castingSpeedBuffList[k] > 0 then
	                value = value - (value * (castingSpeedBuffList[k] / 100));
	            end
	        end
	    end
	end
	
    local byBuff = TryGetProp(self, "CastingSpeed_BM", 0);
	value = value - byBuff;
    
    if value < 10 then
        value = 10;
    end
    
    if value > 200 then
        value = 200;
    end
	
    return math.floor(value);
end

function SCR_Get_NormalAttackSpeed(self)
	local value = 0;
	
    local byBuff = 0;
    local buffList = { "ASPD_BM", "NormalASPD_BM" };
    for i = 1, #buffList do
    	local propName = buffList[i];
		byBuff = byBuff + TryGetProp(self, propName, 0);
	end
	
    value = value + byBuff;
    
    return math.floor(value);
end

function SCR_Get_SkillAttackSpeed(self)
	local value = 0;
	
    local byBuff = 0;
    local buffList = { "ASPD_BM", "SkillASPD_BM" };
    for i = 1, #buffList do
    	local propName = buffList[i];
		byBuff = byBuff + TryGetProp(self, propName, 0);
	end
	
    value = value + byBuff;
    
    return math.floor(value);
end

function SCR_Get_MSPD(self)
    local fixMSPDBuff = TryGetProp(self, "FIXMSPD_BM");
    if fixMSPDBuff ~= nil and fixMSPDBuff ~= 0 then
        return fixMSPDBuff;
    end
    
    if IsBuffApplied(self, 'PunjiStake_Debuff') == 'YES' then
        return 10;
    end
    
    if IsBuffApplied(self, 'HideShot_Buff') == 'YES' then
        return 25;
    end
    
    if IsBuffApplied(self, 'MissileHole_MSPD_Buff') == 'YES' then
    	return 60;
    end
    
    local jobRate = SCR_GET_JOB_RATIO_STAT(self, "MOVE_SPEED");
    local value = 35.0 * jobRate;
    
    if self.ClassName == 'PC' then
        local byItem = GetSumOfEquipItem(self, 'MSPD');
        if byItem == nil then
            byItem = 0;
        end
        
		local byItemRareOption = TryGetProp(self, 'EnchantMSPD');
		if byItemRareOption == nil then
		    byItemRareOption = 0;
		end
        
        value = value + byItem + byItemRareOption;
        
        local byBuff = TryGetProp(self, "MSPD_BM");
        if byBuff == nil then
            byBuff = 0;
        end
        
        if IsPVPServer(self) == 1 or IsPVPField(self) == 1 then
            byBuff = byBuff * 0.5

            local addmspd = 0
            if IsBuffApplied(self, 'Limacon_Buff') == 'YES' or IsBuffApplied(self, 'RunningShot_Buff') == 'YES' then
                local lhItem = GetEquipItem(self, "LH")
                local lh_subItem = GetEquipItem(self, "LH_SUB")
        
                if TryGetProp(lhItem, "ClassType", "None") == "Shield" then
                    addmspd = addmspd - 2
                end
        
                if TryGetProp(lh_subItem, "ClassType", "None") == "Shield" then
                    addmspd = addmspd - 2
                end
            end

            if IsBuffApplied(self, 'Schwarzereiter_MaxR_Buff') == 'YES' then
                addmspd = addmspd - 2
            end

            byBuff = byBuff + addmspd
        end

        local byBuffOnlyTopValue = 0;
        if IsServerSection(self) == 1 then
            local byBuffOnlyTopList = GetMSPDBuffInfoTable(self)
            if byBuffOnlyTopList ~= nil then
                for k, v in pairs(byBuffOnlyTopList) do
                    if byBuffOnlyTopValue < byBuffOnlyTopList[k] then
                        byBuffOnlyTopValue = byBuffOnlyTopList[k];
                    end
                end
            end
        end

		value = value + byBuff + byBuffOnlyTopValue;
        
        local nowWeight = 0;
        local maxWeight = 0;
        if IsServerSection(self) == 1 then
            nowWeight = TryGetProp(self, "NowWeight");
            if nowWeight == nil then
                nowWeight = 0;
            end
            
            maxWeight = TryGetProp(self, "MaxWeight");
            if maxWeight == nil then
                maxWeight = 8000;
            end
            
            local mapCls = GetMapProperty(self);
            if (mapCls == nil or 'City' ~= mapCls.MapType) and nowWeight >= maxWeight then
                value = value / 3;
            end
        else
            local pc = GetMyPCObject();

            nowWeight = TryGetProp(pc, "NowWeight");
            if nowWeight == nil then
                nowWeight = 0;
            end
            
            maxWeight = TryGetProp(pc, "MaxWeight");
            if maxWeight == nil then
                maxWeight = 8000;
            end

            local mymapname = session.GetMapName();
            local map = GetClass("Map", mymapname);
            if (map == nil or map.isVillage ~= "YES") and nowWeight >= maxWeight then
                value = value / 3;
            end
        end
    end
    
    local isDashRun = TryGetProp(self, "DashRun");
    if isDashRun == nil then
        isDashRun = 0;
    end
    
    local jobObj = GetJobObject(self);
    local jobCtrlType = TryGetProp(jobObj, 'CtrlType')
--    if jobCtrlType == "Archer" then
--    	if IsBattleState(self) == 1 and IsBuffApplied(self, "Tracking_Buff") == "NO" then
--    		isDashRun = 0
--    	end
--    end
    
    if IsBuffApplied(self, 'Slithering_Buff') == 'YES' then
        isDashRun = 0
     	return value;
    end
    
    if IsBuffApplied(self, 'Taglio_Buff') == 'YES' then
        isDashRun = 0
        --return value;
    end
    
    if IsBuffApplied(self, 'ITEM_LEGEND_SVIRTI_BUFF') == 'YES' then
        isDashRun = 0
    end
    
    if isDashRun > 0 then    -- 대시 런 --
        local dashRunAddValue = 10
        
	    -- if jobCtrlType == "Wizard" then
	    -- 	dashRunAddValue = dashRunAddValue - 4
	    -- end
	    
--	    if jobCtrlType == "Archer" then
--	    	if IsBattleState(self) == 0 or IsBuffApplied(self, "Tracking_Buff") == "YES" then
--	    		dashRunAddValue = dashRunAddValue + 3
--	    	else
--	    		isDashRun = 0
--	    	end
--	    end
        
	    if jobCtrlType == "Scout" then
	    	dashRunAddValue = dashRunAddValue + 3
	    end
	    
        if IsBuffApplied(self, 'ITEM_TRINKET_MASINIOS') == 'YES' then
            dashRunAddValue = dashRunAddValue + 2
        end
	
		if IsBuffApplied(self, 'premium_seal_2021_buff') == 'YES' and TryGetProp(self, "Lv", 1) < 460 then
			dashRunAddValue = dashRunAddValue + 6
		end

        local cardDash = GetExProp(self, 'CARD_DASH_SPEED_UP')

        if cardDash > 0 then
            dashRunAddValue = dashRunAddValue + cardDash
        end
                    
        value = value + dashRunAddValue;
        if isDashRun == 2 then  -- 인보 특성이 있으면 속도 +1 --
            value = value + 1;
        end
        
        local RidingDashAbil = GetAbility(self, "Hackapell6")
        if isDashRun == 3 and RidingDashAbil ~= nil then
            value = value + 3;  -- 탑승 대쉬 특성이 있으면 속도 +3 --
        end

		if IS_TOS_HERO_ZONE(self) == 'YES' and GetExProp(self, 'TOSHero_Tear2_MoveSPD') > 0 then
			value = value + 5
		end
    end
    
    -- 최대 이속 제한 --
    if value > PC_MAX_MSPD and GetExProp(self, 'ignore_max_mspd') == 0 then
        value = PC_MAX_MSPD;
        if GetExProp(self, 'RIDE_PET_MSPD_LIMIT_INCREASE') > 0 then
            value = value + GetExProp(self, 'RIDE_PET_MSPD_LIMIT_INCREASE')
        end

        if GetExProp(self, 'COMMON_MSPD_LIMIT_INCREASE') > 0 then
            value = value + GetExProp(self, 'COMMON_MSPD_LIMIT_INCREASE')
        end
    end
    
    local byBonus = TryGetProp(self, "MSPD_Bonus");
    if byBonus == nil then
        byBonus = 0;
    end
    
    value = value + byBonus;
	
    value = value * SERV_MSPD_FIX;
    
    if value < 10 then
    	value = 10
    end
    
    if GetExProp(self, "IS_OOBE_DUMMYPC") == 1 then
        value = 55;
    end

    if IsBuffApplied(self, 'SnipersSerenity_Buff') == 'YES' and (IsPVPField(self) == 1 or IsPVPServer(self) == 1) then
        if IsBuffApplied(self, 'DesperateDefense_Buff') == 'YES' then
            return math.floor(value);
        else
            if GetExProp(self, 'SniperSPD') > 0 and value >= GetExProp(self, 'SniperSPD') then
                return GetExProp(self, 'SniperSPD')
            end
        end
    end
    
    if IsBuffApplied(self, 'Burrow_Rogue') == 'YES' then
        if GetExProp(self, 'BurrowSPD') > 0 and value >= GetExProp(self, 'BurrowSPD') then
            return GetExProp(self, 'BurrowSPD')
        end
    end

    if IsBuffApplied(self, 'Bazooka_Abill_Buff') == 'YES' then
        if GetExProp(self, 'BazookaSPD') > 0 and value >= GetExProp(self, 'BazookaSPD') then
            return GetExProp(self, 'BazookaSPD')
        end
    end

    return math.floor(value);
end

function SCR_Get_MinR(self)
    return 0;
end

function SCR_Get_MaxR(self)
    local value = 5;
    local stance = GetCurrentStance(self);
    if stance ~= nil then
        if stance.ClassType == 'Force' then
--            value = 300;
            return;
        end
    end
    
    local rweapon = GetEquipItemForPropCalc(self, 'RH');
    if rweapon ~= nil then
        value = rweapon.MaxR;
    end
    
    return math.floor(value);
end

function SCR_Get_MaxRFwd(self)
    local value = TryGetProp(self, "MaxR")
    if value == nil then
        value = 0;
    end
    
    local stance = GetCurrentStance(self);
    if stance ~= nil then
        if stance.ClassType == 'Magic' then
            return value;
        end
    end
    
    value = value + 15;
    return math.floor(value);
end

function SCR_Get_SR(self)
    local defaultSR = 3;
    
    local jobObj = GetJobObject(self);
    if jobObj ~= nil then
        if jobObj.CtrlType == 'Warrior' then
            defaultSR = 4;
        end
        
        if jobObj.CtrlType == 'Archer' then
            defaultSR = 0;
        end
    end
    
    local byItem = GetSumOfEquipItem(self, "SR");
    if byItem == nil then
        byItem = 0;
    end
    
	local byItemRareOption = TryGetProp(self, 'EnchantSR');
	if byItemRareOption == nil then
	    byItemRareOption = 0;
    end
    
    if IsPVPServer(self) == 1 then
        byItem = 0;
        byItemRareOption = 0;
    end
    
    local byBuff = TryGetProp(self, "SR_BM")
    if byBuff == nil then
        byBuff = 0;
    end
    
    local byAbil = 0;
    local abilPropList = { 'ABIL_THSWORD_SR', 'ABIL_THSTAFF_SR', 'ABIL_THMACE_SR' };
    for i = 1, #abilPropList do
        local abilProp = GetExProp(self, abilPropList[i])
        if abilProp == nil then
            abilProp = 0
        end
        
        byAbil = byAbil + abilProp;
    end
    
    local value = defaultSR + byItem + byItemRareOption + byBuff + byAbil;
    
    return math.floor(value);
end


function SCR_Get_SDR(self)
	local fixedSDR = TryGetProp(self, 'FixedMinSDR_BM');
	if fixedSDR ~= nil and fixedSDR ~= 0 then
		return 1;
	end
	
    local defaultSDR = 1;
    
    local byItem = GetSumOfEquipItem(self, "SDR");
    if byItem == nil then
        byItem = 0;
    end

    local byBuff = TryGetProp(self, "SDR_BM")
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = defaultSDR + byItem + byBuff;
    
    if value < 1 then
    	value = 1;
    end
    
    if IsPVPServer(self) == 1 then
        value = 2 + byBuff;
    elseif IsPVPField(self) == 1 and value > 4 then
        value = math.floor((math.max(0, value-4)^0.5))+math.min(4, value)
    end

    return math.floor(value);
end

function SCR_Get_ForceVel(self)
    return 100;
end

-- KnockDown power
function SCR_GET_KDPOWER(self)
    local byBuff = TryGetProp(self, "KDPow_BM")
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byBuff;
    
    return math.floor(value);
end

function SCR_Get_MGP(self)
    local defaultMGP = 500;
    
    local byBuff = TryGetProp(self, "MGP_BM")
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = defaultMGP + byBuff;
    
    return math.floor(value);
end

function SCR_Get_CAST(self)
    return 1;
end

function SCR_Get_BOOST(self)
    return 1;
end

function SCR_Get_JUMP(self)
    return 350;
end

-- 지금은 안 쓰이는 함수 --
function SCR_Get_AddSplCount(self)
    local byLevel = TryGetProp(self, "Lv");
    if byLevel == nil then
        byLevel = 1;
    end
    
    local byBuff = TryGetProp(self, "AddSplCount_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byLevel + byBuff;
    
    return math.floor(value);
end
--



function SCR_GET_MOVING_SHOT(pc)
    local PCJob = TryGetProp(pc, "Job");
    if PCJob ~= nil then
        local jobFunc = _G[ "MOVING_SHOT_" .. PCJob ]
        if jobFunc ~= nil then
            return jobFunc(pc);
        end
    end
    
    return 0;
end

function SCR_GET_JUMPING_SHOT(pc)
    local PCJob = TryGetProp(pc, "Job");
    if PCJob ~= nil then
        local jobFunc = _G[ "JUMPING_SHOT_" .. PCJob ]
        if jobFunc ~= nil then
            return jobFunc(pc);
        end
    end
    
    return 1;
end


function SCR_PC_MOVINGSHOTABLE(pc)
    local jobObj = nil
    if IsServerObj(pc) == 1 then
        jobObj = GetJobObject(pc);
    else
        jobObj = GetJobObject();
    end
    
    if jobObj == nil then
        return 0;
    end
    
    if jobObj.CtrlType == 'Archer' then
        return 1;
    end

    local buffList = { "Warrior_EnableMovingShot_Buff", "Warrior_RushMove_Buff", "Cyclone_EnableMovingShot_Buff", 'DoubleGunStance_Buff', 'Limacon_Buff' };
    for i = 1, #buffList do
        if IsBuffApplied(pc, buffList[i]) == "YES" then
            return 1;
        end
    end
    
    return 0;
end

function SCR_MOVING_SHOT_SPEED(pc) -- archer moving shot
    local value = 0;
    local isEnableMovingShot = TryGetProp(pc, "MovingShotable");
    if isEnableMovingShot ~= nil and isEnableMovingShot ~= 0 then
        local jobObj = nil
        if IsServerObj(pc) == 1 then
            jobObj = GetJobObject(pc);
        else
            jobObj = GetJobObject();
        end

        if jobObj ~= nil then
            if jobObj.CtrlType == 'Archer' then 
                value = 0.8;
            end
            
            local byBuff = TryGetProp(pc, "MovingShot_BM");
            if byBuff == nil then
                byBuff = 0;
            end
            
            value = value + byBuff;
        end
    end
    
    if value > 5 then
    	value = 5
    end
    
    return value;
end

function SCR_Get_MaxSta(self)
    local defaultMSTA = 25000;
    
    local byItem = GetSumOfEquipItem(self, 'MSTA');
    if byItem == nil then
        byItem = 0;
    end
    
    byItem = byItem * 1000;
    
    local byBonus = TryGetProp(self, "MAXSTA_Bonus");
    if byBonus == nil then
        byBonus = 0;
    end
    
    byBonus = byBonus * 1000;
    
    local byBuff = TryGetProp(self, "MaxSta_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    byBuff = byBuff * 1000;
    
    
    local rewardProperty = GET_REWARD_PROPERTY(self, "MSTA")
    rewardProperty = rewardProperty * 1000;
    
    local value = defaultMSTA + byItem + byBonus + byBuff + rewardProperty;
    
    return math.floor(value);
end

function SCR_Get_Sta_RunStart(self)
    return 0;
end

function SCR_Get_Sta_Run(self)
    local consumptionSTA = 0;

    -- 기본 스태미너 소모량 --
    local defaultConsumptionSTA = 0;
    
    -- 추가하는 스태미너 소모량 --
    local addRateConsumptionSTA = 0.0;
    
    local byRateBuff = TryGetProp(self, 'MOVESTA_RATE_BM');
    if byRateBuff == nil then
        byRateBuff = 0;
    end
    
    local isDashRun = TryGetProp(self, "DashRun");
    if isDashRun == nil then
        isDashRun = 0;
    end

    if isDashRun == 4 then
        consumptionSTA = 250
    end
    
    local isAgility = GetExProp(self, 'ADD_RCSTA')
    if isAgility == nil then
        isAgility = 0;
    end
    
    local jobObj = GetJobObject(self);
    local jobCtrlType = TryGetProp(jobObj, 'CtrlType')
--    if jobCtrlType == "Archer" then
--    	if IsBattleState(self) == 1 and IsBuffApplied(self, "Tracking_Buff") == "NO" then
--    		isDashRun = 0
--    	end
--    end
    
    if isDashRun > 0 then
        local dashAmount = 500;

        if isDashRun == 4 then
            dashAmount = 0
        end

--	    if jobCtrlType == "Archer" then
--	    	if IsBuffApplied(self, "Tracking_Buff") == "YES" then
--	    	    local level = 0;
--	    	    local buff = GetBuffByName(self, "Tracking_Buff")
--	    	    if buff ~= nil then
--	    	        level = GetBuffArg(buff)
--	    	    end
--	    	    
--	    	    local addRate = 1 + (0.5 - 0.03 * level)
--	    		dashAmount = dashAmount * addRate
--	    	end
--	    end        
        
	    if jobCtrlType == "Cleric" then
			if IsBuffApplied(self, "Lycanthropy_Half_Buff") == "YES" then
				dashAmount = dashAmount * 0.5
			end
		end
        
	    -- if jobCtrlType == "Scout" then 
		-- 	dashAmount = dashAmount * 2
		-- end
        
        consumptionSTA = consumptionSTA + dashAmount;
        
        if isDashRun == 2 then
            addRateConsumptionSTA = addRateConsumptionSTA - 0.25;  -- 인보 특성 있는 중에는 추가량 25% 감소
        end

        local byRateBuffDash = TryGetProp(self, 'DASHSTA_RATE_BM');
        if byRateBuffDash == nil then
            byRateBuffDash = 0;
        end
        
        byRateBuff = byRateBuff + byRateBuffDash;
    end
    
    local value = (250 * consumptionSTA / 100);
    
    addRateConsumptionSTA = addRateConsumptionSTA + byRateBuff
    addRateConsumptionSTA = addRateConsumptionSTA - isAgility
    
    value = value + (value * addRateConsumptionSTA);
    
    -- 이런 버프 늘어나면 구조화 필요
    
    if IsBuffApplied(self, 'Corsair_Roar_Buff') == 'YES' then
        local buff = GetBuffByName(self, "Corsair_Roar_Buff")
        local buffOver = 1 - GetOver(buff) * 0.1
        if buffOver <= 0.5 then
            buffOver = 0.5
        end
        value = value * buffOver
    end
    if IsBuffApplied(self, 'Sprint_Buff') == 'YES' then
        value = 0;
    elseif IsBuffApplied(self, 'Stamina_Max_buff') == 'YES' then
        value = SCR_FIELD_DUNGEON_CONSUME_DECREASE(self, 'Sta_Run', value);
    end
    
	if IS_TOS_HERO_ZONE(self) == 'YES' and GetExProp(self, "TOSHero_NECK_MoveSPD") > 0 then
		value = 0
    end

    if GetExProp(self, 'CHALLENGE_MODE_AUTO_PLAYER') == 1 then
        value = value * 0.5
    end
    
    return math.floor(value);
end

function SCR_Get_Sta_Recover(self)
    if GetBuffByProp(self, 'Keyword', 'Curse') ~= nil then
        return 0;
    end
    
    local defaultRSTA = 400;
    
    local byBuff = 0;
    local byBuffList = { "REST_BM", "RSta_BM" };
    for i = 1, #byBuffList do
        local byBuffTemp = TryGetProp(self, byBuffList[i]);
        if byBuffTemp == nil then
            byBuffTemp = 0;
        end
        
        byBuff = byBuff + byBuffTemp;
    end
    
    local value = defaultRSTA + byBuff;
    
    if IsBuffApplied(self, 'SitRest') == 'YES' then 
        value = value * 2;
    end
    
    return math.floor(value);
end

function SCR_Get_Sta_R_Delay(self)
    return 1000;
end

function SCR_Get_Sta_Runable(self)
    return 0;
end

function SCR_Get_Sta_Jump(self)
    local value = 1000
    if IsBuffApplied(self, "RIDE_PET_RIDEPET_5") == "YES" then
        value = 0
    end

    if IsBuffApplied(self, "RIDE_PET_RIDEPET_11_2") == "YES" then
        value = 0
    end

    return value;
end

function SCR_Get_Sta_Step(self)
    return 2500;
end

function SCR_Get_GuardImpactTime(self)
    local defaultValue = 1500;
    
    local byBuff = TryGetProp(self, "GuardImpactTime_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return defaultValue + byBuff;
end

function SCR_Get_PC_HitCount(pc)
    local RH = GetEquipItemForPropCalc(pc, 'RH');
    
    if RH == nil then
        return 1;
    end
    
    return RH.HitCount;
end

function SCR_GET_PC_SKLPOWER(self)
    local byItem = GetSumOfEquipItem(self, 'SkillPower');
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(self, "SkillPower_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_PC_HPDRAIN(pc)
    local defaultHPDRAIN = 2;
    
    local byADD = TryGetProp(pc, "HPDrain_ADD");
    if byADD == nil then
        byADD = 0;
    end
    
    local value = defaultHPDRAIN + byADD;
    
    return value;
end

function SCR_GET_PC_HPDRAIN_ADD(pc)
    local byBuff = TryGetProp(pc, "HPDrain_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

-- 지금은 안 쓰이는 함수 --
function SCR_GET_PC_PIERCE(pc)
    local byLevel = TryGetProp(pc, "Lv");
    if byLevel == nil then
        byLevel = 1;
    end
    
    local byADD = TryGetProp(pc, "PIE_ADD");
    if byADD == nil then
        byADD = 0;
    end
    
    local value = byLevel + byADD;
    
    return value;
end

function SCR_GET_PC_PIE_ADD(pc)
    local byBuff = TryGetProp(pc, "PIE_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end
--

function SCR_GET_PC_KDHIT(pc)
    local byBuff = TryGetProp(pc, "KDHit_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function SCR_GET_PC_KDBONUS(pc)
    local defaultKDBonus = 120;
    
    local lv = TryGetProp(pc, "Lv");
    if lv == nil then
        lv = 1;
    end
    
    local byLevel = 10 * lv;
    
    local byItem = GetSumOfEquipItem(pc, 'KDBonus');
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "KDBonus_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = defaultKDBonus + byLevel + byItem + byBuff;
    
    return value;
end

function SCR_GET_PC_KDDEFENCE(pc)
    local defaultKDDefence = 30;
    
    local lv = TryGetProp(pc, "Lv");
    if lv == nil then
        lv = 1;
    end
    
    local byLevel = 10 * lv;
    
    local byItem = GetSumOfEquipItem(pc, 'KDDefence');
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "KDBonus_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = defaultKDDefence + byLevel + byItem + byBuff;
    
    return value;
end


function SCR_GET_PC_GUARDABLE(pc)
    if IsDummyPC(pc) == 1 then
        return 0;
    end

    -- QuarrelShooter & Equip Shield ---
    local jobListString = GetJobHistoryString(pc);
    if jobListString ~= nil and string.find(jobListString, "Char3_3") ~= nil then
        local itemLH  = GetEquipItemForPropCalc(pc, 'LH');
        if itemLH ~= nil and itemLH.ClassType == "Shield" and itemLH.LHandSkill == "None" then
            return 1;
        end
    end

    if IsBuffApplied(pc, "Impaler_Buff") == "YES" then
        return 0;
    end

     -- beautyshop check
     local beautyshopZone = GetZoneName(pc)
     if beautyshopZone == "c_barber_dress" and jobListString ~= nil and string.find(jobListString, "Char1_1") ~= nil then
        -- 입어보기 상태를 점검한다.
        if IsEquipedDummyItem(pc, "LH") == 1 then  -- 왼손에 장비를 끼고 있을 떄만 확인.
            if IsEquipedDummySheild(pc) == 1 then
                return 1;
            else
                -- 현재 뷰티샵 미리보기 상태이기 때문에 스킬, 실제 장착장비를 확인하지 못하게 해야함.
                -- 방패를 실제로 장착하고 단검을 입어보기하면 가드가 우선이기 때문.        
                return 0;
            end
        end
     end
    
    local isGuardSkill = GetStanceSkill(pc, "Warrior_Guard");
    if isGuardSkill == nil then
        return 0;
    end

    local itemLH  = GetEquipItemForPropCalc(pc, 'LH');
    if itemLH ~= nil then
        if itemLH.ClassType == "Shield" and itemLH.LHandSkill == "None" then
            return 1;
        end
    end
    
    return 0;
end

function SCR_PC_GUARD_ON(pc)
    local lv = TryGetProp(pc, "Lv");
    if lv == nil then
        lv = 1;
    end
    
    if IsBuffApplied(pc, "Archer_Kneelingshot") == "YES" then
        RemoveBuff(pc, "Archer_Kneelingshot")
    end
    
    -- Block --
    local blkAdd = 550;
    
    ----------
    
    
    
    -- Defence --
    local abil_Peltasta10 = GetAbility(pc, 'Peltasta10')
    local defAdd = 0;
    
    if abil_Peltasta10 ~= nil then
        local defenceValue = TryGetProp(pc, "DEF");
        if defenceValue == nil then
            defenceValue = 0;
        end
        
        defAdd = math.floor(defenceValue * 0.1 * abil_Peltasta10.Level);
    end
    
    ----------
    
    
    
    local blockBuff = TryGetProp(pc, "BLK_BM");
    if blockBuff ~= nil then
        pc.BLK_BM = pc.BLK_BM + blkAdd;
        
        SetExProp(pc, 'ADD_PC_GUARD_BLK', blkAdd);
    end
    
    local defenceBuff = TryGetProp(pc, "DEF_BM");
    if defenceBuff ~= nil then
        pc.DEF_BM = pc.DEF_BM + defAdd;
        
        SetExProp(pc, 'ADD_PC_GUARD_DEF', defAdd);
    end
    
    local enableJump = TryGetProp(pc, "Jumpable");
    if enableJump ~= nil then
        pc.Jumpable = pc.Jumpable - 1;
    end
    
    InvalidateStates(pc);
end

function SCR_PC_GUARD_OFF(pc)
    local blockBuff = TryGetProp(pc, "BLK_BM");
    if blockBuff ~= nil then
        local blkAdd = GetExProp(pc, 'ADD_PC_GUARD_BLK');
        
        pc.BLK_BM = pc.BLK_BM - blkAdd;
    end
    
    local defenceBuff = TryGetProp(pc, "BLK_BM");
    if defenceBuff ~= nil then
        local defAdd = GetExProp(pc, 'ADD_PC_GUARD_DEF');
        
        pc.DEF_BM = pc.DEF_BM - defAdd;
    end
    
    local enableJump = TryGetProp(pc, "Jumpable");
    if enableJump ~= nil then
        pc.Jumpable = pc.Jumpable + 1;
    end
    
    InvalidateStates(pc);
end

function SCR_Get_SkillAngle(self)
    local byItem = GetSumOfEquipItem(self, 'SkillAngle');
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(self, "SkillAngle_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return value;
 end

function SCR_Get_SkillRange(self)
    local byItem = GetSumOfEquipItem(self, 'SkillRange');
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(self, "SkillRange_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local byAbil = 0
    local abilPropList = { 'ABIL_SPEAR_RANGE', 'ABIL_THSPEAR_RANGE' };
    for i = 1, #abilPropList do
        local abilProp = GetExProp(self, abilPropList[i])
        if abilProp == nil then
            abilProp = 0
        end
        
        byAbil = byAbil + abilProp;
    end
    
    local value = byItem + byBuff + byAbil;    
    return value;
end

function SCR_Get_SkillWidthRange(self)    
    local byItem = GetSumOfEquipItem(self, 'SkillWidthRange');
    
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(self, "SkillWidthRange_BM");
    
    if byBuff == nil then
        byBuff = 0;
    end
    
    local byAbil = 0
    
    local abilPropList = { 'ABIL_SPEAR_RANGE', 'ABIL_THSPEAR_RANGE' };
    for i = 1, #abilPropList do
        local abilProp = GetExProp(self, abilPropList[i])
        if abilProp == nil then
            abilProp = 0
        end
        
        byAbil = byAbil + abilProp;
    end
    
    local value = byItem + byBuff + byAbil;    
    return value;
end

function SCR_Get_TrustRange(self)
    local byItem = GetSumOfEquipItem(self, "Aries_Range");
    if byItem == nil then
        byItem = 0;
    end
    
    return byItem;
end

function SCR_Get_SlashRange(self)
    local byItem = GetSumOfEquipItem(self, "Slash_Range");
    if byItem == nil then
        byItem = 0;
    end
    
    return byItem;
end

function SCR_Get_StrikeRange(self)
    local byItem = GetSumOfEquipItem(self, "Strike_Range");
    if byItem == nil then
        byItem = 0;
    end
    
    return byItem;
end

function SCR_Get_PostDelay(self)
    local byItem = GetSumOfEquipItem(self, "PostDelay");
    if byItem == nil then
        byItem = 0;
    end
    
    return byItem;
end

function SCR_GET_ADDFEVER(self)
    return 0;
end


function SCR_GET_FIRE_ATK(pc)
    local byItem = GetSumOfEquipItem(pc, "ADD_FIRE");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Fire_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_ICE_ATK(pc)
    local byItem = GetSumOfEquipItem(pc, "ADD_ICE");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Ice_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_POISON_ATK(pc)
    local byItem = GetSumOfEquipItem(pc, "ADD_POISON");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Poison_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_LIGHTNING_ATK(pc)
    local byItem = GetSumOfEquipItem(pc, "ADD_LIGHTNING");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Lightning_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_SOUL_ATK(pc)
    local byItem = GetSumOfEquipItem(pc, "ADD_SOUL");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Soul_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_EARTH_ATK(pc)
    local byItem = GetSumOfEquipItem(pc, "ADD_EARTH");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Earth_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_HOLY_ATK(pc)
    local byItem = GetSumOfEquipItem(pc, "ADD_HOLY");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Holy_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_DARK_ATK(pc)
    local byItem = GetSumOfEquipItem(pc, "ADD_DARK");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Dark_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_ADD_Damage_ATK(pc)
    local byItem = GetSumOfEquipItem(pc, "Add_Damage_Atk");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Add_Damage_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local add_value = SCR_GET_FIRE_ATK(pc)
    add_value = add_value + SCR_GET_ICE_ATK(pc)
    add_value = add_value + SCR_GET_POISON_ATK(pc)
    add_value = add_value + SCR_GET_LIGHTNING_ATK(pc)
    add_value = add_value + SCR_GET_SOUL_ATK(pc)
    add_value = add_value + SCR_GET_EARTH_ATK(pc)
    add_value = add_value + SCR_GET_HOLY_ATK(pc)
    add_value = add_value + SCR_GET_DARK_ATK(pc)

    local byabil = 0
    if GetExProp(pc, "IS_ADDDAMAGE_ABIL") > 0 then
        local patk = (TryGetProp(pc, "MINPATK") + TryGetProp(pc, "MAXPATK")) / 2
        local matk = (TryGetProp(pc, "MINMATK") + TryGetProp(pc, "MAXMATK")) / 2

        local atk = math.max(patk, matk)

        byabil = math.floor(atk * 0.1 * GetExProp(pc, "IS_ADDDAMAGE_ABIL"))
    end

    local value = byItem + byBuff + add_value + byabil;    
    return math.floor(value);
end

function SCR_GET_Widling_ATK(pc)	
    local byItem = GetSumOfEquipItem(pc, "ADD_WIDLING");	
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Widling_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_Paramune_ATK(pc)
    local byItem = GetSumOfEquipItem(pc, "ADD_PARAMUNE");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Paramune_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_Forester_ATK(pc)
    local byItem = GetSumOfEquipItem(pc, "ADD_FORESTER");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Forester_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_Velnias_ATK(pc)
    local byItem = GetSumOfEquipItem(pc, "ADD_VELIAS");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Velnias_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_Klaida_ATK(pc)
    local byItem = GetSumOfEquipItem(pc, "ADD_KLAIDA");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Klaida_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_Cloth_ATK(pc)
    local byItem = GetSumOfEquipItem(pc, "ADD_CLOTH");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Cloth_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_Leather_ATK(pc)
    local byItem = GetSumOfEquipItem(pc, "ADD_LEATHER");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Leather_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_Chain_ATK(pc)
    local byItem = GetSumOfEquipItem(pc, "ADD_CHAIN");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Chain_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_Iron_ATK(pc)
    local byItem = GetSumOfEquipItem(pc, "ADD_IRON");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Iron_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_Ghost_ATK(pc)
    local byItem = GetSumOfEquipItem(pc, "ADD_GHOST");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Ghost_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_SmallSize_ATK(pc)
    local byItem = GetSumOfEquipItem(pc, "ADD_SMALLSIZE");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "SmallSize_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_MiddleSize_ATK(pc)
    local byItem = GetSumOfEquipItem(pc, "ADD_MIDDLESIZE");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "MiddleSize_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end

    local value = byItem + byBuff;
    return math.floor(value);
end

function SCR_GET_MiddleSize_Def(pc)
    local byItem = GetSumOfEquipItem(pc, "MiddleSize_Def");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "MiddleSize_Def_BM");
    if byBuff == nil then
        byBuff = 0;
    end

    local value = byItem + byBuff;
    return math.floor(value);
end

function SCR_GET_AllMaterialType_Def(pc)
    local byItem = GetSumOfEquipItem(pc, "AllMaterialType_Def");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "AllMaterialType_Def_BM");
    if byBuff == nil then
        byBuff = 0;
    end

    local value = byItem + byBuff;
    return math.floor(value);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_AllMaterialType_Atk(pc)
    local byItem = GetSumOfEquipItem(pc, "AllMaterialType_Atk");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "AllMaterialType_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end

    local value = byItem + byBuff;
    return math.floor(value);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_AllSize_Atk(pc)
    local byItem = GetSumOfEquipItem(pc, "AllSize_Atk");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "AllSize_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end

    local value = byItem + byBuff;
    return math.floor(value);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_AllRace_Atk(pc)
    local byItem = GetSumOfEquipItem(pc, "AllRace_Atk");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "AllRace_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end

    local value = byItem + byBuff;
    return math.floor(value);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_LargeSize_ATK(pc)
    local byItem = GetSumOfEquipItem(pc, "ADD_LARGESIZE");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "LargeSize_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_BOSS_ATK(pc)
    local byItem = GetSumOfEquipItem(pc, "ADD_BOSS_ATK");
    if byItem == nil then
        byItem = 0;
    end
  
    local byBuff = TryGetProp(pc, "BOSS_ATK_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;

    return math.floor(value)
end

function SCR_GET_BASE_WEAPON_DEF(pc)
    return 0;
end



function SCR_GET_ATK_ARIES(pc)
    local byItem = GetSumOfEquipItem(pc, "Aries");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Aries_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_ATK_SLASH(pc)
    local byItem = GetSumOfEquipItem(pc, "Slash");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Slash_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_ATK_STRIKE(pc)
    local byItem = GetSumOfEquipItem(pc, "Strike");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Strike_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
	
    return math.floor(value);
end

function SCR_GET_Arrow_Atk(pc)
    -- 아이템에서는 사용하지 않아 아이템에 대한 추가치 로직은 없음
    -- 만약 아이템에서 사용하게 되면 로직 추가해야함
    local byItem = 0;
    
    local byBuff = TryGetProp(pc, "Arrow_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
	
    return math.floor(value);
end

function SCR_GET_Cannon_Atk(pc)
    -- 아이템에서는 사용하지 않아 아이템에 대한 추가치 로직은 없음
    -- 만약 아이템에서 사용하게 되면 로직 추가해야함
    local byItem = 0;
    
    local byBuff = TryGetProp(pc, "Cannon_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
	
    return math.floor(value);
end

function SCR_GET_Gun_Atk(pc)
    -- 아이템에서는 사용하지 않아 아이템에 대한 추가치 로직은 없음
    -- 만약 아이템에서 사용하게 되면 로직 추가해야함
    local byItem = 0;
    
    local byBuff = TryGetProp(pc, "Gun_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;

    if GetExProp(pc, "IS_Hakkapeliter1_Abil") == 1 then
        value = value + GetExProp(pc, "IS_Hakkapeliter1_Value")
    end
	
    return math.floor(value);
end

function SCR_GET_Magic_Melee_Atk(pc)
    local byItem = GetSumOfEquipItem(pc, "Magic_Melee_Atk");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Magic_Melee_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
	
    return math.floor(value);
end

function SCR_GET_Magic_Fire_Atk(pc)
    local byItem = GetSumOfEquipItem(pc, "Magic_Fire_Atk");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Magic_Fire_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
	
    return math.floor(value);
end

function SCR_GET_Magic_Ice_Atk(pc)
    local byItem = GetSumOfEquipItem(pc, "Magic_Ice_Atk");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Magic_Ice_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
	
    return math.floor(value);
end

function SCR_GET_Magic_Lightning_Atk(pc)
    local byItem = GetSumOfEquipItem(pc, "Magic_Lightning_Atk");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Magic_Lightning_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
	
    return math.floor(value);
end

function SCR_GET_Magic_Earth_Atk(pc)
    local byItem = GetSumOfEquipItem(pc, "Magic_Earth_Atk");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Magic_Earth_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
	
    return math.floor(value);
end

function SCR_GET_Magic_Poison_Atk(pc)
    -- 아이템에서는 사용하지 않아 아이템에 대한 추가치 로직은 없음
    -- 만약 아이템에서 사용하게 되면 로직 추가해야함
    local byItem = 0;
    
    local byBuff = TryGetProp(pc, "Magic_Poison_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
	
    return math.floor(value);
end

function SCR_GET_Magic_Dark_Atk(pc)
    local byItem = GetSumOfEquipItem(pc, "Magic_Dark_Atk");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Magic_Dark_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
	
    return math.floor(value);
end

function SCR_GET_Magic_Holy_Atk(pc)
    local byItem = GetSumOfEquipItem(pc, "Magic_Holy_Atk");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Magic_Holy_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
	
    return math.floor(value);
end

function SCR_GET_Magic_Soul_Atk(pc)
    local byItem = GetSumOfEquipItem(pc, "Magic_Soul_Atk");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Magic_Soul_Atk_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
	
    return math.floor(value);
end

function SCR_GET_DEF_ARIES(pc)
    local byItem = GetSumOfEquipItem(pc, "AriesDEF");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "DefAries_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_DEF_SLASH(pc)
    local byItem = GetSumOfEquipItem(pc, "SlashDEF");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "DefSlash_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_DEF_STRIKE(pc)
    local byItem = GetSumOfEquipItem(pc, "StrikeDEF");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "DefStrike_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_RES_FIRE(pc)
    local byItem = GetSumOfEquipItem(pc, "RES_FIRE");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "ResFire_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_RES_ICE(pc)
    local byItem = GetSumOfEquipItem(pc, "RES_ICE");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "ResIce_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_RES_POISON(pc)
    local byItem = GetSumOfEquipItem(pc, "RES_POISON");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "ResPoison_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_RES_LIGHTNING(pc)
    local byItem = GetSumOfEquipItem(pc, "RES_LIGHTNING");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "ResLightning_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_RES_EARTH(pc)
    local byItem = GetSumOfEquipItem(pc, "RES_EARTH");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "ResEarth_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_RES_HOLY(pc)
    local byItem = GetSumOfEquipItem(pc, "RES_HOLY");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "ResHoly_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_RES_DARK(pc)
    local byItem = GetSumOfEquipItem(pc, "RES_DARK");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "ResDark_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_RES_ADD_DAMAGE(pc)
    local byItem = GetSumOfEquipItem(pc, "ResAdd_Damage");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "ResAdd_Damage_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local add_value = SCR_GET_RES_FIRE(pc)
    add_value = add_value + SCR_GET_RES_ICE(pc)
    add_value = add_value + SCR_GET_RES_POISON(pc)
    add_value = add_value + SCR_GET_RES_LIGHTNING(pc)
    add_value = add_value + SCR_GET_RES_SOUL(pc)
    add_value = add_value + SCR_GET_RES_EARTH(pc)
    add_value = add_value + SCR_GET_RES_HOLY(pc)
    add_value = add_value + SCR_GET_RES_DARK(pc)

    local value = byItem + byBuff + add_value;
    
    return math.floor(value);
end

function SCR_GET_RES_SOUL(pc)
    local byItem = GetSumOfEquipItem(pc, "RES_SOUL");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "ResSoul_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_SKL_ADD_COOLDOWN(pc)
    return 1;
end

function SCR_GET_ADDOVERHEAT(pc, skill)
    if skill ~= nil then
        local stat = TryGetProp(pc, "INT");
        if stat == nil then
            stat = 1;
        end
        
        local cls = GetClassByType('skill_oh_reduce', stat)
        if cls ~= nil then
            return math.floor( cls['Circle_'..skill.SklCircleLv] );
        end
    end
    
    return 0;
end

function SCR_GET_PC_LIMIT_BUFF_COUNT(self)
    local value = 999;	-- 2017/9/13 --
    
    local byBuff = TryGetProp(self, "LimitBuffCount_BM", 0);
    if byBuff > 0 then
    	value = byBuff;
    end
    
    return value;
end

function GET_MAXHATE_COUNT(self)
	local maxHateCount = 100;
	
    local owner = GetTopOwner(self);
    if IS_PC(self) == true or IS_PC(owner) == true or TryGetProp(self, "Faction") == "Summon" then
	    local mapID = GetMapID(self);
	    local cls = GetClassByType('Map', mapID);
	    if cls ~= nil then
	        local defaultMaxHateCount = cls.MaxHateCount;
	        
	        if defaultMaxHateCount == nil then
	            defaultMaxHateCount = 100;
	        end
	        
	        local byBuff = TryGetProp(self, "MaxHateCount_BM");
	        if byBuff == nil then
	            byBuff = 0;
	        end
	        
            maxHateCount = defaultMaxHateCount + byBuff;
	    end
    end
    return maxHateCount;
end

function SCR_Get_HateRate(self)
	local value = 0;
	
    local byBuff = TryGetProp(self, "HateRate_BM", 0);
	value = value + byBuff;
	
    if value < -99 then
        value = -99;
    end
	
    return math.floor(value);
end

function GET_ArmorMaterial_ID(self)
    local armorMaterial = nil;
    local equipbodyItem = GetEquipItemForPropCalc(self, 'SHIRT');
    if equipbodyItem ~= nil then
        armorMaterial = TryGetProp(equipbodyItem, "Material");
    end
    
    if armorMaterial == nil then
        armorMaterial = "Cloth";
    end
    
    local armorMaterialList = { "Cloth", "Leather", "Iron", "Ghost", "Chain" };
    for i = 1, #armorMaterialList do
        if armorMaterial == armorMaterialList[i] then
            self.ArmorMaterial = armorMaterialList[i];
            return i;
        end
    end
    
    return 1;
    
--    if armorMaterial == 'Cloth' then
--        self.ArmorMaterial = 'Cloth';
--        return 1;
--    elseif armorMaterial == 'Leather' then
--        self.ArmorMaterial = 'Leather';
--        return 2;
--    elseif armorMaterial == 'Iron' then
--        self.ArmorMaterial = 'Iron';
--        return 3;
--    elseif armorMaterial == 'Ghost' then
--        self.ArmorMaterial = 'Ghost';
--        return 4;
--    elseif armorMaterial == 'Chain' then    
--        self.ArmorMaterial = 'Chain';
--        return 5;
--    end
end

function SCR_GET_ARIES_ATKFACTOR_PC(self)
    local byBuff = TryGetProp(self, "AriesAtkFactor_PC_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function SCR_GET_SLASH_ATKFACTOR_PC(self)
    local byBuff = TryGetProp(self, "SlashAtkFactor_PC_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function SCR_GET_STRIKE_ATKFACTOR_PC(self)
    local byBuff = TryGetProp(self, "StrikeAtkFactor_PC_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function SCR_GET_MISSILE_ATKFACTOR_PC(self)
    local byBuff = TryGetProp(self, "MissileAtkFactor_PC_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function SCR_GET_FIRE_ATKFACTOR_PC(self)
    local byBuff = TryGetProp(self, "FireAtkFactor_PC_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function SCR_GET_ICE_ATKFACTOR_PC(self)
    local byBuff = TryGetProp(self, "IceAtkFactor_PC_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function SCR_GET_LIGHTNING_ATKFACTOR_PC(self)
    local byBuff = TryGetProp(self, "LightningAtkFactor_PC_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function SCR_GET_SOUL_ATKFACTOR_PC(self)
    local byBuff = TryGetProp(self, "SoulAtkFactor_PC_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function SCR_GET_POISON_ATKFACTOR_PC(self)
    local byBuff = TryGetProp(self, "PoisonAtkFactor_PC_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function SCR_GET_EARTH_ATKFACTOR_PC(self)
    local byBuff = TryGetProp(self, "EarthAtkFactor_PC_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function SCR_GET_HOLY_ATKFACTOR_PC(self)
    local byBuff = TryGetProp(self, "HolyAtkFactor_PC_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function SCR_GET_DARK_ATKFACTOR_PC(self)
    local byBuff = TryGetProp(self, "DarkAtkFactor_PC_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function SCR_GET_ARIES_DEFFACTOR_PC(self)
    local byBuff = TryGetProp(self, "AriesDefFactor_PC_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function SCR_GET_SLASH_DEFFACTOR_PC(self)
    local byBuff = TryGetProp(self, "SlashDefFactor_PC_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function SCR_GET_STRIKE_DEFFACTOR_PC(self)
    local byBuff = TryGetProp(self, "StrikeDefFactor_PC_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function SCR_GET_MISSILE_DEFFACTOR_PC(self)
    local byBuff = TryGetProp(self, "MissileDefFactor_PC_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function SCR_GET_FIRE_DEFFACTOR_PC(self)
    local byBuff = TryGetProp(self, "FireDefFactor_PC_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function SCR_GET_ICE_DEFFACTOR_PC(self)
    local byBuff = TryGetProp(self, "IceDefFactor_PC_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function SCR_GET_LIGHTNING_DEFFACTOR_PC(self)
    local byBuff = TryGetProp(self, "LightningDefFactor_PC_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function SCR_GET_SOUL_DEFFACTOR_PC(self)
    local byBuff = TryGetProp(self, "SoulDefFactor_PC_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function SCR_GET_POISON_DEFFACTOR_PC(self)
    local byBuff = TryGetProp(self, "PoisonDefFactor_PC_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function SCR_GET_EARTH_DEFFACTOR_PC(self)
    local byBuff = TryGetProp(self, "EarthDefFactor_PC_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function SCR_GET_HOLY_DEFFACTOR_PC(self)
    local byBuff = TryGetProp(self, "HolyDefFactor_PC_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function SCR_GET_DARK_DEFFACTOR_PC(self)
    local byBuff = TryGetProp(self, "DarkDefFactor_PC_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    return byBuff;
end

function GET_REWARD_PROPERTY(self, propertyName)
    
    local sObj = GetSessionObject(self, 'ssn_klapeda')
    local rewardProperty = 0;

    if sObj == nil and IsServerObj(self) == 0 then
        local pc = GetMyPCObject()
        sObj = GetSessionObject(pc, 'ssn_klapeda')
    end

    if sObj ~= nil then
        local list, listCnt = GetClassList("reward_property");
        
        for i = 0, listCnt -1 do
            local cls = GetClassByIndexFromList(list, i);
            if cls ~= nil and TryGetProp(cls, "Property") == propertyName then
                if sObj[cls.ClassName] == 300 then
                    rewardProperty = rewardProperty + cls.Value
                end
            end
        end
    end

    return rewardProperty;
end



--function GetDefaultPropertyPC(self, property)
--    local value = TryGetProp(self, property);
--    if value == nil then
--        print(property.." is nil");
--        return 0;
--    end
--    
--    local valueBM = TryGetProp(self, property.."_BM");
--    
--    if "MINPATK" == property or "MAXPATK" == property then
--        valueBM = TryGetProp(self, "PATK_BM");
--    elseif "MINMATK" == property or "MAXMATK" == property then
--        valueBM = TryGetProp(self, "MATK_BM");
--    end
--    
--    if valueBM == nil then
--        print(property.."_BM is nil");
--        valueBM = 0;
--    end
--    
--    value = value - valueBM;
--    return math.floor(value);
--end



function SCR_GET_LOOTINGCHANCE(self)
    local defaultValue = 0;
    
    local byItem = GetSumOfEquipItem(self, 'LootingChance');
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(self, 'LootingChance_BM');
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = defaultValue + byItem + byBuff;
    
    if value > 10000 then
    	value = 10000;
    end
    
    return math.floor(value);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_HEAL_PWR(self)
    local flag = 2
    if flag == 1 then 
        return SCR_Get_HEAL_PWR_VER1(self) -- 기존 연산식
    elseif flag == 2 then 
        return SCR_Get_HEAL_PWR_VER2(self) -- 신규 연산식
    end
    
    -- 이전 치유력 계산식
    --local defaultValue = 20;
    --local byLevel = lv * 1.0;
    --local byStat = (stat * 1) + (math.floor(stat / 10) * (byLevel * 0.03));
    --local value = defaultValue + byLevel + byStat;

    -- 레벨 이중 적용 계산식
    --local defaultValue = 70;
    --local byLevel = lv * (1 + 0.0073 * lv);
    --local byStat = stat * 0.9;
    --local byAttack = SCR_GET_DEFAULT_ATK_COMPARE(self) * 0.086
    --local value = math.floor(defaultValue + byLevel + byStat + byAttack)

    local defaultValue = 20;
    
    local lv = TryGetProp(self, "Lv");
    if lv == nil then
        lv = 1;
    end

    local byLevel = lv * 2.5;
    
    local stat = TryGetProp(self, "MNA");
    if stat == nil then
        stat = 1;
    end

    local byStat = stat * 1;

    local atk = SCR_GET_DEFAULT_ATK_COMPARE(self)
    atk = atk / 3
        
    -- local byAttack = atk * 0.08

    -- local value = math.floor(defaultValue + byLevel + byStat + byAttack)
    local value = math.floor(defaultValue + byLevel + byStat)

    local byBuff = 0;
    
    local byBuffTemp = TryGetProp(self, "HEAL_PWR_BM");
    if byBuffTemp ~= nil then
        byBuff = byBuff + byBuffTemp;
    end
    
    local byRateBuff = 0;

    local byRateBuffTemp = TryGetProp(self, "HEAL_PWR_RATE_BM"); 
    if byRateBuffTemp ~= nil then
        byRateBuff = byRateBuff + byRateBuffTemp;
    end
    
    -- HealControl 레이드 체크
    -- if IsHealControlMap(self) == 1 then
    --     local by_rate_raid = GET_HEAL_CTRL_RAID_HEAL_PWR_RATE_BM(self);
    --     byRateBuff = byRateBuff + by_rate_raid;
    --     atk = atk * (1 + by_rate_raid)
    -- end

    byRateBuff = math.floor(value * byRateBuffTemp);
    value = value + byBuff + byRateBuff;    
    local byAbil = GetExProp(self, "ABIL_MACE_ADDHEAL")
    if byAbil == nil then
        byAbil = 0
    end
    
    local sum_of_heal_power = 0
    sum_of_heal_power = sum_of_heal_power + byAbil

    local seal_option = GetExProp(self, "ITEM_Cleric_PatronSaint_HwpRate")        
    if seal_option > 0 then
        seal_option = seal_option / 1000 -- 치유력 증가 합연산으로 처리한다
        sum_of_heal_power = sum_of_heal_power + seal_option
    end
    
    if GetExProp(self, "ITEM_goddess_seal_lv1") > 0 then
        seal_option = GetExProp(self, "ITEM_goddess_seal_lv1")        
        seal_option = seal_option / 1000 -- 치유력 증가 합연산으로 처리한다
        sum_of_heal_power = sum_of_heal_power + seal_option
    end

    if GetExProp(self, "ITEM_goddess_seal_def_lv2") > 0 then
        seal_option = GetExProp(self, "ITEM_goddess_seal_def_lv2")
        seal_option = seal_option / 1000 -- 치유력 증가 합연산으로 처리한다
        sum_of_heal_power = sum_of_heal_power + seal_option
    end

    value = value * (1 + sum_of_heal_power)

    local sum_of_value_atk = math.floor((value * 0.4) + (atk * 0.6))
    if sum_of_value_atk < 1 then
    	sum_of_value_atk = 1;
    end

    return sum_of_value_atk;
end

-- 신규 연산식
function SCR_Get_HEAL_PWR_VER2(self)
    local defaultValue = 20;
    
    local lv = TryGetProp(self, "Lv", 1);
    local byLevel = lv * 2.5;

    local stat = TryGetProp(self, "MNA", 1);
    local byStat = stat * 1;
    
    local value = math.floor(defaultValue + byLevel + byStat)
    
    local byBuff = TryGetProp(self, "HEAL_PWR_BM", 0);
    value = value + byBuff;
    
    local atk = SCR_GET_DEFAULT_ATK_COMPARE(self)
    local byAttack = atk / 4
    value = math.floor((value * 0.4) + (byAttack * 0.6))
    
    local byRateBuff = TryGetProp(self, "HEAL_PWR_RATE_BM", 0); 
    value = value * (1 + byRateBuff)
    
    local sum_of_heal_power = 0
    local byAbil = GetExProp(self, "ABIL_MACE_ADDHEAL") -- 클레릭: 치유력 특성
    if byAbil == nil then
        byAbil = 0
    end
    sum_of_heal_power = sum_of_heal_power + byAbil

    local seal_option = GetExProp(self, "ITEM_Cleric_PatronSaint_HwpRate") -- 보루타 인장 - 클레릭    
    if seal_option > 0 then
        seal_option = seal_option / 1000
        sum_of_heal_power = sum_of_heal_power + seal_option
    end
    if GetExProp(self, "ITEM_goddess_seal_lv1") > 0 then -- 보루타 인장 - 공용
        seal_option = GetExProp(self, "ITEM_goddess_seal_lv1")    
        seal_option = seal_option / 1000
        sum_of_heal_power = sum_of_heal_power + seal_option
    end

    if GetExProp(self, "ITEM_goddess_seal_def_lv2") > 0 then -- 유라테 인장 - 신의 가호
        seal_option = GetExProp(self, "ITEM_goddess_seal_def_lv2")
        seal_option = seal_option / 1000
        sum_of_heal_power = sum_of_heal_power + seal_option
    end


    value = value * (1 + sum_of_heal_power)

    if IsPVPServer(self) == 1 or IsPVPField(self) == 1 or IsJoinColonyWarMap(self) == 1 then
        local reduce_ratio = FINAL_DAMAGE_REDUCE_RATIO_PVP / 100
        value = value * (1 - reduce_ratio)
    end

    if value < 1 then
    	value = 1;
    end
    
    return math.floor(value);
end

-- 툴팁용 표기
function GET_SHOW_HEAL_PWR(self, real_value)
    local atk = SCR_GET_DEFAULT_ATK_COMPARE(self)
    local byAttack = atk / 4
    
    local byRateBuff = TryGetProp(self, "HEAL_PWR_RATE_BM", 0);     
    local sum_of_heal_power = 0
    local byAbil = GetExProp(self, "ABIL_MACE_ADDHEAL") -- 클레릭: 치유력 특성
    if byAbil == nil then
        byAbil = 0
    end
    
    sum_of_heal_power = sum_of_heal_power + byAbil
    
    local seal_option = GetExProp(self, "ITEM_Cleric_PatronSaint_HwpRate") -- 보루타 인장 - 클레릭
    if seal_option > 0 then
        seal_option = seal_option / 1000
        sum_of_heal_power = sum_of_heal_power + seal_option
    end
    if GetExProp(self, "ITEM_goddess_seal_lv1") > 0 then -- 보루타 인장 - 공용
        seal_option = GetExProp(self, "ITEM_goddess_seal_lv1")
        seal_option = seal_option / 1000
        sum_of_heal_power = sum_of_heal_power + seal_option
    end
    
    if GetExProp(self, "ITEM_goddess_seal_def_lv2") > 0 then -- 유라테 인장 - 신의 가호
        seal_option = GetExProp(self, "ITEM_goddess_seal_def_lv2")
        seal_option = seal_option / 1000
        sum_of_heal_power = sum_of_heal_power + seal_option
    end
        
    real_value  = ((real_value - (byAttack * 0.6)) / 0.4)
    
    real_value = ((real_value) + (byAttack * 0.6))
    real_value = real_value * (1 + sum_of_heal_power) 
    
    real_value = real_value * (1 + byRateBuff)
    
    if IsPVPServer() == 1 or IsPVPField() == 1 or IsJoinColonyWarMap() == 1 then
        local reduce_ratio = FINAL_DAMAGE_REDUCE_RATIO_PVP / 100
        real_value = real_value * (1 - reduce_ratio)
    end

    if real_value < 1 then
    	real_value = 1;
    end

    return math.floor(real_value);
end

-- 기존 연산식
function SCR_Get_HEAL_PWR_VER1(self)
    
    local defaultValue = 20;
    
    local lv = TryGetProp(self, "Lv");
    if lv == nil then
        lv = 1;
    end

    local byLevel = lv * 2.5;
    
    local stat = TryGetProp(self, "MNA");
    if stat == nil then
        stat = 1;
    end

    local byStat = stat * 1;

    local atk = SCR_GET_DEFAULT_ATK_COMPARE(self)
    local byAttack = atk * 0.08

    local value = math.floor(defaultValue + byLevel + byStat + byAttack)

    local byBuff = 0;
    
    local byBuffTemp = TryGetProp(self, "HEAL_PWR_BM");
    if byBuffTemp ~= nil then
        byBuff = byBuff + byBuffTemp;
    end
    
    local byRateBuff = 0;

    local byRateBuffTemp = TryGetProp(self, "HEAL_PWR_RATE_BM");    
    if byRateBuffTemp ~= nil then
        byRateBuff = byRateBuff + byRateBuffTemp;
    end

    byRateBuff = math.floor(value * byRateBuffTemp);
    value = value + byBuff + byRateBuff;    
    local byAbil = GetExProp(self, "ABIL_MACE_ADDHEAL")
    if byAbil == nil then
        byAbil = 0
    end
    
    local seal_option = GetExProp(self, "ITEM_Cleric_PatronSaint_HwpRate")        
    seal_option = seal_option / 1000 -- 치유력 증가 합연산으로 처리한다
    value = value * (1 + byAbil + seal_option) 
    
    if value < 1 then
    	value = 1;
    end

    return math.floor(value);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Leather_Def(pc)
    local byItem = GetSumOfEquipItem(pc, "Leather_Def");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Leather_Def_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_Cloth_Def(pc)
    local byItem = GetSumOfEquipItem(pc, "Cloth_Def");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Cloth_Def_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

function SCR_GET_Iron_Def(pc)
    local byItem = GetSumOfEquipItem(pc, "Iron_Def");
    if byItem == nil then
        byItem = 0;
    end
    
    local byBuff = TryGetProp(pc, "Iron_Def_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byItem + byBuff;
    
    return math.floor(value);
end

-- PC ITEM PROP LIST --

function SCR_GET_ENCHANT_MAIN_WEAPON_DAMAGE_RATE(self)
	local propName = "RareOption_MainWeaponDamageRate";
	local optionValue = SCR_GET_PC_ENCHANT_OPTION_VALUE(self, propName);
	
	return optionValue;
end

function SCR_GET_ENCHANT_SUB_WEAPON_DAMAGE_RATE(self)
	local propName = "RareOption_SubWeaponDamageRate";

	local optionValue = SCR_GET_PC_ENCHANT_OPTION_VALUE(self, propName);
	
	return optionValue;
end

function SCR_GET_ENCHANT_BOSS_DAMAGE_RATE(self)
	local propName = "RareOption_BossDamageRate";
	local optionValue = SCR_GET_PC_ENCHANT_OPTION_VALUE(self, propName);
	
	return optionValue;
end

function SCR_GET_ENCHANT_MELEE_REDUCED_RATE(self)
	local propName = "RareOption_MeleeReducedRate";
	local optionValue = SCR_GET_PC_ENCHANT_OPTION_VALUE(self, propName);
	
	return optionValue;
end

function SCR_GET_ENCHANT_MAGIC_REDUCED_RATE(self)
	local propName = "RareOption_MagicReducedRate";
	local optionValue = SCR_GET_PC_ENCHANT_OPTION_VALUE(self, propName);
	
	return optionValue;
end

function SCR_GET_ENCHANT_PVP_DAMAGE_RATE(self)
	local propName = "RareOption_PVPDamageRate";
	local optionValue = SCR_GET_PC_ENCHANT_OPTION_VALUE(self, propName);
	
	return optionValue;
end

function SCR_GET_ENCHANT_PVP_REDUCED_RATE(self)
	local propName = "RareOption_PVPReducedRate";
	local optionValue = SCR_GET_PC_ENCHANT_OPTION_VALUE(self, propName);
	
	return optionValue;
end

function SCR_GET_ENCHANT_CRITICAL_DAMAGE_RATE(self)
	local propName = "RareOption_CriticalDamage_Rate";
	local optionValue = SCR_GET_PC_ENCHANT_OPTION_VALUE(self, propName);
	
	return optionValue;
end

function SCR_GET_ENCHANT_CRITICAL_HIT_RATE(self)
	local propName = "RareOption_CriticalHitRate";
	local optionValue = SCR_GET_PC_ENCHANT_OPTION_VALUE(self, propName);
	
	return optionValue;
end

function SCR_GET_ENCHANT_CRITICAL_DODGE_RATE(self)
	local propName = "RareOption_CriticalDodgeRate";
	local optionValue = SCR_GET_PC_ENCHANT_OPTION_VALUE(self, propName);
	
	return optionValue;
end

function SCR_GET_ENCHANT_HIT_RATE(self)
	local propName = "RareOption_HitRate";
	local optionValue = SCR_GET_PC_ENCHANT_OPTION_VALUE(self, propName);
	
	return optionValue;
end

function SCR_GET_ENCHANT_DODGE_RATE(self)
	local propName = "RareOption_DodgeRate";
	local optionValue = SCR_GET_PC_ENCHANT_OPTION_VALUE(self, propName);
	
	return optionValue;
end

function SCR_GET_ENCHANT_BLOCKBREAK_RATE(self)
	local propName = "RareOption_BlockBreakRate";
	local optionValue = SCR_GET_PC_ENCHANT_OPTION_VALUE(self, propName);
	
	return optionValue;
end

function SCR_GET_ENCHANT_BLOCK_RATE(self)
	local propName = "RareOption_BlockRate";
	local optionValue = SCR_GET_PC_ENCHANT_OPTION_VALUE(self, propName);
	
	return optionValue;
end

function SCR_GET_ENCHANT_MSPD(self)
	local propName = "RareOption_MSPD";
	local optionValue = SCR_GET_PC_ENCHANT_OPTION_VALUE(self, propName);
	
	return optionValue;
end

function SCR_GET_ENCHANT_SR(self)
	local propName = "RareOption_SR";
	local optionValue = SCR_GET_PC_ENCHANT_OPTION_VALUE(self, propName);
	
	return optionValue;
end

-- PC ITEM PROP COMMON CHECK --
function SCR_GET_PC_ENCHANT_OPTION_VALUE(self, propName)
	local optionValue = GetTopRandomOptionRare(self, propName);
	if optionValue == nil then
		optionValue = 0;
	end
	
	return optionValue;
end
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DEFAULT_ATK_COMPARE(self)
    local value = 0
    local atkPatk = (SCR_Get_DEFAULT_MAXPATK(self) + SCR_Get_DEFAULT_MINPATK(self)) / 2
    local atkMatk = (SCR_Get_DEFAULT_MAXMATK(self) + SCR_Get_DEFAULT_MINMATK(self)) / 2

    local maxAtk = math.max(atkPatk, atkMatk)

    return maxAtk
end

-- ** [ 힐량 컨트롤 관련 기능 ] ** --
-- RHP_BM
function GET_HEAL_CTRL_RAID_RHP_BM(self, value)
    if self == nil then return 0; end
    if IsHealControlMap(self) == 0 then return 0; end
    if IsServerSection() == 1 then
        local cmd = GetMGameCmd(self);
        if cmd == nil then return 0; end
        local add_rhp_bm = value * 0.9 * -1.0;
        return add_rhp_bm;
    else
        return -0.9; -- 90% 감소
    end
    return 0;
end

-- HEAL_PWR_RATE_BM
function GET_HEAL_CTRL_RAID_HEAL_PWR_RATE_BM(self)
    if self == nil then return 0; end
    if IsHealControlMap(self) == 0 then return 0; end
    if IsServerSection() == 1 then
        local cmd = GetMGameCmd(self);
        if cmd == nil then return 0; end
        return -0.9; -- 90% 감소
    else
        return -0.9; -- 90% 감소
    end
    return 0;
end

function SCR_GET_STATUS_BY_ITEM(self, statString)
    local byItem = GetSumOfEquipItem(self, statString);
    if byItem == nil then
        byItem = 0;
    end
    
    local byItemBuff = TryGetProp(self, statString.."_ITEM_BM");
    if byItemBuff == nil then
        byItemBuff = 0
    end

    local value = byItem + byItemBuff
    
    return math.floor(value);
end


function GET_ITEM_ATK(item)
    local min, max = GET_BASIC_ATK(item)
    local add = GET_REINFORCE_ADD_VALUE_ATK(item, 0, 0, 'ATK')
    min = min + add
    max = max + add
    return min, max
end

function GET_ITEM_MATK(item)
    local min, max = GET_BASIC_MATK(item)
    local add = GET_REINFORCE_ADD_VALUE_ATK(item, 0, 0, 'ATK')
    min = min + add
    max = max + add
    return min, max
end


function ENABLE_TO_USE_SKILL_STATE(self, skill)
    if TryGetProp(skill, 'Job', 'None') == 'Vanquisher' then
        local list = {'RH'}
        for i = 1, #list do
            if IsServerSection() == 0 then
                local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(list[i]))
                if inv_item ~= nil then
                    local item_obj = GetIES(inv_item:GetObject())                    
                    if TryGetProp(item_obj, 'ClassType', 'None') ~= 'THSword' then
                        return false
                    end

                else
                    return false
                end
            else
                local item_obj = GetEquipItemIgnoreDur(self, list[i]);                
                if TryGetProp(item_obj, 'ClassType', 'None') ~= 'THSword' then
                    return false
                end
            end
        end
    end    

	if IsBuffApplied(self, 'VoidSlash_toggle_Buff') == 'YES' and TryGetProp(skill, 'ClassName', 'None') ~= 'Vanquisher_VoidSlash' then
		return false
	end

	return true
end