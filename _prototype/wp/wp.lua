local addonName = "WP"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")

function WP_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    CHAT_SYSTEM(addonNameLower .. " loaded")
    addon:RegisterMsg('FPS_UPDATE', 'WP_test');

end

function WP_test()
    local am_liftIcon = ui.GetLiftIcon();
    AUTO_CAST(am_liftIcon);
    local itemName = "アイテム名" -- アイテム名を指定
    local classID = 12345 -- クラスIDを指定
    am_liftIcon:SetEventScript(ui.LBUTTONUP, "WP_test2")
    am_liftIcon:SetEventScriptArgString(ui.LBUTTONUP, itemName)
    am_liftIcon:SetEventScriptArgNumber(ui.LBUTTONUP, classID)
end

function WP_test2(frame, ctrl, strarg, numarg)
    print(strarg)
    print(numarg)
end
