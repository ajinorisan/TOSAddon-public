-- shared_grimmark.lua

function SCR_GRIMMARK_CHECK_USE_SKILL_C(actor, skl, buffName)
    local buff = actor:GetBuff():GetBuff("GrimReaper_Buff")
    if buff ~= nil then
        return 1;
    end
    
    return 0;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_SKL_COOLDOWN_GRIMMARK(skill)    
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)
    
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)

    if IsBuffApplied(pc, "GrimReaper_Buff") == "YES" then
        basicCoolDown = 400
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
function SCR_Get_SkillFactor_Grimmark_ChainOfThirst(skill)
    local pc = GetSkillOwner(skill)
    local value = SCR_Get_SkillFactor_Reinforce_Ability(skill)
    local abil = GetAbility(pc, "Grimmark8")
    if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        value = value * 0.75
    end

    return math.floor(value)
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ChainOfThirst_Ratio(skill)
    local value = 1
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, "Grimmark8")
    if abil ~= nil and TryGetProp(abil, "ActiveState", 0) == 1 then
        value = 10
    end
    
    value = GET_PVP_TARGET_COUNT(pc, value)
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_ExploitWeakness_Ratio(skill)
    local value = 20 + (TryGetProp(skill, "Level") * 2)
    if value > 34 then
        value = 34
    end

    return value;
end
-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_PiercingLeap_Ratio(skill)
    local value = 5
    local pc = GetSkillOwner(skill)
    if pc ~= nil then
        value = GET_PVP_TARGET_COUNT(pc, value)
    end
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_HamstringPin_Ratio(skill)
    local value = 5
    local pc = GetSkillOwner(skill)
    if pc ~= nil then
        value = GET_PVP_TARGET_COUNT(pc, value)
    end
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BloodspearPierce_Ratio(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    if pc ~= nil then
        value = GET_PVP_TARGET_COUNT(pc, value)
    end
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_BloodEruption_Ratio(skill)
    local value = 10
    local pc = GetSkillOwner(skill)
    if pc ~= nil then
        value = GET_PVP_TARGET_COUNT(pc, value)
    end
    
    return value;
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function SCR_GET_StakeOfTerminus_Ratio(skill)
    local value = 15
    local pc = GetSkillOwner(skill)
    if pc ~= nil then
        value = GET_PVP_TARGET_COUNT(pc, value)
    end
    
    return value;
end

function SCR_GET_HunterMark_Ratio(skill)
    local value = 1
    local pc = GetSkillOwner(skill)
    if pc ~= nil then
        local abil = GetAbility(pc, "Grimmark11")
        if abil ~= nil and TryGetProp(abil, "ActiveState", 0) ==  1 then
            value = GET_PVP_TARGET_COUNT(pc, 5)
        end
    end
    
    return value;
end