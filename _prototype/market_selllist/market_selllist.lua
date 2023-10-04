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

g.settingsFileLoc = string.format('../addons/%s/settings.json', "marketsellvoucher")

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

    -- acutil.setupHook(MARKET_SELLLIST_SOLD_ITEM_NOTICE, 'ON_SOLD_ITEM_NOTICE')
    -- addon:RegisterMsg("CABINET_ITEM_LIST", "marketsellvoucher_CABINET_ITEM_LIST");

    acutil.setupEvent(addon, 'CABINET_GET_ITEM', "marketsellvoucher_CABINET_GET_ITEM")

    -- MARKET_SELLLIST_LOAD_SETTINGS()

end

function marketsellvoucher_CABINET_GET_ITEM(frame)
    local itemGbox = GET_CHILD(frame, "itemGbox");
    local itemlist = GET_CHILD(itemGbox, "itemlist", "ui::CDetailListBox");
    local cnt = session.market.GetCabinetItemCount();
    for i = 0, cnt - 1 do
        local cabinetItem = session.market.GetCabinetItemByIndex(i);
        local itemID = cabinetItem:GetItemID();
        local itemObj = GetIES(cabinetItem:GetObject());
        local ctrlSet = INSERT_CONTROLSET_DETAIL_LIST(itemlist, i, 0, "market_cabinet_item_detail");
        ctrlSet:Resize(itemlist:GetWidth() - 20, ctrlSet:GetHeight());
        AUTO_CAST(ctrlSet);
        local SELL_SUCCESS_IMAGE = ctrlSet:GetUserConfig('SELL_SUCCESS_IMAGE');
        local SELL_SUCCESS_TEXT_STYLE = ctrlSet:GetUserConfig('SELL_SUCCESS_TEXT_STYLE');
        local typeBox = GET_CHILD_RECURSIVELY(ctrlSet, 'typeBox');
        local typeText = typeBox:GetChild('typeText');
        local whereFrom = cabinetItem:GetWhereFrom();
        ctrlSet:SetUserValue('CABINET_TYPE', whereFrom);
        if whereFrom == 'market_sell' then -- 판매 완료
            typeText:SetTextByKey('type', ClMsg('SellSuccess'));
        end
    end

end

