-- v1.0.1 カードをインベントリを探してなければ装備する数を倉庫から搬出。装備してたカードだけを倉庫へ搬入。
-- v1.0.2 バグ修正
-- v1.0.3 カードを3枚セットで運用に変更
-- v1.0.4 装備ボタン、外すボタンの運用見直し。
-- v1.0.5 作り直し。3枚運用止め、カラーカード毎に着け外し選択出来る様に。5番プリセットを外す用に強制的に使うように変更。
local addonName = "monstercard_change"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.5"

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

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

function MONSTERCARD_CHANGE_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    monstercard_change_load_settings()
    addon:RegisterMsg('GAME_START_3SEC', 'monstercard_change_inventory_frame_init');

end

function monstercard_change_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function monstercard_change_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    g.settings = settings
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
-- CChelper用
function monstercard_change_get_info_accountwarehouse()
    monstercard_change_remove()
end

function monstercard_change_MONSTERCARDPRESET_FRAME_OPEN()
    local frame = ui.GetFrame('monstercardpreset')

    if frame:IsVisible() == 1 then
        MONSTERCARDSLOT_CLOSE()
        return
    end

    local droplist = GET_CHILD_RECURSIVELY(frame, "preset_list")
    AUTO_CAST(droplist)

    droplist:SelectItemByKey(4)
    local page = tonumber(droplist:GetSelItemKey(4))
    local name_str = TRIM_STRING_WITH_SPACING("MCC remove")
    local preset_name = droplist:GetSelItemCaption()
    -- print(preset_name)
    if tostring(preset_name) ~= tostring(name_str) then
        SetCardPreSetTitle(page, name_str)
        _DISABLE_CARD_PRESET_CHANGE_NAME_BTN()
    end

    frame:RemoveChild("saveBtn")
    local saveBtn = frame:CreateOrGetControl("button", "saveBtn", 340, 57, 70, 38)
    AUTO_CAST(saveBtn)
    saveBtn:SetText("{@st66b}SAVE")
    saveBtn:SetSkinName("test_pvp_btn")
    saveBtn:SetTextTooltip("{@st59}Calls up the information of the currently equipped card to the current preset{nl}" ..
                               "{@st59}現在装備中のカード情報を、現在のプリセットに呼び出します{/}")
    saveBtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_msgbox")

    local awframe = ui.GetFrame("accountwarehouse")

    local unequipBtn = frame:CreateOrGetControl("button", "unequipBtn", 480, 57, 70, 38)
    AUTO_CAST(unequipBtn)
    unequipBtn:SetText("{@st66b}REMOVE")
    unequipBtn:SetSkinName("test_pvp_btn")
    unequipBtn:SetEnable(1)

    if awframe:IsVisible() == 1 then
        unequipBtn:SetTextTooltip("{@st59}Remove the cards currently equipped and bring them into the warehouse.{nl}" ..
                                      "{@st59}現在装備中のカードを取り外し、倉庫へ搬入します。{/}")
        unequipBtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_remove")

    else
        unequipBtn:SetTextTooltip("{@st59}Remove the card currently equipped.{nl}" ..
                                      "{@st59}現在装備中のカードを取り外します。{/}")
        unequipBtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_remove")

    end

    frame:RemoveChild("applyBtn")
    local equipBtn = frame:CreateOrGetControl("button", "equipBtn", 410, 57, 70, 38)
    AUTO_CAST(equipBtn)
    equipBtn:SetText("{@st66b}EQUIP")
    equipBtn:SetSkinName("test_pvp_btn")
    equipBtn:SetEnable(1)

    if awframe:IsVisible() == 1 then
        equipBtn:SetTextTooltip("{@st59}Change the installed card with the current preset{nl}" ..
                                    "{@st59}{#FFFF00}※Does not apply to cards not held in inventory or team warehouse{nl}" ..
                                    "{@st59}現在のプリセットで、装着カードを変更します{nl}" ..
                                    "{@st59}{#FFFF00}※インベントリかチーム倉庫に所持していないカードは適用されません")

        equipBtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_get_presetinfo")
        equipBtn:SetEnable(1)

    else
        equipBtn:SetTextTooltip("{@st59}Change the installed card with the current preset{nl}" ..
                                    "{@st59}{#FFFF00}※Does not apply to cards you do not have in your inventory{nl}" ..
                                    "{@st59}現在のプリセットで、装着カードを変更します{nl}" ..
                                    "{@st59}{#FFFF00}※インベントリに所持していないカードは適用されません")

        equipBtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_get_presetinfo")

    end

    local etcObj = GetMyEtcObject()

    droplist:SelectItemByKey(0)
    MONSTERCARDPRESET_FRAME_INIT()
    RequestCardPreset(0)
    frame:ShowWindow(1)
    local mcsframe = ui.GetFrame('monstercardslot')
    local LoginName = session.GetMySession():GetPCApc():GetName()
    if g.settings == nil then
        g.settings = {}
    end
    if g.settings[LoginName] == nil then
        g.settings[LoginName] = {}
    end
    local red_check = mcsframe:CreateOrGetControl('checkbox', 'red_check', 50, 70, 25, 25)
    AUTO_CAST(red_check)
    red_check:SetEventScript(ui.LBUTTONUP, "monstercard_change_check_save")
    if g.settings[LoginName].red_check == 1 then
        red_check:SetCheck(1);
    elseif g.settings[LoginName].red_check == nil then
        g.settings[LoginName].red_check = 0
        red_check:SetCheck(0);
    else
        red_check:SetCheck(0);
    end
    red_check:SetTextTooltip(
        "Monster Card Change{nl}チェックを入れると該当の色のカードを外しません。{nl}" ..
            "If checked, the card of the corresponding color will not be removed.")

    local blue_check = mcsframe:CreateOrGetControl('checkbox', 'blue_check', 365, 70, 25, 25)
    AUTO_CAST(blue_check)
    if g.settings[LoginName].blue_check == 1 then
        blue_check:SetCheck(1);
    elseif g.settings[LoginName].blue_check == nil then
        g.settings[LoginName].blue_check = 0
        blue_check:SetCheck(0);
    else
        blue_check:SetCheck(0);
    end
    blue_check:SetEventScript(ui.LBUTTONUP, "monstercard_change_check_save")
    blue_check:SetTextTooltip(
        "Monster Card Change{nl}チェックを入れると該当の色のカードを外しません。{nl}" ..
            "If checked, the card of the corresponding color will not be removed.")

    local purple_check = mcsframe:CreateOrGetControl('checkbox', 'purple_check', 50, 210, 25, 25)
    AUTO_CAST(purple_check)
    if g.settings[LoginName].purple_check == 1 then
        purple_check:SetCheck(1);
    elseif g.settings[LoginName].purple_check == nil then
        g.settings[LoginName].purple_check = 0
        purple_check:SetCheck(0);
    else
        purple_check:SetCheck(0);
    end
    purple_check:SetEventScript(ui.LBUTTONUP, "monstercard_change_check_save")
    purple_check:SetTextTooltip(
        "Monster Card Change{nl}チェックを入れると該当の色のカードを外しません。{nl}" ..
            "If checked, the card of the corresponding color will not be removed.")

    local green_check = mcsframe:CreateOrGetControl('checkbox', 'green_check', 365, 210, 25, 25)
    AUTO_CAST(green_check)
    green_check:SetEventScript(ui.LBUTTONUP, "monstercard_change_check_save")
    if g.settings[LoginName].green_check == 1 then
        green_check:SetCheck(1);
    elseif g.settings[LoginName].green_check == nil then
        green_check:SetCheck(0);
        g.settings[LoginName].green_check = 0
    else
        green_check:SetCheck(0);
    end
    green_check:SetTextTooltip(
        "Monster Card Change{nl}チェックを入れると該当の色のカードを外しません。{nl}" ..
            "If checked, the card of the corresponding color will not be removed.")
    monstercard_change_save_settings()
    monstercard_change_load_settings()
    if mcsframe:IsVisible() == 0 then
        ReserveScript(string.format("monstercard_change_MONSTERCARDSLOT_FRAME_OPEN()"), 0.1)
    end
    return
