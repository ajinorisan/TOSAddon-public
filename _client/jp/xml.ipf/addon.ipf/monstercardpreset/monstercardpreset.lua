-- monstercardpreset.lua

local curPreset = 0

function MONSTERCARDPRESET_ON_INIT(addon, frame)
	addon:RegisterMsg("CHANGE_RESOLUTION", "CARD_OPTION_OPEN");
end

function MONSTERCARDPRESET_FRAME_OPEN()
	local frame = ui.GetFrame('monstercardpreset')
	local etcObj = GetMyEtcObject()
	local droplist = GET_CHILD_RECURSIVELY(frame,"preset_list")
	droplist:SelectItemByKey(0)
	MONSTERCARDPRESET_FRAME_INIT()
	RequestCardPreset(0)
end

function MONSTERCARDPRESET_FRAME_INIT()
	local frame = ui.GetFrame('monstercardpreset')
	ui.OpenFrame("monstercardpreset")

	CARD_PRESET_CLEAR_SLOT(frame)
	local page = GET_CHILD_RECURSIVELY(frame,"preset_list"):GetSelItemKey()
	 
	if page == "" then
		CARD_PRESET_SHOW_PRESET(0)
	else
		CARD_PRESET_SHOW_PRESET(tonumber(page))
	end

	
	local isOpen = frame:GetUserIValue("CARD_OPTION_OPENED");
	local optionGbox = GET_CHILD_RECURSIVELY(frame, "option_bg")
	optionGbox:ShowWindow(1)	

	CARD_OPTION_OPEN(frame)
	frame:SetUserValue("CARD_OPTION_OPENED", 0);
end

function MONSTERCARDPRESET_FRAME_CLOSE()
	ui.CloseFrame('monstercardpreset')
end

function _GETMYCARD_INFO(slotIndex)
	local frame = ui.GetFrame("monstercardpreset")
	local page = GET_CHILD_RECURSIVELY(frame,"preset_list"):GetSelItemKey()
	 
	if page == "" then
		return 0,0,0
	end

	local cardList = equipcard.GetCardPresetInfo(page)
	if cardList == nil then
		return 0, 0, 0;
	end

	local count = cardList:Count()
	
	for i = 0, count - 1 do
		local info = cardList:Element(i)
		if slotIndex == info.slot_idx - 1 then
			local cardClsID = info.class_id
			local cardExp = info.exp
			local cardLv = 1
			local prop = geItemTable.GetProp(cardClsID);
			if prop ~= nil then
				cardLv = prop:GetLevel(cardExp);
			end
			return cardClsID, cardLv, cardExp
		end
	end


	return 0, 0, 0;
end


function CARD_PRESET_CHANGE_NAME(parent, ctrl)
	local frame = parent:GetTopParentFrame()
	local droplist = GET_CHILD_RECURSIVELY(frame,"preset_list")
	local page = tonumber(droplist:GetSelItemKey())
	local preset_name = droplist:GetSelItemCaption()
    local newframe = ui.GetFrame('inputstring')
    newframe:SetUserValue('InputType', 'InputNameForChange')
	INPUT_STRING_BOX(ClMsg('ChangeAncientDefenseDeckTabName'), 'CARD_PRESET_CHANGE_NAME_EXEC', preset_name, 0, 16)
end

function CARD_PRESET_CHANGE_NAME_EXEC(input_frame, ctrl)
	if ctrl:GetName() == 'inputstr' then
        input_frame = ctrl
	end

    local new_name = GET_INPUT_STRING_TXT(input_frame)
	
	local frame = ui.GetFrame('monstercardpreset')
	local droplist = GET_CHILD_RECURSIVELY(frame,"preset_list")
	local page = tonumber(droplist:GetSelItemKey())
	local preset_name = droplist:GetSelItemCaption()
	if new_name == preset_name then
		ui.SysMsg(ClMsg('AlreadyorImpossibleName'))
		return
	end

	local name_str = TRIM_STRING_WITH_SPACING(new_name)
	if name_str == '' then
		ui.SysMsg(ClMsg('InvalidStringOrUnderMinLen'))
		return
	end

	SetCardPreSetTitle(page, name_str)

	_DISABLE_CARD_PRESET_CHANGE_NAME_BTN()

	input_frame:ShowWindow(0)
end

