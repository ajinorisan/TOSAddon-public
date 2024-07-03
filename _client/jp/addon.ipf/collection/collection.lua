-- collection.lua
REMOVE_ITEM_SKILL = 7

local reinf_item_list = nil
local collection_item_info_list = nil

local function make_collection_item_info_list()
	if collection_item_info_list == nil then
		collection_item_info_list = {}
		local list, cnt = GetClassList('Collection')
		for i = 0, cnt - 1 do
			local cls = GetClassByIndexFromList(list, i)
			if TryGetProp(cls, 'IsReinfoCol', 0) == 1 then
				local type = TryGetProp(cls, 'ClassID', 0)
				for j = 1, 10 do
					local name = TryGetProp(cls, 'ItemName_' .. j, 'None')
					if name ~= 'None' then
						local reinfo = TryGetProp(cls, 'Reinforce_' .. j, 0)
						if collection_item_info_list[name] == nil then
							collection_item_info_list[name] = {}
						end						
						collection_item_info_list[name][type] = reinfo
					else
						break
					end
				end
			end
		end
	end
end

local function make_reinf_item_list()
	if reinf_item_list == nil then
		reinf_item_list = {}
		local inv_item_list = session.GetInvItemList()		
		local inv_guid_list = inv_item_list:GetGuidList();
		local count = inv_guid_list:Count();
		for i = 0 , count - 1 do
			local guid = inv_guid_list:Get(i)
			local inv_item = inv_item_list:GetItemByGuid(guid)
			if inv_item ~= nil and inv_item:GetObject() ~= nil then
				local obj = GetIES(inv_item:GetObject())
				local name = TryGetProp(obj, 'ClassName', 'None')
				local tbl = collection_item_info_list[name] 
				
				if tbl ~= nil then -- 컬렉션 아이템이면
					if reinf_item_list[name] == nil then
						reinf_item_list[name] = {}
					end

					local rein = TryGetProp(obj, 'Reinforce_2', 0)
					if reinf_item_list[name][rein] == nil then
						reinf_item_list[name][rein] = 0
					end

					reinf_item_list[name][rein] = reinf_item_list[name][rein] + 1
				end
			end
		end
	end
end

local function update_reinf_item_list(name, rein, add)
	if reinf_item_list[name] == nil or reinf_item_list[name][rein] == nil then
		reinf_item_list = nil
		make_reinf_item_list()
		return
	end

	reinf_item_list[name][rein] = reinf_item_list[name][rein] + add	
	if reinf_item_list[name][rein] < 0 then
		reinf_item_list = nil
		make_reinf_item_list()
		return
	end

end

local function get_inv_itemlist_by_name_and_reinforce(itemName, reinforce)
	local ret = {}
	local inv_item_list = session.GetInvItemList()
	local inv_guid_list = inv_item_list:GetGuidList()
	local count = inv_guid_list:Count()
	for j = 0, count - 1 do
		local guid = inv_guid_list:Get(j)
		local inv_item = inv_item_list:GetItemByGuid(guid)
		if inv_item ~= nil and inv_item:GetObject() ~= nil then
			local obj = GetIES(inv_item:GetObject())
			if itemName == TryGetProp(obj, 'ClassName', 0) and TryGetProp(obj, 'Reinforce_2', 0) == reinforce then
				table.insert(ret, obj)	
			end
		end
	end
	
	return ret
end

local collectionStatus = {
    isNormal = 0,			-- 기본
	isNew  = 1,				-- 새로등록됨
	isComplete = 2,			-- 완성
	isAddAble = 3			-- 수집가능
};

local collectionView = {
    isUnknown  = 0,			-- 미확인
	isIncomplete = 1,		-- 미완성
	isComplete = 2,			-- 완성
};

local collectionSortTypes = {
	default = 0,			-- 기본값: 기본 컬렉션 순서
	name = 1,				-- 이름순: 컬렉션의 이름순서
	status = 2				-- 상태  : 기본(0), 새로등록(1), 완성(2), 수집가능(3) << 수치가 높을수록 아래로감 >>
};

local collectionViewOptions = {
	showCompleteCollections = true,
	showUnknownCollections = false,
	showIncompleteCollections = true,
	sortType = collectionSortTypes.default
};

local collectionViewCount = {
	showCompleteCollections = 0,
	showUnknownCollections = 0,
	showIncompleteCollections = 0
};

function COLLECTION_ON_INIT(addon, frame)
	addon:RegisterMsg("ADD_COLLECTION", "ON_ADD_COLLECTION");
	addon:RegisterMsg("COLLECTION_ITEM_CHANGE", "ON_COLLECTION_ITEM_CHANGE");
	addon:RegisterMsg("INV_ITEM_REMOVE", "ON_COLLECTION_ITEM_CHANGE");	
	addon:RegisterOpenOnlyMsg("INV_ITEM_ADD", "ON_COLLECTION_ITEM_CHANGE");
	addon:RegisterOpenOnlyMsg("INV_ITEM_IN", "ON_COLLECTION_ITEM_CHANGE");
	addon:RegisterOpenOnlyMsg("INV_ITEM_POST_REMOVE", "ON_COLLECTION_ITEM_CHANGE");
	addon:RegisterOpenOnlyMsg("INV_ITEM_CHANGE_COUNT", "ON_COLLECTION_ITEM_CHANGE");
	addon:RegisterMsg("UPDATE_READ_COLLECTION_COUNT", "ON_COLLECTION_ITEM_CHANGE");
	addon:RegisterMsg('COLLECTION_UI_OPEN', 'COLLECTION_DO_OPEN');
	addon:RegisterMsg("COLLECTION_ITEM_REINFORCE", "ON_COLLECTION_ITEM_REINFORCE");
	addon:RegisterMsg('DRESS_ROOM_SET', 'ON_COLLECTION_ITEM_CHANGE');
	addon:RegisterMsg('DRESS_ROOM_COLLECTION_ADD', 'ON_COLLECTION_ITEM_CHANGE');
end

function COLLECTION_DO_OPEN(frame)	
	ui.ToggleFrame('inventory')
    ui.ToggleFrame('collection')
	RUN_CHECK_LASTUIOPEN_POS(frame)
end

function UI_TOGGLE_COLLECTION()	
	if app.IsBarrackMode() == true then
		return;
	end
	ui.ToggleFrame('inventory');
	ui.ToggleFrame('collection');
end

function COLLECTION_ON_RELOAD(frame)
	COLLECTION_FIRST_OPEN(frame);
end

-- 컬렉션이 최초 열렸을때 드롭다운 리스트를 만든다.
function COLLECTION_FIRST_OPEN(frame)
	local aligntype_list = GET_CHILD_RECURSIVELY(frame, "aligntype_list");
	aligntype_list:ClearItems();
	aligntype_list:AddItem("0",  ClMsg("AlignDefault"), 0); -- ClMsg는 clientmessage.xml에 정의되어 있는 값을 가져온다.
	aligntype_list:AddItem("1",  ClMsg("AlignName"), 0);
	aligntype_list:AddItem("2",  ClMsg("AlignStatus"), 0);
	aligntype_list:SelectItem(0);
	make_collection_item_info_list()
	make_reinf_item_list()
	local category_tab = GET_CHILD_RECURSIVELY(frame, "category_tab", "ui::CTabControl");
	if category_tab ~= nil then
		category_tab:SelectTab(0);
		frame:SetUserValue("CATEGORY_IDX", 0);
	end
	UPDATE_COLLECTION_LIST(frame);
end

function ON_ADD_COLLECTION(frame, msg)
	UPDATE_COLLECTION_LIST(frame);
	UPDATE_COSTUME_COLLECTION_LIST(frame);
	local colls = session.GetMySession():GetCollection();
	if colls:Count() == 1 then
		SYSMENU_FORCE_ALARM("collection", "Collection");
	end
	imcSound.PlaySoundEvent('cllection_register');
	frame:Invalidate();
	end

function ON_COLLECTION_ITEM_CHANGE(frame, msg, str, type, removeType)
	make_collection_item_info_list()
	make_reinf_item_list()
	if msg == 'INV_ITEM_IN' or msg == 'INV_ITEM_ADD' then		
		local inv_item_list = session.GetInvItemList()		
		local inv_item = inv_item_list:GetItemByGuid(str);
		if inv_item ~= nil and inv_item:GetObject() ~= nil then
			local obj = GetIES(inv_item:GetObject())
			local name = TryGetProp(obj, 'ClassName', 'None')			
			if collection_item_info_list[name] == nil then
				return
			end
			local reinforce = TryGetProp(obj, 'Reinforce_2', 0)
			update_reinf_item_list(name, reinforce, 1)
		end
	elseif msg == 'INV_ITEM_REMOVE' then		
		local inv_item_list = session.GetInvItemList()		
		local inv_item = inv_item_list:GetItemByGuid(str);
		if inv_item ~= nil and inv_item:GetObject() ~= nil then
			local obj = GetIES(inv_item:GetObject())
			local name = TryGetProp(obj, 'ClassName', 'None')
			local reinforce = TryGetProp(obj, 'Reinforce_2', 0)
			update_reinf_item_list(name, reinforce, -1)		
			return
		end
	end
	local category_tab = GET_CHILD_RECURSIVELY(frame, "category_tab", "ui::CTabControl");
	if category_tab ~= nil then
		local idx = category_tab:GetSelectItemIndex();
		frame:SetUserValue("CATEGORY_IDX", idx);
		SCR_NEW_COLLECTION_DETAIL_VIEW_REMOVE(frame);
		if idx == 2 then
			UPDATE_COSTUME_COLLECTION_LIST(frame, str, removeType);
		else
			UPDATE_COLLECTION_LIST(frame);
		end
	end
end

function ON_COLLECTION_ITEM_REINFORCE(frame, msg, guid, result)		
	local inv_item_list = session.GetInvItemList()		
	local inv_item = inv_item_list:GetItemByGuid(guid);

	if inv_item ~= nil then
		local obj = GetIES(inv_item:GetObject())
		local name = TryGetProp(obj, 'ClassName', 'None')
		local reinforce = TryGetProp(obj, 'Reinforce_2', 0)		

		if result == 1 then			
			local before = reinforce - 1
			update_reinf_item_list(name, before, -1)
			update_reinf_item_list(name, reinforce, 1)

		elseif result == 0 then	
			local before = reinforce + 1
			update_reinf_item_list(name, before, -1)
			update_reinf_item_list(name, reinforce, 1)
		end
	end
end

-- 컬렉션 정렬 드롭다운리스트 갱신
function COLLECTION_TYPE_CHANGE(frame, ctrl)
	local alignoption = tolua.cast(ctrl, "ui::CDropList");
	if alignoption ~= nil then
		collectionViewOptions.sortType  = alignoption:GetSelItemIndex();
	end
	
	local topFrame = frame:GetTopParentFrame();
	if topFrame ~= nil then
		UPDATE_COLLECTION_LIST(topFrame);
		UPDATE_COSTUME_COLLECTION_LIST(topFrame);
	end
end

