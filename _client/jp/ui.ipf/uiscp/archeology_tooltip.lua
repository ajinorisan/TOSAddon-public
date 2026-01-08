-- archeology_tooltip.lua
-- 고고학 아이템 전용 툴팁 시스템

-- Arc_Prefix_NT 메타데이터 파싱
-- 포맷: "{option_cls_id};{value}" (예: "1;5")
function PARSE_ARCHEOLOGY_PREFIX_META(meta_str)
    if not meta_str or meta_str == "" or meta_str == "None" then
        return nil
    end
    
    local parts = StringSplit(meta_str, ';')
    if #parts ~= 2 then
        return nil
    end
    
    local option_cls_id = tonumber(parts[1])
    local value = tonumber(parts[2])
    
    if not option_cls_id or not value then
        return nil
    end
    
    -- archeology_option_list.xml에서 옵션 정보 가져오기
    local opt_info = GET_ARCHEOLOGY_OPTION_INFO(meta_str)
    
    return opt_info
end

-- 옵션 스탯을 한글 설명으로 변환
function GET_ARCHEOLOGY_STAT_DESC(stat_tag, value)
    local stat_info = {
        -- 발굴 관련 옵션 (1-24)
        ARCHEOLOGY_COIN_GAIN = {
            clmsg = "ARCHEOLOGY_COIN_GAIN",
            format = "+%d%%",
            color = "{#66FF66}"  -- 녹색
        },
        ARCHEOLOGY_DETECTING = {
            clmsg = "ARCHEOLOGY_DETECTING",
            format = "+%d",
            color = "{#66CCFF}"  -- 파란색
        },
        ARCHEOLOGY_RARE_CHANCE = {
            clmsg = "ARCHEOLOGY_RARE_CHANCE",
            format = "+%d%%",
            color = "{#FFCC66}"  -- 주황색
        },
        ARCHEOLOGY_QUALITY_BONUS = {
            clmsg = "ARCHEOLOGY_QUALITY_BONUS",
            format = "+%d%%",
            color = "{#FF66FF}"  -- 보라색
        },
        ARCHEOLOGY_SPECIAL_REWARD = {
            clmsg = "ARCHEOLOGY_SPECIAL_REWARD",
            format = "+%d%%",
            color = "{#66FFCC}"  -- 청록색
        },
        ARCHEOLOGY_CRITICAL_CHANCE = {
            clmsg = "ARCHEOLOGY_CRITICAL_CHANCE",
            format = "+%d%%",
            color = "{#FF6666}"  -- 빨간색
        },
        ARCHEOLOGY_MON_FIND = {
            clmsg = "ARCHEOLOGY_MON_FIND",
            format = "+%d%%",
            color = "{#FFFF66}"  -- 노란색
        },
        ARCHEOLOGY_DOUBLE_DROP = {
            clmsg = "ARCHEOLOGY_DOUBLE_DROP",
            format = "+%d%%",
            color = "{#66FF66}"  -- 녹색
        },
        
        -- 전투/방어 관련 옵션 (25-54)
        ARCHEOLOGY_HP_BONUS = {
            clmsg = "ARCHEOLOGY_HP_BONUS",
            format = "+%d",
            color = "{#FF99CC}"  -- 분홍색
        },
        ARCHEOLOGY_DEF_BONUS = {
            clmsg = "ARCHEOLOGY_DEF_BONUS",
            format = "+%d",
            color = "{#99CCFF}"  -- 하늘색
        },
        ARCHEOLOGY_MDEF_BONUS = {
            clmsg = "ARCHEOLOGY_MDEF_BONUS",
            format = "+%d",
            color = "{#CC99FF}"  -- 연보라색
        },
        ARCHEOLOGY_MON_DROP_RATE = {
            clmsg = "ARCHEOLOGY_MON_DROP_RATE",
            format = "+%.2f%%",
            color = "{#FFCC33}"  -- 금색
        },
        ARCHEOLOGY_DODGE = {
            clmsg = "ARCHEOLOGY_DODGE",
            format = "+%d",
            color = "{#99FF99}"  -- 연녹색
        },
        ARCHEOLOGY_CRIT_RES = {
            clmsg = "ARCHEOLOGY_CRIT_RES",
            format = "+%d",
            color = "{#FF9966}"  -- 연주황색
        },
        ARCHEOLOGY_HP_ON_KILL = {
            clmsg = "ARCHEOLOGY_HP_ON_KILL",
            format = "+%.2f%%",
            color = "{#FF6699}"  -- 진분홍색
        },
        ARCHEOLOGY_DMG_REDUCE = {
            clmsg = "ARCHEOLOGY_DMG_REDUCE",
            format = "+%d%%",
            color = "{#6699FF}"  -- 진파란색
        },
        ARCHEOLOGY_MOVE_SPEED = {
            clmsg = "ARCHEOLOGY_MOVE_SPEED",
            format = "+%d",
            color = "{#CCFF66}"  -- 연두색
        },
        ARCHEOLOGY_BLOCK_PEN = {
            clmsg = "ARCHEOLOGY_BLOCK_PEN",
            format = "+%d",
            color = "{#FFAA66}"  -- 오렌지색
        },
    }

    local info = stat_info[stat_tag]
    if not info then
        -- 알 수 없는 스탯
        return string.format("{#AAAAAA}%s: %d{/}", stat_tag, value)
    end

    -- ClMsg에서 이름 가져오기 (없으면 stat_tag 사용)
    local name = ClMsg(info.clmsg) or stat_tag
    local formatted_value = string.format(info.format, math.abs(value))
    return string.format("%s%s: %s{/}", info.color, name, formatted_value)
