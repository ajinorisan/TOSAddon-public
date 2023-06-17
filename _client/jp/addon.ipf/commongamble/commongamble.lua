local multiple_count_min = 1
local multiple_count_max = 5

function COMMONGAMBLE_ON_INIT(addon, frame)
	addon:RegisterMsg("COMMON_GAMBLE_ITEM_GET", "ON_COMMON_GAMBLE_ITEM_GET");
	addon:RegisterMsg("COMMON_GAMBLE_ITEM_GET_END", "ON_COMMON_GAMBLE_ITEM_GET_END");
	addon:RegisterMsg("COMMON_GAMBLE_ITEM_GET_PROPERTY", "COMMON_GAMBLE_ITEM_GET_PROPERTY");
end

-- UI 오픈
function COMMON_GAMBLE_OPEN(gamble_type)
	local frame = ui.GetFrame("commongamble");

	COMMON_GAMBLE_INIT(frame, gamble_type);
	frame:ShowWindow(1);
end

function COMMON_GAMBLE_CLOSE(frame)
	if ui.CheckHoldedUI() == true then
        return;
	end

	STOP_commongamble();

	COMMON_GAMBLE_CLEAR_COUPON_SLOT()

	ui.CloseFrame("commongamble");
end

function COMMON_GAMBLE_INIT(frame, gamble_type)
	if ui.CheckHoldedUI() == true then
        return;
	end

	frame:SetUserValue("gamble_type", gamble_type)

	local gambleCls = GetClassByType("gamble_list", gamble_type);

	local title_text = GET_CHILD_RECURSIVELY(frame, "title_text");
	local title = TryGetProp(gambleCls, "Desc");
	title_text:SetTextByKey("value", title);

	local resultslot = GET_CHILD_RECURSIVELY(frame, "resultslot");
    resultslot:ClearIcon();
	resultslot:SetText("");
	
	local slot_gb = GET_CHILD(frame, "slot_gb");
	local slot_gb_childCnt = slot_gb:GetChildCount();
	for i = 0, slot_gb_childCnt - 2 do
		local itemslot = GET_CHILD(slot_gb, "slot"..i);
		if itemslot ~= nil then
			itemslot:ClearIcon();
        	itemslot:SetText("");
		end
	end

	-- 뽑기 타입에 따라 제공되는 보상의 수량 및 뽑기 아이템 slot 설정
	local RewardItemCount = TryGetProp(gambleCls, "RewardItemCount");
	local RewardItemStr = StringSplit(TryGetProp(gambleCls, "RewardItemList"), ';');
	for i = 0, RewardItemCount - 1 do
		local itemslot = GET_CHILD(slot_gb, "slot"..i);
		local itemStrlist = StringSplit(RewardItemStr[i+1], '/');
		local itemClassName = itemStrlist[1];
		local itemCls = GetClass("Item", itemClassName);
		if itemCls ~= nil then
			local itemCnt = itemStrlist[2];

			SET_SLOT_ITEM_INFO(itemslot, itemCls, itemCnt,'{s20}{ol}{b}{ds}', -11, -10);  
			itemslot:SetUserValue("ITEM_CLASSID", itemCls.ClassID);
			itemslot:SetUserValue("ITEM_COUNT", itemCnt);
			
			local icon = itemslot:GetIcon();
			icon:SetDisableSlotSize(true);
			icon:SetReducedvalue(10, 10);			
		else
			itemCls = GetClass('common_gamble_property_reward', itemClassName)
			if itemCls ~= nil then
				local itemCnt = itemStrlist[2];

				local icon_1 = CreateIcon(itemslot);
				icon_1:EnableHitTest(0);

				local iconImageName = TryGetProp(itemCls, 'Icon', 'None');				
				local style = '{s20}{ol}{b}{ds}'
				
				icon_1:Set(iconImageName, "item", itemCls.ClassID, itemCnt);				
				itemslot:SetText(style..itemCnt, 'count', ui.RIGHT, ui.BOTTOM, -11, -10);				
				icon_1:SetTooltipType('texthelp');
				icon_1:SetTooltipArg(TryGetProp(itemCls, 'Name', 'None'));

				itemslot:SetUserValue("ITEM_CLASSID", itemCls.ClassID);
				itemslot:SetUserValue("ITEM_COUNT", itemCnt);
				
				local icon = itemslot:GetIcon();
				icon:SetDisableSlotSize(true);
				icon:SetReducedvalue(10, 10);
			end
		end
	end

	-- 배수
	local multiple_count = GET_CHILD_RECURSIVELY(frame, "multiple_count_edit");
	if multiple_count ~= nil then
		multiple_count:SetText('1')
	end

	-- 재료 아이템 slot 설정
	local consumeitem_gb = GET_CHILD(frame, "consumeitem_gb");
	if consumeitem_gb ~= nil then
		local consumeitem_gb_childCnt = consumeitem_gb:GetChildCount();
		for i = 0, consumeitem_gb_childCnt - 2 do
			local itemslot = GET_CHILD(consumeitem_gb, "consumeslot"..i);
			if itemslot ~= nil then
				itemslot:ClearIcon();
				itemslot:SetText("");
				itemslot:SetColorTone("FFFFFFFF")
			end
		end
	end

	local ConsumeItemCount = TryGetProp(gambleCls, "ConsumeItemCount");
	local ConsumeItemStr = StringSplit(TryGetProp(gambleCls, "ConsumeItem"), ';');	
	for i = 0, ConsumeItemCount - 1 do
		local itemslot = GET_CHILD(consumeitem_gb, "consumeslot"..i);
		local itemStrlist = StringSplit(ConsumeItemStr[i+1], '/');
		local itemClassName = itemStrlist[1];
		local itemCls = GetClass("Item", itemClassName);
		if itemCls ~= nil then
			local itemCnt = itemStrlist[2];

			SET_SLOT_ITEM_INFO(itemslot, itemCls, itemCnt,'{s20}{ol}{b}{ds}', -11, -10);  
			itemslot:SetUserValue("ITEM_CLASSID", itemCls.ClassID);
			itemslot:SetUserValue("ITEM_COUNT", itemCnt);
			
			local icon = itemslot:GetIcon();
			icon:SetDisableSlotSize(true);
			icon:SetReducedvalue(10, 10);
			icon:SetColorTone("FFFFFFFF")
		end
	end

	-- 쿠폰
	COMMON_GAMBLE_CLEAR_COUPON_SLOT(frame)

	-- 뽑기 버튼에 현재 뽑기 type에 따른 스크립트 호출 할 수 있도록 지정
	local one_btn = GET_CHILD_RECURSIVELY(frame, "one_btn");
	one_btn:SetEventScript(ui.LBUTTONDOWN, "COMMON_GAMBLE_OK_BTN_CLICK");
	one_btn:SetEventScriptArgNumber(ui.LBUTTONDOWN, gamble_type);

	-- 자동 뽑기 관련
	local auto_btn = GET_CHILD_RECURSIVELY(frame, "auto_btn");
	auto_btn:SetEventScript(ui.LBUTTONDOWN, "AUTO_COMMON_GAMBLE_START_BTN_CLICK");
	auto_btn:SetEventScriptArgNumber(ui.LBUTTONDOWN, gamble_type);
	auto_btn:SetEnable(1);
	
	local stop_btn = GET_CHILD_RECURSIVELY(frame, "stop_btn");
	stop_btn:SetEventScript(ui.LBUTTONDOWN, "AUTO_COMMON_GAMBLE_STOP_BTN_CLICK");
	stop_btn:SetEnable(1);

	local edit = GET_CHILD_RECURSIVELY(frame, "auto_edit");
	edit:SetEnable(1);
	edit:SetText('');

	local auto_text = GET_CHILD_RECURSIVELY(frame, "auto_text");
	auto_text:ShowWindow(1);


	-- 확률 데이터 가져온다
	local RatioCls = TryGetProp(GetClassByType('gamble_prop_list', gamble_type), 'RewardItemProp', 'None')
	if RatioCls == 'None' then
		return
	end
	local Cut = SCR_STRING_CUT(RatioCls, ';')	
	local RatioTable = {}

	for i = 1, #Cut do
		RatioTable[#RatioTable + 1] = Cut[i]		
	end
	
	local RatioSum = 0 
	for i = 1, #RatioTable do
		RatioSum = RatioSum + RatioTable[i]
	end

	if RatioSum == 0 then
		return
	end

	-- 슬롯 별 확률 표기
	for i = 0, #Cut - 1 do
		local slotratio = GET_CHILD(slot_gb, "slot"..i..'_ratio')		
		if slotratio == nil and RatioTable[i+1] == nil or RatioTable[i+1] == 0 then
			return
		end
		if slotratio ~= nil and RatioTable[i+1] ~= nil or RatioTable[i+1] ~= 0 then
			slotratio:SetTextByKey('value'..i, '          '.. string.format('%.1f', RatioTable[i+1] / RatioSum * 100) .. '%')
		end
	end

end

function COMMON_GAMBLE_GET_MULTIPLE_COUNT()
	local frame = ui.GetFrame("commongamble")
	if frame == nil then return multiple_count_min end
	
	local multiple_count_edit = GET_CHILD_RECURSIVELY(frame, 'multiple_count_edit')
	
	if multiple_count_edit == nil then return multiple_count_min end

	local count = tonumber(multiple_count_edit:GetText())
	
	if count < multiple_count_min then
		count = multiple_count_min
	elseif count > multiple_count_max then
		count = multiple_count_max
	end


	return count
end

function COMMON_GAMBLE_UPDATE_CONSUME_COUNT()
	local frame = ui.GetFrame('commongamble')
	if frame == nil then return end
	local gamble_type = frame:GetUserValue("gamble_type")

	local gambleCls = GetClassByType("gamble_list", gamble_type);
	if gambleCls == nil then return end

	local multiple_count = COMMON_GAMBLE_GET_MULTIPLE_COUNT()

	-- 기본재료 개수
	local ConsumeItemCount = TryGetProp(gambleCls, "ConsumeItemCount");
	local ConsumeItemStr = StringSplit(TryGetProp(gambleCls, "ConsumeItem"), ';');	

	for i = 0, ConsumeItemCount - 1 do
		local itemslot = GET_CHILD_RECURSIVELY(frame, "consumeslot"..i);
		local itemStrlist = StringSplit(ConsumeItemStr[i+1], '/');
		local itemClassName = itemStrlist[1];
		local itemCls = GetClass("Item", itemClassName);
		if itemCls ~= nil then
			local itemCnt = itemStrlist[2];

			SET_SLOT_ITEM_INFO(itemslot, itemCls, itemCnt * multiple_count,'{s20}{ol}{b}{ds}', -11, -10);  

			local icon = itemslot:GetIcon();
			icon:SetDisableSlotSize(true);
			icon:SetReducedvalue(10, 10);
		end
	end

	-- 쿠폰 개수
	local coupon_slot = GET_CHILD_RECURSIVELY(frame, "coupon_slot");
	if coupon_slot ~= nil then
		local coupon_item = GET_SLOT_ITEM(coupon_slot)
		if coupon_item ~= nil then
			coupon_slot:SetText('{s18}{ol}{b}{ds}'..1 * multiple_count, 'count', ui.RIGHT, ui.BOTTOM, -4, -4);
		end
	end
end

function COMMON_GAMBLE_OK_BTN_CLICK(parent, ctrl, argStr, gamble_type)
	if ui.CheckHoldedUI() == true then
        return;
	end

	ui.SetHoldUI(true);

	local multiple_count = COMMON_GAMBLE_GET_MULTIPLE_COUNT()
	local coupon_guid = COMMON_GAMBLE_GET_COUPON_GUID()	
    common_gamble.RequestCommonGamble(gamble_type, multiple_count, coupon_guid)
	COMMON_GAMBLE_OK_BTN_EFFECT(frame);
	
	local delay = WORLD_EVENT_CLICK_DELAY;
	ReserveScript("COMMON_GAMBLE_OK_BTN_UNFREEZE()", delay);
end

function AUTO_COMMON_GAMBLE_OK_BTN_CLICK()
	local frame = ui.GetFrame("commongamble");
	local edit = GET_CHILD_RECURSIVELY(frame, "auto_edit");
	local count = edit:GetText();
	if edit:GetText() == "" or tonumber(count) - 1 < 0  then
		STOP_commongamble();
		return;
	end

	local auto_btn = GET_CHILD_RECURSIVELY(frame, "auto_btn");
	local gamble_type = auto_btn:GetEventScriptArgNumber(ui.LBUTTONDOWN);
	
	local multiple_count = COMMON_GAMBLE_GET_MULTIPLE_COUNT()
	local coupon_guid = COMMON_GAMBLE_GET_COUPON_GUID()
    common_gamble.RequestCommonGamble(gamble_type, multiple_count, coupon_guid)
end

function COMMON_GAMBLE_GET_COUPON_GUID()
	local frame = ui.GetFrame("commongamble")
	local coupon_slot = GET_CHILD_RECURSIVELY(frame, 'coupon_slot')
	if coupon_slot ~= nil then
		local coupon_item = GET_SLOT_ITEM(coupon_slot)
		if coupon_item ~= nil then
			return coupon_item:GetIESID()
		end
	end
	return '0' -- 쿠폰을 사용하지 않을 경우 기본값
end

function AUTO_commongamble(gamble_type, count)
	local frame = ui.GetFrame("commongamble");

	local auto_btn = GET_CHILD_RECURSIVELY(frame, "auto_btn");
	auto_btn:SetEnable(0);

	local edit = GET_CHILD_RECURSIVELY(frame, "auto_edit");
	edit:SetEnable(0);

	local one_btn = GET_CHILD_RECURSIVELY(frame, 'one_btn');
	one_btn:SetEnable(0);

	local count = edit:GetText();

	local delay = WORLD_EVENT_CLICK_DELAY * 1000;
	delay = delay + 100;
	AddUniqueTimerFunccWithLimitCount('AUTO_COMMON_GAMBLE_OK_BTN_CLICK', delay, count)
end

function STOP_commongamble()
	RemoveLuaTimerFunc('AUTO_COMMON_GAMBLE_OK_BTN_CLICK')
	
	local frame = ui.GetFrame("commongamble");
	local edit = GET_CHILD_RECURSIVELY(frame, "auto_edit");
	edit:SetEnable(1);

	local auto_btn = GET_CHILD_RECURSIVELY(frame, "auto_btn");
	auto_btn:SetEnable(1);

	local one_btn = GET_CHILD_RECURSIVELY(frame, "one_btn");
	one_btn:SetEnable(1);
end

function COMMON_GAMBLE_OK_BTN_UNFREEZE()
	ui.SetHoldUI(false);
end

-- 확인 버튼 이펙트
function COMMON_GAMBLE_OK_BTN_EFFECT(frame)
    frame = ui.GetFrame("commongamble");

    local OK_BUTTON_EFFECT_NAME = frame:GetUserConfig("OK_BUTTON_EFFECT_NAME");
    local OK_BUTTON_EFFECT_SCALE = tonumber(frame:GetUserConfig("OK_BUTTON_EFFECT_SCALE"));
    
    local one_btn = GET_CHILD_RECURSIVELY(frame, "one_btn");
	if one_btn == nil then
		return;
    end
    
	one_btn:PlayUIEffect(OK_BUTTON_EFFECT_NAME, OK_BUTTON_EFFECT_SCALE, "OK_BUTTON_EFFECT");
    ReserveScript("_OK_BUTTON_EFFECT()", 0.2);
end

function _OK_BUTTON_EFFECT()
	local frame = ui.GetFrame("commongamble");
	if frame:IsVisible() == 0 then
		return;
	end
	
    local one_btn = GET_CHILD_RECURSIVELY(frame, "one_btn");
	if one_btn == nil then
		return;
    end

	one_btn:StopUIEffect("OK_BUTTON_EFFECT", true, 0.5);
end

-- 뽑은 슬롯 이펙트
function ON_COMMON_GAMBLE_ITEM_GET(frame, msg, itemid, itemCount)
	frame = ui.GetFrame("commongamble");

	local itemCls = GetClassByType("Item", itemid);
    if itemCls ~= nil then
		local slot = COMMON_GAMBLE_ITEM_SLOT_GET(itemid, itemCount);      -- 뽑을 수 있는 아이템 slot
		local resultslot = GET_CHILD_RECURSIVELY(frame, "resultslot");    -- 뽑은 아이템 slot 
        if slot == nil then return; end
        if resultslot == nil then return; end

        resultslot:SetUserValue("ITEM_CLASSID", itemid);
        resultslot:SetUserValue("ITEM_COUNT", itemCount);

        SET_SLOT_ITEM_INFO(resultslot, itemCls, itemCount,'{s20}{ol}{b}{ds}', -7, -6);
        
	    local RESULT_EFFECT_NAME = frame:GetUserConfig('RESULT_EFFECT');
        local RESULT_EFFECT_SCALE_S = tonumber(frame:GetUserConfig('RESULT_EFFECT_SCALE_S'));
        local RESULT_EFFECT_SCALE_M = tonumber(frame:GetUserConfig('RESULT_EFFECT_SCALE_M'));
        local RESULT_EFFECT_DURATION = tonumber(frame:GetUserConfig('RESULT_EFFECT_DURATION'));
        
        slot:PlayUIEffect(RESULT_EFFECT_NAME, RESULT_EFFECT_SCALE_S, 'RESULT_EFFECT');
        resultslot:PlayUIEffect(RESULT_EFFECT_NAME, RESULT_EFFECT_SCALE_S, 'RESULT_EFFECT');
	    ReserveScript("_RESULT_EFFECT()", RESULT_EFFECT_DURATION);
    end
end

-- 뽑은 슬롯 이펙트
function COMMON_GAMBLE_ITEM_GET_PROPERTY(frame, msg, class_name, itemCount)
	frame = ui.GetFrame("commongamble");

	local itemCls = GetClass("common_gamble_property_reward", class_name);	
	if itemCls ~= nil then		
		local slot = COMMON_GAMBLE_ITEM_SLOT_GET(TryGetProp(itemCls, 'ClassID', 0), itemCount);      -- 뽑을 수 있는 아이템 slot		
		local resultslot = GET_CHILD_RECURSIVELY(frame, "resultslot");    -- 뽑은 아이템 slot 
        if slot == nil then return; end
        if resultslot == nil then return; end

        resultslot:SetUserValue("ITEM_CLASSID", itemid);
        resultslot:SetUserValue("ITEM_COUNT", itemCount);

		local icon = CreateIcon(resultslot);
		icon:EnableHitTest(0);

		local iconImageName = TryGetProp(itemCls, 'Icon', 'None');
		local style = '{s20}{ol}{b}{ds}'
		
		icon:Set(iconImageName, "item", itemCls.ClassID, itemCount);				
		resultslot:SetText(style..itemCount, 'count', ui.RIGHT, ui.BOTTOM, -7, -6);				
		icon:SetTooltipType('texthelp');
		icon:SetTooltipArg(TryGetProp(itemCls, 'Name', 'None'));
        
	    local RESULT_EFFECT_NAME = frame:GetUserConfig('RESULT_EFFECT');
        local RESULT_EFFECT_SCALE_S = tonumber(frame:GetUserConfig('RESULT_EFFECT_SCALE_S'));
        local RESULT_EFFECT_SCALE_M = tonumber(frame:GetUserConfig('RESULT_EFFECT_SCALE_M'));
        local RESULT_EFFECT_DURATION = tonumber(frame:GetUserConfig('RESULT_EFFECT_DURATION'));
        
        slot:PlayUIEffect(RESULT_EFFECT_NAME, RESULT_EFFECT_SCALE_S, 'RESULT_EFFECT');
        resultslot:PlayUIEffect(RESULT_EFFECT_NAME, RESULT_EFFECT_SCALE_S, 'RESULT_EFFECT');
		ReserveScript("_RESULT_EFFECT()", RESULT_EFFECT_DURATION);
    end
end

function ON_COMMON_GAMBLE_ITEM_GET_END()
	local frame = ui.GetFrame("commongamble")
	if frame == nil then return end

	COMMON_GAMBLE_AUTO_COUNT_UPDATE(frame)
end

function _RESULT_EFFECT()
	local frame = ui.GetFrame("commongamble");
	if frame:IsVisible() == 0 then
		return;
    end
    
    local resultslot = GET_CHILD_RECURSIVELY(frame, "resultslot");
    if resultslot == nil then return; end

	local classID = resultslot:GetUserValue("ITEM_CLASSID");
	local itemCount = resultslot:GetUserIValue("ITEM_COUNT");
	
    local slot = COMMON_GAMBLE_ITEM_SLOT_GET(classID, itemCount);
    if slot == nil then return; end

	slot:StopUIEffect("RESULT_EFFECT", true, 0.5);
	resultslot:StopUIEffect("RESULT_EFFECT", true, 0.5);
end

-- itemid의 아이템이 등록된 slot 찾기
function COMMON_GAMBLE_ITEM_SLOT_GET(itemid, itemCount)
	local frame = ui.GetFrame("commongamble");
	
	local slot_gb = GET_CHILD(frame, "slot_gb");
	local slot_gb_childCnt = slot_gb:GetChildCount();
	for i = 0, slot_gb_childCnt - 2 do
		local itemslot = GET_CHILD(slot_gb, "slot"..i);
		if itemslot then
		local slotitemid = itemslot:GetUserValue("ITEM_CLASSID");
			local slotitemCount = itemslot:GetUserIValue("ITEM_COUNT");
			-- if tonumber(itemid) == tonumber(slotitemid) and itemCount == slotitemCount then
			if tonumber(itemid) == tonumber(slotitemid)then
			return itemslot;
			end
		end
	end

	return nil;
end
function COMMON_GAMBLE_AUTO_EDIT_CLICK(parent, ctrl)
	local auto_text = GET_CHILD(parent, "auto_text");
	auto_text:ShowWindow(0);
end

function AUTO_COMMON_GAMBLE_START_BTN_CLICK(parent, ctrl, argStr, gamble_type)
	if ui.CheckHoldedUI() == true then
        return;
	end

	AUTO_commongamble(gamble_type, count)
end

function AUTO_COMMON_GAMBLE_STOP_BTN_CLICK(parent, ctrl)
	STOP_commongamble();
end

function COMMON_GAMBLE_AUTO_COUNT_UPDATE(frame)
	local auto_btn = GET_CHILD_RECURSIVELY(frame, "auto_btn");
	if auto_btn:IsEnable() == 1 then
		return;
	end

	local edit = GET_CHILD_RECURSIVELY(frame, "auto_edit");
	local count = tonumber(edit:GetText());
	local next_count = count - 1;
	if next_count < 0 then
		return;
	end

	edit:SetText(next_count);
end
function COMMON_GAMBLE_MULTIPLE_COUNT_TYPING(parent, ctrl)
    local curCnt = tonumber(ctrl:GetText());
    COMMON_GAMBLE_MULTIPLE_COUNT_UPDATE(curCnt);
end

function COMMON_GAMBLE_MULTIPLE_COUNT_UPBTN_CLICK(parent, ctrl)
	local curCnt = COMMON_GAMBLE_GET_MULTIPLE_COUNT()
	local upCnt = curCnt + 1; 
    if multiple_count_max < upCnt then
        upCnt = multiple_count_max;
	end
    COMMON_GAMBLE_MULTIPLE_COUNT_UPDATE(upCnt);
end

function COMMON_GAMBLE_MULTIPLE_COUNT_DOWNBTN_CLICK(parent, ctrl)
    local curCnt = COMMON_GAMBLE_GET_MULTIPLE_COUNT()
    local downCnt = curCnt - 1; 
    if downCnt < multiple_count_min then
        downCnt = multiple_count_min;
    end
    COMMON_GAMBLE_MULTIPLE_COUNT_UPDATE(downCnt);
end

function COMMON_GAMBLE_MULTIPLE_COUNT_UPDATE(count)
	local frame = ui.GetFrame("commongamble");
	if frame == nil then return end

	local multiple_count_edit = GET_CHILD_RECURSIVELY(frame, 'multiple_count_edit')
	if multiple_count_edit == nil then return end

	if count < multiple_count_min then
		count = multiple_count_min
	elseif count > multiple_count_max then
		count = multiple_count_max
	end

    multiple_count_edit:SetText(count);

	COMMON_GAMBLE_UPDATE_CONSUME_COUNT()
end

-- 쿠폰 슬롯 등록
function COMMON_GAMBLE_COUPON_DROP(parent, ctrl, argStr, argNum)
	local frame = ui.GetFrame('commongamble')
	if frame == nil then return end

	if ui.CheckHoldedUI() == true then
		return
	end

	local liftIcon = ui.GetLiftIcon()
	local FromFrame = liftIcon:GetTopParentFrame()
	local toFrame = parent:GetTopParentFrame()
	if FromFrame:GetName() ~= 'inventory' then return end

	local iconInfo = liftIcon:GetInfo()
	if COMMON_GAMBLE_REG_COUPONITEM(toFrame, iconInfo:GetIESID()) == false then return end

	-- 기본 재료 비활성화
	local consumeitem_gb = GET_CHILD_RECURSIVELY(frame, 'consumeitem_gb')
	if consumeitem_gb ~= nil then
		local consumeitem_gb_childCnt = consumeitem_gb:GetChildCount();
		for i = 0, consumeitem_gb_childCnt - 2 do
			local itemslot = GET_CHILD(consumeitem_gb, "consumeslot"..i);
			if itemslot ~= nil then
				itemslot:SetColorTone("33FFFFFF")
				local itemicon = itemslot:GetIcon()
				if itemicon ~= nil then
					itemicon:SetColorTone("33333333")
				end
			end
		end
	end
end

-- 쿠폰 슬롯 제거
function COMMON_GAMBLE_COUPON_REMOVE(parent, ctrl)
	local frame = ui.GetFrame('commongamble')
	if frame == nil then return end

	-- 쿠폰 슬롯에서 제거
	COMMON_GAMBLE_CLEAR_COUPON_SLOT(frame)

	-- 기본 재료 활성화
	local consumeitem_gb = GET_CHILD_RECURSIVELY(frame, 'consumeitem_gb')
	if consumeitem_gb ~= nil then
		local consumeitem_gb_childCnt = consumeitem_gb:GetChildCount();
		for i = 0, consumeitem_gb_childCnt - 2 do
			local itemslot = GET_CHILD(consumeitem_gb, "consumeslot"..i);
			if itemslot ~= nil then
				itemslot:SetColorTone("FFFFFFFF")
				local itemicon = itemslot:GetIcon()
				if itemicon ~= nil then
					itemicon:SetColorTone("FFFFFFFF")
				end
			end
		end
	end
end

function COMMON_GAMBLE_REG_COUPONITEM(frame, itemID)
	if ui.CheckHoldedUI() == true then
		return false
	end

	-- 아이템 유효 여부 체크
	local invItem = session.GetInvItemByGuid(itemID)
	if invItem == nil then return false end

	local itemObj = GetIES(invItem:GetObject())
	if itemObj == nil then return false end

	local gamble_type = frame:GetUserValue("gamble_type")
	local gambleCls = GetClass('gamble_list', gamble_type)
	if gambleCls == nil then return false end

	local gamble_coupon_type = TryGetProp(gambleCls, 'CouponStringArg', 'None')
	if gamble_coupon_type == 'None' then return false end
	
	if gamble_coupon_type ~= TryGetProp(itemObj, 'StringArg', 'None') then
		ui.SysMsg(ClMsg('DontUseItem'))
		return false
	end
	
	-- 아이템 잠김 여부 체크
	local invframe = ui.GetFrame("inventory")
	if true == invItem.isLockState or true == IS_TEMP_LOCK(invframe, invItem) then
		ui.SysMsg(ClMsg("MaterialItemIsLock"))
		return false
	end

	-- 쿠폰 슬롯에 추가
	local slot = GET_CHILD_RECURSIVELY(frame, "coupon_slot")
	if slot == nil then return false end
	SET_SLOT_ITEM(slot, invItem)
	
	-- 쿠폰 이름 표시
	local name = GET_CHILD_RECURSIVELY(frame, "couponName")
	if name ~= nil then
		name:SetTextByKey("value", dic.getTranslatedStr(TryGetProp(itemObj, "Name", "None")))
	end

	-- 개수 표시
	local multiple_count = COMMON_GAMBLE_GET_MULTIPLE_COUNT()
	local coupon_slot = GET_CHILD_RECURSIVELY(frame, "coupon_slot");
	if coupon_slot ~= nil then
		coupon_slot:SetText('{s18}{ol}{b}{ds}'..1 * multiple_count, 'count', ui.RIGHT, ui.BOTTOM, -4, -4);
		-- 인벤토리 체크
		local coupon_item = GET_SLOT_ITEM(coupon_slot)
		if coupon_item ~= nil then
			local itemguid = coupon_item:GetIESID()
			SELECT_INV_SLOT_BY_GUID(itemguid, 1)
		end
	end
	return true
end

function COMMON_GAMBLE_CLEAR_COUPON_SLOT(frame)
	if frame == nil then
		frame = ui.GetFrame('commongamble')
		if frame == nil then return end
	end
	
	-- 개수
	local coupon_slot = GET_CHILD_RECURSIVELY(frame, "coupon_slot");
	if coupon_slot ~= nil then
		coupon_slot:SetText('');
		-- 인벤토리 체크 해제
		local coupon_item = GET_SLOT_ITEM(coupon_slot)
		if coupon_item ~= nil then
			local itemguid = coupon_item:GetIESID()
			SELECT_INV_SLOT_BY_GUID(itemguid, 0)
		end
	end

	-- 슬롯 아이콘
	local slot = GET_CHILD_RECURSIVELY(frame, "coupon_slot")
	if slot ~= nil then
		slot:ClearIcon()
	end

	-- 이름
	local name = GET_CHILD_RECURSIVELY(frame, "couponName")
	if name ~= nil then
		name:SetTextByKey("value", frame:GetUserConfig("COUPON_DEFAULT"))
	end
end