local addonName = "FREEFROMLITTLESTRESS"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")

g.SettingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

if not g.loaded then

    g.settings = {
        rrfp_x = 1300,
        rrfp_y = 100
    };

end

function FREEFROMLITTLESTRESS_SAVE_SETTINGS()
    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function FREEFROMLITTLESTRESS_LOADSETTINGS()

    local t, err = acutil.loadJSON(g.settingsFileLoc);
    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files. Create an " .. addonNameLower ..
                                      " folder in the addons folder and create a settinngs.json file in it",
            addonNameLower))
    else
        -- 設定ファイル読み込み成功時処理
        g.settings = t;
    end
    g.loaded = true
end

function FREEFROMLITTLESTRESS_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    CHAT_SYSTEM(addonNameLower .. " loaded")

    acutil.setupHook(FREEFROMLITTLESTRESS_RAID_RECORD_INIT, "RAID_RECORD_INIT")
    acutil.setupHook(FREEFROMLITTLESTRESS_CLEAR_GODDESS_EQUIP_MANAGER, "CLEAR_GODDESS_EQUIP_MANAGER")
    addon:RegisterMsg("RESTART_CONTENTS_HERE", "FREEFROMLITTLESTRESS_FRAME_MOVE")
    addon:RegisterMsg("RESTART_HERE", "FREEFROMLITTLESTRESS_FRAME_MOVE")

    FREEFROMLITTLESTRESS_LOADSETTINGS()
    -- FREEFROMLITTLESTRESS_FRAME_INIT()

end

-- タブ変えた時にスロットクリアーなるの嫌
function FREEFROMLITTLESTRESS_CLEAR_GODDESS_EQUIP_MANAGER(frame)
    GODDESS_MGR_REFORGE_CLEAR(frame)
    GODDESS_MGR_RANDOMOPTION_CLEAR(frame)
    -- GODDESS_MGR_SOCKET_CLEAR(frame)
    GODDESS_MGR_MAKE_CLEAR(frame)
    GODDESS_MGR_INHERIT_CLEAR(frame)
    GODDESS_MGR_CONVERT_CLEAR(frame)
end

-- 死んだ時に現れるフレームを移動可能に
function FREEFROMLITTLESTRESS_FRAME_MOVE()

    local rcframe = ui.GetFrame("restart_contents") -- フレームを移動可能に設定する
    rcframe:EnableMove(1)
    local rframe = ui.GetFrame("restart") -- フレームを移動可能に設定する
    rframe:EnableMove(1)

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

-- レイドクリアー時のフレームを移動して場所を覚えさせる。
function FREEFROMLITTLESTRESS_RAID_RECORD_INIT(frame)
    frame:SetOffset(g.settings.rrfp_x, g.settings.rrfp_y)
    frame:SetSkinName("shadow_box")
    FREEFROMLITTLESTRESS_SAVE_SETTINGS()

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