function CARD_PRESET_GET_CARD_EXP_LIST(frame)
	local frame = frame:GetTopParentFrame()
	local cardList = {}
	local expList = {}
	for i = 0, 11 do
		local cardClsID, cardLv, cardExp = GETMYCARD_INFO(i)

		if clsID ~= 0 then
			table.insert(cardList, cardClsID);
			table.insert(expList, cardExp);
		else
			table.insert(cardList, 0);
			table.insert(expList, 0);
		end
	end

	return cardList, expList
end


function CARD_PRESET_LOAD(page, title, isEmpty)
	local frame = ui.GetFrame("monstercardpreset")
	local droplist = GET_CHILD_RECURSIVELY(frame,"preset_list")

	if title == "" then
		title =  ScpArgMsg('CardPresetNumber{index}', 'index', page + 1)
	end
	
	MONSTERCARDPRESET_FRAME_INIT()
	local changed = droplist:SetItemTextByKey(page, title)
	if changed == false then
		droplist:AddItem(page, title)
	    CARD_PRESET_CLEAR_SLOT(frame)
		CARD_PRESET_SHOW_PRESET(0)
	end
	local saveBtn = GET_CHILD_RECURSIVELY(frame,"saveBtn")
	if saveBtn:IsEnable() == 0 then
		ui.SysMsg(ScpArgMsg('CardPreSetInfoSaved{NAME}', 'NAME', droplist:GetSelItemCaption()));
	end

	_CHECK_CARD_PRESET_APPLY_SAVE_BTN()
end 

function CARD_PRESET_APPLY_COMPLETE(page)
	local frame = ui.GetFrame("monstercardpreset")
	_CHECK_CARD_PRESET_APPLY_SAVE_BTN()
	local droplist = GET_CHILD_RECURSIVELY(frame,"preset_list")
	ui.SysMsg(ScpArgMsg('CardInfoChanged{NAME}', 'NAME', droplist:GetSelItemCaption()));
end

function CARD_PRESET_RELOAD_AFTER_APPLY()
	local frame = ui.GetFrame('monstercardslot')
	CARD_PRESET_CLEAR_SLOT(frame)
	CARD_SLOTS_CREATE(frame)
	CARD_OPTION_OPEN(frame)
end

function CARD_PRESET_SELECT_PRESET(parent, self)
	CARD_PRESET_CLEAR_SLOT(parent)
	local page = tonumber(self:GetSelItemKey())
	CARD_PRESET_SHOW_PRESET(page)
end

function CARD_PRESET_CLEAR_SLOT(frame)
	local frame = frame:GetTopParentFrame()
	for i = 0, 11 do
		local groupName = CARD_SLOT_GET_GROUP_NAME(i)
		_CARD_PRESET_SLOT_REMOVE(frame, i+1, groupName)
	end
end

-- 인벤토리의 카드 슬롯 제거 동작
function _CARD_PRESET_SLOT_REMOVE(cardFrame, slotIndex, cardGroupName)
	local frame = cardFrame
	local groupNameStr = cardGroupName
	local groupSlotIndex = CARD_SLOT_GET_GROUP_SLOT_INDEX(cardGroupName, slotIndex)

	local gBox = GET_CHILD_RECURSIVELY(frame, groupNameStr .. 'cardGbox');
	local card_slotset = GET_CHILD(gBox, groupNameStr .. "card_slotset");
	local card_labelset = GET_CHILD(gBox, groupNameStr .. "card_labelset");

	if card_slotset ~= nil and card_labelset ~= nil then
		local slot = card_slotset:GetSlotByIndex(groupSlotIndex - 1);
		if slot ~= nil then
			slot:ClearIcon();
		end;

		local slot_label = card_labelset:GetSlotByIndex(groupSlotIndex - 1);
		if slot_label ~= nil then
			local icon_label = CreateIcon(slot_label)
			if cardGroupName == 'ATK' then
				icon_label : SetImage('red_cardslot1')
			elseif cardGroupName == 'DEF' then
				icon_label : SetImage('blue_cardslot1')
			elseif cardGroupName == 'UTIL' then
				icon_label : SetImage('purple_cardslot1')
			elseif cardGroupName == 'STAT' then
				icon_label : SetImage('green_cardslot1')
			elseif cardGroupName == 'LEG' then
				icon_label : SetImage('legendopen_cardslot')
			end
		end;
	end;

	CARD_OPTION_CREATE(frame)
