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
-- v1.2.0 アイテム連続使用フレームのバグ修正
-- v1.2.1 アクセの系統変更時不自然なの修正。ボスカード使用時OFFでも使う様に。ええやろ別に。
-- v1.2.2 連続捨てる機能追加
local addon_name = "NOCHECK"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.2.2"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

g.settings_file_location = string.format('../addons/%s/settings.json', addon_name_lower)

local acutil = require("acutil")
local base = {}

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addon_name)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName];
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

function g.mkdir_new_folder()
    local folder_path = string.format("../addons/%s", addon_name_lower)
    local file_path = string.format("../addons/%s/mkdir.txt", addon_name_lower)
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

local function ts(...)

    local num_args = select('#', ...)

    if num_args == 0 then
        print("ts: (no arguments)")
        return
    end

    local string_parts = {}
    for i = 1, num_args do
        local arg = select(i, ...)

        if arg == nil then
            table.insert(string_parts, "nil")
        else
            table.insert(string_parts, tostring(arg))
        end
    end

    print(table.concat(string_parts, "\t"))
end

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
        base["EQUIP_CARDSLOT_INFO_OPEN"](slotIndex)
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

    -- ReserveScript("UNLOCK_ACC_BELONGING_SCROLL_CLOSE()", 1.0)
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

    NOCHECK_BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN_(invItem)
    --[[if g.settings.use == 1 then
        NOCHECK_BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN_(invItem)
    else
        base["BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN"](invItem)
    end]]
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
        local tool_tip = g.lang == "Japanese" and
                             "{ol}[No Check]ON{nl}左クリック: ON/OFF{nl}右クリック: 他の機能選択" or
                             "{ol}[No Check]ON{nl}Left-click: On/Off{nl}Right-click: Select other functions"
        btn:SetTextTooltip(tool_tip)
        -- btn:SetEventScript(ui.RBUTTONUP, "nocheck_inventory_continuous_use_frame")
        btn:SetEventScript(ui.RBUTTONUP, "nocheck_rbtn_context")
    else
        btn:SetSkinName("test_gray_button")
        local tool_tip = g.lang == "Japanese" and "{ol}[No Check]OFF{nl}左クリック: ON/OFF" or
                             "{ol}[No Check]OFF{nl}Left-click: On/Off"
        btn:SetTextTooltip(tool_tip)
        btn:SetEventScript(ui.RBUTTONUP, "")
    end
    btn:SetText("{img equipment_info_btn_mark2 32 32}")
    btn:SetEventScript(ui.LBUTTONUP, "nocheck_inventory_btnup")

end

-- ONOFF切り替え
function nocheck_inventory_btnup(frame, ctrl, str, num)
    if g.settings.use == 1 then
        ctrl:SetSkinName("test_gray_button")
        g.settings.use = 0
        local tool_tip = g.lang == "Japanese" and "{ol}[No Check]OFF{nl}左クリック: ON/OFF" or
                             "{ol}[No Check]OFF{nl}Left-click: On/Off"
        ctrl:SetTextTooltip(tool_tip)
        ctrl:SetEventScript(ui.RBUTTONUP, "")
    else
        ctrl:SetSkinName("test_pvp_btn")
        g.settings.use = 1
        local tool_tip = g.lang == "Japanese" and
                             "{ol}[No Check]ON{nl}左クリック: ON/OFF{nl}右クリック: 他の機能選択" or
                             "{ol}[No Check]ON{nl}Left-click: On/Off{nl}Right-click: Select other functions"
        ctrl:SetTextTooltip(tool_tip)
        -- ctrl:SetEventScript(ui.RBUTTONUP, "nocheck_inventory_continuous_use_frame")
        ctrl:SetEventScript(ui.RBUTTONUP, "nocheck_rbtn_context")
    end
    nocheck_save_settings()
end

