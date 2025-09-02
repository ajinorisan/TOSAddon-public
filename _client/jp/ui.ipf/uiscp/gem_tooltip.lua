---- gem_tooltip.lua
-- 보석 아이템
function ITEM_TOOLTIP_GEM(tooltipframe, invitem, strarg)
	tolua.cast(tooltipframe, "ui::CTooltipFrame");
	local mainframename = 'gem'
	local ypos = DRAW_GEM_COMMON_TOOLTIP(tooltipframe, invitem, mainframename); -- 기타 템이라면 공통적으로 그리는 툴팁들
	ypos = DRAW_GEM_PROPERTYS_TOOLTIP(tooltipframe, invitem, ypos, mainframename); -- 젬의 속성들 그려줌
    ypos = DRAW_GEM_TRADABILITY_TOOLTIP(tooltipframe, invitem, ypos, mainframename);
	ypos = DRAW_GEM_DESC_TOOLTIP(tooltipframe, invitem, ypos, mainframename); -- 젬 설명. 프로퍼티 말고. 오른쪽 클릭 후 장착하고 어쩌고 하는 그런것들
	ypos = DRAW_SELL_PRICE(tooltipframe, invitem, ypos, mainframename);
end

function DRAW_GEM_COMMON_TOOLTIP(tooltipframe, invitem, mainframename)
	local gBox = GET_CHILD(tooltipframe, mainframename,'ui::CGroupBox')
	gBox:RemoveAllChild()
	local CSet = gBox:CreateControlSet('tooltip_gem_common', 'gem_common_cset', 0, 0);
	tolua.cast(CSet, "ui::CControlSet");

	local GRADE_FONT_SIZE = CSet:GetUserConfig("GRADE_FONT_SIZE"); -- 등급 나타내는 별 크기

	-- 아이템 이미지
	local itemPicture = GET_CHILD(CSet, "itempic", "ui::CPicture");
	if invitem.TooltipImage ~= nil and invitem.TooltipImage ~= 'None' then
		itemPicture:SetImage(invitem.TooltipImage);
		itemPicture:ShowWindow(1);
	else
		itemPicture:ShowWindow(0);
	end
	
	-- 로스팅 레벨
	local roatingText = GET_CHILD(CSet, "roastinglv_text");
	roatingText:ShowWindow(0);
	roatingText:SetTextByKey('level',invitem.GemRoastingLv)
	if invitem.GemRoastingLv > 0  then
        roatingText:ShowWindow(1)
	end

	-- 별 그리기
	SET_GRADE_TOOLTIP(CSet, invitem, GRADE_FONT_SIZE);

	-- 아이템 이름 세팅
	local fullname = GET_FULL_NAME(invitem, true);
	local nameChild = GET_CHILD(CSet, "name", "ui::CRichText");
	nameChild:SetText(fullname);

	-- 레벨 몇인지 : 그냥 경험치만 표시하고 레벨은 별 개수로 표시하도록 바꿈 - 140722 ayase
	local level_text = GET_CHILD(CSet,'level_text','ui::CGauge')
	--level_text:SetTextByKey("level", invitem.Level);

	-- 경험치 게이지
	local level_gauge = GET_CHILD(CSet,'level_gauge','ui::CGauge')
	local lv, curExp, maxExp = GET_ITEM_LEVEL_EXP(invitem);
	if curExp > maxExp then
		curExp = maxExp;
	end
	level_gauge:SetPoint(curExp, maxExp);

	if maxExp == 0 then
		level_text:ShowWindow(0)
		level_gauge:ShowWindow(0)
	end

	-- 무게
	local weightRichtext = GET_CHILD(CSet, "weight_text", "ui::CRichText");
	weightRichtext:SetTextByKey("weight",invitem.Weight);

	local BOTTOM_MARGIN = CSet:GetUserConfig("BOTTOM_MARGIN"); -- 맨 아랫쪽 여백
	CSet:Resize(CSet:GetWidth(),level_gauge:GetY() + level_gauge:GetHeight() + BOTTOM_MARGIN);
	gBox:Resize(gBox:GetWidth(),gBox:GetHeight()+CSet:GetHeight())
	return CSet:GetHeight();
end



function GET_GEM_PROPERTY_TEXT(itemObj, optionIdx, socketIdx)
	local realtext = nil
	local propName = "RandomOption_"..optionIdx;
	local marketCategory = TryGetProp(itemObj, "MarketCategory", "None")
	local propGroupName, propValue
	local clientMessage = 'None'
	if marketCategory == "Gem_GemSkill" and TryGetProp(itemObj, propName, "None") ~= "None" then
		propGroupName = itemObj["RandomOptionGroup_"..optionIdx];
		propName = itemObj["RandomOption_"..optionIdx];
		propValue = itemObj["RandomOptionValue_"..optionIdx];
	elseif TryGetProp(itemObj, "GroupName", "None") == "Armor" then
		local invitem = GET_INV_ITEM_BY_ITEM_OBJ(itemObj);		
		local optionInfo = item.GetSkillGemRandomOptionInfo(invitem, socketIdx, optionIdx - 1)
		propGroupName = optionInfo.group
		propName = optionInfo.name
		propValue = optionInfo.value	

		if propGroupName == "None" then
			return realtext
		end
	else
		return realtext
	end

	if propGroupName == 'ATK' then
		clientMessage = 'ItemRandomOptionGroupATK'
	elseif propGroupName == 'DEF' then
		clientMessage = 'ItemRandomOptionGroupDEF'
	elseif propGroupName == 'UTIL_WEAPON' then
		clientMessage = 'ItemRandomOptionGroupUTIL'
	elseif propGroupName == 'UTIL_ARMOR' then
		clientMessage = 'ItemRandomOptionGroupUTIL'
	elseif propGroupName == 'UTIL_SHILED' then
		clientMessage = 'ItemRandomOptionGroupUTIL'
	elseif propGroupName == 'STAT' then
		clientMessage = 'ItemRandomOptionGroupSTAT'
	end

	if propValue > 0 then
		realtext = ClMsg(clientMessage)..' '.. ScpArgMsg(propName) .."{img green_up_arrow 16 16}"..  propValue;
	else
		realtext = ClMsg(clientMessage)..' '..ScpArgMsg(propName) .."{img red_down_arrow 16 16}"..  propValue;
	end

	return realtext
end

