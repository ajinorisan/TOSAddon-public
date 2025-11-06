--- pet_shared.lua

PET_ACTIVATE_COOLDOWN = 5;

PET_STAT_BY_OWNER_RATE = 0.5

function PET_STAT_BY_OWNER(self, statName)
    local value = 0
    local owner = nil
    if IsServerSection() == 1 then
        owner = GetOwner(self)
    else
        owner = GetMyPCObject()
    end

    if owner ~= nil then
        value = TryGetProp(owner, statName, 0) * PET_STAT_BY_OWNER_RATE
    end

    return math.floor(value)
end

function PET_STR(self)
    local ret = GET_MON_STAT(self, self.Lv, "STR") + PET_STAT_BY_OWNER(self, "STR");
    return math.floor(ret);
end

function PET_DEX(self)
    local ret = GET_MON_STAT(self, self.Lv, "DEX") + PET_STAT_BY_OWNER(self, "DEX");
    return math.floor(ret);
end

function PET_CON(self)
    local ret = GET_MON_STAT(self, self.Lv, "CON") + PET_STAT_BY_OWNER(self, "CON");
    return math.floor(ret);
end

function PET_INT(self)
    local ret = GET_MON_STAT(self, self.Lv, "INT") + PET_STAT_BY_OWNER(self, "INT");
    return math.floor(ret);
end

function PET_MNA(self)
    local ret = GET_MON_STAT(self, self.Lv, "MNA") + PET_STAT_BY_OWNER(self, "MNA");
    return math.floor(ret);
end

function PET_GET_MOUNTPATK(self)
    local ret = 0;
    return ret;
end

function PET_GET_MOUNTMATK(self)
    local ret = 0;
    return ret;
end

function PET_GET_MOUNTDEF(self)
    return math.floor(self.DEF * 0.1);
end
 
function PET_GET_MOUNTDR(self)
    return math.floor(self.DR * 0.08);
end
 
function PET_GET_MOUNTMHP(self)
    
    local value = math.floor(self.MHP * 0.25);
    return value;
end

function PET_GET_MOUNTMSPD(self)
    return 0;
end

function PET_MHP_BY_ABIL(statValue)
    return statValue * 27;
end

function PET_GET_MHP(self)
    local owner = self
    if IsZombie(self) ~= 1 then
        owner = GetTopOwner(self)
    end
    
    local lv = TryGetProp(owner, "Lv", 1);
    local standardMHP = lv * 10;
    local byLevel = (standardMHP / 4) * lv;
    local stat = TryGetProp(self, "CON", 1);
    local byStat = (byLevel * (stat * 0.0015)) + (byLevel * (math.floor(stat / 10) * 0.005)) + PET_MHP_BY_ABIL(self.Stat_MHP);
    local value = standardMHP + byLevel + byStat + PET_STAT_BY_OWNER(self, "MHP");
    
    local abilCompMastery4 = GetAbility(owner, 'CompMastery4')
    local abilCompMastery5 = GetAbility(owner, 'CompMastery5')
    if abilCompMastery4 ~= nil and TryGetProp(abilCompMastery4, 'ActiveState', 0) == 1 then
        value = value * 1.25
    end
    if abilCompMastery5 ~= nil and TryGetProp(abilCompMastery5, 'ActiveState', 0) == 1 then
        value = value * 0.75
    end

    if IsBuffApplied(self, 'BeastMaster_Buff') == 'YES' then
        value = value * 1.25
    end

    return math.floor(value);
end

function PET_GET_MHP_C(self, addAbil)
    if addAbil == nil then
        addAbil = 0;
    end
    
    local owner = GetMyPCObject()
    local lv = 1
    if owner ~= nil then
    	lv = TryGetProp(owner, "Lv", 1);
    end
    local standardMHP = lv * 10;
    local byLevel = (standardMHP / 4) * lv;
    local stat = TryGetProp(self, "CON", 1);
    local byStat = (byLevel * (stat * 0.0015)) + (byLevel * (math.floor(stat / 10) * 0.005));
    local value = standardMHP + byLevel + byStat + PET_STAT_BY_OWNER(self, "MHP") + PET_MHP_BY_ABIL(self.Stat_MHP + addAbil);

    local abilCompMastery4 = GetAbility(owner, 'CompMastery4')
    local abilCompMastery5 = GetAbility(owner, 'CompMastery5')
    if abilCompMastery4 ~= nil and TryGetProp(abilCompMastery4, 'ActiveState', 0) == 1 then
        value = value * 1.25
    end
    if abilCompMastery5 ~= nil and TryGetProp(abilCompMastery5, 'ActiveState', 0) == 1 then
        value = value * 0.75
    end

    if IsBuffApplied(self, 'BeastMaster_Buff') == 'YES' then
        value = value * 1.25
    end

    return math.floor(value);
