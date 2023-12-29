-- itemtooltip.lua

-- tooltip.xml에 적혀있는, 툴팁 관련 가장 처음 실행되는 루아 함수. 여기서 아이템의 종류에 따라 각각 다른 전용 툴팁 함수들을 호출한다. 종류되는 함수 명은 item클래스의 CT_ToolTipScp를 따름

function ON_REFRESH_ITEM_TOOLTIP()	
	local wholeitem = ui.GetTooltip("wholeitem")
	if wholeitem ~= nil then
		wholeitem:RefreshTooltip();
	end

    local wholeitem_link = ui.GetFrame("wholeitem_link")
	tolua.cast(wholeitem_link, "ui::CTooltipFrame");
	if wholeitem_link ~= nil then
		wholeitem_link:RefreshTooltip();
	end

	local item_tooltip = ui.GetFrame("item_tooltip")
	tolua.cast(item_tooltip, "ui::CTooltipFrame");
	if item_tooltip ~= nil then
		item_tooltip:RefreshTooltip();
	end
end


function UPDATE_ITEM_CABINET_TOOLTIP(tooltipframe, strarg,curLv,itemtype)
	tolua.cast(tooltipframe, "ui::CTooltipFrame");
	local itemObj, isReadObj = nil;	

	itemObj, isReadObj = GET_TOOLTIP_ITEM_OBJECT(strarg, 0, itemtype);
	--Main Info
	tooltipframe:Resize(tooltipframe:GetOriginalWidth(), tooltipframe:GetOriginalHeight());
	tooltipframe:CheckSize()
	INIT_ITEMTOOLTIPFRAME_CHILDS(tooltipframe)

	local class = itemObj
	local ToolTipScp = _G['ITEM_TOOLTIP_CABINET_GEM_RELIC'];
	SetExProp_Str(itemObj, 'where', strarg); 
	ToolTipScp(tooltipframe, class, strarg, "mainframe", curLv);	

	if itemObj == nil then
		return;
	end

	if isReadObj == 1 then
		DestroyIES(itemObj);
	end

	ITEMTOOLTIPFRAME_RESIZE(tooltipframe); 
end

function UPDATE_ITEM_TOOLTIP(tooltipframe, strarg, numarg1, numarg2, userdata, tooltipobj, noTradeCnt)	
	tolua.cast(tooltipframe, "ui::CTooltipFrame");
	local itemObj, isReadObj = nil;	
	if tooltipobj ~= nil then
		itemObj = tooltipobj;
		isReadObj = 0;
	else
		itemObj, isReadObj = GET_TOOLTIP_ITEM_OBJECT(strarg, numarg2, numarg1);
		
	end
	if itemObj == nil then
		return;
	end
	if nil ~= itemObj and itemObj.GroupName == "Unused" then
		tooltipframe:Resize(1, 1);
        return;
	end
	
	local isForgeryItem = false;	
	if strarg == 'forgery' then
	 	isForgeryItem = true;
	elseif string.find(strarg, 'pcbang_rental') ~= nil and itemObj ~= nil then
		local strList = StringSplit(strarg, '#');
		itemObj.Reinforce_2 = strList[2]
		itemObj.Transcend = strList[3]
	end	
	tooltipframe:SetUserValue('TOOLTIP_ITEM_GUID', numarg2);
	local recipeitemobj = nil
	local recipeid = IS_RECIPE_ITEM(itemObj)
	-- 레시피 아이템 쪽
	if recipeid ~= 0 then
		local recipeIES = CreateIESByID('Item', recipeid);
		if recipeIES ~= nil then
			recipeitemobj = recipeIES
			local refreshScp = recipeitemobj.RefreshScp;
			if refreshScp ~= "None" then				
				refreshScp = _G[refreshScp];				
				refreshScp(recipeitemobj);
			end	
		end
	end
	
	--Main Info
	tooltipframe:Resize(tooltipframe:GetOriginalWidth(), tooltipframe:GetOriginalHeight());
	tooltipframe:CheckSize()
	INIT_ITEMTOOLTIPFRAME_CHILDS(tooltipframe)

	if isReadObj == 0 then
		if 1 == IS_DRAG_RECIPE_ITEM(itemObj) then
		
			local tabTxt = "";
			tabTxt, numarg1 = GET_DRAG_RECIPE_INFO(itemObj);
			isReadObj = 1;
			local tabCtrl = GET_CHILD(tooltipframe, "tabText", "ui::CTabControl");
			tabCtrl:ChangeCaption(0, tabText);
			tabCtrl:ShowWindow(1);
		end
	end

	local recipeclass = recipeitemobj;

	-- 컬렉션에서 툴팁을 띄울때는 제작서는 제작서만 보여준다. 
	if recipeclass ~= nil and strarg ~= 'collection' then
		local ToolTipScp = _G[ 'ITEM_TOOLTIP_' .. recipeclass.ToolTipScp];
		ToolTipScp(tooltipframe, recipeclass, strarg, "usesubframe_recipe");
		DestroyIES(recipeitemobj);
    end
    
	if itemObj == nil then
		return;
	end
	
	local needAppraisal = TryGetProp(itemObj, "NeedAppraisal");
	local needRandomOption = TryGetProp(itemObj, "NeedRandomOption");
    local showAppraisalPic = false;
    
	if needAppraisal ~= nil or needRandomOption ~= nil then
        if needAppraisal == 1 or needRandomOption == 1 then
    		DRAW_APPRAISAL_PICTURE(tooltipframe);
    		showAppraisalPic = true;
		end
	end
	
	-- 메인 프레임. 즉 주된 툴팁 표시.
	if isReadObj == 1 then -- IES가 없는 아이템. 가령 제작서의 완성 아이템 표시 등
		local class = itemObj;
		if class ~= nil then
			local ToolTipScp = _G['ITEM_TOOLTIP_' .. class.ToolTipScp];
			ToolTipScp(tooltipframe, class, strarg, "mainframe", isForgeryItem);
		end		
	else
		local ToolTipScp = _G['ITEM_TOOLTIP_' .. itemObj.ToolTipScp];
		if nil == noTradeCnt then
			noTradeCnt = 0
		end
		SetExProp_Str(itemObj, 'where', strarg); -- scp 호출전에 ex prop 설정.
		ToolTipScp(tooltipframe, itemObj, strarg, "mainframe", noTradeCnt);
	end

	if isReadObj == 1 then
		DestroyIES(itemObj);
	end

	ITEMTOOLTIPFRAME_ARRANGE_CHILDS(tooltipframe, showAppraisalPic);
	ITEMTOOLTIPFRAME_RESIZE(tooltipframe);    