-- 連続使用とゴミ捨ての共通
function nocheck_rbtn_context(frame, ctrl, str, num)

    local frame = ui.GetFrame(addon_name_lower .. "continuous_use")
    if frame and frame:IsVisible() == 1 then
        return
    end

    local delete_item = ui.GetFrame(addon_name_lower .. "_delete_item")
    if delete_item and delete_item:IsVisible() == 1 then
        return
    end

    --[[local map = ui.GetFrame("map")
    local width = map:GetWidth()

    if width > 1920 then
        inv_x = inv_x / 16 * 21
    end]]

    local context = ui.CreateContextMenu("RBTN_CONTEXT", "{ol}Feature Selection", 0, -200, 0, 0)

    local scp = string.format("nocheck_inventory_continuous_use_frame('','','','')")
    local text = g.lang == "Japanese" and "{ol}アイテム連続使用フレーム" or "{ol}Item Continuous Use Frame"
    ui.AddContextMenuItem(context, text, scp)

    local scp = string.format("nocheck_delete_item_frame_init('','','','')")
    local text = g.lang == "Japanese" and "{ol}ゴミ箱用フレーム" or "{ol}Trash Bin Frame"
    ui.AddContextMenuItem(context, text, scp)

    ui.OpenContextMenu(context)
end
-- 連続使用とゴミ捨ての共通。インベントリマウス制御
function nocheck_inv_rbtn(itemObj, slot)
    local icon = slot:GetIcon()
    local icon_info = icon:GetInfo()

    local frame = ui.GetFrame(addon_name_lower .. "continuous_use")
    if frame and frame:IsVisible() == 1 then
        local clsid = icon_info.type
        local inv_item = session.GetInvItemByType(clsid)
        local item_slot = GET_CHILD(frame, "item_slot")
        local item_cls = GetClassByType("Item", clsid)
        item_slot:SetUserValue("CLASS_ID", clsid)
        SET_SLOT_ITEM_CLS(item_slot, item_cls)
        SET_SLOT_ITEM_TEXT(item_slot, inv_item, item_cls)
    else
        local delete_item = ui.GetFrame(addon_name_lower .. "_delete_item")
        if delete_item and delete_item:IsVisible() == 1 then
            AUTO_CAST(delete_item)
            local iesid = icon_info:GetIESID()
            local inv_item = session.GetInvItemByGuid(iesid)
            local item_obj = GetIES(inv_item:GetObject())

            if g.temp_iesids[iesid] then
                local msg = g.lang == "Japanese" and "{ol}既に登録されています" or "{ol}Already registered"
                ui.SysMsg(msg)
                return
            end

            if nocheck_delete_check(iesid, item_obj.ClassID) then

                local delete_slotset = GET_CHILD_RECURSIVELY(delete_item, "delete_slotset")
                AUTO_CAST(delete_slotset);
                local slot_count = delete_slotset:GetSlotCount()

                for i = 1, slot_count do

                    local slot = GET_CHILD(delete_slotset, "slot" .. i)
                    AUTO_CAST(slot)
                    local icon = slot:GetIcon()
                    if not icon then
                        icon = CreateIcon(slot)
                        slot:SetUserValue("DELETE_IDSID", iesid)
                        slot:SetUserValue("DELETE_NAME", item_obj.Name)
                        slot:SetUserValue("DELETE_COUNT", inv_item.count)
                        g.temp_iesids[iesid] = true

                        SET_SLOT_ITEM_CLS(slot, item_obj)
                        SET_SLOT_ITEM_TEXT(slot, inv_item, item_obj)
                        SET_SLOT_STYLESET(slot, item_obj)
                        SET_SLOT_IESID(slot, iesid)
                        SET_SLOT_ICOR_CATEGORY(slot, item_obj);
                        icon:SetTooltipArg("None", 0, iesid);
                        SET_ITEM_TOOLTIP_TYPE(icon, item_obj.ClassID, item_obj, "None");
                        SET_SLOT_ICOR_CATEGORY(slot, item_obj)

                        slot:SetEventScript(ui.RBUTTONUP, "nocheck_delete_item_clear")
                        slot:SetEventScriptArgString(ui.RBUTTONUP, iesid)

                        local inventory = ui.GetFrame("inventory")
                        local inv_slot = INV_GET_SLOT_BY_ITEMGUID(iesid)
                        if inv_slot then
                            AUTO_CAST(inv_slot)

                            inv_slot:SetSelectedImage('socket_slot_check')
                            inv_slot:Select(1)
                            inv_slot:RunUpdateScript("nocheck_inv_invalidate", 0.1)
                            inv_slot:Invalidate()
                        end
                        return
                    end
                end
            end
        end
    end
end

function nocheck_inv_invalidate(frame)
    frame:Invalidate()
end