end

function PET_GET_RHP(self)
    local baseMHP = self.MHP;
    local lv = self.Lv;
    local addLv = self.Level;
    local byOwner = PET_STAT_BY_OWNER(self, "RHP");
    local value = (lv + addLv) * 0.5 + self.CON + self.RHP_BM + byOwner;

    if value < 1 then
        value = 1;
    end

    return math.floor(value);
end

function PET_GET_RHPTIME(self)
    local value = 10000
    return value;
end

function PET_ATK_BY_ABIL(statValue)
    return statValue;
end

function PET_ATK(self)
    local addLv = self.Level;
    local atk = self.Lv + self.STR + addLv + PET_ATK_BY_ABIL(self.Stat_ATK) + self.Stat_ATK_BM;

    local average = PET_STAT_BY_OWNER(self, "MINPATK") + PET_STAT_BY_OWNER(self, "MAXPATK");
    if average ~= 0 then
        average = average / 2;
    end

    local value = atk + average

    local owner = GetOwner(self)
    if owner ~= nil then
        local abilCompMastery4 = GetAbility(owner, 'CompMastery4')
        local abilCompMastery5 = GetAbility(owner, 'CompMastery5')
        if abilCompMastery4 ~= nil and TryGetProp(abilCompMastery4, 'ActiveState', 0) == 1 then
            value = value * 0.75
        end
        if abilCompMastery5 ~= nil and TryGetProp(abilCompMastery5, 'ActiveState', 0) == 1 then
            value = value * 1.25
        end
    end

    if value < 1 then
        value = 1
    end

    return math.floor(value);
end

function PET_ATK_C(self, addAbil)
    local addLv = self.Level;
    local atk = self.Lv + self.STR + addLv + PET_ATK_BY_ABIL(self.Stat_ATK + addAbil) + self.Stat_ATK_BM;

    local average = PET_STAT_BY_OWNER(self, "MINPATK") + PET_STAT_BY_OWNER(self, "MAXPATK");
    if average ~= 0 then
        average = average / 2;
    end

    local value = atk + average

    local owner = GetMyPCObject()
    if owner ~= nil then
        local abilCompMastery4 = GetAbility(owner, 'CompMastery4')
        local abilCompMastery5 = GetAbility(owner, 'CompMastery5')
        if abilCompMastery4 ~= nil and TryGetProp(abilCompMastery4, 'ActiveState', 0) == 1 then
            value = value * 0.75
        end
        if abilCompMastery5 ~= nil and TryGetProp(abilCompMastery5, 'ActiveState', 0) == 1 then
            value = value * 1.25
        end
    end

    if value < 1 then
        value = 1
    end

    return math.floor(value);
end

function PET_MINPATK(self)
    local byStat = self.ATK;
    local byBuff = self.PATK_BM
    local value = byStat + byBuff;
    return math.floor(value);
end

function PET_MAXPATK(self)
    local byStat = self.ATK;
    local byBuff = self.PATK_BM
    local value = byStat + byBuff;
    return math.floor(value);
end

function PET_MINMATK(self)
    local byStat = self.ATK;
    local byOwner = PET_STAT_BY_OWNER(self, "MINMATK");
    local byBuff = self.PATK_BM
    local value = byStat + byOwner + byBuff;
    local owner = GetOwner(self)
    if owner ~= nil then
        local abilCompMastery4 = GetAbility(owner, 'CompMastery4')
        local abilCompMastery5 = GetAbility(owner, 'CompMastery5')
        if abilCompMastery4 ~= nil and TryGetProp(abilCompMastery4, 'ActiveState', 0) == 1 then
            value = value * 0.75
        end
        if abilCompMastery5 ~= nil and TryGetProp(abilCompMastery5, 'ActiveState', 0) == 1 then
            value = value * 1.25
        end
    end
    if value < 1 then
        value = 1
    end
    return math.floor(value);