end

function ITEMTOOLTIPFRAME_ARRANGE_CHILDS(tooltipframe, showAppraisalPic)

	local cvalueGBox = GET_CHILD(tooltipframe, 'changevalue','ui::CGroupBox')
	if showAppraisalPic == true then
		cvalueGBox =  GET_CHILD(tooltipframe, 'appraisal','ui::CGroupBox');
	end
	local cvalueGBoxheight = cvalueGBox:GetHeight()
	local childCnt = tooltipframe:GetChildCount();
	local minY = option.GetClientHeight();
	local arrange = false;
	for i = 0 , childCnt - 1 do
		local chld = tooltipframe:GetChildByIndex(i);
		if chld:GetName() ~= 'changevalue' then
			local targetY = chld:GetY() + cvalueGBoxheight;			
			local diff = targetY + chld:GetHeight() - option.GetClientHeight();
			if diff > 0 then
				arrange = true;
				targetY = targetY - diff;
			end

			chld:SetOffset(chld:GetX(), targetY);

			if minY > targetY then
				minY = targetY;
			end
		end
	end

	if arrange == true then
		-- 비교 툴팁 위치 맞춰주기
		local equip_main = tooltipframe:GetChild('equip_main');
		local equip_sub = tooltipframe:GetChild('equip_sub');
		local mainY = equip_main:GetY();
		local subY = equip_sub:GetY();
		if mainY > subY then
			equip_main:SetOffset(equip_main:GetX(), subY);
		elseif mainY < subY then
			equip_sub:SetOffset(equip_sub:GetX(), mainY);
		end

		-- 비교 말풍선 위치 조정
		local changevalue = tooltipframe:GetChild('changevalue');
		local appraisalOffset = 0;
		if showAppraisalPic == true then
			changevalue = tooltipframe:GetChild('appraisal');
			local marginRect = changevalue:GetMargin();
			appraisalOffset = marginRect.top;
		end
		changevalue:SetOffset(changevalue:GetX(), minY - cvalueGBoxheight + appraisalOffset);
	end
end

function INIT_ITEMTOOLTIPFRAME_CHILDS(tooltipframe)
	local childCnt = tooltipframe:GetChildCount();
	for i = 0 , childCnt - 1 do
		local chld = tooltipframe:GetChildByIndex(i);

		chld:RemoveAllChild()
		chld:SetOffset(chld:GetOriginalX(), chld:GetOriginalY());

		if chld:GetName() ~= 'closebtn' then
			chld:Resize(chld:GetOriginalWidth(), 0);
		end
	end
end

function ITEMTOOLTIPFRAME_RESIZE(tooltipframe)

	local min_x = 9999;
	local max_x = -9999;

	local min_y = 9999;
	local max_y = -9999;

	local childCnt = tooltipframe:GetChildCount();
	for i = 0 , childCnt - 1 do
		local chld = tooltipframe:GetChildByIndex(i);
		if chld:GetHeight() > 0 then
			local chldminx = chld:GetX()
			local chldmaxx = chld:GetX() + chld:GetWidth()
			local chldminy = chld:GetY()
			local chldmaxy = chld:GetY() + chld:GetHeight()

			if chldminx < min_x then
				min_x = chldminx
			end
			if chldmaxx > max_x then
				max_x = chldmaxx
			end
			if chldminy < min_y then
				min_y = chldminy
			end
			if chldmaxy > max_y then
				max_y = chldmaxy
			end

		end
	end

	local childCnt = tooltipframe:GetChildCount();
	for i = 0 , childCnt - 1 do
		local chld = tooltipframe:GetChildByIndex(i);		
		chld:SetOffset(chld:GetX() - min_x, chld:GetY() - min_y);
		
		if chld:GetName() == 'closebtn' then
			chld:SetOffset(chld:GetX(), chld:GetOriginalY() + 5);
		end
	end

	tooltipframe:Resize(max_x-min_x, max_y-min_y);
end

