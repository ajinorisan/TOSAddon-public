-- v1.0.0 Yet Another Account Inventoryの焼き直し。保守しやすい様、自分用にシンプルにした。
-- v1.0.1 アイテム、シルバーの自動搬出入機能追加
-- v1.0.2 搬入搬出高速化。ログ機能追加。設定画面閉じてもマウスカスタムファンクション保持していたバグ修正。
-- v1.0.3 warehousemanagerの設定ファイルをコピー出来る様に。自動設定をキャラ毎に。
-- v1.0.4 トークンの判定が環境によって安定しないためディレイを5秒に変更。入庫のディレイも設定できるように変更。
-- v1.0.5 セット出庫機能追加。設定スロット増設。
-- v1.0.6 キャラ毎設定スロット増設。入庫時のツールチップ修正
-- v1.0.7 設定スロットを999個に。アイコンクリック時の仕様変更。
-- v1.0.8 アイテム出庫を早くした。他の機能はまだ。
-- v1.0.9 用意出来たよのお知らせ。1個残すチェック付けた。
-- v1.1.0 なんか倉庫に入れるのめちゃ早くなった。なんでや？シルバーインプット付けた。セット取り出しバグ修正。
local addonName = "ANOTHER_WAREHOUSE"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.1.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.logpath = string.format('../addons/%s/log.txt', addonNameLower)

local acutil = require("acutil")
local json = require('json')
local os = require("os")
local base = {}

local function IsBlackListedTabName(name)
    return name == 'Quest'
end

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName];
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

function another_warehouse_load_settings()
    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    -- settingsがnilまたは空の場合は初期設定を使用する
    if not settings or next(settings) == nil then
        settings = {
            silver = 1000000,

            amount_check = 0,
            transfer = 0,
            items = {},
            delay = 0.5

        }
    elseif settings.delay == nil then
        settings.delay = 0.5
    end

    another_warehouse_save_settings()

    g.settings = settings

    local LoginName = session.GetMySession():GetPCApc():GetName()
    local LoginCID = info.GetCID(session.GetMyHandle())

    -- g.settings[g.logincid]がnilの場合は初期設定を使用する
    if not g.settings[LoginCID] then
        g.settings[LoginCID] = {
            maney_check = 1,
            item_check = 1,
            name = LoginName,
            items = {},
            transfer = 0
        }
        another_warehouse_save_settings()
    end
    another_warehouse_save_settings()
end

function another_warehouse_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function another_warehouse_lang(str)
    local language = option.GetCurrentCountry()
    if language == "Japanese" then
        if str == "[Another warehouse] is not available because the token has not been applied." then
            str = "トークンが適用されていないため、[Another warehouse]は利用できません。"
        end

        if str == "[Another Warehouse]{nl}Automatic warehousing setup" then
            str = "[Another Warehouse]{nl}自動倉庫設定"
        end

        if str == " Pieces in warehouse" then
            str = " 個搬入しました"
        end

        if str == "automatic deposit and withdrawal" then
            str = "自動入出金"
        end

        if str ==
            "When checked, silver is automatically deposited and withdrawn from the warehouse.Set up for each character." then
            str = "チェックを入れると、自動入出金有効化。各キャラクター毎に設定。"
        end

        if str == "Automatic item receipt and dispatch" then
            str = "自動搬出入"
        end

        if str == "When checked, items are automatically moved in and out of the warehouse.Set up for each character." then
            str = "チェックを入れると、自動搬出入有効化。各キャラクター毎に設定。"
        end

        if str == "deposit and withdrawal amount" then
            str = "自動入出金の金額設定"
        end

        if str == "When checked, fractional amounts less than 1 million silver are taken from the warehouse." then
            str = "チェックを入れると、1M未満の端数シルバーを引き出します。"
        end

        if str == "Unchecking the checkbox stops the{nl}" .. " automatic receipt/issuance and{nl}" ..
            "automatic deposit/withdrawal functions.{nl}" .. "This is a per-character setting." then
            str = "チェックを外すと、ログイン中のキャラでは{nl}" ..
                      "自動入出金、自動搬出入は動作しません。"
        end

        if str == "Already registered." then
            str = "既に登録済です。"
        end

        if str == "Enter the number to be left in the inventory." then
            str = "インベントリに残す数を入力"
        end

        if str == "Notice from [another warehouse]" then
            str = "[another warehouse]からのお知らせ"
        end

        if str == "[Yet Another Account Inventory] add-on is installed and will not function properly." then
            str =
                "[Yet Another Account Inventory]アドオンがインストールされている為、正常に機能しません。"
        end

        if str == "[Warehouse Manager] add-on is installed and will not function properly." then
            str =
                "[Warehouse Manager]アドオンがインストールされている為、正常に機能しません。"
        end

        if str == "team setting" then
            str = "チーム倉庫の自動搬出入設定"
        end
        if str == "character setting" then
            str =
                "キャラ毎の自動搬出入設定(チーム倉庫の自動搬出入設定を上書きします。)"
        end

        if str == "Inventory: right mouse click to set team items" then
            str = "インベントリ:マウス右クリックでチームのアイテム設定"
        end

        if str == "Inventory: left SHIFT+mouse right click to set items for each character" then
            str = "インベントリ:左SHIFT+マウス右クリックで各キャラのアイテム設定"
        end

        if str == "Setting slot: left SHIFT+right mouse click to change the number of setting pieces" then
            str = "設定スロット:左SHIFT+マウス右クリックで設定個数変更"
        end
        if str == "Setting slot: right mouse click to clear settings" then
            str = "設定スロット:マウス右クリックで設定消去"
        end
        -- "Delivered to warehouse"

        if str == "Item to warehousing" then
            str = "倉庫に格納しました"
        end

        if str == "Data copy" then
            str = "データコピー"
        end

        if str == "Data copy from [Wrehouse Manager]" then
            str = "[Wrehouse Manager]からデータをコピーします"
        end

        if str == "Do you want to copy data from{nl}[Wrehouse Manager]?" then
            str = "[Wrehouse Manager]からデータをコピーしますか？"
        end

        if str == "Data copy completed." then
            str = "データコピー完了"
        end
        -- Put delay time
        if str == "Put delay time" then
            str = "入庫遅延設定"
        end

        -- Set the delay time in case of failure {nl}in warehouse entry. Basic is 0.5 sec.
        if str == "If the warehouse entry fails,{nl}set a longer time. Basic is 0.5 sec." then
            str =
                "倉庫入庫に失敗する場合、時間を長めに設定してください。デフォルトは0.5秒です。"
        end

        -- ui.SysMsg(another_warehouse_lang("The entered text is not numeric."){nl}入力された文字が数値ではないです。")
        if str == "Please enter numerical values." then
            str = "数値で入力してください。"
        end

        -- Warehouse items right-click to setting
        if str == "Warehouse items right-click to setting" then
            str = "倉庫アイテム右クリックで設定"
        end
        -- ui.SysMsg("Set name changed.")
        if str == "Set name changed." then
            str = "セット名変更しました。"
        end

        if str == "Name already registered." then
            str = "既に登録済の名前です。"
        end
        -- ui.SysMsg("Name already registered.")
        -- The set is taken out of the warehouse.
        if str == "The set is taken out of the warehouse." then
            str = "倉庫からセットで搬出します。"
        end

        if str == "Inventory: right mouse click to Carry in all items" then
            str = "インベントリ:アイコン右クリックで全数搬入"
        end

        if str == "Inventory: left mouse click to Carry in 1 items" then
            str = "インベントリ:アイコン左クリックで1個搬入"
        end

        if str == "Inventory: left SHIFT+mouse left click to Carry in 10 items" then
            str = "インベントリ:左SHIFT+アイコン左クリックで10個搬入"
        end

        if str == "Inventory: left SHIFT+mouse right click to Carry in Input quantity items" then
            str = "インベントリ:左SHIFT+アイコン右クリックで入力数量搬入"
        end

        -- Warehouse: right mouse click to Carry out Leave 1 piece

        if str == "Warehouse: right mouse click to Carry out Leave 1 piece" then
            str = "チーム倉庫:アイコン右クリックで1個残して搬出"
        end

        if str == "Warehouse: right mouse click to Carry out all items" then
            str = "チーム倉庫:アイコン右クリックで全数搬出"
        end

        if str == "Warehouse: left mouse click to Carry out 1 items" then
            str = "チーム倉庫:アイコン左クリックで1個搬出"
        end

        if str == "Warehouse: left SHIFT+mouse left click to Carry out 10 items" then
            str = "チーム倉庫:左SHIFT+アイコン左クリックで10個搬出"
        end

        if str == "Warehouse: left SHIFT+mouse right click to Carry out Input quantity items" then
            str = "チーム倉庫:左SHIFT+アイコン右クリックで入力数量搬出"
        end

    end

    return str
end

function another_warehouse_help()
    -- tree:SetTextTooltip("Left click 10 each{nl}Right click all{nl}Hold Left Shift to specify quantity")
    local context = ui.CreateContextMenu("CONTEXT", "          [Anothe Warehouse]Help", 30, 0, 100, 100)
    ui.AddContextMenuItem(context, another_warehouse_lang("Inventory: right mouse click to Carry in all items"), "None")
    ui.AddContextMenuItem(context, another_warehouse_lang("Inventory: left mouse click to Carry in 1 items"), "None")
    ui.AddContextMenuItem(context, another_warehouse_lang(
        "Inventory: left SHIFT+mouse right click to Carry in Input quantity items"), "None")
    ui.AddContextMenuItem(context,
        another_warehouse_lang("Inventory: left SHIFT+mouse left click to Carry in 10 items"), "None")

    -- ui.AddContextMenuItem(context, another_warehouse_lang("Warehouse: right mouse click to Carry out all items"), "None")
    ui.AddContextMenuItem(context, another_warehouse_lang("Warehouse: right mouse click to Carry out all items"), "None")
    ui.AddContextMenuItem(context, another_warehouse_lang("Warehouse: left mouse click to Carry out 1 items"), "None")

    ui.AddContextMenuItem(context, another_warehouse_lang(
        "Warehouse: left SHIFT+mouse right click to Carry out Input quantity items"), "None")
    ui.AddContextMenuItem(context,
        another_warehouse_lang("Warehouse: left SHIFT+mouse left click to Carry out 10 items"), "None")

    ui.OpenContextMenu(context)
end

function another_warehouse_setting_help()
    local context = ui.CreateContextMenu("CONTEXT", "          [Anothe Warehouse]Setting Help", 30, 0, 100, 100)
    ui.AddContextMenuItem(context, another_warehouse_lang("Inventory: right mouse click to set team items"), "None")
    ui.AddContextMenuItem(context, another_warehouse_lang(
        "Inventory: left SHIFT+mouse right click to set items for each character"), "None")
    ui.AddContextMenuItem(context, another_warehouse_lang(
        "Setting slot: left SHIFT+right mouse click to change the number of setting pieces"), "None")
    ui.AddContextMenuItem(context, another_warehouse_lang("Setting slot: right mouse click to clear settings"), "None")
    ui.OpenContextMenu(context)
end

function ANOTHER_WAREHOUSE_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.settings = g.settings or {}

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        another_warehouse_load_settings()

        addon:RegisterMsg("GAME_START_3SEC", "another_warehouse_accountwarehouse_init_reserve");
    end
end

function another_warehouse_accountwarehouse_init_reserve()
    if session.loginInfo.IsPremiumState(ITEM_TOKEN) == true then
        another_warehouse_accountwarehouse_init()
    else
        ReserveScript("another_warehouse_accountwarehouse_init()", 2.0)
    end
end

function another_warehouse_accountwarehouse_init()

    -- CHAT_SYSTEM(tostring(session.loginInfo.IsPremiumState(ITEM_TOKEN)))
    if session.loginInfo.IsPremiumState(ITEM_TOKEN) == true then

        ui.SysMsg("[AWH]ready")
        local addon = g.addon
        addon:RegisterMsg("OPEN_DLG_ACCOUNTWAREHOUSE", "another_warehouse_OPEN_DLG_ACCOUNTWAREHOUSE");
        addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_LIST", "another_warehouse_on_msg");
        addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_ADD", "another_warehouse_on_msg");
        addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_REMOVE", "another_warehouse_on_msg");
        addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_CHANGE_COUNT", "another_warehouse_on_msg");
        addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_IN", "another_warehouse_on_msg");

        addon:RegisterMsg('ESCAPE_PRESSED', 'another_warehouse_accountwarehouse_close');

        acutil.setupEvent(addon, 'ACCOUNTWAREHOUSE_OPEN', "another_warehouse_accountwarehouse_open")
        acutil.setupEvent(addon, 'ACCOUNTWAREHOUSE_CLOSE', "another_warehouse_accountwarehouse_close")

        local functionName = "YAACCOUNTINVENTORY_ON_INIT" -- チェックしたい関数の名前を文字列として指定します
        if type(_G[functionName]) == "function" then
            another_warehouse_notice()

        end

        local functionName = "WAREHOUSEMANAGER_ON_INIT" -- チェックしたい関数の名前を文字列として指定します
        if type(_G[functionName]) == "function" then

            another_warehouse_notice2()

        end
    else
        ui.SysMsg(another_warehouse_lang("[Another warehouse] is not available because the token has not been applied."))
        return
    end
end

function another_warehouse_notice2()
    local msg = another_warehouse_lang("Notice from [another warehouse]")

    NICO_CHAT("{@st55_a}" .. msg)
    local msg2 = another_warehouse_lang("[Warehouse Manager] add-on is installed and will not function properly.")
    NICO_CHAT("{@st55_a}" .. msg2)

end

function another_warehouse_set_item_close(frame, ctrl, argStr, argNum)
    frame = ui.GetFrame("another_warehouse_set_items")
    frame:ShowWindow(0)
end

function another_warehouse_set_item_take(frame, ctrl, argStr, argNum)

    local warehouseFrame = ui.GetFrame('accountwarehouse')
    if warehouseFrame:IsVisible() ~= 1 then
        return
    end
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetSortedGuidList();
    local sortedCnt = sortedGuidList:Count();
    local fromframe = ui.GetFrame("accountwarehouse")

    local take = {}
    for key, value in pairs(g.settings.setitems[tostring(argStr)]) do

        for i = 0, sortedCnt - 1 do
            local guid = sortedGuidList:Get(i)
            local invItem = itemList:GetItemByGuid(guid)
            local type = invItem.type
            local iesid = invItem:GetIESID()
            local count = 0
            if value == type then
                -- 1個残す

                if g.settings.leave == 1 then
                    count = invItem.count - 1
                    take[iesid] = count
                else
                    count = invItem.count
                    take[iesid] = count
                end
                -- print(tostring(iesid) .. ":" .. tostring(count))
                break
            end
        end

    end

    session.ResetItemList()
    for iesid, count in pairs(take) do

        if count ~= 0 then
            session.AddItemID(tonumber(iesid), count)
        end
    end
    item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), fromframe:GetUserIValue("HANDLE"))
    another_warehouse_set_item_close(frame, ctrl, argStr, argNum)

    ACCOUNTWAREHOUSE_CLOSE(warehouseFrame)
    -- warehouseFrame:ShowWindow(0)
    INVENTORY_SET_CUSTOM_RBTNDOWN("None")
    SET_INV_LBTN_FUNC(ui.GetFrame("inventory"), "None");
    UI_TOGGLE_INVENTORY()
    return
end

