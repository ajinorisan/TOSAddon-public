-- v1.0.1 ユラテブレスリリック ｰ 誅罰　とかの - の部分がバグ生んでたのを修正
-- v1.0.2 マーケットキャビネットフレームにボタンが表示されないバグ修正
-- v1.0.3 登録日時がバグってたのを修正
-- v1.0.4 色々修正。表示を時間降順に並べ替えたので実質クリアせんでもずっと使える。
-- v1.0.5 バグ修正。見た目修正
-- v1.0.6 バグ修正。logtextが長すぎると、文字列が取得出来無さそう。
-- v1.0.7 韓国語クライアントでも動く様になったハズ。知らんけど。
-- v1.0.8 テキストを上手に格納できずに表示が追いつかずにバグってたのを修正。
-- v1.0.9 ローディング最適化
local addon_name = "MARKET_VOUCHER"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.0.9"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addon_name_lower)
g.logpath = string.format('../addons/%s/log.txt', addon_name_lower)

local json = require("json")

function g.mkdir_new_folder()
    local function create_folder(folder_path, file_path)
        local file = io.open(file_path, "r")
        if not file then
            os.execute('mkdir "' .. folder_path .. '"')
            file = io.open(file_path, "w")
            if file then
                file:write("A new file has been created")
                file:close()
            end
        else
            file:close()
        end
    end

    local folder = string.format("../addons/%s", addon_name_lower)
    local file_path = string.format("../addons/%s/mkdir.txt", addon_name_lower)
    create_folder(folder, file_path)

    g.active_id = session.loginInfo.GetAID()
    local user_folder = string.format("../addons/%s/%s", addon_name_lower, g.active_id)
    local user_file_path = string.format("../addons/%s/%s/mkdir.txt", addon_name_lower, g.active_id)
    create_folder(user_folder, user_file_path)

    g.settings_path = string.format("../addons/%s/%s/settings.json", addon_name_lower, g.active_id)

    local new_settings_file_check = io.open(g.settings_path, "r")
    if not new_settings_file_check then
        local old_file = io.open(g.settingsFileLoc, "rb") -- バイナリモードで開くのが安全
        if old_file then
            local content = old_file:read("*all")
            old_file:close()

            local new_file = io.open(g.settings_path, "wb") -- バイナリモードで書き込む
            if new_file then
                new_file:write(content)
                new_file:close()

                -- os.remove(old_settings_path_local) -- 削除する場合はこれ
            end

        end
    else
        new_settings_file_check:close()
    end
end
g.mkdir_new_folder()

function g.save_json(path, tbl)
    local file = io.open(path, "w")
    if file then
        local str = json.encode(tbl)
        file:write(str)
        file:close()
    end
end

function g.load_json(path)
    local file = io.open(path, "r")
    if not file then
        return nil, "Error opening file: " .. path
    end

    local content = file:read("*all")
    file:close()

    if not content or content == "" then
        return nil, "File content is empty or could not be read: " .. path
    end

    local decoded_table, decode_err = json.decode(content)

    if not decoded_table then
        return nil, decode_err
    end

    return decoded_table, nil
end

function g.setup_hook_and_event(my_addon, origin_func_name, my_func_name, bool)

    g.FUNCS = g.FUNCS or {}
    if not g.FUNCS[origin_func_name] then
        g.FUNCS[origin_func_name] = _G[origin_func_name]
    end

    local origin_func = g.FUNCS[origin_func_name]

    local function hooked_function(...)

        local original_results

        if bool == true then
            original_results = {origin_func(...)}
        end

        g.ARGS = g.ARGS or {}
        g.ARGS[origin_func_name] = {...}
        imcAddOn.BroadMsg(origin_func_name)

        if original_results then
            return table.unpack(original_results)
        else
            return
        end
    end

    _G[origin_func_name] = hooked_function

    if not g.REGISTER[origin_func_name .. my_func_name] then -- g.REGISTERはON_INIT内で都度初期化
        g.REGISTER[origin_func_name .. my_func_name] = true
        my_addon:RegisterMsg(origin_func_name, my_func_name)
    end
end

function g.get_event_args(origin_func_name)
    local args = g.ARGS[origin_func_name]
    if args then
        return table.unpack(args)
    end
    return nil
end

