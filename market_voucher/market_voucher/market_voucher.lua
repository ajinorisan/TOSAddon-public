-- v1.0.1 ユラテブレスリリック ｰ 誅罰　とかの - の部分がバグ生んでたのを修正
-- v1.0.2 マーケットキャビネットフレームにボタンが表示されないバグ修正
-- v1.0.3 登録日時がバグってたのを修正
-- v1.0.4 色々修正。表示を時間降順に並べ替えたので実質クリアせんでもずっと使える。
-- v1.0.5 バグ修正。見た目修正
-- v1.0.6 バグ修正。logtextが長すぎると、文字列が取得出来無さそう。
-- v1.0.7 韓国語クライアントでも動く様になったハズ。知らんけど。
-- v1.0.8 テキストを上手に格納できずに表示が追いつかずにバグってたのを修正。
local addonName = "MARKET_VOUCHER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.8"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.logpath = string.format('../addons/%s/log.txt', addonNameLower)

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

function MARKET_VOUCHER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    -- addon:RegisterMsg("GAME_START", "market_voucher_init_frame")

    -- acutil.setupHook(market_voucher_CABINET_ITEM_BUY, "_CABINET_ITEM_BUY")
    acutil.setupEvent(addon, "MARKET_CABINET_MODE", "market_voucher_MARKET_CABINET_MODE");
    -- acutil.setupEvent(addon, "MARKET_CLOSE", "market_voucher_print_close");
    -- acutil.setupHook(market_voucher_CABINET_GET_ALL_LIST, "CABINET_GET_ALL_LIST")
    g.SetupHook(market_voucher_CABINET_GET_ALL_LIST, "CABINET_GET_ALL_LIST");
    market_voucher_init_frame()
    market_voucher_load_settings()

end

function market_voucher_MARKET_CABINET_MODE(frame)
    ReserveScript("market_voucher_detail_item()", 0.3)

end

function market_voucher_detail_item()
    local frame = ui.GetFrame("market_cabinet")
    local itemGbox = GET_CHILD_RECURSIVELY(frame, "itemGbox");
    local itemlist = GET_CHILD(itemGbox, "itemlist");
    local bg = GET_CHILD(itemlist, "_BG");

    for i = 0, 99 do

        local detail_item = GET_CHILD(bg, "DETAIL_ITEM_" .. i .. "_0")

        if detail_item ~= nil then

            local btn = GET_CHILD(detail_item, "btn")
            local etcBox = GET_CHILD(detail_item, "etcBox")
            btn:ShowWindow(0)
            etcBox:ShowWindow(0)
        else
            break
        end
    end
end

function market_voucher_CABINET_GET_ALL_LIST(frame, control, strarg, now)

    local frame = ui.GetFrame("market_cabinet")
    local itemGbox = GET_CHILD(frame, "itemGbox");
    local cnt = session.market.GetCabinetItemCount();
    -- print(tostring(cnt))
    for i = 0, cnt - 1 do
        local cabinetItem = session.market.GetCabinetItemByIndex(i);
        local whereFrom = cabinetItem:GetWhereFrom();
        -- print(tostring(whereFrom))
        if whereFrom == "market_sell" then -- 

            local itemID = cabinetItem:GetItemID();

            local itemObj = GetIES(cabinetItem:GetObject());
            local itemCls = GetClassByType("Item", itemObj.ClassID);
            local itemName = TryGetProp(itemCls, "Name");

            -- local itemName = itemObj.ClassName
            local langCode = option.GetCurrentCountry()
            -- if (option.GetCurrentCountry() == "Japanese") then
            if langCode ~= "Korean" then

                itemName = dictionary.ReplaceDicIDInCompStr(itemObj.Name)

            end
            -- print(tostring(itemName))
            local itemnamegsub = string.gsub(itemName, "-", "?")
            local registerTime = cabinetItem:GetRegSysTime()
            local year = string.format("%04d", registerTime.wYear)
            local month = string.format("%02d", registerTime.wMonth)
            local day = string.format("%02d", registerTime.wDay)
            local hour = string.format("%02d", registerTime.wHour)
            local minute = string.format("%02d", registerTime.wMinute)
            local second = string.format("%02d", registerTime.wSecond)

            local formattedTime = string.format("%s-%s-%s %s:%s:%s", year, month, day, hour, minute, second)

            local count = 0;
            local amount = 0;
            local charName = nil;
            count = cabinetItem.sellItemAmount;
            amount = tonumber(cabinetItem:GetCount());
            local showcount = count
            local showamount = amount
            charName = GETMYPCNAME();

            local result = market_voucher_lang("time of sale:") .. formattedTime .. market_voucher_lang("/name:") ..
                               charName .. market_voucher_lang("/item:") .. itemnamegsub ..
                               market_voucher_lang("/quantity:") .. tonumber(count) .. "/" .. amount / tonumber(count) ..
                               "/" .. amount .. market_voucher_lang("/unit price:") ..
                               GET_COMMAED_STRING(amount / tonumber(count)) .. market_voucher_lang("/total amount:") ..
                               GET_COMMAED_STRING(amount)
            -- print(tostring(result))
            table.insert(g.settings, result)
            local fd = io.open(g.logpath, "a")
            fd:write(result .. "\n")
            fd:flush()
            fd:close()

        end
    end
    market_voucher_save_settings()
    market_voucher_load_settings()
    -- table.remove(g.settings)
    base["CABINET_GET_ALL_LIST"](frame, control, strarg, now)
    -- CABINET_GET_ALL_LIST_OLD(frame, control, strarg, now)

