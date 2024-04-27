-- v1.0.2 on_init読み込み時にリペアーアイテムの数量確認
-- v1.0.3 SetupHookの競合修正
-- v1.0.4 23.09.05patch対応。修理キット買うコード変えてやがった許せねえ。
-- v1.0.5 数量設定を可能に
-- v1.0.6 イベント修理キットと緊急修理キットを先に使うように設定('EVENT_2005_repairPotion')と('Premium_repairPotion')それ以外持ってない
-- v1.0.7 510修理キットに対応。
-- v1.0.8 フレームの場所変更 
-- v1.0.9 フレーム動かせて記憶する様に。表示最適化
local addonName = "AUTO_REPAIR"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.9"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/new_settings.json', addonNameLower)

local acutil = require("acutil")

--[[g.settings = {
    buyquantity = 50,
    msgquantity = 20
}]]

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
-- 11200365 [LV.510]緊急修理キット QuestReward_repairPotion_510
-- 11200313 [Lv.500]緊急修理キット QuestReward_repairPotion_500
function AUTO_REPAIR_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    g.SetupHook(AUTO_REPAIR_DURNOTIFY_UPDATE, "DURNOTIFY_UPDATE")
    acutil.addSysIcon("auto_repair", "sysmenu_mac", "Auto Repair", "AUTO_REPAIR_SETTING_FRAME_INIT")

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then

        AUTO_REPAIR_LOADSETTINGS()

        local autorepair_item = session.GetInvItemByName('QuestReward_repairPotion_510')

        if autorepair_item ~= nil then
            local repairCount = autorepair_item.count
            if repairCount < g.settings.msgquantity then
                addon:RegisterMsg("GAME_START_3SEC", "AUTO_REPAIR_FRAME_INIT")
            end
        else
            addon:RegisterMsg("GAME_START_3SEC", "AUTO_REPAIR_FRAME_INIT")
        end

    end

end

function AUTO_REPAIR_END_DRAG(frame, ctrl, argStr, argNum)

    local Name = frame:GetName()
    if Name == "auto_repair_notice" then
        g.settings.x = frame:GetX();
        g.settings.y = frame:GetY();
    elseif Name == "auto_repair_setting" then
        g.settings.setx = frame:GetX();
        g.settings.sety = frame:GetY();
    end
    AUTO_REPAIR_SAVE_SETTINGS()
end

function AUTO_REPAIR_SETTING_FRAME_INIT()

    local frame = ui.CreateNewFrame("chat_memberlist", "auto_repair_setting");
    if g.settings.setx == nil or g.settings.sety == nil then
        frame:SetPos(900, 730)
    else
        frame:SetPos(g.settings.setx, g.settings.sety)
    end
    frame:EnableHitTest(1)

    frame:SetSkinName("chat_window")
    frame:SetEventScript(ui.LBUTTONUP, "AUTO_REPAIR_END_DRAG")
    local text1 = frame:CreateOrGetControl('richtext', 'text1', 10, 10)
    AUTO_CAST(text1)
    local itemCls = GetClassByType('Item', 11200365)
    local Name = itemCls.Name
    text1:SetText("{ol}{s18}" .. Name .. AUTO_REPAIR_LANG(" Purchase Settings"))

    local text2 = frame:CreateOrGetControl('richtext', 'text2', 10, 50)
    AUTO_CAST(text2)
    local txt2 = AUTO_REPAIR_LANG("Number of automatic purchases")
    text2:SetText("{s18}{ol}" .. txt2)

    local text3 = frame:CreateOrGetControl('richtext', 'text3', 10, 80)
    AUTO_CAST(text3)
    local txt3 = AUTO_REPAIR_LANG("Message with less than input quantity")
    text3:SetText("{s18}{ol}" .. txt3)

    local width = math.max(text2:GetWidth(), text3:GetWidth())

    local edit1 = frame:CreateOrGetControl('edit', 'edit1', width + 20, 45, 60, 30)
    AUTO_CAST(edit1)
    edit1:SetText("{ol}" .. g.settings.buyquantity)
    edit1:SetFontName("white_16_ol")
    edit1:SetTextAlign("center", "center")
    edit1:SetEventScript(ui.ENTERKEY, "AUTO_REPAIR_SETTING")
    edit1:SetTextTooltip("エンターキー押下で登録{nl}Register by pressing enter key")

    local edit2 = frame:CreateOrGetControl('edit', 'edit2', width + 20, 75, 60, 30)
    AUTO_CAST(edit2)
    edit2:SetText("{ol}" .. g.settings.msgquantity)
    edit2:SetFontName("white_16_ol")
    edit2:SetTextAlign("center", "center")
    edit2:SetEventScript(ui.ENTERKEY, "AUTO_REPAIR_SETTING")
    edit2:SetTextTooltip("エンターキー押下で登録{nl}Register by pressing enter key")

    local closebtn = frame:CreateOrGetControl("button", "closebtn", text1:GetWidth() + 20, 0, 30, 30)
    AUTO_CAST(closebtn)
    closebtn:SetSkinName("None")
    closebtn:SetImage("testclose_button")
    closebtn:SetEventScript(ui.LBUTTONUP, "AUTO_REPAIR_SETTING_FRAME_CLOSE")

    frame:Resize(text1:GetWidth() + 60, 115)
    frame:ShowWindow(1)
    return