function another_warehouse_set_name_edit(frame, ctrl, argStr, argNum)

    for i, handle in ipairs(g.settings.handlelist) do
        local newtext = string.gsub(ctrl:GetText(), "{ol}", "")
        if newtext == tostring(handle) then
            ui.SysMsg(another_warehouse_lang("Name already registered."))

            return
        end
    end

    for i, handle in ipairs(g.settings.handlelist) do
        -- print(handle .. ":" .. ctrl:GetText())
        local newtext = string.gsub(ctrl:GetText(), "{ol}", "")
        if newtext ~= tostring(handle) then
            g.settings.handlelist[argNum] = tostring(newtext)
            another_warehouse_save_settings()
            ui.SysMsg(another_warehouse_lang("Set name changed."))
            -- index = i
            -- str = newtext
            break

        end

    end
    -- another_warehouse_set_items_setting(index, str)
end

function another_warehouse_set_items_setting(number, handle)

    local frame = ui.CreateNewFrame("notice_on_pc", "another_warehouse_set_items", 0, 0, 10, 10)
    AUTO_CAST(frame)
    frame:SetSkinName("test_frame_low")
    frame:SetPos(680, 170)
    frame:SetLayerLevel(100)
    frame:Resize(270, 310)
    frame:SetUserValue("NUMBER", number)
    frame:RemoveAllChild()

    local close = frame:CreateOrGetControl("button", "close", 0, 0, 25, 25)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetOffset(230, 5)
    close:SetEventScript(ui.LBUTTONUP, "another_warehouse_set_item_close")

    local set_gb = frame:CreateOrGetControl("groupbox", "set_gb" .. number, 10, 50, 380, 380)
    AUTO_CAST(set_gb)
    set_gb:SetSkinName("test_frame_midle_light")
    set_gb:Resize(250, 250)
    frame:ShowWindow(1)

    local out = frame:CreateOrGetControl("button", "out", 0, 0, 100, 43)
    AUTO_CAST(out)
    out:SetText("{@st66b}TAKE ITEM")
    out:SetMargin(10, 5, 100, 0)
    out:SetSkinName("test_pvp_btn")
    out:SetTextTooltip(another_warehouse_lang("Warehouse items right-click to setting"))
    out:SetEventScript(ui.LBUTTONUP, "another_warehouse_set_item_take")
    out:SetEventScriptArgString(ui.LBUTTONUP, number)

    --[[local warehouseFrame = ui.GetFrame("accountwarehouse")
    local dropList = GET_CHILD_RECURSIVELY(warehouseFrame, 'dropList')
    AUTO_CAST(dropList)
    print(tostring(dropList:GetText()))]]

    local name_edit = frame:CreateOrGetControl("edit", "name_edit", 115, 13, 110, 30)
    AUTO_CAST(name_edit)
    name_edit:SetFontName("white_16_ol")
    name_edit:SetTextAlign("center", "center")
    name_edit:SetText("{ol}" .. handle)
    name_edit:SetEventScript(ui.ENTERKEY, "another_warehouse_set_name_edit")
    name_edit:SetEventScriptArgNumber(ui.ENTERKEY, number)

    local set_slotset = set_gb:CreateOrGetControl('slotset', 'set_slotset', 0, 0, 0, 0)
    AUTO_CAST(set_slotset);
    set_slotset:SetSlotSize(50, 50) -- スロットの大きさ
    set_slotset:EnablePop(1)
    set_slotset:EnableDrag(1)
    set_slotset:EnableDrop(1)
    -- set_slotset:SetNumberMode(1)
    set_slotset:SetColRow(5, 5) -- スロットの配置と個数
    set_slotset:SetSpc(0, 0)
    set_slotset:SetSkinName('slot')
    -- set_slotset:SetEventScript(ui.DROP, "another_warehouse_setting_drop")

    set_slotset:CreateSlots()
    local slotcount = set_slotset:GetSlotCount()

    for i = 1, slotcount do
        local slot = GET_CHILD_RECURSIVELY(set_slotset, "slot" .. i)
        local icon = slot:GetIcon()
        if icon == nil then
            slot:SetTextTooltip(another_warehouse_lang("Warehouse items right-click to setting"))
        end
        local str_index = tostring(i)
        for key, value in pairs(g.settings.setitems[tostring(number)]) do
            if key == str_index then
                local clsid = value

                local itemcls = GetClassByType("Item", clsid)
                -- slot:SetUserValue("ITEM_CLSID", clsid)
                slot:SetEventScript(ui.RBUTTONUP, "another_warehouse_set_clear_item")
                slot:SetEventScriptArgString(ui.RBUTTONUP, number)
                slot:SetEventScriptArgNumber(ui.RBUTTONUP, clsid)
                SET_SLOT_ITEM_CLS(slot, itemcls)

            end
        end
    end

end

function another_warehouse_takeitem(frame, iesid, count)

    local setframe = ui.GetFrame("another_warehouse_set_items")

    if setframe == nil or setframe:IsVisible() == 0 then

        local invItem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iesid);

        session.ResetItemList();
        session.AddItemID(iesid, count);
        item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), frame:GetUserIValue("HANDLE"));

    elseif setframe:IsVisible() == 1 then

        local invItem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iesid);

        local obj = GetIES(invItem:GetObject());
        local type = tonumber(obj.ClassID)
        local itemcls = GetClassByType("Item", type)

        local set_slotset = GET_CHILD_RECURSIVELY(setframe, "set_slotset")
        local slotcount = set_slotset:GetSlotCount()
        local index = 1

        for i = 1, slotcount do
            local awslot = GET_CHILD_RECURSIVELY(set_slotset, "slot" .. i)
            local slot_icon = awslot:GetIcon();
            if slot_icon == nil then
                index = i
                break
            end
        end
        if g.settings.setitems == nil then
            g.settings.setitems = {}
            another_warehouse_save_settings()

        end
        local number = setframe:GetUserIValue("NUMBER")
        -- print(number .. "value")
        if g.settings.setitems[tostring(number)] == nil then
            g.settings.setitems[tostring(number)] = {}
            another_warehouse_save_settings()

        end

        local ctrl = GET_CHILD_RECURSIVELY(set_slotset, "slot" .. index)
        ctrl:SetEventScript(ui.RBUTTONUP, "another_warehouse_set_clear_item")
        ctrl:SetEventScriptArgString(ui.RBUTTONUP, number)
        ctrl:SetEventScriptArgNumber(ui.RBUTTONUP, type)

        if g.settings.setitems[tostring(number)][tostring(index)] == nil then
            g.settings.setitems[tostring(number)][tostring(index)] = tonumber(type)

        end

        SET_SLOT_ITEM_CLS(ctrl, itemcls)
        another_warehouse_save_settings()

    end
end

function another_warehouse_set_clear_item(frame, ctrl, argStr, argNum)

    for k, v in pairs(g.settings.setitems[argStr]) do
        if v == argNum then
            ctrl:ClearIcon();
            g.settings.setitems[argStr][k] = nil

            another_warehouse_save_settings()
            break
        end
    end

    -- another_warehouse_set_items_setting(g.number)
end

function another_warehouse_take_context(frame, ctrl, argStr, argNum)
    local context = ui.CreateContextMenu("TAKE_SETTING", "Take items", 0, 20, 100, 100)
    -- g.settings.handlelist = nil
    if g.settings.handlelist == nil then

        g.settings.handlelist = {
            [1] = "Take Items 1",
            [2] = "Take Items 2",
            [3] = "Take Items 3",
            [4] = "Take Items 4",
            [5] = "Take Items 5",
            [6] = "Take Items 6",
            [7] = "Take Items 7",
            [8] = "Take Items 8"
        }
        another_warehouse_save_settings()
    end

    for i, handle in ipairs(g.settings.handlelist) do

        local scp = string.format("another_warehouse_set_items_setting(%d,'%s')", tonumber(i), handle)
        ui.AddContextMenuItem(context, handle, scp)
    end

    ui.OpenContextMenu(context)
end

function another_warehouse_OPEN_DLG_ACCOUNTWAREHOUSE()

    local msframe = ui.GetFrame("monstercardslot")
    msframe:SetLayerLevel(98)

    local frame = ui.GetFrame("accountwarehouse")
    local accountwarehouse_tab = GET_CHILD_RECURSIVELY(frame, "accountwarehouse_tab")
    accountwarehouse_tab:SetMargin(0, 240) -- margin="0 120 0 0"
    local richtext_1 = GET_CHILD_RECURSIVELY(frame, "richtext_1")
    richtext_1:SetMargin(30, 133) --  margin="30 73 0 0"
    local itemcnt = GET_CHILD_RECURSIVELY(frame, "itemcnt")
    itemcnt:SetMargin(0, 133, 190, 0) --  margin="0 73 190 0"
    local slotgbox = GET_CHILD_RECURSIVELY(frame, "slotgbox")
    slotgbox:ShowWindow(0)

    local maxcount = another_warehouse_get_maxcount()
    local itemcount = another_warehouse_item_count()

    local grupbox = GET_CHILD_RECURSIVELY(frame, "gbox")

    local awsetting = grupbox:CreateOrGetControl("button", "awsetting", 0, 0, 30, 43)
    AUTO_CAST(awsetting)
    awsetting:SetText("{img config_button_normal 30 30}")
    awsetting:SetEventScript(ui.LBUTTONUP, "another_warehouse_setting_frame_init")
    awsetting:SetMargin(145, 60, 0, 0)
    awsetting:SetSkinName("None")
    awsetting:SetTextTooltip(another_warehouse_lang("[Another Warehouse]{nl}Automatic warehousing setup"))
    awsetting:ShowWindow(1)

    local help = grupbox:CreateOrGetControl('button', "help", 0, 0, 30, 30)
    AUTO_CAST(help);
    -- help:SetSkinName("None")
    help:SetText("{ol}{img question_mark 20 20}")
    help:SetMargin(115, 67, 0, 0)
    help:SetTextTooltip("[Another Warehouse]{nl}help")
    help:SetSkinName("test_pvp_btn")
    help:SetEventScript(ui.LBUTTONUP, "another_warehouse_help")

    local leave = grupbox:CreateOrGetControl('checkbox', "leave", 0, 0, 30, 30)

    AUTO_CAST(leave);
    leave:SetCheck(g.settings.leave or 0)
    leave:SetMargin(180, 67, 0, 0)
    leave:SetEventScript(ui.LBUTTONUP, "another_warehouse_setting_check")
    leave:SetTextTooltip("Check leaves one in the warehouse.{nl}チェックすると倉庫に1個残します。")

    local take = grupbox:CreateOrGetControl("button", "take", 10, 0, 100, 43)
    AUTO_CAST(take)
    take:SetText("{@st66b}TAKE SET")
    take:SetEventScript(ui.LBUTTONUP, "another_warehouse_take_context")
    take:SetMargin(310, 60, 0, 0)
    take:SetSkinName("test_pvp_btn")
    take:SetTextTooltip(another_warehouse_lang("The set is taken out of the warehouse."))
    take:ShowWindow(1)

    local count_text = grupbox:CreateOrGetControl("richtext", "count_text", 0, 0, 200, 24)
    AUTO_CAST(count_text)
    count_text:SetMargin(420, 73, 0, 0)
    count_text:SetText("{@st42}" .. itemcount .. "/" .. maxcount .. "{/}")
    count_text:SetFontName("white_16_ol")
    count_text:ShowWindow(1)

    local awclose = grupbox:CreateOrGetControl("button", "awclose", 10, 0, 100, 43)
    AUTO_CAST(awclose)
    awclose:SetText("{@st66b}AW CLOSE")
    awclose:SetEventScript(ui.LBUTTONUP, "another_warehouse_frame_close")
    awclose:SetMargin(10, 60, 0, 0)
    awclose:SetSkinName("test_pvp_btn")
    awclose:ShowWindow(1)

    local name_text = grupbox:CreateOrGetControl("richtext", "name_text", 15, 0, 200, 24)
    AUTO_CAST(name_text)
    local LoginName = session.GetMySession():GetPCApc():GetName()
    name_text:SetMargin(10, 5, 0, 0)
    name_text:SetText("{ol}{s18}" .. LoginName .. "{/}")

    local overlap = ui.GetFrame("another_warehouse")
    overlap:SetSkinName("None")

    overlap:SetOffset(0, 200)
    overlap:Resize(670, 570)

    local height = overlap:GetHeight()
    local gbox = overlap:GetChild("inventoryGbox")
    AUTO_CAST(gbox)
    gbox:Resize(650, height - 15)
    gbox:SetOffset(10, 5)
    gbox:SetSkinName("test_frame_low")

    local gbox2 = overlap:GetChildRecursively("inventoryitemGbox")
    AUTO_CAST(gbox2)
    gbox2:Resize(650 - 32, height - 15)
    gbox2:SetOffset(35, 0)

    overlap:EnableHitTest(1)
    overlap:EnableHittestFrame(1)
    overlap:SetLayerLevel(97)
    overlap:RunUpdateScript("another_warehouse_ADVANCEDMONEYINPUT", 0.2)
    overlap:ShowWindow(1)
    another_warehouse_frame_update()

end

