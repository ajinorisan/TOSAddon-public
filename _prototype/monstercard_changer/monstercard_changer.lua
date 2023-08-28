local addonName = "monstercard_changer"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

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

g.SettingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

--[[g.settings.tabindex = {

    ATKcard_slotset = {
        slot1 = {
            card_cls_id = 0,
            card_exp = 0,
            card_lv = 0
        },
        slot2 = {
            card_cls_id = 0,
            card_exp = 0,
            card_lv = 0
        },
        slot3 = {
            card_cls_id = 0,
            card_exp = 0,
            card_lv = 0
        }
    },
    DEFcard_slotset = {
        slot1 = {
            card_cls_id = 0,
            card_exp = 0,
            card_lv = 0
        },
        slot2 = {
            card_cls_id = 0,
            card_exp = 0,
            card_lv = 0
        },
        slot3 = {
            card_cls_id = 0,
            card_exp = 0,
            card_lv = 0
        }
    },
    UTILcard_slotset = {
        slot1 = {
            card_cls_id = 0,
            card_exp = 0,
            card_lv = 0
        },
        slot2 = {
            card_cls_id = 0,
            card_exp = 0,
            card_lv = 0
        },
        slot3 = {
            card_cls_id = 0,
            card_exp = 0,
            card_lv = 0
        }
    },
    STATcard_slotset = {
        slot1 = {
            card_cls_id = 0,
            card_exp = 0,
            card_lv = 0
        },
        slot2 = {
            card_cls_id = 0,
            card_exp = 0,
            card_lv = 0
        },
        slot3 = {
            card_cls_id = 0,
            card_exp = 0,
            card_lv = 0
        }
    }

}]]
--[[function monstercard_changer_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function monstercard_changer_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    local loginCharID = info.GetCID(session.GetMyHandle())

    -- CHAT_SYSTEM(loginCharID)
    local temptable = g.settings.tabindex[loginCharID]
    -- CHAT_SYSTEM(pctbl)
    if temptable then

        -- ANCIENT_AUTOSET_ON_SETTINGS()

    end
end]]

function MONSTERCARD_CHANGER_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    -- g.SetupHook(MONSTERCARD_CHANGER_CARD_PRESET_SAVE_PRESET, "CARD_PRESET_SAVE_PRESET")
    -- acutil.setupHook(monstercard_changer_CARD_PRESET_SELECT_PRESET, "CARD_PRESET_SELECT_PRESET")
    addon:RegisterMsg('GAME_START_3SEC', 'monstercard_changer_inventory_frame_init');

end

function MONSTERCARD_CHANGER_CARD_SLOT_RBTNUP_ITEM_INFO(frame, slot, argStr, argNum)
    CHAT_SYSTEM(tostring(frame:GetName()))
    CHAT_SYSTEM(tostring(slot:GetName()))
    local parentSlotSet = slot:GetParent()
    CHAT_SYSTEM(tostring(parentSlotSet:GetName()))
    CHAT_SYSTEM(tostring(argStr))
    CHAT_SYSTEM(tostring(argNum))

    return
end

function MONSTERCARD_CHANGER_CARD_SLOT_DROP(frame, slot, argStr, argNum)
    local liftIcon = ui.GetLiftIcon();
    local FromFrame = liftIcon:GetTopParentFrame();
    local toFrame = frame:GetTopParentFrame();

    if toFrame:GetName() == 'monstercard_changer' then
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

        local parentSlotSet = slot:GetParent()
        if parentSlotSet == nil then
            return
        end

        if cardObj.CardGroupName == "REINFORCE_CARD" then
            ui.SysMsg(ClMsg("LegendReinforceCard_Not_Equip"));
            return
        end

        local cardGroupName_slotset = cardObj.CardGroupName .. 'card_slotset'
        if parentSlotSet:GetName() ~= cardGroupName_slotset then
            -- 같은 card group 에 착용해야합니다 메세지 띄워줘야해
            ui.SysMsg(ClMsg("ToEquipSameCardGroup"));
            return
        end

        CARD_SLOT_EQUIP(slot, item, cardObj.CardGroupName);
    end

    local loginCharID = info.GetCID(session.GetMyHandle())
    if g.settings.tabindex == nil then
        g.settings.tabindex = {}
    end

    -- キャラクターIDに該当するエントリがなければ新しく作成
    if g.settings.tabindex[loginCharID] == nil then
        g.settings.tabindex[loginCharID] = {}
    end
    local temptable = g.settings.tabindex[loginCharID]
    local framename = frame:GetName()
    local slotname = slot:GetName()

    if g.settings.tabindex[loginCharID][framename] == nil then
        g.settings.tabindex[loginCharID][framename] = {}
    end

    if g.settings.tabindex[loginCharID][framename][slotname] == nil then
        g.settings.tabindex[loginCharID][framename][slotname] = {}
    end
    print(g.settings.tabindex[loginCharID][framename][slotname])
    -- g.settings.tabindex[loginCharID][framename][slotname]=
    return
