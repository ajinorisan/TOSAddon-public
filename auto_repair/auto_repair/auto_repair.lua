-- v1.0.2 on_init読み込み時にリペアーアイテムの数量確認
-- v1.0.3 SetupHookの競合修正
-- v1.0.4 23.09.05patch対応。修理キット買うコード変えてやがった許せねえ。
-- v1.0.5 数量設定を可能に
-- v1.0.6 イベント修理キットと緊急修理キットを先に使うように設定('EVENT_2005_repairPotion')と('Premium_repairPotion')それ以外持ってない
-- v1.0.7 510修理キットに対応。500修理キットも余ってたら使う様にした。 
local addonName = "AUTO_REPAIR"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.7"

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

function AUTO_REPAIR_SETTING_FRAME_INIT()

    local frame = ui.CreateNewFrame("chat_memberlist", "auto_repair_setting");
    frame:SetPos(900, 730)
    frame:Resize(490, 120)
    local text1 = frame:CreateOrGetControl('richtext', 'text1', 20, 10)
    AUTO_CAST(text1)
    text1:SetText("{s20}{ol}[Lv.510] Urgent Repair Kit Setting")
    text1:SetTextTooltip("[Lv.510]緊急修理キット")

    local text2 = frame:CreateOrGetControl('richtext', 'text2', 10, 50)
    AUTO_CAST(text2)
    text2:SetText("{s20}{ol}Number of automatic purchases")
    text2:SetTextTooltip("自動購入数")

    local edit1 = frame:CreateOrGetControl('edit', 'edit1', 410, 50, 60, 30)
    AUTO_CAST(edit1)
    edit1:SetText("{ol}" .. g.settings.buyquantity)
    edit1:SetFontName("white_16_ol")
    edit1:SetTextAlign("center", "center")
    edit1:SetEventScript(ui.ENTERKEY, "AUTO_REPAIR_SETTING")
    edit1:SetTextTooltip("エンターキー押下で登録{nl}Register by pressing enter key")

    local text3 = frame:CreateOrGetControl('richtext', 'text3', 10, 80)
    AUTO_CAST(text3)
    text3:SetText("{s20}{ol}Message with less than input quantity")
    text3:SetTextTooltip("入力数量以下でメッセージ")
    frame:ShowWindow(1)

    local edit2 = frame:CreateOrGetControl('edit', 'edit2', 410, 80, 60, 30)
    AUTO_CAST(edit2)
    edit2:SetText("{ol}" .. g.settings.msgquantity)
    edit2:SetFontName("white_16_ol")
    edit2:SetTextAlign("center", "center")
    edit2:SetEventScript(ui.ENTERKEY, "AUTO_REPAIR_SETTING")
    edit2:SetTextTooltip("エンターキー押下で登録{nl}Register by pressing enter key")

    local closebtn = frame:CreateOrGetControl("button", "closebtn", 450, 10, 30, 30)
    AUTO_CAST(closebtn)
    closebtn:SetText("{ol}×")
    closebtn:SetEventScript(ui.LBUTTONUP, "AUTO_REPAIR_SETTING_FRAME_CLOSE")
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

function AUTO_REPAIR_FRAME_INIT()
    local frame = ui.GetFrame("auto_repair")
    frame:Resize(450, 180)
    frame:SetPos(650, 300)
    frame:SetSkinName("bg")
    frame:ShowTitleBar(0)
    frame:SetTitleName("{s20}{ol}Auto Repair")

    local text1 = frame:CreateOrGetControl('richtext', 'text1', 55, 20)
    AUTO_CAST(text1)
    text1:SetText("{s20}{ol}[LV.510]緊急修理キット{nl}残り少ないですが補充しますか？")
    text1:SetTextAlign("center", "center")

    local text3 = frame:CreateOrGetControl('richtext', 'text3', 25, 70)
    AUTO_CAST(text3)
    text3:SetText("{s18}{ol}[Lv.510] Urgent Repair Kit{nl}Do you want to replenish the few remaining?")
    text3:SetTextAlign("center", "center")

    local yesbtn = frame:CreateOrGetControl('button', 'yes', 115, 120, 80, 40)
    yesbtn:SetSkinName("test_red_button")
    yesbtn:SetText("{ol}YES")
    yesbtn:SetEventScript(ui.LBUTTONUP, "AUTO_REPAIR_BUY")

    local nobtn = frame:CreateOrGetControl('button', 'no', 215, 120, 80, 40)
    nobtn:SetSkinName("test_gray_button")
    nobtn:SetText("{ol}NO")
    nobtn:SetEventScript(ui.LBUTTONUP, "AUTO_REPAIR_CLOSE")

    frame:ShowWindow(1)
    ReserveScript("AUTO_REPAIR_CLOSE()", 5.0)

end

function AUTO_REPAIR_CLOSE()
    local frame = ui.GetFrame("auto_repair")
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
            msgquantity = 20
        }

        AUTO_REPAIR_SAVE_SETTINGS()

    end

    g.settings = settings
end

