function EVENTGAMBLE_ON_INIT(addon, frame)
	addon:RegisterMsg('EVENT_GAMBLE_START', 'ON_EVENT_GAMBLE_START');
	addon:RegisterMsg('COMMON_GAMBLE_ITEM_GET', 'ON_EVENT_GAMBLE_ITEM_GET');	
end

function ON_EVENT_GAMBLE_START(frame,msg,argStr,argNum)
	local eventCls = GetClass("gamble_list",argStr)
	EVENT_GAMBLE_INIT(frame,eventCls)
	EVENT_GAMBLE_ITEM_COST_INIT(frame,eventCls)
	EVENT_GAMBLE_ITEM_LIST_INIT(frame,eventCls)
	frame:ShowWindow(1)
end

-- 봉헌 · 확인 버튼, 획득 아이템 slot 초기화
function EVENT_GAMBLE_INIT(frame,eventCls)
	if ui.CheckHoldedUI() == true then
		return;
	end
	local gamble_slot = GET_CHILD_RECURSIVELY(frame, 'gamble_slot');
	gamble_slot:ClearIcon();

	local title_text = GET_CHILD_RECURSIVELY(frame,"title_text")
	title_text:SetTextByKey("title",eventCls.Name)

	frame:SetUserValue("EVENT_CLASSNAME",eventCls.ClassName)
	EVENT_GAMBLE_SET_HELP_TEXT(frame,eventCls)
end

function EVENT_GAMBLE_SET_HELP_TEXT(frame,eventCls)
	local help = GET_CHILD_RECURSIVELY(frame,'help')
	-- if string.find(eventCls.ClassName,"EVENT_2010_Halloween") == 1 then
	-- 	help:SetText(ClMsg("EVENT_2010_HALLOWEEN_UI_HELP"))
	-- end
end

-- 1회 봉헌 비용 설정
function EVENT_GAMBLE_ITEM_COST_INIT(frame,eventCls)
	local itemInfo = TryGetProp(eventCls,"ConsumeItem")
	itemInfo = StringSplit(itemInfo,'/')
	local itemClsName, itemCount = itemInfo[1],itemInfo[2]
	local gamble_silver = GET_CHILD_RECURSIVELY(frame, 'gamble_silver', 'ui::CRichText');
	gamble_silver:SetTextByKey("value", itemCount)

	local itemCls = GetClass("Item",itemClsName)
	local gamble_pic = GET_CHILD_RECURSIVELY(frame, 'gamble_pic', 'ui::CPicture');
	gamble_pic:SetImage(itemCls.Icon)

	local remain_coin = GET_CHILD_RECURSIVELY(frame,"remain_coin")
	remain_coin:SetTextByKey("icon",itemCls.Icon)
	local count = GetInvItemCount(GetMyPCObject(), itemCls.ClassName)
	count = STR_KILO_CHANGE(tostring(count))
	remain_coin:SetTextByKey("count",count)
end

function EVENT_GAMBLE_OPEN(frame)
end

function EVENT_GAMBLE_CLOSE(frame)
	if ui.CheckHoldedUI() == true then
		return;
	end
	ui.CloseFrame("eventgamble");
end