g.translations = {
    Japanese = {
        ["time of sale:"] = "販売日時:",
        ["/name:"] = "/名前:",
        ["/item:"] = "/アイテム名:",
        ["/quantity:"] = "/数量:",
        ["/unit price:"] = "/単価:",
        ["/total amount:"] = "/合計金額:",
        ["Total Sales:"] = "売上合計:",
        ["Period:"] = "集計期間:",
        ["Sales Slip"] = "売上伝票",
        ["Clear Log"] = "ログ削除",
        ["ClearedMsg"] = "販売履歴を削除しました。logtextには残っています。",
        ["CloseFrameTooltip"] = "左クリックでフレームを閉じます。",
        ["ClearLogTooltip"] = "販売履歴を削除します"
    },
    -- Default/English strings (Corrected)
    Default = {
        ["time of sale:"] = "time of sale:",
        ["/name:"] = "/name:",
        ["/item:"] = "/item:",
        ["/quantity:"] = "/quantity:",
        ["/unit price:"] = "/unit price:",
        ["/total amount:"] = "/total amount:",
        ["Total Sales:"] = "Total Sales:",
        ["Period:"] = "Period:",
        ["Sales Slip"] = "Sales Slip",
        ["Clear Log"] = "Clear Log",
        ["ClearedMsg"] = "The sales history has been deleted. It remains in the log text.",
        ["CloseFrameTooltip"] = "Left-click to close the frame.",
        ["ClearLogTooltip"] = "Clear the sales history"
    }
}

function g.lang_trans(key)
    local lang_code = option.GetCurrentCountry()

    if g.translations[lang_code] and g.translations[lang_code][key] then
        return g.translations[lang_code][key]
    end
    return g.translations.Default[key] or key
end

function g.ui_text(key)

    return "{ol}" .. g.lang_trans(key)
end

function market_voucher_save_settings()
    g.save_json(g.settings_path, g.settings)
end

function market_voucherload_settings()
    local settings, err = g.load_json(g.settings_path)
    if not settings then
        settings = {}
    end
    g.settings = settings
    g.save_settings()
end

