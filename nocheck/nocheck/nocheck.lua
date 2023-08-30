-- v1.0.5 SetupHookの競合を修正
-- v1.0.6 帰属解除スキップのバグ修正
-- v1.0.7 チャンネルチェンジバグ修正
local addonName = "NOCHECK"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.7"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsDirLoc = string.format("../addons/%s", addonNameLower)
g.settingsFileLoc = string.format("%s/settings.json", g.settingsDirLoc)

local acutil = require("acutil")
local base = {}

function NOCHECK_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.SetupHook(NOCHECK_BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG, "BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG")
    g.SetupHook(NOCHECK_CARD_SLOT_EQUIP, "CARD_SLOT_EQUIP")
    g.SetupHook(NOCHECK_EQUIP_CARDSLOT_INFO_OPEN, "EQUIP_CARDSLOT_INFO_OPEN");
    g.SetupHook(NOCHECK_EQUIP_GODDESSCARDSLOT_INFO_OPEN, "EQUIP_GODDESSCARDSLOT_INFO_OPEN")
    g.SetupHook(NOCHECK_GODDESS_MGR_SOCKET_REQ_GEM_REMOVE, "GODDESS_MGR_SOCKET_REQ_GEM_REMOVE")
    g.SetupHook(NOCHECK_UNLOCK_TRANSMUTATIONSPREADER_BELONGING_SCROLL_EXEC_ASK_AGAIN,
                "UNLOCK_TRANSMUTATIONSPREADER_BELONGING_SCROLL_EXEC_ASK_AGAIN")
    g.SetupHook(NOCHECK_UNLOCK_ACC_BELONGING_SCROLL_EXEC_ASK_AGAIN, "UNLOCK_ACC_BELONGING_SCROLL_EXEC_ASK_AGAIN")
    g.SetupHook(NOCHECK_SELECT_ZONE_MOVE_CHANNEL, "SELECT_ZONE_MOVE_CHANNEL")
    g.SetupHook(NOCHECK_BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN, "BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN")

    -- CHAT_SYSTEM("NOCHECK loaded")
    -- NOCHECK_FRAME_INIT()

end

-- カードブック使用時の確認削除
function NOCHECK_BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN(invItem)
    if invItem == nil then
        return;
    end

    local invFrame = ui.GetFrame("inventory");
    local itemobj = GetIES(invItem:GetObject());
    if itemobj == nil then
        return;
    end
    invFrame:SetUserValue("REQ_USE_ITEM_GUID", invItem:GetIESID());

    if itemobj.Script == 'SCR_SUMMON_MONSTER_FROM_CARDBOOK' then
        if _G.BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN == nil then
            CHAT_SYSTEM("nai")
        else
            CHAT_SYSTEM("aru")
        end
        REQUEST_SUMMON_BOSS_TX()
        return;
    elseif itemobj.Script == 'SCR_QUEST_CLEAR_LEGEND_CARD_LIFT' then
        local textmsg = string.format("[ %s ]{nl}%s", itemobj.Name, ScpArgMsg("Use_Item_LegendCard_Slot_Open2"));
        ui.MsgBox_NonNested(textmsg, itemobj.Name, "REQUEST_SUMMON_BOSS_TX", "None");
        return;
    end

    -- base["BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN"](invItem)
end

-- チャンネル移動時の確認を削除
function NOCHECK_SELECT_ZONE_MOVE_CHANNEL(index, channelID)
    local zoneInsts = session.serverState.GetMap();
    if zoneInsts == nil or zoneInsts.pcCount == -1 then
        ui.SysMsg(ClMsg("ChannelIsClosed"));
        return;
    end

    local pc = GetMyPCObject();
    if IS_BOUNTY_BATTLE_BUFF_APPLIED(pc) == 1 then
        ui.SysMsg(ClMsg("DoingBountyBattle"));
        return;

    end
    --[[
    if _G.SELECT_ZONE_MOVE_CHANNEL == nil then
        CHAT_SYSTEM("nai")
    else
        CHAT_SYSTEM("aru")
    end
    ]]
    -- base["SELECT_ZONE_MOVE_CHANNEL"](index, channelID)
    -- local msg = ScpArgMsg("ReallyMoveToChannel_{Channel}", "Channel", channelID + 1);
    ReserveScript(string.format("RUN_GAMEEXIT_TIMER(\"Channel\", %d)", channelID), 0.5);
    -- ReserveScript(string.format("CLICK_EXCHANGE_SHOP_CATEGORY('%s','%s','%s',%d)", ctrlSet, ctrl, strArg, numArg), 0.2)
    -- ui.MsgBox(msg, scpString, "None");

