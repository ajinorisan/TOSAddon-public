-- lib_rankreset.lua
local multiple_src = {}
local multiple_dest = {}
function SET_MULTIPLE_RANKROLLBACK_TARGETS(argList)
    if multiple_src~=nil then 
        for i=1,#multiple_src do
            multiple_src[i]=nil 
        end
       
    end
    if multiple_dest~=nil then 
        for i=1,#multiple_dest do
            multiple_dest[i]=nil 
        end
       
    end
    for i=1, #argList do 
        if i%2 == 0 then 
            table.insert(multiple_dest,argList[i])
        else
            table.insert(multiple_src,argList[i])
        end
    end
end
function GET_MULTIPLE_RANKROLLBACK_TARGETS()
    if multiple_src==nil or multiple_dest==nil then 
        return
    end
    return multiple_src,multiple_dest
end
function IS_RANKRESET_ITEM(itemClassName)
    if  itemClassName == 'Premium_RankReset' or itemClassName == '1706Event_RankReset' or itemClassName == 'Premium_RankReset_14d' or itemClassName == 'Premium_RankReset_60d' or itemClassName == 'Premium_RankReset_1d' or itemClassName == 'Premium_RankReset_30d' then
       return 1; 
    end
    return 0;
end

function IS_RANKROLLBACK_ITEM(itemClassName)
    if  itemClassName == 'Premium_RankRollback' then
       return 1; 
    end
    return 0;
end

function GET_MAX_WEEKLY_CLASS_RESET_POINT_EXP()
    return 1000;
end

function GET_MAX_CLASS_RESET_POINT_EXP()
    return 3000;
end


function IS_ABLE_TO_CHANGE_CLASS(pc, targetJobID,destJobID)
    local dest_jobCls = GetClassByType("Job", destJobID);
    local spcialGroup = TryGetProp(dest_jobCls,"SpecialGroup","None")
	if spcialGroup ~= "None" then
        local jobList = GetJobHistoryList(pc)        
		for k, v in pairs(jobList) do
			local cls = GetClassByType('Job', v)
			local checkProp = TryGetProp(cls,"SpecialGroup")
		    if spcialGroup ==  checkProp  then
                if cls.ClassID ~= targetJobID then                    
                    return false
                end
			end
		end
    end
    
    return true
end
