-- v1.0.1 カードをインベントリを探してなければ装備する数を倉庫から搬出。装備してたカードだけを倉庫へ搬入。
-- v1.0.2 バグ修正
-- v1.0.3 カードを3枚セットで運用に変更
-- v1.0.4 装備ボタン、外すボタンの運用見直し。ディレイ数値の見直し。
local addonName = "monstercard_change"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.4"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")

local base = {}
local curPreset = 0

g.slotindex = 0

g.cardlist = {}
g.cardlv = {}
g.cardcount = {}
-- session.ResetItemList()

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

function MONSTERCARD_CHANGE_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    addon:RegisterMsg('GAME_START_3SEC', 'monstercard_change_inventory_frame_init');
    -- addon:RegisterMsg('GAME_START_3SEC', 'monstercard_change_preset_frame_init');
    -- g.SetupHook(monstercard_change_CARD_SLOT_RBTNUP_ITEM_INFO, "CARD_SLOT_RBTNUP_ITEM_INFO")

end

-- 外す処理開始
function monstercard_change_get_info()
    local frame = ui.GetFrame('monstercardpreset')

    monstercard_change_CARD_PRESET_SELECT_PRESET(frame)

    local allnil = true
    for index = 0, 11 do

        local cardID, cardLv, cardExp = _GETMYCARD_INFO(index);

        if cardID ~= 0 then
            allnil = false
            break
        end
    end

    g.cardlist = {}
    g.cardlv = {}
    g.cardcount = {}

    if allnil == false then
        g.slotindex = 0

        for index = 0, 11 do
            local cardID, cardLv, cardExp = GETMYCARD_INFO(index);

            table.insert(g.cardlist, cardID)
            table.insert(g.cardlv, cardLv)
            if g.cardcount[cardID] == nil then
                g.cardcount[cardID] = 3

            end
        end

        for index = 0, 11 do
            local cardID, cardLv, cardExp = GETMYCARD_INFO(index);
            if cardID ~= 0 then
                g.slotindex = index
                break
            end

        end

        if g.slotindex == 11 then
            return
        else
            monstercard_change_unequip()
            return
        end
    else
        for index = 0, 11 do
            local cardID, cardLv, cardExp = GETMYCARD_INFO(index);

            table.insert(g.cardlist, cardID)
            table.insert(g.cardlv, cardLv)
            if g.cardcount[cardID] == nil then
                g.cardcount[cardID] = 3
            end
        end
        -- testcode
        --[[ for key, count in pairs(g.cardcount) do
            local cardInfo = GetClassByType("Item", key)
            if cardInfo then
                local cardname = cardInfo.ClassName
                print("カードID " .. tostring(cardname) .. " : " .. count .. " 回出現しました。")
            end
        end]]

        pc.ReqExecuteTx_NumArgs("SCR_TX_APPLY_CARD_PRESET", tonumber(4))
        _DISABLE_CARD_PRESET_APPLY_SAVE_BTN()
        g.slotindex = 0
        g.cardlist = {}
        g.cardlv = {}
        g.cardcount = {}
        --[[local awframe = ui.GetFrame("accountwarehouse")
        if awframe:IsVisible() == 1 then
            ReserveScript(monstercard_change_put_inv_to_warehouse(), 3.0)
            return
        else
            return
        end]]

    end

end

