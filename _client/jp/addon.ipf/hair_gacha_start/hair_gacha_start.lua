-- hair_gacha_start.lua --

function HAIR_GACHA_START_ON_INIT(addon, frame)

end

function HAIR_GACHA_OPEN(frame)
	local frame = ui.GetFrame("hair_gacha_start")
	
	local openBtn2 = GET_CHILD_RECURSIVELY(frame, "openBtn2")
	local button = GET_CHILD_RECURSIVELY(frame, "button")
	if openBtn2 ~= nil and button ~= nil then
		if config.GetServiceNation() ~= "KOR" then
			openBtn2:SetEnable(0)
			openBtn2:ShowWindow(0)
			button:SetMargin(0, 0, 0, 70);
		end
	end
end

function HAIR_GACHA_OK_BTN()
	local darkframe = ui.GetFrame("fulldark")
	local popupframe = ui.GetFrame("hair_gacha_popup")

	if darkframe == nil or popupframe == nil then
		return
	end

	if darkframe:IsVisible() == true or popupframe:IsVisible() == true then
		ui.SysMsg(ScpArgMsg('TryLater'));
		return
	end

	local frame = ui.GetFrame("hair_gacha_start");
    local skip_animation = GET_CHILD_RECURSIVELY(frame, "skip_animation");
    
	local type = frame:GetUserValue("ClassName");
	local isSkipAnimation = "NO";
	if skip_animation:IsChecked() == 1 then
		isSkipAnimation = "YES";
    end

    if config.GetServiceNation() == "TAIWAN" then
        if type == "Gacha_HairAcc_001" or type == "Gacha_HairAcc_010" then
            local aObj = GetMyAccountObj()
            local count = TryGetProp(aObj, "HAIRACC_CUBE_OPEN_COUNT", 0)
            local msgInfo = ScpArgMsg('HairAccCubeOpen{COUNT}', 'COUNT', count)

            ui.MsgBox(msgInfo, string.format('ui.Chat("/hairgacha %s %s")', type, isSkipAnimation), "None")
            ui.CloseFrame("hair_gacha_start")
            return
        end
    end
    
	ui.Chat(string.format("/hairgacha %s %s", type, isSkipAnimation));
	ui.CloseFrame("hair_gacha_start")
end

function CLIENT_GACHA_SCP(invItem)
	if invItem.isLockState == true then
		ui.SysMsg(ScpArgMsg("MaterialItemIsLock"))
		return
	end

	local itemobj = GetIES(invItem:GetObject());
    local gachaDetail = GetClass("GachaDetail", itemobj.ClassName);
    
	if gachaDetail.PreCheckScp ~= "None" then
		local scp = _G[gachaDetail.PreCheckScp];
		if scp() == "NO" then
			return;
		end
    end

	GACHA_START(gachaDetail)
end

function GACHA_START(gachaDetail)
	if gachaDetail == nil then
		return;
	end

	local cnt = gachaDetail.Count;
	if cnt ~= 1 and cnt ~= 11 then
		return;
	end

	local frame = ui.GetFrame("hair_gacha_start")
	frame:ShowWindow(0)
	frame:SetUserValue("ClassName", gachaDetail.ClassName);
	local item = GetClass("Item", gachaDetail.ClassName);

	--어떤 BG를 쓸 것인가
	--텍스트는 어떤걸?
	--버튼 어떤거?
	--카운트의 유무
	local hairbg = GET_CHILD_RECURSIVELY(frame,"bg_hair")
	local rboxbg = GET_CHILD_RECURSIVELY(frame,"bg_rbox")
    local hairText = GET_CHILD_RECURSIVELY(frame, 'richtext_2');
	local costumeText = GET_CHILD_RECURSIVELY(frame, 'richtext_3');
	local bg_count = GET_CHILD_RECURSIVELY(frame, 'bg_count');
	local btn = GET_CHILD_RECURSIVELY(frame,"button")
	local skip_animation = GET_CHILD_RECURSIVELY(frame, "skip_animation");

	local isSkipAnimation = skip_animation:GetUserValue("IsSkipAnimation");
	if isSkipAnimation ~= nil and isSkipAnimation ~= "None" then
		skip_animation:SetCheck(isSkipAnimation);
	end

	btn:SetVisible(1)
	local val = ScpArgMsg("GachaMsg", "Name", item.Name);
	btn:SetTextByKey("value", "{@st42b}"..val)

	if gachaDetail.GachaType == "hair" then
		hairbg:SetVisible(1);
		rboxbg:SetVisible(0);
		hairText:SetVisible(1);
		costumeText:SetVisible(0);
		if gachaDetail.OpenCountAllow == 'YES' then
			bg_count:SetVisible(1)
			local aObj = GetMyAccountObj()
			if aObj ~= nil then
				local countText = GET_CHILD_RECURSIVELY(frame, 'count_text');
				local count = TryGetProp(aObj, 'HAIRACC_CUBE_OPEN_COUNT', 0)
				countText:SetTextByKey('count', count)
			end
		else
			local countText = GET_CHILD_RECURSIVELY(frame, 'count_text');
			countText:SetVisible(0)
		end
	elseif gachaDetail.GachaType == "rbox" then
		hairbg:SetVisible(0);
		rboxbg:SetVisible(1);
		hairText:SetVisible(1);
		costumeText:SetVisible(0);
	elseif gachaDetail.GachaType == "costume" then
		hairbg:SetVisible(1);
		rboxbg:SetVisible(0);
		hairText:SetVisible(0);
		costumeText:SetVisible(1);
	end

	frame:ShowWindow(1)
end

function SCR_GACHA_SKIP_ANIMATION(frame)
	local skip_animation = GET_CHILD_RECURSIVELY(frame, "skip_animation");
	skip_animation:SetUserValue("IsSkipAnimation", skip_animation:IsChecked());
end