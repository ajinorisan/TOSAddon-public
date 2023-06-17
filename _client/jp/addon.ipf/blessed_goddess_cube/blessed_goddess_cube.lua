function BLESSED_CUBE_ON_INIT(addon, frame)
    addon:RegisterMsg("BLESSED_CUBE_NOT_ENABLE", "BLESSED_CUBE_CLOSE_ALL");
end

function BLESSED_CUBE_OPEN(frame)
	local frame = ui.GetFrame('blessed_goddess_cube');
	BLESSED_CUBE_LIST_UPDATE(frame);
	frame:ShowWindow(1);
	if config.GetServiceNation() ~= "KOR" then
        GET_CHILD_RECURSIVELY(frame,"openBtn2"):SetEnable(0)
        GET_CHILD_RECURSIVELY(frame,"openBtn2"):ShowWindow(0)
		GET_CHILD_RECURSIVELY(frame,"openBtn"):SetMargin(0, 0, 0, 40);
		session.shop.RequestUsedMedalTotal()
	end
end

function BLESSED_CUBE_CLOSE()

end

function BLESSED_CUBE_LIST_UPDATE(frame)
    local cubeListBox = GET_CHILD_RECURSIVELY(frame, 'cubeListBox');
    local defaultSetted = false;
    local ITEM_LIST_INTERVAL = frame:GetUserConfig('ITEM_LIST_INTERVAL');
    local gachaList, cnt = GetClassList("GachaDetail");
    local pc = GetMyPCObject()

    for i = 0, cnt-1 do
        local info = GetClassByIndexFromList(gachaList, i);

        if info ~= nil then
            if TryGetProp(info, "RewardGroup", "None") == "Gacha_Blessed_CUBE_001" then
                local cube = cubeListBox:CreateOrGetControlSet("leticia_cube_list", 'LIST_'..info.ClassName, 0, 0);
                cube = AUTO_CAST(cube);
                
                local pic = GET_CHILD_RECURSIVELY(cube, 'iconPic');
                local itemNameText = cube:GetChild('itemNameText');
                local priceText = GET_CHILD_RECURSIVELY(cube, 'priceText');
                local tpText = GET_CHILD_RECURSIVELY(cube, 'tpText');
                local TP_IMG = frame:GetUserConfig('TP_IMG');
                local itemCls = GetClass('Item', info.ItemClassName);
                pic:SetImage(itemCls.Icon);
                if info.ConsumeType == 'TP' then                
                    tpText:SetTextByKey('consumeType', TP_IMG);
                    tpText:SetTextByKey('typeName', 'TP');
                    priceText:SetText(info.Price);                    
                elseif info.ConsumeType == 'ITEM' then
                    local consumeItem = GetClass('Item', info.ConsumeItem);
                    tpText:SetTextByKey('consumeType', consumeItem.Icon);
                    tpText:SetTextByKey('typeName', consumeItem.Name);
                    priceText:SetText(math.floor(info.ConsumeItemCnt));
                end
                itemNameText:SetText(itemCls.Name);
                itemNameText:AdjustFontSizeByWidth(280);
                itemNameText:Invalidate();

                cube:SetEventScript(ui.LBUTTONDOWN, 'BLESSED_CUBE_CHANGE_INFO');
                cube:SetEventScriptArgString(ui.LBUTTONDOWN, info.ItemClassName);
                cube:SetUserValue('GACHA_DETAIL_CLASS_NAME', info.ClassName);

                if defaultSetted == false then
                    BLESSED_CUBE_CHANGE_INFO(cubeListBox, cube, info.ItemClassName);
                    defaultSetted = true;
                end
            end
        end
    end
    GBOX_AUTO_ALIGN(cubeListBox, 0, ITEM_LIST_INTERVAL, 0, true, false);
end