end

function PET_MAXMATK(self)
    local byStat = self.ATK;
    local byOwner = PET_STAT_BY_OWNER(self, "MAXMATK");
    local byBuff = self.PATK_BM
    local value = byStat + byOwner + byBuff;
    local owner = GetOwner(self)
    if owner ~= nil then
        local abilCompMastery4 = GetAbility(owner, 'CompMastery4')
        local abilCompMastery5 = GetAbility(owner, 'CompMastery5')
        if abilCompMastery4 ~= nil and TryGetProp(abilCompMastery4, 'ActiveState', 0) == 1 then
            value = value * 0.75
        end
        if abilCompMastery5 ~= nil and TryGetProp(abilCompMastery5, 'ActiveState', 0) == 1 then
            value = value * 1.25
        end
    end
    if value < 1 then
        value = 1
    end
    return math.floor(value)
end

function PET_SR(self)
    local value = SCR_Get_MON_SR(self) + PET_STAT_BY_OWNER(self, "SR");
    return value;
end

function PET_MHR(self)
    local value = 0;
    local itemStat = PET_STAT_BY_OWNER(self, "MHR")

    value = itemStat + self.MHR_BM;
    return math.floor(value);
end

function PET_BLK(self)
    local byLv = self.Lv;
    local addLv = self.Level;
    local byStat = self.CON;
    local byOwner = PET_STAT_BY_OWNER(self, 'BLK');
    
    local blkrate = (byLv + addLv) * 0.5 + byStat + byOwner + self.BLK_BM;
    local value = blkrate;
    
    return math.floor(value);
end

function PET_BLK_BREAK(self)
    local byLv = self.Lv;
    local addLv = self.Level;
    local byStat = self.MNA;
    local byOwner = PET_STAT_BY_OWNER(self, 'BLK_BREAK');
    
    local value = (byLv + addLv) * 0.5 + byStat + byOwner + self.BLK_BREAK_BM;

    return math.floor(value);
end

function PET_CRTATK(self)
    local byStat = self.STR;
    local byOwner = PET_STAT_BY_OWNER(self, "CRTATK");
    local byBuff = self.CRTATK_BM;
    local value = byStat + byOwner + byBuff;
    return math.floor(value);
end

function PET_CRTHR_BY_ABIL(statValue)
    return statValue;
end

function PET_CRTHR(self)
    local byStat = self.DEX;
    local byOwner = PET_STAT_BY_OWNER(self, "CRTHR");
    local value = byStat + byOwner + PET_CRTHR_BY_ABIL(self.Stat_CRTHR) + self.CRTHR_BM + self.Stat_CRTHR_BM;
    return math.floor(value);
end

function PET_CRTHR_C(self, addAbil)
    local byStat = self.DEX;
    local byOwner = PET_STAT_BY_OWNER(self, "CRTHR");
    local value = byStat + byOwner + PET_CRTHR_BY_ABIL(self.Stat_CRTHR + addAbil) + self.CRTHR_BM + self.Stat_CRTHR_BM;
    return math.floor(value);
end

function PET_CRTDR(self)
    local byStat = self.CON;
    local byOwner = PET_STAT_BY_OWNER(self, 'CRTDR');
    local value = byStat + byOwner + self.CRTDR_BM;
    return math.floor(value);
end

function PET_DEF_BY_ABIL(statValue)
    return statValue;
end

function PET_DEF(self)
    local byLv = self.Lv;
    local addLv = self.Level;
    local byOwner = PET_STAT_BY_OWNER(self, 'DEF');
    local value = (byLv + addLv) / 2 + byOwner + PET_DEF_BY_ABIL(self.Stat_DEF);
    local owner = GetOwner(self)
    if owner ~= nil then
        local abilCompMastery4 = GetAbility(owner, 'CompMastery4')
        local abilCompMastery5 = GetAbility(owner, 'CompMastery5')
        if abilCompMastery4 ~= nil and TryGetProp(abilCompMastery4, 'ActiveState', 0) == 1 then
            value = value * 1.25
        end
        if abilCompMastery5 ~= nil and TryGetProp(abilCompMastery5, 'ActiveState', 0) == 1 then
            value = value * 0.75
        end
    end
    if value < 1 then
        value = 1
    end
    return math.floor(value);