-- 젬의 부위별 속성들
function DRAW_GEM_PROPERTYS_TOOLTIP(tooltipframe, invitem, yPos, mainframename)
	local gBox = GET_CHILD(tooltipframe, mainframename,'ui::CGroupBox')
	gBox:RemoveChild('tooltip_gem_property');
	
	local CSet = gBox:CreateOrGetControlSet('tooltip_gem_property', 'tooltip_gem_property', 0, yPos);
	local property_gbox = GET_CHILD(CSet,'gem_property_gbox','ui::CGroupBox')

	local inner_yPos = 0;
	local innerCSet = nil
	local innerpropcount = 0
	local innerpropypos = 0

	local propNameList = GET_ITEM_PROP_NAME_LIST(invitem)
	for i = 1 , #propNameList do

		local title = propNameList[i]["Title"];
		local propName = propNameList[i]["PropName"];
		local propValue = propNameList[i]["PropValue"];
		local useOperator = propNameList[i]["UseOperator"];
		local propOptDesc = propNameList[i]["OptDesc"];
		if title ~= nil then
			-- 각 프로퍼티 마다 컨트롤셋 생성. 무기에서 한번, 상의에서 한번 이런 식
			innerCSet = property_gbox:CreateOrGetControlSet('tooltip_each_gem_property', title, 0, inner_yPos); 
			local type_text = GET_CHILD(innerCSet,'type_text','ui::CRichText')
			type_text:SetText( ScpArgMsg(title) )
			local type_icon = GET_CHILD(innerCSet,'type_icon','ui::CPicture')
			tolua.cast(CSet, "ui::CControlSet");
			local imgname = GET_ICONNAME_BY_WHENEQUIPSTR(CSet,title)
			type_icon:SetImage( imgname )
			innerpropcount = 0
			innerpropypos = type_text:GetHeight()+type_text:GetY()
		else
			local type_text = GET_CHILD(innerCSet,'type_text','ui::CRichText')
			-- 각 프로퍼티의 옵션 마다 컨트롤셋 생성. 공격력+10에서 한번, 블록+10에서 한번 이런 식
			innerInnerCSet = innerCSet:CreateOrGetControlSet('tooltip_each_gem_property_each_text', 'proptext'..innerpropcount, 0, innerpropypos);
			
			local realtext = nil
			if propName == "CoolDown" then
				propValue = propValue / 1000;
				realtext = ScpArgMsg("CoolDown : {Sec} Sec", "Sec", propValue);
			elseif propName == "OptDesc" then
				realtext = propOptDesc;
			else
				if useOperator ~= nil and propValue > 0 then
					realtext = ScpArgMsg(propName) .. " : " .."{img green_up_arrow 16 16}".. propValue;
				else
					realtext = ScpArgMsg(propName) .. " : " .."{img red_down_arrow 16 16}".. propValue;
				end
			end
			
			local proptext = GET_CHILD(innerInnerCSet,'prop_text','ui::CRichText')
			if propName == "OptDesc" then
				realtext = propOptDesc;
			proptext:SetText( realtext )
			else
				proptext:SetText( realtext )
			end
			innerpropcount = innerpropcount + 1
			
			tolua.cast(innerCSet, "ui::CControlSet");
			local BOTTOM_MARGIN = innerCSet:GetUserConfig("BOTTOM_MARGIN")

			if BOTTOM_MARGIN == 'None' then
				BOTTOM_MARGIN = 10
			end

			innerpropypos = innerInnerCSet:GetY() + innerInnerCSet:GetHeight() 
			innerCSet:Resize(innerCSet:GetOriginalWidth(), innerInnerCSet:GetY() + innerInnerCSet:GetHeight() + BOTTOM_MARGIN )
			inner_yPos = innerCSet:GetY() + innerCSet:GetHeight()
		end
	end

	if TryGetProp(invitem, "RandomOption_1", "None") ~= "None" then
		innerCSet = property_gbox:CreateOrGetControlSet('tooltip_each_gem_property', "COM", 0, inner_yPos); 
		local type_text = GET_CHILD(innerCSet,'type_text','ui::CRichText')
		type_text:SetText( "" )
		innerpropcount = 0
		innerpropypos = type_text:GetHeight()+type_text:GetY()
		for i = 1, 4 do
			local realtext = GET_GEM_PROPERTY_TEXT(invitem, i)
			if realtext ~= nil then
				local type_text = GET_CHILD(innerCSet,'type_text','ui::CRichText')
				innerInnerCSet = innerCSet:CreateOrGetControlSet('tooltip_each_gem_property_each_text', 'proptext'..innerpropcount, 0, innerpropypos);
			
				local marker = GET_CHILD(innerInnerCSet, 'marker')
				marker:ShowWindow(0)
			
				local proptext = GET_CHILD(innerInnerCSet,'prop_text','ui::CRichText')
				proptext:SetText( realtext )
				proptext:SetMargin(50,0,0,0)
				innerpropcount = innerpropcount + 1
					
				tolua.cast(innerCSet, "ui::CControlSet");
				local BOTTOM_MARGIN = innerCSet:GetUserConfig("BOTTOM_MARGIN")
	
				if BOTTOM_MARGIN == 'None' then
					BOTTOM_MARGIN = 10
				end
	
				innerpropypos = innerInnerCSet:GetY() + innerInnerCSet:GetHeight() 
				innerCSet:Resize(innerCSet:GetOriginalWidth(), innerInnerCSet:GetY() + innerInnerCSet:GetHeight() + BOTTOM_MARGIN )
				inner_yPos = innerCSet:GetY() + innerCSet:GetHeight()
			end
		end
	end

	
	property_gbox:Resize(property_gbox:GetOriginalWidth(),inner_yPos);
	CSet:Resize(CSet:GetWidth(),CSet:GetHeight() + property_gbox:GetHeight() + property_gbox:GetY());
	gBox:Resize(gBox:GetWidth(),gBox:GetHeight() + CSet:GetHeight())
	return CSet:GetHeight() + CSet:GetY();
end

