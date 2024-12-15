-- skill_conversion.lua


local skill_conversion_job_list =
{
    "SpearMaster","Lama"
}


local function CHECK_PLAYER_JOB_BY_SKILLJOB_S(self)
    if self ~= nil then
        local job_list = GetJobHistoryList(self);
        if job_list ~= nil then
            for i = 1, #job_list do
                local job_id = job_list[i];
                local job_cls = GetClassByType("Job", job_id);
                if job_cls ~= nil then
                    local job_name = TryGetProp(job_cls, "JobName", "None");
                    for i = 1, #skill_conversion_job_list do
                        if job_name == skill_conversion_job_list[i] then
                            return true, job_name;
                        end
                    end
                end
            end
        end
    end
    return false;
end

local function CHECK_PLAYER_JOB_BY_SKILLJOB_C()
    local session = session.GetMySession();
    local job_info = session:GetPCJobInfo();
    local job_cnt = job_info:GetJobCount();
    for i = 0, job_cnt - 1 do
        local job = job_info:GetJobInfoByIndex(i);
        if job ~= nil then
            local job_id = job.jobID;
            local job_cls = GetClassByType("Job", job_id);
            if job_cls ~= nil then
                local job_name = TryGetProp(job_cls, "JobName", "None");
                for i = 1, #skill_conversion_job_list do
                    if job_name == skill_conversion_job_list[i] then
                        return true, job_name;
                    end
                end
            end
        end
    end
    return false;
end

--get str by property
function get_skill_conversion_info_by_property(skill, num_arg, propname)
    local str = "None";
    if skill ~= nil then
        local cls_name = TryGetProp(skill, "ClassName", "None");
        local cls = GetClass("skill_conversion_info", cls_name);
        if cls ~= nil then
            local propStr = TryGetProp(cls, propname, "None");
            if propStr ~= "None" then
                local str_list = StringSplit(propStr, ";");
                if str_list ~= nil and #str_list > 0 then
                    str = str_list[num_arg];
                end
            end
        end    
    end
    return str;
end
--------------------------------


-- spear master
function get_spaer_master_skill_info(self, skill, propname)
    if IsServerSection() == 1 then
        if self ~= nil then
            local spearmaster_stance = GetExProp(self, "SPEARMASTER_STANCE");
            if spearmaster_stance == 0 then spearmaster_stance = 1; end
            return get_skill_conversion_info_by_property(skill, spearmaster_stance, propname);
        end
    else
        local my_pc = GetMyPCObject();
        if my_pc ~= nil then
            local spearmaster_stance = GetExProp(my_pc, "SPEARMASTER_STANCE");
            if spearmaster_stance == 0 then spearmaster_stance = 1; end
            return get_skill_conversion_info_by_property(skill, spearmaster_stance, propname);
        end
    end
    return "None";
end

--lama

function get_skill_conversion_lama_skill_info(self, skill, arg)
    local list = {
        Lama_StrongfistHanginglegs = { 3, 1},
        Lama_PointkickEarthshock = { 3, 2},
        Lama_FlyingkickSuddenkick = { 4, 2},
    }

    if IsServerSection() == 1 then
        if self ~= nil then
            local kickBuff = GetBuffByName(self, 'Lamakick_Buff');
            local fistBuff = GetBuffByName(self, 'Lamafist_Buff');

            local index = 1;

            if kickBuff~=nil and fistBuff~=nil then
                local kickOver = GetOver(kickBuff);
                local fistOver = GetOver(fistBuff);
                local skillName = skill.ClassName;

                if list[skillName][1] == fistOver and list[skillName][2] == kickOver then
                    index = 2;
                elseif list[skillName][1] == kickOver and list[skillName][2] == fistOver then
                    index = 3;
                end
            end

            return get_skill_conversion_info_by_property(skill, index, arg);
        end
    else

        local my_pc = GetMyPCObject();
		local kickBuff = info.GetBuffByName(session.GetMyHandle(), "Lamakick_Buff");
		local fistBuff = info.GetBuffByName(session.GetMyHandle(), "Lamafist_Buff");
        local index = 1;
        if kickBuff~=nil and fistBuff~=nil then
            local kickOver = kickBuff.over;
            local fistOver = fistBuff.over;
            local skillName = skill.ClassName;
            if list[skillName][1] == fistOver and list[skillName][2] == kickOver then
                index = 2;
            elseif list[skillName][1] == kickOver and list[skillName][2] == fistOver then
                index = 3;
            end
        end
        if my_pc ~= nil then
            return get_skill_conversion_info_by_property(skill, index, arg);
        end
    end
end


-- check common
function get_skill_conversion_info(self, skill, propname)
    local str = "None";
    if IsServerSection() == 1 then
        res, job_str = CHECK_PLAYER_JOB_BY_SKILLJOB_S(self);
        if res == true then
            if job_str == "SpearMaster" then
                str = get_spaer_master_skill_info(self, skill, propname);
            elseif job_str == "Lama" then
                str = get_skill_conversion_lama_skill_info(self,skill,propname);
            end
        end
    else
        res, job_str = CHECK_PLAYER_JOB_BY_SKILLJOB_C();
        if res == true then
            if job_str == "SpearMaster" then
                str = get_spaer_master_skill_info(nil, skill, propname);
            elseif job_str == "Lama" then
                str = get_skill_conversion_lama_skill_info(nil, skill, propname);
            end
        end
    end
    return str;
end
------


function is_skill_conversion(skill)
    if skill ~= nil then
        local class_name = TryGetProp(skill, "ClassName", "None");
        if class_name ~= "None" then
            local cls = GetClass("skill_conversion_info", class_name);
            if cls ~= nil then return true; end
        end
    end
    return false;
end