end

function AUTO_REPAIR_SETTING(frame, ctrl)
    local value = tonumber(ctrl:GetText())
    local ctrlname = tostring(ctrl:GetName())

    if tonumber(value) ~= tonumber(g.settings.buyquantity) and ctrlname == tostring("edit1") then
        ui.SysMsg("Buy quantity set to " .. value)
        g.settings.buyquantity = value
        AUTO_REPAIR_SAVE_SETTINGS()

    elseif tonumber(value) ~= tonumber(g.settings.msgquantity) and ctrlname == tostring("edit2") then
        ui.SysMsg("Msg quantity set to " .. value)
        g.settings.msgquantity = value
        AUTO_REPAIR_SAVE_SETTINGS()

    else
        return
    end

end

function AUTO_REPAIR_SETTING_FRAME_CLOSE(frame)
    ui.CloseFrame("auto_repair_setting")

end

function AUTO_REPAIR_LANG(str)
    local language = option.GetCurrentCountry()
    if language == "Japanese" then
        if str == " Purchase Settings" then
            str = " 購入設定"
        end

        if str == "Number of automatic purchases" then
            str = "自動購入数入力"
        end

        if str == "Message with less than input quantity" then
            str = "入力数以下で補充メッセージ"
        end

        if str == "Do you want to replenish the few remaining?" then
            str = "残り少ないですが補充しますか？"
        end

    end
    return str

end

-- AUTO_REPAIR_FRAME_INIT()
function AUTO_REPAIR_FRAME_INIT()
    -- local frame = ui.GetFrame("auto_repair")
    local frame = ui.CreateNewFrame("chat_memberlist", "auto_repair_notice");

    if g.settings.x == nil or g.settings.y == nil then
        frame:SetPos(680, 660)
    else
        frame:SetPos(g.settings.x, g.settings.y)
    end

    frame:SetSkinName("chat_window")

    frame:SetEventScript(ui.LBUTTONUP, "AUTO_REPAIR_END_DRAG")

    local itemCls = GetClassByType('Item', 11200365)
    local Name = itemCls.Name

    local text1 = frame:CreateOrGetControl('richtext', 'text1', 10, 10)
    AUTO_CAST(text1)
    local txt1 = Name .. "{nl}" .. AUTO_REPAIR_LANG("Do you want to replenish the few remaining?")
    text1:SetText("{s18}{ol}" .. txt1)
    text1:SetTextAlign("center", "center")

    --[[ local tx1 = AUTO_REPAIR_LANG("Do you want to replenish the few remaining?")
    local width = tx1:GetWidth()
    print(width)]]

    local yesbtn = frame:CreateOrGetControl('button', 'yes', 50, 65, 80, 40)
    yesbtn:SetSkinName("test_red_button")
    yesbtn:SetText("{ol}YES")
    yesbtn:SetEventScript(ui.LBUTTONUP, "AUTO_REPAIR_BUY")

    local nobtn = frame:CreateOrGetControl('button', 'no', 140, 65, 80, 40)
    nobtn:SetSkinName("test_gray_button")
    nobtn:SetText("{ol}NO")
    nobtn:SetEventScript(ui.LBUTTONUP, "AUTO_REPAIR_CLOSE")

    local language = option.GetCurrentCountry()
    if language == "Japanese" then
        frame:Resize(290, 110)
    else
        frame:Resize(420, 110)
        yesbtn:SetMargin(115, 65, 80, 40)
        nobtn:SetMargin(205, 65, 80, 40)
    end
    frame:EnableHittestFrame(1);
    frame:EnableMove(1);
    frame:ShowWindow(1)
    ReserveScript("AUTO_REPAIR_CLOSE()", 7.0)