function monstercard_change_get_info_accountwarehouse()

    local frame = ui.GetFrame('monstercardpreset')
    monstercard_change_CARD_PRESET_SELECT_PRESET(frame)

    local allnil = true
    for index = 0, 11 do

        local cardID, cardLv, cardExp = _GETMYCARD_INFO(index);

        if cardID ~= 0 then
            allnil = false
            break
        end
    end

    g.cardlist = {}
    g.cardlv = {}
    g.cardcount = {}

    if allnil == false then
        g.slotindex = 0

        for index = 0, 11 do
            local cardID, cardLv, cardExp = GETMYCARD_INFO(index);

            table.insert(g.cardlist, cardID)
            table.insert(g.cardlv, cardLv)
            if g.cardcount[cardID] == nil then
                g.cardcount[cardID] = 3

            end
        end

        for index = 0, 11 do
            local cardID, cardLv, cardExp = GETMYCARD_INFO(index);
            if cardID ~= 0 then
                g.slotindex = index
                break
            end

        end

        if g.slotindex == 11 then
            return
        else
            monstercard_change_unequip()
            return
        end
    else
        for index = 0, 11 do
            local cardID, cardLv, cardExp = GETMYCARD_INFO(index);

            table.insert(g.cardlist, cardID)
            table.insert(g.cardlv, cardLv)
            if g.cardcount[cardID] == nil then
                g.cardcount[cardID] = 3
            end
        end
        -- testcode
        --[[for key, count in pairs(g.cardcount) do
            local cardInfo = GetClassByType("Item", key)
            if cardInfo then
                local cardname = cardInfo.ClassName
                print("カードID " .. tostring(cardname) .. " : " .. count .. " 回出現しました。")
            end
        end]]

        pc.ReqExecuteTx_NumArgs("SCR_TX_APPLY_CARD_PRESET", tonumber(4))
        -- _DISABLE_CARD_PRESET_APPLY_SAVE_BTN()
        g.slotindex = 0
        ReserveScript("monstercard_change_put_inv_to_warehouse()", 1.0)

        --[[g.cardlist = {}
        g.cardlv = {}
        g.cardcount = {}
        local awframe = ui.GetFrame("accountwarehouse")
        if awframe:IsVisible() == 1 then
            ReserveScript(monstercard_change_put_inv_to_warehouse(), 3.0)
            return
        else
            return
        end]]

    end

end

-- 外したカードの倉庫搬入処理
function monstercard_change_put_inv_to_warehouse()
    -- CHAT_SYSTEM("test")

    local msgframe = ui.GetFrame(addonNameLower)
    msgframe:Resize(560, 150)
    msgframe:SetPos(750, 300)
    msgframe:ShowTitleBar(0);
    msgframe:SetSkinName("None")
    msgframe:SetGravity(ui.CENTER, ui.CENTER);
    msgframe:SetLayerLevel(98)

    local text1 = msgframe:CreateOrGetControl('richtext', 'text1', 25, 25)
    AUTO_CAST(text1)
    text1:SetText(
        "{s20}{ol}{#CCCC22}[MCC]Operating. Do not perform{nl}other operations to prevent bugs.{nl}[MCC]動作中。バグ防止の為、{nl}他の動作は行わないでください。")
    msgframe:ShowWindow(1)

    local frame = ui.GetFrame("accountwarehouse")
    local fromFrame = ui.GetFrame("inventory");
    local cardTab = GET_CHILD_RECURSIVELY(fromFrame, "inventype_Tab")
    cardTab:SelectTab(4)

    if frame:IsVisible() == 1 then

        local invItemList = session.GetInvItemList()
        local guidList = invItemList:GetGuidList();
        local cnt = guidList:Count();
        for i = 0, cnt - 1 do
            local guid = guidList:Get(i);
            local invItem = invItemList:GetItemByGuid(guid)
            local itemobj = GetIES(invItem:GetObject())
            local itemlv = TryGetProp(itemobj, "Level", 0)
            local iesid = invItem:GetIESID()

            for cardID, count in pairs(g.cardcount) do

                if g.cardcount[cardID] ~= nil and g.cardcount[cardID] > 0 and tostring(itemobj.ClassID) ==
                    tostring(cardID) then

                    -- for _, cardid in pairs(g.cardlist) do
                    -- print(cardid)
                    -- if tostring(itemobj.ClassID) == tostring(cardid) then
                    for _, lv in pairs(g.cardlv) do
                        if tostring(itemlv) == tostring(lv) then

                            g.cardcount[cardID] = g.cardcount[cardID] - 1
                            -- testcode
                            local cardname = itemobj.ClassName
                            -- print("inwarehouse: " .. tostring(cardname) .. g.cardcount[cardID])

                            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, iesid, 1, nil, nil)
                            session.ResetItemList()
                            ReserveScript("monstercard_change_put_inv_to_warehouse()", 0.4)
                            return -- 整合が見つかったら関数を終了
                            -- break
                        end
                    end
                    -- end
                    -- end

                end
            end
            -- end
            -- end
            -- monstercard_change_end_of_operation()
            -- return
        end
        MONSTERCARDSLOT_CLOSE()
        monstercard_change_end_of_operation()
        return
    end
    MONSTERCARDSLOT_CLOSE()
    monstercard_change_end_of_operation()
    return