function another_warehouse_ADVANCEDMONEYINPUT(frame)

    local frame = ui.GetFrame("accountwarehouse")
    local editMoney = frame:GetChildRecursively("moneyInput")
    AUTO_CAST(editMoney)
    editMoney:SetText("0")
    local DepositSkin = frame:GetChildRecursively("DepositSkin")
    AUTO_CAST(DepositSkin)
    DepositSkin:Resize(DepositSkin:GetWidth(), 45)

    local cancel = DepositSkin:CreateOrGetControl("button", "cancel", DepositSkin:GetWidth() - 50,
        DepositSkin:GetHeight() - 23, 50, 25)
    AUTO_CAST(cancel)
    cancel:SetText("{ol}{s12}{@st66b}C")
    cancel:SetSkinName("test_pvp_btn")
    cancel:SetEventScript(ui.LBUTTONUP, "another_warehouse_lbtn_ADVANCEDMONEYINPUT")
    cancel:SetEventScriptArgNumber(ui.LBUTTONUP, 0)
    cancel:SetEventScript(ui.RBUTTONUP, "another_warehouse_rbtn_ADVANCEDMONEYINPUT")
    cancel:SetEventScriptArgNumber(ui.RBUTTONUP, 0)

    local M1 = DepositSkin:CreateOrGetControl("button", "m1", DepositSkin:GetWidth() - 100,
        DepositSkin:GetHeight() - 23, 50, 25)
    AUTO_CAST(M1)
    M1:SetText("{ol}{@st66b}{s12}1M")
    M1:SetSkinName("test_pvp_btn")
    M1:SetEventScript(ui.LBUTTONUP, "another_warehouse_lbtn_ADVANCEDMONEYINPUT")
    M1:SetEventScriptArgNumber(ui.LBUTTONUP, 1000000)
    M1:SetEventScript(ui.RBUTTONUP, "another_warehouse_rbtn_ADVANCEDMONEYINPUT")
    M1:SetEventScriptArgNumber(ui.RBUTTONUP, 1000000)

    local M5 = DepositSkin:CreateOrGetControl("button", "m5", DepositSkin:GetWidth() - 150,
        DepositSkin:GetHeight() - 23, 50, 25)
    AUTO_CAST(M5)
    M5:SetText("{ol}{@st66b}{s12}5M")
    M5:SetSkinName("test_pvp_btn")
    M5:SetEventScript(ui.LBUTTONUP, "another_warehouse_lbtn_ADVANCEDMONEYINPUT")
    M5:SetEventScriptArgNumber(ui.LBUTTONUP, 5000000)
    M5:SetEventScript(ui.RBUTTONUP, "another_warehouse_rbtn_ADVANCEDMONEYINPUT")
    M5:SetEventScriptArgNumber(ui.RBUTTONUP, 5000000)

    local M10 = DepositSkin:CreateOrGetControl("button", "m10", DepositSkin:GetWidth() - 200,
        DepositSkin:GetHeight() - 23, 50, 25)
    AUTO_CAST(M10)
    M10:SetText("{ol}{@st66b}{s12}10M")
    M10:SetSkinName("test_pvp_btn")
    M10:SetEventScript(ui.LBUTTONUP, "another_warehouse_lbtn_ADVANCEDMONEYINPUT")
    M10:SetEventScriptArgNumber(ui.LBUTTONUP, 10000000)
    M10:SetEventScript(ui.RBUTTONUP, "another_warehouse_rbtn_ADVANCEDMONEYINPUT")
    M10:SetEventScriptArgNumber(ui.RBUTTONUP, 10000000)

    local M50 = DepositSkin:CreateOrGetControl("button", "m50", DepositSkin:GetWidth() - 250,
        DepositSkin:GetHeight() - 23, 50, 25)
    AUTO_CAST(M50)
    M50:SetText("{ol}{@st66b}{s12}50M")
    M50:SetSkinName("test_pvp_btn")
    M50:SetEventScript(ui.LBUTTONUP, "another_warehouse_lbtn_ADVANCEDMONEYINPUT")
    M50:SetEventScriptArgNumber(ui.LBUTTONUP, 50000000)
    M50:SetEventScript(ui.RBUTTONUP, "another_warehouse_rbtn_ADVANCEDMONEYINPUT")
    M50:SetEventScriptArgNumber(ui.RBUTTONUP, 50000000)

    local M100 = DepositSkin:CreateOrGetControl("button", "m100", DepositSkin:GetWidth() - 300,
        DepositSkin:GetHeight() - 23, 50, 25)
    AUTO_CAST(M100)
    M100:SetText("{ol}{@st66b}{s12}100M")
    M100:SetSkinName("test_pvp_btn")
    M100:SetEventScript(ui.LBUTTONUP, "another_warehouse_lbtn_ADVANCEDMONEYINPUT")
    M100:SetEventScriptArgNumber(ui.LBUTTONUP, 100000000)
    M100:SetEventScript(ui.RBUTTONUP, "another_warehouse_rbtn_ADVANCEDMONEYINPUT")
    M100:SetEventScriptArgNumber(ui.RBUTTONUP, 100000000)

    local ALLOUT = DepositSkin:CreateOrGetControl("button", "allout", DepositSkin:GetWidth() - 350,
        DepositSkin:GetHeight() - 23, 50, 25)
    AUTO_CAST(ALLOUT)
    ALLOUT:SetText("{ol}{@st66b}{s12}{img chul_arrow 10 10}ALL")
    ALLOUT:SetSkinName("test_pvp_btn")
    ALLOUT:SetEventScript(ui.LBUTTONUP, "another_warehouse_lbtn_ADVANCEDMONEYINPUT")

    local ALLIN = DepositSkin:CreateOrGetControl("button", "allin", DepositSkin:GetWidth() - 400,
        DepositSkin:GetHeight() - 23, 50, 25)
    AUTO_CAST(ALLIN)
    ALLIN:SetText("{ol}{@st66b}{s12}{img in_arrow 10 10}ALL")
    ALLIN:SetSkinName("test_pvp_btn")
    ALLIN:SetEventScript(ui.LBUTTONUP, "another_warehouse_lbtn_ADVANCEDMONEYINPUT")

    return 0

end

function another_warehouse_rbtn_ADVANCEDMONEYINPUT(frame, ctrl, str, num)

    local warehouseFrame = ui.GetFrame('accountwarehouse')
    local editMoney = frame:GetChildRecursively("moneyInput")
    AUTO_CAST(editMoney)
    if ctrl:GetName() == "cancel" then
        editMoney:SetText(0)
        return
    end
    local cleanedValue = string.gsub(editMoney:GetText(), "[\r\n,]", "")

    local numericValue = tonumber(cleanedValue)
    if (numericValue - num) >= 0 then
        editMoney:SetText(GET_COMMAED_STRING(SumForBigNumberInt64(numericValue, "-" .. num)))
    end

end

function another_warehouse_lbtn_ADVANCEDMONEYINPUT(frame, ctrl, str, num)

    local warehouseFrame = ui.GetFrame('accountwarehouse')
    local editMoney = frame:GetChildRecursively("moneyInput")
    AUTO_CAST(editMoney)
    local handle = warehouseFrame:GetUserIValue('HANDLE')

    if ctrl:GetName() == "allout" then

        local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
        local guidList = itemList:GetGuidList();
        local sortedGuidList = itemList:GetSortedGuidList();
        local sortedCnt = sortedGuidList:Count();
        local iesid
        for i = 0, sortedCnt - 1 do
            local guid = sortedGuidList:Get(i)
            local invItem = itemList:GetItemByGuid(guid)
            local obj = GetIES(invItem:GetObject());
            if obj.ClassName == MONEY_NAME then
                iesid = guid
                break
            end
        end
        local gbox = GET_CHILD_RECURSIVELY(warehouseFrame, 'visgBox')
        local cnt = session.AccountWarehouse.GetCount() - 1

        local ctrlSet = GET_CHILD_RECURSIVELY(warehouseFrame, 'CTRLSET_' .. cnt)
        local result = ctrlSet:GetChild('result')
        local value = result:GetTextByKey('value')
        local cleanedValue = string.gsub(value, "[\r\n,]", "")
        local numericValue = tonumber(cleanedValue)

        editMoney:SetText(tostring(value))

        -- session.AddItemIDWithAmount(iesid, tostring(numericValue))
        -- item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), handle)
        return
    elseif ctrl:GetName() == "allin" then
        local silveritem = session.GetInvItemByName(MONEY_NAME)
        if silveritem ~= nil then

            editMoney:SetText(GET_COMMAED_STRING(silveritem:GetAmountStr()))
        else
            editMoney:SetText(0)
        end
    elseif ctrl:GetName() == "cancel" then
        editMoney:SetText(0)
    else
        local cleanedValue = string.gsub(editMoney:GetText(), "[\r\n,]", "")
        local numericValue = tonumber(cleanedValue)
        editMoney:SetText(GET_COMMAED_STRING(SumForBigNumberInt64(numericValue, "+" .. num)))

    end

end

function another_warehouse_accountwarehouse_open()

    another_warehouse_active_mousebutton()

    local frame = ui.GetFrame("accountwarehouse")
    local accountwarehousefilter = GET_CHILD_RECURSIVELY(frame, "accountwarehousefilter")
    accountwarehousefilter:SetMargin(490, 705)

    another_warehouse_keeper_reserve()
end

function another_warehouse_keeper_reserve()
    local LoginCID = info.GetCID(session.GetMyHandle())

    if g.settings[LoginCID].maney_check == 1 then

        ReserveScript('another_warehouse_silver()', 0.1)

    end

    if g.settings[LoginCID].item_check == 1 then
        ReserveScript('another_warehouse_item()', 0.6)

    end

    return
end

function another_warehouse_item_tooltip(Name, iconName, Count, tooltipcount)

    -- print(tostring(tooltipcount) .. "a")

    local tooltip_frame = ui.CreateNewFrame("notice_on_pc", "another_warehouse_tooltip" .. tooltipcount, 0, 0, 10, 10)
    AUTO_CAST(tooltip_frame)

    tooltip_frame:SetSkinName("None")
    tooltip_frame:SetPos(680, 300 + tooltipcount * 55)
    tooltip_frame:SetLayerLevel(100)
    tooltip_frame:Resize(350, 64)
    -- tooltip_frame:RemoveAllChild()

    local tooltip_gb = tooltip_frame:CreateOrGetControl("groupbox", "tooltip_gb", 0, 0, 350, 64)
    AUTO_CAST(tooltip_gb)
    tooltip_gb:SetSkinName("item_show_tootip")
    tooltip_gb:Resize(350, 64)

    local tooltip_slot = tooltip_gb:CreateOrGetControl("slot", "tooltip_slot", 20, 10, 45, 45)
    AUTO_CAST(tooltip_slot)

    local tooltip_text = tooltip_gb:CreateOrGetControl("richtext", "tooltip_text", 75, 15, 265, 22)
    AUTO_CAST(tooltip_text)
    tooltip_text:Resize(265, 22)
    -- tooltip_text:AdjustFontSizeByWidth(265)

    tooltip_text:SetText("{ol}" .. Name)

    local tooltip_count = tooltip_gb:CreateOrGetControl("richtext", "tooltip_count", 75, 37, 265, 22)
    AUTO_CAST(tooltip_count)
    tooltip_count:Resize(265, 22)
    -- tooltip_count:AdjustFontSizeByWidth(265)

    tooltip_count:SetText("{ol}" .. Count .. another_warehouse_lang(" Pieces in warehouse"))

    SET_SLOT_ICON(tooltip_slot, iconName)
    tooltip_frame:ShowWindow(1)
    ReserveScript(string.format("another_warehouse_item_tooltip_close(%d)", tooltipcount), 2.0)
    -- return
end

function another_warehouse_item_tooltip_close(count)
    local tooltip_frame = ui.GetFrame("another_warehouse_tooltip" .. count)
    tooltip_frame:ShowWindow(0)

end

function another_warehouse_item()

    g.takeitemtbl = {}
    g.putitemtbl = {}
    local warehouseFrame = ui.GetFrame('accountwarehouse')
    local handle = warehouseFrame:GetUserIValue('HANDLE')
    local LoginCID = info.GetCID(session.GetMyHandle())

    for str_index, items in pairs(g.settings[LoginCID].items) do
        local clsID = items.clsid

        local count = items.count

        g.takeitemtbl[clsID] = count

    end

    for str_index, items in pairs(g.settings.items) do
        local clsID = items.clsid
        local count = items.count
        if not g.takeitemtbl[clsID] then
            g.takeitemtbl[clsID] = count

        end
    end

    local invItemList = session.GetInvItemList()
    local inv_guidList = invItemList:GetGuidList()
    local cnt = inv_guidList:Count()

    for i = 0, cnt - 1 do
        local guid = inv_guidList:Get(i)
        local inv_Item = invItemList:GetItemByGuid(guid)
        local inv_obj = GetIES(inv_Item:GetObject())
        local inv_clsid = inv_obj.ClassID
        if inv_obj.ClassName ~= MONEY_NAME then
            for clsid, count in pairs(g.takeitemtbl) do
                local take_count = tonumber(count) - inv_Item.count

                if clsid == inv_clsid then
                    -- print(inv_obj.ClassName .. ":" .. take_count)
                    if take_count < 0 then
                        g.takeitemtbl[clsid] = nil
                        g.putitemtbl[clsid] = {
                            iesid = guid,
                            count = -(take_count),
                            handle = handle,
                            invItem = inv_Item
                        }
                    else
                        g.takeitemtbl[clsid] = take_count

                    end
                end

            end
        end
    end

    for clsid, count in pairs(g.takeitemtbl) do
        if count == 0 then

            g.takeitemtbl[clsid] = nil
        end
    end

    --[[for clsid, count in pairs(g.takeitemtbl) do

        print("g.takeitemtbl:" .. clsid .. ":" .. count)

    end
    for clsid, count in pairs(g.putitemtbl) do

        print("g.putitemtbl:" .. clsid .. ":" .. count.count)

    end]]
    another_warehouse_item_take()

end

--[[function another_warehouse_item()

    local LoginCID = info.GetCID(session.GetMyHandle())

    local warehouseFrame = ui.GetFrame('accountwarehouse')
    local handle = warehouseFrame:GetUserIValue('HANDLE')

    local ivframe = ui.GetFrame("inventory");
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList();
    local cnt = guidList:Count();

    g.putitemtbl = {} -- アイテム情報を格納するテーブル
    g.takeitemtbl = {}

    -- another_warehouse_load_settings()
    for k, v in pairs(g.settings.items) do
        local clsID = v.clsid
        local count = v.count

        if warehouseFrame:IsVisible() == 1 then
            if count ~= 0 then
                g.takeitemtbl[clsID] = count
            end

            for i = 0, cnt - 1 do
                local guid = guidList:Get(i)
                local invItem = invItemList:GetItemByGuid(guid)
                local itemobj = GetIES(invItem:GetObject())
                local invClsID = itemobj.ClassID

                if clsID == invClsID then
                    if count == 0 then

                        g.putitemtbl[clsID] = {
                            iesid = guid,
                            count = invItem.count,
                            handle = handle,
                            invItem = invItem
                        }

                        break
                    else
                        local item_count = invItem.count - count
                        if invItem.count > count then
                            g.putitemtbl[clsID] = {
                                iesid = guid,
                                count = item_count,
                                handle = handle,
                                invItem = invItem
                            }
                            g.takeitemtbl[clsID] = 0
                            break
                        elseif invItem.count < count then
                            g.takeitemtbl[clsID] = -item_count
                            break
                        elseif item_count == 0 then
                            g.takeitemtbl[clsID] = 0
                            break
                        end
                    end

                end
            end

        else

            return
        end
    end

    for k2, v2 in pairs(g.settings[LoginCID].items) do
        local char_clsID = v2.clsid
        local char_count = v2.count

        g.putitemtbl[char_clsID] = nil
        g.takeitemtbl[char_clsID] = 0
    end

    for k2, v2 in pairs(g.settings[LoginCID].items) do
        local char_clsID = v2.clsid
        local char_count = v2.count

        if warehouseFrame:IsVisible() == 1 then
            if char_count ~= 0 then
                g.takeitemtbl[char_clsID] = char_count
            end

            for i = 0, cnt - 1 do
                local guid = guidList:Get(i)
                local invItem = invItemList:GetItemByGuid(guid)
                local itemobj = GetIES(invItem:GetObject())
                local invClsID = itemobj.ClassID

                if char_clsID == invClsID then
                    local item_count = invItem.count - char_count

                    if char_count == 0 then

                        g.putitemtbl[char_clsID] = {
                            iesid = guid,
                            count = invItem.count,
                            handle = handle,
                            invItem = invItem
                        }

                        break
                    else

                        if invItem.count > char_count then
                            g.putitemtbl[char_clsID] = {
                                iesid = guid,
                                count = item_count,
                                handle = handle,
                                invItem = invItem
                            }
                            g.takeitemtbl[char_clsID] = 0
                            break
                        elseif invItem.count < char_count then
                            -- (char_count)
                            g.takeitemtbl[char_clsID] = -item_count
                            if g.putitemtbl[char_clsID] then
                                g.putitemtbl[char_clsID] = nil
                            end
                            break
                        elseif item_count == 0 then
                            g.takeitemtbl[char_clsID] = 0

                            g.putitemtbl[char_clsID] = nil

                            break
                        end
                    end

                end
            end

        else

            return
        end
    end
    another_warehouse_item_take()

end]]

function another_warehouse_item_take()

    local warehouseFrame = ui.GetFrame('accountwarehouse')

    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetSortedGuidList();
    local sortedCnt = sortedGuidList:Count();
    local fromframe = ui.GetFrame("accountwarehouse")

    g.take = {}
    for key, value in pairs(g.takeitemtbl) do
        if warehouseFrame:IsVisible() == 1 then
            for i = 0, sortedCnt - 1 do
                local guid = sortedGuidList:Get(i)
                local invItem = itemList:GetItemByGuid(guid)
                local type = invItem.type
                local iesid = invItem:GetIESID()

                if key == type and value ~= 0 then

                    local count = value
                    count = math.min(count, invItem.count)

                    g.takeitemtbl[type] = nil
                    -- another_warehouse_item_take_to(iesid, count)
                    if g.settings.leave == 1 then
                        g.take[iesid] = count - 1
                    else
                        g.take[iesid] = count
                    end

                    -- ReserveScript(string.format("another_warehouse_item_take_to('%s',%d)", iesid, count), delay)
                    -- delay = delay + 0.5
                    break
                elseif key == type and value == 0 then
                    g.takeitemtbl[type] = nil
                    break
                end

            end
        end
    end

    another_warehouse_item_take_to()
