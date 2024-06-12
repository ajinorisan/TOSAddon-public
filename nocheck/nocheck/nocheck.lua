-- v1.0.5 SetupHookの競合を修正
-- v1.0.6 帰属解除スキップのバグ修正
-- v1.0.7 チャンネルチェンジバグ修正
-- v1.0.8 継承とか入れるのをスキップ
-- v1.0.9 「今すぐこわす」をセット
-- v1.1.0 とりあえずmsgをインプットする系は全部セットする様に出来たと思うけど知らん
-- v1.1.1 ラダコレクション連続強化するように。速すぎてミス注意。
-- v1.1.2 継承とか入力出来なかったの修正。テストコードそのまま放置してたのが原因
-- v1.1.3 コレクション強化の際に節目の強化値で一度確認する様に変更。WARNINGBOXの一部がバグるらしいので一時無効化コマンド追加
local addonName = "NOCHECK"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.1.3"

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

    acutil.slashCommand("/nocheck", NOCHECK_COMMAND);

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        if g.nocheck == 0 then
            addon:RegisterMsg("FPS_UPDATE", "NOCHECK_WARNINGMSGBOX_FRAME_OPEN")
            addon:RegisterMsg("FPS_UPDATE", "NOCHECK_WARNINGMSGBOX_EX_FRAME_OPEN_FPS")
        end

        acutil.setupEvent(addon, "MORU_LBTN_CLICK", "NOCHECK_MORU_LBTN_CLICK");
    end

end

function NOCHECK_COMMAND()
    if g.nocheck == nil then
        g.nocheck = 1
        ui.SysMsg("WARNINGMSGBOX NOCHECK OFF{nl}Please return to the barracks once.")

    elseif g.nocheck == 0 then
        ui.SysMsg("WARNINGMSGBOX NOCHECK OFF{nl}Please return to the barracks once.")
        g.nocheck = 1

    else
        ui.SysMsg("WARNINGMSGBOX NOCHECK OFF{nl}Please return to the barracks once.")
        g.nocheck = 0

    end

end

local FIRST_REINFORCE = true -- 初回強化フラグ

function NOCHECK_MORU_LBTN_CLICK(frame, msg)
    local invframe, invItem = acutil.getEventArgs(msg)

    --[[local frame = ui.GetFrame("reinforce_131014")
    g.timer = frame:CreateOrGetControl("timer", "addontimer", 0, 0)
    AUTO_CAST(g.timer)
    g.timer:Stop()
    g.timer:SetUpdateScript("NOCHECK_REINFORCE_131014_MSGBOX")
    g.timer:Start(2)]]
    FIRST_REINFORCE = true -- 初回強化フラグをtrueに
    NOCHECK_REINFORCE_131014_MSGBOX()

end

function NOCHECK_REINFORCE_131014_MSGBOX()
    local frame = ui.GetFrame("reinforce_131014")
    if frame:IsVisible() == 0 then

        SET_MOUSE_FOLLOW_BALLOON(nil);
        ui.RemoveGuideMsg("SelectItem");
        SET_MOUSE_FOLLOW_BALLOON();
        ui.SetEscapeScp("");
        local invframe = ui.GetFrame("inventory");
        -- SET_SLOT_APPLY_FUNC(invframe, "None");
        SET_INV_LBTN_FUNC(invframe, "None");
        RESET_MOUSE_CURSOR();

        return
    end
    local skipOver5 = GET_CHILD_RECURSIVELY(frame, "skipOver5")
    skipOver5:SetCheck(1)

    local fromItem, fromMoru = GET_REINFORCE_TARGET_AND_MORU(frame)
    local fromItemObj = GetIES(fromItem:GetObject())
    local moruObj = GetIES(fromMoru:GetObject())

    local exec = GET_CHILD_RECURSIVELY(frame, "exec")

    if moruObj.ClassName == "Moru_goddess_500" then
        exec:ShowWindow(0)
        NOCHECK_REINFORCE_131014_EXEC(frame, fromItemObj)
    else
        exec:ShowWindow(1)
    end
