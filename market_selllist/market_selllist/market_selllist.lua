-- v1.0.0 時間、販売者名、アイテム名、個数表示
-- v1.0.1 落ちてもログ保持する。textファイルにlog保持
-- v1.0.2 ログデリート機能修正。テーブルが空の場合フレームを開かない様に。
local addonName = "MARKET_SELLLIST"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.2"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.logpath = string.format('../addons/%s/log.text', addonNameLower)

local acutil = require("acutil")
local os = require("os")

local base = {}

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName];
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

if not g.settings then
    g.settings = {} -- もしg.settingsが存在しない場合、新しいテーブルを作成
end

function MARKET_SELLLIST_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    g.SetupHook(MARKET_SELLLIST_SOLD_ITEM_NOTICE, 'ON_SOLD_ITEM_NOTICE')

    acutil.setupEvent(addon, 'MARKET_CABINET_OPEN', "MARKET_SELLLIST_PRINT")

    MARKET_SELLLIST_LOAD_SETTINGS()

end

function MARKET_SELLLIST_PRINT(frame)

    if next(g.settings) == nil then
        -- g.settingsが空の場合の処理
        -- print("g.settingsは空です")
        return

    end

    local frame = ui.GetFrame("market_selllist")

    frame:SetSkinName("chat_window")
    frame:ShowTitleBar(0);
    frame:SetOffset(450, 30);
    frame:Resize(850, 975)
    frame:EnableHitTest(1)
    frame:SetLayerLevel(100);

    frame:SetEventScript(ui.LBUTTONUP, "MARKET_SELLLIST_CLOSE")

    local logdelete = frame:CreateOrGetControl("button", "logdelete", 750, 935, 30, 30)
    AUTO_CAST(logdelete)
    logdelete:SetTextTooltip("ログを削除します。{nl}Delete logs.")
    logdelete:SetText("Log Delete")
    logdelete:SetEventScript(ui.LBUTTONUP, "MARKET_SELLLIST_CLEAR")

    local close = frame:CreateOrGetControl("button", "close", 810, 10, 30, 30)
    AUTO_CAST(close)
    -- close:SetTextTooltip("ログを削除します。{nl}Delete logs.")
    close:SetText("×")
    close:SetEventScript(ui.LBUTTONUP, "MARKET_SELLLIST_CLOSE")

    local textview = frame:CreateOrGetControl("richtext", "textview", 10, 10, 820, 940)
    AUTO_CAST(textview)
    textview:SetTextTooltip("左クリックでフレームを閉じます。{nl}Left-click to close the frame.")
    textview:SetText("")

    local logText = "" -- テキストを組み立てる変数

    for _, dataString in ipairs(g.settings) do
        local parts = {}
        for part in string.gmatch(dataString, "([^/]+)") do
            table.insert(parts, part)
            -- print(tostring(part))
        end

        if #parts >= 4 then
            local timestamp = parts[1]
            local seller = parts[2]
            local item = parts[3]
            local quantity = parts[4]
            local result = timestamp .. " Seller:" .. seller .. "\n Item:" .. item .. "\n Quantity:" .. quantity

            logText = logText .. result .. "{nl}" -- ログテキストに追加
        end
    end

    textview:SetText(logText)
    textview:SetFontName("white_16_ol")

    textview:ShowWindow(1) -- フレーム内でのテキストビューを表示
    frame:ShowWindow(1)

end

function MARKET_SELLLIST_CLOSE(frame)
    frame:ShowWindow(0)
end

function MARKET_SELLLIST_CLEAR(frame)
    ui.SysMsg(
        "The list of sold items has been cleared.{nl}販売履歴を削除しました。logtextには残っています。")

    MARKET_SELLLIST_save_settings_clear()

end

function MARKET_SELLLIST_save_settings_clear()
    local frame = ui.GetFrame("market_selllist")
    g.settings = {}
    acutil.saveJSON(g.settingsFileLoc, g.settings);
    frame:ShowWindow(0)
end

-- testcode
local frame = ui.GetFrame("ingamealert")
local argStr = "パリパリの/@dicID_^*$ETC_20230130_071000$*^/4"
MARKET_SELLLIST_SOLD_ITEM_NOTICE(frame, msg, argStr, argNum)

function MARKET_SELLLIST_SOLD_ITEM_NOTICE(frame, msg, argStr, argNum)
    local ctrlset = INGAMEALERT_GET_ELEM_BY_TYPE(frame, "SoldItem")
    local argList = StringSplit(argStr, "/")
    if #argList ~= 3 then
        INGAMEALERT_REMOVE_ELEM_BY_OBJECT(ctrlset)
        INGAMEALERT_ALIGN_ELEM(frame)
        return
    end

    local text = GET_CHILD(ctrlset, "text")

    local askMsg = ScpArgMsg("SoldItemNotice", "SELLER", argList[1], "ITEM", argList[2], "COUNT", argList[3])
    text:SetText(askMsg)

    INGAMEALERT_RESIZE_ELEM(ctrlset)
    INGAMEALERT_SET_MARGIN_BY_CHAT_FRAME(frame)

    -- print(tostring(argList[1]))
    -- print(tostring(argList[3]))
    local data = argStr

    local pattern = "/(@dicID[^/]+)/" -- @dicIDから/までのパターンを検索
    local match = string.match(data, pattern) -- パターンに一致する部分を取得
    local str = dictionary.ReplaceDicIDInCompStr(match)
    if match then
        argStr = tostring(argList[1]) .. "/" .. tostring(str) .. "/" .. tostring(argList[3])
    end

    MARKET_SELLLIST_save_settings(argStr)
    -- base["ON_SOLD_ITEM_NOTICE"](frame, msg, argStr, argNum)

end

function MARKET_SELLLIST_save_settings(argStr)

    local time = os.date("*t")
    local year = time.year
    local month = time.month
    local day = time.day
    local hour = time.hour
    local min = time.min
    local sec = time.sec
    local timestamp = string.format("%04d.%02d.%02d-%02d:%02d:%02d", year, month, day, hour, min, sec)

    local entrystr = timestamp .. "/" .. argStr

    table.insert(g.settings, entrystr)

    acutil.saveJSON(g.settingsFileLoc, g.settings);

    local fd = io.open(g.logpath, "a")
    fd:write(entrystr .. "\n")
    fd:flush()
    fd:close()

    return

end

function MARKET_SELLLIST_LOAD_SETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if settings then

        g.settings = settings
        -- CHAT_SYSTEM("settings")
        -- MARKET_SELLLIST_PRINT_SELL_LIST()
    end

end

function MARKET_SELLLIST_PRINT_SELL_LIST()

    for _, entry in ipairs(g.settings) do
        print(entry)
    end

end
