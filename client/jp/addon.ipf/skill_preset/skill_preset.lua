--skill_preset.
local MAX_PRESET_CNT = 30;
local MAX_RANK_IN_PRESET = 4;
local skill_list,abil_list = nil, nil;

local function PRE_LOAD_SKILL_PRESET()
    if skill_list==nil then
        skill_list = GetClassList("Skill");
    end
    if abil_list==nil then
        abil_list  = GetClassList("Ability");
    end
end
PRE_LOAD_SKILL_PRESET()

function SKILL_PRESET_ON_INIT(addon, frame)
    addon:RegisterMsg("SKILL_PRESET_SUCCESS_SAVE", "ON_SKILL_PRESET_SUCCESS_SAVE");
    addon:RegisterMsg("SKILL_PRESET_SUCCESS_REMOVE", "ON_SKILL_PRESET_SUCCESS_REMOVE");
    addon:RegisterMsg("SKILL_PRESET_SUCCESS_RENAME", "ON_SKILL_PRESET_SUCCESS_RENAME");
end

function ON_SKILL_PRESET_SUCCESS_SAVE(frame)
    SKILL_PRESET_INIT(frame)
end

function ON_SKILL_PRESET_SUCCESS_REMOVE(frame)
    SKILL_PRESET_INIT(frame)
end

function ON_SKILL_PRESET_SUCCESS_RENAME(frame)
    SKILL_PRESET_INIT(frame)
end

local function SKILL_PRESET_CHANGE_PLUS_TO_JOBICON(ctrlset, index)
    local etc = GetMyEtcObject();
    if etc==nil then return end
    local prop_1 = 'ClassSkillSnapShot_'..index
    local skill_info = TryGetProp(etc,prop_1,"None")
    skill_info = StringSplit(skill_info,'/')
    local prop_2 = 'ClassAbilitySnapShot_'..index
    local ability_info = TryGetProp(etc,prop_1,"None")
    local prop_3 = 'ClassSnapShotTitle_'..index
    local title = TryGetProp(etc,prop_3,"None")
    
    local jobCls = GetClassByType('Job', skill_info[1]);
    ctrlset:SetUserValue("JOB_ID",skill_info[1])
    local icon = GET_CHILD_RECURSIVELY(ctrlset,"entry_icon_1");
    local entry_class_name = GET_CHILD_RECURSIVELY(ctrlset,"entry_class_name");
    local entry_title = GET_CHILD_RECURSIVELY(ctrlset,"entry_title");
    icon:SetImage(jobCls.Icon);
    entry_class_name:SetText(TryGetProp(jobCls,"Name"))
    entry_title:SetText(title);
    entry_title:Invalidate();
end

local function SHOW_CONFIG_PRESET(ctrlset,isShowEntry)
    GET_CHILD_RECURSIVELY(ctrlset,"entry_gb"):ShowWindow(isShowEntry)
    GET_CHILD_RECURSIVELY(ctrlset,"regist_gb"):ShowWindow(1-isShowEntry)
    GET_CHILD_RECURSIVELY(ctrlset,"select_gb"):ShowWindow(0)
end

local function SKILL_PRESET_CHECK_IS_REGISTERED(argNum)
    local etc = GetMyEtcObject();
    if etc==nil then return false end
    
    local index = tostring(argNum)
    local prop = 'ClassSkillSnapShot_'..index
    local res = TryGetProp(etc,prop,"None")
    if res~="None" then return true end
end

