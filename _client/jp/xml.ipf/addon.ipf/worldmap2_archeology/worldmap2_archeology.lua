-- worldmap2_archeology.lua

function WORLDMAP2_ARCHEOLOGY_ON_INIT(addon, frame)
end

function OPEN_WORLDMAP2_ARCHEOLOGY(frame)
	WORLDMAP2_ARCHEOLOGY_SET_MAP(frame)
end

function WORLDMAP2_ARCHEOLOGY_SET_MAP(frame)
	local missionGb = GET_CHILD_RECURSIVELY(frame, "missions_gb")
	local aObj = GetMyAccountObj()
	local index = 0;
	missionGb:RemoveAllChild()
	for i = 1, max_archeology_map_count do
		local mapName = TryGetProp(aObj, "archeology_map_"..i, "None")
		local mapCls = GetClass("Map", mapName)
		local is_complete = TryGetProp(aObj, 'archeology_map_' .. i .. '_complete', 0)
		if mapCls ~= nil and is_complete == 0 then
			local mapCtrl = missionGb:CreateOrGetControlSet("archeology_mission_map_set", "ARCHEOLOGY_MAP_"..i, 3, 80*index)
			local title = GET_CHILD(mapCtrl, "title_text")
			local tokenBtn = GET_CHILD(mapCtrl, "token_btn")
			title:SetText("{@st102_16}I "..mapCls.Name)

			local isTokenState = session.loginInfo.IsPremiumState(ITEM_TOKEN)
			local imageName = ""
	
			if isTokenState == true and GET_TOKEN_WARP_COOLDOWN() == 0 then
				imageName = "{img worldmap2_token_gold 38 38} {@st101lightbrown_16}"
			else
				imageName = "{img worldmap2_token_gray 38 38} {@st101lightbrown_16}"
			end
	
			tokenBtn:SetText(imageName..ScpArgMsg("TokenWarp"))
			tokenBtn:SetUserValue("MAP_NAME", mapName)
			index = index + 1
		end
	end
end

function WORLDMAP2_ARCHEOLOGY_CLICK_TOKEN_BTN(parent, self)
    WORLDMAP2_TOKEN_WARP(self:GetUserValue("MAP_NAME"))
end