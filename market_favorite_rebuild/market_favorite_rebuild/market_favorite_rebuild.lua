-- v2.0.0 エビさんから引き継ぎな感じ。イコル検索と保存呼出を弄った
-- v2.0.1 キャンセルと期間終了の元の販売データを表示する様に
-- v2.0.2 アドオン名変更
local addon_name = 'MARKET_FAVORITE_REBUILD'
local addon_name_lower = string.lower(addon_name)
-- 作者名
local author = 'ebisuke'
local base_ver = "1.1.1"
local ver = "2.0.2"

-- アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addon_name] = _G['ADDONS'][author][addon_name] or {}
local g = _G['ADDONS'][author][addon_name]

local json = require('json')

function g.truncate_text_by_byte_limit(text, lang)
    if not text or text == "" then
        return ""
    end

    local max_bytes
    if lang == "ja" or lang == "ko" then
        max_bytes = 48
    elseif lang == "en" then
        max_bytes = 16
    else
        max_bytes = 16
    end

    if string.len(text) <= max_bytes then
        return text
    end

    local current_bytes = 0
    local end_byte_pos = 0

    for pos, code in utf8.codes(text) do

        local char_len

        local next_pos = utf8.offset(text, 2, pos)
        if next_pos then
            char_len = next_pos - pos
        else

            char_len = #text - pos + 1
        end

        if current_bytes + char_len > max_bytes then
            break
        end

        current_bytes = current_bytes + char_len

        end_byte_pos = current_bytes
    end

    return string.sub(text, 1, end_byte_pos)
end

function g.judge_language(str)

    if not str or str == "" then
        return "unknown"
    end

    local has_korean = false
    local has_japanese = false
    local has_english = false

    for _, code in utf8.codes(str) do
        if code >= 0xAC00 and code <= 0xD7A3 then
            has_korean = true
        elseif (code >= 0x3040 and code <= 0x309F) or (code >= 0x30A0 and code <= 0x30FF) or
            (code >= 0x4E00 and code <= 0x9FFF) then
            has_japanese = true
        elseif (code >= 0x0041 and code <= 0x005A) or (code >= 0x0061 and code <= 0x007A) then
            has_english = true
        end
    end

    if has_korean then
        return "ko"
    end
    if has_japanese then
        return "ja"
    end
    if has_english then
        return "en"
    end

    return "unknown"
end

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
end
g.mkdir_new_folder()

function g.save_settings()
    local function save_json(path, tbl)
        local file = io.open(path, "w")
        if file then
            local str = json.encode(tbl)
            file:write(str)
            file:close()
        end
    end
    save_json(g.settings_path, g.settings)
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

function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end

function market_favorite_rebuild_SAVE_SETTINGS()
    g.save_settings()
end

function market_favorite_rebuild_LOAD_SETTINGS()
    local settings = g.load_json(g.settings_path)
    if not settings then
        settings = {
            move = 1,
            always = 0,
            position = {
                x = 1420,
                y = 0
            },
            items = {},
            searchs = {}
        }
    end
    g.settings = settings

    if not g.settings.sell_items then
        g.settings.sell_items = {}
    end

    if not g.settings.sell_items[g.login_name] then
        g.settings.sell_items[g.login_name] = {}
    end

    market_favorite_rebuild_SAVE_SETTINGS()
end

function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
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

function MARKET_FAVORITE_REBUILD_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()
    g.login_name = session.GetMySession():GetPCApc():GetName()

    if not g.settings then
        market_favorite_rebuild_LOAD_SETTINGS()
    end

    addon:RegisterMsg("OPEN_DLG_MARKET", "market_favorite_rebuild_ON_OPEN_MARKET")

    g.REGISTER = {}
    g.setup_hook_and_event(addon, "MARKET_CLOSE", "market_favorite_rebuild_MARKET_CLOSE", true)
    g.setup_hook_and_event(addon, "_MARKET_SAVE_CATEGORY_OPTION",
        "market_favorite_rebuild__MARKET_SAVE_CATEGORY_OPTION", true)

    g.setup_hook_and_event(addon, "MARKET_INIT_OPTION_GROUP_DROPLIST",
        "market_favorite_rebuild_MARKET_INIT_OPTION_GROUP_DROPLIST", true)
    g.setup_hook_and_event(addon, "MARKET_DELETE_SAVED_OPTION", "market_favorite_rebuild_MARKET_DELETE_SAVED_OPTION",
        false)

    g.setup_hook_and_event(addon, "MARKET_BUYMODE", "market_favorite_rebuild_MARKET_BUYMODE", true)

    g.setup_hook_and_event(addon, "ON_MARKET_SELL_LIST", "market_favorite_rebuild_ON_MARKET_SELL_LIST", false)
    g.setup_hook_and_event(addon, "ON_CABINET_ITEM_LIST", "market_favorite_rebuild_ON_CABINET_ITEM_LIST", false)

    g.setup_hook_and_event(addon, "MARKET_SELL_REGISTER", "market_favorite_rebuild_MARKET_SELL_REGISTER", false)
    g.temp_tbl = {}

end

function market_favorite_rebuild_MARKET_INIT_OPTION_GROUP_DROPLIST(my_frame, my_msg)
    local dropList = g.get_event_args(my_msg)
    local frame = ui.GetFrame("market")
    local optionGroupSet = GET_CHILD_RECURSIVELY(frame, 'optionGroupSet');

    local curSelectCnt = optionGroupSet:GetUserIValue('ADD_SELECT_COUNT');

    local childIdx = curSelectCnt - 1
    local selectSet = GET_CHILD_RECURSIVELY(optionGroupSet, 'SELECT_' .. childIdx)

    if selectSet then
        local minEdit = GET_CHILD_RECURSIVELY(selectSet, 'minEdit');
        if minEdit and minEdit:GetText() == "" then
            minEdit:SetText('0');
        end
    end
end

function market_favorite_rebuild_MARKET_SELL_REGISTER(my_frame, my_msg)

    local parent, ctrl = g.get_event_args(my_msg)

    local count = session.market.GetItemCount();
    local userType = session.loginInfo.GetPremiumState();
    local maxCount = GetCashValue(userType, "marketUpMax");
    if true == session.loginInfo.IsPremiumState(ITEM_TOKEN) then
        local tokenCnt = GetCashValue(ITEM_TOKEN, "marketUpMax");
        if tokenCnt > maxCount then
            maxCount = tokenCnt;
        end
    end

    if count + 1 > maxCount then
        ui.SysMsg(ClMsg("MarketRegitCntOver"));
        return;
    end
    local frame = parent:GetTopParentFrame();
    local groupbox = frame:GetChild("groupbox");
    local slot_item = GET_CHILD_RECURSIVELY(groupbox, "slot_item", "ui::CSlot");
    local edit_count = GET_CHILD_RECURSIVELY(groupbox, "edit_count");
    local edit_price = GET_CHILD_RECURSIVELY(groupbox, "edit_price");

    local invitem = GET_SLOT_ITEM(slot_item);
    if invitem == nil then
        return;
    end

    local count = tonumber(edit_count:GetText());
    local price = GET_NOT_COMMAED_NUMBER(edit_price:GetText());
    if price < 100 then
        ui.SysMsg(ClMsg("SellPriceMustOverThen100Silver"));
        return;
    end

    local limitMoneyStr = GET_REMAIN_MARKET_TRADE_AMOUNT_STR();
    if limitMoneyStr == nil then
        ui.SysMsg(ClMsg('LoadingTradeLimitAmount'));
        return;
    end

    if IsGreaterThanForBigNumber(math.mul_int_for_lua(price, count), limitMoneyStr) == 1 then
        ui.SysMsg(ScpArgMsg('MarketMaxSilverLimit{LIMIT}Over', 'LIMIT', GET_COMMAED_STRING(limitMoneyStr)));
        return;
    end

    local strprice = tostring(price);
    if string.len(strprice) < 3 then
        return
    end

    local floorprice = strprice.sub(strprice, 0, 2);
    for i = 0, string.len(strprice) - 3 do
        floorprice = floorprice .. "0"
    end

    if strprice ~= floorprice then
        edit_price:SetText(GET_COMMAED_STRING(floorprice));
        ui.SysMsg(ScpArgMsg("AutoAdjustToMinPrice"));
        price = tonumber(floorprice);

        local sellPriceGbox = GET_CHILD_RECURSIVELY(frame, 'sellPriceGbox');
        local priceText = GET_CHILD(sellPriceGbox, 'priceText');
        priceText:SetTextByKey('priceText', GetMonetaryString(floorprice));
    end

    if count <= 0 then
        ui.SysMsg(ClMsg("SellCountMustOverThenZeo"));
        return;
    end

    local isPrivate = GET_CHILD_RECURSIVELY(groupbox, "isPrivate", "ui::CCheckBox");
    local itemGuid = invitem:GetIESID();
    local obj = GetIES(invitem:GetObject());

    -- 선택한 라디오를 가져옴
    local radioCtrl = GET_CHILD_RECURSIVELY(frame, "feePerTime_1")
    local selecIndex = GET_RADIOBTN_NUMBER(radioCtrl) - 1;

    local needTime = frame:GetUserIValue('TIME_' .. selecIndex);
    local free = tonumber(frame:GetUserValue('FREE_' .. selecIndex));
    local registerFeeValueCtrl = GET_CHILD_RECURSIVELY(frame, "registerFeeValue");
    local commission = registerFeeValueCtrl:GetTextByKey("value")
    commission = string.gsub(commission, ",", "")
    commission = math.max(tonumber(commission), 1);
    if IsGreaterThanForBigNumber(commission, GET_TOTAL_MONEY_STR()) == 1 then
        ui.SysMsg(ClMsg("Auto_SilBeoKa_BuJogHapNiDa."));
        return;
    end

    UPDATE_FEE_INFO(frame, free, count, price)

    local sellPriceGbox = GET_CHILD_RECURSIVELY(groupbox, "sellPriceGbox");

    local down = sellPriceGbox:GetChild("minPrice");

    local minPrice = down:GetTextByKey("value");
    local iminPrice = GET_NOT_COMMAED_NUMBER(minPrice);
    local iPrice = tonumber(price);
    if IGNORE_ITEM_AVG_TABLE_FOR_TOKEN == 1 then
        if false == session.loginInfo.IsPremiumState(ITEM_TOKEN) then
            if 0 ~= iminPrice and iPrice < iminPrice then
                ui.SysMsg(ScpArgMsg("PremiumRegMinPrice{Price}", "Price", minPrice));
                return;
            end
        end
    else
        if 0 ~= iminPrice and iPrice < iminPrice then
            ui.SysMsg(ScpArgMsg("PremiumRegMinPrice{Price}", "Price", minPrice));
            return;
        end
    end

    if obj.ClassName == "PremiumToken" and iPrice < tonumber(TOKEN_MARKET_REG_LIMIT_PRICE) then
        ui.SysMsg(ScpArgMsg("PremiumRegMinPrice{Price}", "Price", TOKEN_MARKET_REG_LIMIT_PRICE));
        return;
    end
    if obj.ClassName == "PremiumToken" and iPrice > tonumber(TOKEN_MARKET_REG_MAX_PRICE) then
        ui.SysMsg(ScpArgMsg("PremiumRegMaxPrice{Price}", "Price", TOKEN_MARKET_REG_MAX_PRICE));
        return;
    end

    if true == invitem.isLockState then
        ui.SysMsg(ClMsg("MaterialItemIsLock"));
        return false;
    end

    local invframe = ui.GetFrame("inventory");
    if true == IS_TEMP_LOCK(invframe, invitem) then
        ui.SysMsg(ClMsg("MaterialItemIsLock"));
        return false;
    end
    local itemProp = geItemTable.GetProp(obj.ClassID);
    local pr = TryGetProp(obj, "PR");

    local noTradeCnt = TryGetProp(obj, "BelongingCount");
    local tradeCount = invitem.count
    if nil ~= noTradeCnt and 0 < tonumber(noTradeCnt) then
        local wareItem = nil;
        if obj.MaxStack > 1 then
            wareItem = session.GetWarehouseItemByType(obj.ClassID);
        end
        local wareCnt = 0;
        if nil ~= wareItem then
            wareCnt = wareItem.count;
        end
        tradeCount = (invitem.count + wareCnt) - tonumber(noTradeCnt);
        if tradeCount <= 0 then
            ui.AlarmMsg("ItemIsNotTradable");
            return false;
        end
    end

    if itemProp:IsEnableMarketTrade() == false or itemProp:IsMoney() == true or
        ((pr ~= nil and pr < 1) and itemProp:NeedCheckPotential() == true) then
        ui.AlarmMsg("ItemIsNotTradable");
        return false;
    end

    if false == session.loginInfo.IsPremiumState(ITEM_TOKEN) then
        local maxPrice = GET_CHILD_RECURSIVELY(frame, "maxPrice");
        local maxPriceStr = GET_NOT_COMMAED_NUMBER(maxPrice:GetTextByKey('value'), true);
        if tonumber(maxPriceStr) ~= 0 and IsGreaterThanForBigNumber(floorprice, maxPriceStr) == 1 then
            ui.SysMsg(ClMsg('MaxAllowPriceError'));
            return false;
        end
    end

    local clsid = obj.ClassID
    -- local yesScp = string.format("market.ReqRegisterItem(\'%s\', %s, %d, 1, %d)", itemGuid, floorprice, count, needTime);
    local yesScp = string.format("market_favorite_rebuild_req_register_item(\'%s\', %s, %d, 1, %d,%d)", itemGuid,
        floorprice, count, needTime, clsid);
    commission = registerFeeValueCtrl:GetTextByKey("value");
    commission = string.gsub(commission, ",", "");
    commission = math.max(tonumber(commission), 1);

    if nil ~= obj and obj.ItemType == 'Equip' then
        if 0 < obj.BuffValue then
            -- 장비그룹만 buffValue가 있다.
            ui.MsgBox(ScpArgMsg("BuffDestroy{Price}", "Price", tostring(commission)), yesScp, "None");
        else
            ui.MsgBox(ScpArgMsg("CommissionRegMarketItem{Price}", "Price", GetMonetaryString(commission)), yesScp,
                "None");
        end
    else
        ui.MsgBox(ScpArgMsg("CommissionRegMarketItem{Price}", "Price", GetMonetaryString(commission)), yesScp, "None");
    end
