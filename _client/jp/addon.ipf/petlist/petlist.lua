-- petlist.lua

function PETLIST_ON_INIT(addon, frame)
	addon:RegisterMsg('UPDATE_PETLIST', 'UPDATE_RIDE_PETLIST')
end

function PETLIST_OPEN(petinfo_frame)
	if petinfo_frame == nil then
		return
	end

	local petListBtn = GET_CHILD_RECURSIVELY(petinfo_frame, "petListBtn", "ui::CButton");
	if petListBtn == nil then
	return
	end

	local x = petinfo_frame:GetGlobalX() + petinfo_frame:GetWidth() - 5;
	local y = petListBtn:GetGlobalY();
	local frame = ui.GetFrame("petlist");	
	
	-- frame이 현재 보여지는 상태면 닫는다.
	if frame:IsVisible() == 1 then
		CLOSE_PETLIST()
	else 
		UPDATE_RIDE_PETLIST(frame);
		frame:SetGravity(ui.LEFT, ui.TOP);
		frame:SetOffset(x,y);
		frame:ShowWindow(1);
	end

end

function ON_OPEN_PETLIST()
	local frame = ui.GetFrame("petlist");
	frame:ShowWindow(1);
	frame:SetGravity(ui.RIGHT, ui.BOTTOM);
	frame:SetMargin(0, 0, 40, 70);
	UPDATE_RIDE_PETLIST(frame);
end

function CLOSE_PETLIST()
	local frame = ui.GetFrame("petlist");	
	frame:ShowWindow(0);
end

function UPDATE_RIDE_PETLIST(frame, msg, argstr)
	local gb_petlist = frame:GetChild("gb_petlist");
	DESTROY_CHILD_BYNAME(gb_petlist, "_CTRLSET_");	
	local petList = session.pet.GetPetInfoVec();
	local x = 0;
	local y = 0;

	local ridepetlist, cnt = GetClassList("ride_pet")
	local aObj = GetMyAccountObj()
	local myPcEtc = GetMyEtcObject()
	local selectedPet = myPcEtc.SelectedRidePet

	for i = 1, cnt-1 do
		local cls = GetClassByIndexFromList(ridepetlist, i)
		local isHave = TryGetProp(aObj, cls.AccProp);

		if isHave ~= "None" then
			local ctrlset = gb_petlist:CreateControlSet('petlist_ctrl', "_CTRLSET_"..cls.ClassID, x, y);
			y = y + ui.GetControlSetAttribute("petlist_ctrl", "height");
			local slot = GET_CHILD_RECURSIVELY(ctrlset, "slot");

			local icon = CreateIcon(slot);
			icon:SetImage(cls.Icon)
			icon:SetColorTone("FFFFFFFF");

			local curTime = imcTime.GetAppTime();	
			local startTime = frame:GetUserIValue("_CUSTOM_CD_START");
			if curTime - startTime < RIDEPET_SELECT_REQUEST_WAIT_TIME + 1 then
				PETLIST_REQ_CD_SET(frame, icon)
			end

			local name = GET_CHILD_RECURSIVELY(ctrlset, "name");
			name:SetTextByKey("value", cls.Name)

			local desc = GET_CHILD_RECURSIVELY(ctrlset, "desc");
			desc:SetTextByKey("value", cls.Desc);
			desc:SetTextTooltip(cls.AddDesc);

			local radioBtn = GET_CHILD_RECURSIVELY(ctrlset, "radioBtn");

			if cls.ClassID == selectedPet then
				local effectDesc = GET_CHILD_RECURSIVELY(frame,"effectDesc");
				effectDesc:SetTextByKey("effect", '- '..cls.Desc)
				effectDesc:SetTextTooltip(cls.AddDesc);
				radioBtn:SetCheck(true);
			else
				radioBtn:SetCheck(false);
			end

			if argstr == 'enable'  then
				radioBtn:SetEnable(1)
			elseif argstr == 'disable' then
				radioBtn:SetEnable(0)
			elseif IsBuffApplied(GetMyPCObject(), "RIDE_PET_COMMON_BUFF_1") == "YES" then
				radioBtn:SetEnable(0)
			else
				radioBtn:SetEnable(1)
			end

			ctrlset:SetUserValue("CLASS_ID", cls.ClassID);

		end
	end

	if selectedPet == 0 then
		local effectDesc = GET_CHILD_RECURSIVELY(frame,"effectDesc");
		effectDesc:SetTextByKey("effect", '- '.. ClMsg('RidePet_Not_Selected'))
		effectDesc:SetTextTooltip('');
	end

end

function PETLIST_SELECT_RIDE_PET(parent, self)
	local frame = parent:GetTopParentFrame()
	local myPcEtc = GetMyEtcObject()
	local selectedPet = myPcEtc.SelectedRidePet
	local clsId = parent:GetUserIValue("CLASS_ID")
	local clickedRadioBtn = GET_CHILD_RECURSIVELY(parent, "radioBtn");

	if clickedRadioBtn:IsEnable() == 0 then
		return
	end
	local curTime = imcTime.GetAppTime();	
    local startTime = frame:GetUserIValue("_CUSTOM_CD_START");
	if selectedPet ~= 0 then 
		if selectedPet == clsId then
			local effectDesc = GET_CHILD_RECURSIVELY(frame,"effectDesc");
			effectDesc:SetTextByKey("effect", '')
			myPcEtc.SelectedRidePet = 0
			clickedRadioBtn:SetCheck(false)
			
			ride_pet.RequestSelectRidePet(0)

			local effectDesc = GET_CHILD_RECURSIVELY(frame,"effectDesc");
			effectDesc:SetTextByKey("effect", '- '..ClMsg('RidePet_Not_Selected'))
			effectDesc:SetTextTooltip('');

			return;
		else
			local ctrlset = GET_CHILD_RECURSIVELY(frame, "_CTRLSET_"..selectedPet)
			local radioBtn = GET_CHILD_RECURSIVELY(ctrlset, "radioBtn")
			radioBtn:SetCheck(false)
		end
	end


	if curTime - startTime > RIDEPET_SELECT_REQUEST_WAIT_TIME + 1 then
		frame:SetUserValue("_CUSTOM_CD_START", curTime);

		local ctrlset = GET_CHILD_RECURSIVELY(frame, "_CTRLSET_"..clsId)
		local radioBtn = GET_CHILD_RECURSIVELY(ctrlset, "radioBtn")
		radioBtn:SetCheck(true)
	
		local cls = GetClassByType("ride_pet", clsId)
		local effectDesc = GET_CHILD_RECURSIVELY(frame,"effectDesc");
		effectDesc:SetTextByKey("effect", '- '..cls.Desc)
		effectDesc:SetTextTooltip(cls.AddDesc);
		myPcEtc.SelectedRidePet = clsId;
	end
	
	ride_pet.RequestSelectRidePet(clsId)
end

function PETLIST_REQ_CD_SET(frame, icon)
    icon:SetUserValue("_CUSTOM_CD_START", frame:GetUserValue("_CUSTOM_CD_START"));
    icon:SetUserValue("_CUSTOM_CD", RIDEPET_SELECT_REQUEST_WAIT_TIME+1);
    icon:SetOnCoolTimeUpdateScp('_ICON_CUSTOM_COOLDOWN');
end