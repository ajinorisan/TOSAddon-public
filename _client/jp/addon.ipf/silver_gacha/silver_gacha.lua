function SILVER_GACHA_ON_INIT(addon, frame)
    addon:RegisterMsg('SILVER_GACHA_INFO', 'ON_SILVER_GACHA_INFO');
    addon:RegisterMsg('SILVER_GACHA_INFO_CHANGE', 'ON_SILVER_GACHA_INFO_CHANGE');
    addon:RegisterMsg('SILVER_GACHA_EXEC_RESULT', 'ON_SILVER_GACHA_EXEC_RESULT');
    addon:RegisterMsg('SILVER_GACHA_NO_EVENT_EXIST', 'ON_SILVER_GACHA_NO_EVENT_EXIST');
end

local SILVER_GACHA_UNLIMITED_COUNT = 10000000

-- SETTING
function SILVER_GACHA_GET_EVENT_ID()
	return ui.GetFrame("silver_gacha"):GetUserConfig("EVENT_ID")
end

function SILVER_GACHA_SET_EVENT_ID(eventID)
	local frame = ui.GetFrame("silver_gacha")
	frame:SetUserConfig("EVENT_ID", eventID)
end

-- OPEN / CLOSE
function SILVER_GACHA_OPEN()
    SILVER_GACHA_SPINE()
end

function SILVER_GACHA_CLOSE()
    SILVER_GACHA_AUTO_STOP()
end

-- ADDON MSG
function ON_SILVER_GACHA_INFO()
    if ui.GetFrame('godprotection'):IsVisible() == 1 then
        return
    end

    local list = GetSilverGachaEventList()
    local select = 1 -- 추후 이벤트가 동시에 여러개 진행될 경우, 이 부분을 수정

    ui.OpenFrame("silver_gacha")

    if #list > 0 then
        SILVER_GACHA_SET_EVENT_ID(list[select])
        SILVER_GACHA_SET_UI()
        SILVER_GACHA_INIT()
    end
end

function ON_SILVER_GACHA_NO_EVENT_EXIST()
    ui.SysMsg(ScpArgMsg("SilverGachaNoEvent"))
end

function ON_SILVER_GACHA_INFO_CHANGE()
    local frame = ui.GetFrame("silver_gacha")
    local eventID = SILVER_GACHA_GET_EVENT_ID()

    -- 아이템
    for rank = 1, 3 do
        local gb = frame:GetChild("protection_gb")
        local itemList = SILVER_GACHA_GET_ITEM_LIST_BY_RANK(eventID, rank)

        for i = 1, #itemList do
            local itemID = itemList[i]
            local itemData = GetClassByType("Item", itemID)
            local nowCount, originalCount = GetSilverGachaItemCount(eventID, itemID)

            local ctrl = AUTO_CAST(gb:GetChild('ITEMLIST_'..rank..'_'..i))
            local slot = AUTO_CAST(ctrl:GetChild('slot'))
            local text = AUTO_CAST(ctrl:GetChild('slot_text'))

            if originalCount < SILVER_GACHA_UNLIMITED_COUNT then
                text:SetTextByKey("now", nowCount)
                text:SetTextByKey("original", originalCount)

                if nowCount == 0 then
                    slot:GetIcon():SetColorTone('FF444444')
                end
            end
        end
    end
end

function ON_SILVER_GACHA_EXEC_RESULT(frame, msg, argStr, itemID)
    SILVER_GACHA_SET_DEDICATE_SLOT_UI(frame, itemID)
end

-- INIT
function SILVER_GACHA_INIT()
    local frame = ui.GetFrame("silver_gacha")

	if ui.CheckHoldedUI() == true then
        return
    end

    GET_CHILD_RECURSIVELY(frame, "auto_edit"):SetText('')
    GET_CHILD_RECURSIVELY(frame, 'dedication_slot'):ClearIcon()
    
    SILVER_GACHA_TOGGLE_BUTTON("ON")
    
    GET_CHILD_RECURSIVELY(frame, "once_count_edit"):SetText('1')
    SILVER_GACHA_TOTAL_ONCE_SILVER_UPDATE(1)
end