function SET_COLLECTION_PIC(index, frame, slotSet, itemCls, coll, type,drawitemset, reinforce, IsReinfoCol)		
	local colorTone = nil;
	local slot = GET_CHILD(slotSet,"slot","ui::CSlot");
	local btn = GET_CHILD(slotSet, "btn", "ui::CButton");
	local icon = CreateIcon(slot);
	slot:SetUserValue("COLLECTION_TYPE",type);
	slot:SetUserValue("index", index)
	slot:SetUserValue('Reinforce', reinforce)
	icon:SetImage(itemCls.Icon);
	icon:SetTooltipOverlap(0);
	if reinforce > 0 then
		slot:SetText('{s20}{ol}{#FFFFFF}+'..reinforce, 'count', ui.RIGHT, ui.TOP, 0, 2)		
	end

	-- # 기본 아이템 툴팁을 넣음. 아래는 이전부터 있던 주석.
	-- 세션 컬렉션에 오브젝트 정보가 존재하고 이를 바탕으로 하면 item오브젝트의 옵션을 살린 툴팁도 생성 가능하다. 가령 박아넣은 젬의 경험치라던가.
	-- 허나 지금 슬롯 지정하여 꺼내는 기능이 없기 때문에 무의미. 정확한 툴팁을 넣으려면 COLLECTION_TAKE를 type이 아니라 guid 기반으로 바꿔야함
	local tool_str = 'collection'
	if reinforce > 0 then		
		tool_str = 'copy_prop:Reinforce_2' .. '/' .. tostring(reinforce) .. ';'
	end

	SET_ITEM_TOOLTIP_ALL_TYPE(icon, nil, itemCls.ClassName, tool_str, itemCls.ClassID, itemCls.ClassID);
	
	-- 우선 안보이도록 처리
	slot:ShowWindow(0);
	btn:ShowWindow(0);

	-- 공통 처리부분.
	local invcount = session.GetInvItemCountByType(itemCls.ClassID);
	
	if IsReinfoCol == 1 or reinforce > 0 then
		if reinf_item_list[itemCls.ClassName] ~= nil and reinf_item_list[itemCls.ClassName][reinforce] ~= nil then
			invcount = reinf_item_list[itemCls.ClassName][reinforce]			
		else
			invcount = 0
	end
	
	end
	
	local totalcount = invcount;
	local showedcount = 0
	
	if drawitemset[itemCls.ClassID] ~= nil then
		showedcount = drawitemset[itemCls.ClassID]
	end

	if coll ~= nil then		
		local collecount = coll:GetItemCountByType(itemCls.ClassID);

		-- 1. 내가 이미 모은 것들(컬렉션을 등록했을 때만)
		if collecount > showedcount then
			if drawitemset[itemCls.ClassID] == nil then
				drawitemset[itemCls.ClassID] = 1
			else
				drawitemset[itemCls.ClassID] = drawitemset[itemCls.ClassID] + 1
			end
			slot:ShowWindow(1);

			return ;
		end

		totalcount = invcount + collecount;
	end

	-- 공통 처리
	-- 2. 꼽으면 되는 것들		
	if totalcount > showedcount then
		if drawitemset[itemCls.ClassID] == nil then
			drawitemset[itemCls.ClassID] = 1
		else
			drawitemset[itemCls.ClassID] = drawitemset[itemCls.ClassID] + 1
		end
		colorTone = frame:GetUserConfig("ITEM_EXIST_COLOR");
		slot:ShowWindow(1);

		if coll ~= nil then
			btn:ShowWindow(1);
			btn:SetTooltipOverlap(0);
			SET_ITEM_TOOLTIP_ALL_TYPE(btn, nil, itemCls.ClassName, tool_str, itemCls.ClassID, itemCls.ClassID); 				
		end
	else
		colorTone = frame:GetUserConfig("BLANK_ITEM_COLOR");
		slot:ShowWindow(1);	
	end

	if colorTone ~= nil then
		icon:SetColorTone(colorTone);
	end
end

function GET_COLLECTION_COUNT(type, coll)
	local curCount = 0;
	if coll ~= nil then
		curCount = coll:GetItemCount();
	end
	local info = geCollectionTable.Get(type);
	local maxCount = info:GetTotalItemCount();
	return curCount, maxCount;
end

function COLLECTION_OPEN(frame)
	local category_tab = GET_CHILD_RECURSIVELY(frame, "category_tab", "ui::CTabControl");
	if category_tab ~= nil then
		local idx = frame:GetUserIValue("CATEGORY_IDX");
		if idx == nil then idx = 0; end
		category_tab:SelectTab(idx);
		frame:SetUserValue("CATEGORY_IDX", idx);
		if idx == 2 then
			UPDATE_COSTUME_COLLECTION_LIST(frame);
		else
	UPDATE_COLLECTION_LIST(frame);
end
		SCR_NEW_COLLECTION_DETAIL_VIEW_REMOVE(frame);
	end
end

function COLLECTION_CLOSE(frame)
	ui.CloseFrame('collection_allstatus_view');
	local inventory = ui.GetFrame("inventory");
	if inventory ~= nil then
		inventory:ShowWindow(0);
	end
	SCR_NEW_COLLECTION_DETAIL_VIEW_REMOVE(frame);
	UNREGISTERR_LASTUIOPEN_POS(frame);
end

function GET_COLLECT_ABLE_ITEM_COUNT(coll, type)
	local cls = GetClassByType("Collection", type);
	local curCount, maxCount = GET_COLLECTION_COUNT(type, coll);
	local numCnt= 0;
	local inv_item_list = session.GetInvItemList();
	local inv_guid_list = inv_item_list:GetGuidList();
	local count = inv_guid_list:Count();
	local IsReinfoCol = TryGetProp(cls, 'IsReinfoCol', 0)

	-- 한번돌면서 itemList를 채운다.
	local itemList = {};
	local itemCount = {};
	for i = 1 , maxCount do
		local itemName = TryGetProp(cls,"ItemName_" .. i, 'None');
		if itemName == nil or itemName == "None" then
			numCnt= 0;
			break;
		end

		local itemCls = GetClass("Item", itemName);
		if itemCls == nil then
			numCnt= 0;
			break;
		end

		local collecount = 0; -- coll이 nil일때의 기본값.
		local invcount = 0
		if IsReinfoCol == 0 then
			if coll ~= nil then
				collecount = coll:GetItemCountByType(itemCls.ClassID);    -- 해당 아이템이 해당컬렉션에서 몇개가 들어있는지
			end
			invcount = session.GetInvItemCountByType(itemCls.ClassID); -- 해당 아이템을 인벤에 몇개나 들고 있는지.
			-- 같은 ClassID의 아이템의 개수를 증가시킨다.
			if itemList[itemCls.ClassID] ~= nil then
				itemList[itemCls.ClassID] = itemList[itemCls.ClassID] +1;
			else
				itemList[itemCls.ClassID] = 1;
			end
			-- 모아진 컬렉션 아이템 개수보다 필요한 개수가 많을때
			if itemList[itemCls.ClassID] > collecount then
				-- 해당 아이템 클래스에 카운터가 nil이면 0으로 초기화
				if itemCount[itemCls.ClassID] == nil then
					itemCount[itemCls.ClassID]  = 0;
				end
				-- 인벤개수 - 카운터가 0보다 크면 실제 총 필요개수를 증가하고, 사용의 의미로 해당 카운터는 증가
				if invcount - itemCount[itemCls.ClassID] > 0 then
					numCnt = numCnt +1;
					itemCount[itemCls.ClassID]  = itemCount[itemCls.ClassID] +1;
				end
			end
		end
	end

	if IsReinfoCol == 1 and coll ~= nil then
				for i = 1 , maxCount do
					local itemName = TryGetProp(cls,"ItemName_" .. i, 'None');
						local itemCls = GetClass("Item", itemName);
			local reinforce = TryGetProp(cls, 'Reinforce_' .. i, 0) -- 요구 강화
						local collecount = 1
						if coll ~= nil then
							collecount = coll:GetItemCountByType(itemCls.ClassID);    -- 해당 아이템이 해당컬렉션에서 몇개가 들어있는지											
						end
			if reinf_item_list == nil then
				make_collection_item_info_list()
				make_reinf_item_list()
					end					
			if collecount == 0 and reinf_item_list[itemName] ~= nil and reinf_item_list[itemName][reinforce] ~= nil then				
				numCnt = numCnt + reinf_item_list[itemName][reinforce]
				end
			end
		end
	return numCnt; -- 몇개 등록할 수 있는지 개수
end

function SET_COLLECTION_SET(frame, ctrlSet, type, coll, posY)
	local oldPosY = posY;

	-- 컨트롤을 입력하고 y값을 리턴함.
	ctrlSet:SetUserValue("COLLECTION_TYPE", type);
	local cls = GetClassByType("Collection", type);

	local isUnknown = coll == nil;
	-- 컬렉션의 기본 스킨을 설정한다.
	if isUnknown == false then -- 미확인된 컬렉션이 아닐때
		ctrlSet:SetSkinName(frame:GetUserConfig("ENABLE_SKIN"));
	else -- 미확인된 컬렉션일 때
		ctrlSet:SetSkinName(frame:GetUserConfig("DISABLE_SKIN"));
	end

	-- 카운트를 설정한다.
	local collec_count = GET_CHILD(ctrlSet, "collec_count", "ui::CRichText");
	local curCount, maxCount = GET_COLLECTION_COUNT(type, coll);
	collec_count:SetTextByKey("curcount", curCount);
	collec_count:SetTextByKey("maxcount", maxCount);
	if isUnknown == true then --미확인이면 보여주지않음
		collec_count:ShowWindow(0);
	end

	-- 아이콘을 설정한다
	local collec_num = GET_CHILD(ctrlSet, "collec_num", "ui::CRichText"); -- numicon_pic위에 그려질 숫자.
	local numicon_pic = GET_CHILD(ctrlSet, "numicon", "ui::CPicture");
	local newicon_pic = GET_CHILD(ctrlSet, "newicon", "ui::CPicture");
	local compicon_pic = GET_CHILD(ctrlSet, "compicon", "ui::CPicture");
	local gbox_complete = GET_CHILD(ctrlSet, "gb_complete", "ui::CGroupBox");  -- 완료시 테두리용

	-- 컬렉션 이름을 설정한다.
	local collec_name = GET_CHILD(ctrlSet, "collec_name", "ui::CRichText");
	local replaceName =  cls.Name;
	replaceName = string.gsub(replaceName, ClMsg("CollectionReplace"), ""); -- "컬렉션:" 을 공백으로 치환한다.
	-- 이름을 아래에서 설정. 완료/미확인/미완료시에 각각 텍스트가 틀림

	---- 우선 전부 hide
	newicon_pic:ShowWindow(0);
	compicon_pic:ShowWindow(0);
	numicon_pic:ShowWindow(0);
	collec_num:ShowWindow(0);
	gbox_complete:ShowWindow(0);

	-- 읽음 확인용 etcObj
	etcObj = GetMyEtcObject();
	local isread = TryGetProp(etcObj, 'CollectionRead_' .. cls.ClassID);
	local collectionNameFont = nil;
	local visibleAddNumFont = nil;
	local visibleAddNum = false;
	if isUnknown == false then -- 미확인된 컬렉션이 아닐때
		collectionNameFont = frame:GetUserConfig("ENABLE_DECK_TITLE_FONT");
		if curCount >= maxCount then	-- 컴플리트
			compicon_pic:ShowWindow(1);
			gbox_complete:ShowWindow(1);
			collectionNameFont = frame:GetUserConfig("COMPLETE_DECK_TITLE_FONT");	
		elseif isread == nil or isread == 0 then	-- 읽지 않음(new) etcObj의 항목에 1이 들어있으면 읽었다는 뜻.
			newicon_pic:ShowWindow(1);
		else -- 숫자표시 가능
			visibleAddNum = true;
			visibleAddNumFont = frame:GetUserConfig("ENABLE_DECK_NUM_FONT"); 
		end
	else -- 미확인일때 이름 설정
		collectionNameFont = frame:GetUserConfig("DISABLE_DECK_TITLE_FONT");
		visibleAddNumFont = frame:GetUserConfig("DISABLE_DECK_NUM_FONT"); 
		numicon_pic:SetColorTone(frame:GetUserConfig("NOT_HAVE_COLOR")); -- 비활성 컬러톤 설정
		visibleAddNum = true;
	end

	-- 등록가능 숫자 표시
	if visibleAddNum == true then
		local numCnt = 0		
		numCnt= GET_COLLECT_ABLE_ITEM_COUNT(coll,type);
		-- cnt가 0보다 크면 num아이콘활성화
		if numCnt > 0 then
			if visibleAddNumFont ~= nil then
				collec_num:SetTextByKey("value", visibleAddNumFont .. numCnt .. "{/}");
			else
				collec_num:SetTextByKey("value", numCnt);
			end
			collec_num:ShowWindow(1);
			numicon_pic:ShowWindow(1);
		end
	end

	-- 컬렉션 이름 설정
	if collectionNameFont ~= nil then
		collec_name:SetTextByKey("name", collectionNameFont .. replaceName .. "{/}");	
	else 
		collec_name:SetTextByKey("name", replaceName);	
	end

	-- 이름을기준으로 현재 y위치를 구함.
	local curPosY = ctrlSet:GetOriginalY() + collec_name:GetY() + collec_name:GetHeight();
	
	local gbox_magic = GET_CHILD(ctrlSet, "gb_magic", "ui::CGroupBox");
	local img_btn_magic = GET_CHILD(gbox_magic, "iconMagic", "ui::CPicture");			-- 효과 버튼 이미지
	local txt_btn_magic = GET_CHILD(img_btn_magic, "richMagic", "ui::CRichText");		-- 효과 버튼 텍스트
	local txtmagic = GET_CHILD(gbox_magic, "magicList", "ui::CRichText");				-- 효과 내용 텍스트
	
	-- 효과를 기입한다. (이작업으로 height가 변할수있다)
	local desc = GET_COLLECTION_MAGIC_DESC(type);
	local desc_font = nil;
	local magic_font = nil;
	if isUnknown == true then -- 미확인 폰트
		desc_font = frame:GetUserConfig("DISABLE_MAGIC_LIST_FONT");
		magic_font = frame:GetUserConfig("DISABLE_MAGIC_FONT");
		img_btn_magic:SetColorTone(frame:GetUserConfig("NOT_HAVE_COLOR")); -- 효과 버튼 이미지 컬러톤 설정
	else -- 확인 폰트
		desc_font = frame:GetUserConfig("ENABLE_MAGIC_LIST_FONT")
		magic_font = frame:GetUserConfig("ENABLE_MAGIC_FONT");
	end

	-- 효과 버튼 텍스트 입력
	if magic_font ~= nil then
		txt_btn_magic:SetTextByKey("value", magic_font .. ClMsg("CollectionMagicText") .. "{/}");
	else
		txt_btn_magic:SetTextByKey("value", ClMsg("CollectionMagicText"));
	end
	
	-- 효과 입력
	if desc_font ~= nil then
		txtmagic:SetTextByKey("value", desc_font .. desc .. "{/}");
	else 
		txtmagic:SetTextByKey("value", desc);
	end

	-- 텍스트의 높이를 가져온다
	local txtHeight = txtmagic:GetHeight();
	
	-- gbox의 높이를 텍스트높이로 변경한다.
	gbox_magic:Resize(gbox_magic:GetWidth(),txtHeight);

	-- 현재 y위치를 갱신
	curPosY = curPosY + gbox_magic:GetHeight();
	
	-- 아이템이 들어갈 gb_times의 위치와 크기를 변경한다
	local gbox_items = GET_CHILD(ctrlSet, "gb_items", "ui::CGroupBox");
	
	-- Detial 갱신
	curPosY = DETAIL_UPDATE(frame, coll, gbox_items ,type, curPosY ,isUnknown);

	-- ctrlset 크기 조절
	local newposY = posY + ctrlSet:GetHeight() + 10;
	local ctrlsetHeight = math.max(newposY - oldPosY, gbox_magic:GetY() + txtmagic:GetHeight() + 15);	
	newposY = posY + ctrlsetHeight;
	ctrlSet:Resize(ctrlSet:GetWidth(), ctrlsetHeight);

	--마지막으로 컨트롤셋과 gbox_collection의 크기조절
	local gbox_collection = GET_CHILD(ctrlSet,"gb_collection","ui::CGroupBox");	
	gbox_collection:Resize(gbox_collection:GetWidth(), ctrlSet:GetOriginalHeight()); -- 이위치에서 리사이즈해야한다. 디테일뷰가 켜지면 그안에 +버튼을 눌러야하니까 히트는 나머지영역만으로 제한
	curPosY = curPosY + gbox_items:GetHeight() + tonumber(frame:GetUserConfig("SLOT_BOTTOM_MARGIN"));
	gbox_complete:Resize(ctrlSet:GetWidth(), ctrlsetHeight);

	-- 선택된 경우 하단부 커져야 해	
	if frame:GetUserIValue('DETAIL_VIEW_TYPE') == type then		
		ctrlsetHeight = ctrlsetHeight + gbox_items:GetHeight();
		ctrlSet:Resize(ctrlSet:GetWidth(), ctrlsetHeight);
		gbox_complete:Resize(ctrlSet:GetWidth(), ctrlsetHeight);
		newposY = newposY + gbox_items:GetHeight();
	end
	
	-- 리턴할 때는 y위치를 갱신해서.
	return newposY;
