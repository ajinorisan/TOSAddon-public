local addonName = "MARKET_VOUCHER"
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

    market_voucher_load_settings()

    addon:RegisterMsg("GAME_START", "market_voucher_init_frame")
    -- acutil.setupHook(market_voucher_CABINET_GET_ITEM, "CABINET_GET_ITEM")
    acutil.setupEvent(addon, "CABINET_GET_ITEM", "market_voucher_CABINET_GET_ITEM");
    g.SetupHook(market_voucher_CABINET_GET_ALL_LIST, "CABINET_GET_ALL_LIST");
end

function market_voucher_CABINET_GET_ALL_LIST(frame, control, strarg, now)
    -- g.settings = {}
    local frame = ui.GetFrame("market_cabinet")
    local itemGbox = GET_CHILD(frame, "itemGbox");
    local cnt = session.market.GetCabinetItemCount();

    for i = 0, cnt - 1 do
        local cabinetItem = session.market.GetCabinetItemByIndex(i);
        local itemID = cabinetItem:GetItemID();
        local itemObj = GetIES(cabinetItem:GetObject());
        -- local itemName = itemObj.ClassName

        local itemName = dictionary.ReplaceDicIDInCompStr(itemObj.Name)
        local registerTime = cabinetItem:GetRegSysTime()
        local sysTime = geTime.GetServerSystemTime();
        local difSec = imcTime.GetDifSec(sysTime, registerTime);
        local currentTime = os.time()
        local newTime = currentTime - difSec
        local newDate = os.date("%Y-%m-%d %H:%M:%S", newTime)
        local whereFrom = cabinetItem:GetWhereFrom();
        if whereFrom == "market_sell" then
            local count = 0;
            local amount = 0;
            local charName = nil;
            count = cabinetItem.sellItemAmount;
            amount = tonumber(cabinetItem:GetCount());
            local showcount = count
            local showamount = amount
            charName = GETMYPCNAME();

            --[[print(market_voucher_lang("Registered on.") .. newDate .. market_voucher_lang("/name.") .. charName ..
                      market_voucher_lang("/item.") .. itemName .. market_voucher_lang("/quantity.") .. tonumber(count) ..
                      market_voucher_lang("/unit price.") .. amount / tonumber(count) ..
                      market_voucher_lang("/total amount.") .. amount)]]

            local result =
                market_voucher_lang("Registered on.") .. newDate .. market_voucher_lang("/name.") .. charName ..
                    market_voucher_lang("/item.") .. itemName .. market_voucher_lang("/quantity.") .. tonumber(count) ..
                    market_voucher_lang("/unit price.") .. amount / tonumber(count) ..
                    market_voucher_lang("/total amount.") .. amount .. "/" ..
                    GET_COMMAED_STRING(amount / tonumber(count)) .. "/" .. GET_COMMAED_STRING(amount)
            table.insert(g.settings, result)
            local fd = io.open(g.logpath, "a")
            fd:write(result .. "\n")
            fd:flush()
            fd:close()
            market_voucher_save_settings()

        end
    end
    market_voucher_load_settings()
    base["CABINET_GET_ALL_LIST"](frame, control, strarg, now)
    -- CABINET_GET_ALL_LIST_OLD(frame, control, strarg, now)

end

function market_voucher_CABINET_GET_ITEM()
    local frame = ui.GetFrame("market_cabinet")
    local itemGbox = GET_CHILD(frame, "itemGbox");

    local cabinetItem = session.market.GetCabinetItemByIndex(0);
    local itemID = cabinetItem:GetItemID();

    local itemObj = GetIES(cabinetItem:GetObject());
    local itemName = dictionary.ReplaceDicIDInCompStr(itemObj.Name)

    local registerTime = cabinetItem:GetRegSysTime()

    local sysTime = geTime.GetServerSystemTime();

    local difSec = imcTime.GetDifSec(sysTime, registerTime);

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

        --[[print(market_voucher_lang("Registered on.") .. newDate .. market_voucher_lang("/name.") .. charName ..
                  market_voucher_lang("/item.") .. itemName .. market_voucher_lang("/quantity.") .. tonumber(count) ..
                  market_voucher_lang("/unit price.") .. amount / tonumber(count) ..
                  market_voucher_lang("/total amount.") .. amount)]]
        local result = market_voucher_lang("Registered on.") .. newDate .. market_voucher_lang("/name.") .. charName ..
                           market_voucher_lang("/item.") .. itemName .. market_voucher_lang("/quantity.") ..
                           tonumber(count) .. market_voucher_lang("/unit price.") .. amount / tonumber(count) ..
                           market_voucher_lang("/total amount.") .. amount .. "/" ..
                           GET_COMMAED_STRING(amount / tonumber(count)) .. "/" .. GET_COMMAED_STRING(amount)
        table.insert(g.settings, result)
        local fd = io.open(g.logpath, "a")
        fd:write(result .. "\n")
        fd:flush()
        fd:close()
        market_voucher_save_settings()
        market_voucher_load_settings()
    end

end

