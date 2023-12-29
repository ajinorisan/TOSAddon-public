-- shared_change_class_tree.lua

local function _SCR_GET_TREE_INFO_VEC(jobName)
    local treelist = {};    
    local clslist, cnt  = GetClassList("SkillTree");
    local index = 1;
	while 1 do
		local name = jobName .. "_" ..index;
		local cls = GetClassByNameFromList(clslist, name);
		if cls == nil then
			break;
        end
        treelist[#treelist+1] = cls
		index = index + 1;	
    end

    return treelist;
end

function SKILLABILITY_GET_ABILITY_GROUP_NAME(jobEngName)--Ability_Peltasta
    if jobEngName == "Common" then
        return "account_ability"; 
    end

    local abilGroupName = "Ability_"..jobEngName;
    return abilGroupName;
end


function GET_JOB_ENG_NAME(jobClsName)
    if jobClsName == "Common" then
        return "Common";
    end

    local jobCls = GetClass("Job", jobClsName);
    if jobCls == nil then
        return "None"; 
    end

    return jobCls.EngName;
end
function GET_INVESTED_SKILL_POINTS(pc, job_id)
    job_id = tonumber(job_id)
    local totalcnt = 0;

    local jobCls = GetClassByType('Job', job_id)
    local jobClsName = TryGetProp(jobCls, 'ClassName', 'None')
    local defHaveSkill = TryGetProp(jobCls, 'DefHaveSkill', 'None')
    local def_skill_list = StringSplit(defHaveSkill, '#')
  
    local list = _SCR_GET_TREE_INFO_VEC(jobClsName);    

    for _, cls in pairs(list) do
        local usedpts = 0
        local skl = GetSkill(pc, cls.SkillName)
        if table.find(def_skill_list, cls.SkillName) <= 0 and skl ~= nil then
            local level = TryGetProp(skl, 'Level', 0)
            if level > 0 then
                usedpts = level
            end
        end
        totalcnt = totalcnt+usedpts
    end   

    return totalcnt
end

function GET_JOB_TOTAL_SKILL_POINTS_INCLUDE_BONUS(pc, job_id)
    local totalcnt  = GET_INVESTED_SKILL_POINTS(pc, job_id)+ GetRemainSkillPts(pc, job_id)
    return totalcnt
end

function IS_USE_BONUS_SKILL_POINTS(pc, job_id)
    local totalcnt = GET_JOB_TOTAL_SKILL_POINTS_INCLUDE_BONUS(pc, job_id)
    local jobCls = GetClassByType('Job', job_id)
    local jobClsName = TryGetProp(jobCls, 'ClassName', 'None')
    local bonus = totalcnt - GetJobLevelByName(pc, jobClsName)
    if bonus > 0 then
        return true
    end
    return false
end
-- 저장을 위한 현재 스킬 정보 반환
function MAKE_SKILL_TREE_FORMAT(pc, job_id)
    job_id = tonumber(job_id)
    local jobCls = GetClassByType('Job', job_id)
    local jobClsName = TryGetProp(jobCls, 'ClassName', 'None')
    local defHaveSkill = TryGetProp(jobCls, 'DefHaveSkill', 'None')
    local def_skill_list = StringSplit(defHaveSkill, '#')
    local arglist = string.format("%d", job_id);

    local list = _SCR_GET_TREE_INFO_VEC(jobClsName);    

    for _, cls in pairs(list) do
        local usedpts = 0
        local skl = GetSkill(pc, cls.SkillName)
        if table.find(def_skill_list, cls.SkillName) <= 0 and skl ~= nil then
            local level = TryGetProp(skl, 'Level', 0)
            if level > 0 then
                usedpts = level
            end
        end
        arglist = string.format("%s/%d", arglist, usedpts)
    end    
    return arglist
end

-- 2006 0 0 0 15 5 5 5 0 0 10 5
function DECODE_SKILL_TREE_FORMAT(pc, arg_list)
    local ret = {}
    local token = StringSplit(arg_list, '/')
    local job_id = token[1]
    job_id = tonumber(job_id)

    local jobCls = GetClassByType('Job', job_id)
    local jobClsName = TryGetProp(jobCls, 'ClassName', 'None')
    local defHaveSkill = TryGetProp(jobCls, 'DefHaveSkill', 'None')
    local def_skill_list = StringSplit(defHaveSkill, '#')
    local arglist = string.format("%d", job_id);

    local list = _SCR_GET_TREE_INFO_VEC(jobClsName);    
    
    for i = 1, #list do
        local cls = list[i]
        ret[cls.SkillName] = tonumber(token[i + 1])
    end

    return ret
end

function MAKE_SKILL_INFO_SNAPSHOT_FORMAT(pc,job_id)
    local arglist = MAKE_SKILL_TREE_FORMAT(pc,job_id)
    return DECODE_SKILL_TREE_FORMAT(pc, arglist)
end

function MAKE_ABILITY_INFO_SNAPSHOT_FORMAT(pc,job_id)
    local arglist = MAKE_ABILITY_TREE_FORMAT(pc, job_id)
    return DECODE_ABILITY_TREE_FORMAT(pc, arglist)    
end


-- 저장을 위한 현재 특성 정보 반환
function MAKE_ABILITY_TREE_FORMAT(pc, job_id)
    job_id = tonumber(job_id)
    local jobCls = GetClassByType('Job', job_id)
    local jobClsName = TryGetProp(jobCls, 'ClassName', 'None')

    local jobEngName = GET_JOB_ENG_NAME(jobClsName);
    local abilGroupName = SKILLABILITY_GET_ABILITY_GROUP_NAME(jobEngName);
    
    local arg_list = abilGroupName

    if IsServerSection() == 1 then
        local abilList = GetAbilityNamesByJob(pc, jobClsName);
        if #abilList == 0 then
            return;
        end        
        
        for i = 1, #abilList do
            local abilName = abilList[i];
            if IsHiddenAbility(abilName)== false then                
                local abil = GetAbilityIESObject(pc, abilName);
                local abilLevel = TryGetProp(abil, 'Level', 0);
                if abilLevel > 0 then 
                    local cls = GetClass(abilGroupName, abilName);
                    if cls~=nil then 
                        arg_list = string.format('%s/%d/%d', arg_list, cls.ClassID, abilLevel)                
                    end
                end
            end
        end
        
        return arg_list
    else
        local abilList = GetAbilityNamesByJob(GetMyPCObject(), jobClsName)
        if #abilList == 0 then
            return;
        end        
        
        for i = 1, #abilList do
            local abilName = abilList[i];
            local abil = GetAbilityIESObject(pc, abilName);
            local abilLevel = TryGetProp(abil, 'Level', 0);
            if TryGetProp(abil, 'Hidden', 0) == 0 then
                if abilLevel > 0 then 
                    local cls = GetClass(abilGroupName, abilName);
                    if cls~=nil then 
                        arg_list = string.format('%s/%d/%d', arg_list, cls.ClassID, abilLevel)
                    end
                end
            end                
        end
        return arg_list
    end
end

-- -- Ability_Sorcerer 1 1 801 1 702 1
function DECODE_ABILITY_TREE_FORMAT(pc, arg_list)    
    local token = StringSplit(arg_list, '/')
    local abilGroupName = token[1]

    local ret = {}
    for i = 2, #token, 2 do
        local id = tonumber(token[i])
        local count = tonumber(token[i + 1])
        local abil_group_cls = GetClassByType(abilGroupName, id)
        local name = TryGetProp(abil_group_cls, 'ClassName', 'None')

        ret[name] = count
    end

    return ret
end

