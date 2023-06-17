
function DRESS_ROOM_ON_INIT(addon, frame)
	addon:RegisterMsg('DRESS_ROOM_SET', 'ON_DRESS_ROOM_UPDATE');
	addon:RegisterMsg('DRESS_ROOM_COLLECTION_ADD', 'ON_DRESS_ROOM_UPDATE');
end

local DRESS_ROOM_CTRL_Y_OFFSET = -5
local DRESS_ROOM_CTRL_EXPEND_HEIGHT = 60

function DRESS_ROOM_UI_OPEN(frame)
	DRESS_ROOM_INIT(frame)
end

function DRESS_ROOM_UI_CLOSE(frame)
	ui.CloseFrame('dress_room_magic')
	ui.CloseFrame('dress_room_register')
end

function DRESS_ROOM_INIT(frame)
	local itemTable = DRESS_ROOM_GET_ITEM_TABLE()
	local clsList,cnt = GetClassList("dress_room_reward")
	local ListBox = GET_CHILD_RECURSIVELY(frame,"ListBox")
	ListBox:RemoveAllChild()
	local aObj = GetMyAccountObj()
	local y = 0
	for i = 0, cnt-1 do
		local cls = GetClassByIndexFromList(clsList, i);
		local ctrlSet = ListBox:CreateOrGetControlSet('dress_room_deck', 'CTRL_'..i, 0, y);
		DRESS_ROOM_INIT_DECK(frame,ctrlSet,cls,itemTable,aObj)
		y = y + ctrlSet:GetHeight() + DRESS_ROOM_CTRL_Y_OFFSET
	end
end

function DRESS_ROOM_GET_ITEM_TABLE()
	local itemTable = {}
	local clsList,cnt = GetClassList("dress_room")
	for i = 0, cnt-1 do
		local cls = GetClassByIndexFromList(clsList, i);
		local thema = TryGetProp(cls,"Thema")
		if itemTable[thema] == nil then
			itemTable[thema] = {}
		end
		table.insert(itemTable[thema],cls)
	end
	return itemTable
end

