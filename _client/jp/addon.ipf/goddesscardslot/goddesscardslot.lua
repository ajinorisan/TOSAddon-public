-- goddesscardslot.lua
local goddesscard_slot_idx = MAX_NORMAL_MONSTER_CARD_SLOT_COUNT + LEGEND_CARD_SLOT_COUNT + GODDESS_CARD_SLOT_COUNT
function GODDESSCARDSLOT_ON_INIT(addon, frame)
	addon:RegisterMsg("GODDESSCARD_SLOT_SET", "ON_GODDESSCARD_SLOT_SET");
	addon:RegisterMsg("GODDESSCARD_SLOT_REMOVE", "ON_GODDESSCARD_SLOT_REMOVE");
end

function GODDESSCARDSLOT_OPEN(frame)
	INIT_GODDESSCARD_SLOT(frame)
end

function GODDESSCARDSLOT_CLOSE(frame)

end

function INIT_GODDESSCARD_SLOT(frame)
	local cardSlot = GET_CHILD_RECURSIVELY(frame,"cardSlot")
	cardSlot:SetAlpha(45)
	local cardID, cardLv, cardExp = GETMYCARD_INFO(goddesscard_slot_idx-1)
	local itemCls = GetClassByType("Item",cardID)
	if itemCls == nil then
		CLEAR_GODDESSCARDSLOT(frame)
		return
	end
	GODDESSCARD_SLOT_SET_SPINE(frame,TryGetProp(itemCls,"SpineTooltipImage","None"),TryGetProp(itemCls,"TooltipImage","None"))
	GODDESSCARD_SLOT_SET_OPTION(frame,itemCls,cardLv)
end

function CLEAR_GODDESSCARDSLOT(frame)
	local bgImage = GET_CHILD_RECURSIVELY(frame,"bgPic")
	local cardSpinePic = GET_CHILD_RECURSIVELY(frame, 'cardSpinePic');
	local cardImage = GET_CHILD_RECURSIVELY(frame, 'cardImage');
	local resultBox = GET_CHILD_RECURSIVELY(frame,"resultBox")
	bgImage:SetVisible(0)
	cardSpinePic:SetVisible(0)
	cardImage:SetImage(nil)
	resultBox:RemoveAllChild()
end

function ON_GODDESSCARD_SLOT_SET(frame,msg,itemClassName,argNum)
	local invFrame = ui.GetFrame("inventory");
	invFrame:SetUserValue("EQUIP_CARD_GUID", "");
	invFrame:SetUserValue("EQUIP_CARD_SLOTINDEX", "");

	local cardID, cardLv, cardExp = GETMYCARD_INFO(goddesscard_slot_idx-1)
	local itemCls = GetClass("Item",itemClassName)
	GODDESSCARD_SLOT_SET_SPINE(frame,TryGetProp(itemCls,"SpineTooltipImage","None"),TryGetProp(itemCls,"TooltipImage","None"))
	GODDESSCARD_SLOT_SET_OPTION(frame,itemCls,cardLv)
end

function GODDESSCARD_SLOT_SET_SPINE(frame,spineName,iconName)
	local bgImage = GET_CHILD_RECURSIVELY(frame,"bgPic")
	local cardSpinePic = GET_CHILD_RECURSIVELY(frame, 'cardSpinePic');
	local cardImage = GET_CHILD_RECURSIVELY(frame, 'cardImage');
	local spineInfo = geSpine.GetSpineInfo(spineName);
	local isSpine = BoolToNumber(spineInfo ~= nil)
	bgImage:SetVisible(isSpine)
	cardSpinePic:SetVisible(isSpine)
	if isSpine == 1 then
		cardSpinePic:SetScaleFactor(spineInfo:GetScaleFactor());
		cardSpinePic:CreateSpineActor(spineInfo:GetRoot(), spineInfo:GetAtlas(), spineInfo:GetJson(), "", spineInfo:GetAnimation());
		cardImage:SetImage(nil)
	else
		cardImage:SetImage(iconName)
	end
	