end

function UPDATE_COLLECTION_LIST(frame, addType, removeType, target_cls)	
	-- frame이 활성중이 아니면 return
	if frame:IsVisible() == 0 then
		return;
	end
	
	-- collection gbox
	local gbox_collection = GET_CHILD_RECURSIVELY(frame, "collection_bg", "ui::CGroupBox");
	if gbox_collection == nil then
		return;
	end
	
	-- check box
	local gbox_status = GET_CHILD_RECURSIVELY(frame, "status_bg", "ui::CGroupBox");
	if gbox_status == nil then
		return;
	end
	
	-- 컬렉션 상태 Check
	local check_complete = GET_CHILD(gbox_status, "complete_check", "ui::CCheckBox");
	local check_unknown = GET_CHILD(gbox_status, "unknown_check", "ui::CCheckBox");
	local check_incomplete = GET_CHILD(gbox_status, "incomplete_check", "ui::CCheckBox");
	if check_complete == nil or check_unknown == nil or check_incomplete == nil then
		return ;
	end
	
	check_complete:SetCheck(BOOLEAN_TO_NUMBER(collectionViewOptions.showCompleteCollections));
	check_unknown:SetCheck(BOOLEAN_TO_NUMBER(collectionViewOptions.showUnknownCollections));
	check_incomplete:SetCheck(BOOLEAN_TO_NUMBER(collectionViewOptions.showIncompleteCollections));

	-- 초기화 : 그룹박스내의 DECK_로 시작하는 항목들을 제거
	DESTROY_CHILD_BYNAME(gbox_collection, 'DECK_');

	-- 컬렉션 VIEW 카운터 초기화
	collectionViewCount.showCompleteCollections = 0 ;
	collectionViewCount.showUnknownCollections = 0 ;
	collectionViewCount.showIncompleteCollections = 0;

	-- 컬렉션 정보를 만듬
	local pc = session.GetMySession();
	local collectionList = pc:GetCollection();
	local collectionClassList, collectionClassCount= GetClassList("Collection");
	local searchText = GET_COLLECTION_SEARCH_TEXT(frame);
	local etcObject = GetMyEtcObject();

	-- 보여줄 컬렉션 리스트를 만듬
	local collectionCompleteMagicList ={}; -- 완료된 총 효과 리스트.
	local collectionInfoList = {};
	local collectionInfoIndex = 1;
	for i = 0, collectionClassCount - 1 do
		local collectionClass = GetClassByIndexFromList(collectionClassList, i);
		local collection = collectionList:Get(collectionClass.ClassID);
		local collectionInfo = GET_COLLECTION_INFO(collectionClass, collection,etcObject, collectionCompleteMagicList);
		if CHECK_COLLECTION_INFO_FILTER(collectionInfo, searchText, collectionClass, collection) == true then
		    if collectionClass.Journal == 'TRUE' then
				collectionInfoList[collectionInfoIndex] = { cls = collectionClass, coll = collection, info = collectionInfo };
    			collectionInfoIndex = collectionInfoIndex +1;
    		end
		end
	end
	-- 컬렉션 효과 목록을 날려줌 :활성화되어 있지 않다면 그냥반환.
	SET_COLLECTION_MAIGC_LIST(frame, collectionCompleteMagicList, collectionViewCount.showCompleteCollections);
	
	-- 컬렉션 상태 카운터 적용
	check_complete:SetTextByKey("value", collectionViewCount.showCompleteCollections);
	check_unknown:SetTextByKey("value", collectionViewCount.showUnknownCollections);
	check_incomplete:SetTextByKey("value", collectionViewCount.showIncompleteCollections);

	-- sort option 적용
	if collectionViewOptions.sortType == collectionSortTypes.name then
		table.sort(collectionInfoList, SORT_COLLECTION_BY_NAME);
	elseif collectionViewOptions.sortType == collectionSortTypes.status then
		table.sort(collectionInfoList, SORT_COLLECTION_BY_STATUS);
	end
	
	-- 컬렉션 항목 입력
	local pos_y = 0;
	for i, v in pairs(collectionInfoList) do
		local ctrl_set = gbox_collection:CreateOrGetControlSet("new_collection_deck", "DECK_"..i, 10, pos_y);
		if ctrl_set ~= nil then
			ctrl_set:SetUserValue("type", v.cls.ClassID);
			ctrl_set:ShowWindow(1);
			pos_y = SET_NEW_COLLECTION_SET(frame, ctrl_set, v.cls.ClassID, v.coll, pos_y);
			pos_y = pos_y - tonumber(frame:GetUserConfig("DECK_SPACE")); -- 가까이 붙이기 위해 좀더 위쪽으로땡김
		end
	end

	if addType ~= "UNEQUIP" and REMOVE_ITEM_SKILL ~= 7 then
		imcSound.PlaySoundEvent("quest_ui_alarm_2");
	end
end

-- 컬렉션 view를 카운트하고 필터도 검사한다.
function CHECK_COLLECTION_INFO_FILTER(collectionInfo, searchText, collectionClass, collection, is_view_all_status)
	local frame = ui.GetFrame("collection");
	if frame == nil then return; end
	if is_view_all_status == nil then is_view_all_status = false; end
	local category_idx = frame:GetUserIValue("CATEGORY_IDX");
	local category_type = tonumber(collectionInfo.categoryType);
	if is_view_all_status == false and category_idx ~= category_type then
		return false;
	end
	-- view counter
	local checkOption = 0;
	if collectionInfo.view == collectionView.isUnknown then	
		-- 미확인
		if collectionClass.Journal == 'TRUE' then
			collectionViewCount.showUnknownCollections = collectionViewCount.showUnknownCollections +1;
		end
		checkOption = 1;
	elseif collectionInfo.view == collectionView.isComplete then 
		-- 완성
		collectionViewCount.showCompleteCollections = collectionViewCount.showCompleteCollections +1;
		checkOption = 2;
	else
		-- 미완성
		if collectionClass.Journal == 'TRUE' then
			collectionViewCount.showIncompleteCollections = collectionViewCount.showIncompleteCollections +1;
		end
		checkOption = 3;
	end
	-- option filter
		-- unknown
	if collectionViewOptions.showUnknownCollections == false and  checkOption == 1 then
		return false;
	end
		-- complete
	if collectionViewOptions.showCompleteCollections == false and  checkOption == 2 then
		return false;
	end
		-- incomplete
	if collectionViewOptions.showIncompleteCollections == false and  checkOption == 3 then
		return false;
	end
	-- text filter
		-- 검색문자열이 없거나 길이가 0이면 true리턴
	if searchText == nil or string.len(searchText) == 0 then
		return true;
	end
	-- 컬렉션 이름을 가져온다
	local collectionName = collectionInfo.name;
	collectionName = dic.getTranslatedStr(collectionName)
	collectionName = string.lower(collectionName); -- 소문자로 변경
	-- 컬렉션 효과에서도 필터링한다.
	local desc = GET_COLLECTION_MAGIC_DESC(collectionClass.ClassID);
	desc = dic.getTranslatedStr(desc)
	desc = string.lower(desc); -- 소문자로 변경
	-- 검색문자열 검색해서 nil이면 false
	if string.find(collectionName, searchText) == nil and string.find(desc, searchText) == nil then
		 return false;
	end 
	return true;
end