end

function monstercard_change_check_save(frame, ctrl, argStr, argNum)
    local ischeck = ctrl:IsChecked()
    local ctrl_name = ctrl:GetName()

    local LoginName = session.GetMySession():GetPCApc():GetName()

    g.settings[LoginName][ctrl_name] = ischeck
    monstercard_change_save_settings()
    monstercard_change_load_settings()
end

-- 外す処理開始
function monstercard_change_remove()
    local frame = ui.GetFrame('monstercardpreset')

    local monstercardpslot_cardList, monstercardpslot_expList = monstercard_change_monstercardslot_info()

    local droplist = GET_CHILD_RECURSIVELY(frame, "preset_list")
    AUTO_CAST(droplist)
    droplist:SelectItemByKey(4)
    local page = tonumber(droplist:GetSelItemKey(4))

    SetCardPreset(page, monstercardpslot_cardList, monstercardpslot_expList)

    -- CARD_PRESET_SHOW_PRESET(page)
    droplist:SelectItemByKey(0)
    ReserveScript(string.format("pc.ReqExecuteTx_NumArgs('%s', %d)", "SCR_TX_APPLY_CARD_PRESET", page), 0.1)
    local awhframe = ui.GetFrame("accountwarehouse")
    if awhframe:IsVisible() == 1 then
        ReserveScript("monstercard_change_put_inv_to_warehouse()", 0.5)
    end