end

-- 몬스터 카드를 인벤토리의 카드 슬롯에 드레그드롭으로 장착하려 할 경우.
function GODDESSCARD_SLOT_DROP(frame, slot, argStr, argNum)
	local liftIcon = ui.GetLiftIcon();
	local iconInfo = liftIcon:GetInfo();
	if iconInfo == nil then
		return
	end

	local item = session.GetInvItem(iconInfo.ext);
	if nil == item then
		return;
	end
	local cardObj = GetClassByType("Item", item.type)
	if cardObj == nil then
		return
	end
	
	if cardObj.CardGroupName ~= "GODDESS" then
		ui.SysMsg(ClMsg("ToEquipSameCardGroup"));
		return
	end

	GODDESSCARD_SLOT_EQUIP(slot, item, cardObj.CardGroupName);
end

-- 몬스터 카드를 인벤토리의 카드 슬롯에 장착 요청하기 전에 메세지 박스로 한번 더 확인
function GODDESSCARD_SLOT_EQUIP(slot, item, groupNameStr)
	local obj = GetIES(item:GetObject());
	if obj.GroupName == "Card" then
		local cardInfo = equipcard.GetCardInfo(goddesscard_slot_idx);
		if cardInfo ~= nil then
			ui.SysMsg(ClMsg("AlreadyEquippedThatCardSlot"));
			return;
		end

		if groupNameStr == 'GODDESS' then
			local pcEtc = GetMyEtcObject();
			local aObj = GetMyAccountObj();
			if pcEtc.IS_LEGEND_CARD_OPEN ~= 1 or aObj.IS_GODDESS_CARD_OPEN ~= 1 then
				ui.SysMsg(ClMsg("GoddessCard_Slot_NotOpen"))
				return
			end
		end

		if item.isLockState == true then
			ui.SysMsg(ClMsg("MaterialItemIsLock"));
			return
		end

		local itemGuid = item:GetIESID();
		local invFrame = ui.GetFrame("inventory");
		invFrame:SetUserValue("EQUIP_CARD_GUID", itemGuid);
		invFrame:SetUserValue("EQUIP_CARD_SLOTINDEX", goddesscard_slot_idx-1);
		REQUEST_EQUIP_CARD_TX();
		return 1;
	end
	return 0;
end


function GODDESSCARD_SLOT_SET_OPTION(frame,itemCls,cardLv)
	local cardCls = GetClass("EquipBossCard",itemCls.ClassName)
	local resultBox = GET_CHILD_RECURSIVELY(frame,"resultBox")
	resultBox:RemoveAllChild()
	local y = 10
	do
		local optionText = TryGetProp(cardCls,"OptionText")
		local optionTextValue = TryGetProp(cardCls,"OptionTextValue")
		y = y + GODDESSCARD_SLOT_SET_OPTION_EACH(resultBox,"OPTION_CSET_MAIN",cardLv,optionText,optionTextValue,y)
	end
	local i = 1
	while true do
		local optionText = TryGetProp(cardCls,"ExtraOptionText"..i,"None")
		if optionText == "None" then
			break
		end
		local optionTextValue = TryGetProp(cardCls,"ExtraOptionTextValue"..i)
		y = y + GODDESSCARD_SLOT_SET_OPTION_EACH(resultBox,"OPTION_CSET_"..i,cardLv,optionText,optionTextValue,y)
		i = i + 1
	end
end