end

function AUTO_REPAIR_CLOSE()
    local frame = ui.GetFrame("auto_repair_notice")
    frame:ShowWindow(0)
end

function AUTO_REPAIR_BUY()

    local autorepair_item = session.GetInvItemByName('QuestReward_repairPotion_510')
    if autorepair_item ~= nil then
        local repairCount = autorepair_item.count

        local cnt = g.settings.buyquantity - repairCount

        local shopType = "RadaCertificate"
        local recipeCls = GetClass("ItemTradeShop", 'RadaCertificate_13')

        session.ResetItemList()
        session.AddItemID(tostring(0), 1)
        local itemlist = session.GetItemIDList()
        local cntText = string.format("%s %s", tostring(recipeCls.ClassID), tostring(cnt))
        local str_list = NewStringList();
        str_list:Add(shopType)

        item.DialogTransaction("Certificate_SHOP", itemlist, cntText, str_list)
    else
        local cnt = g.settings.buyquantity

        local shopType = "RadaCertificate"
        local recipeCls = GetClass("ItemTradeShop", 'RadaCertificate_13')

        session.ResetItemList()
        session.AddItemID(tostring(0), 1)
        local itemlist = session.GetItemIDList()
        local cntText = string.format("%s %s", tostring(recipeCls.ClassID), tostring(cnt))
        local str_list = NewStringList();
        str_list:Add(shopType)

        item.DialogTransaction("Certificate_SHOP", itemlist, cntText, str_list)

    end

    AUTO_REPAIR_CLOSE()
end

function AUTO_REPAIR_DURNOTIFY_UPDATE(frame, notOpenFrame)
    if frame:IsVisible() == 0 then
        frame:ShowWindow(1);
    end

    local slotSet = GET_CHILD_RECURSIVELY(frame, 'slotlist', 'ui::CSlotSet')
    slotSet:ClearIconAll();

    for i = 0, slotSet:GetSlotCount() - 1 do
        local slot = slotSet:GetSlotByIndex(i);
        slot:ShowWindow(0);
    end

    local reverseIndex = slotSet:GetSlotCount() - 1;
    local equiplist = session.GetEquipItemList();
    local someflag = 1
    for i = 0, equiplist:Count() - 1 do
        local equipItem = equiplist:GetEquipItemByIndex(i);
        local spot = item.GetEquipSpotName(equipItem.equipSpot)
        local slotcnt = imcSlot:GetFilledSlotCount(slotSet);
        local tempobj = equipItem:GetObject()
        if tempobj ~= nil then
            local obj = GetIES(tempobj);
            if IS_DUR_UNDER_10PER(obj) == true then
                local colorTone = "FF999900";
                if someflag < 2 then
                    someflag = 2
                    local type = equipItem.type
                    AUTO_REPAIR_ITEM_USE(obj, spot)

                end
                if IS_DUR_ZERO(obj) == true then
                    colorTone = "FF990000";
                    if someflag < 3 then
                        someflag = 3
                    end
                end

                local slot = slotSet:GetSlotByIndex(reverseIndex - slotcnt)
                local icon = CreateIcon(slot);
                local iconImg = obj.Icon;
                local briquettingID = TryGetProp(obj, 'BriquettingIndex', 0);
                if briquettingID > 0 then
                    local briquettingItemCls = GetClassByType('Item', briquettingID);
                    iconImg = briquettingItemCls.Icon;
                end
                icon:Set(iconImg, 'Item', equipItem.type, reverseIndex - slotcnt, equipItem:GetIESID());
                icon:SetColorTone(colorTone);
                slot:ShowWindow(1);
            end
        end
    end

    local nowvalue = frame:GetValue();
    if someflag == 1 then
        frame:SetValue(1)
    elseif someflag == 2 and nowvalue < someflag then
        frame:SetValue(2)

        ui.SysMsg(ScpArgMsg('DurUnder30'));

    elseif someflag == 3 and nowvalue < someflag then
        frame:SetValue(3)
        ui.SysMsg(ScpArgMsg('DurUnder0'));

    end