end

function market_favorite_rebuild_req_register_item(itemGuid, floorprice, count, _, needTime, clsid)

    local current_time = os.date("%y-%m-%d %H:%M")

    local data = {
        iesid = itemGuid,
        clsid = clsid,
        price = floorprice,
        count = count,
        time = needTime,
        register_time = current_time,
        status = "selling"
    }
    table.insert(g.settings.sell_items[g.login_name], data)
    g.item_index = #g.settings.sell_items[g.login_name]
    market.ReqRegisterItem(itemGuid, tonumber(floorprice), tonumber(count), 1, tonumber(needTime))

end

function market_favorite_rebuild_ON_CABINET_ITEM_LIST(my_frame, my_msg)

    local frame = g.get_event_args(my_msg)
    local itemGbox = GET_CHILD(frame, "itemGbox");
    local itemlist = GET_CHILD(itemGbox, "itemlist", "ui::CDetailListBox");
    itemlist:RemoveAllChild();
    local cnt = session.market.GetCabinetItemCount();
    local sysTime = geTime.GetServerSystemTime();

    local cab_items = {}
    for i = 0, cnt - 1 do
        local cabinetItem = session.market.GetCabinetItemByIndex(i)
        local item_id = tostring(cabinetItem:GetItemID())
        cab_items[item_id] = cabinetItem:GetWhereFrom()
    end

    local clean_items = {}
    if g.settings.sell_items and g.settings.sell_items[g.login_name] then
        for _, saved_item in ipairs(g.settings.sell_items[g.login_name]) do

            if cab_items[saved_item.iesid] then
                saved_item.status = cab_items[saved_item.iesid]
                table.insert(clean_items, saved_item)

            elseif saved_item.status == 'selling' then
                table.insert(clean_items, saved_item)
            end
        end
    end

    g.settings.sell_items[g.login_name] = clean_items
    market_favorite_rebuild_SAVE_SETTINGS()

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
        AUTO_CAST(typeText)

        local whereFrom = cabinetItem:GetWhereFrom();

        ctrlSet:SetUserValue('CABINET_TYPE', whereFrom);
        if whereFrom == 'market_sell' then -- 판매 완료
            typeText:SetTextByKey('type', ClMsg('SellSuccess'));
        elseif whereFrom == 'market_buy' then -- 구매 완료
            typeText:SetTextByKey('type', ClMsg('BuySuccess'));
        elseif whereFrom == 'market_cancel' or whereFrom == 'market_expire' then -- 판매 취소, 판매 기한 완료
            typeText:SetTextByKey('type', ClMsg('SellCancel'));
        end

        -- item picture and name
        local pic = GET_CHILD(ctrlSet, "pic", "ui::CSlot");
        local itemImage = GET_ITEM_ICON_IMAGE(itemObj);
        local icon = CreateIcon(pic)
        local iconInfo = icon:GetInfo();

        SET_SLOT_ITEM_CLS(pic, itemObj)
        icon:SetImage(itemImage);
        SET_SLOT_STYLESET(pic, itemObj)

        if itemObj.ClassName ~= MONEY_NAME and itemObj.MaxStack > 1 then
            if whereFrom == "market_sell" then
                SET_SLOT_COUNT_TEXT(pic, cabinetItem.sellItemAmount, '{s16}{ol}{b}');
            elseif whereFrom ~= "market_sell" then
                SET_SLOT_COUNT_TEXT(pic, cabinetItem.count or tonumber(cabinetItem:GetCount()), '{s16}{ol}{b}');
            end
        end

        -- pic:SetImage(itemImage);
        local name = ctrlSet:GetChild("name");

        name:SetTextByKey("value", GET_FULL_NAME(itemObj));

        -- etc box
        local etcBox = GET_CHILD_RECURSIVELY(ctrlSet, 'etcBox');
        local etcShow = false;

        if whereFrom ~= 'market_sell' and whereFrom ~= 'market_buy' and itemObj.ClassName ~= MONEY_NAME then
            local etcText = etcBox:GetChild('etcText');
            etcText:SetTextByKey('count', cabinetItem.count or tonumber(cabinetItem:GetCount()));
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
        -- fees = cabinetItem.count * 0.1
        -- elseif false == session.loginInfo.IsPremiumState(ITEM_TOKEN) then
        -- fees = cabinetItem.count * 0.3   			
        -- end

        -- price (count - fees)

        local totalPrice = GET_CHILD_RECURSIVELY(ctrlSet, "totalPrice"); -- 10,000 처럼 표기
        local totalPriceStr = GET_CHILD_RECURSIVELY(ctrlSet, "totalPriceStr"); -- 1만    처럼 표기
        if itemObj.ClassName == MONEY_NAME or (whereFrom == 'market_sell' and etcShow == false) then
            local count = cabinetItem.count or tonumber(cabinetItem:GetCount())
            if count and count < 70 then
                ClientRemoteLog("CABINET_ITEM_PRICE_ERROR - " .. cabinetItem.count or tonumber(cabinetItem:GetCount()));
            end
            -- :GetCount()
            -- totalPrice:SetTextByKey("value", GET_COMMAED_STRING(cabinetItem.count));
            -- totalPriceStr:SetTextByKey("value", GetMonetaryString(cabinetItem.count));
            local amount = tonumber(cabinetItem:GetCount())

            totalPrice:SetTextByKey("value", GET_COMMAED_STRING(amount));
            totalPriceStr:SetTextByKey("value", GetMonetaryString(amount));
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

        if whereFrom == 'market_cancel' or whereFrom == 'market_expire' then -- 판매 취소, 판매 기한 완료

            for index, data in ipairs(g.settings.sell_items[g.login_name]) do
                local iesid = data.iesid
                if tostring(itemID) == iesid then
                    local register_time = data.register_time
                    local price = data.price
                    local count = data.count
                    local period = data.time
                    local temp_text = g.lang == "Japanese" and "{ol}登録日: " .. register_time ..
                                          "{nl}販売期間: " .. period .. "日{nl}販売単価: " .. price ..
                                          "{nl}販売個数: " .. count or "{ol}Reg. Date: " .. register_time ..
                                          "{nl}Sales Period: " .. period .. " Days{nl}Unit Price: " .. price ..
                                          "{nl}Quantity: " .. count
                    typeText:SetTextTooltip(temp_text)
                    btn:SetTextTooltip(temp_text)
                    break
                end
            end
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

function market_favorite_rebuild_ON_MARKET_SELL_LIST(my_frame, my_msg)

    local frame, msg, argStr, argNum = g.get_event_args(my_msg)
    if msg == MARKET_ITEM_LIST then
        local str = GET_TIME_TXT(argNum);
        ui.SysMsg(ScpArgMsg("MarketCabinetAfter{TIME}", "Time", str));
        if frame:IsVisible() == 0 then
            return;
        end
    end

    local itemlist = GET_CHILD(frame, "itemlist", "ui::CDetailListBox");
    itemlist:RemoveAllChild();
    local sysTime = geTime.GetServerSystemTime();
    local count = session.market.GetItemCount();
    local live_guids = {}
    for i = 0, count - 1 do
        local marketItem = session.market.GetItemByIndex(i);

        local itemObj = GetIES(marketItem:GetObject());
        local refreshScp = itemObj.RefreshScp;
        if refreshScp ~= "None" then
            refreshScp = _G[refreshScp];
            refreshScp(itemObj);
        end

        local ctrlSet = INSERT_CONTROLSET_DETAIL_LIST(itemlist, i, 0, "market_sell_item_detail");
        local pic = GET_CHILD(ctrlSet, "pic", "ui::CSlot");
        local imgName = GET_ITEM_ICON_IMAGE(itemObj);
        local icon = CreateIcon(pic)
        SET_SLOT_ITEM_CLS(pic, itemObj)
        icon:SetImage(imgName);
        SET_SLOT_STYLESET(pic, itemObj)
        if itemObj.MaxStack > 1 then
            SET_SLOT_COUNT_TEXT(pic, marketItem.count, '{s16}{ol}{b}');
        end

        local nameCtrl = ctrlSet:GetChild("name");
        nameCtrl:SetTextByKey("value", GET_FULL_NAME(itemObj));

        local totalPriceCtrl = ctrlSet:GetChild("totalPrice");
        local totalPriceValue = math.mul_int_for_lua(marketItem:GetSellPrice(), marketItem.count);
        local totalPrice = GET_COMMAED_STRING(totalPriceValue);
        totalPriceCtrl:SetTextByKey("value", totalPrice);

        local totalPriceStrCtrl = ctrlSet:GetChild("totalPriceStr");
        local totalPriceStr = GetMonetaryString(totalPriceValue);
        totalPriceStrCtrl:SetTextByKey("value", totalPriceStr);

        -- 시간 표기하는 부분
        local remainTimeCtrl = ctrlSet:GetChild("remainTime");
        if marketItem:IsWatingForRegister() == true then
            remainTimeCtrl:SetTextByKey("value", ClMsg("PleaseWaiting"));
        else
            local endSYSTime = marketItem:GetEndTime();
            local difSec = imcTime.GetDifSec(endSYSTime, sysTime);
            remainTimeCtrl:SetUserValue("REMAINSEC", difSec);
            remainTimeCtrl:SetUserValue("STARTSEC", imcTime.GetAppTime());
            remainTimeCtrl:RunUpdateScript("SHOW_REMAIN_MARKET_SELL_TIME");
        end
        -- 시간 표기하는 부분 end

        local cashValue = GetCashValue(marketItem.premuimState, "marketSellCom") * 0.01;
        local stralue = GetCashValue(marketItem.premuimState, "marketSellCom");
        local feeValueCtrl = ctrlSet:GetChild("feeValue");
        local feeValue = math.floor(math.mul_int_for_lua(totalPriceValue, cashValue));

        local feeStr = GET_COMMAED_STRING(feeValue);
        feeValueCtrl:SetTextByKey("value", feeStr);
        local feeValueStrCtrl = ctrlSet:GetChild("feeValueStr");
        local feeValueStr = GetMonetaryString(feeValue);
        feeValueStrCtrl:SetTextByKey("value", feeValueStr);

        if msg == "MARKET_SELL_LIST" then

            live_guids[tostring(marketItem:GetMarketGuid())] = true

            if not g.temp_tbl[tostring(marketItem:GetMarketGuid())] then
                if not g.settings.sell_items then
                    g.settings.sell_items = {}
                end
                if not g.settings.sell_items[g.login_name] then
                    g.settings.sell_items[g.login_name] = {}
                end
                if g.settings.sell_items[g.login_name][g.item_index] then
                    g.settings.sell_items[g.login_name][g.item_index].market_guid = tostring(marketItem:GetMarketGuid())
                    g.item_index = nil
                end
            end

            g.temp_tbl[tostring(marketItem:GetMarketGuid())] = true

        end

        SET_ITEM_TOOLTIP_ALL_TYPE(ctrlSet, marketItem, itemObj.ClassName, "market", marketItem.itemType,
            marketItem:GetMarketGuid());

        local btn = GET_CHILD(ctrlSet, "btn");
        btn:SetTextByKey("value", ClMsg("Cancel"));
        btn:SetEventScript(ui.LBUTTONUP, "CANCEL_MARKET_ITEM");
        btn:SetEventScriptArgString(ui.LBUTTONUP, marketItem:GetMarketGuid());
    end
    if msg == "MARKET_SELL_LIST" then
        for _, saved_item in ipairs(g.settings.sell_items[g.login_name]) do
            if saved_item.market_guid and saved_item.status == 'selling' then
                local market_guid = saved_item.market_guid
                if not live_guids[market_guid] then
                    saved_item.status = "nothing"
                    -- print("Status updated to 'nothing' for GUID:" .. saved_item.market_guid) -- テスト用
                end
            end
        end
    end
    market_favorite_rebuild_SAVE_SETTINGS()
    itemlist:RealignItems();
    GBOX_AUTO_ALIGN(itemlist:GetGroupBox(), 2, 0, 0, false, true);
end

function market_favorite_rebuild_MARKET_BUYMODE(my_frame, my_msg)

    local frame = ui.GetFrame('market_favorite_rebuild')
    if g.settings.always == 1 then
        market_favorite_rebuild_TOGGLE_FRAME("true")
        frame:ShowWindow(1)
    end

end

function market_favorite_rebuild_MARKET_DELETE_SAVED_OPTION(my_frame, my_msg)

    local parent, ctrl = g.get_event_args(my_msg)
    local nameText = GET_CHILD(parent, 'nameText');
    session.market.DeleteCategoryConfig(nameText:GetText());
    MARKET_TRY_LOAD_CATEGORY_OPTION(parent);

    local delete_text = nameText:GetText()

    for i = #g.settings.searchs, 1, -1 do
        local entry = g.settings.searchs[i]

        if entry and entry.key == delete_text then

            table.remove(g.settings.searchs, i)
            break
        end
    end
    market_favorite_rebuild_SAVE_SETTINGS()
    market_favorite_rebuild_TOGGLE_FRAME("true")
end