--상점에서 가격 표시
function DRAW_SELL_PRICE(tooltipframe, invitem, yPos, mainframename)
    
	local itemProp = geItemTable.GetPropByName(invitem.ClassName);
    if itemProp:IsEnableShopTrade() == false then
        return yPos
    end

	local gBox = GET_CHILD(tooltipframe, mainframename,'ui::CGroupBox')
	gBox:RemoveChild('tooltip_sellinfo');

	local tooltip_sellinfo_CSet = gBox:CreateControlSet('tooltip_sellinfo', 'tooltip_sellinfo', 0, yPos);
	tolua.cast(tooltip_sellinfo_CSet, "ui::CControlSet");

	local sellprice_text = GET_CHILD(tooltip_sellinfo_CSet,'sellprice','ui::CRichText')
	sellprice_text:SetTextByKey("silver", GET_COMMAED_STRING(geItemTable.GetSellPrice(itemProp)));
	
	local BOTTOM_MARGIN = tooltipframe:GetUserConfig("BOTTOM_MARGIN"); -- 맨 아랫쪽 여백
	tooltip_sellinfo_CSet:Resize(gBox:GetWidth(), tooltip_sellinfo_CSet:GetHeight() + BOTTOM_MARGIN);

	local height = gBox:GetHeight() + tooltip_sellinfo_CSet:GetHeight();
	gBox:Resize(gBox:GetWidth(), height);
	return yPos + tooltip_sellinfo_CSet:GetHeight();
end

function DRAW_REMAIN_LIFE_TIME(tooltipframe, invitem, yPos, mainframename)	
	local itemProp = geItemTable.GetPropByName(invitem.ClassName);
    if itemProp:IsEnableShopTrade() == false and itemProp.LifeTime == 0 then
        return yPos
    end
    
	local gBox = GET_CHILD(tooltipframe, mainframename,'ui::CGroupBox')
	gBox:RemoveChild('tooltip_lifeTimeinfo');	

	local tooltip_lifeTimeinfo_CSet = gBox:CreateControlSet('tooltip_lifeTimeinfo', 'tooltip_lifeTimeinfo', 0, yPos);
	tolua.cast(tooltip_lifeTimeinfo_CSet, "ui::CControlSet");

	local expire_datetime = GET_ITEM_EXPIRE_TIME(invitem)
	
	local lifeTime_text = GET_CHILD(tooltip_lifeTimeinfo_CSet,'lifeTime','ui::CRichText');
	if string.find(invitem.ItemLifeTime, "None") ~= nil and expire_datetime == 'None' then
		local timeTxt = GET_TIME_TXT(invitem.LifeTime);
		lifeTime_text:SetTextByKey("p_LifeTime", timeTxt );				
	else
		if expire_datetime == 'None' then
			local sysTime = geTime.GetServerSystemTime();
			local endTime = imcTime.GetSysTimeByStr(invitem.ItemLifeTime);
			local difSec = imcTime.GetDifSec(endTime, sysTime);
			lifeTime_text:SetUserValue("REMAINSEC", difSec);
			lifeTime_text:SetUserValue("STARTSEC", imcTime.GetAppTime());
			lifeTime_text:RunUpdateScript("SHOW_REMAIN_LIFE_TIME");		
		else
			local sysTime = geTime.GetServerSystemTime();
			local endTime = imcTime.GetSysTimeByYYMMDDHHMMSS(expire_datetime);
			local difSec = imcTime.GetDifSec(endTime, sysTime);
			lifeTime_text:SetUserValue("REMAINSEC", difSec);
			lifeTime_text:SetUserValue("STARTSEC", imcTime.GetAppTime());
			lifeTime_text:RunUpdateScript("SHOW_REMAIN_LIFE_TIME");		
		end
	end

	local BOTTOM_MARGIN = tooltipframe:GetUserConfig("BOTTOM_MARGIN"); -- 맨 아랫쪽 여백
	tooltip_lifeTimeinfo_CSet:Resize(tooltip_lifeTimeinfo_CSet:GetWidth(),tooltip_lifeTimeinfo_CSet:GetHeight() + BOTTOM_MARGIN);
	
	local height = gBox:GetHeight() + tooltip_lifeTimeinfo_CSet:GetHeight();
	gBox:Resize(gBox:GetWidth(), height);
	return tooltip_lifeTimeinfo_CSet:GetY() + tooltip_lifeTimeinfo_CSet:GetHeight()
end;

function SHOW_REMAIN_LIFE_TIME(ctrl)
	local elapsedSec = imcTime.GetAppTime() - ctrl:GetUserIValue("STARTSEC");
	local startSec = ctrl:GetUserIValue("REMAINSEC");
	startSec = startSec - elapsedSec;
	if 0 > startSec then
		ctrl:SetText(ScpArgMsg("LessThanItemLifeTime"));
		ctrl:SetFontName("red_18");
		ctrl:StopUpdateScript("SHOW_REMAIN_LIFE_TIME");
		return 0;
	end 
	
	local timeTxt = GET_TIME_TXT(startSec);
	ctrl:SetTextByKey("p_LifeTime", timeTxt );
	return 1;
end

function GET_ITEM_TOOLTIP_DESC(obj, desc)

	local invDesc = GET_ITEM_DESC_BY_TOOLTIP_VALUE(obj);	
	local byDescColumn = TryGetProp(obj, 'Desc', 'None');
	if byDescColumn == 'None' then
		byDescColumn = "";
	end
	
	if config.GetServiceNation() ~= "TAIWAN" then
		byDescColumn = DRAW_RECYCLE_PRICE(obj, byDescColumn)		
	end
	
	if invDesc == "" then
		invDesc = invDesc .. byDescColumn;
	else
		invDesc = invDesc .. "{nl}" .. byDescColumn;
	end	

	if desc ~= nil and desc ~= '' then		
		invDesc = desc .. '{nl} {nl}' .. invDesc
	end

	return invDesc;
end