function OPEN_DECK_DETAIL(parent, ctrl)
	local topFrame = parent:GetTopParentFrame();
	if topFrame:GetName() == 'adventure_book' then
		ADVENTURE_BOOK_COLLECTION_DETAIL(parent, ctrl);
		return;
	end

	imcSound.PlaySoundEvent('cllection_inven_open');
	local type = parent:GetUserValue("COLLECTION_TYPE");
	local cls = GetClassByType("Collection", type);
	local frame = parent:GetTopParentFrame();
	if frame == nil then
	 return 
	end

	local is_dress_room = parent:GetUserIValue("is_dress_room");
	if is_dress_room == 1 then
		if cls == nil then cls = GetClassByType("dress_room_reward", type); end
		if cls ~= nil then
			local cur_deatil_collection_type = frame:GetUserIValue("DETAIL_VIEW_TYPE");
			if cur_deatil_collection_type == cls.ClassID then
				frame:SetUserValue("DETAIL_VIEW_TYPE", nil);
			else
				frame:SetUserValue("DETAIL_VIEW_TYPE", cls.ClassID);
				local acc_obj = GetMyAccountObj();
				if acc_obj ~= nil then
					local thema = TryGetProp(cls, "ClassName", "None");
					if TryGetProp(acc_obj, thema) ~= 0 then
						local is_read = TryGetProp(acc_obj, "CollectionDressRoomRead_"..cls.ClassID);
						if is_read == nil or is_read == 0 then
							local scpString = string.format("/readcostumecollection %d", type);
							ui.Chat(scpString);
						end
					end
				end
			end
		else
			frame:SetUserValue("DETAIL_VIEW_TYPE", nil);
		end
		UPDATE_COSTUME_COLLECTION_LIST(frame, nil, nil, cls);
	else
	if cls ~= nil then
		local curDetailCollectionType = frame:GetUserIValue("DETAIL_VIEW_TYPE");
		if curDetailCollectionType ~= cls.ClassID then
			-- DetailView를 설정
			frame:SetUserValue("DETAIL_VIEW_TYPE", cls.ClassID);
			
			local pc = session.GetMySession();
			local collectionList = pc:GetCollection();
			local coll = collectionList:Get(cls.ClassID);

			-- 컬렉션이 등록되어있을때만.
			if coll ~= nil then 
				-- 오픈된다면 확인하기위해 누른것임. 여기서 확인처리
				etcObj = GetMyEtcObject();
				local isread = TryGetProp(etcObj,"CollectionRead_" .. cls.ClassID);
				if isread == nil or isread == 0 then -- 한번이라도 읽은 컬렉션은 new 표시 안생기도록.
					local scpString = string.format("/readcollection %d", type);
					ui.Chat(scpString);
				end
			end
		else
			frame:SetUserValue("DETAIL_VIEW_TYPE", nil);
		end
	else
			frame:SetUserValue("DETAIL_VIEW_TYPE", nil);
	end
	UPDATE_COLLECTION_LIST(frame, nil, nil, cls);
end
end

function ATTACH_TEXT_TO_OBJECT(ctrl, objName, text, x, y, width, height, alignX, alignY, enableFixWIdth, textAlignX, textAlignY, textOmitByWidth)
	local title = ctrl:CreateControl('richtext', objName, x, y, width, height);
	title = tolua.cast(title, "ui::CRichText");
	title:SetGravity(alignX, alignY);
	title:EnableResizeByText(1);
	if textOmitByWidth ~= nil then
		title:EnableTextOmitByWidth(textOmitByWidth);
	end

	if enableFixWIdth ~= nil then
		title:SetTextFixWidth(enableFixWIdth);
	end

	if textAlignX ~= nil then
		title:SetTextAlign(textAlignX, textAlignY);
	end

	title:SetText(text);
	
	if enableFixWIdth ~= nil then
		if (ctrl:GetWidth() < title:GetTextWidth()) then		
			title:SetTextFixWidth(1);
			title:SetTextMaxWidth(title:GetTextWidth() - 40);

			ctrl:Resize(ctrl:GetWidth(), title:GetLineCount() * 34);
			return (y + ctrl:GetHeight()), title;
		end
	end

	return (y + title:GetHeight()), title;
end

function GET_COLLECTION_MAGIC_DESC(type)
	local info = geCollectionTable.Get(type);
	local ret = "";
	local propCnt = info:GetPropCount();
	local isAccountColl = false;
	if 0 == propCnt then
		 propCnt = info:GetAccPropCount();
		isAccountColl = true;
	end

	for i = 0 , propCnt - 1 do
		
		local prop = nil;
		if false == isAccountColl then
			prop = info:GetProp(i);
		else
			prop = info:GetAccProp(i);
		end

		if i >= 1 then
			ret = ret .. "{nl}";
		end

		if nil ~= prop then
		if prop.value > 0 then
			ret = ret ..  string.format("%s +%d", ClMsg(prop:GetPropName()), prop.value);
		elseif prop.value == 0 then
			ret = ret ..  string.format("%s", ClMsg(prop:GetPropName()), prop.value);
		else
			ret = ret ..  string.format("%s %d", ClMsg(prop:GetPropName()), prop.value);
		end
	end
	end
	local cls = GetClassByType('Collection', type)
	local itemList = TryGetProp(cls, 'AccGiveItemList', 'None')
	if itemList ~= 'None' then
	    local itemList = SCR_STRING_CUT(itemList)
	    local aObj = GetMyAccountObj()
	    if aObj[itemList[1]] < itemList[2] then
	        local count = itemList[2] - aObj[itemList[1]]
    	    if #itemList >= 4 then
    			ret = ret .. "{nl}"..ScpArgMsg('COLLECTION_REWARD_ITEM_MSG1','COUNT',count)..'{nl}'
    	        for i = 2, #itemList/2 do
    	            local item = GetClassString('Item',itemList[i*2 - 1],'Name')
    	            ret = ret..ScpArgMsg('COLLECTION_REWARD_ITEM_MSG2','ITEM',item,'COUNT',itemList[i*2])
    	        end
    	    end
    	end
	end
	return ret;
end

-- draw detail 
function DETAIL_UPDATE(frame, coll, detailView ,type, posY ,playEffect, isUnknown)

	-- 디테일뷰가 있을지 모르니까 지운다.
	DESTROY_CHILD_BYNAME(detailView, 'SLOT_');
	
	-- 액티브상태면 디테일뷰를 그린다.
	local topParentFrame = detailView:GetTopParentFrame()
	local curDetailCollectionType = frame:GetUserIValue("DETAIL_VIEW_TYPE");
	if curDetailCollectionType == type and topParentFrame:GetName() ~= 'adventure_book' then
		local curCount, maxCount = GET_COLLECTION_COUNT(type, coll);

		posY = posY + frame:GetUserConfig("MAGIC_DETAIL_MARGIN"); -- 효과텍스트랑 붙어있는 공간을 띄운다.

		-- 디테일 뷰에 그려질 라인을 구한다.
		local lineCnt = math.ceil(maxCount / 7); -- 첫째자리에서 올림한다.
		-- 뷰의 크기를 결정한다
		detailView:Resize(detailView:GetWidth(),math.floor(detailView:GetHeight() * lineCnt));
		detailView:ShowWindow(1);

		-- 엑티브설정된 타입과 같으니 DETAILVIEW를 만들어줌
		local cls = GetClassByType("Collection", type);

		local marginX =  frame:GetUserConfig("DETAIL_MARGIN_X");  -- 첫번째 그림이 시작되는위치. 계산으로 해야하지만 우선 10으로
		local marginY  = frame:GetUserConfig("DETAIL_MARGIN_Y");  -- 천장과의 간격
		local boxWidth = detailView:GetWidth() - (marginX * 2);   -- 박스의 넓이 : 뷰의 넓이에서 양쪽 마진을빼줌.
		local picInBox = frame:GetUserConfig("DETAIL_ITEM_COUNT");  -- 한줄에 들어가는 아이템수        (콘피그로빼자)
		local space  = frame:GetUserConfig("DETAIL_ITEM_SPACE");   -- 아이템과 아이템사이의 X축 간격
		local slotWidth =  math.floor( (boxWidth / picInBox) - (space*2)); -- 슬롯한개의 넓이
		local slotHeight = slotWidth; -- 슬롯한개의 높이
		
		local num = 1;
		local brk = 0;
		local drawitemset = {}
		for i = 1 , lineCnt do -- 
			for j= 1, 7 do -- 1줄에 7개그림
				local itemName = TryGetProp(cls,"ItemName_" .. num);
				local reinforce = TryGetProp(cls, 'Reinforce_' .. num, 0)
				local IsReinfoCol = TryGetProp(cls, 'IsReinfoCol', 0)
				if itemName == nil or itemName == "None" then
					brk = 1;
					break;
				end
				
				local itemCls = GetClass("Item", itemName);
				local row = i;
				local col = (j - 1)  % picInBox;
				local x = marginX + col * (slotWidth + space);
				local y = marginY + (row - 1) * (slotHeight + space);

				local slotSet = detailView:CreateOrGetControlSet('collection_slot', "SLOT_" .. num, x,y );

				SET_COLLECTION_PIC(j, frame, slotSet, itemCls, coll,type, drawitemset, reinforce, IsReinfoCol);

				num = num+1;
			end -- loop j

			if brk == 1 then
				break;
			end
		end -- loop i
	else
		-- deactive면 슬롯칸을 없앤다.
		detailView:Resize(detailView:GetWidth(),0);
		detailView:ShowWindow(0);
	end

	return posY;
end

-- 검색 텍스트를 가져옴
function GET_COLLECTION_SEARCH_TEXT(frame)
	-- collection search edit
	local searchEdit = GET_CHILD_RECURSIVELY(frame, "collection_search_edit", "ui::CEditBox");
	if searchEdit == nil then
		return;
	end

	local searchText = searchEdit:GetText();
	if searchText ~= nil then
		return string.lower(searchText);
	end
	
	return nil;
end

function EXEC_PUT_COLLECTION(itemID, type, index)	
	session.ResetItemList();
	session.AddItemID(itemID);
	local resultlist = session.GetItemIDList();
	item.DialogTransaction("PUT_COLLECTION", resultlist, type .. ' ' .. index);
	imcSound.PlaySoundEvent("cllection_weapon_epuip");
end

function COLLECTION_ADD(index, collectionType, itemType, itemIesID)
	if index == nil or collectionType == nil or itemType == nil or itemIesID == nil then
		return;
	end
	
	local inv_item = session.GetInvItemByGuid(itemIesID)
	local item_obj = GetIES(inv_item:GetObject())
	local groupName = TryGetProp(item_obj, "GroupName", "None");
	if groupName=='Gem' then 		
		local belonging = TryGetProp(item_obj, "CharacterBelonging", 0);
		if tonumber(belonging)==1 then
			ui.SysMsg(ClMsg('AddDenied'));	
			return
		end

		if IS_RANDOM_OPTION_SKILL_GEM(item_obj) == true then
			ui.SysMsg(ClMsg('CantUseCabinetCuzRandomOption'));				
			return
		end
	end
	
	local cls = GetClassByType('Collection', collectionType)	
	local reinforce = TryGetProp(cls, 'Reinforce_' .. index, 0)
	if reinforce > 0 then
		if TryGetProp(item_obj, 'Reinforce_2', 0) ~= reinforce then
			return
		end
	end

	local is_costume_collection = false;
	if cls == nil then
		local dress_room_cls = GetClassByType("dress_room_reward", collectionType);
		if dress_room_cls ~= nil then
			cls = dress_room_cls;
			is_costume_collection = true;
		end
	end

	if is_costume_collection == false then
	local colls = session.GetMySession():GetCollection();
	local coll = colls:Get(collectionType);
	local nowcnt = coll:GetItemCountByType(itemType)
	local colinfo = geCollectionTable.Get(collectionType);
		local needcnt = colinfo:GetNeedItemCount(itemType);
	if nowcnt < needcnt then
		imcSound.PlaySoundEvent('sys_popup_open_1');
		local yesScp = string.format("EXEC_PUT_COLLECTION(\"%s\", %d, %d)", itemIesID, collectionType, index);
		ui.MsgBox(ScpArgMsg("CollectionIsSharedToTeamAndCantTakeBackItem_Continue?"), yesScp, "None");
	end
	else
		local item_class_name = TryGetProp(item_obj, "ClassName", "None");
		local reward_cls = GetClassByStrProp("dress_room", "ItemClassName", item_class_name);
		if config.GetServiceNation() == 'PAPAYA' then reward_cls = GetClassByStrProp("dress_room_papaya", "ItemClassName", item_class_name); end
		if reward_cls ~= nil then
			local reward_cls_id = TryGetProp(reward_cls, "ClassID", 0);
			local frame = ui.GetFrame("collection");
			if frame ~= nil then
				frame:SetUserValue("DRESS_ITEM_IES_ID", itemIesID);
				frame:SetUserValue("DRESS_CLS_ID", reward_cls_id);
				local is_enable, msg_text = IS_REGISTER_ENABLE_COSTUME(item_obj);
				if is_enable == false and msg_text ~= nil then
					ui.SysMsg(ClMsg(msg_text));
					return;
				end
				if item_obj ~= nil then
					local item_name = TryGetProp(item_obj, "Name", "None"); 
					local msg = ScpArgMsg("ReallyRegisterCostume{item}", "item", dic.getTranslatedStr(item_name));
					local yes_scp = "SCR_NEW_COSTUME_COLLECTION_REGISTER()";
					local msgbox = ui.MsgBox(msg, yes_scp, "None");
					SET_MODAL_MSGBOX(msgbox);
				end
			end
		end
	end