end

function monstercard_changer_get_card_info()
    local frame = ui.GetFrame(addonName) -- UIフレームを取得

    -- カウントするアイコンを含む親要素（例: SlotSet）
    local ATKcard_slotset = GET_CHILD_RECURSIVELY(frame, "ATKcard_slotset")
    AUTO_CAST(ATKcard_slotset)
    local DEFcard_slotset = GET_CHILD_RECURSIVELY(frame, "DEFcard_slotset")
    AUTO_CAST(DEFcard_slotset)
    local UTILcard_slotset = GET_CHILD_RECURSIVELY(frame, "UTILcard_slotset")
    AUTO_CAST(UTILcard_slotset)
    local STATcard_slotset = GET_CHILD_RECURSIVELY(frame, "STATcard_slotset")
    AUTO_CAST(STATcard_slotset)

    local iconCount = 0 -- アイコンの数をカウントする変数
    local cardInfoList = {} -- カード情報を保存するテーブル

    if ATKcard_slotset ~= nil then
        -- SlotSet内のアイコンの数をカウント
        for i = 0, 2 do
            local slot = ATKcard_slotset:GetSlotByIndex(i)
            if slot ~= nil and slot:GetIcon() ~= nil then
                -- iconCount = iconCount + 1
                table.insert(cardInfoList, GetCardInfo(i + 1))
            end
        end
    end
    if DEFcard_slotset ~= nil then
        -- SlotSet内のアイコンの数をカウント
        for i = 0, 2 do
            local slot = DEFcard_slotset:GetSlotByIndex(i)
            if slot ~= nil and slot:GetIcon() ~= nil then
                -- iconCount = iconCount + 1
                table.insert(cardInfoList, GetCardInfo(i + 1))
            end
        end
    end
    if UTILcard_slotset ~= nil then
        -- SlotSet内のアイコンの数をカウント
        for i = 0, 2 do
            local slot = UTILcard_slotset:GetSlotByIndex(i)
            if slot ~= nil and slot:GetIcon() ~= nil then
                -- iconCount = iconCount + 1
                table.insert(cardInfoList, GetCardInfo(i + 1))
            end
        end
    end
    if STATcard_slotset ~= nil then
        -- SlotSet内のアイコンの数をカウント
        for i = 0, 2 do
            local slot = STATcard_slotset:GetSlotByIndex(i)
            if slot ~= nil and slot:GetIcon() ~= nil then
                -- iconCount = iconCount + 1
                table.insert(cardInfoList, GetCardInfo(i + 1))
            end
        end
    end

    -- アイコンの数を表示
    -- CHAT_SYSTEM("アイコンの数: " .. iconCount)
    if cardInfoList == nil then
        return 0, 0, 0;
    end

    local count = cardInfoList:Count()
    CHAT_SYSTEM("アイコンの数: " .. count)
    for i = 0, count - 1 do
        local info = cardInfoList:Element(i)
        local slotIndex = frame:GetUserIValue("PREINDEX")
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

end

function monstercard_changer_inventory_frame_init()

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        local invframe = ui.GetFrame('inventory')
        local inventoryGbox = invframe:GetChild("inventoryGbox")
        local btnX = inventoryGbox:GetWidth() - 492
        local btnY = inventoryGbox:GetHeight() - 290 -- 290
        local mccbtn = invframe:CreateOrGetControl("button", "mcc", btnX, btnY, 30, 32)
        AUTO_CAST(mccbtn)
        mccbtn:SetSkinName("test_red_button")
        mccbtn:SetTextAlign("right", "center")
        mccbtn:SetText("{img monsterbtn_image 28 23}{/}")
        -- mccqbtn:SetEventScript(ui.LBUTTONUP, "MONSTERCARDPRESET_FRAME_OPEN")
        mccbtn:SetEventScript(ui.RBUTTONUP, "monstercard_changer_frame_init")
        -- print("ok")
    end