function market_voucher_lang(str)
    local langcode = option.GetCurrentCountry()
    if langcode == "Japanese" then
        if str == tostring("Registered on.") then
            str = "登録日時."
        end
        if str == tostring("/name.") then
            str = "/名前."
        end
        if str == tostring("/item.") then
            str = "/アイテム名."
        end
        if str == tostring("/quantity.") then
            str = "/数量."
        end
        if str == tostring("/unit price.") then
            str = "/単価."
        end
        if str == tostring("/total amount.") then
            str = "/合計金額."
        end

        if str == tostring("{ol}{#FF0000}Log Total Sales:") then
            str = "{ol}{#FF0000}表示売上合計:"
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
    -- logbtn:SetSkinName("tab2_btn_2")
    logbtn:SetText(market_voucher_lang("{ol}Sales Voucher"))
    logbtn:SetEventScript(ui.LBUTTONUP, "market_voucher_print")
    -- logbtn:SetEventScript(ui.LBUTTONUP, "market_voucher_CABINET_GET_ALL_LIST")
end

function market_voucher_print(frame, ctrl, argStr, argNum)
    local frame = ui.GetFrame("market_voucher")
    frame:SetSkinName("chat_window")
    frame:ShowTitleBar(0);
    frame:SetOffset(150, 30);
    frame:Resize(1200, 925)
    frame:EnableHitTest(1)
    frame:SetLayerLevel(100);

    local logdelete = frame:CreateOrGetControl("button", "logdelete", 1100, 885, 30, 30)
    AUTO_CAST(logdelete)
    logdelete:SetTextTooltip("ログを削除します。{nl}Delete logs.")
    logdelete:SetText(market_voucher_lang("{ol}Log Delete"))
    logdelete:SetEventScript(ui.LBUTTONUP, "market_voucher_clear")

    local close = frame:CreateOrGetControl("button", "close", 1165, 5, 30, 30)
    AUTO_CAST(close)
    -- close:SetTextTooltip("ログを削除します。{nl}Delete logs.")
    close:SetText("×")
    close:SetEventScript(ui.LBUTTONUP, "market_voucher_print_close")

    local textview = frame:CreateOrGetControl("richtext", "textview", 10, 10, 1150, 890)
    AUTO_CAST(textview)
    textview:SetTextTooltip("左クリックでフレームを閉じます。{nl}Left-click to close the frame.")

    textview:SetText("")
    textview:SetEventScript(ui.LBUTTONUP, "market_voucher_print_close")
    -- print(tostring(g.settings))
    local logText = "" -- テキストを組み立てる変数
    local sumtotal_amount = 0
    local total_amount_sum = 0
    g.sumtotal_amount = 0

    local total_amount_sum_eng = 0

    for _, dataString in pairs(g.settings) do
        local parts = {}
        for part in string.gmatch(dataString, "([^/]+)") do
            table.insert(parts, part)
            -- print(tostring(part))
        end
        -- if #parts >= 5 then
        local timestamp = parts[1]
        local seller = parts[2]
        local item = parts[3]
        local quantity = parts[4]
        local unit_price = parts[5]
        local total_amount = parts[6]
        local show_unit_price = parts[7]
        local show_total_amount = parts[8]

        local result = timestamp .. "  " .. seller .. "  " .. item .. "  " .. quantity .. "  " ..
                           market_voucher_lang("/unit price.") .. show_unit_price .. "  " ..
                           market_voucher_lang("/total amount.") .. show_total_amount

        logText = logText .. tostring(result) .. "{nl}" -- ログテキストに追加

        if string.find(total_amount, "合計金額.") ~= nil then
            total_amount_sum = total_amount:gsub("合計金額.", "")
            g.sumtotal_amount = g.sumtotal_amount + tonumber(total_amount_sum)

        elseif string.find(total_amount, "total amount.") ~= nil then

            total_amount_sum_eng = total_amount:gsub("total amount.", "")
            g.sumtotal_amount = g.sumtotal_amount + tonumber(total_amount_sum_eng)

        end
    end

    -- print(tostring(g.sumtotal_amount))
    local sumtotal_amount_text = frame:CreateOrGetControl("richtext", "sumtotal_amount_text", 800, 890, 100, 30)
    local roundedNumber = math.floor(g.sumtotal_amount / 100000)
    local roundednumber = round(roundedNumber)
    -- local roundedNumber = tonumber(string.format("%.0f", g.sumtotal_amount)) -- 3
    sumtotal_amount_text:SetText(market_voucher_lang("{ol}{#FF0000}Log Total Sales:") ..
                                     GET_COMMAED_STRING(g.sumtotal_amount) .. "(" .. roundednumber .. "M)")
    sumtotal_amount_text:ShowWindow(1)

    local logtextgsub = logText:gsub("%.", ":")
    textview:SetText(logtextgsub)
    textview:SetFontName("white_16_ol")

    textview:ShowWindow(1)
    frame:ShowWindow(1)

end

local function round(num)
    return math.floor(num + 0.5) * 0.1
end

function market_voucher_clear(frame)
    ui.SysMsg(
        "The list of sold items has been cleared.{nl}販売履歴を削除しました。logtextには残っています。")

    market_voucher_save_settings()
    market_voucher_load_settings()

end

function market_voucher_print_close(frame, ctrl, argStr, argNum)
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