function nocheck_inventory_continuous_use_frame_close(frame, ctrl, str, num)
    local frame = ui.GetFrame(addon_name_lower .. "continuous_use")
    local item_slot = GET_CHILD(frame, "item_slot")
    AUTO_CAST(item_slot)
    item_slot:SetUserValue("CLASS_ID", 0)
    frame:ShowWindow(0)
    INVENTORY_SET_CUSTOM_RBTNDOWN('None')
end

function nocheck_inventory_continuous_use_count_result(frame_name, clsid)

    local frame = ui.GetFrame(frame_name)

    local item_slot = GET_CHILD(frame, "item_slot")
    AUTO_CAST(item_slot)
    local inv_item = session.GetInvItemByType(clsid)
    if not inv_item then
        nocheck_inventory_continuous_use_frame_close(frame)
        return
    end
    local count = tonumber(inv_item.count)
    if g.count ~= count then
        item_slot:SetText("{s18}{ol}{b}" .. count, 'count', ui.RIGHT, ui.BOTTOM, -2, 1);
        frame:RunUpdateScript("nocheck_inv_invalidate", 0.1)
        frame:Invalidate()
        nocheck_inventory_continuous_use(frame)
        return

    else
        nocheck_inventory_continuous_use_frame_close(frame)
        return
    end
end

function nocheck_inventory_continuous_use_icon_use(frame)

    local frame = ui.GetFrame(addon_name_lower .. "continuous_use")
    local item_slot = GET_CHILD(frame, "item_slot")
    AUTO_CAST(item_slot)
    local clsid = item_slot:GetUserIValue("CLASS_ID")
    if clsid == 0 then
        frame:ShowWindow(0)
        return
    end

    local inv_item = session.GetInvItemByType(clsid)
    if inv_item ~= nil then
        INV_ICON_USE(inv_item)
        local item_cls = GetClassByType("Item", clsid)
        SET_SLOT_ITEM_CLS(item_slot, item_cls);
        inv_item = session.GetInvItemByType(clsid)
        local count = tonumber(inv_item.count)

        local result = ReserveScript(string.format("nocheck_inventory_continuous_use_count_result('%s',%d)",
            frame:GetName(), clsid), 1.0)

    else
        local item_cls = GetClassByType("Item", clsid)
        SET_SLOT_ITEM_CLS(item_slot, item_cls);
        CreateIcon(item_slot):SetColorTone('FFFF0000')
        item_slot:SetText("{s18}{ol}{b}" .. 0, 'count', ui.RIGHT, ui.BOTTOM, -2, 1);
        frame:RunUpdateScript("nocheck_inv_invalidate", 0.1)
        frame:Invalidate()
        frame:RunUpdateScript("nocheck_inventory_continuous_use_frame_close", 1.0);
        return
    end

end

function nocheck_inventory_continuous_use(frame, ctrl, str, num)
    local frame = ui.GetFrame(addon_name_lower .. "continuous_use")
    local item_slot = GET_CHILD(frame, "item_slot")
    local clsid = item_slot:GetUserIValue("CLASS_ID")
    -- session.ResetItemList();
    local inv_item = session.GetInvItemByType(clsid)
    g.count = tonumber(inv_item.count)

    if inv_item ~= nil then
        local item_cls = GetClassByType("Item", clsid)
        SET_SLOT_ITEM_TEXT(item_slot, inv_item, item_cls)
        nocheck_inventory_continuous_use_icon_use(frame)
        -- frame:RunUpdateScript("nocheck_inventory_continuous_use_icon_use", 1.0);
    end
end

function nocheck_inventory_continuous_use_frame(frame, ctrl, str, num)
    acutil.setupEvent(g.addon, "INVENTORY_CLOSE", "nocheck_inventory_continuous_use_frame_close");
    local inventory = ui.GetFrame("inventory")
    local inv_x = inventory:GetX()
    local continuous_use_frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "continuous_use", 0, 0, 0, 0)
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

s_dropDeleteItemIESID = ''
s_dropDeleteItemCount = 0
s_dropDeleteItemName = ''