end
-- g.settings = {}
-- market_voucher_save_settings()

function market_voucher_lang(str)
    local langcode = option.GetCurrentCountry()
    if langcode == "Japanese" then
        if str == tostring("time of sale:") then
            str = "販売日時:"
        end
        if str == tostring("/name:") then
            str = "/名前:"
        end
        if str == tostring("/item:") then
            str = "/アイテム名:"
        end
        if str == tostring("/quantity:") then
            str = "/数量:"
        end
        if str == tostring("/unit price:") then
            str = "/単価:"
        end
        if str == tostring("/total amount:") then
            str = "/合計金額:"
        end

        if str == tostring("{ol}{#FF0000}Total Sales:") then
            str = "{ol}{#FF0000}売上合計:"
        end
        if str == tostring("{ol}Period:") then
            str = "{ol}集計期間:"
        end

        if str == tostring("{ol}Sales Voucher") then
            str = "{ol}売上伝票"
        end
        if str == tostring("{ol}Log Delete") then
            str = "{ol}ログ削除"
        end

    end
    return str
end
function market_voucher_save_settings(result)
    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function market_voucher_init_frame()
    local frame = ui.GetFrame("market_cabinet")
    local logbtn = frame:CreateOrGetControl("button", "log", 810, 105, 200, 45)

    logbtn:SetText(market_voucher_lang("{ol}Sales Voucher"))
    logbtn:SetEventScript(ui.LBUTTONUP, "market_voucher_print")
    logbtn:ShowWindow(1)

end

