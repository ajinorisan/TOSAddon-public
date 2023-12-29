--사용가능 설정--
function IS_ANCIENT_ENABLE_MAP(self)
    if IsServerSection() ~= 1 then self = GetMyPCObject(); end

    local zoneName = "None";
    if IsServerSection() == 1 then zoneName = GetZoneName(self);
    else zoneName = session.GetMapName(); end
    
    local enableMapList = {"onehour_test1", "d_solo_dungeon_2", "d_solo_dungeon"}
    for i = 1, #enableMapList do
        if zoneName == enableMapList[i] then
            return "YES";
        end
    end
    
    local indun_cls = nil;
    if IsServerSection() == 1 then
    local cmd = GetMGameCmd(self);
    if cmd ~= nil then
        local mGameName = cmd:GetMGameName();
            indun_cls = GET_MGAME_CLASS_BY_MGAMENAME(mGameName);
        end
    else
        if IsRaidField() == 1 or IsRaidMap() == 1 or session.IsSoloChallengeMap() == true then
            local mGameName = session.mgame.GetCurrentMGameName()
			if mGameName ~= nil and mGameName ~= 'None' then
                indun_cls = GetClassByStrProp("Indun", "MGame", mGameName)
			end
        end
	end

    if indun_cls ~= nil then
        local sub_type = TryGetProp(indun_cls, "SubType", "None");
        local dungeon_type = TryGetProp(indun_cls, "DungeonType", "None");
        if sub_type == "Casual" or dungeon_type == "WeeklyRaid" or dungeon_type == "FreeDungeon" or dungeon_type == "Challenge_Solo" then
        return "YES";
        end

        local class_name = TryGetProp(indun_cls, "ClassName", "None");
        if class_name == "Goddess_Raid_Vasilissa_Solo" then
            return "YES";
        end
    end

    -- 챌린지 모드 캐주얼 모드
    if IsServerSection() == 1 then
    local isChallengeModePlaying = IsChallengeModePlaying(self);
	if isChallengeModePlaying == 1 then
		local partyObj = GetPartyObj(self);
		if partyObj ~= nil then
			local selectedLevel = GetExProp(partyObj, "ChallengeMode_SelectedLevel");
			if selectedLevel == 2 then
				return "YES";
			end
		end
	end
    else
        local selectedLevel = GetExProp(self, 'ChallengeMode_SelectedLevel')
        if selectedLevel == 2 then
            return 'YES'
        end
    end
    
    return "NO"
end

function IS_ANCIENT_HEAL_ENABLE(self)
    if self == nil then
        self = GetMyPCObject()
    end

    -- 텔 하르샤 4단계 이하
    local mGameName = 'None'
    if IsServerSection() == 1 then
        local cmd = GetMGameCmd(self)
        if cmd ~= nil then
            mGameName = cmd:GetMGameName()
        end
    else
        zoneName = session.GetMapName();
		if zoneName == 'id_irredians_113_1' then
            mGameName = session.mgame.GetCurrentMGameName()
        end
    end
    if mGameName == 'FreeDungeon_Telharsha' then
        local dungeon_level = GetExProp(self, 'sraidC_Total_Level_boss')
        if dungeon_level > 0 and dungeon_level <= 4 then
            return "YES"
        end
    end

    -- 챌린지 1인 모드
    if IsServerSection() == 1 then
        local isChallengeModePlaying = IsChallengeModePlaying(self);
        if isChallengeModePlaying == 1 then
            local partyObj = GetPartyObj(self)
            if partyObj ~= nil then
                local selectedLevel = GetExProp(partyObj, "ChallengeMode_SelectedLevel")
                if selectedLevel == 2 then
                    return "YES"
                end
            end
        end
    else
        local selectedLevel = GetExProp(self, 'ChallengeMode_SelectedLevel')
        if selectedLevel == 2 then
            return 'YES'
        end
    end
    
    return "NO"
end

function IS_ANCIENT_CARD_UI_ENABLE_MAP(zoneName)
    local zoneCls = GetClass("Map", zoneName);
    local mapType = TryGetProp(zoneCls,"MapType","None")
    if mapType == 'City' then
        return true
    end
    return false