end

-- ゴッデスアクセ帰属解除時の簡易化
function NOCHECK_UNLOCK_ACC_BELONGING_SCROLL_EXEC_ASK_AGAIN(frame, btn)
    --[[
    if _G.UNLOCK_ACC_BELONGING_SCROLL_EXEC_ASK_AGAIN == nil then
        CHAT_SYSTEM("nai")
    else
        CHAT_SYSTEM("aru")
    end
    ]]
    -- CHAT_SYSTEM("Hi")
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
    local yesscp = 'NOCHECK_UNLOCK_ACC_BELONGING_SCROLL_EXEC'
    ui.MsgBox(clmsg, yesscp, "None");

    -- base["UNLOCK_ACC_BELONGING_SCROLL_EXEC_ASK_AGAIN"](frame, btn)
end

function NOCHECK_UNLOCK_ACC_BELONGING_SCROLL_EXEC()
    local frame = ui.GetFrame("unlock_acc_belonging");
    imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_EVENT_EXEC"));
    frame:SetUserValue("EnableTranscendButton", 0);

    local slot = GET_CHILD(frame, "slot");
    local targetItem = GET_SLOT_ITEM(slot);
    local scrollGuid = frame:GetUserValue("ScrollGuid")

    session.ResetItemList();
    session.AddItemID(targetItem:GetIESID());
    session.AddItemID(scrollGuid);
    local resultlist = session.GetItemIDList();
    item.DialogTransaction("ITEM_UNLOCK_ACC_BELONGING_SCROLL", resultlist);

    imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_CAST"));

    ReserveScript("UNLOCK_ACC_BELONGING_SCROLL_CLOSE()", 1.0)
    return
end

-- ゴッデス装備帰属解除時の簡易化
function NOCHECK_UNLOCK_TRANSMUTATIONSPREADER_BELONGING_SCROLL_EXEC_ASK_AGAIN(frame, btn)
    -- CHAT_SYSTEM("Hi2")
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
    local yesscp = 'NOCHECK_UNLOCK_TRANSMUTATIONSPREADER_BELONGING_SCROLL_EXEC'
    ui.MsgBox(clmsg, yesscp, "None");

    -- base["UNLOCK_TRANSMUTATIONSPREADER_BELONGING_SCROLL_EXEC_ASK_AGAIN"](frame, btn)
end

function NOCHECK_UNLOCK_TRANSMUTATIONSPREADER_BELONGING_SCROLL_EXEC()
    local frame = ui.GetFrame("unlock_transmutationspreader_belonging");
    imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_EVENT_EXEC"));
    frame:SetUserValue("EnableTranscendButton", 0);

    local slot = GET_CHILD(frame, "slot");
    local targetItem = GET_SLOT_ITEM(slot);
    local scrollGuid = frame:GetUserValue("ScrollGuid")

    session.ResetItemList();
    session.AddItemID(targetItem:GetIESID());
    session.AddItemID(scrollGuid);
    local resultlist = session.GetItemIDList();
    item.DialogTransaction("ITEM_UNLOCK_TRANSMUTATIONSPREADER_BELONGING_SCROLL", resultlist);

    imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_CAST"));

    ReserveScript("UNLOCK_TRANSMUTATIONSPREADER_BELONGING_SCROLL_CLOSE()", 1.0)
    return
end