function market_favorite_rebuild_MARKET_CLOSE()
    local market_favorite_rebuild = ui.GetFrame("market_favorite_rebuild")
    market_favorite_rebuild:ShowWindow(0)
end

function market_favorite_rebuild_MARKET_LOAD_CATEGORY_OPTION(parent, ctrl, configKey)
    local market = ui.GetFrame("market")
    local optionBox = GET_CHILD_RECURSIVELY(market, 'optionBox')
    optionBox:ShowWindow(0)
    market_favorite_rebuild__MARKET_LOAD_CATEGORY_OPTION(market, configKey)
end

function market_favorite_rebuild__MARKET_LOAD_CATEGORY_OPTION(frame, configKey)
    frame = frame:GetTopParentFrame()
    local configText = session.market.GetCategoryConfig(configKey)

    if configText == nil or configText == '' then
        return false
    end

    -- parse
    local configList = StringSplit(configText, '@')
    local configTable = {}
    for i = 1, #configList do
        local config = configList[i]
        local idx = string.find(config, ':')

        if idx == nil then
            return false
        end
        local propName = string.sub(config, 0, idx - 1)
        local propValue = string.sub(config, idx + 1)
        -- print(tostring(propValue))
        configTable[propName] = propValue
    end

    -- set category
    local categoryStr = configTable['category']
    local underBarIdx = string.find(categoryStr, '_')
    local category = categoryStr
    local subCategory = ''
    if underBarIdx ~= nil then
        category = string.sub(categoryStr, 0, underBarIdx - 1)
        subCategory = string.sub(categoryStr, underBarIdx + 1)
    end
    if category == '' then
        category = 'IntegrateRetreive'
    end

    local categoryCtrlset = GET_CHILD_RECURSIVELY(frame, 'CATEGORY_' .. category)
    MARKET_CATEGORY_CLICK(categoryCtrlset, categoryCtrlset:GetChild('bgBox'), false, true)

    if subCategory ~= '' then
        local subCategoryCtrlset = GET_CHILD_RECURSIVELY(frame, 'SUB_CATE_' .. subCategory)
        if subCategoryCtrlset ~= nil then
            MARKET_SUB_CATEOGRY_CLICK(subCategoryCtrlset:GetParent(), subCategoryCtrlset, false)
        end
    end

    -- set price order
    local checkIdx = configTable['order']
    local priceOrderCheck = GET_CHILD_RECURSIVELY(frame, 'priceOrderCheck_' .. checkIdx)
    priceOrderCheck:SetCheck(1)
    MARKET_UPDATE_PRICE_ORDER(frame, priceOrderCheck)

    -- set level range
    local function GET_MINMAX_VALUE_BY_QUERY_STRING(queryString)
        local semiColonIdx = string.find(queryString, ';')
        local minValue = tonumber(string.sub(queryString, 0, semiColonIdx - 1))
        local maxValue = tonumber(string.sub(queryString, semiColonIdx + 1))
        minValue = math.max(minValue, 0)
        maxValue = math.max(maxValue, 0)
        return minValue, maxValue
    end

    if configTable['CT_UseLv'] ~= nil or configTable['Level'] ~= nil then
        local levelRangeSet = GET_CHILD_RECURSIVELY(frame, 'levelRangeSet')
        if levelRangeSet ~= nil and levelRangeSet:IsVisible() == 1 then
            local rangeValue = configTable['CT_UseLv']
            if configTable['Level'] ~= nil then
                rangeValue = configTable['Level']
            end

            local minValue, maxValue = GET_MINMAX_VALUE_BY_QUERY_STRING(rangeValue)
            local minEdit = GET_CHILD_RECURSIVELY(levelRangeSet, 'minEdit')
            local maxEdit = GET_CHILD_RECURSIVELY(levelRangeSet, 'maxEdit')
            minEdit:SetText(minValue)
            maxEdit:SetText(maxValue)
        end
    end

    -- set item grade	
    local gradeCheckSet = GET_CHILD_RECURSIVELY(frame, 'gradeCheckSet')

    if gradeCheckSet ~= nil then
        local gradeChildCnt = gradeCheckSet:GetChildCount() -- init
        for i = 0, gradeChildCnt - 1 do
            local child = gradeCheckSet:GetChildByIndex(i)
            if string.find(child:GetName(), 'gradeCheck_') ~= nil then
                AUTO_CAST(child)
                child:SetCheck(0)
            end
        end
        print(tostring(configTable['CT_ItemGrade']))
        if configTable['CT_ItemGrade'] ~= nil then
            if gradeCheckSet ~= nil and gradeCheckSet:IsVisible() == 1 then
                local checkValue = configTable['CT_ItemGrade']
                local checkValueList = nil
                if string.find(checkValue, ";") then
                    checkValueList = StringSplit(checkValue, ';')
                else
                    checkValueList = StringSplit(checkValue, '')
                end
                -- set check
                for i = 1, #checkValueList do
                    local gradeCheck = GET_CHILD(gradeCheckSet, 'gradeCheck_' .. checkValueList[i])
                    gradeCheck:SetCheck(1)
                end
            end
        end
    end

    -- set search text
    local itemSearchSet = GET_CHILD_RECURSIVELY(frame, 'itemSearchSet')
    local searchEdit = GET_CHILD_RECURSIVELY(itemSearchSet, 'searchEdit')

    searchEdit:SetText(configTable['searchText'])

    -- set appraisal check
    if configTable['Random_Item'] ~= nil then
        local appCheckSet = GET_CHILD_RECURSIVELY(frame, 'appCheckSet')
        if appCheckSet ~= nil and appCheckSet:IsVisible() == 1 then
            local configValue = tonumber(configTable['Random_Item'])
            local checkCtrl = nil
            if configValue == 1 then
                checkCtrl = GET_CHILD(appCheckSet, 'appCheck_1')
            elseif configValue == 2 then
                checkCtrl = GET_CHILD(appCheckSet, 'appCheck_0')
            end
            if checkCtrl ~= nil then
                checkCtrl:SetCheck(1)
                MARKET_UPDATE_APPRAISAL_CHECK(checkCtrl:GetParent(), checkCtrl)
            end
        end
    end

    local function ALIGN_OPTION_GROUP_SET(optionGroupSet)
        local Y_ADD_MARGIN = 6
        local staticText = GET_CHILD(optionGroupSet, 'staticText')
        local ypos = staticText:GetY() + staticText:GetHeight() + Y_ADD_MARGIN
        local childCnt = optionGroupSet:GetChildCount()

        local visibleSelectChildCount = 0
        local visibleChild = nil
        for i = 0, childCnt - 1 do
            local child = optionGroupSet:GetChildByIndex(i)
            if string.find(child:GetName(), 'SELECT_') ~= nil then
                child:SetOffset(child:GetX(), ypos)
                visibleChild = child
                ypos = ypos + child:GetHeight()
                visibleSelectChildCount = visibleSelectChildCount + 1
            end
        end
        local addOptionBtn = GET_CHILD(optionGroupSet, 'addOptionBtn')
        addOptionBtn:SetOffset(0, ypos)
        ypos = ypos + addOptionBtn:GetHeight() + Y_ADD_MARGIN
        optionGroupSet:Resize(optionGroupSet:GetWidth(), ypos)
        return visibleSelectChildCount, visibleChild
    end

    -- detail setting
    local detailOptionSet = GET_CHILD_RECURSIVELY(frame, 'detailOptionSet')
    if detailOptionSet ~= nil and detailOptionSet:IsVisible() == 1 then
        local added = false
        for configName, configValue in pairs(configTable) do
            if IS_MARKET_DETAIL_SETTING_OPTION(configName) == true then
                local selectSet = MARKET_ADD_SEARCH_DETAIL_SETTING(detailOptionSet)
                local groupList = GET_CHILD(selectSet, 'groupList')
                groupList:SelectItemByKey(configName)
                local minValue, maxValue = GET_MINMAX_VALUE_BY_QUERY_STRING(configValue)
                local minEdit, maxEdit = GET_CHILD_RECURSIVELY(selectSet, 'minEdit'),
                    GET_CHILD_RECURSIVELY(selectSet, 'maxEdit')
                minEdit:SetText(minValue)
                maxEdit:SetText(maxValue)

                added = true
            end
        end
        if added == false then
            ALIGN_OPTION_GROUP_SET(detailOptionSet)
        end
    end

    -- option group

    local optionGroupSet = GET_CHILD_RECURSIVELY(frame, 'optionGroupSet')
    if optionGroupSet ~= nil and optionGroupSet:IsVisible() == 1 then
        local added = false
        for configName, configValue in pairs(configTable) do
            local isOptionGroup, group = IS_MARKET_SEARCH_OPTION_GROUP(configName)
            if isOptionGroup == true then
                local selectSet = MARKET_ADD_SEARCH_OPTION_GROUP(optionGroupSet)

                local groupList = GET_CHILD(selectSet, 'groupList')
                groupList:SelectItemByKey(group)
                MARKET_INIT_OPTION_GROUP_VALUE_DROPLIST(groupList:GetParent(), groupList)

                local nameList = GET_CHILD(selectSet, 'nameList')
                nameList:SelectItemByKey(configName)

                local minValue, maxValue = GET_MINMAX_VALUE_BY_QUERY_STRING(configValue)
                -- print(tostring(minValue) .. ":" .. tostring(maxValue))
                local minEdit, maxEdit = GET_CHILD_RECURSIVELY(selectSet, 'minEdit'),
                    GET_CHILD_RECURSIVELY(selectSet, 'maxEdit')
                minEdit:SetText(minValue)
                maxEdit:SetText(maxValue)

                added = true
            end
        end
        if added == false then
            ALIGN_OPTION_GROUP_SET(optionGroupSet)
        end
    end

    -- gem
    local gemOptionSet = GET_CHILD_RECURSIVELY(frame, 'gemOptionSet')
    if gemOptionSet ~= nil then
        local optionGroupSet = GET_CHILD_RECURSIVELY(frame, 'optionGroupSet')
        local selectSet = MARKET_ADD_SEARCH_OPTION_GROUP(optionGroupSet)

        if configTable['GemLevel'] ~= nil then

            local minValue, maxValue = GET_MINMAX_VALUE_BY_QUERY_STRING(configTable['GemLevel'])
            local minEdit, maxEdit = GET_CHILD_RECURSIVELY(selectSet, 'levelMinEdit'),
                GET_CHILD_RECURSIVELY(selectSet, 'levelMaxEdit')
            minEdit:SetText(minValue)
            maxEdit:SetText(maxValue)
        end
        if configTable['CardLevel'] ~= nil then
            local minValue, maxValue = GET_MINMAX_VALUE_BY_QUERY_STRING(configTable['CardLevel'])
            local minEdit, maxEdit = GET_CHILD_RECURSIVELY(selectSet, 'levelMinEdit'),
                GET_CHILD_RECURSIVELY(selectSet, 'levelMaxEdit')
            minEdit:SetText(minValue)
            maxEdit:SetText(maxValue)
        end
        if configTable['GemRoastingLv'] ~= nil then
            local minValue, maxValue = GET_MINMAX_VALUE_BY_QUERY_STRING(configTable['CardLevel'])
            local minEdit, maxEdit = GET_CHILD_RECURSIVELY(selectSet, 'levelMinEdit'),
                GET_CHILD_RECURSIVELY(selectSet, 'levelMaxEdit')
            minEdit:SetText(minValue)
            maxEdit:SetText(maxValue)
        end
    end

    -- saveBtn
    local saveCheck = GET_CHILD_RECURSIVELY(frame, 'saveCheck')
    if saveCheck ~= nil then
        saveCheck:SetCheck(1)
    end

    local function ALIGN_ALL_CATEGORY(frame)
        local cateListBox = GET_CHILD_RECURSIVELY(frame, 'cateListBox')
        local selectedCtrlset = GET_CHILD_RECURSIVELY(frame, 'CATEGORY_' .. frame:GetUserValue('SELECTED_CATEGORY'))
        local subCateBox = GET_CHILD_RECURSIVELY(frame, 'detailBox')
        GBOX_AUTO_ALIGN(subCateBox, 0, 1, 0, true, true)
        ALIGN_CATEGORY_BOX(cateListBox, selectedCtrlset, subCateBox)
    end

    ALIGN_ALL_CATEGORY(frame)
    -- MARKET_REQ_LIST(frame)
    frame:RunUpdateScript("MARKET_REQ_LIST", 0.2)
    return true
end

function market_favorite_rebuild_delete_load_option(frame, ctrl, delete_text)

    local configKeyList = GetMarketCategoryConfigKeyList();

    for i = 1, #configKeyList do

        if configKeyList[i] ~= '' then
            local text = configKeyList[i]
            if delete_text == text then
                session.market.DeleteCategoryConfig(delete_text);
                break
            end
        end
    end
    for i = #g.settings.searchs, 1, -1 do
        local entry = g.settings.searchs[i]
        if entry and entry.key == delete_text then
            table.remove(g.settings.searchs, i)
            break
        end
    end
    market_favorite_rebuild_SAVE_SETTINGS()
    market_favorite_rebuild_TOGGLE_FRAME("true")
end

function market_favorite_rebuild_ON_LBUTTONDOWN(frame, ctrl, str, num)

    g.settings.items[num] = {}
    g.slot_index = num
    g.slot = ctrl
end

