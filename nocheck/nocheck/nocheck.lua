-- v1.0.5 SetupHookの競合を修正
-- v1.0.6 帰属解除スキップのバグ修正
-- v1.0.7 チャンネルチェンジバグ修正
-- v1.0.8 継承とか入れるのをスキップ
-- v1.0.9 「今すぐこわす」をセット
-- v1.1.0 とりあえずmsgをインプットする系は全部セットする様に出来たと思うけど知らん
-- v1.1.1 ラダコレクション連続強化するように。速すぎてミス注意。
-- v1.1.2 継承とか入力出来なかったの修正。テストコードそのまま放置してたのが原因
-- v1.1.3 コレクション強化の際に節目の強化値で一度確認する様に変更。WARNINGBOXの一部がバグるらしいので一時無効化コマンド追加
-- v1.1.4 コレクション強化の挙動安定してなかったの直したハズ。むずかった
-- v1.1.5 WARNINGBOXバグってたので修正。
-- v1.1.6 コレクション強化の挙動が安定しなかったのでシンプルに戻した。
-- v1.1.7 コレクション強化520に対応。金床の挙動安定化再挑戦。
-- v1.1.8 コレクション強化520に対応。1.1.6の挙動のまま
-- v1.1.9 金床はなんでもノーチェックに。インベントリにonoff付けた。クエとかでバグるらしいので、街以外ではOFFに。アイテム連続使用のフレーム作った
local addonName = "NOCHECK"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.1.9"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settings_file_location = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")
local base = {}

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName];
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

function g.mkdir_new_folder()
    local folder_path = string.format("../addons/%s", addonNameLower)
    local file_path = string.format("../addons/%s/mkdir.txt", addonNameLower)
    local file = io.open(file_path, "r")
    if not file then
        os.execute('mkdir "' .. folder_path .. '"')
        file = io.open(file_path, "w")
        if file then
            file:write("A new file has been created")
            file:close()
        end
    else
        file:close()
    end
end
g.mkdir_new_folder()

-- 欠片アイテム他使用時のメッセージボックス非表示
function NOCHECK_BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG(invItem)
    if g.settings.use == 1 then
        NOCHECK_BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG_(invItem)
    else
        base["BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG"](invItem)
    end
end

function NOCHECK_BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG_(invItem)
    if invItem == nil then
        return
    end
    local itemobj = GetIES(invItem:GetObject());
    if itemobj == nil then
        return;
    end
    local frame = ui.GetFrame("inventory");
    frame:SetUserValue("REQ_USE_ITEM_GUID", invItem:GetIESID());
    REQUEST_SUMMON_BOSS_TX()
    return
end

-- レジェンドカード装着時のメッセージボックス非表示
function NOCHECK_CARD_SLOT_EQUIP(slot, item, groupNameStr)
    if g.settings.use == 1 then
        NOCHECK_CARD_SLOT_EQUIP_(slot, item, groupNameStr)
    else
        base["CARD_SLOT_EQUIP"](slot, item, groupNameStr)
    end
end

function NOCHECK_CARD_SLOT_EQUIP_(slot, item, groupNameStr)

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
            local pcEtc = GetMyEtcObject()
            if pcEtc.IS_LEGEND_CARD_OPEN ~= 1 then
                ui.SysMsg(ClMsg("LegendCard_Slot_NotOpen"))
                return
            end
        end
        REQUEST_EQUIP_CARD_TX()
    end
end

-- レジェンドカード脱着時
function NOCHECK_EQUIP_CARDSLOT_INFO_OPEN(slotIndex)

    if g.settings.use == 1 then
        NOCHECK_EQUIP_CARDSLOT_BTN_REMOVE_WITHOUT_EFFECT(slotIndex)
    else
        base[EQUIP_CARDSLOT_INFO_OPEN](slotIndex)
    end
end
function NOCHECK_EQUIP_CARDSLOT_BTN_REMOVE_WITHOUT_EFFECT(slotIndex)

    local frame = ui.GetFrame("monstercardslot")
    local argStr = slotIndex

    argStr = argStr .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
    pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)

end

