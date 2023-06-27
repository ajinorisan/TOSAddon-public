local addonName = "indun_panel"
local addonNameLower = string.lower(addonName)
local author = "norisan"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")

function INDUN_PANEL_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.faramname = addonNameLower
    CHAT_SYSTEM(addonNameLower .. " loaded")

    g.indun_panel_frame_init()

end

function g.indun_panel_frame_init()
    local ipframe = ui.GetFrame(g.faramname)
    ipframe:Resize(100, 30)
    ipframe:SetOffset(300, 50)
    local button = ipframe:CreateOrGetControl("button", "indun_panel_open", 10, 10, 100, 30)
    button:SetText(addonNameLower)
    button:setEventScript(ui.LBUTTONDOWN, "g.indun_panel_click")
end

function g.indun_panel_click()
    CHAT_SYSTEM("button_click")
end
