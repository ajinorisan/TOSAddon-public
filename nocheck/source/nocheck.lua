local addonName = "NOCHECK"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.1"

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
    acutil.setupHook(NOCHECK_EQUIP_CARDSLOT_INFO_OPEN, "EQUIP_CARDSLOT_INFO_OPEN");
    acutil.setupHook(NOCHECK_EQUIP_GODDESSCARDSLOT_INFO_OPEN, "EQUIP_GODDESSCARDSLOT_INFO_OPEN")
    acutil.setupHook(NOCHECK_GODDESS_MGR_SOCKET_REQ_GEM_REMOVE, "GODDESS_MGR_SOCKET_REQ_GEM_REMOVE")
    acutil.setupHook(NOCHECK_GODDESS_MGR_SOCKET_OPEN, "GODDESS_MGR_SOCKET_OPEN")
    acutil.setupHook(NOCHECK_GODDESS_MGR_REFORGE_OPEN, "GODDESS_MGR_REFORGE_OPEN")
    acutil.setupHook(NOCHECK_UNLOCK_TRANSMUTATIONSPREADER_BELONGING_SCROLL_EXEC_ASK_AGAIN,
        "UNLOCK_TRANSMUTATIONSPREADER_BELONGING_SCROLL_EXEC_ASK_AGAIN")
    acutil.setupHook(NOCHECK_UNLOCK_ACC_BELONGING_SCROLL_EXEC_ASK_AGAIN, "UNLOCK_ACC_BELONGING_SCROLL_EXEC_ASK_AGAIN")

    CHAT_SYSTEM("NOCHECK loaded")
    -- NOCHECK_FRAME_INIT()

end

function NOCHECK_UNLOCK_ACC_BELONGING_SCROLL_EXEC_ASK_AGAIN(frame, btn)
    local scrollType = frame:GetUserValue("ScrollType")
    local clickable = frame:GetUserValue("EnableTranscendButton")
    if tonumber(clickable) ~= 1 then
        return;
    end

    local slot = GET_CHILD(frame, "slot");
    local invItem = GET_SLOT_ITEM(slot);
    if invItem == nil then
        ui.MsgBox(ScpArgMsg("DropItemPlz"));
        imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_BTN_OVER_SOUND"));
        return;
    end

    local itemObj = GetIES(invItem:GetObject());

    local scrollGuid = frame:GetUserValue("ScrollGuid")
    local scrollInvItem = session.GetInvItemByGuid(scrollGuid);
    if scrollInvItem == nil then
        return;
    end
    local clmsg = ScpArgMsg("ReallyUnlockBelonging")
    local yesscp = 'UNLOCK_ACC_BELONGING_SCROLL_EXEC'
    ui.MsgBox(clmsg, yesscp, "None");
end

-- ゴッデス装備帰属解除時の簡易化
function NOCHECK_UNLOCK_TRANSMUTATIONSPREADER_BELONGING_SCROLL_EXEC_ASK_AGAIN(frame, btn)
    local scrollType = frame:GetUserValue("ScrollType")
    local clickable = frame:GetUserValue("EnableTranscendButton")
    if tonumber(clickable) ~= 1 then
        return;
    end

    local slot = GET_CHILD(frame, "slot");
    local invItem = GET_SLOT_ITEM(slot);
    if invItem == nil then
        ui.MsgBox(ScpArgMsg("DropItemPlz"));
        imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_BTN_OVER_SOUND"));
        return;
    end

    local itemObj = GetIES(invItem:GetObject());

    local scrollGuid = frame:GetUserValue("ScrollGuid")
    local scrollInvItem = session.GetInvItemByGuid(scrollGuid);
    if scrollInvItem == nil then
        return;
    end
    local clmsg = ScpArgMsg("ReallyUnlockBelonging")
    local yesscp = 'UNLOCK_TRANSMUTATIONSPREADER_BELONGING_SCROLL_EXEC'
    ui.MsgBox(clmsg, yesscp, "None");
end