-- ゴッデスカード脱着時
function NOCHECK_EQUIP_GODDESSCARDSLOT_INFO_OPEN(slotIndex)
    if g.settings.use == 1 then
        NOCHECK_EQUIP_GODDESSCARDSLOT_BTN_REMOVE(slotIndex)
    else
        base["EQUIP_GODDESSCARDSLOT_INFO_OPEN"](slotIndex)
    end
end

function NOCHECK_EQUIP_GODDESSCARDSLOT_BTN_REMOVE(slotIndex)
    local frame = ui.GetFrame("monstercardslot")
    local argStr = slotIndex
    argStr = argStr .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
    pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)
end

-- エーテルジェム着脱時のメッセージ非表示
function NOCHECK_GODDESS_MGR_SOCKET_REQ_GEM_REMOVE(parent, btn)
    if g.settings.use == 1 then
        NOCHECK_GODDESS_MGR_SOCKET_REQ_GEM_REMOVE_(parent, btn)
    else
        base["GODDESS_MGR_SOCKET_REQ_GEM_REMOVE"](parent, btn)
    end

end

function NOCHECK_GODDESS_MGR_SOCKET_REQ_GEM_REMOVE_(parent, btn)

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
            _GODDESS_MGR_SOCKET_REQ_GEM_REMOVE(index)
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

-- ゴッデス装備帰属解除時の簡易化
function NOCHECK_UNLOCK_TRANSMUTATIONSPREADER_BELONGING_SCROLL_EXEC_ASK_AGAIN(frame, btn)
    if g.settings.use == 1 then
        NOCHECK_UNLOCK_TRANSMUTATIONSPREADER_BELONGING_SCROLL_EXEC_ASK_AGAIN_(frame, btn)
    else
        base["UNLOCK_TRANSMUTATIONSPREADER_BELONGING_SCROLL_EXEC_ASK_AGAIN"](frame, btn)
    end
end

function NOCHECK_UNLOCK_TRANSMUTATIONSPREADER_BELONGING_SCROLL_EXEC_ASK_AGAIN_(frame, btn)
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

-- ゴッデスアクセ帰属解除時の簡易化
function NOCHECK_UNLOCK_ACC_BELONGING_SCROLL_EXEC_ASK_AGAIN(frame, btn)
    if g.settings.use == 1 then
        NOCHECK_UNLOCK_ACC_BELONGING_SCROLL_EXEC_ASK_AGAIN_(frame, btn)
    else
        base["UNLOCK_ACC_BELONGING_SCROLL_EXEC_ASK_AGAIN"](frame, btn)
    end
end

function NOCHECK_UNLOCK_ACC_BELONGING_SCROLL_EXEC_ASK_AGAIN_(frame, btn)

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

-- チャンネル移動時の確認を削除
function NOCHECK_SELECT_ZONE_MOVE_CHANNEL(index, channelID)
    if g.settings.use == 1 then
        NOCHECK_SELECT_ZONE_MOVE_CHANNEL_(index, channelID)
    else
        base["SELECT_ZONE_MOVE_CHANNEL"](index, channelID)
    end
end

function NOCHECK_SELECT_ZONE_MOVE_CHANNEL_(index, channelID)
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
    local channelName = "Channel"
    ReserveScript(string.format("RUN_GAMEEXIT_TIMER(%q, %d)", channelName, channelID), 0.5);
end

-- カードブック使用時の確認削除
function NOCHECK_BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN(invItem)
    if g.settings.use == 1 then
        NOCHECK_BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN_(invItem)
    else
        base["BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN"](invItem)
    end
end

function NOCHECK_BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN_(invItem)
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

        REQUEST_SUMMON_BOSS_TX()
        return
    elseif itemobj.Script == 'SCR_QUEST_CLEAR_LEGEND_CARD_LIFT' then
        local textmsg = string.format("[ %s ]{nl}%s", itemobj.Name, ScpArgMsg("Use_Item_LegendCard_Slot_Open2"));
        ui.MsgBox_NonNested(textmsg, itemobj.Name, "REQUEST_SUMMON_BOSS_TX", "None");
        return;
    end
end