end

function monstercard_change_CARD_PRESET_SELECT_PRESET(frame)
    local frame = ui.GetFrame('monstercardpreset')
    local droplist = GET_CHILD_RECURSIVELY(frame, "preset_list")
    AUTO_CAST(droplist)
    droplist:SelectItem(tonumber(4))
    CARD_PRESET_CLEAR_SLOT(frame)
    local page = tonumber(droplist:GetSelItemKey(4))
    CARD_PRESET_SHOW_PRESET(page)

end

-- 5番目のプリセットも埋まっている場合は順番に外す。めちゃ遅いよ
function monstercard_change_unequip()

    -- print(g.slotindex)
    local frame = ui.GetFrame("monstercardslot")

    if g.slotindex <= 2 then

        for i = 0, 2 do
            local ATKcard_slotset = GET_CHILD_RECURSIVELY(frame, "ATKcard_slotset")
            local slot = GET_CHILD(ATKcard_slotset, "slot" .. (g.slotindex + 1))
            local icon = slot:GetIcon()

            if icon ~= nil then

                local argStr = g.slotindex .. " 1"
                pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)
                ReserveScript("monstercard_change_unequip()", 0.2)
                return
            else

                g.slotindex = g.slotindex + 1
                ReserveScript("monstercard_change_unequip()", 0.2)
                return
            end
        end
    elseif g.slotindex <= 5 and g.slotindex >= 3 then
        for i = 0, 2 do
            local DEFcard_slotset = GET_CHILD_RECURSIVELY(frame, "DEFcard_slotset")
            local slot = GET_CHILD(DEFcard_slotset, "slot" .. (g.slotindex - 2))
            local icon = slot:GetIcon()

            if icon ~= nil then

                local argStr = g.slotindex .. " 1"
                pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)
                ReserveScript("monstercard_change_unequip()", 0.2)
                return
            else
                g.slotindex = g.slotindex + 1
                ReserveScript("monstercard_change_unequip()", 0.2)
                return
            end
        end
    elseif g.slotindex <= 8 and g.slotindex >= 6 then
        for i = 0, 2 do
            local UTILcard_slotset = GET_CHILD_RECURSIVELY(frame, "UTILcard_slotset")
            local slot = GET_CHILD(UTILcard_slotset, "slot" .. (g.slotindex - 5))
            local icon = slot:GetIcon()

            if icon ~= nil then

                local argStr = g.slotindex .. " 1"
                pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)
                ReserveScript("monstercard_change_unequip()", 0.2)
                return
            else
                g.slotindex = g.slotindex + 1
                ReserveScript("monstercard_change_unequip()", 0.2)
                return
            end
        end
    elseif g.slotindex <= 11 and g.slotindex >= 9 then
        for i = 0, 2 do
            local STATcard_slotset = GET_CHILD_RECURSIVELY(frame, "STATcard_slotset")
            local slot = GET_CHILD(STATcard_slotset, "slot" .. (g.slotindex - 8))
            local icon = slot:GetIcon()

            if icon ~= nil then

                local argStr = g.slotindex .. " 1"
                pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)
                ReserveScript("monstercard_change_unequip()", 0.2)
                return
            else
                g.slotindex = g.slotindex + 1
                ReserveScript("monstercard_change_unequip()", 0.2)
                return
            end
        end
    else
        g.slotindex = 0

        local awframe = ui.GetFrame("accountwarehouse")
        if awframe:IsVisible() == 1 then
            monstercard_change_put_inv_to_warehouse()
            return
        else
            return
        end
    end
end