end

local REINFORCE_LEVEL_CHECKED = false

function NOCHECK_REINFORCE_131014_EXEC(frame, fromItemObj)
    local curReinforce = fromItemObj.Reinforce_2

    local found = false
    for _, level in ipairs({7, 10, 15, 20}) do
        if tonumber(curReinforce) == level then
            found = true
            break
        end
    end

    if found then
        if FIRST_REINFORCE then -- 初回強化の場合
            NOCHECK_REINFORCE_131014_CONTINUE()

        else
            if not REINFORCE_LEVEL_CHECKED then
                local msg = "Continue to reinforce?"
                local yes = string.format("NOCHECK_REINFORCE_131014_CONTINUE()")
                local no = string.format("NOCHECK_REINFORCE_131014_CANCEL()")
                ui.MsgBox(msg, yes, no)
                REINFORCE_LEVEL_CHECKED = true
            end
        end
    else
        -- 確認条件に合致しない場合は続行
        NOCHECK_REINFORCE_131014_CONTINUE()
        for _, level in ipairs({1, 2, 3, 4, 5, 6, 8, 9, 11, 12, 13, 14, 16, 17, 18, 19}) do
            if tonumber(curReinforce) == level then
                REINFORCE_LEVEL_CHECKED = false
                FIRST_REINFORCE = false -- 初回強化フラグをfalseに
                break
            end
        end
    end
end

function NOCHECK_REINFORCE_131014_CONTINUE()
    local frame = ui.GetFrame("reinforce_131014")
    local fromItem, fromMoru = GET_REINFORCE_TARGET_AND_MORU(frame)
    session.ResetItemList()
    session.AddItemID(fromItem:GetIESID())
    session.AddItemID(fromMoru:GetIESID())
    local resultlist = session.GetItemIDList()
    item.DialogTransaction("ITEM_REINFORCE_131014", resultlist)

    REINFORCE_131014_UPDATE_MORU_COUNT(frame)
    ReserveScript("NOCHECK_REINFORCE_131014_MSGBOX()", 2.0)
    return
    -- REINFORCE_LEVEL_CHECKED = false
end

function NOCHECK_REINFORCE_131014_CANCEL()

    local frame = ui.GetFrame("reinforce_131014")
    frame:ShowWindow(0)
    REINFORCE_LEVEL_CHECKED = false

    SET_MOUSE_FOLLOW_BALLOON(nil);
    ui.RemoveGuideMsg("SelectItem");
    SET_MOUSE_FOLLOW_BALLOON();
    ui.SetEscapeScp("");
    local invframe = ui.GetFrame("inventory");
    -- SET_SLOT_APPLY_FUNC(invframe, "None");
    SET_INV_LBTN_FUNC(invframe, "None");
    RESET_MOUSE_CURSOR();

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
    -- print("test")
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

                -- print("次の部分文字列:" .. desiredText)
            else
                -- print("次の']'が見つかりませんでした")
                return
            end
        else
            -- print("次のパターンが見つかりませんでした")
            return
        end
    end

end

