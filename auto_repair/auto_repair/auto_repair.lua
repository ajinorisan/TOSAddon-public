-- v1.0.2 on_init読み込み時にリペアーアイテムの数量確認
-- v1.0.3 SetupHookの競合修正
-- v1.0.4 23.09.05patch対応。修理キット買うコード変えてやがった許せねえ。
local addonName = "AUTO_REPAIR"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.4"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

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

function AUTO_REPAIR_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    -- CHAT_SYSTEM(addonNameLower .. " loaded")
    -- acutil.setupHook(AUTO_REPAIR_IS_DUR_UNDER_10PER, "IS_DUR_UNDER_10PER")
    g.SetupHook(AUTO_REPAIR_DURNOTIFY_UPDATE, "DURNOTIFY_UPDATE")
    -- g.SetupHook(AUTO_REPAIR_DRAW_EXCHANGE_SHOP_IETMS, "DRAW_EXCHANGE_SHOP_IETMS")
    -- g.SetupHook(AUTO_REPAIR_ACCOUNT_EXCHANGE_CREATE_TREE_NODE_CTRL, "EXCHANGE_CREATE_TREE_NODE_CTRL")
    --[[
    ['VakarineCertificate'] = 
    {
        ['coinName'] = 'dummy_VakarineCertificate',
        ['propName'] = 'VakarineCertificate',
    }
]] -- 11200243

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then

        local autorepair_item = session.GetInvItemByName('QuestReward_repairPotion_500')

        if autorepair_item ~= nil then
            local repairCount = autorepair_item.count

            if repairCount < 10 then

                addon:RegisterMsg("GAME_START_3SEC", "AUTO_REPAIR_FRAME_INIT")
            end
        else

            addon:RegisterMsg("GAME_START_3SEC", "AUTO_REPAIR_FRAME_INIT")
        end

    end

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
    text1:SetText("{s20}{ol}[LV.500]緊急修理キット{nl}残り少ないですが補充しますか？")
    text1:SetTextAlign("center", "center")
    --[[local text2 = frame:CreateOrGetControl('richtext', 'text2', 25, 30)
    AUTO_CAST(text2)
    text2:SetText("{s20}{ol}残り少ないですが補充しますか？")]]
    local text3 = frame:CreateOrGetControl('richtext', 'text3', 25, 70)
    AUTO_CAST(text3)
    text3:SetText("{s18}{ol}QuestReward_repairPotion_500{nl}Do you want to replenish the few remaining?")
    text3:SetTextAlign("center", "center")
    --[[local text4 = frame:CreateOrGetControl('richtext', 'text4', 25, 80)
    AUTO_CAST(text4)
    text4:SetText("{s18}{ol}Do you want to replenish the few remaining?")]]

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

    -- local frame = ui.GetFrame('earthtowershop')
    -- local shopType = "VakarineCertificate"
    -- ui.CloseFrame('earthtowershop')
    -- control.CustomCommand('REQ_SEASON_COIN_SHOP_OPEN', 0);

    local autorepair_item = session.GetInvItemByName('QuestReward_repairPotion_500')
    if autorepair_item ~= nil then
        local repairCount = autorepair_item.count

        -- CHAT_SYSTEM(repeatCount)
        local cnt = 50 - repairCount

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
        local cnt = 50

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
        local slotcnt = imcSlot:GetFilledSlotCount(slotSet);
        local tempobj = equipItem:GetObject()
        if tempobj ~= nil then
            local obj = GetIES(tempobj);
            if IS_DUR_UNDER_10PER(obj) == true then
                local colorTone = "FF999900";
                if someflag < 2 then
                    someflag = 2
                    AUTO_REPAIR_ITEM_USE(obj)
                    -- ReserveScript(string.format("AUTO_REPAIR_ITEM_USE(\"%s\")", obj), 1.0)
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

function AUTO_REPAIR_ITEM_USE(obj)
    session.ResetItemList()
    local autorepair_item = session.GetInvItemByName('QuestReward_repairPotion_500')

    if autorepair_item == nil then

        CHAT_SYSTEM('[Lv.500]緊急修理キットがありません')
        CHAT_SYSTEM('[Lv.500] Urgent Repair Kit is not available.')
        return
    end

    if autorepair_item.isLockState == true then

        CHAT_SYSTEM(ClMsg('MaterialItemIsLock'))
        return
    end

    local repeatCount = math.min(autorepair_item.count, 4)
    -- ui.SysMsg("Automatic repair of equipment.") 表示が邪魔なので消した。v1.0.1
    -- ui.ChatMsg("Automatic repair of equipment.")
    -- CHAT_SYSTEM("Automatic repair of equipment.")

    for i = 0, repeatCount - 1 do
        if obj.Dur / obj.MaxDur < 0.9 then
            item.UseByGUID(autorepair_item:GetIESID())

        else
            break
        end
    end
    -- ReserveScript(string.format("AUTO_REPAIR_ITEM_USE(\"%s\")", obj), 1.0)

end

function AUTO_REPAIR_SAVE_SETTINGS()
    -- CHAT_SYSTEM("save")
    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function AUTO_REPAIR_LOADSETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end
    if not settings then
        settings = g.settings
    end

    g.settings = settings
end