function monstercard_change_end_of_operation()
    ui.CloseFrame(addonNameLower)
    ui.CloseFrame("monstercardpreset")
    ui.CloseFrame("monstercardslot")
    g.cardlist = {}
    g.cardlv = {}
    g.cardcount = {}
    ui.SysMsg("[MCC]end of operation")
end

-- カードを着ける処理
function monstercard_change_get_presetinfo()
    -- g.slotindex = 0
    g.cardlist = {}
    g.cardlv = {}
    g.cardcount = {}

    for index = 0, 11 do
        local cardID, cardLv, cardExp = _GETMYCARD_INFO(index);
        table.insert(g.cardlist, cardID)
        table.insert(g.cardlv, cardLv)
        if g.cardcount[cardID] == nil then
            g.cardcount[cardID] = 3

            -- g.presetcardcount[cardID] = g.presetcardcount[cardID] + 1 -- 既に出現している場合はカウントを増やす
        end
    end

    -- testcode
    --[[for key, value in pairs(g.cardcount) do
        print(tostring(key.ClassName) .. " : " .. g.cardcount[value])
    end]]
    -- print("loopcount: " .. g.loopcount)
    monstercard_change_CARD_PRESET_APPLY_PRESET()
    return
end

function monstercard_change_CARD_PRESET_APPLY_PRESET()
    local frame = ui.GetFrame("monstercardpreset")
    local fromframe = ui.GetFrame("accountwarehouse")
    -- local cardList, expList = monstercard_change_CARD_PRESET_GET_CARD_EXP_LIST(frame)
    local droplist = GET_CHILD_RECURSIVELY(frame, "preset_list")
    local page = tonumber(droplist:GetSelItemKey())

    if fromframe:IsVisible() == 0 then

        if page ~= nil then
            pc.ReqExecuteTx_NumArgs("SCR_TX_APPLY_CARD_PRESET", page)
            _DISABLE_CARD_PRESET_APPLY_SAVE_BTN()
            g.cardlist = {}
            g.cardlv = {}
            g.cardcount = {}
            return
        end

    else
        monstercard_change_warehouse()
        return
    end

end
-- インベントリに何枚あるか調査
--[[function monstercard_change_inventry()

    local msgframe = ui.GetFrame(addonNameLower)
    msgframe:Resize(560, 150)
    msgframe:SetPos(750, 300)
    msgframe:ShowTitleBar(0);
    msgframe:SetSkinName("None")
    msgframe:SetGravity(ui.CENTER, ui.CENTER);

    local text1 = msgframe:CreateOrGetControl('richtext', 'text1', 25, 25)
    AUTO_CAST(text1)
    text1:SetText(
        "{s20}{ol}{#CCCC22}[MCC]Operating. Do not perform{nl}other operations to prevent bugs.{nl}[MCC]動作中。バグ防止の為、{nl}他の動作は行わないでください。")
    msgframe:ShowWindow(1)

    local fromFrame = ui.GetFrame("inventory");
    local cardTab = GET_CHILD_RECURSIVELY(fromFrame, "inventype_Tab")
    cardTab:SelectTab(4)
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList();
    local cnt = guidList:Count();
    for i = 0, cnt - 1 do
        local guid = guidList:Get(i);
        local invItem = invItemList:GetItemByGuid(guid)
        local itemobj = GetIES(invItem:GetObject())
        local itemlv = TryGetProp(itemobj, "Level", 0)
        local iesid = invItem:GetIESID()
        local iesid_table = {}

        for cardID, count in pairs(g.cardcount) do

            if g.cardcount[cardID] ~= nil and g.cardcount[cardID] > 0 and tostring(itemobj.ClassID) == tostring(cardID) then
                -- for _, cardid in pairs(g.cardlist) do
                -- if tostring(itemobj.ClassID) == tostring(cardid) then
                for _, lv in pairs(g.cardlv) do
                    if tostring(itemlv) == tostring(lv) then
                        for _, iesID in pairs(iesid_table) do
                            if tostring(iesid) ~= tostring(iesID) then
                                table.insert(iesid_table, iesid)
                                g.cardcount[cardID] = g.cardcount[cardID] - 1
                                -- testcode
                                local cardname = itemobj.ClassName
                                print("inv: " .. tostring(cardname) .. g.cardcount[cardID])

                                ReserveScript("monstercard_change_inventry()", 0.2)
                                return
                            end
                        end
                    end
                end
                -- end
                -- end

            end

        end
    end

    monstercard_change_warehouse()
    return
end]]