end

local function is_contain(tab,elem)
    local guid = elem:GetGuid()
    for i = 1,#tab do
        if tab[i]:GetGuid() == guid then
            return true
        end
    end
    return false
end

function GET_ANCIENT_COMBO_CARD_LIST(combo,cardList)
    table.sort(cardList,SORT_ANCIENT)
    
    local num = combo.MaxApplyCount
    local ret = ""
    for i = 1,num do
        ret = ret..cardList[i].slot..'/'
    end
    return ret
end

function SORT_ANCIENT(a,b)
    if a.rarity ~= b.rarity then
        return a.rarity > b.rarity
    end
    if a.starrank ~= b.starrank then
        return a.starrank > b.starrank
    end
    local a_exp = a:GetStrExp();
    local a_xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(a_exp))
    local a_level = a_xpInfo.level

    local b_exp = b:GetStrExp();
    local b_xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(b_exp))
    local b_level = b_xpInfo.level
    if a_level ~= b_level then
        return a_level > b_level
    end
    return a.slot < b.slot
end
--combo prescp--
function SCR_ANCIENT_COMBO_RACETYPE_PRECHECK(combo, cardList)
    local comboMonList = {}
    local comboCardList = {}
    for i = 1,4 do
        local raceType = TryGetProp(combo,"TypeName_"..i)
        if raceType == nil or raceType == "None" then
            break
        end
        local needCnt = TryGetProp(combo,"TypeNum_"..i)
        local myCnt = 0
        for i = 1,#cardList do
            local cls = GetClass("Monster",cardList[i]:GetClassName())
            if cls ~= nil and TryGetProp(cls,"RaceType") == raceType then
                if table.find(comboMonList, cls.ClassName) == 0 then
                    myCnt = myCnt + 1
                    comboMonList[#comboMonList+1] = cls.ClassName
                    comboCardList[#comboCardList+1] = cardList[i]
                end
            end
        end
        if myCnt < needCnt then
            return "None"
        end
    end
    local slotList_str = GET_ANCIENT_COMBO_CARD_LIST(combo,comboCardList)
    return slotList_str
end

function SCR_ANCIENT_COMBO_ATTRIBUTE_PRECHECK(combo, cardList)
    local comboMonList = {}
    local comboCardList = {}
    for i = 1,4 do
        local raceType = TryGetProp(combo,"TypeName_"..i)
        if raceType == nil or raceType == "None" then
            break
        end
        local needCnt = TryGetProp(combo,"TypeNum_"..i)
        local myCnt = 0
        for i = 1,#cardList do
            local cls = GetClass("Monster",cardList[i]:GetClassName())
            if cls ~= nil and TryGetProp(cls,"Attribute") == raceType then
                if table.find(comboMonList, cls.ClassName) == 0 then
                    myCnt = myCnt + 1
                    comboMonList[#comboMonList+1] = cls.ClassName
                    comboCardList[#comboCardList+1] = cardList[i]
                end
            end
        end
        if myCnt < needCnt then
            return "None"
        end
    end
    local slotList_str = GET_ANCIENT_COMBO_CARD_LIST(combo,comboCardList)
    return slotList_str
end

function SCR_ANCIENT_COMBO_RANK_PRECHECK(combo, cardList)
    local comboMonList = {}
    local comboCardList = {}
    for i = 1, 4 do
        local rank = TryGetProp(combo,"TypeName_"..i)
        if rank == nil or rank == "None" then
            break
        end
        local needCnt = TryGetProp(combo,"TypeNum_"..i)
        local myCnt = 0
        for i = 1,#cardList do
            local cls = GetClass("Monster",cardList[i]:GetClassName())
            if cls ~= nil then
                local infoCls = GetClass("Ancient_Info",cls.ClassName)
                local rarity= infoCls.Rarity
                if tonumber(rank) == tonumber(rarity) then
                    if table.find(comboMonList, cls.ClassName) == 0 then
                        myCnt = myCnt + 1
                        comboMonList[#comboMonList+1] = cls.ClassName
                        comboCardList[#comboCardList+1] = cardList[i]
                    end
                end
            end
        end
        if myCnt < needCnt then
            return "None"
        end
    end
    local slotList_str = GET_ANCIENT_COMBO_CARD_LIST(combo,comboCardList)
    return slotList_str
end
--combo calc--
function GET_ANCIENT_COMBO_CALC_VALUE(combo,cardList)
    local defaultValue = combo.NumArg1
    local lvRate = combo.NumArg2
    local level = 0;
    local starRank = 0;
    local grade = 0;
    for i = 1, #cardList do
        local exp = cardList[i]:GetStrExp();
        local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
        local addLv = xpInfo.level
        if addLv >= PC_MAX_LEVEL then
            addLv = PC_MAX_LEVEL
        end
        level = level + addLv
        
        local cls = GetClass("Monster",cardList[i]:GetClassName())
        local infoCls = GetClass("Ancient_Info",cls.ClassName)
        grade = grade + infoCls.Rarity
        starRank = starRank + cardList[i].starrank
    end
    
    local levelValue = (level/#cardList) * lvRate
    local starRankValue, gradeValue = ANCINET_GRADE_RANK_CALC((starRank/#cardList), (grade/#cardList))
    local value = defaultValue + levelValue * starRankValue *  gradeValue
    if value < 1 then
        value = 1
    end
    return math.floor(value)
end

function GET_ANCIENT_COMBO_PERCENT_CALC_VALUE(combo, cardList)
    local defaultValue = combo.NumArg1
    local maxValue = combo.NumArg2
    local lvRate = (maxValue - defaultValue)/PC_MAX_LEVEL
    
    local level = 0;
    local starRank = 0;
    
    for i = 1, #cardList do
        local exp = cardList[i]:GetStrExp();
        local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
        local addLv = xpInfo.level
        if addLv >= PC_MAX_LEVEL then
            addLv = PC_MAX_LEVEL
        end
        level = level + addLv
        starRank = starRank + cardList[i].starrank
    end
    
    local starRankValue = ANCINET_GRADE_RANK_CALC(math.floor(starRank/#cardList), 1)
    local levelValue = (level/#cardList) * lvRate
    
    local value = defaultValue + (levelValue*starRankValue)
    if value < 1 then
        value = 1
    end
    
    if maxValue < value then
        value = maxValue
    end
    
    return math.floor(value)
end

--Passive calc--
function GET_ANCIENT_CALC_VALUE(infoCls,card)
    local defaultValue = infoCls.NumArg1

    local exp = card:GetStrExp();
    local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
    local level = xpInfo.level
    if level >= PC_MAX_LEVEL then
        level = PC_MAX_LEVEL
    end
        
    local levelValue = level * infoCls.NumArg2
    
    local starRank = card.starrank
    local grade = infoCls.Rarity;
    if starRank == nil or starRank < 1 then
        starRank = 1;
    end
    if grade == nil or grade < 1 then
        grade = 1
    end
    local starRankValue, gradeRankValue = ANCINET_GRADE_RANK_CALC(starRank, grade)
    
    local value = defaultValue + (levelValue * starRankValue * gradeRankValue)
    if value < 1 then
        value = 1
    end
    
    return math.floor(value)
end

function GET_ANCIENT_PERCENT_CALC_VALUE(infoCls,card)
    local defaultValue = infoCls.NumArg1
    local maxValue = infoCls.NumArg2
    local lvRate = (maxValue - defaultValue)/PC_MAX_LEVEL
    
    local exp = card:GetStrExp();
    local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
    local level = xpInfo.level
    if level >= PC_MAX_LEVEL then
        level = PC_MAX_LEVEL
    end
        
    local levelValue = level * lvRate
    
    local starRank = card.starrank
    local grade = infoCls.Rarity;
    if starRank == nil or starRank < 1 then
        starRank = 1;
    end
    if grade == nil or grade < 1 then
        grade = 1
    end
    local starRankValue, gradeRankValue = ANCINET_GRADE_RANK_CALC(starRank, grade)
    
    local value = defaultValue + (levelValue * starRankValue * gradeRankValue)
    if value < 1 then
        value = 1
    end
    
    return math.floor(value)
end

function ANCINET_GRADE_RANK_CALC(starRank, grade)
    local rankValue = 0.5 + (starRank-1) * 0.25
    local gradeValue = 0.4 + (grade-1) * 0.2
    
    return rankValue, gradeValue
end

function GET_ANCIENT_CARD_SLOT_MAX(pc)
    local value = tonumber(ANCIENT_CARD_SLOT_MAX)

    local acc = nil
    if IsServerSection() == 1 then
        acc = GetAccountObj(pc)
    else
        acc = GetMyAccountObj()
    end

    local extra_value = 0
    if acc ~= nil then
        local extend_cnt = TryGetProp(acc, 'ANCIENT_SLOT_EXTEND_COUNT', 0)
        local extend_cls = GetClass('ancient_slot_extend', tostring(extend_cnt))
        if extend_cls ~= nil then
            local extend_slot = TryGetProp(extend_cls, 'ExtendSlot', 0)
            extra_value = extra_value + extend_slot
        end
    end

    value = value + extra_value

    return value
end

function GET_ANCIENT_SLOT_EXTEND_COST(pc)
    local value = nil

    local acc = nil
    if IsServerSection() == 1 then
        acc = GetAccountObj(pc)
    else
        acc = GetMyAccountObj()
    end

    if acc ~= nil then
        local extend_cnt = TryGetProp(acc, 'ANCIENT_SLOT_EXTEND_COUNT', 0)
        local extend_cls = GetClass('ancient_slot_extend', tostring(extend_cnt + 1))
        if extend_cls ~= nil then
            value = TryGetProp(extend_cls, 'ExtendCost', 5000000)
        end
    end

    return value
end

function GET_ANCIENT_SLOT_EXTEND_COUNT(pc)
    local value = 0

    local acc = nil
    if IsServerSection() == 1 then
        acc = GetAccountObj(pc)
    else
        acc = GetMyAccountObj()
    end

    if acc ~= nil then
        local extend_cnt = TryGetProp(acc, 'ANCIENT_SLOT_EXTEND_COUNT', 0)
        local cur_cls = GetClass('ancient_slot_extend', tostring(extend_cnt))
        local next_cls = GetClass('ancient_slot_extend', tostring(extend_cnt + 1))
        if cur_cls ~= nil and next_cls ~= nil then
            local cur_value = TryGetProp(cur_cls, 'ExtendSlot', 10)
            local next_value = TryGetProp(next_cls, 'ExtendSlot', 10)
            value = next_value - cur_value
        elseif extend_cnt == 0 and next_cls ~= nil then
            local next_value = TryGetProp(next_cls, 'ExtendSlot', 10)
            value = next_value
        end
    end

    return value
end






-- 소환수 스탯 계산

-- 대상 공격력 등 갱신
local special_atk_list = {
    'Add_Damage_Atk',
    'Aries_Atk',
    'Slash_Atk',
    'Strike_Atk',
    'Arrow_Atk',
    'Cannon_Atk',
    'Gun_Atk',
    'Magic_Melee_Atk',
    'Magic_Fire_Atk',
    'Magic_Ice_Atk',
    'Magic_Lightning_Atk',
    'Magic_Earth_Atk',
    'Magic_Poison_Atk',
    'Magic_Dark_Atk',
    'Magic_Holy_Atk',
    'Magic_Soul_Atk',
    'Widling_Atk',
    'Paramune_Atk',
    'Forester_Atk',
    'Velnias_Atk',
    'Klaida_Atk',
    'Cloth_Atk',
    'Leather_Atk',
    'Chain_Atk',
    'Iron_Atk',
    'Ghost_Atk',
    'SmallSize_Atk',
    'MiddleSize_Atk',
    'LargeSize_Atk',
    'BOSS_ATK',
}


function SCR_SUMMONED_MON_STATE_CALC(self, owner, skl)
	if self == nil or owner == nil or skl == nil then
        return
    end

	local rateList = {}
    local rate = 0

    rateList['MHP'] = 1
    rateList['ATK'] = 1
    rateList['DEF'] = 1

    if skl.ClassName == 'Sorcerer_Morph' or skl.ClassName == 'Sorcerer_Evocation' then
        skl = GetSkill(owner, 'Sorcerer_Summoning')
        if skl == nil then return end
    end
    
    if skl.ClassName == 'Sorcerer_Summoning' then
        rateList['DEF'] = SCR_Get_Summoning_Ratio(skl) * 0.01
        rateList['MHP'] = SCR_Get_Summoning_Ratio2(skl) * 0.01
        rateList['ATK'] = SCR_Get_Summoning_Ratio3(skl) * 0.01        
        rate = 1
        self.SDR_BM = 5 - self.SDR
    elseif skl.ClassName == 'Sorcerer_SummonSalamion' then
        rateList['ATK'] = SCR_Get_SummonSalamion_Ratio(skl) * 0.01
        rateList['DEF'] = SCR_Get_SummonSalamion_Ratio2(skl) * 0.01
        rateList['MHP'] = SCR_Get_SummonSalamion_Ratio3(skl) * 0.01        
        rate = 1
        self.SDR_BM = 3 - self.SDR
    elseif skl.ClassName == 'Necromancer_RaiseDead' then
        rateList['ATK'] = SCR_GET_RaiseDead_Ratio(skl) * 0.01
        rateList['DEF'] = SCR_GET_RaiseDead_Ratio2(skl) * 0.01
        rateList['MHP'] = SCR_GET_RaiseDead_Ratio3(skl) * 0.01        
        rate = 1
        self.SDR_BM = 1 - self.SDR
    elseif skl.ClassName == 'Necromancer_RaiseSkullarcher' then
        rateList['ATK'] = SCR_GET_RaiseSkullarcher_Ratio(skl) * 0.01
        rateList['DEF'] = SCR_GET_RaiseSkullarcher_Ratio2(skl) * 0.01
        rateList['MHP'] = SCR_GET_RaiseSkullarcher_Ratio3(skl) * 0.01
        rate = 1
        self.SDR_BM = 1 - self.SDR
    elseif skl.ClassName == 'Necromancer_RaiseSkullwizard' then        
        rateList['ATK'] = SCR_GET_RaiseSkullWizard_Ratio(skl) * 0.01
        rateList['DEF'] = SCR_GET_RaiseSkullWizard_Ratio2(skl) * 0.01
        rateList['MHP'] = SCR_GET_RaiseSkullWizard_Ratio3(skl) * 0.01
        rate = 1
        self.SDR_BM = 1 - self.SDR
    elseif skl.ClassName == 'Necromancer_CorpseTower' then
        rate = skl.Level * 0.1
        rateList['MHP'] = 0.8
        rateList['DEF'] = 0.8

        local rate1 = rate
        if rate1 == 0 then
            rate1 = 1
        end
        rateList['ATK'] = SCR_GET_CorpseTower_Ratio3(skl) * 0.01 / rate1
        
        self.SDR_BM = 1 - self.SDR
    elseif skl.ClassName == 'Necromancer_CreateShoggoth' then
        local cardCnt = 0
        local etc = nil
        if IsServerSection() == 1 then
            etc = GetETCObject(owner)
        else
            etc = GetMyEtcObject()
        end

        if etc ~= nil then
            for i = 1, 4 do
                local guid = etc['Necro_bosscardGUID' .. i]
                local card = nil
                if guid ~= nil and guid ~= 'None' then
                    if IsServerSection() == 1 then
                        card = GetInvItemByGuid(owner, guid)
                    else
                        card = session.GetInvItemByGuid(guid)
                    end
                end
                if card ~= nil then
                    cardCnt = cardCnt + 1
                end
            end
        end

        rate = 0.6 + skl.Level * 0.1
        rateList['MHP'] = 1 + cardCnt * 0.1

        local rate1 = rate
        if rate1 == 0 then
            rate1 = 1
        end
        rateList['ATK'] = SCR_Get_CreateShoggoth_Ratio(skl) * 0.01 / rate1
        rateList['DEF'] = SCR_Get_CreateShoggoth_Ratio2(skl) * 0.01 / rate1
        self.SDR_BM = 2 - self.SDR
    end
    
    SUMMON_APPLY_OWNER_STAT_MINUS(self)

    SUMMON_APPLY_OWNER_ATK_DEF(self, owner, rate, rateList)

    SUMMON_APPLY_OWNER_STAT(self, owner, rate)

	local cardRate = GetExProp(owner, 'MON_AVERAGE_ATK_FROM_PC')
	if cardRate ~= 0 then
        local addPATK = math.floor((self.MAXPATK - self.MINPATK) * (cardRate/100))
        local addMATK = math.floor((self.MAXMATK - self.MINMATK) * (cardRate/100))

		self.MINPATK_BM = self.MINPATK_BM + addPATK
		self.MINMATK_BM = self.MINMATK_BM + addMATK
	end

    if IsServerSection() == 1 then
        InvalidateStates(self)
    end
end

--[[
    소환수 스탯 적용 제거 :
    이미 소환되어 있는 소환수의 경우, 미리 적용되어 있던 스탯을 덜어내지 않고 능력치 갱신하게 되면
    공격력 방어력 등이 의도한 수치보다 오버해서 계산되는 문제가 발생할 수 있으므로
    공격력 및 방어력 계산 전에 한 번 덜어낸 후 공방을 갱신할 수 있도록 하기 위함
]]
function SUMMON_APPLY_OWNER_STAT_MINUS(self)
    local stat_list = { 'STR', 'INT', 'CON', 'DR', 'CRTDR', 'BLK', 'HR', 'CRTHR', 'BLK_BREAK' }
    for i, name in ipairs(stat_list) do
        local add_value = GetExProp(self, 'SUMMON_INHERITED_' .. name)
        if add_value ~= 0 then
            self[name .. '_BM'] = self[name .. '_BM'] - add_value
        end
    end
    
    for i, name in ipairs(special_atk_list) do
        local add_value = GetExProp(self, 'SUMMON_INHERITED_' .. name)
        self[name .. '_BM'] = self[name .. '_BM'] - add_value
    end
    if IsServerSection() == 1 then
        InvalidateStates(self)
    end
end

-- 소환수 공방 갱신
function SUMMON_APPLY_OWNER_ATK_DEF(self, owner, rate, rateList)    
    local ownerMATK = math.floor((owner.MINMATK + owner.MAXMATK) / 2)
    local mhpRate = rateList['MHP']
    local atkRate = rateList['ATK']
    local defRate = rateList['DEF']
    
    local owner_MNA = TryGetProp(owner, 'MNA', 1)
    local owner_LV = TryGetProp(owner, 'Lv', 999)
    
    local mna_Rate = math.floor(math.max(1, owner_MNA / owner_LV) * 10)
    mna_Rate = mna_Rate / 10
    
    if IsPVPServer(owner) == 1 then
        mna_Rate = 1
    end
    
    self.MHP_BM = self.MHP_BM + math.floor(owner.MHP * mhpRate * rate * mna_Rate - self.MHP)

    local ratio = atkRate * rate    
    self.MINPATK_BM = self.MINPATK_BM + math.floor(ownerMATK * 0.9 * ratio - self.MINPATK)
    self.MAXPATK_BM = self.MAXPATK_BM + math.floor(ownerMATK * 1.1 * ratio - self.MAXPATK)
    
    self.MINMATK_BM = self.MINMATK_BM + math.floor(ownerMATK * ratio - self.MINMATK)
    self.MAXMATK_BM = self.MAXMATK_BM + math.floor(ownerMATK * ratio - self.MAXMATK)

	self.DEF_BM = self.DEF_BM + math.floor(owner.DEF * defRate * rate - self.DEF)
    self.MDEF_BM = self.MDEF_BM + math.floor(owner.MDEF * defRate * rate - self.MDEF)

    if IsServerSection() == 1 then
        InvalidateStates(self)
    end
end

function SUMMON_APPLY_OWNER_SPECIAL_ATK(self, owner, rate)
    local atkRate = rate
    if atkRate > 1 then
        atkRate = 1
    end

    for _, name in pairs(special_atk_list) do
        local add_value = math.floor(TryGetProp(owner, name, 0) * atkRate)
        self[name .. '_BM'] = self[name .. '_BM'] + add_value
        SetExProp(self, 'SUMMON_INHERITED_' .. name, add_value)
    end
end

-- 소환수 종류별 추가 스탯 적용
function SUMMON_APPLY_OWNER_STAT(self, owner, rate)
    local clsName = TryGetProp(self, 'ClassName')
    local ownerMNA = TryGetProp(owner, 'MNA', 0)
    local addStatRate = ownerMNA / (self.Lv * 4)
    local ownerMNARate = 0.1
    if GetExProp(owner, "ITEM_VIBORA_Necromancer_Lv4") > 0 then
        ownerMNARate = ownerMNARate + 0.2
    end
    
    if clsName == 'pcskill_shogogoth' then
        local add_con = math.floor(ownerMNA * ownerMNARate)
        self.CON_BM = self.CON_BM + add_con
        SetExProp(self, 'SUMMON_INHERITED_CON', add_con)
    elseif clsName == 'pcskill_skullsoldier' or clsName == 'Vibora_Spiritsoldier' then
        local add_con = math.floor(ownerMNA * ownerMNARate)
        self.CON_BM = self.CON_BM + add_con
        SetExProp(self, 'SUMMON_INHERITED_CON', add_con)
    elseif clsName == 'pcskill_skullarcher' or clsName == 'Vibora_Spiritarcher' then
        local add_str = math.floor(ownerMNA * ownerMNARate)
        self.STR_BM = self.STR_BM + add_str
        SetExProp(self, 'SUMMON_INHERITED_STR', add_str)
    elseif clsName == 'pcskill_skullwizard' or clsName == 'Vibora_Spiritwizard' then
        local add_int = math.floor(ownerMNA * ownerMNARate)
        self.INT_BM = self.INT_BM + add_int
        SetExProp(self, 'SUMMON_INHERITED_INT', add_int)
    elseif clsName == 'pcskill_CorpseTower' then
        local add_str = math.floor(ownerMNA * ownerMNARate)
        self.STR_BM = self.STR_BM + add_str
        SetExProp(self, 'SUMMON_INHERITED_STR', add_str)
    elseif GetExProp(self, 'SORCERER_SUMMONING') == 1 then        
        local add_dr = math.floor(TryGetProp(owner, 'DR', 0) * addStatRate)
        local add_crtdr = math.floor(TryGetProp(owner, 'CRTDR', 0) * addStatRate)
        local add_blk = math.floor(TryGetProp(owner, 'BLK', 0) * addStatRate)
        self.DR_BM = self.DR_BM + add_dr
        self.CRTDR_BM = self.CRTDR_BM + add_crtdr
        self.BLK_BM = self.BLK_BM + add_blk
        SetExProp(self, 'SUMMON_INHERITED_DR', add_dr)
        SetExProp(self, 'SUMMON_INHERITED_CRTDR', add_crtdr)
        SetExProp(self, 'SUMMON_INHERITED_BLK', add_blk)
    elseif clsName == 'Saloon' then
        -- nothing
    end
    
    local add_hr = math.floor(TryGetProp(owner, 'HR', 0) * addStatRate)
    local add_crthr = math.floor(TryGetProp(owner, 'CRTHR', 0) * addStatRate)
    local add_blk_break = math.floor(TryGetProp(owner, 'BLK_BREAK', 0) * addStatRate)
    self.HR_BM = self.HR_BM + add_hr
    self.CRTHR_BM = self.CRTHR_BM + add_crthr
    self.BLK_BREAK_BM = self.BLK_BREAK_BM + add_blk_break
    SetExProp(self, 'SUMMON_INHERITED_HR', add_hr)
    SetExProp(self, 'SUMMON_INHERITED_CRTHR', add_crthr)
    SetExProp(self, 'SUMMON_INHERITED_BLK_BREAK', add_blk_break)

    SUMMON_APPLY_OWNER_SPECIAL_ATK(self, owner, addStatRate)

    if IsServerSection() == 1 then
        InvalidateStates(self) -- 가급적 최종적으로 한 번만 호출하려고 했는데, 여기서 호출 안하면 스탯 차이로 인해 최소 공격력이 최대 공격력보다 높아지는 문제 발생함
    end
end

-- SKL_SET_TGT_EXPROP_RECENT