-- propNameList만 가져오는 함수. 만일 툴팁이나 기타 등등에 아이템의 옵션을 표시할 때 옵션값들을 하나의 통합된 string 형태가 아니라 그냥 리스트로 가져오고 싶을 때 활용.
function GET_ITEM_PROP_NAME_LIST(obj) 
	local tooltipValue = TryGetProp(obj, "TooltipValue");
	if tooltipValue == nil or tooltipValue == "None" then
		return "";
	end

	local sList = StringSplit(tooltipValue, "/");
	local propNameList = {};
	for i = 1, #sList do
		local propName = sList[i];
		if string.sub(propName, 1, 1) == "#" then
			local func = _G[string.sub(propName, 2, string.len(propName) )];
			func(obj, propNameList);
		else
			propNameList[#propNameList + 1] = {};
			propNameList[#propNameList]["PropName"] = propName;
            local propValue = math.floor(obj[propName]);
            if propName == 'CoolDown' and propValue == 0 then -- 인벤토리가 아닌 아이템의 경우 CP계산을 못해요
                propValue = obj.ItemCoolDown;
            end
			propNameList[#propNameList]["PropValue"] = propValue;
		end
	end
	return propNameList;
end

-- 에테르 젬 아이템 프로퍼티 옵션 값
function AETHER_GET_ITEM_PROP_NAME_LIST(obj, guid) 
	local tooltip_value = TryGetProp(obj, "TooltipValue");
	if tooltip_value == nil or tooltip_value == "None" then
		return "";
	end

	local string_list = StringSplit(tooltip_value, "/");
	local prop_name_list = {};
	for i = 1, #string_list do
		local prop_name = string_list[i];
		if string.sub(prop_name, 1, 1) == "#" then
			local func = _G[string.sub(prop_name, 2, string.len(prop_name) )];
			func(obj, prop_name_list, guid);
		else
			prop_name_list[#prop_name_list + 1] = {};
			prop_name_list[#prop_name_list]["PropName"] = prop_name;
            local prop_value = math.floor(obj[prop_name]);
            if prop_name == 'CoolDown' and prop_value == 0 then
                prop_value = obj.ItemCoolDown;
            end
			prop_name_list[#prop_name_list]["PropValue"] = prop_value;
		end
	end
	return prop_name_list;
end

function GET_ITEM_DESC_BY_TOOLTIP_VALUE(obj)

	local propNameList = GET_ITEM_PROP_NAME_LIST(obj)
	local ret = "";
	for i = 1, #propNameList do
		local propName = propNameList[i]["PropName"];
		local propValue = propNameList[i]["PropValue"];
		local useOperator = propNameList[i]["UseOperator"];
		local title = propNameList[i]["Title"];

		local resultMsg = "";
		if title ~= nil then
			resultMsg = title;
		else
			if propName == "CoolDown" then
				propValue = math.floor(propValue / 1000);
				 resultMsg = ScpArgMsg("CoolDown : {Sec} Sec",'Sec', propValue);
			else
				if useOperator ~= nil and propValue > 0 then
					resultMsg = ClMsg(propName) .. " : " .."{img green_up_arrow 16 16}".. propValue;
				else
					resultMsg = ClMsg(propName) .. " : " .."{img red_down_arrow 16 16}".. propValue;
				end
			end
		end	

		if ret ~= "" then
			ret = ret .. "{nl}";
		end

		ret = ret .. resultMsg;
	end
	
	return ret;
end

function GETCARDTOOLTIP(obj, propNameList)
	
	local lhandSkill = GET_ITEM_LHAND_SKILL(obj);
	if lhandSkill ~= nil then
		local values = CreateTooltipValues();
		GET_SKILL_TOOLTIP_VALUES(lhandSkill, obj.Level, values);

		local tooltipCount = GetTooltipVecCount(values);
		if tooltipCount > 0 then
			local langType = "SkillStats";
			propNameList[#propNameList + 1] = {};
			propNameList[#propNameList]["Title"] = "{#FFFF22}" .. ClMsg(langType) .. "{/}";

			for i = 0 , tooltipCount - 1 do
				local key, value = GetTooltipInfoByIndex(values, i);
				propNameList[#propNameList + 1] = {};
				propNameList[#propNameList]["PropName"] = key;
				propNameList[#propNameList]["PropValue"] = value;
			end	
		end	
	end
end


function CLOSE_ITEM_TOOLTIP()

end

function SET_ITEM_TOOLTIP_ALL_TYPE(icon, invitem, className, strType, itemType, index)	
	if IS_SKILL_SCROLL_ITEM_BYNAME(className) == true then
		local obj = GetIES(invitem:GetObject());
		SET_TOOLTIP_SKILLSCROLL(icon, obj, nil, strType);
	else
		icon:SetTooltipType('wholeitem');
		if nil ~= strType and nil ~= itemType and nil ~= index then			
			icon:SetTooltipArg(strType, itemType, index);
		end
	end
end

function SET_ITEM_TOOLTIP_TYPE(prop, itemID, itemCls, tooltipType)
	local customTooltipScp = TryGetProp(itemCls, "CustomToolTip");	
	if customTooltipScp ~= nil and customTooltipScp ~= "None" then
		customTooltipScp = _G[customTooltipScp];		
		if customTooltipScp ~= nil then
			customTooltipScp(prop, itemCls, nil, tooltipType);
		else
			prop:SetTooltipType('wholeitem');	
		end
	else
		prop:SetTooltipType('wholeitem');
	end	
end

function SET_TOOLTIP_SKILLSCROLL(icon, obj, itemCls, strType)

	if nil == obj or obj.SkillType == 0 then
		return 0;
	end 

	SET_SKILL_TOOLTIP_BY_TYPE_LEVEL(icon, obj.SkillType, obj.SkillLevel);
	if strType ~= nil then
		local slot = icon:GetParent();
		if slot ~= nil then
			slot:SetUserValue("SCROLL_ITEM_ID", GetIESID(obj));
			slot:SetUserValue("SCROLL_ITEM_INVTYPE", strType);
		end
		
		icon:SetUserValue("SCROLL_ITEM_ID", GetIESID(obj));
		icon:SetUserValue("SCROLL_ITEM_INVTYPE", strType);
	end

	return 1;
end

function SET_ITEM_DESC(value, desc, item)
	if desc == "None" then
		desc = "";
	end

	local obj = GetIES(item:GetObject());
	if IS_SKILL_SCROLL_ITEM(obj) == 1 then		
		local sklCls = GetClassByType("Skill", obj.SkillType)
		value:SetTextByKey("value", obj.SkillLevel .. " Level/ "..  sklCls.Name);
	else
		value:SetTextByKey("value", desc);
	end
end

function ICON_SET_INVENTORY_TOOLTIP(icon, invitem, strarg, itemCls)
    if itemCls == nil then
        return;
    end

	if strarg == nil then
		strarg = 'inven';
	end

	SET_ITEM_TOOLTIP_ALL_TYPE(icon, invitem, itemCls.ClassName, strarg, 0, invitem:GetIESID());

	local itemobj = GetIES(invitem:GetObject());
	if itemobj.ItemType == "Equip" and itemobj.MaxDur ~= 0 and itemobj.Dur == 0 then
		icon:SetColorTone("FFFF0000");
	end

end

function ICON_SET_EQUIPITEM_TOOLTIP(icon, equipitem, topParentFrameName)
	SET_ITEM_TOOLTIP_TYPE(icon, equipitem.type);
	icon:SetTooltipArg('equip', equipitem.type, equipitem:GetIESID());
	if topParentFrameName ~= nil then
		icon:SetTooltipTopParentFrame(topParentFrameName);
	end
end

-- 옵션 추출 아이템 툴팁 (아이커 툴팁)
function ITEM_TOOLTIP_EXTRACT_OPTION(tooltipframe, invitem, mouseOverFrameName)
	local targetItem = GetClass('Item', invitem.InheritanceItemName);
	if targetItem == nil then
        targetItem = GetClass('Item', invitem.InheritanceRandomItemName);
        if targetItem == nil then
		    return;
        end
	end

	tolua.cast(tooltipframe, "ui::CTooltipFrame");
	local mainframename = 'extract_option';
	local ypos, commonCtrlSet = DRAW_EXTRACT_OPTION_COMMON_TOOLTIP(tooltipframe, invitem, targetItem, mainframename);	
	local line1 = commonCtrlSet:GetChild('line1');
	if IS_EXIST_RANDOM_OPTION(invitem) == true then		
		ypos = DRAW_EXTRACT_OPTION_RANDOM_OPTION(tooltipframe, invitem, mainframename, ypos);
	end
	
	ypos = DRAW_EQUIP_PROPERTY(tooltipframe, targetItem, nil, ypos, mainframename, false);
	--ypos = DRAW_EXTRACT_OPTION_LIMIT_EQUIP_DESC(tooltipframe, targetItem, mainframename, ypos, ScpArgMsg('{LEVEL}LimitEquip', 'LEVEL'));
	ypos = DRAW_EQUIP_TRADABILITY(tooltipframe, invitem, ypos, mainframename);
	ypos = DRAW_EQUIP_VIBORA_REFINE(tooltipframe, invitem, ypos, mainframename)
	ypos = DRAW_EQUIP_GODDESS_REFINE(tooltipframe, invitem, ypos, mainframename)
	ypos = DRAW_EQUIP_DESC(tooltipframe, invitem, ypos, mainframename);
	ypos = DRAW_SELL_PRICE(tooltipframe, invitem, ypos, mainframename);
end

function DRAW_EXTRACT_OPTION_LIMIT_EQUIP_DESC(tooltipframe, targetItem, mainframename, ypos, clmsg)
	local gBox = GET_CHILD(tooltipframe, mainframename);
	local descCtrlset = gBox:CreateControlSet('tooltip_extract_option_equip_limit', 'equipLimitCtrlSet', 0, ypos);
    local descText = GET_CHILD(descCtrlset, 'descText');
    descText:SetText(clmsg);
    descCtrlset:Resize(descCtrlset:GetWidth(), descText:GetY() + descText:GetHeight());

	ypos = ypos + descCtrlset:GetHeight() + 10;
	gBox:Resize(gBox:GetWidth(), ypos);
	return ypos;
end

function GET_ENCHANT_JEWELL_ITEM_NAME_STRING(jewellItem)
	if tonumber(TryGetProp(jewellItem, 'NumberArg1', 0)) >= 400 then
		return jewellItem.Name
	else	
		return '['..string.format('LV. %d', jewellItem.Level)..'] '..jewellItem.Name;
	end
end

function GET_ICOR_ITEM_NAME_STRING(item)
	local name = item.Name;
	local targetItem = nil;
	
	if 	TryGetProp(item, 'InheritanceItemName', 'None') ~= 'None' then
		targetItem = GetClass('Item', item.InheritanceItemName);
	elseif TryGetProp(item, 'InheritanceRandomItemName', 'None') ~= 'None' then
		targetItem = GetClass('Item', item.InheritanceRandomItemName);
	end

	if targetItem == nil then
		return name;
	end
	
	local string = TryGetProp(targetItem, 'ReqToolTip', 'None');
	if string ~= 'None' then
		name = "["..targetItem.Name.."] "..item.Name;
	end

	return name;
end

function GET_EXTRACT_ITEM_NAME(invitem)
	local name = invitem.Name;
	if IS_ENCHANT_JEWELL_ITEM(invitem) == true then
		return GET_ENCHANT_JEWELL_ITEM_NAME_STRING(invitem);
	end

	if IS_ICOR_ITEM(invitem) == true then
		return GET_ICOR_ITEM_NAME_STRING(invitem);
	end
	
	return name;
end

function DRAW_EXTRACT_OPTION_COMMON_TOOLTIP(tooltipframe, invitem, targetItem, mainframename)
	local gBox = GET_CHILD(tooltipframe, mainframename);
	gBox:RemoveAllChild();	
	local ctrlset = gBox:CreateControlSet('tooltip_extract_option', 'EXTRACT_OPTION_CTRLSET', 0, 0);
	local nameText = GET_CHILD(ctrlset, 'nameText');
	local nameStr = GET_EXTRACT_ITEM_NAME(invitem);
	nameText:SetText(nameStr);

	local itemPic = GET_CHILD(ctrlset, 'itemPic');
	itemPic:SetImage(invitem.Icon);

	local groupText = GET_CHILD(ctrlset, 'groupText');
	groupText:SetText(ClMsg(invitem.GroupName));

	local weightText = GET_CHILD(ctrlset, 'weightText');
	weightText:SetTextByKey('weight', invitem.Weight)

	local classTypeText = GET_CHILD(ctrlset, 'classTypeText');
	local classType = TryGetProp(targetItem, 'ClassType', 'None');
	if classType ~= 'None' then
		classTypeText:SetText(ClMsg(targetItem.ClassType));
	else
		classTypeText:SetText('');
	end

	gBox:Resize(gBox:GetWidth(), gBox:GetHeight() + ctrlset:GetHeight());
	return ctrlset:GetHeight(), ctrlset;
end

function DRAW_EXTRACT_OPTION_RANDOM_OPTION(tooltipframe, invitem, mainframename, ypos)
	local gBox = GET_CHILD(tooltipframe, mainframename);
	local randomOptionBox = gBox:CreateControl('groupbox', 'randomOptionBox', 0, ypos + 5, gBox:GetWidth(), 0);
	randomOptionBox:SetSkinName('None');
	local inner_yPos = 0;

	for i = 1 , 6 do
	    local propGroupName = "RandomOptionGroup_"..i;
		local propName = "RandomOption_"..i;
		local propValue = "RandomOptionValue_"..i;
		local clientMessage = 'None'
		
		if invitem[propGroupName] == 'ATK' then
		    clientMessage = 'ItemRandomOptionGroupATK'
		elseif invitem[propGroupName] == 'DEF' then
		    clientMessage = 'ItemRandomOptionGroupDEF'
		elseif invitem[propGroupName] == 'UTIL_WEAPON' then
		    clientMessage = 'ItemRandomOptionGroupUTIL'
		elseif invitem[propGroupName] == 'UTIL_ARMOR' then
		    clientMessage = 'ItemRandomOptionGroupUTIL'
		elseif invitem[propGroupName] == 'UTIL_SHILED' then
		    clientMessage = 'ItemRandomOptionGroupUTIL'
		elseif invitem[propGroupName] == 'STAT' then
			clientMessage = 'ItemRandomOptionGroupSTAT'
		elseif invitem[propGroupName] == 'SPECIAL' then
			clientMessage = 'ItemRandomOptionGroupSPECIAL'		
		elseif invitem[propGroupName] == 'SPECIAL' then
			clientMessage = 'ItemRandomOptionGroupSPECIAL'		
		end
		
		if invitem[propValue] ~= 0 and invitem[propName] ~= "None" then
			local opName = string.format("%s %s", ClMsg(clientMessage), ScpArgMsg(invitem[propName]));
			local strInfo = ABILITY_DESC_NO_PLUS(opName, invitem[propValue], 0);
			inner_yPos = ADD_ITEM_PROPERTY_TEXT(randomOptionBox, strInfo, 0, inner_yPos);
		end
	end	
	inner_yPos = ADD_RANDOM_OPTION_RARE_TEXT(randomOptionBox, invitem, inner_yPos);

	randomOptionBox:Resize(randomOptionBox:GetWidth(), inner_yPos);
	ypos = randomOptionBox:GetY() + randomOptionBox:GetHeight() + 10;
	gBox:Resize(gBox:GetWidth(), ypos);
	return ypos;
end

function GET_RANDOM_OPTION_RARE_CLIENT_TEXT(invitem)
	local propName = 'RandomOptionRare';
    local propValue = 'RandomOptionRareValue';
    return _GET_RANDOM_OPTION_RARE_CLIENT_TEXT(invitem[propName], invitem[propValue]);
end

function _GET_RANDOM_OPTION_RARE_CLIENT_TEXT(rareOptionName, rareOptionValue, prefixOverride)
	if rareOptionValue ~= nil and rareOptionValue ~= 0 and rareOptionName ~= "None" then
		local prefix = ClMsg('ItemRandomOptionGroupRare');
		if prefixOverride ~= nil then
			prefix = prefixOverride;
		end
		local opName = string.format("%s %s", prefix, ScpArgMsg(rareOptionName));

    	local clmsg = ScpArgMsg("PropUp");
    	if tonumber(rareOptionValue) < 0 then
    		clmsg = ScpArgMsg('PropDown');
    	end

    	local function IS_NONE_PERCENT_PROPERTY(propName)
    		if propName == "RareOption_MSPD" or propName == "RareOption_SR" then -- percent 표기 안하는 프로퍼티 여기에 등록
    			return true;
    		end
    		return false;
    	end

    	local strInfo = '{@st66b}{#e28500}{ol}'..string.format(' %s'..clmsg, opName);
    	local absValue = math.abs(rareOptionValue);
    	if IS_NONE_PERCENT_PROPERTY(rareOptionName) == false then
    		absValue = absValue / 10; -- 15% -> 150 하기로 함
    	end

    	if absValue == math.floor(absValue) then
    		strInfo = "{@st66b}{#e28500}{ol}"..strInfo..string.format('%d', math.floor(absValue));
    	else
    		strInfo = "{@st66b}{#e28500}{ol}"..strInfo..string.format('%.1f', absValue);
    	end

		if IS_NONE_PERCENT_PROPERTY(rareOptionName) == false then
        	strInfo = strInfo..'%{/}';
        end
        return strInfo;
	end
	return nil;
end

function ADD_RANDOM_OPTION_RARE_TEXT(box, invitem, ypos)	
	if invitem['RandomOptionRare'] ~= nil and invitem['RandomOptionRare'] ~= 'None' then
	    local propName = 'RandomOptionRare';
	    local propValue = 'RandomOptionRareValue';
	    local clientMessage = 'ItemRandomOptionGroupRare';
	    local strInfo = GET_RANDOM_OPTION_RARE_CLIENT_TEXT(invitem);
	    if strInfo ~= nil then
			ypos = ADD_ITEM_PROPERTY_TEXT(box, strInfo, 0, ypos+5);
	    end
	end
	return ypos
end

-- 쥬얼 툴팁
function ITEM_TOOLTIP_ENCHANT_JEWELL(tooltipframe, invitem, mouseOverFrameName)	
	tolua.cast(tooltipframe, "ui::CTooltipFrame");
	local mainframename = 'extract_option';
	local ypos, commonCtrlSet = DRAW_EXTRACT_OPTION_COMMON_TOOLTIP(tooltipframe, invitem, invitem, mainframename);
	local line1 = commonCtrlSet:GetChild('line1');
	line1:ShowWindow(0);

	if invitem.NumberArg1 > 0 then
		ypos = DRAW_EXTRACT_OPTION_LIMIT_EQUIP_DESC(tooltipframe, invitem, mainframename, ypos, ScpArgMsg('{LEVEL}LimitEquipNormalItem', 'LEVEL', invitem.NumberArg1));
	else
		ypos = DRAW_EXTRACT_OPTION_LIMIT_EQUIP_DESC(tooltipframe, invitem, mainframename, ypos, ScpArgMsg('{LEVEL}LimitEquipNormalItem', 'LEVEL', invitem.Level));
	end
	ypos = DRAW_EQUIP_TRADABILITY(tooltipframe, invitem, ypos, mainframename);
	ypos = DRAW_EQUIP_DESC(tooltipframe, invitem, ypos, mainframename);
	ypos = DRAW_SELL_PRICE(tooltipframe, invitem, ypos, mainframename);
end

-- 가디스 아이커
function ITEM_TOOLTIP_GODDESS_ICOR(tooltipframe, invitem, mouseOverFrameName)
	tolua.cast(tooltipframe, "ui::CTooltipFrame");
	local mainframename = 'extract_option';
	local ypos, commonCtrlSet = DRAW_EXTRACT_OPTION_COMMON_TOOLTIP(tooltipframe, invitem, invitem, mainframename);			
	ypos = DRAW_GODDESS_ICOR_PROPERTY(tooltipframe, invitem, nil, ypos, mainframename, false);		
	ypos = DRAW_EQUIP_DESC(tooltipframe, invitem, ypos, mainframename);
	ypos = DRAW_EQUIP_TRADABILITY(tooltipframe, invitem, ypos, mainframename);
end

local function get_goddess_set_option_exprop(name)
	local sum = 0
	-- app.IsBarrackMode() == true
	local charlist = ui.GetFrame("barrack_charlist");
	if charlist == nil then		
		local list = {'LH', 'RH', 'LH_SUB', 'RH_SUB', 'SHIRT', 'PANTS', 'GLOVES', 'BOOTS'}
		for i = 1, #list do
			local slot_name = list[i]
			local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_name))		
			if inv_item ~= nil then
				local obj = GetIES(inv_item:GetObject())
				for i = 1, MAX_RANDOM_OPTION_COUNT do
					local op_name = 'RandomOption_' .. i
					local _name = TryGetProp(obj, op_name, 'None')		
					if _name == name then
						local value = TryGetProp(obj, 'RandomOptionValue_' .. i, 0)
						sum = sum + value
					end
				end
			end
		end
	else
		local barrack_mode = charlist:GetUserValue('BarrackMode')	
		if barrack_mode == 'Barrack' then
			local account = session.barrack.GetMyAccount();
			local bpc = account:GetBySlot(charlist:GetUserIValue('select_slot'));
			local spotCount = item.GetEquipSpotCount() - 1;
			for i = 0 , spotCount do
				local eqpObj = bpc:GetEquipObj(i);				
				if eqpObj ~= nil then
					local obj = GetIES(eqpObj);
					if item.IsNoneItem(obj.ClassID) == 0 then
						for i = 1, MAX_RANDOM_OPTION_COUNT do
							local op_name = 'RandomOption_' .. i
							local _name = TryGetProp(obj, op_name, 'None')		
							if _name == name then
								local value = TryGetProp(obj, 'RandomOptionValue_' .. i, 0)
								sum = sum + value
							end
						end
					end
				end
			end
		end		
	end

	return sum
end

function DRAW_SPECIAL_RANDOM_OPTION(item, desc)		
	for i = 1, MAX_RANDOM_OPTION_COUNT do
		local op_name = 'RandomOption_' .. i
		local name = TryGetProp(item, op_name, 'None')		
		local cls = GetClass('goddess_special_option', name)
		if cls ~= nil then
			local type = TryGetProp(cls, 'Type', 'None')
			if type == 'Invoke' then
				local prop = TryGetProp(cls, 'Prop', 1)				
				desc = desc .. ScpArgMsg(name .. '_desc', 'prop', prop)
			elseif type == 'Using' then
				local using_count = TryGetProp(cls, 'UsingCount', 0)				
				desc = desc .. ScpArgMsg(name .. '_desc', 'using', using_count)
			else
				desc = desc .. ClMsg(name .. '_desc')
			end
		end
		cls = GetClass('goddess_atk_def_option', name)		
		if cls ~= nil then
			local value = TryGetProp(item, 'RandomOptionValue_' .. i, 0)
			if name == 'revenge' then
				desc = desc .. ScpArgMsg(name .. '_desc', 'value', value, 'value2', math.floor(value * 0.25))
			elseif string.find(name, '_res') ~= nil then
				local pc = GetMyPCObject()
				local value1 = 0
				local level = PC_MAX_LEVEL
				if pc ~= nil then
					level = pc.Lv
				end

				value1 = string.format('%.1f', math.min(tonumber(value / GET_MAX_REG_VALUE(level) * 100), 100))
            	desc = desc .. ScpArgMsg(name .. '_desc', 'value', value1, 'level', level)
			else
				desc = desc .. ScpArgMsg(name .. '_desc', 'value', value)
			end
		end
	end


	for i = 1, MAX_RANDOM_OPTION_COUNT do
		local op_name = 'RandomOption_' .. i
		local name = TryGetProp(item, op_name, 'None')		
		local cls = GetClass('goddess_set_option', name)
		if cls ~= nil then
			local max = TryGetProp(cls, 'MaxSet', 0)
			local exprop_value = get_goddess_set_option_exprop(name)
			if exprop_value > max then
				exprop_value = max;
			end
			-- if exprop_value > 1 then
				desc = desc .. ' {nl}{img tooltip_attribute5} ' .. ScpArgMsg(name) .. '{nl}'
			-- end
			for j = 2, exprop_value do
				local desc_name = string.format('%s_set%d_desc', name, j)
				desc = desc .. '{@st47}{s15}{#F4D999}'.. ScpArgMsg(desc_name) .. '{/}{/}{/}' .. '{nl}'
			end	
			if exprop_value == 0 then
				exprop_value = 1
			end
			
			for k = exprop_value + 1, max do
				local desc_name = string.format('%s_set%d_desc', name, k)
				desc = desc .. ScpArgMsg(desc_name) .. '{nl}'
			end

			local desc_name = string.format('%s_set%d_desc2', name, max)
			if GetClass('ClientMessage', desc_name) ~= nil and (keyboard.IsKeyPressed('LALT') == 1 or keyboard.IsKeyDown('LALT') == 1) then
				desc = desc .. ScpArgMsg(desc_name) .. '{nl}'
			end

		end
	end
	
	local RadaOption = TryGetProp(item, 'RadaOption', 'None')
	local equip_group = TryGetProp(item, 'EquipGroup', 'None')
	if RadaOption ~= 'None' then
		local prefix = ''
		local suffix = ''
		if SEASON_COIN_NAME ~= 'RadaCertificate' then
			prefix = '{#7F7F7F}'
			suffix = '{/}'
		end

		desc = prefix .. desc
		desc = desc .. '{nl}' .. ScpArgMsg('rada_option') .. '{nl}'

		local list = StringSplit(RadaOption, ';')
		for i = 1, #list do
			local name = StringSplit(list[i], '/')[1]
			local value = StringSplit(list[i], '/')[2]

			local range = GET_RADAOPTION_RANGE(name, equip_group)
			desc = desc .. ScpArgMsg(name, 'level', value, 'min', range[1], 'max', range[2]) .. '{nl}'
		end
		desc = desc .. ScpArgMsg('rada_option_end') .. '{nl}'
		desc = desc .. suffix
	end

	return desc
end

function DRAW_REROLL_INFOMATION(item, desc)
	local index = TryGetProp(item, 'RerollIndex', 0)
	local count = TryGetProp(item, 'RerollCount', 0)
	local flag = false
	if index ~= 0 then
		local msg = ScpArgMsg('reroll{count}', 'count', count)
		desc = desc .. '{nl} {nl}' .. msg
		flag = true
	end
	
	count = TryGetProp(item, 'Ductility_Count', 0)
	if count > 0 then
		local msg = ScpArgMsg('ductility{count}', 'count', count)
		if flag == true then
			desc = desc .. '{nl}' .. msg
		else
			desc = desc .. '{nl} {nl}' .. msg
		end
	end

	return desc
end


function DRAW_VAKARINE_SKILL_OPTION(item, desc)	
	for i = 1, 1 do
		local op_name = 'EnchantSkillName_' .. i
		local name = TryGetProp(item, op_name, 'None')
		if name ~= 'None' then
			local skl = GetClass('Skill', name)
			if skl ~= nil then
				local lv = TryGetProp(item, 'EnchantSkillLevel_'.. i, 1)
				desc = desc .. ScpArgMsg('vakarine_skill_desc', 'name', TryGetProp(skl, 'Name', 'None'), 'level', lv)
			end
		end
	end
	
	return desc
end