function DRESS_ROOM_INIT_DECK(frame,ctrlSet,cls,itemTable,aObj)
	-- 타이틀 입력
	local thema = TryGetProp(cls,"ClassName")
	ctrlSet:SetUserValue("THEMA",thema)
	local collec_name = GET_CHILD(ctrlSet,"collec_name")
	collec_name:SetTextByKey("name",cls.Name)
	-- 개수 입력
	local curcount = GET_DRESS_ROOM_THEMA_ITEM_NUM(thema,itemTable,aObj)
	local collec_count = GET_CHILD(ctrlSet,"collec_count")
	collec_count:SetTextByKey("curcount",curcount)
	collec_count:SetTextByKey("maxcount",#itemTable[thema])
	-- 효과 버튼 텍스트 입력
	local richMagic = GET_CHILD_RECURSIVELY(ctrlSet,"richMagic")
	richMagic:SetTextByKey("value", ClMsg("CollectionMagicText"));

	local rewardStr = DRESS_ROOM_GET_REWARD_TEXT(cls)
	local magicList = GET_CHILD_RECURSIVELY(ctrlSet,"magicList")
	magicList:SetTextByKey("value", rewardStr)

	RESIZE_DRESS_ROOM_CTRLSET(ctrlSet)

	local gb_complete = GET_CHILD(ctrlSet,"gb_complete")
	local font,desc_font;
	--미등록
	if TryGetProp(aObj,thema) == 0 then
		gb_complete:SetVisible(0)
		ctrlSet:SetSkinName(frame:GetUserConfig("DISABLE_SKIN"));
		ctrlSet:SetUserValue("COLLECTION_STATE", "DISABLE");
		font = frame:GetUserConfig("DISABLE_DECK_TITLE_FONT")
		desc_font = frame:GetUserConfig("DISABLE_MAGIC_LIST_FONT");
		local iconMagic = GET_CHILD_RECURSIVELY(ctrlSet,"iconMagic")
		iconMagic:SetColorTone(frame:GetUserConfig("NOT_HAVE_COLOR")); -- 효과 버튼 이미지 컬러톤 설정
	--완성
	elseif curcount == #itemTable[thema] then
		gb_complete:SetVisible(1)
		font = frame:GetUserConfig("COMPLETE_DECK_TITLE_FONT")
		desc_font = frame:GetUserConfig("ENABLE_MAGIC_LIST_FONT");
		ctrlSet:SetSkinName(frame:GetUserConfig("ENABLE_SKIN"));
		ctrlSet:SetUserValue("COLLECTION_STATE", "COMPLETE");
	--미완성
	else
		gb_complete:SetVisible(0)
		font = frame:GetUserConfig("DECK_TITLE_FONT")
		desc_font = frame:GetUserConfig("ENABLE_MAGIC_LIST_FONT");
		ctrlSet:SetSkinName(frame:GetUserConfig("ENABLE_SKIN"));
		ctrlSet:SetUserValue("COLLECTION_STATE", "INCOMPLETE");
	end
	collec_name:SetTextByKey("font",font)
	magicList:SetTextByKey("font",desc_font)
	--디테일 페이지 제거
	local gb_items = GET_CHILD_RECURSIVELY(ctrlSet,"gb_items")
	gb_items:SetVisible(0)
end

function DRESS_ROOM_GET_REWARD_TEXT(cls)
	local reward = StringSplit(TryGetProp(cls,"PropList"),';')
	local rewardStr = {}
	local rewardPerPiece = TryGetProp(cls, "RewardPerPiece", "NO")
	if rewardPerPiece == "YES" then
		table.insert(rewardStr,ClMsg("PerPieceInCollection"))
	end
	for i = 1,#reward do
		local prop = StringSplit(reward[i],'/')
		local propStr = string.format("%s+%d",ClMsg(prop[1]),prop[2])
		table.insert(rewardStr,propStr)
	end
	return table.concat(rewardStr,"{nl}")
end

-- 완성 여부 확인 확인
function GET_DRESS_ROOM_THEMA_ITEM_NUM(thema,itemTable,aObj)
	local cnt = 0
	for j = 1,#itemTable[thema] do
		if DRESS_ROOM_IS_ITEM_SET(aObj,itemTable[thema][j]) == true then
			cnt = cnt + 1
		end
	end
	return cnt
end

function DRESS_ROOM_SET_COSTUME_SLOT(gBox, itemList, state)
	local aObj = GetMyAccountObj()
	local frame = gBox:GetTopParentFrame()
	local disable_color = frame:GetUserConfig("NOT_HAVE_COLOR")
	for i = 1, #itemList do
		local rewardCls = itemList[i]
		local slotCtrlSet = gBox:CreateOrGetControlSet('dress_rool_slot', "SLOT_"..rewardCls.ClassName, 20 + (i-1)*60, 0);
		local slot = GET_CHILD_RECURSIVELY(slotCtrlSet,"slot")
		local itemCls = GetClass("Item",rewardCls.ItemClassName)
		SET_SLOT_IMG(slot, itemCls.Icon);
		SET_ITEM_TOOLTIP_BY_TYPE(slot:GetIcon(), itemCls.ClassID);
		slotCtrlSet:SetUserValue("DRESS_PROP",rewardCls.ClassName)
		local btn = GET_CHILD_RECURSIVELY(slotCtrlSet, "btn")
		btn:ShowWindow(0)
		local icon = CreateIcon(slot)
		if DRESS_ROOM_IS_ITEM_SET(aObj, rewardCls) == false then
			icon:SetColorTone(disable_color)
			if TryGetProp(rewardCls, "Group", "None") == "dress_room_blessed_cube" then
				btn:ShowWindow(1)
				btn:SetEventScriptArgNumber(ui.LBUTTONUP, rewardCls.ClassID)
			end
		else
			icon:SetColorTone("FFFFFFFF")
		end
	end
end

function OPEN_DRESS_ROOM_DECK_DETAIL(parent,ctrl,argStr,argNum)
	local ctrlSet = parent
	local itemTable = DRESS_ROOM_GET_ITEM_TABLE()
	local thema = ctrlSet:GetUserValue("THEMA")
	local is_open = 1-ctrlSet:GetUserIValue("DETAIL_OPEN")
	local gb_items = GET_CHILD_RECURSIVELY(ctrlSet,"gb_items")
	local magicList = GET_CHILD_RECURSIVELY(ctrlSet,"magicList")
	local gb_complete = GET_CHILD(ctrlSet,"gb_complete")
	gb_items:SetVisible(is_open)

	if is_open == 1 then
		DRESS_ROOM_SET_COSTUME_SLOT(gb_items, itemTable[thema], ctrlSet:GetUserValue("COLLECTION_STATE"))
	end
	ctrlSet:SetUserValue("DETAIL_OPEN", is_open)
	RESIZE_DRESS_ROOM_CTRLSET(ctrlSet)
	GBOX_AUTO_ALIGN(ctrlSet:GetParent(), 0, DRESS_ROOM_CTRL_Y_OFFSET, 0, true, true);
end

function DRESS_ROOM_IS_ITEM_SET(aObj, rewardCls)
	return TryGetProp(aObj,rewardCls.ClassName) == 1
end

function ON_CLICK_DRESS_ROOM_MAKE_ITEM(parent,ctrl)
	local propName = parent:GetUserValue("DRESS_PROP")
	if propName == nil or propName == "None" then
		return
	end
	local cls = GetClass("dress_room",propName)
	if cls == nil then
		return
	end
	local aObj = GetMyAccountObj()
	if TryGetProp(aObj,propName) == 0 then
		return
	end
	local invItem = session.GetInvItemByName(cls.ItemClassName)
	if invItem ~= nil then
		addon.BroadMsg("NOTICE_Dm_!", ClMsg("Auto_iMi_aiTemeul_KaJiKo_issSeupNiDa"), 3);
		return
	end

	local equip_item = session.GetEquipItemBySpot(item.GetEquipSpotNum('OUTER'))
	if equip_item ~= nil then
		local equip_obj = GetIES(equip_item:GetObject())
		if equip_obj ~= nil then			
			if TryGetProp(equip_obj, 'ClassName', 'None') == cls.ItemClassName then
				addon.BroadMsg("NOTICE_Dm_!", ClMsg("Auto_iMi_aiTemeul_KaJiKo_issSeupNiDa"), 3);
				return
			end
		end
	end

	dress_room.RequestMakeItemFromDressRoom(propName)
end

function ON_DRESS_ROOM_UPDATE(frame,msg,thema,argNum)
	local clsList,cnt = GetClassList("dress_room_reward")
	local ListBox = GET_CHILD_RECURSIVELY(frame, "ListBox")
	local ctrlSet = nil
	for i = 0, cnt-1 do
		local tmp = ListBox:GetControlSet('dress_room_deck', 'CTRL_'..i);
		if tmp ~= nil and tmp:GetUserValue("THEMA") == thema then
			ctrlSet = tmp
			break
		end
	end

	if ctrlSet == nil then
		return
	end

	local aObj = GetMyAccountObj()
	local itemTable = DRESS_ROOM_GET_ITEM_TABLE()
	local rewardCls = GetClass("dress_room_reward",thema)
	DRESS_ROOM_INIT_DECK(frame, ctrlSet, rewardCls, itemTable, aObj)
	local is_open = ctrlSet:GetUserIValue("DETAIL_OPEN")
	local gb_items = GET_CHILD_RECURSIVELY(ctrlSet, "gb_items")
	gb_items:SetVisible(is_open)
	if is_open == 1 then
		DRESS_ROOM_SET_COSTUME_SLOT(gb_items, itemTable[thema], ctrlSet:GetUserValue("COLLECTION_STATE"))
	end
end

-- 총 효과보기 버튼 클릭시.
function VIEW_DRESS_ROOM_ALL_STATUS(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	local aObj = GetMyAccountObj()
	-- 효과 리스트를 갱신
	local completeList ={}; -- 완료된 총 효과 리스트.
	local itemTable = DRESS_ROOM_GET_ITEM_TABLE()
	local clsList,cnt = GetClassList("dress_room_reward")
	local complete_cnt = 0
	for i = 0, cnt-1 do
		local cls = GetClassByIndexFromList(clsList, i);
		local thema = TryGetProp(cls,"ClassName")
		local rewardPerPiece = TryGetProp(cls, "RewardPerPiece", "NO") == "YES"
		local is_complete = true
		local pieceCount = 0
		for j = 1,#itemTable[thema] do
			if DRESS_ROOM_IS_ITEM_SET(aObj,itemTable[thema][j]) == false then
				if rewardPerPiece == false then
					is_complete = false
					break
				end
			else
				pieceCount = pieceCount + 1
			end
		end
		if is_complete == true or (rewardPerPiece == true and pieceCount > 0) then
			local reward = StringSplit(TryGetProp(cls,"PropList"),';')
			for i = 1,#reward do
				local prop = StringSplit(reward[i],'/')
				local propName,propValue = ClMsg(prop[1]),tonumber(prop[2])
				if completeList[propName] == nil then
					completeList[propName] = 0
				end
				if rewardPerPiece == true then
					propValue = propValue * pieceCount
				end
				completeList[propName] = completeList[propName] + propValue
			end
			complete_cnt = complete_cnt + 1
		end
	end
	SET_COLLECTION_MAIGC_LIST(frame, completeList, complete_cnt,'dress_room_magic')
	COLLECTION_MAGIC_OPEN(frame,'dress_room_magic');
end

function RESIZE_DRESS_ROOM_CTRLSET(ctrlSet)
	local magicList = GET_CHILD_RECURSIVELY(ctrlSet,"magicList")
	local height_diff = magicList:GetHeight() - magicList:GetOriginalHeight()

	local gb_complete = GET_CHILD(ctrlSet,"gb_complete")
	local gb_magic = GET_CHILD(ctrlSet,"gb_magic")
	
	local is_open = ctrlSet:GetUserIValue("DETAIL_OPEN")
	if is_open == 1 then
		height_diff = height_diff + DRESS_ROOM_CTRL_EXPEND_HEIGHT
	end
	ctrlSet:Resize(ctrlSet:GetWidth(), ctrlSet:GetOriginalHeight() + height_diff)
	gb_complete:Resize(gb_complete:GetWidth(), gb_complete:GetOriginalHeight() + height_diff)
	gb_magic:Resize(gb_magic:GetWidth(), gb_magic:GetOriginalHeight() + height_diff)
end