end

-- 고고학 아이템 툴팁 (메인 함수)
function ITEM_TOOLTIP_ARCHEOLOGY(tooltipframe, invitem, argStr, usesubframe)
    tolua.cast(tooltipframe, "ui::CTooltipFrame");
    
    local mainframename = 'archeology'
    
    if usesubframe == "usesubframe" then
        mainframename = "archeology_sub"
    elseif usesubframe == "usesubframe_recipe" then
        mainframename = "archeology_sub"
    end

    local ypos = DRAW_ETC_COMMON_TOOLTIP(tooltipframe, invitem, mainframename, argStr); -- 기타 템이라면 공통적으로 그리는 툴팁들	
    ypos = DRAW_ARCHEOLOGY_OPTIONS_TOOLTIP(tooltipframe, invitem, ypos, mainframename)

	ypos = DRAW_ETC_DESC_TOOLTIP(tooltipframe, invitem, ypos, mainframename); -- 아이템 설명.	
	ypos = DRAW_ETC_RECIPE_NEEDITEM_TOOLTIP(tooltipframe, invitem, ypos, mainframename); -- 재료템이라면 필요한 재료랑 보여줌
	ypos = DRAW_ETC_PREVIEW_TOOLTIP(tooltipframe, invitem, ypos, mainframename);			-- 아이콘 확대해서 보여줌
	ypos = DRAW_EQUIP_TRADABILITY(tooltipframe, invitem, ypos, mainframename);
    -- 2. 옵션 정보 그리기 (핵심 차별화 부분)

	local isHaveLifeTime = TryGetProp(invitem, "LifeTime", 0);	
	if 0 == tonumber(isHaveLifeTime) and GET_ITEM_EXPIRE_TIME(invitem) == 'None' then
		ypos = DRAW_SELL_PRICE(tooltipframe, invitem, ypos, mainframename); -- 가격
	else
		ypos = DRAW_REMAIN_LIFE_TIME(tooltipframe, invitem, ypos, mainframename); -- 남은 시간
	end

    local gBox = GET_CHILD(tooltipframe, mainframename, 'ui::CGroupBox')
    gBox:Resize(gBox:GetWidth(), ypos)
    tooltipframe:Resize(tooltipframe:GetWidth(), ypos)
end