function market_voucher_print(frame, ctrl, argStr, argNum)
    local frame = ui.GetFrame("market_voucher")
    frame:SetSkinName("downbox")
    frame:ShowTitleBar(0);
    frame:SetOffset(15, 175);
    frame:Resize(1220, 770)
    frame:EnableHitTest(1)
    frame:SetLayerLevel(100);

    local bg = frame:CreateOrGetControl("groupbox", "bg", 5, 5, 1210, 720)
    AUTO_CAST(bg)
    bg:SetSkinName("chat_window")
    bg:SetTextTooltip("左クリックでフレームを閉じます。{nl}Left-click to close the frame.")
    bg:SetEventScript(ui.LBUTTONUP, "market_voucher_print_close")

    local logdelete = frame:CreateOrGetControl("button", "logdelete", 1130, 730, 80, 30)
    AUTO_CAST(logdelete)
    logdelete:SetTextTooltip("ログを削除します。{nl}Delete logs.")
    logdelete:SetText(market_voucher_lang("{ol}Log Delete"))
    logdelete:SetEventScript(ui.LBUTTONUP, "market_voucher_clear")

    local close = frame:CreateOrGetControl("button", "close", 1185, 5, 30, 30)
    AUTO_CAST(close)
    -- close:SetTextTooltip("ログを削除します。{nl}Delete logs.")
    close:SetText("×")
    close:SetEventScript(ui.LBUTTONUP, "market_voucher_print_close")

    g.sumtotal_amount = 0

    local total_amount_sum_eng = 0

    table.sort(g.settings, function(a, b)
        local tokenA = StringSplit(a, '/')
        local tokenB = StringSplit(b, '/')
        local dateA = tokenA[1]
        local dateB = tokenB[1]
        -- dateA と dateB を比較して降順に並び替えるロジック
        return dateA > dateB
    end)

    -- printTable(g.settings)
    -- 
    -- textview:SetText(tostring(logText))

    local count = #g.settings

    local startdate = ""
    local enddate = ""

    local logEntries = {} -- 新しいテーブルを用意
    local x = 5
    for i = 1, count do
        local token = StringSplit(g.settings[i], '/')
        if i == 1 then
            local originalString = token[1]
            local startIndex = string.find(originalString, ":") + 1 -- ":"の次の位置を取得
            local endIndex = startIndex + 10 -- ":"の次から10文字分を取得
            startdate = string.sub(originalString, startIndex, endIndex)
        end

        if i == #g.settings then
            local originalString = token[1]
            local startIndex = string.find(originalString, ":") + 1 -- ":"の次の位置を取得
            local endIndex = startIndex + 10 -- ":"の次から10文字分を取得
            enddate = string.sub(originalString, startIndex, endIndex)
        end

        local entry = {
            date = "{ol}" .. token[1],
            name = "{ol}" .. token[2],
            item = "{ol}" .. (string.find(token[3], "?") ~= nil and string.gsub(token[3], "?", "-") or token[3]),
            quantity = "{ol}" .. token[4],
            show_unit_price = "{ol}" .. token[7],
            show_total_amount = "{ol}" .. token[8]
        }
        table.insert(logEntries, entry) -- 新しいテーブルに要素を追加

        local unit_price = token[5]
        local total_amount = token[6]
        g.sumtotal_amount = g.sumtotal_amount + tonumber(total_amount)

        local logText = bg:CreateOrGetControl("richtext", "logtext" .. i, 1190, 20)

        for _, entry in ipairs(logEntries) do
            logText = entry.date .. " , " .. entry.name .. " , " .. entry.item .. " , " .. entry.quantity .. " , " ..
                          entry.show_unit_price .. " , " .. entry.show_total_amount
        end
        local textview = bg:CreateOrGetControl("richtext", "textview" .. i, 5, x)
        AUTO_CAST(textview)
        textview:SetText(logText)
        x = x + 20
    end

    local sumtotal_amount_text = frame:CreateOrGetControl("richtext", "sumtotal_amount_text", 880, 740, 100, 30)
    local roundednumber = market_voucher_round(g.sumtotal_amount / 1000000)

    sumtotal_amount_text:SetText(market_voucher_lang("{ol}{#FF0000}Total Sales:") ..
                                     GET_COMMAED_STRING(g.sumtotal_amount) .. "(" .. roundednumber .. "M)")
    sumtotal_amount_text:ShowWindow(1)

    local date_text = frame:CreateOrGetControl("richtext", "date_text", 600, 740, 100, 30)
    date_text:SetText(market_voucher_lang("{ol}Period:") .. enddate .. "～" .. startdate)

    frame:ShowWindow(1)
    frame:RunUpdateScript("market_voucher_auto_close", 0.5);

    -- textview:ShowWindow(1)
    -- market_voucher_set_textview(textview, logText)
end