end

function another_warehouse_item_take_to()

    local fromframe = ui.GetFrame("accountwarehouse")
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    session.ResetItemList()

    for iesid, count in pairs(g.take) do
        if count ~= 0 then
            session.AddItemID(tonumber(iesid), count)
        end
    end

    item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), fromframe:GetUserIValue("HANDLE"))
    g.take = nil

    -- local flag = 0
    -- ReserveScript(string.format("another_warehouse_item_put(%d)", flag, 0.2))
    fromframe:RunUpdateScript("another_warehouse_item_put", 0.2)
    return
end

function another_warehouse_item_put()

    local warehouseFrame = ui.GetFrame('accountwarehouse')
    if warehouseFrame:IsVisible() == 0 then
        return 0
    end
    local tooltip_count = 0
    local delay = 0.2
    for clsID, itemData in pairs(g.putitemtbl) do

        local iesid = itemData.iesid
        local Count = itemData.count
        local handle = itemData.handle
        local invItem = itemData.invItem
        local itemobj = GetIES(invItem:GetObject())

        another_warehouse_checkvalid(iesid)
        local exist, index = another_warehouse_get_exist_item_index(itemobj)
        local goal_index = another_warehouse_get_goal_index()
        if exist == true and index >= 0 then
            goal_index = index
        end

        -- g.putitemtbl[clsID] = nil
        if tooltip_count >= 10 then
            tooltip_count = tooltip_count - 10
        else
            tooltip_count = tooltip_count + 1
        end
        local itemCls = GetClassByType('Item', clsID)
        local iconName = GET_ITEM_ICON_IMAGE(itemCls);
        local Name = itemCls.Name

        CHAT_SYSTEM(another_warehouse_lang("Item to warehousing") .. "：[" .. "{#EE82EE}" .. Name .. "{#FFFF00}]×" ..
                        "{#EE82EE}" .. Count)
        item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, iesid, tostring(Count), handle, goal_index)
        ReserveScript(string.format("another_warehouse_item_tooltip('%s','%s',%d,%d)", Name, iconName, Count,
            tooltip_count), delay)
        delay = delay + 0.2
        -- another_warehouse_item_put_to(iesid, Count, handle, goal_index, Name, iconName, tooltip_count)

    end
    ReserveScript("another_warehouse_end()", delay)
    --[[local tooltip_count = 0
    local delay = 0.2
    if #g.putitemtbl >= 1 then
        for clsID, itemData in pairs(g.putitemtbl) do
            local Count = itemData.count
            local itemList = session.GetInvItemList();
            local guidList = itemList:GetGuidList();
            local cnt = guidList:Count();
            for i = 0, cnt - 1 do
                local guid = guidList:Get(i);
                local invItem = itemList:GetItemByGuid(guid);
                local itemObj = GetIES(invItem:GetObject());
                if itemObj.ClassName ~= MONEY_NAME then
                    local classid = itemObj.ClassID
                    if clsID == classid then
                        if math.min(Count, invItem) <= Count then
                            if tooltip_count >= 4 then
                                tooltip_count = tooltip_count - 4
                            else
                                tooltip_count = tooltip_count + 1
                            end
                            local itemCls = GetClassByType('Item', clsID)
                            local iconName = GET_ITEM_ICON_IMAGE(itemCls);
                            local Name = itemCls.Name
                            another_warehouse_item_tooltip(Name, iconName, Count, tooltip_count)
                            g.putitemtbl[clsID] = nil
                            print(delay)
                            return 1
                        end
                    end
                end

                -- print("putitemtbl:" .. clsid .. ":" .. count.count)
            end
        end
    else
        another_warehouse_end()
        return 0
    end]]
end

function another_warehouse_item_put_to(iesid, count, handle, goal_index, Name, iconName, tooltip_count)

    item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, iesid, tostring(count), handle, goal_index)
    another_warehouse_item_tooltip(Name, iconName, count, tooltip_count)
    return
end

--[[function another_warehouse_item_put()

    local warehouseFrame = ui.GetFrame('accountwarehouse')
    if warehouseFrame:IsVisible() == 0 then
        return
    end

    local tooltip_count = 0

    local delay = g.settings.delay

    for clsID, itemData in pairs(g.putitemtbl) do

        local iesid = itemData.iesid
        local Count = itemData.count
        local handle = itemData.handle
        local invItem = itemData.invItem
        local itemobj = GetIES(invItem:GetObject())
        local itemCls = GetClassByType('Item', clsID)

        another_warehouse_checkvalid(iesid)
        local exist, index = another_warehouse_get_exist_item_index(itemobj)
        local goal_index = another_warehouse_get_goal_index()
        if exist == true and index >= 0 then
            goal_index = index
        end

        g.putitemtbl[clsID] = nil

        local iconName = GET_ITEM_ICON_IMAGE(itemCls);
        local Name = itemCls.Name

        ReserveScript(string.format("another_warehouse_item_put_to('%s',%d,%d,%d,'%s','%s',%d)", iesid, Count, handle,
            goal_index, Name, iconName, tooltip_count), delay)
        -- delay = delay + g.settings.delay
        delay = delay + 0.2
        if tooltip_count >= 4 then
            tooltip_count = tooltip_count - 4
        else
            tooltip_count = tooltip_count + 1
        end

    end
    for clsid, count in pairs(g.putitemtbl) do

        print("putitemtbl:" .. clsid .. ":" .. count.count)

    end
    ReserveScript("another_warehouse_end()", delay)

end]]

function another_warehouse_get_goal_index()
    local frame = ui.GetFrame("accountwarehouse")
    local tab = GET_CHILD(frame, "accountwarehouse_tab")
    local gbox = GET_CHILD_RECURSIVELY(frame, "gbox")

    local accountObj = GetMyAccountObj()
    local basecount = accountObj.BasicAccountWarehouseSlotCount + accountObj.MaxAccountWarehouseCount +
                          accountObj.AccountWareHouseExtend + accountObj.AccountWareHouseExtendByItem +
                          ADDITIONAL_SLOT_COUNT_BY_TOKEN

    local invItemCount = another_warehouse_item_count()
    local maxcount = another_warehouse_get_maxcount()

    if invItemCount >= maxcount then
        ui.SysMsg(ClMsg('CannotPutBecauseMaxSlot'))
        return
    end

    local function GetLeftCount(itemcnt)
        local length = #itemcnt:GetText()
        if length == 14 then
            return tonumber(string.sub(itemcnt:GetText(), length - 6, length - 6))
        else
            return tonumber(string.sub(itemcnt:GetText(), length - 7, length - 6))
        end
    end

    local function GetTabLeftCount(tab, gbox)
        local itemcnt = GET_CHILD(gbox, "itemcnt")
        return GetLeftCount(itemcnt)
    end

    local tabIndices = {4, 3, 2, 1, 0}
    local offsets = {210, 140, 70, 0, 0}

    for index = #tabIndices, 1, -1 do
        local i = tabIndices[index]
        tab:SelectTab(i)
        if i > 0 then
            local left = GetTabLeftCount(tab, gbox)
            if left < 70 then
                return basecount + offsets[index] + left + 1
            end
        else
            local slotset = GET_CHILD_RECURSIVELY(frame, "slotset")
            for j = 1, basecount do
                local slot = slotset:GetSlotByIndex(j)
                AUTO_CAST(slot)
                if slot:GetIcon() == nil then
                    return j + 1
                end
            end
        end
    end
end

--[[function another_warehouse_get_goal_index()
    local frame = ui.GetFrame("accountwarehouse")
    local tab = GET_CHILD(frame, "accountwarehouse_tab");
    local gbox = GET_CHILD_RECURSIVELY(frame, "gbox")

    local accountObj = GetMyAccountObj();
    local basecount = accountObj.BasicAccountWarehouseSlotCount + accountObj.MaxAccountWarehouseCount +
                          accountObj.AccountWareHouseExtend + accountObj.AccountWareHouseExtendByItem +
                          ADDITIONAL_SLOT_COUNT_BY_TOKEN

    local invItemCount = another_warehouse_item_count()
    local maxcount = another_warehouse_get_maxcount()
    local index = 0

    if invItemCount < maxcount then
        for i = 4, 0, -1 do
            -- for i = 0, 4 do
            if i == 4 then
                tab:SelectTab(i)
                local itemcnt = GET_CHILD(gbox, "itemcnt")
                local length = #itemcnt:GetText()
                local left = 0

                if length == 14 then
                    left = string.sub(itemcnt:GetText(), length - 6, length - 6) * 1 -- 左側の数字を取得
                else
                    left = string.sub(itemcnt:GetText(), length - 7, length - 6) * 1 -- 左側の数字を取得
                end

                if left < 70 then
                    index = basecount + 210 + left + 1
                    return index
                end
            elseif i == 3 then
                tab:SelectTab(i)
                local itemcnt = GET_CHILD(gbox, "itemcnt")
                local length = #itemcnt:GetText()
                local left = 0

                if length == 14 then
                    left = string.sub(itemcnt:GetText(), length - 6, length - 6) * 1 -- 左側の数字を取得
                else
                    left = string.sub(itemcnt:GetText(), length - 7, length - 6) * 1 -- 左側の数字を取得
                end

                if left < 70 then
                    index = basecount + 140 + left + 1
                    return index
                end
            elseif i == 2 then
                tab:SelectTab(i)
                local itemcnt = GET_CHILD(gbox, "itemcnt")
                local length = #itemcnt:GetText()
                local left = 0

                if length == 14 then
                    left = string.sub(itemcnt:GetText(), length - 6, length - 6) * 1 -- 左側の数字を取得
                else
                    left = string.sub(itemcnt:GetText(), length - 7, length - 6) * 1 -- 左側の数字を取得
                end

                if left < 70 then
                    index = basecount + 70 + left + 1
                    return index
                end
            elseif i == 1 then
                tab:SelectTab(i)
                local itemcnt = GET_CHILD(gbox, "itemcnt")
                local length = #itemcnt:GetText()
                local left = 0

                if length == 14 then
                    left = string.sub(itemcnt:GetText(), length - 6, length - 6) * 1 -- 左側の数字を取得
                else
                    left = string.sub(itemcnt:GetText(), length - 7, length - 6) * 1 -- 左側の数字を取得
                end

                if left < 70 then
                    index = basecount + left + 1
                    return index
                end

            elseif i == 0 then
                tab:SelectTab(i)
                local slotset = GET_CHILD_RECURSIVELY(frame, "slotset")
                for j = 1, basecount do
                    local slot = slotset:GetSlotByIndex(j)
                    AUTO_CAST(slot)
                    local icon = slot:GetIcon()
                    if icon == nil then
                        index = j + 1
                        return index
                    end

                end

            end
        end
    else

        ui.SysMsg(ClMsg('CannotPutBecauseMaxSlot'));
        return
    end

end]]

function another_warehouse_get_exist_item_index(itemObj)
    local ret1 = false
    local ret2 = -1

    if geItemTable.IsStack(itemObj.ClassID) == 1 then
        local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
        local sortedGuidList = itemList:GetGuidList();
        local sortedCnt = sortedGuidList:Count();

        for i = 0, sortedCnt - 1 do
            local guid = sortedGuidList:Get(i);
            local invItem = itemList:GetItemByGuid(guid)
            local invItem_obj = GetIES(invItem:GetObject());
            if itemObj.ClassID == invItem_obj.ClassID then
                ret1 = true
                ret2 = invItem.invIndex
                break
            end
        end
        return ret1, ret2
    else
        return false, -1
    end
end

--[[function another_warehouse_reitem_put(flag)
    -- print(flag)
    local LoginCID = info.GetCID(session.GetMyHandle())

    local warehouseFrame = ui.GetFrame('accountwarehouse')
    local handle = warehouseFrame:GetUserIValue('HANDLE')

    local ivframe = ui.GetFrame("inventory");
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList();
    local cnt = guidList:Count();

    g.putitemtbl = {} -- アイテム情報を格納するテーブル

    for k, v in pairs(g.settings.items) do
        local clsID = v.clsid
        local count = v.count

        if warehouseFrame:IsVisible() == 1 then

            for i = 0, cnt - 1 do
                local guid = guidList:Get(i)
                local invItem = invItemList:GetItemByGuid(guid)
                local itemobj = GetIES(invItem:GetObject())
                local invClsID = itemobj.ClassID

                if clsID == invClsID then
                    if count == 0 then

                        g.putitemtbl[clsID] = {
                            iesid = guid,
                            count = invItem.count,
                            handle = handle,
                            invItem = invItem
                        }

                        break
                    else
                        local item_count = invItem.count - count
                        if invItem.count > count then
                            g.putitemtbl[clsID] = {
                                iesid = guid,
                                count = item_count,
                                handle = handle,
                                invItem = invItem
                            }
                        end
                    end

                end
            end

        else

            return
        end
    end

    for k2, v2 in pairs(g.settings[LoginCID].items) do
        local char_clsID = v2.clsid
        local char_count = v2.count

        g.putitemtbl[char_clsID] = nil

    end

    for k2, v2 in pairs(g.settings[LoginCID].items) do
        local char_clsID = v2.clsid
        local char_count = v2.count

        if warehouseFrame:IsVisible() == 1 then

            for i = 0, cnt - 1 do
                local guid = guidList:Get(i)
                local invItem = invItemList:GetItemByGuid(guid)
                local itemobj = GetIES(invItem:GetObject())
                local invClsID = itemobj.ClassID

                if char_clsID == invClsID then
                    local item_count = invItem.count - char_count

                    if char_count == 0 then

                        g.putitemtbl[char_clsID] = {
                            iesid = guid,
                            count = invItem.count,
                            handle = handle,
                            invItem = invItem
                        }

                        break
                    else

                        if invItem.count > char_count then
                            g.putitemtbl[char_clsID] = {
                                iesid = guid,
                                count = item_count,
                                handle = handle,
                                invItem = invItem
                            }

                            break
                        elseif invItem.count < char_count then

                            if g.putitemtbl[char_clsID] then
                                g.putitemtbl[char_clsID] = nil
                            end
                            break
                        elseif item_count == 0 then

                            g.putitemtbl[char_clsID] = nil

                            break
                        end
                    end

                end
            end

        else

            return
        end
    end
    another_warehouse_item_put(flag)
end]]

function another_warehouse_end()
    ui.SysMsg("[AWH]End of Operation")
end

function another_warehouse_silver()

    local silveritem = session.GetInvItemByName(MONEY_NAME)
    local warehouseFrame = ui.GetFrame('accountwarehouse')
    local handle = warehouseFrame:GetUserIValue('HANDLE')

    local charsilver = 0
    if silveritem ~= nil then
        charsilver = tonumber(silveritem:GetAmountStr())

    end

    local silver = charsilver - tonumber(g.settings.silver)

    if silver > 0 then

        item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, silveritem:GetIESID(), tostring(silver), handle)

    elseif silver < 0 then

        session.ResetItemList()
        session.AddItemIDWithAmount("0", tostring(-silver))
        item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), handle)

    end

    if g.settings.amount_check == 1 then
        ReserveScript("another_warehouse_fraction()", 0.2)

    end
end