end

function PET_DEF_C(self, addAbil)
    local byLv = self.Lv;
    local addLv = self.Level;
    local byOwner = PET_STAT_BY_OWNER(self, 'DEF');
    local value = (byLv + addLv) / 2 + byOwner + PET_DEF_BY_ABIL(self.Stat_DEF + addAbil);
    local owner = GetMyPCObject()
    if owner ~= nil then
        local abilCompMastery4 = GetAbility(owner, 'CompMastery4')
        local abilCompMastery5 = GetAbility(owner, 'CompMastery5')
        if abilCompMastery4 ~= nil and TryGetProp(abilCompMastery4, 'ActiveState', 0) == 1 then
            value = value * 1.25
        end
        if abilCompMastery5 ~= nil and TryGetProp(abilCompMastery5, 'ActiveState', 0) == 1 then
            value = value * 0.75
        end
    end
    if value < 1 then
        value = 1
    end
    return math.floor(value);
end

function PET_MDEF_BY_ABIL(statValue)
    return statValue;
end

function PET_MDEF(self)
    local byLv = self.Lv;
    local addLv = self.Level;
    local byOwner = PET_STAT_BY_OWNER(self, 'MDEF');
    local value = (byLv + addLv) / 2 + byOwner + PET_MDEF_BY_ABIL(self.Stat_MDEF);
    local owner = GetOwner(self)
    if owner ~= nil then
        local abilCompMastery4 = GetAbility(owner, 'CompMastery4')
        local abilCompMastery5 = GetAbility(owner, 'CompMastery5')
        if abilCompMastery4 ~= nil and TryGetProp(abilCompMastery4, 'ActiveState', 0) == 1 then
            value = value * 1.25
        end
        if abilCompMastery5 ~= nil and TryGetProp(abilCompMastery5, 'ActiveState', 0) == 1 then
            value = value * 0.75
        end
    end
    if value < 1 then
        value = 1
    end
    return math.floor(value);
end

function PET_MDEF_C(self, addAbil)
    local byLv = self.Lv;
    local addLv = self.Level;
    local byOwner = PET_STAT_BY_OWNER(self, 'MDEF');
    local value = (byLv + addLv) / 2 + byOwner + PET_MDEF_BY_ABIL(self.Stat_MDEF + addAbil);
    local owner = GetMyPCObject()
    if owner ~= nil then
        local abilCompMastery4 = GetAbility(owner, 'CompMastery4')
        local abilCompMastery5 = GetAbility(owner, 'CompMastery5')
        if abilCompMastery4 ~= nil and TryGetProp(abilCompMastery4, 'ActiveState', 0) == 1 then
            value = value * 1.25
        end
        if abilCompMastery5 ~= nil and TryGetProp(abilCompMastery5, 'ActiveState', 0) == 1 then
            value = value * 0.75
        end
    end
    if value < 1 then
        value = 1
    end
    return math.floor(value);
end

function PET_SDR(self)
    local value = 1
    if IsPVPServer(self) == 1 then
        value = 0
    end

    return value;
end

function PET_DR_BY_ABIL(statValue)
    return statValue;
end

function PET_DR(self)
    local byLv = self.Lv;
    local addLv = self.Level;
    local byOwner = PET_STAT_BY_OWNER(self, "DR")
    local ret = byLv + addLv + byOwner + self.DEX + PET_DR_BY_ABIL(self.Stat_DR);
    return math.floor(ret);
end

function PET_DR_C(self, addAbil)
    local byLv = self.Lv;
    local addLv = self.Level;
    local byOwner = PET_STAT_BY_OWNER(self, "DR")
    local ret = byLv + addLv + byOwner + self.DEX + PET_DR_BY_ABIL(self.Stat_DR + addAbil);
    return math.floor(ret);
end

function PET_HR_BY_ABIL(statValue)
    return statValue;
end

