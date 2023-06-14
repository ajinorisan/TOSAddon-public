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

function ANCIENT_AUTOSET_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    CHAT_SYSTEM(addonNameLower .. " loaded")

    local aasframe = ui.CreateNewFrame("notice_on_pc", "aasframe")
    aasframe:Resize(100, 40)
    aasframe:SetOffset(1000, 500)
    aasframe:ShowWindow(1)
    local btn = aasframe:CreateOrGetControl("button", "testbtn", 0, 0, 100, 40)
    btn:SetText("testbtn")
    btn:SetEventScript(ui.LBUTTONUP, "ANCIENT_AUTOSET_FRAME_INIT")
    -- addon:RegisterMsg("BANDI_CAM", "HIDE_CHATFRAME_ON_BANDI_CAM")
    -- acutil.setupHook(HIDE_CHATFRAME_ON_BANDI_CAM, "ON_BANDI_CAM")

end

function ANCIENT_AUTOSET_FRAME_INIT(frame)
    local frame = ui.GetFrame("ancient_autoset")
    frame:Resize(176, 90)
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

    local ancient_card_slot_Gbox = frame:CreateOrGetControl("groupbox", "ancient_card_slot_Gbox", 176, 90, ui.LEFT,
                                                            ui.TOP, 0, 0, 0, 0);
    AUTO_CAST(ancient_card_slot_Gbox)
    ancient_card_slot_Gbox:EnableHittestGroupBox(false)
    ancient_card_slot_Gbox:SetSkinName("test_frame_midle")

    local slotset = ancient_card_slot_Gbox:CreateOrGetControl("slotset", "slotset", 0, 0, 176, 90)

    tolua.cast(slotset, "ui::CSlotSet")
    slotset:RemoveAllChild();
    slotset:SetColRow(4, 1)
    slotset:SetMaxSelectionCount(1)
    slotset:SetSlotSize(42, 90)
    slotset:SetSkinName('invenslot')
    slotset:CreateSlots()

    ANCIENT_AUTOSET_CTRL_INIT(frame)

end

function ANCIENT_AUTOSET_CTRL_INIT(frame)

    local gbox = GET_CHILD_RECURSIVELY(frame, 'ancient_card_slot_Gbox')

end
