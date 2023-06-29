local addonName = "indun_panel"
local addonNameLower = string.lower(addonName)
local author = "norisan"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")
--[[

]]
-- local panelframe = ui.CreateNewFrame("chat_window", "panelframe", 470, 40, 200, 200)
-- panelframe:ShowWindow(1)

function INDUN_PANEL_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.framename = addonName
    CHAT_SYSTEM(addonNameLower .. " loaded")

    indun_panel_frame_init()

end

function indun_panel_frame_init()

    local ipframe = ui.GetFrame(g.framename)
    ipframe:SetSkinName('None')
    ipframe:SetLayerLevel(30)
    ipframe:Resize(90, 35)
    ipframe:SetPos(500, 30)
    ipframe:SetTitleBarSkin("None")
    local button = ipframe:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(button)
    button:SetText("IP OPEN")
    button:SetEventScript(ui.LBUTTONUP, "indun_panel_init")
    ipframe:ShowWindow(1)

end

function indun_panel_init(ipframe)
    -- CHAT_SYSTEM("button_click")
    ipframe:SetLayerLevel(100)
    ipframe:Resize(700, 400)
    -- ipframe:SetSkinName("chat_window")
    ipframe:SetSkinName("test_frame_low")
    local title = ipframe:CreateOrGetControl("richtext", "indun_panel", 120, 10)
    title:SetText("{#000000}{s20}Indun Panel")
    local button = GET_CHILD_RECURSIVELY(ipframe, "indun_panel_open")
    button:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init")

    local challenge = ipframe:CreateOrGetControl("richtext", "challenge", 10, 45)
    challenge:SetText("{#000000}{s20}Challenge(チャレ)")
    local expert = ipframe:CreateOrGetControl("richtext", "Expert", 10, 80)
    expert:SetText("{#000000}{s20}Expert(分裂)")
    local roze = ipframe:CreateOrGetControl("richtext", "roze", 10, 115)
    roze:SetText("{#000000}{s20}Roze(ロゼ)")
    local falouros = ipframe:CreateOrGetControl("richtext", "falouros", 10, 150)
    falouros:SetText("{#000000}{s20}Falouros(ファロ)")
    local spreader = ipframe:CreateOrGetControl("richtext", "spreader", 10, 185)
    spreader:SetText("{#000000}{s20}Spreader(プロゲ)")
    local jellyzele = ipframe:CreateOrGetControl("richtext", "jellyzele", 10, 220)
    jellyzele:SetText("{#000000}{s20}Jellyzele(クラゲ)")
    local delmore = ipframe:CreateOrGetControl("richtext", "delmore", 10, 255)
    delmore:SetText("{#000000}{s20}Delmore(ムーア)")
    local telharsha = ipframe:CreateOrGetControl("richtext", "telharsha", 10, 290)
    telharsha:SetText("{#000000}{s20}TelHarsha(テル爺)")
    local velnice = ipframe:CreateOrGetControl("richtext", "velnice", 10, 325)
    velnice:SetText("{#000000}{s20}Velnice(ヴェルニケ)")
    local ancient = ipframe:CreateOrGetControl("richtext", "ancient", 10, 360)
    ancient:SetText("{#000000}{s20}Ancient(アシスター)")

    local challenge460 = ipframe:CreateOrGetControl('button', 'challenge460', 220, 45, 80, 30)
    local challenge480 = ipframe:CreateOrGetControl('button', 'challenge480', 305, 45, 80, 30)
    local challengept = ipframe:CreateOrGetControl('button', 'challengept', 390, 45, 80, 30)
    challenge460:SetText("460")
    challenge480:SetText("480")
    challengept:SetText("PT")

    challenge460:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge460")
end

function indun_panel_enter_challenge460()
    ReqChallengeAutoUIOpen(644)
    ReserveScript("ReqMoveToIndun(1,0)", 1.25)
end