function market_favorite_rebuild_TOGGLE_FRAME(bool)

    if bool ~= "true" then
        ui.ToggleFrame('market_favorite_rebuild')
    end
    local frame = ui.GetFrame('market_favorite_rebuild')

    if frame:IsVisible() == 1 then
        frame:RemoveChild("slot_set")
        local slot_set = frame:CreateOrGetControl('slotset', 'slot_set', 15, 75, 0, 0)
        AUTO_CAST(slot_set)

        slot_set:SetColRow(7, 8)
        slot_set:SetSlotSize(50, 50)
        slot_set:EnableDrag(1)
        slot_set:EnableDrop(1)
        slot_set:EnablePop(1)
        slot_set:SetSpc(0, 0)
        slot_set:SetSkinName('invenslot2')

        slot_set:CreateSlots()
        local slotCount = slot_set:GetSlotCount()

        for i = 1, slotCount do

            local slot = slot_set:GetSlotByIndex(i - 1)
            slot:SetEventScript(ui.RBUTTONDOWN, 'market_favorite_rebuild_ON_RCLICK')
            slot:SetEventScriptArgNumber(ui.RBUTTONDOWN, i)
            slot:SetEventScript(ui.DROP, 'market_favorite_rebuild_ON_DROP')
            slot:SetEventScriptArgNumber(ui.DROP, i)
            slot:SetEventScript(ui.LBUTTONDOWN, 'market_favorite_rebuild_ON_LBUTTONDOWN')
            slot:SetEventScriptArgNumber(ui.LBUTTONDOWN, i)
            if g.settings.items then
                local item = g.settings.items[i]
                if item and item['clsid'] then
                    slot:SetUserValue('clsid', tostring(item['clsid']))

                    local item_cls = GetClassByType("Item", item['clsid'])
                    SET_SLOT_ITEM_CLS(slot, item_cls)
                    SET_SLOT_STYLESET(slot, item_cls)
                else
                    g.settings.items[i] = {}
                end
            end

        end
        -- market_favorite_rebuild_LOADFROMSTRUCTURE()
        for i = 1, 18 do
            local search_btn = GET_CHILD(frame, 'search_btn' .. i)
            if search_btn then
                frame:RemoveChild(search_btn)
            end
        end

        local x = 15
        local y = 530
        for i = 1, 18 do
            local search_btn = frame:CreateOrGetControl('button', 'search_btn' .. i, x, y, 30, 25)
            AUTO_CAST(search_btn)
            search_btn:SetText("{ol}" .. i)
            if g.settings.searchs and g.settings.searchs[i] then
                local key = g.settings.searchs[i].key

                local text = g.lang == "Japanese" and
                                 "{ol}左クリック:オプション呼出{nl}右クリック:オプション削除" or
                                 "{ol}Left-click: Recall Option{nl}Right-click: Delete Option"

                search_btn:SetTextTooltip("{ol}" .. key .. "{nl}" .. text)
                search_btn:SetEventScript(ui.LBUTTONUP, "market_favorite_rebuild_MARKET_LOAD_CATEGORY_OPTION")
                search_btn:SetEventScriptArgString(ui.LBUTTONUP, key)

                search_btn:SetEventScript(ui.RBUTTONUP, "market_favorite_rebuild_delete_load_option")
                search_btn:SetEventScriptArgString(ui.RBUTTONUP, key)

                search_btn:SetSkinName("test_red_button")
            else
                local text = g.lang == "Japanese" and "{ol}保存されたオプションはありません" or
                                 "{ol}No saved Option"
                search_btn:SetTextTooltip(text)
                search_btn:SetSkinName('test_gray_button')
            end

            x = x + 35
            if i == 10 then
                x = 15
                y = 560
            end
            search_btn:ShowWindow(1)
        end
        slot_set:ShowWindow(1)
    end
    market_favorite_rebuild_SAVE_SETTINGS()

    local tips = frame:CreateOrGetControl('richtext', "tips", 15, 480, 95, 25)
    AUTO_CAST(tips)
    local text = g.lang == "Japanese" and
                     "{ol}右クリック: マーケット検索{nl}LSHIFT+右クリック: スロット初期化" or
                     "{ol}Right-click: Market Search{nl}LSHIFT + Right-click: Initialize Slot"
    tips:SetText(text)

    local always_check = frame:CreateOrGetControl('checkbox', "always_check", 15, 600, 25, 25)
    AUTO_CAST(always_check)
    local text = g.lang == "Japanese" and "{ol}チェックすると自動表示" or "{ol}Check to auto-display"
    always_check:SetText(text)
    always_check:SetCheck(g.settings.always or 0)
    always_check:SetEventScript(ui.LBUTTONUP, "market_favorite_rebuild_toggle_check")

    local move_check = frame:CreateOrGetControl('checkbox', "move_check", 15, 630, 25, 25)
    AUTO_CAST(move_check)
    local text = g.lang == "Japanese" and "{ol}チェック外すとフレーム固定" or "{ol}Uncheck to lock frame"
    move_check:SetText(text)
    move_check:SetCheck(g.settings.move or 1)
    move_check:SetEventScript(ui.LBUTTONUP, "market_favorite_rebuild_toggle_check")

    local xBtn = GET_CHILD_RECURSIVELY(frame, "xBtn")
    AUTO_CAST(xBtn)
    xBtn:SetEventScript(ui.LBUTTONUP, "market_favorite_rebuild_CLOSE")
    -- market_favorite_rebuild_CLOSE()
    frame:Resize(frame:GetWidth(), 670)

end

function market_favorite_rebuild_toggle_check(frame, ctrl)
    local is_check = ctrl:IsChecked()
    local ctrl_name = ctrl:GetName()
    if ctrl_name == "always_check" then
        if is_check == 1 then
            g.settings.always = 1
        else
            g.settings.always = 0
        end
    end

    if ctrl_name == "move_check" then
        if is_check == 1 then
            g.settings.move = 1
            frame:EnableMove(1)
        else
            g.settings.move = 0
            frame:EnableMove(0)
        end
    end
    market_favorite_rebuild_SAVE_SETTINGS()
    market_favorite_rebuild_TOGGLE_FRAME("true")
end

function market_favorite_rebuild_END_DRAG(frame)
    g.settings.position.x = frame:GetX()
    g.settings.position.y = frame:GetY()
    market_favorite_rebuild_SAVE_SETTINGS()
end

function market_favorite_rebuild_ON_OPEN_MARKET(frame, msg)

    frame = ui.GetFrame('market_favorite_rebuild')
    frame:Move(0, 0)
    frame:SetOffset(g.settings.position.x, g.settings.position.y)
    frame:ShowWindow(0)
    frame:SetEventScript(ui.LBUTTONUP, 'market_favorite_rebuild_END_DRAG')
    frame:EnableMove(g.settings.move or 1)
    if g.settings.always == 1 then
        market_favorite_rebuild_TOGGLE_FRAME()
        frame:ShowWindow(1)
    end

    local market = ui.GetFrame("market")
    local open_btn = market:CreateOrGetControl("button", "open_btn", 610, 120, 100, 30)
    AUTO_CAST(open_btn)
    open_btn:SetSkinName("tab2_btn")
    local text = g.lang == "Japanese" and "{@st66b18}お気に入り" or "{@st66b18}Favorites"
    open_btn:SetText(text)
    open_btn:SetEventScript(ui.LBUTTONUP, "market_favorite_rebuild_TOGGLE_FRAME")
    -- market_favorite_rebuild_INIT_FRAME(frame)
end

function market_favorite_rebuild_CLOSE(frame)
    frame:ShowWindow(0)
    -- ui.GetFrame('market_favorite_rebuild'):ShowWindow(0)
end

function market_favorite_rebuild__MARKET_SAVE_CATEGORY_OPTION(my_frame, my_msg)

    local frame, configKey, orderByDesc, searchText, category, optionKey, optionValue = g.get_event_args(my_msg)
    local format_str = "%s:%s:%s:%s:%s:%s:%s"

    if type(g.settings.searchs) ~= "table" then
        g.settings.searchs = {}
    end

    local key_str = tostring(configKey)
    if not key_str then
        return
    end

    local serialize_val = string.format('order:%s@searchText:%s@category:%s', tostring(orderByDesc),
        tostring(searchText), tostring(category))
    if optionKey and optionValue then
        for i = 1, #optionKey do
            serialize_val = serialize_val .. '@' .. tostring(optionKey[i]) .. ':' .. tostring(optionValue[i])
        end
    end
    -- print("Key:" .. key_str .. "Value:" .. serialize_val)

    local new_entry = {
        key = key_str,
        value = serialize_val
    }

    table.insert(g.settings.searchs, new_entry)

    market_favorite_rebuild_SAVE_SETTINGS()
    market_favorite_rebuild_TOGGLE_FRAME("true")
end

function market_favorite_rebuild_ON_DROP(frame, slot, str, slot_index)

    local liftIcon = ui.GetLiftIcon()
    local liftParent = liftIcon:GetParent()
    local slot = tolua.cast(slot, 'ui::CSlot')
    local iconInfo = liftIcon:GetInfo()

    local invitem = GET_ITEM_BY_GUID(iconInfo:GetIESID())

    if iconInfo == nil or slot == nil or invitem == nil then

        return
    end
    local itemobj = GetIES(invitem:GetObject())
    if (iconInfo:GetIESID() == '0') then

        if (liftParent:GetName() == 'pic') then
            local parent = liftParent:GetParent()
            while (string.starts(parent:GetName(), 'ITEM') == false) do
                parent = parent:GetParent()
                if (parent == nil) then
                    CHAT_SYSTEM('失敗')
                    return
                end
            end

            local row = tonumber(parent:GetUserValue('DETAIL_ROW'))
            local marketItem = session.market.GetItemByIndex(row)
            local obj = GetIES(marketItem:GetObject())
            local item_cls = GetClassByType("Item", obj.ClassID)

            if item_cls then
                slot:SetUserValue('clsid', tostring(obj.ClassID))
                g.settings.items[slot_index] = {
                    ["clsid"] = obj.ClassID
                }
                SET_SLOT_ITEM_CLS(slot, item_cls)
                SET_SLOT_STYLESET(slot, item_cls)

            end
        else
            if g.slot_index then

                local cls_id = g.slot:GetUserValue("clsid")

                local drop_clsid = slot:GetUserValue("clsid")
                local item_cls = GetClassByType("Item", cls_id)
                if item_cls then

                    slot:SetUserValue('clsid', tostring(cls_id))
                    g.settings.items[slot_index] = {
                        ["clsid"] = cls_id
                    }
                    SET_SLOT_ITEM_CLS(slot, item_cls)
                    SET_SLOT_STYLESET(slot, item_cls)

                    local drop_item_cls = GetClassByType("Item", drop_clsid)
                    if drop_item_cls then
                        g.slot:SetUserValue('clsid', tostring(drop_clsid))
                        g.settings.items[g.slot_index] = {
                            ["clsid"] = drop_clsid
                        }
                    else
                        g.settings.items[g.slot_index] = {}
                    end

                end
                g.slot_index = nil
                g.slot = nil
            end

        end
    else

        local item_cls = GetClassByType("Item", itemobj.ClassID)
        if item_cls then
            slot:SetUserValue('clsid', tostring(itemobj.ClassID))
            g.settings.items[slot_index] = {
                ["clsid"] = itemobj.ClassID
            }

            SET_SLOT_ITEM_CLS(slot, item_cls)
            SET_SLOT_STYLESET(slot, item_cls)

        end
    end
    market_favorite_rebuild_SAVE_SETTINGS()
    market_favorite_rebuild_TOGGLE_FRAME("true")
end