-- エーテルジェム着脱時のメッセージ非表示
function NOCHECK_GODDESS_MGR_SOCKET_REQ_GEM_REMOVE(parent, btn)
    --[[
    if _G.GODDESS_MGR_SOCKET_REQ_GEM_REMOVE == nil then
        CHAT_SYSTEM("nai")
    else
        CHAT_SYSTEM("aru")
    end
    ]]
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

    -- base["GODDESS_MGR_SOCKET_REQ_GEM_REMOVE"](parent, btn)

end

-- 欠片アイテム他使用時のメッセージボックス非表示
function NOCHECK_BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG(invItem)
    --[[
    if _G.BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG == nil then
        CHAT_SYSTEM("nai")
    else
        CHAT_SYSTEM("aru")
    end
]]
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
    -- base["BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG"](invItem)
    return;
end

-- レジェンドカード装着時のメッセージボックス非表示
function NOCHECK_CARD_SLOT_EQUIP(slot, item, groupNameStr)
    --[[
    if _G.CARD_SLOT_EQUIP == nil then
        CHAT_SYSTEM("nai")
    else
        CHAT_SYSTEM("aru")
    end
]]
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
            -- g.NOCHECK_CARD_SLOT_EQUIP(slot, item, groupNameStr)
            REQUEST_EQUIP_CARD_TX();
        else
            -- g.NOCHECK_CARD_SLOT_EQUIP(slot, item, groupNameStr)
            REQUEST_EQUIP_CARD_TX();
        end
    end

end

function NOCHECK_EQUIP_CARDSLOT_INFO_OPEN(slotIndex)
    --[[
    if _G.EQUIP_CARDSLOT_INFO_OPEN == nil then
        CHAT_SYSTEM("nai")
    else
        CHAT_SYSTEM("aru")
    end
    ]]
    -- EQUIP_CARDSLOT_INFO_OPEN_OLD(slotIndex)
    -- local slv = tonumber(GET_TOTAL_MONEY_STR());
    -- local cardslv = tonumber(cardLv * 2000)
    -- if slv < cardslv then
    -- ui.SysMsg("Not enough silver.")
    -- return
    -- else

    NOCHECK_EQUIP_CARDSLOT_BTN_REMOVE_WITHOUT_EFFECT()
    -- end

    base[EQUIP_CARDSLOT_INFO_OPEN](slotIndex)
end

function NOCHECK_EQUIP_GODDESSCARDSLOT_INFO_OPEN(slotIndex)
    --[[
    if _G.EQUIP_GODDESSCARDSLOT_INFO_OPEN == nil then
        CHAT_SYSTEM("nai")
    else
        CHAT_SYSTEM("aru")
    end
]]
    NOCHECK_EQUIP_GODDESSCARDSLOT_BTN_REMOVE()
    base["EQUIP_GODDESSCARDSLOT_INFO_OPEN"](slotIndex)

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

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName];
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

-- レジェンドカード装着時のメッセージボックス非表示ここまで
--[[
local success, err = pcall(function()
    
end)

if not success then
    -- エラーが発生した場合の処理
    print("Error: " .. err)
end


function BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN(invItem)	
	if invItem == nil then
		return;
	end

	local invFrame = ui.GetFrame("inventory");	
	local itemobj = GetIES(invItem:GetObject());
	if itemobj == nil then
		return;
	end
	invFrame:SetUserValue("REQ_USE_ITEM_GUID", invItem:GetIESID());
	
	if itemobj.Script == 'SCR_SUMMON_MONSTER_FROM_CARDBOOK' then
		local textmsg = string.format("[ %s ]{nl}%s", itemobj.Name, ScpArgMsg("Card_Summon_check_Use"));
		ui.MsgBox_NonNested(textmsg, itemobj.Name, "REQUEST_SUMMON_BOSS_TX", "None");
		return;
	elseif itemobj.Script == 'SCR_QUEST_CLEAR_LEGEND_CARD_LIFT' then
		local textmsg = string.format("[ %s ]{nl}%s", itemobj.Name, ScpArgMsg("Use_Item_LegendCard_Slot_Open2"));
		ui.MsgBox_NonNested(textmsg, itemobj.Name, "REQUEST_SUMMON_BOSS_TX", "None");
		return;
	end
end

]]
