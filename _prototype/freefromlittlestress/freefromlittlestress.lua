local addonName = "FREEFROMLITTLESTRESS"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

g.settings = {
    rrfp_x = 500,
    rrfp_y = 300
}

function FREEFROMLITTLESTRESS_SAVE_SETTINGS()
    -- CHAT_SYSTEM("save")
    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function FREEFROMLITTLESTRESS_LOADSETTINGS()

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

function FREEFROMLITTLESTRESS_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    CHAT_SYSTEM(addonNameLower .. " loaded")

    acutil.setupHook(FREEFROMLITTLESTRESS_RAID_RECORD_INIT, "RAID_RECORD_INIT")
    addon:RegisterMsg("RESTART_HERE", "FREEFROMLITTLESTRESS_FRAME_MOVE")
    addon:RegisterMsg("RESTART_CONTENTS_HERE", "FREEFROMLITTLESTRESS_FRAME_MOVE")

    FREEFROMLITTLESTRESS_LOADSETTINGS()
    FREEFROMLITTLESTRESS_FRAME_INIT()

end

function FREEFROMLITTLESTRESS_UPDATESETTINGS(frame)
    if g.settings.rrfp_x ~= frame:GetX() or g.settings.rrfp_y ~= frame:GetY() then
        g.settings.rrfp_x = frame:GetX()
        g.settings.rrfp_y = frame:GetY()
        FREEFROMLITTLESTRESS_SAVE_SETTINGS()
    end
end

-- レイドクリアー時のフレームを移動して場所を覚えさせる。
function FREEFROMLITTLESTRESS_RAID_RECORD_INIT(frame)
    frame:SetOffset(g.settings.rrfp_x, g.settings.rrfp_y)
    -- frame:SetOffset(500, 300)
    frame:SetSkinName("shadow_box")
    frame:SetEventScript(ui.LBUTTONUP, "FREEFROMLITTLESTRESS_UPDATESETTINGS")
    FREEFROMLITTLESTRESS_UPDATESETTINGS(frame)

    local myInfo = GET_CHILD_RECURSIVELY(frame, "myInfo")
    local myInfo_name = GET_CHILD_RECURSIVELY(myInfo, "name")
    local myInfo_time = GET_CHILD_RECURSIVELY(myInfo, "time")
    myInfo_name:SetFontName("white_16_ol")
    myInfo_time:SetFontName("white_16_ol")

    local friendInfo1 = GET_CHILD_RECURSIVELY(frame, "friendInfo1")
    local friendInfo1_name = GET_CHILD_RECURSIVELY(friendInfo1, "name")
    local friendInfo1_time = GET_CHILD_RECURSIVELY(friendInfo1, "time")
    friendInfo1_name:SetFontName("white_16_ol")
    friendInfo1_time:SetFontName("white_16_ol")

    local friendInfo2 = GET_CHILD_RECURSIVELY(frame, "friendInfo2")
    local friendInfo2_name = GET_CHILD_RECURSIVELY(friendInfo2, "name")
    local friendInfo2_time = GET_CHILD_RECURSIVELY(friendInfo2, "time")
    friendInfo2_name:SetFontName("white_16_ol")
    friendInfo2_time:SetFontName("white_16_ol")

    local friendInfo3 = GET_CHILD_RECURSIVELY(frame, "friendInfo3")
    local friendInfo3_name = GET_CHILD_RECURSIVELY(friendInfo3, "name")
    local friendInfo3_time = GET_CHILD_RECURSIVELY(friendInfo3, "time")
    friendInfo3_name:SetFontName("white_16_ol")
    friendInfo3_time:SetFontName("white_16_ol")

    GET_CHILD_RECURSIVELY(frame, 'bgIndunClear'):ShowWindow(1)
    GET_CHILD_RECURSIVELY(frame, 'textNewRecord'):ShowWindow(0);

end

-- 死んだ時に現れるフレームを移動可能に
function FREEFROMLITTLESTRESS_FRAME_MOVE()

    local rcframe = ui.GetFrame("restart_contents") -- フレームを移動可能に設定する
    rcframe:EnableMove(1)

    -- 多分コロニー時はこっちちゃうかな
    local rframe = ui.GetFrame("restart") -- フレームを移動可能に設定する
    rframe:EnableMove(1)
    rframe:SetSkinName("None")
    local buttonSkin = "chat_window" -- 適用したいスキンの名前
    local buttonNames = {"btn_restart_1", "btn_restart_2", "btn_restart_3", "btn_restart_4", "btn_restart_5"}

    for i, buttonName in ipairs(buttonNames) do
        local button = GET_CHILD_RECURSIVELY(rframe, buttonName)
        if button ~= nil then
            button:SetSkinName(buttonSkin)
        end
    end

end
-- エーテルジェム自動着脱作りかけ
function FREEFROMLITTLESTRESS_FRAME_INIT()
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

    eqbutton:SetEventScript(ui.LBUTTONUP, "FREEFROMLITTLESTRESS_EQUIP_BUTTON_CLICK")
    rmeqbutton:SetEventScript(ui.LBUTTONUP, "FREEFROMLITTLESTRESS_REMOVEEQUIP_BUTTON_CLICK")

end

function FREEFROMLITTLESTRESS_EQUIP_BUTTON_CLICK()
    print("equipボタンがクリックされました")

    local gdsframe = ui.GetFrame('goddess_equip_manager')
    local socket_bg = GET_CHILD_RECURSIVELY(gdsframe, "socket_bg")

end

function FREEFROMLITTLESTRESS_REMOVEEQUIP_BUTTON_CLICK()
    print("rmequipボタンがクリックされました")
    local gdsframe = ui.GetFrame('goddess_equip_manager')
    FREEFROMLITTLESTRESS_GODDESS_MGR_SOCKET_OPEN(gdsframe)

end

function FREEFROMLITTLESTRESS_GODDESS_MGR_SOCKET_OPEN(gdsframe)
    INVENTORY_SET_CUSTOM_RBTNDOWN('GODDESS_MGR_SOCKET_INV_RBTN')
    GODDESS_MGR_SOCKET_CLEAR(gdsframe)
    gdsframe:ShowWindow(1)
    print("1")
    TOGGLE_GODDESS_EQUIP_MANAGER_TAB(gdsframe, 2)
    print("2")
end