function another_warehouse_fraction()

    local warehouseFrame = ui.GetFrame('accountwarehouse')
    local handle = warehouseFrame:GetUserIValue('HANDLE')
    local awsilver = 0

    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local guidlist = itemList:GetSortedGuidList();
    local cnt = itemList:Count();

    for i = 0, cnt - 1 do
        local guid = guidlist:Get(i);
        local invItem = itemList:GetItemByGuid(guid)
        if (invItem ~= nil) then
            local invItem_obj = GetIES(invItem:GetObject());
            if invItem_obj.ClassName == MONEY_NAME then
                awsilver = invItem.count
                local numRight = 6
                local fraction = string.sub(tostring(awsilver), -numRight)
                awsilver = tonumber(fraction)
                break
            end
        end
    end

    session.ResetItemList()
    session.AddItemIDWithAmount("0", tostring(awsilver))
    item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), handle)

    --[[if g.settings.item_check == 1 then
        ReserveScript('another_warehouse_item()', 0.1)
        return
    end]]

end

function another_warehouse_setting_frame_init(frame, ctrl, argStr, argNum)

    local LoginCID = info.GetCID(session.GetMyHandle())

    local warehouseFrame = ui.GetFrame('accountwarehouse')
    warehouseFrame:ShowWindow(0)
    local inventoryFrame = ui.GetFrame('inventory')
    inventoryFrame:ShowWindow(1)

    INVENTORY_SET_CUSTOM_RBTNDOWN("None")
    INVENTORY_SET_CUSTOM_RBTNDOWN("another_warehouse_setting_rbtn")

    local settingframe = ui.CreateNewFrame("notice_on_pc", "another_warehouse_setting", 0, 0, 70, 30)
    AUTO_CAST(settingframe)

    settingframe:RemoveAllChild()
    settingframe:SetPos(670, 10)
    settingframe:Resize(740, 1060)
    settingframe:SetLayerLevel(96)
    settingframe:SetSkinName("test_frame_low")
    settingframe:ShowWindow(1)
    local title_gb = settingframe:CreateOrGetControl("groupbox", "title_gb", 0, 0, settingframe:GetWidth(), 55)
    title_gb:SetSkinName("test_frame_top")
    AUTO_CAST(title_gb)

    local title_text = title_gb:CreateOrGetControl("richtext", "title_text", 0, 0, ui.CENTER_HORZ, ui.TOP, 0, 15, 0, 0)
    AUTO_CAST(title_text);

    title_text:SetText('{ol}{s26}Another Warehouse Setting')

    local close = settingframe:CreateOrGetControl("button", "close", 0, 0, 25, 25)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetOffset(680, 15)
    close:SetEventScript(ui.LBUTTONUP, "another_warehouse_setting_close")

    local maney_text = settingframe:CreateOrGetControl("richtext", "maney_text", 55, 65, 0, 0)
    AUTO_CAST(maney_text);
    maney_text:SetText("{ol}" .. another_warehouse_lang("automatic deposit and withdrawal"))

    local maney_check = settingframe:CreateOrGetControl('checkbox', 'maney_check', 25, 65, 25, 25)
    AUTO_CAST(maney_check);
    maney_check:SetEventScript(ui.LBUTTONUP, "another_warehouse_setting_check")
    maney_check:SetCheck(g.settings[LoginCID].maney_check)
    maney_check:SetTextTooltip(another_warehouse_lang(
        "When checked, silver is automatically deposited and withdrawn from the warehouse.Set up for each character."))

    local item_text = settingframe:CreateOrGetControl("richtext", "item_text", 55, 95, 0, 0)
    AUTO_CAST(item_text);
    item_text:SetText("{ol}" .. another_warehouse_lang("Automatic item receipt and dispatch"))

    local item_check = settingframe:CreateOrGetControl('checkbox', 'item_check', 25, 95, 25, 25)
    AUTO_CAST(item_check);
    item_check:SetEventScript(ui.LBUTTONUP, "another_warehouse_setting_check")
    item_check:SetCheck(g.settings[LoginCID].item_check)
    item_check:SetTextTooltip(another_warehouse_lang(
        "When checked, items are automatically moved in and out of the warehouse.Set up for each character."))

    local amount_text = settingframe:CreateOrGetControl("richtext", "amount_text", 400, 65, 0, 0)
    AUTO_CAST(amount_text);
    amount_text:SetText("{ol}" .. another_warehouse_lang("deposit and withdrawal amount"))

    local amount_check = settingframe:CreateOrGetControl('checkbox', "amount_check", 660, 65, 25, 25)
    AUTO_CAST(amount_check);
    amount_check:SetTextTooltip(another_warehouse_lang(
        "When checked, fractional amounts less than 1 million silver are taken from the warehouse."))
    amount_check:SetEventScript(ui.LBUTTONUP, "another_warehouse_setting_check")
    amount_check:SetCheck(g.settings.amount_check)

    local help = settingframe:CreateOrGetControl('button', "help", 695, 65, 25, 25)
    AUTO_CAST(help);
    -- help:SetSkinName("None")
    help:SetText("{img question_mark 15 15}")
    help:SetTextTooltip("help")
    help:SetEventScript(ui.LBUTTONUP, "another_warehouse_setting_help")

    local amount_edit = settingframe:CreateOrGetControl('edit', 'amount_edit', 400, 95, 250, 25)
    AUTO_CAST(amount_edit)
    amount_edit:SetFontName("white_16_ol")
    amount_edit:SetTextAlign("center", "center") -- print(tostring(g.settings.silver))
    amount_edit:SetText(GET_COMMAED_STRING(tonumber(g.settings.silver)))
    amount_edit:SetEventScript(ui.ENTERKEY, 'another_warehouse_setting_edit')
    -- amount_edit:SetEventScriptArgString(ui.ENTERKEY, yes_arg))
    --[[local char_use_check = settingframe:CreateOrGetControl('checkbox', "char_use_check", 660, 95, 25, 25)
    AUTO_CAST(char_use_check);
    char_use_check:SetTextTooltip(another_warehouse_lang("Unchecking the checkbox stops the{nl}" ..
                                                             " automatic receipt/issuance and{nl}" ..
                                                             "automatic deposit/withdrawal functions.{nl}" ..
                                                             "This is a per-character setting."))
    char_use_check:SetEventScript(ui.LBUTTONUP, "another_warehouse_setting_check")
    char_use_check:SetCheck(g.settings[LoginCID].use) -- g.settings[LoginCID].use]]

    local team_text = settingframe:CreateOrGetControl("richtext", "team_text", 25, 125, 0, 0)
    AUTO_CAST(team_text);
    team_text:SetText("{ol}" .. another_warehouse_lang("team setting"))

    local char_text = settingframe:CreateOrGetControl("richtext", "char_text", 25, 695, 0, 0)
    AUTO_CAST(char_text);
    char_text:SetText("{ol}" .. another_warehouse_lang("character setting"))

    local team_gb = settingframe:CreateOrGetControl("groupbox", "team_gb", 20, 145, settingframe:GetWidth() - 25, 540)
    team_gb:SetSkinName("test_frame_low")
    AUTO_CAST(team_gb);

    local team_slotset = team_gb:CreateOrGetControl('slotset', 'team_slotset', 10, 10, 0, 0)
    AUTO_CAST(team_slotset);
    team_slotset:SetSlotSize(40, 40) -- スロットの大きさ
    team_slotset:EnablePop(1)
    team_slotset:EnableDrag(1)
    team_slotset:EnableDrop(1)
    -- team_slotset:SetNumberMode(1)
    team_slotset:SetColRow(17, 58) -- スロットの配置と個数
    team_slotset:SetSpc(0, 0)
    team_slotset:SetSkinName('slot')
    team_slotset:SetEventScript(ui.DROP, "another_warehouse_setting_drop")
    team_slotset:SetEventScript(ui.RBUTTONUP, "another_warehouse_setting_icon_clear")

    team_slotset:CreateSlots()
    local slotcount = team_slotset:GetSlotCount()

    for i = 1, slotcount do
        local slot = GET_CHILD_RECURSIVELY(team_slotset, "slot" .. i)
        local str_index = tostring(i)
        for key, value in pairs(g.settings.items) do
            if key == str_index then
                local clsid = value.clsid
                local count = value.count

                local itemcls = GetClassByType("Item", clsid)
                slot:SetUserValue("ITEM_CLSID", clsid)
                SET_SLOT_ITEM_CLS(slot, itemcls)

                if count ~= 0 then

                    SET_SLOT_COUNT_TEXT(slot, count)
                end

            end
        end
    end

    local char_gb = settingframe:CreateOrGetControl("groupbox", "char_gb", 20, 715, settingframe:GetWidth() - 25, 330)
    char_gb:SetSkinName("test_frame_low")
    AUTO_CAST(char_gb);

    local char_slotset = char_gb:CreateOrGetControl('slotset', 'char_slotset', 10, 10, 0, 0)
    AUTO_CAST(char_slotset);
    char_slotset:SetSlotSize(40, 40) -- スロットの大きさ
    char_slotset:EnablePop(1)
    char_slotset:EnableDrag(1)
    char_slotset:EnableDrop(1)
    char_slotset:SetColRow(17, 58) -- スロットの配置と個数
    char_slotset:SetSpc(0, 0)
    char_slotset:SetSkinName('slot')
    char_slotset:SetEventScript(ui.DROP, "another_warehouse_setting_drop")
    char_slotset:SetEventScript(ui.RBUTTONUP, "another_warehouse_setting_icon_clear")

    char_slotset:CreateSlots()

    local char_slotcount = char_slotset:GetSlotCount()

    for i = 1, char_slotcount do
        local slot = GET_CHILD_RECURSIVELY(char_slotset, "slot" .. i)
        local str_index = tostring(i)
        for key, value in pairs(g.settings[LoginCID].items) do
            if key == str_index then
                local clsid = value.clsid
                local count = value.count

                local itemcls = GetClassByType("Item", clsid)
                slot:SetUserValue("ITEM_CLSID", clsid)
                SET_SLOT_ITEM_CLS(slot, itemcls)

                if count ~= 0 then

                    SET_SLOT_COUNT_TEXT(slot, count)
                end

            end
        end
    end

    local WHM_SettingsFileLoc = string.format('../addons/%s/settings.json', 'warehousemanager')
    local WHM_settings = {}

    local err = acutil.loadJSON(WHM_SettingsFileLoc, WHM_settings)

    if err == nil then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", 'warehousemanager'))
        return
    end

    if g.settings.transfer ~= 1 or g.settings[LoginCID].transfer ~= 1 then
        local transfer = settingframe:CreateOrGetControl('button', "transfer", 610, 125, 100, 25)
        AUTO_CAST(transfer);
        transfer:SetSkinName("test_red_button")
        transfer:SetText("{ol}" .. another_warehouse_lang("Data copy"))
        transfer:SetTextTooltip(another_warehouse_lang("Data copy from [Wrehouse Manager]"))
        transfer:SetEventScript(ui.LBUTTONUP, "another_warehouse_data_transfer_confirmation")
    end

    --[[local delay_edit = settingframe:CreateOrGetControl('edit', 'delay_edit', 400, 120, 100, 25)
    AUTO_CAST(delay_edit)
    delay_edit:SetFontName("white_16_ol")
    delay_edit:SetTextAlign("center", "center") -- print(tostring(g.settings.silver))
    if g.settings.delay == nil then
        g.settings.delay = 0.3
        another_warehouse_save_settings()
    end
    delay_edit:SetTextTooltip(another_warehouse_lang(
        "If the warehouse entry fails,{nl}set a longer time. Basic is 0.5 sec."))
    delay_edit:SetText(tonumber(g.settings.delay))
    delay_edit:SetEventScript(ui.ENTERKEY, 'another_warehouse_setting_edit')

    local delay_text = settingframe:CreateOrGetControl("richtext", "delay_text", 505, 125, 100, 0)
    AUTO_CAST(delay_text);
    delay_text:SetText("{ol}" .. another_warehouse_lang("Put delay time"))]]

end

function another_warehouse_setting_edit(frame, ctrl, argStr, argNum)

    local ctrlnum = tonumber(ctrl:GetText())

    if ctrlnum == nil then
        ui.SysMsg(another_warehouse_lang("Please enter numerical values."))
        return
    end

    local ctrlName = tostring(ctrl:GetName())

    if ctrlName == "amount_edit" then
        g.settings.silver = ctrlnum
    elseif ctrlName == "delay_edit" then
        g.settings.delay = ctrlnum
    end
    another_warehouse_save_settings()
    another_warehouse_setting_frame_init(frame, ctrl, argStr, argNum)
end

function another_warehouse_data_transfer_confirmation(frame, ctrl, argStr, argNum)
    local yesScp = string.format("another_warehouse_data_transfer()");

    local str = another_warehouse_lang("Do you want to copy data from{nl}[Wrehouse Manager]?")
    ui.MsgBox(str, yesScp, "None");
    return;

end

function another_warehouse_data_transfer()

    -- 'WarehouseManager''Charbon'
    if g.settings.transfer ~= 1 then
        local WHM_SettingsFileLoc = string.format('../addons/%s/settings.json', 'warehousemanager')
        local WHM_settings = {}

        local settings, err = acutil.loadJSON(WHM_SettingsFileLoc, WHM_settings)
        if err then
            -- 設定ファイル読み込み失敗時処理
            CHAT_SYSTEM(string.format("[%s] cannot load setting files", 'warehousemanager'))
        end

        local clsid = 0
        local count = 0
        -- settingsがnilまたは空の場合は初期設定を使用する
        if settings then
            for key, value in pairs(settings) do

                if key == "ItemList" then
                    g.settings.items = {}
                    for key2, value2 in pairs(value) do
                        g.settings.items[tostring(key2)] = {}
                        for key3, value3 in pairs(value2) do

                            if key3 == "ItemType" then
                                g.settings.items[tostring(key2)].clsid = value3
                            elseif key3 == "Count" then
                                g.settings.items[tostring(key2)].count = value3
                            end

                        end
                    end

                end
            end
        end
        g.settings.transfer = 1
        another_warehouse_save_settings()
        another_warehouse_setting_frame_init(_, _, _, _)
        ReserveScript("another_warehouse_data_transfer_char()", 0.2)
    else
        another_warehouse_data_transfer_char()
    end

end

function another_warehouse_data_transfer_char()

    local LoginCID = info.GetCID(session.GetMyHandle())

    if g.settings[tostring(LoginCID)].transfer ~= 1 then

        local WHM_char_SettingsFileLoc = string.format("../addons/%s/%s.json", 'warehousemanager', LoginCID)
        -- print(tostring(WHM_char_SettingsFileLoc))
        local WHM_char_settings = {}

        local settings, err = acutil.loadJSON(WHM_char_SettingsFileLoc, WHM_char_settings)
        if err then
            -- 設定ファイル読み込み失敗時処理
            -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", 'WarehouseManagerキャラ設定'))
        end

        local clsid = 0
        local count = 0
        -- settingsがnilまたは空の場合は初期設定を使用する
        -- print(tostring(settings))
        if settings then

            for key, value in pairs(settings) do

                if key == "ItemList" then
                    g.settings[tostring(LoginCID)].items = {}
                    for key2, value2 in pairs(value) do
                        g.settings[tostring(LoginCID)].items[tostring(key2)] = {}
                        for key3, value3 in pairs(value2) do

                            if key3 == "ItemType" then
                                g.settings[tostring(LoginCID)].items[tostring(key2)].clsid = value3
                            elseif key3 == "Count" then
                                g.settings[tostring(LoginCID)].items[tostring(key2)].count = value3
                            end

                        end
                    end

                end
            end
        end

        g.settings[tostring(LoginCID)].transfer = 1
        another_warehouse_save_settings()
        another_warehouse_setting_frame_init(_, _, _, _)
        ui.SysMsg(another_warehouse_lang("Data copy completed."))
    else

        ui.SysMsg(another_warehouse_lang("Data copy completed."))
        return
    end

