-- housing_craft.lua 

local selectedValue = 1
function HOUSING_CRAFT_ON_INIT(addon, frame)
	addon:RegisterMsg('HOUSINGCRAFT_UPDATE_ENDTIME', 'HOUSING_CRAFT_REMAIN_TIME_UPDATE');
	addon:RegisterMsg('SUCCESS_RECEIVE_HOUSINGCRAFT_GOODS', 'HOUSING_CRAFT_RECEIVED_GOODS');
	addon:RegisterMsg('SUCCESS_USE_HOUSINGCRAFT_COUPON', 'HOUSING_CRAFT_COUPON_TEXT');
	addon:RegisterMsg('FURNITURE_NOT_EXIST', 'HOUSING_CRAFT_FURNITURE_NOT_EXIST');

end
function HOUSING_CRAFT_OPEN(frame)
	selectedValue = 1
	housing.RequestArrangedFurniture();
	local help_pic = GET_CHILD_RECURSIVELY(frame, "helpPic");
	if help_pic ~= nil then
		local tooltip_text = ScpArgMsg('Personal_Housing_Craftshop_tootip_msg_1');
		help_pic:SetTextTooltip(tooltip_text);
		help_pic:Invalidate();
	end
	HOUSING_CRAFT_COUPON_TEXT(frame);
	HOUSING_CRAFT_REMAIN_TIME_UPDATE(frame,"msg","YES");
end

function HOUSING_CRAFT_CLOSE(frame)
	ui.OpenAllClosedUI();
end
function HOUSING_CRAFT_FURNITURE_NOT_EXIST(frame)
	SCR_HOUSING_CRAFT_FURNITURE_LIST();
end
function SCR_HOUSING_CRAFT_FURNITURE_LIST(list)
	if list == nil then
		list={}
	end
	ui.OpenFrame("housing_craft")
	local frame = ui.GetFrame("housing_craft")
	CREATE_POINTCRAFT_CATEGORY(frame)
	ON_HOUSING_EDITMODE_CLOSE()
	--GET_CHILD_RECURSIVELY(frame, "couponbtn"):SetEnable(0);
	local couponBox = GET_CHILD_RECURSIVELY(frame, 'couponBox');  
	couponBox:ShowWindow(0);
	CREATE_POINTCRAFT_LIST(frame, list)
	HOUSING_CRAFT_GET_COIN_AMOUNT_LIST(frame, list)
end

function CREATE_POINTCRAFT_CATEGORY(frame)
	local categorygbox = GET_CHILD_RECURSIVELY(frame,"categorygbox")
	local statusgbox = GET_CHILD_RECURSIVELY(frame,"statusgbox")
	local categoryCls = HOUSING_CRAFT_GET_CATEGORY_CLS(frame)
	local value_cnt = categoryCls.ValueCnt
	local category = categoryCls.ClassName
	local baseid = categoryCls.BaseID 
	for i = 1, value_cnt do
		local groupCls = GetClassByType("Housing_CraftShop_Group", baseid + i);
		local coinName = groupCls.Name 
		local limitCnt = groupCls.LimitCount
        local categoryCtrl = categorygbox:CreateOrGetControlSet('house_craft_coin_cate', 'CATEGORY_CTRL_'..(baseid + i), 0, (i - 1) * 70);
		
		local mainCoinNametxt = GET_CHILD(categoryCtrl,"mainCoinNameText")
		local coinNametxt = GET_CHILD(categoryCtrl, "coinNameText")
		local conditiontxt = GET_CHILD(categoryCtrl, "conditionText")
		local shadow = GET_CHILD(categoryCtrl, "shadow")

		categoryCtrl:SetUserValue("VALUE_COUNT", i)

		mainCoinNametxt:SetTextByKey("name", coinName)
		coinNametxt:SetTextByKey("name", coinName)
		conditiontxt:SetTextByKey("name", groupCls.Condition)

		if groupCls.UnlockCondition == "None" then-- 추후에 UnlockCondition으로 프로퍼티값 받아와서 잠금처리
			coinNametxt:ShowWindow(0)
			conditiontxt:ShowWindow(0)
			shadow:ShowWindow(0)
		else
			mainCoinNametxt:ShowWindow(0)
			coinNametxt:ShowWindow(1)
			conditiontxt:ShowWindow(1)
			shadow:ShowWindow(1)
		end

		categoryCtrl = statusgbox:CreateOrGetControlSet('house_craft_coin_progress', 'PROGRESS_CTRL_'..(baseid + i), 0, (i - 1) * 120);
		local statusNametxt = GET_CHILD(categoryCtrl, "statusName")
		local statusCnttxt = GET_CHILD(categoryCtrl, "statusCnt")
		local statusIcon = GET_CHILD(categoryCtrl, "icon")
		local jarguage = GET_CHILD(categoryCtrl,"jar_gauge")
		local pertext = GET_CHILD(jarguage,"progressText")
		
		statusNametxt:SetTextByKey("name", coinName)
		statusCnttxt:SetTextByKey("cur", 0)
		statusCnttxt:SetTextByKey("max", limitCnt)
		statusIcon:SetImage(groupCls.Icon)
		jarguage:SetPoint(0,limitCnt)
		pertext:SetTextByKey("per", 0)
	end
