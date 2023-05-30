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
    -- print("rmequipボタンがクリックされました")

    local frame = ui.GetFrame('goddess_equip_manager')

    -- ui.OpenFrame('goddess_equip_manager')
    -- frame:showwindow(1)
    -- socket_bg:showwindow(1)
    local index = 2
    AETHERGEM_MGR_TOGGLE_GODDESS_EQUIP_MANAGER_TAB(frame, index)
end

function AETHERGEM_MGR_TOGGLE_GODDESS_EQUIP_MANAGER_TAB(frame, index)

    if index == 2 then
        CHAT_SYSTEM("TEST")
        AETHERGEM_MGR_GODDESS_MGR_SOCKET_OPEN(frame)

    end

    GODDESS_EQUIP_UI_TUTORIAL_CHECK(frame)
end

function AETHERGEM_MGR_GODDESS_MGR_SOCKET_OPEN(frame)
    CHAT_SYSTEM("TEST")
    ui.OpenFrame('goddess_equip_manager')

    INVENTORY_SET_CUSTOM_RBTNDOWN('GODDESS_MGR_SOCKET_INV_RBTN')
    GODDESS_MGR_SOCKET_CLEAR(frame)
    local socket_bg = GET_CHILD_RECURSIVELY(frame, 'socket_bg')
    socket_bg:showwindow(1)
end