end

function another_warehouse_setting_drop(frame, ctrl, argStr, argNum)

    local lifticon = ui.GetLiftIcon();
    local fromframe = lifticon:GetTopParentFrame();
    local fromslot = lifticon:GetParent();
    local iconinfo = lifticon:GetInfo();
    local type = iconinfo.type

    local itemcls = GetClassByType("Item", type)
    local slot_icon = ctrl:GetIcon();

    local guid = iconinfo:GetIESID();
    local item = GET_ITEM_BY_GUID(guid);
    local obj = GetIES(item:GetObject());
    local index = string.gsub(ctrl:GetName(), "slot", "") * 1

    local LoginCID = info.GetCID(session.GetMyHandle())

    if fromframe:GetName() == "inventory" and slot_icon == nil then
        if true == item.isLockState then
            ui.SysMsg(ClMsg("MaterialItemIsLock"));
            return;
        end

        if itemcls.ItemType == 'Quest' then
            ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"));
            return;
        end

        local enableTeamTrade = TryGetProp(itemcls, "TeamTrade");
        if enableTeamTrade ~= nil and enableTeamTrade == "NO" then
            ui.SysMsg(ClMsg("ItemIsNotTradable"));
            return;
        end

        local belongingCount = TryGetProp(obj, 'BelongingCount', 0)
        if belongingCount > 0 and belongingCount >= item.count then
            ui.SysMsg(ClMsg("ItemIsNotTradable"));
            return;
        end

        if TryGetProp(obj, 'CharacterBelonging', 0) == 1 then
            ui.SysMsg(ClMsg("ItemIsNotTradable"));
            return;
        end
    end

    if fromframe:GetName() == "inventory" and tostring(ctrl:GetParent():GetName()) == "team_slotset" then

        for key, value in pairs(g.settings.items) do
            local clsid = value.clsid

            if tostring(type) == tostring(clsid) then
                ui.SysMsg(another_warehouse_lang("Already registered."))
                return
            end

        end

        ctrl:SetEventScript(ui.LBUTTONUP, "another_warehouse_setting_drop")

        if tonumber(itemcls.MaxStack) > 1 then
            local frame = ui.GetFrame("another_warehouse_setting")
            frame:SetUserValue("SLOT_NAME", ctrl:GetParent():GetName())

            INPUT_NUMBER_BOX(frame, another_warehouse_lang('Enter the number to be left in the inventory.'),
                "another_warehouse_setting_item_count", 0, 0, tonumber(itemcls.MaxStack), type, tostring(index), nil)
        else

            if g.settings.items[tostring(index)] == nil then
                g.settings.items[tostring(index)] = {
                    clsid = tonumber(type),
                    count = 0
                }
            end
            SET_SLOT_ITEM_CLS(ctrl, itemcls)
            another_warehouse_save_settings()
        end
    elseif fromframe:GetName() == "inventory" and tostring(ctrl:GetParent():GetName()) == "char_slotset" then

        for key, value in pairs(g.settings[LoginCID].items) do
            local clsid = value.clsid

            if tostring(type) == tostring(clsid) then
                ui.SysMsg(another_warehouse_lang("Already registered."))
                return
            end

        end

        ctrl:SetEventScript(ui.LBUTTONUP, "another_warehouse_setting_drop")
        if tonumber(itemcls.MaxStack) > 1 then
            local frame = ui.GetFrame("another_warehouse_setting")
            frame:SetUserValue("SLOT_NAME", ctrl:GetParent():GetName())
            INPUT_NUMBER_BOX(frame, another_warehouse_lang('Enter the number to be left in the inventory.'),
                "another_warehouse_setting_item_count", 0, 0, tonumber(itemcls.MaxStack), type, tostring(index), nil)
        else

            if g.settings[LoginCID].items[tostring(index)] == nil then
                g.settings[LoginCID].items[tostring(index)] = {
                    clsid = tonumber(type),
                    count = 0
                }
            end
            SET_SLOT_ITEM_CLS(ctrl, itemcls)
            another_warehouse_save_settings()
        end
    end

    if fromframe:GetName() == "another_warehouse_setting" and tostring(ctrl:GetParent():GetName()) == "team_slotset" then

        local fromslot = lifticon:GetParent();
        local fromframe = fromslot:GetParent():GetName()

        local fromindex = string.gsub(fromslot:GetName(), "slot", "") * 1
        local toindex = string.gsub(ctrl:GetName(), "slot", "") * 1

        if g.settings.items[tostring(toindex)] == nil and fromframe == "char_slotset" then
            local type = fromslot:GetUserIValue("ITEM_CLSID")

            for key, value in pairs(g.settings.items) do
                local clsid = value.clsid

                if tostring(type) == tostring(clsid) then
                    ui.SysMsg(another_warehouse_lang("Already registered."))
                    return
                end

            end

            g.settings.items[tostring(toindex)] = {
                clsid = g.settings[LoginCID].items[tostring(fromindex)].clsid,
                count = g.settings[LoginCID].items[tostring(fromindex)].count
            }

        elseif g.settings.items[tostring(toindex)] == nil and fromframe == "team_slotset" then

            g.settings.items[tostring(toindex)] = {
                clsid = g.settings.items[tostring(fromindex)].clsid,
                count = g.settings.items[tostring(fromindex)].count
            }

            g.settings.items[tostring(fromindex)] = nil

        end
        another_warehouse_save_settings()
        another_warehouse_setting_frame_init(_, _, _, _)

    elseif fromframe:GetName() == "another_warehouse_setting" and tostring(ctrl:GetParent():GetName()) == "char_slotset" then

        local fromslot = lifticon:GetParent();
        local fromframe = fromslot:GetParent():GetName()

        local fromindex = string.gsub(fromslot:GetName(), "slot", "") * 1
        local toindex = string.gsub(ctrl:GetName(), "slot", "") * 1

        if g.settings[LoginCID].items[tostring(toindex)] == nil and fromframe == "team_slotset" then

            for key, value in pairs(g.settings[LoginCID].items) do
                local type = fromslot:GetUserIValue("ITEM_CLSID")
                local clsid = value.clsid

                if tostring(type) == tostring(clsid) then
                    ui.SysMsg(another_warehouse_lang("Already registered."))
                    return
                end

            end

            g.settings[LoginCID].items[tostring(toindex)] = {
                clsid = g.settings.items[tostring(fromindex)].clsid,
                count = g.settings.items[tostring(fromindex)].count
            }

        elseif g.settings[LoginCID].items[tostring(toindex)] == nil then

            g.settings[LoginCID].items[tostring(toindex)] = {
                clsid = g.settings[LoginCID].items[tostring(fromindex)].clsid,
                count = g.settings[LoginCID].items[tostring(fromindex)].count

            }

            g.settings[LoginCID].items[tostring(fromindex)] = nil

        end
        another_warehouse_save_settings()
        another_warehouse_setting_frame_init(_, _, _, _)
    end

end

function another_warehouse_setting_check(frame, ctrl, argStr, argNum)

    local LoginCID = info.GetCID(session.GetMyHandle())

    local ischeck = ctrl:IsChecked()

    local ctrlName = ctrl:GetName()

    if ctrlName == "amount_check" then
        g.settings[tostring(ctrlName)] = ischeck
    elseif ctrlName == "leave" then
        g.settings.leave = ischeck
    else
        g.settings[LoginCID][tostring(ctrlName)] = ischeck
    end

    another_warehouse_save_settings()
end

function another_warehouse_setting_rbtn(itemObj, slot)

    local LoginCID = info.GetCID(session.GetMyHandle())

    local icon = slot:GetIcon();
    local iconInfo = icon:GetInfo();
    local iesid = iconInfo:GetIESID()
    local invItem = GET_PC_ITEM_BY_GUID(iesid);

    if nil == invItem then
        return;
    end

    local type = iconInfo.type
    local itemcls = GetClassByType("Item", type)

    local guid = iconInfo:GetIESID();
    local item = GET_ITEM_BY_GUID(guid);
    local obj = GetIES(item:GetObject());

    if true == item.isLockState then
        ui.SysMsg(ClMsg("MaterialItemIsLock"));
        return;
    end

    if itemcls.ItemType == 'Quest' then
        ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"));
        return;
    end

    local enableTeamTrade = TryGetProp(itemcls, "TeamTrade");
    if enableTeamTrade ~= nil and enableTeamTrade == "NO" then
        ui.SysMsg(ClMsg("ItemIsNotTradable"));
        return;
    end

    local belongingCount = TryGetProp(obj, 'BelongingCount', 0)
    if belongingCount > 0 and belongingCount >= item.count then
        ui.SysMsg(ClMsg("ItemIsNotTradable"));
        return;
    end

    if TryGetProp(obj, 'CharacterBelonging', 0) == 1 then
        ui.SysMsg(ClMsg("ItemIsNotTradable"));
        return;
    end

    if keyboard.IsKeyPressed("LSHIFT") == 1 then
        for key, value in pairs(g.settings[LoginCID].items) do

            for k, v in pairs(value) do

                if tostring(type) == tostring(v) then
                    ui.SysMsg(another_warehouse_lang("Already registered."))
                    return
                end
            end
        end

        local frame = ui.GetFrame("another_warehouse_setting")
        local char_slotset = GET_CHILD_RECURSIVELY(frame, "char_slotset")
        local slotcount = char_slotset:GetSlotCount()
        local index = 1

        for i = 1, slotcount do
            local awslot = GET_CHILD_RECURSIVELY(char_slotset, "slot" .. i)
            local slot_icon = awslot:GetIcon();
            if slot_icon == nil then
                index = i
                break
            end
        end

        local ctrl = GET_CHILD_RECURSIVELY(char_slotset, "slot" .. index)
        ctrl:SetEventScript(ui.LBUTTONUP, "another_warehouse_setting_drop")

        if tonumber(itemcls.MaxStack) > 1 then
            local frame = ui.GetFrame("another_warehouse_setting")
            frame:SetUserValue("SLOT_NAME", ctrl:GetParent():GetName())
            INPUT_NUMBER_BOX(frame, another_warehouse_lang('Enter the number to be left in the inventory.'),
                "another_warehouse_setting_item_count", 0, 0, tonumber(itemcls.MaxStack), type, tostring(index), nil)
        else

            if g.settings[LoginCID].items[tostring(index)] == nil then
                g.settings[LoginCID].items[tostring(index)] = {
                    clsid = tonumber(type),
                    count = 0
                }
            end

            SET_SLOT_ITEM_CLS(ctrl, itemcls)

            another_warehouse_save_settings()
        end
    else
        for key, value in pairs(g.settings.items) do

            for k, v in pairs(value) do

                if tostring(type) == tostring(v) then
                    ui.SysMsg(another_warehouse_lang("Already registered."))
                    return
                end
            end
        end

        local frame = ui.GetFrame("another_warehouse_setting")
        local team_slotset = GET_CHILD_RECURSIVELY(frame, "team_slotset")
        local slotcount = team_slotset:GetSlotCount()
        local index = 1

        for i = 1, slotcount do
            local awslot = GET_CHILD_RECURSIVELY(team_slotset, "slot" .. i)
            local slot_icon = awslot:GetIcon();
            if slot_icon == nil then
                index = i
                break
            end
        end

        local ctrl = GET_CHILD_RECURSIVELY(team_slotset, "slot" .. index)
        ctrl:SetEventScript(ui.LBUTTONUP, "another_warehouse_setting_drop")

        if tonumber(itemcls.MaxStack) > 1 then
            local frame = ui.GetFrame("another_warehouse_setting")
            frame:SetUserValue("SLOT_NAME", ctrl:GetParent():GetName())
            INPUT_NUMBER_BOX(frame, another_warehouse_lang('Enter the number to be left in the inventory.'),
                "another_warehouse_setting_item_count", 0, 0, tonumber(itemcls.MaxStack), type, tostring(index), nil)
        else

            if g.settings.items[tostring(index)] == nil then
                g.settings.items[tostring(index)] = {
                    clsid = tonumber(type),
                    count = 0
                }
            end

            SET_SLOT_ITEM_CLS(ctrl, itemcls)

            another_warehouse_save_settings()
        end
    end
end

function another_warehouse_setting_item_count(frame, count, inputFrame)

    local type = inputFrame:GetValue()

    local index = inputFrame:GetUserValue("ArgString");

    local itemcls = GetClassByType("Item", type)
    local user_value = frame:GetUserValue("SLOT_NAME")

    local LoginCID = info.GetCID(session.GetMyHandle())
    if user_value == "team_slotset" then
        local slotset = GET_CHILD_RECURSIVELY(frame, user_value)
        local slot = GET_CHILD_RECURSIVELY(slotset, "slot" .. index)
        if g.settings.items[tostring(index)] == nil then
            g.settings.items[tostring(index)] = {
                clsid = tonumber(type),
                count = tonumber(count)
            }
        elseif g.settings.items[tostring(index)] ~= nil then
            g.settings.items[tostring(index)] = {
                clsid = tonumber(type),
                count = tonumber(count)
            }
        end
        SET_SLOT_ITEM_CLS(slot, itemcls)
        another_warehouse_save_settings()

        inputFrame:ShowWindow(0)
        another_warehouse_setting_frame_init(_, _, _, _)
    elseif user_value == "char_slotset" then
        local slotset = GET_CHILD_RECURSIVELY(frame, user_value)
        local slot = GET_CHILD_RECURSIVELY(slotset, "slot" .. index)

        if g.settings[LoginCID].items[tostring(index)] == nil then
            g.settings[LoginCID].items[tostring(index)] = {
                clsid = tonumber(type),
                count = tonumber(count)
            }
        elseif g.settings[LoginCID].items[tostring(index)] ~= nil then
            g.settings[LoginCID].items[tostring(index)] = {
                clsid = tonumber(type),
                count = tonumber(count)
            }
        end
        SET_SLOT_ITEM_CLS(slot, itemcls)
        another_warehouse_save_settings()

        inputFrame:ShowWindow(0)
        another_warehouse_setting_frame_init(_, _, _, _)
    end

end

function another_warehouse_setting_count_change(frame, ctrl, argStr, argNum)

    local slot_index = string.gsub(ctrl:GetName(), "slot", "") * 1

    local type = ctrl:GetUserIValue("ITEM_CLSID")
    local itemcls = GetClassByType("Item", type)
    local awsframe = ui.GetFrame("another_warehouse_setting")
    awsframe:SetUserValue("SLOT_NAME", ctrl:GetParent():GetName())
    INPUT_NUMBER_BOX(awsframe, another_warehouse_lang('Enter the number to be left in the inventory.'),
        "another_warehouse_setting_item_count", 0, 0, tonumber(itemcls.MaxStack), type, tostring(slot_index), nil)

end

function another_warehouse_setting_icon_clear(frame, ctrl, argStr, argNum)
    if keyboard.IsKeyPressed("LSHIFT") == 1 then

        another_warehouse_setting_count_change(frame, ctrl, argStr, argNum)
        return
    end

    local LoginCID = info.GetCID(session.GetMyHandle())
    if frame:GetName() == "team_slotset" then
        local str_index = string.gsub(ctrl:GetName(), "slot", "")
        for key, value in pairs(g.settings.items) do
            if key == str_index then
                ctrl:ClearIcon();
                g.settings.items[str_index] = nil
                another_warehouse_save_settings()
                break
            end
        end
    elseif frame:GetName() == "char_slotset" then
        local str_index = string.gsub(ctrl:GetName(), "slot", "")
        for key, value in pairs(g.settings[LoginCID].items) do
            if key == str_index then
                ctrl:ClearIcon();
                g.settings[LoginCID].items[str_index] = nil
                another_warehouse_save_settings()
                break
            end
        end
    else
        return
    end
    another_warehouse_setting_frame_init(_, _, _, _)