-- インベントリに足りなければ3枚になるまで補充。無ければ終了
function monstercard_change_warehouse()

    local frame = ui.GetFrame("monstercardpreset")

    local fromframe = ui.GetFrame("accountwarehouse")
    -- local cardList, expList = monstercard_change_CARD_PRESET_GET_CARD_EXP_LIST(frame)
    local droplist = GET_CHILD_RECURSIVELY(frame, "preset_list")
    local page = tonumber(droplist:GetSelItemKey())

    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetSortedGuidList();
    local sortedCnt = sortedGuidList:Count();
    -- for i = 1, math.min(#cardList, 12) do

    for i = 0, sortedCnt - 1 do
        local guid = sortedGuidList:Get(i)
        local invItem = itemList:GetItemByGuid(guid)
        local iesid = invItem:GetIESID()

        local obj = GetIES(invItem:GetObject());
        local cardLevel = TryGetProp(obj, 'Level', 1)

        if obj.ClassName ~= MONEY_NAME then
            for cardID, count in pairs(g.cardcount) do
                -- print(tostring(obj.ClassID) .. ":" .. tostring(cardID))
                if g.cardcount[cardID] ~= nil and g.cardcount[cardID] > 0 and tostring(obj.ClassID) == tostring(cardID) then
                    for _, lv in pairs(g.cardlv) do
                        if tostring(cardLevel) == tostring(lv) then

                            g.cardcount[cardID] = g.cardcount[cardID] - 1
                            -- testcode
                            local cardname = obj.ClassName
                            -- print("outwarehouse: " .. tostring(cardname) .. g.cardcount[cardID])

                            session.ResetItemList()
                            session.AddItemID(tonumber(iesid), 1)
                            item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                                                            fromframe:GetUserIValue("HANDLE"))
                            ReserveScript("monstercard_change_warehouse()", 0.2)

                            return
                        end
                    end
                end
            end

        end

    end

    -- end
    if page ~= nil then
        pc.ReqExecuteTx_NumArgs("SCR_TX_APPLY_CARD_PRESET", page)
        _DISABLE_CARD_PRESET_APPLY_SAVE_BTN()
        ReserveScript("monstercard_change_end_of_operation()", 1.0)
        return
    end

end

-- 誤操作防止のためプリセット登録前の確認工程追加
function monstercard_change_msgbox(frame, ctrl)

    frame = ui.GetFrame("monstercardpreset")
    local msg = "Do you want to register the information of the card currently equipped to the current preset?{nl}" ..
                    "現在装備中のカード情報を、現在のプリセットに登録しますか？"
    local yesscp = string.format("monstercard_change_CARD_PRESET_SAVE_PRESET('%s', '%s')", frame, ctrl)
    ui.MsgBox(msg, yesscp, "None")

end

function monstercard_change_CARD_PRESET_SAVE_PRESET(parent, self)
    local parent = ui.GetFrame("monstercardslot")
    local cardList, expList = CARD_PRESET_GET_CARD_EXP_LIST(parent)
    local frame = ui.GetFrame("monstercardpreset")
    local droplist = GET_CHILD_RECURSIVELY(frame, "preset_list")
    local page = tonumber(droplist:GetSelItemKey())
    SetCardPreset(page, cardList, expList)
    _DISABLE_CARD_PRESET_APPLY_SAVE_BTN()

end

-- インベントリにボタン作成
function monstercard_change_inventory_frame_init()

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
        mccbtn:SetTextTooltip("{@st59}Automatic card loading/unloading, automatic insertion/removal{nl}" ..
                                  "{@st59}カード自動搬出入、自動着脱{/}")
        mccbtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_MONSTERCARDPRESET_FRAME_OPEN")
    end