function NOCHECK_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()

    nocheck_load_settings()

    addon:RegisterMsg("GAME_START", "nocheck_inventory_frame_init")

    g.SetupHook(NOCHECK_BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG, "BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG") --
    g.SetupHook(NOCHECK_CARD_SLOT_EQUIP, "CARD_SLOT_EQUIP") --
    g.SetupHook(NOCHECK_EQUIP_CARDSLOT_INFO_OPEN, "EQUIP_CARDSLOT_INFO_OPEN");
    g.SetupHook(NOCHECK_EQUIP_GODDESSCARDSLOT_INFO_OPEN, "EQUIP_GODDESSCARDSLOT_INFO_OPEN")
    g.SetupHook(NOCHECK_GODDESS_MGR_SOCKET_REQ_GEM_REMOVE, "GODDESS_MGR_SOCKET_REQ_GEM_REMOVE")
    g.SetupHook(NOCHECK_UNLOCK_TRANSMUTATIONSPREADER_BELONGING_SCROLL_EXEC_ASK_AGAIN,
        "UNLOCK_TRANSMUTATIONSPREADER_BELONGING_SCROLL_EXEC_ASK_AGAIN")
    g.SetupHook(NOCHECK_UNLOCK_ACC_BELONGING_SCROLL_EXEC_ASK_AGAIN, "UNLOCK_ACC_BELONGING_SCROLL_EXEC_ASK_AGAIN")
    g.SetupHook(NOCHECK_SELECT_ZONE_MOVE_CHANNEL, "SELECT_ZONE_MOVE_CHANNEL")
    g.SetupHook(NOCHECK_BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN, "BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN")

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        g.settings.use = g.settings.use or 0
        addon:RegisterMsg("FPS_UPDATE", "NOCHECK_WARNINGMSGBOX_FRAME_OPEN")
        addon:RegisterMsg("FPS_UPDATE", "NOCHECK_WARNINGMSGBOX_EX_FRAME_OPEN_FPS")
        acutil.setupEvent(addon, "MORU_LBTN_CLICK", "NOCHECK_MORU_LBTN_CLICK");
    else
        g.settings.use = 0
    end

end

function nocheck_save_settings()
    acutil.saveJSON(g.settings_file_location, g.settings)
end

function nocheck_load_settings()
    local settings = acutil.loadJSON(g.settings_file_location)
    if not settings then
        settings = {
            use = 1
        }
    end
    g.settings = settings
    nocheck_save_settings()
end

function nocheck_inventory_btnup(frame, ctrl, str, num)
    if g.settings.use == 1 then
        ctrl:SetSkinName("test_gray_button")
        g.settings.use = 0
        ctrl:SetTextTooltip("{ol}No Check ON{nl}LeftClick:On Off switch")
        ctrl:SetEventScript(ui.RBUTTONUP, "")
    else
        ctrl:SetSkinName("test_pvp_btn")
        g.settings.use = 1
        ctrl:SetTextTooltip("{ol}No Check ON{nl}LeftClick:On Off switch{nl}RightClick:Continuous item use frame")
        ctrl:SetEventScript(ui.RBUTTONUP, "nocheck_inventory_continuous_use_frame")
    end
    nocheck_save_settings()
end

function nocheck_inv_rbtn(itemObj, slot)
    local icon = slot:GetIcon()
    local iconInfo = icon:GetInfo()
    local clsid = iconInfo.type
    local inv_item = session.GetInvItemByType(clsid)

    local frame = ui.GetFrame(addonNameLower .. "continuous_use")
    local item_slot = GET_CHILD(frame, "item_slot")
    local item_cls = GetClassByType("Item", clsid)
    item_slot:SetUserValue("CLASS_ID", clsid)
    SET_SLOT_ITEM_CLS(item_slot, item_cls)
    SET_SLOT_ITEM_TEXT(item_slot, inv_item, item_cls)
end

function nocheck_inventory_continuous_use_frame_close(frame, ctrl, str, num)
    local frame = ui.GetFrame(addonNameLower .. "continuous_use")
    frame:ShowWindow(0)
    INVENTORY_SET_CUSTOM_RBTNDOWN('None')
end

