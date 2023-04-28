local addonName = "NOCHECK"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsDirLoc = string.format("../addons/%s", addonNameLower)
g.settingsFileLoc = string.format("%s/settings.json", g.settingsDirLoc)

local acutil = require("acutil")

function NOCHECK_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    acutil.setupHook(NOCHECK_BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG, "BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG")
    acutil.setupHook(NOCHECK_CARD_SLOT_EQUIP, "CARD_SLOT_EQUIP")
    acutil.setupHook(NOCHECK_EQUIP_CARDSLOT_INFO_OPEN, "EQUIP_CARDSLOT_INFO_OPEN")
	--acutil.setupHook(NOCHECK_EQUIP_GODDESSCARDSLOT_BTN_REMOVE, "EQUIP_GODDESSCARDSLOT_BTN_REMOVE")
    CHAT_SYSTEM("NOCHECK loaded")

end

--欠片アイテム他使用時のメッセージボックス非表示
function NOCHECK_BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG(invItem)

    if invItem == nil then
        return;
    end
    
    local invFrame = ui.GetFrame("inventory");    
    local itemobj = GetIES(invItem:GetObject());
    if itemobj == nil then
        return;
    end
    invFrame:SetUserValue("REQ_USE_ITEM_GUID", invItem:GetIESID());
    
    REQUEST_SUMMON_BOSS_TX();
    --BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG_OLD(invItem)
    
    return;
end

--レジェンドカード装着時のメッセージボックス非表示
function NOCHECK_CARD_SLOT_EQUIP(slot, item, groupNameStr)
	local obj = GetIES(item:GetObject());
	if obj.GroupName == "Card" then			
		local slotIndex = CARD_SLOT_GET_SLOT_INDEX(groupNameStr, slot:GetSlotIndex());
		local cardInfo = equipcard.GetCardInfo(slotIndex + 1);


		if cardInfo ~= nil then
			ui.SysMsg(ClMsg("AlreadyEquippedThatCardSlot"));
			return;
		end
			
		if item.isLockState == true then
			ui.SysMsg(ClMsg("MaterialItemIsLock"));
			return
		end

		local itemGuid = item:GetIESID();
		local invFrame = ui.GetFrame("inventory");	
		invFrame:SetUserValue("EQUIP_CARD_GUID", itemGuid);
		invFrame:SetUserValue("EQUIP_CARD_SLOTINDEX", slotIndex);	

		if groupNameStr == 'LEG' then
			local pcEtc = GetMyEtcObject();
			if pcEtc.IS_LEGEND_CARD_OPEN ~= 1 then
				ui.SysMsg(ClMsg("LegendCard_Slot_NotOpen"))
				return
			end	

			REQUEST_EQUIP_CARD_TX();
		else
			REQUEST_EQUIP_CARD_TX();
		end
	end
end

function NOCHECK_EQUIP_CARDSLOT_INFO_OPEN(slotIndex)
	EQUIP_CARDSLOT_INFO_OPEN_OLD(slotIndex)

	EQUIP_CARDSLOT_BTN_REMOVE_WITHOUT_EFFECT(frame, nil)

end
--[[
function EQUIP_CARDSLOT_INFO_OPEN(slotIndex)
	local other_frame = ui.GetFrame('equip_cardslot_info_goddess')
	other_frame:ShowWindow(0)

	local frame = ui.GetFrame('equip_cardslot_info');
	
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

	local multiValue = 64;	-- 꽉 찬 카드 이미지를 하고 싶다면 90 으로. (단, 카드레벨 하락 정보가 잘 안보일 수 있음.)
	local star_bg = GET_CHILD(frame, "star_bg");
	local cardStar_Before = GET_CHILD(star_bg, "cardStar_Before");
	local imgSize = frame:GetUserConfig('starSize');
	if cardLv <= 1 then	
		multiValue = 90;
		cardStar_Before:SetVisible(0);
	else
		cardStar_Before:SetTextByKey("value", GET_STAR_TXT(imgSize, cardLv, cls));
		cardStar_Before:SetVisible(1);
	end;

	-- 카드 크기 변환.
--	card_img:Resize(3 * multiValue, 4 * multiValue);

	-- 제거되는 효과 표시하는 곳. 
	local removedEffect =  string.format("%s{/}", cls.Desc);	
	if cls.Desc == "None" then
		removedEffect = "{/}";
	end

	local needSilverText = GET_CHILD_RECURSIVELY(frame, "button_3")
	local needSilver = tonumber(CALC_NEED_SILVER(cls, cardLv))
	needSilverText:SetTextByKey("needSilver", GET_COMMAED_STRING(needSilver))
	local bg = GET_CHILD(frame, "bg");
	local effect_info = GET_CHILD(bg, "effect_info");
	effect_info:SetTextByKey("RemovedEffect", removedEffect);
	
	-- 정보창 위치를 인벤 옆으로 붙힘.
	frame:SetOffset(inven:GetX() - frame:GetWidth(), frame:GetY());

	frame:ShowWindow(1);	
end

function BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG(invItem)
	if invItem == nil then
		return;
	end
	
	local invFrame = ui.GetFrame("inventory");	
	local itemobj = GetIES(invItem:GetObject());
	if itemobj == nil then
		return;
	end
	invFrame:SetUserValue("REQ_USE_ITEM_GUID", invItem:GetIESID());
	
	local textmsg = string.format("[ %s ]{nl}%s", itemobj.Name, ScpArgMsg("YESSCP_OPEN_BASIC_MSG"));
	ui.MsgBox_NonNested(textmsg, itemobj.Name, 'REQUEST_SUMMON_BOSS_TX', "None");
	
	return;
end

function CARD_SLOT_EQUIP(slot, item, groupNameStr)
	local obj = GetIES(item:GetObject());
	if obj.GroupName == "Card" then			
		local slotIndex = CARD_SLOT_GET_SLOT_INDEX(groupNameStr, slot:GetSlotIndex());
		local cardInfo = equipcard.GetCardInfo(slotIndex + 1);


		if cardInfo ~= nil then
			ui.SysMsg(ClMsg("AlreadyEquippedThatCardSlot"));
			return;
		end
			
		if item.isLockState == true then
			ui.SysMsg(ClMsg("MaterialItemIsLock"));
			return
		end

		local itemGuid = item:GetIESID();
		local invFrame = ui.GetFrame("inventory");	
		invFrame:SetUserValue("EQUIP_CARD_GUID", itemGuid);
		invFrame:SetUserValue("EQUIP_CARD_SLOTINDEX", slotIndex);	

		if groupNameStr == 'LEG' then
			local pcEtc = GetMyEtcObject();
			if pcEtc.IS_LEGEND_CARD_OPEN ~= 1 then
				ui.SysMsg(ClMsg("LegendCard_Slot_NotOpen"))
				return
			end	

			local textmsg = string.format("[ %s ]{nl}%s", obj.Name, ScpArgMsg("AreYouSureEquipCard"));	
			ui.MsgBox_NonNested(textmsg, invFrame:GetName(), "REQUEST_EQUIP_CARD_TX", "REQUEST_EQUIP_CARD_CANCLE");		
		else
			REQUEST_EQUIP_CARD_TX();
		end
	end
end

]]