-- UI SET
function SILVER_GACHA_SET_UI()
    local frame = ui.GetFrame("silver_gacha")
    local gb = frame:GetChild("protection_gb")

    gb:RemoveAllChild()
    
    -- 배경 이미지
    local pic = AUTO_CAST(gb:CreateControl('picture', 'protection_gb_pic', 572, 720, ui.CENTER_HORZ, ui.CENTER_VERT, 0, 0, 0, 0))
    pic:SetImage(frame:GetUserConfig('BACKGROUND_IMAGE'))

    -- 이벤트 ID
    local eventID = SILVER_GACHA_GET_EVENT_ID()

    -- 시간
    local timeText = GET_CHILD_RECURSIVELY(frame, 'time')
    local month1, day1, month2, day2 = GetSilverGachaEventTime(eventID)

    timeText:SetTextByKey("month1", month1)
    timeText:SetTextByKey("month2", month2)
    timeText:SetTextByKey("day1", day1)
    timeText:SetTextByKey("day2", day2)

    -- 비용
    local dedicate = GET_CHILD_RECURSIVELY(frame, 'dedication_silver')

    dedicate:SetText("{@st41b}{s16}"..GetSilverGachaEventCost(eventID))
    
    -- 아이템
    for rank = 1, 3 do
        local gb = frame:GetChild("protection_gb")
        local itemList = SILVER_GACHA_GET_ITEM_LIST_BY_RANK(eventID, rank)

        for i = 1, #itemList do
            local itemID = itemList[i]
            local itemData = GetClassByType("Item", itemID)
            local nowCount, originalCount = GetSilverGachaItemCount(eventID, itemID)

            local ctrl = gb:CreateOrGetControlSet('silver_gacha_slot', 'ITEMLIST_'..rank..'_'..i, 0, 0);

            -- 테두리 세팅
            local pic = AUTO_CAST(ctrl:GetChild('slot_pic'))

            local imageName = frame:GetUserConfig("SLOT_IMAGE_RANK"..rank)
            local imageSize = ui.GetSkinImageSize(imageName)

            pic:SetImage(imageName)
            pic:Resize(imageSize.x, imageSize.y)

            -- 아이템 슬롯
            local slot = AUTO_CAST(ctrl:GetChild('slot'))

            SET_SLOT_IMG(slot, itemData.Icon)
            SET_ITEM_TOOLTIP_BY_TYPE(slot:GetIcon(), itemData.ClassID)

            slot:GetIcon():SetTooltipOverlap(1)
            slot:SetUserValue("ITEM_ID", itemID)

            -- 텍스트
            local text = AUTO_CAST(ctrl:GetChild('slot_text'))

            if originalCount >= SILVER_GACHA_UNLIMITED_COUNT then
                text:SetText("{@st100white_16}{s26}"..ScpArgMsg("SilverGachaMaxVal"))
            else
                text:SetTextByKey("now", nowCount)
                text:SetTextByKey("original", originalCount)

                if nowCount == 0 then
                    slot:GetIcon():SetColorTone('FF444444')
                end
            end

            -- 위치 조정
            local offset_x = (gb:GetWidth() + 100) / (#itemList + 1)
            local offset_y = 220

            ctrl:SetMargin(i * offset_x - ctrl:GetWidth() / 2 - 50, (rank-1) * offset_y + 80, 0, 0)
        end
    end
end

function SILVER_GACHA_SET_DEDICATE_SLOT_UI(frame, itemID)
	local slot = GET_CHILD_RECURSIVELY(frame, 'dedication_slot')
    local itemData = GetClassByType('Item', itemID)
    
    -- 가챠 성공
	if itemData ~= nil then
		SET_SLOT_IMG(slot, itemData.Icon)
        SET_ITEM_TOOLTIP_BY_TYPE(slot:GetIcon(), itemData.ClassID)
        
		slot:GetIcon():SetTooltipOverlap(1)
        slot:SetUserValue("ITEM_ID", itemID)
        
        -- 이펙트
        SILVER_GACHA_RESULT_EFFECT(itemID)

    -- 가챠 실패
    else
        SET_SLOT_IMG(slot, GetClass('Item', 'misc_silver_gacha_mileage').Icon)

        -- 이펙트
        SILVER_GACHA_POINT_RESULT_EFFECT()
    end

    -- 사운드
    imcSound.PlaySoundEvent("sys_quest_item_get")
end

-- EFFECT
function SILVER_GACHA_DEDICATION_EFFECT()
    local frame = ui.GetFrame("silver_gacha")
	if frame:IsVisible() == 0 then
		return
    end

	local DEDICATION_BUTTON_EFFECT_NAME = frame:GetUserConfig('DEDICATION_BUTTON_EFFECT')
	local DEDICATION_BUTTON_EFFECT_SCALE = tonumber(frame:GetUserConfig('DEDICATION_BUTTON_EFFECT_SCALE'))
    local DEDICATION_BUTTON_EFFECT_DURATION = tonumber(frame:GetUserConfig('DEDICATION_BUTTON_EFFECT_DURATION'))
    
	local dedication_btn_gb = GET_CHILD_RECURSIVELY(frame, 'dedication_btn_gb')
	if dedication_btn_gb == nil then
		return
    end
    
	dedication_btn_gb:PlayUIEffect(DEDICATION_BUTTON_EFFECT_NAME, DEDICATION_BUTTON_EFFECT_SCALE, 'DEDICATION_BUTTON_EFFECT')
    ReserveScript("_SILVER_GACHA_DEDICATION_EFFECT()", DEDICATION_BUTTON_EFFECT_DURATION)
end

function _SILVER_GACHA_DEDICATION_EFFECT()
	local frame = ui.GetFrame("silver_gacha")
	if frame:IsVisible() == 0 then
		return
	end

	local dedication_btn_gb = GET_CHILD_RECURSIVELY(frame, 'dedication_btn_gb')
    if dedication_btn_gb == nil then
        return
    end
    
    dedication_btn_gb:StopUIEffect('DEDICATION_BUTTON_EFFECT', true, 0.5)
end

function SILVER_GACHA_RESULT_EFFECT(itemID)
	local frame = ui.GetFrame("silver_gacha")
	if frame:IsVisible() == 0 then
		return
    end

	local RESULT_EFFECT_NAME = frame:GetUserConfig('RESULT_EFFECT')
	local RESULT_EFFECT_SCALE = tonumber(frame:GetUserConfig('RESULT_EFFECT_SCALE'))
    local RESULT_EFFECT_DURATION = tonumber(frame:GetUserConfig('RESULT_EFFECT_DURATION'))
    
	local slot = SILVER_GACHA_GET_SLOT(itemID)
	if slot == nil then
		return
	end

	slot:PlayUIEffect(RESULT_EFFECT_NAME, RESULT_EFFECT_SCALE, 'RESULT_EFFECT')
	ReserveScript("_SILVER_GACHA_RESULT_EFFECT()", RESULT_EFFECT_DURATION)
end

function _SILVER_GACHA_RESULT_EFFECT()
	local frame = ui.GetFrame("silver_gacha")
	if frame:IsVisible() == 0 then
		return
	end
	
	local dedication_slot = GET_CHILD_RECURSIVELY(frame, 'dedication_slot')
    local itemID = dedication_slot:GetUserValue("ITEM_ID")
    
	local slot = SILVER_GACHA_GET_SLOT(itemID)
	if slot == nil then
		return
	end

	slot:StopUIEffect('RESULT_EFFECT', true, 0.5)
end

function SILVER_GACHA_POINT_RESULT_EFFECT()
    local frame = ui.GetFrame("silver_gacha")
	if frame:IsVisible() == 0 then
		return
    end

	local RESULT_EFFECT_NAME = frame:GetUserConfig('RESULT_EFFECT')
	local RESULT_EFFECT_SCALE = tonumber(frame:GetUserConfig('POINT_RESULT_EFFECT_SCALE'))
    local RESULT_EFFECT_DURATION = tonumber(frame:GetUserConfig('RESULT_EFFECT_DURATION'))
    
	local slot = GET_CHILD_RECURSIVELY(frame, "dedication_slot")
	if slot == nil then
		return
	end

	slot:PlayUIEffect(RESULT_EFFECT_NAME, RESULT_EFFECT_SCALE, 'RESULT_EFFECT')
	ReserveScript("_SILVER_GACHA_POINT_RESULT_EFFECT()", RESULT_EFFECT_DURATION)
end

function _SILVER_GACHA_POINT_RESULT_EFFECT()
	local frame = ui.GetFrame("silver_gacha")
	if frame:IsVisible() == 0 then
		return
	end
	
	local slot = GET_CHILD_RECURSIVELY(frame, 'dedication_slot')
	if slot == nil then
		return
	end

	slot:StopUIEffect('RESULT_EFFECT', true, 0.5)
end

-- EXEC (NORMAL)
function SILVER_GACHA_CLICK()
    if ui.CheckHoldedUI() == true then
        return
	end
	
    local frame = ui.GetFrame("silver_gacha")
    local eventID = SILVER_GACHA_GET_EVENT_ID()
    local silverCost = GetSilverGachaEventCost(eventID)

    -- 실버 체크
    if IS_SILVER_ENOUGH(silverCost) == false then
        ui.SysMsg(ScpArgMsg("REQUEST_TAKE_SILVER"))
        return
    end

    -- UI 홀드
    ui.SetHoldUI(true)
    ReserveScript("BUTTON_UNFREEZE()", WORLD_EVENT_CLICK_DELAY)

    -- 버튼 변경
    SILVER_GACHA_TOGGLE_BUTTON("OFF")

    -- 이펙트
    SILVER_GACHA_DEDICATION_EFFECT()

    -- 실행
    local once_edit = GET_CHILD_RECURSIVELY(frame, "once_count_edit");
    local onceCnt = tonumber(once_edit:GetText());
    silver_gacha_shop.RequestSilverGachaShopGamble(SILVER_GACHA_GET_EVENT_ID(), true, onceCnt)
end

-- EXEC (AUTO)
function SILVER_GACHA_AUTO_START_BTN_CLICK(parent, ctrl)
	if ui.CheckHoldedUI() == true then
        return
    end

    local frame = ui.GetFrame("silver_gacha")

    local edit = GET_CHILD_RECURSIVELY(frame, "auto_edit")
    local auto_btn = GET_CHILD_RECURSIVELY(frame, "auto_btn")
    local dedication_btn = GET_CHILD_RECURSIVELY(frame, 'dedication_btn')

	edit:SetEnable(0)
	auto_btn:SetEnable(0)
	dedication_btn:SetEnable(0)
    
    SILVER_GACHA_AUTO_START(edit:GetText())
end

function SILVER_GACHA_AUTO_STOP_BTN_CLICK(parent, ctrl)
    SILVER_GACHA_AUTO_STOP()
end

function SILVER_GACHA_AUTO_START(count)
    AddUniqueTimerFunccWithLimitCount('AUTO_SILVER_GACHA_DEDICATION_CLICK', 100 + WORLD_EVENT_CLICK_DELAY * 1000, count)	
end

function SILVER_GACHA_AUTO_STOP()
    local frame = ui.GetFrame("silver_gacha")

    local edit = GET_CHILD_RECURSIVELY(frame, "auto_edit")
    local auto_btn = GET_CHILD_RECURSIVELY(frame, "auto_btn")
    local dedication_btn = GET_CHILD_RECURSIVELY(frame, 'dedication_btn')

	edit:SetEnable(1)
	auto_btn:SetEnable(1)
    dedication_btn:SetEnable(1)
    
    RemoveLuaTimerFunc('AUTO_SILVER_GACHA_DEDICATION_CLICK')
end

function AUTO_SILVER_GACHA_DEDICATION_CLICK()
    if ui.CheckHoldedUI() == true then
        SILVER_GACHA_AUTO_STOP()
	end
	
    local frame = ui.GetFrame("silver_gacha")
    local eventID = SILVER_GACHA_GET_EVENT_ID()
    local silverCost = GetSilverGachaEventCost(eventID)

    -- 실버 체크
    if IS_SILVER_ENOUGH(silverCost) == false then
        ui.SysMsg(ScpArgMsg("REQUEST_TAKE_SILVER"))
        SILVER_GACHA_AUTO_STOP()
        return
    end

    -- 횟수 체크
	local edit = GET_CHILD_RECURSIVELY(frame, "auto_edit")
    local count = edit:GetText()
    
	if edit:GetText() == "" or tonumber(count) < 1  then
		SILVER_GACHA_AUTO_STOP(frame)
		return
    else
        edit:SetText(tonumber(count)-1)
    end

    -- 실행
    local once_edit = GET_CHILD_RECURSIVELY(frame, "once_count_edit");
    local onceCnt = tonumber(once_edit:GetText());
    silver_gacha_shop.RequestSilverGachaShopGamble(SILVER_GACHA_GET_EVENT_ID(), true, onceCnt)
end

-- SCRIPT

-- UI 열기
function OPEN_SILVER_GACHA()
    silver_gacha_shop.RequestSilverGachaShopInfo()
end

-- 실버가 충분한지 체크
function IS_SILVER_ENOUGH(silverCost)
    local invItem = session.GetInvItemByName('Vis')
    if invItem == nil then
        return false
    end

    if tonumber(invItem:GetAmountStr()) < silverCost then
        return false
    end

    return true
end

-- 당첨된 아이템의 슬롯 가져오기
function SILVER_GACHA_GET_SLOT(itemID)
    local frame = ui.GetFrame("silver_gacha")
    local eventID = SILVER_GACHA_GET_EVENT_ID()
	
    for rank = 1, 3 do
        local itemList = SILVER_GACHA_GET_ITEM_LIST_BY_RANK(eventID, rank)

        for i = 1, #itemList do
            local slot = GET_CHILD_RECURSIVELY(frame, 'ITEMLIST_'..rank..'_'..i)
            local slotItemID = slot:GetUserValue("ITEM_ID")
            
            if tonumber(itemID) == tonumber(slotItemID) then
                return slot
            end
        end
	end

	return nil
end

-- 확인/헌납 버튼 토글
function SILVER_GACHA_TOGGLE_BUTTON(dedicate)
    local frame = ui.GetFrame("silver_gacha")
    local btn = GET_CHILD_RECURSIVELY(frame, 'dedication_btn')
    local okbtn = GET_CHILD_RECURSIVELY(frame, 'dedication_okbtn')

    if dedicate == "ON" then
        btn:ShowWindow(1)
        okbtn:ShowWindow(0)
    else
        btn:ShowWindow(0)
        okbtn:ShowWindow(1)
    end
end

-- AUTO EDIT 클릭
function SILVER_GACHA_AUTO_EDIT_CLICK(parent, ctrl)
    local auto_text = GET_CHILD(parent, "auto_text")
    auto_text:ShowWindow(0)
end

-- 랭크에 따른 아이템 리스트
function SILVER_GACHA_GET_ITEM_LIST_BY_RANK(eventID, rank)
    local list = GetSilverGachaItemList(eventID)

    for i = #list, 1, -1 do
        if GetSilverGachaItemRank(eventID, list[i]) ~= rank then
            table.remove(list, i)
        end
    end

	return list
end

function SILVER_GACHA_SPINE()
	local frame = ui.GetFrame("silver_gacha");
    local picture = GET_CHILD_RECURSIVELY(frame, 'spinepic');
	local isEnableSpine = config.GetXMLConfig("EnableAnimateItemIllustration");
	if isEnableSpine == 1 then

		local spineToolTip = frame:GetUserConfig("SPINE")
		local spineInfo = geSpine.GetSpineInfo(spineToolTip);
		if spineInfo ~= nil then
			picture:CreateSpineActor(spineInfo:GetRoot(), spineInfo:GetAtlas(), spineInfo:GetJson(), "", spineInfo:GetAnimation());
		end	
	end
	
end

function SILVER_GACHA_ONCE_COUNT_TYPING(parent, ctrl)
    local edit = GET_CHILD(parent, "once_count_edit");
    if edit:GetText() == nil or edit:GetText() == "" then
        edit:SetText(1);
    end

    local curCnt = tonumber(edit:GetText());
    SILVER_GACHA_TOTAL_ONCE_SILVER_UPDATE(upCnt);
end

function SILVER_GACHA_ONCE_COUNT_UPBTN_CLICK(parent, ctrl)
    local edit = GET_CHILD(parent, "once_count_edit");

    local curCnt = tonumber(edit:GetText());
    local upCnt = curCnt + 1; 
    if 5 < upCnt then
        upCnt = 5;
    end

    edit:SetText(upCnt);
    SILVER_GACHA_TOTAL_ONCE_SILVER_UPDATE(upCnt);
end

function SILVER_GACHA_ONCE_COUNT_DOWNBTN_CLICK(parent, ctrl)
    local edit = GET_CHILD(parent, "once_count_edit");
    
    local curCnt = tonumber(edit:GetText());
    local downCnt = curCnt - 1; 
    if downCnt < 1 then
        downCnt = 1;
    end

    edit:SetText(downCnt);
    SILVER_GACHA_TOTAL_ONCE_SILVER_UPDATE(downCnt);
end

function SILVER_GACHA_TOTAL_ONCE_SILVER_UPDATE(count)
    local frame = ui.GetFrame("silver_gacha");
    local eventID = frame:GetUserConfig("EVENT_ID");
    
    local cost = GetSilverGachaEventCost(eventID);

    local edit = GET_CHILD_RECURSIVELY(frame, "once_count_edit");
    local onceCnt = tonumber(edit:GetText());

    local total = onceCnt * cost;

    local silverText = GET_CHILD_RECURSIVELY(frame, "dedication_silver");
    silverText:SetTextByKey("value", total);
end