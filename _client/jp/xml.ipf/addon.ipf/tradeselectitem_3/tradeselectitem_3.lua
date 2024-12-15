function TRADESELECTITEM_3_ON_INIT(addon, frame)
end

function OPEN_ABILITY_RESET_SELECT_JOB(invItem)
	local zoneName = GetZoneName()
	local mapCls = GetClass('Map', zoneName)
	if mapCls == nil or TryGetProp(mapCls, 'MapType', 'None') ~= 'City' then
		ui.SysMsg(ClMsg('AllowedInTown1'))
		return
	end

	local frame = ui.GetFrame("tradeselectitem_3")
	frame:SetTitleName('{@st43}{s22}' ..ScpArgMsg('Premium_SkillResetJob'))
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
	box:DeleteAllControl();
	local y = 5;

	local jobList = GetMyJobList()
	
    for i = 1,#jobList do
		local jobCls = GetClassByType("Job",jobList[i])
		if jobCls ~= nil then
			local jobName = jobCls.Name
			y = CREATE_QUEST_REWARE_CTRL_JOB(box, y, i, jobCls);	
			y = y + 5
		end
	end

	local cancelBtn = frame:GetChild('CancelBtn');
	local useBtn = frame:GetChild('UseBtn');
	useBtn:SetEventScript(ui.LBUTTONUP,'REQUEST_ABILITY_RESET_JOB')	

	box:Resize(box:GetOriginalWidth(), y);	    
	local screen_height = option.GetClientHeight();
	local maxSizeHeightFrame = box:GetY() + box:GetHeight() + 20;
	local maxSizeHeightWnd = ui.GetSceneHeight();
    
    if maxSizeHeightWnd >= 950 then        
        maxSizeHeightWnd = 950
    
        if maxSizeHeightWnd > screen_height then
            maxSizeHeightWnd = screen_height * 0.8
        end
    end
    
    if maxSizeHeightFrame >= maxSizeHeightWnd then
        maxSizeHeightFrame = maxSizeHeightWnd
    end
       
	if maxSizeHeightWnd < (maxSizeHeightFrame + 50) then                 
		local margin = maxSizeHeightWnd/2;
		box:EnableScrollBar(1);

		box:Resize(box:GetOriginalWidth(), margin - useBtn:GetHeight() - 40);
		box:SetScrollBar(0);
		box:InvalidateScrollBar();
		frame:Resize(frame:GetOriginalWidth(), margin + 100);
	else
		box:SetCurLine(0) -- scroll init
		
		box:Resize(box:GetOriginalWidth(), y);
		frame:Resize(frame:GetOriginalWidth(), maxSizeHeightFrame);
	end;
	box:SetScrollPos(0);
	local selectExist = 0;
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			selectExist = 1;
		end 
	end

	local NeedItemSlot = frame:GetChild('NeedItemSlot')
	local NeedItemName = frame:GetChild('NeedItemName')
	NeedItemName:SetVisible(0)
	NeedItemSlot:SetVisible(0)

    local itemGuid = invItem:GetIESID();
	frame:SetUserValue("UseItemGuid", itemGuid);
	frame:ShowWindow(1);
end

function REQUEST_ABILITY_RESET_JOB(frame, ctrl, argStr, argNum)    
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");

	local selectExist = 0;
	local selected = 0;
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			if ctrlSet:IsSelected() == 1 then
				selected = ctrlSet:GetValue();
			end
			selectExist = 1;
		end
	end

	if selectExist == 1 and selected == 0 then
		ui.MsgBox(ScpArgMsg("Auto_BoSangeul_SeonTaegHaeJuSeyo."));
		return;
	end

	if selectExist == 1 then
		--선택한 ClassID
		local itemGuid = frame:GetUserValue("UseItemGuid");		
		local argStr = string.format("%s", selected);		
        pc.ReqExecuteTx_Item("RESET_ABILITY_POINT_JOB", itemGuid, argStr);		
	end

	frame = frame:GetTopParentFrame();
	frame:ShowWindow(0);
end
