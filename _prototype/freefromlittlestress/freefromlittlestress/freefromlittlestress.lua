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

g.defaultsettings = {
    rrfp_x = 500,
    rrfp_y = 300
};

function FREEFROMLITTLESTRESS_SAVE_SETTINGS()
    CHAT_SYSTEM("save")
    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function FREEFROMLITTLESTRESS_LOADSETTINGS()
    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.defaultsettings)
    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end
    if not settings then
        settings = g.defaultSettings -- 変数名が `g.defaultSettings` ではなく `g.defaultsettings` になっているため修正
    end

    g.settings = settings
end

function FREEFROMLITTLESTRESS_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    CHAT_SYSTEM(addonNameLower .. " loaded")

    acutil.setupHook(FREEFROMLITTLESTRESS_RAID_RECORD_INIT, "RAID_RECORD_INIT")
    -- acutil.setupHook(FREEFROMLITTLESTRESS_CLEAR_GODDESS_EQUIP_MANAGER, "CLEAR_GODDESS_EQUIP_MANAGER")
    addon:RegisterMsg("RESTART_CONTENTS_HERE", "FREEFROMLITTLESTRESS_FRAME_MOVE")
    addon:RegisterMsg("RESTART_HERE", "FREEFROMLITTLESTRESS_FRAME_MOVE")

    -- FREEFROMLITTLESTRESS_SAVE_SETTINGS()
    FREEFROMLITTLESTRESS_LOADSETTINGS()

    -- FREEFROMLITTLESTRESS_FRAME_INIT()

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

    -- FREEFROMLITTLESTRESS_UPDATESETTINGS(frame)

end
--[[
-- タブ変えた時にスロットクリアーなるの嫌
function FREEFROMLITTLESTRESS_CLEAR_GODDESS_EQUIP_MANAGER(frame)
    CHAT_SYSTEM("test")
    GODDESS_MGR_REFORGE_CLEAR(frame)
    GODDESS_MGR_RANDOMOPTION_CLEAR(frame)
    -- GODDESS_MGR_SOCKET_CLEAR(frame)
    GODDESS_MGR_MAKE_CLEAR(frame)
    GODDESS_MGR_INHERIT_CLEAR(frame)
    GODDESS_MGR_CONVERT_CLEAR(frame)
end
]]

-- 死んだ時に現れるフレームを移動可能に
function FREEFROMLITTLESTRESS_FRAME_MOVE()

    local rcframe = ui.GetFrame("restart_contents") -- フレームを移動可能に設定する
    rcframe:EnableMove(1)
    --[[
    rcframe:SetSkinName("shadow_box")
    local buttonSkin = "chat_window" -- 適用したいスキンの名前
    local buttonNames = {"btn_restart_1", "btn_restart_2", "btn_restart_3", "btn_restart_4", "btn_restart_5"}

    for i, buttonName in ipairs(buttonNames) do
        local button = GET_CHILD_RECURSIVELY(rcframe, buttonName)
        if button ~= nil then
            button:SetSkinName(buttonSkin)
        end
    end
    ]]
    local rframe = ui.GetFrame("restart") -- フレームを移動可能に設定する
    rframe:EnableMove(1)
    rframe:SetSkinName("shadow_box")
    local buttonSkin = "chat_window" -- 適用したいスキンの名前
    local buttonNames = {"btn_restart_1", "btn_restart_2", "btn_restart_3", "btn_restart_4", "btn_restart_5"}

    for i, buttonName in ipairs(buttonNames) do
        local button = GET_CHILD_RECURSIVELY(rcframe, buttonName)
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

    eqbutton:SetEventScript(ui.LBUTTONUP, "ON_EQUIP_BUTTON_CLICK")
    rmeqbutton:SetEventScript(ui.LBUTTONUP, "ON_RMEQUIP_BUTTON_CLICK")

end

function ON_EQUIP_BUTTON_CLICK(invframe)
    print("equipボタンがクリックされました")

    local goddessframe = ui.GetFrame('goddess_equip_manager')
    local socket_bg = GET_CHILD_RECURSIVELY(goddessframe, "socket_bg")

end

function ON_RMEQUIP_BUTTON_CLICK(invframe)
    print("rmequipボタンがクリックされました")
    local enable_slot_list = {'RH', 'LH', 'RH_SUB', 'LH_SUB'}
    for i = 1, #enable_slot_list do
        local slot_name = enable_slot_list[i]
        local ctrl_slot = GET_CHILD_RECURSIVELY(invframe, slot_name)
        if ctrl_slot ~= nil then
            local item = GET_SLOT_ITEM(ctrl_slot)
            if item ~= nil then
                local itemName = item:GetName()
                local itemID = item:GetIESID()
                print("スロット名: " .. slot_name)
                print("アイテム名: " .. itemName)
                print("アイテムID: " .. itemID)
            else
                print("スロット名 " .. slot_name .. " にはアイテムが入っていません")
            end
        else
            print("スロット名 " .. slot_name .. " は見つかりませんでした")
        end
    end
end