function market_favorite_rebuild_ON_RCLICK(frame, slot, argstr, argnum)

    if keyboard.IsKeyPressed('LSHIFT') == 1 then
        -- 削除モード

        g.settings.items[argnum] = {}

        market_favorite_rebuild_SAVE_SETTINGS()
        market_favorite_rebuild_TOGGLE_FRAME("true")
        -- market_favorite_rebuild_LOADFROMSTRUCTURE()
    else

        if (ui.GetFrame('market'):IsVisible() == 0) then
            CHAT_SYSTEM(L_("HavntopenMarket"))
            return
        end
        local frame = ui.GetFrame('market')
        local clsid = slot:GetUserValue('clsid')

        if (clsid == nil) then
            return
        end
        -- local iesid=slot:GetUserValue("iesid")

        local invitem = GetClassByType('Item', tonumber(clsid))
        if (invitem == nil) then
            return
        end
        MARKET_BUYMODE(frame)
        MARKET_INIT_CATEGORY(frame)
        -- MARKET_REFRESH_SEARCH_OPTION(frame, nil)

        local searchtext = GET_CHILD_RECURSIVELY(frame, 'searchEdit')
        AUTO_CAST(searchtext)
        local realname = dictionary.ReplaceDicIDInCompStr(invitem.Name)
        local cls_name = invitem.ClassName
        local armor = nil
        local weapon = nil

        if string.find(cls_name, "EP16_GoddessIcor_Weapon_high") or string.find(cls_name, "EP16_GoddessIcor_Weapon") or
            string.find(cls_name, "EP15_GoddessIcor_Weapon_high") or string.find(cls_name, "EP15_GoddessIcor_Weapon") then
            weapon = true
        elseif string.find(cls_name, "EP16_GoddessIcor_Armor_high") or string.find(cls_name, "EP16_GoddessIcor_Armor") or
            string.find(cls_name, "EP15_GoddessIcor_Armor_high") or string.find(cls_name, "EP15_GoddessIcor_Armor") then
            armor = true
        end

        if weapon or armor then
            local marketCategory = GET_CHILD_RECURSIVELY(frame, 'marketCategory')
            local bgBox = GET_CHILD(marketCategory, 'bgBox')

            local cateListBox = GET_CHILD_RECURSIVELY(marketCategory, 'cateListBox')
            cateListBox:RemoveAllChild()

            local function SORT_CATEGORY(categoryList, sortFunc)
                table.sort(categoryList, sortFunc)
                return categoryList
            end

            local marketCategorySortCriteria = { -- 숫자가 작은 순서로 나오고, 없는 애들은 밑에 감
                Weapon = 1,
                Armor = 2,
                Consume = 3,
                Accessory = 4,
                Recipe = 5,
                Card = 6,
                Misc = 7,
                Gem = 8
            }

            local categoryList = SORT_CATEGORY(GetMarketCategoryList('root'), function(lhs, rhs)
                local lhsValue = marketCategorySortCriteria[lhs]
                local rhsValue = marketCategorySortCriteria[rhs]

                if lhsValue == nil then
                    lhsValue = 200000000
                end
                if rhsValue == nil then
                    rhsValue = 200000000
                end

                return lhsValue < rhsValue
            end)

            for i = 0, #categoryList do
                local group
                if i == 0 then
                    group = 'IntegrateRetreive'
                else
                    group = categoryList[i]
                end
                local ctrlSet =
                    cateListBox:CreateControlSet("market_tree", "CATEGORY_" .. group, ui.LEFT, 0, 0, 0, 0, 0)
                AUTO_CAST(ctrlSet)

                local part = ctrlSet:GetChild("part")
                part:SetTextByKey("value", ClMsg(group))
                ctrlSet:SetUserValue('CATEGORY', group)
            end
            GBOX_AUTO_ALIGN(cateListBox, 0, 0, 0, true, false)

            local optionBox = GET_CHILD_RECURSIVELY(frame, 'optionBox')
            optionBox:ShowWindow(0)

            frame:SetUserValue('SELECTED_CATEGORY', 'None')
            frame:SetUserValue('SELECTED_SUB_CATEGORY', 'None')

            local categoryCtrlset = GET_CHILD_RECURSIVELY(frame, 'CATEGORY_' .. "OPTMisc")
            AUTO_CAST(categoryCtrlset)
            MARKET_CATEGORY_CLICK(categoryCtrlset, categoryCtrlset:GetChild('bgBox'), false, true)
            local subCategoryCtrlset = nil
            if weapon then
                subCategoryCtrlset = GET_CHILD_RECURSIVELY(frame, 'SUB_CATE_' .. "GoddessIcorWeapon")
            elseif armor then
                subCategoryCtrlset = GET_CHILD_RECURSIVELY(frame, 'SUB_CATE_' .. "GoddessIcorArmor")
            end
            AUTO_CAST(subCategoryCtrlset)
            MARKET_SUB_CATEOGRY_CLICK(subCategoryCtrlset:GetParent(), subCategoryCtrlset, true)
            local market_search = GET_CHILD_RECURSIVELY(frame, 'itemSearchSet')

            local searchEdit = GET_CHILD_RECURSIVELY(market_search, 'searchEdit')
            AUTO_CAST(searchEdit)

            local lang_code = g.judge_language(realname)
            if lang_code == "ko" or lang_code == "ja" then
                realname = g.truncate_text_by_byte_limit(realname, lang_code)

            elseif lang_code == "en" then
                realname = g.truncate_text_by_byte_limit(realname, lang_code)

            else
                return
            end

            searchEdit:SetText(realname)
            -- print(tostring(realname))
            frame:RunUpdateScript("MARKET_REQ_LIST", 0.1) -- (frame)
            return
        end
        local lang_code = g.judge_language(realname)
        if lang_code == "ko" or lang_code == "ja" then
            realname = g.truncate_text_by_byte_limit(realname, lang_code)

        elseif lang_code == "en" then
            realname = g.truncate_text_by_byte_limit(realname, lang_code)

        else
            return
        end

        searchtext:SetText(realname)
        MARKET_REQ_LIST(frame)
    end

end