function market_voucher__BUY_MARKET_ITEM(my_frame, my_msg)

    local row, isRecipeSearchBox = g.get_event_args(my_msg)
    local frame = ui.GetFrame("market");

    local totalPrice = 0;
    market.ClearBuyInfo();

    local marketItem = nil
    local buyCount = nil
    if isRecipeSearchBox ~= nil and isRecipeSearchBox == 1 then
        local itemlist = GET_CHILD_RECURSIVELY(frame, "recipeSearchGbox")
        local child = itemlist:GetChildByIndex(row - 1);
        local editCount = GET_CHILD_RECURSIVELY(child, "count")
        if editCount == nil then
            marketItem = session.market.GetRecipeSearchByIndex(row - 1);
            market.AddBuyInfo(marketItem:GetMarketGuid(), 1);
            totalPrice = SumForBigNumber(totalPrice, marketItem:GetSellPrice());
        else
            buyCount = editCount:GetText()
            if tonumber(buyCount) > 0 then
                marketItem = session.market.GetRecipeSearchByIndex(row - 1);
                market.AddBuyInfo(marketItem:GetMarketGuid(), buyCount);
                totalPrice = SumForBigNumber(totalPrice, math.mul_int_for_lua(buyCount, marketItem:GetSellPrice()));
            else
                ui.SysMsg(ScpArgMsg("YouCantBuyZeroItem"));
            end
        end
    else
        local itemlist = GET_CHILD_RECURSIVELY(frame, "itemListGbox");
        local child = itemlist:GetChildByIndex(row - 1);
        if child == nil then
            marketItem = session.market.GetItemByIndex(row - 1);
            market.AddBuyInfo(marketItem:GetMarketGuid(), 1);
            totalPrice = SumForBigNumber(totalPrice, marketItem:GetSellPrice());
        else
            local editCount = GET_CHILD_RECURSIVELY(child, "count")
            buyCount = 1;
            if editCount ~= nil then
                buyCount = editCount:GetText()
            end

            if tonumber(buyCount) > 0 then
                marketItem = session.market.GetItemByIndex(row - 1);
                market.AddBuyInfo(marketItem:GetMarketGuid(), buyCount);
                totalPrice = SumForBigNumber(totalPrice, math.mul_int_for_lua(buyCount, marketItem:GetSellPrice()));
            else
                ui.SysMsg(ScpArgMsg("YouCantBuyZeroItem"));
            end
        end
    end

    if totalPrice == 0 then
        return;
    end

    if IsGreaterThanForBigNumber(totalPrice, GET_TOTAL_MONEY_STR()) == 1 then
        ui.SysMsg(ClMsg("NotEnoughMoney"));
        return;
    end

    local limitTradeStr = GET_REMAIN_MARKET_TRADE_AMOUNT_STR();
    if limitTradeStr ~= nil then
        if IsGreaterThanForBigNumber(totalPrice, limitTradeStr) == 1 then
            ui.SysMsg(ScpArgMsg('MarketMaxSilverLimit{LIMIT}Over', 'LIMIT', GET_COMMAED_STRING(limitTradeStr)));
            return;
        end
    end

    local my_char_name = GETMYPCNAME()

    local item_obj = GetIES(marketItem:GetObject())

    local item_name = dictionary.ReplaceDicIDInCompStr(item_obj.Name)

    local sanitized_item_name = string.gsub(item_name, "-", "?")
    local time = geTime.GetServerSystemTime()
    print(tostring(reg_time))
    local formatted_time = string.format("%04d-%02d-%02d %02d:%02d:%02d", time.wYear, time.wMonth, time.wDay,
        time.wHour, time.wMinute, time.wSecond)
    print(tostring(formatted_time))
    local quantity = tonumber(buyCount)
    print(tostring(quantity))
    local total_amount = tonumber(totalPrice)
    print(tostring(total_amount))
    local unit_price = 0
    if quantity > 0 then
        unit_price = total_amount / quantity
    end
    print(tostring(unit_price))
    local results_table = {}
    local result_string = string.format("%s/%s/%s/%d/%d/%d/%s", formatted_time, my_char_name, sanitized_item_name,
        quantity, unit_price, total_amount, "buy")
    table.insert(results_table, result_string)
    if #results_table > 0 then
        table.insert(g.settings, table.unpack(results_table))
        local all_results = table.concat(results_table, "\n")
        local file_handle = io.open(g.logpath, "a")
        if file_handle then
            file_handle:write(all_results .. "\n")
            file_handle:close()
        end
        market_voucher_save_settings()
    end

    market.ReqBuyItems();
end

function MARKET_VOUCHER_ON_INIT(addon, frame)

    local start_time = os.clock() -- ★処理開始前の時刻を記録★
    g.addon = addon
    g.frame = frame

    g.REGISTER = {}
    g.setup_hook_and_event(addon, "CABINET_GET_ALL_LIST", "market_voucher_CABINET_GET_ALL_LIST", false)

    g.setup_hook_and_event(addon, "_BUY_MARKET_ITEM", "market_voucher__BUY_MARKET_ITEM", false)

    addon:RegisterMsg("CABINET_ITEM_LIST", "market_voucher_init_frame");
    if not g.settings then
        market_voucherload_settings()
    end
    local end_time = os.clock() -- ★処理終了後の時刻を記録★
    local elapsed_time = end_time - start_time
    -- CHAT_SYSTEM(string.format("%s: %.4f seconds", addon_name, elapsed_time))
end

function market_voucher_CABINET_GET_ALL_LIST(my_frame, my_msg)
    local frame, control, strarg, now = g.get_event_args(my_msg)
    frame = ui.GetFrame("market_cabinet")

    local item_count = session.market.GetCabinetItemCount()
    if item_count == 0 then
        return
    end

    local my_char_name = GETMYPCNAME()
    local results_table = {}

    for i = 0, item_count - 1 do
        local cabinet_item = session.market.GetCabinetItemByIndex(i)
        if not cabinet_item then
            goto continue
        end

        local where_from = cabinet_item:GetWhereFrom()

        if where_from == "market_sell" then
            local item_obj = GetIES(cabinet_item:GetObject())
            local item_name = dictionary.ReplaceDicIDInCompStr(item_obj.Name)
            local sanitized_item_name = string.gsub(item_name, "-", "?")
            local reg_time = cabinet_item:GetRegSysTime()
            local formatted_time = string.format("%04d-%02d-%02d %02d:%02d:%02d", reg_time.wYear, reg_time.wMonth,
                reg_time.wDay, reg_time.wHour, reg_time.wMinute, reg_time.wSecond)

            local quantity = tonumber(cabinet_item.sellItemAmount)
            local total_amount = tonumber(cabinet_item:GetCount())

            local unit_price = 0
            if quantity > 0 then
                unit_price = total_amount / quantity
            end

            local result_string = string.format("%s/%s/%s/%d/%d/%d", formatted_time, my_char_name, sanitized_item_name,
                quantity, unit_price, total_amount)
            table.insert(results_table, result_string)
        end

        ::continue::
    end

    if #results_table > 0 then
        table.insert(g.settings, table.unpack(results_table))
        local all_results = table.concat(results_table, "\n")
        local file_handle = io.open(g.logpath, "a")
        if file_handle then
            file_handle:write(all_results .. "\n")
            file_handle:close()
        end
        market_voucher_save_settings()
    end

    g.FUNCS["CABINET_GET_ALL_LIST"](frame, control, strarg, now)
