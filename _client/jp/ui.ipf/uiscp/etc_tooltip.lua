-- etc_tooltip.lua

local function replace(text, to_be_replaced, replace_with)
	local retText = text
	local strFindStart, strFindEnd = string.find(text, to_be_replaced)	
    if strFindStart ~= nil then
		local nStringCnt = string.len(text)		
		retText = string.sub(text, 1, strFindStart-1) .. replace_with ..  string.sub(text, strFindEnd+1, nStringCnt)		
    else
        retText = text
	end
	
    return retText
end

function ITEM_TOOLTIP_ETC(tooltipframe, invitem, argStr, usesubframe)    
	tolua.cast(tooltipframe, "ui::CTooltipFrame");

	local mainframename = 'etc'
	
	if usesubframe == "usesubframe" then
		mainframename = "etc_sub"
	elseif usesubframe == "usesubframe_recipe" then
		mainframename = "etc_sub"
	end
	
	local ypos = DRAW_ETC_COMMON_TOOLTIP(tooltipframe, invitem, mainframename, argStr); -- 기타 템이라면 공통적으로 그리는 툴팁들	
	ypos = DRAW_ETC_DESC_TOOLTIP(tooltipframe, invitem, ypos, mainframename); -- 아이템 설명.
	ypos = DRAW_ETC_RECIPE_NEEDITEM_TOOLTIP(tooltipframe, invitem, ypos, mainframename); -- 재료템이라면 필요한 재료랑 보여줌
	ypos = DRAW_ETC_PREVIEW_TOOLTIP(tooltipframe, invitem, ypos, mainframename);			-- 아이콘 확대해서 보여줌
	ypos = DRAW_EQUIP_TRADABILITY(tooltipframe, invitem, ypos, mainframename);
	
	local isHaveLifeTime = TryGetProp(invitem, "LifeTime", 0);	
	if 0 == tonumber(isHaveLifeTime) and GET_ITEM_EXPIRE_TIME(invitem) == 'None' then
		ypos = DRAW_SELL_PRICE(tooltipframe, invitem, ypos, mainframename); -- 가격
	else
		ypos = DRAW_REMAIN_LIFE_TIME(tooltipframe, invitem, ypos, mainframename); -- 남은 시간
	end
end

function DRAW_ETC_COMMON_TOOLTIP(tooltipframe, invitem, mainframename, from)		
    local gBox = GET_CHILD(tooltipframe, mainframename,'ui::CGroupBox')
	gBox:RemoveAllChild()
	--스킨 세팅
	local SkinName  = GET_ITEM_TOOLTIP_SKIN(invitem);
	gBox:SetSkinName('test_Item_tooltip_normal');
	
	local CSet = gBox:CreateControlSet('tooltip_etc_common', 'tooltip_etc_common', 0, 0);
	tolua.cast(CSet, "ui::CControlSet");

	local GRADE_FONT_SIZE = CSet:GetUserConfig("GRADE_FONT_SIZE"); -- 등급 나타내는 별 크기

	-- 아이템 이미지
	local itemPicture = GET_CHILD(CSet, "itempic", "ui::CPicture");
	
	if invitem.TooltipImage ~= nil and invitem.TooltipImage ~= 'None' then
	    local itemImg = invitem.TooltipImage;
	    
	    -- 레시피 툴팁 이미지와 인벤 이미지를 통일
	    if invitem.GroupName == 'Recipe' then
	        itemImg = invitem.Icon;
	    end
	    
		itemPicture:SetImage(itemImg);		
		itemPicture:ShowWindow(1);	
		SET_SLOT_STAR_TEXT(itemPicture, invitem)	
	else
		itemPicture:ShowWindow(0);
	end

	local questMark = GET_CHILD(CSet, "questMark", "ui::CPicture");
	if invitem.GroupName ~= 'Quest' then		
		questMark:ShowWindow(0);
	end

	-- 별 그리기
	SET_GRADE_TOOLTIP(CSet, invitem, GRADE_FONT_SIZE);	

	-- 아이템 이름 세팅
	local fullname = TranslateDicID(GET_FULL_NAME(invitem, true));
	local nameChild = GET_CHILD(CSet, "name", "ui::CRichText");
	
	--EVENT_1909_ANCIENT
	if invitem.StringArg ~= 'None' then
		local infoCls = GetClass('Ancient_Info', invitem.StringArg);
		if infoCls ~= nil then
			local color = ""
			if infoCls.Rarity == 1 then
				color = "{#ffffff}"
			elseif infoCls.Rarity == 2 then
				color = "{#0e7fe8}"
			elseif infoCls.Rarity == 3 then
				color = "{#d92400}"
			elseif infoCls.Rarity == 4 then
				color = "{#ffa800}"
			end
			fullname = string.gsub(fullname,"%[.*%]",function(w) return color..w.."{/}" end)
		end
	end
	
	nameChild:SetText(fullname);	
	nameChild:SetTextAlign("center","center");
    if nameChild:GetWidth() < nameChild:GetTextWidth() then
		nameChild:EnableSlideShow(1)
		nameChild:SetCompareTextWidthBySlideShow(true);
	else
		nameChild:EnableSlideShow(0)
		nameChild:SetCompareTextWidthBySlideShow(false);
	end	
	
    -- 쿨타임 등 세팅 옮김
	local invDesc = GET_ITEM_DESC_BY_TOOLTIP_VALUE(invitem);
	local propRichtext= GET_CHILD(CSet,'prop_text','ui::CRichText')
	propRichtext:SetText(invDesc)

	-- 아이템 유저 거래 유무 다시 세팅
	local noTrade_cnt = GET_CHILD(CSet, "noTrade_cnt", "ui::CRichText");
	local noTradeCount = TryGetProp(invitem, "BelongingCount");
	if nil ~= noTradeCount and 0 > noTradeCount then
		noTradeCount = 0
	end
	noTrade_cnt:SetTextByKey('count', noTradeCount);

	local itemProp = geItemTable.GetPropByName(invitem.ClassName);
	if itemProp ~= nil then
		if itemProp:IsEnableUserTrade() ~= true then
			if nil ~= noTrade_cnt then
				noTrade_cnt:ShowWindow(0);
			end
		end
	else
		if nil ~= noTrade_cnt then
			noTrade_cnt:ShowWindow(0);
		end
	end
    
    if from ~= nil and from == 'accountwarehouse' then
        noTrade_cnt:ShowWindow(0)
    end
    
	
	-- 아이템 종류 세팅
	local type_richtext = GET_CHILD(CSet, "type_text", "ui::CRichText");
	local type_txt = invitem.GroupName
	if type_txt == 'Gem_Relic' then
		type_txt = invitem.GemType
	end
	type_richtext:SetTextByKey('type',ScpArgMsg(type_txt));
	
	--무게
	local weightRichtext = GET_CHILD(CSet, "weight_text", "ui::CRichText");
	local weightString = string.format("%.1f", invitem.Weight)
	weightRichtext:SetTextByKey('weight', weightString);

	gBox:Resize(gBox:GetWidth(),gBox:GetHeight()+CSet:GetHeight())
	return CSet:GetHeight();