function nocheck_delete_item_frame_init()

    acutil.setupEvent(g.addon, "INVENTORY_CLOSE", "nocheck_delete_item_frame_close")
    g.temp_iesids = {}

    local inventory = ui.GetFrame("inventory")
    local inv_x = inventory:GetX()

    local map = ui.GetFrame("map")
    local width = map:GetWidth()

    if width > 1920 then
        inv_x = inv_x / 16 * 21
    end

    local frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "_delete_item", 0, 0, 10, 10)
    AUTO_CAST(frame)
    frame:SetSkinName("test_frame_low")
    frame:SetPos(inv_x - 135, 170)
    frame:SetLayerLevel(100)
    frame:Resize(300, 698)
    frame:RemoveAllChild()

    local title = frame:CreateOrGetControl('richtext', 'title', 10, 15, 0, 0)
    AUTO_CAST(title)
    title:SetText(g.lang == "Japanese" and "{ol}{s18}ゴミ箱スロット" or "{ol}{s18}Discard item Slots")

    local close = frame:CreateOrGetControl("button", "close", 0, 0, 25, 25)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "nocheck_delete_item_frame_close")
    close:SetEventScriptArgString(ui.LBUTTONUP, "true")

    local delete_gb = frame:CreateOrGetControl("groupbox", "delete_gb", 10, 40, 380, 380)
    AUTO_CAST(delete_gb)
    delete_gb:SetSkinName("test_frame_midle_light")
    delete_gb:Resize(280, 600)
    frame:ShowWindow(1)

    local delete_slotset = delete_gb:CreateOrGetControl('slotset', 'delete_slotset', 0, 0, 0, 0)
    AUTO_CAST(delete_slotset);
    delete_slotset:SetSlotSize(40, 40)
    delete_slotset:EnablePop(0)
    delete_slotset:EnableDrag(1)
    delete_slotset:EnableDrop(1)
    delete_slotset:SetColRow(7, 15)
    delete_slotset:SetSpc(0, 0)
    delete_slotset:SetSkinName('slot')

    delete_slotset:CreateSlots()
    local slot_count = delete_slotset:GetSlotCount()

    local go_func = frame:CreateOrGetControl("button", "go_func", 0, 0, 100, 43)
    AUTO_CAST(go_func)
    go_func:SetText(g.lang == "Japanese" and "{ol}{s16}スタート" or "{ol}{s16}START")
    go_func:SetMargin(190, 645, 100, 0)
    go_func:SetSkinName("test_red_button")
    go_func:SetEventScript(ui.LBUTTONUP, "nocheck_delete_item_msgbox")

    local stop_func = frame:CreateOrGetControl("button", "stop_func", 0, 0, 100, 43)
    AUTO_CAST(stop_func)
    stop_func:SetText(g.lang == "Japanese" and "{ol}{s16}ストップ" or "{ol}{s16}STOP")
    stop_func:SetMargin(10, 645, 100, 0)
    stop_func:SetSkinName("test_gray_button")
    stop_func:SetEventScript(ui.LBUTTONUP, "nocheck_delete_item_frame_close")
    stop_func:SetEventScriptArgString(ui.LBUTTONUP, "true")

    INVENTORY_SET_CUSTOM_RBTNDOWN("nocheck_inv_rbtn")

end

function nocheck_delete_check(iesid, cls_id)

    if GetCraftState() == 1 then
        return false
    end
    if true == BEING_TRADING_STATE() then
        return false
    end

    local inventory = ui.GetFrame("inventory")
    --[[if ui.GetPickedFrame() ~= nil then
        return false
    end]]

    local inv_item = session.GetInvItemByGuid(iesid)
    if nil == inv_item then
        return false
    end

    if true == inv_item.isLockState or true == IS_TEMP_LOCK(inventory, inv_item) then
        ui.SysMsg(ClMsg("MaterialItemIsLock"))
        return false
    end

    local item_cls = GetClassByType("Item", cls_id)
    if nil == item_cls then
        return false
    end

    local item_prop = geItemTable.IsDestroyable(cls_id)
    if item_cls.Destroyable == 'NO' or item_prop == false then
        local item_obj = GetIES(inv_item:GetObject());
        if item_obj.ItemLifeTimeOver == 0 then
            ui.AlarmMsg("ItemIsNotDestroy");
            return false
        end
    end
    return true
end