end

function monstercard_change_MONSTERCARDPRESET_FRAME_OPEN()
    local frame = ui.GetFrame('monstercardpreset')
    -- local mcframe = ui.GetFrame("monstercardslotset")

    if frame:IsVisible() == 1 then
        MONSTERCARDSLOT_CLOSE()
        return
    end

    local droplist = GET_CHILD_RECURSIVELY(frame, "preset_list")
    local page = tonumber(4)
    local name_str = TRIM_STRING_WITH_SPACING("MCC Blank Preset")
    SetCardPreSetTitle(page, name_str)

    _DISABLE_CARD_PRESET_CHANGE_NAME_BTN()

    frame:RemoveChild("saveBtn")
    local saveBtn = frame:CreateOrGetControl("button", "saveBtn", 340, 57, 70, 38)
    AUTO_CAST(saveBtn)
    saveBtn:SetText("{@st66b}SAVE")
    saveBtn:SetSkinName("test_pvp_btn")
    saveBtn:SetTextTooltip("{@st59}Calls up the information of the currently equipped card to the current preset{nl}" ..
                               "{@st59}現在装備中のカード情報を、現在のプリセットに呼び出します{/}")
    saveBtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_msgbox")

    local awframe = ui.GetFrame("accountwarehouse")

    local allnil = true
    for index = 0, 11 do
        local cardID, cardLv, cardExp = GETMYCARD_INFO(index);
        if cardID ~= 0 then
            allnil = false
            break
        end

    end
    -- if awframe:IsVisible() == 1 then
    local unequipBtn = frame:CreateOrGetControl("button", "unequipBtn", 480, 57, 70, 38)
    AUTO_CAST(unequipBtn)
    unequipBtn:SetText("{@st66b}REMOVE")
    unequipBtn:SetSkinName("test_pvp_btn")

    if awframe:IsVisible() == 1 and allnil == false then
        unequipBtn:SetTextTooltip("{@st59}Remove the cards currently equipped and bring them into the warehouse.{nl}" ..
                                      "{@st59}現在装備中のカードを取り外し、倉庫へ搬入します。{/}")
        unequipBtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_get_info_accountwarehouse")
        -- unequipBtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_CARD_PRESET_SELECT_PRESET")

    elseif awframe:IsVisible() == 1 and allnil == true then
        unequipBtn:SetTextTooltip("{@st59}Remove the cards currently equipped and bring them into the warehouse.{nl}" ..
                                      "{@st59}現在装備中のカードを取り外し、倉庫へ搬入します。{/}")
        unequipBtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_get_info_accountwarehouse")
        unequipBtn:SetEnable(0)
    else
        unequipBtn:SetTextTooltip("{@st59}Remove the card currently equipped.{nl}" ..
                                      "{@st59}現在装備中のカードを取り外します。{/}")
        unequipBtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_get_info")
        -- unequipBtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_CARD_PRESET_SELECT_PRESET")
    end
    -- end

    frame:RemoveChild("applyBtn")
    local applyBtn = frame:CreateOrGetControl("button", "applyBtn", 410, 57, 70, 38)
    AUTO_CAST(applyBtn)
    applyBtn:SetText("{@st66b}EQUIP")
    applyBtn:SetSkinName("test_pvp_btn")

    if awframe:IsVisible() == 1 and allnil == true then
        applyBtn:SetTextTooltip("{@st59}Change the installed card with the current preset{nl}" ..
                                    "{@st59}{#FFFF00}※Does not apply to cards not held in inventory or team warehouse{nl}" ..
                                    "{@st59}現在のプリセットで、装着カードを変更します{nl}" ..
                                    "{@st59}{#FFFF00}※インベントリかチーム倉庫に所持していないカードは適用されません")
        -- applyBtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_CARD_PRESET_APPLY_PRESET")
        applyBtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_get_presetinfo")
        -- frame:RunUpdateScript("monstercard_change_CARD_PRESET_APPLY_PRESET", 0.1)
    elseif awframe:IsVisible() == 1 and allnil == false then
        applyBtn:SetTextTooltip("{@st59}Change the installed card with the current preset{nl}" ..
                                    "{@st59}{#FFFF00}※Does not apply to cards not held in inventory or team warehouse{nl}" ..
                                    "{@st59}現在のプリセットで、装着カードを変更します{nl}" ..
                                    "{@st59}{#FFFF00}※インベントリかチーム倉庫に所持していないカードは適用されません")
        -- applyBtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_CARD_PRESET_APPLY_PRESET")
        applyBtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_get_presetinfo")
        applyBtn:SetEnable(0)

    else
        applyBtn:SetTextTooltip("{@st59}Change the installed card with the current preset{nl}" ..
                                    "{@st59}{#FFFF00}※Does not apply to cards you do not have in your inventory{nl}" ..
                                    "{@st59}現在のプリセットで、装着カードを変更します{nl}" ..
                                    "{@st59}{#FFFF00}※インベントリに所持していないカードは適用されません")

        applyBtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_get_presetinfo")
        -- frame:RunUpdateScript("monstercard_change_CARD_PRESET_APPLY_PRESET", 0.1)

    end

    local etcObj = GetMyEtcObject()

    droplist:SelectItemByKey(0)
    MONSTERCARDPRESET_FRAME_INIT()
    RequestCardPreset(0)
    local mcsframe = ui.GetFrame('monstercardslot')
    if mcsframe:IsVisible() == 0 then
        ReserveScript(string.format("monstercard_change_MONSTERCARDSLOT_FRAME_OPEN()"), 0.1)
    end
    return 1