end

-- 쿨타임등 표시
function DRAW_ETC_PROPRTY(tooltipframe, invitem, yPos, mainframename)

	local gBox = GET_CHILD(tooltipframe, mainframename,'ui::CGroupBox')

	gBox:RemoveChild('tooltip_etc_property');

	local invDesc = GET_ITEM_DESC_BY_TOOLTIP_VALUE(invitem);

	if invDesc == "" then
		return yPos;
	end

	local Cset = gBox:CreateOrGetControlSet('tooltip_etc_property', 'tooltip_etc_property', 0, yPos);	
	local propRichtext= GET_CHILD(Cset,'prop_text','ui::CRichText')
	
	-- 아이템 설명 설정
	propRichtext:SetText(invDesc)

	tolua.cast(Cset, "ui::CControlSet");
	local BOTTOM_MARGIN = Cset:GetUserConfig("BOTTOM_MARGIN"); -- 맨 아랫쪽 여백
	Cset:Resize(Cset:GetOriginalWidth(), propRichtext:GetY()+propRichtext:GetHeight() + BOTTOM_MARGIN)
	gBox:Resize(gBox:GetWidth(), gBox:GetHeight() + Cset:GetHeight())
	return Cset:GetHeight() + Cset:GetY();
end

function DRAW_RECYCLE_PRICE(invitem, Desc)
	local name = TryGetProp(invitem, 'ClassName', 'None')	
	local cls = GetClass('recycle_shop', name)
	if config.GetServiceNation() == 'PAPAYA' then
		cls = GetClass('recycle_shop_papaya', name)
	end
	
	if cls ~= nil  then
		local sell = TryGetProp(cls, 'SellPrice', 0)
		if sell > 0 then				
			Desc = dic.getTranslatedStr(Desc)
			Desc = replace(Desc, dic.getTranslatedStr(ClMsg('ExchangeRecycleMedal_1')), '')
			Desc = replace(Desc, dic.getTranslatedStr(ClMsg('ExchangeRecycleMedal_2')), '')
			
			if TryGetProp(invitem, 'TeamBelonging', 0) == 0 and TryGetProp(invitem, 'CharacterBelonging', 0) == 0 then
				local suffix = '{nl}' .. ScpArgMsg('ExchangeRecycleMedal', 'value', sell)
				Desc = Desc .. suffix
			end
		end
	end
	return Desc
end