function PET_HR(self)
    local byLv = self.Lv;
    local addLv = self.Level;
    local byOwner = PET_STAT_BY_OWNER(self, "HR")
    local ret = byLv + addLv + byOwner + self.DEX + PET_HR_BY_ABIL(self.Stat_HR) + self.Stat_HR_BM;
    return math.floor(ret);
end

function PET_HR_C(self, addAbil)
    local byLv = self.Lv;
    local addLv = self.Level;
    local byOwner = PET_STAT_BY_OWNER(self, "HR")
    local ret = byLv + addLv + byOwner + self.DEX + PET_HR_BY_ABIL(self.Stat_HR + addAbil) + self.Stat_HR_BM;
    return math.floor(ret);
end

function GET_PET_STAT_PRICE(pc, pet, statName, val, taxRate)
    local defPrice = 300;
    if statName  == "DEF" then
        defPrice = 600;
    end

    if val == nil then
        val = pet["Stat_" .. statName];
    end 
    local price = math.floor(defPrice * math.pow(1.08, val - 1))
    if taxRate ~= nil then
        price = tonumber(CALC_PRICE_WITH_TAX_RATE(price, taxRate))
    end
    return price;
end

--function PET_ADD_FIRE(self)
--    local value = GetSumOfPetEquip(self, "ADD_FIRE") + self.ADD_FIRE_BM;
--    return value;
--end
--
--function PET_ADD_ICE(self)
--    local value = GetSumOfPetEquip(self, "ADD_ICE") + self.ADD_ICE_BM;
--    return value;
--end
--
--function PET_ADD_LIGHTNING(self)
--    local value = GetSumOfPetEquip(self, "ADD_LIGHTNING") + self.ADD_LIGHTNING_BM;
--    return value;
--end
--
--function PET_ADD_EARTH(self)
--    local value = GetSumOfPetEquip(self, "ADD_EARTH") + self.ADD_EARTH_BM;
--    return value;
--end
--
--function PET_ADD_POISON(self)
--    local value = GetSumOfPetEquip(self, "ADD_POISON") + self.ADD_POISON_BM;
--    return value;
--end
--
--function PET_ADD_HOLY(self)
--    local value = GetSumOfPetEquip(self, "ADD_HOLY") + self.ADD_HOLY_BM;
--    return value;
--end
--
--function PET_ADD_DARK(self)
--    local value = GetSumOfPetEquip(self, "ADD_DARK") + self.ADD_DARK_BM;
--    return value;
--end
--
--function PET_Fire_Def(self)
--    local value = GetSumOfPetEquip(self, "Fire_Def") + self.Fire_Def_BM;
--    return value;
--end
--
--function PET_Ice_Def(self)
--    local value = GetSumOfPetEquip(self, "Ice_Def") + self.Ice_Def_BM;
--    return value;
--end
--
--function PET_Lightning_Def(self)
--    local value = GetSumOfPetEquip(self, "Lightning_Def") + self.Lightning_Def_BM;
--    return value;
--end
--
--function PET_Earth_Def(self)
--    local value = GetSumOfPetEquip(self, "Earth_Def") + self.Earth_Def_BM;
--    return value;
--end
--
--function PET_Poison_Def(self)
--    local value = GetSumOfPetEquip(self, "Poison_Def") + self.Poison_Def_BM;
--    return value;
--end
--
--function PET_Holy_Def(self)
--    local value = GetSumOfPetEquip(self, "Holy_Def") + self.Holy_Def_BM;
--    return value;
--end
--
--function PET_Dark_Def(self)
--    local value = GetSumOfPetEquip(self, "Dark_Def") + self.Dark_Def_BM;
--    return value;
--end

function PET_REVIVE_PRICE(obj)
    return 100;
end

function CHECK_PET_IS_DEAD(obj, petObj, serverSysTime)

    local lifeMin = petObj.LifeMin;
    local learnAbilTime = imcTime.GetSysTimeByStr(obj.AdoptTime);
    local difSec = imcTime.GetDifSec(serverSysTime, learnAbilTime);
    local difMin = difSec / 60;
    local overMinute = difMin - lifeMin;
    local overDate = GET_PET_OVER_DATE(overMinute);
    if overDate >= 10 then
        return 1;
    end

    return 0;

end

function GET_PET_OVER_DATE(overMinute)

    -- return math.floor(overMinute / 1440) + 1;
    return overMinute * 10;
end