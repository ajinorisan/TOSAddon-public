local addonName = "AETHERGEM_MGR"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")

function AETHERGEM_MGR_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    CHAT_SYSTEM(addonNameLower .. " loaded")

    AETHERGEM_MGR_FRAME_INIT()

end

function AETHERGEM_MGR_FRAME_INIT()
    local invframe = ui.GetFrame('inventory')
    local inventoryGbox = invframe:GetChild("inventoryGbox")

    -- ボタンの配置位置
    local buttonX = inventoryGbox:GetWidth() - 240
    local buttonY = inventoryGbox:GetHeight() - 610

    local eqbutton = inventoryGbox:CreateOrGetControl("button", "eqbutton", buttonX, buttonY, 50, 30)
    eqbutton:SetText("equip")

    local rmbuttonX = inventoryGbox:GetWidth() - 105
    local rmbuttonY = inventoryGbox:GetHeight() - 610

    local rmeqbutton = inventoryGbox:CreateOrGetControl("button", "rmeqbutton", rmbuttonX, rmbuttonY, 60, 30)
    rmeqbutton:SetText("rmequip")

    eqbutton:SetEventScript(ui.LBUTTONUP, "AETHERGEM_MGR_EQUIP_BUTTON_CLICK")
    rmeqbutton:SetEventScript(ui.LBUTTONUP, "AETHERGEM_MGR_REMOVEEQUIP_BUTTON_CLICK")

end

function AETHERGEM_MGR_EQUIP_BUTTON_CLICK()
    print("equipボタンがクリックされました")

end

function AETHERGEM_MGR_REMOVEEQUIP_BUTTON_CLICK()
    print("rmequipボタンがクリックされました")
    local frame = ui.GetFrame('goddess_equip_manager')
    AETHERGEM_MGR_GODDESS_EQUIP_MANAGER_OPEN(frame)
end

function AETHERGEM_MGR_GODDESS_EQUIP_MANAGER_OPEN(frame)
    if TUTORIAL_CLEAR_CHECK(GetMyPCObject()) == false then
        ui.SysMsg(ClMsg('CanUseAfterTutorialClear'))
        frame:ShowWindow(0)
        return
    end

    ui.CloseFrame('rareoption')
    ui.CloseFrame('item_cabinet')
    for i = 1, #revertrandomitemlist do
        local revert_name = revertrandomitemlist[i]
        local revert_frame = ui.GetFrame(revert_name)
        if revert_frame ~= nil and revert_frame:IsVisible() == 1 then
            ui.CloseFrame(revert_name)
        end
    end

    ui.OpenFrame('goddess_equip_manager')
    local main_tab = GET_CHILD_RECURSIVELY(frame, 'main_tab')
    main_tab:SelectTab(2)
    CLEAR_GODDESS_EQUIP_MANAGER(frame)
    GODDESS_MGR_SOCKET_OPEN(frame)
    AETHERGEM_MGR_EQUIP_SLOT_SET()
end

function AETHERGEM_MGR_EQUIP_SLOT_SET()
    local eqpframe = ui.GetFrame("inventory");
    local gbox_Equipped = GET_CHILD_RECURSIVELY(eqpframe, "gbox_Equipped");

    if gbox_Equipped:IsVisible() == 1 then
        CHAT_SYSTEM("true")
    end

    -- eqpSet:ShowWindow(0)
end