end

function another_warehouse_setting_close(frame, ctrl, argStr, argNum)
    frame:ShowWindow(0)
    INVENTORY_SET_CUSTOM_RBTNDOWN("None")
    SET_INV_LBTN_FUNC(ui.GetFrame("inventory"), "None");
    -- !
end

function another_warehouse_notice()
    local msg = another_warehouse_lang("Notice from [another warehouse]")
    NICO_CHAT("{@st55_a}" .. msg)
    local msg2 = another_warehouse_lang(
        "[Yet Another Account Inventory] add-on is installed and will not function properly.")
    NICO_CHAT("{@st55_a}" .. msg2)

end

function another_warehouse_accountwarehouse_close()

    another_warehouse_deactive_mousebutton()
    local msframe = ui.GetFrame("monstercardslot")
    msframe:SetLayerLevel(96)

    local overlap = ui.GetFrame("another_warehouse")
    overlap:ShowWindow(0)

    local setframe = ui.GetFrame("another_warehouse_set_items")
    setframe:ShowWindow(0)

end

--[[function another_warehouse_accountwarehouse_save()
    local frame = ui.GetFrame("accountwarehouse")
    local tab = GET_CHILD(frame, "accountwarehouse_tab");
    local accountObj = GetMyAccountObj();
    local basecount = accountObj.BasicAccountWarehouseSlotCount + accountObj.MaxAccountWarehouseCount +
                          accountObj.AccountWareHouseExtend + accountObj.AccountWareHouseExtendByItem +
                          ADDITIONAL_SLOT_COUNT_BY_TOKEN

    for i = 0, 4 do
        if i == 0 then
            tab:SelectTab(i)
            local slotset = GET_CHILD_RECURSIVELY(frame, "slotset")
            for j = 1, basecount do
                local slot = slotset:GetSlotByIndex(j)
                AUTO_CAST(slot)
                local icon = slot:GetIcon()
                if icon == nil then

                    local iconInfo = icon:GetInfo();
                    local invItem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iconInfo:GetIESID());
                end

            end
        end
    end
end]]

function another_warehouse_item_count()
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidlist = itemList:GetSortedGuidList();
    local cnt = itemList:Count();
    local rcnt = 0
    for i = 0, cnt - 1 do
        local guid = guidlist:Get(i);
        local invItem = itemList:GetItemByGuid(guid)
        if (invItem ~= nil) then
            local invItem_obj = GetIES(invItem:GetObject());
            if invItem_obj.ClassName ~= MONEY_NAME then
                rcnt = rcnt + 1
            end
        end
    end

    return rcnt
end

function another_warehouse_checkvalid(iesid)
    local invItem = session.GetInvItemByGuid(iesid)

    local obj = GetIES(invItem:GetObject())
    local itemcnt = another_warehouse_item_count()
    local maxcount = another_warehouse_get_maxcount()

    if maxcount <= itemcnt then

        ui.SysMsg(ClMsg('CannotPutBecauseMaxSlot'));
        return;
    end
    if true == invItem.isLockState then

        ui.SysMsg(ClMsg("MaterialItemIsLock"));

        return;
    end

    local itemCls = GetClassByType("Item", obj.ClassID);
    if itemCls.ItemType == 'Quest' then

        ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"));

        return;
    end

    local enableTeamTrade = TryGetProp(itemCls, "TeamTrade");
    if enableTeamTrade ~= nil and enableTeamTrade == "NO" then

        ui.SysMsg(ClMsg("ItemIsNotTradable"));

        return;

    end

end

function another_warehouse_putitem(iesid, count)

    another_warehouse_checkvalid(iesid)

    local invItem = session.GetInvItemByGuid(iesid)
    local invItem_obj = GetIES(invItem:GetObject());

    local exist, index = another_warehouse_get_exist_item_index(invItem_obj)

    local goal_index = another_warehouse_get_goal_index()

    if exist == true and index >= 0 then
        goal_index = index
    end

    local frame = ui.GetFrame("accountwarehouse")

    item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, iesid, tostring(math.min(count or invItem.count, invItem.count)),
        frame:GetUserIValue("HANDLE"), goal_index)

end

function another_warehouse_active_mousebutton()

    if (ui.GetFrame("accountwarehouse"):IsVisible() == 1) then

        local invframe = ui.GetFrame("inventory")
        INVENTORY_SET_CUSTOM_RBTNDOWN("another_warehouse_inv_rbtn")

        SET_INV_LBTN_FUNC(invframe, "another_warehouse_inv_lbtn")
    end
end

function another_warehouse_inv_lbtn(frame, invItem, dumm)

    local iesid = invItem:GetIESID()

    if keyboard.IsKeyPressed("LSHIFT") == 1 then

        --[[local frame = ui.GetFrame("accountwarehouse")
        local obj = GetIES(invItem:GetObject())

        local maxCnt = invItem.count;
        local belongingCount = TryGetProp(obj, 'BelongingCount', 0)
        if belongingCount > 0 then
            maxCnt = invItem.count - obj.BelongingCount;
            if maxCnt <= 0 then
                maxCnt = 0;
            end
        end

        if invItem.count > 1 or geItemTable.IsStack(obj.ClassID) == 1 then
            INPUT_NUMBER_BOX(frame, ScpArgMsg("InputCount"), "EXEC_PUT_ITEM_TO_ACCOUNT_WAREHOUSE", maxCnt, 1, maxCnt,
                nil, tostring(invItem:GetIESID()));
        else
            another_warehouse_putitem(iesid, 1)
        end]]
        local count = math.min(10, invItem.count)
        another_warehouse_putitem(iesid, count)

    else
        another_warehouse_putitem(iesid, 1)
    end
end

function another_warehouse_inv_rbtn(itemObj, slot)

    local icon = slot:GetIcon();
    local iconInfo = icon:GetInfo();
    local iesid = iconInfo:GetIESID()
    local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());

    if nil == invItem then
        return;
    end

    if keyboard.IsKeyPressed("LSHIFT") == 1 then

        local frame = ui.GetFrame("accountwarehouse")
        local obj = GetIES(invItem:GetObject())

        local maxCnt = invItem.count;
        local belongingCount = TryGetProp(obj, 'BelongingCount', 0)
        if belongingCount > 0 then
            maxCnt = invItem.count - obj.BelongingCount;
            if maxCnt <= 0 then
                maxCnt = 0;
            end
        end

        if invItem.count > 1 or geItemTable.IsStack(obj.ClassID) == 1 then
            INPUT_NUMBER_BOX(frame, ScpArgMsg("InputCount"), "EXEC_PUT_ITEM_TO_ACCOUNT_WAREHOUSE", maxCnt, 1, maxCnt,
                nil, tostring(invItem:GetIESID()));
        else
            another_warehouse_putitem(iesid, invItem.count)
        end
    else
        another_warehouse_putitem(iesid, invItem.count)
    end

end

function another_warehouse_deactive_mousebutton()

    INVENTORY_SET_CUSTOM_RBTNDOWN("None")
    SET_INV_LBTN_FUNC(ui.GetFrame("inventory"), "None");

end

function another_warehouse_on_msg(frame, msg, argStr, argNum)

    if msg == 'ACCOUNT_WAREHOUSE_ITEM_LIST' then
        another_warehouse_frame_update()
    elseif msg == 'ACCOUNT_WAREHOUSE_ITEM_IN' then

        -- no op
    elseif msg == 'ACCOUNT_WAREHOUSE_ITEM_ADD' then
        DebounceScript("another_warehouse_frame_update", 1.0, 0)

    elseif msg == 'ACCOUNT_WAREHOUSE_ITEM_REMOVE' then

        another_warehouse_remove_targeted(argStr)
        DebounceScript("another_warehouse_frame_update", 3.0, 0)

    elseif msg == 'ACCOUNT_WAREHOUSE_ITEM_CHANGE_COUNT' then
        another_warehouse_remove_targeted(argStr)

        another_warehouse_frame_update()
    else
        another_warehouse_frame_update()
    end

end

function another_warehouse_remove_targeted(itemguid)

    local frame = ui.GetFrame("another_warehouse")

    another_warehouse_remove_recurse_guid(frame, itemguid)

end
function another_warehouse_remove_recurse_guid(parent, guid)

    for i = 0, parent:GetChildCount() - 1 do
        local child = parent:GetChildByIndex(i)

        if (string.find(child:GetClassString(), "CSlotSet")) then
            AUTO_CAST(child)
            for j = 0, child:GetSlotCount() - 1 do
                local slot = child:GetSlotByIndex(j)
                local icon = slot:GetIcon();
                if (icon ~= nil) then
                    local iconInfo = icon:GetInfo();

                    if (iconInfo:GetIESID() == guid) then
                        slot:ClearIcon()
                        slot:SetSkinName("invenslot2")
                        slot:SetText("")
                        slot:RemoveAllChild()

                        break
                    end

                end
            end
        else
            another_warehouse_remove_recurse_guid(child, guid)
        end

    end

end

function another_warehouse_get_maxcount()
    local accountObj = GetMyAccountObj();

    local maxcnt = 0
    if session.loginInfo.IsPremiumState(ITEM_TOKEN) == true then
        maxcnt = accountObj.BasicAccountWarehouseSlotCount + accountObj.MaxAccountWarehouseCount +
                     accountObj.AccountWareHouseExtend + accountObj.AccountWareHouseExtendByItem +
                     ADDITIONAL_SLOT_COUNT_BY_TOKEN + 280
        return maxcnt
    else
        maxcnt = accountObj.BasicAccountWarehouseSlotCount + accountObj.MaxAccountWarehouseCount +
                     accountObj.AccountWareHouseExtend + accountObj.AccountWareHouseExtendByItem +
                     ADDITIONAL_SLOT_COUNT_BY_TOKEN
        return maxcnt
    end

end

function another_warehouse_frame_close(frame, ctrl)
    local frame = ui.GetFrame("another_warehouse")
    frame:ShowWindow(0)

    local awframe = ui.GetFrame("accountwarehouse")
    -- awframe:ShowWindow(1)
    local accountwarehouse_tab = GET_CHILD_RECURSIVELY(awframe, "accountwarehouse_tab")
    accountwarehouse_tab:SetMargin(0, 120, 0, 0) -- margin="0 120 0 0"
    local richtext_1 = GET_CHILD_RECURSIVELY(awframe, "richtext_1")
    richtext_1:SetMargin(30, 73, 0, 0) --  margin="30 73 0 0"
    local itemcnt = GET_CHILD_RECURSIVELY(awframe, "itemcnt")
    itemcnt:SetMargin(0, 73, 190, 0) --  margin="0 73 190 0"
    local slotgbox = GET_CHILD_RECURSIVELY(awframe, "slotgbox")
    slotgbox:ShowWindow(1)

    local awclose = GET_CHILD_RECURSIVELY(awframe, "awclose")
    awclose:ShowWindow(0)

    local count_text = GET_CHILD_RECURSIVELY(awframe, "count_text")
    count_text:ShowWindow(0)

    local awsetting = GET_CHILD_RECURSIVELY(awframe, "awsetting")
    awsetting:ShowWindow(0)

    local take = GET_CHILD_RECURSIVELY(awframe, "take")
    take:ShowWindow(0)

    another_warehouse_deactive_mousebutton()
    INVENTORY_SET_CUSTOM_RBTNDOWN("ACCOUNT_WAREHOUSE_INV_RBTN")
end

function another_warehouse_find_activegbox(frame)

    for typeNo = 1, #g_invenTypeStrList do
        if not IsBlackListedTabName(g_invenTypeStrList[typeNo]) then
            local tree_box = GET_CHILD_RECURSIVELY(frame, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox');
            if (tree_box:IsVisible() == 1) then

                return tree_box
            end
        end

    end

    return nil

end

function another_warehouse_get_slotset_name(baseidcls)

    local cls = baseidcls
    if cls == nil then
        return 'error'
    else
        local className = cls.ClassName
        if cls.MergedTreeTitle ~= "NO" then
            className = cls.MergedTreeTitle
        end
        return 'sset_' .. className
    end
end

function another_warehouse_make_inven_slotset(tree, name)

    local frame = ui.GetFrame('another_warehouse');

    local slotsize = 54
    local colcount = 10

    local newslotset = tree:CreateOrGetControl('slotset', name, 0, 0, 0, 0)
    tolua.cast(newslotset, "ui::CSlotSet");

    newslotset:EnablePop(1)
    newslotset:EnableDrag(1)
    newslotset:EnableDrop(1)
    newslotset:SetMaxSelectionCount(999)
    newslotset:SetSlotSize(slotsize, slotsize);
    newslotset:SetColRow(colcount, 1)
    newslotset:SetSpc(0, 0)
    newslotset:SetSkinName('invenslot')
    newslotset:EnableSelection(0)
    newslotset:CreateSlots();
    ui.inventory.AddInvenSlotSetName(name);
    return newslotset;
end

function another_warehouse_inven_slotset_and_title(tree, treegroup, slotsetname, baseidcls)

    local slotsettitle = 'ssettitle_' .. baseidcls.ClassName;
    if baseidcls.MergedTreeTitle ~= "NO" then
        slotsettitle = 'ssettitle_' .. baseidcls.MergedTreeTitle
    end

    local newSlotsname = MAKE_INVEN_SLOTSET_NAME(tree, slotsettitle, baseidcls.TreeSSetTitle)
    local newSlots = another_warehouse_make_inven_slotset(tree, slotsetname)
    tree:Add(treegroup, newSlotsname, slotsettitle);
    local slotHandle = tree:Add(treegroup, newSlots, slotsetname);
    local slotNode = tree:GetNodeByTreeItem(slotHandle);
    slotNode:SetUserValue("IS_ITEM_SLOTSET", 1);
end

function another_warehouse_insert_item_to_tree(frame, tree, invItem, itemCls, baseidcls, typeStr)

    local treegroupname = baseidcls.TreeGroup

    local treegroup = tree:FindByValue(treegroupname);
    if tree:IsExist(treegroup) == 0 then
        treegroup = tree:Add(baseidcls.TreeGroupCaption, baseidcls.TreeGroup);
        local treeNode = tree:GetNodeByTreeItem(treegroup);
        treeNode:SetUserValue("BASE_CAPTION", baseidcls.TreeGroupCaption);

        -- ui.inventory.AddInvenGroupName(treegroupname);
    end

    -- 슬롯셋 없으면 만들기
    local slotsetname = another_warehouse_get_slotset_name(baseidcls)
    local slotsetnode = tree:FindByValue(treegroup, slotsetname);
    if tree:IsExist(slotsetnode) == 0 then
        local slotsettitle = 'ssettitle_' .. baseidcls.ClassName;
        if baseidcls.MergedTreeTitle ~= "NO" then
            slotsettitle = 'ssettitle_' .. baseidcls.MergedTreeTitle
        end

        local newSlotsname = MAKE_INVEN_SLOTSET_NAME(tree, slotsettitle, baseidcls.TreeSSetTitle)

        g.tree[typeStr] = g.tree[typeStr] or {}
        g.tree[typeStr][#g.tree[typeStr] + 1] = {
            treegroup = treegroupname,
            treegroupcaption = newSlotsname:GetText():gsub("%(.*%)", ""),
            slotsetname = slotsetname
        }
        another_warehouse_inven_slotset_and_title(tree, treegroup, slotsetname, baseidcls);

        INVENTORY_CATEGORY_OPENOPTION_CHECK(tree:GetName(), baseidcls.ClassName);
    end
    local slotset = GET_CHILD_RECURSIVELY(tree, slotsetname, 'ui::CSlotSet');
    local slotCount = slotset:GetSlotCount();
    local slotindex = slotCount;

    -- 검색 기능
    local slot = nil;

    local cnt = GET_SLOTSET_COUNT(tree, baseidcls);
    -- 저장된 템의 최대 인덱스에 따라 자동으로 늘어나도록. 예를들어 해당 셋이 10000부터 시작하는데 10500 이 오면 500칸은 늘려야됨
    while slotCount <= cnt do
        slotset:ExpandRow()
        slotCount = slotset:GetSlotCount();
    end

    slot = slotset:GetSlotByIndex(cnt);
    cnt = cnt + 1;
    slotset:SetUserValue("SLOT_ITEM_COUNT", cnt)

    slot:ShowWindow(1);
    UPDATE_INVENTORY_SLOT(slot, invItem, itemCls);

    local function _DRAW_ITEM(invItem, slot)
        local obj = GetIES(invItem:GetObject());

        slot:SetSkinName('invenslot2')
        local itemCls = GetIES(invItem:GetObject());
        local iconImg = GET_ITEM_ICON_IMAGE(itemCls);

        slot:SetHeaderImage('None')

        SET_SLOT_IMG(slot, iconImg)
        SET_SLOT_COUNT(slot, invItem.count)

        SET_SLOT_STYLESET(slot, itemCls)
        SET_SLOT_IESID(slot, invItem:GetIESID())
        SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, invItem, obj, nil)
        slot:SetMaxSelectCount(invItem.count);
        local icon = slot:GetIcon();
        icon:SetTooltipArg("accountwarehouse", invItem.type, invItem:GetIESID());
        SET_ITEM_TOOLTIP_TYPE(icon, itemCls.ClassID, itemCls, "accountwarehouse");

        if invItem.hasLifeTime == true or TryGetProp(obj, 'ExpireDateTime', 'None') ~= 'None' then
            ICON_SET_ITEM_REMAIN_LIFETIME(icon, IT_ACCOUNT_WAREHOUSE);
            slot:SetFrontImage('clock_inven');
        else
            CLEAR_ICON_REMAIN_LIFETIME(slot, icon);
        end
        -- 아이커 종류 표시
        SET_SLOT_ICOR_CATEGORY(slot, itemCls);

    end
    -- INV_ICON_SETINFO(frame, slot, invItem, nil, nil, nil);
    _DRAW_ITEM(invItem, slot, nil)
    SET_SLOTSETTITLE_COUNT(tree, baseidcls, 1)
    if (g.settings.enabledrag) then
        slot:EnableDrag(1)
    else
        slot:EnableDrag(0)
    end
    slot:SetEventScript(ui.LBUTTONUP, "another_warehouse_on_lbutton")
    slot:SetEventScript(ui.RBUTTONUP, "another_warehouse_on_rbutton")
    slotset:MakeSelectionList();
    -- slotset:EnableSelection(1)