function nocheck_inventory_continuous_use_icon_use(frame)

    local frame = ui.GetFrame(addonNameLower .. "continuous_use")
    local item_slot = GET_CHILD(frame, "item_slot")
    AUTO_CAST(item_slot)
    local clsid = item_slot:GetUserIValue("CLASS_ID")
    if clsid == 0 then
        return
    end

    local inv_item = session.GetInvItemByType(clsid)
    if inv_item ~= nil then
        INV_ICON_USE(inv_item)
        local item_cls = GetClassByType("Item", clsid)
        SET_SLOT_ITEM_CLS(item_slot, item_cls);
        inv_item = session.GetInvItemByType(clsid)
        local count = tonumber(inv_item.count)
        item_slot:SetText("{s18}{ol}{b}" .. count, 'count', ui.RIGHT, ui.BOTTOM, -2, 1);
        frame:Invalidate()
        return 1
    else
        local item_cls = GetClassByType("Item", clsid)
        SET_SLOT_ITEM_CLS(item_slot, item_cls);
        CreateIcon(item_slot):SetColorTone('FFFF0000')
        item_slot:SetText("{s18}{ol}{b}" .. 0, 'count', ui.RIGHT, ui.BOTTOM, -2, 1);
        frame:Invalidate()
        frame:RunUpdateScript("nocheck_inventory_continuous_use_frame_close", 1.0);
        return 0
    end

end

function nocheck_inventory_continuous_use(frame, ctrl, str, num)
    local frame = ui.GetFrame(addonNameLower .. "continuous_use")
    local item_slot = GET_CHILD(frame, "item_slot")
    local clsid = item_slot:GetUserIValue("CLASS_ID")
    local inv_item = session.GetInvItemByType(clsid)

    if inv_item ~= nil then
        local item_cls = GetClassByType("Item", clsid)
        SET_SLOT_ITEM_TEXT(item_slot, inv_item, item_cls)
        frame:RunUpdateScript("nocheck_inventory_continuous_use_icon_use", 1.0);
    end
end

function nocheck_inventory_continuous_use_frame(frame, ctrl, str, num)
    acutil.setupEvent(g.addon, "INVENTORY_CLOSE", "nocheck_inventory_continuous_use_frame_close");
    local inventory = ui.GetFrame("inventory")
    local inv_x = inventory:GetX()
    local continuous_use_frame = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "continuous_use", 0, 0, 0, 0)
    AUTO_CAST(continuous_use_frame)
    continuous_use_frame:SetSkinName("test_win_lastpopup")
    continuous_use_frame:Resize(300, 300)
    continuous_use_frame:SetPos(inv_x - 305, 300)
    continuous_use_frame:RemoveAllChild()
    continuous_use_frame:ShowWindow(1)

    local item_slot = continuous_use_frame:CreateOrGetControl('slot', 'item_slot', 115, 100, 70, 70)
    AUTO_CAST(item_slot)
    item_slot:SetSkinName("slot");
    INVENTORY_SET_CUSTOM_RBTNDOWN("nocheck_inv_rbtn")
    item_slot:SetEventScript(ui.RBUTTONUP, "nocheck_inventory_continuous_use_frame_close")

    local notice = continuous_use_frame:CreateOrGetControl('richtext', 'notice', 30, 180, 0, 0)
    AUTO_CAST(notice)
    notice:SetText(g.lang == "Japanese" and "{ol}{s20}アイテムを連続使用します" or
                       "{ol}{s18}Use the item continuously");

    local continuous_use = continuous_use_frame:CreateOrGetControl('button', 'continuous_use', 40, 220, 100, 50)
    AUTO_CAST(continuous_use)
    continuous_use:SetSkinName("test_red_button")
    continuous_use:SetText(g.lang == "Japanese" and "{ol}{s16}連続使用" or "{ol}{s16}Continu");
    continuous_use:SetEventScript(ui.LBUTTONUP, "nocheck_inventory_continuous_use")

    local cancel = continuous_use_frame:CreateOrGetControl('button', 'cancel', 155, 220, 100, 50)
    AUTO_CAST(cancel)
    cancel:SetSkinName("test_gray_button")
    cancel:SetText(g.lang == "Japanese" and "{ol}{s16}キャンセル" or "{ol}{s16}Cancel");
    cancel:SetEventScript(ui.LBUTTONUP, "nocheck_inventory_continuous_use_frame_close")
end