function nocheck_delete_item_frame_close(frame, ctrl, bool)

    local delete_item = ui.GetFrame(addon_name_lower .. "_delete_item")
    delete_item:ShowWindow(0)
    g.temp_iesids = {}
    INVENTORY_SET_CUSTOM_RBTNDOWN('None')
    INVENTORY_CLEAR_SELECT(nil)
    if bool == "true" then
        UI_TOGGLE_INVENTORY()
    end
    if ctrl:GetName() == "delete_slotset" then
        ui.SysMsg("{ol}[No Check]End of Operation")
    end
    if ctrl:GetName() == "stop_func" then
        delete_item:StopUpdateScript("nocheck_delete_item")
        ui.SysMsg("{ol}[No Check]Stop Operation")
    end

end

function nocheck_delete_item_msgbox()
    local yes_scp = string.format("nocheck_delete_item_reserve()")
    local msg = g.lang == "Japanese" and
                    "{ol}{#FF0000}本当にゴミ捨てを開始しますか？{nl}(リカバリーサービス対象外かも)" or
                    "{ol}{#FF0000}Are you sure you want to start trashing?{nl}(might not be covered by the{nl} recovery service)"
    ui.MsgBox(msg, yes_scp, "None");

end

function nocheck_delete_item_reserve()
    local delete_item = ui.GetFrame(addon_name_lower .. "_delete_item")
    nocheck_delete_item(delete_item)
    delete_item:RunUpdateScript("nocheck_delete_item", 1.0)
end

function nocheck_delete_item(delete_item)

    if delete_item and delete_item:IsVisible() == 0 then
        return 0
    end
    local delete_slotset = GET_CHILD_RECURSIVELY(delete_item, "delete_slotset")
    AUTO_CAST(delete_slotset);
    local slot_count = delete_slotset:GetSlotCount()

    for i = 1, slot_count do

        local slot = GET_CHILD(delete_slotset, "slot" .. i)
        AUTO_CAST(slot)
        local icon = slot:GetIcon()

        if icon then
            local iesid = slot:GetUserValue("DELETE_IDSID")
            local name = slot:GetUserValue("DELETE_NAME")
            local count = slot:GetUserIValue("DELETE_COUNT")
            local trans_name = dic.getTranslatedStr(name)
            -- ts(iesid, name, count, trans_name)
            s_dropDeleteItemIESID = iesid
            s_dropDeleteItemCount = count
            s_dropDeleteItemName = name
            nocheck_delete_item_execute(slot, iesid, trans_name, count)
            return 1
        end
    end

    nocheck_delete_item_frame_close(delete_item, delete_slotset, "true")
    return 0

end

function nocheck_delete_item_execute(slot, iesid, trans_name, count)
    IMC_LOG("INFO_NORMAL", "EXEC_DELETE_ITEMDROP")
    local pc = GetMyPCObject()
    local msg = g.lang == "Japanese" and "{ol}{#FFFF00}[" .. trans_name .. "]{/}{ol}{#FFFFFF}を" .. "{ol}{#FFFF00}[" ..
                    count .. "個]{/}" .. "{ol}{#FFFFFF}捨てました" or "{ol}{#FFFFFF}Discarded {/}" ..
                    "{ol}{#FFFF00}[" .. count .. "]{ol}{#FFFFFF} piece " .. "{ol}{#FFFF00}[" .. trans_name .. "]{/}"

    imcAddOn.BroadMsg("NOTICE_Dm_!", msg, 0.9);
    item.DropDelete(s_dropDeleteItemIESID, s_dropDeleteItemCount)
    s_dropDeleteItemIESID = ''
    s_dropDeleteItemCount = 0
    s_dropDeleteItemName = ''
    nocheck_delete_item_clear("", slot, iesid, "")

end

function nocheck_delete_item_clear(frame, slot, iesid, num)
    slot:ClearIcon()
    slot:ClearText()
    slot:SetSkinName('slot')
    slot:SetUserValue("DELETE_IDSID", "None")
    slot:SetUserValue("DELETE_NAME", "None")
    slot:SetUserValue("DELETE_COUNT", 0)
    g.temp_iesids[iesid] = nil

    local inventory = ui.GetFrame("inventory")
    local inv_slot = INV_GET_SLOT_BY_ITEMGUID(iesid)

    if inv_slot then
        AUTO_CAST(inv_slot)
        inv_slot:Select(0)
        inv_slot:RunUpdateScript("nocheck_inv_invalidate", 0.1)
        inv_slot:Invalidate()
    end
end