function DRAW_ETC_DESC_TOOLTIP(tooltipframe, invitem, yPos, mainframename)

	local gBox = GET_CHILD(tooltipframe, mainframename,'ui::CGroupBox')
	gBox:RemoveChild('tooltip_etc_desc');
	
	local CSet = gBox:CreateOrGetControlSet('tooltip_etc_desc', 'tooltip_etc_desc', 0, yPos);
	local descRichtext= GET_CHILD(CSet,'desc_text','ui::CRichText')

	local customSet = false;
	local customTooltip = TryGetProp(invitem, "CustomToolTip", 'None');		
	if customTooltip ~= nil and customTooltip ~= "None" then
		local nameFunc = _G[customTooltip .. "_DESC"];
		if nameFunc ~= nil then
			local desc = invitem.Desc;
			desc = desc .. "{nl} {nl}" .. nameFunc(invitem);
			descRichtext:SetText(desc);
			customSet = true;
		end
	end

	-------- 확률 공개 큐브일 경우 reward_ratio_open_list.xml에서 툴팁을 불러온다
	local Desc = ClMsg('tooltip_reward_ratio_open_list')
	if false ~= customSet and (TryGetProp(invitem, "GroupName", "None") == "Cube" or TryGetProp(invitem, "GroupName", "None") == "Premium" or TryGetProp(invitem, "GroupName", "None") == "Misc" or TryGetProp(invitem, "GroupName", "None") == "Drug") then

		local cls_list, cls_cnt = GetClassList("reward_ratio_open_list")
        local TableGroup = TryGetProp(invitem, 'StringArg', 'None')
  		local Tablelist = {}
		local RatioSum = 0

		local itemcls = GetClass('Item', invitem.ClassName)
		local clsName = itemcls.ClassName
		local count = 0
		local equalRatioCheck = 0
		local isEqualRatio = 1
        for i = 0, cls_cnt - 1 do
            local cls = GetClassByIndexFromList(cls_list, i)
			if TryGetProp(cls, 'Group', 'None') == TableGroup then
				local ItemName = TryGetProp(GetClass('Item', TryGetProp(cls, "ItemName", "None")), "Name", "None")
				local Count = tostring(TryGetProp(cls, 'Count', 1))
				local Ratio = TryGetProp(cls, 'Ratio', '')
				Tablelist[#Tablelist + 1] = '{nl} - '..ItemName..' x'..Count..' '..'{@st45ty}{s14}['..Ratio..']{/}{/}'
				
				-- 확률 합계가 100이 되는지 검사
				local RatioNum = string.gsub(Ratio,'%%','')
				RatioSum = RatioSum + tonumber(RatioNum)

				-- -- 균등확률인지 검사
				if equalRatioCheck ~= 0 and tonumber(RatioNum) ~= tonumber(equalRatioCheck) then
					isEqualRatio = 0
				end

				equalRatioCheck = RatioNum
				count = count + 1
			end
		end

		-- 합계가 100이 안되면 경고 메시지 삽입. 소숫점 7자리까지 오차 범위 허용
		if RatioSum < 99.9999999 or RatioSum > 100.0000009 then
			Desc = Desc.."{#ff0000}!!!!!!!!!!! Wrong Ratio Sum !!!!!!!!!!!!!!{/}{/}"
		end

		if isEqualRatio == 1 then
			Desc = ClMsg('tooltip_reward_ratio_open_list3')
		end

		if TryGetProp(invitem, "ClassName", "None") == "Piece_BorutaSeal" or TryGetProp(invitem, "ClassName", "None") == "Piece_LegendMisc" then
			Desc = ScpArgMsg("tooltip_reward_ratio_open_list_spendcount", "COUNT", 10)
		end

		if #Tablelist > 0 then
			Desc = Desc
		else
			Desc = invitem.Desc
		end

		if TableGroup == "Cube_ALL_SKLGEM" or TableGroup == "Cube_ALL_SKLGEM_2" then
			Desc = ScpArgMsg("tooltip_reward_ratio_open_list_sklgem", "COUNT", count)
		end

	elseif false == customSet then
		Desc = invitem.Desc		
	end

	if config.GetServiceNation() ~= "TAIWAN" then
		Desc = DRAW_RECYCLE_PRICE(invitem, Desc)
	end
	Desc = DRAW_COLLECTION_INFO(invitem, Desc)
	Desc = DRAW_USAGEDESC_INFO(invitem, Desc)
	Desc = DRAW_COMMON_SKILL_LIST(invitem, Desc)
	descRichtext:SetText(Desc)

	tolua.cast(CSet, "ui::CControlSet");
	local BOTTOM_MARGIN = CSet:GetUserConfig("BOTTOM_MARGIN"); -- 맨 아랫쪽 여백
	CSet:Resize(CSet:GetWidth(), descRichtext:GetHeight() + BOTTOM_MARGIN);
	gBox:Resize(gBox:GetWidth(),gBox:GetHeight()+CSet:GetHeight())

	yPos = CSet:GetHeight() + CSet:GetY();

	return yPos, descRichtext

end

function DRAW_COMMON_SKILL_LIST(invitem, Desc)
	local str = TryGetProp(invitem, 'StringArg', 'None')
	if str == 'random_common_skill_scroll' then
		local list = shared_skill_enchant.get_skill_list(TryGetProp(invitem, 'NumberArg1', 0))
		if list ~= nil then
			Desc = Desc .. '{nl} {nl}'
		end
		
		for k, v in pairs(list) do	
			local name = GetClass('Skill', k).Name
			if v[1] == v[2] then
				Desc = Desc .. ScpArgMsg('tooltip_common_skill_list{name}{num}', 'name', name, 'num', v[1]) .. ', '
			else
				Desc = Desc .. ScpArgMsg('tooltip_common_skill_list{name}{num1}{num2}', 'name', name, 'num1', v[1], 'num2', v[2])  .. ', '
			end
		end
	elseif str == 'select_common_skill_scroll' then
		local cls = GetClass('TradeSelectItem', TryGetProp(invitem, 'ClassName', 'None'))
		if cls ~= nil then
			for i = 1, 50 do
				local name = 'SelectItemName_' .. i
				local count = 'SelectItemCount_' .. i
				local item_name = TryGetProp(cls, name, 'None')				
				if item_name == 'None' then
					break
				end

				Desc = Desc .. GetClass('Item', item_name).Name .. '{nl}' 
			end
		end
	end

	return Desc
end

function DRAW_USAGEDESC_INFO(invitem, desc)
	local UsageDesc = TryGetProp(invitem, 'UsageDesc', 'None')

	local nameFunc = _G[UsageDesc];
	if nameFunc ~= nil then
		UsageDesc = nameFunc(invitem)
	end
	
	if UsageDesc ~= "None" then
		local text = UsageDesc
		desc = desc .. '{nl} {nl}' .. text
	end

	return desc
end

function DRAW_ETC_RECIPE_NEEDITEM_TOOLTIP(tooltipframe, invitem, ypos, mainframename)


	local gBox = GET_CHILD(tooltipframe, mainframename,'ui::CGroupBox')
	gBox:RemoveChild('tooltip_recipes');

	if invitem.GroupName ~= 'Recipe' then
		return ypos;
	end

	local CSet = gBox:CreateControlSet('tooltip_recipe_needitems', 'tooltip_recipes', 0, ypos);
	tolua.cast(CSet, "ui::CControlSet");
	local gbox_items= GET_CHILD(CSet,'needitem_gbox','ui::CGroupBox')


	-- 세트아이템 세트 효과 텍스트 표시 부분
	inner_yPos = 0;

	local AVAIABLE_MAKE_FONT = CSet:GetUserConfig("AVAIABLE_MAKE_FONT")
	local UNAVAIABLE_MAKE_FONT = CSet:GetUserConfig("UNAVAIABLE_MAKE_FONT")

	local recipecls = GetClass('Recipe', invitem.ClassName);

	for i = 1 , 5 do
		if TryGetProp(recipecls, "Item_"..i.."_1", 'None') ~= "None" then
			local recipeItemCnt, invItemCnt, dragRecipeItem = GET_RECIPE_MATERIAL_INFO(recipecls, i, GetMyPCObject());

			local itemSet = gbox_items:CreateOrGetControlSet("tooltip_recipe_eachitem", "ITEM_" .. i, 0, inner_yPos);
			itemSet = tolua.cast(itemSet, 'ui::CControlSet');
			
			local image = GET_CHILD(itemSet, "image", "ui::CPicture");
			local text = GET_CHILD(itemSet, "text", "ui::CRichText");
			image:SetImage(dragRecipeItem.Icon)
			text:SetTextByKey("itemName",dragRecipeItem.Name)
			text:SetTextByKey("havecount",invItemCnt)
			text:SetTextByKey("needcount",recipeItemCnt)

			if invItemCnt >= recipeItemCnt then
				text:SetFontName(AVAIABLE_MAKE_FONT)
			else
				text:SetFontName(UNAVAIABLE_MAKE_FONT)
			end

			local GRADE_FONT_SIZE = itemSet:GetUserConfig("GRADE_FONT_SIZE"); -- 등급 나타내는 별 크기
			SET_GRADE_TOOLTIP(itemSet,dragRecipeItem,GRADE_FONT_SIZE)
			
			inner_yPos = inner_yPos + itemSet:GetHeight();
		end
	end

	gbox_items:Resize( gbox_items:GetWidth() ,inner_yPos)

	local BOTTOM_MARGIN = tooltipframe:GetUserConfig("BOTTOM_MARGIN"); -- 맨 아랫쪽 여백
	
	CSet:Resize(CSet:GetWidth(), gbox_items:GetHeight() + gbox_items:GetY() + BOTTOM_MARGIN);
	gBox:Resize(gBox:GetWidth(), gBox:GetHeight() + CSet:GetHeight()+ BOTTOM_MARGIN)

	return CSet:GetHeight() + CSet:GetY();
end

function DRAW_ETC_PREVIEW_TOOLTIP(tooltipframe, invitem, ypos, mainframename)
	if string.find(invitem.StringArg, "Balloon_") == nil then
		return ypos;
	end

	local iconName = invitem.Icon;
	if string.find(invitem.StringArg, "Balloon_") ~= nil then
		-- 말풍선 아이템일 경우 item의 icon이 아닌 chat_balloon의 SkinPreview 이미지 출력
		local balloonCls = GetClass('Chat_Balloon', invitem.StringArg);
		iconName = balloonCls.SkinPreview;
	end

	local gBox = GET_CHILD(tooltipframe, mainframename,'ui::CGroupBox')
	gBox:RemoveChild('tooltip_preview');

	local CSet = gBox:CreateControlSet('tooltip_preview', 'tooltip_preview', 0, ypos);
	tolua.cast(CSet, "ui::CControlSet");
	local previewPic = GET_CHILD(CSet,'previewPic','ui::CPicture')
	previewPic:SetImage(iconName);

	local BOTTOM_MARGIN = tooltipframe:GetUserConfig("BOTTOM_MARGIN");
	gBox:Resize(gBox:GetWidth(), gBox:GetHeight() + CSet:GetHeight()+ BOTTOM_MARGIN)

	return CSet:GetHeight() + CSet:GetY();
end

local function _SET_TRUST_POINT_PARAM_INFO(tooltipframe, index, paramType)
	-- point
	local starTextBox = GET_CHILD_RECURSIVELY(tooltipframe, 'starTextBox'..index);
	local point = session.inventory.GetTrustPointByParam(paramType);
	local STAR_IMG = 'star_in_arrow';
	local STAR_SIZE = 19;
	local starText = '';

	local name = tooltipframe:GetName();
	if name == "trust_point_global" then
		local paramText = GET_CHILD_RECURSIVELY(tooltipframe, 'paramText'..index);
		if 20 < paramText:GetHeight() then
			local starTextBox = GET_CHILD_RECURSIVELY(tooltipframe, 'starTextBox'..index);
			starTextBox:Resize(starTextBox:GetWidth(), paramText:GetHeight());
	
			local paramTextBox = GET_CHILD_RECURSIVELY(tooltipframe, 'paramTextBox'..index);
			paramTextBox:Resize(paramTextBox:GetWidth(), paramText:GetHeight());
			
			local list = GET_CHILD_RECURSIVELY(tooltipframe, 'list'..index);
			list:Resize(list:GetWidth(), paramText:GetHeight());
		end
	end

	if point == 5 then
		starText = starText..string.format('{img %s %s %s}', STAR_IMG, STAR_SIZE, STAR_SIZE);
		starText = starText..string.format('{img %s %s %s}', "starmark_multipl05", 19, 15);
	else
		for i = 1, point do
			starText = starText..string.format('{img %s %s %s}', STAR_IMG, STAR_SIZE, STAR_SIZE);
		end
	end	
	starTextBox:SetTextByKey('value', starText);

	-- info
	local paramTextBox = GET_CHILD_RECURSIVELY(tooltipframe, 'paramTextBox'..index);
	if paramType == 'SafeAuth' then
		paramTextBox:SetTextByKey('value', ClMsg('SafeAuthInfo'));
	else		
		paramTextBox:SetTextByKey('value', session.inventory.GetTrustInfoCriteria(paramType));
	end

	-- check
	local check = GET_CHILD_RECURSIVELY(tooltipframe, 'check'..index);
	if session.inventory.IsSatisfyTrustParam(paramType) == true then
		check:SetCheck(1);
	else
		check:SetCheck(0);
	end
end

local function _HIDE_SAFEAUTH_INFO(tooltipframe, safeAuthIndex, questIndex)
	local starTextBox = GET_CHILD_RECURSIVELY(tooltipframe, 'starTextBox'..safeAuthIndex);
	local paramTextBox = GET_CHILD_RECURSIVELY(tooltipframe, 'paramTextBox'..safeAuthIndex);
	local check = GET_CHILD_RECURSIVELY(tooltipframe, 'check'..safeAuthIndex);
	starTextBox:ShowWindow(0);
	paramTextBox:ShowWindow(0);
	check:ShowWindow(0);

	local _starTextBox = GET_CHILD_RECURSIVELY(tooltipframe, 'starTextBox'..questIndex);
	local _paramTextBox = GET_CHILD_RECURSIVELY(tooltipframe, 'paramTextBox'..questIndex);
	local _check = GET_CHILD_RECURSIVELY(tooltipframe, 'check'..questIndex);
	_starTextBox:SetOffset(_starTextBox:GetX(), starTextBox:GetY());
	_paramTextBox:SetOffset(_paramTextBox:GetX(), paramTextBox:GetY());		
	local margin = check:GetMargin();
	_check:SetMargin(margin.left, margin.top, margin.right, margin.bottom);

	tooltipframe:Resize(tooltipframe:GetWidth(), _starTextBox:GetY() + _starTextBox:GetHeight() + 10);
end

function UPDATE_TRUST_POINT_TOOLTIP(tooltipframe, tree)
	_SET_TRUST_POINT_PARAM_INFO(tooltipframe, 1, 'TeamLevel');
	_SET_TRUST_POINT_PARAM_INFO(tooltipframe, 2, 'CharLevel');
	_SET_TRUST_POINT_PARAM_INFO(tooltipframe, 3, 'CreateTime');
	_SET_TRUST_POINT_PARAM_INFO(tooltipframe, 4, 'SafeAuth');
	_SET_TRUST_POINT_PARAM_INFO(tooltipframe, 5, 'Quest');

	if config.GetServiceNation() ~= 'KOR' and config.GetServiceNation() ~= 'GLOBAL_KOR' and config.GetServiceNation() ~= 'GLOBAL' and config.GetServiceNation() ~= 'GLOBAL_JP' then
		_HIDE_SAFEAUTH_INFO(tooltipframe, 4, 5);
	end
end

function UPDATE_TRUST_POINT_GLOBAL_TOOLTIP(tooltipframe, tree)
	_SET_TRUST_POINT_PARAM_INFO(tooltipframe, 1, "CreateTime");
	_SET_TRUST_POINT_PARAM_INFO(tooltipframe, 2, "Quest");
	_SET_TRUST_POINT_PARAM_INFO(tooltipframe, 3, "Episode");
	_SET_TRUST_POINT_PARAM_INFO(tooltipframe, 4, "FirstTPBuy");
	_SET_TRUST_POINT_PARAM_INFO(tooltipframe, 5, 'SafeAuth');
	
	local gBox = GET_CHILD_RECURSIVELY(tooltipframe, "static_gb");
	GBOX_AUTO_ALIGN(gBox, 0, 3, 0, true, true);

	tooltipframe:Resize(tooltipframe:GetWidth(), gBox:GetHeight() + 45);
end

function UPDATE_INDUN_INFO_TOOLTIP(tooltipframe, cidStr, param1, param2, actor)
	actor =	tolua.cast(actor, "CFSMActor")
	tootltipframe = AUTO_CAST(tooltipframe)

	local indunClsList, indunCount = GetClassList('Indun');
	local ctrlWidth = tonumber(tooltipframe:GetUserConfig("INDUN_CTRL_WIDTH"))
	local ctrlHeight = tonumber(tooltipframe:GetUserConfig("INDUN_CTRL_HEIGHT"))
	local ctrlLeftMargin = tonumber(tooltipframe:GetUserConfig("INDUN_CTRL_LEFT_MARGIN"))
	local playPerRestTypeTable={}

	local accountInfo = session.barrack.GetMyAccount();
	local indunListBox = GET_CHILD_RECURSIVELY(tooltipframe, "indunListBox")

	local indunLabelText = GET_CHILD_RECURSIVELY(tooltipframe, "indunLabelText")
	indunLabelText:SetText("{@st43}{s20}" ..ClMsg("IndunCountInfo"))
	local pcInfo = accountInfo:GetByStrCID(cidStr)

	-- 인던 이용 현황 출력
	for j = 0, indunCount - 1 do
		local indunCls = GetClassByIndexFromList(indunClsList, j)
		if indunCls ~= nil and indunCls.Category ~= "None" then
			local indunGroupBox = indunListBox:CreateOrGetControl("groupbox", "INDUN_CONTROL_".. indunCls.PlayPerResetType, ctrlLeftMargin, 0, ctrlWidth, ctrlHeight)
			indunGroupBox = tolua.cast(indunGroupBox, "ui::CGroupBox")
			indunGroupBox:EnableDrawFrame(0)
			local indunLabel = indunGroupBox:CreateOrGetControl("richtext", "INDUN_NAME_" .. indunCls.PlayPerResetType, 0, 0, ctrlWidth - 60, ctrlHeight)
			indunLabel = tolua.cast(indunLabel, 'ui::CRichText')
			indunLabel:SetTextFixWidth(1);
			indunLabel:SetTextFixHeight(true);
			indunLabel:SetAutoFontSizeByWidth(indunLabel:GetWidth())
			indunLabel:SetText('{@st42b}' .. indunCls.Category)
			indunLabel:SetEnable(0)
			local difficulty = TryGetProp(indunCls, "Difficulty", "None")
            if difficulty ~= "None" then
                indunLabel:SetText('{@st42b}' .. indunCls.Category .. ' - ' .. difficulty)
            end
			
			local indunCntLabel = indunGroupBox:CreateOrGetControl("richtext", "INDUN_COUNT_" .. indunCls.PlayPerResetType, 0, 0, ctrlWidth / 2, ctrlHeight)
			indunCntLabel:SetGravity(ui.RIGHT, ui.TOP)
			indunCntLabel:SetEnable(0)

			local entranceCount = BARRACK_GET_CHAR_INDUN_ENTRANCE_COUNT(cidStr, indunCls.PlayPerResetType)
			if entranceCount ~= nil then
				if entranceCount == 'None' then
					entranceCount = 0;
				else
					entranceCount = tonumber(entranceCount)
				end

				local dungeonType = TryGetProp(indunCls, "DungeonType", "None");
				if dungeonType == "MythicDungeon_Auto_Hard" or string.find(indunCls.ClassName, "Challenge_Division_Auto") ~= nil or indunCls.PlayPerResetType == 807 then
					indunCntLabel:SetText("{@st42b}" .. entranceCount .. "/" .. "{img infinity_text 20 10}");
				elseif dungeonType == "BridgeWailing" then
					indunCntLabel:SetText("{@st42b}" .. ScpArgMsg("ChallengeMode_HardMode_Count", "Count", entranceCount));
				else
					indunCntLabel:SetText("{@st42b}" .. entranceCount .. "/" .. BARRACK_GET_INDUN_MAX_ENTERANCE_COUNT(indunCls.PlayPerResetType))
				end
			end

			if pcInfo ~= nil then
				if indunCls.Level <= actor:GetLv() or playPerRestTypeTable["INDUN_COUNT_" .. indunCls.PlayPerResetType]==1 then
					indunLabel:SetEnable(1)
					indunCntLabel:SetEnable(1)
					playPerRestTypeTable["INDUN_COUNT_" .. indunCls.PlayPerResetType]=1
				end
			end
		end
	end

	-- 챌린지 모드, 프리 던전 보스 이용 현황 출력
	local contentsClsList, count = GetClassList('contents_info');
	for i = 0, count - 1 do
        local contentsCls = GetClassByIndexFromList(contentsClsList, i);
		if contentsCls ~= nil then
            local resetGroupID = contentsCls.ResetGroupID;
			local category = contentsCls.Category;
			local indunGroupBox = indunListBox:GetChild('INDUN_CONTROL_'..resetGroupID);
			if category ~= 'None' then
				local indunGroupBox = indunListBox:CreateOrGetControl("groupbox", "INDUN_CONTROL_".. resetGroupID, ctrlLeftMargin, 0, ctrlWidth, ctrlHeight);
				indunGroupBox = tolua.cast(indunGroupBox, "ui::CGroupBox");
				indunGroupBox:EnableDrawFrame(0);

				local indunLabel = indunGroupBox:CreateOrGetControl("richtext", "INDUN_NAME_" .. resetGroupID, 0, 0, ctrlWidth / 2, ctrlHeight);
				indunLabel = tolua.cast(indunLabel, 'ui::CRichText');
				indunLabel:SetText('{@st42b}' .. category);
				indunLabel:SetEnable(0);

				local indunCntLabel = indunGroupBox:CreateOrGetControl("richtext", "INDUN_COUNT_" .. resetGroupID, 0, 0, ctrlWidth / 2, ctrlHeight);
				indunCntLabel = tolua.cast(indunCntLabel, 'ui::CRichText');
				indunCntLabel:SetGravity(ui.RIGHT, ui.TOP);
				indunCntLabel:SetEnable(0);

				local curCount = BARRACK_GET_CHAR_INDUN_ENTRANCE_COUNT(cidStr, resetGroupID);
				if curCount == nil or curCount == 'None' then
					curCount = 0;
				else
					curCount = tonumber(curCount)
				end

				local maxCount = BARRACK_GET_INDUN_MAX_ENTERANCE_COUNT(resetGroupID);
				indunCntLabel:SetText("{@st42b}" .. curCount .. "/" .. maxCount);

				if pcInfo ~= nil then
					if contentsCls.Level <= actor:GetLv()  or playPerRestTypeTable["INDUN_COUNT_" .. resetGroupID]== 1 then
						indunLabel:SetEnable(1);
						indunCntLabel:SetEnable(1);
						playPerRestTypeTable["INDUN_COUNT_" .. resetGroupID] = 1;
					end
				end
			end
		end
	end

	-- 실버 표시
	local indunGroupBox = indunListBox:CreateOrGetControl("groupbox", "INDUN_CONTROL_SILVER", ctrlLeftMargin, 0, ctrlWidth, ctrlHeight)
	indunGroupBox = tolua.cast(indunGroupBox, "ui::CGroupBox")
	indunGroupBox:EnableDrawFrame(0)
	local indunLabel = indunGroupBox:CreateOrGetControl("richtext", "INDUN_NAME_SILVER", 0, 0, ctrlWidth / 2, ctrlHeight)
	indunLabel = tolua.cast(indunLabel, 'ui::CRichText')
	indunLabel:SetText('{@st42b}' .. ScpArgMsg('Auto_SilBeo'))
	indunLabel:SetEnable(1)
	
	local indunCntLabel = indunGroupBox:CreateOrGetControl("richtext", "INDUN_CRRUNT_SILVER", 0, 0, ctrlWidth / 2, ctrlHeight)
	indunCntLabel:SetGravity(ui.RIGHT, ui.TOP)
	indunCntLabel:SetText('{@st42b}' .. GET_COMMAED_STRING(pcInfo:GetSilver()))
	indunCntLabel:SetEnable(1)

	local spacing = tonumber(tooltipframe:GetUserConfig("INDUN_CTRL_SPACING"))
	local startY = tonumber(tooltipframe:GetUserConfig("INDUN_CTRL_START_TOP_MARGIN"))
	local offset = tonumber(tooltipframe:GetUserConfig("INDUN_CTRL_OFFSET"))
	local frameoffset = tonumber(tooltipframe:GetUserConfig("INDUN_FRAME_OFFSET"))
	GBOX_AUTO_ALIGN(indunListBox, startY, spacing, offset, true, false)

	-- 인던 갯수에 따른 툴팁 크기변환
	local spaceOffset = indunListBox:GetChildCount() * (ctrlHeight + spacing) + offset;	-- 인던 list gb 크기

	local bgBox = GET_CHILD(tooltipframe, 'indunListBoxBg');
	indunListBox:Resize(indunListBox:GetOriginalWidth(), spaceOffset);
	bgBox:Resize(bgBox:GetOriginalWidth(), spaceOffset + frameoffset);
	tootltipframe:Resize(tootltipframe:GetOriginalWidth(), spaceOffset + frameoffset);
end


function ITEM_TOOLTIP_MONSTER_PIECE(tooltipframe, invitem, argStr, usesubframe)    
	tolua.cast(tooltipframe, "ui::CTooltipFrame");

	local mainframename = 'etc'
	
	if usesubframe == "usesubframe" then
		mainframename = "etc_sub"
	elseif usesubframe == "usesubframe_recipe" then
		mainframename = "etc_sub"
	end

	local ypos = DRAW_ETC_COMMON_TOOLTIP(tooltipframe, invitem, mainframename, argStr); -- 기타 템이라면 공통적으로 그리는 툴팁들	
	ypos = DRAW_ETC_DESC_TOOLTIP(tooltipframe, invitem, ypos, mainframename); -- 아이템 설명.
	ypos = DRAW_ETC_RECIPE_NEEDITEM_TOOLTIP(tooltipframe, invitem, ypos, mainframename); -- 재료템이라면 필요한 재료랑 보여줌
	ypos = DRAW_EQUIP_TRADABILITY(tooltipframe, invitem, ypos, mainframename);
	
	local isHaveLifeTime = TryGetProp(invitem, "LifeTime", 0);	
	if 0 == tonumber(isHaveLifeTime) then
		ypos = DRAW_SELL_PRICE(tooltipframe, invitem, ypos, mainframename); -- 가격
	else
		ypos = DRAW_REMAIN_LIFE_TIME(tooltipframe, invitem, ypos, mainframename); -- 남은 시간
	end
	
end


-- 서브 툴팁이 출력되는 이벤트 아이템용 툴팁
function ITEM_TOOLTIP_ETC_EVENT(tooltipframe, invitem, argStr, usesubframe)    
	tolua.cast(tooltipframe, "ui::CTooltipFrame");

	local mainframename = 'etc'
	
	if usesubframe == "usesubframe" then
		mainframename = "etc_sub"
	elseif usesubframe == "usesubframe_recipe" then
		mainframename = "etc_sub"
	end

	local ypos = DRAW_ETC_COMMON_TOOLTIP(tooltipframe, invitem, mainframename, argStr); -- 기타 템이라면 공통적으로 그리는 툴팁들	
	ypos = DRAW_ETC_DESC_TOOLTIP(tooltipframe, invitem, ypos, mainframename); -- 아이템 설명.
	ypos = DRAW_ETC_RECIPE_NEEDITEM_TOOLTIP(tooltipframe, invitem, ypos, mainframename); -- 재료템이라면 필요한 재료랑 보여줌
	ypos = DRAW_ETC_PREVIEW_TOOLTIP(tooltipframe, invitem, ypos, mainframename);			-- 아이콘 확대해서 보여줌
	ypos = DRAW_EQUIP_TRADABILITY(tooltipframe, invitem, ypos, mainframename);
	
	local isHaveLifeTime = TryGetProp(invitem, "LifeTime", 0);	
	if 0 == tonumber(isHaveLifeTime) and GET_ITEM_EXPIRE_TIME(invitem) == 'None' then
		ypos = DRAW_SELL_PRICE(tooltipframe, invitem, ypos, mainframename); -- 가격
	else
		ypos = DRAW_REMAIN_LIFE_TIME(tooltipframe, invitem, ypos, mainframename); -- 남은 시간
	end

	DRAW_ETC_EVENT_SET(tooltipframe, invitem, 0); -- 세트아이템
	DRAW_ETC_EVENT_EQUIP(tooltipframe, invitem, argStr); -- 특정 아이템
end

-- 세트 옵션 스크롤 
function DRAW_ETC_EVENT_SET(tooltipframe, invitem, ypos)
	local gBox = GET_CHILD(tooltipframe, "equip_main_addinfo",'ui::CGroupBox'); -- addinfo frame
	gBox:RemoveChild('tooltip_set');

	-- 세트 옵션 구분 조건
	local prefix = TryGetProp(invitem, "StringArg", "None");
	local prefixCls = GetClass("LegendSetItem", prefix);
	if prefixCls == nil then
		return ypos;
	end

	local group = TryGetProp(prefixCls, "LegendGroup", "None");

	local tooltip_CSet = gBox:CreateControlSet('tooltip_set', 'tooltip_set', 0, ypos);
	tolua.cast(tooltip_CSet, "ui::CControlSet");
	local set_gbox_type= GET_CHILD(tooltip_CSet, 'set_gbox_type', 'ui::CGroupBox');
	local set_gbox_prop= GET_CHILD(tooltip_CSet, 'set_gbox_prop', 'ui::CGroupBox');

	local inner_yPos = 0;
	local inner_xPos = 0;
	local DEFAULT_POS_Y = tooltip_CSet:GetUserConfig("DEFAULT_POS_Y");
	inner_yPos = DEFAULT_POS_Y;
	inner_xPos = 0;

	local EntireHaveCount = 0;
	local setList = {'RH', 'LH', 'SHIRT', 'PANTS', 'GLOVES', 'BOOTS'};
	local setFlagList = {RH_flag, LH_flag, SHIRT_flag, PANTS_flag, GLOVES_flag, BOOTS_flag};
	local setItemCount = 0;
	setItemCount, setFlagList[1], setFlagList[2], setFlagList[3], setFlagList[4], setFlagList[5], setFlagList[6] = CHECK_EQUIP_SET_ITEM(invitem, group, prefix);

	for i = 1, setItemCount do
		local setItemTextCset = set_gbox_type:CreateControlSet('eachitem_in_setitemtooltip', 'setItemText'..i, inner_xPos, inner_yPos);
		tolua.cast(setItemTextCset, "ui::CControlSet");
		local setItemName = GET_CHILD_RECURSIVELY(setItemTextCset, "setitemtext");
		if setFlagList[i] == 0 then
			setItemName:SetTextByKey("font", tooltip_CSet:GetUserConfig("NOT_HAVE_ITEM_FONT"));
		else 
			setItemName:SetTextByKey("font", tooltip_CSet:GetUserConfig("HAVE_ITEM_FONT"));
			EntireHaveCount = EntireHaveCount + 1;
		end

		local temp = "";
		if prefixCls ~= nil then
			temp = prefixCls.Name;
		end

		local setItemText = temp .. ' ' .. tooltip_CSet:GetUserConfig(setList[i] .. '_SET_TEXT');
		setItemName:SetTextByKey("itemname", setItemText);
		local heightMargin = setItemTextCset:GetUserConfig("HEIGHT_MARGIN");
		inner_yPos = inner_yPos + heightMargin;
	end

	set_gbox_type:Resize(set_gbox_type:GetWidth(), inner_yPos);

	local USE_SETOPTION_FONT = tooltip_CSet:GetUserConfig("USE_SETOPTION_FONT");
	local NOT_USE_SETOPTION_FONT = tooltip_CSet:GetUserConfig("NOT_USE_SETOPTION_FONT");

	inner_yPos = DEFAULT_POS_Y;

	local max_option_count = TryGetProp(prefixCls, 'MaxOptionCount', 5);
	if prefixCls ~= nil then
		for i = 0, (max_option_count - 3) do		-- 3 4 5 
		local index = 'EffectDesc_' .. i+ 3;
			local color = USE_SETOPTION_FONT;
			if EntireHaveCount >= i + 3 then
				color = NOT_USE_SETOPTION_FONT;
			end

			local setTitle = ScpArgMsg("Auto_{s16}{Auto_1}{Auto_2}_SeTeu_HyoKwa__{nl}", "Auto_1",color, "Auto_2",i + 3);
			local setDesc = string.format("{s16}%s%s", color, prefixCls[index]);

			local each_text_CSet = set_gbox_prop:CreateControlSet('tooltip_set_each_prop_text', 'each_text_CSet'..i, inner_xPos, inner_yPos);
			tolua.cast(each_text_CSet, "ui::CControlSet");
			local set_text = GET_CHILD(each_text_CSet,'set_prop_Text','ui::CRichText');
			set_text:SetTextByKey("setTitle",setTitle);
			set_text:SetTextByKey("setDesc",setDesc);

			local labelline = GET_CHILD_RECURSIVELY(each_text_CSet, 'labelline');
			local y_margin = each_text_CSet:GetUserConfig("TEXT_Y_MARGIN");
			local testRect = set_text:GetMargin();
			each_text_CSet:Resize(each_text_CSet:GetWidth(), set_text:GetHeight() + testRect.top);				
			inner_yPos = inner_yPos + each_text_CSet:GetHeight() + y_margin;
		end
	end

	-- 맨 아랫쪽 여백
	local BOTTOM_MARGIN = tooltipframe:GetUserConfig("BOTTOM_MARGIN");
	set_gbox_prop:Resize( set_gbox_prop:GetWidth() ,inner_yPos  + BOTTOM_MARGIN);
	set_gbox_prop:SetOffset(set_gbox_prop:GetX(),set_gbox_type:GetY()+set_gbox_type:GetHeight());
	tooltip_CSet:Resize(tooltip_CSet:GetWidth(), set_gbox_prop:GetHeight() + set_gbox_prop:GetY() + BOTTOM_MARGIN);
	gBox:Resize(gBox:GetWidth(),gBox:GetHeight() + tooltip_CSet:GetHeight());
	
	return tooltip_CSet:GetHeight() + tooltip_CSet:GetY();
end

-- 인챈트 스크롤
function DRAW_ETC_EVENT_EQUIP(tooltipframe, invitem, argStr)
	local item_ClassName = TryGetProp(invitem, "StringArg", "None");
	local itemCls = GetClass("Item", item_ClassName);
	if itemCls == nil then
		return;
	end
	
	local itemType = itemCls.ItemType;
	if itemType ~= "Equip" then
		return;
	end

	local CompItemToolTipScp = _G[ 'ITEM_TOOLTIP_' .. itemCls.ToolTipScp];
	CompItemToolTipScp(tooltipframe, itemCls, argStr, "usesubframe"); -- usesubframe frame
end

-- 강화 복구 스크롤
function SAVED_REINFORCE_AND_PR_DESC(item)
	local rein = TryGetProp(item, 'Saved_Reinforce', 0)
	local pr = TryGetProp(item, 'Saved_PR', 0)	
	local trans = TryGetProp(item, 'Saved_Transcend', 0)	
	local clmsg = ScpArgMsg("SavedReinforceAndPR{reinforce}{pr}{trans}", "reinforce", rein ,"pr", pr, 'trans', trans);	
	return clmsg
end

local function comma_value(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

-- 용병단 증표 부스트
function PVP_MINE_MISC_BOOST_DESC(item)	
	local pc = GetMyPCObject()
	
	local a = comma_value(GET_PVP_MINE_MISC_BOOST_COUNT2(pc)) -- 주간 최대치
	local d = comma_value(GET_ADDITIONAL_DROP_COUNT_PVP_MINE_MISC_BOOST2(pc, 'solo_dun')) -- 베르니케
	local e = comma_value(GET_ADDITIONAL_DROP_COUNT_PVP_MINE_MISC_BOOST2(pc, 'weekly_boss')) -- 주간 보스
	local f = comma_value((GET_PVP_MINE_MISC_BOOST_FIELD_RATE2(pc) - 1) * 100) -- 필드 획득량

	local clmsg = ScpArgMsg("pvp_mine_misc_boost_tooltip{a}{d}{e}{f}", "a", a , 'd', d, 'e', e, 'f', f);	
	return clmsg
end


function ITEM_TOOLTIP_ETCSEAL(tooltipframe, invitem, argStr, usesubframe)	
	tolua.cast(tooltipframe, "ui::CTooltipFrame");

	local mainframename = 'etc'
	
	if usesubframe == "usesubframe" then
		mainframename = "etc_sub"
	elseif usesubframe == "usesubframe_recipe" then
		mainframename = "etc_sub"
	end
	
	local descRichtext = nil
	local ypos = DRAW_ETC_COMMON_TOOLTIP(tooltipframe, invitem, mainframename, argStr); -- 기타 템이라면 공통적으로 그리는 툴팁들	
	local before = ypos
	ypos, descRichtext = DRAW_ETC_DESC_TOOLTIP(tooltipframe, invitem, ypos, mainframename); -- 아이템 설명.	
	if descRichtext ~= nil then
		local desc = descRichtext:GetText()
		desc = replace(desc, 'num', shared_item_jurate_seal.get_piece_count(invitem))
		desc = replace(desc, 'name', dic.getTranslatedStr(shared_item_jurate_seal.get_seal_name(invitem)))
		desc = replace(desc, 'name', dic.getTranslatedStr(shared_item_jurate_seal.get_seal_name(invitem)))
		desc = desc .. dic.getTranslatedStr(shared_item_jurate_seal.get_consume_seal_name(invitem)) .. '{nl}'
		local cost_list = shared_item_jurate_seal.get_cost(invitem)
		for k, v in pairs(cost_list) do
			local mat_cls = nil
			if IS_STRING_COIN(k) == true then
				mat_cls = GetClass('Item', 'dummy_' .. k)
				
			else
				mat_cls = GetClass('Item', k)
			end

			local msg = string.format('- %s %s{nl}', dic.getTranslatedStr(mat_cls.Name), GET_COMMAED_STRING(v))
			desc = desc .. msg
		end
		descRichtext:SetText(desc)
	end
	
	local gBox = GET_CHILD(tooltipframe, mainframename,'ui::CGroupBox')
	local CSet = gBox:CreateOrGetControlSet('tooltip_etc_desc', 'tooltip_etc_desc', 0, before);
	local before_2 = CSet:GetHeight()
	tolua.cast(CSet, "ui::CControlSet");
	local BOTTOM_MARGIN = CSet:GetUserConfig("BOTTOM_MARGIN"); -- 맨 아랫쪽 여백
	CSet:Resize(CSet:GetWidth(), descRichtext:GetHeight() + BOTTOM_MARGIN);
	
	local diff = CSet:GetHeight() - before_2 + (BOTTOM_MARGIN / 2)
	gBox:Resize(gBox:GetWidth(), gBox:GetHeight() + diff)
	
	ypos = CSet:GetHeight() + CSet:GetY();
	ypos = DRAW_EQUIP_TRADABILITY(tooltipframe, invitem, ypos, mainframename);	
end


function attendance_gift_box_DESC(item)	
	local str = TryGetProp(item, 'StringArg', 'None')
	local list = StringSplit(str, ';')

	local desc = ''
	for i = 1, #list do
		local token = StringSplit(list[i], '/')
		local cls = GetClass('Item', token[1])		
		local msg = '- ' .. ScpArgMsg('get_item{name}{count}', 'name', dic.getTranslatedStr(cls.Name), 'count', token[2])
		desc = desc .. msg .. '{nl}'		
	end
	
	return desc
end

function attendance_gift_box_DESC_LIST(item)	
	local str = TryGetProp(item, 'StringArg', 'None')
	local list = StringSplit(str, ';')

	local desc = ''
	for i = 1, #list do
		local token = StringSplit(list[i], '/')
		local cls = GetClass('Item', token[1])		
		local msg = ScpArgMsg('get_item{name}{count}', 'name', dic.getTranslatedStr(cls.Name), 'count', token[2])
		if i == #list then
			desc = desc .. msg
		else
			desc = desc .. msg .. ', '		
		end
	end
	
	return desc
end

function trade_select_item_DESC(item)
	local name = TryGetProp(item, 'ClassName', 'None')
	local select_cls = GetClass('TradeSelectItem', name)
	local desc = ''
	if select_cls == nil then
		return desc
	end

	for i = 1, 50 do
		local item_name = TryGetProp(select_cls, 'SelectItemName_' .. i, 'None')
		local count = TryGetProp(select_cls, 'SelectItemCount_' .. i, 0)
		if item_name == 'None' or count == 0 then
			break
		end

		local cls = GetClass('Item', item_name)
		local msg = '- ' .. ScpArgMsg('get_item{name}{count}', 'name', dic.getTranslatedStr(cls.Name), 'count', count)
		desc = desc .. msg .. '{nl}'		
	end

	return desc
end
