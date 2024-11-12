--- calc_property_skill.lua

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function HAS_DRAGON_POWER(pc)
    if pc == nil  then
        return false
    end

    if IsServerSection() == 1 then
        if pc ~= nil then
            local isDragonPower = GetExProp(pc, 'ITEM_DRAGON_POWER')
            if tonumber(isDragonPower) >= 1 then
                return true
            end
        end
    else
        local seal  = GetEquipItem(pc, 'SEAL');
        if seal == nil then 
            return false
        end
        local option = TryGetProp(seal, 'SealOption_3', 'None')
        if option == 'ITEM_DRAGON_POWER' then
            return true
        end
    end

    return false
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function GET_SKL_VALUE(skill, startValue, maxValue)
    local maxLv = 100;
    local curLv = skill.Level;
    local rate = curLv / maxLv;
    rate = math.pow(rate, 0.7);
    return startValue + rate * (maxValue - startValue);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_ATK(skill)
    local value = skill.SklATKValue;
    local propvalue = GetClassNumber('SklRankUp', skill.ATKRankType, 'IncreaseValue');
    value = value + skill.SklATK_BM * propvalue;
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_CastTime(skill)
    local value = skill.CastTimeValue;
    value = value + skill.CastTime_BM;
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.(bind::GetSkillRestrictArg(imcIES::IObject* pc, const imc::StringID& skillClassName, imc::StringID& coolDownClassify, float& zoneAddCoolDown))
function SCR_GET_SKILL_RESTRICT_ARG(pc, skill)
    local cls = GetClassList("SkillRestrict");
    local sklCls = GetClassByNameFromList(cls, skill.ClassName);
    local coolDownClassify = nil;
    local zoneAddCoolDown = 0;
    
    if sklCls ~= nil then
        local isKeyword = TryGetProp(sklCls, "Keyword", nil)
        if IsRaidField(pc) == 1 then
            if string.find(isKeyword, "IsRaidField") == 1 then
                local addCoolDown = TryGetProp(sklCls, "Raid_CoolDown", nil)
                addCoolDown = StringSplit(addCoolDown, "/");
                coolDownClassify, zoneAddCoolDown = addCoolDown[1], addCoolDown[2]
            end
        elseif IsPVPField(pc) == 1 then
            if string.find(isKeyword, "IsPVPField") == 1 then
                local addCoolDown = TryGetProp(sklCls, "PVP_CoolDown", nil)
                addCoolDown = StringSplit(addCoolDown, "/");
                coolDownClassify, zoneAddCoolDown = addCoolDown[1], addCoolDown[2]
            end
        end
    end
    
    return coolDownClassify, zoneAddCoolDown
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_CoolDown(skill)
    local pc = GetSkillOwner(skill);
    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)
    
    local value = skill.CoolDownValue;
    local propvalue = GetClassNumber('SklRankUp', skill.CoolDownRankType, 'IncreaseValue');
    value = value + skill.CoolDown_BM * propvalue;
    
    if coolDownClassify == "Fix" then
        value = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        value = zoneAddCoolDown + value
    end

    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SpendSP_Dargoon(skill)
    local value = SCR_Get_SpendSP(skill)
    local pc = GetSkillOwner(skill);
    
    if value < 1 then
        value = 0
    end
    
    local addValue = 1
    local pcLevel = TryGetProp(pc, "Lv", 1)
    local mnaRate = TryGetProp(pc, "MNA", 1)    
    
    if IsBuffApplied(pc, "DragoonHelmet_Buff") == "YES" then
        addValue = 2
        addValue = addValue - math.min(0.5, mnaRate / pcLevel)
        value = math.floor(value * addValue)        
    elseif IsBuffApplied(pc, "DragoonHelmet_Abil_Buff") == "YES" then
        addValue = 1.5
        addValue = addValue - math.min(0.5, mnaRate / pcLevel)
        value = math.floor(value * addValue)
    end
    
    return math.floor(value);
end

function SCR_TOSHero_Tear1_ManaBurn(skill, value)
	local CD = TryGetProp(skill, "CoolDown", 0)
	if CD > 0 and CD <= 10000 then
		value = value * 2
	elseif CD > 10000 and CD < 20000 then
		value = value * 3
	elseif CD >= 20000 then
		value = value * 4
	end

	return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SpendSP(skill)
    local basicSP = skill.BasicSP;
--    local lv = skill.Level;
--    local lvUpSpendSp = skill.LvUpSpendSp;
    local bylvCorrect = 0

    local pc = GetSkillOwner(skill);

    if TryGetProp(skill, "ClassName", "None") == "Pardoner_Simony" then
        local abilPardoner21 = GetAbility(pc, "Pardoner21")
        if abilPardoner21 ~= nil and TryGetProp(abilPardoner21, "ActiveState", 0) == 1 then
            basicSP = 90
        end
    end
    
    if basicSP == 0 then
        return 0;
    end

    if pc == nil and ui.GetFrame("pub_createchar"):IsVisible() == 1 then
        return basicSP;
    end

    local lv = pc.Lv
    bylvCorrect = lv - 300

    if bylvCorrect < 0 then
        bylvCorrect = bylvCorrect * 2.75 / 1000
    elseif bylvCorrect >= 0 then
        bylvCorrect = bylvCorrect * 1.25 / 1000
    end

    local value = basicSP * (1 + bylvCorrect)
    
    local abilAddSP = GetAbilityAddSpendValue(pc, skill.ClassName, "SP");
    abilAddSP = abilAddSP / 100;

--    local lvUpSpendSpRound = math.floor((lvUpSpendSp * 10000) + 0.5)/10000;

--  value = basicsp + (lv - 1) * lvUpSpendSpRound + abilAddSP;
--  value = basicsp + (lv - 1) * lvUpSpendSpRound;
    value = math.floor(value) + math.floor(value * abilAddSP);
   
    local decByZemina = 0
    local zeminaSP = GetExProp(pc, "ZEMINA_BUFF_SP");
    if zeminaSP ~= 0 then
        decByZemina = value * zeminaSP
    end
    value = value - decByZemina;
    
    --burning_event
    local decByBuff = 0
    if IsBuffApplied(pc, "Event_Cooldown_SPamount_Decrease") == "YES" then
        decByBuff = SCR_COOLDOWN_SPAMOUNT_DECREASE(pc, "SpendSP", value)
    elseif IsBuffApplied(pc, "FIELD_SP_FULL_BUFF") == "YES" then
        decByBuff = SCR_FIELD_DUNGEON_CONSUME_DECREASE(pc, "SpendSP", value)
    elseif IsBuffApplied(pc, 'premium_seal_2021_buff') == 'YES' and IsBuffApplied(pc, 'Event_Cooldown_SPamount_Decrease') == 'NO' and SCR_IS_LEVEL_DUNGEON(pc) == 'YES' then
		decByBuff = value * 0.5
	else
        if IsBuffApplied(pc, "Gymas_Buff") == "YES" then -- 기마스
            local ratio = 0.5;
            decByBuff = value * ratio
        end
    end
    value = value - decByBuff;
    ----------
	
    if value < 1 then
        value = 0
    end
    
    if skill.ClassName == "Scout_Cloaking" and IsBattleState(pc) == 1 and (IsPVPServer(pc) == 1 or IsPVPField(pc) == 1) then
        return 0
    end

    if skill.ClassName == 'Oracle_CounterSpell' and GetExProp(pc, 'ITEM_VIBORA_Aura_LV4') > 0 then
        return 0
    end

	if IsBuffApplied(pc, "ManaAmplify_Buff") == "YES" then
        value = value * 1.5
    end
	
	if IS_TOS_HERO_ZONE(pc) == "YES" and GetExProp(pc, "TOSHero_Tear1_ManaBurn") > 0 then
		value = SCR_TOSHero_Tear1_ManaBurn(skill, value)
	end

	if IS_TOS_HERO_ZONE(pc) == "YES" and GetExProp(pc, "TOSHero_Tear2_ManaBurn") > 0 and TryGetProp(skill, "ValueType", "None") == "Attack" then
		value = value * 2
	end

    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SpendSP_Magic(skill)--여기
    local value = SCR_Get_SpendSP(skill)
--    local basicsp = skill.BasicSP;
--    local lv = skill.Level;
--    local lvUpSpendSp = skill.LvUpSpendSp;
--    local decsp = 0;
--    
--    if basicsp == 0 then
--        return 0;
--    end
--    
    local pc = GetSkillOwner(skill);

    if pc == nil then
        return math.floor(value);
    end
--
--    local abilAddSP = GetAbilityAddSpendValue(pc, skill.ClassName, "SP");
--    abilAddSP = abilAddSP / 100;
--    
--    local value = basicsp + (lv - 1) * lvUpSpendSp + abilAddSP;
--    local value = basicsp + (lv - 1) * lvUpSpendSp;
    
    if IsBuffApplied(pc, 'Wizard_Wild_buff') == 'YES' then
        value = value * 1.5 * spRatio;
        return math.floor(value);
    end
    
    if IsBuffApplied(pc, 'MalleusMaleficarum_Debuff') == 'YES' then
        value = value * 2
        return math.floor(value);
    end
    
    if TryGetProp(skill, "ClassName", "None") == "Cleric_Heal" then
        local jobHistory = '';
        if IsServerObj(pc) == 1 then
            if IS_PC(pc) == true then
                jobHistory = GetJobHistoryString(pc);
            end
        else
            jobHistory = GetMyJobHistoryString();
        end
        
        local jobList = GetJobHistoryList(pc)
        for i = 1, #jobList do
            if jobList[i] == 4002 then
                value = value - 25
            end
        end

        -- if jobHistory ~= nil and string.find(jobHistory, "Char4_2") ~= nil then
        --     value = value - 25
        -- end
        
        if jobHistory ~= nil and string.find(jobHistory, "Char4_10") ~= nil then
            value = value - 50
        end
    end
    
--    value = value + (value * abilAddSP);
--    
--    local zeminaLv = GetExProp(pc, "ZEMINA_BUFF_LV");
--    if zeminaLv > 0 then
--        decsp = 4 + (zeminaLv * 4);
--    end
--    value = value - decsp;
    
    if value < 1 then
        value = 0
    end
    if IsBuffApplied(pc, 'ShadowPool_Buff') == 'YES' and (skill.ClassName == "Shadowmancer_ShadowPool" or skill.ClassName == "Common_Shadowmancer_ShadowPool") then
        value = 0;
    end
    
    if skill.ClassName == "Oracle_TwistOfFate" and 
        (GetZoneName(pc) == "guild_agit_1" or GetZoneName(pc) == "guild_agit_extension") then
        return 0
    end

    return math.floor(value);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SpendSP_Praise(skill)
    local basicSP = skill.BasicSP;
    local decsp = 0;
    local bylvCorrect = 0

    local pc = GetSkillOwner(skill);
    
    if basicSP == 0 then
        return 0;
    end

    if pc == nil and ui.GetFrame("pub_createchar"):IsVisible() == 1 then
        return basicSP;
    end

    local lv = pc.Lv
    bylvCorrect = lv - 300

    if bylvCorrect < 0 then
        bylvCorrect = bylvCorrect * 2.75 / 1000
    elseif bylvCorrect >= 0 then
        bylvCorrect = bylvCorrect * 1.25 / 1000
    end

    local skillLv = TryGetProp(skill, "Level", 1)
    local value = basicSP * (1 + bylvCorrect) * (1 - ((skillLv - 1) * 0.1))
    
    local abilAddSP = GetAbilityAddSpendValue(pc, skill.ClassName, "SP");
    abilAddSP = abilAddSP / 100;
    value = math.floor(value) + math.floor(value * abilAddSP);
   
    local zeminaSP = GetExProp(pc, "ZEMINA_BUFF_SP");
    if zeminaSP ~= 0 then
        decsp = value * zeminaSP
    end
   
    value = value - decsp;
    
    --burning_event
    if IsBuffApplied(pc, "Event_Cooldown_SPamount_Decrease") == "YES" then
        decsp = SCR_COOLDOWN_SPAMOUNT_DECREASE(pc, "SpendSP", value)
    elseif IsBuffApplied(pc, "FIELD_SP_FULL_BUFF") == "YES" then
        decsp = SCR_FIELD_DUNGEON_CONSUME_DECREASE(pc, "SpendSP", value)
    elseif IsBuffApplied(pc, 'premium_seal_2021_buff') == 'YES' and IsBuffApplied(pc, 'Event_Cooldown_SPamount_Decrease') == 'NO' and SCR_IS_LEVEL_DUNGEON(pc) == 'YES' then
		decsp = value * 0.5
	else
        if IsBuffApplied(pc, "Gymas_Buff") == "YES" then -- 기마스
            local ratio = 0.5;
            decsp = value * ratio
        end
    end
	
    ----------
    value = value - decsp;
    if value < 1 then
        value = 0
    end

	if IsBuffApplied(pc, "ManaAmplify_Buff") == "YES" then
        value = value * 1.5
    end
	
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SpendSP_EnableCompanion_Warrior(skill)
    local value = SCR_Get_SpendSP(skill)
    local pc = GetSkillOwner(skill)
    
    if value < 1 then
    value = 0
    end
    
    if IsBuffApplied(pc, "AcrobaticMount_Buff") == "YES" then
        if TryGetProp(skill, "EnableCompanion") == "YES" and TryGetProp(skill, "ValueType") == "Attack" then            
            if IsServerSection() == 1 then                
                local acrobaticBuff = GetBuffByName(pc, "AcrobaticMount_Buff")
                local acrobaticBuffLevel = GetBuffArg(acrobaticBuff)
                local acrobaticAddSPRate = acrobaticBuffLevel * 0.05
                value = value *(1 + acrobaticAddSPRate)
                SetExProp(acrobaticBuff, "ACROBATICMOUNT_SPENDSP", math.floor(value));
            else                
                local acrobaticBuff = GET_BUFF_BY_NAME_C("AcrobaticMount_Buff");
                local acrobaticBuffLevel = acrobaticBuff.arg1;
                local acrobaticAddSPRate = acrobaticBuffLevel * 0.05
                value = value *(1 + acrobaticAddSPRate)
            end
        end
    end

    return math.floor(value)
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SpendSP_AstralBodySmite(skill)

    local basicSP = 25;
--    local lv = skill.Level;
--    local lvUpSpendSp = 4;
    local decsp = 0;
    local bylvCorrect = 0 
    
    if basicsp == 0 then
        return 0;
    end
    
    local pc = GetSkillOwner(skill);
    local lv = pc.Lv
    bylvCorrect = lv - 300

    if bylvCorrect < 0 then
        bylvCorrect = bylvCorrect * 2.75 / 1000
    elseif bylvCorrect >= 0 then
        bylvCorrect = bylvCorrect * 1.25 / 1000
    end

    local value = basicSP * (1 + bylvCorrect)

    local abilAddSP = GetAbilityAddSpendValue(pc, skill.ClassName, "SP");
    abilAddSP = abilAddSP / 100;
    
--  local value = basicsp + (lv - 1) * lvUpSpendSp + abilAddSP;
--    local value = basicsp + (lv - 1) * lvUpSpendSp;
    
    if IsBuffApplied(pc, 'Wizard_Wild_buff') == 'YES' then
        value = value * 1.5;
        return math.floor(value);
    end
    
    if IsBuffApplied(pc, 'MalleusMaleficarum_Debuff') == 'YES' then
        value = value * 2
        return math.floor(value);
    end    
    
    value = value + (value * abilAddSP);
    
    local zeminaLv = GetExProp(pc, "ZEMINA_BUFF_LV");
    if zeminaLv > 0 then
        decsp = 4 + (zeminaLv * 4);
    end
    value = value - decsp;
    
    local buffOver = GetBuffOver(pc, "Sadhu_Soul_Buff")
    if buffOver > 0 then
        value = value + (value * (0.2 * buffOver))
    end

    if value < 1 then
        value = 0
    end

    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SpendSP_FanaticIllusion(skill)

    local basicSP = 25;
--    local lv = skill.Level;
--    local lvUpSpendSp = 4;
    local decsp = 0;
    local bylvCorrect = 0 
    
    if basicsp == 0 then
        return 0;
    end
    
    local pc = GetSkillOwner(skill);
    local lv = pc.Lv
    bylvCorrect = lv - 300

    if bylvCorrect < 0 then
        bylvCorrect = bylvCorrect * 2.75 / 1000
    elseif bylvCorrect >= 0 then
        bylvCorrect = bylvCorrect * 1.25 / 1000
    end

    local value = basicSP * (1 + bylvCorrect)

    local abilAddSP = GetAbilityAddSpendValue(pc, skill.ClassName, "SP");
    abilAddSP = abilAddSP / 100;
    
--  local value = basicsp + (lv - 1) * lvUpSpendSp + abilAddSP;
--    local value = basicsp + (lv - 1) * lvUpSpendSp;
    
    if IsBuffApplied(pc, 'Wizard_Wild_buff') == 'YES' then
        value = value * 1.5;
        return math.floor(value);
    end
    
    if IsBuffApplied(pc, 'MalleusMaleficarum_Debuff') == 'YES' then
        value = value * 2
        return math.floor(value);
    end    
    
    value = value + (value * abilAddSP);
    
    local zeminaLv = GetExProp(pc, "ZEMINA_BUFF_LV");
    if zeminaLv > 0 then
        decsp = 4 + (zeminaLv * 4);
    end
    value = value - decsp;
    
    if value < 1 then
        value = 0
    end

    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SpendPoison(skill)

    local lv = skill.Level;
    local lvUpSpendPoison = skill.LvUpSpendPoison;
    local basicsp = skill.BasicPoison + lvUpSpendPoison * (lv - 1);
    
    local pc = GetSkillOwner(skill)
    --[[ local abil = GetAbility(pc, "SavePoison")
    if abil ~= nil then 
        basicsp = basicsp - (basicsp * (abil.Level * 0.01))
    end ]]
    
    if basicsp == 0 then
        return 0;
    end
    
    return math.floor(basicsp)

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Skill_STA(skill)
    local basicsta = skill.BasicSta;
    if basicsta == 0 then
        return 0;
    end

    local pc = GetSkillOwner(skill);
    return basicsta * 1000;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Skill_SubweaponCancel_STA(skill)
    local basicsta = skill.BasicSta;
    if basicsta == 0 then
        return 0;
    end

    local pc = GetSkillOwner(skill);
    local jolly = GetSkill(pc, 'Corsair_JollyRoger')
    if jolly ~= nil and IsBuffApplied(pc, 'JollyRoger_Buff') == 'YES' then
        basicsta = basicsta - (basicsta * (jolly.Level * 0.05))
    end
    return basicsta * 1000
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Skill_DoublePunch_STA(skill)

    local basicsta = skill.BasicSta;
    if basicsta == 0 then
        return 0;
    end

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, 'Monk10')
    if abil ~= nil and abil.ActiveState == 1 then
        local random = IMCRandom(1,100);
        if random >= 51 then
            basicsta = basicsta / 2
        else
            return basicsta * 1000;
        end
    end
    return basicsta * 1000;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_CAST(skill)

    local pc = GetSkillOwner(skill);
    local basicCast = skill.BasicCast;
    if basicCast == 0 then
        return 0;
    end
    return basicCast * (100 - pc.SPEED_BM) / 100;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BonusSkilDam(skill)

    return skill.BonusDam;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_CAST_ABIL(skill)

    local basicCast = skill.BasicCast;
    return basicCast;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_READY(skill)

    local pc = GetSkillOwner(skill);
    local stnTime = GetStanceReadyTime(pc);
    local sklFix = skill.ReadyFix;
    local byItem = GetSumOfEquipItem(pc, "ReadyFix");
    local resultValue = stnTime + sklFix + byItem;
    resultValue = resultValue * skill.SkillASPD;
    
    return math.max(0, resultValue);

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_READY_ARC(skill)

    local pc = GetSkillOwner(skill);
    local stnTime = GetStanceReadyTime(pc);
    local sklFix = skill.ReadyFix;
    local resultValue = stnTime + sklFix;

    return math.max(0, resultValue);

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_HITCOUNT(skill)
    
    return skill.SklHitCount;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_HITCOUNT_BOW(skill)

    local pc = GetSkillOwner(skill);
    local rItem  = GetEquipItem(pc, 'RH');
    local weaponType = rItem.ClassType;

    if weaponType == 'Bow' then
        if rItem.ArrowCount ~= 0 then
            return rItem.ArrowCount;
        end
    end

    return skill.SklHitCount;
end   

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_READY_RF(skill)

    local pc = GetSkillOwner(skill);
    local stnTime = GetStanceReadyTime(pc);
    local sklFix = skill.ReadyFix;
    local resultValue = stnTime + sklFix + pc.ASPD;

    return math.max(0, resultValue);

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN(skill)    
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)
    
    if skill.ClassName == "Cleric_Cure" then
        local jobHistory = '';
        if IsServerObj(pc) == 1 then
            if IS_PC(pc) == true then
                jobHistory = GetJobHistoryString(pc);
            end
        else
            jobHistory = GetMyJobHistoryString();
        end

        local curJobHistory = StringSplit(jobHistory, ";")
        local jobList = {"Char4_7", "Char4_18", "Char4_8", "Char4_15", "Char4_10", "Char4_2", "Char4_14"}
        for i = 1, #jobList do
            for j = 1, #curJobHistory do
                if jobHistory ~= nil and jobList[i] == curJobHistory[j] then
                    basicCoolDown = basicCoolDown - 3000
                end
            end
        end

        if basicCoolDown < 1000 then
            basicCoolDown = 1000
        end
    end
    
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local abilPriest39 = GetAbility(pc, 'Priest39')
    if IsPVPServer(pc) == 1 then
        if skill.ClassName == "Cleric_Heal" then
            basicCoolDown = basicCoolDown + 2000
        end

        if skill.ClassName == "Priest_Revive" then
            basicCoolDown = 900000
        end

        if TryGetProp(skill, "ClassName", "None") == "Priest_Resurrection" then
            if abilPriest39 == nil or TryGetProp(abilPriest39, 'ActiveState', 0) == 0 then
                basicCoolDown = 900000
            end
        end
    end

    if IsJoinColonyWarMap(pc) == 1 then
        if TryGetProp(skill, "ClassName", "None") == "Priest_Resurrection" then
            if abilPriest39 == nil or TryGetProp(abilPriest39, 'ActiveState', 0) == 0 then
                basicCoolDown = 600000
            end
        end
    end

    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end

    -- 시련 스킬 재사용 대기시간 증가
    local tb_add_cool_down_rate = GetExProp(pc, "tb_add_cool_down_rate");
    if tb_add_cool_down_rate > 0 then
        local add_value = math.floor(ret * tb_add_cool_down_rate);
        ret = ret + add_value;
    end
    
    return math.floor(ret);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Lydeti(skill)    
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)
    
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)

    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        basicCoolDown = 80000
    end

    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end

    return math.floor(ret);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Karys(skill)    
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)
    
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    if IsPVPServer(pc) == 1 then
        basicCoolDown = 300000
    end

    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Ezera(skill)    
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)
    
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    if IsPVPServer(pc) == 1 then
        basicCoolDown = 300000
    end

    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_ADD_LEVEL_BYGEM(skill)
    
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    
    local level = TryGetProp(skill, "Level", 1)
    local decreaseCoolDown = math.floor(basicCoolDown * (level-1) * 0.05)

    if decreaseCoolDown > basicCoolDown then
        decreaseCoolDown = basicCoolDown
    end
    
    basicCoolDown = basicCoolDown - decreaseCoolDown 

    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)
    
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_ADD_LEVEL_BYGEM_VAKARINE(skill)
    
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    
    local level = TryGetProp(skill, "Level", 1)
    local decreaseCoolDown = math.floor(basicCoolDown * (level-1) * 0.1)

    if decreaseCoolDown > basicCoolDown then
        decreaseCoolDown = basicCoolDown
    end
    
    basicCoolDown = basicCoolDown - decreaseCoolDown 

    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)

    if GetExProp(pc, "ITEM_VIBORA_Dievdirbys") > 0 then
        basicCoolDown = 180000
    end
    
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_ADD_LEVEL_SWIFTMOVE(skill)
    local pc = GetSkillOwner(skill);
    local basic_cool_down = skill.BasicCoolDown;
    
    local level = TryGetProp(skill, "Level", 1);
    local decrease_cool_down = (level - 1) * 1000;
    if decrease_cool_down > basic_cool_down then
        decrease_cool_down = basic_cool_down;
    end

    basic_cool_down = basic_cool_down - decrease_cool_down;

    local abil_add_cool_down = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basic_cool_down = basic_cool_down + abil_add_cool_down;
    
    local cool_down_classify, zone_add_cool_down = SCR_GET_SKILL_RESTRICT_ARG(pc, skill);
    basic_cool_down = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basic_cool_down);
    
    local ret = math.floor(basic_cool_down) / 1000;
    ret = math.floor(ret) * 1000;
    if cool_down_classify == "Fix" then
        ret = zone_add_cool_down;
    elseif cool_down_classify == "Add" then
        ret = zone_add_cool_down + ret;
    end
    return math.floor(ret);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_AssaultFire(skill)  
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)
    
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)

    local abilSchwarzereiter18 = GetAbility(pc, "Schwarzereiter18")
    if abilSchwarzereiter18 ~= nil and TryGetProp(abilSchwarzereiter18, "ActiveState", 0) == 1 then
        basicCoolDown = basicCoolDown + 10000
    end

    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Bunshin_no_jutsu(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown - (TryGetProp(skill, "Level", 0) * 1000);
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    return math.floor(ret);    
end
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_KaguraDance(skill)
    local pc = GetSkillOwner(skill)

    local level = TryGetProp(skill, "Level", 0)
    local abil = GetAbility(pc, "Miko18")
    if abil ~= nil and TryGetProp(abil, 'ActiveState', 0) == 1 then
        if level > 5 then
            level = 5
        end
    end

    local basicCoolDown = skill.BasicCoolDown - ((level - 1) * 5000)
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown")
    basicCoolDown = basicCoolDown + abilAddCoolDown
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000
    ret = math.max(1000, ret)
    return ret
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_BUNSIN(skill)
    
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    if IsServerSection() == 1 and GetExProp(pc, "BUNSIN_VIBORA_DAGGER") ~= 0 then
        basicCoolDown = 0
    end

    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    return math.floor(ret);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_PrimeAndLoad(skill)
    
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    local abilMusketeer29 = GetAbility(pc, "Musketeer29")
    if abilMusketeer29 ~= nil and abilMusketeer29.ActiveState == 1 then
        basicCoolDown = basicCoolDown - (abilMusketeer29.Level * 1000);
    end
    
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)

    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;   
    return math.floor(ret);

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_CounterSpell(skill)
    
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown  - (skill.Level * 1000);
    
    if skill.ClassName == "Cleric_Heal" then
        if IsPVPServer(pc) == 1 then
            basicCoolDown = basicCoolDown + 28000
        end
    end
    
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    
    ret = math.floor(ret) * 1000;
    
    return math.floor(ret);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_ABIL(skill)

    local basicCoolDown = skill.BasicCoolDown;
    return basicCoolDown;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_CoolDown_BackSlide(skill)
    
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = (basicCoolDown + abilAddCoolDown) - (skill.Level * 1000);
    
    if skill.ClassName == "Cleric_Heal" then
        if IsPVPServer(pc) == 1 then
            basicCoolDown = basicCoolDown + 28000
        end
    end
    
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    
    return math.floor(ret);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Preparation(skill)
    
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = (basicCoolDown + abilAddCoolDown) - ((skill.Level - 1) * 1000);
    
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    
    return math.floor(ret);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_CoolDown_Prevent(skill)
    
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = (basicCoolDown + abilAddCoolDown) - (SCR_GET_Prevent_Ratio(skill) * 1000);
    
    if skill.ClassName == "Cleric_Heal" then
        if IsPVPServer(pc) == 1 then
            basicCoolDown = basicCoolDown + 28000
        end
    end
    
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if ret <= 45000 then
        ret = 45000
    end
    return math.floor(ret);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_MISTWIND(skill)

    local basicCoolDown = skill.BasicCoolDown;
    local pc = GetSkillOwner(skill);
    
    basicCoolDown = basicCoolDown - 100 * pc.INT;
    
    if pc.MistWind_BM > 0 then
        return basicCoolDown * (100 - pc.MistWind_BM) / 100;
    end
    
    if basicCoolDown < skill.MinCoolDown then
        return skill.MinCoolDown;
    end

    return basicCoolDown;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Golden_Bell_Shield(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    basicCoolDown = basicCoolDown - (skill.Level * 1000);
    if basicCoolDown < 0 then
        basicCoolDown = 0;
    end
    
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    
    basicCoolDown = basicCoolDown + abilAddCoolDown;
        
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    if IsPVPServer(pc) == 1 then
        basicCoolDown = basicCoolDown + 10000;
    end

    return math.floor(basicCoolDown);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_VisibleTalent(skill)
    
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown  - ((skill.Level - 1) * 1000);
    
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    
    ret = math.floor(ret) * 1000;
    
    return math.floor(ret);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Chronomancer_Stop(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown  - ((skill.Level - 1) * 2000);
    
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    
    ret = math.floor(ret) * 1000;
    
    return math.floor(ret);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_WIZARD(skill)    
    local pc = GetSkillOwner(skill);
    
    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)
    
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)

    if IsPVPServer(pc) == 1 then
        if skill.ClassName == "Chronomancer_BackMasking" then
            basicCoolDown = 900000
        end

        local abilChronomancer12 = GetAbility(pc, "Chronomancer12")
        if skill.ClassName == "Chronomancer_Samsara" and abilChronomancer12 ~= nil and TryGetProp(abilChronomancer12, "ActiveState", 0) == 1 then
            basicCoolDown = 900000
        end
    end
    
    if basicCoolDown < skill.MinCoolDown then
        return skill.MinCoolDown;
    end
    
    if coolDownClassify == "FIX" then
        basicCoolDown = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        basicCoolDown = zoneAddCoolDown + basicCoolDown
    end
    
    return basicCoolDown;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Teleportation(skill)
    local pc = GetSkillOwner(skill);
    
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    
    basicCoolDown = (basicCoolDown - (TryGetProp(skill, "Level", 0) - 1) * 1000) + abilAddCoolDown;
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    if basicCoolDown < skill.MinCoolDown then
        return skill.MinCoolDown;
    end
    
    return basicCoolDown;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_SummonFamiliar(skill)

    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)

    if basicCoolDown < skill.MinCoolDown then
        return skill.MinCoolDown;
    end
    
    --basicCoolDown = basicCoolDown - (skill.Level * 1000)
    
    return basicCoolDown;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Bloodletting(skill)

    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    
    basicCoolDown = basicCoolDown + abilAddCoolDown;
        
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    if IsPVPServer(pc) == 1 then
        basicCoolDown = basicCoolDown + 20000;
    end

    return math.floor(basicCoolDown);

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_HealingFactor(skill)
    
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    
    basicCoolDown = basicCoolDown + abilAddCoolDown;
        
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    if IsPVPServer(pc) == 1 then
        basicCoolDown = basicCoolDown + 20000;
    end 

    return math.floor(basicCoolDown);
    
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_GravityPole(skill)
    
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    
    basicCoolDown = basicCoolDown + abilAddCoolDown;
        
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    if IsPVPServer(pc) == 1 then
        basicCoolDown = basicCoolDown + 15000;
    end 

    return math.floor(basicCoolDown);
    
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_WaveLength(skill)

    local pc = GetSkillOwner(skill);
    local overWriteExist, overWritedValue = GetOverWritedProp(pc, skill, "WaveLength");
    if overWriteExist == 1.0 then
        return overWritedValue;
    end 
    
    local waveLength = skill.SklWaveLength;
    if skill.SplType == "Square" then
        waveLength = waveLength + pc.SkillRange + TryGet(pc, skill.AttackType .. "_Range");
    end
    
    return waveLength;  

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Skl_SR(skill)

    local sklSR = skill.SklSR;
    local pc = GetSkillOwner(skill);
    local sumValue = GetSumValueByItem(pc, skill, "SR");
    return sklSR + sumValue;
        
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_SPLANGLE(skill)

    local pc = GetSkillOwner(skill);
    local overWriteExist, overWritedValue = GetOverWritedProp(pc, skill, "SplAngle");
    if overWriteExist == 1.0 then
        return overWritedValue;
    end
    
    local splType = skill.SplType;
    if splType ~= "Fan" then
        return skill.SklSplAngle;
    end
    
    return skill.SklSplAngle + pc.SkillAngle;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SplRange(skill)

    local pc = GetSkillOwner(skill);
    
    local overWriteExist, overWritedValue = GetOverWritedProp(pc, skill, "SplRange");
    if overWriteExist == 1.0 then
        return overWritedValue;
    end 

    local splRange = skill.SklSplRange;
    local splType = skill.SplType;
    if splType == "Fan" then
        splRange = splRange + pc.SkillRange + TryGet(pc, skill.AttackType .. "_Range");
    elseif splType == "Square" then
        splRange = splRange + pc.SkillAngle;
    end
    
    return splRange;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Skl_BackHit(skill)

    local pc = GetSkillOwner(skill);
    local overWriteExist, overWritedValue = GetOverWritedProp(pc, skill, "BackHitRange");
    if overWriteExist == 1.0 then
        return overWritedValue;
    end 
    
    return 0;

end


--[ Normal_Attack ]--
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor(skill)
    local sklFactor;
    local skillOwner = GetSkillOwner(skill);
    
    sklFactor = SyncFloor(skill.SklFactor * 10) * 0.1 + SyncFloor(skill.SklFactorByLevel * 10) * 0.1 * (skill.Level - 1);
    return math.floor(sklFactor);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Reinforce_Ability(skill)
    local pc = GetSkillOwner(skill)
    local pc_faction_check = TryGetProp(pc, "Faction", "None")
    -- 몬스터 장판 뒤집기 스킬 에러로그 예외처리
    if pc_faction_check == "Monster" then 
        return 0;
    end

    local value = SyncFloor(skill.SklFactor * 10) * 0.1 + SyncFloor(skill.SklFactorByLevel * 10) * 0.1 * (skill.Level - 1)
    
    if IsInTOSHeroMap(pc) == true then
        return math.floor(value)
    end

    local reinfabil = skill.ReinforceAbility
    local abil = GetAbility(pc, reinfabil)-- 강화 특성
    if abil ~= nil and TryGetProp(skill, "ReinforceAbility") ~= 'None' then
        local abilLevel = TryGetProp(abil, "Level")
        local masterAddValue = 0
        if abilLevel == 100 then
            masterAddValue = 0.1
        end

        value = value * (1 + ((abilLevel * 0.005) + masterAddValue))
        
        local hidden_abil_cls = GetClass("HiddenAbility_Reinforce", skill.ClassName);
        if abilLevel >= 65 and hidden_abil_cls ~= nil then
        	local hidden_abil_name = TryGetProp(hidden_abil_cls, "HiddenReinforceAbil");
        	local hidden_abil = GetAbility(pc, hidden_abil_name);
        	if hidden_abil ~= nil then
        		local abil_level = TryGetProp(hidden_abil, "Level");
        		local add_factor = TryGetProp(hidden_abil_cls, "FactorByLevel", 0) * 0.01;
        		local add_value = 0;
        		if abil_level == 10 then
        			add_value = TryGetProp(hidden_abil_cls, "AddFactor", 0) * 0.01
        		end
                value = value * (1 + (abil_level * add_factor) + add_value);
        	end
        end
    end
    
    local clsName = TryGetProp(skill, "ClassName", "None")

    if GetExProp(pc, "ITEM_VIBORA_ChillWind_LV4") > 0 then
        if clsName == 'NakMuay_TeKha' or clsName == 'NakMuay_SokChiang' or clsName == 'NakMuay_TeTrong' then
            value = value * 1.3
        end
    end
    
    return math.floor(value);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Doppelsoeldner_Zornhau_Abil(skill)
    local pc = GetSkillOwner(skill);
    local value = 100 
    local zornhauSkill = GetSkill(pc, 'Doppelsoeldner_Zornhau');
    if zornhauSkill ~= nil then
        value = TryGetProp(zornhauSkill, "SkillFactor", 100) * 0.4
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Pheasant_Vibora(skill)
    local pc = GetSkillOwner(skill);
    local value = 100 
    local pheasantSkill = GetSkill(pc, 'Falconer_Pheasant');
    if pheasantSkill ~= nil then
        value = TryGetProp(pheasantSkill, "SkillFactor", 100) * 0.10
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Arbalester_Missile(skill)
    local pc = GetSkillOwner(skill);
    local value = 468 
    local GuidedShotSkill = GetSkill(pc, 'Arbalester_GuidedShot');
    if GuidedShotSkill ~= nil then
        value = TryGetProp(GuidedShotSkill, "SkillFactor", 468) * 0.3
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Molich_4(skill)
    
    local self = GetSkillOwner(skill);
    local buff = GetBuffByName(self, 'Melee_charging');
    local buffOver = 0;
    if buff ~= nil then
        buffOver = GetOver(buff);
    end
    
    sklFactor = skill.SklFactor + (skill.Level - 1) * skill.SklFactorByLevel + buffOver;
    return math.floor(sklFactor);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Molich_5(skill)
    
    local self = GetSkillOwner(skill);
    local buff = GetBuffByName(self, 'Magic_charging');
    local buffOver = 0;
    if buff ~= nil then
        buffOver = GetOver(buff);
    end
    
    sklFactor = skill.SklFactor + (skill.Level - 1) * skill.SklFactorByLevel + buffOver;
    
    return math.floor(sklFactor);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_PC_summon_Canceril(skill)
    
    local self = GetSkillOwner(skill);
    local parent = GetOwner(self)
    --local etc_pc = GetETCObject(parent);
    --local itemGuid = etc_pc.Wugushi_bosscardGUID1;
    --local itembonus = item.Level * 10
    
    sklFactor = skill.SklFactor + (skill.Level - 1) * skill.SklFactorByLevel
    return math.floor(sklFactor);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_pc_summon_Manticen(skill)
    
    local self = GetSkillOwner(skill);
    local parent = GetOwner(self)
    --local etc_pc = GetETCObject(parent);
    --local itemGuid = etc_pc.Wugushi_bosscardGUID1;
    --local itembonus = item.Level * 10
    
    sklFactor = skill.SklFactor + (skill.Level - 1) * skill.SklFactorByLevel
    return math.floor(sklFactor);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_pcskill_shogogoth(skill)
    
    local self = GetSkillOwner(skill);
    local pc = GetOwner(self)
    local value = skill.SklFactor + (skill.Level - 1) * skill.SklFactorByLevel
    
    local shoggothSkill = GetSkill(pc, 'Necromancer_CreateShoggoth');
    local abil = GetAbility(pc, "Necromancer5")      -- Skill Damage add
    if shoggothSkill ~= nil and abil ~= nil then
        value = SCR_ABIL_ADD_SKILLFACTOR(shoggothSkill, abil, value);
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_pcskill_CorpseTower(skill)
    
    local self = GetSkillOwner(skill);
    local pc = GetOwner(self)
    local value = skill.SklFactor + (skill.Level - 1) * skill.SklFactorByLevel
    
    local corpseTowerSkill = GetSkill(pc, "Necromancer_CorpseTower");
    local abil = GetAbility(pc, "Necromancer6")      -- Skill Damage add
    if corpseTowerSkill ~= nil and abil ~= nil then
        value = SCR_ABIL_ADD_SKILLFACTOR(corpseTowerSkill, abil, value);
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_pcskill_skullsoldier(skill)
    
    local self = GetSkillOwner(skill);
    local pc = GetTopOwner(self)
    local value = skill.SklFactor + (skill.Level - 1) * skill.SklFactorByLevel
    
    local skullSoldierSkill = GetSkill(pc, "Necromancer_RaiseDead");
    local abil = GetAbility(pc, "Necromancer7")      -- Skill Damage add
    if skullSoldierSkill ~= nil and abil ~= nil then
        value = SCR_ABIL_ADD_SKILLFACTOR(skullSoldierSkill, abil, value);
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_pcskill_skullarcher(skill)
    
    local self = GetSkillOwner(skill);
    local pc = GetTopOwner(self)
    local value = skill.SklFactor + (skill.Level - 1) * skill.SklFactorByLevel
    
    local skullArcherSkill = GetSkill(pc, "Necromancer_RaiseSkullarcher");
    local abil = GetAbility(pc, "Necromancer10")      -- Skill Damage add
    if skullArcherSkill ~= nil and abil ~= nil then
        value = SCR_ABIL_ADD_SKILLFACTOR(skullArcherSkill, abil, value);
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
-- 젤리젤, 변질의 전파자 : 20% 증가.
function SCR_Get_SkillFactor_PilgrimMode(skill)
    local skl_factor = SyncFloor(skill.SklFactor * 10) * 0.1 + SyncFloor(skill.SklFactorByLevel * 10) * 0.1 * (skill.Level - 1);
    local skl_owner = GetSkillOwner(skill);
    if skl_owner ~= nil then
        local class_name = TryGetProp(skl_owner, "ClassName", "None");
        -- 레이드 모드 체크.
        local raid_mode = GetExProp(skl_owner, "raid_mode");
        local add_skl_factor = 0;
        if raid_mode == 3 then 
            -- 익스트림(순례자) 모드 : 20% 증가.
            local rate = 0.2;
            if class_name == "boss_TransmutationSpreader_Extreme" then
                rate = 4.0; -- 변질의 전파자 4배 증가.
            end
            local add_skl_factor = skl_factor * rate;
            skl_factor = skl_factor + add_skl_factor;
        end
    end
    return math.floor(skl_factor);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
-- 변질의 전파자 시련 - 난입 Factor 처리
function SCR_Get_SkillFactor_Falouros_TribulationSpreaderExtreme(skill)
    local skl_factor = SyncFloor(skill.SklFactor * 10) * 0.1 + SyncFloor(skill.SklFactorByLevel * 10) * 0.1 * (skill.Level - 1);
    local skl_owner = GetSkillOwner(skill);
    if skl_owner ~= nil then
        local class_name = TryGetProp(skl_owner, "ClassName", "None");
        if class_name == "boss_Falouros_Spreader_Extreme" then
            -- 변질의 전파자 순례자 시련 - 난입으로 생성된 팔로우로스 스킬 펙터 10% 증가.
            local rate = 0.1;
            local add_skl_factor = skl_factor * rate;
            skl_factor = skl_factor + add_skl_factor;
        end
    end
    return math.floor(skl_factor);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SklAtkAdd(skill)    
    local sklAtkAdd;
    local skillOwner = GetSkillOwner(skill);
    
    if skillOwner.ClassName == 'PC' then
    
        sklAtkAdd = skill.SklAtkAdd + (skill.Level - 1) * skill.SklAtkAddByLevel;
       
        return math.floor(sklAtkAdd);
    else
        return 0;
    end
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_ReinforceAtk(skill)
  
    local ReinforceAtkAdd = 0;
    local self = GetSkillOwner(skill);
    
    if self.ClassName == 'PC' then
--        local jobObj = GetJobObject(self);
        local weapon = GetEquipItem(self, 'RH')
        local Transcend = weapon.Transcend
        
        ReinforceAtkAdd = skill.ReinforceAtkAdd + Transcend * skill.ReinforceAtkAddByLevel;
        
        return ReinforceAtkAdd
    else
        return 1;
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_NormalAttack_Lv(skill)

    local pc = GetSkillOwner(skill);
    local value = pc.Lv
    
  return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_ABIL_ADD_SKILLFACTOR(skill, abil, value)
    local abilLevel = TryGetProp(abil, "Level")
    local masterAddValue = 0
    if abilLevel == 100 then
        masterAddValue = 0.1
    end
    
    local value = value * (1 + ((abilLevel * 0.005) + masterAddValue))

    local pc = GetSkillOwner(skill);
    local sklClassName = TryGetProp(skill, "ClassName");
    local hidden_abil_cls = GetClass("HiddenAbility_Reinforce", sklClassName);
    if abilLevel >= 65 and hidden_abil_cls ~= nil then
        local hidden_abil_name = TryGetProp(hidden_abil_cls, "HiddenReinforceAbil");
        local hidden_abil = GetAbility(pc, hidden_abil_name);
        if hidden_abil ~= nil then
            local abil_level = TryGetProp(hidden_abil, "Level");
            local add_factor = TryGetProp(hidden_abil_cls, "FactorByLevel", 0) * 0.01;
            local add_value = 0;
            if abil_level == 10 then
                add_value = TryGetProp(hidden_abil_cls, "AddFactor", 0) * 0.01
            end
            value = value * (1 + (abil_level * add_factor) + add_value);
        end
	end
    
    return value
end

-- skillshared.lua 의 function SCR_REINFORCEABILITY_FOR_BUFFSKILL(self, skill) 과 동일함. 변경시 같이 변경 필요
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_REINFORCEABILITY_TOOLTIP(skill)
    local ignore_hidden_list = {
        "Oracle_CounterSpell",
        "Dievdirbys_CarveAustrasKoks",
    }

    local pc = GetSkillOwner(skill);
    local addAbilRate = 1;
    local reinforceAbilName = TryGetProp(skill, "ReinforceAbility", "None");
    if reinforceAbilName ~= "None" then
        local reinforceAbil = GetAbility(pc, reinforceAbilName)
        if reinforceAbil ~= nil then
            local abilLevel = TryGetProp(reinforceAbil, "Level")
            local masterAddValue = 0
            if abilLevel == 100 then
                masterAddValue = 0.1
            end
            addAbilRate = 1 + (reinforceAbil.Level * 0.005 + masterAddValue);

            local hidden_abil_cls = GetClass("HiddenAbility_Reinforce", skill.ClassName);
            if table.find(ignore_hidden_list, skill.ClassName) == 0 and abilLevel >= 65 and hidden_abil_cls ~= nil then
                local hidden_abil_name = TryGetProp(hidden_abil_cls, "HiddenReinforceAbil");
                local hidden_abil = GetAbility(pc, hidden_abil_name);
                if hidden_abil ~= nil then
                    local abil_level = TryGetProp(hidden_abil, "Level");
                    local add_factor = TryGetProp(hidden_abil_cls, "FactorByLevel", 0) * 0.01;
                    local add_value = 0;
                    if abil_level == 10 then
                        add_value = TryGetProp(hidden_abil_cls, "AddFactor", 0) * 0.01
                    end
                    addAbilRate = addAbilRate * (1 + (abil_level * add_factor) + add_value);
                end
            end
        end
    end
 
    return addAbilRate
end

function SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil)
    return abil.Level * 1
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Thrust_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Swordman2") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Bash_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Swordman1") 
    local value = 0
    if abil ~= nil then 
    return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
  end


end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PommelBeat_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Swordman25") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PommelBeat_Ratio(skill)

    return (1 + (skill.Level - 1) * 0.5)

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DoubleSlash_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Swordman27") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RimBlow_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 0
    local abil = GetAbility(pc, "Peltasta38")
	if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        local addValue = TryGetProp(abil, "Level", 0) * 6
        value = value + addValue
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_UmboBlow_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Peltasta12") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_ShieldLob(skill)

    local pc = GetSkillOwner(skill);
    local Peltasta4_abil = GetAbility(pc, 'Peltasta4')

    if Peltasta4_abil ~= nil and 1 == Peltasta4_abil.ActiveState then
        return pc.SR + skill.SklSR + Peltasta4_abil.Level;
    end
    return pc.SR + skill.SklSR

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ShieldLob_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 0
    local abil = GetAbility(pc, "Peltasta38")
	if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        local addValue = TryGetProp(abil, "Level", 0) * 6
        value = value + addValue
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_PommelBeat(skill)

    local pc = GetSkillOwner(skill);    
    return skill.SklSR

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ButterFly_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 0
    local abil = GetAbility(pc, "Murmillo20")
	if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        local addValue = TryGetProp(abil, "Level", 0) * 6
        value = value + addValue
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_UmboThrust_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Peltasta26") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Langort_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 0
    local abil = GetAbility(pc, "Peltasta38")
	if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        local addValue = TryGetProp(abil, "Level", 0) * 6
        value = value + addValue
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_HEX(skill)
  local value = skill.Level;
    return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Moulinet_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 100
    if IsBuffApplied(pc, "RidingCompanion") == "YES" then 
        value = 150
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CartarStroke_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Highlander11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CartarStroke_Ratio2(skill)
--    local pc = GetSkillOwner(skill);
--    local abil = GetAbility(pc, 'Highlander33')
    local value = 0.5
--    if abil ~= nil and abil.ActiveState == 1 then
--        value = value / 2
--    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_WagonWheel_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Highlander13") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Crown_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Highlander12") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ScullSwing_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Highlander25") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SkyLiner_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Highlander29") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CrossCut_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Highlander30") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_VerticalSlash_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Highlander31") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Stabbing_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Hoplite11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_LongStride_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Hoplite12") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SynchroThrusting_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Hoplite13") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Pierce_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Hoplite14") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ThrouwingSpear_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Hoplite23") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SpearLunge_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Hoplite26") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Embowel_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Barbarian17") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_StompingKick_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Barbarian20") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Pouncing_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Barbarian24") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HelmChopper_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local value = 2.5
    
    if IsBuffApplied(pc, "Frenzy_Buff") == "YES" then
        value = 4
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Seism_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Barbarian26") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Seism_Ratio2(skill)
--  local pc = GetSkillOwner(skill)
--  local buff = GetBuffByName(pc, "ScudInstinct_Buff")
--  local buffOver = GetOver(buff)
--  if buff ~=nil and buffOver >= 5 then
--      hitCount = hitCount + 2
--    end
    local hitCount = 3
    
    return hitCount;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Cleave_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Barbarian27") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ShieldCharge_Ratio(skill)
    local value = 10 + (skill.Level * 6)
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Montano_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 0
    local abil = GetAbility(pc, "Rodelero31")
	if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        local addValue = TryGetProp(abil, "Level", 0) * 6
        value = value + addValue
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Montano_Time(skill)
    local pc = GetSkillOwner(skill);
    local value = 5
    
    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = 2.5
    end
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TargeSmash_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 0
    local abil = GetAbility(pc, "Rodelero31")
	if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        local addValue = TryGetProp(abil, "Level", 0) * 6
        value = value + addValue
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ShieldPush_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 0
    local abil = GetAbility(pc, "Rodelero31")
	if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        local addValue = TryGetProp(abil, "Level", 0) * 6
        value = value + addValue
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ShieldShoving_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 0
    local abil = GetAbility(pc, "Rodelero31")
	if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        local addValue = TryGetProp(abil, "Level", 0) * 6
        value = value + addValue
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ShieldShoving_Bufftime(skill)
    local pc = GetSkillOwner(skill);
    local value = 1.5
    if IsPVPServer(pc) == 1 then
        value = 3
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ShieldBash_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 0
    local abil = GetAbility(pc, "Rodelero31")
	if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        local addValue = TryGetProp(abil, "Level", 0) * 6
        value = value + addValue
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Slithering_Ratio(skill)
    local value = skill.Level * 10
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Slithering_Ratio2(skill)
    local value = skill.Level * 5
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Slithering_Ratio3(skill)
    local value = math.floor(skill.Level * 1.5)
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ShootingStar_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 0

    local abilRodelero41 = GetAbility(pc, "Rodelero41")
    if abilRodelero41 ~= nil and TryGetProp(abilRodelero41, "ActiveState", 0) == 1 then
        value = 20
    end
    
    local abil = GetAbility(pc, "Rodelero31")
	if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        local addValue = TryGetProp(abil, "Level", 0) * 6
        value = value + addValue
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HighKick_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Rodelero28") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Impaler_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Cataphract14") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Impaler_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 8 + skill.Level;
    local zone = GetZoneName(pc);
    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = 6;
    end
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DoomSpike_Ratio(skill)
    local value = 10 + TryGetProp(skill, "Level", 1) 
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Rush_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Cataphract11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Rush_Ratio3(skill)
    local pc = GetSkillOwner(skill);
    local value = 10 + skill.Level *1;
    local abil = GetAbility(pc, "Cataphract1")
    if abil ~= nil and abil.ActiveState == 1 then
        value = value * 1.2
    end
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EarthWave_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Cataphract17") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SteedCharge_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Cataphract20") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Keelhauling_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Corsair11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Keelhauling_Ratio(skill)
    local pc = GetSkillOwner(skill);
    
    local value = 2;
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DustDevil_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Corsair12") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HexenDropper_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Corsair13") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PistolShot_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Corsair16") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Cyclone_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Doppelsoeldner11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Cyclone_Ratio2(skill)
    return 3.5
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Mordschlag_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Doppelsoeldner12") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Punish_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Doppelsoeldner13") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Zornhau_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Doppelsoeldner14") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Zornhau_Ratio2(skill)
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, 'Doppelsoeldner22')
    local hitCount = 1
    if abil ~= nil and skill.Level >= 6 and abil.ActiveState == 1 then
        hitCount = 1 + abil.Level;
    end
    return hitCount;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Redel_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Doppelsoeldner15") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Redel_Ratio2(skill)
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, "Doppelsoeldner21")
    local hitCount = 10
    if abil ~= nil and skill.Level >=6 and abil.ActiveState == 1 then
        hitCount = 14
    end
    
    return hitCount;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Zucken_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Doppelsoeldner16") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Zucken_Ratio2(skill)

    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, "Doppelsoeldner20")
    local hitCount = 8
    if abil ~= nil and skill.Level >= 6 and abil.ActiveState == 1 then
        hitCount = hitCount * 2
    end
    
    return hitCount;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_AttaqueComposee_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Fencer2") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Lunge_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Fencer3") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Lunge_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local value = 50 + (20 * skill.Level)
    
    return value;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Lunge_BuffTime(skill)
return 4
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SeptEtoiles_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Fencer4") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_AttaqueCoquille_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Fencer5") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_AttaqueCoquille_Ratio2(skill)

    local value = 4 + skill.Level * 1
  return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Preparation_Ratio(skill)

    local value = 50 + skill.Level * 5
  return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Preparation_Ratio2(skill)

    local value = 3
  return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EsquiveToucher_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Fencer6") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EsquiveToucher_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local value = 10 * skill.Level
    
  return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Flanconnade_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Fencer7") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Mijin_no_jutsu_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Shinobi3") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Mijin_no_jutsu_Ratio2(skill)
    local value = 7500 - skill.Level * 500
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Bunshin_no_jutsu_Ratio(skill)
    local value = 20
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SummonGuildMember_Ratio(skill)
    local value = 1 * skill.Level
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BattleOrders_Ratio(skill)
    local value = 1 + skill.Level * 0.2
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BattleOrders_Ratio2(skill)
    local value = skill.Level * 1.5
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_AdvancedOrders_Ratio(skill)
    local value = 5 + skill.Level * 0.7
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_AdvancedOrders_Ratio2(skill)
    local value = skill.Level
    if value > 5 then
        value = 5
    end
    
    return value
end

function SCR_GET_AdvancedOrders_Ratio3(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BuildForge_Time(skill)
    local value = 50 + skill.Level * 2
    local pc = GetSkillOwner(skill);
    if IsPVPServer(pc) == 1 then
        value = value * 0.5
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BuildForge_Ratio(skill)
    local value = 73
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FlyingColors_Ratio(skill)
    local value = 12 + skill.Level * 6
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FlyingColors_Ratio2(skill)
    local value = skill.Level * 5
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_BuildForge(skill)
    
    local self = GetSkillOwner(skill);
    local pc = GetOwner(self)
    local value = skill.SklFactor + (skill.Level - 1) * skill.SklFactorByLevel
    
    local forgeSkill = GetSkill(pc, "Templer_BuildForge");
    local abil = GetAbility(pc, "Templar4")      -- Skill Damage add
    if forgeSkill ~= nil and abil ~= nil then
        value = SCR_ABIL_ADD_SKILLFACTOR(forgeSkill, abil, value);
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BuildShieldCharger_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 10 + (skill.Level * 2)
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)

    if IsPVPField(pc) == 1 then
        value = value / 2
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BuildShieldCharger_Ratio2(skill)
    local value = 5
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BuildShieldCharger_Ratio3(skill)
    local value = 60
    local pc = GetSkillOwner(skill);
    if IsPVPServer(pc) == 1 then
        value = 30
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ShareBuff_Ratio(skill)
    local value = 5 + (skill.Level * 2)
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ShareBuff_Ratio2(skill)
    local value = 42 + skill.Level * 2
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ReduceCraftTime_Ratio(skill)
    local value = 5 * skill.Level
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Bunshin_no_jutsu_Ratio2(skill)
    local value = skill.Level
    if value >= 3 then
        value = 3
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Mokuton_no_jutsu_Ratio(skill)

    local value = 10 + skill.Level * 4

  return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Katon_no_jutsu_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Shinobi2") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Kunai_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Shinobi1") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DeadlyCombo_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Squire11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end
    
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Dragontooth_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Dragoon1") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Serpentine_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Dragoon3") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Gae_Bulg_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Dragoon5") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Gae_Bulg_Ratio2(skill)

    local value = 10
  return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Dragon_Soar_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Dragoon8") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Dragon_Soar_Ratio2(skill)
    local value = 5;
    
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Dragoon16") 
    if abil ~= nil and abil.ActiveState == 1 then 
        value = value * 2;
    end
    
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Zwerchhau_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Doppelsoeldner18") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Zwerchhau_Bufftime(skill)
    local value = 6.5
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Sturzhau_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Doppelsoeldner19") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

--function SCR_GET_Sturzhau_Ratio2(skill)
--    local value = skill.Level * 200
--    return value
--end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Sturzhau_Ratio3(skill)
    local value = skill.Level * 5
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BalestraFente_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Fencer8") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_AttaqueAuFer_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Fencer9") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_AttaqueAuFer_Bufftime(skill)
    local value = 15
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EpeeGarde_Ratio(skill)
    local value = 9 + skill.Level * 1.5;

    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EpeeGarde_Bufftime(skill)
    local value = 15 + skill.Level * 3
    return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Dethrone_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Dragoon11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Dethrone_Ratio2(skill)
    local value = 5
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Dethrone_Bufftime(skill)
    local value = 10
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DargonDive_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Dragoon13") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_DragoonHelmet_Ratio(skill)
    local value = 40
    local pc = GetSkillOwner(skill);
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_DragoonHelmet_Ratio2(skill)
    local value = 100
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Dragoon20")
    if abil ~= nil and abil.ActiveState == 1 then
        value = 50
    end
    
    local pcLevel = TryGetProp(pc, "Lv", 1)
    local mnaRate = TryGetProp(pc, "MNA", 1)      
    
    value = value - math.min(50, (mnaRate / pcLevel) * 100)    
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_DragoonHelmet_Ratio3(skill)

    local pc = GetSkillOwner(skill);
    
    local pcLevel = TryGetProp(pc, "Lv", 1)
    local mnaRate = TryGetProp(pc, "MNA", 1)      
    
    local value = math.min(50, (mnaRate / pcLevel) * 100)    
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MortalSlash_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Templar1") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_MortalSlash(skill)
    
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    local owner = GetSkillOwner(skill)
    
    if IsServerSection(owner) == 1 then
        local list, cnt = GetPartyMemberList(owner, PARTY_NORMAL, 0);
        if cnt > 1 then
            local abilCoolDownRatio = 1;
            for i = 1, cnt - 1 do
                abilCoolDownRatio = abilCoolDownRatio - 0.1;
            end
            
            if abilCoolDownRatio < 0.6 then
                abilCoolDownRatio = 0.6;
            end
            
            basicCoolDown = basicCoolDown * abilCoolDownRatio;
        end
    else
        local list = session.party.GetPartyMemberList(PARTY_NORMAL);
        if list ~= nil then
            local cnt = list:Count();
            if cnt > 1 then
                local myObj = session.party.GetMyPartyObj(PARTY_NORMAL)
                local myMapID = myObj:GetMapID()
                local myChannelInfo = session.loginInfo.GetChannel();
                
                local loginCount = 0;
                for i = 0 , cnt - 1 do
                    local partyMemberInfo = list:Element(i);
                    if partyMemberInfo:GetMapID() == myMapID and partyMemberInfo:GetChannel() == myChannelInfo then
                        loginCount = loginCount + 1;
                    end
                end
                
                local abilCoolDownRatio = 1;
                
                if loginCount > 1 then
                    for i = 1, loginCount - 1 do
                        abilCoolDownRatio = abilCoolDownRatio - 0.1;
                    end
                end
                
                if abilCoolDownRatio < 0.6 then
                    abilCoolDownRatio = 0.6;
                end
                
                basicCoolDown = basicCoolDown * abilCoolDownRatio;
            end
        end
    end
    
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    if IsBuffApplied(pc, "Bunshin_Debuff") == "YES" then
        local bunshinBuff = nil
        local bunsinCount = nil
        if IsServerObj(pc) == 1 then
            bunshinBuff = GetBuffByName(pc, "Bunshin_Debuff")
            bunsinCount = GetBuffArg(bunshinBuff)
        else 
            local handle = session.GetMyHandle();
            bunshinBuff = info.GetBuff(handle, 3049)
            bunsinCount = bunshinBuff.arg1
        end
        
        basicCoolDown = basicCoolDown + (bunsinCount * 2000 + (basicCoolDown * (bunsinCount * 0.1)))
    end
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    return math.floor(ret);

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CassisCrista_Bufftime(skill)

    local value = 240
    
    return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CassisCrista_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 5

    local isVibora = GetExProp(pc, "ITEM_VIBORA_Arena")
    if isVibora > 0 then
        value = 3
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CassisCrista_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 25

    local isVibora = GetExProp(pc, "ITEM_VIBORA_Arena")
    if isVibora > 0 then
        value = 12.5
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FrenziedSlash_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Murmillo2") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FrenziedSlash_Ratio2(skill)

    local value = 4 + skill.Level * 1
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EvadeThrust_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Murmillo3") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Headbutt_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Murmillo5") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Headbutt_Time(skill)
    local value = 3
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Takedown_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Murmillo6") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FrenziedShoot_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Murmillo7") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ScutumHit_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 0
    local abil = GetAbility(pc, "Murmillo20")
	if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        local addValue = TryGetProp(abil, "Level", 0) * 6
        value = value + addValue
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ShieldTrain_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_ScutumHit(skill)
    local pc = GetSkillOwner(skill);
    local byAbil = 0;
    local abil = GetAbility(pc, 'Murmillo16');
    if abil ~= nil and 1 == abil.ActiveState then
        byAbil = pc.SR + skill.SklSR;
    end
    
    return math.floor(pc.SR + skill.SklSR + byAbil)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Crush_Ratio(skill)
    local value = skill.Level * 0.5
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Crush_Buff_Ratio(skill)
    local value = 1 + skill.Level * 0.2
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HeadStrike_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Lancer4") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HeadStrike_Ratio2(skill)
    local value = 30 + skill.Level * 2
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Joust_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Lancer6") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Joust_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 10 + skill.Level * 1;
    local zone = GetZoneName(pc);
    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = value * 0.5;
    end
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SpillAttack_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Lancer7") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Quintain_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Lancer8") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Commence_Ratio(skill)
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)
    local value = base + skill.Level * per
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Commence_Ratio2(skill)
    local value = skill.Level * 1.875

    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill))

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Commence_Bufftime(skill)
    local value = 10 + skill.Level * 3
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Capote_Ratio(skill)
    local value = 10 + skill.Level * 1
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Capote_Ratio2(skill)
    local value = 15
    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill));
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Faena_Ratio(skill)
    local value = (skill.Level / 2) + 2
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Faena_Ratio2(skill)
    local value = skill.Level + 2
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Ole_BuffTime(skill)
    local pc = GetSkillOwner(skill)
    local value = 20
    local abil = GetAbility(pc, "Matador4")
    if abil ~= nil and abil.ActiveState == 1 then
        value = value + abil.Level
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Ole_Ratio(skill)
    local value = 10 + (skill.Level * 3)
    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill))
    
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Ole_Ratio2(skill)
    local value = 15 +  skill.Level * 2.5;
    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill))
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BackSlide_Bufftime(skill)
    local value = skill.Level
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Sprint_Ratio(skill)
    local base = TryGetProp(skill, 'SklFactor', 0) / 10
    local per = TryGetProp(skill, 'SklFactorByLevel', 0) / 10
    local value = base + skill.Level * per        
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ShadowPool_Bufftime(skill)
    local base = TryGetProp(skill, 'SklFactor', 0) / 100
    local per = TryGetProp(skill, 'SklFactorByLevel', 0) / 100
    local value = base + skill.Level * per    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ShadowFatter_Bufftime(skill)
    local pc = GetSkillOwner(skill)
    local value = 3 + skill.Level * 1.5
    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = value / 2
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Hallucination_Bufftime(skill)
    local value = 5 + skill.Level
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Enervation_BuffTime(skill)
    local value = 20 + skill.Level * 2
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EnchantEarth_Ratio(skill)
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)
    local value = base + skill.Level * per
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Multishot_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Archer11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Fulldraw_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Archer12") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ObliqueShot_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Archer13") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_KnockbackShot_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Archer26") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DuelShot_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Archer28") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Barrage_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Ranger11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HighAnchoring_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Ranger12") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BounceShot_Ratio2(skill)
    local value = 50;
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SpiralArrow_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Ranger30") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ArrowSprinkle_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Ranger23") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CriticalShot_Ratio(skill)

    local value = 25 + skill.Level * 2.5
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TimeBombArrow_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Ranger28") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Scan_Ratio(skill)
    local value = 17.5 + skill.Level * 3 

    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Scan_Ratio2(skill)
    local value = 0.5 + skill.Level * 0.3
    return value
end


-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ScatterCaltrop_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "QuarrelShooter11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_StonePicking_Ratio(skill)
    local value = skill.Level
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_StoneShot_Ratio(skill)
    local value = 25 + skill.Level * 5
    if value >= 100 then
        value = 100
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_StoneShot_Ratio2(skill)
    local value = 50
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RapidFire_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "QuarrelShooter13") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_RunningShot_Ratio(skill)

    local value = 50 + 30 * skill.Level
  return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DestroyPavise_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "QuarrelShooter20") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BroomTrap_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Sapper11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_StakeStockades_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Sapper29") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_StakeStockades_Time(skill)
    local pc = GetSkillOwner(skill);
    local value = 15
    if IsPVPServer(pc) == 1 then
        value = 900
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_StakeStockades_HitCount(skill)--CaptionRatio2
    local pc = GetSkillOwner(skill);
    local value = 15
    if IsPVPServer(pc) == 1 then
        value = 6
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Claymore_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Sapper12") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Claymore_Ratio(skill)
    local value = 5
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PunjiStake_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Sapper13") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PunjiStake_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 20 + skill.Level * 5
    if IsPVPServer(pc) == 1 then
        value = 900
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DetonateTraps_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Sapper14") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SpikeShooter_Ratio3(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Sapper26") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HoverBomb_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Sapper27") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Coursing_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Hunter9") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Snatching_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Hunter10") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RushDog_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Hunter11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Retrieve_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Hunter12") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_NeedleBlow_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Wugushi11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_NeedleBlow_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local value = 5 + skill.Level * 0.5

    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_WugongGu_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Wugushi14") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_WugongGu_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local value = 10

    return value;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ThrowGuPot_Time(skill)
    local value = 15
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ThrowGuPot_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Wugushi17") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FluFlu_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Scout11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_JincanGu_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local value = skill.Level
    if value > 5 then
        value = 5
    end

    return value;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FlareShot_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Scout14") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FlareShot_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local value = 25
  return value;
  
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SplitArrow_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Scout17") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Vendetta_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Rogue11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Backstab_Ratio2(skill)
    local value = 0.5 + (skill.Level * 0.1)
    -- local pc = GetSkillOwner(skill);
    
    -- if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
    --     value = 2 + (skill.Level * 0.2)
    -- end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BroadHead_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Fletcher11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BodkinPoint_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Fletcher14") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BarbedArrow_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Fletcher17") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CrossFire_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local value = 5
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MagicArrow_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Fletcher23") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MagicArrow_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local value = 5 + skill.Level * 2
    return value 

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Singijeon_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Fletcher25") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ConcentratedFire_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Schwarzereiter11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ConcentratedFire_Ratio2(skill)

    return 10;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Limacon(skill)
    local pc = GetSkillOwner(skill);
    local LimaconSkill = GetSkill(pc, "Schwarzereiter_Limacon")
    local value = 0
    if LimaconSkill ~= nil then
        value = LimaconSkill.SklFactor + LimaconSkill.SklFactorByLevel * (skill.Level - 1)
    end

--    local limaconSkill = GetSkill(pc, "Schwarzereiter_Limacon");
--    local abil = GetAbility(pc, "Schwarzereiter13")      -- Skill Damage add
--    if limaconSkill ~= nil and abil ~= nil then
--        value = SCR_ABIL_ADD_SKILLFACTOR(limaconSkill, abil, value);
--    end
    
    return math.floor(value)

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_DoubleBullet(skill)
    local pc = GetSkillOwner(skill);
    local DoubleBulletSkill = GetSkill(pc, "Schwarzereiter_DoubleBullet")
    local value = 0
    if DoubleBulletSkill ~= nil then
        value = SCR_Get_SkillFactor_Reinforce_Ability(DoubleBulletSkill)
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Limacon_Ratio(skill)
--    local value = 5 + (skill.Level * 1);
--    local pc = GetSkillOwner(skill);
--    if pc ~= nil then
--        local abilSchwarzereiter18 = GetAbility(pc, 'Schwarzereiter18');
--        if abilSchwarzereiter18 ~= nil and TryGetProp(abilSchwarzereiter18, 'ActiveState') == 1 then
--            value = value + 3;
--        end
--    end
--    
--    return value;
    
    local pc = GetSkillOwner(skill);
    local value = 12;
    local lv = pc.Lv
    local bylvCorrect = lv - 300
    if bylvCorrect < 0 then
        bylvCorrect = bylvCorrect * 2.75 / 1000
    elseif bylvCorrect >= 0 then
        bylvCorrect = bylvCorrect * 1.25 / 1000
    end
    
    value = value * (1 + bylvCorrect)
    
    local abilSchwarzereiter18 = GetAbility(pc, 'Schwarzereiter18');
    if abilSchwarzereiter18 ~= nil then
        value = value + 5;
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Limacon_BuffTime(skill)
    local value = skill.Level * 20
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EvasiveAction_BuffTime(skill)
    local value = 300
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RetreatShot_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Schwarzereiter14") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_WildShot_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Schwarzereiter15") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EvasiveAction_Ratio(skill)
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)

    local value = base + skill.Level * per

    local pc = GetSkillOwner(skill);
    local abilSchwarzereiter34 = GetAbility(pc, "Schwarzereiter34")
    if abilSchwarzereiter34 ~= nil and TryGetProp(abilSchwarzereiter34, "ActiveState", 0) == 1 and GetSkill(pc, 'Schwarzereiter_EvasiveAction') ~= nil then
        value = 12 + skill.Level * 2
    end

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Schwarzereiter33") 
    if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 and GetSkill(pc, 'Schwarzereiter_EvasiveAction') ~= nil then
        value = value * SCR_REINFORCEABILITY_TOOLTIP(skill);
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EvasiveAction_Ratio2(skill)
    local value = skill.Level * 3

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Hovering_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Falconer5") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Pheasant_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Falconer6") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BlisteringThrash_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Falconer8") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CannonShot_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Cannoneer2") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ShootDown_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Cannoneer3") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SiegeBurst_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Cannoneer4") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CannonBlast_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Cannoneer5") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SmokeGrenade_Time(skill)
    local value = 1 + skill.Level
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SmokeGrenade_Ratio(skill)
    local value = 20
    local pc = GetSkillOwner(skill);
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SmokeGrenade_Ratio2(skill)
    local value = 20 + skill.Level * 3

    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)

    if value >= 90 then
        value = 90
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Bazooka_Ratio(skill)
    local value = 100 + 10 * (skill.Level - 1)
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Bazooka_Ratio2(skill)
    local value = 3 + skill.Level * 1
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CoveringFire_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Musketeer2") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HeadShot_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Musketeer3") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Snipe_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Musketeer4") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PenetrationShot_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Musketeer5") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ButtStroke_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Musketeer6") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BayonetThrust_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Musketeer7") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Combination_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Falconer9") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FirstStrike_Ratio2(skill)
    local value = skill.Level * 10
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CannonBarrage_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Cannoneer9") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_CannonBarrage(skill)
    
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    if IsBuffApplied(pc, "Bazooka_Buff") == "YES" then
        basicCoolDown = basicCoolDown * 2
    end

    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)
    
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)

    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;   
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Volleyfire_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Musketeer11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Birdfall_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Musketeer18") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Skarphuggning_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Hackapell1") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HakkaPalle_BuffTime(skill)
    local value = 10 + (skill.Level * 2)
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BombardmentOrders_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Hackapell2") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BombardmentOrder_Time(skill)
    local value = 2 + skill.Level * 0.3
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HackapellCharge_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Hackapell3") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HackapellCharge_BuffTime(skill)
    local value = 15 + skill.Level
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_LegShot_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Hackapell4") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_LegShot_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 50
    
    local abil = GetAbility(pc, "Hackapell5")
    if abil ~= nil and 1 == abil.ActiveState then
        value = value + abil.Level
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_StormBolt_BuffTime(skill)
    local value = 6 * skill.Level
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Unload_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Mergen2") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Unload_Ratio2(skill)
    local value = 6
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FocusFire_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Mergen3") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_QuickFire_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Mergen4") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TrickShot_Ratio(skill)
    local value = 10 + (skill.Level * 6)
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ArrowRain_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Mergen6") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ParthianShaft_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Mergen7") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ParthianShaft_Ratio2(skill)
    local value = skill.Level * 3;
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EnergyBolt_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Wizard11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EarthQuake_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Wizard13") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MagicMissile_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Wizard12") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MagicMissile_Ratio2(skill)
    local value = math.floor(0.5 + (skill.Level / 2))
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FireBall_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Pyromancer29") 
    local value = 5
    if abil ~= nil and abil.ActiveState == 1 then 
        value = value + abil.Level
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FireWall_Ratio3(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Pyromancer12") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Flare_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Pyromancer13") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FlameGround_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Pyromancer26") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FirePillar_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Pyromancer15") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HellBreath_Ratio2(skill)

    return TryGetProp(skill, "Level", 0)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_IceBolt_Ratio(skill)

    local value = 30
    local pc = GetSkillOwner(skill);

    local abilCryomancer2 = GetAbility(pc, 'Cryomancer2');
    if abilCryomancer2 ~= nil and TryGetProp(abilCryomancer2, "ActiveState") == 1 and (IsPVPServer(pc) == 0 or IsPVPField(pc) == 0) then
        value = value * (1 + abilCryomancer2.Level * 0.1);
    end

    local abilCryomancer9 = GetAbility(pc, "Cryomancer9");
    if abilCryomancer9 ~= nil and TryGetProp(abilCryomancer9, "ActiveState") == 1 then
        value = math.floor(value * (1 + abilCryomancer9.Level * 0.05));
    end

    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_IceBolt_BuffTime(skill)
    local value = 5
    local pc = GetSkillOwner(skill);
    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = value / 2
    end
    return value
end

function SCR_GET_IciclePike_BuffTime(skill)
    local value = 5
    local pc = GetSkillOwner(skill);
    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = value / 2
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_IceWall_BuffTime(skill)
    local value = 5
    local pc = GetSkillOwner(skill);
    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = value / 2
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_IciclePike_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 7
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_IciclePike_Ratio2(skill)
    local value = 50
    local pc = GetSkillOwner(skill);
    
    local abilCryomancer9 = GetAbility(pc, "Cryomancer9");
    if abilCryomancer9 ~= nil and TryGetProp(abilCryomancer9, "ActiveState") == 1 then
        value = math.floor(value * (1 + abilCryomancer9.Level * 0.05));
    end

    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = 10
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_IceBlast_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Cryomancer13") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SnowRolling_Ratio2(skill)
    local value = 3 + skill.Level
    if value > 10 then
        value = 10
    end
    
	return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Telekinesis_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Psychokino11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MagneticForce_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Psychokino13") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_GravityPole_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Psychokino8") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Meteor_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Elementalist11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Prominence_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Elementalist26") 
    local value = 4
    if abil ~= nil and abil.ActiveState == 1 then 
        value = value + abil.Level
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Hail_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Elementalist17") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Electrocute_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Elementalist20") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FrostCloud_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Elementalist23") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FrostCloud_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 12 + skill.Level * 2

    local abil = GetAbility(pc, "Elementalist40")
    if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        value = 6 + skill.Level * 1
    end

    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FreezingSphere_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Elementalist24") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_pcskill_summon_Familiar(skill)
    local sklLevel = 1;
    local self = GetSkillOwner(skill);
    local parent = GetOwner(self)
    local skl = nil;
    if parent ~= nil then
        skl = GetSkill(parent, 'Sorcerer_SummonFamiliar');
        if skl ~= nil then
            sklLevel = skl.Level
        end
    end
    
    local value = skill.SklFactor + skill.SklFactorByLevel * (sklLevel - 1)
    local abil = GetAbility(parent, "Sorcerer11")      -- Skill Damage add
    if skl ~= nil and abil ~= nil then
        value = SCR_ABIL_ADD_SKILLFACTOR(skl, abil, value);
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SummonFamiliar_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Sorcerer11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Evocation_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Sorcerer12") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Evocation_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local value = 30
    
    return value
    
end

-- 데스모두스 흡혈 디버프와 네크로맨서 시독 디버프 대미지 증가 통합 적용
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SummonDamage_Ratio(skill)
    local value = 84 + (skill.Level) * 3.6

    return value
end

-- 데스모두스 흡혈의 일반 소환수 대미지 증가
-- SCR_GET_SummonDamage_Ratio(skill) 이거 사용해야 됨
function SCR_GET_Desmodus_Ratio(skill)
    local value = skill.Level * 24
    
    return value
end

-- 데스모두스 흡혈의 서모닝 소환수 대미지 증가
-- SCR_GET_SummonDamage_Ratio(skill) 이거 사용해야 됨
function SCR_GET_Desmodus_Ratio2(skill)
    local value = skill.Level * 36
    
    return value
end

-- 네크로맨서 시독의 소환수 대미지 증가
-- SCR_GET_SummonDamage_Ratio(skill) 이거 사용해야 됨
function SCR_GET_GatherCorpse_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local value = 30 * skill.Level

    return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_GatherCorpse_Time(skill)
    local pc = GetSkillOwner(skill);
    local value = 20

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_GatherCorpse_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 5 + skill.Level

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FleshCannon_Ratio2(skill)
    local value = 25 + skill.Level * 5
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FleshHoop_Ratio2(skill)
    local value = skill.Level
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RevengedSevenfold_Time(skill)
    local value = 15
    local pc = GetSkillOwner(skill)
    if IsPVPServer(pc) == 1 then
        value = 7
    end

    local abil = GetAbility(pc, 'Kabbalist32')
    if abil ~= nil and TryGetProp(abil, 'ActiveState', 0) == 1 then
        value = skill.Level
        if IsPVPServer(pc) == 1 then
            value = value * 0.5;
        end
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RevengedSevenfold_Ratio(skill)
    local value = 3.5 * skill.Level
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
-- 아인소프 버프 지속시간
function SCR_GET_Ayin_sof_Time(skill)
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)

    local value = base + skill.Level * per
    local pc = GetSkillOwner(skill);
    if IsPVPServer(pc) == 1 then
        value = value * 0.5
    end
    
    local Kabbalist23_Abil = GetAbility(pc, "Kabbalist23")
    if Kabbalist23_Abil ~= nil and TryGetProp(Kabbalist23_Abil, "ActiveState", 0) == 1 and GetSkill(pc, 'Kabbalist_Ayin_sof') ~= nil then
        value = value * 0.5
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
-- 최대 HP 증가
function SCR_GET_Ayin_sof_Ratio(skill)
    local name = TryGetProp(skill, 'ClassName', 'None')
    local pc = GetSkillOwner(skill);
    local value = 15

    if name == 'Kabbalist_Ayin_sof' then
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    
    local Kabbalist23_Abil = GetAbility(pc, "Kabbalist23")
        if Kabbalist23_Abil ~= nil and TryGetProp(Kabbalist23_Abil, "ActiveState", 0) == 1 and GetSkill(pc, 'Kabbalist_Ayin_sof') ~= nil then
        value = value * 0.5
    end    
    else
        value = 15 
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
-- 5초당 HP 회복
function SCR_GET_Ayin_sof_Ratio2(skill)
    local name = TryGetProp(skill, 'ClassName', 'None')
    local pc = GetSkillOwner(skill);
    
    local value = get_hp_recovery_ratio(pc, TryGetProp(pc, "RHP", 0))

    if name == 'Common_Kabbalist_Ayin_sof' then
        value = get_hp_recovery_ratio(pc, TryGetProp(pc, "RHP", 0))
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
-- 재사용 대기시간 감소%
function SCR_GET_Ayin_sof_Ratio4(skill)
    local name = TryGetProp(skill, 'ClassName', 'None')
    if name == 'Kabbalist_Ayin_sof' then
        return 5
    else
        return TryGetProp(skill, 'Level', 1)
    end
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
-- 재사용 대기시간 버프 시간
function SCR_GET_Ayin_sof_Ratio3(skill)
    local name = TryGetProp(skill, 'ClassName', 'None')
    if name == 'Kabbalist_Ayin_sof' then
        return 90
    else
        return skill.Level * 18
    end
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Ayin_sof_Cri_Ratio(skill)
    return skill.Level
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Gematria_Ratio(skill)
    local value = 10;
    
    local pc = GetSkillOwner(skill);
    local abilKabbalist14 = GetAbility(pc, "Kabbalist14");
    if abilKabbalist14 ~= nil and abilKabbalist14.ActiveState == 1 then
        value = value + abilKabbalist14.Level;
    end
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Notarikon_Ratio(skill)
    local value = 10;
    
    local pc = GetSkillOwner(skill);
    local abilKabbalist14 = GetAbility(pc, "Kabbalist14");
    if abilKabbalist14 ~= nil and abilKabbalist14.ActiveState == 1 then
        value = value + abilKabbalist14.Level;
    end
    
    return value;
end


-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Multiple_Hit_Chance_Ratio(skill)
    local value = skill.Level * 8
  return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Reduce_Level_Ratio(skill)
    local value = skill.Level
  return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Reduce_Level_Ratio2(skill)
    local value = 10 + skill.Level
  return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Clone_Time(skill)
    local value = skill.Level * 3
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PoleofAgony_Bufftime(skill)
    local value = 7 + skill.Level * 1
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PoleofAgony_Ratio2(skill)
    local value = 14
    local pc = GetSkillOwner(skill);
    if IsPVPServer(pc) == 1 then
        value = 7
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Ngadhundi_Ratio2(skill)
    local value = 5
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Enervation_Ratio2(skill)
    local value = 8
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Kundela_Ratio2(skill)
    local value = 3
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BloodExplosion_Ratio2(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Bloodpool_Ratio2(skill)
    local value = 5
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Plague_Ratio2(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Pass_Bufftime(skill)
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)
    local value = base + skill.Level * per
  return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Combustion_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Alchemist11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BloodBath_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Featherfoot3") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BloodBath_Ratio2(skill)

    local value = 10
    return value;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BloodSucking_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Featherfoot4") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BloodSucking_Ratio2(skill)

  local value = 50
  return value;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BloodSucking_Ratio3(skill)

  local value = 40 + skill.Level * 2
  return value;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BonePointing_Ratio2(skill)
    local value = 35
    return value;
end


-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Kurdaitcha_Ratio(skill)

  local value = 15
  return value;
  
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Kurdaitcha_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 15
    
    local abil = GetAbility(pc, 'Featherfoot14')
    if abil ~= nil and 1 == abil.ActiveState then
        value = 5
    end
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HeadShot_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 5 * skill.Level
    if IsPVPServer(pc) == 1 then
        value = (5 * skill.Level) + (pc.HR * 0.1)
    end
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HealingFactor_Time(skill)
    local value = 60
    local pc = GetSkillOwner(skill);
    if IsPVPServer(pc) == 1 then
        value = 20
    end
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HealingFactor_Ratio(skill)
    local value = 1020 + (skill.Level - 1) * 137.5
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Bloodletting_Time(skill)

  local value = 30 + skill.Level * 5
  
  local pc = GetSkillOwner(skill);
  if IsPVPServer(pc) == 1 then
    value = value / 3
  end
   
  return math.floor(value);
  
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Bloodletting_Ratio(skill)

  local value = 6 - skill.Level
  
  if value <= 0 then
  value = 1
  end
  
  return value;
  
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Fumigate_Ratio(skill)
    local value = 5

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Fumigate_Ratio2(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Fumigate(skill)
    local value = SCR_GET_SKL_COOLDOWN_ADD_LEVEL_BYGEM(skill)
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, 'PlagueDoctor29')
    if abil ~= nil and TryGetProp(abil, 'ActiveState', 0) == 1 then
        value = SCR_GET_SKL_COOLDOWN(skill)
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Pandemic_Ratio(skill)
    local value = 3 + skill.Level * 2
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Pandemic_Ratio2(skill)
    local pc = GetSkillOwner(skill)
    local value = 20
    
    if GetExProp(pc, "ITEM_VIBORA_PLAGUEDOCTOR") > 0 then
        value = 30
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Pandemic_Ratio3(skill)
    local pc = GetSkillOwner(skill)
    local value = 100
    
    if GetExProp(pc, "ITEM_VIBORA_PLAGUEDOCTOR") > 0 then
        value = 150
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BeakMask_Time(skill)
    local value = 60
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Modafinil_Ratio(skill)
    local name = TryGetProp(skill, 'ClassName', 'None')
    
    local value = 3 + skill.Level * 0.3;

    if name == 'PlagueDoctor_Modafinil' then
        value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    
        local pc = GetSkillOwner(skill)
        local casterMNA = TryGetProp(pc, "MNA");
        local baseLv = TryGetProp(pc, "Lv");
        
        local addRate = casterMNA / baseLv;
        if addRate <= 0 then
            addRate = 0;
        elseif addRate >= 1 then
            addRate = 1;
        end
        
        value = math.floor(value * (1 + addRate));
    else -- Common_PlagueDoctor_Modafinil
        value = skill.Level * 2.4
    end
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Modafinil_Bufftime(skill)
    local name = TryGetProp(skill, 'ClassName', 'None')
    local pc = GetSkillOwner(skill)
    local value = 20 + skill.Level * 2;
    
    if name == 'Common_PlagueDoctor_Modafinil' then
        value = skill.Level * 8
    end

    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = value / 3
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Disenchant_Ratio(skill)
    local value = math.min(skill.Level * 10, 100)
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Disenchant_Ratio2(skill)
    local value = 2 + skill.Level
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_BonePointing2(skill)

    local value = skill.SklFactor
    local owl = GetSkillOwner(skill);
    local pc = GetOwner(owl);
    if pc ~= nil then
        local bonePointingSkl = GetSkill(pc, "Featherfoot_BonePointing")
        value = bonePointingSkl.SkillFactor
    end

    return math.floor(value)

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BonePointing_Ratio(skill)
    local value = 30 + skill.Level * 10

    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Ngadhundi_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 10
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PoleofAgony_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Warlock2") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Invocation_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Warlock4") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DarkTheurge_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Warlock7") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DarkTheurge_Ratio2(skill)
    local value = 1
    
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Warlock18");

    if abil ~= nil and TryGetProp(abil, "ActiveState") == 1 then
        value = value * 2
    end
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Mastema_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Warlock9") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Drain_Bufftime(skill)
    local value = skill.Level * 4.5
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Drain_Ratio(skill)
    local value = skill.Level
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Drain_Ratio2(skill)
    local value = 0.7
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Hagalaz_Ratio(skill)
    local value = skill.Level * 1.5
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Tiwaz_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "RuneCaster5") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FleshStrike_Ratio(skill)
    local value = skill.Level * 10
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FleshStrike_Ratio2(skill)
    local value = 100
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_AlchemisticMissile_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Alchemist9") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_KundelaSlash_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Featherfoot11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EnchantedPowder_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Enchanter1") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EnchantedPowder_Bufftime(skill)

    local value = 6 + skill.Level * 0.5;
    return value
    
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Rewards_Ratio(skill)

    local value = skill.Level * 10;
    return value
    
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Rewards_Ratio2(skill)

    local value = skill.Level * 10;
    return value
    
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Agility_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Enchanter10") 
    local value = 1 + skill.Level * 0.3
    if abil ~= nil then 
        value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    end
    return math.floor(value)
    
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Agility_Bufftime(skill)

    local value = 300;
    return value
    
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Enchantment_Ratio(skill)

    local value = 4 + skill.Level;
    return value
    
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EnchantLightning_Bufftime(skill)

    local value = 300
    return value
    
end

-- 인챈트 라이트닝
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EnchantLightning_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local sklLv = TryGetProp(skill, "Level", 1)

    local base = TryGetProp(skill, 'SklFactor', 0) / 10
    local per = TryGetProp(skill, 'SklFactorByLevel', 0) / 10

    local value = base + sklLv * per
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return math.floor(value)
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EnchantLightning_Ratio2(skill)
    local value = 1
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Empowering_Bufftime(skill)

    local value = skill.Level * 10 + 20
    return value
    
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Empowering_Ratio(skill)

    local value = skill.Level;
    return value
    
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Empowering_Ratio2(skill)

    local value = skill.Level * 10;
    return value
    
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Portal_Ratio(skill)
    local value = 3
    local pc = GetSkillOwner(skill);
    local abil1 = GetAbility(pc, "Sage1")
    if abil1 ~= nil and 1 == abil1.ActiveState then
        value = value + abil1.Level
    end

    local abil2 = GetAbility(pc, "Sage16")
    if abil2 ~= nil and 1 == abil2.ActiveState then
        value = value + abil2.Level
    end

    local abil3 = GetAbility(pc, "Sage17")
    if abil3 ~= nil and 1 == abil3.ActiveState then
        value = value + abil3.Level
    end

    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Portal_Time(skill)
    local value = 30 - (skill.Level - 1)
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MicroDimension_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Sage2") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_UltimateDimension_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Sage3") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HoleOfDarkness_Ratio(skill)
    local value = 10

    local pc = GetSkillOwner(skill);
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HoleOfDarkness_Ratio2(skill)
    local value = 20
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Gevura_Ratio(skill)
    local value = skill.Level * 20
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Gevura_Ratio2(skill)
    local value = skill.Level * 5
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Maze_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Sage6") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Maze_Bufftime(skill)

    local value = 5 + skill.Level * 1;
    return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Blink_Bufftime(skill)
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Sage5") 
    local value = skill.Level * 2;
    if abil ~= nil and abil.ActiveState == 1 then 
        value = value + abil.Level
    end
    return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MissileHole_Bufftime(skill)
    local base = TryGetProp(skill, 'SklFactor', 0) / 10
    local per = TryGetProp(skill, 'SklFactorByLevel', 0) / 10
    local value = base + (skill.Level * per);
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MissileHole_Ratio(skill)
    local value = 4 + (skill.Level - 1) * 3;
    
    local pc = GetSkillOwner(skill)
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Heal_Time(skill)

    local pc = GetSkillOwner(skill);
    local value = 40;
    
    if IsPVPServer(pc) == 1 then
        value = 10;
    end
    
    return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DivineMight_Ratio(skill)
    local value = skill.Level
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, "Oracle20")
    if abil ~= nil and abil.ActiveState == 1 then
        value = value + abil.Level
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DivineMight_BuffTime(skill)
    local value = 20 + skill.Level * 0.5
    local pc = GetSkillOwner(skill)

    local abilOracle20 = GetAbility(pc, "Oracle20");
    if abilOracle20 ~= nil and TryGetProp(abilOracle20, "ActiveState") == 1 then
        value = value + TryGetProp(abilOracle20, "Level")
    end

    local abilOracle23 = GetAbility(pc, "Oracle23")
    if abilOracle23 ~= nil and abilOracle23.ActiveState == 1 then
        value = 10
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Zaibas_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Kriwi11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Aspersion_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Priest11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Exorcise_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local value = (pc.MNA + pc.INT) * skill.Level
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Exorcise_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Priest20") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Effigy_Ratio3(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Bokor11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Damballa_Ratio(skill)
	local cls = GetClassList("Skill");   
    local sklCls = GetClassByNameFromList(cls, "Bokor_NormalDamballa");			
	local pc = GetSkillOwner(skill)
    local value = sklCls.SklFactor + sklCls.SklFactorByLevel * (skill.Level - 1)-- 스킬팩터 계산
    local reinfabil = skill.ReinforceAbility
    local abil = GetAbility(pc, reinfabil)-- 강화 특성
    if abil ~= nil and TryGetProp(skill, "ReinforceAbility") ~= 'None' then
        local abilLevel = TryGetProp(abil, "Level")
        local masterAddValue = 0
        if abilLevel == 100 then
            masterAddValue = 0.1
        end
        
        value = value * (1 + ((abilLevel * 0.005) + masterAddValue))
        
        local hidden_abil_cls = GetClass("HiddenAbility_Reinforce", skill.ClassName);
        if abilLevel >= 65 and hidden_abil_cls ~= nil then
        	local hidden_abil_name = TryGetProp(hidden_abil_cls, "HiddenReinforceAbil");
        	local hidden_abil = GetAbility(pc, hidden_abil_name);
        	if hidden_abil ~= nil then
        		local abil_level = TryGetProp(hidden_abil, "Level");
        		local add_factor = TryGetProp(hidden_abil_cls, "FactorByLevel", 0) * 0.01;
        		local add_value = 0;
        		if abil_level == 10 then
        			add_value = TryGetProp(hidden_abil_cls, "AddFactor", 0) * 0.01
        		end
        		value = value * (1 + (abil_level * add_factor) + add_value);
        		
        	end
        end
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Damballa_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local value = skill.Level * 3
  return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BwaKayiman_Ratio(skill)
    local value = skill.Level

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Carve_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Dievdirbys11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_CarveOwl_Add_SkillFactor(skill, level)
    local pc = GetSkillOwner(skill)
    local value = skill.SklFactorByLevel * level
    local reinfabil = TryGetProp(skill, "ReinforceAbility", 'None')
    local abil = GetAbility(pc, reinfabil)
    if reinfabil ~= 'None' and abil ~= nil then
        local abilLevel = TryGetProp(abil, "Level")
        local masterAddValue = 0
        if abilLevel == 100 then
            masterAddValue = 0.1
        end
        
        value = value * (1 + ((abilLevel * 0.005) + masterAddValue))
        
        local hidden_abil_cls = GetClass("HiddenAbility_Reinforce", skill.ClassName)
        if abilLevel >= 65 and hidden_abil_cls ~= nil then
        	local hidden_abil_name = TryGetProp(hidden_abil_cls, "HiddenReinforceAbil")
        	local hidden_abil = GetAbility(pc, hidden_abil_name)
        	if hidden_abil ~= nil then
        		local abil_level = TryGetProp(hidden_abil, "Level")
        		local add_factor = TryGetProp(hidden_abil_cls, "FactorByLevel", 0) * 0.01
        		local add_value = 0
        		if abil_level == 10 then
        			add_value = TryGetProp(hidden_abil_cls, "AddFactor", 0) * 0.01
        		end
        		value = value * (1 + (abil_level * add_factor) + add_value)
        	end
        end
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_CarveOwl2(skill)

    local value = skill.SklFactor
    local owl = GetSkillOwner(skill);
    local pc = GetOwner(owl);
    if pc ~= nil then
        local carveOwlSkl = GetSkill(pc, "Dievdirbys_CarveOwl")
        if carveOwlSkl ~= nil then
            value = carveOwlSkl.SkillFactor

            local addLv = GetExProp(owl, 'OWL_LV_UP')
            if addLv ~= nil and addLv > 0 then
                local addFactor = SCR_Get_CarveOwl_Add_SkillFactor(carveOwlSkl, addLv)
    
                value = value + addFactor
            end
        end
    end

    return math.floor(value)

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_OwlStatue_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Dievdirbys12") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_AstralBodyExplosion_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Sadhu11") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Possession_Ratio(skill)
    local value = TryGetProp(skill, "Level", 1) * 0.3 + 1
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Possession_Ratio2(skill)
    local value = 7
    local pc = GetSkillOwner(skill);
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_EctoplasmAttack(skill)
    local pc = GetSkillOwner(skill);
    local OutofBodySkill = GetSkill(pc, "Sadhu_OutofBody")
    local value = 0
    if OutofBodySkill ~= nil then
        value = OutofBodySkill.SkillFactor;
    end
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Levitation_ratio(skill)
    local value = 30;
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_BloodCurse_ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 30
    
    local abil = GetAbility(pc, 'Featherfoot12')
    if abil ~= nil and 1 == abil.ActiveState then
        value = 20
    end
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_BloodCurse_BuffTime(skill)

    local value = 5 + 0.5 * skill.Level
    local pc = GetSkillOwner(skill);
    
    local abil = GetAbility(pc, 'Featherfoot12')
    if abil ~= nil and 1 == abil.ActiveState then
        value = value + abil.Level * 7
    end
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Smite_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 10

    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Demolition_Ratio(skill)
    local value = skill.Level * 2;
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Conviction_BuffTime(skill)
    local value = 20
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Conviction_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Paladin17") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Conviction_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local value = skill.Level * 2;
    
    return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CorpseTower_Bufftime(skill)

    local value = 30;
    
    return value

end

-- 쌍쇄공 공격 속도 증가
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DoublePunch_Ratio(skill)
    local value = skill.Level * 20    
    return value
end

-- 쌍쇄공 추가 대미지 수치
-- 바뀌면 cpp의 SKILL_AFTERCALC_HIT(DoublePunch_Attack) 내용 수정 필요
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DoublePunch_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local str = TryGetProp(pc, 'STR', 0)
    local dex = TryGetProp(pc, 'DEX', 0)    
    local value = skill.Level * ((str + dex) * 0.5)
    return value
end

-- 쌍쇄공 스킬 계수
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_DoublePunch(skill)
    local pc = GetSkillOwner(skill);
    local DoublePunchSkill = GetSkill(pc, "Monk_DoublePunch")
    local value = 0
    if DoublePunchSkill ~= nil then
        value = DoublePunchSkill.SkillFactor;
    end    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PalmStrike_Ratio(skill)
    local value = skill.Level
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HandKnife_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Monk18") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Bunshin_no_jutsu_BuffTime(skill)


    local value = skill.Level * 10

 return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Aspergillum_Time(skill)
    local value = 30
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Methadone_Time(skill)
    local value = 5 + skill.Level
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_IronMaiden_Time(skill)
    local value = 2 + skill.Level * 0.3
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Judgment_Bufftime(skill)
    local value = 30 + skill.Level * 6
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_LastRites_Time(skill)
    local value = 30
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_LastRites_Ratio(skill)
    local pc = GetSkillOwner(skill);    

    local value = (3.5 + skill.Level * 0.3)
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MagnusExorcismus_Time(skill)
    local value = 9
    return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BuildCappella_Ratio(skill)
    local value = 30
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BuildCappella_Ratio2(skill)
    local value = skill.Level * 2.5
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Binatio_Time(skill)
    local value = 30;
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ParaclitusTime_Time(skill)
    local pc = GetSkillOwner(skill)
    local value = 20 + skill.Level * 2

    if IsPVPField(pc) == 1 then
        value = math.floor(value / 2)
    end

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ParaclitusTime_Ratio(skill)
    local value = skill.Level * 5
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_1InchPunch_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Monk21") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EnergyBlast_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Monk23") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EnergyBlast_Ratio3(skill)
    local value = 35 + skill.Level * 1;
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_God_Finger_Flicking_Ratio3(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Monk24") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Indulgentia_Ratio2(skill)
    local value = 76 + (skill.Level - 1) * 10
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_IncreaseMagicDEF_Bufftime(skill)
    local pc = GetSkillOwner(skill);
    local value = 300
    
    local abil = GetAbility(pc, "Pardoner6")
    local ActiveState = TryGetProp(abil, "ActiveState")
    if abil ~= nil and ActiveState == 1 then
        local abilLevel = TryGetProp(abil, "Level")
        local abilValue = abilLevel * 20
        
        value = value + abilValue
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_IncreaseMagicDEF_Ratio(skill)
    local value = 0

    if TryGetProp(skill, 'ClassName', 'None') == 'Pardoner_IncreaseMagicDEF' then
        local pc = GetSkillOwner(skill);
        value = skill.Level * 1.5
        local pcStat = TryGetProp(pc, "MNA", 1)
        local pcLevel = TryGetProp(pc, "Lv", 1)
        local casterMnaRate = (pcStat / (pcStat + pcLevel) * 2) + 0.15
        
        value = value * casterMnaRate
        value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    else
        local lv = TryGetProp(skill, 'Level', 0)
        value = lv * 4
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_IncreaseMagicDEF_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = skill.Level * 3;

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Incineration_Ratio2(skill)
    local value = 10

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Incineration_Ratio3(skill)
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "PlagueDoctor15") 
    local value = 0.5
    if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then 
        value = value - 0.2   
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Nachash_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value - 2) ^ 0.5)) + math.min(2, value)
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Merkabah_Ratio(skill)
    local value = skill.Level * 3

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Merkabah_Ratio2(skill)

    local value = skill.Level * 10;
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MagnusExorcismus_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Chaplain3") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PlagueVapours_Ratio(skill)
    local value = skill.Level * 2

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PlagueVapours_Bufftime(skill)
    local value = 15
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_IronMaiden_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Inquisitor2") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HereticsFork_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Inquisitor3") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_IronBoots_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Inquisitor4") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PearofAnguish_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Inquisitor6") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PearofAnguish_Ratio2(skill)
    local value = 5;
    return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BreakingWheel_Bufftime(skill)
    local value = 10;
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, "Inquisitor20")
    if abil ~= nil and abil.ActiveState == 1 then
        value = value + abil.Level
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MalleusMaleficarum_Bufftime(skill)
    local value = 7 + skill.Level * 3
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MalleusMaleficarum_Ratio(skill)
    local value = 6 + (skill.Level -1)* 6;
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_GodSmash_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Inquisitor10")
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Entrenchment_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Daoshi2") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Hurling_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Daoshi3") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_StormCalling_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = 8
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value - 2) ^ 0.5)) + math.min(2, value)
    end
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PhantomEradication_Ratio(skill)
    local value = 6;
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BegoneDemon_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Daoshi9") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DarkSight_Time(skill)
    local value = skill.Level * 60
    
    local pc = GetSkillOwner(skill);
    if IsPVPServer(pc) == 1 then
        value = 30;
    end
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DarkSight_Ratio(skill)
    local value = 40 * (1 + skill.Level * 0.1)
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Hurling_Ratio2(skill)
    local value = skill.Level
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HiddenPotential_Ratio(skill)
    local value = 10 * skill.Level
    
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Daoshi5")
    if abil ~= nil and 1 == abil.ActiveState then
        value = value + abil.Level
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HiddenPotential_Ratio2(skill)
    local value = 50 * skill.Level
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HiddenPotential_Time(skill)
    local value = 60
    
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Daoshi6")
    if abil ~= nil and 1 == abil.ActiveState then
        value = value + abil.Level * 5;
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_StormCalling_Ratio2(skill)
    local value = skill.Level * 20
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_StormCalling_Time(skill)
    local value = 10
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TriDisaster_Time(skill)
    local value = 12 * skill.Level
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TriDisaster_Ratio(skill)
    local value = skill.Level * 5
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill);
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CreepingDeath_Ratio(skill)
    local value = 10
    local owner = GetSkillOwner(skill)
    local abilDaoshi37 = GetAbility(owner, "Daoshi37")
    if abilDaoshi37 ~= nil and TryGetProp(abilDaoshi37, "ActiveState", 0) == 1 then
        value = 5
    end
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CreepingDeath_Ratio2(skill)
    local value = 624
    
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ShapeShifting_Bufftime(skill)
    local value = 50 + skill.Level * 10
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Transform_Bufftime(skill)
    local value = 50 + skill.Level * 10
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Lycanthropy_Bufftime(skill)
    local value = 30
    
    if TryGetProp(skill, 'ClassName', 'None') == 'Common_Druid_Lycanthropy' then
        value = 15
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Lycanthropy_Ratio(skill)
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)
    local value = base + skill.Level * per
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Lycanthropy_Ratio2(skill)
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)

    local value = base + skill.Level * per
    
    local pc = GetSkillOwner(skill);
    local abilDruid20 = GetAbility(pc, "Druid20");
    if abilDruid20 ~= nil and TryGetProp(abilDruid20, 'ActiveState') == 1 then
        value = value + 10
    end
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Muleta(skill)
    local pc = GetSkillOwner(skill);
    local MuletaSkill = GetSkill(pc, "Matador_Muleta")
    local value = 0
    if MuletaSkill ~= nil then
        value = MuletaSkill.SklFactor + (MuletaSkill.Level - 1) * MuletaSkill.SklFactorByLevel
        
        local abil = GetAbility(pc, "Matador1")      -- Skill Damage add
        if abil ~= nil then
            value = SCR_ABIL_ADD_SKILLFACTOR(MuletaSkill, abil, value);
        end
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Muleta_CastTime(skill)
    local value = 1;
    
    local pc = GetSkillOwner(skill);
    local abilMatador7 = GetAbility(pc, "Matador7");
    if abilMatador7 ~= nil and TryGetProp(abilMatador7, 'ActiveState') == 1 then
        value = value + (abilMatador7.Level * 0.5);
    end
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Muleta_Ratio(skill)
    local value = 914 + (skill.Level - 1) * 50.3
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Matador1")
    if abil ~= nil then
        value = value * (1 + (abil.Level * 0.005))
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Muleta_Ratio2(skill)
    local value = skill.Level * 2
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_DoubleGun(skill)
    local pc = GetSkillOwner(skill);
    local DoubleGunSkill = GetSkill(pc, "Bulletmarker_DoubleGunStance")
    local value = 0
    if DoubleGunSkill ~= nil then
        value = DoubleGunSkill.SklFactor + (DoubleGunSkill.Level - 1) * DoubleGunSkill.SklFactorByLevel
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DoubleGunStance_Ratio(skill)
    local value = 100 + skill.Level * 10
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DoubleGunStance_Ratio2(skill)
    local value = 20 + skill.Level * 4
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EmperorsBane_Time(skill)
    local value = 4
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EmperorsBane_Ratio(skill)
    local value = 8
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Gohei_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Miko1") 
    local value = 0
    if abil ~= nil then 
        return SCR_ABIL_ADD_SKILLFACTOR_TOOLTIP(abil);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Hamaya_Ratio(skill)
    local value = skill.Level * 2

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Hamaya_Ratio2(skill)
    local value = 10
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HoukiBroom_Time(skill)
    local value = 5
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HoukiBroom_Ratio(skill)
    local value = 5 + skill.Level
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_KaguraDance_Time(skill)
    local value = 15
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, 'Miko18')
    if abil ~= nil and TryGetProp(abil, 'ActiveState', 0) == 1 then
        value = 5
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_KaguraDance_Ratio(skill)
    local value = 12 + skill.Level * 3
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Omikuji_Time(skill)
    local value = 20
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Omikuji_Ratio(skill)
    local value = 7.5 + (2.5 * skill.Level)
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Omikuji_Ratio2(skill)
    local value = 90 + (10 * skill.Level)

    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Omikuji_Ratio3(skill)
    local value = 22.5 + (2.5 * skill.Level)
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Invulnerable_Time(skill)
    local name = TryGetProp(skill, 'ClassName', 'None')
    if name == 'Zealot_Invulnerable' then
    local value = 20 + skill.Level
    return value
    else
        local value = skill.Level * 7
        return value
    end
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Immolation_Ratio2(skill)
    local value = skill.Level * 0.001
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Fanaticism_Ratio(skill)
    local value = 30 + skill.Level * 6
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BlindFaith_Ratio(skill)
    local value = 20 + ((skill.Level - 1) * 20)
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FanaticIllusion_Time(skill)
    local value = 5 + skill.Level * 2

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Fanaticism_Time(skill)
    local value = 10 + skill.Level * 2

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_KaguraDance_Ratio2(skill)
    local value = 16 + skill.Level * 3
    return math.floor(value)
end


--[BodkinPoint]]--
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_BodkinPoint_SkillFactor(skill)
    local value = 112 + skill.Level * 8;
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_BodkinPoint(skill)
    local pc = GetSkillOwner(skill);
    return math.floor(1 + pc.SR + (skill.Level * 0.2))

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_Skarphuggning(skill)
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Hackapell10")
    local value = pc.SR + skill.SklSR
    if abil ~= nil and abil.ActiveState == 1 then
        value = value + abil.Level
    end

    if IsPVPField(pc) == 1 and value > 4 then
        value = math.floor((math.max(0, value-4)^0.5))+math.min(4, value)
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Kasiwade_Ratio(skill)
    local value = skill.Level * 5
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Kasiwade_Ratio2(skill)
    local value = 22.5 + skill.Level * 1.5
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_Stabbing(skill)
    return 1
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_Murmillo(skill)
    local pc = GetSkillOwner(skill);
    if pc == nil and ui.GetFrame("pub_createchar"):IsVisible() == 1 then
        return skill.SklSR;
    end

    local value = pc.SR + skill.SklSR;
    
    local abil = GetAbility(pc, "Murmillo29")
    if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 and IsBuffApplied(pc, "Sprint_Buff") == "YES" then
        value = value * 2
    end

    if IsPVPField(pc) == 1 and value > 4 then
        value = math.floor((math.max(0, value-4)^0.5))+math.min(4, value)
    end

    if value < 1 then
        value = 1
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_BodkinPoint_Ratio(skill)
    return 25 + skill.Level * 1;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_DeployPavise_Time(skill)
    local pc = GetSkillOwner(skill);
    local value = 30;
    
    local abil = GetAbility(pc, 'QuarrelShooter24')
    if abil ~= nil and abil.ActiveState == 1 then
        value = value * 0.5;
    end
    
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_DeployPavise_Ratio(skill)
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)

    local value = base + skill.Level * per;
    
    local pc = GetSkillOwner(skill);
    if IsPVPField(pc) == 1 then
        value = math.min(15, value);
    else
        local abil = GetAbility(pc, 'QuarrelShooter24')
        if abil ~= nil and abil.ActiveState == 1 then
            value = math.ceil(value * 0.5)
        end
    end
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_DeployPavise_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, 'QuarrelShooter9')
    local value = 40
    if abil ~= nil and abil.ActiveState == 1 then
        value = value + abil.Level * 1
    end
    
    return value 
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_BounceShot_Ratio(skill)
    local value = 6;
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SmokeBomb_Ratio(skill)
    return 50 + skill.Level * 0.5;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_ArrowSprinkle_Ratio(skill)
    return 0 + skill.Level;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SteadyAim_Ratio(skill)
    local value = skill.Level
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SteadyAim_Ratio2(skill)
    local value = 18 + skill.Level * 3
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Retrieve_Bufftime(skill)
    return 4 + skill.Level;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Retrieve_Ratio(skill)
    return 10 + 6 * skill.Level;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Hounding_Ratio(skill)
    local value = 600 + skill.Level * 100
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Snatching_Bufftime(skill)
    return 2 * skill.Level;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_StoneCurse_Bufftime(skill)
    local pc = GetSkillOwner(skill)
    local value = 1 + skill.Level;
    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = value / 3
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_StoneCurse_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = 5;
    
    local abil = GetAbility(pc, 'Elementalist2')
    if abil ~= nil and 1 == abil.ActiveState then
        value = value + abil.Level;
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SummonFamiliar_Ratio(skill)
    return skill.Level
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SummonSalamion_BuffTime(skill)
    local pc = GetSkillOwner(skill)
    return 50 + skill.Level * 10
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SummonSalamion_Ratio(skill)
    local value = 14.72 + (skill.Level * 5.152);
    return value * SUMMON_ADD_ATK_TRANSFER_RATIO;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SummonSalamion_Ratio2(skill)
    local value = 16 + (skill.Level * 5.6);
    return value * SUMMON_ADD_DEF_TRANSFER_RATIO;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SummonSalamion_Ratio3(skill)
    local value = 24 + (skill.Level * 8.4);
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SummonServant_Ratio(skill)
    local value = skill.Level
    
    if value > 5 then
        value = 5
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Hail_Bufftime(skill)
    local value = 10
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Rain_Bufftime(skill)
    local value = 8 + skill.Level * 2
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Rain_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 0;
    
    local abil = GetAbility(pc, 'Elementalist9')
    if abil ~= nil and 1 == abil.ActiveState then
        value = value + abil.Level * 5;
    end
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SafetyZone_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = skill.Level * 2;
    
    local abil = GetAbility(pc, 'Cleric18')
    if abil ~= nil and 1 == abil.ActiveState then
        value = value + abil.Level * 1;
    end
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Briquetting_Ratio(skill)
    local value = 4.5 + skill.Level * 0.5;
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ItemAwakening_Ratio(skill)
    return skill.Level;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Arrest_Ratio(skill)
    local value = 1 + skill.Level * 1
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Quicken_Ratio(skill)
    local value = 15 + (skill.Level * 10)
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Quicken_Bufftime(skill)
    return 4 + skill.Level * 0.4
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Samsara_Bufftime(skill)
    local pc = GetSkillOwner(skill)
    local value = 5 + skill.Level * 1
    -- 팀 배틀리그 토너먼트만 해당함 -------
    if IsPVPServer(pc) == 1 then
        value = value * 0.5
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Stop_Time(skill)
    local pc = GetSkillOwner(skill)
    local value = 5 + skill.Level * 1
    local zone = GetZoneName(pc);
    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = value * 0.5
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Bodkin_Ratio(skill)
    local value = 7.5 + (skill.Level * 1.5)
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Haste_Bufftime(skill)
    local value = 40 + skill.Level * 8;
    
    local pc = GetSkillOwner(skill)
    if IsPVPServer(pc) == 1 then
        value = value / 3
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_CreateShoggoth_Ratio(skill)
    local value = 69 + skill.Level * 11.5;
    return math.floor(value) * SUMMON_ADD_ATK_TRANSFER_RATIO;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_CreateShoggoth_Ratio2(skill)
    local value = 60 + skill.Level * 10;
    return math.floor(value) * SUMMON_ADD_DEF_TRANSFER_RATIO;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_CreateShoggoth_Ratio3(skill)
    local value = 60 + skill.Level * 10;
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_CreateShoggoth_Parts(skill)
  local pc = GetSkillOwner(skill);
    local value = 30
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_FleshCannon_Ratio(skill)
    local value = 15
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_FleshHoop_Ratio(skill)
    local value = 5
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DirtyWall_Bufftime(skill)
    local value = 14 + skill.Level
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DirtyWall_Ratio(skill)
    local value = 2 + skill.Level
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DirtyWall_Ratio2(skill)
    local value = 30
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DirtyPole_Time(skill)
    local value = 14 + skill.Level
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DirtyPole_Ratio(skill)
    local value = 20 + skill.Level * 2
    local pc = GetSkillOwner(skill)
    if IsPVPServer(pc) == 1 then
        value = 900
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DirtyPole_Ratio2(skill)
    local value = 5
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Disinter_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = 70;
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Cloaking_Bufftime(skill)
    return 18 + skill.Level * 2;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Cloaking_Ratio(skill)
    local value = 23 + skill.Level * 2;
    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill))
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DoubleAttack_Ratio(skill)
    local value = skill.Level * 5
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DoubleAttack_Ratio2(skill)
    local value = 40
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FreeStep_Ratio(skill)
    local value = skill.Level * 4
    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill))
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SwellBody_Bufftime(skill)
    return 5 + skill.Level;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_ShrinkBody_Bufftime(skill)
    return 5 + skill.Level;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SwellBody_Ratio(skill)
    local base = TryGetProp(skill, 'SklFactor', 0) / 10
    local per = TryGetProp(skill, 'SklFactorByLevel', 0) / 10
    return base + (skill.Level * per) 
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_ShrinkBody_Ratio(skill)
    return math.floor(3 + skill.Level * 0.5)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Praise_Bufftime(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 then
        value = 5
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Praise_Ratio(skill)
    local value = 10 + skill.Level * 2
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Praise_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 0.3 * skill.Level
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Pointing_Ratio(skill)
    return 10 + skill.Level * 6
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Growling_Ratio(skill)
    local value = 10
    local pc = GetSkillOwner(skill);
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Growling_Ratio2(skill)
    local value = 3 + (skill.Level - 1) * 1
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Growling_Time(skill)
    local value = 5 - (skill.Level - 1) * 0.5
    if value < 3 then
        value = 3
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Camouflage_Ratio(skill)
    local value = skill.Level * 5
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Camouflage_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local spdrate = 1 - (skill.Level * 0.1)
    local value = math.max(30 * spdrate, pc.MSPD * spdrate)
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_FluFlu_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 5;
    
    local Scout6_abil =  GetAbility(pc, 'Scout6')
    if Scout6_abil ~= nil and 1 == Scout6_abil.ActiveState then 
        value = value + (Scout6_abil.Level * 1)
    end

    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Beprepared_Ratio(skill)
    local value = 5 * skill.Level * 1;
    return math.floor(value);
    
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Fluflu_Bufftime(skill)
    local value = 8 + skill.Level * 0.2;
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_StoneShot_Bufftime(skill)
    local value = 4;
    local pc = GetSkillOwner(skill);
    local zone = GetZoneName(pc);
    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = value / 2
    end
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SnowRolling_Ratio(skill)
    local value = skill.Level * 2
    local pc = GetSkillOwner(skill);
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Barrier_Ratio(skill)
    local value = 24 + skill.Level * 6
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Sanctuary_Ratio(skill)
    local value = 10 + skill.Level * 2
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, "Paladin40")
    if abil ~= nil and abil.ActiveState == 1 then
        value = 20 + skill.Level * 4
    end

    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Sanctuary_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local MDEF = SCR_CALC_BASIC_MDEF(pc);
    local mdefRate = MDEF * (0.1 * skill.Level)
    
    return math.floor(mdefRate)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Sanctuary_Ratio3(skill)
    local value = 30
    local pc = GetSkillOwner(skill);
    local level = pc.Lv
    local bylvCorrect = level - 300
    
    if bylvCorrect < 0 then
        bylvCorrect = bylvCorrect * 2.75 / 1000
    elseif bylvCorrect >= 0 then
        bylvCorrect = bylvCorrect * 1.25 / 1000
    end
    
    value = value * (1 + bylvCorrect)
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Undistance_Ratio(skill)
    local value = 55 + skill.Level *5;
    return value
    
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Undistance_Ratio2(skill)
    local value = 10 + skill.Level * 1
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_DetonateTraps_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 4

    local abil = GetAbility(pc, "Sapper4")
    if abil ~= nil and 1 == abil.ActiveState then
        value = value + abil.Level;
    end

    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Detoxify_Ratio(skill)
    local value = 3
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Daino_Ratio(skill)
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)

    local value = base + TryGetProp(skill, 'Level', 1) * per
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Daino_Ratio2(skill)
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)

    local value = base + TryGetProp(skill, 'Level', 1) * per
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Coursing_Bufftime(skill)

    local value = 5 + skill.Level * 2;
    return math.floor(value)

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Coursing_Ratio(skill)
    local value = 5 + skill.Level * 0.5;
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Scan_Time(skill)

    local value = 8 + skill.Level * 2
    return math.floor(value)
    
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Surespell_Bufftime(skill)
    return 45 + skill.Level * 18;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Surespell_Ratio(skill)
    local value = skill.Level - 1
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Quickcast_Bufftime(skill)
    local value = 300
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Quickcast_Ratio(skill)
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)
    local value = base + skill.Level * per
    if value > 90 then
        value = 90
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ScatterCaltrop_Time(skill)
    local pc = GetSkillOwner(skill);
    local value = 20;
    
    local abil = GetAbility(pc, "QuarrelShooter2")
    if abil ~= nil and 1 == abil.ActiveState then
        value = value + abil.Level;
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_ScatterCaltrop_Ratio2(skill)
    local value = skill.Level;
    
    if value > 15 then
        value = 15
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_EnergyBolt_SkillFactor(skill)

    local value = 150 + skill.Level * 12;
    return value;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_HighAnchoring(skill)

    local pc = GetSkillOwner(skill);
    local value = pc.SR + skill.SklSR + skill.Level * 1

    if IsPVPField(pc) == 1 and value > 4 then
        value = math.floor((math.max(0, value-4)^0.5))+math.min(4, value)
    end

    return value

end

--[Psychokino_Telekinesis]--
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Telekinesis_SkillFactor(skill)

    local value = 110 + skill.Level * 3;
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Telekinesis_ThrowDist(skill)
    return 30 + skill.Level * 5;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PsychicPressure_Ratio(skill)
    local value = skill.Level + 4
    local pc = GetSkillOwner(skill);
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PsychicPressure_Ratio2(skill)
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, 'Psychokino10')
    if abil ~= nil and abil.ActiveState == 1 then
        return 2;
    end
    return 1
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PsychicPressure_Ratio3(skill)
    local pc = GetSkillOwner(skill);
    local value = 42
    local bylvCorrect = pc.Lv - 300
    if bylvCorrect < 0 then
        bylvCorrect = bylvCorrect * 2.75 / 1000
    elseif bylvCorrect >= 0 then
        bylvCorrect = bylvCorrect * 1.25 / 1000
    end
    
    value = value * (1 + bylvCorrect)
    
    local abil = GetAbility(pc, 'Psychokino10')
    if abil ~= nil and abil.ActiveState == 1 then
        value = value * 1.2
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_GravityPole_Ratio(skill)
    local value = 10 + skill.Level * 1
    local pc = GetSkillOwner(skill);
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_GravityPole_Ratio3(skill)
    local pc = GetSkillOwner(skill);
    local value = 47
    local bylvCorrect = pc.Lv - 300
    if bylvCorrect < 0 then
        bylvCorrect = bylvCorrect * 2.75 / 1000
    elseif bylvCorrect >= 0 then
        bylvCorrect = bylvCorrect * 1.25 / 1000
    end
    
    value = value * (1 + bylvCorrect)
    
    local abil = GetAbility(pc, 'Psychokino20')
    if abil ~= nil and abil.ActiveState == 1 then
        value = value * 1.2
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Telekinesis_ThrowCount(skill)
    
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, 'Psychokino1');
    if abil ~= nil and 1 == abil.ActiveState then
        return math.ceil(0.5 * skill.Level) + abil.Level;
    end

    return math.ceil(0.5 * skill.Level)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Telekinesis_Holdtime(skill)
    local pc = GetSkillOwner(skill)
    local value = 3 + skill.Level * 1;
    local zone = GetZoneName(pc);
    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = value * 0.5;
    end
    
    return math.floor(value);

end

--[Wizard_MagicMissile]--
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_MagicMissile_SkillFactor(skill)
    local value = 160 + skill.Level * 15;
    return value;
end


--[Pyromancer_FireBall]--
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_FireBall_SkillFactor(skill)
    local value = 180 + skill.Level * 14;
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_FireBall(skill)
    return skill.Level
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_WoodCarve(skill)
    return 1;
end


--[Pyromancer_EnchantFire]--
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EnchantFire_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local int = TryGetProp(pc, 'INT', 0)
    local mna = TryGetProp(pc, 'MNA', 0)    
    local bonus = (int + mna) * 3

    local value = 100 + ((TryGetProp(skill, 'Level', 1) - 1) * 100) + bonus
    
    local Pyromancer16_abil = GetAbility(pc, 'Pyromancer16');
    if Pyromancer16_abil ~= nil then
        value = value + TryGetProp(Pyromancer16_abil, 'Level', 1)
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EnchantFire_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local int = TryGetProp(pc, 'INT', 0)
    local mna = TryGetProp(pc, 'MNA', 0)    
    local bonus = (int + mna) * 2
    
    local value = pc.MINMATK * 0.1 + bonus    
    return math.floor(value)  
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_FireBall_Bufftime(skill)
  return 20 + skill.Level * 5
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HellBreath_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 20
    local bylvCorrect = pc.Lv - 300
    if bylvCorrect < 0 then
        bylvCorrect = bylvCorrect * 2.75 / 1000
    elseif bylvCorrect >= 0 then
        bylvCorrect = bylvCorrect * 1.25 / 1000
    end
    
    value = value * (1 + bylvCorrect)
    
    local abil = GetAbility(pc, 'Pyromancer4')
    if abil ~= nil and abil.ActiveState == 1 then
        value = value * 1.3
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Rapidfire_Bufftime(skill)
    local value = 1 + skill.Level*0.2
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EnchantFire_Bufftime(skill)
  return 300;
end

--[Pyromancer_FirePillar]--
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_FirePillar_SkillFactor(skill)
    local value = 26 + skill.Level * 4;
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FirePillar_Time(skill)
    return 6 + skill.Level * 0.04;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FirePillar_HitCount(skill)
    return 5 + skill.Level;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FireWall_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = 5
    
    local abil = GetAbility(pc, "Pyromancer31")
    if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        value = value * 2
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FireWall_Ratio2(skill)
    return 2 + skill.Level;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_IceWall_Ratio(skill)
    return 1 + skill.Level * 1
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_IceWall_Ratio3(skill)
    local pc = GetSkillOwner(skill);
    local value = 60

    local abilCryomancer9 = GetAbility(pc, "Cryomancer9");
    if abilCryomancer9 ~= nil and TryGetProp(abilCryomancer9, "ActiveState") == 1 then
        value = math.floor(value * (1 + abilCryomancer9.Level * 0.05));
    end
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ElementalEssence_Ratio(skill)
    local value = skill.Level * 10
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Blessing_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local pcMNA = TryGetProp(pc, "MNA", 0)
    local int = TryGetProp(pc, "INT", 0)
    local mna_bonus = pcMNA * 1.5
    local int_bonus = int * 1.5
    local baseDamageValue = 150 + (skill.Level) * 150    
    local value = baseDamageValue + mna_bonus + int_bonus    
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Blessing_AddCount(skill)
    local pc = GetSkillOwner(skill);
    local value = 2
    
    local Priest6_abil = GetAbility(pc, 'Priest6');
    if Priest6_abil ~= nil and 1 == Priest6_abil.ActiveState then
        value = value + Priest6_abil.Level
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Carve_BuffTime(skill)
    local pc = GetSkillOwner(skill);
    local value = skill.Level * 5
    
    local Dievdirbys1_abil = GetAbility(pc, 'Dievdirbys1');
    if Dievdirbys1_abil ~= nil and 1 == Dievdirbys1_abil.ActiveState then
        value = value + Dievdirbys1_abil.Level
    end
    
    return math.floor(value);

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Sacrament_Bufftime(skill)
    return 15;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Sacrament_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local pcMNA = TryGetProp(pc, "MNA")
    local mna_bonus = pcMNA * 2
    local baseDamageValue = 100 + (skill.Level) * 100    
    local value = baseDamageValue + mna_bonus    
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)    
    return math.floor(value)
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Sacrament_Ratio2(skill)
    local pc = GetSkillOwner(skill)
    local value = 4 + skill.Level + math.floor(skill.Level / 4)
    if value > 10 then
        value = 10
    end
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Revive_Bufftime(skill)
    local pc = GetSkillOwner(skill);
    local value = 90
    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = 15
    end
    local Priest21_abil = GetAbility(pc, 'Priest21')
    if Priest21_abil ~= nil and 1 == Priest21_abil.ActiveState and IsPVPServer(pc) == 0 then
        value = value + Priest21_abil.Level * 7
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Revive_Ratio(skill)
    local value = 24 + skill.Level * 6
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Revive_Ratio2(skill)
    local pc = GetSkillOwner(skill)
    local value = 2.4 + skill.Level * 0.6;

    if IsPVPServer(pc) == 1 then
        value = 1.5
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Exorcise_Bufftime(skill)
    local value = 10
    
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, 'Priest23')
    if abil ~= nil and abil.ActiveState == 1 then
        value = value + abil.Level
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MassHeal_Ratio(skill)
    return SCR_GET_MassHeal_Ratio_Common(skill)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MassHeal_Ratio_Common(skill)
    local value = 422.4 + (skill.Level - 1) * 202.56
    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill))
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MassHeal_Ratio2(skill)
    local value = SCR_GET_SkillFactor_By_Other(skill, 'Priest_Luminosity')
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MassHeal_Luminosity_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_StoneSkin_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)
    local value = base + skill.Level * per
    value = value / 100

    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MeteorSwarm_Count(skill)
    local meteorCount = 1 + (skill.Level - 1) / 2
    
    if meteorCount > 10 then
        meteorCount = 10;
    end
    return math.floor(meteorCount);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Burrow_Ratio(skill)
local value = 5 * skill.Level
return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Burrow_Time(skill)
    local value = 20 + skill.Level * 2
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_HellFire_SkillFactor(skill)
    local value = 57 + skill.Level * 3;
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Wizard_Wild_Ratio(skill)
    return 15 + skill.Level * 2;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Wizard_Wild_Ratio2(skill)
    return 60 - skill.Level * 10;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SwiftStep_Bufftime(skill)
    return 300
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SwiftStep_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 10 - skill.Level;
    
    if value <= 0 then
        value = 1;
    end
    
    return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SwiftStep_Ratio2(skill)
    local value = 3 * skill.Level;
    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill));
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SwiftStep_Ratio3(skill)
     local mspdadd = 15
     return mspdadd;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Concentration_Ratio(skill)
     local value = 2 * skill.Level;
     value = value * SCR_REINFORCEABILITY_TOOLTIP(skill);
     
     return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Concentration_BuffTime(skill)
     local value = 300
     return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Fulldraw_BuffTime(skill)
    local pc = GetSkillOwner(skill);
    return 5 + 1 * skill.Level;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Lethargy_Bufftime(skill)
    local value = 20;
    local pc = GetSkillOwner(skill);
    
    local Wizard6_abil = GetAbility(pc, 'Wizard6')
    if Wizard6_abil ~= nil and 1 == Wizard6_abil.ActiveState then 
        value = value + Wizard6_abil.Level * 2
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SpiralArrow_Ratio(skill)
    return 6;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Lethargy_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = skill.Level * 2
    local abil = GetAbility(pc, "Wizard27")
    if abil ~= nil and abil.ActiveState == 1 then
        value = value * (1 + (abil.Level * 0.005))
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Lethargy_Ratio2(skill)
    local value = skill.Level
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Lethargy_Ratio3(skill)
    local value = skill.Level * 3
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_KneelingShot_Ratio(skill)
    local value = 15;
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill);
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_KneelingShot_Ratio2(skill)
    local value = 250
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_KneelingShot_Ratio3(skill)
    local value = skill.Level * 30
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BlockAndShoot_Ratio(skill)
    local value = 50
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ObliqueShot_Ratio(skill)
    local value = 50
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Carve_Ratio(skill)
    local value = skill.Level * 5
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CarveZemina_Ratio2(skill)
    local value = 15 + (skill.Level * 2)
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_OwlStatue_Bufftime(skill)
    local pc = GetSkillOwner(skill);
    local value = 20 + skill.Level * 2;
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_OwlStatue_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 50;
    
    if IsPVPServer(pc) == 1 then
        value = 25;
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_Crown(skill)
    local pc = GetSkillOwner(skill);
    local value = pc.SR
    if IsPVPField(pc) == 1 and value > 4 then
        value = math.floor((math.max(0, value-4)^0.5))+math.min(4, value)
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CrossGuard_Ratio(skill)
    local value = skill.Level * 5
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CrossGuard_Ratio2(skill)
    local value = skill.Level
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CrossGuard_Ratio3(skill)
    local value = 70 + skill.Level * 5
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CorpseTower_Ratio(skill)
    local value = 30 + skill.Level * 5
    return math.floor(value);

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CorpseTower_Ratio2(skill)
    local value = 7
    return math.floor(value);

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CorpseTower_Ratio3(skill)
    local value = TryGetProp(skill, 'SkillFactor', 0)    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RaiseDead_Ratio(skill)
    local value = 55.2 + skill.Level * 9.2;
    return math.floor(value) * SUMMON_ADD_ATK_TRANSFER_RATIO;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RaiseDead_Ratio2(skill)
   local value = 120 + skill.Level * 20;
   return math.floor(value) * SUMMON_ADD_DEF_TRANSFER_RATIO;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RaiseDead_Ratio3(skill)
    local value = 60 + skill.Level * 10;
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RaiseSkullarcher_Ratio(skill)
    local value = 69 + skill.Level * 11.5;
    return math.floor(value) *SUMMON_ADD_ATK_TRANSFER_RATIO;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RaiseSkullarcher_Ratio2(skill)
    local value = 60 + skill.Level * 10;
    return math.floor(value) * SUMMON_ADD_DEF_TRANSFER_RATIO;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RaiseSkullarcher_Ratio3(skill)
    local value = 48 + skill.Level * 8;
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RaiseSkullWizard_Ratio(skill)
   local value = 69 + skill.Level * 11.5;
   return math.floor(value) * SUMMON_ADD_ATK_TRANSFER_RATIO;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RaiseSkullWizard_Ratio2(skill)
   local value = 60 + skill.Level * 10;
   return math.floor(value) * SUMMON_ADD_DEF_TRANSFER_RATIO;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RaiseSkullWizard_Ratio3(skill)
    local value = 30 + skill.Level * 5;
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Trot_Ratio(skill)
    if skill == nil then
        return 0
    end

    if TryGetProp(skill, 'ClassName', 'None') == 'Cataphract_Trot' then
        local value = skill.Level + 5
        return value
    else
        local value = skill.Level + 5
        return value
    end
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_IceBolt_SkillFactor(skill)

    local value = 180 + skill.Level * 13;
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ReflectShield_Bufftime(skill)
	local pc = GetSkillOwner(skill);
    local lv = TryGetProp(pc, "Lv", 1)
    local value = math.floor((200 + ((lv - 1) * 18)) / 20)
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ReflectShield_Ratio(skill)
    local value = (skill.Level * 3)
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ReflectShield_Ratio2(skill)
    local value = 30;
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ReflectShield_Ratio3(skill)
	local pc = GetSkillOwner(skill)
	local value = 0.7
	if IsPVPField(pc)== 1 then
		value = 6
    end

	return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Exchange_Bufftime(skill)
    return 10 + skill.Level;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Exchange_Ratio(skill)
    return 25
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_IceWall_Bonus(skill)
    return 100 + 30 * skill.Level;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_IceWall_Bufftime(skill)
    local lv = 5.5 - 0.5 * skill.Level;
    return math.max(3, lv);

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_IceTremor_SkillFactor(skill)
    local value = 233 + skill.Level * 31;
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_IceTremor(skill)
    local pc = GetSkillOwner(skill);
    return skill.Level * 1
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_Fleche(skill)
    local pc = GetSkillOwner(skill);
    return 3
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SubzeroShield_Ratio(skill)
    -- 결빙 지속 시간
    local pc = GetSkillOwner(skill);
    local value = 3;
    
    local abil = GetAbility(pc, "Cryomancer7")
    if abil ~= nil and 1 == abil.ActiveState and GetSkill(pc, 'Cryomancer_SubzeroShield') ~= nil then
        value = value + abil.Level * 0.5
    end
    
    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = value / 2
    end    
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SubzeroShield_Ratio2(skill)
    -- 적 공격 방어 확률
    local pc = GetSkillOwner(skill);
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)
    local value = base + TryGetProp(skill, "Level", 0) * per

    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = value * 0.5
    end

    local abilCryomancer9 = GetAbility(pc, "Cryomancer9");
    if abilCryomancer9 ~= nil and TryGetProp(abilCryomancer9, "ActiveState") == 1 then
        value = math.floor(value * (1 + abilCryomancer9.Level * 0.05));
    end
    
    return value;

    end
    
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SubzeroShield_Ratio3(skill)
    -- 피해 감소
    local pc = GetSkillOwner(skill);
    local value = 4.3 + skill.Level * 0.4
    return value;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Roasting_Ratio(skill)
    local value = skill.Level * 1

    if value > 10 then
        value = 10
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SubzeroShield_BuffTime(skill)
    -- 서브제로 실드 버프 지속 시간
    local value = 1800
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 then
        value = 30
    end
    return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_IceWall_Time(skill)
    local pc = GetSkillOwner(skill);
    local value = 15
    local abil = GetAbility(pc, 'Cryomancer22')
    if abil ~= nil and abil.ActiveState == 1 then
        value = value + 10
    end
    
    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 or IsRaidField(pc) == 1 then
        value = value / 2
    end    
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_Gust(skill)
    local pc = GetSkillOwner(skill);
    return pc.SR + math.floor(skill.Level / 5);

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Gust_Distance(skill)
    return 200;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Gust_Ratio(skill)
    local value = 5 + skill.Level;
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Gust_Bufftime(skill)
    local value = 4 + skill.Level * 0.1;
    return math.floor(value);

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_IciclePike_SkillFactor(skill)
    local value = 238 + skill.Level * 12;
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Effigy_SkillFactor(skill)
    local value = 209 + skill.Level * 17;
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_StabDoll_Dist(skill)
    return (50 + 10 * skill.Level);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Effigy_Bonus(skill)
    local min = 160 + 7 * (skill.Level-1)
    local max = 230 + 9 * (skill.Level-1)
    return IMCRandom(min, max)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Effigy_Ratio(skill)
    local value = 1.60 + 0.07 * (skill.Level-1);
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Effigy_Ratio2(skill)
    local value = 2.3 + 0.09 * (skill.Level-1)
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_Damballa(skill)
    return skill.Level * skill.SklSR
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_TwistOfFate(skill)
    return 0
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Barrier_Bufftime(skill)
    local value = skill.Level * 4
    local pc = GetSkillOwner(skill)
    if IsPVPServer(pc) == 1 then
        value = value / 2
    end

    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Restoration_Ratio(skill)
    local value = 107 + (skill.Level - 1) * 6.2
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ResistElements_Bufftime(skill)
    local value = 45
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ResistElements_Ratio(skill)
    local value = 10 + skill.Level * 2
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ResistElements_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = skill.Level
    
    local abil = GetAbility(pc, "Paladin1")
    if abil ~= nil and 1 == abil.ActiveState then
        value = value + abil.Level * 0.8
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ResistElements_Ratio3(skill)
    local pc = GetSkillOwner(skill);
    local value = skill.Level * 2.5

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TurnUndead_Ratio(skill)
    return 3 + skill.Level
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_IronSkin_Time(skill)
    return 300;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_IronSkin_Ratio(skill)
    local value = 6 + skill.Level * 2
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Golden_Bell_Shield_Ratio(skill)
    local value = 50 + 5 * (skill.Level-1);
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Golden_Bell_Shield_Time(skill)
    return 3 + skill.Level;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_1InchPunch_Bufftime(skill)
    return 5 + skill.Level * 1;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EnergyBlast_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = pc.MSP * (0.06 - (skill.Level * 0.002))
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_God_Finger_Flicking_Ratio(skill)
    local value = 5 + skill.Level * 2
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_God_Finger_Flicking_Ratio2(skill)
    local value = 100
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DiscernEvil_Ratio(skill)
    local value = 25 + skill.Level * 5
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DiscernEvil_Ratio2(skill)
    local value = skill.Level * 2
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Indulgentia_Ratio(skill)
    local value = 3 + skill.Level
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Oblation_Ratio(skill)
    local value = 100 * skill.Level
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SpellShop_Ratio(skill)
    local value = 9 * skill.Level
    
    local pc = GetSkillOwner(skill);
    
    local abil = GetAbility(pc, "Pardoner4")
    if IsServerSection() ~= 1 and abil == nil then
        abil = GetOtherAbility(pc, "Pardoner4")
    end
    
    if abil ~= nil and 1 == abil.ActiveState then
        value = value + (abil.Level * 3);
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Squire_Food_Salad_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local time = 45

	local abil = GetAbility(pc, "Squire5")
    time = time + (TryGetProp(abil, "Level", 0) * 1.5)
    
    return time
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Squire_Food_Sandwich_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local time = 45

	local abil = GetAbility(pc, "Squire6")
    time = time + (TryGetProp(abil, "Level", 0) * 1.5)
    
    return time
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Squire_Food_Soup_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local time = 45

	local abil = GetAbility(pc, "Squire7")
    time = time + (TryGetProp(abil, "Level", 0) * 1.5)
    
    return time
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Squire_Food_Yogurt_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local time = 45

	local abil = GetAbility(pc, "Squire8")
    time = time + (TryGetProp(abil, "Level", 0) * 1.5)
    
    return time
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Squire_Food_BBQ_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local time = 60
    
    return time
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Squire_Food_champagne_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local time = 60
    
    return time
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_COMMON_MNA_FACTOR(baseValue, skillLevel, levelFactor, mnaFactor)
    local value = baseValue + (skillLevel - 1) * levelFactor;
    value = value * mnaFactor
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SpellShop_Sacrament_Ratio(skill)
    local pc = GetSkillOwner(skill)
	
    local value = SCR_GET_Sacrament_Ratio(skill)
    value = value * 0.3
    
    -- 주문 ?�매?�점 개설 강화 ?�성?�??�러개라??SCR_REINFORCEABILITY_TOOLTIP ?�수???�용 불�?. 직접 ?�용 ----
    local abilAddRate = 1;
    local reinforceAbil = GetAbility(pc, "Pardoner12")
    if IsServerSection() ~= 1 and reinforceAbil == nil then
        reinforceAbil = GetOtherAbility(pc, "Pardoner12")
    end
    if reinforceAbil ~= nil then
        local abilLevel = TryGetProp(reinforceAbil, "Level")
        local masterAddValue = 0
        if abilLevel == 100 then
            masterAddValue = 0.1
        end
        abilAddRate = abilAddRate + (abilLevel * 0.005 + masterAddValue);
    end
    
    value = value * abilAddRate
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SpellShop_Blessing_Ratio(skill)
    local pc = GetSkillOwner(skill)
	
    local value = SCR_GET_Blessing_Ratio(skill)
    value = value * 0.3
    
    -- 주문 ?�매?�점 개설 강화 ?�성?�??�러개라??SCR_REINFORCEABILITY_TOOLTIP ?�수???�용 불�?. 직접 ?�용 ----
    local abilAddRate = 1;
    local reinforceAbil = GetAbility(pc, "Pardoner13")
    if IsServerSection() ~= 1 and reinforceAbil == nil then
        reinforceAbil = GetOtherAbility(pc, "Pardoner13")
    end
    if reinforceAbil ~= nil then
        local abilLevel = TryGetProp(reinforceAbil, "Level")
        local masterAddValue = 0
        if abilLevel == 100 then
            masterAddValue = 0.1
        end
        abilAddRate = abilAddRate + (abilLevel * 0.005 + masterAddValue);
    end
    
    value = value * abilAddRate
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SpellShop_IncreaseMagicDEF_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local pcLevel = TryGetProp(pc, "Lv")
    if IsServerSection() == 0 then
        local buffTarget = GetMyPCObject()
        pcLevel = TryGetProp(buffTarget, "Lv")
    end
    local pcMNA = TryGetProp(pc, "MNA")
    
    local levelRate = 1.5
    local mnaRate = (pcMNA / (pcMNA + pcLevel) * 2) + 0.15
    
    local value = SCR_COMMON_MNA_FACTOR(1.5, 10, levelRate, mnaRate)
    value = value * 0.3
    
    -- 주문 ?�매?�점 개설 강화 ?�성?�??�러개라??SCR_REINFORCEABILITY_TOOLTIP ?�수???�용 불�?. 직접 ?�용 ----
    local abilAddRate = 1;
    local reinforceAbil = GetAbility(pc, "Pardoner14")
    if IsServerSection() ~= 1 and reinforceAbil == nil then
        reinforceAbil = GetOtherAbility(pc, "Pardoner14")
    end
    if reinforceAbil ~= nil then
        local abilLevel = TryGetProp(reinforceAbil, "Level")
        local masterAddValue = 0
        if abilLevel == 100 then
            masterAddValue = 0.1
        end
        abilAddRate = abilAddRate + (abilLevel * 0.005 + masterAddValue);
    end
    
    value = value * abilAddRate
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SpellShop_Aspersion_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local pcLevel = TryGetProp(pc, "Lv")
    if IsServerSection() == 0 then
        local buffTarget = GetMyPCObject()
        pcLevel = TryGetProp(buffTarget, "Lv")
    end
    local pcMNA = TryGetProp(pc, "MNA")
    
    local levelRate = 1
    local mnaRate = (pcMNA / (pcMNA + pcLevel) * 2) + 0.15
    
    local value = SCR_COMMON_MNA_FACTOR(1, 15, levelRate, mnaRate)
    value = value * 0.3
    
    -- 주문 ?�매?�점 개설 강화 ?�성?�??�러개라??SCR_REINFORCEABILITY_TOOLTIP ?�수???�용 불�?. 직접 ?�용 ----
    local abilAddRate = 1;
    local reinforceAbil = GetAbility(pc, "Pardoner15")
    if IsServerSection() ~= 1 and reinforceAbil == nil then
        reinforceAbil = GetOtherAbility(pc, "Pardoner15")
    end
    if reinforceAbil ~= nil then
        local abilLevel = TryGetProp(reinforceAbil, "Level")
        local masterAddValue = 0
        if abilLevel == 100 then
            masterAddValue = 0.1
        end
        abilAddRate = abilAddRate + (abilLevel * 0.005 + masterAddValue);
    end
    
    value = value * abilAddRate
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Telepath_Ratio(skill)
    local value = 10 + skill.Level * 1
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Conversion_Bufftime(skill)
    local value = 10 + skill.Level * 1
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Carnivory_Ratio(skill)
    local value = 1 + ((skill.Level * 1) / 2)
    return math.ceil(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Carnivory_Ratio2(skill)
    local value = (skill.Level * 10)
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Carnivory_Time(skill)
    local value = 15
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_StereaTrofh_Ratio(skill)
    local value = skill.Level * 7
    local pc = GetSkillOwner(skill)

    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Chortasmata_Time(skill)
    local value = 5 + skill.Level * 0.6
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Chortasmata_Bufftime(skill)
    local value = 10 + skill.Level * 0.6
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Chortasmata_Ratio(skill)
    local value = 41 + (7.6 * (skill.Level - 1));
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ArcaneEnergy_Ratio(skill)
    local value = 0.4 * skill.Level;
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ArcaneEnergy_Ratio2(skill)
    local value = 5 + skill.Level * 4
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ArcaneEnergy_Bufftime(skill)
    local value = skill.Level
    local pc = GetSkillOwner(skill)

    local Oracle32_abil = GetAbility(pc, "Oracle32")
    local Oracle7_abil = GetAbility(pc, "Oracle7")
    if Oracle32_abil ~= nil and 1 == Oracle32_abil.ActiveState then
        if value < 5 then
            value = 5
        end
    elseif Oracle7_abil ~= nil and 1 == Oracle7_abil.ActiveState then
        value = value + Oracle7_abil.Level
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CallOfDeities_Ratio(skill)
    local value = 1 + skill.Level * 2;
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Change_Ratio(skill)
    local value = skill.Level;
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Forecast_Ratio(skill)
    local value = 300;
    local pc = GetSkillOwner(skill)
    
    local Oracle3_abil = GetAbility(pc, "Oracle3")
    if Oracle3_abil ~= nil and 1 == Oracle3_abil.ActiveState then
        value = value + Oracle3_abil.Level * 60;
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BeadyEyed_Time(skill)
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)

    local value = base + (skill.Level * per);
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CounterSpell_Bufftime(skill)
    local value = 25
    local pc = GetSkillOwner(skill)

    local abilOracle33 = GetAbility(pc, "Oracle33")
    local abilOracle16 = GetAbility(pc, "Oracle16")
    if abilOracle33 ~= nil and TryGetProp(abilOracle33, 'ActiveState', 0) == 1 then
        value = 10
    elseif abilOracle16 ~= nil and TryGetProp(abilOracle16, 'ActiveState', 0) == 1 then
        value = value + TryGetProp(abilOracle16, 'Level', 0)
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CounterSpell_Ratio(skill)
    local value = 5 + skill.Level * 2
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, 'Oracle33')
    if abil ~= nil and TryGetProp(abil, 'ActiveState', 0) == 1 and GetExProp(pc, 'ITEM_VIBORA_Aura_LV4') > 0 then
        return 35
    end

    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    
    return math.floor(value)
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CounterSpell_Ratio2(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DeathVerdict_Ratio(skill)
    local value =20 + skill.Level * 3
    
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill);
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DeathVerdict_Ratio2(skill)
    local value = 5 + skill.Level
    local pc = GetSkillOwner(skill);
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DeathVerdict_Ratio3(skill)
    local value = 25
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, "Oracle18")
    if abil ~= nil and abil.ActiveState >= 1 then
        value = 11 + abil.Level * 1
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Prophecy_Ratio(skill)
    return skill.Level;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Prophecy_Ratio2(skill)
    local value = 6
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Prophecy_Time(skill)
    local value = 30
    local pc = GetSkillOwner(skill);
    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = 15;
    end
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Prophecy(skill)
    local value = SCR_GET_SKL_COOLDOWN_ADD_LEVEL_BYGEM(skill)
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, 'Oracle34')
    if abil ~= nil and TryGetProp(abil, 'ActiveState', 0) == 1 then
        value = SCR_GET_SKL_COOLDOWN(skill)
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Foretell_Time(skill)
    local value = 5
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Foretell_Ratio(skill)  -- 받는 피해 감소
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)
    local value = base + skill.Level * per
    local pc = GetSkillOwner(skill)
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    if GetExProp(pc, 'ITEM_VIBORA_Aura') > 0 and GetSkill(pc, 'Oracle_Foretell') ~= nil then
        value = value + 5
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TwistOfFate_BuffTime(skill)
    local value = 30
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TwistOfFate_Ratio(skill)
    local value = 25 + (skill.Level * 2)
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TwistOfFate_Ratio2(skill)
    local value = 32 + (skill.Level * 2)
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HengeStone_Time(skill)
    local value = 20
    return math.floor(value)
end


-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ManaShield_Bufftime(skill)
    return 10 + skill.Level;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ManaShield_Ratio(skill)
    return 120
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Sleep_Ratio(skill)
    local value = skill.Level
    local pc = GetSkillOwner(skill);
    local zone = GetZoneName(pc);
    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = 1;
    end
    return value;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Sleep_Ratio2(skill)
    local value = 2 + skill.Level
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_Bash(skill)
    local pc = GetSkillOwner(skill);
    local value = pc.SR + skill.SklSR
    if pc == nil and ui.GetFrame("pub_createchar"):IsVisible() == 1 then
        return pc.SR
    end

    local abil = GetAbility(pc, 'Penetration');
    if abil ~= nil and skill.ClassName == "Swordman_Bash" and 1 == abil.ActiveState then
        value = value + abil.Level;
    end

    if IsPVPField(pc) == 1 and value > 4 then
        value = math.floor((math.max(0, value-4)^0.5))+math.min(4, value)
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Crown_Bufftime(skill)
    return (1 * skill.Level);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SynchroThrusting_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 65
    local abil = GetAbility(pc, "Hoplite40")
    if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        value = 50
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_SynchroThrusting(skill)
    local pc = GetSkillOwner(skill);
    return pc.SR + skill.Level
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Finestra_Bufftime(skill)
    return 45 + (3 * skill.Level);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Warcry_Bufftime(skill)
    local value = 10 + (skill.Level * 2)
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Warcry_Ratio(skill)
    local value = 5.5 + skill.Level * 0.5
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Warcry_Ratio2(skill)
    local value = skill.Level * 3
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_Pull(skill)
    local pc = GetSkillOwner(skill);
    return skill.SklSR;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Gungho_Bufftime(skill)
    return 300;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Gungho_Ratio(skill)
    local value = skill.Level * 2;
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Gungho_Ratio2(skill)
    local pc = GetSkillOwner(skill)
    local value = 5 + (skill.Level - 1) + ((skill.Level / 5) * ((pc.STR * 0.3) ^ 0.5))
    
--    local Swordman20_abil = GetAbility(pc, "Swordman20")    -- 2rank Atk multiple
--    local Swordman21_abil = GetAbility(pc, "Swordman21")    -- 3rank Atk multiple
--    if Swordman21_abil ~= nil then
--        value = value * 1.44
--    elseif Swordman21_abil == nil and Swordman20_abil ~= nil then
--        value = value * 1.38
--    end
    
    local Swordman13_abil = GetAbility(pc, "Swordman13")
    if Swordman13_abil ~= nil and skill.Level >= 3 then
        value = value * (1 + Swordman13_abil.Level * 0.01);
    end
    
    return math.floor(value);
    
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Bear_Bufftime(skill)
    return 300;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Bear_Ratio(skill)
    local value = skill.Level * 2;
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Guardian_Bufftime(skill)
    return 30
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Guardian_Ratio(skill)
    if TryGetProp(skill, 'ClassName', 'None') == 'Peltasta_Guardian' then
        local pc = GetSkillOwner(skill)
        local value = 20 + skill.Level * 2.5
        if IsPVPField(pc) == 1 then	
            value = 10 + skill.Level * 1.25
        end
            value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill))
        return value;
    else
        local pc = GetSkillOwner(skill)
        local value = skill.Level * 10
        if IsPVPField(pc) == 1 then	
            value = skill.Level * 5
        end
            
        return value;
    end
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Guardian_Ratio2(skill)
    if TryGetProp(skill, 'ClassName', 'None') == 'Peltasta_Guardian' then
        local value = 6 + skill.Level * 1
        return math.floor(value);
    else
        local value = 6 + skill.Level * 1
        value = math.min(value, 11)
        return math.floor(value);
    end
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Concentrate_Bufftime(skill)
    return 45;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Concentrate_Ratio(skill)
    return skill.Level * 2;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Concentrate_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local statBonus = 0;
    local byAbilRate = 0;
    
    statBonus = math.floor((pc.STR * 0.1 + pc.DEX * 0.2) * skill.Level)
    
    local Swordman14_abil = GetAbility(pc, "Swordman14")
    if Swordman14_abil ~= nil and skill.Level >= 3 then
        byAbilRate = Swordman14_abil.Level * 0.01;
    end
    
    value = 5 + (skill.Level - 1) * 1.5 + statBonus;
    value = value + (value * byAbilRate);
    
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ShieldPush_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = skill.Level * 5
      return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Restrain_Bufftime(skill)
    local pc = GetSkillOwner(skill)
    local value = 30 + skill.Level * 3;
      return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Restrain_Ratio(skill)

    local pc = GetSkillOwner(skill)
    local value = skill.Level * 6
    
    return math.floor(value);

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Restrain_Ratio2(skill)

    local pc = GetSkillOwner(skill)
--    local value = 164.4 + (skill.Level - 1) * 41.1
    local value = 50 + (skill.Level * 5) + (pc.MHP * 0.01 * skill.Level) 
    
    local Swordman24_abil = GetAbility(pc, "Swordman24")    -- 3rank Skill Damage multiple
    if Swordman24_abil ~= nil then
        value = value * 1.44
    end
    
    local abil = GetAbility(pc, "Swordman15")
    if abil ~= nil then
        value = value + abil.Level * 10
    end

    return math.floor(value);

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Frenzy_Ratio(skill)
    local value = 150 + (skill.Level * 10)

    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Frenzy_Bufftime(skill)
    return math.floor(skill.Level / 2)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Aggressor_Ratio(skill)

    return math.floor(10 + skill.Level * 5)

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Aggressor_Bufftime(skill)
    return 20 + skill.Level * 2
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Frenzy_Buff_Ratio2(skill, pc)  -- 최대 중첩수
    if nil ~= pc then
        local abil = GetAbility(pc, 'Barbarian22');
        if nil ~= abil and 1 == abil.ActiveState and GetSkill(pc, 'Barbarian_Frenzy') ~= nil then
            return skill.Level
        end
    end
    return skill.Level * TryGetProp(skill, 'SklFactorByLevel', 0)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Frenzy_Buff_Ratio3(skill) -- 중첩당 적에게 주는 대미지
    local value = 2
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BackMasking_Ratio(skill, pc)
    return 50 + skill.Level * 10
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Savagery_Bufftime(skill)
    return 40
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Parrying_Bufftime(skill)
    return 50 + 10 * skill.Level
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Parrying_Ratio(skill)
  return  9 + skill.Level
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Zhendu_Bufftime(skill)
    return  300
end

-- 속성 추가 타격 --
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Zhendu_Ratio(skill)
    local value = 0 
    local pc = GetSkillOwner(skill)
    if pc ~= nil then
        local minPATK = TryGetProp(pc, "MINPATK")
        local maxPATK = TryGetProp(pc, "MAXPATK")
        value = math.floor(((minPATK + maxPATK) / 2) * 0.5)
    end
    
    return math.floor(value)
end

-- 대미지 증가 --
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Zhendu_Ratio2(skill)
    local value = 5 + skill.Level * 2
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_JollyRoger_Bufftime(skill)
	local value = 10
	local pc = GetSkillOwner(skill);
	local abil1 = GetAbility(pc, 'Corsair27')
	local abil2 = GetAbility(pc, 'Corsair28')
	
	if (GetSkill(pc, 'Thaumaturge_SwellHands') ~= nil or  GetSkill(pc, 'Common_Thaumaturge_SwellHands') ~= nil) and abil1 ~= nil then
		value = value + 25
		
	end
	if GetSkill(pc, 'Enchanter_OverReinforce') ~= nil and abil2 ~= nil then
		value = value + 25
	end	
	return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_JollyRoger_Ratio(skill)
    local value = 10 + (skill.Level * 1)
    
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill);
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SubweaponCancel_Bufftime(skill)
    local value = 5
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Looting_Bufftime(skill)
    return 9 + skill.Level
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_WeaponTouchUp_Ratio(skill)
    return skill.Level * 0.7
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_WeaponTouchUp_Ratio2(skill)
    local pc = GetSkillOwner(skill)
    local value = math.floor(2500 + skill.Level * 250 + ((pc.DEX + pc.STR) * 0.5))
    local Squire3 = GetAbility(pc, 'Squire3');
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ArmorTouchUp_Ratio(skill)
    return skill.Level * 0.7
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ArmorTouchUp_Ratio2(skill)
    local pc = GetSkillOwner(skill)
    local value = math.floor(500 + skill.Level * 50 + ((pc.DEX + pc.STR) * 0.1))
    local Squire4 = GetAbility(pc, 'Squire4');
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Repair_Ratio(skill)
    return skill.Level;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_UnlockChest_Ratio(skill)
    return skill.Level;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Conscript_Ratio(skill)
    local value = 3 + skill.Level;
    
    if value > 8 then
        value = 8
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Tercio_Ratio(skill)

    local pc = GetSkillOwner(skill)
    return skill.Level * 10

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Phalanx_Ratio(skill)

    local pc = GetSkillOwner(skill)
    return skill.Level * 10

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Wingedformation_Ratio(skill)
    local value = 50 + (3 * skill.Level)
    return value;  
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Wedgeformation_Ratio(skill)
    return 4
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Wedgeformation_Ratio2(skill)
    local value = 50 + skill.Level * 5
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Testudo_Ratio(skill)
    return 50
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Testudo_Ratio2(skill)
    return skill.Level * 30
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DeedsOfValor_Bufftime(skill)
    return 10 + skill.Level * 10
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DeedsOfValor_Ratio(skill)
    local value = 15 + skill.Level

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DeedsOfValor_Ratio2(skill)
    return 5 + (skill.Level - 1) * 1;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DeedsOfValor_Ratio3(skill)
    return 5;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PainBarrier_Bufftime(skill)
    local base = TryGetProp(skill, 'SklFactor', 0) / 1000
    local per = TryGetProp(skill, 'SklFactorByLevel', 0) / 1000
    local value = base + skill.Level * per
    local pc = GetSkillOwner(skill)
    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = value / 2
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Double_pay_earn_Ratio(skill)
    local value = skill.Level * 30
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Camp_Ratio(skill)
    return 1 + skill.Level * 0.5
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Camp_Ratio2(skill)
    return skill.Level * 5
end


function SCR_GET_FOOD_salad_Ratio(skilllevel)
    return 4 + skilllevel * 1.2
end

function SCR_GET_FOOD_sandwich_Ratio(skilllevel)
    return 4 + skilllevel * 1.2
end

function SCR_GET_FOOD_soup_Ratio(skilllevel)
    return skilllevel * 3
end

function SCR_GET_FOOD_yogurt_Ratio(skilllevel)
    return skilllevel * 3
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_TEST(skill)
    local pc = GetSkillOwner(skill);
  return skill.SklSR
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Peltasta_SwashBuckling(self)

  return 1;
  
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SwashBuckling_SkillFactor(skill)

    local value = 19 + skill.Level * 38;
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_SwashBuckling(skill)

    local pc = GetSkillOwner(skill);
    return 6 + skill.Level

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SwashBuckling_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 6 + skill.Level * 3;
    
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SwashBuckling_Ratio2(skill)
    local value = 35
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SwashBuckling_Ratio3(skill)
    return skill.Level * 4
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SwashBuckling_Bufftime(skill)
    local buffTime = 5 + skill.Level * 2
    local pc = GetSkillOwner(skill);

    if IsPVPField(pc) == 1 then
        buffTime = buffTime * 0.5
    end

    if pc ~= nil then
        local abilPeltasta32 = GetAbility(pc, "Peltasta32");
        if abilPeltasta32 ~= nil and TryGetProp(abilPeltasta32, "ActiveState") == 1 then
            buffTime = buffTime + TryGetProp(abilPeltasta32, "Level");
        end
    end
    
    return buffTime;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_CrescentWing_SkillFactor(skill)
    local pc = GetSkillOwner(skill);
    local byItem = GetSumOfEquipItem(pc, 'Slash');
    local value = 185 + skill.Level * 49 + byItem;
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_CrescentWing(skill)

    local pc = GetSkillOwner(skill);
  return pc.SR + skill.SklSR

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Provoke_Ratio(skill)

    return 300

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Provoke_Bufftime(skill)

    return 12 + (skill.Level * 3)

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_EarthTremor_SkillFactor(skill)
    local pc = GetSkillOwner(skill);
    local byItem = GetSumOfEquipItem(pc, 'Strike');
    local value = 202 + skill.Level * 49 + byItem;
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_EarthTremor_SklAtkAdd(skill)
    
    --local value = 9 + skill.Level * 5;
    local value = 0;
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_EarthTremor(skill)

    local pc = GetSkillOwner(skill);
  return pc.SR + skill.SklSR

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Earthtremor_Bufftime(skill)

    return 3

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Earthtremor_Ratio(skill)

    return 5 + skill.Level * 5;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Moulinet_SkillFactor(skill)
    local pc = GetSkillOwner(skill);
    local byItem = GetSumOfEquipItem(pc, 'Slash');
    local value = 77 + skill.Level * 3 + byItem;
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Moulinet_SklAtkAdd(skill)

    return 0;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_Moulinet(skill)

    local pc = GetSkillOwner(skill);
    local value = pc.SR / 2 + math.floor(skill.Level/5);
    
    if value < 1 then
        value = 1;
    end
    
    return value;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Cyclone_SkillFactor(skill)
    local pc = GetSkillOwner(skill);
    local byItem = GetSumOfEquipItem(pc, 'Slash');
    local value = 63 + skill.Level * 23 + byItem;
    return value;
    
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Cyclone_SklAtkAdd(skill)
    
    --local value = 3 + skill.Level * 2;
    local value = 0;
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_WhirlWind(skill)

    local pc = GetSkillOwner(skill);
  return pc.SR + skill.SklSR

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_BroadHead_SkillFactor(skill)

    local value = 92 + skill.Level * 8
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_BroadHead_Ratio(skill)
    local caster = GetSkillOwner(skill);
    local evgDmg = (caster.MINPATK + caster.MAXPATK) / 2;
    local addDmg = 4 + (skill.Level - 1) * 3;
    
    if skill.Level > 5 then
        addDmg = 4 + (skill.Level - 1) * 5 + (skill.Level - 5) * 6.3
    end
    
    local value = math.floor(evgDmg * 0.3 + addDmg);
    return value;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_BroadHead_Bufftime(skill)
    return 10 + skill.Level
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_CrossFire_Ratio(skill)
    return 75 + skill.Level * 5;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Multishot_Ratio(skill)
    local value = 10;
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_BarbedArrow_SkillFactor(skill)
    local value = 140 + skill.Level * 25
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_MultiShot(skill)
    local pc = GetSkillOwner(skill);
    return pc.SR + math.floor(skill.Level / 5) + skill.SklSR;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_BuildRoost_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 100;
    
    local Falconer1_abil = GetAbility(pc, "Falconer1");
    if Falconer1_abil ~= nil and 1 == Falconer1_abil.ActiveState then
        value = value + Falconer1_abil.Level * 20
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_BuildRoost_Ratio2(skill)
    local value = 20
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Hovering_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 10;
    
    local abil = GetAbility(pc, "Falconer3")
    if abil ~= nil and 1 == abil.ActiveState then
        value = value + abil.Level * 3
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Circling_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = skill.Level
    local abil = GetAbility(pc, "Falconer11");
    if abil ~= nil and 1 == abil.ActiveState then
        value = value + 3
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Circling_Ratio2(skill)
    local value = 10 + skill.Level
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_HangingShot_Ratio(skill)
    return 30 + (skill.Level-1) * 5
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Aiming_Bufftime(skill)
    local value = 10 + (skill.Level * 5);
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FirstStrike_Bufftime(skill)
    local value = 20 + (skill.Level - 1) * 10;
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FirstStrike_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local lv = pc.Lv
    local bylvCorrect = lv - 300
    local spendSP = 90
    
    if bylvCorrect < 0 then
        bylvCorrect = bylvCorrect * 2.75 / 1000
    elseif bylvCorrect >= 0 then
        bylvCorrect = bylvCorrect * 1.25 / 1000
    end

    local skillLv = TryGetProp(skill, "Level", 1)
    local spendSP = spendSP * (1 + bylvCorrect) * (1 - ((skillLv - 1) * 0.1))
    
    return math.floor(spendSP)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SHOOTMOVE_CYCLONE(skill)

    local pc = GetSkillOwner(skill);
    local ablLevel = GET_ABIL_LEVEL(pc, "DustDevil");

    if ablLevel > 0 then
        return 0;
    end
    
    return 0;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_AcrobaticMount_Ratio(skill)
    local value = 50 + (skill.Level * 6)
    
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill);
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_AcrobaticMount_Ratio2(skill)
    local value = skill.Level * 5
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RimBlow_Bonus(skill)

    return 25 + skill.Level * 30;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_UmboBlow_Bonus(skill)

    return 25 + skill.Level * 30;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DreadWorm_Bonus(skill)

    return 25 + skill.Level * 50;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Rage_Bufftime(skill)

    return (12000 + 4000 * skill.Level)/1000;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Conviction_AttackRatio(skill)

    return 25 + skill.Level * 25;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Conviction_DefenceRatio(skill)

    return 20 + skill.Level * 15;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Soaring_Bufftime(skill)

    return 20;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EnergyBolt_Bonus(skill)

    return 25 + skill.Level * skill.SklFactor * 50;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EnergyBolt_HitSplRange(skill)
    return 30;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EnergyBolt_Splash(skill)
    local lv = skill.Level;
    local splCnt = math.min(3, lv) + skill.Splash_BM + 1;
    
    return splCnt;  
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Fog_Bufftime(skill)

    return 4 + skill.Level;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Heal_Bufftime(skill)
    
    local cnt = skill.Level;
    if skill.Level > 10 then
        cnt = 10;
    end
    
    return cnt;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Heal_Ratio(skill)        
    local pc = GetSkillOwner(skill);
    local pcINT = TryGetProp(pc, "INT");
    if pcINT == nil then
        pcINT = 1;
    end
    
    local pcMNA = TryGetProp(pc, "MNA");
    if pcMNA == nil then
        pcMNA = 1;
    end
    
    local value = (pcINT + pcMNA) * 2;
    
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Heal_Ratio2(skill)        
    return SCR_GET_Heal_Ratio2_Common(skill)    
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Heal_Ratio3(skill)    
    return SCR_GET_Heal_Ratio3_Common(skill)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Heal_Ratio2_Common(skill)
	local pc = GetSkillOwner(skill)
    local value = 150 + (skill.Level - 1) * 103
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    
    if pc == nil then
        return math.floor(value);
    end

    local jobHistory = '';
    if IsServerObj(pc) == 1 then
        if IS_PC(pc) == true then
            jobHistory = GetJobHistoryString(pc);
        end
    else
        jobHistory = GetMyJobHistoryString();
    end
    
    local jobList = GetJobHistoryList(pc)
    for i = 1, #jobList do
        if jobList[i] == 4002 then
            value = value * 1.05
        end
    end

    -- if jobHistory ~= nil and string.find(jobHistory, "Char4_2") ~= nil then
    --     value = value * 1.05
    -- end
    
    if jobHistory ~= nil and string.find(jobHistory, "Char4_15") ~= nil then
        value = value * 1.1
    end
    
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Heal_Ratio3_Common(skill)    
    local pc = GetSkillOwner(skill)
    local value = 85.9 + (skill.Level - 1) * 32.2
    
    local addAbilRate = 1;
    local reinforceAbilName = "Cleric33"
    local reinforceAbil = GetAbility(pc, reinforceAbilName)    
    if reinforceAbil ~= nil then
        local abilLevel = TryGetProp(reinforceAbil, "Level")        
        local masterAddValue = 0
        if abilLevel == 100 then
            masterAddValue = 0.1
        end
        addAbilRate = 1 + (reinforceAbil.Level * 0.005 + masterAddValue);
        
        local hidden_abil_cls = GetClass("HiddenAbility_Reinforce", "Cleric_Heal_Cleric34");
        if abilLevel >= 65 and hidden_abil_cls ~= nil then
            local hidden_abil_name = "Cleric34"
            local hidden_abil = GetAbility(pc, hidden_abil_name);
            if hidden_abil ~= nil then
                local abil_level = TryGetProp(hidden_abil, "Level");
                local add_factor = TryGetProp(hidden_abil_cls, "FactorByLevel", 0) * 0.01;
                local add_value = 0;
                if abil_level == 10 then
                    add_value = TryGetProp(hidden_abil_cls, "AddFactor", 0) * 0.01
                end
                addAbilRate = addAbilRate * (1 + (abil_level * add_factor) + add_value);
            end
        end        
    end
    value = value * addAbilRate    
    
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Cure_Ratio(skill)
    local value = skill.Level * 10
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    
    return value 
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Bless_Bufftime(skill)
    
    return 45 + 10 * skill.Level;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Bless_Ratio(skill)

    return 12 + 5 * skill.Level;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Bless_Ratio2(skill)
    
    local value = 20 + skill.Level * 0.3;
    return math.floor(value);

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SafetyZone_Bufftime(skill)

    return 5 + skill.Level;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DeprotectedZone_Bufftime(skill)

    local pc = GetSkillOwner(skill)
    local buffTime = skill.Level * 2 + 4;
    
    local Cleric5_abil = GetAbility(pc, "Cleric5");
    if Cleric5_abil ~= nil and 1 == Cleric5_abil.ActiveState then
        buffTime = buffTime + Cleric5_abil.Level;
    end
    
    return math.floor(buffTime);

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DeprotectedZone_Ratio(skill)

    local pc = GetSkillOwner(skill)
    local value = 2.8 + (skill.Level - 1) * 0.7 + pc.MNA;
    
    return math.floor(value);

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DeprotectedZone_Ratio2(skill)
    
    local value = 1 + (skill.Level - 1) * 0.5;

    return math.floor(value);

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Fade_Bufftime(skill)
    local value = 18 + skill.Level * 2
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PatronSaint_Bufftime(skill)
    local value = 60
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PatronSaint_Raito(skill)
    local pc = GetSkillOwner(skill)
    local value = skill.Level * 5
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PatronSaint_Raito2(skill)
    local pc = GetSkillOwner(skill)
    local value = 0
    local abil = GetAbility(pc, 'Cleric29');
    if abil ~= nil and 1 == TryGetProp(abil, "ActiveState", 0) then
        value = 20
    end
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Daino_Bufftime(skill)
    local value = 10 + (skill.Level * 2);
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Mackangdal_Bufftime(skill)
    local value = skill.Level * 5

    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Hexing_Bufftime(skill)

    local value = skill.Level * 1 + 6;
    return value;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SpecialForceFormation_Ratio(skill)

    local value = 35 + skill.Level * 5
    return value;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SpecialForceFormation_Ratio2(skill)

    local value = 55 + skill.Level * 5
    return value;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Zombify_Bufftime(skill)

    local value = 5 + skill.Level * 5
    return value;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Zombify_ratio(skill)
    local value = 10 + (skill.Level * 2)
    
    return value;
end

function SCR_GET_Zombify_ratio2(skill)
    local value = 16 + skill.Level * 5.6
    return value;
end

function SCR_GET_Zombify_ratio3(skill)
    local value = 8 + skill.Level * 2.8
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CrossGuard_Bufftime(skill)
    local value = 15
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Finestra_Ratio(skill)
    local value = 20 + skill.Level * 8
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill);
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Finestra_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 5 * skill.Level + 25
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Finestra_Ratio3(skill)

    local pc = GetSkillOwner(skill);
    
    local value = 25 + (15 * skill.Level); 
    
--    local abil = GetAbility(pc, 'Hoplite9');
--    if abil ~= nil and 1 == abil.ActiveState then
--        value = value * 2;
--    end
    
    return math.floor(value)

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SharpSpear_Bufftime(skill)
    local value = 300
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SharpSpear_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 10 + (skill.Level * 2)
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HighGuard_Ratio(skill)
    local value = 14 + (skill.Level)
    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill));
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HighGuard_Ratio2(skill)
    local value = 29 + (skill.Level)
    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill));

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
-- function SCR_GET_HighGuard_Ratio3(skill)
--     local value = 50 - (skill.Level - 1) * 10

--     if value < 0 then
--         value = 0
--     end

--     return value
-- end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HighGuard_Ratio4(skill)
    local value = 25 - (skill.Level - 1) * 5

    if value < 0 then
        value = 0
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HighGuard_Time(skill)
    local pc = GetSkillOwner(skill);
    local value = 20
    if IsPVPField(pc) == 1 then
        value = value * 0.1
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HighGuard_AtkDown(skill)
    local pc = GetSkillOwner(skill);
    
    local value = skill.Level
    
    return math.floor(value)

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HolyEnchant_Bufftime(skill)

    return 60 + 0.5 * skill.Level;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HolyEnchant_Ratio(skill)

    return 20 + 2 * skill.Level;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Haste_Ratio(skill)

    local value = 5 + skill.Level * 0.2;
    return math.floor(value);

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Cure_Bufftime(skill)
    
    local value = 5 + skill.Level;
    return math.floor(value);

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Aukuras_Bufftime(skill)
    local value = 30;
    
    local pc = GetSkillOwner(skill)
    local Kriwi18_abil = GetAbility(pc, "Kriwi18")
    if Kriwi18_abil ~= nil and Kriwi18_abil.ActiveState == 1 then
        value = 20;
    end
    
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Aukuras_Ratio(skill)    
    local value = 39 + (19 * (skill.Level - 1));
    
    local pc = GetSkillOwner(skill)
    local abilKriwi14 = GetAbility(pc, 'Kriwi14');
    if abilKriwi14 ~= nil and skill.Level >= 3 then
        value = value * (1 + abilKriwi14.Level * 0.01);
    end
    
    local abilKriwi18 = GetAbility(pc, "Kriwi18");
    if abilKriwi18 ~= nil and abilKriwi18.ActiveState == 1 then
        value = 0;
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Aukuras_Ratio2(skill)
    local pc = GetSkillOwner(skill)
    local pcLv = TryGetProp(pc, "Lv", 1)
    local sklLv = TryGetProp(skill, "Level", 1)
    
    local value = (14*pcLv) + (sklLv*pcLv*1.5)
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DivineStigma_Ratio(skill)
    local value = skill.Level
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DivineStigma_Ratio2(skill)
    local value = skill.Level * 5
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DivineStigma_Time(skill)
    local value = 5 + skill.Level;
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Limitation_Bufftime(skill)

    return 180;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Limitation_Ratio(skill)

    local value =  10 + 0.9 * skill.Level;
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Melstis_Ratio(skill)
	local pc = GetSkillOwner(skill);
	local PATKAVER = (pc.MINPATK + pc.MAXPATK)/2
	local MATKAVER = (pc.MINMATK + pc.MAXMATK)/2
	local CHOATK = 0
	if PATKAVER > MATKAVER then
		CHOATK = PATKAVER
	else
		CHOATK = MATKAVER
	end
	local value = math.floor(skill.Level * CHOATK * 0.02)
    return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Melstis_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 45 + skill.Level * 9

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Zalciai_Ratio(skill)
    local value = 15 + TryGetProp(skill, 'Level', 1) * 3
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill);    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Zalciai_Ratio2(skill)
    local value = TryGetProp(skill, 'Level', 1) * 1
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill);    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Zalciai_Ratio3(skill)
    local value = skill.Level    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Zaibas_Ratio(skill)

    return 4 + skill.Level * 1;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Aspersion_Ratio(skill)    
    local value = 0
    if TryGetProp(skill, 'ClassName', 'None') == 'Priest_Aspersion' then
        local pc = GetSkillOwner(skill)
        local pcLevel = TryGetProp(pc, "Lv")
        local pcMNA = TryGetProp(pc, "MNA")
        local mnaRate = (pcMNA / (pcMNA + pcLevel) * 2) + 0.15    
        local skillValue = skill.Level
        value = skillValue * mnaRate
        
        value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    else
        local lv = TryGetProp(skill, 'Level', 0)
        value = lv * 4    
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Resurrection_Ratio(skill)
    local value = 24 + skill.Level * 6
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Resurrection_Ratio2(skill)
    local pc = GetSkillOwner(skill)
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Resurrection_Ratio3(skill)
    local value = SCR_GET_SkillFactor_By_Other(skill, 'Priest_Condemn')
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Resurrection_Time(skill)
    local value = math.max(1, 7 - skill.Level);
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Monstrance_Debufftime(skill)
    local value = 15
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Monstrance_Ratio2(skill)
    local value = 10 + skill.Level

    local pc = GetSkillOwner(skill)
    local addAbilRate = 1
    local reinforceAbilName = TryGetProp(skill, "ReinforceAbility", "None")
    if reinforceAbilName ~= "None" then
        local reinforceAbil = GetAbility(pc, reinforceAbilName)
        if reinforceAbil ~= nil then
            local abilLevel = TryGetProp(reinforceAbil, "Level")
            local masterAddValue = 0
            if abilLevel == 100 then
                masterAddValue = 0.1
            end
            addAbilRate = 1 + (reinforceAbil.Level * 0.001 + masterAddValue)
        end
    end

    value = value * addAbilRate

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Aspersion_Bufftime(skill)

    return 300;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_OutofBody_Ratio(skill)
    local value = 8 + skill.Level * 2

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_OutofBody_Ratio2(skill)
    local value = skill.Level
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_OutofBody_Ratio3(skill)
    local value = skill.Level * 2
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_OutofBodySkill(skill)
    local pc = GetSkillOwner(skill);
    local OutofBodySkill = GetSkill(pc, "Sadhu_OutofBody")
    local value = 0
    if OutofBodySkill ~= nil then
        value = OutofBodySkill.SkillFactor;
    end
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Prakriti_Ratio(skill)
    local value = skill.Level + 5
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TransmitPrana_BuffTime(skill)
    local value = 60
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TransmitPrana_Ratio(skill)
    local value = 20 + (skill.Level * 5)
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TransmitPrana_Ratio2(skill)
    local value = skill.Level * 15
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TransmitPrana_Ratio3(skill)
    local value = 15 + TryGetProp(skill, 'Level', 1) * 3
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_VashitaSiddhi_Time(skill)
    local pc = GetSkillOwner(skill);
    local value = 4
    if IsPVPField(pc) == 1 then
        value = value * 0.75
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_VashitaSiddhi_Ratio(skill)

    return skill.Level * 5;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_VashitaSiddhi_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 35 + skill.Level * 1;
    local abil = GetAbility(pc, "Sadhu7")
    if abil ~= nil and abil.ActiveState == 1 then
        value = value * 1.2
    end
    
    return math.floor(value);

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Physicallink_Bufftime(skill)

    return 60 + skill.Level * 10

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Isa_Bufftime(skill)

    return 10 * skill.Level

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Isa_Ratio(skill)

    return 10 * skill.Level

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Hagalaz_Castingime(skill)
	local value = 2
	local pc = GetSkillOwner(skill);
	if IsBuffApplied(pc, "Runcaster_Casting_Buff") == "YES" then
		local castingBuffOver = GetBuffOver(pc, "Runcaster_Casting_Buff")
		value = 1
		if castingBuffOver == 2 then
			value = 0.5
		end
	end
	
	return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Isa_Castingime(skill)
	local value = 2
	local pc = GetSkillOwner(skill);
	if IsBuffApplied(pc, "Runcaster_Casting_Buff") == "YES" then
		local castingBuffOver = GetBuffOver(pc, "Runcaster_Casting_Buff")
		value = 1
		if castingBuffOver == 2 then
			value = 0.5
		end
	end
	
	return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Tiwaz_Castingime(skill)
	local value = 2
	local pc = GetSkillOwner(skill);
	if IsBuffApplied(pc, "Runcaster_Casting_Buff") == "YES" then
		local castingBuffOver = GetBuffOver(pc, "Runcaster_Casting_Buff")
		value = 1
		if castingBuffOver == 2 then
			value = 0.5
		end
	end
	
	return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Algiz_Castingime(skill)
	local value = 2
	local pc = GetSkillOwner(skill);
	if IsBuffApplied(pc, "Runcaster_Casting_Buff") == "YES" then
		local castingBuffOver = GetBuffOver(pc, "Runcaster_Casting_Buff")
		value = 1
		if castingBuffOver == 2 then
			value = 0.5
		end
	end
	
	return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Stan_Castingime(skill)
	local value = 2
	local pc = GetSkillOwner(skill);
	if IsBuffApplied(pc, "Runcaster_Casting_Buff") == "YES" then
		local castingBuffOver = GetBuffOver(pc, "Runcaster_Casting_Buff")
		value = 1
		if castingBuffOver == 2 then
			value = 0.5
		end
	end
	
	return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Algiz_Bufftime(skill)
    local buffTime = 30 * TryGetProp(skill, "Level");
    local pc = GetSkillOwner(skill);
    local abilRuneCaster6 = GetAbility(pc, "RuneCaster6");
    if abilRuneCaster6 ~= nil and TryGetProp(abilRuneCaster6, "ActiveState") == 1 then
        local abilAddBuffTime = 10 - TryGetProp(abilRuneCaster6, "Level") * 2
        if abilAddBuffTime <= 0 then
            abilAddBuffTime = 0
end

        buffTime = buffTime - abilAddBuffTime;
    end

    return buffTime;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Thurisaz_Bufftime(skill)

    return 30 * skill.Level

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Thurisaz_Ratio(skill)

    return 20
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Thurisaz_Ratio2(skill)

    return 20

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Bewitch_Ratio(skill)

    return 2 + skill.Level 
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Physicallink_Ratio(skill)
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)
    local value = base + skill.Level * per

    return 100 - value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ShieldBash_Ratio2(skill)

    return 5 + skill.Level * 1

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_JointPenalty_Bufftime(skill)
    local pc = GetSkillOwner(skill)
    local value = 10
    local abil_linker19 = GetAbility(pc, 'Linker19')
    if abil_linker19 ~= nil and abil_linker19.ActiveState == 1 then
        value = 15
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_JointPenalty_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = 3 + math.floor(skill.Level/2)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_JointPenalty_Ratio2(skill)
    local value = skill.Level * 10
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 then
        value = value * 0.4
    end
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_HangmansKnot_Bufftime(skill)
    return 1 + skill.Level * 0.2;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_UmbilicalCord_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 0;

    local casterSTR = TryGetProp(pc, "STR", 0);
    local casterCON = TryGetProp(pc, "CON", 0);
    local casterINT = TryGetProp(pc, "INT", 0);
    local casterMNA = TryGetProp(pc, "MNA", 0);
    local casterDEX = TryGetProp(pc, "DEX", 0);
    local casterStat = casterSTR + casterCON + casterINT + casterMNA + casterDEX
        
    local base = TryGetProp(skill, 'SklFactor', 0) / 100
    local per = TryGetProp(skill, 'SklFactorByLevel', 0) / 100
    
    local rate = base + (skill.Level * per)    

    value = math.floor(casterStat / 15)
    value = math.floor(value * rate)
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_UmbilicalCord_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local value = 0;

    if pc ~= nil then
        value = pc.RHP
    end

    return value;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SpiritShock_Ratio(skill)
    local value = 3 + (skill.Level * 0.5)
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_ElectricShock_Ratio(skill)
    local value = 10
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Scud_Ratio(skill)

    return 10 + skill.Level * 10

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Slow_Ratio(skill)
    return math.floor(8 + skill.Level * 1.5);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Slow_Ratio2(skill)
    return 14 + skill.Level * 0.5
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MagnumOpus_Ratio(skill)
    local value = 2 + skill.Level;
    
    if value > 7 then
        value = 7;
    end
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_RunningShot_Bufftime(skill)
    local value = 30
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CoverTraps_Ratio(skill)
    return 2
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SpikeShooter_Ratio(skill)
    return 2 * skill.Level
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SpikeShooter_Ratio2(skill)
    return 5 + skill.Level * 7;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HoverBomb_Ratio(skill)
    return skill.Level
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SneakHit_Ratio(skill)
    return 25 + skill.Level * 5;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SneakHit_Bufftime(skill)

    local pc = GetSkillOwner(skill)
    local value = 35 + skill.Level * 7;
    
    local Rogue1_abil = GetAbility(pc, 'Rogue1');
    if Rogue1_abil ~= nil and 1 == Rogue1_abil.ActiveState then
        value = value + 2 * Rogue1_abil.Level
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Feint_Ratio(skill)
    return 50 + skill.Level * 2.5;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Feint_Ratio2(skill)
    return 30 + skill.Level * 3
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Feint_Ratio3(skill)
    return 50 + skill.Level * 5
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Feint_Bufftime(skill)
    return 2.5 + skill.Level * 0.2
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Spoliation_Ratio(skill)
    return skill.Level
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Evasion_Ratio(skill)
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)

    local value = base + skill.Level * per
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Evasion_Ratio2(skill)
    local value = 2 * skill.Level
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Evasion_Bufftime(skill)
    return 15 + skill.Level * 1;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Vendetta_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local value = 5 * skill.Level

    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ZombieCapsule_Ratio(skill)
    local value = skill.Level

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Vendetta_Bufftime(skill)
    return 10 + skill.Level * 2
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Lachrymator_Bufftime(skill)
    return 3.5 + skill.Level * 0.5
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Backstab_Ratio(skill)
    return 50 + skill.Level * 2
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Slow_Bufftime(skill)

    return 14 + skill.Level * 0.5;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Fog_IceRatio(skill)

    return 13 + skill.Level * 2;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SplitArrow_Ratio2(skill)

    return skill.SkillFactor * 2;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FireBall_Bonus(skill)

    return 30 + skill.Level * 35;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FireBall_HitSplRange(skill)

    return 50;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MitigatePenalty_Ratio(skill)

    return 2 * skill.Level

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MitigatePenalty_Ratio2(skill)

    return 0.4 * skill.Level

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MitigatePenalty_BuffTime(skill)

    return 15 * skill.Level

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FirePillar_Bufftime(skill)

    local value = 7 + skill.Level;
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Kako_Count(skill)

    return 2;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Kako_Ratio(skill)

    return 8 + 2 * skill.Level;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_FrostCloud_Bufftime(skill)

    return 10

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_FlameGround_Bufftime(skill)

    return 15 + skill.Level * 1

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Holy_Baptism_Ratio(skill)

    local value = 10 + skill.Level * 0.4;
    return math.floor(value);

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Raise_Ratio(skill)
    local value = skill.Level;
    local pc = GetSkillOwner(skill);

    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Raise_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 5 + skill.Level * 1;
    local zone = GetZoneName(pc);
    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = value * 0.5;
    end
    
    return value;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Holy_Baptism_Bufftime(skill)

    return 30;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_REFRIGER_SPLASH(skill)

    local splCnt = 10;
    
    return splCnt;  

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_GUST_SPLASH(skill)

    local splCnt = math.ceil(skill.Level / 2);

    
    return splCnt;  

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SPLASH_ICESHATTERING(skill)

    local splCnt = 10;
    
    return splCnt;  

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ICEBOLT_HITSPLRANGE(skill)

    return 20;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_IceBolt_Bonus(skill)

    return 40 + skill.Level * 40;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_IcePillar_Bonus(skill)

    local value = 10 + 0.9 * skill.Level;
    return 1;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Swap_Ratio(skill)

    local value = skill.Level
    return value;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Teleportation_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = 100 + skill.Level * 20;
    
    if IsBuffApplied(pc, "Thurisaz_Buff") == "YES" then
        value = value * 1.5
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Common_Teleportation_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)
    local value = base + skill.Level * per;
    
    if IsBuffApplied(pc, "Thurisaz_Buff") == "YES" and skill.ClassName ~= "Common_Wizard_Teleportation" then
        value = value * 1.5
    end
    
    return value
end


-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_IcePillar_Bufftime(skill)

    local value = 10
    return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SwellLeftArm_Ratio(skill)

    local pc = GetSkillOwner(skill);
--  local value = 34.4 + (skill.Level - 1) * 12.4 + pc.INT * 0.15;
    local value = 70 + (skill.Level - 1) * 12 + (skill.Level/5) * ((pc.INT + pc.MNA)*0.6)^0.9

    local Thaumaturge11_abil = GetAbility(pc, "Thaumaturge11")  -- 1rank Skill Damage add
    if Thaumaturge11_abil ~= nil and skill.Level >= 3 then
        value = value * (1 + Thaumaturge11_abil.Level * 0.01)    -- Temporary Value
    end

    return math.floor(value)

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SwellRightArm_Ratio(skill)

    local pc = GetSkillOwner(skill);
    local value = 90 + (skill.Level - 1) * 20 + (skill.Level / 5) * ((pc.INT + pc.MNA) * 0.7) ^ 0.9 
    
    local Thaumaturge14_abil = GetAbility(pc, "Thaumaturge14")
    if Thaumaturge14_abil ~= nil and 1 == Thaumaturge14_abil.ActiveState and skill.Level >= 3 then
        value = value * (1 + (Thaumaturge14_abil.Level * 0.01))
    end
    
    return math.floor(value)

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SwellRightArm_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 45 + (skill.Level - 1)*10 + (skill.Level/5) * ((pc.INT + pc.MNA)*0.6)^0.9
    
    local Thaumaturge14_abil = GetAbility(pc, "Thaumaturge14")
    if Thaumaturge14_abil ~= nil then
        value = value * (1 + Thaumaturge14_abil.Level * 0.01)
    end

    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SwellBrain_Ratio(skill)
    local value = skill.Level * 100
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SwellBrain_Ratio2(skill)

    local pc = GetSkillOwner(skill);
    local value = 60 + (skill.Level - 1) * 10 + (skill.Level/3) * (pc.MNA * 0.7)^0.9
    local abil = GetAbility(pc, 'Thaumaturge15')
    if abil ~= nil and skill.Level >= 3 then
        value = value * (1 + abil.Level * 0.01);
    end
    return math.floor(value)

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SpiritualChain_Bufftime(skill)

    local pc = GetSkillOwner(skill);
    local value = 30 + skill.Level * 5
    
    local abil = GetAbility(pc, 'Linker4')
    if abil ~= nil and 1 == abil.ActiveState then
        value = value + abil.Level
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_UmbilicalCord_Bufftime(skill)

    local value = 11 * skill.Level
    
    return value
    
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SwellLeftArm_Bufftime(skill)

    local value = 300
    return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SwellRightArm_Bufftime(skill)

    local value = 300
    return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SwellBrain_Bufftime(skill)

    local value = 300
    return value

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Transpose_Bufftime(skill)

    local value = 50 + skill.Level * 10

    return value;

end

--function SCR_Get_Meteor_Casttime(skill)
--    local pc = GetSkillOwner(skill);
--    local value = (skill.Level * 1) * 0.5
--    local abil = GetAbility(pc, "Elementalist25")
--    if abil ~= nil and abil.ActiveState == 1 then
--        value = value * 0.5
--    end

--    return value;
--end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Summoning_Ratio(skill)
    local value = 16 + (skill.Level * 5.6);
    
    return value * SUMMON_ADD_DEF_TRANSFER_RATIO;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Summoning_Ratio2(skill)
    local value = 24 + (skill.Level * 8.4);
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Summoning_Ratio3(skill)
    local value = 18.4 + (skill.Level * 6.44);
    
    return value * SUMMON_ADD_ATK_TRANSFER_RATIO;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Electrocute_Ratio(skill)
    local value = 1 + (2 + skill.Level * 0.5)
    local pc = GetSkillOwner(skill);
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_IceTremor_Bonus(skill)

    return set_LI(skill.Level, 10, 90)

end

  -- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TEST3_Bonus(skill)

  local lv = skill.Level;
  
  if lv >= 1 then
    return skill.BonusDam + 100;
    end
    return skill.BonusDam;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_KDOWNPOWER(skill) 
    local pc = GetSkillOwner(skill);
    
    return skill.KDownValue;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_KDOWNPOWER_Thrust(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "DeepStraight")

    if abil == nil then
        return skill.KDownValue;
    else
        return skill.KDownValue + (abil.Level * 50);
    end

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_KDOWNPOWER_WagonWheel(skill) 

    return skill.KDownValue + skill.Level * 25;

end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_KDOWNPOWER_CartarStroke(skill) 
--    
--    local pc = GetSkillOwner(skill);
--    
--    local abil = GetAbility(pc, "Highlander28")
--    if abil ~= nil and 1 == abil.ActiveState then
--        return 0;
--    end
--    
--    local abil = GetAbility(pc, "Highlander3")
--    if abil ~= nil and 1 == abil.ActiveState then
--        return skill.KDownValue + (abil.Level * 50);
--    else
--        return skill.KDownValue;
--    end
--    
end

--function SCR_GET_KDOWNPOWER_UmboBlow(skill)
--
--    local pc = GetSkillOwner(skill);
--    local abil = GetAbility(pc, "Peltasta8")
--
--    if abil == nil then
--        return skill.KDownValue;
--    else
--        return skill.KDownValue + (abil.Level * 20);
--    end
--
--end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_KDOWNPOWER_RimBlow(skill)
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Peltasta35")
    if abil ~= nil and abil.ActiveState == 1 then
        return 0
    end
    
    return skill.KDownValue;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_KDOWNPOWER_Fulldraw(skill)

    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Overwhelming")

    if abil ~= nil and 1 == abil.ActiveState then
        return skill.KDownValue + (abil.Level * 50);
    else
        return skill.KDownValue;
    end

end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_NORMAL_PUNISH(self, from, skill, splash, ret)  
    if OnKnockDown(self) == "YES" then
        SCR_NORMAL_ATTACK(self, from, skill, splash, ret);
    else
        NO_HIT_RESULT(ret);
    end
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_NORMAL_SYNCHROTHRUSTING(self, from, skill, splash, ret)

    -- Spear ATK ---
    local rhDamage = SCR_LIB_ATKCALC_RH(from, skill)
    
    local rightHandAttribute = "Melee"
    local rhEquipWeapon = GetEquipItem(from, 'RH');
    if rhEquipWeapon ~= nil and IS_NO_EQUIPITEM(rhEquipWeapon) == 0 then
        rightHandAttribute = rhEquipWeapon.Attribute;
    end
    
    local ariesDamage = rhDamage;
    -------------------------------------------
    
    -- Shield ATK ---
    local leftHandAttribute = "Melee"
    local lhEquipWeapon = GetEquipItem(from, 'LH');
    if lhEquipWeapon ~= nil and IS_NO_EQUIPITEM(lhEquipWeapon) == 0 then
        leftHandAttribute = lhEquipWeapon.Attribute;
    end
     
    local byItem = 0;
    local byItemList = { "DEF", "ADD_DEF" };
    for i = 1, #byItemList do
        local byItemTemp = GetSumOfEquipItem(from, byItemList[i]);
        if byItemTemp == nil then
            byItemTemp = 0;
        end
        
        byItem = byItem + byItemTemp;
    end
    
    local exceptDEF = byItem + from.DEF_BM;
    local basicDEF = TryGetProp(from, "DEF", 0) - exceptDEF
    local shieldDEF = TryGetProp(lhEquipWeapon, "DEF", 0)
    
    local atkRate = 0.65;
    local abilHoplite40 = GetAbility(from, "Hoplite40")
    if abilHoplite40 ~= nil and TryGetProp(abilHoplite40, "ActiveState", 0) == 1 then
        atkRate = 0.5
    end

    local strikeDamage = (shieldDEF + basicDEF) * atkRate
    -------------------------------------------
    
    local abil = GetAbility(from, 'Hoplite7');
    if abil ~= nil then
        strikeDamage = strikeDamage * (1 - abil.Level * 0.1);
        ariesDamage = ariesDamage * (1 + abil.Level * 0.1);
    end
    
    local key = GetSkillSyncKey(from, ret);
    StartSyncPacket(from, key);
    RunScript('SCR_SYNCHROTHRUSTING_TAKEDAMAGE', self, from, skill, ariesDamage, strikeDamage, rightHandAttribute, leftHandAttribute)
    EndSyncPacket(from, key, 0);

    NO_HIT_RESULT(ret);
end

function SCR_SYNCHROTHRUSTING_TAKEDAMAGE(self, from, skill, ariesDamage, strikeDamage, rightHandAttribute, leftHandAttribute)
    local cnt = 1
    local abil = GetAbility(from, "Hoplite40")
    if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        cnt = 2
    end

    for i = 1, cnt do
        TakeDamage(from, self, skill.ClassName, ariesDamage, rightHandAttribute, "Aries", "Melee", HIT_BASIC, 0);
        sleep(200)
        TakeDamage(from, self, skill.ClassName, strikeDamage, leftHandAttribute, "Strike", "Melee", HIT_BASIC, 0);
    end
end

-- 사용처 없음
function SCR_SKILL_FoldingFan(self, from, skill, splash, ret)
    NO_HIT_RESULT(ret);

    local angle = GetSkillDirByAngle(from);
        AddBuff(from, self, 'FoldingFan_Buff', 1, 0, 1300, 1);
        KnockBack(self, from, 200, angle, 30, 0.9);

    
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_SKILL_BubbleStick(self, from, skill, splash, ret)
    NO_HIT_RESULT(ret);
end


-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_NOHIT_ATTACK(self, from, skill, splash, ret)
    NO_HIT_RESULT(ret);
    SCR_SKILL_SPECIAL_CALC(self, from, ret, skill);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_TurnUndead(skill)
    local pc = GetSkillOwner(skill)
    local value = 8 + skill.Level
    
    if IsBuffApplied(pc, "Engkrateia_Buff") == "YES" then
        value = math.floor(value * 1.5)
    end

    if IsPVPField(pc) == 1 and value > 4 then
        value = math.floor((math.max(0, value-4)^0.5))+math.min(4, value)
    end

    if value < 1 then
        value = 1
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_GatherCorpse(skill)

    local pc = GetSkillOwner(skill);
    local value = pc.SR + skill.SklSR;

    local abil = GetAbility(pc, "Necromancer34")
    if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        value = value * 2
    end

    if IsPVPField(pc) == 1 and value > 4 then
        value = math.floor((math.max(0, value-4)^0.5))+math.min(4, value)
    end

    if value < 1 then
        value = 1
    end
    
    return value

end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV(skill)

    local pc = GetSkillOwner(skill);
    if pc == nil and ui.GetFrame("pub_createchar"):IsVisible() == 1 then
        return skill.SklSR;
    end

    local value = pc.SR + skill.SklSR;

    if IsPVPField(pc) == 1 and value > 4 then
        value = math.floor((math.max(0, value-4)^0.5))+math.min(4, value)
    end
    
    if value < 1 then
        value = 1
    end

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_PalmStrike(skill)

    local pc = GetSkillOwner(skill);
    if pc == nil and ui.GetFrame("pub_createchar"):IsVisible() == 1 then
        return skill.SklSR;
    end

    local value = pc.SR + skill.SklSR;
    local abil = GetAbility(pc, "Monk34")
    if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        value = value + 10
    end

    if IsPVPField(pc) == 1 and value > 4 then
        value = math.floor((math.max(0, value-4)^0.5))+math.min(4, value)
    end
    
    if value < 1 then
        value = 1
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_Dragoon28(skill)
    local pc = GetSkillOwner(skill);
    if pc == nil and ui.GetFrame("pub_createchar"):IsVisible() == 1 then
        return skill.SklSR;
    end

    local value = pc.SR + skill.SklSR;

    local abilDragoon28 = GetAbility(pc, "Dragoon28")
    if abilDragoon28 ~= nil and TryGetProp(abilDragoon28, "ActiveState", 0) == 1 then
        value = value + 20
    end

    if IsPVPField(pc) == 1 and value > 4 then
        value = math.floor((math.max(0, value-4)^0.5))+math.min(4, value)
    end
    
    if value < 1 then
        value = 1
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
-- function SCR_GET_SR_LV_SeptEtoiles(skill)
--     local pc = GetSkillOwner(skill);
--     if pc == nil and ui.GetFrame("pub_createchar"):IsVisible() == 1 then
--         return skill.SklSR;
--     end

--     local value = pc.SR + skill.SklSR;
    
--     if value < 1 then
--         value = 1
--     end

--     local abil = GetAbility(pc, "Fencer20")
--     if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
--         value = value + 20
--     end
    
--     return value
-- end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_OUTLAW2(skill)
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Outlaw2")
    if abil ~= nil and abil.ActiveState == 1 then
        skill.SklSR = 17
    end
    
    local value = pc.SR + skill.SklSR;
    
    if IsPVPField(pc) == 1 and value > 4 then
        value = math.floor((math.max(0, value-4)^0.5))+math.min(4, value)
    end

    if value < 1 then
        value = 1
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_RestInPeace(skill)

    local pc = GetSkillOwner(skill);
    local value = pc.SR + skill.SklSR;
    
    local abil = GetAbility(pc, "Bulletmarker13")
    if abil ~= nil and abil.ActiveState == 1 then
        value = value + 5
    end

    if IsPVPField(pc) == 1 and value > 4 then
        value = math.floor((math.max(0, value-4)^0.5))+math.min(4, value)
    end

    if value < 1 then
        value = 1
    end

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_Bazooka_Buff(skill)

    local pc = GetSkillOwner(skill);
    local skillSR = skill.SklSR;
    if IsBuffApplied(pc, 'Bazooka_Buff') == 'YES' then
        local bazooka = GetSkill(pc, 'Cannoneer_Bazooka')
        skillSR = skillSR + SCR_GET_Bazooka_Ratio2(bazooka)
    end

    local Cannoneer32 = GetAbility(pc, "Cannoneer32");
    if TryGetProp(skill, "ClassName", "None") == 'Cannoneer_CannonShot' and  Cannoneer32 ~= nil and TryGetProp(Cannoneer32, "ActiveState") == 1 then
        skillSR = skillSR + 5
    end
    
    local value = pc.SR + skillSR;

    if IsPVPField(pc) == 1 and value > 4 then
        value = math.floor((math.max(0, value-4)^0.5))+math.min(4, value)
    end
    
    if value < 1 then
        value = 1
    end
    
    return value
    
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_MagicMissile(skill)

    return 1;
    
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_Doppelsoeldner(skill)

    local pc = GetSkillOwner(skill);
    local skillSR = skill.SklSR;
    
    local abil =  GetAbility(pc, 'Doppelsoeldner24')
    if abil ~= nil and abil.ActiveState == 1 then
        skillSR = skillSR + abil.Level;
    end
    
    local value = pc.SR + skillSR;

    if IsPVPField(pc) == 1 and value > 4 then
        value = math.floor((math.max(0, value-4)^0.5))+math.min(4, value)
    end
   
    if value < 1 then
        value = 1
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillASPD(skill)

    local pc = GetSkillOwner(skill);
    local stc = GetStance(pc);
    if stc == nil then
        return 1.0;
    end

    return stc.SkillASPD;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_USEOVERHEAT(skill) 
    local pc = GetSkillOwner(skill);
    --local reduce_OH_value = SCR_GET_ADDOVERHEAT(pc, skill);
    --skill.    
    local skillScale = 0.4; -- ????-- skill.xml????????
--  local byStat = math.pow(math.log(pc.MNA + 2.718282), skillScale);

    --local value = skill.SklUseOverHeat;
    local value = skill.BasicCoolDown;
    value = value * ((100 + pc.OverHeat_BM) / 100);
    if value < 0 then
        value = 0;
    end
    
--  value = value / byStat;
    
    return math.floor(value);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Tackle_Bonus(skill)
  
    return skill.BonusDam + 84;
    
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_SKILL_MAXR(skill)
    local pc = GetSkillOwner(skill);
    local addMaxR = 0;
    local abilFletcher26 = GetAbility(pc, "Fletcher26");
    if TryGetProp(skill, "Job") == "Fletcher" then
        if abilFletcher26 ~= nil and TryGetProp(abilFletcher26, "ActiveState") == 1 then
            local abilLv = TryGetProp(abilFletcher26, "Level");
            addMaxR = abilLv * 10
        end
    end

    local abilRanger46 = GetAbility(pc, "Ranger46");
    if TryGetProp(skill, "Job") == "Ranger" then
        if abilRanger46 ~= nil and TryGetProp(abilRanger46, "ActiveState") == 1 then
            local abilLv = TryGetProp(abilRanger46, "Level");
            addMaxR = abilLv * 10
        end
    end

    return skill.MaxRValue + pc.MaxR_BM + addMaxR;
    
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_NORMALSKILL_MAXR(skill)
    
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, "Mergen1")
    
    local abilBonus = 0
    if abil ~= nil and 1 == abil.ActiveState then
        abilBonus = abilBonus + abil.Level;
    end
    
    return skill.MaxRValue + pc.MaxR_BM + abilBonus;
    
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_SKILL_ITEM_MAXR(skill)

    
    local pc = GetSkillOwner(skill);

    local maxr = skill.MaxRValue + pc.MaxR_BM;

    local rItem  = GetEquipItem(pc, 'RH');
    if rItem ~= nil then
        maxr = maxr + rItem.AddSkillMaxR;
    end
    
    return maxr;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKILLLV_WITH_BM(skill)
    local fixedLevel = GetExProp(skill, "FixedLevel");
    if fixedLevel > 0 then
        return fixedLevel;
    end
    
    local value = skill.LevelByDB

    if CHECK_SKILL_KEYWORD(skill, "ExpertSkill") ~= 1 or CHECK_SKILL_KEYWORD(skill, "LimitInstanceLevelUp") ~= 1 then
        value = value + skill.Level_BM;
    end
    
    if TryGetProp(skill, "GemLevel_BM", 0) > 0 then
        value = value + TryGetProp(skill, "GemLevel_BM", 0);
    end
    
    if skill.LevelByDB == 0 then
        return 0;
    end

    if TryGetProp(skill, "ClassName", "None") == "Peltasta_Guardian" and value > 7 then
        value = 7;
    end

    if value < 1 then
        value = 1;
    end

    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_WagonWheel(skill)
    local pc = GetSkillOwner(skill);
    
    local byAbil = 0;
    local abil = GetAbility(pc, 'Highlander6');
    if abil ~= nil and 1 == abil.ActiveState then
        byAbil = abil.Level * 1;
    end

    local value = pc.SR + skill.SklSR + byAbil

    if IsPVPField(pc) == 1 and value > 4 then
        value = math.floor((math.max(0, value-4)^0.5))+math.min(4, value)
    end

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SPENDITEM_COUNT(skill)
    local count = skill.SpendItemBaseCount
    local pc = GetSkillOwner(skill);
    local addCount = GetAbilityAddSpendValue(pc, skill.ClassName, "SpendItem");

    return count + addCount;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SPENDITEM_COUNT_PALADIN40(skill)
    local count = skill.SpendItemBaseCount
    local pc = GetSkillOwner(skill);
    local addCount = GetAbilityAddSpendValue(pc, skill.ClassName, "SpendItem");
    local abil = GetAbility(pc, "Paladin40")
    if abil ~= nil and abil.ActiveState == 1 then
        addCount = 1;
    end
    
    return count + addCount;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SPENDITEM_COUNT_BackMasking(skill)
    local count = skill.SpendItemBaseCount
    local pc = GetSkillOwner(skill);
    if GetExProp(pc, "BACKMASKING_HIDDEN_ABIL_STATE") == 1 then
        count = 0;
    end

    return count;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SPENDITEM_COUNT_Samsara(skill)
    local count = skill.SpendItemBaseCount
    local pc = GetSkillOwner(skill);
    local addCount = GetAbilityAddSpendValue(pc, skill.ClassName, "SpendItem");

    return count + addCount;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SPENDITEM_COUNT_BroomTrap(skill)
    local count = skill.SpendItemBaseCount;
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, 'Sapper34')
    if abil ~= nil and 1 == abil.ActiveState then
        count = count + 1;
    end
    return count;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SPENDITEM_COUNT_PunjiStake(skill)
    local count = skill.SpendItemBaseCount;
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, 'Sapper32')
    if abil ~= nil and 1 == abil.ActiveState then
        count = count - 1;
    end
    return count;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SPENDITEM_COUNT_SpikeShooter(skill)
    local count = skill.SpendItemBaseCount;
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, 'Sapper35')
    if abil ~= nil and 1 == abil.ActiveState then
        count = count * 2;
    end
    return count;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SPENDITEM_COUNT_Claymore(skill)
    local count = skill.SpendItemBaseCount;
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, 'Sapper33')
    if abil ~= nil and 1 == abil.ActiveState then
        count = count * 2;
    end
    return count;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SPENDITEM_COUNT_GreenwoodShikigami(skill)
    local count = skill.SpendItemBaseCount;
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, 'Onmyoji16')
    if abil ~= nil and abil.ActiveState == 1 then
        count = count * 2;
    end
    
    return count;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Dekatos_Ratio(skill)
    return 300
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Overestimate_Ratio(skill)
    local pc = GetSkillOwner(skill);
    return skill.Level + 2
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Overestimate_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local abil = GetAbility(pc, 'Appraiser1')
    local time = 40
    if abil ~= nil and abil.ActiveState == 1 then
        time = time + (abil.Level * 1)
    end
    return time;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Devaluation_Ratio(skill)
    local value = skill.Level;
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Devaluation_Ratio2(skill)
    local value = skill.Level * 1.8
    
    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill))
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Devaluation_Ratio3(skill)
    local value = skill.Level * 1.8

    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill))
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Blindside_Ratio(skill)
    local pc = GetSkillOwner(skill);
    return 10 + (skill.Level * 2);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Forgery_Ratio2(skill)
    local value = 300 + (skill.Level * 100);
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Apprise_Ratio(skill)
    local pc = GetSkillOwner(skill);
    return 20 + (skill.Level * 2);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Apprise_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    return 20 + (skill.Level * 2);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Devaluation_BuffTime(skill)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)
    local value = skill.Level * per
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Blindside_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 6 + ((skill.Level - 1) * 0.5)
    local abilRateAdd = 1
    local abil = GetAbility(pc, "Appraiser3")
    if abil ~= nil then
        abilRateAdd = abilRateAdd + (0.005 * abil.Level);
        if abil.Level == 100 then
            abilRateAdd = abilRateAdd + 0.1
        end
    end
    value = value * abilRateAdd

    local arts = GetAbility(pc, "Appraiser7")
    if arts ~= nil and TryGetProp(arts, 'ActiveState', 0) == 1 then
        value = value / 2
    end

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SPENDITEM_COUNT_Aspersion(skill)

    local count = skill.SpendItemBaseCount;
    local pc = GetSkillOwner(skill);
    if GetAbility(pc, 'Priest1') ~= nil then
        count = count + 1;
    end

     return count;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SPENDITEM_COUNT_Blessing(skill)

    local count = skill.SpendItemBaseCount;
    local pc = GetSkillOwner(skill);

    return count;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Hexing_Ratio(skill)
    local pc = GetSkillOwner(skill);
--    local value = 12.9 + (skill.Level - 1) * 3.2 + pc.MNA * 0.3
    local value = 0.5 + (skill.Level * 0.5)
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_IronHook_Ratio(skill)
    
    local pc = GetSkillOwner(skill);
    local value = 4 + skill.Level * 1;
    local zone = GetZoneName(pc);
    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = value * 0.5;
    end
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Ogouveve_Ratio(skill)
    
    local pc = GetSkillOwner(skill);
--    local value = 2 + 1.2 * (skill.Level - 1) + pc.INT * 0.5
    local value = skill.Level * 5
    
    return math.floor(value);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Ogouveve_BuffTime(skill)
    
    local pc = GetSkillOwner(skill);
    local value = 60 + skill.Level * 10
    
    return math.floor(value);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Ogouveve_Ratio2(skill)
    
    local value = 1 + skill.Level * 0.5
    
    return math.floor(value);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Ogouveve_Ratio3(skill)
    local skillLevel = TryGetProp(skill, 'Level');
    if skillLevel == nil then
        skillLevel = 0;
    end
    
    local value = skillLevel * 10;
    
    return math.floor(value);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Samdiveve_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = (pc.MHP - pc.MHP_BM) * (0.05 * skill.Level)
    return math.floor(value)

end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Samdiveve_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 3 + skill.Level * 1
    local zone = GetZoneName(pc)
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Samdiveve_BuffTime(skill)

    local value = 40 + skill.Level * 10
    return value
     
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CarveAustrasKoks_Ratio(skill)
    local value = 15 + skill.Level * 2
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, 'Dievdirbys31')
    if abil ~= nil and TryGetProp(abil, 'ActiveState', 0) == 1 then
        value = 20
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CarveAustrasKoks_Ratio2(skill)
    local value = skill.Level * 4
    
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill);
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CarveAustrasKoks_Ratio3(skill)
    local value = 5
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CarveVakarine_Ratio(skill)
    return skill.Level
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CarveZemina_Ratio(skill)
    local value = 1.5 * skill.Level
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CarveLaima_Ratio(skill)
    local value = 5 + skill.Level * 0.5
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CarveLaima_Ratio2(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CarveLaima_Ratio3(skill)
    local pc = GetSkillOwner(skill)
    local value = 10
    if IsPVPServer(pc) == 1 then
        value = math.floor(value * 0.5);
    end
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CarveLaima_Time(skill)
    local value = 60
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, 'Dievdirbys32')
    if abil ~= nil and TryGetProp(abil, 'ActiveState', 0) == 1 then
        value = 3
    end

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CarveAusirine_Ratio(skill)
    local value = skill.Level * 3
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DELAY_TIME(skill)
    local actor = GetSkillOwner(skill);
    if actor ~= nil then
        if actor.ClassName ~= "PC" and actor.Faction == "Monster" then
            if skill.ClassType == 'Missile' or skill.UseType == 'FORCE' or skill.UseType == 'FORCE_GROUND' then
                if actor.Lv < 75 then
                    return 3000;
                elseif actor.Lv < 170 then
                    return 2500;
                elseif actor.Lv < 220 then
                    return 2000;
                else
                    return 1500;
                end
            else
                if actor.Lv < 40 then
                    return 3000;
                elseif actor.Lv < 75 then
                    return 2500;
                elseif actor.Lv < 120 then
                    return 2000;
                elseif actor.Lv < 170 then
                    return 1500;
                elseif actor.Lv < 220 then
                    return 1000;
                else
                    return 500;
                end
            end
        end
    end
    return skill.DelayTime;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_USE_DELAY_TIME(skill)
    return skill.DelayTime;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Dig_Ratio(skill)
    local value = skill.Level;
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Zombify(skill)
    local mon = GetSkillOwner(skill)
    local owner = GetOwner(mon)
    local ownerSkill = GetSkill(owner, "Bokor_Zombify")

    local value = skill.SklFactor + (ownerSkill.Level - 1) * skill.SklFactorByLevel
    return math.floor(value)
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SilverBullet_BuffTime(skill)
    local value = 15 + skill.Level * 3 
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Tase_BuffTime(skill)
    local value = 15 + skill.Level * 3
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Tase_Ratio(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, "Bulletmarker7")
    if abil ~= nil and abil.ActiveState == 1 then
        value = value + abil.Level
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DoubleGunStance_BuffTime(skill)

end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SmashBullet_Ratio(skill)
    local value = 0
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TracerBullet_Ratio(skill)
    local value = 10 + skill.Level * 2
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TracerBullet_Ratio2(skill)
    local value = 10 + skill.Level * 2
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TracerBullet_BuffTime(skill)
    local value = 15 + skill.Level * 3
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Jump_Ratio(skill)
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)
    local value = base + (skill.Level * per)
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_InfiniteAssault_Ratio(skill)
    local value = 10
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DownFall_Ratio(skill)
    local value = 3.5 + skill.Level * 0.5;
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DownFall_Ratio2(skill)
    local value = 1
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, "Mergen14")
    if abil ~= nil and TryGetProp(abil, "ActiveState") == 1 then
        value = 1.8
    end
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HakkaPalle_Ratio(skill)
    local value = 2.2 * skill.Level
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HakkaPalle_Ratio2(skill)
    local value = 3 * skill.Level
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HakkaPalle_Ratio3(skill)
    local value = skill.Level * 5
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SnipersSerenity_Ratio(skill)
    local value = 4 - (skill.Level * 0.72)
    if value < 0.4 then
        value = 0.4
    end
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_NonInvasiveArea_Bufftime(skill)
    local value = 10;
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_NonInvasiveArea_Ratio(skill)
    local value = 5 + (skill.Level * 2)
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_NonInvasiveArea_Ratio2(skill)
    local value = 42 + skill.Level * 2
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_RamMuay(skill)
    local pc = GetSkillOwner(skill);
    local value = 0
    local RamMuaySkill = GetSkill(pc, "NakMuay_RamMuay")
    if RamMuaySkill ~= nil then
        value = RamMuaySkill.SkillFactor;
    end
    return math.floor(value)
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Rammuay_Ratio(skill)
    local value = skill.Level * 20
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SokChiang_Time(skill)
    local pc = GetSkillOwner(skill);
    local value = 5 + skill.Level * 1
    
    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = value * 0.5; 
    end

    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_GroovingMuzzle_BuffTime(skill)
    local value = 15 + skill.Level;
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Sabbath_Ratio(skill)
    local value = 50
    value = value + (TryGetProp(skill, "Level") * 10)
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SubweaponCancel_Ratio(skill)
    local value = 500;
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FishingNetsDraw_Ratio(skill)
    local value = 2.5 + skill.Level;
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FishingNetsDraw_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 9 + skill.Level * 2;
    
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FishingNetsDraw_Ratio3(skill)
    local value = 50 + skill.Level * 5;
    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill))

    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ThrowingFishingNet_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 5 + skill.Level * 1;
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ThrowingFishingNet_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 9 + skill.Level * 2;
    local abil = GetAbility(pc, "Retiarii24")
    if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        value = value * 2
    end

    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ThrowingFishingNet_Ratio3(skill)
    local value = 50 + skill.Level * 5
    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill))
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ThrowingFishingNet_Time(skill)
    local value = 5
    local pc = GetSkillOwner(skill)
    if GetExProp(pc, 'ITEM_THROWINGFISHINGNET_TIMEUP') > 0 then
        value = value + 5
    end

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DaggerGuard_Ratio(skill)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)
    local value = skill.Level * per;
    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill))
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DaggerGuard_Ratio2(skill)
    return 15;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DaggerGuard_Ratio3(skill)
    local value = 10 + TryGetProp(skill, "Level");
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_FireFoxShikigami_Summon(skill)
    local value = 0
    local fireFox = GetSkillOwner(skill);
    local owner = GetOwner(fireFox)
    if owner ~= nil then
        local skillFireFoxShikigami = GetSkill(owner, "Onmyoji_FireFoxShikigami")
        if skillFireFoxShikigami ~= nil then
            value = skillFireFoxShikigami.SkillFactor
        end
    end
    
    return math.floor(value)
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_FireFoxShikigami2_Summon(skill)
    local value = skill.SklFactor
    local fireFox = GetSkillOwner(skill);
    local owner = GetOwner(fireFox)
    if owner ~= nil then
        local skillFireFoxShikigami = GetSkill(owner, "Onmyoji_FireFoxShikigami")
        if skillFireFoxShikigami ~= nil then
            value = skillFireFoxShikigami.SkillFactor
        end
    end
    
    return math.floor(value)
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FireFoxShikigami_Ratio(skill)
    local value = 20 + skill.Level * 5
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_WhiteTigerHowling_Ratio(skill)
    local value = 4 + skill.Level
    local pc = GetSkillOwner(skill);
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_GenbuArmor_Ratio(skill)
    local pc = GetSkillOwner(skill);
	local SPValue = 10
	if IsPVPField(pc) == 1 then
		SPValue = 5
	end
    local value = 100 - ((skill.Level - 1) * SPValue)
    
    local abilOnmyoji12 = GetAbility(pc, "Onmyoji12")
    if abilOnmyoji12 ~= nil and TryGetProp(abilOnmyoji12, "ActiveState", 0) == 1 then
        value = value - (value * abilOnmyoji12.Level * 0.01)
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_WaterShikigami_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 12
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_GenbuArmor_Ratio2(skill)
    local value = 60
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_VitalProtection_Ratio(skill)
    local value = 10 + skill.Level * 2
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Retiarii_EquipDesrption_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 4;
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Retiarii_EquipDesrption_Ratio2(skill)
    local value = 5;
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Kraujas_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = pc.RHP;
    if pc ~= nil then
        value = pc.RHP * 10;
    end
    
    return value;
end

-- 리쿠마
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Rykuma_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 25
    if pc ~= nil then        
        if HAS_DRAGON_POWER(pc) == true then
            value = 50
        end  
    end
    
    return value;
end

-- 앱사우가 - 지속시간
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Apsauga_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 30
    if pc ~= nil then        
        if HAS_DRAGON_POWER(pc) == true then
            value = value + 30
        end  
    end
    
    return value;
end

-- 코르프
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Korup_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 15
    if pc ~= nil then        
        if HAS_DRAGON_POWER(pc) == true then
            value = value + 15
        end  
    end
    
    return value;
end

-- 밴드린티
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Bendrinti_Time(skill)
    local pc = GetSkillOwner(skill);
    local value = 30
    if pc ~= nil then        
        if HAS_DRAGON_POWER(pc) == true then
            value = value + 20
        end  
    end
    return value;
end

-- 밴드린티
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Bendrinti_Ratio(self)   
    local value = 35

    if IsPVPServer(self) == 1 or IsPVPField(self) == 1 then
        value = 10
    end

    return value;
end

-- 가드마
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Goduma_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local casterMHP = TryGetProp(pc, "MHP", 0) - TryGetProp(pc, "MHP_BM", 0)
    local value = math.floor(casterMHP / (1000 * PC_MAX_LEVEL) * 100)
    local MaxValue = 50
    if HAS_DRAGON_POWER(pc) == true then
        MaxValue = 80
    end
    
    if value >= MaxValue then
        value = MaxValue
    end
        
    return value
end

-- 가드마
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Goduma_Ratio2(skill)
    local pc = GetSkillOwner(skill)
    local value = 0.5
    if pc ~= nil then        
        if HAS_DRAGON_POWER(pc) == true then
            value = 1
        end  
    end
    
    return value
end

-- 기마스
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Gymas_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 50
    return value;
end

-- 기마스
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Gymas_Ratio2(skill)    
    local pc = GetSkillOwner(skill)
    local value = 20

    if pc ~= nil then        
        if HAS_DRAGON_POWER(pc) == true then
            value = 40
        end  
    end

    return value
end

-- 스무지
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Smugis_Ratio(skill)
    local value = 25
    local pc = GetSkillOwner(skill)
    if pc ~= nil then        
        if HAS_DRAGON_POWER(pc) == true then
            value = value * 2
        end  
    end

    return value;
end

-- 앱크로바
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_apkrova_Ratio(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    if pc ~= nil then        
        if HAS_DRAGON_POWER(pc) == true then
            value = 20
        end  
    end

    return value;
end

-- 아트갈
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Atagal_Ratio(skill)
    local value = 100
    local pc = GetSkillOwner(skill)
    if pc ~= nil then        
        if HAS_DRAGON_POWER(pc) == true then
            value = 200
        end  
    end
    return value
end

-- 리리스
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Liris_Ratio(skill)
    local value = 30
    local pc = GetSkillOwner(skill)
    if pc ~= nil then        
        if HAS_DRAGON_POWER(pc) == true then
            value = 60
        end  
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_LatentVenom_Ratio(skill)

    local value = 3

    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_LatentVenom_Ratio2(skill)
    local value = 25 + (5 * skill.Level)

    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Dissonanz_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = 5
    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = value / 2
    end
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Wiegenlied_Time(skill)
    local pc = GetSkillOwner(skill)
    local value = 10
    if IsPVPField(pc) == 1 then
        value = 3
    end
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Wiegenlied_Ratio(skill)
    local value = 5 + skill.Level
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Wiegenlied_Ratio2(skill)
    local value = 5 + (skill.Level * 2)
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HypnotischeFlete_Ratio(skill)
    local value = 3 + skill.Level
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Friedenslied_Ratio(skill)
    local value = 4 + skill.Level
    local pc = GetSkillOwner(skill);
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Marschierendeslied_Ratio(skill)
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)
    local value = base + skill.Level * per
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_LiedDerWeltbaum_BuffTime(skill)
    local pc = GetSkillOwner(skill)
    local value = 10
    local abil = GetAbility(pc, "PiedPiper15")
    if abil ~= nil and TryGetProp(abil, "ActiveState") == 1 then
        value = value + TryGetProp(abil, "Level")
    end
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_LiedDerWeltbaum_Ratio(skill)
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)
    local value = base + (skill.Level * per)
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_LiedDerWeltbaum_Ratio2(skill)
    local value = 50 + (skill.Level * 10)
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Crescendo_Bane(skill)
    local value = 12 + skill.Level * 2
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Crescendo_Bane2(skill)
    local value = skill.Level * 20
    
    return value;
end

function SCR_GET_WideMiasma_Bufftime(skill)
    local value = 10
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_HamelnNagetier_Mouse(skill)
    local value = 0
    local piedPiper = GetSkillOwner(skill);
    local owner = GetOwner(piedPiper)
    if owner ~= nil then
        local skillHameln = GetSkill(owner, "PiedPiper_HamelnNagetier")
        if skillHameln ~= nil then   
            value = skillHameln.SkillFactor
        end
    end
    
    return math.floor(value)
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Rubric_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 5;
    local abilExorcist2 = GetAbility(pc, "Exorcist2");
    if abilExorcist2 ~= nil and TryGetProp(abilExorcist2, "ActiveState") == 1 then
        value = value + abilExorcist2.Level;
    end

    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Rubric_Ratio2(skill)
    local value = 5
    local pc = GetSkillOwner(skill);
    local abilExorcist3 = GetAbility(pc, "Exorcist3");
    if abilExorcist3 ~= nil and TryGetProp(abilExorcist3, "ActiveState") == 1 then
        value = 25
    end
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Rubric_Ratio3(skill)
    local value = 4
    local pc = GetSkillOwner(skill);
    local abilExorcist3 = GetAbility(pc, "Exorcist3");
    if abilExorcist3 ~= nil and TryGetProp(abilExorcist3, "ActiveState") == 1 then
        value = 2
    end
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Engkrateia_Ratio(skill)
    return skill.Level * 5
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Engkrateia_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 3;
    local abilExorcist8 = GetAbility(pc, "Exorcist8");
    if abilExorcist8 ~= nil and TryGetProp(abilExorcist8, "ActiveState") == 1 then
        value = value + abilExorcist8.Level;
    end

    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TheTreeofSepiroth_Ratio(skill)
    local value = 45 + (skill.Level - 1) * 21.1
    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill))
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TheTreeofSepiroth_Ratio2(skill)
    local pc = GetSkillOwner(skill)
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TheTreeofSepiroth_Time(skill)
    local value = 10
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Koinonia_Ratio(skill)
    local value = 5 + 3 * skill.Level;
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Gregorate_Ratio(skill)
    local value = 3;
    local pc = GetSkillOwner(skill);
    local abilExorcist11 = GetAbility(pc, "Exorcist11");
    if abilExorcist11 ~= nil and TryGetProp(abilExorcist11, "ActiveState") == 1 then
        value = value + abilExorcist11.Level;
    end
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Gregorate_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 17.5 + skill.Level * 1.75;
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FreezeBullet_BuffTime(skill)
    local value = 15 + skill.Level
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_OverReinforce_BuffTime(skill)
    local value = 45

    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, 'Enchanter5')
    if abil ~= nil and abil.ActiveState == 1 then
        value = value + (abil.Level * 3)
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_OverReinforce_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local maxpatk = SCR_Get_DEFAULT_MAXPATK(pc, 0)
    local minpatk = SCR_Get_DEFAULT_MINPATK(pc, 0)
    local rate = 0.015 + skill.Level * 0.004

    local vibora_rate = GetExProp(pc, 'ITEM_VIBORA_Empowering') / 1000
    if vibora_rate > 0 then
        rate = rate + vibora_rate
    end

    local value = ((maxpatk + minpatk)/2) * rate
    
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BreastRipper_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 8
    local SR = TryGetProp(pc, "SR")
    local strValue = SR / 3
    if strValue <= 0 then
        strValue = 0
    end
    value = value + strValue

    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_InfernalShadow_Bufftime(skill)
    return 5 + skill.Level;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_InfernalShadow_CaptionRatio(skill)
    local value = 36 + skill.Level * 6;
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EmphasisTrust_Ratio(skill)
    return 15 + skill.Level*2;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Hasisas_Ratio(skill)
    local name = TryGetProp(skill, 'ClassName', 'None')
    if name == 'Assassin_Hasisas' then
        local value = 155 + skill.Level * 20
        value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill))
        return value;
    else
        local value = skill.Level * 34
        return value;
    end
    
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Hasisas_Ratio2(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, 'Assassin2')
    if abil ~= nil and abil.ActiveState == 1 then
        value = value + abil.Level
    end
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Hasisas_Ratio3(skill)
    local name = TryGetProp(skill, 'ClassName', 'None')
    if name == 'Assassin_Hasisas' then
        local value = 3 + skill.Level * 1.5
        value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)    
        return value;
    else
        local value = skill.Level * 1.5
        return value;
    end    
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HallucinationSmoke_Ratio(skill)
    local value = 20
    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill))
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HallucinationSmoke_Time(skill)
    local value = 5 + skill.Level
    return value;
end
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PiercingHeart_Time(skill)
    local value = 10;
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, 'Assassin13')
    if abil ~= nil and abil.ActiveState == 1 then
        value = value + abil.Level
    end 
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Bully_Ratio(skill)
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)

    local value = base + skill.Level * per
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Bully_Ratio2(skill)
    local name = TryGetProp(skill, 'ClassName', 'None')
    if name == 'OutLaw_Bully' then
        local pc = GetSkillOwner(skill)
        local minPATK = TryGetProp(pc, "MINPATK")
        local maxPATK = TryGetProp(pc, "MAXPATK")
        local patkValue = math.floor((minPATK + maxPATK) / 2)
        local hateValue = patkValue * (skill.Level * 0.02)
        
        local abilReinforceRate = 1
        local abilOutlaw11 = GetAbility(pc, "Outlaw11");
        if abilOutlaw11 ~= nil then
            local abilLv = TryGetProp(abilOutlaw11, "Level");
            abilReinforceRate = abilReinforceRate + (abilLv * 0.005)
        end
        
        hateValue = hateValue * abilReinforceRate
    
        return math.floor(hateValue);
    else
        return skill.Level * 694
    end
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Aggress_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = skill.Level * 3
    
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Aggress_Ratio2(skill)
    local value = skill.Level * 2
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SiegeBurst_Ratio2(skill)
    local value = skill.Level * 0.1
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Algiz_Ratio(skill)
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)
    local value = base + skill.Level * per
    
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill);
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Algiz_Ratio2(skill)
    local value = 30;
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, 'RuneCaster11')
    if abil ~= nil and abil.ActiveState == 1 then
        value = 5
    end 
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SprinkleHPPotion_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local hpPotion = SCR_GET_SPEND_ITEM_Alchemist_SprinkleHPPotion(pc)
    local numberArg1 = TryGetProp(hpPotion, "NumberArg1", 0)
    local hpValue = numberArg1 * 7
    
    hpValue = hpValue * 8
    
    local sprinkleHP = hpValue * (skill.Level * 0.1)
    
    return sprinkleHP;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SprinkleSPPotion_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local spPotion = SCR_GET_SPEND_ITEM_Alchemist_SprinkleSPPotion(pc)
    local numberArg1 = TryGetProp(spPotion, "NumberArg1", 0)
    local spValue = numberArg1 * 7
    
    spValue = spValue * 8
    
    local sprinkleSP = spValue * (skill.Level * 0.1)
    
    return sprinkleSP;
end


function GET_SPENDSP_BY_LEVEL(sklObj, destLv)
    if destLv == nil or destLv == 0 then
        return math.floor(sklObj.SpendSP);
    end

    if destLv > 0 then
        local tempObj = CreateGCIESByID("Skill", sklObj.ClassID);
        if tempObj == nil then
            return 0;
        end
        tempObj.Level = destLv;
        return math.floor(tempObj.SpendSP);
    end

    --if upLv < 0 then return nil end;
    return nil;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Insurance_Ratio(skill)
    local value = skill.Level * 6
    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill))
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Insurance_Ratio2(skill)
    local value = skill.Level * 5
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Insurance_Ratio3(skill)
    local value = skill.Level * 5
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SwellHands_Ratio(skill)
    local name = TryGetProp(skill, 'ClassName', 'None')
    if name == 'Thaumaturge_SwellHands' then
        local pc = GetSkillOwner(skill)
        local maxpatk = SCR_Get_DEFAULT_MAXPATK(pc, value)
        local minpatk = SCR_Get_DEFAULT_MINPATK(pc, value)
        local value = ((maxpatk + minpatk)/2) * (0.02 + skill.Level * 0.002)
        
        value = (value * SCR_REINFORCEABILITY_TOOLTIP(skill))
        return math.floor(value);
    else
        local pc = GetSkillOwner(skill)
        local maxpatk = SCR_Get_DEFAULT_MAXPATK(pc)
        local minpatk = SCR_Get_DEFAULT_MINPATK(pc)        
        local sum_patk = (maxpatk + minpatk) / 2

        local maxmatk = SCR_Get_DEFAULT_MAXMATK(pc)
        local minmatk = SCR_Get_DEFAULT_MINMATK(pc)
        
        local sum_matk = (maxmatk + minmatk) / 2

        local pivot = math.max(sum_patk, sum_matk)        
        local value = pivot * (skill.Level * 0.006)
        
        return math.floor(value);
    end
end
    
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SwellHands_Ratio2(skill)    
    local pc = GetSkillOwner(skill)
    local value = TryGetProp(skill, 'Level', 1) * 2
    value = (value * SCR_REINFORCEABILITY_TOOLTIP(skill))    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Agility_Ratio(skill)
    local value = 5 + skill.Level * 1
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EnchantGlove_Ratio(skill)
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)
    local value = base + (skill.Level * per)
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_KnifeThrowing_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = 5 + (skill.Level * 1)

    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = value * 0.5;
    end
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_TimeForward_Ratio(skill)
    local value = skill.Level * 3
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Howling_Ratio(skill)
    local value = skill.Level * 4
    
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill);
    
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Howling_Ratio2(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Howling_Time(skill)
    local value = 10
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Immolation_Ratio(skill)
    local value = 0
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, "Zealot4")
    if abil ~= nil and abil.ActiveState == 1 then
        value = abil.Level * 300
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BeadyEyed_Ratio(skill)
    local value = 15 + skill.Level * 2
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FanaticIllusion_Ratio2(skill)
    local value = skill.Level * 10
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FreezeBullet_Ratio(skill)
    local value = 30
    local pc = GetSkillOwner(skill)
    if IsPVPServer(pc) == 1 then
        value = value / 2
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_brutality_Ratio(skill)
    local value = skill.Level * 0.4
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Bunshin_no_jutsu_Ratio3(skill)
    local value = 10 * skill.Level
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_DragonFear_Ratio(skill)
    local value = 10 + (skill.Level-1) * 5
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_DragonFear_Ratio2(skill)
    local value = 9 + (skill.Level) * 1
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_DragonFear_Ratio3(skill)
    local value = skill.Level * 10
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MuayThai_Ratio(skill)
    local value = 12 + skill.Level * 2
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MuayThai_Ratio2(skill)
    local pc = GetSkillOwner(skill)
    local cnt = 0;

    if GetSkill(pc, "NakMuay_TeKha") ~= nil then
        cnt = cnt + 1
    end

    if GetSkill(pc, "NakMuay_TeTrong") ~= nil then
        cnt = cnt + 1
    end

    if GetSkill(pc, "NakMuay_SokChiang") ~= nil then
        cnt = cnt + 1
    end

    local value = 10 + skill.Level * cnt * 0.35
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Hallucination_Ratio(skill)
    local value = 25 + (skill.Level * 5)
    local pc = GetSkillOwner(skill)
    local reinforceAbilName = TryGetProp(skill, "ReinforceAbility", "None");
    if reinforceAbilName ~= "None" then
        local reinforceAbil = GetAbility(pc, reinforceAbilName)
        if reinforceAbil ~= nil then
            local abilLevel = TryGetProp(reinforceAbil, "Level")
            value = value * (1 + (reinforceAbil.Level * 0.005));
        end
    end
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HardShield_Ratio(skill)
    if skill == nil then
        return 0
    end

    local factor = TryGetProp(skill, 'SklFactorByLevel', 0)
    local value = factor * TryGetProp(skill, 'Level', 0)
    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill));    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_Hackapell_GrindCutter(skill)
    local pc = GetSkillOwner(skill);
    local value = pc.SR + skill.SklSR;
    
    if IsPVPField(pc) == 1 and value > 4 then
        value = math.floor((math.max(0, value-4)^0.5))+math.min(4, value)
    end

    if value < 1 then
        value = 1
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_KnifeThrowing(skill)
    local pc = GetSkillOwner(skill);
    local skllv = TryGetProp(skill, "Level", 0)
    local basicCoolDown = TryGetProp(skill, "BasicCoolDown", 0)
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    if IsPVPField(pc) ~= 1 then
        if skllv >= 6 then
            basicCoolDown = basicCoolDown - (skllv-5) * 1000;
        end
        basicCoolDown = basicCoolDown + abilAddCoolDown;
        if basicCoolDown <= 8000 then
            basicCoolDown = 8000
        end
    end
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    return math.floor(basicCoolDown);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Bully_Time(skill)
    local value = 60
    local name = TryGetProp(skill, 'ClassName', 'None')
    
    if name == 'OutLaw_Bully' then
        local pc = GetSkillOwner(skill);
        local Outlaw19_abil = GetAbility(pc, 'Outlaw19')
        if Outlaw19_abil ~= nil and 1 == Outlaw19_abil.ActiveState and GetSkill(pc, 'OutLaw_Bully') ~= nil then
            value = 20
        end
    else
        value = 60
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_LightningCharm_Ratio(skill)
	local value = 30 + TryGetProp(skill, "Level", 1) * 1.5
	value = value * SCR_REINFORCEABILITY_TOOLTIP(skill);
	
	return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_BloodCurse_ratio2(skill)
    local value = (1 + skill.Level * 0.1)
    
    return value
end

-- Matross_FireAndRun
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FireAndRun_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = 90;
    local abil = GetAbility(pc, "Matross2")
    if abil ~= nil and abil.ActiveState == 1 then
        value = 45
    end
    
    return value
end

-- Matross_Explosion
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Explosion_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = math.floor(3 + skill.Level * 0.375);
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    
    return value
end

-- Matross_MenaceShot
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MenaceShot_Time(skill)
    local pc = GetSkillOwner(skill)
    local value = 5;
    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 then
        value = 2.5;
    end
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MenaceShot_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = 5 + skill.Level * 3
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    
    return value;
end

-- Matross_Roar
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Roar_Time(skill)
    local value = 30
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Roar_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = skill.Level * 5
    
    return value
end

-- Matross_CanisterShot
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CanisterShot_Time(skill)
    local pc = GetSkillOwner(skill)
    local value = 5;
    local abil = GetAbility(pc, "Matross12")
    if abil ~= nil and abil.ActiveState == 1 then
        value = value + abil.Level
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CanisterShot_Ratio(skill)
    local value = 10

    local pc = GetSkillOwner(skill);
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return value
end

-- TigerHunter_PierceShot
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function  SCR_GET_PierceShot_Ratio(skill)
    local value = 50
    return value
end

-- TigerHunter_Tracking
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Tracking_Time(skill)
    local pc = GetSkillOwner(skill)
    local value = 5
    
    local abil = GetAbility(pc, "TigerHunter2");
    if abil ~= nil and abil.ActiveState == 1 then
        value = value + 5;
    end
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Tracking_Ratio(skill)
    local value = 10 + 2 * skill.Level

    return value
end

-- TigerHunter_RapidShot
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RapidShot_Ratio(skill)
    local value = 20
    return value
end

-- TigerHunter_EyeofBeast
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EyeofBeast_Time(skill)
    local value = 20 + skill.Level * 8
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EyeofBeast_Ratio(skill)
    local value = 10 + skill.Level * 2
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EyeofBeast_Ratio2(skill)
    local value = skill.Level * 10
    return value
end

-- TigerHunter_Blitz
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Blitz_Ratio(skill)
    local value = skill.Level * 5
    return value
end

-- TigerHunter_HideShot
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HideShot_Time(skill)
    local pc = GetSkillOwner(skill)
    local value = 6
    
    return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HideShot_Ratio(skill)
    local value = 44 - (skill.Level * 2)
    return value
end

-- Arditi_TreGranata
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TreGranata_Time(skill)
    local value = 8
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TreGranata_Ratio(skill)
    local value = 3
    return value
end

-- Arditi_Recupero
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Recupero_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = skill.Level + 5
    
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Recupero_Ratio3(skill)
    local pc = GetSkillOwner(skill)
    local addHP = skill.Level * 535
    addHP = addHP * SCR_REINFORCEABILITY_TOOLTIP(skill)
    
    local mhp = TryGetProp(pc, "MHP", 0)
    
    local value = addHP - math.floor(mhp * 0.5)
    
    if value < 0 then
        value = 0;
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Recupero_Ratio2(skill)
    local value = skill.Level
    return value
end

-- Arditi_Taglio
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Taglio_Time(skill)
    local value = 2
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, "Arditi19")
    if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        value = 5
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Taglio_Ratio(skill)
    local value = 10
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_QuckDraw_Ratio(skill)
    local value = skill.Level * 0.1
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Fanning_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = math.min(4 + math.floor(TryGetProp(pc, 'SR', 0) / 2), 10);

    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Fanning_Ratio2(skill)
    local pc = GetSkillOwner(skill)
    local value = math.min(4 + math.floor(TryGetProp(pc, 'SR', 0) / 3), 10)

    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return value
end

-- Sheriff_Westraid
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Westraid_Time(skill)
    local value = 30
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Westraid_Ratio(skill)
    local value = math.floor(4 + skill.Level * 1)
    return value
end

-- Sheriff_Peacemaker
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Peacemaker_Time(skill)
    local value = 3
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Peacemaker_Time2(skill)
    local value = 3 + (skill.Level - 1) * 0.5
    return value
end

-- Sheriff_Redemption
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Redemption_Time(skill)
    -- 버프 지속시간
    local pc = GetSkillOwner(skill)
    local value = 40
    if IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 or IsJoinColonyWarMap(pc) == 1 then
        value = 8
    end

    local abil = GetAbility(pc, 'Sheriff6')
    if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 and GetSkill(pc, 'Sheriff_Redemption') ~= nil then
        value = value / 2;
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Redemption_Ratio(skill)
    -- 이동속도
    local pc = GetSkillOwner(skill)
    local value = 3

    if IsPVPField(pc) == 1 then
        value = value * 2;
    end

    local abil = GetAbility(pc, 'Sheriff6')
    if abil ~= nil and abil.ActiveState == 1 and GetSkill(pc, 'Sheriff_Redemption') ~= nil then
        value = value * 2;
    end
     
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Redemption_Ratio2(skill)    
    -- 최종 회피율
    local pc = GetSkillOwner(skill)
    local skillLevel = TryGetProp(skill, "Level", 1)

    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)

    local value = base + skillLevel * per
    if IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 or IsJoinColonyWarMap(pc) == 1 then
        value = 90 + skillLevel
    end
    
    return value
end

-- Sheriff_AimingShot
-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_AimingShot_Ratio(skill)
    local value = 3
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_AimingShot_Ratio2(skill)
    local pc = GetSkillOwner(skill)
    local value = 50
    local abil = GetAbility(pc, "Sheriff5")
    if abil ~= nil and abil.ActiveState == 1 then
        value = 200
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Prevent_Bufftime(skill)
    local pc = GetSkillOwner(skill)
    local value = 2
    local abil = GetAbility(pc, "Lancer14")
    if abil ~= nil and abil.ActiveState == 1 then
        value = value + (abil.Level * 0.2)
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Methadone_Ratio(skill)
	local value = 20 - (skill.Level * 2)
	
	return value;
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Prevent_Ratio(skill)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0) / 10    
    local value = skill.Level * per    
    if value >= 15 then
        value = 15
    end
    return value
end


function SCR_GET_JOLLYROGERFEVERTIME(pc)
	local bufftime = 10000
	if IsExistSkill(pc, 'Thaumaturge_SwellHands') ~= 0 or IsExistSkill(pc, 'Common_Thaumaturge_SwellHands') ~= 0 then
		bufftime = bufftime + 25000
	end
--	if IsExistSkill(pc, 'Linker_JointPenalty') ~= 0 then
--		bufftime = bufftime + 25000
--	end
	if IsExistSkill(pc, 'Enchanter_OverReinforce') ~= 0 then
		bufftime = bufftime + 25000
	end	

	return bufftime
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SPRIMKLESANDSTIME(skill)
    local value = skill.Level * 0.2

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_EctoplasmExplosion(skill)
    local pc = GetSkillOwner(skill);
    local OutofBodySkill = GetSkill(pc, "Sadhu_OutofBody")
    local value = 0
    if OutofBodySkill ~= nil then
        value = OutofBodySkill.SkillFactor;
    end
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Sacred_Heal_Ratio(skill)
    --value = skill.SklFactor + (skill.Level - 1) * skill.SklFactorByLevel;
    local value = (10 + (skill.Level - 1) * 2.7) * 0.4
    
    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill))
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Barong_Time(skill)
    local value = 20
    return math.floor(value);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HolySmash_Heal_Ratio(skill)
    local value = (16 + (skill.Level - 1) * 2.7) * 0.4

    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill))
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RingOfLight_Heal_Ratio(skill)
    local value = (42 + (skill.Level - 1) * 7.1) * 0.4

    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill))
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Condemn_Heal_Ratio(skill)
    local value = (14 + (skill.Level - 1) * 3.7) * 0.4

    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill))
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ProtectionOfGoddess_Heal_Ratio(skill)
    local value = (67 + (skill.Level - 1) * 67.3) * 0.4

    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill))
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Retaliation_Heal_Ratio(skill)
    local value = (76 + (skill.Level - 1) * 20) * 0.4

    value = math.floor(value * SCR_REINFORCEABILITY_TOOLTIP(skill))
    
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ProtectionOfGoddess_SPD_Ratio(skill)
	local pc = GetSkillOwner(skill);
	local sspd = skill.Level * 0.05
	local value = pc.MSPD * sspd
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Chants_Ratio(skill)
    value = 100 + (skill.Level * 8)
	
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Chants_Ratio2(skill)
    value = (20 + skill.Level * 5)
	
    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HolySmash_SR_Ratio(skill)
    local pc = GetSkillOwner(skill);
    return math.floor(2 + pc.SR/3)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ProtectionOfGoddess_SR_Ratio(skill)
    local pc = GetSkillOwner(skill);

    local value = math.floor(4 + pc.SR/3)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Sacred_SR_Ratio(skill)
    local pc = GetSkillOwner(skill);

    local value = math.floor(3 + pc.SR/3)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Retaliation_SR_Ratio(skill)
    local pc = GetSkillOwner(skill);

    local value = math.floor(3 + pc.SR/3)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Condemn_SR_Ratio(skill)
    local pc = GetSkillOwner(skill);

    local value = math.floor(3 + pc.SR/3)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RingOfLight_SR_Ratio(skill)
    local pc = GetSkillOwner(skill);

    local value = math.floor(2 + pc.SR/3)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SandWall_SPD_Ratio(skill)
    local value = 10 + skill.Level
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Obey_Ratio(skill)
    local value = 50
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_ControlBlade(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");

    local abil = GetAbility(pc, 'Blossomblader9')
    if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        if IsBuffApplied(pc, "StartUp_Buff") == "YES" then
            local reduceCoolTime = TryGetProp(abil, "Level", 0) * 1000 
            basicCoolDown = basicCoolDown + abilAddCoolDown - reduceCoolTime;
        end
    end
    
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    
    local ret = math.floor(basicCoolDown) / 1000
    
    ret = math.floor(ret) * 1000;
    
    return math.floor(ret);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Flowering_BuffTime(skill)
    local value = 30
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Flowering_Ratio(skill)
    local value = 2 * skill.Level
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Flowering_Ratio2(skill)
    local value = skill.Level + 1
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_StartUp_BuffTime(skill)
    local value = 20
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_StartUp_Ratio(skill)
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)
    local value = base + per * skill.Level
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Luka_Time(skill)
    local value = 10
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Kutukan_Time(skill)
    local value = 4
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Penyerapan_Ratio(skill)
    local sklLv = TryGetProp(skill, "Level", 1)
    local value = 15 + sklLv * 5

    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)

    return math.floor(value)
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Keletihan_Time(skill)
    local value = 10 + skill.Level;
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Keletihan_Ratio(skill)
    local value = 0.5 * skill.Level;
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Keletihan_Ratio2(skill)
    local pc = GetSkillOwner(skill)
    local value = 7 + (pc.SR/5);
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return math.floor(value)
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Keletihan_Ratio3(skill)
    local value = 0.15 * skill.Level;
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Rawa_Time(skill)
    local value = 8.5;
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Rawa_Ratio(skill)
    local value = 2;
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Rawa_Ratio2(skill)
    local value = skill.Level;
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_Kutukan(skill)

    local pc = GetSkillOwner(skill);
    if pc == nil and ui.GetFrame("pub_createchar"):IsVisible() == 1 then
        return skill.SklSR;
    end

    local value = pc.SR

    if IsPVPField(pc) == 1 and value > 4 then
        value = math.floor((math.max(0, value-4)^0.5))+math.min(4, value)
    end
    
    if value < 1 then
        value = 1
    end
    
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_GuidedShot_Time(skill)
    local value = 20
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Escape_Ratio(skill)
    local value = skill.Level * 5
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DeadZone_Time(skill)
    local value = 10
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DeadZone_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = 3

    local abil = GetAbility(pc, 'Arbalester18')
    if abil ~= nil and TryGetProp(abil, 'ActiveState', 0) == 1 then
        value = 7
    end

    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DeadZone_Ratio2(skill)
    local pc = GetSkillOwner(skill)
    local value = 2

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ShiningBurst_Time(skill)
    local value = 5
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ShiningBurst_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = math.floor(7 + TryGetProp(pc, "SR", 0)/3)

    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_SeptEtoiles(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    if IsBuffApplied(pc, "ITEM_BUFF_VIBORA_RAPIER") == "YES" then
        basicCoolDown = basicCoolDown - 5000 
    end

    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)

    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Fleche(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    if IsBuffApplied(pc, "ITEM_BUFF_VIBORA_RAPIER") == "YES" then
        basicCoolDown = basicCoolDown - 10000
    end

    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)

    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_HolySmash(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    if IsBuffApplied(pc, "ITEM_BUFF_VIBORA_THMACE") == "YES" then
        basicCoolDown = basicCoolDown - 5000
    end

    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)

    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Condemn(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    if IsBuffApplied(pc, "ITEM_BUFF_VIBORA_THMACE") == "YES" then
        basicCoolDown = basicCoolDown - 10000
    end

    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)

    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_BlossomSlash(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    if IsBuffApplied(pc, "ITEM_BUFF_VIBORA_THSWORD") == "YES" then
        basicCoolDown = basicCoolDown - 15000
    end

    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)

    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Crusader_Chants_Heal_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local skills = GetSkill(pc, 'Crusader_Chants')
    local value = 100
    
    return math.floor(value)
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_InfernalShadow_CaptionRatio2(skill)
    return skill.Level * 4
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BreakBrick_Ratio(skill)
    local value = skill.Level
    return value
end

function SCR_GET_BreakBrick_Ratio(skill)
    local value = skill.Level
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ShadowFatter_Ratio(skill)
    local value = 20 + skill.Level * 2
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Tracking_Ratio2(skill)
    local value = 5 + skill.Level * 2
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    local skill_name = TryGetProp(skill, "ClassName", "None")

    -- 기본 스킬 재사용 대기시간 1초짜리는 감소시켜 주지 않음
    if CHECK_SKILL_KEYWORD(skill, "BasicSkill") == 1 then
        return basicCoolDown
    end

    -- 공용스킬은 재사용 대기시간 효과를 적용받지 않음
    if GetClass('enchant_skill_list', skill_name) ~= nil then
        return basicCoolDown
    end

    -- Laima CoolTime Buff
    local laimaCoolTime = GetExProp(pc, "LAIMA_BUFF_COOLDOWN")
    if laimaCoolTime ~= 0 and TryGetProp(skill, "CoolDownGroup", "None") ~= "ItemSetSkill" then
        basicCoolDown = basicCoolDown * (1 - laimaCoolTime)
    end

    -- AyinSof CoolTime Buff
    local AyinSofCoolTime = GetExProp(pc, "AyinSof_BUFF_COOLDOWN")
    if AyinSofCoolTime ~= 0 and TryGetProp(skill, "CoolDownGroup", "None") ~= "ItemSetSkill" then
        basicCoolDown = basicCoolDown * (1 - AyinSofCoolTime)
    end

    -- Laima CoolTime Debuff
    if laimaCoolTime == 0 and IsBuffApplied(pc, 'CarveLaima_Debuff') == 'YES' and TryGetProp(skill, "CoolDownGroup", "None") ~= "ItemSetSkill" then
        basicCoolDown = basicCoolDown * 1.2;
    end

    -- Burning Event
    if IsBuffApplied(pc, "Event_Cooldown_SPamount_Decrease") == "YES" then
        basicCoolDown = SCR_COOLDOWN_SPAMOUNT_DECREASE(pc, "CoolDown", basicCoolDown)
    end

    -- Field Dungeon
    if IsBuffApplied(pc, "FIELD_COOLDOWNREDUCE_BUFF") == "YES" or IsBuffApplied(pc, "FIELD_DEFAULTCOOLDOWN_BUFF") == "YES" or IsBuffApplied(pc, "FIELD_COOLDOWNREDUCE_MIN_BUFF") == "YES" then
        basicCoolDown = SCR_FIELD_DUNGEON_CONSUME_DECREASE(pc, "CoolDown", basicCoolDown)
    end

    -- (WEEKLY BOSS RAID) Star Pall
    local monCoolDownRate = math.max(-9, GetExProp(pc, "MON_COOLDOWN_RATE"))*0.1
    if monCoolDownRate ~= 0 then
        basicCoolDown = basicCoolDown + (basicCoolDown * monCoolDownRate)
    end

    -- GM Buff
    if IsBuffApplied(pc, 'GM_Cooldown_Buff') == 'YES' then
        basicCoolDown = basicCoolDown * 0.9;
    end
    
    -- RootCrystal
    if IsBuffApplied(pc, 'RootCrystalCoolDown_BUFF') == 'YES' then
        basicCoolDown = basicCoolDown * 0.5
    end

    -- -- Centurion Buff (Removed)
    -- if IsBuffApplied(pc, 'SpeForceFom_Buff') == 'YES' then
    --     if skill.ClassName ~= "Centurion_SpecialForceFormation" then
    --         basicCoolDown = basicCoolDown * 0.5;
    --     end
    -- end
    
    -- 여신 방어구 체크
    if IsPVPField(pc) ~= 1 and IsPVPServer(pc) ~= 1 then
    local tempskill = GetSkill(pc, TryGetProp(skill, "ClassName", "None"))
    -- 달리아 방어구    
    if tempskill ~= nil and GetExProp(pc, 'ep12_dalia_leather_stack') > 0 and TryGetProp(tempskill, 'CastingCategory', 'None') == 'channeling' and TryGetProp(tempskill, 'ValueType', 'None') == 'Attack' then
        local stack = GetExProp(pc, 'ep12_dalia_leather_stack')
        basicCoolDown = basicCoolDown * (1 - (0.05 * stack)) -- 부위당 5%
    end

    -- 가비야의 선물    
    if GetExProp(pc, 'ep12_gabija_casting_stack') > 0 then
        local stack = GetExProp(pc, 'ep12_gabija_casting_stack')
        if TryGetProp(tempskill, 'CastingCategory', 'None') == 'cast' and TryGetProp(tempskill, 'ValueType', 'None') == 'Attack' then
            basicCoolDown = basicCoolDown * (1 - (0.05 * stack)) -- 부위당 5%
        elseif TryGetProp(tempskill, 'CastingCategory', 'None') == 'dynamic_casting' and TryGetProp(tempskill, 'ValueType', 'None') == 'Attack' then
                basicCoolDown = basicCoolDown * (1 - (0.05 * stack)) -- 부위당 5%
        end
    end
    end
    
    -- RadaOption 라다의 축복
    local rada_cooldown = GetExProp(pc, 'rada_cooldown')
    if rada_cooldown > 0 then
        rada_cooldown = 1 - rada_cooldown / 100
        basicCoolDown = basicCoolDown * rada_cooldown
    end

    rada_cooldown = GetExProp(pc, 'jurate_cooldown')
    if rada_cooldown > 0 then
        rada_cooldown = 1 - rada_cooldown / 100        
        basicCoolDown = basicCoolDown * rada_cooldown
    end
    
    -- 여신의 전언: 불꽃의 기억 쿨다운 감소
    local earring_raid_cooldown = GetExProp(pc, 'earring_raid_cooldown')
    if earring_raid_cooldown > 0 then
        earring_raid_cooldown = 1 - earring_raid_cooldown / 100
        basicCoolDown = basicCoolDown * earring_raid_cooldown
    end

    -- 시련 : 스킬 쿨다운 증가
    local tribulation_cooldown = GetExProp(pc, "tribulation_cooldown");
    if tribulation_cooldown > 0 then
        tribulation_cooldown = 1 + (tribulation_cooldown / 100);
        basicCoolDown = BasicCoolDown * tribulation_cooldown;
    end
    
	-- 2021 근본 인장
	if IsBuffApplied(pc, 'premium_seal_2021_buff') == 'YES' and IsBuffApplied(pc, 'Event_Cooldown_SPamount_Decrease') == 'NO' and SCR_IS_LEVEL_DUNGEON(pc) == 'YES' then
		basicCoolDown = basicCoolDown * 0.5
    end
    
    if IsBuffApplied(pc, 'TOSHero_MonsterBuff_SkillCoolDownUp') == 'YES' then
		basicCoolDown = basicCoolDown * 1.1
    end

	-- 영웅담
	if IS_TOS_HERO_ZONE(pc) == 'YES' and TryGetProp(skill, "ValueType", "None") == "Attack" and CHECK_SKILL_KEYWORD(skill, "NormalSkill") == 0 and GetExProp(pc, "TOSHero_CoolDownRate") ~= 0 then
		basicCoolDown = basicCoolDown * GetExProp(pc, "TOSHero_CoolDownRate")
    end

    -- 레전드 카드 : 스킬 쿨 다운
    local card_skill_cooldown = GetExProp(pc, 'card_SkillCoolDown')
    if card_skill_cooldown > 0 then
        card_skill_cooldown = 1 - (card_skill_cooldown / 100);
        basicCoolDown = basicCoolDown * card_skill_cooldown;
    end
    
    local neck = GetEquipItem(pc, 'NECK')
	if IS_TOS_HERO_ZONE(pc) == 'YES' and TryGetProp(skill, "ValueType", "None") == "Attack" and basicCoolDown <= 20000 and GetBuffOver(pc, "TOSHero_Buff_Tear3_AttackSPD") >= 5 and TryGetProp(neck, "ClassName", "None") == "TOSHero_NECK_AS" then
        basicCoolDown = 5000
    end
    
    -- 재사용 대기시간이 없는 스킬은 제외(스킬 쿨다운이 0초가 되는 이유는 쿨다운 custom funciton에서 ret = math.floor(ret) * 1000 로 floor 하기 때문임)
    local class_name = TryGetProp(skill, 'ClassName', 'None')
    if TryGetProp(skill, 'CoolDownStartType', 'None') == 'None' and IsExpertSkill(class_name) == 1 and basicCoolDown > 0 and basicCoolDown < 1000 then
        basicCoolDown = 1000
    end

	return basicCoolDown
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Judgment_Ratio(skill)
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)
    local value = base + skill.Level * per
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Zealot_Invulnerable(skill)    
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)

    local value = base + skill.Level * per
    value = value / 10
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FanwiseShots_Ratio(skill)
    local value = 2 * skill.Level

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_ShadowThorn(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    

    -- local VTS = GetExProp(pc, 'ITEM_VIBORA_THSTAFF_SHADOWTHORN')
    -- if VTS ~= 0 then
    --     basicCoolDown = basicCoolDown - 5000 
    -- end

    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)

    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SnipersSerenitySPD_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local lv = TryGetProp(skill, "Level", 1)
    local value = 45 + lv
        

        
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BreakingWheel_Ratio(skill)
    local value = 0
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, "Inquisitor8")
    if abil ~= nil and abil.ActiveState == 1 then
        value = 15
        local abilInquisitor20 = GetAbility(pc, "Inquisitor20")
        if abilInquisitor20 ~= nil and abilInquisitor20.ActiveState == 1 then
            value = value + abilInquisitor20.Level
        end
    end

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Outrage_Ratio(skill)
    local arg1 = TryGetProp(skill, 'Level', '1')
    local value = 100 + arg1 * 10
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_Granata(skill)

    local pc = GetSkillOwner(skill);
    if pc == nil and ui.GetFrame("pub_createchar"):IsVisible() == 1 then
        return skill.SklSR;
    end

    local value = pc.SR + skill.SklSR;
    
    if GetExProp(pc, "ITEM_VIBORA_DAGGER_TAGLIO") > 0 then
        value = value + 10
    end

    if IsPVPField(pc) == 1 and value > 4 then
        value = math.floor((math.max(0, value-4)^0.5))+math.min(4, value)
    end

    if value < 1 then
        value = 1
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Vibora_Granada(skill)
    local pc = GetSkillOwner(skill)
    local Granada = GetSkill(pc, "Arditi_Granata")
    local value = TryGetProp(Granada, "SkillFactor", 0) * 6

    value = value * 0.5

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Vibora_KnifeThrow(skill)
    local pc = GetSkillOwner(skill)
    local Knife = GetSkill(pc, "Rogue_KnifeThrowing")
    local value = TryGetProp(Knife, "SkillFactor", 0)
    
    value = value * 2 * 0.6
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_ArrowRain(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    local VTS = GetExProp(pc, 'ITEM_VIBORA_ARROW_RAIN')
    if VTS ~= 0 then
        basicCoolDown = basicCoolDown - 20000
    end

    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)

    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Vibora_Gust(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Cryomancer_IciclePike")
    local value = TryGetProp(skl, "SkillFactor", 0)

    value = value
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Highlander_CounterSlash(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Highlander_CrossCut")
    local value = TryGetProp(skl, "SkillFactor", 0) * 2

    value = value * 2
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Hoplite_ThrouwingSpear_Vibora(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Hoplite_ThrouwingSpear")
    local value = TryGetProp(skl, "SkillFactor", 0)

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_PierceShot(skill)

    local pc = GetSkillOwner(skill);
    if pc == nil and ui.GetFrame("pub_createchar"):IsVisible() == 1 then
        return skill.SklSR;
    end

    local value = pc.SR + skill.SklSR;
    
    if value < 1 then
        value = 1
    end
    
    if GetExProp(pc, "ITEM_VIBORA_MUSKET_TIGERHUNTER") > 0 then
        value = value + 10
    end

    if IsPVPField(pc) == 1 and value > 4 then
        value = math.floor((math.max(0, value-4)^0.5))+math.min(4, value)
    end

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_PierceShot(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    local VTS = GetExProp(pc, 'ITEM_VIBORA_MUSKET_TIGERHUNTER')
    if VTS ~= 0 then
        basicCoolDown = basicCoolDown - 10000
    end

    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)

    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_RIP(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    if IsBuffApplied(pc, "ITEM_BUFF_VIBORA_PISTOL") == "YES" then
        basicCoolDown = basicCoolDown - 10000
    end

    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)

    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_MozambiqueDrill(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    if IsBuffApplied(pc, "ITEM_BUFF_VIBORA_PISTOL") == "YES" then
        basicCoolDown = basicCoolDown - 10000
    end

    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)

    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_YinYangConsonance(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = TryGetProp(skill, "BasicCoolDown", 0)
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    local abil = GetAbility(pc, "Onmyoji28")
    if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        basicCoolDown = basicCoolDown - 22500;
    end
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    return math.floor(basicCoolDown);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Vibora_Katadikazo(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Exorcist_Katadikazo")
    local value = TryGetProp(skl, "SkillFactor", 0)

    value = (value * 3) * 0.5
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Sauk_Ratio(skill)
    local value = 7
    local pc = GetSkillOwner(skill)
    if pc ~= nil then        
        if HAS_DRAGON_POWER(pc) == true then
            value = value + 3
        end  
    end

    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Ezera_Ratio(skill)
    local value = 25
    local pc = GetSkillOwner(skill)
    local dragonPower = 10
    if IsPVPServer(pc) == 1 then
        value = 12
        dragonPower = 5
    end

    if HAS_DRAGON_POWER(pc) == true then
        value = value + dragonPower
    end

    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Balinta_Ratio(skill)
    local value = 175
    local pc = GetSkillOwner(skill)
    if pc ~= nil then        
        if HAS_DRAGON_POWER(pc) == true then
            value = 250
        end  
    end

    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Karys_Ratio(skill)
    local value = 100
    local pc = GetSkillOwner(skill)
    if pc ~= nil then        
        if HAS_DRAGON_POWER(pc) == true then
            value = 150
        end  
    end

    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Karys_Ratio2(skill)
    local value = 30
    local pc = GetSkillOwner(skill)
    if IsPVPServer(pc) == 1 then
        value = 15
    end

    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Lydeti_Ratio(skill)
    local value = 300
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 then
        value = 150
    end

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_DownFall(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = TryGetProp(skill, "BasicCoolDown", 0)
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    return math.floor(basicCoolDown);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Vibora_QS(skill)
    local pc = GetSkillOwner(skill)
    local RapidFire = GetSkill(pc, "QuarrelShooter_RapidFire")
    local value = math.floor(TryGetProp(RapidFire, "SkillFactor", 0) * 5)

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Capote(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    if IsBuffApplied(pc, "ITEM_BUFF_VIBORA_RAPIER_MATADOR_EQUIP") == "YES" then
        basicCoolDown = basicCoolDown - 10000
    end

    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)

    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Ole(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    if IsBuffApplied(pc, "ITEM_BUFF_VIBORA_RAPIER_MATADOR_EQUIP") == "YES" then
        basicCoolDown = basicCoolDown - 10000
    end

    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)

    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CrossCut_Bufftime(skill)
    local pc = GetSkillOwner(skill);
    local time = 5 + (TryGetProp(skill, "Level", 0) * 1)
    local abil = GetAbility(pc, 'Highlander34')
    if abil ~= nil and abil.ActiveState == 1 then
        time = time + (abil.Level * 1)
    end
    return time;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
-- 포스 웨이브 대미지
function SCR_Get_SkillFactor_Triukas(skill)
    local pc = GetSkillOwner(skill)
    local now1 = GetExProp(pc, 'EP12_LOW_006_STACK')
    local now2 = GetExProp(pc, 'EP12_HIGH_006_STACK')
    local now3 = GetExProp(pc, 'EP12_LUCI_005_STACK')

    local value = (now1 * 330) + (now2 * 550) + (now3 * 600)
    if GetExProp(pc, "ITEM_DRAGON_POWER") == 2 then
        if now2 == 4 then
            value = now2 * 715
        end

        if now3 == 4 then
            value = now3 * 780
        end
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ShadowFatter_Ratio2(skill)
    local value = skill.Level * 0.2
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Barrage_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local sklsr = TryGetProp(skill, "SklSR", 0)
    local value = sklsr + math.floor(TryGetProp(pc, "SR", 0))
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_ViboraGravity(skill)
    local pc = GetSkillOwner(skill)
    local Teardown = GetSkill(pc, "Psychokino_GravityPole")
    local value = TryGetProp(Teardown, "SkillFactor", 0)

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_ViboraGravity_Finish(skill)
    local pc = GetSkillOwner(skill)
    local Teardown = GetSkill(pc, "Psychokino_GravityPole")
    local value = TryGetProp(Teardown, "SkillFactor", 0) * 10

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Westraid(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    if IsBuffApplied(pc, "ITEM_BUFF_VIBORA_PISTOL_DERRINGER") == "YES" then
        basicCoolDown = basicCoolDown - 25000
    end

    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)

    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Punish(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    if IsBuffApplied(pc, "ITEM_BUFF_VIBORA_THSWORD_PUNISH") == "YES" then
        basicCoolDown = basicCoolDown + 10000
    end

    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)

    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Vibora_Matross(skill)
    local pc = GetSkillOwner(skill)
    local Explosion = GetSkill(pc, "Matross_Explosion")
    local value = math.floor(TryGetProp(Explosion, "SkillFactor", 0) * 0.6)
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Vibora_Matador(skill)
    local pc = GetSkillOwner(skill)
    local PasoDoble = GetSkill(pc, "Matador_PasoDoble")
    local value = math.floor(TryGetProp(PasoDoble, "SkillFactor", 0) * 4 * 0.2)
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HallucinationSmoke_Ratio2(skill)
    local value = 30 + skill.Level * 2
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Luciferi_Piktis(skill)
    local pc = GetSkillOwner(skill)
    local now = GetExProp(pc, 'EP12_LUCI_004_STACK')

    local value = now * 500
    if GetExProp(pc, "ITEM_DRAGON_POWER") == 2 and now == 4 then
        value = now * 650
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Prediction_Time(skill)
    local value = 30
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Prediction_Ratio(skill)
    local value = 6 * skill.Level
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Binatio(skill)
    local pc = GetSkillOwner(skill);
    local BinatioSkill = GetSkill(pc, "Chaplain_Binatio")
    local value = 0
    if BinatioSkill ~= nil then
        value = BinatioSkill.SklFactor + BinatioSkill.SklFactorByLevel * (BinatioSkill.Level - 1)
    end
    
    return math.floor(value)

end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_EP13_Card_Austeja(skill)
    local pc = GetSkillOwner(skill)
    local buff = GetBuffByName(pc, 'CARD_EP13_Austeja_Equip')
    local now, notuse = GetBuffArg(buff)

    local value = now * 720
    if IsPVPField(pc) == 1 then
        value = math.floor(value * 0.5)
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_EP13_Card_Saule(skill)
    local pc = GetSkillOwner(skill)
    local buff = GetBuffByName(pc, 'CARD_EP13_Saule_Equip')
    local now, notuse = GetBuffArg(buff)
    
    local value = now * 504
    if IsPVPField(pc) == 1 then
        value = math.floor(value * 0.5)
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_EP13_Card_Dalia(skill)
    local pc = GetSkillOwner(skill)

    local value = 4320
    if IsPVPField(pc) == 1 then
        value = math.floor(value * 0.5)
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_EP13_Card_Vakarine(skill)
    local pc = GetSkillOwner(skill)

    local value = 4320
    if IsPVPField(pc) == 1 then
        value = math.floor(value * 0.5)
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
-- 바우바스 카드
function SCR_Get_SkillFactor_Baubas_fire(skill)
    local pc = GetSkillOwner(skill)

    local value = 30000
    if IsPVPField(pc) == 1 then
        value = math.floor(value * 0.5)
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Vibora_DragonFall(skill)
    local pc = GetSkillOwner(skill)
    local fall = GetSkill(pc, "Dragoon_DragonFall")
    local value = math.floor(TryGetProp(fall, "SkillFactor", 0) * 3 * 0.4)

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Vibora_Leventador(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Fencer_BalestraFente")
    local value = math.floor(TryGetProp(skl, "SkillFactor", 0) * 4 * 0.1)

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Fletcher_ViboraArrow(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Fletcher_BodkinPoint")
    local value = math.floor(TryGetProp(skl, "SkillFactor", 0) * 0.5)

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Cannoneer_ViboraCannonHold(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Cannoneer_CannonShot")
    local value = math.floor(TryGetProp(skl, "SkillFactor", 0))

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Berkana_Ratio(skill)
    local value = 10.5 + skill.Level * 1
    
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill);
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Crusader_Convict(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Crusader_Sacred")
    local value = math.floor(TryGetProp(skl, "SkillFactor", 0) * 8 * 0.2)

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TrickorTreat_Ratio(skill)
    local value = skill.Level * 1
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill);
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TrickorTreat_Ratio2(skill)
    local value = skill.Level * 2
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill);
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_ClownWalk(skill)
    local pc = GetSkillOwner(skill);
    local ClownWalkSkill = GetSkill(pc, 'Clown_ClownWalk');
    local value = skill.SklFactor + (TryGetProp(ClownWalkSkill, "Level", 1) - 1) * skill.SklFactorByLevel;
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_FatalRoulette(skill)
    local pc = GetSkillOwner(skill);
    local FatalSkill = GetSkill(pc, 'Clown_FatalRoulette');
    local value = TryGetProp(FatalSkill, "SkillFactor", 0)
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_TimeClutch(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Chronomancer_Slow")
    if skl == nil then
        return
    end
    local sklLV = TryGetProp(skl, "Level", 1)
    local value = sklLV * 400

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_LewaAdvent(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Bokor_Damballa")
    local value = math.floor(TryGetProp(skl, "SkillFactor", 0) * 0.9)

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Tempest(skill)
    local pc = GetSkillOwner(skill)
    local skl1 = GetSkill(pc, "NakMuay_TeKha")
    local skl2 = GetSkill(pc, "NakMuay_SokChiang")
    local skl3 = GetSkill(pc, "NakMuay_TeTrong")
    local skl4 = GetSkill(pc, "NakMuay_KhaoLoi")
    if skl1 == nil and skl2 == nil and skl3 == nil and skl4 == nil then
        return
    end
    
    local sklFactor_1 = 0
    local sklFactor_2 = 0
    local sklFactor_3 = 0
    local sklFactor_4 = 0
    
    if skl1 ~= nil then
        sklFactor_1 = TryGetProp(skl1, "SkillFactor", 0) * 4
    end
    
    if skl2 ~= nil then
        sklFactor_2 = TryGetProp(skl2, "SkillFactor", 0) * 4
    end
    
    if skl3 ~= nil then
        sklFactor_3 = TryGetProp(skl3, "SkillFactor", 0) * 2
    end
    
    if skl4 ~= nil then
        sklFactor_4 = TryGetProp(skl4, "SkillFactor", 0) * 2
    end
    
    
    local value = math.floor((sklFactor_1 + sklFactor_2 + sklFactor_3 + sklFactor_4) * 0.1)

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DesperateDefense_Time(skill)
    local pc = GetSkillOwner(skill)
    local value = 10 + (TryGetProp(skill, "Level", 0) - 1)

    local abil = GetAbility(pc, "Arquebusier16")
    if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        value = value + TryGetProp(abil, "Level", 0)
    end

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_TeKha_Normal(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "NakMuay_TeKha")
    local value = TryGetProp(skl, "SkillFactor", 100)
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_SokChiang_Normal(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "NakMuay_SokChiang")
    local value = TryGetProp(skl, "SkillFactor", 100)
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_TeTrong_Normal(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "NakMuay_TeTrong")
    local value = TryGetProp(skl, "SkillFactor", 100)
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FrenziedBurst_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 0
    local abil = GetAbility(pc, "Murmillo20")
	if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        local addValue = TryGetProp(abil, "Level", 0) * 6
        value = value + addValue
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ShieldTrain_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 0
    local abil = GetAbility(pc, "Murmillo20")
	if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        local addValue = TryGetProp(abil, "Level", 0) * 6
        value = value + addValue
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Heal(skill)        
    local pc = GetSkillOwner(skill)
    local value = 0;
    if pc ~= nil and IsBuffApplied(pc, "Cleric32_DARK_SPHERE_BUFF") == "YES" then
        value = SCR_GET_Heal_Ratio3_Common(skill)
    elseif pc ~= nil and IsBuffApplied(pc, "AUTO_MATCHING_DARK_SPHERE_BUFF") == "YES" then
        local add_buff_factor = 10;
        value = SCR_GET_Heal_Ratio2_Common(skill) * add_buff_factor
    end

    return value
end
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Priest_MassHeal(skill)
    local pc = GetSkillOwner(skill)
    local value = 0;
    if pc ~= nil and IsBuffApplied(pc, "AUTO_MATCHING_DARK_SPHERE_BUFF") == "YES" then
        local add_buff_factor = 10;
        value = SCR_GET_MassHeal_Ratio_Common(skill)*add_buff_factor
        return value
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Clown_Knife(skill) -- 포켓 나이프
    local pc = GetSkillOwner(skill);
    local value = 1000
    local GuidedShotSkill = GetSkill(pc, 'Clown_Replica');
    if GuidedShotSkill ~= nil then
        value = TryGetProp(GuidedShotSkill, "SkillFactor", 1000)
    end

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ClownWalk_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = TryGetProp(skill, "Level", 1)

    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DoublePunch_Ratio3(skill)
    local value = 35 + skill.Level * 1;
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Vibora_KnifeSpread(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Clown_Climax")
    local value = TryGetProp(skl, "SkillFactor", 0) * 5 * 0.25

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_BlandirCadena(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    local VTS = GetExProp(pc, 'ITEM_Retiarii_ThrowNet_Lv4')
    if VTS ~= 0 then
        basicCoolDown = basicCoolDown - 25000
    end

    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)

    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Grind(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Rancer_GiganteMarcha")
    if skl == nil then
        return
    end
    
    local value = TryGetProp(skl, "SkillFactor", 0) * 10

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_ShadowCondensation(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = TryGetProp(skill, "BasicCoolDown", 0)
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    

    if GetExProp(pc, "ITEM_VIBORA_DiffuseReflection_Lv4") > 0 then
        basicCoolDown = basicCoolDown - 15000;
    end
 
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)

    return math.floor(basicCoolDown);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Evocation(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = TryGetProp(skill, "BasicCoolDown", 0)
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    

    if GetExProp(pc, "ITEM_VIBORA_WickedDesire_Lv4") > 0 then
        basicCoolDown = basicCoolDown - 10000;
    end
 
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)

    return math.floor(basicCoolDown);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_InfiniteAssault(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = TryGetProp(skill, "BasicCoolDown", 0)
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    

    if GetExProp(pc, "ITEM_VIBORA_SWORD_Hackapell_Lv4") > 0 then
        basicCoolDown = basicCoolDown - 5000;
    end
 
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)

    return math.floor(basicCoolDown);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_RapidShot(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = TryGetProp(skill, "BasicCoolDown", 0)
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    

    if GetExProp(pc, "ITEM_VIBORA_TripleStepsSingleShot_LV4") > 0 then
        basicCoolDown = basicCoolDown - 10000;
    end
 
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)

    return math.floor(basicCoolDown);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Joust(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = TryGetProp(skill, "BasicCoolDown", 0)
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    

    if GetExProp(pc, "ITEM_VIBORA_Lancer_LV4") > 0 then
        basicCoolDown = basicCoolDown - 10000;
    end
 
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)

    return math.floor(basicCoolDown);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_CrouchingStrike(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = TryGetProp(skill, "BasicCoolDown", 0)
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    

    -- if GetExProp(pc, "ITEM_VIBORA_CenterFire_LV4") > 0 then
    --     basicCoolDown = basicCoolDown - 5000;
    -- end
 
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)

    return math.floor(basicCoolDown);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Tiwaz(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = TryGetProp(skill, "BasicCoolDown", 0)
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    

    if GetExProp(pc, "ITEM_VIBORA_AwakeningRune_LV4") > 0 then
        basicCoolDown = basicCoolDown - 15000;
    end
 
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)

    return math.floor(basicCoolDown);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PrecisionFire_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = 0.7
    if GetExProp(pc, "ITEM_VIBORA_Arquebusier") > 0 then
        value = value / 2
    end

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Unload(skill)
    local pc = GetSkillOwner(skill)
    local basicCoolDown = TryGetProp(skill, "BasicCoolDown", 0)
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown")
 
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)

    return math.floor(basicCoolDown)
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_BreastRipper(skill)
    local pc = GetSkillOwner(skill)
    local basicCoolDown = TryGetProp(skill, "BasicCoolDown", 0)
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown")

    if GetExProp(pc, "ITEM_VIBORA_Outrage_LV4") > 0 then
        basicCoolDown = basicCoolDown - 25000
    end
 
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)

    return math.floor(basicCoolDown)
end

function SCR_GET_Escape_Ratio2(skill)
    local value = skill.Level * 1
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BlockAndShoot_Ratio2(skill)
    local pc = GetSkillOwner(skill)
    local value = math.floor(2+pc.SR/3)

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Zhendu_Ratio3(skill)
    local pc = GetSkillOwner(skill)
    local pcLv = TryGetProp(pc, "Lv", 1)
    local sklLv = TryGetProp(skill, "Level", 1)

    local value = (15*pcLv) + (sklLv*pcLv*3.3)
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return math.floor(value)
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Matador_Muleta_Faena(skill)
    local value = 100
    local pc = GetSkillOwner(skill)
    local faena_skill = GetSkill(pc, 'Matador_Faena')
    if faena_skill ~= nil then
        value = TryGetProp(faena_skill, 'SkillFactor', 100)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_OneManRush(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Cataphract_Rush")
    local value = TryGetProp(skl, "SkillFactor", 0)
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Micro_Distortion(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Sage_HoleOfDarkness")
    local value = math.floor(TryGetProp(skl, "SkillFactor", 0) * 6)
    
    value = value * 0.35

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Extinction(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Elementalist_ElementalEssence")
    local value = math.floor(TryGetProp(skl, "SkillFactor", 0))    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_ShakeFoot(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Monk_DoublePunch")
    local value = math.floor(TryGetProp(skl, "SkillFactor", 0) * 24)

    value = value * 0.2
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_ShakeFoot_OneTarget(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Monk_DoublePunch")
    local value = math.floor(TryGetProp(skl, "SkillFactor", 0) * 24)
    
    value = value * 0.2
    value = value * 2
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_ShakeFoot_LV4(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Monk_PalmStrike")
    local value = math.floor(TryGetProp(skl, "SkillFactor", 0) * 0.275)
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_DivineShock(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Kriwi_Melstis")
    local value = math.floor(TryGetProp(skl, "SkillFactor", 0) * 1.5)

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_VIBORA_OUTLAW(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "OutLaw_Rampage")
    local value = math.floor(TryGetProp(skl, "SkillFactor", 0))
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Aiming_Ratio(skill)
    local value = skill.Level

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Caracole_Ratio(skill)
    local value = skill.Level * 0.5
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, "Schwarzereiter16")
    if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        value = value * 2
    end
    if value >= 5 then
        value = 5
    end
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Caracole_Ratio2(skill)
    local value = skill.Level

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HighMagnifyingGlass_Ratio(skill)
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)
    local value = base + skill.Level * per
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)

    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Vibora_Assassin(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Assassin_PiercingHeart")
    local value = math.floor(TryGetProp(skl, "SkillFactor", 0)) * 2
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Annihilation(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = TryGetProp(skill, "BasicCoolDown", 0)
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    

    if GetExProp(pc, "ITEM_VIBORA_SuddenDeath_Lv4") > 0 then
        basicCoolDown = basicCoolDown - 15000;
    end
 
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)

    return math.floor(basicCoolDown);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_DarkspiritExplosion(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Warlock_Invocation")
    local value = math.floor(TryGetProp(skl, "SkillFactor", 0) * 2)
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ShieldLob_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 8
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Pouncing_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 5
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Impaler_Ratio3(skill)
    local pc = GetSkillOwner(skill);
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FrenziedSlash_Ratio3(skill)
    local pc = GetSkillOwner(skill);
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BalestraFente_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DragonFall_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 30
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Joust_Ratio3(skill)
    local pc = GetSkillOwner(skill);
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CorridaFinale_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 15
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_InfiniteAssault_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 12
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FlameGround_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FirePillar_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 7
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HellBreath_Ratio3(skill)
    local pc = GetSkillOwner(skill);
    local value = 7
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Prominence_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 3
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_IcePillar_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MagneticForce_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HeavyGravity_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 13
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Stop_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 5
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Slow_Ratio3(skill)
    local pc = GetSkillOwner(skill);
    local value = 3
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ElementalEssence_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 15
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MicroDimension_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 3
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_UltimateDimension_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DimensionCompression_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 15
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PoleofAgony_Ratio3(skill)
    local pc = GetSkillOwner(skill);
    local value = 4
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Mastema_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 7
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Ngadhundi_Ratio3(skill)
    local pc = GetSkillOwner(skill);
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_KundelaSlash_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Hagalaz_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 8
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Stan_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 3
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ShadowConjuration_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ShadowCondensation_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 5
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_GreenwoodShikigami_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Toyou_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 15
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_YinYangConsonance_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 15
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CrystalballShikigami_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 7
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CreepingDeath_Ratio3(skill)
    local pc = GetSkillOwner(skill);
    local value = 3
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PhantomEradication_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 15
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HornOfGolem_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ThrowGuPot_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 6
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MagicArrow_Ratio3(skill)
    local pc = GetSkillOwner(skill);
    local value = 3
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Pheasant_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 15
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CoveringFire_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 6
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Zaibas_Ratio3(skill)
    local pc = GetSkillOwner(skill);
    local value = 4
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DivineStigma_Ratio3(skill)
    local pc = GetSkillOwner(skill);
    local value = 5
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Chortasmata_Ratio3(skill)
    local pc = GetSkillOwner(skill);
    local value = 9
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Seedbomb_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 5
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Seedbomb_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_AstralBodySmite_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 5
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Incineration_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 8
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PlagueVapours_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 4
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Merkabah_Ratio3(skill)
    local pc = GetSkillOwner(skill);
    local value = 3
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Hamaya_Ratio3(skill)
    local pc = GetSkillOwner(skill);
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FanaticIllusion_Ratio3(skill)
    local pc = GetSkillOwner(skill);
    local value = 6

    local abil = GetAbility(pc, "Zealot16")
    if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        value = value * 2
    end

    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EmphasisTrust_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_AquaBenedicta_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Gregorate_Ratio3(skill)
    local pc = GetSkillOwner(skill);
    local value = 5
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Koinonia_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 15
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_AssaultFire_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 15
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TreGranata_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 15
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Rawa_Ratio3(skill)
    local pc = GetSkillOwner(skill);
    local value = 6
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FatalRoulette_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 7
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

function SCR_Get_SkillFactor_Vibora_Mergen(skill)
    local pc = GetSkillOwner(skill)
    local Explosion = GetSkill(pc, "Mergen_ArrowRain")
    local value = math.floor(TryGetProp(Explosion, "SkillFactor", 0))

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Blink_Ratio(skill)
    local value = 100 + skill.Level * 10
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Skarphuggning(skill)
    local pc = GetSkillOwner(skill)
    local value = 0
    local skarphuggningSkill = GetSkill(pc, "Hackapell_Skarphuggning")
    if skarphuggningSkill ~= nil then
        value = TryGetProp(skarphuggningSkill, "SkillFactor", 0)
    end
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Tanoti_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = TryGetProp(skill, "Level", 0) * 4.5 + 35
    return value;
end 

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Patati_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = TryGetProp(skill, "Level", 0) * 4.5 + 35
    return value;
end 

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SoulMaster_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = 17 + TryGetProp(skill, "Level", 0)
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Anila_Ratio(skill)
    local value = TryGetProp(skill, "Level", 0) * 3 + 45
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Golpear_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 5

    local abil = GetAbility(pc, "Luchador11")
    if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        value = 10
    end

    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Golpear(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;

    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)

    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_DobleAtaque(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Luchador_LuchaDeSilla")
    local value = math.floor(TryGetProp(skl, "SkillFactor", 0)*1.35) 
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_EscudoEspada(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Rodelero_Montano")
    local value = math.floor(TryGetProp(skl, "SkillFactor", 0))
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Enmascarado_Ratio(skill)
    local value = 51 + TryGetProp(skill, "Level", 0) * 6
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Ceremonia_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Buceando(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Luchador_Chocar")
    local value = math.floor(TryGetProp(skl, "SkillFactor", 0) * 0.875) 
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Rodando(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Luchador_LuchaDeSilla")
    local value = math.floor(TryGetProp(skl, "SkillFactor", 0) * 0.466) 
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Brothehood(skill)
    local pc = GetSkillOwner(skill)
    local value = 0.8 + 0.295 * skill.Level

    local reinfabil = skill.ReinforceAbility
    local abil = GetAbility(pc, reinfabil)
    if abil ~= nil and TryGetProp(skill, "ReinforceAbility") ~= 'None' then
        local abilLevel = TryGetProp(abil, "Level")
        local masterAddValue = 0
        if abilLevel == 100 then
            masterAddValue = 0.1
        end

        value = value * (1 + ((abilLevel * 0.005) + masterAddValue))
    end

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DoNotRetreat(skill)
    local pc = GetSkillOwner(skill)
    local value = (18 + skill.Level * 7)*2

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DoNotRetreat2(skill)
    local pc = GetSkillOwner(skill);
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    return math.floor(value)
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_DoNotRetreat_Arts(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Hwarang_PyeonJeon")
    if skl == nil then 
       return 100
    end

    local donot = GetSkill(pc, 'Hwarang_DoNotRetreat')
    local rate = SCR_GET_DoNotRetreat(donot) / 100

    if IsBuffApplied(pc, "Hwarang_DoNotRetreat_Arts_Buff") == 'YES' then
        rate = rate * 0.5
    end

    local value = math.floor(TryGetProp(skl, "SkillFactor", 0) * rate) 

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_SKILL_MAXR_FletcherArrowShot(skill)
    local pc = GetSkillOwner(skill);
    if pc == nil then
        return skill.MaxRValue;
    end
    local addMaxR = 0;
    if skill.ClassName == 'Fletcher_FletcherArrowShot' then
        addMaxR = skill.Level * 10
    end

    local value = skill.MaxRValue + pc.MaxR_BM + addMaxR;
    if value >= 220 then
        value = 220
    end

    return value
    
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Reinforce_Ability_FletcherArrowSkill(skill)
    local pc = GetSkillOwner(skill)
    local value = skill.SklFactor + skill.SklFactorByLevel * (skill.Level - 1)

    if IsInTOSHeroMap(pc) == true then
        return math.floor(value)
    end

    local reinfabil = skill.ReinforceAbility
    local abil = GetAbility(pc, reinfabil)
    if abil ~= nil and TryGetProp(skill, "ReinforceAbility") ~= 'None' then
        local abilLevel = TryGetProp(abil, "Level")
        local masterAddValue = 0
        if abilLevel == 100 then
            masterAddValue = 0.1
        end
        
        value = value * (1 + ((abilLevel * 0.005) + masterAddValue))

        local hidden_abil_cls = GetClass("HiddenAbility_Reinforce", skill.ClassName);
        if abilLevel >= 65 and hidden_abil_cls ~= nil then
        	local hidden_abil_name = TryGetProp(hidden_abil_cls, "HiddenReinforceAbil");
        	local hidden_abil = GetAbility(pc, hidden_abil_name);
        	if hidden_abil ~= nil then
        		local abil_level = TryGetProp(hidden_abil, "Level");
        		local add_factor = TryGetProp(hidden_abil_cls, "FactorByLevel", 0) * 0.01;
        		local add_value = 0;
        		if abil_level == 10 then
        			add_value = TryGetProp(hidden_abil_cls, "AddFactor", 0) * 0.01
        		end
                value = value * (1 + (abil_level * add_factor) + add_value);
        	end
        end
    end

    local FletcherArrowShot = GetSkill(pc, 'Fletcher_FletcherArrowShot')
    if FletcherArrowShot ~= nil then
        local add_factor = SCR_Get_SkillFactor_Reinforce_Ability(FletcherArrowShot) / 100

        value = value + value * add_factor
    end

    return math.floor(value)
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CatenaChainArrow_Ratio(skill)
    
    local pc = GetSkillOwner(skill);
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end

    local Fletcher40 = GetAbility(pc, "Fletcher40")

    if Fletcher40 ~= nil and TryGetProp(Fletcher40, "ActiveState") == 1 then
        value = 1
    end

    return value

end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Strafe_Ratio(skill)
    local value = 100 + skill.Level * 20
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_CriticalShot(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    if GetExProp(pc, 'ITEM_VIBORA_Tempest') > 0 then
        basicCoolDown = basicCoolDown - 5000
    end

    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)

    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Reinforce_Ability_BlazingArrow(skill)
    local pc = GetSkillOwner(skill)
    local value = skill.SklFactor + skill.SklFactorByLevel * (skill.Level - 1)-- 스킬팩터 계산

    if IsInTOSHeroMap(pc) == true then
        return math.floor(value)
    end

    local reinfabil = skill.ReinforceAbility
    local abil = GetAbility(pc, reinfabil)-- 강화 특성
    if abil ~= nil and TryGetProp(skill, "ReinforceAbility") ~= 'None' then
        local abilLevel = TryGetProp(abil, "Level")
        local masterAddValue = 0
        if abilLevel == 100 then
            masterAddValue = 0.1
        end
        
        value = value * (1 + ((abilLevel * 0.005) + masterAddValue))

        local hidden_abil_cls = GetClass("HiddenAbility_Reinforce", skill.ClassName);
        if abilLevel >= 65 and hidden_abil_cls ~= nil then
        	local hidden_abil_name = TryGetProp(hidden_abil_cls, "HiddenReinforceAbil");
        	local hidden_abil = GetAbility(pc, hidden_abil_name);
        	if hidden_abil ~= nil then
        		local abil_level = TryGetProp(hidden_abil, "Level");
        		local add_factor = TryGetProp(hidden_abil_cls, "FactorByLevel", 0) * 0.01;
        		local add_value = 0;
        		if abil_level == 10 then
        			add_value = TryGetProp(hidden_abil_cls, "AddFactor", 0) * 0.01
        		end
                value = value * (1 + (abil_level * add_factor) + add_value);
        	end
        end
    end
    
    local Ranger38 = GetAbility(pc, "Ranger38")
    if Ranger38 ~= nil and TryGetProp(Ranger38, "ActiveState") == 1 then
        value = value * 0.7
    end
    return math.floor(value)
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Reinforce_Ability_Strape(skill)
    local pc = GetSkillOwner(skill)
    local value = skill.SklFactor + skill.SklFactorByLevel * (skill.Level - 1)-- 스킬팩터 계산

    if IsInTOSHeroMap(pc) == true then
        return math.floor(value)
    end

    local reinfabil = skill.ReinforceAbility
    local abil = GetAbility(pc, reinfabil)-- 강화 특성
    if abil ~= nil and TryGetProp(skill, "ReinforceAbility") ~= 'None' then
        local abilLevel = TryGetProp(abil, "Level")
        local masterAddValue = 0
        if abilLevel == 100 then
            masterAddValue = 0.1
        end
        
        value = value * (1 + ((abilLevel * 0.005) + masterAddValue))

        local hidden_abil_cls = GetClass("HiddenAbility_Reinforce", skill.ClassName);
        if abilLevel >= 65 and hidden_abil_cls ~= nil then
        	local hidden_abil_name = TryGetProp(hidden_abil_cls, "HiddenReinforceAbil");
        	local hidden_abil = GetAbility(pc, hidden_abil_name);
        	if hidden_abil ~= nil then
        		local abil_level = TryGetProp(hidden_abil, "Level");
        		local add_factor = TryGetProp(hidden_abil_cls, "FactorByLevel", 0) * 0.01;
        		local add_value = 0;
        		if abil_level == 10 then
        			add_value = TryGetProp(hidden_abil_cls, "AddFactor", 0) * 0.01
        		end
                value = value * (1 + (abil_level * add_factor) + add_value);
        	end
        end
    end

    local Ranger54 = GetAbility(pc, "Ranger54")
    if Ranger54 ~= nil and TryGetProp(Ranger54, "ActiveState") == 1 then
        value = value * 2
    end

    return math.floor(value)
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_TrickShot_Explode(skill)
    local pc = GetSkillOwner(skill)
    if TryGetProp(skill, 'ClassName', 'None') ~= 'Mergen_TrickShot' then
        skill = GetSkill(pc, 'Mergen_TrickShot')
    end
    return math.floor(TryGetProp(skill, 'SkillFactor', 100) * 0.4)
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Prakriti_Ratio2(skill)
    local value = 10
    local pc = GetSkillOwner(skill);
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Anila_Ratio2(skill)
    local value = 7
    local pc = GetSkillOwner(skill);
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Tanoti_Ratio2(skill)
    local value = 5
    local pc = GetSkillOwner(skill);
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Patati_Ratio2(skill)
    local value = 10
    local pc = GetSkillOwner(skill);
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Moksha_Ratio2(skill)
    local value = 10
    local pc = GetSkillOwner(skill);
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Zenith_CaptionRatio(skill)
    local value = skill.Level * 3
    if value >= 21 then
        value = 21
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_Mergen(skill)

    local pc = GetSkillOwner(skill);
    if pc == nil and ui.GetFrame("pub_createchar"):IsVisible() == 1 then
        return skill.SklSR;
    end

    local value = pc.SR + skill.SklSR;

    local zenith = GetSkill(pc, 'Mergen_Zenith')
    local zenith_level = TryGetProp(zenith, 'Level', 0)

    local Mergen26 = GetAbility(pc, "Mergen26")

    if zenith_level > 0 and TryGetProp(Mergen26, "ActiveState", 0) == 0 then
        value = value + SCR_GET_Zenith_CaptionRatio(zenith)
    end

    if IsPVPField(pc) == 1 and value > 4 then
        value = math.floor((math.max(0, value-4)^0.5))+math.min(4, value)
    end
    
    if value < 1 then
        value = 1
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_GroovingMuzzle_Ratio(skill)
    local pc = GetSkillOwner(skill)
       
    local level = TryGetProp(skill, "Level", 1)
    local value = 20 + 3 * level

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.

function SCR_GET_DesperateDefens_Ratio(skill)
    local level = TryGetProp(skill, "Level", 1)
    local ability_add_val = SCR_REINFORCEABILITY_TOOLTIP(skill)
    -- Damage Reduction
    local base = TryGetProp(skill, 'SklFactor', 0)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0)
    local val = base + (level * per)
    val = val * ability_add_val
    return val
end

function SCR_GET_DesperateDefens_Ratio2(skill)
    local level = TryGetProp(skill, "Level", 1)
    local ability_add_val = SCR_REINFORCEABILITY_TOOLTIP(skill)
    
    --CRTDR & BLK rate increse
    local val = 5 + 1.5 * level
    val = val * ability_add_val

    return val
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_LV_Arquebusier(skill)

    local pc = GetSkillOwner(skill);
    if pc == nil and ui.GetFrame("pub_createchar"):IsVisible() == 1 then
        return skill.SklSR;
    end

    local value = pc.SR + skill.SklSR;

    local Arquebusier22 = GetAbility(pc, "Arquebusier22")
    if TryGetProp(Arquebusier22, "ActiveState", 0) == 1 then
        value = value + 10
    end

    if IsPVPField(pc) == 1 and value > 4 then
        value = math.floor((math.max(0, value-4)^0.5))+math.min(4, value)
    end
    
    if value < 1 then
        value = 1
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_SKILL_MAXR_Bazooka(skill)
    local pc = GetSkillOwner(skill);
    if pc == nil then
        return skill.MaxRValue;
    end

    local value = skill.MaxRValue
    if IsBuffApplied(pc, 'Bazooka_Buff') == 'YES' then
        value = 200
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_CannonShot(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    if IsBuffApplied(pc, "Bazooka_Buff") == "YES" then
        basicCoolDown = basicCoolDown * 2
    end

    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill);

    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Matross_ArtilleryCall(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;

    if GetExProp(pc, 'ITEM_VIBORA_CenterFire_LV4') > 0 then
        basicCoolDown = basicCoolDown - 20000
    end

    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill);

    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Cannoneer_SweepingCannon(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;

    if GetExProp(pc, 'CamnonHold_Lv4') > 0 then
        basicCoolDown = basicCoolDown - 20000
    end

    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill);

    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SR_CrouchingStrike(skill)

    local pc = GetSkillOwner(skill);
    if pc == nil and ui.GetFrame("pub_createchar"):IsVisible() == 1 then
        return skill.SklSR;
    end

    local value = pc.SR + skill.SklSR;
    
    local Matross14 = GetAbility(pc, "Matross14")
    if Matross14 ~= nil and TryGetProp(Matross14, "ActiveState", 0) == 1 then
        value = value + 6
    end
    
    if IsPVPField(pc) == 1 and value > 4 then
        value = math.floor((math.max(0, value-4)^0.5))+math.min(4, value)
    end
    
    if value < 1 then
        value = 1
    end

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Teardown(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;

    if skill.Level > 1 then
        basicCoolDown = basicCoolDown - skill.Level * 1000 + 1000
    end

    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)

    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DarkJudgements_Time(skill)
    local value = 4 + 1 * skill.Level
    
    return value;
end

-- 이시다비 트리우카스
function SCR_Get_SkillFactor_Isdavi_Triukas(skill)
    local pc = GetSkillOwner(skill)
    local now = GetExProp(pc, 'EP13_ISDA_005_STACK')

    local value = now * 1500
    if GetExProp(pc, "ITEM_DRAGON_POWER") == 2 and now == 4 then
        value = now * 1950
    end
    
    return value
end

-- 이시다비 피크티스
function SCR_Get_SkillFactor_Isdavi_Piktis(skill)
    local pc = GetSkillOwner(skill)
    local now = GetExProp(pc, 'EP13_ISDA_004_STACK')

    local value = now * 500
    if GetExProp(pc, "ITEM_DRAGON_POWER") == 2 and now == 4 then
        value = now * 650
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Defiance_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local per = TryGetProp(skill, 'SklFactorByLevel', 0) / 10
    local value = TryGetProp(skill, "Level", 0) * per
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Rangda_Luka(skill)
    local pc = GetSkillOwner(skill);
    local value = 100
    local original_Skill = GetSkill(pc, 'Rangda_Luka');
    if original_Skill ~= nil then
        value = TryGetProp(original_Skill, "SkillFactor", 100)
    end

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Rangda_Kutukan(skill)
    local pc = GetSkillOwner(skill);
    local value = 100
    local original_Skill = GetSkill(pc, 'Rangda_Kutukan');
    if original_Skill ~= nil then
        value = TryGetProp(original_Skill, "SkillFactor", 100)
    end

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ElectricDrive_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = 5 + TryGetProp(skill, "Level", 0)


    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ElectricDrive_Ratio2(skill)
    local pc = GetSkillOwner(skill)
    local value = 2 + TryGetProp(skill, "Level", 0) * 0.4

    return math.floor(value)
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HackaPoa_Ratio(skill)
    local value = 10 + skill.Level * 2
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Spaning_Ratio(skill)
    local value = skill.Level
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Blossa_Ratio(skill)
    local value = 15 + skill.Level
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_EnchantAura_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local basicSP = 100
    local bylvCorrect = 0

    local lv = pc.Lv
    bylvCorrect = lv - 300

    if bylvCorrect < 0 then
        bylvCorrect = bylvCorrect * 2.75 / 1000
    elseif bylvCorrect >= 0 then
        bylvCorrect = bylvCorrect * 1.25 / 1000
    end

    local value = basicSP * (1 + bylvCorrect)
    
    local abilAddSP = GetAbilityAddSpendValue(pc, skill.ClassName, "SP");
    abilAddSP = abilAddSP / 100;

    value = math.floor(value) + math.floor(value * abilAddSP);

    local decByZemina = 0
    local zeminaSP = GetExProp(pc, "ZEMINA_BUFF_SP");
    if zeminaSP ~= 0 then
        decByZemina = value * zeminaSP
    end
    value = value - decByZemina;
    
    --burning_event
    local decByBuff = 0
    if IsBuffApplied(pc, "Event_Cooldown_SPamount_Decrease") == "YES" then
        decByBuff = SCR_COOLDOWN_SPAMOUNT_DECREASE(pc, "SpendSP", value)
    elseif IsBuffApplied(pc, "FIELD_SP_FULL_BUFF") == "YES" then
        decByBuff = SCR_FIELD_DUNGEON_CONSUME_DECREASE(pc, "SpendSP", value)
    elseif IsBuffApplied(pc, 'premium_seal_2021_buff') == 'YES' and IsBuffApplied(pc, 'Event_Cooldown_SPamount_Decrease') == 'NO' and SCR_IS_LEVEL_DUNGEON(pc) == 'YES' then
		decByBuff = value * 0.5
	else
        if IsBuffApplied(pc, "Gymas_Buff") == "YES" then -- 기마스
            local ratio = 0.5;
            decByBuff = value * ratio
        end
    end
    value = value - decByBuff;
    ----------
	
    if value < 1 then
        value = 0
    end
	
	if IS_TOS_HERO_ZONE(pc) == "YES" and GetExProp(pc, "TOSHero_Tear1_ManaBurn") > 0 then
		value = SCR_TOSHero_Tear1_ManaBurn(skill, value)
	end

	if IS_TOS_HERO_ZONE(pc) == "YES" and GetExProp(pc, "TOSHero_Tear2_ManaBurn") > 0 and TryGetProp(skill, "ValueType", "None") == "Attack" then
		value = value * 2
	end

    return math.floor(value);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_EnchantAura_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 2

    if GetExProp(pc, 'ITEM_VIBORA_Empowering_LV4') > 0 then
        value = 1
    end

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SpendSP_Featherfoot(skill)
    
    local pc = GetSkillOwner(skill);

    if pc == nil then
        return math.floor(0);
    end

    if TryGetProp(skill, "BasicSP") == 0 then
        return 0;
    end
    
    local pcMSP = TryGetProp(pc, "MSP")
    local pcSP = TryGetProp(pc, "SP", 0)
    if IsServerSection() == 0 then
        local stat = info.GetStat(session.GetMyHandle())
        pcMSP = stat.maxSP
        pcSP = stat.SP
    end
    
    local value = SCR_Get_MSP(pc) * (0.12 - (pcSP/pcMSP*0.1))
    
    if IsBuffApplied(pc, 'Wizard_Wild_buff') == 'YES' then
        value = value * 1.5 * spRatio;
        return math.floor(value);
    end
    
    if IsBuffApplied(pc, 'MalleusMaleficarum_Debuff') == 'YES' then
        value = value * 2
        return math.floor(value);
    end
    
    if TryGetProp(skill, "ClassName", "None") == "Cleric_Heal" then
        local jobHistory = '';
        if IsServerObj(pc) == 1 then
            if IS_PC(pc) == true then
                jobHistory = GetJobHistoryString(pc);
            end
        else
            jobHistory = GetMyJobHistoryString();
        end
        
        local jobList = GetJobHistoryList(pc)
        for i = 1, #jobList do
            if jobList[i] == 4002 then
                value = value - 25
            end
        end

        
        if jobHistory ~= nil and string.find(jobHistory, "Char4_10") ~= nil then
            value = value - 50
        end
    end
    
    if value < 1 then
        value = 0
    end
    if IsBuffApplied(pc, 'ShadowPool_Buff') == 'YES' and (skill.ClassName == "Shadowmancer_ShadowPool" or skill.ClassName == "Common_Shadowmancer_ShadowPool" )then
        value = 0;
    end
    
    if skill.ClassName == "Oracle_TwistOfFate" and 
        (GetZoneName(pc) == "guild_agit_1" or GetZoneName(pc) == "guild_agit_extension") then
        return 0
    end

    return math.floor(value);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_JointPenalty_Ratio3(skill)
    local value = 100 * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Kundela_Bufftime(skill)
    local pc = GetSkillOwner(skill)
    local value = 10
    local abilFeatherfoot41 = GetAbility(pc, "Featherfoot41")
    if abilFeatherfoot41 ~= nil and TryGetProp(abilFeatherfoot41, "ActiveState", 0) == 1 then
        value = 20
    end
    return math.floor(value)
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Plague_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = 7.5 + skill.Level * 1.5

    return math.floor(value)
end

function SCR_FEATHERFOOT_ATTACCOUNT(skill)
    local value = 0
    local list = {
        {"Featherfoot_Kundela", 3},
        {"Featherfoot_Ngadhundi", 10},
        {"Featherfoot_Bloodexplosion", 5},
        {"Featherfoot_Bloodpool", 5},
        {"Featherfoot_Enervation", 15},
    }
    for i = 1, #list do
        if skill.ClassName == list[i][1] then
            value = list[i][2]
            break;
        end
    end

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Sapper_SpikeShooter(skill)
    local pc = GetSkillOwner(skill);
    local value = 100
    local zornhauSkill = GetSkill(pc, 'Sapper_SpikeShooter');
    if zornhauSkill ~= nil then
        value = TryGetProp(zornhauSkill, "SkillFactor", 100)
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_DarkMeteor(skill)
    local pc = GetSkillOwner(skill)
    local value = math.max(GetExProp(pc, 'heal_dark_sphere_470_factor'), 100)
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_IceBolt_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 5
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Cryomancer_FrostPillar_Vibora_Icedrops(skill)
    local pc = GetSkillOwner(skill);
    local value = 100 
    local FrostPillarSkill = GetSkill(pc, 'Cryomancer_FrostPillar');
    if FrostPillarSkill ~= nil then
        value = TryGetProp(FrostPillarSkill, "SkillFactor", 100)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Bloodtransfusion_Ratio(skill)
    local pc = GetSkillOwner(skill);

    local jobRate = SCR_GET_JOB_RATIO_STAT(pc, "MSP");
    local jobMSP = 200 * jobRate;
    local lv = TryGetProp(pc, "Lv", 1);
    local stat = GetSumOfEquipItem(pc, "MNA", 1);
    if stat == nil then
        stat = 0;
    end
    
    local byLevel = math.floor(jobMSP + ((lv - 1) * 18 * jobRate));
    local byStat = math.floor(((stat * 0.005) + (math.floor(stat / 10) * 0.015)) * byLevel);                    
    byStat = math.floor(byStat / 15)
    local byItem = GetSumOfEquipItem(pc, 'MSP');
    if byItem == nil then
        byItem = 0;
    end
    
    local value = byItem + byStat; 
    if value < 0 then
        value = 0;
    end
	
    local totalHP = math.floor(value * 0.1 + 0.5);
    
    return totalHP
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Wrath(skill)
    local value = 0
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, "Barbarian_Warcry")
    if skl ~= nil then
        local sklLV = TryGetProp(skl, "Level", 1)
        value = sklLV * 906
    end

    return value
end



-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Lamapose_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 5 + skill.Level*0.5
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Lama_SR_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Lama_SR2_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 5
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SkillFactor_By_Other(skill, otherClassName)
    local pc = GetSkillOwner(skill);
    local sklclass = GetClass("Skill", otherClassName);
    local value = SyncFloor(sklclass.SklFactor * 10) * 0.1 + SyncFloor(sklclass.SklFactorByLevel * 10) * 0.1 * (skill.Level - 1)
    if IsInTOSHeroMap(pc) == true then
        return math.floor(value)
    end

    local reinfabil = sklclass.ReinforceAbility
    local abil = GetAbility(pc, reinfabil)-- 강화 특성
    if abil ~= nil and TryGetProp(sklclass, "ReinforceAbility") ~= 'None' then
        local abilLevel = TryGetProp(abil, "Level")
        local masterAddValue = 0
        if abilLevel == 100 then
            masterAddValue = 0.1
        end

        value = value * (1 + ((abilLevel * 0.005) + masterAddValue))

        local hidden_abil_cls = GetClass("HiddenAbility_Reinforce", sklclass.ClassName);
        if abilLevel >= 65 and hidden_abil_cls ~= nil then
        	local hidden_abil_name = TryGetProp(hidden_abil_cls, "HiddenReinforceAbil");
        	local hidden_abil = GetAbility(pc, hidden_abil_name);

        	if hidden_abil ~= nil then
        		local abil_level = TryGetProp(hidden_abil, "Level");
        		local add_factor = TryGetProp(hidden_abil_cls, "FactorByLevel", 0) * 0.01;
        		local add_value = 0;
        		if abil_level == 10 then
        			add_value = TryGetProp(hidden_abil_cls, "AddFactor", 0) * 0.01
        		end
                value = value * (1 + (abil_level * add_factor) + add_value);
        	end
        end
    end

    return math.floor(value)
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Strongfist_SkillFactor(skill)
    if TryGetProp(skill, "ClassName", "None") ~= "Lama_StrongfistHanginglegs" then
        local pc = GetSkillOwner(skill)
        skill = GetSkill(pc, "Lama_StrongfistHanginglegs")
    end
    local value = SCR_GET_SkillFactor_By_Other(skill, "Lama_Strongfist");

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Hanginglegs_SkillFactor(skill)
    if TryGetProp(skill, "ClassName", "None") ~= "Lama_StrongfistHanginglegs" then
        local pc = GetSkillOwner(skill)
        skill = GetSkill(pc, "Lama_StrongfistHanginglegs")
    end
    local value = SCR_GET_SkillFactor_By_Other(skill, "Lama_Hanginglegs");
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_StrongfistHanginglegs_SkillFactor(skill)
    if skill ~= nil then
        local pc = GetSkillOwner(skill);
        local nFist = GetExProp(pc,"LamaFistCnt");
        local nKick = GetExProp(pc,"LamaKickCnt");
        if nFist == 3 and nKick == 1 then
            return SCR_GET_SkillFactor_By_Other(skill, "Lama_Strongfist");
        elseif nFist == 1 and nKick == 3 then
            return SCR_GET_SkillFactor_By_Other(skill, "Lama_Hanginglegs");
        end
    end
    return 0;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Pointkick_SkillFactor(skill)
    if TryGetProp(skill, "ClassName", "None") ~= "Lama_PointkickEarthshock" then
        local pc = GetSkillOwner(skill)
        skill = GetSkill(pc, "Lama_PointkickEarthshock")
    end
    local value = SCR_GET_SkillFactor_By_Other(skill, "Lama_Pointkick");

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Earthshock_SkillFactor(skill)
    if TryGetProp(skill, "ClassName", "None") ~= "Lama_PointkickEarthshock" then
        local pc = GetSkillOwner(skill)
        skill = GetSkill(pc, "Lama_PointkickEarthshock")
    end
    local value = SCR_GET_SkillFactor_By_Other(skill, "Lama_Earthshock");

    return value
end
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PointkickEarthshock_SkillFactor(skill)
    if skill ~= nil then
        local pc = GetSkillOwner(skill);
        local nFist = GetExProp(pc,"LamaFistCnt");
        local nKick = GetExProp(pc,"LamaKickCnt");
        if nFist == 3 and nKick == 2 then
            return SCR_GET_SkillFactor_By_Other(skill, "Lama_Earthshock");
        elseif nFist == 2 and nKick == 3 then
            return SCR_GET_SkillFactor_By_Other(skill, "Lama_Pointkick");
        end
    end
    return 0;
end
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Flyingkick_SkillFactor(skill)
    if TryGetProp(skill, "ClassName", "None") ~= "Lama_FlyingkickSuddenkick" then
        local pc = GetSkillOwner(skill)
        skill = GetSkill(pc, "Lama_FlyingkickSuddenkick")
    end
    local value = SCR_GET_SkillFactor_By_Other(skill, "Lama_Flyingkick");

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Suddenkick_SkillFactor(skill)
    if TryGetProp(skill, "ClassName", "None") ~= "Lama_FlyingkickSuddenkick" then
        local pc = GetSkillOwner(skill)
        skill = GetSkill(pc, "Lama_FlyingkickSuddenkick")
    end
    local value = SCR_GET_SkillFactor_By_Other(skill, "Lama_Suddenkick");

    return value
end
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FlyingkickSuddenkick_SkillFactor(skill)
    if skill ~= nil then
        local pc = GetSkillOwner(skill);
        local nFist = GetExProp(pc,"LamaFistCnt");
        local nKick = GetExProp(pc,"LamaKickCnt");
        if nFist == 4 and nKick == 2 then
            return SCR_GET_SkillFactor_By_Other(skill, "Lama_Flyingkick");
        elseif nFist == 2 and nKick == 4 then
            return SCR_GET_SkillFactor_By_Other(skill, "Lama_Suddenkick");
        end
    end
    return 0;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Anagrama_Time(skill)
    return 15
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Anagrama_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FlameRadiation_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = 5
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value - 2) ^ 0.5)) + math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FireCharm_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = 10
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value - 2) ^ 0.5)) + math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FireCharm_Time(skill)
    local value = 13
    return value
end

-- done , 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_KaguraDance_Ratio3(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value - 2) ^ 0.5)) + math.min(2, value)
    end

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RevengedSevenfold_Ratio2(skill)
    local value = 7
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
        value = 1
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_MoraleBanner_Ratio(skill)
    local value = 3 + skill.Level * 0.5
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_VitalityBanner_Ratio(skill)
    local value = skill.Level * 0.5
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_VitalityBanner_Time(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
        value = 5
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RevengeBanner_Ratio(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Retribution_Ratio(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Retribution_Residue(skill)
    local value = 100
    local pc = GetSkillOwner(skill)
    local retributionSkl = GetSkill(pc, 'Templer_Retribution')
    if retributionSkl ~= nil then
        value = math.floor(TryGetProp(retributionSkl, 'SkillFactor', 100) * 0.1)
    end
    return value
end


-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_JaguarStance_Ratio(skill)
    local value = 5 + skill.Level * 0.5
    local pc = GetSkillOwner(skill)
    if GetExProp(pc, 'ITEM_VIBORA_LawOfTheJungle') > 0 then
        value = value * 3
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_JaguarStance_Ratio2(skill)
    local value = math.ceil((skill.Level - 1) / 2)
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_WildRush_Ratio(skill)
    local value = 5
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TargetOfHunt_Time(skill)
    return 10
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_TargetOfHunt_Ratio(skill)
    local value = 3
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_WildHowling_Ratio(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_WildThorn_Ratio(skill)
    local value = 1
    local pc = GetSkillOwner(skill)
    if IsBuffApplied(pc, 'JaguarStance_Buff') == 'YES' then
        value = 5
    end
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_WildClaw_Ratio(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_AdaptabilityOfWildness_Time(skill)
    local value = 5
    local pc = GetSkillOwner(skill)
    local abilJaguar14 = GetAbility(pc, 'Jaguar14')
    if abilJaguar14 ~= nil and TryGetProp(abilJaguar14, 'ActiveState', 0 ) == 1 then
        value = value + 5
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_AdaptabilityOfWildness_Ratio(skill)
    local value = 2.5 + TryGetProp(skill, 'Level', 0) * 2.5
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, 'Jaguar14')
    if abil ~= nil and TryGetProp(abil, 'ActiveState', 0) == 1 then
        value = math.floor(value * 7.5) * 0.1
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_JaguarStance(skill)
    local value = 100
    local pc = GetSkillOwner(skill)
    local jaguarStance = GetSkill(pc, 'Jaguar_JaguarStance')
    if jaguarStance ~= nil then
        value = jaguarStance.SkillFactor
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_LegHoldTrap_Ratio(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Annihilation(skill)
    local value = 100
    local pc = GetSkillOwner(skill)
    local detonateTraps = GetSkill(pc, 'Sapper_DetonateTraps')
    if detonateTraps ~= nil then
        value = TryGetProp(detonateTraps, 'SkillFactor', 100) * 0.1
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Sapper_Vibora_Ratio(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_Bolas_Time(skill)
    return 5
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Bolas_Ratio(skill)
    local value = 8
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_BleedingPierce_Time(skill)
    return 10
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BleedingPierce_Ratio(skill)
    local value = 8
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_BleedingPierce_Atk(skill)
    local value = 100
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, 'Hunter_BleedingPierce')
    if skl ~= nil then
        value = math.floor(TryGetProp(skl, 'SkillFactor', 100)) * 0.5
    else
        local cls = GetClass('Skill', 'Hunter_BleedingPierce')
        if cls ~= nil then
            value = math.floor(TryGetProp(cls, 'SklFactor', 100) + TryGetProp(cls, 'SklFactorByLevel', 0)) * 0.5
        end
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_BleedingPierce_DOT(skill)
    local value = 100
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, 'Hunter_BleedingPierce')
    if skl ~= nil then
        value = math.floor(TryGetProp(skl, 'SkillFactor', 100)) * 0.1
    else
        local cls = GetClass('Skill', 'Hunter_BleedingPierce')
        if cls ~= nil then
            value = math.floor(TryGetProp(cls, 'SklFactor', 100) + TryGetProp(cls, 'SklFactorByLevel', 0)) * 0.1
        end
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Brawl_Ratio(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PetAttack_Ratio(skill)
    local value = 5
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CommonRecovery_Bufftime(skill)
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
        return 7
    end

    return 1
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_CommonRecovery_Ratio(skill)
    local level = skill.Level

    if level == 1 then
        return 1000
    elseif level == 2 then
        return 2000
    else
        return 4000
    end
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_WildTigerSpear_SkillFactor(skill)
    if skill ~= nil then
        local pc = GetSkillOwner(skill);
        local stance = GetExProp(pc, "SPEARMASTER_STANCE");
        if stance == 1 then -- 속
            return SCR_GET_WildTigerSpear_Aries_SkillFactor(skill);
        elseif stance == 2 then -- 광
            return SCR_GET_WildTigerSpear_Slash_SkillFactor(skill);
        end
    end
    return 0;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_WildTigerSpear_Aries_SkillFactor(skill)
    local pc = GetSkillOwner(skill);
    if TryGetProp(skill, 'ClassName', 'None') ~= 'SpearMaster_WildTigerSpear' then
        skill = GetSkill(pc, 'SpearMaster_WildTigerSpear');
    end

    local value = SCR_GET_SkillFactor_By_Other(skill, 'SpearMaster_WildTigerSpear_Aries');
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_WildTigerSpear_Slash_SkillFactor(skill)
    local pc = GetSkillOwner(skill);
    if TryGetProp(skill, 'ClassName', 'None') ~= 'SpearMaster_WildTigerSpear' then
        skill = GetSkill(pc, 'SpearMaster_WildTigerSpear');
    end

    local value = SCR_GET_SkillFactor_By_Other(skill, 'SpearMaster_WildTigerSpear_Slash');
    local abil = GetAbility(pc, 'SpearMaster6');
    if abil ~= nil and TryGetProp(abil, 'ActiveState', 0) == 1 then
        value = value * 0.6;
    end
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_WildTiger_Aries_DOT_SkillFactor(skill)
    local value = 100
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, 'SpearMaster_WildTigerSpear');
    if skl ~= nil then
        value = TryGetProp(skl, 'SkillFactor', 100) * 0.4
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_WildTiger_Slash_DOT_SkillFactor(skill)
    local value = 100
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, 'SpearMaster_WildTigerSpear');
    if skl ~= nil then
        value = TryGetProp(skl, 'SkillFactor', 100) * 0.2
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RushSpear_SkillFactor(skill)
    if skill ~= nil then
        local pc = GetSkillOwner(skill);
        local stance = GetExProp(pc, "SPEARMASTER_STANCE");
        if stance == 1 then -- 속
            return SCR_GET_RushSpear_Aries_SkillFactor(skill);
        elseif stance == 2 then -- 광
            return SCR_GET_RushSpear_Slash_SkillFactor(skill);
        end
    end
    return 0;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RushSpear_Aries_SkillFactor(skill)
    if TryGetProp(skill, 'ClassName', 'None') ~= 'SpearMaster_RushSpear' then
        local pc = GetSkillOwner(skill)
        skill = GetSkill(pc, 'SpearMaster_RushSpear')
    end
    local value = SCR_GET_SkillFactor_By_Other(skill, 'SpearMaster_RushSpear_Aries')
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RushSpear_Slash_SkillFactor(skill)
    local pc = GetSkillOwner(skill);
    if TryGetProp(skill, 'ClassName', 'None') ~= 'SpearMaster_RushSpear' then
        skill = GetSkill(pc, 'SpearMaster_RushSpear');
    end
    
    local value = SCR_GET_SkillFactor_By_Other(skill, 'SpearMaster_RushSpear_Slash')
    local abil = GetAbility(pc, 'SpearMaster8');
    if abil ~= nil and TryGetProp(abil, 'ActiveState', 0) == 1 then
        value = value * 0.8
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FlyingSerpentFall_SkillFactor(skill)
    if skill ~= nil then
        local pc = GetSkillOwner(skill);
        local stance = GetExProp(pc, "SPEARMASTER_STANCE");
        if stance == 1 then -- 속
            return SCR_GET_FlyingSerpentFall_Aries_SkillFactor(skill);
        elseif stance == 2 then -- 광
            return SCR_GET_FlyingSerpentFall_Slash_SkillFactor(skill);
        end
    end
    return 0;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FlyingSerpentFall_Aries_SkillFactor(skill)
    if TryGetProp(skill, 'ClassName', 'None') ~= 'SpearMaster_FlyingSerpentFall' then
        local pc = GetSkillOwner(skill)
        skill = GetSkill(pc, 'SpearMaster_FlyingSerpentFall')
    end
    local value = SCR_GET_SkillFactor_By_Other(skill, 'SpearMaster_FlyingSerpentFall_Aries')

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FlyingSerpentFall_Slash_SkillFactor(skill)
    if TryGetProp(skill, 'ClassName', 'None') ~= 'SpearMaster_FlyingSerpentFall' then
        local pc = GetSkillOwner(skill)
        skill = GetSkill(pc, 'SpearMaster_FlyingSerpentFall')
    end
    local value = SCR_GET_SkillFactor_By_Other(skill, 'SpearMaster_FlyingSerpentFall_Slash')

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_UniqueSpearDance_SkillFactor(skill)
    if skill ~= nil then
        local pc = GetSkillOwner(skill);
        local stance = GetExProp(pc, "SPEARMASTER_STANCE");
        if stance == 1 then -- 속
            return SCR_GET_UniqueSpearDance_Aries_SkillFactor(skill);
        elseif stance == 2 then -- 광
            return SCR_GET_UniqueSpearDance_Slash_SkillFactor(skill);
        end
    end
    return 0;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_UniqueSpearDance_Aries_SkillFactor(skill)
    if TryGetProp(skill, 'ClassName', 'None') ~= 'SpearMaster_UniqueSpearDance' then
        local pc = GetSkillOwner(skill)
        skill = GetSkill(pc, 'SpearMaster_UniqueSpearDance')
    end
    local value = SCR_GET_SkillFactor_By_Other(skill, 'SpearMaster_UniqueSpearDance_Aries')

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_UniqueSpearDance_Slash_SkillFactor(skill)
    if TryGetProp(skill, 'ClassName', 'None') ~= 'SpearMaster_UniqueSpearDance' then
        local pc = GetSkillOwner(skill)
        skill = GetSkill(pc, 'SpearMaster_UniqueSpearDance')
    end
    local value = SCR_GET_SkillFactor_By_Other(skill, 'SpearMaster_UniqueSpearDance_Slash')

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Hierophany_Time(skill)
    local value = 12

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Hierophany_Ratio(skill)
    local lv = TryGetProp(skill, 'Level', 0)
    local value = 25 + lv
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, 'SpearMaster19')
    if abil ~= nil and TryGetProp(abil, 'ActiveState', 0) == 1 then
        value = value * 0.5
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Hierophany_Ratio2(skill)
    local lv = TryGetProp(skill, 'Level', 0)
    local value = 25 + lv
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, 'SpearMaster19')
    if abil ~= nil and TryGetProp(abil, 'ActiveState', 0) == 1 then
        value = value * 0.5
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_WildTigerSpear_Ratio(skill)
    local value = 0;
    if skill ~= nil then
        local pc = GetSkillOwner(skill);
        if pc ~= nil then
            local stance = GetExProp(pc, "SPEARMASTER_STANCE");
            if stance == 1 then
                value = SCR_GET_WildTigerSpear_Aries_Ratio(skill);
            elseif stance == 2 then
                value = SCR_GET_WildTigerSpear_Slash_Ratio(skill);
            end
        end
    end
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_WildTigerSpear_Aries_Ratio(skill)
    local value = 5
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_WildTigerSpear_Slash_Ratio(skill)
    local value = 15
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RushSpear_Ratio(skill)
    local value = 0;
    if skill ~= nil then
        local pc = GetSkillOwner(skill);
        if pc ~= nil then
            local stance = GetExProp(pc, "SPEARMASTER_STANCE");
            if stance == 1 then
                value = SCR_GET_RushSpear_Aries_Ratio(skill);
            elseif stance == 2 then
                value = SCR_GET_RushSpear_Slash_Ratio(skill);
            end
        end
    end
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RushSpear_Ratio2(skill)
    local value = 0;
    if skill ~= nil then
        local pc = GetSkillOwner(skill);
        if pc ~= nil then
            local stance = GetExProp(pc, "SPEARMASTER_STANCE");
            if stance == 1 then
                value = SCR_GET_RushSpear_Aries_Ratio2(skill);
            elseif stance == 2 then
                value = 0;
            end
        end
    end
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RushSpear_Aries_Ratio(skill)
    local value = 5
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RushSpear_Aries_Ratio2(skill)
    local value = 50
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RushSpear_Slash_Ratio(skill)
    local value = 15
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FlyingSerpentFall_Ratio(skill)
    local value = 0;
    if skill ~= nil then
        local pc = GetSkillOwner(skill);
        if pc ~= nil then
            local stance = GetExProp(pc, "SPEARMASTER_STANCE");
            if stance == 1 then
                value = SCR_GET_FlyingSerpentFall_Aries_Ratio(skill);
            elseif stance == 2 then
                value = SCR_GET_FlyingSerpentFall_Slash_Ratio(skill);
            end
        end
    end
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FlyingSerpentFall_Aries_Ratio(skill)
    local value = 5
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FlyingSerpentFall_Slash_Ratio(skill)
    local value = 15
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_UniqueSpearDance_Ratio(skill)
    local value = 0;
    if skill ~= nil then
        local pc = GetSkillOwner(skill);
        if pc ~= nil then
            local stance = GetExProp(pc, "SPEARMASTER_STANCE");
            if stance == 1 then
                value = SCR_GET_UniqueSpearDance_Aries_Ratio(skill);
            elseif stance == 2 then
                value = SCR_GET_UniqueSpearDance_Slash_Ratio(skill);
            end
        end
    end
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_UniqueSpearDance_Aries_Ratio(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_UniqueSpearDance_Slash_Ratio(skill)
    local value = 20
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_SwiftMove(skill)
    local value = SCR_GET_SKL_COOLDOWN_ADD_LEVEL_SWIFTMOVE(skill)
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FlameTurret_Ratio(skill)
    local value = 15
    local pc = GetSkillOwner(skill)
    local abilEngineer21 = GetAbility(pc, 'Engineer21')

    if abilEngineer21 ~= nil and TryGetProp(abilEngineer21, 'ActiveState', 0 ) == 1 then
        value = 10
    end
    if GetExProp(pc, 'ITEM_VIBORA_MaxPower') > 0 then
       value = value * 1.2
    end

    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FlameTurret_Ratio2(skill)
    local pc = GetSkillOwner(skill)
    local value = 15
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FrozenTurret_Ratio(skill)
    local value = 15
    local pc = GetSkillOwner(skill)
    local abilEngineer23 = GetAbility(pc, 'Engineer23')
    if abilEngineer23 ~= nil and TryGetProp(abilEngineer23, 'ActiveState', 0 ) == 1 then
        value = 10
    end
    if GetExProp(pc, 'ITEM_VIBORA_MaxPower') > 0 then
        value = value * 1.2
     end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_FrozenTurret_Ratio2(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ArrowTurret_Ratio(skill)
    local value = 15
    local pc = GetSkillOwner(skill)
    local abilEngineer24 = GetAbility(pc, 'Engineer24')
    if abilEngineer24 ~= nil and TryGetProp(abilEngineer24, 'ActiveState', 0 ) == 1 then
        value = 10
    end
    if GetExProp(pc, 'ITEM_VIBORA_MaxPower') > 0 then
        value = value * 1.2
    end
    
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ArrowTurret_Ratio2(skill)
    local value = 1
    local pc = GetSkillOwner(skill)
    local abilEngineer24 = GetAbility(pc, 'Engineer24')
    if abilEngineer24 ~= nil and TryGetProp(abilEngineer24, 'ActiveState', 0 ) == 1 then
        value = 15
        if IsPVPField(pc) == 1 and value > 2 then
            value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
        end
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ArrowTurret_Ratio3(skill)
    local value = 0.5
    local pc = GetSkillOwner(skill)
    local abilEngineer24 = GetAbility(pc, 'Engineer24')
    if abilEngineer24 ~= nil and TryGetProp(abilEngineer24, 'ActiveState', 0 ) == 1 then
        value = 1
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_LightningTurret_Ratio(skill)
    local value = 15
    local pc = GetSkillOwner(skill)
    if GetExProp(pc, 'ITEM_VIBORA_MaxPower') > 0 then
        value = value * 1.2
    end
   
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_LightningTurret_Ratio2(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_LightningTurret_Ratio3(skill)
    local pc = GetSkillOwner(skill)
    local value = 1
    local skill_lv = skill.Level;
    value = value * skill_lv
    local abilEngineer17 = GetAbility(pc, 'Engineer17')
    if abilEngineer17 ~= nil and TryGetProp(abilEngineer17, 'ActiveState', 0 ) == 1 then
        value = 100
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BuffTurret_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = 2.5 -- % 수치
    local skill_lv = skill.Level;
    value = value + 0.5* skill_lv
    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    value = math.min(15,value) -- 최대 15%로 제한
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BuffTurret_Ratio2(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BuffTurret_Ratio3(skill)
    local pc = GetSkillOwner(skill)
    local value = 15
    if GetExProp(pc, 'ITEM_VIBORA_MaxPower') > 0 then
        value = value * 1.2
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Repairkit_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = 0
    local limit = 2500
    local factorByLevel = 500
    local lv = skill.Level
    local value = factorByLevel * lv
    if value > limit then value = limit end
    value = value * 0.001
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_KingMechaV(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = TryGetProp(skill, "BasicCoolDown", 0)
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    

    if GetExProp(pc, "ITEM_VIBORA_MaxPower") > 0 then
        basicCoolDown = basicCoolDown - 10000;
    end
 
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)

    return math.floor(basicCoolDown);
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_KingMechaV_Ratio(skill)
    local value = 15
    local pc = GetSkillOwner(skill)
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_KingMechaV_Flame(skill)
    local value = 100
    local pc = GetSkillOwner(skill)
    local KingMechaVSkl = GetSkill(pc, 'Engineer_KingMechaV')

    -- 디폴트 스킬 데미지의 총량에 50%데미지를 8초에 걸쳐 입힌다.
    if KingMechaVSkl ~= nil then
        value = math.floor(TryGetProp(KingMechaVSkl, 'SkillFactor', 100) * 3 * 0.125) 
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_KingMechaV_Frozen(skill)
    local value = 100
    local pc = GetSkillOwner(skill)
    local KingMechaVSkl = GetSkill(pc, 'Engineer_KingMechaV')

    -- 디폴트 sklfactor에 25%의 데미지를 가한다.
    if KingMechaVSkl ~= nil then
        value = math.floor(TryGetProp(KingMechaVSkl, 'SkillFactor', 100) * 0.25) 
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SpendSP_Common_MovingForward(skill)
    local pc = GetSkillOwner(skill)
    local msp = TryGetProp(pc, 'MSP', 0)
    local sp = math.floor(msp * 0.07)
    return sp
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SpendSP_Common_Activate_Cupole_Skill(skill)
    local pc = GetSkillOwner(skill)
    local msp = TryGetProp(pc, 'MSP', 0)
    local sp = math.floor(msp * 0.07)
    return 0
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Common_MovingForward(skill)
    local basicCoolDown = TryGetProp(skill, "BasicCoolDown", 0)
    local pc = GetSkillOwner(skill)
    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 or IsJoinColonyWarMap(pc) == 1 then
        basicCoolDown = basicCoolDown * 2
    end

    return basicCoolDown
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Kupole_Active_Skill(skill)
    local basicCoolDown = TryGetProp(skill, "BasicCoolDown", 0)
    local pc = GetSkillOwner(skill)
    rank = SCR_GET_Kupole_Rank(skill)

    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 or IsJoinColonyWarMap(pc) == 1 then
        basicCoolDown = basicCoolDown * 2
    end

    return basicCoolDown - rank * 5000;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Common_Activate_Cupole_Skill(skill)
    local basicCoolDown = TryGetProp(skill, "BasicCoolDown", 0)
    local pc = GetSkillOwner(skill)
    if IsPVPServer(pc) == 1 or IsPVPField(pc) == 1 or IsJoinColonyWarMap(pc) == 1 then
        basicCoolDown = basicCoolDown * 2
    end
    return basicCoolDown
end


-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Illusionist_Cloaking_Time(skill)
    local pc = GetSkillOwner(skill)
    local value = 5
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Illusionist_IllusionSword_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 15;    
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Illusionist_IllusionBlast_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = 15; 
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Illusion_Bolt(skill)
    local value = 100
    local pc = GetSkillOwner(skill)
    local MagicalIllusion = GetSkill(pc, 'Illusionist_MagicalIllusion')

    if MagicalIllusion ~= nil then
        value = math.floor(TryGetProp(MagicalIllusion, 'SkillFactor', 100)) 
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Illusion_Slash(skill)
    local value = 100
    local pc = GetSkillOwner(skill)
    local MagicalIllusion = GetSkill(pc, 'Illusionist_MagicalIllusion')

    if MagicalIllusion ~= nil then
        value = math.floor(TryGetProp(MagicalIllusion, 'SkillFactor', 100) * 1.2)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Illusion_Swing(skill)
    local value = 100
    local pc = GetSkillOwner(skill)
    local MagicalIllusion = GetSkill(pc, 'Illusionist_MagicalIllusion')

    if MagicalIllusion ~= nil then
        value = math.floor(TryGetProp(MagicalIllusion, 'SkillFactor', 100)) * 2.0
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Illusionist_Flood_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 15;    
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Illusionist_Nightmare_Ratio(skill)
    local pc = GetSkillOwner(skill)
    local value = 15; 
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Illusionist_IllusionArmor_Illusionist29(skill)
    local pc = GetSkillOwner(skill)
    local value = 7; 
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Illusionist_IllusionArmor_DeActivate_Time(skill)
    local pc = GetSkillOwner(skill)
    local value = 18000; 
    local abil_Illusionist29 = GetAbility(pc, 'Illusionist29')
    local abil_Illusionist30 = GetAbility(pc, 'Illusionist30')
    if abil_Illusionist29 ~= nil and TryGetProp(abil_Illusionist29, 'ActiveState', 0 ) == 1 then
        value = 25000; 
    end

    if abil_Illusionist30 ~= nil and TryGetProp(abil_Illusionist30, 'ActiveState', 0 ) == 1 then
        value = 25000; 
    end

    local subVal = 1000;
    local lv = TryGetProp(skill, "Level", 1)
    if lv > 10 then lv = 10 end
    value = value - subVal * lv
    value = value * 0.001
    value = math.floor(value)
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Illusionist_IllusionArmor_Illusionist30(skill)
    local pc = GetSkillOwner(skill)
    local value = 10000; 
    
    return value;
end


-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Illusionist_Flood_Ratio_Time(skill)
    local value = 900; 
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Illusionist_IllusionBlast_Ratio_Time(skill)
    local value = 400; 
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Illusionist_Nightmare_Ratio_Time(skill)
    local value = 1000; 
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Illusionist_Nightmare_Ratio2(skill)
    local value = 12; 
    local pc = GetSkillOwner(skill)
    local abil_Illusionist28 = GetAbility(pc, 'Illusionist28')
    if abil_Illusionist28 ~= nil and TryGetProp(abil_Illusionist28, 'ActiveState', 0 ) == 1 then
        value = 5 
    end
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Reinforce_Ability_Flood(skill)
    local value = SCR_Get_SkillFactor_Reinforce_Ability(skill)
    local pc = GetSkillOwner(skill)
    
    local abil_Illusionist25 = GetAbility(pc, 'Illusionist25')
    if abil_Illusionist25 ~= nil and TryGetProp(abil_Illusionist25, 'ActiveState', 0 ) == 1 then
        value = value * 0.3 
    end
    value = math.floor(value)
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Reinforce_Ability_IllusionBlast(skill)
    local value = SCR_Get_SkillFactor_Reinforce_Ability(skill)
    local pc = GetSkillOwner(skill)
    local Illusionist22_factor = GetExProp(pc,"IllusionBlast_Illusionist22")
    local Illusionist23_factor = GetExProp(pc,"IllusionBlast_Illusionist23")
    local mulfactor = 1
    if Illusionist22_factor ~= 0 then
        mulfactor = mulfactor + (Illusionist22_factor * 0.01)
    end
    
    if Illusionist23_factor ~= 0 then
        mulfactor = mulfactor + (Illusionist23_factor * 0.01)
    end

    value = value * mulfactor
    value = math.floor(value)
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Reinforce_Ability_Nightmare(skill)
    local value = SCR_Get_SkillFactor_Reinforce_Ability(skill)
    local pc = GetSkillOwner(skill)
    local abil_Illusionist28 = GetAbility(pc, 'Illusionist28')
    if abil_Illusionist28 ~= nil and TryGetProp(abil_Illusionist28, 'ActiveState', 0 ) == 1 then
        value = value * 2.4 * 1.5
    end
    value = math.floor(value)
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_IllusionSword_Illusion31(skill)
    local value = 100
    local pc = GetSkillOwner(skill)
    local IllusionSword = GetSkill(pc, 'Illusionist_IllusionSword')

    if IllusionSword ~= nil then
        value = math.floor(TryGetProp(IllusionSword, 'SkillFactor', 100) * 0.1 ) 
    end
    return value
end
-------------------------- 폰티펙스(Pontifex)
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Missa_Ratio(skill)
    local value = 1 + (skill.Level * TryGetProp(skill, 'SklFactor', 0)) * 0.01
    return value
end
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SpendSP_Missa(skill)
    local value = SCR_Get_SpendSP_Magic(skill)
    local pc = GetSkillOwner(skill);

    if pc == nil then
        return math.floor(value);
    end
    
    local over = GetBuffOver(pc, 'Missa_Buff')    
    over = math.min(over, 2)
    local multiple = 1 + (over * 0.5)        
    multiple = math.max(multiple, 1)    
    return value * multiple
end
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function GET_Missa_buff_hp_point(skill)
    local pc = GetSkillOwner(skill)
    local value = TryGetProp(pc, 'MHP', 0) * SCR_GET_Missa_Ratio(skill) * 0.01
    return math.floor(value)
end
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_EvilBurn_Target_Count(skill)
    local pc = GetSkillOwner(skill);
    local value = 10;    
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SpendSP_BySinBuff(skill)
    local value = SCR_Get_SpendSP_Magic(skill)    
    local pc = GetSkillOwner(skill);

    if pc == nil then
        return math.floor(value);
    end

    local over = GetBuffOver(pc, 'Sin_Buff')
    over = math.min(over, 5)    
    local multiple = 1.5^over
    return value * multiple
end

function SCR_GET_Gospel_Ratio(skill)
    -- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
    local level = TryGetProp(skill, 'Level', 0)    
    local ratio = 1
    local pc = GetSkillOwner(skill)    
    local abil = GetAbility(pc, 'Pontifex51');
    if abil ~= nil and 1 == TryGetProp(abil, "ActiveState", 0) then
        -- 특성이 활성화 되었다면 0.2
        ratio = 0.2
    end

    local value = 5 + (level * TryGetProp(skill, 'SklFactor', 0) * 0.01)
    value = value * ratio
    return value
end
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Matador_CorridaFinale_Hidden(skill)
    local pc = GetSkillOwner(skill)

    local s = GetSkill(pc, 'Matador_CorridaFinale')
    local factor = 100
    if s ~= nil then
        factor = s.SkillFactor
    end
    
    return factor
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BadGuy_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 0
    if pc ~= nil then 
        local lv = TryGetProp(skill, 'Level', 0)   
        value = 5 * lv;
        value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BadGuy_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 0
    if pc ~= nil then 
        local lv = TryGetProp(skill, 'Level', 0)   
        value = 0.2 * lv;
    end
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BadGuy_Ratio3(skill)
    local pc = GetSkillOwner(skill);
    local value = SCR_GET_BadGuy_Ratio2(skill)
    value = value * 5
    return value
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Revenged_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 12;    
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Equilibrium_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 12;    
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_DeadlyFire_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 15;    
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_LastManStanding_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 15;    
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Violent_ConsumeRatio(skill)
    local pc = GetSkillOwner(skill);
    local value = 10;
    if skill == nil then return value end
    local clsName = TryGetProp(skill, 'ClassName', 'None')
    if clsName == "Desperado_Equilibrium" then
        value = 1
    elseif clsName == "Desperado_Revenged" then
        value = 2
    elseif clsName == "Desperado_DeadlyFire" then
        value = 3
    elseif clsName == "Desperado_LastManStanding" then
        value = 6
    end
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_RussianRoulette_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 1
    local Desperado24 = GetExProp(pc,"Desperado24")
    if pc ~= nil  then 
        local lv = TryGetProp(skill, 'Level', 0)   
        local mulfactor = 1
        if Desperado24 == 1 then
            mulfactor = 2
        end
        value = 2 * lv * mulfactor;
        value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)
    end

    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_RussianRoulette(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)

    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end

-- [아츠] 졸리 로저: 지원 포격
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Corsair_Bombardments(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, 'Corsair_HexenDropper')

    if skl == nil then
        skl = skill
    end
    local value = SCR_Get_SkillFactor_Reinforce_Ability(skl)
    value = (value * 7) * 0.5 
    value = math.floor(value)    
    return value
end

-- [아츠] 최루: 살상 가스
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Rogue_Lachrymator(skill)
    local pc = GetSkillOwner(skill)
    local skl = GetSkill(pc, 'Rogue_Backstab')

    if skl == nil then
        skl = skill
    end
    local value = SCR_Get_SkillFactor_Reinforce_Ability(skl)
    value = (value * 2) * 0.5
    value = math.floor(value)    
    return value
end
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Vulture_Attack(skill)
    local pc = GetSkillOwner(skill)
    local value = SCR_Get_SkillFactor_Reinforce_Ability(skill)
    value = math.floor(value)
    local total = 0;
    local skillNames = {
        "Vulture_Decomposition_Archer", "Vulture_GravityField_Archer", "Vulture_Diffusion_Archer",
        "Vulture_Decomposition_Wizard", "Vulture_GravityField_Wizard", "Vulture_Diffusion_Wizard",
        "Vulture_Decomposition_Scout", "Vulture_GravityField_Scout", "Vulture_Diffusion_Scout"
    }
    
    local total = 0
    for _, skillName in ipairs(skillNames) do
        local skl = GetSkill(pc, skillName)
        if skl then
            total = total + skl.Level
        end
    end
    
    return value + (total * 300)
end
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Reinforce_Ability_CombatProtocol(skill)
    local value = SCR_Get_SkillFactor_Reinforce_Ability(skill)
    value = math.floor(value)
    return value
end
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_Get_SkillFactor_Reinforce_Ability_Decomposition(skill)
    local value = SCR_Get_SkillFactor_Reinforce_Ability(skill)
    
    value = math.floor(value)
    return value
end
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Kupole_Rank(skill)
    local name = TryGetProp(skill, "ClassName", 0)
    local RankName = "KupoleRank"..name;
    local pc = GetSkillOwner(skill)
    local rank = GetExProp(pc, RankName);
    
    if IsServerSection() == 0 then    
        local cls = GET_REPRESENT_CUPOLE_INFO()
        local Group_ID = TryGetProp(cls, "Group_ID", "None")
        local sklCls = GetClassByStrProp2("cupole_skill", "Group_ID", Group_ID, "Skill_Type", "Active");
        local skillname = TryGetProp(sklCls, "Skill_Name", "None")
        if skill.ClassName == skillname then
            rank = GET_CUPOLE_RANK_BY_CLS(cls)
        end
    end
    
    return rank;
end

function SCR_GET_R_Kupole_Ratio(skill)
    local value = 600
    local kupoleRank = SCR_GET_Kupole_Rank(skill)
    
    value = value + (value * (0.1 * kupoleRank))
    
    return value
end

function SCR_GET_SR_Kupole_Ratio(skill)
    local value = 900
    local kupoleRank = SCR_GET_Kupole_Rank(skill)
    
    value = value + (value * (0.1 * kupoleRank))
    
    return value
end

-- TODO:DY
function SCR_Get_SkillFactor_Reinforce_Ability_CombatProtocol(skill)
    local pc = GetSkillOwner(skill)
    local value = SCR_Get_SkillFactor_Reinforce_Ability(skill)
    value = math.floor(value)
    return value
end

function SCR_GET_Decomposition_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 15;    
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value;
end
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Decomposition_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 15;    
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value;
end
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_GravityField_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 15;    
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value;
end
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Diffusion_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 15;    
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Vulture_Purification_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 15;    
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    
    return value;
end
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Vulture_Devastation_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 20;    
    if IsPVPField(pc) == 1 and value > 2 then
        value = math.floor((math.max(0, value-2)^0.5))+math.min(2, value)
    end
    return value;
end
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Vulture_Protocol_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 0
    if pc ~= nil then 
        local lv = TryGetProp(skill, 'Level', 0)   
        value = 1.5 * lv;
    end
    return value
end
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_Vulture_Protocol_Ratio2(skill)
    local pc = GetSkillOwner(skill);
    local value = 0
    if pc ~= nil then 
        local lv = TryGetProp(skill, 'Level', 0)   
        value = 1.0 * lv;
    end
    return value
end
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PurificationProtocol_Ratio(skill)
    local pc = GetSkillOwner(skill);
    local value = 0
    if pc ~= nil then 
        local lv = TryGetProp(skill, 'Level', 0)   
        value = 5 * lv;
    end
    return value
end
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_Purification(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = TryGetProp(skill, "BasicCoolDown", 0)
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    
    if GetExProp(pc, "ITEM_VIBORA_ParticleAccel_Lv4") > 0 then
        basicCoolDown = basicCoolDown - 1000;
    end
 
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)

    return math.floor(basicCoolDown);
end

function SCR_GET_Sledgehammer_Ratio(skill)
    local level = TryGetProp(skill, 'Level', 0)
    local value = 1 * level;

    value = value * SCR_REINFORCEABILITY_TOOLTIP(skill)

    return value
end