-- 고고학 아이템 공통 정보 그리기
function DRAW_ARCHEOLOGY_COMMON_TOOLTIP(tooltipframe, invitem, mainframename, from)
    local gBox = GET_CHILD(tooltipframe, mainframename,'ui::CGroupBox')
    gBox:RemoveAllChild()
    
    -- 스킨 세팅
    local SkinName = GET_ITEM_TOOLTIP_SKIN(invitem)
    gBox:SetSkinName('test_Item_tooltip_normal')
    
    local CSet = gBox:CreateControlSet('tooltip_etc_common', 'tooltip_etc_common', 0, 0)
    tolua.cast(CSet, "ui::CControlSet")
    
    local GRADE_FONT_SIZE = CSet:GetUserConfig("GRADE_FONT_SIZE")
    
    -- 아이템 이미지
    local itemPicture = GET_CHILD(CSet, "itempic", "ui::CPicture")
    
    if invitem.TooltipImage ~= nil and invitem.TooltipImage ~= 'None' then
        local itemImg = invitem.TooltipImage
        itemPicture:SetImage(itemImg)
        itemPicture:ShowWindow(1)
        SET_SLOT_STAR_TEXT(itemPicture, invitem)
    else
        itemPicture:ShowWindow(0)
    end
    
    local questMark = GET_CHILD(CSet, "questMark", "ui::CPicture")
    questMark:ShowWindow(0)
    
    -- 별 그리기 (등급)
    SET_GRADE_TOOLTIP(CSet, invitem, GRADE_FONT_SIZE)
    
    -- 아이템 이름 세팅
    local fullname = TranslateDicID(GET_FULL_NAME(invitem, true))
    
    -- 고고학 아이템 특별 표시 추가
    fullname = "{@st43}" .. fullname .. "{/}"
    
    local nameChild = GET_CHILD(CSet, "name", "ui::CRichText")
    nameChild:SetText(fullname)
    nameChild:SetTextAlign("center","center")
    
    if nameChild:GetWidth() < nameChild:GetTextWidth() then
        nameChild:EnableSlideShow(1)
        nameChild:SetCompareTextWidthBySlideShow(true)
    else
        nameChild:EnableSlideShow(0)
        nameChild:SetCompareTextWidthBySlideShow(false)
    end
    
    -- 기본 정보 (쿨타임 등)
    local invDesc = GET_ITEM_DESC_BY_TOOLTIP_VALUE(invitem)
    local propRichtext = GET_CHILD(CSet,'prop_text','ui::CRichText')
    propRichtext:SetText(invDesc)
    
    local ypos = CSet:GetY() + CSet:GetHeight()
    return ypos
end

-- 고고학 옵션 정보 그리기
function DRAW_ARCHEOLOGY_OPTIONS_TOOLTIP(tooltipframe, invitem, ypos, mainframename)
    local gBox = GET_CHILD(tooltipframe, mainframename, 'ui::CGroupBox')
    
    local prefix_meta = TryGetProp(invitem, "Arc_Prefix", "None")
    if prefix_meta == "None" or prefix_meta == "" then
        return ypos
    end
    
    -- 옵션 정보 가져오기
    local opt_info = GET_ARCHEOLOGY_OPTION_INFO(prefix_meta)
    if not opt_info or #opt_info == 0 then
        return ypos
    end

    local cost = shared_archeology.get_item_cost_by_cls(invitem);
    
    -- 구분선 추가
    local labelLine = gBox:CreateOrGetControl('labelline', 'archeology_option_line', 0, ypos, gBox:GetWidth() - 20, 2)
    labelLine:SetSkinName('labelline_def_2')
    labelLine:SetGravity(ui.CENTER_HORZ, ui.TOP)
    ypos = ypos + 5
    
    -- 제목 추가
    local titleText = gBox:CreateOrGetControl('richtext', 'archeology_option_title', 10, ypos, gBox:GetWidth() - 20, 25)
    titleText:SetText(ScpArgMsg("archeology_effect"))
    titleText:SetTextAlign("center", "center")
    titleText:SetGravity(ui.CENTER_HORZ, ui.TOP)

    local costText = gBox:CreateOrGetControl('richtext', 'archeology_option_cost', 10, ypos, gBox:GetWidth() - 20, 25)
    costText:SetText(ScpArgMsg("archeology_cost{COST}", "COST", cost))
    costText:SetTextAlign("right", "center")
    costText:SetGravity(ui.RIGHT, ui.TOP)
    costText:SetMargin(0, costText:GetMargin().top, 10, 0);
    ypos = ypos + titleText:GetHeight()

    for i, opt in ipairs(opt_info) do
        -- 옵션 표시
        local optionText = gBox:CreateOrGetControl('richtext', 'archeology_option_text_'..i, 10, ypos, gBox:GetWidth() - 20, 20)
        local desc = opt.desc or opt.tag
        local value_str = GET_ARCHEOLOGY_STAT_DESC(opt.tag, opt.value)
        optionText = tolua.cast(optionText, 'ui::CRichText')
        optionText:SetMaxWidth(gBox:GetWidth() - 20)
        optionText:SetTextFixWidth(1)

        optionText:SetText(string.format("{@st42}%s{/}", value_str))
        optionText:SetTextAlign("center", "center")
        optionText:SetGravity(ui.CENTER_HORZ, ui.TOP)
        ypos = ypos + optionText:GetHeight() 
    end
    
    ypos = ypos + 5
    
    return ypos
end

-- 하위 호환: ETC 툴팁 함수들 사용
-- DRAW_ETC_DESC_TOOLTIP는 이미 etc_tooltip.lua에 정의되어 있음
-- DRAW_EQUIP_TRADABILITY도 이미 정의되어 있음
-- DRAW_SELL_PRICE, DRAW_REMAIN_LIFE_TIME도 이미 정의되어 있음