end

function market_voucher_round(number)
    return math.floor(number + 0.5)
end

function market_voucher_print(frame, ctrl, arg_str, arg_num)

    local frame = ui.GetFrame("market_voucher")
    frame:SetSkinName("downbox")
    frame:ShowTitleBar(0)
    frame:SetOffset(15, 175)
    frame:Resize(1280, 770)
    frame:EnableHitTest(1)
    frame:SetLayerLevel(100)

    local bg = frame:CreateOrGetControl("groupbox", "bg", 5, 5, 1270, 720)
    AUTO_CAST(bg)
    bg:SetSkinName("chat_window")
    bg:SetTextTooltip(g.ui_text("CloseFrameTooltip"))
    bg:SetEventScript(ui.LBUTTONUP, "market_voucher_print_close")

    local log_delete_button = frame:CreateOrGetControl("button", "logdelete", 1180, 735, 80, 30)
    AUTO_CAST(log_delete_button)
    log_delete_button:SetTextTooltip(g.ui_text("ClearLogTooltip"))
    log_delete_button:SetText(g.ui_text("Clear Log"))
    log_delete_button:SetEventScript(ui.LBUTTONUP, "market_voucher_clear")

    local close_button = frame:CreateOrGetControl("button", "close", 1245, 0, 30, 30)
    AUTO_CAST(close_button)
    close_button:SetImage("testclose_button")
    -- close_button:SetGravity(ui.RIGHT, ui.TOP)
    -- close_button:SetText("×")
    close_button:SetEventScript(ui.LBUTTONUP, "market_voucher_print_close")

    local sumtotal_amount = 0

    if #g.settings == 0 then
        frame:ShowWindow(1)
        frame:RunUpdateScript("market_voucher_auto_close", 0.1)
        return -- 表示するログがない場合はここで終了
    end

    table.sort(g.settings, function(a, b)
        -- 日付文字列 (YYYY-MM-DD...) は直接比較可能
        return a > b
    end)
    -- print(#g.settings .. "a")
    local item_count = #g.settings
    local y_pos = 5

    for i = 1, item_count do
        local tokens = StringSplit(g.settings[i], '/')

        local date_str = tokens[1]
        local name_str = tokens[2]
        local item_str = string.gsub(tokens[3], "?", "-") -- '?' を '-' に戻す
        local quantity_str = tokens[4]
        local unit_price_val = tonumber(tokens[5])
        local total_amount_val = tonumber(tokens[6])
        local unit_price_str = tokens[7]
        local total_amount_str = tokens[8]

        sumtotal_amount = sumtotal_amount + total_amount_val

        -- 1行のテキストを生成
        local line_text = string.format("%s , %s , %s , %s , %s , %s", date_str, name_str, item_str, quantity_str,
            unit_price_str, total_amount_str)

        -- 1行ごとにRichTextコントロールを作成してテキストを設定
        local text_view = bg:CreateOrGetControl("richtext", "textview" .. i, 5, y_pos)
        AUTO_CAST(text_view)
        text_view:SetText("{ol}" .. line_text)

        y_pos = y_pos + 20
    end

    -- 期間の文字列を取得 (ソート後の最初と最後のエントリから)
    local latest_date_str = string.match(g.settings[1], ":(%-?%d%d%d%d%-%d%d%-%d%d)")
    local earliest_date_str = string.match(g.settings[item_count], ":(%-?%d%d%d%d%-%d%d%-%d%d)")

    -- 合計金額のテキストを設定

    local sum_total_amount_text = frame:CreateOrGetControl("richtext", "sumtotal_amount_text", 900, 740, 100, 30)
    local rounded_number = market_voucher_round(sumtotal_amount / 1000000)
    sum_total_amount_text:SetText(g.ui_text("Total Sales:") .. GET_COMMAED_STRING(sumtotal_amount) .. "(" ..
                                      rounded_number .. "M)")
    sum_total_amount_text:ShowWindow(1)

    -- 期間のテキストを設定
    local period_text = frame:CreateOrGetControl("richtext", "date_text", 640, 740, 100, 30)
    period_text:SetText(g.ui_text("Period:") .. earliest_date_str .. "～" .. latest_date_str)

    frame:ShowWindow(1)
    frame:RunUpdateScript("market_voucher_auto_close", 0.3)
end

function market_voucher_auto_close(frame)
    local market_frame = ui.GetFrame("market_cabinet")
    if market_frame:IsVisible() == 1 then
        return 1
    else
        frame:ShowWindow(0)
        market_frame:RemoveChild("log_btn")
        return 0
    end
end

function market_voucher_clear(frame)
    g.settings = {}
    ui.SysMsg(g.ui_text("ClearedMsg"))
    market_voucher_save_settings()
end

function market_voucher_print_close(frame, ctrl, argStr, argNum)
    local frame = ui.GetFrame("market_voucher")
    frame:RemoveAllChild()
    frame:ShowWindow(0)
end

function market_voucher_init_frame()
    local frame = ui.GetFrame("market_cabinet")
    local log_btn = frame:CreateOrGetControl("button", "log_btn", 610, 120, 100, 30)

    AUTO_CAST(log_btn)
    log_btn:SetSkinName("tab2_btn")
    local text = "{@st66b18}" .. g.lang_trans("Sales Slip")

    log_btn:SetText(text)
    log_btn:SetEventScript(ui.LBUTTONUP, "market_voucher_print")
    log_btn:ShowWindow(1)

end

--[==[
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

end

function market_voucher_auto_close(frame)
    local marketframe = ui.GetFrame("market_cabinet")
    if marketframe:IsVisible() == 1 then
        return 1
    else
        frame:ShowWindow(0)
        return 0
    end

end

function market_voucher_round(number)
    return math.floor(number + 0.5)
end

function market_voucher_clear(frame)
    g.settings = {}
    ui.SysMsg(
        "The list of sold items has been cleared.{nl}販売履歴を削除しました。logtextには残っています。")
    market_voucher_save_settings()
    frame:ShowWindow(0)

end
function market_voucher_CABINET_GET_ALL_LIST(my_frame, my_msg)

    local frame, control, strarg, now = g.get_event_args(my_msg)
    local frame = ui.GetFrame("market_cabinet")
    local itemGbox = GET_CHILD(frame, "itemGbox");
    local cnt = session.market.GetCabinetItemCount();
    local result = ""

    for i = 0, cnt - 1 do
        local cabinetItem = session.market.GetCabinetItemByIndex(i);
        local whereFrom = cabinetItem:GetWhereFrom();

        if whereFrom == "market_sell" then -- 

            local itemID = cabinetItem:GetItemID();

            local itemObj = GetIES(cabinetItem:GetObject());
            local itemCls = GetClassByType("Item", itemObj.ClassID);
            local itemName = TryGetProp(itemCls, "Name");

            local langCode = option.GetCurrentCountry()
            -- if (option.GetCurrentCountry() == "Japanese") then
            if langCode ~= "Korean" then

                itemName = dictionary.ReplaceDicIDInCompStr(itemObj.Name)

            end

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

            table.insert(g.settings, result)
        end
    end

    local fd = io.open(g.logpath, "a")
    fd:write(result .. "\n")
    fd:close()
    market_voucher_save_settings()
    g.FUNCS["CABINET_GET_ALL_LIST"](frame, control, strarg, now)
end
function market_voucher_MARKET_CABINET_MODE(frame)
    -- ReserveScript("market_voucher_detail_item()", 0.3)
    frame:RunUpdateScript("market_voucher_detail_item", 0.3)
end

function market_voucher_detail_item(frame)
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
    return 0
end]==]