end

function monstercard_change_monstercardslot_info()

    local LoginName = session.GetMySession():GetPCApc():GetName()
    local frame = ui.GetFrame('monstercardpslot')
    local monstercardpslot_cardList = {}
    local monstercardpslot_expList = {}

    g.cardslot_cardlist = {}
    g.cardslot_lvlist = {}
    g.atk = 3
    g.def = 3
    g.util = 3
    g.stat = 3
    -- g.cardcount = 0

    for i = 0, 11 do
        local cardClsID, cardLv, cardExp = GETMYCARD_INFO(i)

        if i <= 2 and g.settings[LoginName].red_check ~= 0 and cardClsID ~= 0 then

            table.insert(monstercardpslot_cardList, cardClsID);
            table.insert(monstercardpslot_expList, cardExp);
            g.atk = g.atk - 1
        elseif i >= 3 and i <= 5 and g.settings[LoginName].blue_check ~= 0 and cardClsID ~= 0 then
            table.insert(monstercardpslot_cardList, cardClsID);
            table.insert(monstercardpslot_expList, cardExp);
            g.def = g.def - 1
        elseif i >= 6 and i <= 8 and g.settings[LoginName].purple_check ~= 0 and cardClsID ~= 0 then
            table.insert(monstercardpslot_cardList, cardClsID);
            table.insert(monstercardpslot_expList, cardExp);
            g.util = g.util - 1
        elseif i >= 9 and i <= 11 and g.settings[LoginName].green_check ~= 0 and cardClsID ~= 0 then
            table.insert(monstercardpslot_cardList, cardClsID);
            table.insert(monstercardpslot_expList, cardExp);
            g.stat = g.stat - 1
        else
            table.insert(monstercardpslot_cardList, 0);
            table.insert(monstercardpslot_expList, 0);
            table.insert(g.cardslot_cardlist, cardClsID)
            table.insert(g.cardslot_lvlist, cardLv)

            -- g.cardcount = g.cardcount + 1
        end

    end
    return monstercardpslot_cardList, monstercardpslot_expList

end
-- 外したカードを入庫
function monstercard_change_put_inv_to_warehouse()

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
    -- print("atk:" .. g.atk .. " def:" .. g.def .. " util:" .. g.util .. " stat:" .. g.stat)
    if frame:IsVisible() == 1 then
        local invItemList = session.GetInvItemList()
        local guidList = invItemList:GetGuidList()
        local cnt = guidList:Count()

        for i = 0, cnt - 1 do
            local guid = guidList:Get(i)
            local invItem = invItemList:GetItemByGuid(guid)
            local itemobj = GetIES(invItem:GetObject())
            local itemlv = TryGetProp(itemobj, "Level", 0)
            local iesid = invItem:GetIESID()
            -- print(tostring(itemobj.CardGroupName))
            if tostring(itemobj.CardGroupName) == "ATK" and g.atk ~= 0 then
                for _, cardID in ipairs(g.cardslot_cardlist) do

                    if tostring(itemobj.ClassID) == tostring(cardID) then

                        for _, cardLV in ipairs(g.cardslot_lvlist) do

                            if tostring(itemlv) == tostring(cardLV) then

                                item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, iesid, 1, nil, nil)
                                session.ResetItemList()
                                g.atk = g.atk - 1
                                ReserveScript("monstercard_change_put_inv_to_warehouse()", 0.5)
                                return -- 整合が見つかったら関数を終了
                            end
                        end
                    end
                end
            elseif tostring(itemobj.CardGroupName) == "DEF" and g.def ~= 0 then
                for _, cardID in ipairs(g.cardslot_cardlist) do

                    if tostring(itemobj.ClassID) == tostring(cardID) then

                        for _, cardLV in ipairs(g.cardslot_lvlist) do

                            if tostring(itemlv) == tostring(cardLV) then

                                item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, iesid, 1, nil, nil)
                                session.ResetItemList()
                                g.def = g.def - 1
                                ReserveScript("monstercard_change_put_inv_to_warehouse()", 0.5)
                                return -- 整合が見つかったら関数を終了
                            end
                        end
                    end
                end
            elseif tostring(itemobj.CardGroupName) == "UTIL" and g.util ~= 0 then
                for _, cardID in ipairs(g.cardslot_cardlist) do

                    if tostring(itemobj.ClassID) == tostring(cardID) then

                        for _, cardLV in ipairs(g.cardslot_lvlist) do

                            if tostring(itemlv) == tostring(cardLV) then

                                item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, iesid, 1, nil, nil)
                                session.ResetItemList()
                                g.util = g.util - 1
                                ReserveScript("monstercard_change_put_inv_to_warehouse()", 0.5)
                                return -- 整合が見つかったら関数を終了
                            end
                        end
                    end
                end
            elseif tostring(itemobj.CardGroupName) == "STAT" and g.stat ~= 0 then
                for _, cardID in ipairs(g.cardslot_cardlist) do

                    if tostring(itemobj.ClassID) == tostring(cardID) then

                        for _, cardLV in ipairs(g.cardslot_lvlist) do

                            if tostring(itemlv) == tostring(cardLV) then

                                item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, iesid, 1, nil, nil)
                                session.ResetItemList()
                                g.stat = g.stat - 1
                                ReserveScript("monstercard_change_put_inv_to_warehouse()", 0.5)
                                return -- 整合が見つかったら関数を終了
                            end
                        end
                    end
                end
            end
        end

        MONSTERCARDSLOT_CLOSE()
        monstercard_change_end_of_operation()
        return
    end
    MONSTERCARDSLOT_CLOSE()
    monstercard_change_end_of_operation()
    return
