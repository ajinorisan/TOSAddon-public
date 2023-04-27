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
    --acutil.setupHook(NOCHECK_EQUIP_GODDESSCARDSLOT_BTN_REMOVE, "EQUIP_GODDESSCARDSLOT_BTN_REMOVE")
    --acutil.setupHook(NOCHECK_EQUIP_CARD_SLOT_RBTNUP_ITEM_INFO, "CARD_SLOT_RBTNUP_ITEM_INFO")
    CHAT_SYSTEM("NOCHECK loaded")

end

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

function NOCHECK_EQUIP_GODDESSCARDSLOT_BTN_REMOVE(frame)
	local argStr = string.format("%d", frame:GetUserIValue("REMOVE_CARD_SLOTINDEX"))

	argStr = argStr .. " 0"

	SCR_TX_UNEQUIP_CARD_SLOT()
end

function NOCHECK_CARD_SLOT_RBTNUP_ITEM_INFO(frame, slot, argStr, argNum)
	local icon = slot:GetIcon();		
	if icon == nil then		
		return;		
	end;

	local parentSlotSet = slot:GetParent()
	if parentSlotSet == nil then
		return
	end
		
	local groupName = string.gsub(parentSlotSet:GetName(), 'card_slotset', '');
	local slotIndex = CARD_SLOT_GET_SLOT_INDEX(groupName, slot:GetSlotIndex()) 

	if groupName == 'LEG' then
	    --argStr = slotIndex .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
		pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr);
	else
		--argStr = slotIndex .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
		pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr);
	end
end

--[[
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

function EQUIP_GODDESSCARDSLOT_BTN_REMOVE(frame)
	local argStr = string.format("%d", frame:GetUserIValue("REMOVE_CARD_SLOTINDEX"))

	argStr = argStr .. " 0"

	pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)
end

function CARD_SLOT_RBTNUP_ITEM_INFO(frame, slot, argStr, argNum)
	local icon = slot:GetIcon();		
	if icon == nil then		
		return;		
	end;

	local parentSlotSet = slot:GetParent()
	if parentSlotSet == nil then
		return
	end
		
	local groupName = string.gsub(parentSlotSet:GetName(), 'card_slotset', '');
	local slotIndex = CARD_SLOT_GET_SLOT_INDEX(groupName, slot:GetSlotIndex()) 

	if groupName == 'LEG' then
	EQUIP_CARDSLOT_INFO_OPEN(slotIndex);
	else
		argStr = slotIndex .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
		pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr);
	end
end
]]
