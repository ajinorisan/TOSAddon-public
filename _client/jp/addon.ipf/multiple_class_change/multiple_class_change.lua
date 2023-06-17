--multiple_class_change
local SHOW_MAX_RANK = 3;

function MULTIPLE_CLASS_CHANGE_CLOSE_ON_INIT(addon, frame)
	frame:SetUserValue("CTRL_ID",0)
end

function MULTIPLE_CLASS_CHANGE_OPEN(frame)
	UPDATE_CURRENT_CLASSTREE_INFO(frame)
end

function UPDATE_CURRENT_CLASSTREE_INFO(frame)
	local pc 		  = GetMyPCObject();
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
	
	for i = 1, SHOW_MAX_RANK do	
		if i==1 then 
			frame:SetUserValue("ID",jobHistoryList[i].JobClassID)
		end	

		local jobCtrlset = GET_CHILD_RECURSIVELY(frame, 'class_'..i);
		GET_CHILD_RECURSIVELY(jobCtrlset,"selected_gb"):ShowWindow(0)
		GET_CHILD_RECURSIVELY(jobCtrlset,"select_gb"):ShowWindow(1)
		local jobInfo = jobHistoryList[i+1];
		local jobCls = nil;
		if jobInfo ~= nil then
			jobCls = GetClassByType('Job', jobInfo.JobClassID);
			local jobNameText = GET_CHILD_RECURSIVELY(jobCtrlset, 'class_name');			
			jobNameText:SetTextByKey('value', GET_JOB_NAME(jobCls, GETMYPCGENDER()));
			jobNameText:AdjustFontSizeByWidth(jobNameText:GetWidth());
			jobNameText:Invalidate();

			local jobEmblemPic = GET_CHILD(jobCtrlset, 'class_icon');
			jobEmblemPic:SetImage(jobCls.Icon);
			jobCtrlset:ShowWindow(1);

			local select_gb  = GET_CHILD(jobCtrlset, 'select_gb');
			if select_gb ~= nil then
				select_gb:SetEventScript(ui.LBUTTONDOWN, "MULTIPLE_CLASS_CHANGE_BTN_CLICK");
				select_gb:SetEventScriptArgNumber(ui.LBUTTONDOWN, i);
			end
			jobCtrlset:SetUserValue("SRC",jobInfo.JobClassID)
			jobCtrlset:SetUserValue("DEST",0)
		else
			jobCtrlset:ShowWindow(0);
		end
	end
end

function MULTIPLE_CLASS_CHANGE_BTN_CLICK(parent,self,argStr,argNum)
	local frame	   = parent:GetTopParentFrame();
	frame:SetUserValue("CTRL_ID",parent:GetUserValue("SRC"))
	local multiple_class_selector = ui.GetFrame("multiple_class_selector")
	
	local x = parent:GetGlobalX()+parent:GetWidth();
	local y = parent:GetGlobalY();
	if multiple_class_selector:IsVisible() == 1 then 
		ui.CloseFrame("multiple_class_selector") 
	end 
	ui.OpenFrame("multiple_class_selector")
	multiple_class_selector:SetOffset(x,y)
	MULTIPLE_CLASS_SELECTOR_SET_CURR_ID(argNum)	
end


function MULTIPLE_CLASS_CHANGE_SELECT_DEST(ctrl_index , dest_Id)
	local frame = ui.GetFrame("multiple_class_change")
	local jobCtrlset = GET_CHILD_RECURSIVELY(frame, 'class_'..ctrl_index);
	if jobCtrlset==nil or ctrl_index==0 or dest_Id==nil then return end
	jobCtrlset:SetUserValue("DEST",dest_Id)

	GET_CHILD_RECURSIVELY(jobCtrlset,"select_gb"):ShowWindow(0)

	local selected_gb = GET_CHILD_RECURSIVELY(jobCtrlset,"selected_gb")
	selected_gb:ShowWindow(1)
	selected_gb:SetEventScript(ui.RBUTTONDOWN, "RESET_MULTIPLE_CLASS_CHANGE_BTN_CLICK");
	jobCls = GetClassByType('Job', dest_Id);
	
	local jobNameText = GET_CHILD_RECURSIVELY(jobCtrlset, 'selected_class_name');			
	jobNameText:SetTextByKey('value', GET_JOB_NAME(jobCls, GETMYPCGENDER()));
	jobNameText:AdjustFontSizeByWidth(jobNameText:GetWidth());
	jobNameText:Invalidate();

	local jobEmblemPic = GET_CHILD_RECURSIVELY(jobCtrlset, 'selected_class_icon');
	jobEmblemPic:SetImage(jobCls.Icon);