end

function HOUSING_CRAFT_GET_CATEGORY_CLS(frame)
	local tab = GET_CHILD_RECURSIVELY(frame,"craftTab")
	local tabindex = tab:GetSelectItemIndex();
	return GetClassByType("Housing_CraftShop_Group", tabindex + 2)
end

function CREATE_POINTCRAFT_LIST(frame, furniture_list)
	local maingbox = GET_CHILD_RECURSIVELY(frame,"maingbox")

	local furnitures = {}

	for i = 1, #furniture_list do
		local furnitureCls = GetClassByType("Housing_Furniture", furniture_list[i])
		if TryGetProp(furnitureCls,"RewardGroup", "None") ~= "None" then
			table.insert(furnitures, furnitureCls)
		end
	end
	
	local cnt = 0
	maingbox:RemoveAllChild()
	for i = 1, #furnitures do
		local furnitureCls = furnitures[i]
		local preset = GetClass("HousingCraft_RewardGroup", TryGetProp(furnitureCls,"RewardGroup"))
		local presetValue = TryGetProp(preset, "Value"..selectedValue, 0)
		if presetValue ~= 0 then
			local listCtrl = maingbox:CreateOrGetControlSet('house_craft_furniture', 'LIST_CTRL_'..cnt, (cnt%2)*280 + 5, math.floor(cnt/2) * 282 + 5);
			local icon = GET_CHILD_RECURSIVELY(listCtrl, "icon")
			local infoName = GET_CHILD(listCtrl, "infoName")
			local detailbox = GET_CHILD(listCtrl, "coingb")
			local itemCls = GetClass("Item", furnitureCls.ItemClassName)
			
			icon:SetImage(TryGetProp(itemCls,"Icon","None"))
			infoName:SetTextByKey("name", furnitureCls.Name)

			HOUSING_CRAFT_CREATE_LIST_DETAIL(frame, furnitureCls, detailbox)

			cnt = cnt + 1
		end
	end

	local titleText = GET_CHILD_RECURSIVELY(frame, "titletext")
	local categoryCls = HOUSING_CRAFT_GET_CATEGORY_CLS(frame)
	local baseid = categoryCls.BaseID 
	local groupCls = GetClassByType("Housing_CraftShop_Group", baseid + selectedValue);
	titleText:SetTextByKey("title", groupCls.Name)
end

function HOUSING_CRAFT_CREATE_LIST_DETAIL(frame, furniture, detailbox)
	local categoryCls = HOUSING_CRAFT_GET_CATEGORY_CLS(frame)
	local value = categoryCls.ValueCnt
	local baseid = categoryCls.BaseID 
	local preset = GetClass("HousingCraft_RewardGroup", TryGetProp(furniture,"RewardGroup"))
	local presetValue = TryGetProp(preset, "Value"..selectedValue, 0)
	if presetValue ~= 0 then
		local groupCls = GetClassByType("Housing_CraftShop_Group", baseid + selectedValue);
		local detailCtrl = detailbox:CreateOrGetControlSet('house_craft_furniture_detail', 'LIST_DETAIL_CTRL', 0, 0);
		local icon = GET_CHILD(detailCtrl, "icon")
		local name = GET_CHILD(detailCtrl, "name")
		icon:SetImage(groupCls.Icon)
		name:SetTextByKey("name", groupCls.Name)
		name:SetTextByKey("point", presetValue)
	end
end

function HOUSING_CRAFT_SELECT_CATEGORY(parent, self)
	selectedValue = parent:GetUserIValue("VALUE_COUNT");
	housing.RequestArrangedFurniture();
end