function BLESSED_CUBE_CHANGE_INFO(cubeListBox, ctrlSet, argStr)
    local itemCls = GetClass("Item", argStr);
    local gachaClassName = ctrlSet:GetUserValue('GACHA_DETAIL_CLASS_NAME');
    local gachaCls = GetClass('GachaDetail', gachaClassName);

    local topframe = cubeListBox:GetTopParentFrame();
    local TP_IMG = topframe:GetUserConfig('TP_IMG');
    local cubePic = GET_CHILD_RECURSIVELY(topframe, 'cubePic');
    local cubeText = GET_CHILD_RECURSIVELY(topframe, 'cubeText');
    local openBtn = GET_CHILD_RECURSIVELY(topframe, 'openBtn');
    cubePic:SetImage(itemCls.Icon);
    cubeText:SetText(itemCls.Name);
    if gachaCls.ConsumeType == 'TP' then
        openBtn:SetTextByKey('icon', TP_IMG);
    else
        openBtn:SetTextByKey('icon', itemCls.Icon);
    end
    topframe:SetUserValue("CubeName", itemCls.ClassName);
    topframe:SetUserValue('GACHA_DETAIL_NAME', gachaClassName);       
end

function BLESSED_CUBE_OPEN_BUTTON(frame, ctrl, argStr, argNum, _gachaClassName, _cubeName)
	local gachaClassName = frame:GetUserValue('GACHA_DETAIL_NAME');
	if _gachaClassName ~= nil then
		gachaClassName = _gachaClassName;
	end
	local cubeName = frame:GetUserValue("CubeName");
	if _cubeName ~= nil then
		cubeName = _cubeName;
	end

	local gachaCls = GetClass('GachaDetail', gachaClassName);    
	local cubeItemCls = GetClass('Item', cubeName);
	local TP_IMG = frame:GetUserConfig('TP_IMG');
	local clMsg = '';
    
	clMsg = string.format('{@st66d}{s18}{img %s 40 40} %d{/}{/}', TP_IMG, gachaCls.Price);
        
	local pc = GetMyPCObject()
	local aobj = GetMyAccountObj(pc)
    
	local skip_animation = GET_CHILD_RECURSIVELY(frame, "skip_animation");
    
	if frame:GetUserIValue('OPEN_MSG_BOX') == 0 then
		local msg = string.format("%s{nl} {nl}{#85070a}%s", ScpArgMsg('BlessedCubeGacha{CONSUME}', 'CONSUME', clMsg), ClMsg('ContainWarningItem'))
		cubeName = tostring(cubeName) .. "/" .. tostring(skip_animation:GetUserValue("IsSkipAnimation"))
		local yesScp = string.format('REQ_BLESSED_CUBE_OPEN("%s")', cubeName)
        
		ui.MsgBox(msg, yesScp, 'BLESSED_CUBE_CLOSE_ALL()');
		frame:SetUserValue('OPEN_MSG_BOX', 1);
		ui.SetHoldUI(true);
	end
end

function REQ_BLESSED_CUBE_OPEN(cubeItemName)
    pc.ReqExecuteTx('EXECUTE_BLESSED_GACHA', cubeItemName)

    BLESSED_CUBE_MSG_BOX_RESET();
    ui.CloseFrame('blessed_goddess_cube');
end

function BLESSED_CUBE_MSG_BOX_RESET()
    local leticia_cube = ui.GetFrame('blessed_goddess_cube');
    leticia_cube:SetUserValue('OPEN_MSG_BOX', 0);
    ui.SetHoldUI(false);
end

function BLESSED_CUBE_CLOSE_ALL()
    ui.CloseFrame('fulldark');
    BLESSED_CUBE_MSG_BOX_RESET();
end


function BLESSED_CUBE_ITEM_LIST_BUTTON()
    if config.GetServiceNation() ~= "KOR" then
        return
    end

	local textmsg = string.format("[ %s ]{nl}%s", '{@st66d_y}'..ClMsg('ContainWarningItem2')..'{/}{/}', '{nl} {nl}'..ScpArgMsg("ContainWarningItem_URL"))
	ui.MsgBox(textmsg, 'BLESSED_CUBE_ITEM_LIST_BUTTON_URL', "None")
end

function BLESSED_CUBE_ITEM_LIST_BUTTON_URL()
    if config.GetServiceNation() ~= "KOR" then
        return
    end

	login.OpenURL('http://iteminfo.nexon.com/probability/games/tos')
end

function SCR_BLESSED_CUBE_SKIP_ANIMATION(frame)
	local skip_animation = GET_CHILD_RECURSIVELY(frame, "skip_animation");
	skip_animation:SetUserValue("IsSkipAnimation", skip_animation:IsChecked());
end