end

function another_warehouse_take_item_from_warehouse(frame, count, inputframe)
    inputframe:ShowWindow(0);
    local iesid = inputframe:GetUserValue("ArgString");
    session.ResetItemList();
    session.AddItemID(iesid, count);
    item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), frame:GetUserIValue("HANDLE"));
end

function another_warehouse_on_lbutton(frame, slot, argstr, argnum)

    local awframe = ui.GetFrame("accountwarehouse");
    local icon = slot:GetIcon();
    if (icon == nil) then
        return

    end
    local iconInfo = icon:GetInfo();
    if (iconInfo == nil) then
        return
    end
    local invItem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iconInfo:GetIESID());
    local iesid = invItem:GetIESID()
    local obj = GetIES(invItem:GetObject())

    if keyboard.IsKeyPressed("LSHIFT") == 1 then
        --[[local belongingCount = TryGetProp(obj, 'BelongingCount', 0)
        local maxCnt = invItem.count;
        if belongingCount > 0 then
            maxCnt = invItem.count - obj.BelongingCount;
            if maxCnt <= 0 then
                maxCnt = 0;
            end
        end

        if invItem.count > 1 or geItemTable.IsStack(obj.ClassID) == 1 then
            INPUT_NUMBER_BOX(awframe, ScpArgMsg("InputCount"), "another_warehouse_take_item_from_warehouse", maxCnt, 1,
                maxCnt, nil, iesid);
        else
            another_warehouse_takeitem(awframe, iesid, 1)

        end]]
        local count = math.min(10, invItem.count)
        another_warehouse_takeitem(awframe, iesid, count)
    else
        --[[if invItem.count > 1 or geItemTable.IsStack(obj.ClassID) == 1 then
            another_warehouse_takeitem(awframe, iesid, 10)
        else
           
        end]]
        another_warehouse_takeitem(awframe, iesid, 1)
    end
    -- another_warehouse_put_account_item_to_warehouse(frame, slot)
    -- another_warehouse_takeitem(awframe, iesid, 10)

end

function another_warehouse_on_rbutton(frame, slot, argstr, argnum)

    local awframe = ui.GetFrame("accountwarehouse");
    local icon = slot:GetIcon();
    if (icon == nil) then
        return

    end
    local iconInfo = icon:GetInfo();
    if (iconInfo == nil) then
        return
    end
    local invItem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iconInfo:GetIESID());
    local iesid = invItem:GetIESID()
    local obj = GetIES(invItem:GetObject())
    local count = invItem.count

    if keyboard.IsKeyPressed("LSHIFT") == 1 then
        local belongingCount = TryGetProp(obj, 'BelongingCount', 0)
        local maxCnt = invItem.count;
        if belongingCount > 0 then
            maxCnt = invItem.count - obj.BelongingCount;
            if maxCnt <= 0 then
                maxCnt = 0;
            end
        end

        if invItem.count > 1 or geItemTable.IsStack(obj.ClassID) == 1 then
            INPUT_NUMBER_BOX(awframe, ScpArgMsg("InputCount"), "another_warehouse_take_item_from_warehouse", maxCnt, 1,
                maxCnt, nil, iesid);
        else
            another_warehouse_takeitem(awframe, iesid, 1)

        end
    else
        if invItem.count > 1 or geItemTable.IsStack(obj.ClassID) == 1 then
            -- 1個残す
            if g.settings.leave == 1 then
                count = invItem.count - 1

            end
            another_warehouse_takeitem(awframe, iesid, count)
        else
            another_warehouse_takeitem(awframe, iesid, 1)
        end
    end
    -- another_warehouse_takeitem(awframe, iesid, count)
    -- !YAI_HANDLE_ACTION(invItem, "R", false)

end

function another_warehouse_frame_update()

    g.tree = {}
    local frame = ui.GetFrame("another_warehouse")

    local invenTypeStr = nil
    local invframe = ui.GetFrame("inventory")
    local awframe = ui.GetFrame("accountwarehouse")
    local blinkcolor = frame:GetUserConfig("TREE_SEARCH_BLINK_COLOR");
    local group = GET_CHILD_RECURSIVELY(frame, 'inventoryGbox', 'ui::CGroupBox')

    local etree_box = another_warehouse_find_activegbox(frame)
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetSortedGuidList();
    local isShowMap = {};
    local sortedCnt = sortedGuidList:Count();

    local invItemCount = sortedCnt;

    local invItemList = {}
    local index_count = 1
    local cls_inv_index = {}
    local i_cnt = 0

    local curpos = etree_box:GetScrollCurPos();
    frame:SetUserValue("INVENTORY_CUR_SCROLL_POS", curpos);

    for typeNo = 1, #g_invenTypeStrList do
        if not IsBlackListedTabName(g_invenTypeStrList[typeNo]) then
            if (invenTypeStr == nil or invenTypeStr == g_invenTypeStrList[typeNo] or typeNo == 1) then
                local tree_box =
                    GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox')
                local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo],
                    'ui::CTreeControl')

                local groupfontname = frame:GetUserConfig("TREE_GROUP_FONT");
                local tabwidth = frame:GetUserConfig("TREE_TAB_WIDTH");

                tree:Clear();
                tree:EnableDrawFrame(false)
                tree:SetFitToChild(true, 60)
                tree:SetFontName(groupfontname);
                tree:SetTabWidth(tabwidth);

            end
        end
    end

    local baseidclslist, baseidcnt = GetClassList("inven_baseid");
    local invenTitleName = nil
    if invenTitleName == nil then
        invenTitleName = {}
        for i = 1, baseidcnt do

            local baseidcls = GetClassByIndexFromList(baseidclslist, i - 1)
            local tempTitle = baseidcls.ClassName
            if baseidcls.MergedTreeTitle ~= "NO" then
                tempTitle = baseidcls.MergedTreeTitle
            end

            if table.find(invenTitleName, tempTitle) == 0 then
                invenTitleName[#invenTitleName + 1] = tempTitle
            end
        end
    end

    for i = 0, invItemCount - 1 do
        local invItem = itemList:GetItemByGuid(sortedGuidList:Get(i));
        if invItem ~= nil then
            local pass = true
            -- local obj = GetIES(invItem:GetObject())
            -- local class = GetClassByType("Item", obj.ClassID)
            -- local realname = dictionary.ReplaceDicIDInCompStr(class.Name)

            if pass then
                invItem.index = index_count
                invItemList[index_count] = invItem
                index_count = index_count + 1
            end
        end
    end

    local sortType = 3

    if sortType == 1 then
        table.sort(invItemList, INVENTORY_SORT_BY_GRADE)
    elseif sortType == 2 then
        table.sort(invItemList, INVENTORY_SORT_BY_WEIGHT)
    elseif sortType == 3 then
        table.sort(invItemList, INVENTORY_SORT_BY_NAME)
    elseif sortType == 4 then
        table.sort(invItemList, INVENTORY_SORT_BY_COUNT)
    else
        table.sort(invItemList, INVENTORY_SORT_BY_NAME)
    end

    for i = 1, #invenTitleName do
        local category = invenTitleName[i]
        local lim = 30

        for j = 1, #invItemList do
            lim = lim - 1
            if (lim == 0) then

                lim = 30
            end
            local invItem = invItemList[j];
            if invItem ~= nil then
                local itemCls = GetIES(invItem:GetObject())
                if itemCls.MarketCategory ~= "None" then
                    local baseidcls = nil
                    baseidcls = INV_GET_INVEN_BASEIDCLS_BY_ITEMGUID(invItem:GetIESID())
                    cls_inv_index[invItem.invIndex] = baseidcls

                    local titleName = baseidcls.ClassName
                    if baseidcls.MergedTreeTitle ~= "NO" then
                        titleName = baseidcls.MergedTreeTitle
                    end

                    if category == titleName then
                        local typeStr = GET_INVENTORY_TREEGROUP(baseidcls)
                        if itemCls ~= nil then
                            local makeSlot = true;

                            local viewOptionCheck = 1
                            if typeStr == "Equip" then
                                viewOptionCheck = CHECK_INVENTORY_OPTION_EQUIP(itemCls)
                            elseif typeStr == "Card" then
                                viewOptionCheck = CHECK_INVENTORY_OPTION_CARD(itemCls)
                            elseif typeStr == "Etc" then
                                viewOptionCheck = CHECK_INVENTORY_OPTION_ETC(itemCls)
                            elseif typeStr == "Gem" then
                                viewOptionCheck = CHECK_INVENTORY_OPTION_GEM(itemCls)
                            end

                            if invItem.count > 0 and baseidcls.ClassName ~= 'Unused' then -- Unused로 설정된 것은 안보임
                                g.tree[typeStr] = g.tree[typeStr] or {}
                                if invenTypeStr == nil or invenTypeStr == typeStr then
                                    local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. typeStr,
                                        'ui::CGroupBox')
                                    local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. typeStr,
                                        'ui::CTreeControl')
                                    another_warehouse_insert_item_to_tree(frame, tree, invItem, itemCls, baseidcls,
                                        typeStr);

                                end

                                local tree_box_all = GET_CHILD_RECURSIVELY(group, 'treeGbox_All', 'ui::CGroupBox')
                                local tree_all =
                                    GET_CHILD_RECURSIVELY(tree_box_all, 'inventree_All', 'ui::CTreeControl')
                                another_warehouse_insert_item_to_tree(frame, tree_all, invItem, itemCls, baseidcls,
                                    typeStr);

                            end
                        end
                    end
                end
            end

        end

    end
    local height = frame:GetHeight()
    for typeNo = 1, #g_invenTypeStrList do
        if not IsBlackListedTabName(g_invenTypeStrList[typeNo]) then
            local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox');
            local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo], 'ui::CTreeControl');
            AUTO_CAST(tree_box)
            if tree_box:GetWidth() ~= (650 - 38) then
                tree_box:Resize(650 - 38, height - 5)
            end

        end
    end
    for typeNo = 1, #g_invenTypeStrList do
        if not IsBlackListedTabName(g_invenTypeStrList[typeNo]) then
            local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox');
            local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo], 'ui::CTreeControl');
            local slotset

            -- 아이템 없는 빈 슬롯은 숨겨라
            local slotSetNameListCnt = ui.inventory.GetInvenSlotSetNameCount();
            for i = 1, slotSetNameListCnt do
                local getSlotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1);
                slotset = GET_CHILD_RECURSIVELY(tree, getSlotSetName, 'ui::CSlotSet');
                if slotset ~= nil then
                    ui.InventoryHideEmptySlotBySlotSet(slotset);
                end
            end

            ADD_GROUP_BOTTOM_MARGIN(frame, tree)
            tree:OpenNodeAll();
            tree:SetEventScript(ui.LBUTTONDOWN, "INVENTORY_TREE_OPENOPTION_CHANGE");
            INVENTORY_CATEGORY_OPENCHECK(frame, tree);

            -- 검색결과 스크롤 세팅은 여기서 하자. 트리 업데이트 후에 위치가 고정된 다음에.
            for i = 1, slotSetNameListCnt do
                local getSlotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1);
                slotset = GET_CHILD_RECURSIVELY(tree, getSlotSetName, 'ui::CSlotSet');

                local slotsetnode = tree:FindByValue(getSlotSetName);
                -- if setpos == 'setpos' then
                local savedPos = frame:GetUserValue("INVENTORY_CUR_SCROLL_POS");
                if savedPos == 'None' then
                    savedPos = 0
                end

                tree_box:SetScrollPos(tonumber(savedPos))

                -- end
            end
        end

    end
    for typeNo = 1, #g_invenTypeStrList do
        if not IsBlackListedTabName(g_invenTypeStrList[typeNo]) then
            local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox');
            local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo], 'ui::CTreeControl');
            AUTO_CAST(tree)
            if tree:GetWidth() ~= (650 - 38) then
                tree:Resize(650 - 38, height - 5)
            end
            -- 
        end
    end

    local gbox = frame:GetChild("inventoryGbox")
    AUTO_CAST(gbox)
    gbox:Resize(650, height - 15)
    gbox:SetOffset(10, 5)
    gbox:SetSkinName("test_frame_low")

    local gbox2 = frame:GetChildRecursively("inventoryitemGbox")
    AUTO_CAST(gbox2)
    gbox2:Resize(650 - 32, height - 15)
    gbox2:SetOffset(35, 0)

    local maxcount = another_warehouse_get_maxcount()
    local itemcount = another_warehouse_item_count()

    local count_text = GET_CHILD_RECURSIVELY(awframe, "count_text")
    AUTO_CAST(count_text)

    count_text:SetText("{@st42}" .. itemcount .. "/" .. maxcount .. "{/}")
    count_text:SetFontName("white_16_ol")

end