end

function monstercard_change_end_of_operation()

    ui.CloseFrame(addonNameLower)
    ui.CloseFrame("monstercardpreset")
    ui.CloseFrame("monstercardslot")
    g.atk = 0
    g.def = 0
    g.util = 0
    g.stat = 0
    g.cardslot_cardlist = {}
    g.cardslot_lvlist = {}
    g.cardpreset_cardlist = {}
    g.cardpreset_lvlist = {}
    ui.SysMsg("[MCC]end of operation")
end

-- カードを着ける処理
function monstercard_change_get_presetinfo()

    g.cardpreset_cardlist = {}
    g.cardpreset_lvlist = {}
    g.atk = 0
    g.def = 0
    g.util = 0
    g.stat = 0

    local LoginName = session.GetMySession():GetPCApc():GetName()

    for i = 0, 11 do
        local cardID, cardLv, cardExp = _GETMYCARD_INFO(i)

        if i <= 2 and g.settings[LoginName].red_check == 0 and cardID ~= 0 then

            table.insert(g.cardpreset_cardlist, cardID)
            table.insert(g.cardpreset_lvlist, cardLv)
            g.atk = g.atk + 1
        elseif i >= 3 and i <= 5 and g.settings[LoginName].blue_check == 0 and cardID ~= 0 then
            table.insert(g.cardpreset_cardlist, cardID)
            table.insert(g.cardpreset_lvlist, cardLv)
            g.def = g.def + 1
        elseif i >= 6 and i <= 8 and g.settings[LoginName].purple_check == 0 and cardID ~= 0 then
            table.insert(g.cardpreset_cardlist, cardID)
            table.insert(g.cardpreset_lvlist, cardLv)
            g.util = g.util + 1
        elseif i >= 9 and i <= 11 and g.settings[LoginName].green_check == 0 and cardID ~= 0 then
            table.insert(g.cardpreset_cardlist, cardID)
            table.insert(g.cardpreset_lvlist, cardLv)
            g.stat = g.stat + 1
        else
            table.insert(g.cardpreset_cardlist, 0)
            table.insert(g.cardpreset_lvlist, 0)

        end
    end

    monstercard_change_CARD_PRESET_APPLY_PRESET()
    return
end

function monstercard_change_CARD_PRESET_APPLY_PRESET()
    local frame = ui.GetFrame("monstercardpreset")
    local fromframe = ui.GetFrame("accountwarehouse")

    local droplist = GET_CHILD_RECURSIVELY(frame, "preset_list")
    local page = tonumber(droplist:GetSelItemKey())

    if fromframe:IsVisible() == 0 then
        -- print(page)
        if page ~= nil then
            pc.ReqExecuteTx_NumArgs("SCR_TX_APPLY_CARD_PRESET", page)
            _DISABLE_CARD_PRESET_APPLY_SAVE_BTN()
            ReserveScript("monstercard_change_end_of_operation()", 1.0)

            return
        end
    else

        monstercard_change_warehouse()
        return
    end