end

-- + 버튼을 눌러서 등록
function COLLECTION_TAKE(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	if frame == nil then
		return; 
	end

	local slot = GET_CHILD(parent, "slot", "ui::CSlot");
	if slot == nil then
		return;
	end
	
	local collectionType = slot:GetUserIValue("COLLECTION_TYPE");
	local reinforce = slot:GetUserIValue("Reinforce");	
	local index = slot:GetUserIValue('index')		
	local icon = slot:GetIcon();
	local itemType = icon:GetTooltipIESID(); -- icon에 입력된 클래스 ID를 가져옴(문자열)
	local iesID = 0;
	if reinforce == 0 then
		-- 가장 가치가 없는 아이템을 가져옴.
		local invItemlist = GET_ONLY_PURE_INVITEMLIST(tonumber(itemType));
		if #invItemlist < 1 or invItemlist == nil then
			return;
		end
		iesID = invItemlist[1]:GetIESID();	
	else
		local cls = GetClassByType('Item', itemType)
		local ret_list = get_inv_itemlist_by_name_and_reinforce(cls.ClassName, reinforce)
		if #ret_list == 0 then
			return;
		end
		iesID = GetIESID(ret_list[1])
	end
	COLLECTION_ADD(index, collectionType,itemType,iesID);
end

-- 아이템 드롭으로 등록
function COLLECTION_DROP(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	if frame == nil then
	 return 
	end

	local slot = GET_CHILD(parent, "slot", "ui::CSlot");
	if slot == nil then
		return 
	end

	local liftIcon = ui.GetLiftIcon():GetInfo();
	local iesID = liftIcon:GetIESID();
	local itemType = liftIcon.type;
	local collectionType = slot:GetUserIValue("COLLECTION_TYPE");
	local reinforce = slot:GetUserIValue("Reinforce");
	local index = slot:GetUserIValue('index')

	COLLECTION_ADD(index, collectionType,itemType,iesID);
end

function SEARCH_COLLECTION_NAME(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	if frame == nil then
	 return 
	end
	local tab_index = frame:GetUserIValue("CATEGORY_IDX");
	if tab_index ~= 2 then
	UPDATE_COLLECTION_LIST(frame);
	else
		UPDATE_COSTUME_COLLECTION_LIST(frame);
	end
end

-- 옵션체크
function UPDATE_COLLECTION_OPTION(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	if frame == nil then
		return;
	end
	
	-- check box
	local gbox_status = GET_CHILD_RECURSIVELY(frame, "status_bg", "ui::CGroupBox");
	if gbox_status == nil then
		return;
	end

	local chkComplete = GET_CHILD(gbox_status, "complete_check", "ui::CCheckBox");
	local chkUnknown = GET_CHILD(gbox_status, "unknown_check", "ui::CCheckBox");
	local chkIncomplete = GET_CHILD(gbox_status, "incomplete_check", "ui::CCheckBox");
	if chkComplete == nil or chkUnknown == nil or chkIncomplete == nil then
		return ;
	end

	collectionViewOptions.showCompleteCollections = NUMBER_TO_BOOLEAN(chkComplete:IsChecked());
	collectionViewOptions.showUnknownCollections = NUMBER_TO_BOOLEAN(chkUnknown:IsChecked());
	collectionViewOptions.showIncompleteCollections = NUMBER_TO_BOOLEAN(chkIncomplete:IsChecked());

	local tab_index = frame:GetUserIValue("CATEGORY_IDX");
	if tab_index ~= 2 then
	UPDATE_COLLECTION_LIST(frame);
	else
		UPDATE_COSTUME_COLLECTION_LIST(frame);
	end
end

-- 검색중 엔터누르면 갱신
function SEARCH_COLLECTION_ENTER(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	if frame == nil then
	 	return;
	end
	local tab_index = frame:GetUserIValue("CATEGORY_IDX");
	if tab_index ~= 2 then
	UPDATE_COLLECTION_LIST(frame);
	else
		UPDATE_COSTUME_COLLECTION_LIST(frame);
	end
end

function BOOLEAN_TO_NUMBER(value)
	if value == true then
	   return 1;
	end
	return 0;
end

function NUMBER_TO_BOOLEAN(value)
	if value == 0 or value == nil then
	   return false;
	end
	return true;
end

function SORT_COLLECTION_BY_STATUS(a, b)
	local aStatus = a.info.status;
	local bStatus = b.info.status;

	if aStatus ~= bStatus then
		return aStatus > bStatus;
	end

	-- status 비교후 view 상태 비교
	local aView = a.info.view;
	local bView = b.info.view;
	
	if aView ~= bView then
		return aView > bView;
	end 

	--view 상태 비교 후 이름비교
	local aName = a.info.name;
	local bName = b.info.name;

	return aName < bName;
end

function SORT_COLLECTION_BY_NAME(a,b)
	local aName = a.info.name;
	local bName = b.info.name;

	return aName < bName;
end

-- 컬렉션 정보를 리턴.
function GET_COLLECTION_INFO(collectionClass, collection, etcObject, collectionCompleteMagicList)
	-- view 
	local curCount, maxCount = GET_COLLECTION_COUNT(collectionClass.ClassID, collection);
	local collView = collectionView.isIncomplete;
	if collection == nil then
		collView = collectionView.isUnknown;
	elseif curCount >= maxCount then 
		collView = collectionView.isComplete;
	end
	-- status
	local cls = GetClassByType("Collection", collectionClass.ClassID);	
	local class_id = TryGetProp(cls, "ClassID", 0);
	local isread = TryGetProp(etcObject, 'CollectionRead_'..class_id);
	local addNumCnt= GET_COLLECT_ABLE_ITEM_COUNT(collection,collectionClass.ClassID);
	local collStatus = collectionStatus.isNormal;
	if curCount >= maxCount then	
		-- 컴플리트
		collStatus = collectionStatus.isComplete;
		-- complete 상태면 magicList에 추가해줌.
		ADD_MAGIC_LIST(collectionClass.ClassID, collection, collectionCompleteMagicList, false);
	elseif isread == nil or isread == 0 then	
		-- 읽지 않음(new) etcObj의 항목에 1이 들어있으면 읽었다는 뜻.		
		if collection ~= nil then -- 미확인 상태가 아닐때만 new를 입력
			collStatus = collectionStatus.isNew;
		end
	end
	-- 위에 new/complete를 체크했는데 기본값이며 추가가능한지 확인. 이렇게 안하면 미확인에서 정렬 제대로 안됨.
	if collStatus == collectionStatus.isNormal then
		-- cnt가 0보다 크면 num아이콘활성화
		if addNumCnt > 0 then
			collStatus = collectionStatus.isAddAble;
		end
	end
	-- name
	local collectionName = TryGetProp(cls, "Name", "None");
	collectionName = string.gsub(collectionName, ClMsg("CollectionReplace"), ""); -- "컬렉션:" 을 공백으로 치환한다.
	-- category
	local category_type = TryGetProp(cls, "CategoryType", 0);
	return { 
			 name = collectionName,		-- "컬렉션:" 이 제거된 이름
			 status = collStatus,		-- 컬렉션 상태
			 view = collView,			-- 컬랙션 보여주기 상태
			 addNum = addNumCnt,			-- 추가 가능한 아이템 개수.
			 categoryType = category_type 	-- 카테고리 타입.
			};
end

-- 테이블에 효과 목록을 담아준다.
function ADD_MAGIC_LIST(type, collection, collectionCompleteMagicList, is_costume)
	if is_costume == false or is_costume == nil then
	local info = geCollectionTable.Get(type);
	local propCnt = info:GetPropCount();
	local isAccountColl = false;
	if 0 == propCnt then
		 propCnt = info:GetAccPropCount();
		isAccountColl = true;
	end

	for i = 0 , propCnt - 1 do
		local prop = nil;
		if false == isAccountColl then
			prop = info:GetProp(i);
		else
			prop = info:GetAccProp(i);
		end

		if nil ~= prop then
			local propName = ClMsg(prop:GetPropName());
			if collectionCompleteMagicList[propName] == nil then
				collectionCompleteMagicList[propName] = 0 ;
			end

			if prop.value > 0 then
				collectionCompleteMagicList[propName] =  collectionCompleteMagicList[propName] + prop.value;
			elseif prop.value == 0 then
					collectionCompleteMagicList[propName] = collectionCompleteMagicList[propName] + 0;
			else
					collectionCompleteMagicList[propName] = collectionCompleteMagicList[propName] + prop.value;
				end
			end
		end
	else
		ADD_COSTUME_MAGIC_LIST(type, collection, collectionCompleteMagicList); 
	end
end

-- 테이블에 코스튬 효과 목록을 담아준다.
function ADD_COSTUME_MAGIC_LIST(item_table, cls, collection_magic_list)
	if item_table ~= nil and cls ~= nil then
		local account_obj = GetMyAccountObj();
		local thema = TryGetProp(cls, "ClassName", "None");
		local reward_per_piece = TryGetProp(cls, "RewardPerPiece", "NO") == "YES";
		local is_complete = true;
		local piece_count = 0;
		local item_list = item_table[thema];
		for i = 1, #item_list do
			local cls = item_list[i];
			if cls ~= nil then
				if DRESS_ROOM_IS_ITEM_SET(account_obj, cls) == false then
					if reward_per_piece == false then
						is_complete = false;
						break;
					end
				else
					piece_count = piece_count + 1;
				end
			end
		end
		if is_complete == true or (reward_per_piece == true and piece_count > 0) then
			local prop_list = TryGetProp(cls, "PropList", "None");
			local reward = StringSplit(prop_list, ';');
			for i = 1, #reward do
				local value = reward[i];
				local prop = StringSplit(value, '/');
				local prop_name, prop_value = ClMsg(prop[1]), tonumber(prop[2]);
				if collection_magic_list[prop_name] == nil then 
					collection_magic_list[prop_name] = 0;
				end
				if reward_per_piece == true then
					prop_value = prop_value * piece_count;
				end
				collection_magic_list[prop_name] = collection_magic_list[prop_name] + prop_value;
			end
		end
	end
end

-- 총 효과보기 버튼 클릭시.
function VIEW_COLLECTION_ALL_STATUS(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	if frame == nil then
		return; 
	end
	-- 컬렉션 VIEW 카운터 초기화
	collectionViewCount.showCompleteCollections = 0 ;
	collectionViewCount.showUnknownCollections = 0 ;
	collectionViewCount.showIncompleteCollections = 0;
	-- 컬렉션 정보를 만듬
	local pc = session.GetMySession();
	if pc ~= nil then
		local complete_magic_list = {};
		-- collection
		local collection_list = pc:GetCollection();
		local list, cnt = GetClassList("Collection");
		if list ~= nil and cnt > 0 then
			local etc_object = GetMyEtcObject();
			if etc_object ~= nil then
				-- 효과 리스트를 갱신
				for i = 0, cnt - 1 do
					local cls = GetClassByIndexFromList(list, i);
					if cls ~= nil then
						local type = TryGetProp(cls, "ClassID", 0);
						local collection = collection_list:Get(type);
						local collection_info = GET_COLLECTION_INFO(cls, collection, etc_object, complete_magic_list);
						CHECK_COLLECTION_INFO_FILTER(collection_info, "", cls, collection, true);
					end
				end
			end
		end
		-- dress_room
		local item_table = DRESS_ROOM_GET_ITEM_TABLE();
		list, cnt = GetClassList("dress_room_reward");
		if list ~= nil and cnt > 0 then
			local account_obj = GetMyAccountObj();
			if account_obj ~= nil then
				for i = 0, cnt - 1 do
					local collection_cls = GetClassByIndexFromList(list, i);
					if collection_cls ~= nil then
						local class_name = TryGetProp(collection_cls, "ClassName", "None");
						local item_info = item_table[class_name];
						if item_info ~= nil then
							-- cls, acc_obj, item_table, collection_complete_list
							local collection_info = GET_NEW_COSTUME_COLLECTION_INFO(collection_cls, account_obj, item_table, complete_magic_list);
							CHECK_NEW_COSTUME_COLLECTION_INFO_FILETER(collection_info, "", collection_cls, true);
						end
					end
				end
			end
		end
		-- 컬렉션 효과 목록을 날려줌 : 활성화되어 있지 않다면 그냥 반환.
		SET_COLLECTION_ALL_STATUS_VIEW_LIST(frame, complete_magic_list, collectionViewCount.showCompleteCollections);
		-- 컬렉션 효과 목록 오픈.
		COLLECTION_ALL_STATUS_VIEW_OPEN(frame);
	end
end

function SET_NEW_COLLECTION_SET(frame, ctrl_set, type, collection, pos_y)
	if frame == nil or ctrl_set == nil then return 0; end
	ctrl_set:SetUserValue("COLLECTION_TYPE", type);
	local cls = GetClassByType("Collection", type);
	if cls ~= nil then
		-- ctrlset basic skin
		local is_unknown = collection == nil;
		if is_unknown == false then
			ctrl_set:SetSkinName(frame:GetUserConfig("ENABLE_SKIN"));
		else
			ctrl_set:SetSkinName(frame:GetUserConfig("DISABLE_SKIN"));
		end
		-- count
		local cur, max = GET_COLLECTION_COUNT(type, collection);
		local count_text = GET_CHILD_RECURSIVELY(ctrl_set, "collection_count", "ui::CRichText");
		if count_text ~= nil then
			count_text:SetTextByKey("cur", cur);
			count_text:SetTextByKey("max", max);
			if is_unknown == true then
				count_text:ShowWindow(0);
			end
		end
		-- icon
		local text_collection_num = GET_CHILD_RECURSIVELY(ctrl_set, "collection_num", "ui::CRichText");
		local icon_num = GET_CHILD_RECURSIVELY(ctrl_set, "icon_num", "ui::CPicture");
		local icon_new = GET_CHILD_RECURSIVELY(ctrl_set, "icon_new", "ui::CPicture");
		local icon_comp = GET_CHILD_RECURSIVELY(ctrl_set, "icon_comp", "ui::CPicture");
		text_collection_num:ShowWindow(0);
		icon_num:ShowWindow(0);
		icon_new:ShowWindow(0);
		icon_comp:ShowWindow(0);
		-- complete
		local gbox_complete = GET_CHILD_RECURSIVELY(ctrl_set, "gb_complete", "ui::CGroupBox");
		gbox_complete:ShowWindow(0);
		-- read check
		local collection_name = "";
		local name_text = GET_CHILD_RECURSIVELY(ctrl_set, "collection_name", "ui::CRichText");
		local etc_obj = GetMyEtcObject();
		if etc_obj ~= nil then
			local collection_name_font = nil;
			local visible_add_num_font = nil;
			local visible_add_num = false;
			local class_id = TryGetProp(cls, "ClassID", 0);
			if is_unknown == false then
				collection_name_font = frame:GetUserConfig("ENABLE_DECK_TITLE_FONT");
				local is_read = TryGetProp(etc_obj, "CollectionRead_"..class_id);
				if cur >= max then
					-- complete
					icon_comp:ShowWindow(1);
					gbox_complete:ShowWindow(1);
					collection_name_font = frame:GetUserConfig("COMPLETE_DECK_TITLE_FONT");
				elseif is_read == nil or is_read == 0 then
					icon_new:ShowWindow(1);
				else
					visible_add_num = true;
					visible_add_num_font = frame:GetUserConfig("ENABLE_DECK_NUM_FONT");
				end
			else
				icon_num:SetColorTone(frame:GetUserConfig("NOT_HAVE_COLOR"));
				collection_name_font = frame:GetUserConfig("DISABLE_DECK_TITLE_FONT");
				visible_add_num_font = frame:GetUserConfig("DISABLE_DECK_NUM_FONT");
				visible_add_num = true;
			end
			-- registration number
			if visible_add_num == true then
				local registration_num_count = GET_COLLECT_ABLE_ITEM_COUNT(collection, type);
				if registration_num_count > 0 then
					if visible_add_num_font ~= nil then
						text_collection_num:SetTextByKey("value", visible_add_num_font..registration_num_count.."{/}");
					else
						text_collection_num:SetTextByKey("value", visible_add_num_font);
					end
					text_collection_num:ShowWindow(1);
					icon_num:ShowWindow(1);
				end
			end
			-- name
			if name_text ~= nil then
				local replace_name = TryGetProp(cls, "Name", "None");
				if replace_name ~= "None" then replace_name = string.gsub(replace_name, ClMsg("CollectionReplace"), ""); end
				collection_name = replace_name;
				if collection_name_font ~= nil then
					name_text:SetTextByKey("name", collection_name_font..replace_name.."{/}");
				else
					name_text:SetTextByKey("name", replace_name);
				end
			end
		end
		-- detail
		local gbox_detail = GET_CHILD_RECURSIVELY(ctrl_set, "gb_detail", "ui::CGroupBox");
		local icon_detail = GET_CHILD_RECURSIVELY(gbox_detail, "icon_detail", "ui::CPicture");
		local text_detail = GET_CHILD_RECURSIVELY(icon_detail, "text_detail", "ui::CRichText");
		local text_detail_list = GET_CHILD_RECURSIVELY(gbox_detail, "text_detail_list", "ui::CRichText");
		-- detail - font
		local desc_font = nil;
		local detail_font = nil;
		if is_unknown == false then
			desc_font = frame:GetUserConfig("DISABLE_MAGIC_LIST_FONT");
			detail_font = frame:GetUserConfig("DISABLE_MAGIC_FONT");
			icon_detail:SetColorTone(frame:GetUserConfig("NOT_HAVE_COLOR"));
		else
			desc_font = frame:GetUserConfig("ENABLE_MAGIC_LIST_FONT");
			detail_font = frame:GetUserConfig("ENABLE_MAGIC_FONT");
		end
		-- detail - text
		if detail_font ~= nil then
			text_detail:SetTextByKey("value", detail_font..ClMsg("CollectionMagicText").."{/}");
		else
			text_detail:SetTextByKey("value", ClMsg("CollectionMagicText"));
		end
		-- deatil - input
		local desc = GET_COLLECTION_MAGIC_DESC(type);
		if desc_font ~= nil then
			text_detail_list:SetTextByKey("value", desc_font..desc.."{/}");
		else
			text_detail_list:SetTextByKey("value", desc);
		end
		-- deatil - resize
		local text_detail_list_height = text_detail_list:GetHeight();
		gbox_detail:Resize(gbox_detail:GetWidth(), text_detail_list_height);

		-- ctrlset resize
		local old_pos_y = pos_y;
		local cur_pos_y = ctrl_set:GetOriginalY() + name_text:GetY() + name_text:GetHeight();
		cur_pos_y = cur_pos_y + gbox_detail:GetHeight();

		local new_pos_y = pos_y + ctrl_set:GetHeight() + 10;
		local ctrl_set_height = math.max(new_pos_y - old_pos_y, gbox_detail:GetY() + text_detail_list:GetHeight() + 15);
		new_pos_y = pos_y + ctrl_set_height;
		ctrl_set:Resize(ctrl_set:GetWidth(), ctrl_set_height);
		
		-- gbox collection resize
		local gbox_collection = GET_CHILD_RECURSIVELY(ctrl_set, "gb_collection", "ui::CGroupBox");
		if gbox_collection ~= nil then
			gbox_collection:Resize(gbox_collection:GetWidth(), ctrl_set:GetOriginalHeight());
			gbox_complete:Resize(ctrl_set:GetWidth(), ctrl_set_height);
		end
		cur_pos_y = cur_pos_y + tonumber(frame:GetUserConfig("SLOT_BOTTOM_MARGIN"));
		
		-- select
		if frame:GetUserIValue("DETAIL_VIEW_TYPE") == type then
			local gbox_collection_info = GET_CHILD_RECURSIVELY(frame, "collection_info_bg");
			if gbox_collection_info ~= nil then
				local collection_info_detail_pic = GET_CHILD_RECURSIVELY(gbox_collection_info, "collection_info_detail_pic");
				local collection_info_detail_text = GET_CHILD_RECURSIVELY(gbox_collection_info, "collection_info_detail_text");
				local collection_info_detail_list_text = GET_CHILD_RECURSIVELY(gbox_collection_info, "collection_info_detail_list_text");
				collection_info_detail_pic:ShowWindow(1);
				collection_info_detail_text:ShowWindow(1);
				collection_info_detail_list_text:ShowWindow(1);
				SET_NEW_COLLECTION_DETAIL_VIEW(frame, collection, gbox_collection_info, type, desc);
			end
		end
		return new_pos_y;
	end
	return 0;
end

function SET_NEW_COLLECTION_DETAIL_VIEW(frame, collection, gbox_info, type, desc)
	if frame == nil then return; end
	-- detail info title
	local collection_info_detail_text = GET_CHILD_RECURSIVELY(gbox_info, "collection_info_detail_text");
	if collection_info_detail_text ~= nil then
		collection_info_detail_text:SetTextByKey("value", ClMsg("CollectionMagicText"));
	end
	-- deatil info desc
	local collection_info_detail_list_text = GET_CHILD_RECURSIVELY(gbox_info, "collection_info_detail_list_text");
	if collection_info_detail_list_text ~= nil then
		collection_info_detail_list_text:SetTextByKey("value", desc);
	end
	-- detail view
	DESTROY_CHILD_BYNAME(gbox_info, "SLOT_");
	local detail_view_type = frame:GetUserIValue("DETAIL_VIEW_TYPE");
	local enable_detail_view = (detail_view_type == type and frame:GetName() ~= "adventure_book");
	if enable_detail_view == true then
		local cur, max = GET_COLLECTION_COUNT(type, collection);
		local draw_count_limit = frame:GetUserConfig("DETAIL_ITEM_COUNT"); -- detailveiw draw count limit 
		local draw_count = math.ceil(max / draw_count_limit);
		local cls = GetClassByType("Collection", type);
		if cls ~= nil then
			local margin_x = frame:GetUserConfig("DETAIL_MARGIN_X");
			local margin_y = frame:GetUserConfig("DETAIL_MARGIN_Y");
			local space = frame:GetUserConfig("DETAIL_ITEM_SPACE");
			local gbox_width = gbox_info:GetWidth();
			local box_width = gbox_width - (margin_x * 2);
			local slot_width = math.floor((box_width / draw_count_limit) - (space * 2)) + 15;
			local slot_height = slot_width;
			local idx = 1;
			local is_break = 0;
			local draw_item_set = {};
			for i = 1, draw_count_limit do
				for j = 1, draw_count_limit do
					local item_name = TryGetProp(cls, "ItemName_"..idx, "None");
					local reinforce = TryGetProp(cls, "Reinforce_"..idx, 0);
					local is_reinforce_collection = TryGetProp(cls, "IsReinfoCol", 0);
					if item_name == "None" then
						is_break = 1;
						break;
					end
					-- draw item info
					local item_cls = GetClass("Item", item_name);
					if item_cls ~= nil then
						local row = i;
						local col = (j - 1) % draw_count_limit;
						local x = margin_x + col * (slot_width + space);
						local y = margin_y + (row - 1) * (slot_height + space);
						local ctrl_set = gbox_info:CreateOrGetControlSet("collection_slot", "SLOT_"..idx, x, y);
						if ctrl_set ~= nil then
							SET_COLLECTION_PIC(j, frame, ctrl_set, item_cls, collection, type, draw_item_set, reinforce, is_reinforce_collection);
							idx = idx + 1;
						end
					end
					if is_break == 1 then
						break;
					end
				end
			end
		end
	end
end

function SCR_NEW_COLLECTION_DETAIL_VIEW_REMOVE(frame)
	local gbox = GET_CHILD_RECURSIVELY(frame, "collection_info_bg");
	if gbox ~= nil then
		local info_detail_pic = GET_CHILD_RECURSIVELY(frame, "collection_info_detail_pic");
		local info_detail_text = GET_CHILD_RECURSIVELY(frame, "collection_info_detail_text");
		local info_detail_list_text = GET_CHILD_RECURSIVELY(frame, "collection_info_detail_list_text");
		local info_costume_detail_list_text = GET_CHILD_RECURSIVELY(frame, "costume_collection_info_detail_list_text");
		info_detail_pic:ShowWindow(0);
		info_detail_text:ShowWindow(0);
		info_detail_list_text:ShowWindow(0);
		info_costume_detail_list_text:ShowWindow(0);
		DESTROY_CHILD_BYNAME(gbox, "SLOT_");
	end
end

function SCR_NEW_COLLECTION_TAB_CHANGE(frame, ctrl, arg_str, arg_num)
	if frame == nil then return; end
	local top_frame = frame:GetTopParentFrame();
	if top_frame ~= nil then
		local category_tab = GET_CHILD_RECURSIVELY(top_frame, "category_tab", "ui::CTabControl");
		if category_tab ~= nil then
			local idx = category_tab:GetSelectItemIndex();
			top_frame:SetUserValue("CATEGORY_IDX", idx);
			SCR_NEW_COLLECTION_DETAIL_VIEW_REMOVE(top_frame);
			if idx == 2 then
				UPDATE_COSTUME_COLLECTION_LIST(top_frame);
			else
				UPDATE_COLLECTION_LIST(top_frame);
			end
		end
	end
end

function GET_NEW_COSTUME_COLLECTION_INFO(cls, acc_obj, item_table, collection_complete_list)
	if cls == nil or acc_obj == nil or item_table == nil then return; end
	-- view
	local thema = TryGetProp(cls, "ClassName", "None");
	local cur_count = GET_DRESS_ROOM_THEMA_ITEM_NUM(thema, item_table, acc_obj);
	local max_count = #item_table[thema];
	local collection_view = collectionView.isIncomplete; -- 미완성.
	if TryGetProp(acc_obj, thema) == 0 then 
		collection_view = collectionView.isUnknown; -- 미등록.
	elseif cur_count >= max_count then 
		collection_view = collectionView.isComplete; -- 완성.
	end
	-- status
	local class_id = TryGetProp(cls, "ClassID", 0);
	local is_read = TryGetProp(acc_obj, "CollectionDressRoomRead_"..class_id);
	local collection_status = collectionStatus.isNormal;
	if cur_count >= max_count then
		collection_status = collectionStatus.isComplete;
		-- complete 상태라면 magic_list에 추가해줌
		ADD_MAGIC_LIST(item_table, cls, collection_complete_list, true);
	elseif is_read == nil or is_read == 0 then
		if collection_view ~= collectionView.isUnknown then
			collection_status = collectionStatus.isNew;
		end
	end
	-- add able chekc
	local add_num = 0;
	if collection_status == collectionStatus.isNormal then
		local item_list = item_table[thema];
		for i = 1, #item_list do
			local dress_cls = item_list[i];
			if dress_cls ~= nil then
				if DRESS_ROOM_IS_ITEM_SET(acc_obj, dress_cls) == false then
					local item_class_name = TryGetProp(dress_cls, "ItemClassName", "None");
					local item_cls = GetClass("Item", item_class_name);
					if item_cls ~= nil then
						local item_cls_id = TryGetProp(item_cls, "ClassID", 0);
						if session.GetInvItemCountByType(item_cls_id) > 0 then
							add_num = add_num + 1;
						end
					end
				end
			end
		end
		if add_num > 0 then
			collection_status = collectionStatus.isAddAble;
		end
	end
	-- name
	local collection_name = TryGetProp(cls, "Name", "None");
	-- category
	local category_type = TryGetProp(cls, "CategoryType", 0);
	return { 
		name = collection_name,
		status = collection_status,
		view = collection_view,
		addNum = add_num,
		categoryType = category_type
	 };
end

function CHECK_NEW_COSTUME_COLLECTION_INFO_FILETER(collection_info, search_text, collection_cls, is_view_all_status)
	local frame = ui.GetFrame("collection");
	if frame == nil then return; end
	if is_view_all_status == nil then is_view_all_status = false; end
	local category_idx = frame:GetUserIValue("CATEGORY_IDX");
	local category_type = tonumber(collection_info.categoryType);
	if is_view_all_status == false and category_idx ~= category_type then
		return false;
	end
		-- view
		local option = 0;
		if collection_info.view == collectionView.isUnknown then
			collectionViewCount.showUnknownCollections = collectionViewCount.showUnknownCollections + 1;
			option = 1; 
		elseif collection_info.view == collectionView.isComplete then
			collectionViewCount.showCompleteCollections = collectionViewCount.showCompleteCollections + 1;
			option = 2;
		else
			collectionViewCount.showIncompleteCollections = collectionViewCount.showIncompleteCollections + 1;
			option = 3;
		end
		-- option filter
		if collectionViewOptions.showUnknownCollections == false and option == 1 then
			return false;
		end
		if collectionViewOptions.showCompleteCollections == false and option == 2 then
			return false;
		end
		if collectionViewOptions.showIncompleteCollections == false and option == 3 then
			return false;
		end
		-- text filter
		if search_text == nil or string.len(search_text) == 0 then
			return true;
		end
		-- name
		local name = collection_info.name;
		name = dic.getTranslatedStr(name);
		name = string.lower(name);
		-- desc
		local desc = DRESS_ROOM_GET_REWARD_TEXT(collection_cls);
		desc = dic.getTranslatedStr(desc);
		desc = string.lower(desc);
		-- check text
		if string.find(name, search_text) == nil and string.find(desc, search_text) == nil then
			return false;
		end
		return true;
	end
	
function UPDATE_COSTUME_COLLECTION_LIST(frame, add_type, remove_type, target_cls)
	if frame == nil then return; end
	if frame:IsVisible() == 0 then return; end
	local gbox_collection = GET_CHILD_RECURSIVELY(frame, "collection_bg", "ui::CGroupBox");
	if gbox_collection == nil then return; end
	local gbox_status = GET_CHILD_RECURSIVELY(frame, "status_bg", "ui::CGroupBox");
	if gbox_status == nil then return; end

	local check_complete = GET_CHILD(gbox_status, "complete_check", "ui::CCheckBox");
	local check_unknown = GET_CHILD(gbox_status, "unknown_check", "ui::CCheckBox");
	local check_incomplete = GET_CHILD(gbox_status, "incomplete_check", "ui::CCheckBox");
	if check_complete == nil or check_unknown == nil or check_incomplete == nil then return; end
	check_complete:SetCheck(BOOLEAN_TO_NUMBER(collectionViewOptions.showCompleteCollections));
	check_unknown:SetCheck(BOOLEAN_TO_NUMBER(collectionViewOptions.showUnknownCollections));
	check_incomplete:SetCheck(BOOLEAN_TO_NUMBER(collectionViewOptions.showIncompleteCollections));
	
	DESTROY_CHILD_BYNAME(gbox_collection, 'DECK_');
	collectionViewCount.showCompleteCollections = 0;
	collectionViewCount.showUnknownCollections = 0;
	collectionViewCount.showIncompleteCollections = 0;

	local account_obj = GetMyAccountObj();
	if account_obj == nil then return; end
	
	-- info list
	local costume_collection_info_index = 1;
	local costume_collection_info_list = {};
	local complete_magic_list = {};
	local search_text = GET_COLLECTION_SEARCH_TEXT(frame);
	local item_table = DRESS_ROOM_GET_ITEM_TABLE();
	local list, cnt = GetClassList("dress_room_reward");
	if list ~= nil and cnt > 0 then
		for i = 0, cnt - 1 do
			local collection_cls = GetClassByIndexFromList(list, i);
			if collection_cls ~= nil then
				local class_name = TryGetProp(collection_cls, "ClassName", "None");
				local item_info = item_table[class_name];
				if item_info ~= nil then
					-- cls, acc_obj, item_table, collection_complete_list
					local collection_info = GET_NEW_COSTUME_COLLECTION_INFO(collection_cls, account_obj, item_table, complete_magic_list);
					if CHECK_NEW_COSTUME_COLLECTION_INFO_FILETER(collection_info, search_text, collection_cls) == true then
						costume_collection_info_list[costume_collection_info_index] = { cls = collection_cls, info = collection_info };
						costume_collection_info_index = costume_collection_info_index + 1;
					end
				end
end
		end
	end
	SET_COLLECTION_MAIGC_LIST(frame, complete_magic_list, collectionViewCount.showCompleteCollections);

	-- count setting
	check_complete:SetTextByKey("value", collectionViewCount.showCompleteCollections);
	check_unknown:SetTextByKey("value", collectionViewCount.showUnknownCollections);
	check_incomplete:SetTextByKey("value", collectionViewCount.showIncompleteCollections);

	-- sort option
	if collectionViewOptions.sortType == collectionSortTypes.name then
		table.sort(costume_collection_info_list, SORT_COLLECTION_BY_NAME);
	elseif collectionViewOptions.sortType == collectionSortTypes.status then
		table.sort(costume_collection_info_list, SORT_COLLECTION_BY_STATUS);
	end

	-- deck
	local pos_y = 0;
	for i, v in pairs(costume_collection_info_list) do
		local ctrl_set = gbox_collection:CreateOrGetControlSet("new_collection_deck", "DECK_"..i, 10, pos_y);
		if ctrl_set ~= nil then
			ctrl_set:SetUserValue("is_dress_room", 1);
			ctrl_set:SetUserValue("type", v.cls.ClassID);
			ctrl_set:ShowWindow(1);
			pos_y = SET_NEW_COSTUME_COLLECTION_SET(frame, ctrl_set, item_table, v.cls.ClassID, pos_y);
		end
	end
end

function SET_NEW_COSTUME_COLLECTION_SET(frame, ctrl_set, item_table, type, pos_y)
	if frame == nil or ctrl_set == nil or item_table == nil then return 0; end
	ctrl_set:SetUserValue("COLLECTION_TYPE", type);
	local cls = GetClassByType("dress_room_reward", type);
	if cls ~= nil then
		local thema = TryGetProp(cls, "ClassName", "None");
		local acc_obj = GetMyAccountObj();
		if acc_obj == nil then return 0; end
		-- ctrlset basic skin
		local is_unknown = TryGetProp(acc_obj, thema) == 0;
		if is_unknown == false then
			ctrl_set:SetSkinName(frame:GetUserConfig("ENABLE_SKIN"));
		else
			ctrl_set:SetSkinName(frame:GetUserConfig("DISABLE_SKIN"));
		end
		-- count
		local cur = GET_DRESS_ROOM_THEMA_ITEM_NUM(thema, item_table, acc_obj);
		local max = #item_table[thema];
		local count_text = GET_CHILD_RECURSIVELY(ctrl_set, "collection_count", "ui::CRichText");
		if count_text ~= nil then
			count_text:SetTextByKey("cur", cur);
			count_text:SetTextByKey("max", max);
			if is_unknown == true then
				count_text:ShowWindow(0);
			end
		end
		-- icon
		local text_collection_num = GET_CHILD_RECURSIVELY(ctrl_set, "collection_num", "ui::CRichText");
		local icon_num = GET_CHILD_RECURSIVELY(ctrl_set, "icon_num", "ui::CPicture");
		local icon_new = GET_CHILD_RECURSIVELY(ctrl_set, "icon_new", "ui::CPicture");
		local icon_comp = GET_CHILD_RECURSIVELY(ctrl_set, "icon_comp", "ui::CPicture");
		text_collection_num:ShowWindow(0);
		icon_num:ShowWindow(0);
		icon_new:ShowWindow(0);
		icon_comp:ShowWindow(0);
		-- complete
		local gbox_complete = GET_CHILD_RECURSIVELY(ctrl_set, "gb_complete", "ui::CGroupBox");
		gbox_complete:ShowWindow(0);
		-- read check
		local collection_name = "";
		local name_text = GET_CHILD_RECURSIVELY(ctrl_set, "collection_name", "ui::CRichText");
		local collection_name_font = nil;
		local visible_add_num_font = nil;
		local visible_add_num = false;
		local class_id = TryGetProp(cls, "ClassID", 0);
		if is_unknown == false then
			collection_name_font = frame:GetUserConfig("ENABLE_DECK_TITLE_FONT");
			local is_read = TryGetProp(acc_obj, "CollectionDressRoomRead_"..class_id);
			if cur >= max then
				-- complete
				icon_comp:ShowWindow(1);
				gbox_complete:ShowWindow(1);
				collection_name_font = frame:GetUserConfig("COMPLETE_DECK_TITLE_FONT");
			elseif is_read == nil or is_read == 0 then
				icon_new:ShowWindow(1);
			else
				visible_add_num = true;
				visible_add_num_font = frame:GetUserConfig("ENABLE_DECK_NUM_FONT");
			end
		else
			icon_num:SetColorTone(frame:GetUserConfig("NOT_HAVE_COLOR"));
			collection_name_font = frame:GetUserConfig("DISABLE_DECK_TITLE_FONT");
			visible_add_num_font = frame:GetUserConfig("DISABLE_DECK_NUM_FONT");
			visible_add_num = true;
		end
		-- registration number
		if visible_add_num == true then
			if cur > 0 then
				local add_num = 0;
				local item_list = item_table[thema];
				for i = 1, #item_list do
					local dress_cls = item_list[i];
					if dress_cls ~= nil then
						if DRESS_ROOM_IS_ITEM_SET(acc_obj, dress_cls) == false then
							local item_class_name = TryGetProp(dress_cls, "ItemClassName", "None");
							local item_cls = GetClass("Item", item_class_name);
							if item_cls ~= nil then
								local item_cls_id = TryGetProp(item_cls, "ClassID", 0);
								if session.GetInvItemCountByType(item_cls_id) > 0 then
									add_num = add_num + 1;
								end
							end
						end
					end
				end
				if add_num > 0 then
					if visible_add_num_font ~= nil then
						text_collection_num:SetTextByKey("value", visible_add_num_font..add_num.."{/}");
					else
						text_collection_num:SetTextByKey("value", visible_add_num_font);
					end
					text_collection_num:ShowWindow(1);
					icon_num:ShowWindow(1);
				end
			end
		end
		-- name
		if name_text ~= nil then
			local name = TryGetProp(cls, "Name", "None");
			collection_name = name;
			if collection_name_font ~= nil then
				name_text:SetTextByKey("name", collection_name_font..name.."{/}");
			else
				name_text:SetTextByKey("name", name);
			end
		end
		-- detail
		local gbox_detail = GET_CHILD_RECURSIVELY(ctrl_set, "gb_detail", "ui::CGroupBox");
		local icon_detail = GET_CHILD_RECURSIVELY(gbox_detail, "icon_detail", "ui::CPicture");
		local text_detail = GET_CHILD_RECURSIVELY(icon_detail, "text_detail", "ui::CRichText");
		local text_detail_list = GET_CHILD_RECURSIVELY(gbox_detail, "text_detail_list", "ui::CRichText");
		-- detail - font
		local desc_font = nil;
		local detail_font = nil;
		if is_unknown == false then
			desc_font = frame:GetUserConfig("DISABLE_MAGIC_LIST_FONT");
			detail_font = frame:GetUserConfig("DISABLE_MAGIC_FONT");
			icon_detail:SetColorTone(frame:GetUserConfig("NOT_HAVE_COLOR"));
		else
			desc_font = frame:GetUserConfig("ENABLE_MAGIC_LIST_FONT");
			detail_font = frame:GetUserConfig("ENABLE_MAGIC_FONT");
		end
		-- detail - text
		if detail_font ~= nil then
			text_detail:SetTextByKey("value", detail_font..ClMsg("CollectionMagicText").."{/}");
		else
			text_detail:SetTextByKey("value", ClMsg("CollectionMagicText"));
		end
		-- deatil - input
		local desc = DRESS_ROOM_GET_REWARD_TEXT(cls);
		if desc_font ~= nil then
			text_detail_list:SetTextByKey("value", desc_font..desc.."{/}");
		else
			text_detail_list:SetTextByKey("value", desc);
		end
		-- deatil - resize
		local text_detail_list_height = text_detail_list:GetHeight();
		gbox_detail:Resize(gbox_detail:GetWidth(), text_detail_list_height);
	
		-- ctrlset resize
		local old_pos_y = pos_y;
		local cur_pos_y = ctrl_set:GetOriginalY() + name_text:GetY() + name_text:GetHeight();
		cur_pos_y = cur_pos_y + gbox_detail:GetHeight();
	
		local new_pos_y = pos_y + ctrl_set:GetHeight() + 10;
		local ctrl_set_height = math.max(new_pos_y - old_pos_y, gbox_detail:GetY() + text_detail_list:GetHeight() + 15);
		new_pos_y = pos_y + ctrl_set_height;
		ctrl_set:Resize(ctrl_set:GetWidth(), ctrl_set_height);
		
		-- gbox collection resize
		local gbox_collection = GET_CHILD_RECURSIVELY(ctrl_set, "gb_collection", "ui::CGroupBox");
		if gbox_collection ~= nil then
			gbox_collection:Resize(gbox_collection:GetWidth(), ctrl_set:GetOriginalHeight());
			gbox_complete:Resize(ctrl_set:GetWidth(), ctrl_set_height);
		end
		cur_pos_y = cur_pos_y + tonumber(frame:GetUserConfig("SLOT_BOTTOM_MARGIN"));
		
		-- select
		if frame:GetUserIValue("DETAIL_VIEW_TYPE") == type then
			local gbox_collection_info = GET_CHILD_RECURSIVELY(frame, "collection_info_bg");
			if gbox_collection_info ~= nil then
				local collection_info_detail_pic = GET_CHILD_RECURSIVELY(gbox_collection_info, "collection_info_detail_pic");
				local collection_info_detail_text = GET_CHILD_RECURSIVELY(gbox_collection_info, "collection_info_detail_text");
				local collection_info_detail_list_text = GET_CHILD_RECURSIVELY(gbox_collection_info, "collection_info_detail_list_text");
				local costume_collection_info_detail_list_text = GET_CHILD_RECURSIVELY(gbox_collection_info, "costume_collection_info_detail_list_text");
				collection_info_detail_pic:ShowWindow(1);
				collection_info_detail_text:ShowWindow(1);
				collection_info_detail_list_text:ShowWindow(1);
				costume_collection_info_detail_list_text:ShowWindow(1);
				SET_NEW_COSTUME_COLLECTION_DETAIL_VIEW(frame, gbox_collection_info, acc_obj, item_table, thema, type, desc);
			end
		end
		return new_pos_y;
	end
end

function SET_NEW_COSTUME_COLLECTION_DETAIL_VIEW(frame, gbox_info, acc_obj, item_table, thema, type, desc)
	if frame == nil or acc_obj == nil or item_table == nil then return; end
	-- detail info title
	local collection_info_detail_text = GET_CHILD_RECURSIVELY(gbox_info, "collection_info_detail_text");
	if collection_info_detail_text ~= nil then
		collection_info_detail_text:SetTextByKey("value", ClMsg("CollectionMagicText"));
	end
	-- deatil info desc
	local collection_info_detail_list_text = GET_CHILD_RECURSIVELY(gbox_info, "collection_info_detail_list_text");
	if collection_info_detail_list_text ~= nil then
		collection_info_detail_list_text:SetTextByKey("value", desc);
	end
	-- detail info desc costume
	local costume_collection_info_detail_list_text = GET_CHILD_RECURSIVELY(gbox_info, "costume_collection_info_detail_list_text");
	if costume_collection_info_detail_list_text ~= nil then
		costume_collection_info_detail_list_text:SetTextByKey("value", ClMsg("CostumeCollectionInfoText"));
	end
	-- detail view
	DESTROY_CHILD_BYNAME(gbox_info, "SLOT_");
	local detail_view_type = frame:GetUserIValue("DETAIL_VIEW_TYPE");
	local enable_detail_view = (detail_view_type == type and frame:GetName() ~= "adventure_book");
	if enable_detail_view == true then
		local cur = GET_DRESS_ROOM_THEMA_ITEM_NUM(thema, item_table, acc_obj);
		local max = #item_table[thema];
		local draw_count_limit = frame:GetUserConfig("DETAIL_ITEM_COUNT"); -- detailveiw draw count limit 
		local draw_count = math.ceil(max / draw_count_limit);
		local cls = GetClassByType("dress_room_reward", type);
		if cls ~= nil then
			local item_list = item_table[thema];
			local margin_x = frame:GetUserConfig("DETAIL_MARGIN_X");
			local margin_y = frame:GetUserConfig("DETAIL_MARGIN_Y");
			local space = frame:GetUserConfig("DETAIL_ITEM_SPACE");
			local gbox_width = gbox_info:GetWidth();
			local box_width = gbox_width - (margin_x * 2);
			local slot_width = math.floor((box_width / draw_count_limit) - (space * 2)) + 15;
			local slot_height = slot_width;
			local idx = 0;
			local is_break = 0;
			local draw_item_set = {};
			for i = 1, draw_count do
				for j = 1, draw_count_limit do
					local reward_cls = item_list[idx + 1];
					if reward_cls ~= nil then
						if idx > max then
							is_break = 1;
							break;
						end
						local item_name = TryGetProp(reward_cls, "ItemClassName", "None");
						if item_name == "None" then
							is_break = 1;
							break;
						end
						local item_cls = GetClass("Item", item_name);
						if item_cls ~= nil then
							local row = i;
							local col = (j - 1) % draw_count_limit;
							local x = margin_x + col * (slot_width + space);
							local y = margin_y + (row - 1) * (slot_height + space);
							local ctrl_set = gbox_info:CreateOrGetControlSet("collection_slot", "SLOT_"..idx, x, y);
							if ctrl_set ~= nil then
								local reward_class_name = TryGetProp(reward_cls, "ClassName", "None");
								ctrl_set:SetUserValue("DRESS_PROP", reward_class_name);
								local btn = GET_CHILD_RECURSIVELY(ctrl_set, "btn", "ui::CSlot");
								btn:ShowWindow(0);
								btn:SetTooltipOverlap(0);
								local slot = GET_CHILD_RECURSIVELY(ctrl_set, "slot", "ui::CSlot");
								if slot ~= nil then
									slot:SetUserValue("COLLECTION_TYPE", type);
									slot:SetUserValue("index", j);
									slot:SetUserValue("Reinforce", 0);
									slot:SetEventScript(ui.RBUTTONUP, "ON_CLICK_DRESS_ROOM_MAKE_ITEM")
									local icon = CreateIcon(slot);
									if icon ~= nil then
										local icon_name = TryGetProp(item_cls, "Icon", "None");
										icon:SetImage(icon_name);
										icon:SetTooltipOverlap(0);
										if DRESS_ROOM_IS_ITEM_SET(acc_obj, reward_cls) == false then
											icon:SetColorTone("88000000");
											if TryGetProp(reward_cls, "Group", "None") == "dress_room_blessed_cube" then
												btn:ShowWindow(1);
												btn:SetEventScriptArgNumber(ui.LBUTTONUP, reward_cls.ClassID);
											end
										else
											icon:SetColorTone("FFFFFFFF");
										end
										local item_class_id = TryGetProp(item_cls, "ClassID", 0);
										SET_ITEM_TOOLTIP_ALL_TYPE(icon, nil, item_name, "collection", item_class_id, item_class_id);
										SET_ITEM_TOOLTIP_ALL_TYPE(btn, nil, item_name, "collection", item_class_id, item_class_id);
									end
								end
								idx = idx + 1;
							end
						end
					end
					if is_break == 1 then
						break;
					end
				end
			end
		end
	end
end

function SCR_NEW_COSTUME_COLLECTION_REGISTER()
	local frame = ui.GetFrame("collection");
	if frame == nil then return; end
	local dress_cls_id = frame:GetUserIValue("DRESS_CLS_ID");
	local dress_cls = GetClassByType("dress_room", dress_cls_id);
	if config.GetServiceNation() == "PAPAYA" then dress_cls = GetClassByType("dress_room_papaya", dress_cls_id); end
	if dress_cls == nil then return; end
	local ies_id = frame:GetUserValue("DRESS_ITEM_IES_ID");
	local inv_item = session.GetInvItemByGuid(ies_id);
	if inv_item ~= nil then
		pc.ReqExecuteTx_Item("REGISTER_DRESS_ROOM_ITEM", inv_item:GetIESID(), tostring(dress_cls_id));
	end
end