end


function RESET_MULTIPLE_CLASS_CHANGE_BTN_CLICK(parent,ctrl)
	local select_gb = GET_CHILD_RECURSIVELY(parent,"select_gb")
	select_gb:ShowWindow(1)
	local selected_gb = GET_CHILD_RECURSIVELY(parent,"selected_gb")
	selected_gb:ShowWindow(0)
	parent:SetUserValue("DEST",0)
	local multiple_class_selector = ui.GetFrame("multiple_class_selector")
	if multiple_class_selector:IsVisible() then 
		ui.CloseFrame("multiple_class_selector")
	end
end

function GET_SELECTED_ID_LIST()
	local frame = ui.GetFrame("multiple_class_change")
	local id_list ={}
	for i = 1, SHOW_MAX_RANK do	
		local jobCtrlset = GET_CHILD_RECURSIVELY(frame, 'class_'..i);
		local dest = jobCtrlset:GetUserIValue("DEST")
		if dest ~=0 and dest ~=nil then 
			table.insert(id_list,dest)
		end 
	end
	return id_list
end

function MULTIPLE_CLASS_CHANGE_CLOSE(frame)
	local multiple_class_selector = ui.GetFrame("multiple_class_selector")
	if multiple_class_selector:IsVisible() then 
		ui.CloseFrame("multiple_class_selector")
	end
end

function MULTIPLE_CLASS_CHANGE_ON_ESCAPE(frame)
	ui.CloseFrame('multiple_class_change')
	local multiple_class_selector = ui.GetFrame("multiple_class_selector")
	if multiple_class_selector:IsVisible() then 
		ui.CloseFrame("multiple_class_selector")
	end
end

function GET_CURRENT_CLASS_EACH_CTRL()
	local frame = ui.GetFrame("multiple_class_change")
	local id = frame:GetUserIValue("CTRL_ID")
	return id
end

function GET_CURRENT_CLASS_LIST()
	local frame = ui.GetFrame("multiple_class_change")
	local id_table = {}
	local id = frame:GetUserIValue("ID")
	if id > 0 and id~=nil then 	table.insert(id_table,id) end

	for i = 1, SHOW_MAX_RANK do	
		local jobCtrlset = GET_CHILD_RECURSIVELY(frame, 'class_'..i);
		local id = jobCtrlset:GetUserIValue("SRC")
		if id > 0 and id~=nil then 	table.insert(id_table,id) end
	end
	return id_table
end

function MULTIPLE_CLASS_CHANGE()
	local frame = ui.GetFrame("multiple_class_change")
	local reqTable ={}
	local changeCnt = 0;
	for i = 1, SHOW_MAX_RANK do	
		local jobCtrlset = GET_CHILD_RECURSIVELY(frame, 'class_'..i);
		local src = jobCtrlset:GetUserIValue("SRC")
		if src == 0 then 
			table.insert(reqTable,0)
		else
			table.insert(reqTable,src)
		end
		local dest = jobCtrlset:GetUserIValue("DEST")
		if dest ==0 then 
			table.insert(reqTable,0)
		else
			table.insert(reqTable,dest)
			changeCnt = changeCnt + 1
		end
	end

	if reqTable[2]==0 and  reqTable[4]==0 and  reqTable[6]==0 then
		ui.CloseFrame('multiple_class_selector');
		ui.CloseFrame('multiple_class_change');
		return 
	end

	local curExp = session.job.GetClassResetPointExp();
	local CanChangeCnt = math.floor(curExp/1000)

	if changeCnt > CanChangeCnt then
		ui.SysMsg(ClMsg('ClassResetFailPoint'));
		return 
	end
	ui.CloseFrame('multiple_class_selector');
	ui.CloseFrame('multiple_class_change');
	ui.CloseFrame('changejob');
	session.job.ReqUnEquipItemAll()

	local rankrollback = ui.GetFrame("rankrollback");
	rankrollback:ShowWindow(1);
	RANKROLLBACK_CHECK_PLAYER_MULTIPLE_STATE(rankrollback,reqTable)	
end