local function SKILL_PRESET_OPEN_SAVE_SECTION(ctrlset)
    local frame = ui.GetFrame("skill_preset")
    GET_CHILD_RECURSIVELY(frame,"each_info_gb"):ShowWindow(0)
    local mainSession = session.GetMainSession();
    local pcJobInfo   = mainSession:GetPCJobInfo();
    local jobCount 	  = pcJobInfo:GetJobCount();
    
    local jobHistoryList = {};
    
    for i = 0, jobCount - 1 do
        local jobHistory = pcJobInfo:GetJobInfoByIndex(i);		
        jobHistoryList[#jobHistoryList + 1] = {
            JobClassID  = jobHistory.jobID,
            JobSequence = jobHistory.index;
        };
    end
    
    table.sort(jobHistoryList, function(lhs, rhs)
        return lhs.JobSequence < rhs.JobSequence;
    end);

    for i = 1, MAX_RANK_IN_PRESET do	
        local jobInfo = jobHistoryList[i];
        local jobCls = nil;
        if jobInfo ~= nil then
            jobCls = GetClassByType('Job', jobInfo.JobClassID);
            local inner_ctrlset = GET_CHILD_RECURSIVELY(ctrlset,"preset_job_icon_"..i);
            inner_ctrlset:SetUserValue("JOB_ID",jobInfo.JobClassID)
            local gb =  GET_CHILD_RECURSIVELY(inner_ctrlset,"gb");
            gb:ShowWindow(1)

            local icon = GET_CHILD_RECURSIVELY(inner_ctrlset,"icon");
            icon:SetImage(jobCls.Icon);            
            
            local class_name = GET_CHILD_RECURSIVELY(inner_ctrlset, 'class_name');			
            class_name:SetText(GET_JOB_NAME(jobCls, GETMYPCGENDER()))
            class_name:Invalidate();

            local btn = GET_CHILD_RECURSIVELY(inner_ctrlset, 'open_info_btn');
            btn:SetEventScript(ui.LBUTTONUP, "SKILL_PRESET_OPEN_INFO_BTN");
            btn:SetEventScriptArgNumber(ui.LBUTTONUP, i);
        else
            local inner_ctrlset = GET_CHILD_RECURSIVELY(ctrlset,"preset_job_icon_"..i);
            local gb =  GET_CHILD_RECURSIVELY(inner_ctrlset,"gb");
            gb:ShowWindow(0)
        end
    end
end

local function MAKE_SKILL_AND_ABILITY_LIST(job_id)
    local skill_list ={};
    local abil_list ={};
    local pc  = GetMyPCObject();
    
    job_id = tonumber(job_id)
    local jobCls = GetClassByType('Job', job_id)
    local jobClsName = TryGetProp(jobCls, 'ClassName', 'None')
    local jobEngName = GET_JOB_ENG_NAME(jobClsName);
    local abilGroupName = SKILLABILITY_GET_ABILITY_GROUP_NAME(jobEngName);
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

end

