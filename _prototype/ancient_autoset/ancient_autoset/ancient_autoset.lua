local addonName = "ANCIENT_AUTOSET"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")

if not g.loaded then
    g.settings = {
        pctbl = {
            slot1 = nil,
            slot2 = nil,
            slot3 = nil,
            slot4 = nil
        }
    }
end

function ANCIENT_AUTOSET_SAVE_SETTINGS()

    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function ANCIENT_AUTOSET_LOAD_SETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    local loginCharID = info.GetCID(session.GetMyHandle())

    if g.settings.pctbl == nil then
        g.settings.pctbl = {}
    end

end

function ANCIENT_AUTOSET_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    CHAT_SYSTEM(addonNameLower .. " loaded")

    local aasframe = ui.CreateNewFrame("notice_on_pc", "aasframe")
    aasframe:Resize(100, 40)
    aasframe:SetOffset(1300, 930)
    aasframe:ShowWindow(1)
    local btn = aasframe:CreateOrGetControl("button", "testbtn", 0, 0, 100, 40)
    btn:SetText("testbtn")
    btn:SetEventScript(ui.LBUTTONUP, "ANCIENT_AUTOSET_FRAME_INIT")

    local origframe = ui.GetFrame("ancient_card_list")
    local btn2 = origframe:GetChildRecursively("topbg"):CreateOrGetControl("button", "btn_aas", 0, 0, 90, 33)
    AUTO_CAST(btn2)
    btn2:SetGravity(ui.LEFT, ui.BOTTOM)
    btn2:SetMargin(200, 0, 0, 0)
    btn2:SetText("{ol}Setting Reg")
    btn2:SetEventScript(ui.LBUTTONUP, "ANCIENT_SETTING_REG")
    -- addon:RegisterMsg("BANDI_CAM", "HIDE_CHATFRAME_ON_BANDI_CAM")
    -- acutil.setupHook(HIDE_CHATFRAME_ON_BANDI_CAM, "ON_BANDI_CAM")

end

function ANCIENT_SETTING_REG()
    local frame = ui.GetFrame("ancient_card_list")
    local tab = frame:GetChild("tab")
    AUTO_CAST(tab)
    tab:SelectTab(0)

end

function ANCIENT_AUTOSET_FRAME_INIT(frame)

    -- btn:SetEventScript(ui.LBUTTONUP, "ANCIENTMONSTERBOOKSHELF_TOGGLE")

    local frame = ui.GetFrame("ancient_autoset")
    frame:Resize(132, 43)
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

    local ancient_card_slot_Gbox = frame:CreateOrGetControl("groupbox", "ancient_card_slot_Gbox", 120, 30, ui.LEFT,
                                                            ui.TOP, 0, 0, 0, 0);
    AUTO_CAST(ancient_card_slot_Gbox)
    ancient_card_slot_Gbox:EnableHittestGroupBox(false)
    ancient_card_slot_Gbox:SetSkinName("test_frame_midle")

    local slotset = ancient_card_slot_Gbox:CreateOrGetControl("slotset", "slotset", 0, 0, 132, 43)
    -- local slotset = frame:CreateOrGetControl("slotset", "slotset", 0, 0, 220, 92)
    tolua.cast(slotset, "ui::CSlotSet")
    slotset:RemoveAllChild();
    slotset:SetColRow(4, 1)
    slotset:SetMaxSelectionCount(1)
    -- slotset:SetSlotSize(33, 43)
    slotset:SetSlotSize(30, 30)
    slotset:SetSkinName("slot");
    slotset:CreateSlots()

    slotset:ShowWindow(1)

    ANCIENT_AUTOSET_CTRL_INIT(frame, slotset)

end

function ANCIENT_AUTOSET_CTRL_INIT(frame, slotset)
    for i = 0, 3 do
        local toslot = slotset:GetSlotByIndex(i)
        toslot:SetUserValue("SLOT_NAME", "toslot_" .. i)
        AUTO_CAST(toslot)
        -- local frame = ui.GetFrame("ancient_card_list")
        -- local gbox = GET_CHILD_RECURSIVELY(frame, 'ancient_card_slot_Gbox')

        -- local ctrlSet = gbox:CreateControlSet("ancient_card_item_slot", "SLOT_" .. i, 4, 4);
        -- local slot = GET_CHILD_RECURSIVELY(ctrlSet, "ancient_card_slot")
        -- AUTO_CAST(slot)

        -- local icon = CreateIcon(slot);

        local card = session.ancient.GetAncientCardBySlot(i)

        local monCls = GetClass("Monster", card:GetClassName());

        local iconName = TryGetProp(monCls, "Icon");
        CHAT_SYSTEM(iconName)
        -- icon:SetImage(iconName)

        local toicon = CreateIcon(toslot);
        toicon:SetImage(iconName)
    end
    ReserveScript("ANCIENT_AUTOSET_CLOSE()", 5.0)
end

function ANCIENT_AUTOSET_CLOSE()
    local frame = ui.CloseFrame("ancient_autoset")
end
--[[とりあえず動いたやつ
function ANCIENT_AUTOSET_CTRL_INIT(frame, slotset)
    for i = 0, 3 do
        local toslot = slotset:GetSlotByIndex(i)
        toslot:SetUserValue("SLOT_NAME", "toslot_" .. i)
        AUTO_CAST(toslot)
        local frame = ui.GetFrame("ancient_card_list")
        local gbox = GET_CHILD_RECURSIVELY(frame, 'ancient_card_slot_Gbox')

        local ctrlSet = gbox:CreateControlSet("ancient_card_item_slot", "SLOT_" .. i, 4, 4);
        local slot = GET_CHILD_RECURSIVELY(ctrlSet, "ancient_card_slot")
        AUTO_CAST(slot)

        local icon = CreateIcon(slot);

        local card = session.ancient.GetAncientCardBySlot(i)

        local monCls = GetClass("Monster", card:GetClassName());

        local iconName = TryGetProp(monCls, "Icon");
        CHAT_SYSTEM(iconName)
        icon:SetImage(iconName)

        local toicon = CreateIcon(toslot);
        toicon:SetImage(iconName)
    end
end
]]