-- 일반 아이템 정보 설정 (초기화)
function EVENT_GAMBLE_ITEM_LIST_INIT(frame,eventCls)
	local protection_gb = GET_CHILD_RECURSIVELY(frame,"protection_gb")
	protection_gb:RemoveChildByType('controlset')

	local itemInfoTable = EVENT_GAMBLE_GET_ITEM_TABLE(eventCls)
	
	local row_size = #itemInfoTable
	local row = 0
	for row = 1,#itemInfoTable do
		for col = 1,#itemInfoTable[row] do
			local name = 'gamble_'..row..col;
			local grade = itemInfoTable[row][col][3]
			local x,y = GET_EVENT_GAMBLE_SLOT_MARGIN(protection_gb,row,col,row_size,#itemInfoTable[row])
			local ctrl = MAKE_GAMBLE_SLOT(protection_gb,name,tonumber(grade),x,y)
			local slot = GET_CHILD_RECURSIVELY(ctrl, 'slot');
			local itemclassname = itemInfoTable[row][col][1]
			local itemCls = GetClass('Item', itemclassname);
			if slot ~= nil and itemCls ~= nil then
				SET_SLOT_IMG(slot, itemCls.Icon);
				SET_ITEM_TOOLTIP_BY_TYPE(slot:GetIcon(), itemCls.ClassID);
				slot:GetIcon():SetTooltipOverlap(1);
				slot:SetUserValue("ITEM_ID", itemCls.ClassID);
			end
		end
	end
end
--commongamble.xml 아이템 읽어오기
function EVENT_GAMBLE_GET_ITEM_TABLE(eventCls)
	local itemInfoList = TryGetProp(eventCls,"RewardItemList")
	itemInfoList = StringSplit(itemInfoList,";")
	local itemGradeList = TryGetProp(eventCls,"RewardItemGrade")
	itemGradeList = StringSplit(itemGradeList,";")

	local retTable = {}
	local idx = 0
	local grade_before = 0
	for i = 1,#itemInfoList do
		local itemInfo = StringSplit(itemInfoList[i],'/')
		local itemclassname, itemCount = itemInfo[1], itemInfo[2]
		local itemGrade = tonumber(itemGradeList[i])
		if grade_before ~= itemGrade or #retTable[idx] >= 4 then
			idx = idx + 1
			retTable[idx]={}
		end
		table.insert(retTable[idx],{itemclassname, itemCount,itemGrade})
		grade_before = itemGrade
	end
	return retTable
end
--위치 설정
function GET_EVENT_GAMBLE_SLOT_MARGIN(groupBox,row,col,row_size,col_size)
	local X_MARGIN_UNIT_LIST = {0,200,190,140}
	local X_MARGIN_UNIT = X_MARGIN_UNIT_LIST[col_size]
	local x_margin = X_MARGIN_UNIT * (col-(col_size+1)/2)

	local height = groupBox:GetHeight()
	local slot_height = 146
	local OFFSET_Y_LIST = {0,150,70,30}
	local OFFSET_Y = OFFSET_Y_LIST[row_size]
	local Y_MARGIN_UNIT = (height - slot_height - OFFSET_Y*2)/(row_size-1)
	local y_margin = OFFSET_Y + Y_MARGIN_UNIT*(row-1)

	return x_margin,y_margin
end
--슬롯 추가
function MAKE_GAMBLE_SLOT(parent,name,grade,x,y)
	local ctrlSet = parent:CreateControlSet("event_gamble_slot", name, ui.CENTER_HORZ, ui.TOP, x,y, 0, 0);
	local slot_pic = GET_CHILD(ctrlSet, 'slot_pic');
	AUTO_CAST(slot_pic)
	if grade == 1 then
		slot_pic:SetImage("protection_normal")
	elseif grade == 2 then
		slot_pic:SetImage("protection_magic")
	elseif grade == 3 then
		slot_pic:SetImage("protection_unique")
	elseif grade == 4 then
		slot_pic:SetImage("protection_legend")
	end
	return ctrlSet
end

-- 봉헌 버튼 클릭, 조건확인 
function EVENT_GAMBLE_OK_BTN_CLICK(parent,ctrl)
	if ui.CheckHoldedUI() == true then
		return;
	end
	local frame = parent:GetTopParentFrame()
	local clsName = frame:GetUserValue("EVENT_CLASSNAME")
	local eventCls = GetClass("gamble_list",clsName)
	local itemInfo = TryGetProp(eventCls,"ConsumeItem")
	itemInfo = StringSplit(itemInfo,'/')
	local itemClsName, itemCount = itemInfo[1],tonumber(itemInfo[2])

	local invItem = session.GetInvItemByName(itemClsName);

	if invItem == nil or tonumber(invItem:GetAmountStr()) < itemCount then
		local itemCls = GetClass("Item",itemClsName)
		ui.SysMsg(ScpArgMsg("NotEnough{ItemName}Item","ItemName",itemCls.Name));		
		return;
	end

	-- 봉헌!
	ui.SetHoldUI(true);
	common_gamble.RequestCommonGamble(eventCls.ClassID);
	EVENT_GAMBLE_OK_BTN_EFFECT(frame)
	ReserveScript("BUTTON_UNFREEZE()", CASUAL_GAMBLE_CLICK_DELAY);
end

-- 획득 가능한 아이템 SLOT들, 버튼 이펙트
function EVENT_GAMBLE_OK_BTN_EFFECT(frame)
	local GAMBLE_BUTTON_EFFECT_NAME = frame:GetUserConfig('GAMBLE_BUTTON_EFFECT');
	local GAMBLE_BUTTON_EFFECT_SCALE = tonumber(frame:GetUserConfig('GAMBLE_BUTTON_EFFECT_SCALE'));
	local GAMBLE_BUTTON_EFFECT_DURATION = tonumber(frame:GetUserConfig('GAMBLE_BUTTON_EFFECT_DURATION'));
	local gamble_btn_gb = GET_CHILD_RECURSIVELY(frame, 'gamble_btn_gb');
	if gamble_btn_gb == nil then
		return;
	end
	gamble_btn_gb:PlayUIEffect(GAMBLE_BUTTON_EFFECT_NAME, GAMBLE_BUTTON_EFFECT_SCALE, 'GAMBLE_BUTTON_EFFECT');
	ReserveScript("_EVENTGAMBLE_EFFECT()", GAMBLE_BUTTON_EFFECT_DURATION);
end

function _EVENTGAMBLE_EFFECT()
	local frame = ui.GetFrame("eventgamble");
	if frame:IsVisible() == 0 then
		return;
	end

	local gamble_btn_gb = GET_CHILD_RECURSIVELY(frame, 'gamble_btn_gb');
	if gamble_btn_gb ~= nil then
		gamble_btn_gb:StopUIEffect('GAMBLE_BUTTON_EFFECT', true, 0.5);
	end
end

function EVENT_GAMBLE_RESULT_EFFECT(frame,itemid)
	if frame:IsVisible() == 0 then
		return;
	end
	
	-- 획득 가능 아이템 slot 들 중 획득한 아이템 slot
	local RESULT_EFFECT_NAME = frame:GetUserConfig('RESULT_EFFECT');
	local RESULT_EFFECT_SCALE = tonumber(frame:GetUserConfig('RESULT_EFFECT_SCALE'));
	local RESULT_EFFECT_DURATION = tonumber(frame:GetUserConfig('RESULT_EFFECT_DURATION'));
	local resultslot = EVENT_GAMBLE_GET_SLOT(frame,itemid);
	if resultslot == nil then
		return;
	end

	resultslot:PlayUIEffect(RESULT_EFFECT_NAME, RESULT_EFFECT_SCALE, 'RESULT_EFFECT');
	ReserveScript("_GAMBLE_RESULT_EFFECT()", RESULT_EFFECT_DURATION);
end

function _GAMBLE_RESULT_EFFECT()
	local frame = ui.GetFrame("eventgamble");
	if frame:IsVisible() == 0 then
		return;
	end
	
	local gamble_slot = GET_CHILD_RECURSIVELY(frame, 'gamble_slot');
	local itemid = gamble_slot:GetUserValue("ITEM_ID");
	local resultslot = EVENT_GAMBLE_GET_SLOT(frame,itemid);
	if resultslot == nil then
		return;
	end

	resultslot:StopUIEffect('RESULT_EFFECT', true, 0.5);
end

--아이템 획득
function ON_EVENT_GAMBLE_ITEM_GET(frame, msg, itemid, itemCount)
	EVENT_GAMBLE_ITEM_GET(frame, itemid);	
	EVENT_GAMBLE_RESULT_EFFECT(frame,itemid);
	EVENT_GAMBLE_ITEM_REMAIN_UPDATE(frame)
end

-- 아이템 획득시 획득 아이템 slot 변경
function EVENT_GAMBLE_ITEM_GET(frame, itemid)
	local slot = GET_CHILD_RECURSIVELY(frame, 'gamble_slot');
	local itemCls = GetClassByType('Item', itemid);
	if itemCls ~= nil then	
		SET_SLOT_IMG(slot, itemCls.Icon);
		SET_ITEM_TOOLTIP_BY_TYPE(slot:GetIcon(), itemCls.ClassID);
		slot:GetIcon():SetTooltipOverlap(1);
		slot:SetUserValue("ITEM_ID", itemid);
	end
	-- 아이템 획득 사운드
	local GET_ITEM_SOUND = frame:GetUserConfig('GET_ITEM_SOUND');
	imcSound.PlaySoundEvent(GET_ITEM_SOUND);
end

-- itemid로 해당 아이템이 출력되는 slot 반환
function EVENT_GAMBLE_GET_SLOT(frame,itemid)
	if itemid == "None" then
		return nil;
	end
	
	local protection_gb = GET_CHILD_RECURSIVELY(frame,"protection_gb")
	for i = 0,protection_gb:GetChildCount()-1 do
		local ctrlSet = protection_gb:GetChildByIndex(i)
		local slot = GET_CHILD_RECURSIVELY(ctrlSet,'slot')
		if slot ~= nil then
			local slotitemid = slot:GetUserValue("ITEM_ID");
			if tonumber(itemid) == tonumber(slotitemid) then
				return slot;
			end
		end
	end

	return nil;
end


function EVENT_GAMBLE_ITEM_REMAIN_UPDATE(frame)
	local eventClsName = frame:GetUserValue("EVENT_CLASSNAME")		
	local eventCls = GetClass("gamble_list",eventClsName)
	if eventCls == nil then
		return
	end
	local itemInfo = TryGetProp(eventCls,"ConsumeItem")
	if itemInfo == nil or #itemInfo < 2 then
		return
	end

	itemInfo = StringSplit(itemInfo,'/')
	local itemClsName, itemCount = itemInfo[1], itemInfo[2]	
	if itemClsName == nil or itemCount == nil then
		return
	end
	local remain_coin = GET_CHILD_RECURSIVELY(frame,"remain_coin")
	local count = GetInvItemCount(GetMyPCObject(), itemClsName)
	count = STR_KILO_CHANGE(tostring(count))
	remain_coin:SetTextByKey("count",count)
end