--[[function market_voucher_print(frame, ctrl, argStr, argNum)
    local frame = ui.GetFrame("market_voucher")
    frame:SetSkinName("downbox")
    frame:ShowTitleBar(0);
    frame:SetOffset(15, 175);
    frame:Resize(1220, 770)
    frame:EnableHitTest(1)
    frame:SetLayerLevel(100);

    local bg = frame:CreateOrGetControl("groupbox", "bg", 5, 5, 1210, 720)
    AUTO_CAST(bg)
    bg:SetSkinName("chat_window")

    local logdelete = frame:CreateOrGetControl("button", "logdelete", 1130, 730, 80, 30)
    AUTO_CAST(logdelete)
    logdelete:SetTextTooltip("ログを削除します。{nl}Delete logs.")
    logdelete:SetText(market_voucher_lang("{ol}Log Delete"))
    logdelete:SetEventScript(ui.LBUTTONUP, "market_voucher_clear")

    local close = frame:CreateOrGetControl("button", "close", 1185, 5, 30, 30)
    AUTO_CAST(close)
    -- close:SetTextTooltip("ログを削除します。{nl}Delete logs.")
    close:SetText("×")
    close:SetEventScript(ui.LBUTTONUP, "market_voucher_print_close")

    g.sumtotal_amount = 0

    local total_amount_sum_eng = 0

    table.sort(g.settings, function(a, b)
        local tokenA = StringSplit(a, '/')
        local tokenB = StringSplit(b, '/')
        local dateA = tokenA[1]
        local dateB = tokenB[1]
        -- dateA と dateB を比較して降順に並び替えるロジック
        return dateA > dateB
    end)

    -- printTable(g.settings)
    local textview = bg:CreateOrGetControl("richtext", "textview", 5, 5, 1210, 3000)
    AUTO_CAST(textview)
    textview:SetTextTooltip("左クリックでフレームを閉じます。{nl}Left-click to close the frame.")

    textview:SetText("")
    textview:SetEventScript(ui.LBUTTONUP, "market_voucher_print_close")
    -- textview:SetText(tostring(logText))

    local count = #g.settings

    local logText = ""

    local startdate = ""
    local enddate = ""

    for i = 1, count do
        local token = StringSplit(g.settings[i], '/')
        if i == 1 then
            local originalString = token[1]
            local startIndex = string.find(originalString, ":") + 1 -- ":"の次の位置を取得
            local endIndex = startIndex + 10 -- ":"の次から10文字分を取得
            startdate = string.sub(originalString, startIndex, endIndex)
        end

        if i == #g.settings then
            local originalString = token[1]
            local startIndex = string.find(originalString, ":") + 1 -- ":"の次の位置を取得
            local endIndex = startIndex + 10 -- ":"の次から10文字分を取得
            enddate = string.sub(originalString, startIndex, endIndex)
        end

        local date = "{ol}" .. token[1]
        local name = "{ol}" .. token[2]
        local item = "{ol}" .. token[3]
        if string.find(item, "?") ~= nil then
            -- item = "{ol}" .. item:gsub("?", "-")
            item = string.gsub(item, "?", "-")
        end
        local quantity = "{ol}" .. token[4]
        local unit_price = token[5]
        local total_amount = token[6]
        local show_unit_price = "{ol}" .. token[7]
        local show_total_amount = "{ol}" .. token[8]

        logText = tostring(logText) .. date .. " , " .. name .. " , " .. item .. " , " .. quantity .. " , " ..
                      show_unit_price .. " , " .. show_total_amount .. "{nl}"
        textview:SetText(logText)
        g.sumtotal_amount = g.sumtotal_amount + tonumber(total_amount)
        print(tostring(logText))
    end
    print(tostring(logText))
    -- print(tostring(startdate))
    -- print(tostring(enddate))
    -- market_voucher_frame_init(frame)

    local sumtotal_amount_text = frame:CreateOrGetControl("richtext", "sumtotal_amount_text", 880, 740, 100, 30)
    local roundednumber = market_voucher_round(g.sumtotal_amount / 1000000)

    sumtotal_amount_text:SetText(market_voucher_lang("{ol}{#FF0000}Total Sales:") ..
                                     GET_COMMAED_STRING(g.sumtotal_amount) .. "(" .. roundednumber .. "M)")
    sumtotal_amount_text:ShowWindow(1)

    local date_text = frame:CreateOrGetControl("richtext", "date_text", 600, 740, 100, 30)
    date_text:SetText(market_voucher_lang("{ol}Period:") .. enddate .. "～" .. startdate)

    frame:ShowWindow(1)
    frame:RunUpdateScript("market_voucher_auto_close", 0.5);

    textview:ShowWindow(1)
    -- market_voucher_set_textview(textview, logText)
end]]

function market_voucher_auto_close(frame)
    local marketframe = ui.GetFrame("market_cabinet")
    if marketframe:IsVisible() == 1 then
        -- CHAT_SYSTEM("1")

        return 1
    else
        frame:ShowWindow(0)
        return 0
    end