--[==[function market_favorite_rebuild_ON_DROP(frame, ctrl, str, num)
    EBI_try_catch {
        try = function()
            local liftIcon = ui.GetLiftIcon()
            local liftParent = liftIcon:GetParent()
            local slot = tolua.cast(ctrl, 'ui::CSlot')
            local iconInfo = liftIcon:GetInfo()

            local invitem = GET_ITEM_BY_GUID(iconInfo:GetIESID())

            if iconInfo == nil or slot == nil or invitem == nil then

                return
            end
            local itemobj = GetIES(invitem:GetObject())
            if (iconInfo:GetIESID() == '0') then
                if (liftParent:GetName() == 'pic') then
                    local parent = liftParent:GetParent()
                    while (string.starts(parent:GetName(), 'ITEM') == false) do
                        parent = parent:GetParent()
                        if (parent == nil) then
                            CHAT_SYSTEM('失敗')
                            return
                        end
                    end

                    --[[local row = tonumber(parent:GetUserValue('DETAIL_ROW'))
                    local mySession = session.GetMySession()
                    local cid = mySession:GetCID()
                    local count = session.market.GetItemCount()]]
                    local row = tonumber(parent:GetUserValue('DETAIL_ROW'))
                    local marketItem = session.market.GetItemByIndex(row)
                    local obj = GetIES(marketItem:GetObject())

                    -- アイコンを生成
                    local item_cls = GetClassByType("Item", obj.ClassID)
                    -- IESを生成
                    if item_cls then
                        slot:SetUserValue('clsid', tostring(obj.ClassID))
                        g.settings.items[num] = {
                            ["clsid"] = obj.ClassID
                        }
                        SET_SLOT_ITEM_CLS(slot, item_cls)
                        SET_SLOT_STYLESET(slot, item_cls)

                    end
                else
                    return
                end
            else

                local item_cls = GetClassByType("Item", itemobj.ClassID)
                if item_cls then
                    slot:SetUserValue('clsid', tostring(itemobj.ClassID))
                    g.settings.items[num] = {
                        ["clsid"] = itemobj.ClassID
                    }

                    SET_SLOT_ITEM_CLS(slot, item_cls)
                    SET_SLOT_STYLESET(slot, item_cls)

                end
            end
            market_favorite_rebuild_SAVE_SETTINGS()
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
end]==]

--[[function market_favorite_rebuild_MARKET_ADD_SEARCH_OPTION_GROUP(my_frame, my_msg)

    local optionGroupSet, ctrl, hideDeleteCtrl = g.get_event_args(my_msg)

    local function GET_DETAIL_OPTION_CTRLSET_COUNT(optionGroupSet)
        local ctrlsetCnt = 0
        local childCnt = optionGroupSet:GetChildCount()
        for i = 0, childCnt - 1 do
            local child = optionGroupSet:GetChildByIndex(i)
            if string.find(child:GetName(), 'SELECT_') ~= nil and child:IsVisible() == 1 then
                ctrlsetCnt = ctrlsetCnt + 1
            end
        end
        return ctrlsetCnt
    end

    if GET_DETAIL_OPTION_CTRLSET_COUNT(optionGroupSet) >= 8 then
        return
    end

    local curSelectCnt = optionGroupSet:GetUserIValue('ADD_SELECT_COUNT')
    optionGroupSet:SetUserValue('ADD_SELECT_COUNT', curSelectCnt + 1)
    local childIdx = curSelectCnt
    local selectSet = optionGroupSet:CreateOrGetControlSet('market_option_group_select', 'SELECT_' .. childIdx, 0, 0)
    local minEdit = GET_CHILD_RECURSIVELY(selectSet, 'minEdit')
    local maxEdit = GET_CHILD_RECURSIVELY(selectSet, 'maxEdit')
    minEdit:SetText('0')
    maxEdit:SetText('')

    if hideDeleteCtrl == true then
        local deleteText = GET_CHILD(selectSet, 'deleteText')
        deleteText:ShowWindow(0)
        optionGroupSet:SetUserValue('HIDE_CHILD_INDEX', childIdx)
    else
        local hideChildIdx = optionGroupSet:GetUserValue('HIDE_CHILD_INDEX')
        local hideChild = GET_CHILD(optionGroupSet, 'SELECT_' .. hideChildIdx)
        if hideChild ~= nil then
            local hideDelText = GET_CHILD(hideChild, 'deleteText')
            hideDelText:ShowWindow(1)
            optionGroupSet:SetUserValue('HIDE_CHILD_INDEX', 'None')
        end
    end
    print(tostring("etst1"))
    local groupList = GET_CHILD(selectSet, 'groupList')
    MARKET_INIT_OPTION_GROUP_DROPLIST(groupList)

    local function ALIGN_OPTION_GROUP_SET(optionGroupSet)
        local Y_ADD_MARGIN = 6
        local staticText = GET_CHILD(optionGroupSet, 'staticText')
        local ypos = staticText:GetY() + staticText:GetHeight() + Y_ADD_MARGIN
        local childCnt = optionGroupSet:GetChildCount()

        local visibleSelectChildCount = 0
        local visibleChild = nil
        for i = 0, childCnt - 1 do
            local child = optionGroupSet:GetChildByIndex(i)
            if string.find(child:GetName(), 'SELECT_') ~= nil then
                child:SetOffset(child:GetX(), ypos)
                visibleChild = child
                ypos = ypos + child:GetHeight()
                visibleSelectChildCount = visibleSelectChildCount + 1
            end
        end
        local addOptionBtn = GET_CHILD(optionGroupSet, 'addOptionBtn')
        addOptionBtn:SetOffset(0, ypos)
        ypos = ypos + addOptionBtn:GetHeight() + Y_ADD_MARGIN
        optionGroupSet:Resize(optionGroupSet:GetWidth(), ypos)
        return visibleSelectChildCount, visibleChild
    end
    print(tostring(tostring(optionGroupSet)))
    ALIGN_OPTION_GROUP_SET(optionGroupSet)
    print(tostring("test2"))
    local function ALIGN_ALL_CATEGORY(frame)
        local cateListBox = GET_CHILD_RECURSIVELY(frame, 'cateListBox')
        local selectedCtrlset = GET_CHILD_RECURSIVELY(frame, 'CATEGORY_' .. frame:GetUserValue('SELECTED_CATEGORY'))
        local subCateBox = GET_CHILD_RECURSIVELY(frame, 'detailBox')
        GBOX_AUTO_ALIGN(subCateBox, 0, 1, 0, true, true)
        ALIGN_CATEGORY_BOX(cateListBox, selectedCtrlset, subCateBox)
    end
    ALIGN_ALL_CATEGORY(optionGroupSet:GetTopParentFrame())
    print(tostring(tostring(selectSet)))
    return selectSet
end]]
--[[function market_favorite_rebuild_get_market_guid(market_sell)

    local count = session.market.GetItemCount()

    print("--- Checking g.temp_tbl ---")
    for key, value in pairs(g.temp_tbl) do
        print(string.format("  Key: %s, Value: %s", tostring(key), tostring(value)))
    end
    print("---------------------------")

    for i = 0, count - 1 do
        local marketItem = session.market.GetItemByIndex(i)

        local market_guid = marketItem:GetMarketGuid()
        print(tostring(market_guid))
        if not g.temp_tbl[tostring(marketItem:GetMarketGuid())] then

            g.settings.sell_items[g.login_name][g.item_index].market_guid = market_guid
            market_favorite_rebuild_SAVE_SETTINGS()
            return 0
        end

    end
    return 0
end]]
--[[function g.utf8_sub(str, start_char, end_char)
    if not str or str == "" then
        return ""
    end

    -- end_charが省略された場合は、最後までを意味する
    end_char = end_char or -1

    -- utf8.offset(文字列, 文字インデックス, 開始バイト位置)
    -- 文字列の先頭から、指定した文字数分のオフセット（バイト位置）を取得する
    local start_byte = utf8.offset(str, start_char)

    -- もし開始位置が見つからなければ（範囲外）、空文字を返す
    if not start_byte then
        return ""
    end

    local end_byte
    if end_char == -1 then
        -- 終了位置が-1なら、最後までを意味するので引数を省略
        end_byte = -1
    else
        -- 終了位置の次の文字の開始バイト位置を取得
        local next_char_byte = utf8.offset(str, end_char + 1)
        if next_char_byte then
            -- 次の文字の開始位置の1つ手前が、終了文字の最後のバイト
            end_byte = next_char_byte - 1
        else
            -- 次の文字が見つからない = 最後の文字まで
            end_byte = -1
        end
    end

    if end_byte == -1 then
        return string.sub(str, start_byte)
    else
        return string.sub(str, start_byte, end_byte)
    end
end]]

--[==[local acutil = require('acutil')
-- デフォルト設定

-- 文字処理用

-- $Id: utf8.lua 179 2009-04-03 18:10:03Z pasta $
--
-- Provides UTF-8 aware string functions implemented in pure lua:
-- * utf8len(s)
-- * utf8sub(s, i, j)
-- * utf8reverse(s)
-- * utf8char(unicode)
-- * utf8unicode(s, i, j)
-- * utf8gensub(s, sub_len)
-- * utf8find(str, regex, init, plain)
-- * utf8match(str, regex, init)
-- * utf8gmatch(str, regex, all)
-- * utf8gsub(str, regex, repl, limit)
--
-- If utf8data.lua (containing the lower<->upper case mappings) is loaded, these
-- additional functions are available:
-- * utf8upper(s)
-- * utf8lower(s)
--
-- All functions behave as their non UTF-8 aware counterparts with the exception
-- that UTF-8 characters are used instead of bytes for all units.

--[[
Copyright (c) 2006-2007, Kyle Smith
All rights reserved.

Contributors:
	Alimov Stepan

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the author nor the names of its contributors may be
      used to endorse or promote products derived from this software without
      specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES LOSS OF USE, DATA, OR PROFITS OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

-- ABNF from RFC 3629
-- 
-- UTF8-octets = *( UTF8-char )
-- UTF8-char   = UTF8-1 / UTF8-2 / UTF8-3 / UTF8-4
-- UTF8-1      = %x00-7F
-- UTF8-2      = %xC2-DF UTF8-tail
-- UTF8-3      = %xE0 %xA0-BF UTF8-tail / %xE1-EC 2( UTF8-tail ) /
--               %xED %x80-9F UTF8-tail / %xEE-EF 2( UTF8-tail )
-- UTF8-4      = %xF0 %x90-BF 2( UTF8-tail ) / %xF1-F3 3( UTF8-tail ) /
--               %xF4 %x80-8F 2( UTF8-tail )
-- UTF8-tail   = %x80-BF
-- 

local byte = string.byte
local char = string.char
local dump = string.dump
local find = string.find
local format = string.format
local gmatch = string.gmatch
local gsub = string.gsub
local len = string.len
local lower = string.lower
local match = string.match
local rep = string.rep
local reverse = string.reverse
local sub = string.sub
local upper = string.upper

-- returns the number of bytes used by the UTF-8 character at byte i in s
-- also doubles as a UTF-8 character validator
local function utf8charbytes(s, i)
    -- argument defaults
    i = i or 1

    -- argument checking
    if type(s) ~= "string" then
        error("bad argument #1 to 'utf8charbytes' (string expected, got " .. type(s) .. ")")
    end
    if type(i) ~= "number" then
        error("bad argument #2 to 'utf8charbytes' (number expected, got " .. type(i) .. ")")
    end

    local c = byte(s, i)

    -- determine bytes needed for character, based on RFC 3629
    -- validate byte 1
    if c > 0 and c <= 127 then
        -- UTF8-1
        return 1

    elseif c >= 194 and c <= 223 then
        -- UTF8-2
        local c2 = byte(s, i + 1)

        if not c2 then
            error("UTF-8 string terminated early")
        end

        -- validate byte 2
        if c2 < 128 or c2 > 191 then
            error("Invalid UTF-8 character")
        end

        return 2

    elseif c >= 224 and c <= 239 then
        -- UTF8-3
        local c2 = byte(s, i + 1)
        local c3 = byte(s, i + 2)

        if not c2 or not c3 then
            error("UTF-8 string terminated early")
        end

        -- validate byte 2
        if c == 224 and (c2 < 160 or c2 > 191) then
            error("Invalid UTF-8 character")
        elseif c == 237 and (c2 < 128 or c2 > 159) then
            error("Invalid UTF-8 character")
        elseif c2 < 128 or c2 > 191 then
            error("Invalid UTF-8 character")
        end

        -- validate byte 3
        if c3 < 128 or c3 > 191 then
            error("Invalid UTF-8 character")
        end

        return 3

    elseif c >= 240 and c <= 244 then
        -- UTF8-4
        local c2 = byte(s, i + 1)
        local c3 = byte(s, i + 2)
        local c4 = byte(s, i + 3)

        if not c2 or not c3 or not c4 then
            error("UTF-8 string terminated early")
        end

        -- validate byte 2
        if c == 240 and (c2 < 144 or c2 > 191) then
            error("Invalid UTF-8 character")
        elseif c == 244 and (c2 < 128 or c2 > 143) then
            error("Invalid UTF-8 character")
        elseif c2 < 128 or c2 > 191 then
            error("Invalid UTF-8 character")
        end

        -- validate byte 3
        if c3 < 128 or c3 > 191 then
            error("Invalid UTF-8 character")
        end

        -- validate byte 4
        if c4 < 128 or c4 > 191 then
            error("Invalid UTF-8 character")
        end

        return 4

    else
        error("Invalid UTF-8 character")
    end
end

-- returns the number of characters in a UTF-8 string
local function utf8len(s)
    -- argument checking
    if type(s) ~= "string" then
        for k, v in pairs(s) do
            print('"', tostring(k), '"', tostring(v), '"')
        end
        error("bad argument #1 to 'utf8len' (string expected, got " .. type(s) .. ")")
    end

    local pos = 1
    local bytes = len(s)
    local len = 0

    while pos <= bytes do
        len = len + 1
        pos = pos + utf8charbytes(s, pos)
    end

    return len
end

-- functions identically to string.sub except that i and j are UTF-8 characters
-- instead of bytes
local function utf8sub(s, i, j)
    -- argument defaults
    j = j or -1

    local pos = 1
    local bytes = len(s)
    local len = 0

    -- only set l if i or j is negative
    local l = (i >= 0 and j >= 0) or utf8len(s)
    local startChar = (i >= 0) and i or l + i + 1
    local endChar = (j >= 0) and j or l + j + 1

    -- can't have start before end!
    if startChar > endChar then
        return ""
    end

    -- byte offsets to pass to string.sub
    local startByte, endByte = 1, bytes

    while pos <= bytes do
        len = len + 1

        if len == startChar then
            startByte = pos
        end

        pos = pos + utf8charbytes(s, pos)

        if len == endChar then
            endByte = pos - 1
            break
        end
    end

    if startChar > len then
        startByte = bytes + 1
    end
    if endChar < 1 then
        endByte = 0
    end

    return sub(s, startByte, endByte)
end

-- replace UTF-8 characters based on a mapping table
local function utf8replace(s, mapping)
    -- argument checking
    if type(s) ~= "string" then
        error("bad argument #1 to 'utf8replace' (string expected, got " .. type(s) .. ")")
    end
    if type(mapping) ~= "table" then
        error("bad argument #2 to 'utf8replace' (table expected, got " .. type(mapping) .. ")")
    end

    local pos = 1
    local bytes = len(s)
    local charbytes
    local newstr = ""

    while pos <= bytes do
        charbytes = utf8charbytes(s, pos)
        local c = sub(s, pos, pos + charbytes - 1)

        newstr = newstr .. (mapping[c] or c)

        pos = pos + charbytes
    end

    return newstr
end

-- identical to string.upper except it knows about unicode simple case conversions
local function utf8upper(s)
    return utf8replace(s, utf8_lc_uc)
end

-- identical to string.lower except it knows about unicode simple case conversions
local function utf8lower(s)
    return utf8replace(s, utf8_uc_lc)
end

-- identical to string.reverse except that it supports UTF-8
local function utf8reverse(s)
    -- argument checking
    if type(s) ~= "string" then
        error("bad argument #1 to 'utf8reverse' (string expected, got " .. type(s) .. ")")
    end

    local bytes = len(s)
    local pos = bytes
    local charbytes
    local newstr = ""

    while pos > 0 do
        c = byte(s, pos)
        while c >= 128 and c <= 191 do
            pos = pos - 1
            c = byte(s, pos)
        end

        charbytes = utf8charbytes(s, pos)

        newstr = newstr .. sub(s, pos, pos + charbytes - 1)

        pos = pos - 1
    end

    return newstr
end

-- http://en.wikipedia.org/wiki/Utf8
-- http://developer.coronalabs.com/code/utf-8-conversion-utility
local function utf8char(unicode)
    if unicode <= 0x7F then
        return char(unicode)
    end

    if (unicode <= 0x7FF) then
        local Byte0 = 0xC0 + math.floor(unicode / 0x40)
        local Byte1 = 0x80 + (unicode % 0x40)
        return char(Byte0, Byte1)
    end

    if (unicode <= 0xFFFF) then
        local Byte0 = 0xE0 + math.floor(unicode / 0x1000)
        local Byte1 = 0x80 + (math.floor(unicode / 0x40) % 0x40)
        local Byte2 = 0x80 + (unicode % 0x40)
        return char(Byte0, Byte1, Byte2)
    end

    if (unicode <= 0x10FFFF) then
        local code = unicode
        local Byte3 = 0x80 + (code % 0x40)
        code = math.floor(code / 0x40)
        local Byte2 = 0x80 + (code % 0x40)
        code = math.floor(code / 0x40)
        local Byte1 = 0x80 + (code % 0x40)
        code = math.floor(code / 0x40)
        local Byte0 = 0xF0 + code

        return char(Byte0, Byte1, Byte2, Byte3)
    end

    error 'Unicode cannot be greater than U+10FFFF!'
end

local shift_6 = 2 ^ 6
local shift_12 = 2 ^ 12
local shift_18 = 2 ^ 18

local utf8unicode
utf8unicode = function(str, i, j, byte_pos)
    i = i or 1
    j = j or i

    if i > j then
        return
    end

    local char, bytes

    if byte_pos then
        bytes = utf8charbytes(str, byte_pos)
        char = sub(str, byte_pos, byte_pos - 1 + bytes)
    else
        char, byte_pos = utf8sub(str, i, i), 0
        bytes = #char
    end

    local unicode

    if bytes == 1 then
        unicode = byte(char)
    end
    if bytes == 2 then
        local byte0, byte1 = byte(char, 1, 2)
        local code0, code1 = byte0 - 0xC0, byte1 - 0x80
        unicode = code0 * shift_6 + code1
    end
    if bytes == 3 then
        local byte0, byte1, byte2 = byte(char, 1, 3)
        local code0, code1, code2 = byte0 - 0xE0, byte1 - 0x80, byte2 - 0x80
        unicode = code0 * shift_12 + code1 * shift_6 + code2
    end
    if bytes == 4 then
        local byte0, byte1, byte2, byte3 = byte(char, 1, 4)
        local code0, code1, code2, code3 = byte0 - 0xF0, byte1 - 0x80, byte2 - 0x80, byte3 - 0x80
        unicode = code0 * shift_18 + code1 * shift_12 + code2 * shift_6 + code3
    end

    return unicode, utf8unicode(str, i + 1, j, byte_pos + bytes)
end

-- Returns an iterator which returns the next substring and its byte interval
local function utf8gensub(str, sub_len)
    sub_len = sub_len or 1
    local byte_pos = 1
    local len = #str
    return function(skip)
        if skip then
            byte_pos = byte_pos + skip
        end
        local char_count = 0
        local start = byte_pos
        repeat
            if byte_pos > len then
                return
            end
            char_count = char_count + 1
            local bytes = utf8charbytes(str, byte_pos)
            byte_pos = byte_pos + bytes

        until char_count == sub_len

        local last = byte_pos - 1
        local sub = sub(str, start, last)
        return sub, start, last
    end
end

local function binsearch(sortedTable, item, comp)
    local head, tail = 1, #sortedTable
    local mid = math.floor((head + tail) / 2)
    if not comp then
        while (tail - head) > 1 do
            if sortedTable[tonumber(mid)] > item then
                tail = mid
            else
                head = mid
            end
            mid = math.floor((head + tail) / 2)
        end
    else
    end
    if sortedTable[tonumber(head)] == item then
        return true, tonumber(head)
    elseif sortedTable[tonumber(tail)] == item then
        return true, tonumber(tail)
    else
        return false
    end
end
local function classMatchGenerator(class, plain)
    local codes = {}
    local ranges = {}
    local ignore = false
    local range = false
    local firstletter = true
    local unmatch = false

    local it = utf8gensub(class)

    local skip
    for c, bs, be in it do
        skip = be
        if not ignore and not plain then
            if c == "%" then
                ignore = true
            elseif c == "-" then
                table.insert(codes, utf8unicode(c))
                range = true
            elseif c == "^" then
                if not firstletter then
                    error('!!!')
                else
                    unmatch = true
                end
            elseif c == ']' then
                break
            else
                if not range then
                    table.insert(codes, utf8unicode(c))
                else
                    table.remove(codes) -- removing '-'
                    table.insert(ranges, {table.remove(codes), utf8unicode(c)})
                    range = false
                end
            end
        elseif ignore and not plain then
            if c == 'a' then -- %a: represents all letters. (ONLY ASCII)
                table.insert(ranges, {65, 90}) -- A - Z
                table.insert(ranges, {97, 122}) -- a - z
            elseif c == 'c' then -- %c: represents all control characters.
                table.insert(ranges, {0, 31})
                table.insert(codes, 127)
            elseif c == 'd' then -- %d: represents all digits.
                table.insert(ranges, {48, 57}) -- 0 - 9
            elseif c == 'g' then -- %g: represents all printable characters except space.
                table.insert(ranges, {1, 8})
                table.insert(ranges, {14, 31})
                table.insert(ranges, {33, 132})
                table.insert(ranges, {134, 159})
                table.insert(ranges, {161, 5759})
                table.insert(ranges, {5761, 8191})
                table.insert(ranges, {8203, 8231})
                table.insert(ranges, {8234, 8238})
                table.insert(ranges, {8240, 8286})
                table.insert(ranges, {8288, 12287})
            elseif c == 'l' then -- %l: represents all lowercase letters. (ONLY ASCII)
                table.insert(ranges, {97, 122}) -- a - z
            elseif c == 'p' then -- %p: represents all punctuation characters. (ONLY ASCII)
                table.insert(ranges, {33, 47})
                table.insert(ranges, {58, 64})
                table.insert(ranges, {91, 96})
                table.insert(ranges, {123, 126})
            elseif c == 's' then -- %s: represents all space characters.
                table.insert(ranges, {9, 13})
                table.insert(codes, 32)
                table.insert(codes, 133)
                table.insert(codes, 160)
                table.insert(codes, 5760)
                table.insert(ranges, {8192, 8202})
                table.insert(codes, 8232)
                table.insert(codes, 8233)
                table.insert(codes, 8239)
                table.insert(codes, 8287)
                table.insert(codes, 12288)
            elseif c == 'u' then -- %u: represents all uppercase letters. (ONLY ASCII)
                table.insert(ranges, {65, 90}) -- A - Z
            elseif c == 'w' then -- %w: represents all alphanumeric characters. (ONLY ASCII)
                table.insert(ranges, {48, 57}) -- 0 - 9
                table.insert(ranges, {65, 90}) -- A - Z
                table.insert(ranges, {97, 122}) -- a - z
            elseif c == 'x' then -- %x: represents all hexadecimal digits.
                table.insert(ranges, {48, 57}) -- 0 - 9
                table.insert(ranges, {65, 70}) -- A - F
                table.insert(ranges, {97, 102}) -- a - f
            else
                if not range then
                    table.insert(codes, utf8unicode(c))
                else
                    table.remove(codes) -- removing '-'
                    table.insert(ranges, {table.remove(codes), utf8unicode(c)})
                    range = false
                end
            end
            ignore = false
        else
            if not range then
                table.insert(codes, utf8unicode(c))
            else
                table.remove(codes) -- removing '-'
                table.insert(ranges, {table.remove(codes), utf8unicode(c)})
                range = false
            end
            ignore = false
        end

        firstletter = false
    end

    table.sort(codes)

    local function inRanges(charCode)
        for _, r in ipairs(ranges) do
            if r[1] <= charCode and charCode <= r[2] then
                return true
            end
        end
        return false
    end
    if not unmatch then
        return function(charCode)
            return binsearch(codes, charCode) or inRanges(charCode)
        end, skip
    else
        return function(charCode)
            return charCode ~= -1 and not (binsearch(codes, charCode) or inRanges(charCode))
        end, skip
    end
end

-- utf8sub with extra argument, and extra result value 
local function utf8subWithBytes(s, i, j, sb)
    -- argument defaults
    j = j or -1

    local pos = sb or 1
    local bytes = len(s)
    local len = 0

    -- only set l if i or j is negative
    local l = (i >= 0 and j >= 0) or utf8len(s)
    local startChar = (i >= 0) and i or l + i + 1
    local endChar = (j >= 0) and j or l + j + 1

    -- can't have start before end!
    if startChar > endChar then
        return ""
    end

    -- byte offsets to pass to string.sub
    local startByte, endByte = 1, bytes

    while pos <= bytes do
        len = len + 1

        if len == startChar then
            startByte = pos
        end

        pos = pos + utf8charbytes(s, pos)

        if len == endChar then
            endByte = pos - 1
            break
        end
    end

    if startChar > len then
        startByte = bytes + 1
    end
    if endChar < 1 then
        endByte = 0
    end

    return sub(s, startByte, endByte), endByte + 1
end

local cache = setmetatable({}, {
    __mode = 'kv'
})
local cachePlain = setmetatable({}, {
    __mode = 'kv'
})
local function matcherGenerator(regex, plain)
    local matcher = {
        functions = {},
        captures = {}
    }
    if not plain then
        cache[regex] = matcher
    else
        cachePlain[regex] = matcher
    end
    local function simple(func)
        return function(cC)
            if func(cC) then
                matcher:nextFunc()
                matcher:nextStr()
            else
                matcher:reset()
            end
        end
    end
    local function star(func)
        return function(cC)
            if func(cC) then
                matcher:fullResetOnNextFunc()
                matcher:nextStr()
            else
                matcher:nextFunc()
            end
        end
    end
    local function minus(func)
        return function(cC)
            if func(cC) then
                matcher:fullResetOnNextStr()
            end
            matcher:nextFunc()
        end
    end
    local function question(func)
        return function(cC)
            if func(cC) then
                matcher:fullResetOnNextFunc()
                matcher:nextStr()
            end
            matcher:nextFunc()
        end
    end

    local function capture(id)
        return function(cC)
            local l = matcher.captures[id][2] - matcher.captures[id][1]
            local captured = utf8sub(matcher.string, matcher.captures[id][1], matcher.captures[id][2])
            local check = utf8sub(matcher.string, matcher.str, matcher.str + l)
            if captured == check then
                for i = 0, l do
                    matcher:nextStr()
                end
                matcher:nextFunc()
            else
                matcher:reset()
            end
        end
    end
    local function captureStart(id)
        return function(cC)
            matcher.captures[id][1] = matcher.str
            matcher:nextFunc()
        end
    end
    local function captureStop(id)
        return function(cC)
            matcher.captures[id][2] = matcher.str - 1
            matcher:nextFunc()
        end
    end

    local function balancer(str)
        local sum = 0
        local bc, ec = utf8sub(str, 1, 1), utf8sub(str, 2, 2)
        local skip = len(bc) + len(ec)
        bc, ec = utf8unicode(bc), utf8unicode(ec)
        return function(cC)
            if cC == ec and sum > 0 then
                sum = sum - 1
                if sum == 0 then
                    matcher:nextFunc()
                end
                matcher:nextStr()
            elseif cC == bc then
                sum = sum + 1
                matcher:nextStr()
            else
                if sum == 0 or cC == -1 then
                    sum = 0
                    matcher:reset()
                else
                    matcher:nextStr()
                end
            end
        end, skip
    end

    matcher.functions[1] = function(cC)
        matcher:fullResetOnNextStr()
        matcher.seqStart = matcher.str
        matcher:nextFunc()
        if (matcher.str > matcher.startStr and matcher.fromStart) or matcher.str >= matcher.stringLen then
            matcher.stop = true
            matcher.seqStart = nil
        end
    end

    local lastFunc
    local ignore = false
    local skip = nil
    local it = (function()
        local gen = utf8gensub(regex)
        return function()
            return gen(skip)
        end
    end)()
    local cs = {}
    for c, bs, be in it do
        skip = nil
        if plain then
            table.insert(matcher.functions, simple(classMatchGenerator(c, plain)))
        else
            if ignore then
                if find('123456789', c, 1, true) then
                    if lastFunc then
                        table.insert(matcher.functions, simple(lastFunc))
                        lastFunc = nil
                    end
                    table.insert(matcher.functions, capture(tonumber(c)))
                elseif c == 'b' then
                    if lastFunc then
                        table.insert(matcher.functions, simple(lastFunc))
                        lastFunc = nil
                    end
                    local b
                    b, skip = balancer(sub(regex, be + 1, be + 9))
                    table.insert(matcher.functions, b)
                else
                    lastFunc = classMatchGenerator('%' .. c)
                end
                ignore = false
            else
                if c == '*' then
                    if lastFunc then
                        table.insert(matcher.functions, star(lastFunc))
                        lastFunc = nil
                    else
                        error('invalid regex after ' .. sub(regex, 1, bs))
                    end
                elseif c == '+' then
                    if lastFunc then
                        table.insert(matcher.functions, simple(lastFunc))
                        table.insert(matcher.functions, star(lastFunc))
                        lastFunc = nil
                    else
                        error('invalid regex after ' .. sub(regex, 1, bs))
                    end
                elseif c == '-' then
                    if lastFunc then
                        table.insert(matcher.functions, minus(lastFunc))
                        lastFunc = nil
                    else
                        error('invalid regex after ' .. sub(regex, 1, bs))
                    end
                elseif c == '?' then
                    if lastFunc then
                        table.insert(matcher.functions, question(lastFunc))
                        lastFunc = nil
                    else
                        error('invalid regex after ' .. sub(regex, 1, bs))
                    end
                elseif c == '^' then
                    if bs == 1 then
                        matcher.fromStart = true
                    else
                        error('invalid regex after ' .. sub(regex, 1, bs))
                    end
                elseif c == '$' then
                    if be == len(regex) then
                        matcher.toEnd = true
                    else
                        error('invalid regex after ' .. sub(regex, 1, bs))
                    end
                elseif c == '[' then
                    if lastFunc then
                        table.insert(matcher.functions, simple(lastFunc))
                    end
                    lastFunc, skip = classMatchGenerator(sub(regex, be + 1))
                elseif c == '(' then
                    if lastFunc then
                        table.insert(matcher.functions, simple(lastFunc))
                        lastFunc = nil
                    end
                    table.insert(matcher.captures, {})
                    table.insert(cs, #matcher.captures)
                    table.insert(matcher.functions, captureStart(cs[#cs]))
                    if sub(regex, be + 1, be + 1) == ')' then
                        matcher.captures[#matcher.captures].empty = true
                    end
                elseif c == ')' then
                    if lastFunc then
                        table.insert(matcher.functions, simple(lastFunc))
                        lastFunc = nil
                    end
                    local cap = table.remove(cs)
                    if not cap then
                        error('invalid capture: "(" missing')
                    end
                    table.insert(matcher.functions, captureStop(cap))
                elseif c == '.' then
                    if lastFunc then
                        table.insert(matcher.functions, simple(lastFunc))
                    end
                    lastFunc = function(cC)
                        return cC ~= -1
                    end
                elseif c == '%' then
                    ignore = true
                else
                    if lastFunc then
                        table.insert(matcher.functions, simple(lastFunc))
                    end
                    lastFunc = classMatchGenerator(c)
                end
            end
        end
    end
    if #cs > 0 then
        error('invalid capture: ")" missing')
    end
    if lastFunc then
        table.insert(matcher.functions, simple(lastFunc))
    end
    lastFunc = nil
    ignore = nil

    table.insert(matcher.functions, function()
        if matcher.toEnd and matcher.str ~= matcher.stringLen then
            matcher:reset()
        else
            matcher.stop = true
        end
    end)

    matcher.nextFunc = function(self)
        self.func = self.func + 1
    end
    matcher.nextStr = function(self)
        self.str = self.str + 1
    end
    matcher.strReset = function(self)
        local oldReset = self.reset
        local str = self.str
        self.reset = function(s)
            s.str = str
            s.reset = oldReset
        end
    end
    matcher.fullResetOnNextFunc = function(self)
        local oldReset = self.reset
        local func = self.func + 1
        local str = self.str
        self.reset = function(s)
            s.func = func
            s.str = str
            s.reset = oldReset
        end
    end
    matcher.fullResetOnNextStr = function(self)
        local oldReset = self.reset
        local str = self.str + 1
        local func = self.func
        self.reset = function(s)
            s.func = func
            s.str = str
            s.reset = oldReset
        end
    end

    matcher.process = function(self, str, start)

        self.func = 1
        start = start or 1
        self.startStr = (start >= 0) and start or utf8len(str) + start + 1
        self.seqStart = self.startStr
        self.str = self.startStr
        self.stringLen = utf8len(str) + 1
        self.string = str
        self.stop = false

        self.reset = function(s)
            s.func = 1
        end

        local lastPos = self.str
        local lastByte
        local char
        while not self.stop do
            if self.str < self.stringLen then
                --[[ if lastPos < self.str then
					print('last byte', lastByte)
					char, lastByte = utf8subWithBytes(str, 1, self.str - lastPos - 1, lastByte)
					char, lastByte = utf8subWithBytes(str, 1, 1, lastByte)
					lastByte = lastByte - 1
				else
					char, lastByte = utf8subWithBytes(str, self.str, self.str)
				end
				lastPos = self.str ]]
                char = utf8sub(str, self.str, self.str)
                -- print('char', char, utf8unicode(char))
                self.functions[self.func](utf8unicode(char))
            else
                self.functions[self.func](-1)
            end
        end

        if self.seqStart then
            local captures = {}
            for _, pair in pairs(self.captures) do
                if pair.empty then
                    table.insert(captures, pair[1])
                else
                    table.insert(captures, utf8sub(str, pair[1], pair[2]))
                end
            end
            return self.seqStart, self.str - 1, unpack(captures)
        end
    end

    return matcher
end

-- string.find
local function utf8find(str, regex, init, plain)
    local matcher = cache[regex] or matcherGenerator(regex, plain)
    return matcher:process(str, init)
end

-- string.match
local function utf8match(str, regex, init)
    init = init or 1
    local found = {utf8find(str, regex, init)}
    if found[1] then
        if found[3] then
            return unpack(found, 3)
        end
        return utf8sub(str, found[1], found[2])
    end
end

-- string.gmatch
local function utf8gmatch(str, regex, all)
    regex = (utf8sub(regex, 1, 1) ~= '^') and regex or '%' .. regex
    local lastChar = 1
    return function()
        local found = {utf8find(str, regex, lastChar)}
        if found[1] then
            lastChar = found[2] + 1
            if found[all and 1 or 3] then
                return unpack(found, all and 1 or 3)
            end
            return utf8sub(str, found[1], found[2])
        end
    end
end

local function replace(repl, args)
    local ret = ''
    if type(repl) == 'string' then
        local ignore = false
        local num = 0
        for c in utf8gensub(repl) do
            if not ignore then
                if c == '%' then
                    ignore = true
                else
                    ret = ret .. c
                end
            else
                num = tonumber(c)
                if num then
                    ret = ret .. args[num]
                else
                    ret = ret .. c
                end
                ignore = false
            end
        end
    elseif type(repl) == 'table' then
        ret = repl[args[1] or args[0]] or ''
    elseif type(repl) == 'function' then
        if #args > 0 then
            ret = repl(unpack(args, 1)) or ''
        else
            ret = repl(args[0]) or ''
        end
    end
    return ret
end
-- string.gsub
local function utf8gsub(str, regex, repl, limit)
    limit = limit or -1
    local ret = ''
    local prevEnd = 1
    local it = utf8gmatch(str, regex, true)
    local found = {it()}
    local n = 0
    while #found > 0 and limit ~= n do
        local args = {
            [0] = utf8sub(str, found[1], found[2]),
            unpack(found, 3)
        }
        ret = ret .. utf8sub(str, prevEnd, found[1] - 1) .. replace(repl, args)
        prevEnd = found[2] + 1
        n = n + 1
        found = {it()}
    end
    return ret .. utf8sub(str, prevEnd), n
end

---------

local translationtable = {
    Favorites = {
        jp = "お気に入り",
        en = "Favorites"
    },
    HavntopenMarket = {
        jp = "マーケット画面を開いていません",
        en = "Please open the market window."
    }
}

local function L_(str)
    if (option.GetCurrentCountry() == "Japanese") then
        return translationtable[str].jp
    else
        return translationtable[str].en
    end
end

--[[function market_favorite_rebuild_SAVETOSTRUCTURE()
    local frame = ui.GetFrame('market_favorite_rebuild')
    if (frame == nil) then
        return
    end
    local slotset = frame:GetChild('slot_set')
    if (slotset == nil) then
        return
    end
    slotset = tolua.cast(slotset, 'ui::CSlotSet')

    for i = 0, slotset:GetSlotCount() - 1 do
        local slot = slotset:GetSlotByIndex(i)
        if (slot ~= nil) then
            local val = slot:GetUserValue('clsid')
            g.settings.items[i + 1] = {
                clsid = tonumber(val)
            }

        else

            g.settings.items[i + 1] = nil
        end
    end
end
function market_favorite_rebuild_LOADFROMSTRUCTURE()
    local frame = ui.GetFrame('market_favorite_rebuild')
    if (frame == nil or g.settings.items == nil) then
        return
    end

    local obj = frame:GetChild('slot_set')
    local slotset = tolua.cast(obj, 'ui::CSlotSet')
    if (slotset == nil) then
        return
    end
    slotset:ClearIconAll()

    for i = 0, slotset:GetSlotCount() - 1 do
        -- statements
        local slot = slotset:GetSlotByIndex(i)
        if (slot ~= nil) then
            slot:SetText("")
            slot:RemoveAllChild()
            slot:SetSkinName('invenslot2')
        end
    end
    for i = 1, #g.settings.items do
        EBI_try_catch {
            try = function()

                local item = g.settings.items[i]
                if (item ~= nil) then

                    local slot = slotset:GetSlotByIndex(i - 1)
                    if (item['clsid'] ~= nil) then
                        slot:SetUserValue('clsid', tostring(item['clsid']))
                        -- アイコンを生成
                        local invitem = GetClassByType("Item", item['clsid'])

                        SET_SLOT_ITEM_CLS(slot, invitem)
                        SET_SLOT_STYLESET(slot, invitem)
                    end
                end
            end,
            catch = function(error)
                CHAT_SYSTEM(error)
            end
        }
    end
end]]
--[[function market_favorite_rebuild_INIT_FRAME(frame)
    EBI_try_catch {
        try = function()

        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
end]]
--[[function market_favorite_rebuild_MARKET_ITEMLIST_JUMPER(frame, msg, argStr, argNum)
    if (OLD_ON_MARKET_ITEM_LIST ~= nil) then
        OLD_ON_MARKET_ITEM_LIST(frame, msg, argStr, argNum)
    end
    market_favorite_rebuild_MARKET_ITEMLIST(frame)
end
function market_favorite_rebuild_MARKET_ITEMLIST(frame)
    EBI_try_catch {
        try = function()
            local frame = ui.GetFrame('market')

            for i = 0, 20 do
                -- statements
                local ctrl2 = GET_CHILD_RECURSIVELY(frame, 'ITEM2EQUIP_' .. tostring(i))
                local ctrl1 = GET_CHILD_RECURSIVELY(frame, 'ITEM_EQUIP_' .. tostring(i))
                local pic

                if (ctrl2 ~= nil) then
                    pic = GET_CHILD_RECURSIVELY(ctrl2, 'pic')
                elseif (ctrl1 ~= nil) then
                    -- statements

                    pic = GET_CHILD_RECURSIVELY(ctrl1, 'pic')
                end

            end
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
end]]
--[[function market_favorite_rebuild_MARKET_FIND_PAGE(frame, page)
    local function CLAMP_MARKET_PAGE_NUMBER(frame, pageControllerName, page)
        if page == nil then
            return 0
        end
        local pagecontrol = GET_CHILD(frame, pageControllerName)
        local MaxPage = pagecontrol:GetMaxPage()
        if page >= MaxPage then
            page = MaxPage - 1
        elseif page <= 0 then
            page = 0
        end
        return page
    end

    page = CLAMP_MARKET_PAGE_NUMBER(frame, 'pagecontrol', page)

    local function GET_SEARCH_PRICE_ORDER(frame)
        local priceOrderCheck_0 = GET_CHILD_RECURSIVELY(frame, 'priceOrderCheck_0')
        local priceOrderCheck_1 = GET_CHILD_RECURSIVELY(frame, 'priceOrderCheck_1')
        if priceOrderCheck_0 == nil or priceOrderCheck_1 == nil then
            return -1
        end

        if priceOrderCheck_0:IsChecked() == 1 then
            return 0
        end
        if priceOrderCheck_1:IsChecked() == 1 then
            return 1
        end
        return 0 -- default
    end

    local orderByDesc = GET_SEARCH_PRICE_ORDER(frame)
    if orderByDesc < 0 then
        return
    end

    local function GET_SEARCH_TEXT(frame)
        local defaultValue = ''
        local market_search = GET_CHILD_RECURSIVELY(frame, 'itemSearchSet')
        if market_search ~= nil and market_search:IsVisible() == 1 then
            local searchEdit = GET_CHILD_RECURSIVELY(market_search, 'searchEdit')
            local findItem = searchEdit:GetText()
            local minLength = 0
            local findItemStrLength = findItem.len(findItem)
            local maxLength = 120
            if config.GetServiceNation() == "GLOBAL" then
                minLength = 1
                maxLength = 40
            elseif config.GetServiceNation() == "JPN" then
                maxLength = 120
            elseif config.GetServiceNation() == "KOR" then
                maxLength = 120
            end
            if findItemStrLength ~= 0 then -- 있다면 길이 조건 체크
                if findItemStrLength <= minLength then
                    ui.SysMsg(ClMsg("InvalidFindItemQueryMin"))
                    return defaultValue
                elseif findItemStrLength > maxLength then
                    ui.SysMsg(ClMsg("InvalidFindItemQueryMax"))
                    return defaultValue
                end
            end
            return findItem
        end
        return defaultValue
    end

    local searchText = GET_SEARCH_TEXT(frame)
    local category, _category, _subCategory = GET_CATEGORY_STRING(frame)
    if category == '' and searchText == '' then
        return
    end

    if searchText ~= '' and ui.GetPaperLength(searchText) < 2 then
        ui.SysMsg(ClMsg('InvalidFindItemQueryMin'))
        return
    end

    local function GET_SEARCH_OPTION(frame)
        local optionName, optionValue = {}, {}
        local optionSet = {} -- for checking duplicate option
        local category = frame:GetUserValue('SELECTED_CATEGORY')

        -- level range
        local levelRangeSet = GET_CHILD_RECURSIVELY(frame, 'levelRangeSet')
        if levelRangeSet ~= nil and levelRangeSet:IsVisible() == 1 then
            local minEdit = GET_CHILD_RECURSIVELY(levelRangeSet, 'minEdit')
            local maxEdit = GET_CHILD_RECURSIVELY(levelRangeSet, 'maxEdit')
            local opValue = GET_MINMAX_QUERY_VALUE_STRING(minEdit, maxEdit)
            if opValue ~= '' then
                local opName = 'CT_UseLv'
                if category == 'OPTMisc' then
                    opName = 'Level'
                end
                optionName[#optionName + 1] = opName
                optionValue[#optionValue + 1] = opValue
                optionSet[opName] = true
            end
        end

        -- grade
        local gradeCheckSet = GET_CHILD_RECURSIVELY(frame, 'gradeCheckSet')
        if gradeCheckSet ~= nil and gradeCheckSet:IsVisible() == 1 then
            local checkStr = ''
            local matchCnt, lastMatch = 0, nil
            local childCnt = gradeCheckSet:GetChildCount()
            for i = 0, childCnt - 1 do
                local child = gradeCheckSet:GetChildByIndex(i)
                if string.find(child:GetName(), 'gradeCheck_') ~= nil then
                    AUTO_CAST(child)
                    if child:IsChecked() == 1 then
                        local grade = string.sub(child:GetName(), string.find(child:GetName(), '_') + 1)
                        checkStr = checkStr .. grade .. ''
                        matchCnt = matchCnt + 1
                        lastMatch = grade
                    end
                end
            end
            if checkStr ~= '' then
                if matchCnt == 1 then
                    checkStr = checkStr .. lastMatch
                end
                local opName = 'CT_ItemGrade'
                optionName[#optionName + 1] = opName
                optionValue[#optionValue + 1] = checkStr
                optionSet[opName] = true
            end
        end

        -- random option flag
        local appCheckSet = GET_CHILD_RECURSIVELY(frame, 'appCheckSet')
        if appCheckSet ~= nil and appCheckSet:IsVisible() == 1 then
            local ranOpName, ranOpValue
            local appCheck_0 = GET_CHILD(appCheckSet, 'appCheck_0')
            if appCheck_0:IsChecked() == 1 then
                ranOpName = 'Random_Item'
                ranOpValue = '2'
            end

            local appCheck_1 = GET_CHILD(appCheckSet, 'appCheck_1')
            if appCheck_1:IsChecked() == 1 then
                ranOpName = 'Random_Item'
                ranOpValue = '1'
            end

            if ranOpName ~= nil then
                optionName[#optionName + 1] = ranOpName
                optionValue[#optionValue + 1] = ranOpValue
                optionSet[ranOpName] = true
            end
        end

        -- detail setting
        local detailOptionSet = GET_CHILD_RECURSIVELY(frame, 'detailOptionSet')
        if detailOptionSet ~= nil and detailOptionSet:IsVisible() == 1 then
            local curCnt = detailOptionSet:GetUserIValue('ADD_SELECT_COUNT')
            for i = 0, curCnt do
                local selectSet = GET_CHILD_RECURSIVELY(detailOptionSet, 'SELECT_' .. i)
                if selectSet ~= nil and selectSet:IsVisible() == 1 then
                    local nameList = GET_CHILD(selectSet, 'groupList')
                    local opName = nameList:GetSelItemKey()
                    if opName ~= '' then
                        local opValue = GET_MINMAX_QUERY_VALUE_STRING(GET_CHILD_RECURSIVELY(selectSet, 'minEdit'),
                            GET_CHILD_RECURSIVELY(selectSet, 'maxEdit'))
                        if opValue ~= '' and optionSet[opName] == nil then
                            optionName[#optionName + 1] = opName
                            optionValue[#optionValue + 1] = opValue
                            optionSet[opName] = true
                        end
                    end
                end
            end
        end

        -- option group
        local optionGroupSet = GET_CHILD_RECURSIVELY(frame, 'optionGroupSet')
        if optionGroupSet ~= nil and optionGroupSet:IsVisible() == 1 then
            local curCnt = optionGroupSet:GetUserIValue('ADD_SELECT_COUNT')
            for i = 0, curCnt do
                local selectSet = GET_CHILD_RECURSIVELY(optionGroupSet, 'SELECT_' .. i)
                if selectSet ~= nil then
                    local nameList = GET_CHILD(selectSet, 'nameList')
                    local opName = nameList:GetSelItemKey()
                    if opName ~= '' then
                        local opValue = GET_MINMAX_QUERY_VALUE_STRING(GET_CHILD_RECURSIVELY(selectSet, 'minEdit'),
                            GET_CHILD_RECURSIVELY(selectSet, 'maxEdit'))
                        if opValue ~= '' and optionSet[opName] == nil then
                            optionName[#optionName + 1] = opName
                            optionValue[#optionValue + 1] = opValue
                            optionSet[opName] = true
                        end
                    end
                end
            end
        end

        -- gem option
        local gemOptionSet = GET_CHILD_RECURSIVELY(frame, 'gemOptionSet')
        if gemOptionSet ~= nil and gemOptionSet:IsVisible() == 1 then
            local levelMinEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'levelMinEdit')
            local levelMaxEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'levelMaxEdit')
            local roastingMinEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'roastingMinEdit')
            local roastingMaxEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'roastingMaxEdit')
            if category == 'Gem' then
                local opValue = GET_MINMAX_QUERY_VALUE_STRING(levelMinEdit, levelMaxEdit)
                if opValue ~= '' then
                    optionName[#optionName + 1] = 'GemLevel'
                    optionValue[#optionValue + 1] = opValue
                    optionSet['GemLevel'] = true
                end

                local roastOpValue = GET_MINMAX_QUERY_VALUE_STRING(roastingMinEdit, roastingMaxEdit)
                if roastOpValue ~= '' then
                    optionName[#optionName + 1] = 'GemRoastingLv'
                    optionValue[#optionValue + 1] = roastOpValue
                    optionSet['GemRoastingLv'] = true
                end
            elseif category == 'Card' then
                local opValue = GET_MINMAX_QUERY_VALUE_STRING(levelMinEdit, levelMaxEdit)
                if opValue ~= '' then
                    optionName[#optionName + 1] = 'CardLevel'
                    optionValue[#optionValue + 1] = opValue
                    optionSet['CardLevel'] = true
                end
            end
        end

        return optionName, optionValue
    end

    local optionKey, optionValue = GET_SEARCH_OPTION(frame)
    local itemCntPerPage = GET_MARKET_SEARCH_ITEM_COUNT(_category)
    MarketSearch(page + 1, orderByDesc, searchText, category, optionKey, optionValue, itemCntPerPage)
    DISABLE_BUTTON_DOUBLECLICK_WITH_CHILD(frame:GetName(), 'commitSet', 'searchBtn', 1)
    MARKET_OPTION_BOX_CLOSE_CLICK(frame)
end

function market_favorite_rebuild_MARKET_REQ_LIST(frame)
    frame = frame:GetTopParentFrame()
    market_favorite_rebuild_MARKET_FIND_PAGE(frame, 0)
end]]

--[[function market_favorite_rebuild_TOGGLE_FRAME()
    if g.frame:IsVisible() == 0 then
        -- 非表示->表示
        g.frame:ShowWindow(1)
        g.settings.enable = true
    else
        -- 表示->非表示
        g.frame:ShowWindow(0)
        g.settings.show = false
    end

    market_favorite_rebuild_SAVE_SETTINGS()
end]]

-- フレーム場所保存処理
]==]