function DRAW_GEM_TRADABILITY_TOOLTIP(tooltipframe, invitem, ypos, mainframename)
	local gBox = GET_CHILD(tooltipframe, mainframename,'ui::CGroupBox')
	gBox:RemoveChild('tooltip_gem_tradability');

	local CSet = gBox:CreateControlSet('tooltip_gem_tradability', 'tooltip_gem_tradability', 0, ypos);
	tolua.cast(CSet, "ui::CControlSet");
	TOGGLE_TRADE_OPTION(CSet, invitem, 'option_npc', 'option_npc_text', 'ShopTrade')
	TOGGLE_TRADE_OPTION(CSet, invitem, 'option_market', 'option_market_text', 'MarketTrade')
	TOGGLE_TRADE_OPTION(CSet, invitem, 'option_teamware', 'option_teamware_text', 'TeamTrade')
	TOGGLE_TRADE_OPTION(CSet, invitem, 'option_trade', 'option_trade_text', 'UserTrade')

	gBox:Resize(gBox:GetWidth(),gBox:GetHeight()+CSet:GetHeight())
    return ypos + CSet:GetHeight();
end

function DRAW_SEALED_SKILL_GEM_INFO(invitem, desc)
	local level = TryGetProp(invitem, 'RandomGemLevel', 0)
	if level == 0 then
		level = 480
	end
	for i = 1, 4 do
		local op = 'RandomOptionValue_' .. i
		local value = TryGetProp(invitem, op, 0)
		if value > 0 then
			desc = desc .. '{nl}' .. ClMsg('CantUseCabinetCuzRandomOption')
			desc = desc .. '{nl}' .. ScpArgMsg('FreeUnEquipGem', 'level', level)
			return desc
		end
	end

	if TryGetProp(invitem, 'StringArg', 'None') == 'SkillGem' then
		desc = desc .. '{nl}' .. ClMsg('SkillGemDecompositionMsg')
	end

	return desc
end

function DRAW_GEM_DESC_TOOLTIP(tooltipframe, invitem, yPos, mainframename)
	local gBox = GET_CHILD(tooltipframe, mainframename,'ui::CGroupBox')
	gBox:RemoveChild('tooltip_gem_desc');
	
	local CSet = gBox:CreateOrGetControlSet('tooltip_gem_desc', 'tooltip_gem_desc', 0, yPos);
	local descRichtext= GET_CHILD(CSet,'desc_text','ui::CRichText')

	local desc = invitem.Desc

	desc = DRAW_SEALED_SKILL_GEM_INFO(invitem, desc)
	desc = DRAW_COLLECTION_INFO(invitem, desc)

	descRichtext:SetText(desc)

	tolua.cast(CSet, "ui::CControlSet");
	local BOTTOM_MARGIN = CSet:GetUserConfig("BOTTOM_MARGIN"); -- 맨 아랫쪽 여백
	CSet:Resize(CSet:GetWidth(), descRichtext:GetHeight() + BOTTOM_MARGIN);
	gBox:Resize(gBox:GetWidth(),gBox:GetHeight()+CSet:GetHeight())
	return CSet:GetHeight() + CSet:GetY();
end