function SKILL_PRESET_OPEN_INFO_BTN(parent,self,arg1,argNum)
    local frame  = parent:GetTopParentFrame();
    frame:SetUserValue("INVEST_SKILLPOINTS_OR_NOT","None")
    
    local each_info_gb = GET_CHILD_RECURSIVELY(frame,"each_info_gb")
    each_info_gb:ShowWindow(1)
    local each_skill_info_gb = GET_CHILD_RECURSIVELY(each_info_gb,"each_skill_info_gb")
    each_skill_info_gb:RemoveAllChild()
    local preset_job_icon = GET_CHILD_RECURSIVELY(frame,"preset_job_icon_"..argNum)
    local job_id = preset_job_icon:GetUserIValue("JOB_ID")

    frame:SetUserValue("I_DECIDE_IT",job_id)

    if job_id=="None" or job_id==nil then return end  
    
    local pc  = GetMyPCObject();
    local token1 = MAKE_SKILL_INFO_SNAPSHOT_FORMAT(pc,job_id)
    local myAbil_list = MAKE_ABILITY_TREE_FORMAT(pc,job_id)
    myAbil_list = StringSplit(myAbil_list,'/')
    local token2  = MAKE_ABILITY_INFO_SNAPSHOT_FORMAT(pc,job_id)
   
    if skill_list ==nil or abil_list==nil then 
        PRE_LOAD_SKILL_PRESET()
    end

    local yPos = 0;
    local yPos_Child = 0;
    local nameIndex  = 0 ;
    for k,v in pairs(token1) do
        local cls_skill = GetClassByNameFromList(skill_list,k)
        local cls_skillTree = GetClassByStrProp("SkillTree", "SkillName",k)
        local skillName = k
        local skl_name  =  dic.getTranslatedStr(TryGetProp(cls_skill,"Name"))
        local tooltipSet = each_skill_info_gb:CreateOrGetControlSet('skill_preset_tooltip_narrow', 'INFO_SKILL'..nameIndex,ui.LEFT, ui.TOP, 0, yPos,0,0)
        yPos  = yPos + 60;

        -- Setting Skill Info Start --
        local skill_icon = GET_CHILD_RECURSIVELY(tooltipSet,"single_icon")
        skill_icon:SetImage("icon_"..cls_skill.Icon)
        local txt = GET_CHILD_RECURSIVELY(tooltipSet,"text")
        txt:SetTextByKey('value1',skl_name);
        txt:SetTextByKey('value2',v);
        if tonumber(TryGetProp(cls_skillTree,"MaxLevel",0))==v then
            txt:SetTextByKey('value3',"M");    
        end
        -- Setting Skill Info End --
        nameIndex_sub=0;
        for i,p in pairs(token2) do

            local cls_abil = GetClassByNameFromList(abil_list,i) 
            local skill_category = TryGetProp(cls_abil,"SkillCategory","None")
            if skill_category==k then 
                local job_abil = GetClassByStrProp(myAbil_list[1],"ClassName",i)
                local abil_name=  dic.getTranslatedStr(TryGetProp(cls_abil,"Name"))
                local tooltipSet = each_skill_info_gb:CreateOrGetControlSet('skill_preset_tooltip_narrow', 'INFO_ABIL'..nameIndex.."_"..nameIndex_sub,ui.RIGHT, ui.TOP, 0, yPos_Child,30,0)
                yPos_Child  = yPos_Child + 60;
                
                nameIndex_sub = nameIndex_sub+1
                
                local abil_icon  = GET_CHILD_RECURSIVELY(tooltipSet,"single_icon")
                abil_icon:SetImage(cls_abil.Icon)
                if v == 0 then
                    if p > 0 then 
                        frame:SetUserValue("INVEST_SKILLPOINTS_OR_NOT","NOT")
                    end
                end 
                local txt = GET_CHILD_RECURSIVELY(tooltipSet,"text")
                txt:SetTextByKey('value1',abil_name);
                txt:SetTextByKey('value2',p);
                if tonumber(TryGetProp(job_abil,"MaxLevel",0))==p then
                    txt:SetTextByKey('value3',"M");    
                end
            end   
        end
        nameIndex = nameIndex+1 
        
        if yPos < yPos_Child then
            yPos= yPos_Child
        else
            yPos_Child = yPos
        end
    end
end