end

-- インベントリになければ補充。無ければ終了
function monstercard_change_warehouse()

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

    local frame = ui.GetFrame("monstercardpreset")

    local fromframe = ui.GetFrame("accountwarehouse")

    local droplist = GET_CHILD_RECURSIVELY(frame, "preset_list")
    local page = tonumber(droplist:GetSelItemKey())

    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetSortedGuidList();
    local sortedCnt = sortedGuidList:Count();

    for i = 0, sortedCnt - 1 do
        local guid = sortedGuidList:Get(i)
        local invItem = itemList:GetItemByGuid(guid)
        local iesid = invItem:GetIESID()

        local obj = GetIES(invItem:GetObject());
        local cardLevel = TryGetProp(obj, 'Level', 1)
        if tostring(obj.CardGroupName) == "ATK" and g.atk ~= 0 then

            for _, cardID in ipairs(g.cardpreset_cardlist) do
                if tostring(obj.ClassID) == tostring(cardID) then
                    -- print(tostring(obj.CardGroupName) .. ":" .. tostring(cardID))
                    for _, lv in ipairs(g.cardpreset_lvlist) do
                        if tostring(cardLevel) == tostring(lv) then
                            session.ResetItemList()
                            session.AddItemID(tonumber(iesid), 1)
                            item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                                fromframe:GetUserIValue("HANDLE"))
                            g.atk = g.atk - 1
                            ReserveScript("monstercard_change_warehouse()", 0.5)
                            return
                        end
                    end
                end
            end
        elseif tostring(obj.CardGroupName) == "DEF" and g.def ~= 0 then

            for _, cardID in ipairs(g.cardpreset_cardlist) do
                if tostring(obj.ClassID) == tostring(cardID) then
                    -- print(tostring(obj.CardGroupName) .. ":" .. tostring(cardID))
                    for _, lv in ipairs(g.cardpreset_lvlist) do
                        if tostring(cardLevel) == tostring(lv) then
                            session.ResetItemList()
                            session.AddItemID(tonumber(iesid), 1)
                            item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                                fromframe:GetUserIValue("HANDLE"))
                            g.def = g.def - 1
                            ReserveScript("monstercard_change_warehouse()", 0.5)
                            return
                        end
                    end
                end
            end
        elseif tostring(obj.CardGroupName) == "UTIL" and g.util ~= 0 then

            for _, cardID in ipairs(g.cardpreset_cardlist) do
                if tostring(obj.ClassID) == tostring(cardID) then
                    -- print(tostring(obj.CardGroupName) .. ":" .. tostring(cardID))
                    for _, lv in ipairs(g.cardpreset_lvlist) do
                        if tostring(cardLevel) == tostring(lv) then
                            session.ResetItemList()
                            session.AddItemID(tonumber(iesid), 1)
                            item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                                fromframe:GetUserIValue("HANDLE"))
                            g.util = g.util - 1
                            ReserveScript("monstercard_change_warehouse()", 0.5)
                            return
                        end
                    end
                end
            end
        elseif tostring(obj.CardGroupName) == "STAT" and g.stat ~= 0 then

            for _, cardID in ipairs(g.cardpreset_cardlist) do
                if tostring(obj.ClassID) == tostring(cardID) then
                    -- print(tostring(obj.CardGroupName) .. ":" .. tostring(cardID))
                    for _, lv in ipairs(g.cardpreset_lvlist) do
                        if tostring(cardLevel) == tostring(lv) then
                            session.ResetItemList()
                            session.AddItemID(tonumber(iesid), 1)
                            item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                                fromframe:GetUserIValue("HANDLE"))
                            g.stat = g.stat - 1
                            ReserveScript("monstercard_change_warehouse()", 0.5)
                            return
                        end
                    end
                end
            end
        end

    end

    ReserveScript("monstercard_change_end_of_operation()", 1.0)
    if page ~= nil then
        pc.ReqExecuteTx_NumArgs("SCR_TX_APPLY_CARD_PRESET", page)

        _DISABLE_CARD_PRESET_APPLY_SAVE_BTN()

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
    applyBtn:ShowWindow(0)
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
    -- frame:RunUpdateScript("monstercard_change_MONSTERCARDPRESET_FRAME_OPEN", 0.2)
end

-- 5番目のプリセットも埋まっている場合は順番に外す。めちゃ遅いよ
--[[function monstercard_change_unequip()

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
end]]