end

function monstercard_changer_frame_close(frame)
    ui.CloseFrame(addonName)
end

function monstercard_changer_frame_init()

    local frame = ui.GetFrame(addonName)
    if frame:IsVisible() == 1 then
        monstercard_changer_frame_close(frame)
        return
    end
    -- frame:Setrect(-150, 0)
    local closebtn = GET_CHILD_RECURSIVELY(frame, 'close')
    closebtn:SetEventScript(ui.LBUTTONUP, "monstercard_changer_frame_close")
    AUTO_CAST(closebtn)

    local droplist = GET_CHILD_RECURSIVELY(frame, "preset_list")
    frame:RemoveChild("preset_list")

    local old_tab = GET_CHILD_RECURSIVELY(frame, "tab")
    if old_tab ~= nil then
        frame:RemoveChild("tab")
    end

    local tab = frame:CreateOrGetControl("tab", "tab", 665, 40, ui.LEFT, ui.TOP, 48, 58, 0, 0);
    -- tab:SetEventScript(ui.LBUTTONUP, "ANCIENTPRESET_ON_TAB_CHANGE");
    AUTO_CAST(tab)
    tab:SetSkinName("tab2")
    tab:AddItem("{@st66b}{s16}nowset", true, "", "", "", "", "", false)
    tab:SetEventScript(ui.LBUTTONUP, "monstercard_changer_slot_init")
    for i = 2, 5 do
        tab:AddItem("{@st66b}{s16}set " .. i - 1, true, "", "", "", "", "", false)

    end
    tab:SetItemsFixWidth(80)
    tab:SetItemsAdjustFontSizeByWidth(80);

    local DEFcardGbox = GET_CHILD_RECURSIVELY(frame, 'DEFcardGbox')
    AUTO_CAST(DEFcardGbox)
    -- DEFcardGbox:SetMargin(-150, 0, 0, 0)
    DEFcardGbox:SetOffset(50, -70, 0, 0)
    local STATcardGbox = GET_CHILD_RECURSIVELY(frame, 'STATcardGbox')
    AUTO_CAST(STATcardGbox)
    STATcardGbox:SetOffset(50, 70, 0, 0)

    CARD_SLOT_CREATE(frame, "ATK", 0 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
    CARD_SLOT_CREATE(frame, 'DEF', 1 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
    CARD_SLOT_CREATE(frame, 'UTIL', 2 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
    CARD_SLOT_CREATE(frame, 'STAT', 3 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
    CARD_SLOT_CREATE(frame, 'LEG', 4 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)

    local isOpen = frame:GetUserIValue("CARD_OPTION_OPENED");
    local optionGbox = GET_CHILD_RECURSIVELY(frame, "option_bg")
    optionGbox:ShowWindow(1)

    monstercard_changer_CARD_OPTION_OPEN(frame)
    frame:SetUserValue("CARD_OPTION_OPENED", 0);

    frame:ShowWindow(1)
    -- CHAT_SYSTEM(tostring(MONSTER_CARD_SLOT_COUNT_PER_TYPE))

    -- frame:ShowWindow(1)

end

function monstercard_changer_slot_init(frame, ctrl)

    local frame = frame:GetTopParentFrame();
    local tab = frame:GetChild("tab")
    AUTO_CAST(tab)
    local tabindex = tab:GetSelectItemIndex();
    -- CHAT_SYSTEM(tostring(tabindex))
    if tabindex == 0 then

        -- CHAT_SYSTEM("monstercard_changer_slot_init")
        CARD_SLOT_CREATE(frame, "ATK", 0 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
        CARD_SLOT_CREATE(frame, 'DEF', 1 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
        CARD_SLOT_CREATE(frame, 'UTIL', 2 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
        CARD_SLOT_CREATE(frame, 'STAT', 3 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
        CARD_SLOT_CREATE(frame, 'LEG', 4 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)

        local isOpen = frame:GetUserIValue("CARD_OPTION_OPENED");
        local optionGbox = GET_CHILD_RECURSIVELY(frame, "option_bg")
        optionGbox:ShowWindow(1)

        monstercard_changer_CARD_OPTION_OPEN(frame)
        frame:SetUserValue("CARD_OPTION_OPENED", 0);

        print("start")
        local test1 = frame:GetUserValue("EQUIP_CARD_GUID")
        print("test1:" .. tostring(test1.ClassID))
        local test2 = frame:GetUserValue("EQUIP_CARD_SLOTINDEX")
        print("test2:" .. tostring(test2))
        local test3 = frame:GetUserValue("CARD_OPTION_OPENED")
        print("test3:" .. tostring(test3))
        local test4 = frame:GetUserValue("CARD_OPTION_INDEX")
        print("test4:" .. tostring(test4))
        local test5 = frame:GetUserValue("DUPLICATE_COUNT")
        print("test5:" .. tostring(test5))
        local test6 = frame:GetUserValue("IS_EQUIP_TYPE")
        print("test6:" .. tostring(test6))
        local test7 = frame:GetUserValue("DUPLICATE_OPTION_VALUE")
        print("test7:" .. tostring(test7))
        local test8 = frame:GetUserValue("DUPLICATE_OPTION_VALUE1")
        print("test8:" .. tostring(test8))
        local test9 = frame:GetUserValue("DUPLICATE_OPTION_VALUE2")
        print("test9:" .. tostring(test9))
        local test10 = frame:GetUserValue("DUPLICATE_OPTION_VALUE3")
        print("test10:" .. tostring(test10))
        local test11 = frame:GetUserValue("PREINDEX")
        print("test11:" .. tostring(test11))
        local test12 = frame:GetUserValue("CARD_TEMP_CLASSID")
        print("test12:" .. tostring(test12))
        local test13 = frame:GetUserValue("CARD_TEMP_LEVEL")
        print("test13:" .. tostring(test13))
        local test14 = frame:GetUserValue("CARD_TEMP_EXP")
        print("test14:" .. tostring(test14))
    else
        local ATKcard_slotset = GET_CHILD_RECURSIVELY(frame, 'ATKcard_slotset')
        -- local groupName = string.gsub(ATKcard_slotset, 'card_slotset', '');
        for slotIndex = "slot" .. 1, 3 do
            -- argStr
            local argStr = slotIndex .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
            pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr);
        end

        AUTO_CAST(ATKcard_slotset)
        -- ATKcard_slotset:ClearIconAll()
        frame:SetUserValue("REMOVE_CARD_SLOTINDEX", 0)
        local test1 = frame:GetUserValue("EQUIP_CARD_GUID")
        print(tostring(test1.ClassID))
        local test2 = frame:GetUserValue("EQUIP_CARD_SLOTINDEX")
        print(tostring(test2))
        local test3 = frame:GetUserValue("CARD_OPTION_OPENED")
        print(tostring(test3))
        local test4 = frame:GetUserValue("CARD_OPTION_INDEX")
        print(tostring(test4))
        local test5 = frame:GetUserValue("DUPLICATE_COUNT")
        print(tostring(test5))
        local test6 = frame:GetUserValue("IS_EQUIP_TYPE")
        print(tostring(test6))

        local test7 = frame:GetUserValue("DUPLICATE_OPTION_VALUE")
        print(tostring(test7))
        frame:SetUserValue("DUPLICATE_OPTION_VALUE1", "")
        local test8 = frame:GetUserValue("DUPLICATE_OPTION_VALUE1")
        print(tostring(test8))
        local test9 = frame:GetUserValue("DUPLICATE_OPTION_VALUE2")
        print(tostring(test9))
        local test10 = frame:GetUserValue("DUPLICATE_OPTION_VALUE3")
        print(tostring(test10))
        local test11 = frame:GetUserValue("PREINDEX")
        print(tostring(test11))
        local test12 = frame:GetUserValue("CARD_TEMP_CLASSID")
        print(tostring(test12))
        local test13 = frame:GetUserValue("CARD_TEMP_LEVEL")
        print(tostring(test13))
        local test14 = frame:GetUserValue("CARD_TEMP_EXP")
        print(tostring(test14))

        local DEFcard_slotset = GET_CHILD_RECURSIVELY(frame, 'DEFcard_slotset')
        AUTO_CAST(DEFcard_slotset)
        DEFcard_slotset:ClearIconAll()
        local UTILcard_slotset = GET_CHILD_RECURSIVELY(frame, 'UTILcard_slotset')
        AUTO_CAST(UTILcard_slotset)
        UTILcard_slotset:ClearIconAll()
        local STATcard_slotset = GET_CHILD_RECURSIVELY(frame, 'STATcard_slotset')
        AUTO_CAST(STATcard_slotset)
        STATcard_slotset:ClearIconAll()
        local optionGbox = GET_CHILD_RECURSIVELY(frame, 'option_bg')
        optionGbox:RemoveAllChild()

    end
    -- monstercard_changer_get_card_info()
end

function monstercard_changer_CARD_OPTION_OPEN(monsterCardSlotFrame)
    local frame = monsterCardSlotFrame;
    if frame == nil then
        frame = ui.GetFrame('monstercardslot')
    end

    local isOpen = frame:GetUserIValue("CARD_OPTION_OPENED");
    if isOpen == nil then
        return;
    end

    local optionGbox = GET_CHILD_RECURSIVELY(frame, 'option_bg')
    local optionBtn = frame:GetChild('optionBtn');

    local bg = frame:GetChild('bg');
    local mainGbox = frame:GetChild('mainGbox');
    local pip = frame:GetChild('pip4');

    local option_H = optionGbox:GetHeight();
    local bg_X = bg:GetOriginalX();
    local bg_Y = bg:GetOriginalY();
    local bg_W = bg:GetWidth();
    local bg_H = bg:GetHeight();

    monstercard_changer_CARD_OPTION_CREATE(frame)
    bg:Resize(bg_X, bg_Y, bg_W, mainGbox:GetHeight() + pip:GetHeight() + option_H);
end

function monstercard_changer_CARD_OPTION_CREATE(monsterCardSlotFrame)
    local frame = monsterCardSlotFrame;
    if frame == nil then
        frame = ui.GetFrame('monstercardslot')
    end

    local optionGbox = GET_CHILD_RECURSIVELY(frame, "option_bg")
    if optionGbox ~= nil then
        optionGbox:RemoveAllChild();
    end

    local optionIndex = -1
    frame:SetUserValue("CARD_OPTION_INDEX", optionIndex);
    frame:SetUserValue("LABEL_HEIGHT", 0);
    local duplicateCount = 0;
    frame:SetUserValue("DUPLICATE_COUNT", 0)
    local currentHeight = 0;

    local clientMessage = ""

    local cardSlotCount_max = MAX_NORMAL_MONSTER_CARD_SLOT_COUNT
    local cardSlotCount_type = MONSTER_CARD_SLOT_COUNT_PER_TYPE
    local cardGroupCount = MAX_NORMAL_MONSTER_CARD_SLOT_COUNT / MONSTER_CARD_SLOT_COUNT_PER_TYPE

    local deleteLabelIndex = -1;

    --[[local legendCardSlotset = GET_CHILD_RECURSIVELY
    -- 전설카드 껴있는지 확인하고 껴있으면 해당 옵션 여기다가 그려주자

    -- 숫자 12 빼줘야함
    local legendCardID, legendCardLv, legendCardExp = GETMYCARD_INFO(12)

    local prop = geItemTable.GetProp(legendCardID);
    if prop ~= nil then
        legendCardLv = prop:GetLevel(legendCardExp);
    end

    if legendCardID ~= nil and legendCardID ~= 0 then
        clientMessage = 'MonsterCardOptionGroupLEG'
        optionIndex = frame:GetUserIValue("CARD_OPTION_INDEX");
        monstercard_changer_CARD_OPTION_CREATE_BY_GROUP(frame, 12, clientMessage, legendCardID, legendCardLv,
            legendCardExp, optionIndex, labelIndex)

        optionIndex = frame:GetUserIValue("CARD_OPTION_INDEX");
        labelHeight = frame:GetUserIValue("LABEL_HEIGHT");
        currentHeight = frame:GetUserIValue("CURRENT_HEIGHT");
        local labelline = optionGbox:CreateOrGetControlSet('labelline', 'labelline_' .. 4, 0, 0);
        labelline:Move(0, currentHeight + labelHeight + labelline:GetHeight())
        frame:SetUserValue("LABEL_HEIGHT", labelHeight + labelline:GetHeight());
        frame:SetUserValue("CURRENT_HEIGHT", currentHeight);
        deleteLabelIndex = 4
    end]]

    for i = 0, 3 do
        frame:SetUserValue("DUPLICATE_COUNT", 0)
        if i == 0 then
            clientMessage = 'MonsterCardOptionGroupATK'
        elseif i == 1 then
            clientMessage = 'MonsterCardOptionGroupDEF'
        elseif i == 2 then
            clientMessage = 'MonsterCardOptionGroupUTIL'
        elseif i == 3 then
            clientMessage = 'MonsterCardOptionGroupSTAT'
        end

        local cardID, cardLv, cardExp = 0, 0, 0
        local isEquipThisTypeCard = -1

        frame:SetUserValue("IS_EQUIP_TYPE", isEquipThisTypeCard)
        frame:SetUserValue("DUPLICATE_OPTION_VALUE", 0)

        for j = 0, cardSlotCount_type - 1 do
            optionIndex = frame:GetUserIValue("CARD_OPTION_INDEX");
            local labelHeight = frame:GetUserIValue("LABEL_HEIGHT");
            -- CHAT_SYSTEM(tostring(labelHeight))
            if frame:GetName() == "monstercard_changer" then
                cardID, cardLv, cardExp = GETMYCARD_INFO(i * cardSlotCount_type + j);
            else
                cardID, cardLv, cardExp = _GETMYCARD_INFO(i * cardSlotCount_type + j);
            end

            if cardID ~= 0 then
                monstercard_changer_CARD_OPTION_CREATE_BY_GROUP(frame, i * cardSlotCount_type + j, clientMessage,
                    cardID, cardLv, cardExp, optionIndex, labelIndex)
            end
        end

        currentHeight = frame:GetUserIValue("CURRENT_HEIGHT");
        isEquipThisTypeCard = frame:GetUserIValue("IS_EQUIP_TYPE")
        if isEquipThisTypeCard ~= -1 then
            local labelHeight = frame:GetUserIValue("LABEL_HEIGHT");
            local labelline = optionGbox:CreateOrGetControlSet('labelline', 'labelline_' .. i, 0, 0);
            labelline:Move(0, currentHeight + labelHeight + labelline:GetHeight())
            frame:SetUserValue("LABEL_HEIGHT", labelHeight + labelline:GetHeight());
            frame:SetUserValue("CURRENT_HEIGHT", currentHeight);
            deleteLabelIndex = i
        end
    end

    if deleteLabelIndex ~= -1 then
        local labelline = optionGbox:CreateOrGetControlSet('labelline', 'labelline_' .. deleteLabelIndex, 0, 0);
        labelline:ShowWindow(0)
    end

    local arrowText = frame:GetUserConfig("OPTION_BTN_TEXT_CLOSE");
    local optionBtn = GET_CHILD_RECURSIVELY(frame, "optionBtn")
    if optionBtn ~= nil then
        optionBtn:SetText(arrowText)
    end

    optionGbox:ShowWindow(1)
    frame:SetUserValue("CARD_OPTION_OPENED", 1);
end

function monstercard_changer_CARD_OPTION_CREATE_BY_GROUP(monsterCardSlotFrame, i, clientMessage, cardID, cardLv,
    cardExp, optionIndex, labelIndex)
    local frame = monsterCardSlotFrame;
    if frame == nil then
        frame = ui.GetFrame('monstercardslot')
    end

    local itemcls = GetClassByType("Item", cardID)
    if itemcls == nil then
        return
    end

    local strInfo = ""
    local optionValue = {}
    optionValue[1] = frame:GetUserIValue("DUPLICATE_OPTION_VALUE1")
    optionValue[2] = frame:GetUserIValue("DUPLICATE_OPTION_VALUE2")
    optionValue[3] = frame:GetUserIValue("DUPLICATE_OPTION_VALUE3")

    local optionValue_temp = {}
    optionValue_temp[1] = 0
    optionValue_temp[2] = 0
    optionValue_temp[3] = 0

    local itemClassName = itemcls.ClassName
    local cardcls = GetClass("EquipBossCard", itemClassName);
    if cardcls == nil then
        return;
    end

    local optionImage = string.format("%s", ClMsg(clientMessage));
    strInfo = strInfo .. optionImage

    local optionGbox = GET_CHILD_RECURSIVELY(frame, "option_bg")
    local itemClsCtrl = nil

    local duplicateOptionIndex = -1
    local duplicateCount = frame:GetUserIValue("DUPLICATE_COUNT")

    local optionTextValue = cardcls.OptionTextValue
    local optionTextValueList = StringSplit(optionTextValue, "/")

    if optionTextValueList == nil then
        return
    end

    for j = 0, i - 1 do
        local cardID_temp, cardLv_temp
        if frame:GetName() == "monstercard_changer" then
            cardID_temp, cardLv_temp = GETMYCARD_INFO(j);
        else
            cardID_temp, cardLv_temp = _GETMYCARD_INFO(j);
        end
        if cardID == cardID_temp then
            if duplicateOptionIndex == -1 then
                duplicateOptionIndex = j
                local preIndex = frame:GetUserIValue("PREINDEX")
                local cardID_flag
                if frame:GetName() == "monstercard_changer" then
                    cardID_flag = GETMYCARD_INFO(preIndex);
                else
                    cardID_flag = _GETMYCARD_INFO(preIndex);
                end
                if i - j == 2 and preIndex ~= j and cardID_flag ~= cardID_temp then
                    duplicateCount = duplicateCount + 1
                end
            end

            for k = 1, #optionTextValueList do
                optionValue_temp[k] = optionValue_temp[k] + optionTextValueList[k] * cardLv_temp
            end
        end
    end

    if optionGbox ~= nil then
        if duplicateOptionIndex == -1 then
            optionIndex = optionIndex + 1
            itemClsCtrl = optionGbox:CreateOrGetControlSet('eachoption_in_monstercard', 'OPTION_CSET_' .. i, 0, 0);
            for k = 1, #optionTextValueList do
                optionValue_temp[k] = optionValue_temp[k] + optionTextValueList[k] * cardLv
            end

            local optionText = cardcls.OptionText
            local temp = dictionary.ReplaceDicIDInCompStr(optionText);
            optionText = string.format(temp, optionValue_temp[1], optionValue_temp[2], optionValue_temp[3])

            strInfo = strInfo .. optionText
        else
            itemClsCtrl = optionGbox:CreateOrGetControlSet('eachoption_in_monstercard',
                'OPTION_CSET_' .. duplicateOptionIndex, 0, 0);

            for k = 1, #optionTextValueList do
                optionValue[k] = optionValue_temp[k] + optionTextValueList[k] * cardLv
            end

            local optionText = cardcls.OptionText
            local temp = dictionary.ReplaceDicIDInCompStr(optionText);
            optionText = string.format(temp, optionValue[1], optionValue[2], optionValue[3])

            strInfo = strInfo .. optionText
            frame:SetUserValue("DUPLICATE_OPTION_VALUE1", optionValue[1])
            frame:SetUserValue("DUPLICATE_OPTION_VALUE2", optionValue[2])
            frame:SetUserValue("DUPLICATE_OPTION_VALUE3", optionValue[3])
        end

        itemClsCtrl = AUTO_CAST(itemClsCtrl)
        local pos_y = itemClsCtrl:GetUserConfig("POS_Y")
        local labelHeight = frame:GetUserIValue("LABEL_HEIGHT")
        itemClsCtrl:Move(0, (optionIndex - duplicateCount) * pos_y + labelHeight)
        local optionList = GET_CHILD_RECURSIVELY(itemClsCtrl, "option_name", "ui::CRichText");
        optionList:SetText(strInfo)
        frame:SetUserValue("CURRENT_HEIGHT", (optionIndex + 1) * pos_y);
    end

    frame:SetUserValue("IS_EQUIP_TYPE", i)
    frame:SetUserValue("CARD_OPTION_INDEX", optionIndex);
    frame:SetUserValue("DUPLICATE_COUNT", duplicateCount)
    frame:SetUserValue("PREINDEX", i)
end