end

-- YAAI使ってるかどうか
local function InstalledYAAI()
    if _G['ADDONS']['ebisuke']['YAACCOUNTINVENTORY'] then
        return true
    else
        return false
    end

end

function monstercard_change_MONSTERCARDSLOT_FRAME_OPEN()
    local frame = ui.GetFrame('monstercardslot')
    local applyBtn = GET_CHILD_RECURSIVELY(frame, "applyBtn")
    frame:RemoveChild("applyBtn")
    local etcObj = GetMyEtcObject()
    MONSTERCARDSLOT_FRAME_INIT()

    local invframe = ui.GetFrame("inventory")
    local cardTab = GET_CHILD_RECURSIVELY(invframe, "inventype_Tab")
    cardTab:SelectTab(4)

    local presetframe = ui.GetFrame("monstercardpreset")

    if InstalledYAAI() == true then

        local yaiframe = ui.GetFrame("yaireplacement")

        if yaiframe:IsVisible() == 1 then

            local yaicardTab = GET_CHILD_RECURSIVELY(yaiframe, "inventype_Tab")
            yaicardTab:SelectTab(4)

        end

    end
    frame:RunUpdateScript("monstercard_change_MONSTERCARDPRESET_FRAME_OPEN", 0.2)
end

-- ここから恐らく不要関数
--[[function monstercard_change_GETMYCARD_INFO(slotIndex)
    local frame = ui.GetFrame("monstercardpreset")
    local info = equipcard.GetCardInfo(slotIndex + 1);

    if info ~= nil then
        return info:GetCardID(), info.cardLv, info.exp;
    else
        return 0, 0, 0;
    end
end

function monstercard_change_CARD_PRESET_GET_CARD_EXP_LIST(frame)
    local frame = frame:GetTopParentFrame()
    local cardList = {}
    local expList = {}
    for i = 0, 11 do
        local cardClsID, cardLv, cardExp = _GETMYCARD_INFO(i)

        if cardClsID ~= 0 then
            table.insert(cardList, cardClsID);
            table.insert(expList, cardExp);
        else
            table.insert(cardList, 0);
            table.insert(expList, 0);
        end
    end

    return cardList, expList
end

function monstercard_change_preset_frame_init()
    local frame = ui.GetFrame("monstercardslot")
    local applyBtn = GET_CHILD_RECURSIVELY(frame, "applyBtn")
    applyBtn:ShowWindow(0)
end]]