function ON_CABINET_ITEM_LIST(frame)
    local itemGbox = GET_CHILD(frame, "itemGbox");
    local itemlist = GET_CHILD(itemGbox, "itemlist", "ui::CDetailListBox");
    itemlist:RemoveAllChild();
    local cnt = session.market.GetCabinetItemCount();
    local sysTime = geTime.GetServerSystemTime();
    for i = 0, cnt - 1 do
        local cabinetItem = session.market.GetCabinetItemByIndex(i);
        local itemID = cabinetItem:GetItemID();
        local itemObj = GetIES(cabinetItem:GetObject());
        local registerTime = cabinetItem:GetRegSysTime();
        local difSec = imcTime.GetDifSec(registerTime, sysTime);
        if 0 >= difSec then
            difSec = 0;
        end
        local timeString = GET_TIME_TXT(difSec);

        local refreshScp = itemObj.RefreshScp;
        if refreshScp ~= "None" then
            refreshScp = _G[refreshScp];
            refreshScp(itemObj);
        end

        -- market_cabinet_item_detail / market_cabinet_item_etc
        local ctrlSet = INSERT_CONTROLSET_DETAIL_LIST(itemlist, i, 0, "market_cabinet_item_detail");
        ctrlSet:Resize(itemlist:GetWidth() - 20, ctrlSet:GetHeight());
        AUTO_CAST(ctrlSet);

        -- get skin and text style
        local BUY_SUCCESS_IMAGE = ctrlSet:GetUserConfig('BUY_SUCCESS_IMAGE');
        local SELL_SUCCESS_IMAGE = ctrlSet:GetUserConfig('SELL_SUCCESS_IMAGE');
        local SELL_CANCEL_IMAGE = ctrlSet:GetUserConfig('SELL_CANCEL_IMAGE');
        local DEFAULT_TYPE_IMAGE = ctrlSet:GetUserConfig('DEFAULT_TYPE_IMAGE');
        local BUY_SUCCESS_TEXT_STYLE = ctrlSet:GetUserConfig('BUY_SUCCESS_TEXT_STYLE');
        local SELL_SUCCESS_TEXT_STYLE = ctrlSet:GetUserConfig('SELL_SUCCESS_TEXT_STYLE');
        local SELL_CANCEL_TEXT_STYLE = ctrlSet:GetUserConfig('SELL_CANCEL_TEXT_STYLE');

        -- type
        local typeBox = GET_CHILD_RECURSIVELY(ctrlSet, 'typeBox');
        local typeText = typeBox:GetChild('typeText');
        local whereFrom = cabinetItem:GetWhereFrom();

        ctrlSet:SetUserValue('CABINET_TYPE', whereFrom);
        if whereFrom == 'market_sell' then -- 판매 완료
            typeText:SetTextByKey('type', ClMsg('SellSuccess'));
        elseif whereFrom == 'market_buy' then -- 구매 완료
            typeText:SetTextByKey('type', ClMsg('BuySuccess'));
        elseif whereFrom == 'market_cancel' or whereFrom == 'market_expire' then -- 판매 취소, 판매 기한 완료
            typeText:SetTextByKey('type', ClMsg('SellCancel'));
        elseif whereFrom == 'SquadModeReward' then
            typeText:SetTextByKey('type', ClMsg('SquadModeReward'));
        elseif whereFrom == 'fishing_statue' then
            typeText:SetTextByKey('type', ClMsg('fishing_statue'));
        end

        -- item picture and name
        local pic = GET_CHILD(ctrlSet, "pic", "ui::CSlot");
        local itemImage = GET_ITEM_ICON_IMAGE(itemObj);
        local icon = CreateIcon(pic)
        SET_SLOT_ITEM_CLS(pic, itemObj)
        icon:SetImage(itemImage);
        SET_SLOT_STYLESET(pic, itemObj)
        SET_SLOT_STAR_TEXT(pic, itemObj);
        if itemObj.ClassName ~= MONEY_NAME and itemObj.MaxStack > 1 then
            local font = '{s16}{ol}{b}';
            local count = 0;
            if whereFrom == "market_sell" then
                count = cabinetItem.sellItemAmount;
            elseif whereFrom ~= "market_sell" then
                count = tonumber(cabinetItem:GetCount());
            end

            if 100000 <= count then -- 6자리 수 폰트 크기 조정
                font = '{s14}{ol}{b}';
            end

            SET_SLOT_COUNT_TEXT(pic, count, font);
        end
        -- pic:SetImage(itemImage);
        local name = ctrlSet:GetChild("name");
        local name_text = GET_FULL_NAME(itemObj)
        local grade = shared_item_earring.get_earring_grade(itemObj)
        if grade > 0 then
            name_text = name_text .. '(' .. grade .. ClMsg('Grade') .. ')'
        end
        name:SetTextByKey("value", name_text);

        -- etc box
        local etcBox = GET_CHILD_RECURSIVELY(ctrlSet, 'etcBox');
        local etcShow = false;
        if whereFrom ~= 'market_sell' and whereFrom ~= 'market_buy' and itemObj.ClassName ~= MONEY_NAME then
            local etcText = etcBox:GetChild('etcText');
            etcText:SetTextByKey('count', tonumber(cabinetItem:GetCount()));
            etcBox:ShowWindow(1);
            etcShow = true;
        else
            etcBox:ShowWindow(0);
        end

        -- time
        local timeBox = GET_CHILD_RECURSIVELY(ctrlSet, 'timeBox');
        local endTime = timeBox:GetChild("endTime");
        if (etcShow == true and difSec <= 0) or whereFrom ~= 'market_sell' then
            timeBox:ShowWindow(0);
        else
            endTime:SetTextByKey("value", timeString);
            if 0 == difSec then
                endTime:SetTextByKey("value", ClMsg("Auto_JongLyo"));
            else
                endTime:SetUserValue("REMAINSEC", difSec);
                endTime:SetUserValue("STARTSEC", imcTime.GetAppTime());
                SHOW_REMAIN_NEXT_TIME_GET_CABINET(medalFreeTime);
                endTime:RunUpdateScript("SHOW_REMAIN_NEXT_TIME_GET_CABINET");
            end
        end

        -- fees / NEXON_PC 조건도 추가해야 된다. / 추후 작업
        -- local fees = 0;
        -- if true == session.loginInfo.IsPremiumState(ITEM_TOKEN) then					
        -- fees = tonumber(cabinetItem:GetCount()) * 0.1
        -- elseif false == session.loginInfo.IsPremiumState(ITEM_TOKEN) then
        -- fees = tonumber(cabinetItem:GetCount()) * 0.3   			
        -- end

        -- price (count - fees)
        local totalPrice = GET_CHILD_RECURSIVELY(ctrlSet, "totalPrice"); -- 10,000 처럼 표기
        local totalPriceStr = GET_CHILD_RECURSIVELY(ctrlSet, "totalPriceStr"); -- 1만    처럼 표기
        if itemObj.ClassName == MONEY_NAME or (whereFrom == 'market_sell' and etcShow == false) then
            if tonumber(cabinetItem:GetCount()) < 70 then
                ClientRemoteLog("CABINET_ITEM_PRICE_ERROR - " .. tonumber(cabinetItem:GetCount()));
            end
            totalPrice:SetTextByKey("value", GET_COMMAED_STRING(tonumber(cabinetItem:GetCount())));
            totalPriceStr:SetTextByKey("value", GetMonetaryString(tonumber(cabinetItem:GetCount())));
        else
            totalPrice:ShowWindow(0);
            totalPriceStr:ShowWindow(0);
        end

        SET_ITEM_TOOLTIP_ALL_TYPE(ctrlSet, cabinetItem, itemObj.ClassName, "cabinet", cabinetItem.itemType,
            cabinetItem:GetItemID());

        local btn = GET_CHILD(ctrlSet, "btn");
        btn:SetTextByKey("value", ClMsg("Receieve"));
        btn:UseOrifaceRectTextpack(true)
        btn:SetEventScript(ui.LBUTTONUP, "CABINET_ITEM_BUY");
        btn:SetEventScriptArgString(ui.LBUTTONUP, cabinetItem:GetItemID());

        if 0 >= difSec or whereFrom ~= 'market_sell' then
            btn:SetEnable(1);
        else
            btn:SetEnable(0);
        end

    end
    GBOX_AUTO_ALIGN(itemlist:GetGroupBox(), 3, 0, 0, true, true);
    itemlist:RealignItems();

    -- default filter
    local buySuccessCheckBox = GET_CHILD_RECURSIVELY(frame, 'buySuccessCheckBox');
    local sellSuccessCheckBox = GET_CHILD_RECURSIVELY(frame, 'sellSuccessCheckBox');
    local sellCancelCheckBox = GET_CHILD_RECURSIVELY(frame, 'sellCancelCheckBox');
    local etcCheckBox = GET_CHILD_RECURSIVELY(frame, 'etcCheckBox');
    buySuccessCheckBox:SetCheck(1);
    sellSuccessCheckBox:SetCheck(1);
    sellCancelCheckBox:SetCheck(1);
    etcCheckBox:SetCheck(1);
    MARKET_CABINET_FILTER(frame);
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
