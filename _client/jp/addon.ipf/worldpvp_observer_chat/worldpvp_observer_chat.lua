function CHAT_OBSERVER_ENABLE(count, aidList, teamIDList, iconList)
	local frame = ui.GetFrame("worldpvp_observer_chat");
	for i = 1 , 2 do
		local gbox = frame:GetChild("gbox_" .. i);
		gbox:RemoveAllChild();
	end
	
	frame:ShowWindow(1);
	if count == 0 then
		for i = 0 , frame:GetChildCount() - 1 do
			local child = frame:GetChildByIndex(i);
			if string.find(child:GetName(), "button") ~= nil or string.find(child:GetName(), "mainchat") ~= nil then
				child:ShowWindow(1)
			else
				child:ShowWindow(0)
			end
		end
		return;
	end

	local aniPCAID = nil;
	for i = 0 , count - 1 do
		local aid = aidList:Get(i);
		local icon_info = iconList:GetByIndex(i);
		local gbox = frame:GetChild("gbox_"..teamIDList:Get(i));
		local ctrl_set = gbox:CreateControlSet("pvp_observer_ctrlset", "CTRL_" .. i, ui.LEFT, ui.CENTER_VERT, 0, 0, 0, 0);
		if ctrl_set ~= nil then
			ctrl_set:EnableHitTest(1);
			ctrl_set:SetUserValue("AID", aid);
			if aniPCAID == nil then 
				aniPCAID = aid; 
			end
	
			local pic = GET_CHILD(ctrl_set, "pic");
			if pic ~= nil then
				local img_name = GET_JOB_ICON(icon_info.repre_job);
				pic:SetImage(img_name);
			end

			local btn = ctrl_set:GetChild("btn");
			if btn ~= nil then
				local text = ScpArgMsg("Observe{PC}", "PC", icon_info:GetFamilyName());
				btn:SetTextTooltip(text);
			end
		end
	end

	for i = 1, 2 do
		local gbox = frame:GetChild("gbox_" .. i);
		GBOX_AUTO_ALIGN_HORZ(gbox, 10, 10, 0, true, false);
	end

	if aniPCAID ~= nil then
		if camera.IsViewFocsedToSelf() == true then
			worldPVP.ReqObservePC(aniPCAID);
		end
	end
end

function END_PVP_OBSERVER(parent, ctrl)
	worldPVP.ReturnToOriginalServer();
end

function CENTER_PVP_OBSERVER(parent, ctrl)
	worldPVP.ReqObserveCenter();
end