local function SKILL_PRESET_OPEN_APPLY_SECTION(index)
    local frame = ui.GetFrame("skill_preset")
    if frame==nil then return end
    GET_CHILD_RECURSIVELY(frame,"rename_gb"):ShowWindow(0)
    local applyInfo = GET_CHILD_RECURSIVELY(frame,"applyInfo")  
    local icon = GET_CHILD(applyInfo,"icon")
    local clsName = GET_CHILD(applyInfo,"class_name")
    local etc = GetMyEtcObject()
    local pc  = GetMyPCObject();
    local prop  = 'ClassSkillSnapShot_'..index
    local prop1 = 'ClassAbilitySnapShot_'..index
    
    local info = TryGetProp(etc,prop,"None");
    local info2 =  TryGetProp(etc,prop1,"None");
    
    local skill_info_gb = GET_CHILD_RECURSIVELY(applyInfo,"skill_info_gb")
    
    skill_info_gb:RemoveAllChild();
    
    if skill_list ==nil or abil_list==nil then 
        PRE_LOAD_SKILL_PRESET()
    end

    if info~="None" and info2~="None" then
        local infoList  = StringSplit(info,'/')
        local infoList2 = StringSplit(info2,'/')
        local token1 = DECODE_SKILL_TREE_FORMAT(pc,info)
        local token2 = DECODE_ABILITY_TREE_FORMAT(pc,info2)
        
        local yPos = 0;
        local yPos_Child = 0;
        local nameIndex  = 0 ;
        local totalpoint = 0;
        for k,v in pairs(token1) do
            local cls_skill = GetClassByNameFromList(skill_list,k)
            local cls_skillTree = GetClassByStrProp("SkillTree", "SkillName",k)
            
            local skillName = k
            local skl_name  =  dic.getTranslatedStr(TryGetProp(cls_skill,"Name"))
            local tooltipSet = skill_info_gb:CreateOrGetControlSet('skill_preset_tooltip_narrow', 'INFO_SKILL'..nameIndex,ui.LEFT, ui.TOP, 0, yPos,0,0)
            yPos  = yPos + 60;
            
            local skill_icon = GET_CHILD_RECURSIVELY(tooltipSet,"single_icon")
            skill_icon:SetImage("icon_"..cls_skill.Icon)
            local txt = GET_CHILD_RECURSIVELY(tooltipSet,"text")
            totalpoint = totalpoint + v
            txt:SetTextByKey('value1',skl_name);
            txt:SetTextByKey('value2',v);
            if tonumber(TryGetProp(cls_skillTree,"MaxLevel",0))==v then
                txt:SetTextByKey('value3',"M");    
            end
            
            nameIndex_sub=0;
            for i,p in pairs(token2) do
                local cls_abil = GetClassByNameFromList(abil_list,i) 
                local skill_category = TryGetProp(cls_abil,"SkillCategory","None")
                if skill_category==k then 
                    local job_abil = GetClassByStrProp(infoList2[1],"ClassName",i)
                    local abil_name=  dic.getTranslatedStr(TryGetProp(cls_abil,"Name"))
                    local tooltipSet = skill_info_gb:CreateOrGetControlSet('skill_preset_tooltip_narrow', 'INFO_ABIL'..nameIndex.."_"..nameIndex_sub,ui.RIGHT, ui.TOP, 0, yPos_Child,0,0)
                    yPos_Child  = yPos_Child + 60;
                    
                    nameIndex_sub = nameIndex_sub+1
                
                    local abil_icon  = GET_CHILD_RECURSIVELY(tooltipSet,"single_icon")
                    abil_icon:SetImage(cls_abil.Icon)
                    
                    local txt = GET_CHILD_RECURSIVELY(tooltipSet,"text")
                    txt:SetTextByKey('value1',abil_name);
                    txt:SetTextByKey('value2',p);
                    if tonumber(TryGetProp(job_abil,"MaxLevel",0))==p then
                        txt:SetTextByKey('value3',"M");    
                    end
                end   
            end
            nameIndex = nameIndex+1 
            
            if yPos < yPos_Child then
                yPos= yPos_Child
            else
                yPos_Child = yPos
            end
        end
        
        local total_skillpoint = GET_CHILD_RECURSIVELY(frame,"skill_point_info")
        total_skillpoint:SetTextByKey('value',totalpoint)

        local cls = GetClassByType('Job', infoList[1]);
        icon:SetImage(cls.Icon);
        clsName:SetText(TryGetProp(cls,"Name"))
    end
end

function SKILL_PRESET_CREATE_LIST(frame)
    local list_gb = GET_CHILD_RECURSIVELY(frame,"list_gb") 
    list_gb:RemoveAllChild();
    
    for i = 0, MAX_PRESET_CNT-1 do
        local ctrlset = list_gb:CreateOrGetControlSet("add_preset_info","PRESET_"..i, ui.LEFT, ui.TOP, 0, i*70, 0, 0)
        local preset_num = GET_CHILD_RECURSIVELY(ctrlset,"preset_num")
        preset_num:SetTextByKey("value",i+1) 
        preset_num:ShowWindow(1)
        SHOW_CONFIG_PRESET(ctrlset,0)    
    end

    local saved_preset_cnt = 0;
    for i = 0, MAX_PRESET_CNT-1 do
        local ctrlset = GET_CHILD_RECURSIVELY(list_gb,"PRESET_"..i)
        local isRegistered = SKILL_PRESET_CHECK_IS_REGISTERED(i)
        if isRegistered==true then 
            local preset_num = GET_CHILD_RECURSIVELY(ctrlset,"preset_num")
            preset_num:ShowWindow(0)
            SHOW_CONFIG_PRESET(ctrlset,1)
            SKILL_PRESET_CHANGE_PLUS_TO_JOBICON(ctrlset,i)  
            saved_preset_cnt = saved_preset_cnt + 1;
        end
    end
    GET_CHILD_RECURSIVELY(frame,"regist_cnt"):SetTextByKey("value",saved_preset_cnt)
end