end

--[[function printTable(table, indent)
    indent = indent or 0
    for k, v in pairs(table) do
        if type(v) == "table" then
            print(string.rep("  ", indent) .. k .. ":")
            printTable(v, indent + 1)
        else
            print(string.rep("  ", indent) .. k .. ": " .. tostring(v))
        end
    end
end]]

--[[function market_voucher_set_textview(textview, logText)
    -- print(tostring(logText))
    textview:SetText(logText)
    textview:SetFontName("white_16_ol")

    textview:ShowWindow(1)
end]]
function market_voucher_round(number)
    return math.floor(number + 0.5)
end

function market_voucher_clear(frame)
    g.settings = {}
    ui.SysMsg(
        "The list of sold items has been cleared.{nl}販売履歴を削除しました。logtextには残っています。")

    market_voucher_save_settings()
    market_voucher_load_settings()
    frame:ShowWindow(0)

end

function market_voucher_print_close(frame, ctrl, argStr, argNum)
    local frame = ui.GetFrame("market_voucher")
    frame:RemoveAllChild()
    frame:ShowWindow(0)
    return
end

function market_voucher_load_settings()
    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if settings then

        g.settings = settings

    end

end

--[[function market_voucher_CABINET_ITEM_BUY(frame, ctrl, guid)
    -- market.ReqGetCabinetItem(guid);
    -- g.settings = {}
    print(tostring(ctrl:GetName()))
    --  Close popup
    local popUp_frame = ui.GetFrame("market_cabinet_popup")
    if popUp_frame ~= nil then
        ui.CloseFrame("market_cabinet_popup")
    end

    local frame = ui.GetFrame("market_cabinet")
    local itemGbox = GET_CHILD(frame, "itemGbox");

    -- local itemID = cabinetItem:GetItemID();

    -- local itemObj = GetIES(cabinetItem:GetObject());
    -- local itemName = dictionary.ReplaceDicIDInCompStr(guid.Name)
    local itemName = guid.ClassName
    print(tostring(itemName))
    local registerTime = cabinetItem:GetRegSysTime()
    print(tostring(registerTime))
    -- local sysTime = geTime.GetServerSystemTime();

    local difSec = imcTime.GetDifSec(sysTime, registerTime);
    print(tostring(difSec))
    local currentTime = os.time()
    local newTime = currentTime - difSec
    local newDate = os.date("%Y-%m-%d %H:%M:%S", newTime)

    local whereFrom = cabinetItem:GetWhereFrom();

    local count = 0;
    local amount = 0;
    local charName = nil;
    amount = cabinetItem.sellItemAmount;
    count = tonumber(cabinetItem:GetCount());
    charName = GETMYPCNAME();

    if whereFrom == "market_sell" then
        local count = 0;
        local amount = 0;
        local charName = nil;
        count = cabinetItem.sellItemAmount;
        amount = tonumber(cabinetItem:GetCount());
        charName = GETMYPCNAME();

       print(market_voucher_lang("Registered on.") .. newDate .. market_voucher_lang("/name.") .. charName ..
                  market_voucher_lang("/item.") .. itemName .. market_voucher_lang("/quantity.") .. tonumber(count) ..
                  market_voucher_lang("/unit price.") .. amount / tonumber(count) ..
                  market_voucher_lang("/total amount.") .. amount)
        print("test")
        local result = market_voucher_lang("Registered on.") .. newDate .. market_voucher_lang("/name.") .. charName ..
                           market_voucher_lang("/item.") .. itemName .. market_voucher_lang("/quantity.") ..
                           tonumber(count) .. market_voucher_lang("/unit price.") .. amount / tonumber(count) ..
                           market_voucher_lang("/total amount.") .. amount .. "/" ..
                           GET_COMMAED_STRING(amount / tonumber(count)) .. "/" .. GET_COMMAED_STRING(amount)
        print(tostring(result))
        table.insert(g.settings, result)
        local fd = io.open(g.logpath, "a")
        fd:write(result .. "\n")
        fd:flush()
        fd:close()
        market_voucher_save_settings()
        market_voucher_load_settings()
    end

end]]
