-- v1.0.0 時間、販売者名、アイテム名、個数表示
local addonName = "MARKET_SELLLIST"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.logpath = string.format('../addons/%s/log.json', addonNameLower)

local acutil = require("acutil")
local os = require("os")
-- local json = require("json_imc")

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

g.settings = {
    selllist = {}
}

g.log = {
    selllist = {}
}

function MARKET_SELLLIST_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    -- addon:RegisterMsg("SOLD_ITEM_NOTICE", "MARKET_SELLLIST_SOLD_ITEM_NOTICE")

    g.SetupHook(MARKET_SELLLIST_SOLD_ITEM_NOTICE, 'ON_SOLD_ITEM_NOTICE')
    acutil.setupEvent(addon, 'MARKET_CABINET_OPEN', "MARKET_SELLLIST_PRINT")

    MARKET_SELLLIST_load_settings()
    MARKET_SELLLIST_save_settings(nil)

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        -- addon:RegisterMsg("GAME_START_3SEC", "MARKET_SELLLIST_PRINT")
    end

end

function MARKET_SELLLIST_PRINT(frame)

    local frame = ui.GetFrame("market_selllist")
    frame:SetSkinName("chat_window")
    frame:ShowTitleBar(0);
    frame:SetOffset(450, 30);
    frame:Resize(850, 975)
    frame:EnableHitTest(1)
    frame:SetLayerLevel(100);
    -- frame:EnableScrollBar(1)

    -- frame:SetEventScript(ui.RBUTTONUP, "MARKET_SELLLIST_CLEAR")
    frame:SetEventScript(ui.LBUTTONUP, "MARKET_SELLLIST_CLOSE")

    local textview_log = frame:GetChildRecursively("textview_log")
    if textview_log ~= nil then
        textview_log:ShowWindow(0)
    end

    local logdelete = frame:CreateOrGetControl("button", "logdelete", 750, 935, 30, 30)
    AUTO_CAST(logdelete)
    logdelete:SetTextTooltip("ログを削除します。{nl}Delete logs.")
    logdelete:SetText("Log Delete")
    logdelete:SetEventScript(ui.LBUTTONUP, "MARKET_SELLLIST_CLEAR")

    local close = frame:CreateOrGetControl("button", "close", 810, 10, 30, 30)
    AUTO_CAST(logdelete)
    -- close:SetTextTooltip("ログを削除します。{nl}Delete logs.")
    close:SetText("×")
    close:SetEventScript(ui.LBUTTONUP, "MARKET_SELLLIST_CLOSE")

    local textview = frame:CreateOrGetControl("richtext", "textview", 10, 10, 820, 940)
    AUTO_CAST(textview)
    textview:SetTextTooltip("左クリックでフレームを閉じます。{nl}Left-click to close the frame.")
    textview:SetText("")

    local logText = "" -- テキストを組み立てる変数

    -- フォーマットして表示
    for timestamp, inputString in pairs(g.settings.selllist) do
        local delimiter = "/" -- 最初の区切り文字

        -- 最初に "/" で分割
        local parts = {}
        for part in string.gmatch(inputString, "[^" .. delimiter .. "]+") do
            table.insert(parts, part)
        end

        -- timestampを行の左側に追加
        table.insert(parts, 1, timestamp)

        -- "/" で分割された各部分を1行に表示
        -- local result = "販売者: " .. timestamp .. "\nアイテム名: " .. parts[2] .. "\n個: " .. parts[3]
        local result = timestamp .. " Seller:" .. parts[2] .. "\n Item:" .. parts[3] .. " \n" .. parts[4] .. "\n個" -- 結果の表示

        logText = logText .. result .. "{nl}" -- ログテキストに追加
        -- print(logText)
        -- textview:SetFontName("white_16_ol")
    end

    textview:SetText(logText)
    textview:SetFontName("white_16_ol")
    -- textview_log:EnableResizeByText(1)
    textview:ShowWindow(1) -- フレーム内でのテキストビューを表示
    frame:ShowWindow(1)
    -- print("test")
end

function MARKET_SELLLIST_CLOSE(frame)
    frame:ShowWindow(0)
end

function MARKET_SELLLIST_CLEAR(frame)
    ui.SysMsg("The list of sold items has been cleared.")
    g.settings.selllist = {}
    MARKET_SELLLIST_save_settings()
    frame:ShowWindow(0)

end

function MARKET_SELLLIST_SOLD_ITEM_NOTICE(frame, msg, argStr, argNum)
    base["ON_SOLD_ITEM_NOTICE"](frame, msg, argStr, argNum)

    MARKET_SELLLIST_save_settings(argStr)

end

function MARKET_SELLLIST_save_settings(argStr)

    local time = os.date("*t")
    local year = time.year
    local month = time.month
    local day = time.day
    local hour = time.hour
    local min = time.min
    local timestamp = string.format("%04d.%02d.%02d-%02d:%02d", year, month, day, hour, min)

    -- CHAT_SYSTEM(tostring(argStr))
    -- CHAT_SYSTEM(tostring(timestamp))

    -- print(tostring(argStr))
    -- print(tostring(timestamp))

    local newtbl = {
        [tostring(timestamp)] = argStr
    }

    for k, v in pairs(newtbl) do
        g.settings.selllist[k] = v
        g.log.selllist[k] = v
    end

    acutil.saveJSON(g.settingsFileLoc, g.settings);
    acutil.saveJSON(g.logpath, g.log);

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