function SKILL_PRESET_OPEN(frame)
    local abil_frame = ui.GetFrame("skillability");
    local button = GET_CHILD_RECURSIVELY(abil_frame,"skill_preset_btn")
    local posX = button:GetGlobalX()-frame:GetWidth()+button:GetWidth()*2
    local posY = button:GetGlobalY()+button:GetHeight()
    frame:SetOffset(posX, posY)
    
    SKILL_PRESET_INIT(frame)
end

function SKILL_PRESET_INIT(frame)
    frame:SetUserValue("CURR_INDEX","None")
    GET_CHILD_RECURSIVELY(frame,"save_section"):ShowWindow(0)
    GET_CHILD_RECURSIVELY(frame,"apply_section"):ShowWindow(0)
    GET_CHILD_RECURSIVELY(frame,"input_title_edit"):ClearText();
    SKILL_PRESET_CREATE_LIST(frame)
end

function SKILL_PRESET_SECTION_OPEN(parent,self) 
    local frame = parent:GetTopParentFrame();
    local name  = parent:GetName()

    name = StringSplit(name,'_')
    if #name <= 0 then return end 
    local index = name[#name]  

    local isRegistered = SKILL_PRESET_CHECK_IS_REGISTERED(index)

    local before_index = frame:GetUserValue("CURR_INDEX")

    if index==before_index then return end

    if before_index~="None" then 
        local before_ctrlset = GET_CHILD_RECURSIVELY(frame, "PRESET_"..before_index)
        GET_CHILD_RECURSIVELY(before_ctrlset,"select_gb"):ShowWindow(0)
    end
    
    GET_CHILD_RECURSIVELY(parent,"select_gb"):ShowWindow(1)
    local save_section = GET_CHILD_RECURSIVELY(frame,"save_section")
    save_section:ShowWindow(0)
    local apply_section = GET_CHILD_RECURSIVELY(frame,"apply_section")
    apply_section:ShowWindow(0)

    local userval = parent:GetUserValue("JOB_ID")
    if isRegistered==true then
        local applyInfo = GET_CHILD_RECURSIVELY(apply_section,"applyInfo")    
        SKILL_PRESET_OPEN_APPLY_SECTION(index)
        apply_section:ShowWindow(1)   
    else
        local save_ctrlset = GET_CHILD_RECURSIVELY(save_section,"class_ctrlset")
        save_section:ShowWindow(1)
        frame:SetUserValue("I_DECIDE_IT","None")
        SKILL_PRESET_OPEN_SAVE_SECTION(save_ctrlset)
    end
    frame:SetUserValue("CURR_INDEX",index)
end

function SKILL_PRESET_REMOVE(parent,self)
    local frame = parent:GetTopParentFrame();
    local currCtrl_index = frame:GetUserValue("CURR_INDEX")
    local ctrlset = GET_CHILD_RECURSIVELY(frame,"PRESET_"..currCtrl_index)
    if ctrlset==nil then return end
    local job_id = ctrlset:GetUserIValue("JOB_ID") 
    session.job.ReqRemoveClassSnapshot(currCtrl_index)
end

function SKILL_PRESET_APPLY(parent,self)
    local frame = parent:GetTopParentFrame();
    local currCtrl_index = frame:GetUserValue("CURR_INDEX")
    local ctrlset = GET_CHILD_RECURSIVELY(frame,"PRESET_"..currCtrl_index)
    if ctrlset==nil then return end
    local id = ctrlset:GetUserValue("JOB_ID")
    local sklpts = GET_INVESTED_SKILL_POINTS(GetMyPCObject(),id)
    if sklpts > 0 then
        ui.SysMsg(ClMsg("CannotApplyPreset"))
        return
    end

    if IS_MATCHED_CURR_JOB(id) == false then
        ui.SysMsg(ClMsg("CannotApplyPresetCuzNoneTarget"))
        return
    end

    session.job.ReqApplyClassSnapshot(currCtrl_index)
    
    SKILL_PRESET_INIT(frame)
end

function IS_MATCHED_CURR_JOB(arg)
    local requestId = tonumber(arg)
    local pc 		  = GetMyPCObject();
	local mainSession = session.GetMainSession();
	local pcJobInfo   = mainSession:GetPCJobInfo();
	local jobCount 	  = pcJobInfo:GetJobCount();
	for i = 0, jobCount - 1 do
        local jobHistory = pcJobInfo:GetJobInfoByIndex(i);		
        local id = jobHistory.jobID
        if id == requestId then
            return true
        end
	end

    return false
end

function SKILL_PRESET_SAVE(parent,self)
    local frame  = parent:GetTopParentFrame();
    local job_id = frame:GetUserIValue("I_DECIDE_IT")
    if job_id=="None" or job_id==nil or job_id==0 then
        return
    end
    local sklpts = GET_INVESTED_SKILL_POINTS(GetMyPCObject(), job_id)
    local isUse  = IS_USE_BONUS_SKILL_POINTS(GetMyPCObject(), job_id)
    if tonumber(sklpts) < 1 then 
        ui.SysMsg(ClMsg("CannotSnapShotBecauseZero"))
        return
    end
    if isUse == true then 
        ui.SysMsg(ClMsg("CannotSnapShotBecauseBonus"))
        return
    end
    if frame:GetUserValue("INVEST_SKILLPOINTS_OR_NOT") == "NOT" then
        ui.SysMsg(ClMsg("CannotSnapShotCuzInvalidskillabilpoint"))
        return
    end
    local edit = GET_CHILD_RECURSIVELY(frame,"input_title_edit")
    local curr_index = frame:GetUserValue("CURR_INDEX")

    local input_title_name = edit:GetText()
    if input_title_name=="" then
        ui.SysMsg(ClMsg('PlzCheckPresetName'));
        return
    end
    _SKILL_PRESET_SAVE(job_id,curr_index,input_title_name)
end

function _SKILL_PRESET_SAVE(id,index,title)
    session.job.ReqSaveClassSnapshot(id, index, title)
end

function SKILL_PRESET_SAVE_BTN_CLICK(parent,self,arg1,argNum)
    local frame  = parent:GetTopParentFrame();
    local preset_job_icon = GET_CHILD_RECURSIVELY(frame,"preset_job_icon_"..argNum)
    local job_id = preset_job_icon:GetUserIValue("JOB_ID")
    if job_id=="None" or job_id==nil then
        return
    end
    local sklpts = GET_INVESTED_SKILL_POINTS(GetMyPCObject(), job_id)
    local isUse = IS_USE_BONUS_SKILL_POINTS(GetMyPCObject(), job_id)
    if tonumber(sklpts) < 1 then 
        ui.SysMsg(ClMsg("CannotSnapShotBecauseZero"))
        return
    end
    if isUse == true then 
        ui.SysMsg(ClMsg("CannotSnapShotBecauseBonus"))
        return
    end
    
    local edit = GET_CHILD_RECURSIVELY(frame,"input_title_edit")

    local startindex = nil 
    if #emptyIndex_list > 0 then
        startindex = emptyIndex_list[1]
    end

    local input_title_name = edit:GetText()
    if input_title_name=="" then
        ui.SysMsg(ClMsg('PlzCheckPresetName'));
        return
    end
    session.job.ReqSaveClassSnapshot(job_id, startindex, input_title_name)
end

function SKILL_PRESET_CLOSE(frame)

end

function SKILL_PRESET_ON_ESCAPE(frame)
    ui.CloseFrame('skill_preset')
end

function SKILL_PRESET_RENAME_EDIT_OPEN(parent,self) 
    local frame  = parent:GetTopParentFrame();
    local rename_gb = GET_CHILD_RECURSIVELY(frame,"rename_gb")
    rename_gb:ShowWindow(1)
    local rename_edit = GET_CHILD_RECURSIVELY(rename_gb,"rename_edit")
    rename_edit:ClearText()
    
end

function SKILL_PRESET_RENAME(parent,self)
    local frame  = parent:GetTopParentFrame();
    local rename_edit = GET_CHILD_RECURSIVELY(frame,"rename_edit")
    local curr_index = frame:GetUserValue("CURR_INDEX")
    local title  = rename_edit:GetText();
    if title=="" then
        ui.SysMsg(ClMsg('PlzCheckPresetName'));
        return
    end
    session.job.ReqRenameClassSnapshot(curr_index,title)
end