--[[function NOCHECK_WARNINGMSGBOX_EX_FRAME_OPEN(frame, msg, argStr, argNum, option)
    -- print("test")
    local arg_list = SCR_STRING_CUT(argStr, ';')
    if arg_list == nil or #arg_list <= 0 then
        return
    end

    local clmsg = ClMsg(arg_list[1])
    local yes_arg = ""
    if #arg_list > 1 then
        yes_arg = arg_list[2]
    end

    ui.OpenFrame("warningmsgbox_ex")

    local frame = ui.GetFrame('warningmsgbox_ex')

    -- 커스터마이징 옵션.
    local compare_msg_color = nil;
    local compare_msg_desc = nil;
    if option ~= nil then
        if option.ChangeTitle ~= nil then
            local warningTitle = GET_CHILD_RECURSIVELY(frame, "warningtitle")
            warningTitle:SetText(ClMsg(option.ChangeTitle));
        end
        if option.CompareTextColor ~= nil then
            compare_msg_color = option.CompareTextColor;
        end
        if option.CompareTextDesc ~= nil then
            compare_msg_desc = option.CompareTextDesc;
        end
    end

    local warningText = GET_CHILD_RECURSIVELY(frame, "warningtext")
    warningText:SetText(clmsg)

    local compareText = GET_CHILD_RECURSIVELY(frame, "comparetext")
    local compareHeight = 0

    local input_frame = GET_CHILD_RECURSIVELY(frame, "input")
    AUTO_CAST(input_frame)
    local input_height = 0

    local yes_list = SCR_STRING_CUT(yes_arg, '/')
    local compare_msg = ''
    if #yes_list > 0 then
        compare_msg = ClMsg(yes_list[1])
    end

    if compare_msg ~= '' then
        compareText:ShowWindow(1)

        if compare_msg_desc ~= nil then
            compareText:SetTextByKey('desc', compare_msg_desc)
        end

        if compare_msg_color ~= nil then
            compareText:SetTextByKey('value', compare_msg_color .. compare_msg .. '{/}')
        else
            compareText:SetTextByKey('value', compare_msg)
        end

        compareHeight = compareText:GetHeight()
        -- compareText:SetMargin(0, 0, 0, 170)

        input_frame:ShowWindow(1)
        -- input_frame:SetTextByKey('value', compare_msg)
        local str = dictionary.ReplaceDicIDInCompStr(compare_msg)
        input_frame:SetText(tostring(str))

        input_frame:Focus()
        input_height = input_frame:GetHeight()
    else
        compareText:ShowWindow(0)
        input_frame:ShowWindow(0)
    end

    local yesBtn = GET_CHILD_RECURSIVELY(frame, "yes")
    tolua.cast(yesBtn, "ui::CButton")
    yesBtn:SetEventScript(ui.LBUTTONUP, '_WARNINGMSGBOX_EX_FRAME_OPEN_YES')
    yesBtn:SetEventScriptArgString(ui.LBUTTONUP, yes_arg)
    yesBtn:SetEventScript(ui.ENTERKEY, '_WARNINGMSGBOX_EX_FRAME_OPEN_YES')
    yesBtn:SetEventScriptArgString(ui.ENTERKEY, yes_arg)

    local noBtn = GET_CHILD_RECURSIVELY(frame, "no")
    tolua.cast(noBtn, "ui::CButton")
    noBtn:SetEventScript(ui.LBUTTONUP, '_WARNINGMSGBOX_EX_FRAME_OPEN_NO')
    local okBtn = GET_CHILD_RECURSIVELY(frame, "ok")
    tolua.cast(okBtn, "ui::CButton")
    if argNum == 0 then
        yesBtn:ShowWindow(1)
        noBtn:ShowWindow(1)
        okBtn:ShowWindow(0)
    elseif argNum == 1 then
        okBtn:SetEventScript(ui.LBUTTONUP, '_WARNINGMSGBOX_EX_FRAME_OPEN_YES')
        okBtn:SetEventScriptArgString(ui.LBUTTONUP, yes_arg)

        yesBtn:ShowWindow(0)
        noBtn:ShowWindow(0)
        okBtn:ShowWindow(1)
    end

    local buttonMargin = noBtn:GetMargin()
    local warningbox = GET_CHILD_RECURSIVELY(frame, 'warningbox')
    local totalHeight =
        warningbox:GetY() + warningText:GetY() + warningText:GetHeight() + compareHeight + input_height +
            noBtn:GetHeight() + 2 * buttonMargin.bottom

    local bg = GET_CHILD_RECURSIVELY(frame, 'bg')
    warningbox:Resize(warningbox:GetWidth(), totalHeight)
    bg:Resize(bg:GetWidth(), totalHeight)
    frame:Resize(frame:GetWidth(), totalHeight)
end]]

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