-- 젬 툴팁의 옵션값들 리스트 생성.
function GETGEMTOOLTIP(obj, propNameList)
	local prop = geItemTable.GetProp(obj.ClassID);
	local gemExp = obj.ItemExp
	local lv = GET_ITEM_LEVEL_EXP(obj, gemExp);
	local socketProp = prop:GetSocketPropertyByLevel(lv);

	-- 알케미스트 젬 로스팅.  패널티부분을 로스팅 스킬레벨 만큼 빼서 적용
	local penaltyLv = 0;
	penaltyLv = lv - obj.GemRoastingLv;
	local drawPanetly = true;
	if 0 > penaltyLv then
		penaltyLv = 0;
	end

	if obj.GemRoastingLv > 0 and 0 >= penaltyLv then
		drawPanetly = false
	end

	for i = 0, ITEM_SOCKET_PROPERTY_TYPE_COUNT - 1 do
		local cnt = socketProp:GetPropAddCount(i);
		if cnt > 0 then
			local socketType = geItemTable.GetSocketPropertyTypeStr(i);
			local langType = "WhenEquipTo" ..socketType;

			propNameList[#propNameList + 1] = {};
			propNameList[#propNameList]["Title"] = langType;
		end

		-- 추가효과
		for j = 0 , cnt - 1 do
			local propAdd = socketProp:GetPropAddByIndex(i, j);
			-- 나도 얘네는 "Title"의 하위 테이블로 들어가는게 구조상 맞다고 생각은 하지만, 루아 테이블을 3중 이상 쓰는 것은 썩 좋지 않은거 같다. 안타깝게도 내 머리가 못따라감.
			propNameList[#propNameList + 1] = {};
			propNameList[#propNameList]["PropName"] = propAdd:GetPropName(); 
			propNameList[#propNameList]["PropValue"] = propAdd.value;
			propNameList[#propNameList]["UseOperator"] = true;
			if propAdd:GetPropName() == "OptDesc" then
			--print(propAdd:GetPropDesc())
				propNameList[#propNameList]["OptDesc"] = propAdd:GetPropDesc();
			end
		end

		if true == drawPanetly then
			-- 패널티
			local socketPenaltyProp = prop:GetSocketPropertyByLevel(penaltyLv);
			cnt = socketPenaltyProp:GetPropPenaltyAddCount(i);
			for j = 0 , cnt - 1 do
				local propPenaltyAdd = socketPenaltyProp:GetPropPenaltyAddByIndex(i, j);
				-- 나도 얘네는 "Title"의 하위 테이블로 들어가는게 구조상 맞다고 생각은 하지만, 루아 테이블을 3중 이상 쓰는 것은 썩 좋지 않은거 같다. 안타깝게도 내 머리가 못따라감.
				propNameList[#propNameList + 1] = {};
				propNameList[#propNameList]["PropName"] = propPenaltyAdd:GetPropName(); 
				propNameList[#propNameList]["PropValue"] = propPenaltyAdd.value;
				propNameList[#propNameList]["UseOperator"] = true;
				if propPenaltyAdd:GetPropName() == "OptDesc" then
					propNameList[#propNameList]["OptDesc"] = propPenaltyAdd:GetPropDesc();
				end
			end
		end
	end
end

-- 성물 젬 툴팁
local relic_gem_text_margin = 10
local function _GET_RELIC_GEM_LEVEL_FOR_TOOLTIP(item_obj)
	local lv = 0
	local item_info, where = GET_INV_ITEM_BY_ITEM_OBJ(item_obj);
	if where == 'inventory' and tonumber(item_info:GetIESID()) == 0 then
		-- 이 부분은 성물 UI의 소켓 관리 탭에만 해당하므로 장착한 성물에서 직접 젬 레벨을 가져옴
		local relic_item = session.GetEquipItemBySpot(item.GetEquipSpotNum('RELIC'))
		if relic_item ~= nil then
			local gem_type = relic_gem_type[TryGetProp(item_obj, 'GemType', 'None')]
			lv = relic_item:GetEquipGemLv(gem_type)
		end
	else
		lv = TryGetProp(item_obj, 'GemLevel', 1)
	end
	return lv
end

-- 에테르 젬 툴팁
function GET_AETHER_GEM_TOOLTIP(obj, prop_name_list, guid)
	if obj == nil then return; end
	if obj.GroupName ~= "Gem_High_Color" then return; end	

	local level = 1;
		local equip_item = session.GetEquipItemByGuid(guid);
		if equip_item ~= nil then
			local item_object = GetIES(equip_item:GetObject());
			local item_grade = TryGetProp(item_object, "ItemGrade", 0);
			if item_grade == 6 then
				local start_index, end_index = GET_AETHER_GEM_INDEX_RANGE(TryGetProp(item_object, 'UseLv', 0))	
				for i = start_index, end_index do
					if equip_item:IsAvailableSocket(i) == true then
						local gem_class_id = equip_item:GetEquipGemID(i);
						if gem_class_id ~= 0 and gem_class_id == obj.ClassID then
							local gem_class = GetClassByType("Item", gem_class_id);
							if gem_class ~= nil then
								local group_name = TryGetProp(gem_class, "GroupName", "None");
								if group_name == "Gem_High_Color" then
									level = equip_item:GetEquipGemLv(i);
								end
							end
						end
					end
				end
			end
	else
		local info, where = GET_INV_ITEM_BY_ITEM_OBJ(obj);
		if where == "inventory" and tonumber(info:GetIESID()) ~= 0 then
			level = get_current_aether_gem_level(obj);
		elseif where == "inventory" and tonumber(info:GetIESID()) == 0 then
			level = 1;
		end
	end

	local gem_class = GetClassByType("Item", obj.ClassID);
	if gem_class ~= nil then
		local string_arg = TryGetProp(gem_class, "StringArg");
		local get_func_str = "get_aether_gem_"..string_arg.."_prop";
		local func = _G[get_func_str];
		for i = 0, ITEM_SOCKET_PROPERTY_TYPE_COUNT - 1 do
			local socket_type = geItemTable.GetSocketPropertyTypeStr(i);
			if socket_type ~= "Helmet" and socket_type ~= "Armband" and socket_type ~= "ShirtsOrPants" and socket_type ~= "HandOrFoot" then
				local lang_type = "WhenEquipTo"..socket_type;
				prop_name_list[#prop_name_list + 1] = {};
				prop_name_list[#prop_name_list]["Title"] = lang_type;
				local add_count = 1;
				for j = 0, add_count - 1 do
					local prop_name, prop_value, use_operator = func(level);
					prop_name_list[#prop_name_list + 1] = {};
					prop_name_list[#prop_name_list]["PropName"] = prop_name;
					prop_name_list[#prop_name_list]["PropValue"] = prop_value;
					prop_name_list[#prop_name_list]["UseOperator"] = use_operator;
				end
			end
		end
	end
end

function GET_RELIC_GEM_NAME_WITH_FONT(item, font_size)
	if item == nil then
		return 'None'
	end

	if font_size == nil then
		font_size = 16
	end

	local gem_type_str = TryGetProp(item, 'GemType', 'None')
	local gem_type = relic_gem_type[gem_type_str]
	local font = '{@sti1c}'
	if gem_type == 0 then
		font = '{@st204_purple}'
	elseif gem_type == 1 then
		font = '{@st204_purple}'
	elseif gem_type == 2 then
		font = '{@st204_purple}'
	end

	font = font .. '{s'.. font_size .. '}%s{/}{/}'
	
	local name = dic.getTranslatedStr(TryGetProp(item, 'Name', 'None'))
	local name_str = string.format(font, name)

	return name_str
end

function _RELIC_GEM_OPTION_BY_LV_FOR_CABINET(gBox, ypos, gem_type, step, class_name, curlv)
	local margin = 5

	local gem_class = GetClass('Item', class_name)
	if gem_class == nil then
		return ypos
	end

	local option_text_format = 'RelicOptionLongText%s'
	local parent = gBox:GetParent()

	local option_name = TryGetProp(gem_class, 'RelicGemOption', 'None')
	local func_str = string.format('get_tooltip_%s_arg%d', option_name, step)
	local tooltip_func = _G[func_str]
	if tooltip_func ~= nil then
		local value, name, interval, type = tooltip_func()
		local total = value * math.floor(curlv / interval)
		local msg = string.format(option_text_format, type)
		local strInfo = ScpArgMsg(msg, 'name', ClMsg(name), 'total', total, 'interval', interval, 'value', value)
		local infoText = gBox:CreateControl('richtext', 'infoText' .. gem_type .. '_' .. step, relic_gem_text_margin, ypos, gBox:GetWidth() - relic_gem_text_margin, 30)
		infoText:SetTextFixWidth(1)
		infoText:SetText(strInfo)
		infoText:SetFontName('brown_16')
		ypos = ypos + infoText:GetHeight() + margin
	end

	return ypos
end

function _RELIC_GEM_OPTION_BY_LV(gBox, ypos, gem_type, step, class_name, curlv)
	local margin = 5

	local gem_class = GetClass('Item', class_name)
	if gem_class == nil then
		return ypos
	end

	local option_text_format = 'RelicOptionLongText%s'
	local parent = gBox:GetParent()
	if parent:GetName() ~= 'etc' then
		option_text_format = 'RelicOptionShortText%s'
	end

	local option_name = TryGetProp(gem_class, 'RelicGemOption', 'None')
	local func_str = string.format('get_tooltip_%s_arg%d', option_name, step)
	local tooltip_func = _G[func_str]
	if tooltip_func ~= nil then
		local value, name, interval, type = tooltip_func()
		local total = value * math.floor(curlv / interval)
		local msg = string.format(option_text_format, type)
		local strInfo = ScpArgMsg(msg, 'name', ClMsg(name), 'total', total, 'interval', interval, 'value', value)
		local infoText = gBox:CreateControl('richtext', 'infoText' .. gem_type .. '_' .. step, relic_gem_text_margin, ypos, gBox:GetWidth() - relic_gem_text_margin, 30)
		infoText:SetTextFixWidth(1)
		infoText:SetText(strInfo)
		infoText:SetFontName('brown_16')
		ypos = ypos + infoText:GetHeight() + margin
	end

	return ypos
end

function _RELIC_GEM_SPEND_RP_OPTION(gBox, ypos, gem_class_id)
	local margin = 5

	local gem_class = GetClassByType('Item', gem_class_id)
	if gem_class ~= nil then
		local text_margin = 10
		local infoText = gBox:CreateControl('richtext', 'spend_rp' .. gem_class_id, relic_gem_text_margin, ypos, gBox:GetWidth() - relic_gem_text_margin, 30)
		local spend_rp = TryGetProp(gem_class, 'Spend_RP', 0)
		local msgstr = 'SpendRPWhenRelicReleaseStart'
		if relic_gem_type[TryGetProp(gem_class, 'GemType', 'None')] == 1 then
			msgstr = 'SpendRPWhenRelicReleasePerSec'
		end

		local strInfo = ScpArgMsg(msgstr, 'value', spend_rp)

		infoText:SetTextFixWidth(1)
		infoText:SetText(strInfo)
		infoText:SetFontName('brown_16')
		ypos = ypos + infoText:GetHeight() + margin
	end

	return ypos
end

function _RELIC_GEM_RELEASE_OPTION(gBox, ypos, gem_class_id)
	local margin = 5

	local gem_class = GetClassByType('Item', gem_class_id)
	if gem_class ~= nil then
		local infoNameText = gBox:CreateControl('richtext', 'relic_release1', relic_gem_text_margin, ypos, gBox:GetWidth() - relic_gem_text_margin, 30)
		local nameStr = ClMsg('OptionWhenRelicReleaseStart')

		infoNameText:SetTextFixWidth(1)
		infoNameText:SetText(nameStr)
		infoNameText:SetFontName('brown_16')
		ypos = ypos + infoNameText:GetHeight() + margin

		local infoText = gBox:CreateControl('richtext', 'relic_release2', relic_gem_text_margin, ypos, gBox:GetWidth() - relic_gem_text_margin, 30)
		local option_name = TryGetProp(gem_class, 'RelicGemOption', 'None')
		local msgstr = string.format('RelicGem_%s_DescText', option_name)
		local strInfo = ClMsg(msgstr)
		
		infoText:SetTextFixWidth(1)
		infoText:SetText(strInfo)
		infoText:SetFontName('brown_16')
		ypos = ypos + infoText:GetHeight() + margin
	end

	return ypos
end

function ITEM_TOOLTIP_CABINET_GEM_RELIC(tooltipframe,invitem, argStr, argStr2, curlv)
	
end

function ITEM_TOOLTIP_GEM_RELIC(tooltipframe, invitem, argStr, argStr2, curlv)
	if invitem.GroupName ~= 'Gem_Relic' then
		return
	end
	tolua.cast(tooltipframe, 'ui::CTooltipFrame')
	local mainframename = 'etc'
	local ypos = DRAW_RELIC_GEM_COMMON_TOOLTIP(tooltipframe, invitem, mainframename, argStr)
	ypos = DRAW_RELIC_GEM_LV(tooltipframe, invitem, ypos, mainframename)
	ypos = DRAW_RELIC_GEM_OPTION(tooltipframe, invitem, ypos, mainframename)
	ypos = DRAW_ETC_DESC_TOOLTIP(tooltipframe, invitem, ypos, mainframename)
	ypos = DRAW_EQUIP_TRADABILITY(tooltipframe, invitem, ypos, mainframename)
	
	local gBox = GET_CHILD(tooltipframe, mainframename, 'ui::CGroupBox')
    gBox:Resize(gBox:GetWidth(), ypos)
end


function DRAW_RELIC_GEM_COMMON_TOOLTIP(tooltipframe, invitem, mainframename, isForgery)
	local gBox = GET_CHILD(tooltipframe, mainframename, 'ui::CGroupBox')
	gBox:RemoveAllChild()
	
    if invitem.ItemGrade == 0 then
        local SkinName  = GET_ITEM_TOOLTIP_SKIN(invitem)
    	gBox:SetSkinName('premium_skin')
    else
        local SkinName  = GET_ITEM_TOOLTIP_SKIN(invitem)
    	gBox:SetSkinName('test_Item_tooltip_equip2')
    end

	local relicGemCommonCSet = gBox:CreateControlSet('tooltip_relic_gem', 'equip_common_cset', 0, 0)
	tolua.cast(relicGemCommonCSet, 'ui::CControlSet')

	local legendTitle = GET_CHILD_RECURSIVELY(relicGemCommonCSet, 'legendTitle')
	legendTitle:ShowWindow(0)

	local itemClass = GetClassByType('Item', invitem.ClassID)
	local gradeText = relicGemCommonCSet:GetUserConfig('GRADE_TEXT_FONT')
	if itemClass.ItemGrade == 1 then
		gradeText = gradeText .. relicGemCommonCSet:GetUserConfig('NORMAL_GRADE_TEXT')
	elseif itemClass.ItemGrade == 2 then
		gradeText = gradeText .. relicGemCommonCSet:GetUserConfig('MAGIC_GRADE_TEXT')
	elseif itemClass.ItemGrade == 3 then
		gradeText = gradeText .. relicGemCommonCSet:GetUserConfig('RARE_GRADE_TEXT')
	elseif itemClass.ItemGrade == 4 then
		gradeText = gradeText .. relicGemCommonCSet:GetUserConfig('UNIQUE_GRADE_TEXT')
	elseif itemClass.ItemGrade == 5 then
		gradeText = gradeText .. relicGemCommonCSet:GetUserConfig('LEGEND_GRADE_TEXT')
	elseif itemClass.ItemGrade == 6 then
		gradeText = gradeText .. relicGemCommonCSet:GetUserConfig('GODDESS_GRADE_TEXT')
	end

	local gradeName = GET_CHILD_RECURSIVELY(relicGemCommonCSet, 'gradeName')
	gradeName:SetText(gradeText)

	-- 아이템 배경 이미지 : grade기준
	local item_bg = GET_CHILD(relicGemCommonCSet, 'item_bg', 'ui::CPicture')
	local gradeBGName = GET_ITEM_BG_PICTURE_BY_GRADE(invitem.ItemGrade)
	item_bg:SetImage(gradeBGName)

	-- 아이템 이미지
	local itemPicture = GET_CHILD(relicGemCommonCSet, 'itempic', 'ui::CPicture')
	if invitem.TooltipImage ~= nil and invitem.TooltipImage ~= 'None' then
		imageName = GET_EQUIP_ITEM_IMAGE_NAME(invitem, 'TooltipImage')
		itemPicture:SetImage(imageName)
		itemPicture:ShowWindow(1)
	else
		itemPicture:ShowWindow(0)
	end
	
	-- 아이템 이름 세팅
	local fullname = GET_RELIC_GEM_NAME_WITH_FONT(invitem, 18)
	local nameChild = GET_CHILD(relicGemCommonCSet, 'name', 'ui::CRichText')
	nameChild:SetText(fullname)
	nameChild:AdjustFontSizeByWidth(nameChild:GetWidth()) -- 폰트 사이즈를 조정
	nameChild:SetTextAlign('center', 'center') -- 중앙 정렬
	
	gBox:Resize(gBox:GetWidth(), gBox:GetHeight() + relicGemCommonCSet:GetHeight())

	local retxpos = relicGemCommonCSet:GetWidth()
	local retypos = relicGemCommonCSet:GetHeight()

	local picxpos = GET_CHILD_RECURSIVELY(relicGemCommonCSet, 'itempic'):GetWidth()
	local typexpos = GET_CHILD_RECURSIVELY(relicGemCommonCSet, 'bg_type'):GetWidth()

	local value_type = GET_CHILD_RECURSIVELY(relicGemCommonCSet, 'value_type', 'ui::CRichText')
	value_type:SetTextByKey('type', ScpArgMsg(invitem.GemType))
	value_type:AdjustFontSizeByWidth(retxpos - picxpos - typexpos - 20)

	local value_weight = GET_CHILD_RECURSIVELY(relicGemCommonCSet, 'value_weight')
	value_weight:SetTextByKey('weight', invitem.Weight .. ' ')

	return retypos
end

function DRAW_RELIC_GEM_LV(tooltipframe, invitem, ypos, mainframename)
	local margin = 5
	local class_name = TryGetProp(invitem, 'ClassName', 'None')	
	if class_name == 'None' then return end

	class_name = replace(class_name, 'PVP_', '')
	local gBox = GET_CHILD(tooltipframe, mainframename)
	if gBox == nil then return end

	local CSet = gBox:CreateOrGetControlSet('tooltip_relic_gem_lv', 'tooltip_relic_gem_lv', 0, ypos)
	-- 레벨 설정
	local _ypos = 74 -- offset
	local curlv = _GET_RELIC_GEM_LEVEL_FOR_TOOLTIP(invitem)

	local lvtext = GET_CHILD(CSet, 'lv', 'ui::CRichText')
	lvtext:SetTextByKey('value', curlv)

	local enablelv = curlv * 2
	if curlv == 1 then
		enablelv = 1		
	end
	local enable_lv_text = GET_CHILD(CSet, 'enable_lv', 'ui::CRichText')
	enable_lv_text:SetTextByKey('value', enablelv)

	local team_belong = TryGetProp(invitem, 'TeamBelonging', 1)
	if team_belong ~= 0 then
		local belong_text = CSet:CreateControl('richtext', 'belong_text', 10, _ypos, CSet:GetWidth(), 30)
		belong_text:SetTextFixWidth(1)
		belong_text:SetText(ClMsg('TeamBelongingItem'))
		_ypos = _ypos + belong_text:GetHeight() + margin
	end
	
	CSet:Resize(CSet:GetWidth(), _ypos + margin)
	ypos = ypos + CSet:GetHeight() + margin

	return ypos
end


function ITEM_TOOLTIP_GEM_RELIC_ONLY_FOR_CABINET(tooltipframe, invitem, mainframename,argStr,lv)
	
	if invitem.GroupName ~= 'Gem_Relic' then
		return
	end
	tolua.cast(tooltipframe, 'ui::CTooltipFrame')
	local ypos =0
	local margin = 5
	local class_name = TryGetProp(invitem, 'ClassName', 'None')	
	if class_name == 'None' then return end
	class_name = replace(class_name, 'PVP_', '')
	local gBox = GET_CHILD(tooltipframe, mainframename)
	if gBox == nil then return end

	local CSet = gBox:CreateOrGetControlSet('tooltip_relic_gem_lv_cabinet', 'tooltip_relic_gem_lv', 0, ypos)
	local _ypos = 74 
	local curlv = tostring(lv)
	local lvtext = GET_CHILD(CSet, 'lv', 'ui::CRichText')
	lvtext:SetTextByKey('value', curlv)
	local enablelv = curlv * 2
	if curlv == 1 then
		enablelv = 1		
	end
	local enable_lv_text = GET_CHILD(CSet, 'enable_lv', 'ui::CRichText')
	enable_lv_text:SetTextByKey('value', enablelv)
	CSet:Resize(CSet:GetWidth(), _ypos + margin)
	
	ypos = ypos + CSet:GetHeight() + margin


	local CSet = gBox:CreateOrGetControlSet('item_tooltip_gem_cabinet', 'item_tooltip_gem_cabinet', 0, ypos)
	local _ypos = 5 
	
	
	local gem_id = TryGetProp(invitem, 'ClassID', 0)
	local gem_type = relic_gem_type[TryGetProp(invitem, 'GemType', 'None')]
	if gem_type == 0 then
		_ypos = _RELIC_GEM_SPEND_RP_OPTION(CSet, _ypos, gem_id)
		_ypos = _RELIC_GEM_RELEASE_OPTION(CSet, _ypos, gem_id)
	elseif gem_type == 1 then
		_ypos = _RELIC_GEM_SPEND_RP_OPTION(CSet, _ypos, gem_id)
	end

	-- 레벨에 의한 옵션
	for i = 1, max_relic_option_count do
		_ypos = _RELIC_GEM_OPTION_BY_LV_FOR_CABINET(CSet, _ypos, 0, i, class_name, curlv)
	end
	CSet:Resize(CSet:GetWidth(), _ypos)

	ypos = ypos + CSet:GetHeight() + 5

	local gBox = GET_CHILD(tooltipframe, mainframename, 'ui::CGroupBox')
    gBox:Resize(gBox:GetWidth(), ypos)
end

function DRAW_RELIC_GEM_OPTION(tooltipframe, invitem, ypos, mainframename)
	local class_name = TryGetProp(invitem, 'ClassName', 'None')	
	if class_name == 'None' then return end

	class_name = replace(class_name, 'PVP_', '')
	local gBox = GET_CHILD(tooltipframe, mainframename)
	if gBox == nil then return end

	local CSet = gBox:CreateOrGetControlSet('item_tooltip_ark', 'tooltip_relic_gem_option', 0, ypos)
	local _ypos = 5 -- offset
	
	-- 성물해방
	local gem_id = TryGetProp(invitem, 'ClassID', 0)
	local gem_type = relic_gem_type[TryGetProp(invitem, 'GemType', 'None')]
	if gem_type == 0 then
		_ypos = _RELIC_GEM_SPEND_RP_OPTION(CSet, _ypos, gem_id)
		_ypos = _RELIC_GEM_RELEASE_OPTION(CSet, _ypos, gem_id)
	elseif gem_type == 1 then
		_ypos = _RELIC_GEM_SPEND_RP_OPTION(CSet, _ypos, gem_id)
	end

	-- 레벨에 의한 옵션
	local curlv = _GET_RELIC_GEM_LEVEL_FOR_TOOLTIP(invitem)
	for i = 1, max_relic_option_count do
		_ypos = _RELIC_GEM_OPTION_BY_LV(CSet, _ypos, 0, i, class_name, curlv)
	end
	
	CSet:Resize(CSet:GetWidth(), _ypos)
	ypos = ypos + CSet:GetHeight() + 5

	return ypos
end

-- Aether Gem ToolTip
function ITEM_TOOLTIP_GEM_AEHTER(tooltip_frame, inv_item, arg_str)
	if tooltip_frame == nil or inv_item == nil then return; end
	tolua.cast(tooltip_frame, "ui::CTooltipFrame");
	local main_frame_name = "gem";
	local ypos = DRAW_AETHER_GEM_COMMON_TOOLTIP(tooltip_frame, inv_item, main_frame_name, arg_str); 
	ypos = DRAW_AETHER_GEM_PROPERTYS_TOOLTIP(tooltip_frame, inv_item, ypos, main_frame_name, arg_str); 
	ypos = DRAW_AETHER_GEM_TRADABILITY_TOOLTIP(tooltip_frame, inv_item, ypos, main_frame_name);
	ypos = DRAW_AETHER_GEM_DESC_TOOLTIP(tooltip_frame, inv_item, ypos, main_frame_name); 
end

function DRAW_AETHER_GEM_COMMON_TOOLTIP(tooltip_frame, inv_item, main_frame_name, arg_str)
	local gbox = GET_CHILD_RECURSIVELY(tooltip_frame, main_frame_name, "ui::CGroupBox");
	if gbox ~= nil then
		gbox:RemoveAllChild();
		local ctrl_set = gbox:CreateControlSet("tooltip_aether_gem", "gem_common_cset", 0, 0);
		if ctrl_set ~= nil then
			tolua.cast(ctrl_set, "ui::CControlSet");
			-- item image
			local item_picture = GET_CHILD_RECURSIVELY(ctrl_set, "itempic", "ui::CPicture");
			if item_picture ~= nil and inv_item.TooltipImage ~= nil and inv_item.TooltipImage ~= "None" then
				item_picture:SetImage(inv_item.TooltipImage);
				item_picture:ShowWindow(1);
			else
				item_picture:ShowWindow(0);
			end

			-- item name
			local name_text = GET_CHILD_RECURSIVELY(ctrl_set, "name", "ui::CRichText");
			if name_text ~= nil then
				local name = GET_FULL_NAME(inv_item, true);
				name_text:SetText(name);
			end

			-- level
			local level_text = GET_CHILD_RECURSIVELY(ctrl_set, "level_text");
			if level_text ~= nil then
				local level = 1;
					local equip_item = session.GetEquipItemByGuid(arg_str);
					if equip_item ~= nil then
						local item_object = GetIES(equip_item:GetObject());
						local item_grade = TryGetProp(item_object, "ItemGrade", 0);
						if item_grade == 6 then
							local start_index, end_index = GET_AETHER_GEM_INDEX_RANGE(TryGetProp(item_object, 'UseLv', 0))	
							for i = start_index, end_index do
								if equip_item:IsAvailableSocket(i) == true then
									local gem_class_id = equip_item:GetEquipGemID(i);
									if gem_class_id ~= 0 and gem_class_id == inv_item.ClassID then
										local gem_class = GetClassByType("Item", gem_class_id);
										if gem_class ~= nil then
											local group_name = TryGetProp(gem_class, "GroupName", "None");
											if group_name == "Gem_High_Color" then
												level = equip_item:GetEquipGemLv(i);
											end
										end
									end
								end
							end
						end
				else
					local info, where = GET_INV_ITEM_BY_ITEM_OBJ(inv_item);
					if where == "inventory" and tonumber(info:GetIESID()) ~= 0 then
						level = get_current_aether_gem_level(inv_item);
					elseif where == "inventory" and tonumber(info:GetIESID()) == 0 then
						level = 1;
					end
				end
				level_text:SetTextByKey("level", level);
			end

			-- weight
			local weight_text = GET_CHILD_RECURSIVELY(ctrl_set, "weight_text", "ui::CRichText");
			if weight_text ~= nil then
				weight_text:SetTextByKey("weight", inv_item.Weight);
			end

			local bottom_margin = ctrl_set:GetUserConfig("BOTTOM_MARGIN");
			ctrl_set:Resize(ctrl_set:GetWidth(), bottom_margin);
			gbox:Resize(gbox:GetWidth(), gbox:GetHeight() + ctrl_set:GetHeight());
			return ctrl_set:GetHeight();
		end
	end
end

function DRAW_AETHER_GEM_PROPERTYS_TOOLTIP(tooltip_frame, inv_item, ypos, main_frame_name, arg_str)
	local gbox = GET_CHILD_RECURSIVELY(tooltip_frame, main_frame_name, "ui::CGroupBox");
	if gbox ~= nil then
		gbox:RemoveChild("tooltip_gem_property");
		local ctrl_set = gbox:CreateOrGetControlSet("tooltip_gem_property", "tooltip_gem_property", 0, ypos);
		if ctrl_set ~= nil then
			local property_gbox = GET_CHILD_RECURSIVELY(ctrl_set, "gem_property_gbox", "ui::CGroupBox");
			if property_gbox ~= nil then
				local inner_ctrl_set = nil;
				local inner_ypos = 0;
				local inner_prop_count = 0;
				local inner_prop_ypos = 0;
				local prop_name_list = AETHER_GET_ITEM_PROP_NAME_LIST(inv_item, arg_str);
				for i = 1, #prop_name_list do
					local title = prop_name_list[i]["Title"];
					local prop_name = prop_name_list[i]["PropName"];
					local prop_value = prop_name_list[i]["PropValue"];
					local use_operator = prop_name_list[i]["UseOperator"];
					local prop_opt_desc = prop_name_list[i]["OptDesc"];
					if title ~= nil then
						inner_ctrl_set = property_gbox:CreateOrGetControlSet("tooltip_each_gem_property", title, 0, inner_ypos);
						local type_text = GET_CHILD_RECURSIVELY(inner_ctrl_set, "type_text", "ui::CRichText");
						local type_icon = GET_CHILD_RECURSIVELY(inner_ctrl_set, "type_icon", "ui::CPicture");

						tolua.cast(ctrl_set, "ui::CControlSet");
						local img_name = GET_ICONNAME_BY_WHENEQUIPSTR(ctrl_set, title);
						type_icon:SetImage(img_name);
						inner_prop_count = 0;
						inner_prop_ypos = type_text:GetHeight() + type_text:GetY();
					else
						local type_text = GET_CHILD_RECURSIVELY(inner_ctrl_set, "type_text", "ui::CRichText");
						inner_inner_ctrlset = inner_ctrl_set:CreateOrGetControlSet("tooltip_each_gem_property_each_text", "proptext"..inner_prop_count, 0, inner_prop_ypos);

						local real_text = nil;
						if prop_name == "CoolDown" then
							prop_value = prop_value / 1000;
							real_text = ScpArgMsg("CoolDown : {Sec} Sec", "Sec", prop_value);
						elseif prop_name == "OptDesc" then
							real_text = prop_opt_desc;
						else
							if use_operator ~= nil and prop_value > 0 then
								real_text = ScpArgMsg(prop_name).." : ".."{img green_up_arrow 16 16}"..prop_value;
							else
								real_text = ScpArgMsg(prop_name).." : ".."{img red_down_arrow 16 16}"..prop_value;
							end
						end

						local prop_text = GET_CHILD_RECURSIVELY(inner_inner_ctrlset, "prop_text", "ui::CRichText");
						if prop_name == "OptDesc" then real_text = prop_opt_desc; end
						prop_text:SetText(real_text);
						inner_prop_count = inner_prop_count + 1;

						tolua.cast(inner_ctrl_set, "ui::CControlSet");
						local bottom_margin = inner_ctrl_set:GetUserConfig("BOTTOM_MARGIN");
						if bottom_margin == "None" then bottom_margin = 10; end

						inner_prop_ypos = inner_inner_ctrlset:GetY() + inner_inner_ctrlset:GetHeight();
						inner_ctrl_set:Resize(inner_ctrl_set:GetOriginalWidth(), inner_inner_ctrlset:GetY() + inner_inner_ctrlset:GetHeight() + bottom_margin);
						inner_ypos = inner_ctrl_set:GetY() + inner_ctrl_set:GetHeight();
					end
				end

				property_gbox:Resize(property_gbox:GetOriginalWidth(), inner_ypos);
				ctrl_set:Resize(ctrl_set:GetWidth(), ctrl_set:GetHeight() + property_gbox:GetHeight() + property_gbox:GetY());
				gbox:Resize(gbox:GetWidth(), gbox:GetHeight() + ctrl_set:GetHeight());
				return ctrl_set:GetHeight() + ctrl_set:GetY();
			end
		end
	end
end

function DRAW_AETHER_GEM_TRADABILITY_TOOLTIP(tooltip_frame, inv_item, ypos, main_frame_name)
	local gbox = GET_CHILD_RECURSIVELY(tooltip_frame, main_frame_name, "ui::CGroupBox");
	if gbox ~= nil then
		gbox:RemoveChild("tooltip_gem_tradability");
		local ctrl_set = gbox:CreateControlSet("tooltip_gem_tradability", "tooltip_gem_tradability", 0, ypos);
		if ctrl_set ~= nil then
			tolua.cast(ctrl_set, "ui::CControlSet");
			TOGGLE_TRADE_OPTION(ctrl_set, inv_item, "option_npc", "option_npc_text", "ShopTrade")
			TOGGLE_TRADE_OPTION(ctrl_set, inv_item, "option_market", "option_market_text", "MarketTrade")
			TOGGLE_TRADE_OPTION(ctrl_set, inv_item, "option_teamware", "option_teamware_text", "TeamTrade")
			TOGGLE_TRADE_OPTION(ctrl_set, inv_item, "option_trade", "option_trade_text", "UserTrade")
			gbox:Resize(gbox:GetWidth(), gbox:GetHeight() + ctrl_set:GetHeight())
			return ypos + ctrl_set:GetHeight();
		end
	end
end

function DRAW_AETHER_GEM_DESC_TOOLTIP(tooltip_frame, inv_item, ypos, main_frame_name)
	local gbox = GET_CHILD_RECURSIVELY(tooltip_frame, main_frame_name, "ui::CGroupBox");
	if gbox ~= nil then
		gbox:RemoveChild("tooltip_gem_desc");
		local ctrl_set = gbox:CreateOrGetControlSet('tooltip_gem_desc', 'tooltip_gem_desc', 0, ypos);
		if ctrl_set ~= nil then
			local desc_text = GET_CHILD_RECURSIVELY(ctrl_set, "desc_text", "ui::CRichText");
			if desc_text ~= nil then
				local desc = inv_item.Desc				
				if TryGetProp(inv_item, 'ItemGrade', 0) == 0 and is_max_aether_gem_level(inv_item) == true then
					desc = desc .. '{nl} {nl}' .. ClMsg('EnableUpgradeAetherGem')
				end
				
				desc_text:SetText(desc);
				tolua.cast(ctrl_set, "ui::CControlSet");
				local bottom_margin = ctrl_set:GetUserConfig("BOTTOM_MARGIN");
				ctrl_set:Resize(ctrl_set:GetWidth(), desc_text:GetHeight() + bottom_margin);
				gbox:Resize(gbox:GetWidth(), gbox:GetHeight() + ctrl_set:GetHeight());
				return ctrl_set:GetHeight() + ctrl_set:GetY();
			end
		end
	end
end