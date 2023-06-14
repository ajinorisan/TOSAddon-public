local addonName = "WP"
local addonNameLower = string.lower(addonName)
local author = "norisan"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")

-- print("5")

-- フレームの位置と表示

function WP_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    local wp2frame = ui.CreateNewFrame("notice_on_pc", "WP2FRAME")
    wp2frame:Resize(200, 150)
    -- wp2frame:SetLayerLevel(130)
    frame:SetOffset(1000, 500)
    wp2frame:ShowWindow(1)
    -- CHAT_SYSTEM("1")
    -- ボタン作成
    local btn = wp2frame:CreateOrGetControl("button", "BTN_TEST", 50, 50, 100, 40)
    btn:SetText("Click me!")
    -- CHAT_SYSTEM("2")
    btn:SetEventScript(ui.LBUTTONUP, "ANCIENT_NOTICE_FRAME_INIT")
    -- addon:RegisterMsg('FPS_UPDATE', 'WP_LIFT_ICON')
    -- addon:RegisterMsg("GAME_START_3SEC", 'WP_TEST')
    -- acutil.setupHook(WP_CHECK_INV_LBTN, "CHECK_INV_LBTN")

    -- ANCIENT_NOTICE_FRAME_INIT(frame)
    CHAT_SYSTEM(addonNameLower .. " loaded")

end

function ANCIENT_NOTICE_FRAME_INIT(frame)
    -- CHAT_SYSTEM("1")

    -- CHAT_SYSTEM("iconName2")

    -- for index = 0, 3 do
    -- local card = session.ancient.GetAncientCardBySlot(index)
    -- end
    -- local anslot = GET_CHILD_RECURSIVELY(anctrlSet, "ancient_card_slot")
    -- AUTO_CAST(slot)
    -- local icon = anslot:GetIcon()

    local frame = ui.GetFrame("wp")
    frame:Resize(170, 60)

    frame:SetSkinName("None")
    -- frame:SetImage("pcbang_timer_bg")
    frame:SetLayerLevel(120)
    frame:ShowTitleBar(0)
    frame:EnableHitTest(1)
    local screenWidth = ui.GetClientInitialWidth()
    local offsetX = screenWidth - 610
    local screenHeight = ui.GetClientInitialHeight()
    local frameHeight = frame:GetHeight()
    local offsetY = screenHeight - frameHeight - 60
    frame:SetOffset(offsetX, offsetY)
    frame:RemoveAllChild();
    frame:ShowWindow(1)
    local slotset = GET_CHILD_RECURSIVELY(frame, "slotset")
    if slotset == nil then
        slotset = frame:CreateOrGetControl("slotset", "slotset", 0, 0, 170, 60)

        tolua.cast(slotset, "ui::CSlotSet")
        slotset:RemoveAllChild();
        slotset:SetColRow(4, 1)
        slotset:SetMaxSelectionCount(1)
        slotset:SetSlotSize(40, 60)
        slotset:SetSkinName('invenslot')

        slotset:CreateSlots()
    end
    for i = 0, 3 do
        local anframe = ui.GetFrame("ancient_card_list")

        local anctrlSet = GET_CHILD_RECURSIVELY(anframe, "ancient_card_slot")
        tolua.cast(anctrlSet, "ui::CSlotSet")

        CHAT_SYSTEM("1")
        local slot = slotset:GetSlotByIndex(i)
        CHAT_SYSTEM("2")
        slot = slotset:CreateOrGetControl("slot", "slot" .. i, 0, 0, 35, 35)
        CHAT_SYSTEM("3")
        local anslot = anctrlSet:GetSlotByIndex(i)
        AUTO_CAST(anslot)
        CHAT_SYSTEM("4")
        AUTO_CAST(slot)

        CHAT_SYSTEM("5")
        slot:SetSkinName("slot")
        CHAT_SYSTEM("6")
        local slotX = i * (39) -- スロットの横位置を計算
        slot:SetOffset(slotX, 0) -- スロットの位置を設定

        if slot ~= nil and anslot ~= nil then
            local originalIcon = anslot:GetIcon()
            if originalIcon ~= nil then
                local iconName = originalIcon:GetImageName()

                slot:SetImage(iconName)
            end

            slot:EnableDrag(0) -- ドラッグ無効化
            slot:EnableDrop(0) -- ドロップ無効化
            -- itemIES = GetIES(invenItemInfo:GetObject());
            -- SET_SLOT_IMG(slot, GET_ITEM_ICON_IMAGE(itemIES));
            slot:ShowWindow(1)

        end

    end
end
--[[
function WP_TEST()
    CHAT_SYSTEM("test1")
    local frame = ui.GetFrame("inventory")
    -- if frame:IsVisible() == 1 then
    local lift_icon = ui.GetLiftIcon()
    CHAT_SYSTEM("test2")
    local icon_info = lift_icon:GetInfo()
    CHAT_SYSTEM("test3")
    local guid = icon_info:GetIESID()
    CHAT_SYSTEM("test4")
    local inv_item = session.GetInvItemByGuid(guid)
    CHAT_SYSTEM("test5")
    local item_obj = GetIES(inv_item:GetObject())
    CHAT_SYSTEM("test6")
    local item_name = TryGetProp(item_obj, 'ClassName', 'None')
    CHAT_SYSTEM("test7")
    local item_type = TryGetProp(item_obj, 'Type', 'None')
    CHAT_SYSTEM("test8")
    local item_cls = TryGetProp(item_obj, 'ClassID', 0)
    CHAT_SYSTEM("test9")
    CHAT_SYSTEM(guid)
    CHAT_SYSTEM(item_name)
    CHAT_SYSTEM(item_type)
    CHAT_SYSTEM(item_cls)
    
end
]]

