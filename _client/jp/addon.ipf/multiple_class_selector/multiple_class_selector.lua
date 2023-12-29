local CTRLTYPE = 0;
local bantable = nil;
local CURR_ID = nil;
local CTRLINDEX = 0;

function MULTIPLE_CLASS_SELECTOR_UI_OPEN(frame)
    frame:SetUserValue("CLASS_ID", "None")
    local mclass_change = ui.GetFrame('multiple_class_change')
    if mclass_change ~=nil then 
        local baseID = mclass_change:GetUserIValue("ID")
        if baseID~="None" or  baseID~=nil then  CTRLTYPE = baseID end
    end
    
end

function MULTIPLE_CLASS_SELECTOR_SET_CURR_ID(argNum)
    CURR_ID   = GET_CURRENT_CLASS_EACH_CTRL()
    CTRLINDEX = argNum
    MULTIPLE_CLASS_SELECTOR_FILL_CLASS(CURR_ID)
end

function MULTIPLE_CLASS_SELECTOR_UI_CLOSE(frame)
    frame:ShowWindow(0)
    CTRLTYPE = 0;
end

local function MULTIPLE_CLASS_SELECTOR_GET_JOB_LIST(baseJobID)
	local retTable = {}
	local list, cnt = GetClassList("Job");
	local baseCls = GetClassByTypeFromList(list, baseJobID);
	if baseCls == nil then
		return retTable;
	end

	local ctrlType = TryGetProp(baseCls, "CtrlType")
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(list,i);
		if TryGetProp(cls, "CtrlType") == ctrlType and TryGetProp(cls, "Rank") <= 2 then
			table.insert(retTable, cls);
		end
	end
	return retTable;
end

function DUPLICATION_CHECK_SPECIALCLASS(job_list,selected_id_table)
    for i=1, #selected_id_table do
        local cls  = GetClassByType("Job",selected_id_table[i])
        local specialGroup = TryGetProp(cls,"SpecialGroup","None")
        if specialGroup~="None" then 
            for j = 1, #job_list do
                if job_list[j].ClassID ~= selected_id_table[i] and TryGetProp(job_list[j],"SpecialGroup") == specialGroup  then
                    table.insert(selected_id_table,job_list[j].ClassID)
                end
            end
        end
    end 

    return selected_id_table
end

function MULTIPLE_CLASS_SELECTOR_FILL_CLASS(jobID)
    local frame = ui.GetFrame('multiple_class_selector');
	local classList = GET_CHILD_RECURSIVELY(frame, "classList");
	classList:RemoveAllChild();
    local job_list = MULTIPLE_CLASS_SELECTOR_GET_JOB_LIST(CTRLTYPE);
    bantable = GET_CURRENT_CLASS_LIST()
    local cnt = 0;
    local selected_id_table = GET_SELECTED_ID_LIST()
    -- duplication check about specialclass
    selected_id_table = DUPLICATION_CHECK_SPECIALCLASS(job_list,selected_id_table)
    for k,v in pairs(selected_id_table) do
        if table.find(bantable,v) == 0 then
            table.insert(bantable,v) 
        end 
    end

    local function _IS_SATISFIED_HIDDEN_JOB_TRIGGER(jobCls)	
        local preFuncName = TryGetProp(jobCls, 'PreFunction', 'None');
        if jobCls.HiddenJob == 'NO' then
            return true;
		end

		if preFuncName == 'None' then
			return true;
		end
	
		local name = TryGetProp(jobCls, "JobName", "None")
		if name ~= 'Appraiser' and name ~= 'NakMuay' and name ~= 'Shinobi' and name ~= 'Miko' and name ~= 'RuneCaster' then
			return true
        end
        
		return false;
    end
    
    local pc = GetMyPCObject();	
            
    for i = 1, #job_list do
		local job_cls = job_list[i];
        local job_cls_id = TryGetProp(job_cls, "ClassID", 0);
        local preFuncName = TryGetProp(job_cls, 'PreFunction', 'None');
        
        --히든 클래스 
        if _IS_SATISFIED_HIDDEN_JOB_TRIGGER(job_cls) ==false then
            if preFuncName ~="None" then
                local preFunc = _G[preFuncName]	
                local result = preFunc(pc,nil);
                if result == "NO" then 
                    table.insert(bantable, job_cls_id)
                end
            end    
        end
        --신규 클래스
        if  job_cls.HiddenJob == 'YES' and preFuncName ~= 'None' then
            local preFunc = _G[preFuncName]
            if preFunc ~=nil then
                local jobCount = GetTotalJobCount(pc);
                local result = preFunc(pc, jobCount);
                if result == 'NO' then
                    table.insert(bantable, job_cls_id)
                end
            end
        end

        local check_banId =  table.find(bantable, tonumber(job_cls_id))
        if job_cls ~= nil and job_cls_id ~= nil and check_banId==0  then
            cnt = cnt+1;
            local width = 80;
			local height = 80;
			local x = (cnt - 1) % 3 * width;
			local y = math.floor((cnt - 1) / 3) * height - 20;
			local ctrlSet = classList:CreateOrGetControlSet("multiple_class_selector_job_btn", "list_job_"..cnt, ui.LEFT, ui.TOP, x, y, 0, 0);
			if ctrlSet ~= nil then
				local icon = GET_CHILD_RECURSIVELY(ctrlSet, "icon_pic");
				local icon_name = TryGetProp(job_cls, "Icon", "None");
				if icon_name ~= nil and icon_name ~= "None" then
					icon:SetImage(icon_name);
                    icon:SetColorTone("FFFFFFFF");
				end

				local select_btn = GET_CHILD(ctrlSet,"select_btn")
				select_btn:SetTooltipType('adventure_book_job_info');
				select_btn:SetTooltipArg(job_cls_id, 0, 0);
                select_btn:SetEventScriptArgNumber(ui.LBUTTONUP, job_cls_id);
			end
		end
	end
end

function MULTIPLE_CLASS_SELECT_BTN(parent, ctrl, argStr, jobID)
    local jobList = GetJobHistoryList(GetMyPCObject())
    local ret = IS_ABLE_TO_CHANGE_CLASS(GetMyPCObject(), jobList[CTRLINDEX + 1], jobID)
    
    if ret == false then
        ui.SysMsg(ClMsg('IsAleadyExistSpecialClassGroup'))
        return        
    end

    local frame = parent:GetTopParentFrame()
    MULTIPLE_CLASS_CHANGE_SELECT_DEST(CTRLINDEX,jobID)
    ui.CloseFrame("multiple_class_selector");
end