end

function AUTO_REPAIR_ITEM_USE(obj, spot)

    session.ResetItemList()
    local autorepair_item_normal = session.GetInvItemByName('Premium_repairPotion')
    local autorepair_item_event = session.GetInvItemByName('EVENT_2005_repairPotion')
    local autorepair_item = session.GetInvItemByName('QuestReward_repairPotion_510')
    if autorepair_item_event ~= nil then

        local repeatCount = math.min(autorepair_item_event.count, 4)
        if autorepair_item_event.isLockState ~= true then
            for i = 0, repeatCount - 1 do
                if obj.Dur / obj.MaxDur < 0.9 then
                    item.UseByGUID(autorepair_item_event:GetIESID())

                else
                    break
                end
            end
        end

    elseif autorepair_item_normal ~= nil then

        local repeatCount = math.min(autorepair_item_normal.count, 4)
        if autorepair_item_normal.isLockState ~= true then
            for i = 0, repeatCount - 1 do
                if obj.Dur / obj.MaxDur < 0.9 then
                    item.UseByGUID(autorepair_item_normal:GetIESID())

                else
                    break
                end
            end
        end

    elseif autorepair_item ~= nil then

        local repeatCount = math.min(autorepair_item.count, 4)
        if autorepair_item.isLockState ~= true then
            for i = 0, repeatCount - 1 do
                if obj.Dur / obj.MaxDur < 0.9 then
                    item.UseByGUID(autorepair_item:GetIESID())

                else
                    break
                end
            end
        end
    else
        -- ui.SysMsg("Not have a repair kit.")
        return
    end
    --[[local autorepair_item_500 = session.GetInvItemByName('QuestReward_repairPotion_500')
    local autorepair_item_490 = session.GetInvItemByName('QuestReward_repairPotion_490')
    local autorepair_item_480 = session.GetInvItemByName('QuestReward_repairPotion_480')
    local autorepair_item_470 = session.GetInvItemByName('QuestReward_repairPotion_470')
    -- BELT=470 SHOULDER=480
    if autorepair_item_470 ~= nil and spot == "BELT" then

        local repeatCount = math.min(autorepair_item_470.count, 4)
        if autorepair_item_470.isLockState ~= true then
            for i = 0, repeatCount - 1 do
                if obj.Dur / obj.MaxDur < 0.9 then
                    item.UseByGUID(autorepair_item_470:GetIESID())

                else
                    break
                end
            end
        end
    elseif autorepair_item_480 ~= nil and spot == "SHOULDER" then

        local repeatCount = math.min(autorepair_item_480.count, 4)
        if autorepair_item_480.isLockState ~= true then
            for i = 0, repeatCount - 1 do
                if obj.Dur / obj.MaxDur < 0.9 then
                    item.UseByGUID(autorepair_item_480:GetIESID())

                else
                    break
                end
            end
        end
    elseif autorepair_item_490 ~= nil then
        if spot == "SHOULDER" or spot == "BELT" then

            local repeatCount = math.min(autorepair_item_490.count, 4)
            if autorepair_item_490.isLockState ~= true then
                for i = 0, repeatCount - 1 do
                    if obj.Dur / obj.MaxDur < 0.9 then
                        item.UseByGUID(autorepair_item_490:GetIESID())

                    else
                        break
                    end
                end
            end
        end
        elseif autorepair_item_500 ~= nil and spot ~= "RING1" and spot ~= "RING2" and spot ~= "NECK" then

        local repeatCount = math.min(autorepair_item_500.count, 4)
        if autorepair_item_500.isLockState ~= true then
            for i = 0, repeatCount - 1 do
                if obj.Dur / obj.MaxDur < 0.9 then
                    item.UseByGUID(autorepair_item_500:GetIESID())

                else
                    break
                end
            end
        end]]

end

function AUTO_REPAIR_SAVE_SETTINGS()

    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function AUTO_REPAIR_LOADSETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not settings then

        g.settings = {
            buyquantity = 50,
            msgquantity = 20,
            setx = 900,
            sety = 730,
            x = 680,
            y = 660
        }

        AUTO_REPAIR_SAVE_SETTINGS()

    end

    g.settings = settings
end

