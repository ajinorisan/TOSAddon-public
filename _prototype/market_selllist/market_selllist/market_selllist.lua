local addonName = "MARKET_SELLLIST"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.logpath = string.format('../addons/%s/log.txt', addonNameLower)

local acutil = require("acutil")
local os = require("os")

local base = {}
g.sellcount = 0

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName];
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

g.settings.sell_list = {}

function MARKET_SELLLIST_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    addon:RegisterMsg("SOLD_ITEM_NOTICE", "MARKET_SELLLIST_SOLD_ITEM_NOTICE")
    -- g.SetupHook(BARRACK_MGR_SELECT_CHARBTN_LBTNUP, "SELECT_CHARBTN_LBTNUP")

    -- addon:RegisterMsg("GAME_START", "AUTO_REPAIR_FRAME_INIT")
    MARKET_SELLLIST_load_settings()

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" and g.sellcount > 0 then
        addon:RegisterMsg("GAME_START_3SEC", "MARKET_SELLLIST_PRINT")
    end
end

function MARKET_SELLLIST_PRINT(frame)

    local frame = ui.GetFrame("market_selllist")
    frame:SetSkinName("chat_window")
    frame:ShowTitleBar(0);

    frame:SetEventScript(ui.RBUTTONUP, "MARKET_SELLLIST_CLEAR")
    frame:SetEventScript(ui.LBUTTONUP, "MARKET_SELLLIST_CLOSE")
    frame:SetTextTooltip(
        "右クリック:リストクリア 左クリック:リストを閉じる{nl}Right click: Clear list Left click: Close list")
    local textview_log = frame:GetChildRecursively("textview_log")
    textview_log:SetText("")
    textview_log:SetFontName("white_16_ol")
    for timestamp, msg in pairs(g.settings.sell_list) do
        local currentText = textview_log:GetText()
        local newText = timestamp .. " " .. msg .. "\n"
        textview_log:SetText(currentText .. newText)
    end

    -- スクロールバーを一番下までスクロール
    textview_log:ScrollToBottom()
    frame:ShowWindow(1)

end

function MARKET_SELLLIST_CLOSE(frame)
    frame:ShowWindow(0)
end

function MARKET_SELLLIST_CLEAR(frame)
    for timestamp, msg in pairs(g.settings.sell_list) do
        local fd = io.open(g.logpath, "a")
        fd:write(timestamp .. " " .. msg .. "\n")
        fd:flush()
        fd:close()
    end
    ui.SysMsg("The list of sold items has been cleared.")
    g.settings.sell_list = {}
    MARKET_SELLLIST_save_settings()
end

function MARKET_SELLLIST_SOLD_ITEM_NOTICE(frame, msg, argStr, argNum)

    g.sellcount = g.sellcount + 1

    local time = os.date("*t")
    local year = time.year
    local month = time.month
    local day = time.day
    local hour = time.hour
    local min = time.min
    local timestamp = string.format("%04d.%02d.%02d-%02d:%02d", year, month, day, hour, min)

    if not g.settings.sell_list[timestamp] then
        g.settings.sell_list[timestamp] = {}
    end

    table.insert(g.settings.sell_list, timestamp, msg)
    MARKET_SELLLIST_save_settings()
end

function MARKET_SELLLIST_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function MARKET_SELLLIST_load_settings()

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