function GODDESSCARD_SLOT_SET_OPTION_EACH(gb,name,cardLv,optionText,optionTextValue,y)
	if optionText == "None" then
		return
	end
	local itemClsCtrl = gb:CreateOrGetControlSet('eachoption_in_goddesscard', name, 0, y);
	local optionTextValueList = StringSplit(optionTextValue, "/")
	for i = 1,#optionTextValueList do
		optionTextValueList[i] = optionTextValueList[i] * cardLv
	end

	optionText = dictionary.ReplaceDicIDInCompStr(optionText)
	optionText = string.format(optionText, optionTextValueList[1], optionTextValueList[2], optionTextValueList[3])
	
	local optionImage = string.format("%s", ClMsg('MonsterCardOptionGroupGODDESS'))
	optionText = optionImage .. optionText

	local option_richText = GET_CHILD_RECURSIVELY(itemClsCtrl, "option_text", "ui::CRichText");
	option_richText:SetText(optionText)

	local height_diff = option_richText:GetHeight() - option_richText:GetOriginalHeight()
	itemClsCtrl:Resize(itemClsCtrl:GetWidth(),itemClsCtrl:GetOriginalHeight()+height_diff)

	return itemClsCtrl:GetHeight()
end

function ON_GODDESSCARD_SLOT_REMOVE(frame,msg)
	CLEAR_GODDESSCARDSLOT(frame)
end

--우클릭 제거
function GODDESSCARD_SLOT_REMOVE(frame,slot,argStr,argNum)
	EQUIP_GODDESSCARDSLOT_INFO_OPEN(goddesscard_slot_idx-1);
end

-- 카드 슬롯 정보창 열기
function EQUIP_GODDESSCARDSLOT_INFO_OPEN(slotIndex)
	local other_frame = ui.GetFrame('equip_cardslot_info')
	other_frame:ShowWindow(0)
	local frame = ui.GetFrame('equip_cardslot_info_goddess');
	if frame:IsVisible() == 1 then
		frame:ShowWindow(0);	
	end
	
	local cardID, cardLv, cardExp = GETMYCARD_INFO(slotIndex);	
	if cardID == 0 then
		return;
	end

	local prop = geItemTable.GetProp(cardID);
	if prop ~= nil then
		cardLv = prop:GetLevel(cardExp);
	end
	
	-- 카드 슬롯 제거하기 위함
	frame:SetUserValue("REMOVE_CARD_SLOTINDEX", slotIndex);

	local inven = ui.GetFrame("inventory");
	local cls = GetClassByType("Item", cardID);

	-- 안내메세지에 이름 적용
	local infoMsg = GET_CHILD(frame, "infoMsg");
	infoMsg:SetTextByKey("Name", cls.Name);

	-- 카드 이미지 적용
	local card_img = GET_CHILD(frame, "card_img");
	card_img:SetImage(TryGetProp(cls, "TooltipImage"));
	local spineName = TryGetProp(cls, "SpineTooltipImage")
	local spineInfo = geSpine.GetSpineInfo(spineName);
	if spineInfo ~= nil then
		card_img:SetScaleFactor(spineInfo:GetScaleFactor());
		card_img:CreateSpineActor(spineInfo:GetRoot(), spineInfo:GetAtlas(), spineInfo:GetJson(), "", spineInfo:GetAnimation());
	end

	local cardStar = GET_CHILD(frame, "cardStar");
	local imgSize = frame:GetUserConfig('starSize');
	cardStar:SetTextByKey("value", GET_STAR_TXT(imgSize, cardLv, cls));

	-- 제거되는 효과 표시하는 곳. 
	local removedEffect =  string.format("%s{/}", cls.Desc);	
	if cls.Desc == "None" then
		removedEffect = "{/}";
	end

	local bg = GET_CHILD(frame, "bg");
	local effect_info = GET_CHILD(bg, "effect_info");
	effect_info:SetTextByKey("RemovedEffect", removedEffect);
	
	-- 정보창 위치를 인벤 옆으로 붙힘.
	frame:SetOffset(inven:GetX() - frame:GetWidth(), frame:GetY());

	frame:ShowWindow(1);	
end

function EQUIP_GODDESSCARDSLOT_BTN_REMOVE(frame)
	local argStr = string.format("%d", frame:GetUserIValue("REMOVE_CARD_SLOTINDEX"))

	argStr = argStr .. " 0"

	pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)
end