---- 쿠폰 로직----
function HOUSING_CRAFT_OPEN_COUPON(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	local couponBox = GET_CHILD_RECURSIVELY(frame, 'couponBox');  
	couponBox:ShowWindow(1);
  
	local couponSlotset = GET_CHILD_RECURSIVELY(frame, 'couponSlotset');
	local selectedSlotCount = couponSlotset:GetSelectedSlotCount();
	if selectedSlotCount < 1 then
		HOUSING_CRAFT_MAKE_COUPON_SLOTSET(frame, couponSlotset, 'Goods');
	end
end
function HOUSING_CRAFT_CANCEL_COUPON(parent, ctrl)  
	local frame = parent:GetTopParentFrame();
	local couponBox = GET_CHILD_RECURSIVELY(frame, 'couponBox');
	local couponSlotset = GET_CHILD_RECURSIVELY(frame, 'couponSlotset');
	couponSlotset:ClearSelectedSlot();
	couponBox:ShowWindow(0);  
	HOUSING_CRAFT_SIMPLELIST_APPLY_COUPON(frame, 'couponSlotset');
end

function HOUSING_CRAFT_MAKE_COUPON_SLOTSET(frame, slotset, type)
	slotset:ClearIconAll();  
	local totalSlotCount = slotset:GetSlotCount();
	local invItemList = session.GetInvItemList();
	FOR_EACH_INVENTORY(invItemList, function(invItemList, invItem, type, slotset)
	  	if invItem ~= nil then
			local itemObj = GetIES(invItem:GetObject());
			if IS_COUPON_ITEM(itemObj, type) == true then
				local curCnt = imcSlot:GetEmptySlotIndex(slotset);
				local slot = slotset:GetSlotByIndex(curCnt);        
				SET_SLOT_IMG(slot, itemObj.Icon);
				SET_SLOT_COUNT(slot, invItem.count);
				SET_SLOT_COUNT_TEXT(slot, invItem.count);
				SET_SLOT_IESID(slot, invItem:GetIESID());
				SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, invItem, itemObj, nil);
				SET_ITEM_TOOLTIP_BY_NAME(slot:GetIcon(), itemObj.ClassName);
				slot:SetUserValue('COUPON_CLASS_NAME', itemObj.ClassName);
				slot:SetUserValue('COUPON_GUID', invItem:GetIESID());
				slot:SetSelectedImage('socket_slot_check');          
			end
		end
	end, false, type, slotset);    
end