end;


function CARD_PRESET_SHOW_PRESET(page)
	local cardList = equipcard.GetCardPresetInfo(page)
	if cardList == nil then
		return;
	end
	local count = cardList:Count()

	for i = 0, count - 1 do
		local info = cardList:Element(i)
		local class_id = info.class_id
		local page = info.page
		local slot = info.slot_idx
		local exp = info.exp
		_CARD_PRESET_SLOT_EQUIP(slot, class_id, 1, exp) -- 수정 필요
	end
end

function _CARD_PRESET_SLOT_EQUIP(slotIndex, itemClsId, itemLv, itemExp)
	local moncardFrame = ui.GetFrame("monstercardpreset");
	local invFrame    = ui.GetFrame("inventory");	
	
	if moncardFrame:IsVisible() == 0 then
		return;
	end;

	if invFrame:IsVisible() == 0 then
		return;
	end;

	local cardObj = GetClassByType("Item", itemClsId);
	if cardObj == nil then
		return;
	end

	local groupNameStr = cardObj.CardGroupName
	local groupSlotIndex = CARD_SLOT_GET_GROUP_SLOT_INDEX(groupNameStr, slotIndex)

	local moncardGbox = GET_CHILD_RECURSIVELY(moncardFrame, groupNameStr .. 'cardGbox');
	local card_slotset = GET_CHILD(moncardGbox, groupNameStr .. "card_slotset");

	local card_labelset = GET_CHILD(moncardGbox, groupNameStr .. "card_labelset");
	if card_slotset ~= nil and card_labelset then
		CARD_SLOT_SET(card_slotset, card_labelset, groupSlotIndex -1, itemClsId, itemLv, itemExp);
	end;
	invFrame:SetUserValue("EQUIP_CARD_GUID", "");
	invFrame:SetUserValue("EQUIP_CARD_SLOTINDEX", "");	
	
	CARD_OPTION_CREATE(moncardFrame)
end;

function CARD_PRESET_SAVE_PRESET(parent, self)
	local cardList, expList = CARD_PRESET_GET_CARD_EXP_LIST(parent)
	local droplist = GET_CHILD_RECURSIVELY(parent,"preset_list")
	local page = tonumber(droplist:GetSelItemKey())

	SetCardPreset(page, cardList, expList)
	_DISABLE_CARD_PRESET_APPLY_SAVE_BTN()
end

function CARD_PRESET_APPLY_PRESET(parent, self)
	local cardList, expList = CARD_PRESET_GET_CARD_EXP_LIST(parent)
	local droplist = GET_CHILD_RECURSIVELY(parent,"preset_list")
	local page = tonumber(droplist:GetSelItemKey())

	if page ~= nil then
		pc.ReqExecuteTx_NumArgs("SCR_TX_APPLY_CARD_PRESET", page)
		_DISABLE_CARD_PRESET_APPLY_SAVE_BTN()
	end
end

function _CHECK_CARD_PRESET_CHANGE_NAME_BTN()
	local frame = ui.GetFrame('monstercardpreset')
	local btn = GET_CHILD_RECURSIVELY(frame, 'nameBtn')
	btn:SetEnable(1)
end

function _DISABLE_CARD_PRESET_CHANGE_NAME_BTN()
	local frame = ui.GetFrame('monstercardpreset')
	local btn = GET_CHILD_RECURSIVELY(frame, 'nameBtn')
	if btn ~= nil then
		ReserveScript('_CHECK_CARD_PRESET_CHANGE_NAME_BTN()', 1)
    	btn:SetEnable(0)
	end
end

function _CHECK_CARD_PRESET_APPLY_SAVE_BTN()
	local frame = ui.GetFrame('monstercardpreset')
	local btn1 = GET_CHILD_RECURSIVELY(frame, 'saveBtn')
	local btn2 = GET_CHILD_RECURSIVELY(frame, 'applyBtn')
	btn1:SetEnable(1)
	btn2:SetEnable(1)
end

function _DISABLE_CARD_PRESET_APPLY_SAVE_BTN()
	local frame = ui.GetFrame('monstercardpreset')
	local btn1 = GET_CHILD_RECURSIVELY(frame, 'saveBtn')
	local btn2 = GET_CHILD_RECURSIVELY(frame, 'applyBtn')
	btn1:SetEnable(0)
	btn2:SetEnable(0)
end