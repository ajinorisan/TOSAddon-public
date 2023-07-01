

function GET_MAP_POS(frame, mapprop, x, y, width, height)
	
	if frame:GetName() == "map" then
		local MapPos = mapprop:WorldPosToMinimapPos(x, y, m_mapWidth, m_mapHeight);
		 return m_offsetX + MapPos.x, m_offsetY + MapPos.y, width, height;
	else
		
		local cursize = GET_MINIMAPSIZE();
		local pictureui  = GET_CHILD(frame:GetTopParentFrame(), "map", "ui::CPicture");	
		local minimapw = pictureui:GetImageWidth() * (100 + cursize) / 100;
		local minimaph = pictureui:GetImageHeight() * (100 + cursize) / 100;
		local dd = (100 + cursize) / 100;
		local MapPos = mapprop:WorldPosToMinimapPos(x, y, minimapw, minimaph);
		return MapPos.x, MapPos.y, width * dd, height * dd;
	end
end

function MAP_MON_MINIMAP(frame, msg, argStr, argNum, info)
	local isMinimap = false;
	if frame:GetTopParentFrame():GetName() == "minimap" then
		frame = GET_CHILD(frame, 'npclist', 'ui::CGroupBox');
		isMinimap = true;
	end

	local ctrlName = "_MONPOS_" .. info.handle;
	local monPic = frame:GetChild(ctrlName);
	if monPic ~= nil then
		MAP_MON_MINIMAP_SETPOS(frame, info);
		return;
	end

	local SIZE = 40;
	if info.isDot == true then
		SIZE = 14;
	end

	local ctrlName = "_MONPOS_" .. info.handle;
	monPic = frame:CreateOrGetControl('picture', ctrlName, 0, 0, SIZE, SIZE);
	tolua.cast(monPic, "ui::CPicture");
	if false == monPic:HaveUpdateScript("_MONPIC_AUTOUPDATE") then
		monPic:RunUpdateScript("_MONPIC_AUTOUPDATE", 1);
	end

	monPic:SetUserValue("W", SIZE);
	monPic:SetUserValue("H", SIZE);
	monPic:SetUserValue("HANDLE", info.handle);
	monPic:SetUserValue("EXTERN", "YES");
	monPic:SetUserValue("EXTERN_PIC", "YES");

	if isMinimap == true then
		local cursize = GET_MINIMAPSIZE();
		local dd = (100 + cursize) / 100;
		dd = 1 / dd;
		dd = CLAMP(dd, 0.5, 1.5);
		monPic:SetScale(dd, dd);
	end

	local imgName = GET_MAP_MON_MINIMAP_IMAGENAME(info)
	monPic:SetImage(imgName);
	monPic:SetEnableStretch(1);
	monPic:ShowWindow(1);

	MAP_MON_MINIMAP_SETPOS(frame, info);
end

function GET_MAP_MON_MINIMAP_IMAGENAME(info)
	local isPC = info.type == 0;
	if isPC then
		return GET_JOB_ICON(info.job);
	end
	if info.useIcon == true then
		if info.isDot == true then
			return "monster_notice_dot"
		else
			local monCls = GetClassByType("Monster", info.type);
			return monCls.MinimapIcon
		end
	end
	
	local myTeam = GET_MY_TEAMID();
	if info.teamID == 0 then
		return "fullyellow";
	elseif info.teamID ~= myTeam then
		return "fullred";
	else
		return "fullblue";
	end
end

function MAP_MON_MINIMAP_SETPOS(frame, info)
	
	_MAP_MON_MINIMAP_SETPOS(frame, info.handle, info.x, info.z);

	local ctrlName = "_MONPOS_" .. info.handle;
	local monPic = frame:GetChild(ctrlName);
	monPic:SetUserValue("POS_X", info.x);
	monPic:SetUserValue("POS_Z", info.z);	
	
end

function _MAP_MON_MINIMAP_SETPOS(frame, handle, x, z)

	local ctrlName = "_MONPOS_" .. handle;
	local monPic = frame:GetChild(ctrlName);
	local mapprop = session.GetCurrentMapProp();
	local width = monPic:GetUserIValue("W");
	local height = monPic:GetUserIValue("H");
	local XC, YC, sx, sy = GET_MAP_POS(frame, mapprop, x, z, width, height);
	
	XC = XC - sx / 2;
	YC = YC - sy / 2;
	monPic:SetOffset(XC, YC);
	monPic:Resize(sx, sy);

	ctrlName = "_MONPOS_T_" .. handle;
	local textC = frame:GetChild(ctrlName);
	if textC ~= nil then
		textC:SetOffset(XC + 0, YC + 0);
		textC:Resize(sx, sy);
	end

	if frame:GetTopParentFrame():GetName() == "minimap" then
		local cursize = GET_MINIMAPSIZE();
		local dd = (100 + cursize) / 100;
		dd = 1 / dd;
		dd = CLAMP(dd, 0.5, 1.5);
		monPic:SetScale(dd, dd);
	end

end

function ON_MON_MINIMAP_END(frame, msg, argStr, handle)

	if frame:GetName() == "minimap" then
		frame = GET_CHILD(frame, 'npclist', 'ui::CGroupBox');
	end

	frame:RemoveChild(string.format("_MONPOS_%d", handle));
	frame:RemoveChild(string.format("_MONPOS_T_%d", handle));
	frame:Invalidate();

end

function _MONPIC_AUTOUPDATE(ctrl)
	local handle = ctrl:GetUserIValue("HANDLE");	
	local actor = world.GetActor(handle);
	if actor ~= nil then
		local actorPos = actor:GetPos();
		ctrl:SetUserValue("POS_X", actorPos.x);
		ctrl:SetUserValue("POS_Y", actorPos.z);
		_MAP_MON_MINIMAP_SETPOS(ctrl:GetParent(), handle, actorPos.x, actorPos.z);
		return 1;
	end

	if ctrl:GetTopParentFrame():GetName() == "minimap" then
		local lastSize = ctrl:GetUserIValue("LASTSIZE");
		local cursize = GET_MINIMAPSIZE();
		if lastSize ~= cursize then
			ctrl:SetUserValue("LASTSIZE", cursize);
			
			local x = ctrl:GetUserIValue("POS_X");
			local y = ctrl:GetUserIValue("POS_Y");
			_MAP_MON_MINIMAP_SETPOS(ctrl:GetParent(), handle, x, y);
			ctrl:GetTopParentFrame():Invalidate();
		end
	end

	return 1;
end