function HOUSING_CRAFT_SIMPLELIST_APPLY_COUPON_BTN(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	local couponBox = GET_CHILD_RECURSIVELY(frame, 'couponBox');
	couponBox:ShowWindow(0);
	HOUSING_CRAFT_SIMPLELIST_APPLY_COUPON(frame, 'couponSlotset');
end

function HOUSING_CRAFT_SIMPLELIST_APPLY_COUPON(frame, slotsetName)
	local slotset = GET_CHILD_RECURSIVELY(frame, slotsetName);
	local slot = slotset:GetSelectedSlot(0);
	local useCouponGuid = '0';

	if slot ~= nil then
		local aObj = GetMyAccountObj();  
	  	local couponCls = GetClass('Item', slot:GetUserValue('COUPON_CLASS_NAME'));
		useCouponGuid = slot:GetUserValue('COUPON_GUID');
		local couponSlotset = GET_CHILD_RECURSIVELY(frame, 'couponSlotset');
		couponSlotset:ClearSelectedSlot();

		if TryGetProp(aObj, "HOUSING_CRAFT_COUPON_CNT", 0) > 2 then
			ui.SysMsg(ClMsg("CannotUseHousingCraftCoupon"));
			return;
		end

		local invItem = session.GetInvItemByGuid(useCouponGuid);
		if invItem == nil then
			return;
    	end
	
		if invItem.isLockState == true then
			ui.SysMsg(ClMsg("MaterialItemIsLock"));
			return;
		end

		if useCouponGuid ~= '0' then
			pc.ReqExecuteTx_Item("USE_HOUSING_CRAFT_COUPON", useCouponGuid);
		end
	end
end


function HOUSING_CRAFT_GET_COIN_AMOUNT_LIST(frame, furniture_list)
	local categoryCls = HOUSING_CRAFT_GET_CATEGORY_CLS(frame);
	local value_cnt = categoryCls.ValueCnt;
	local value_list = {};
	for i = 1, value_cnt do value_list[i] = 0; end -- table init

	
	for i = 1, #furniture_list do
		local furnitureCls = GetClassByType("Housing_Furniture", furniture_list[i]);
		local preset = GetClass("HousingCraft_RewardGroup", TryGetProp(furnitureCls,"RewardGroup"));
		if preset ~= nil then
			for i = 1, value_cnt do
				value_list[i] = value_list[i] + preset["Value"..i];
			end
		end
	end

	for i = 1, value_cnt do 
		local progressCtrl = GET_CHILD_RECURSIVELY(frame,"PROGRESS_CTRL_"..(categoryCls.BaseID + i));
		local statusCnttxt = GET_CHILD(progressCtrl, "statusCnt");
		local jarguage = GET_CHILD(progressCtrl,"jar_gauge");
		local pertext = GET_CHILD(jarguage,"progressText");
		local percent = math.floor(value_list[i]/jarguage:GetMaxPoint()*100)

		statusCnttxt:SetTextByKey("cur", value_list[i]);
		jarguage:SetCurPoint(value_list[i]);
		pertext:SetTextByKey("per", percent);

		if value_list[i] < jarguage:GetMaxPoint() then
			pertext:SetColorTone("FFFFFFFF");
		elseif value_list[i] == jarguage:GetMaxPoint() then
			pertext:SetColorTone("FF0067A3");
		else
			pertext:SetColorTone("FFFF0000");
		end
	end
end

function HOUSING_CRAFT_REMAIN_TIME_UPDATE(frame, msg, argStr)
	if argStr ~= "YES" then 
		return;
	end
	local timer_text = GET_CHILD_RECURSIVELY(frame, "remainTimeText");
	local complete_text = GET_CHILD_RECURSIVELY(frame, "completeText");
	local receive_btn = GET_CHILD_RECURSIVELY(frame, "receivebtn");
	local remainsec= SET_TIME_TEXT(timer_text);

	if remainsec >= 0 then
		receive_btn:SetEnable(0);
		complete_text:ShowWindow(0);
		timer_text:ShowWindow(1);
		timer_text:RunUpdateScript("UPDATE_HOUSING_CRAFT_TIMER_TEXT", 60);
	else
		receive_btn:SetEnable(1);
		complete_text:ShowWindow(1);
		timer_text:ShowWindow(0);
		
		if TryGetProp(aObj,"HOUSINGCRAFT_NEED_RECEIVE",0) == 0 and TryGetProp(aObj,"HOUSINGCRAFT_RECEIVED",0) == 0 then
			control.CustomCommand('REQ_CALC_HOUSINGCRAFT_GOODS',0);
		end

		if TryGetProp(aObj,"HOUSINGCRAFT_RECEIVED",0) == 1 then
			receive_btn:SetEnable(0);
		end
	end
end

function UPDATE_HOUSING_CRAFT_TIMER_TEXT(ctrl, elapsedTime)  
	local parent = ctrl:GetParent();
	local aObj = GetMyAccountObj();
	local remainsec = SET_TIME_TEXT(ctrl);
	if remainsec < 0 then
		GET_CHILD_RECURSIVELY(parent, "receivebtn"):SetEnable(1);
		GET_CHILD_RECURSIVELY(parent, "completeText"):ShowWindow(1);
		ctrl:ShowWindow(0);
		if TryGetProp(aObj,"HOUSINGCRAFT_NEED_RECEIVE",0) == 0 and TryGetProp(aObj,"HOUSINGCRAFT_RECEIVED",0) == 0 then
			control.CustomCommand('REQ_CALC_HOUSINGCRAFT_GOODS',0);
		end
		return 0;
	end
	return 1;	
end

function SET_TIME_TEXT(timer_text)
	local aObj = GetMyAccountObj();
	local endtime = imcTime.GetSysTimeByYYMMDDHHMMSS(TryGetProp(aObj,"HOUSINGCRAFT_END_TIME"));
	local remainsec = imcTime.GetDifSec(endtime, geTime.GetServerSystemTime());

    local day = math.floor(remainsec / 86400);
    local remainder  = remainsec % 86400;
    local hour = math.floor(remainder  / 3600);
    remainder  = remainder  % 3600;
    local min = math.floor(remainder  / 60);

    timer_text:SetTextByKey("day", day);
    timer_text:SetTextByKey("hour", hour);
	timer_text:SetTextByKey("min", min);
	return remainsec
end


function HOUSING_CRAFT_GET_REWARD(parent, self)
	control.CustomCommand('REQ_GET_HOUSINGCRAFT_GOODS',0);
end

function HOUSING_CRAFT_RECEIVED_GOODS(frame)
	local aObj = GetMyAccountObj();
	if TryGetProp(aObj,"HOUSINGCRAFT_RECEIVED",0) == 1 then
		local receive_btn = GET_CHILD_RECURSIVELY(frame, "receivebtn");
		receive_btn:SetEnable(0);
	else
		HOUSING_CRAFT_REMAIN_TIME_UPDATE(frame,"msg","YES");
	end
end

function HOUSING_CRAFT_COUPON_TEXT(frame)
	local aObj = GetMyAccountObj();
	local per = TryGetProp(aObj, "HOUSINGCRAFT_COUPON_PER", 0);
	local couponText = GET_CHILD_RECURSIVELY(frame,"couponText");
	local effect = "";
	if per > 0 then
		effect = effect..ClMsg('HousingCraftPer')..string.format("(%d%%)",per)
	end
	couponText:SetTextByKey("effect",effect);
end