function nocheck_inventory_frame_init(frame, msg, str, num)
    local frame = ui.GetFrame("inventory")
    local searchSkin = GET_CHILD_RECURSIVELY(frame, "searchSkin")
    searchSkin:Resize(284, 30)
    searchSkin:SetMargin(38, 0, 0, 5)
    local searchGbox = GET_CHILD_RECURSIVELY(frame, "searchGbox")
    local btn = searchGbox:CreateOrGetControl("button", "btn", 160, -3, 35, 38)
    AUTO_CAST(btn)
    if g.settings.use == 1 then
        btn:SetSkinName("test_pvp_btn")
        btn:SetTextTooltip("{ol}No Check ON{nl}LeftClick:On Off switch{nl}RightClick:Continuous item use frame")
        btn:SetEventScript(ui.RBUTTONUP, "nocheck_inventory_continuous_use_frame")
    else
        btn:SetSkinName("test_gray_button")
        btn:SetTextTooltip("{ol}No Check ON{nl}LeftClick:On Off switch")
        btn:SetEventScript(ui.RBUTTONUP, "")
    end
    btn:SetText("{img equipment_info_btn_mark2 32 32}")
    btn:SetEventScript(ui.LBUTTONUP, "nocheck_inventory_btnup")
end

function NOCHECK_MORU_LBTN_CLICK(frame, msg)
    local invframe, invItem = acutil.getEventArgs(msg)
    if g.settings.use == 1 then
        NOCHECK_REINFORCE_131014_MSGBOX()
    else
        return
    end
end

function NOCHECK_REINFORCE_131014_MSGBOX()
    local frame = ui.GetFrame("reinforce_131014")
    local fromItem, fromMoru = GET_REINFORCE_TARGET_AND_MORU(frame)
    local fromItemObj = GetIES(fromItem:GetObject())
    local moruObj = GetIES(fromMoru:GetObject())
    local exec = GET_CHILD_RECURSIVELY(frame, "exec")

    local skipOver5 = GET_CHILD_RECURSIVELY(frame, "skipOver5")
    skipOver5:SetCheck(1)
    exec:ShowWindow(0)
    NOCHECK_REINFORCE_131014_EXEC()
end

function NOCHECK_REINFORCE_131014_EXEC()
    local frame = ui.GetFrame("reinforce_131014");
    local fromItem, fromMoru = REINFORCE_131014_GET_ITEM(frame);
    if fromItem ~= nil and fromMoru ~= nil and frame:IsVisible() == 1 then
        local fromItemObj = GetIES(fromItem:GetObject());
        session.ResetItemList();
        session.AddItemID(fromItem:GetIESID());
        session.AddItemID(fromMoru:GetIESID());
        local resultlist = session.GetItemIDList();
        item.DialogTransaction("ITEM_REINFORCE_131014", resultlist);
        ReserveScript("NOCHECK_REINFORCE_131014_EXEC()", 0.3)
    end
    REINFORCE_131014_UPDATE_MORU_COUNT(frame);
end

function NOCHECK_WARNINGMSGBOX_FRAME_OPEN()

    local frame = ui.GetFrame("warningmsgbox")
    if frame:IsVisible() == 0 then
        return
    else
        local warningText = GET_CHILD_RECURSIVELY(frame, "warningtext")
        local langCode = option.GetCurrentCountry()
        local msg = ClMsg("destory_now")
        if langCode ~= "Korean" then
            msg = dictionary.ReplaceDicIDInCompStr(msg)
        end
        if string.find(warningText:GetText(), msg) ~= nil then
            local input_frame = GET_CHILD_RECURSIVELY(frame, "input")
            input_frame:SetText(msg)
        end

    end
end

function NOCHECK_WARNINGMSGBOX_EX_FRAME_OPEN_FPS()

    local frame = ui.GetFrame('warningmsgbox_ex')
    if frame:IsVisible() == 0 then
        return
    else
        local compareText = GET_CHILD_RECURSIVELY(frame, "comparetext")
        local start, finish = string.find(compareText:GetText(), "nl%}%[")

        if start and finish then
            local nextSubstring = compareText:GetText():sub(finish + 1)
            local nextStart, nextFinish = string.find(nextSubstring, "%]")
            if nextStart and nextFinish then
                local desiredText = nextSubstring:sub(1, nextStart - 1)
                local input_frame = GET_CHILD_RECURSIVELY(frame, "input")
                input_frame:SetText(desiredText)
            else
                return
            end
        else
            return
        end
    end
end