--[[ エーテルジェム自動着脱作りかけ
function NOCHECK_FRAME_INIT()
   local inveframe = ui.GetFrame('inventory')
   local button = inveframe:CreateOrGetControl("button", "equip", 10, 10, 100, 30)
   button:SetText("equip")
   button:ShowWindow(1)
end


function NOCHECK_GODDESS_MGR_REFORGE_OPEN(frame)
    -- GODDESS_MGR_REFORGE_CLEAR(frame)
    INVENTORY_SET_CUSTOM_RBTNDOWN('GODDESS_MGR_REFORGE_INV_RBTN')
end

function NOCHECK_GODDESS_MGR_SOCKET_OPEN(frame)
    INVENTORY_SET_CUSTOM_RBTNDOWN('GODDESS_MGR_SOCKET_INV_RBTN')
    -- GODDESS_MGR_SOCKET_CLEAR(frame)
end
]]
-- エーテルジェム着脱時のメッセージ非表示
function NOCHECK_GODDESS_MGR_SOCKET_REQ_GEM_REMOVE(parent, btn)
    local frame = parent:GetTopParentFrame()
    local slot = GET_CHILD_RECURSIVELY(frame, 'socket_slot')
    local guid = slot:GetUserValue('ITEM_GUID')
    if guid ~= 'None' then
        local index = parent:GetUserValue('SLOT_INDEX')

        local inv_item = session.GetInvItemByGuid(guid)
        if inv_item == nil then
            return
        end

        local item_obj = GetIES(inv_item:GetObject())
        local item_name = dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'None'))

        local gem_id = inv_item:GetEquipGemID(index)
        local gem_cls = GetClassByType('Item', gem_id)
        local gem_numarg1 = TryGetProp(gem_cls, 'NumberArg1', 0)
        local price = gem_numarg1 * 100
        local clmsg = 'None'

        local msg_cls_name = ''

        if TryGetProp(gem_cls, 'GemType', 'None') == 'Gem_High_Color' then
            -- msg_cls_name = 'ReallyRemoveGem_AetherGem'
            -- clmsg = "[" .. item_name .. "]" .. ScpArgMsg(msg_cls_name) .. tostring(price)
            _GODDESS_MGR_SOCKET_REQ_GEM_REMOVE(index)
            -- GODDESS_MGR_SOCKET_REQ_GEM_REMOVE_OLD(parent, btn)
        else
            local pc = GetMyPCObject();
            local isGemRemoveCare = IS_GEM_EXTRACT_FREE_CHECK(pc)

            local free_gem = nil
            for optionIdx = 1, 4 do
                free_gem = GET_GEM_PROPERTY_TEXT(item_obj, optionIdx, index)
                if free_gem ~= nil then
                    _GODDESS_MGR_SOCKET_REQ_GEM_REMOVE(index)
                    return
                end
            end

            if isGemRemoveCare == true then
                msg_cls_name = "ReallyRemoveGem_Care"
            else
                msg_cls_name = "ReallyRemoveGem"
            end

            local clmsg = "'" .. item_name .. ScpArgMsg("Auto_'_SeonTaeg") .. ScpArgMsg(msg_cls_name)
            local yesscp = string.format('_GODDESS_MGR_SOCKET_REQ_GEM_REMOVE(%s)', index)
            local msgbox = ui.MsgBox(clmsg, yesscp, '')
            SET_MODAL_MSGBOX(msgbox)
        end
    end
end

-- 欠片アイテム他使用時のメッセージボックス非表示
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
    -- BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG_OLD(invItem)

    return;
end

-- レジェンドカード装着時のメッセージボックス非表示
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
    -- EQUIP_CARDSLOT_INFO_OPEN_OLD(slotIndex)
    -- local slv = tonumber(GET_TOTAL_MONEY_STR());
    -- local cardslv = tonumber(cardLv * 2000)
    -- if slv < cardslv then
    -- ui.SysMsg("Not enough silver.")
    -- return
    -- else

    NOCHECK_EQUIP_CARDSLOT_BTN_REMOVE_WITHOUT_EFFECT()
    -- end

    EQUIP_CARDSLOT_INFO_OPEN_OLD(slotIndex)
end

function NOCHECK_EQUIP_GODDESSCARDSLOT_INFO_OPEN(slotIndex)

    NOCHECK_EQUIP_GODDESSCARDSLOT_BTN_REMOVE()

    EQUIP_GODDESSCARDSLOT_INFO_OPEN_OLD(slotIndex)
end

function NOCHECK_EQUIP_CARDSLOT_BTN_REMOVE_WITHOUT_EFFECT()
    local legcardslot = 13
    local frame = ui.GetFrame("monstercardslot")
    local argStr = legcardslot - 1

    argStr = argStr .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
    pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)

end

function NOCHECK_EQUIP_GODDESSCARDSLOT_BTN_REMOVE()

    local legcardslot = 14
    local frame = ui.GetFrame("monstercardslot")
    local argStr = legcardslot - 1

    argStr = argStr .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
    pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)

end
-- レジェンドカード装着時のメッセージボックス非表示ここまで
--[[
local success, err = pcall(function()
    
end)

if not success then
    -- エラーが発生した場合の処理
    print("Error: " .. err)
end
]]

