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
-- v1.1.2 環境依存してそうなのでディレイを元に戻した。
-- v1.1.3 ディレイ設定消えてたの修正。
-- v1.1.4 ディレイ設定バグってたの修正。
-- v1.1.5 倉庫にアイテム無い時に搬出バグってたの修正。あと1M未満のシルバー取り出し修正。怒涛の修正つかれたよ。
-- v1.1.6 1M未満修正、倉庫自動搬出入最適化。
-- v1.1.7 更に最適化。もう無理
-- v1.1.8 預ける数と引き出す数が一緒でインベントリに無かった場合バグってたの修正。引き出し開始が早すぎて読み込めてなかったの修正。
-- v1.1.9 数量指定アイテムが倉庫に足りなかった場合に引き出さなかったバグ修正。
-- v1.2.0 検索を有効に。その他些末なバグ修正。
-- v1.2.1 あかんバグ修正
-- v1.2.2 入庫時に引っ掛かりにくくなったハズ。テストは足りてない。
-- v1.2.3 入庫時の引っ掛かりバグ完全に直った。IMCに勝った。
-- v1.2.4 セット取り出しスロットを増やした。整理も出来る様に。
-- v1.2.5 トークン判定を減らした。
-- v1.2.6 読込早くした。トークン使ってない時の挙動少し変更
-- v1.2.7 製造書に製造後のアイコンを表示。倉庫にMAXを超えて入れられるバグ修正
-- v1.2.8 スロットを少し改造するモード追加。入庫時の挙動見直し。
local addonName = "ANOTHER_WAREHOUSE"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.2.8"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")
local json = require('json')
local os = require("os")
local base = {}

local function ts(...)

    local num_args = select('#', ...)

    if num_args == 0 then
        print("ts: (no arguments)")
        return
    end

    local string_parts = {}
    for i = 1, num_args do
        local arg = select(i, ...)

        if arg == nil then
            table.insert(string_parts, "nil")
        else
            table.insert(string_parts, tostring(arg))
        end
    end

    print(table.concat(string_parts, "\t"))
end

local function IsBlackListedTabName(name)
    return name == 'Quest'
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
    local folder = string.format("../addons/%s", addonNameLower)
    local file_path = string.format("../addons/%s/mkdir.txt", addonNameLower)
    create_folder(folder, file_path)

    local active_id = session.loginInfo.GetAID()
    local user_folder = string.format("../addons/%s/%s", addonNameLower, active_id)
    local user_file_path = string.format("../addons/%s/%s/mkdir.txt", addonNameLower, active_id)
    create_folder(user_folder, user_file_path)
end
g.mkdir_new_folder()

local active_id = session.loginInfo.GetAID()
g.settingsFileLoc = string.format('../addons/%s/%s/settings.json', addonNameLower, active_id)
g.settings_base_location = string.format('../addons/%s/settings.json', addonNameLower)

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

    if not g.REGISTER[origin_func_name .. my_func_name] then
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

    -- local settings = acutil.loadJSON(g.settingsFileLoc)
    local settings = g.load_json(g.settingsFileLoc)
    if not settings then
        -- local base_settings = acutil.loadJSON(g.settings_base_location)
        local base_settings = g.load_json(g.settings_base_location)

        if base_settings then
            settings = base_settings
        else
            settings = {
                silver = 1000000,
                amount_check = 0,
                transfer = 0,
                items = {},
                delay = 0.3
            }
        end
    end

    local LoginName = session.GetMySession():GetPCApc():GetName()
    local LoginCID = info.GetCID(session.GetMyHandle())

    if not settings[LoginCID] then
        settings[LoginCID] = {
            maney_check = 1,
            item_check = 1,
            name = LoginName,
            items = {},
            transfer = 0
        }
    end

    g.settings = settings

    another_warehouse_save_settings()

end

function another_warehouse_save_settings()

    -- acutil.saveJSON(g.settingsFileLoc, g.settings);
    g.save_json(g.settingsFileLoc, g.settings);

end
function another_warehouse_setting_file_organize()
    local account_info = session.barrack.GetMyAccount()
    local barrack_pc_count = account_info:GetBarrackPCCount()

    local validKeys = {}

    for key, data in pairs(g.settings) do
        local num = tonumber(key)
        if num then
            for i = 0, barrack_pc_count - 1 do
                local barrack_pc_info = account_info:GetBarrackPCByIndex(i)
                local barrack_pc_name = barrack_pc_info:GetName()
                if barrack_pc_name == data.name then
                    validKeys[key] = true
                end
            end
        else
            validKeys[key] = true
        end
    end

    for key in pairs(g.settings) do
        if not validKeys[key] then
            g.settings[key] = nil
        end
    end

    another_warehouse_save_settings()
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
        if str == "Delay time" then
            str = "遅延設定"
        end

        -- Set the delay time in case of failure {nl}in warehouse entry. Basic is 0.5 sec.
        if str == "If the warehouse entry fails,{nl}set a longer time. Basic is 0.3 sec." then
            str =
                "倉庫入出庫に失敗する場合、時間を長めに設定してください。デフォルトは0.3秒です。"
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

g.log_file_path = string.format('../addons/%s/debug_log.txt', addonNameLower)
function g.log_to_file(message)

    local file, err = io.open(g.log_file_path, "a")

    if file then
        local timestamp = os.date("[%Y-%m-%d %H:%M:%S] ")
        file:write(timestamp .. tostring(message) .. "\n")
        file:close()
    end
end

function another_warehouse_APPS_TRY_MOVE_BARRACK(frame, msg)

    if session.loginInfo.IsPremiumState(ITEM_TOKEN) ~= true then
        g.token = false
        -- ui.SysMsg(another_warehouse_lang("[Another warehouse] is not available because the token has not been applied."))
    else
        g.token = true
    end
end

g.loaded = false
function ANOTHER_WAREHOUSE_ON_INIT(addon, frame)
    local start_time = os.clock() -- ★処理開始前の時刻を記録★
    g.addon = addon
    g.frame = frame
    g.REGISTER = {}
    g.cid = info.GetCID(session.GetMyHandle())
    g.lang = option.GetCurrentCountry()
    -- g.lang = "English"

    local scp_frame = ui.GetFrame("another_warehouse_scp_frame")
    if not scp_frame then
        scp_frame = ui.CreateNewFrame("notice_on_pc", "another_warehouse_scp_frame", 0, 0, 0, 0)
        AUTO_CAST(scp_frame)
    else
        AUTO_CAST(scp_frame)
    end
    scp_frame:ShowWindow(1)

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then

        if not g.settings then
            another_warehouse_load_settings()
        else
            if not g.settings[g.cid] then
                another_warehouse_load_settings()
            end
        end

        g.token = g.token or false
        -- acutil.setupEvent(addon, 'APPS_TRY_MOVE_BARRACK', "another_warehouse_APPS_TRY_MOVE_BARRACK")
        g.setup_hook_and_event(addon, 'APPS_TRY_MOVE_BARRACK', "another_warehouse_APPS_TRY_MOVE_BARRACK", true)

        if not g.token then
            scp_frame:RunUpdateScript("another_warehouse_accountwarehouse_init_reserve", 0.1)
            g.count = 1
        else
            addon:RegisterMsg("GAME_START", "another_warehouse_accountwarehouse_init");
        end
        if g.loaded then
            addon:RegisterMsg("GAME_START", "another_warehouse_setting_file_organize");

        end
        g.loaded = true
    end
    local end_time = os.clock() -- ★処理終了後の時刻を記録★
    local elapsed_time = end_time - start_time
    -- CHAT_SYSTEM(string.format("%s: %.4f seconds", addonName, elapsed_time))
end

function another_warehouse_accountwarehouse_init_reserve(frame)

    if session.loginInfo.IsPremiumState(ITEM_TOKEN) ~= true and not g.token then
        -- print(tostring(g.count))
        g.count = g.count + 1
        if g.count >= 60 then
            ui.SysMsg(another_warehouse_lang(
                "[Another warehouse] is not available because the token has not been applied."))
            return 0
        else
            return 1
        end
    else
        g.token = true
        ui.SysMsg("[AWH]ready")
        another_warehouse_accountwarehouse_init(frame)
        return 0
    end
end

function another_warehouse_accountwarehouse_init(frame)

    g.token = true

    local addon = g.addon
    addon:RegisterMsg("OPEN_DLG_ACCOUNTWAREHOUSE", "another_warehouse_OPEN_DLG_ACCOUNTWAREHOUSE");
    addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_LIST", "another_warehouse_on_msg");
    addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_ADD", "another_warehouse_on_msg");
    addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_REMOVE", "another_warehouse_on_msg");
    addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_CHANGE_COUNT", "another_warehouse_on_msg");
    addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_IN", "another_warehouse_on_msg");

    addon:RegisterMsg('ESCAPE_PRESSED', 'another_warehouse_accountwarehouse_close');

    g.setup_hook_and_event(addon, 'ACCOUNTWAREHOUSE_OPEN', "another_warehouse_accountwarehouse_open", true)

    g.setup_hook_and_event(addon, 'ACCOUNTWAREHOUSE_CLOSE', "another_warehouse_accountwarehouse_close", true)

    local functionName = "YAACCOUNTINVENTORY_ON_INIT" -- チェックしたい関数の名前を文字列として指定します
    if type(_G[functionName]) == "function" then
        another_warehouse_notice()
        _G[functionName] = nil
    end

    local functionName = "WAREHOUSEMANAGER_ON_INIT" -- チェックしたい関数の名前を文字列として指定します
    if type(_G[functionName]) == "function" then
        another_warehouse_notice2()
        _G[functionName] = nil
    end
    g.new_stack_add_item = {}
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

    local take = {}
    for key, value in pairs(g.settings.setitems[tostring(argStr)]) do

        for i = 0, sortedCnt - 1 do
            local guid = sortedGuidList:Get(i)
            local invItem = itemList:GetItemByGuid(guid)
            local type = invItem.type
            local iesid = invItem:GetIESID()
            local count = 0
            if value == type then

                if g.settings.leave == 1 then
                    count = invItem.count - 1
                    if count ~= 0 then
                        take[iesid] = count
                    end
                else
                    count = invItem.count
                    if count ~= 0 then
                        take[iesid] = count
                    end
                end

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
    item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
        warehouseFrame:GetUserIValue("HANDLE"))
    another_warehouse_set_item_close(frame, ctrl, argStr, argNum)

    ACCOUNTWAREHOUSE_CLOSE(warehouseFrame)
    INVENTORY_SET_CUSTOM_RBTNDOWN("None")
    SET_INV_LBTN_FUNC(ui.GetFrame("inventory"), "None");
    UI_TOGGLE_INVENTORY()
    return
end

function another_warehouse_set_name_edit(frame, ctrl, argStr, argNum)

    if ctrl:GetText() == "" or string.gsub(ctrl:GetText(), "{ol}", "") == "" then
        ui.SysMsg(g.lang == "Japanese" and "文字を入れてください" or "Please enter the text")
        return
    end
    for i, handle in ipairs(g.settings.handlelist) do
        local newtext = string.gsub(ctrl:GetText(), "{ol}", "")
        if newtext == tostring(handle) then
            ui.SysMsg(another_warehouse_lang("Name already registered."))
            return
        end
    end

    for i, handle in ipairs(g.settings.handlelist) do

        local newtext = string.gsub(ctrl:GetText(), "{ol}", "")
        if newtext ~= tostring(handle) then
            g.settings.handlelist[argNum] = tostring(newtext)
            another_warehouse_save_settings()
            ui.SysMsg(another_warehouse_lang("Set name changed."))
            break
        end
    end
end

function another_warehouse_set_items_setting(number, handle)

    local frame = ui.CreateNewFrame("notice_on_pc", "another_warehouse_set_items", 0, 0, 10, 10)
    AUTO_CAST(frame)
    frame:SetSkinName("test_frame_low")
    frame:SetPos(680, 170)
    frame:SetLayerLevel(100)
    -- frame:Resize(270, 310)
    frame:Resize(270, 608)
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
    set_gb:Resize(250, 500)
    frame:ShowWindow(1)

    --[[local out = frame:CreateOrGetControl("button", "out", 0, 0, 100, 43)
    AUTO_CAST(out)
    out:SetText("{@st66b}TAKE ITEM")
    out:SetMargin(10, 5, 100, 0)
    out:SetSkinName("test_pvp_btn")
    out:SetTextTooltip(another_warehouse_lang("Warehouse items right-click to setting"))
    out:SetEventScript(ui.LBUTTONUP, "another_warehouse_set_item_take")
    out:SetEventScriptArgString(ui.LBUTTONUP, number)]]

    local name_edit = frame:CreateOrGetControl("edit", "name_edit", 10, 13, 210, 30)
    AUTO_CAST(name_edit)
    name_edit:SetFontName("white_16_ol")
    name_edit:SetTextAlign("center", "center")
    name_edit:SetText("{ol}" .. handle)
    name_edit:SetEventScript(ui.ENTERKEY, "another_warehouse_set_name_edit")
    name_edit:SetEventScriptArgNumber(ui.ENTERKEY, number)

    local set_slotset = set_gb:CreateOrGetControl('slotset', 'set_slotset', 0, 0, 0, 0)
    AUTO_CAST(set_slotset);
    set_slotset:SetSlotSize(50, 50)
    set_slotset:EnablePop(1)
    set_slotset:EnableDrag(1)
    set_slotset:EnableDrop(1)
    set_slotset:SetEventScript(ui.DROP, "another_warehouse_set_swap_item")
    set_slotset:SetEventScriptArgString(ui.DROP, number)

    set_slotset:SetColRow(5, 10)
    set_slotset:SetSpc(0, 0)
    set_slotset:SetSkinName('slot')

    set_slotset:CreateSlots()
    local slotcount = set_slotset:GetSlotCount()

    for i = 1, slotcount do
        local slot = GET_CHILD_RECURSIVELY(set_slotset, "slot" .. i)
        AUTO_CAST(slot)

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

                -- slot:SetEventScriptArgNumber(ui.LBUTTONUP, clsid)

            end
        end
    end

    local initialize = frame:CreateOrGetControl("button", "initialize", 0, 0, 100, 43)
    AUTO_CAST(initialize)
    initialize:SetText(g.lang == "Japanese" and "{@st66b}初期化" or "{@st66b}Initialize")
    initialize:SetMargin(160, 555, 100, 0)
    initialize:SetSkinName("test_pvp_btn")
    -- initialize:SetTextTooltip(another_warehouse_lang("Warehouse items right-click to setting"))
    initialize:SetEventScript(ui.LBUTTONUP, "another_warehouse_setslot_initialize")
    initialize:SetEventScriptArgString(ui.LBUTTONUP, number)

end

function another_warehouse_setslot_initialize(frame, btn, set_number_str, num)
    local yesscp = string.format('another_warehouse_setslot_initialize_yes(%s)', set_number_str)
    local msg = g.lang == "Japanese" and "{ol}{#FFFFFF}セット初期化しますか？" or
                    "{ol}{#FFFFFF}Initialize this set?"
    local msgbox = ui.MsgBox(msg, yesscp, 'None')
end

function another_warehouse_setslot_initialize_yes(set_number_str)

    g.settings.setitems[tostring(set_number_str)] = {}
    for i, value in ipairs(g.settings.handlelist) do
        if value == "" then
            g.settings.handlelist[i] = "Take Items " .. i
        end
        if i == tonumber(set_number_str) then
            g.settings.handlelist[i] = "Take Items " .. i
        end
    end
    ui.SysMsg(g.lang == "Japanese" and "{ol}初期化しました" or "{ol}Initialized")
    another_warehouse_save_settings()
    another_warehouse_set_item_close()
end

function another_warehouse_set_swap_item(parent, slot, set_number_str, clsid)

    if parent:GetTopParentFrame():GetName() ~= "another_warehouse_set_items" then
        return
    end
    local lift_icon = ui.GetLiftIcon();
    local from_slot = lift_icon:GetParent();
    local from_index = string.gsub(from_slot:GetName(), "slot", "") * 1
    local from_clsid = g.settings.setitems[tostring(set_number_str)][tostring(from_index)]

    local to_index = string.gsub(slot:GetName(), "slot", "") * 1

    local to_icon = slot:GetIcon()
    if not to_icon then
        g.settings.setitems[tostring(set_number_str)][tostring(from_index)] = nil
        g.settings.setitems[tostring(set_number_str)][tostring(to_index)] = from_clsid

    else
        local to_clsid = g.settings.setitems[tostring(set_number_str)][tostring(to_index)]
        g.settings.setitems[tostring(set_number_str)][tostring(from_index)] = to_clsid
        g.settings.setitems[tostring(set_number_str)][tostring(to_index)] = from_clsid
    end

    another_warehouse_save_settings()

    local frame = parent:GetTopParentFrame()
    local name_edit = GET_CHILD_RECURSIVELY(frame, "name_edit")
    local handle = name_edit:GetText()
    another_warehouse_set_items_setting(tonumber(set_number_str), handle)

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
end

function another_warehouse_take_context(frame, ctrl, argStr, argNum)
    local context = ui.CreateContextMenu("TAKE_SETTING", "Take items", 0, 20, 100, 100)

    if g.settings.handlelist == nil then

        g.settings.handlelist = {"Take Items 1", "Take Items 2", "Take Items 3", "Take Items 4", "Take Items 5",
                                 "Take Items 6", "Take Items 7", "Take Items 8", "Take Items 9", "Take Items 10"}
        another_warehouse_save_settings()
    end

    if not g.settings.handlelist[9] then
        table.insert(g.settings.handlelist, "Take Items 9")
        another_warehouse_save_settings()
    end

    if not g.settings.handlelist[10] then
        table.insert(g.settings.handlelist, "Take Items 10")
        another_warehouse_save_settings()
    end

    for i, handle in ipairs(g.settings.handlelist) do
        -- another_warehouse_set_item_take
        -- local scp = string.format("another_warehouse_set_items_setting(%d,'%s')", tonumber(i), handle)
        local scp = string.format("another_warehouse_set_item_take('','',%d,'%s')", tonumber(i), handle)
        ui.AddContextMenuItem(context, handle, scp)
    end

    ui.OpenContextMenu(context)
end

function another_warehouse_setting_context(frame, ctrl, argStr, argNum)
    local context = ui.CreateContextMenu("TAKE_SETTING", "{ol}{#FF0000}set slot setting", 0, 20, 100, 100)

    local master_handlelist = {"Take Items 1", "Take Items 2", "Take Items 3", "Take Items 4", "Take Items 5",
                               "Take Items 6", "Take Items 7", "Take Items 8", "Take Items 9", "Take Items 10"}

    if g.settings.handlelist == nil then
        g.settings.handlelist = master_handlelist
        another_warehouse_save_settings()
    else

        local has_changed = false
        for i, master_item in ipairs(master_handlelist) do
            if g.settings.handlelist[i] == nil then
                g.settings.handlelist[i] = master_item
                has_changed = true
            end
        end

        if has_changed then
            another_warehouse_save_settings()
        end
    end

    for i, handle in ipairs(g.settings.handlelist) do
        -- another_warehouse_set_item_take
        local scp = string.format("another_warehouse_set_items_setting(%d,'%s')", tonumber(i), handle)
        -- local scp = string.format("another_warehouse_set_item_take('','',%d,'%s')", tonumber(i), handle)
        ui.AddContextMenuItem(context, "{ol}{#FF0000}" .. handle, scp)
    end

    ui.OpenContextMenu(context)
end
-- !
function another_warehouse_OPEN_DLG_ACCOUNTWAREHOUSE()

    local msframe = ui.GetFrame("monstercardslot")
    msframe:SetLayerLevel(98)

    local frame = ui.GetFrame("accountwarehouse")
    local accountwarehouse_tab = GET_CHILD_RECURSIVELY(frame, "accountwarehouse_tab")
    accountwarehouse_tab:SetMargin(0, 240) -- margin="0 120 0 0"
    local richtext_1 = GET_CHILD_RECURSIVELY(frame, "richtext_1")
    richtext_1:ShowWindow(0)

    local itemcnt = GET_CHILD_RECURSIVELY(frame, "itemcnt")
    itemcnt:SetMargin(0, 133, 190, 0) --  margin="0 73 190 0"
    local slotgbox = GET_CHILD_RECURSIVELY(frame, "slotgbox")
    slotgbox:ShowWindow(0)
    --[[local richtext_2 = GET_CHILD_RECURSIVELY(frame, "richtext_2")
    richtext_2:SetMargin(21, 0, 0, 366)
    print(tostring(richtext_2:GetText()))]]
    local richtext_3 = GET_CHILD_RECURSIVELY(frame, "richtext_3")
    richtext_3:SetMargin(17, 4, 0, 0)

    --[[local gbox = GET_CHILD_RECURSIVELY(frame, 'visgBox')
    local cnt = session.AccountWarehouse.GetCount();

    for i = cnt - 1, 0, -1 do
        local ctrlSet = gbox:CreateControlSet("AccountVisLog", "CTRLSET_" .. i, ui.CENTER_HORZ, ui.TOP, 0, 0, 0, 0);
        local inputVis = ctrlSet:GetChild('inputVis')
        AUTO_CAST(inputVis)
        print(inputVis:GetText())
        local margin = inputVis:GetMargin()
        inputVis:SetMargin(margin.left - 150, margin.top, margin.right, margin.bottom)
        -- print(tostring(margin.left))
    end]]

    local maxcount = another_warehouse_get_maxcount()
    local itemcount = another_warehouse_item_count()

    local grupbox = GET_CHILD_RECURSIVELY(frame, "gbox")
    grupbox:RemoveChild("search_edit")
    -- !!
    local search_edit = grupbox:CreateOrGetControl("edit", "search_edit", 0, 0, 295, 35)
    AUTO_CAST(search_edit)
    search_edit:SetFontName("white_18_ol")
    search_edit:SetTextAlign("left", "center")
    search_edit:SetSkinName("inventory_serch")
    local margin = search_edit:GetMargin();
    search_edit:SetMargin(margin.left + 115, margin.top + 20, margin.right, margin.bottom)
    search_edit:SetEventScript(ui.ENTERKEY, "another_warehouse_frame_update")
    search_edit:ShowWindow(1)

    local search_btn = search_edit:CreateOrGetControl("button", "search_btn", 0, 0, 60, 38)
    AUTO_CAST(search_btn)
    search_btn:SetImage("inven_s")
    search_btn:SetGravity(ui.RIGHT, ui.TOP)
    search_btn:SetEventScript(ui.LBUTTONUP, "another_warehouse_frame_update")

    local awsetting = grupbox:CreateOrGetControl("button", "awsetting", 0, 0, 30, 43)
    AUTO_CAST(awsetting)
    awsetting:SetText("{img config_button_normal 27 27}")
    awsetting:SetEventScript(ui.LBUTTONUP, "another_warehouse_setting_frame_init")
    awsetting:SetMargin(145, 60, 0, 0)
    awsetting:SetSkinName("None")
    awsetting:SetTextTooltip("{ol}" .. another_warehouse_lang("[Another Warehouse]{nl}Automatic warehousing setup"))
    awsetting:ShowWindow(1)

    local help = grupbox:CreateOrGetControl('button', "help", 0, 0, 30, 30)
    AUTO_CAST(help);
    -- help:SetSkinName("None")
    help:SetText("{ol}{img question_mark 20 20}")
    help:SetMargin(115, 67, 0, 0)
    help:SetTextTooltip("{ol}[Another Warehouse]{nl}help")
    help:SetSkinName("test_pvp_btn")
    help:SetEventScript(ui.LBUTTONUP, "another_warehouse_help")
    help:ShowWindow(1)

    local leave = grupbox:CreateOrGetControl('checkbox', "leave", 0, 0, 30, 30)
    AUTO_CAST(leave);
    leave:SetCheck(g.settings.leave or 0)
    leave:SetMargin(180, 67, 0, 0)
    leave:SetEventScript(ui.LBUTTONUP, "another_warehouse_setting_check")
    local tooltip_text = g.lang == "Japanese" and "{ol}チェックすると倉庫に1個残します" or
                             "{ol}Check leaves one in the warehouse"
    leave:SetTextTooltip(tooltip_text)
    leave:ShowWindow(1)

    local display_change = grupbox:CreateOrGetControl('checkbox', "display_change", 0, 0, 30, 30)
    AUTO_CAST(display_change);
    display_change:SetCheck(g.settings.display_change or 0)
    display_change:SetMargin(215, 67, 0, 0)
    display_change:SetEventScript(ui.LBUTTONUP, "another_warehouse_setting_check")
    local tooltip_text = g.lang == "Japanese" and "{ol}チェックすると表示切替" or
                             "{ol}Check to switch display"
    display_change:SetTextTooltip(tooltip_text)
    display_change:ShowWindow(1)

    local take = grupbox:CreateOrGetControl("button", "take", 10, 0, 100, 43)
    AUTO_CAST(take)
    take:SetText("{@st66b}TAKE SET")
    take:SetEventScript(ui.LBUTTONUP, "another_warehouse_take_context")
    take:SetEventScript(ui.RBUTTONUP, "another_warehouse_setting_context")
    take:SetMargin(310, 60, 0, 0)
    take:SetSkinName("test_pvp_btn")
    take:SetTextTooltip(g.lang == "Japanese" and
                            "{ol}左クリック: 倉庫からセットで搬出します{nl}右クリック: セット設定を呼び出します" or
                            "{ol}left-click: Move set from warehouse{nl}Right-click: Call up set settings")
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
    name_text:ShowWindow(1)

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

    local tab = GET_CHILD_RECURSIVELY(overlap, "inventype_Tab")
    AUTO_CAST(tab)
    local tab_JP = GET_CHILD_RECURSIVELY(overlap, "inventype_Tab_JP")
    AUTO_CAST(tab_JP)
    if g.lang == "Japanese" then
        tab_JP:ShowWindow(1)
        tab:ShowWindow(0)
    else
        tab_JP:ShowWindow(0)
        tab:ShowWindow(1)
    end

    local height = overlap:GetHeight()

    -- 各tree_boxのリサイズ
    for typeNo = 1, #g_invenTypeStrList do
        if not IsBlackListedTabName(g_invenTypeStrList[typeNo]) then
            local tree_box = GET_CHILD_RECURSIVELY(gbox, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox')
            if tree_box then
                tree_box:Resize(650 - 38, height - 5)
                local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo],
                    'ui::CTreeControl')
                if tree then
                    tree:Resize(650 - 38, height - 5)
                end
            end
        end
    end

    --[[local gbox = frame:GetChild("inventoryGbox")
    AUTO_CAST(gbox)
    gbox:Resize(650, height - 15)
    gbox:SetOffset(10, 5)
    gbox:SetSkinName("test_frame_low")

    local gbox2 = frame:GetChildRecursively("inventoryitemGbox")
    AUTO_CAST(gbox2)
    gbox2:Resize(650 - 32, height - 15)
    gbox2:SetOffset(35, 0)]]
    another_warehouse_frame_update()

end

function another_warehouse_ADVANCEDMONEYINPUT(frame)

    local frame = ui.GetFrame("accountwarehouse")
    local editMoney = frame:GetChildRecursively("moneyInput")
    AUTO_CAST(editMoney)
    editMoney:SetText("")
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
        editMoney:SetText("")
        return
    end
    local cleanedValue = string.gsub(editMoney:GetText(), "[\r\n,]", "")

    local numericValue = tonumber(cleanedValue)
    if (numericValue - num) > 0 then
        editMoney:SetText(GET_COMMAED_STRING(SumForBigNumberInt64(numericValue, "-" .. num)))
    else
        editMoney:SetText("")
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

        return
    elseif ctrl:GetName() == "allin" then
        local silveritem = session.GetInvItemByName(MONEY_NAME)
        if silveritem ~= nil then

            editMoney:SetText(GET_COMMAED_STRING(silveritem:GetAmountStr()))
        else
            editMoney:SetText("")
        end
    elseif ctrl:GetName() == "cancel" then
        editMoney:SetText("")
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
    local delay = g.settings.delay

    if g.settings[LoginCID].item_check == 1 then
        -- another_warehouse_item()
        ReserveScript("another_warehouse_item()", delay)
        return
    elseif g.settings[LoginCID].maney_check == 1 then

        ReserveScript("another_warehouse_silver()", delay * 2)
        return
    else
        another_warehouse_end()
        return
    end

end

function another_warehouse_silver()

    local silveritem = session.GetInvItemByName(MONEY_NAME)
    local warehouseFrame = ui.GetFrame('accountwarehouse')
    local handle = warehouseFrame:GetUserIValue('HANDLE')

    local charsilver = 0
    if silveritem ~= nil then
        charsilver = tonumber(silveritem:GetAmountStr())

    end

    charsilver = charsilver - tonumber(g.settings.silver)

    if charsilver > 0 then

        item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, silveritem:GetIESID(), tostring(charsilver), handle)

    elseif charsilver <= 0 then

        session.ResetItemList()
        session.AddItemIDWithAmount("0", tostring(-charsilver))
        item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), handle)

    end
    if g.settings.amount_check == 1 then
        local delay = g.settings.delay
        ReserveScript("another_warehouse_fraction()", delay)
    end

end

function another_warehouse_fraction()

    local warehouseFrame = ui.GetFrame('accountwarehouse')
    local handle = warehouseFrame:GetUserIValue('HANDLE')
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local guidlist = itemList:GetSortedGuidList()
    local cnt = itemList:Count()

    for i = 0, cnt - 1 do
        local guid = guidlist:Get(i)
        local invItem = itemList:GetItemByGuid(guid)
        if invItem ~= nil then
            local invItem_obj = GetIES(invItem:GetObject())
            if invItem_obj.ClassName == MONEY_NAME then
                local count = invItem.count
                if count >= 1000000 then
                    local fraction = count % 1000000
                    session.ResetItemList()
                    session.AddItemIDWithAmount(guid, tostring(fraction))
                    item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), handle)
                end
            end
        end
    end
end

function another_warehouse_item()
    g.takeitemtbl = {}
    g.putitemtbl = {}
    g.is_putting_item = false

    local LoginCID = info.GetCID(session.GetMyHandle())

    local warehouseFrame = ui.GetFrame('accountwarehouse')
    local handle = warehouseFrame:GetUserIValue('HANDLE')
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local sortedGuidList = itemList:GetSortedGuidList()
    local sortedCnt = sortedGuidList:Count()
    local leave_one = g.settings.leave == 1

    for i = 0, sortedCnt - 1 do
        local guid = sortedGuidList:Get(i)
        local invItem = itemList:GetItemByGuid(guid)
        local type = invItem.type
        local itemobj = GetIES(invItem:GetObject())
        local iesid = invItem:GetIESID()
        local inv_count = leave_one and invItem.count - 1 or invItem.count

        -- Process LoginCID specific items
        local loginCIDItems = g.settings[LoginCID] and g.settings[LoginCID].items or {}
        for str_index, items in pairs(loginCIDItems) do
            local clsID = items.clsid
            local count = items.count
            if not g.putitemtbl[clsID] and tonumber(clsID) ~= 900011 then
                g.putitemtbl[clsID] = {
                    iesid = "",
                    count = count
                }
            end
            if type == clsID and inv_count > 0 and tonumber(clsID) ~= 900011 then
                g.takeitemtbl[clsID] = {
                    iesid = iesid,
                    count = count
                }
                break
            end
        end

        -- Process global items
        local globalItems = g.settings.items or {}
        for str_index, items in pairs(globalItems) do
            local clsID = items.clsid
            local count = items.count
            if not g.putitemtbl[clsID] and clsID ~= 900011 then
                g.putitemtbl[clsID] = {
                    iesid = "",
                    count = count
                }
            end
            if type == clsID and inv_count > 0 and clsID ~= 900011 then
                if not g.takeitemtbl[clsID] then
                    g.takeitemtbl[clsID] = {
                        iesid = iesid,
                        count = count
                    }
                    break
                end
            end
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
            for clsID, table in pairs(g.takeitemtbl) do
                if clsID == inv_clsid then
                    local take_count = table.count - inv_Item.count

                    if take_count <= 0 then
                        g.takeitemtbl[clsID] = nil
                    else
                        g.takeitemtbl[clsID].count = take_count
                    end
                    break
                end
            end

            for clsID, table in pairs(g.putitemtbl) do
                if clsID == inv_clsid then
                    local put_count = inv_Item.count - table.count
                    if put_count > 0 then
                        g.putitemtbl[clsID] = {
                            iesid = guid,
                            count = put_count,
                            invcount = inv_Item.count
                        }

                    elseif put_count == 0 then
                        g.putitemtbl[clsID] = nil -- 同数の場合、putのみを除外
                    else
                        g.putitemtbl[clsID] = nil
                    end

                    break
                end
            end
        end
    end

    -- 同数のアイテムをチェックして除外
    for clsID, takeData in pairs(g.takeitemtbl) do
        local putData = g.putitemtbl[clsID]
        if putData and takeData.count == putData.count then
            -- g.takeitemtbl[clsID] = nil
            g.putitemtbl[clsID] = nil
        end
    end

    if next(g.putitemtbl) then

        -- pairsでテーブルをループ
        for cls_id, item_data in pairs(g.putitemtbl) do
            if item_data.count == 0 then
                g.putitemtbl[cls_id] = nil
            end
        end
    end

    --[[ ★★★ ここからが確認用コード ★★★
    print("--- g.putitemtbl の内容 (除外処理後) ---")

    -- テーブルが空かどうかを先にチェック
    if not next(g.putitemtbl) then
        print("  (テーブルは空です)")
    else
        -- pairsでテーブルをループ
        for cls_id, item_data in pairs(g.putitemtbl) do
            -- まず、キーであるクラスIDを表示
            print(string.format("Key (cls_id): %s", tostring(cls_id)))

            -- 次に、値であるテーブルの中身を、インデントを付けて表示
            if type(item_data) == "table" then
                print(string.format("  - iesid: %s", tostring(item_data.iesid)))
                print(string.format("  - count: %s", tostring(item_data.count)))
                print(string.format("  - invcount: %s", tostring(item_data.invcount)))
            else
                -- 予期せぬデータ形式の場合
                print(string.format("  - Value: %s (予期せぬ形式)", tostring(item_data)))
            end
        end
    end

    print("--- 表示完了 ---")
    -- ★★★ 確認用コードはここまで ★★★]]
    another_warehouse_item_take()

end

function another_warehouse_item_take()

    local warehouseFrame = ui.GetFrame('accountwarehouse')
    if warehouseFrame:IsVisible() == 0 then
        return
    end
    session.ResetItemList()

    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local sortedGuidList = itemList:GetSortedGuidList()
    local sortedCnt = sortedGuidList:Count()
    local leave_one = g.settings.leave == 1

    for clsid, itemInfo in pairs(g.takeitemtbl) do
        for i = 0, sortedCnt - 1 do
            local guid = sortedGuidList:Get(i)
            local invItem = itemList:GetItemByGuid(guid)
            local inv_count = leave_one and invItem.count - 1 or invItem.count
            local inv_obj = GetIES(invItem:GetObject())
            local count = math.min(itemInfo.count, inv_count)
            local iesid = invItem:GetIESID()

            if iesid == itemInfo.iesid then

                if count ~= 0 then

                    session.AddItemID(iesid, count)
                    break
                end
            end
        end
    end

    item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
        warehouseFrame:GetUserIValue("HANDLE"))

    local delay = g.settings.delay
    g.tooltip_count = 0
    warehouseFrame:RunUpdateScript("another_warehouse_item_put", 0.1)

end

function another_warehouse_item_put(frame)

    local accountwarehouse = ui.GetFrame('accountwarehouse')
    -- ts("accountwarehouse:IsVisible()", accountwarehouse:IsVisible())
    if accountwarehouse:IsVisible() == 0 then
        return 0
    end

    if g.is_putting_item then
        return 1
    end

    local next_cls_id, item_data = next(g.putitemtbl)

    if not next_cls_id then
        local login_cid = info.GetCID(session.GetMyHandle())
        if g.settings[login_cid].maney_check == 1 then
            ReserveScript("another_warehouse_silver()", 0.1)
        end
        ReserveScript("another_warehouse_end()", g.settings.delay or 0.2)
        return 0
    end

    local inv_item = session.GetInvItemByGuid(item_data.iesid)
    if inv_item and another_warehouse_checkvalid(item_data.iesid) then

        local inv_obj = GetIES(inv_item:GetObject())
        local inv_clsid = inv_obj.ClassID

        g.is_putting_item = true

        local handle = accountwarehouse:GetUserIValue("HANDLE")
        local goal_index = another_warehouse_get_goal_index()
        item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, item_data.iesid, item_data.count, handle, goal_index)
        if geItemTable.IsStack(inv_obj.ClassID) == 1 then
            g.new_stack_add_item[#g.new_stack_add_item + 1] = inv_clsid
        end
        another_warehouse_item_put_to(item_data.iesid, item_data.count, goal_index, next_cls_id, item_data.invcount)
    else

        g.putitemtbl[next_cls_id] = nil
    end

    return 1

end

--[[function another_warehouse_item_put(frame)

    local warehouseFrame = ui.GetFrame('accountwarehouse')
    if warehouseFrame:IsVisible() == 0 then
        return 0
    end

    local delay = g.settings.delay

    local invItemList = session.GetInvItemList()
    local inv_guidList = invItemList:GetGuidList()
    local cnt = inv_guidList:Count()

    for i = 0, cnt - 1 do
        local guid = inv_guidList:Get(i)
        local inv_Item = invItemList:GetItemByGuid(guid)
        local inv_obj = GetIES(inv_Item:GetObject())
        local inv_clsid = inv_obj.ClassID
        if inv_obj.ClassName ~= MONEY_NAME then
            for clsID, itemData in pairs(g.putitemtbl) do

                if clsID == inv_clsid then

                    local count = itemData.count
                    local invcount = itemData.invcount

                    local goal_index = 0
                    goal_index = another_warehouse_get_goal_index()
                    
                    local check = another_warehouse_checkvalid(guid)
                    -- ts(check)
                    if check then
                        item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, guid, tostring(count),
                            warehouseFrame:GetUserIValue("HANDLE"), goal_index)
                        another_warehouse_item_put_to(guid, count, goal_index, clsID, invcount)
                        -- g.putitemtbl[clsID] = nil
                        if geItemTable.IsStack(inv_obj.ClassID) == 1 then
                            g.new_stack_add_item[#g.new_stack_add_item + 1] = inv_obj.ClassID
                        end
                        return 1
                    else
                        return 0
                    end

                end
            end
        end
    end

    local LoginCID = info.GetCID(session.GetMyHandle())
    if g.settings[LoginCID].maney_check == 1 then
        ReserveScript("another_warehouse_silver()", 0.1)
    end
    ReserveScript("another_warehouse_end()", delay)

    return 0

end]]

function another_warehouse_item_put_to(guid, count, goal_index, clsID, invcount)

    local itemCls = GetClassByType('Item', clsID)
    local iconName = GET_ITEM_ICON_IMAGE(itemCls);
    local Name = itemCls.Name

    if g.tooltip_count >= 4 then
        g.tooltip_count = g.tooltip_count - 4
    else
        g.tooltip_count = g.tooltip_count + 1
    end
    another_warehouse_item_tooltip(Name, iconName, count, g.tooltip_count)
    CHAT_SYSTEM(another_warehouse_lang("Item to warehousing") .. "：[" .. "{#EE82EE}" .. Name .. "{#FFFF00}]×" ..
                    "{#EE82EE}" .. count)

    if g.putitemtbl and g.putitemtbl[clsID] then
        g.putitemtbl[clsID] = nil
    end
    g.is_putting_item = false

end

function another_warehouse_item_tooltip(Name, iconName, Count, tooltipcount)

    local tooltip_frame = ui.CreateNewFrame("notice_on_pc", "another_warehouse_tooltip" .. tooltipcount, 0, 0, 10, 10)
    AUTO_CAST(tooltip_frame)

    tooltip_frame:SetSkinName("None")
    tooltip_frame:SetPos(680, 300 + tooltipcount * 55)
    tooltip_frame:SetLayerLevel(100)
    tooltip_frame:Resize(350, 64)

    local tooltip_gb = tooltip_frame:CreateOrGetControl("groupbox", "tooltip_gb", 0, 0, 350, 64)
    AUTO_CAST(tooltip_gb)
    tooltip_gb:SetSkinName("item_show_tootip")
    tooltip_gb:Resize(350, 64)

    local tooltip_slot = tooltip_gb:CreateOrGetControl("slot", "tooltip_slot", 20, 10, 45, 45)
    AUTO_CAST(tooltip_slot)

    local tooltip_text = tooltip_gb:CreateOrGetControl("richtext", "tooltip_text", 75, 15, 265, 22)
    AUTO_CAST(tooltip_text)
    tooltip_text:Resize(265, 22)

    tooltip_text:SetText("{ol}" .. Name)

    local tooltip_count = tooltip_gb:CreateOrGetControl("richtext", "tooltip_count", 75, 37, 265, 22)
    AUTO_CAST(tooltip_count)
    tooltip_count:Resize(265, 22)

    tooltip_count:SetText("{ol}" .. Count .. another_warehouse_lang(" Pieces in warehouse"))

    SET_SLOT_ICON(tooltip_slot, iconName)
    tooltip_frame:ShowWindow(1)
    ReserveScript(string.format("another_warehouse_item_tooltip_close(%d)", tooltipcount), 2.0)

end

function another_warehouse_item_tooltip_close(count)
    local tooltip_frame = ui.GetFrame("another_warehouse_tooltip" .. count)
    tooltip_frame:ShowWindow(0)

end

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
    -- print(invItemCount .. ":" .. maxcount)
    if tonumber(invItemCount) > tonumber(maxcount) then
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

    for index = 1, #tabIndices do
        local i = tabIndices[index]
        tab:SelectTab(i)
        if i > 0 then
            local left = GetTabLeftCount(tab, gbox)
            if left < 70 then
                return basecount + i * 70
            end
        else
            local slotset = GET_CHILD_RECURSIVELY(frame, "slotset")
            for j = 1, basecount do
                local slot = slotset:GetSlotByIndex(j)
                AUTO_CAST(slot)
                if slot:GetIcon() == nil then
                    return j
                end
            end
        end
    end
end

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

function another_warehouse_end()

    ui.SysMsg("[AWH]End of Operation")
    imcSound.PlaySoundEvent('sys_cube_open_normal');
end

function another_warehouse_setting_frame_init(frame, ctrl, str, num)

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

    local delay_edit = settingframe:CreateOrGetControl('edit', 'delay_edit', 400, 120, 100, 25)
    AUTO_CAST(delay_edit)
    delay_edit:SetFontName("white_16_ol")
    delay_edit:SetTextAlign("center", "center") -- print(tostring(g.settings.silver))

    delay_edit:SetTextTooltip(another_warehouse_lang(
        "If the warehouse entry fails,{nl}set a longer time. Basic is 0.3 sec."))
    delay_edit:SetText(tonumber(g.settings.delay) or 0.3)
    delay_edit:SetEventScript(ui.ENTERKEY, 'another_warehouse_setting_edit')

    local delay_text = settingframe:CreateOrGetControl("richtext", "delay_text", 505, 125, 100, 0)
    AUTO_CAST(delay_text);
    delay_text:SetText("{ol}" .. another_warehouse_lang("Delay time"))

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

    -- local err = acutil.loadJSON(WHM_SettingsFileLoc, WHM_settings)
    local err = g.load_json(WHM_SettingsFileLoc, WHM_settings)

    if err == nil then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", 'warehousemanager'))
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
        ui.SysMsg("Set to " .. ctrlnum .. " sec.")
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

    if g.settings.transfer ~= 1 then
        local WHM_SettingsFileLoc = string.format('../addons/%s/settings.json', 'warehousemanager')
        local WHM_settings = {}

        -- local settings, err = acutil.loadJSON(WHM_SettingsFileLoc, WHM_settings)
        local settings, err = g.load_json(WHM_SettingsFileLoc, WHM_settings)
        if err then
            -- 設定ファイル読み込み失敗時処理
            -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", 'warehousemanager'))
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

        -- local settings, err = acutil.loadJSON(WHM_char_SettingsFileLoc, WHM_char_settings)
        local settings, err = g.load_json(WHM_char_SettingsFileLoc, WHM_char_settings)
        if err then
            -- 設定ファイル読み込み失敗時処理
            -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", 'WarehouseManagerキャラ設定'))
        end

        local clsid = 0
        local count = 0

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
    elseif ctrlName == "leave" then -- 
        g.settings.leave = ischeck
    elseif ctrlName == "display_change" then -- 
        g.settings.display_change = ischeck
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

    local frame = ui.GetFrame("accountwarehouse")
    frame:ShowWindow(0)

    local overlap = ui.GetFrame("another_warehouse")
    overlap:ShowWindow(0)

    local setframe = ui.GetFrame("another_warehouse_set_items")
    setframe:ShowWindow(0)

end

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
        return false
    end
    if true == invItem.isLockState then

        ui.SysMsg(ClMsg("MaterialItemIsLock"));

        return false
    end

    local itemCls = GetClassByType("Item", obj.ClassID);
    if itemCls.ItemType == 'Quest' then

        ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"));

        return false
    end

    local enableTeamTrade = TryGetProp(itemCls, "TeamTrade");
    if enableTeamTrade ~= nil and enableTeamTrade == "NO" then

        ui.SysMsg(ClMsg("ItemIsNotTradable"));

        return false

    end
    return true
end

function another_warehouse_putitem(iesid, count)

    -- another_warehouse_checkvalid(iesid)

    local invItem = session.GetInvItemByGuid(iesid)
    local invItem_obj = GetIES(invItem:GetObject());

    local goal_index = another_warehouse_get_goal_index()
    --[[local exist, index = another_warehouse_get_exist_item_index(invItem_obj)
    if exist == true and index >= 0 then
        goal_index = index
    else
        another_warehouse_checkvalid(iesid)
    end]]
    local check = another_warehouse_checkvalid(iesid)
    -- ts(check)
    if check then
        local frame = ui.GetFrame("accountwarehouse")

        -- item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, iesid, tostring(math.min(count or invItem.count, invItem.count)),
        -- frame:GetUserIValue("HANDLE"))

        item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, iesid, tostring(math.min(count or invItem.count, invItem.count)),
            frame:GetUserIValue("HANDLE"), goal_index)
        g.new_stack_add_item[#g.new_stack_add_item + 1] = invItem_obj.ClassID .. "_" .. iesid
        local gbox_warehouse = GET_CHILD_RECURSIVELY(frame, "gbox_warehouse");
        if gbox_warehouse ~= nil then
            gbox_warehouse:UpdateData();
            -- gbox_warehouse:SetCurLine(0);
            -- gbox_warehouse:InvalidateScrollBar();
            frame:Invalidate();
        end
    end
end

function another_warehouse_active_mousebutton()

    if (ui.GetFrame("accountwarehouse"):IsVisible() == 1) then

        local invframe = ui.GetFrame("inventory")
        INVENTORY_SET_CUSTOM_RBTNDOWN("another_warehouse_inv_rbtn")

        SET_INV_LBTN_FUNC(invframe, "another_warehouse_inv_lbtn")
    end
end

function another_warehouse_inv_lbtn(frame, invItem, dumm)

    --[[local another_warehouse_setting = ui.GetFrame("another_warehouse_setting")
    if another_warehouse_setting and another_warehouse_setting:IsVisible() == 1 then
        return
    end]]

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

    local active_tree_box = another_warehouse_find_activegbox(frame)
    if active_tree_box then
        AUTO_CAST(active_tree_box)
        local curpos = active_tree_box:GetScrollCurPos();
        -- ts(active_tree_box:GetName(), curpos, type(curpos))
        active_tree_box:SetUserValue("INVENTORY_CUR_SCROLL_POS", curpos);
    end

    if msg == 'ACCOUNT_WAREHOUSE_ITEM_LIST' then
        another_warehouse_frame_update()
    elseif msg == 'ACCOUNT_WAREHOUSE_ITEM_IN' then

        -- no op
    elseif msg == 'ACCOUNT_WAREHOUSE_ITEM_ADD' then
        -- DebounceScript("another_warehouse_frame_update", 1.0, 0)
        another_warehouse_frame_update()

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
-- !!!
function another_warehouse_frame_close(frame, ctrl)
    local frame = ui.GetFrame("another_warehouse")
    frame:ShowWindow(0)

    local awframe = ui.GetFrame("accountwarehouse")
    -- awframe:ShowWindow(1)
    local accountwarehouse_tab = GET_CHILD_RECURSIVELY(awframe, "accountwarehouse_tab")
    accountwarehouse_tab:SetMargin(0, 120, 0, 0) -- margin="0 120 0 0"
    local richtext_1 = GET_CHILD_RECURSIVELY(awframe, "richtext_1")
    richtext_1:ShowWindow(1)
    -- richtext_1:SetMargin(30, 73, 0, 0) --  margin="30 73 0 0"
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

    local help = GET_CHILD_RECURSIVELY(awframe, "help")
    help:ShowWindow(0)
    -- name_text
    local name_text = GET_CHILD_RECURSIVELY(awframe, "name_text")
    name_text:ShowWindow(0)
    -- leave
    local leave = GET_CHILD_RECURSIVELY(awframe, "leave")
    leave:ShowWindow(0)

    local search_edit = GET_CHILD_RECURSIVELY(awframe, "search_edit")
    search_edit:ShowWindow(0)

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

function another_warehouse_take_item_from_warehouse(frame, count, inputframe)
    inputframe:ShowWindow(0);
    local iesid = inputframe:GetUserValue("ArgString");
    session.ResetItemList();
    session.AddItemID(iesid, count);
    item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), frame:GetUserIValue("HANDLE"));
end

function another_warehouse_on_lbutton(frame, slot, argstr, argnum)

    local another_warehouse_set_items = ui.GetFrame("another_warehouse_set_items")
    if another_warehouse_set_items and another_warehouse_set_items:IsVisible() == 1 then
        return
    end

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

end
---- if geItemTable.IsStack(inv_obj.ClassID) == 1 then
local function is_stack_new_item(class_id)
    for k, v in pairs(g.new_stack_add_item) do
        if v == class_id then
            return true
        end
    end
    return false
end

function another_warehouse_insert_item_to_tree(frame, tree, inv_item, item_cls, baseid_cls, type_str)

    local unique_id = tree:GetName() .. "_" .. inv_item:GetIESID()
    if g.processed_slots[unique_id] then
        return -- 
    end
    g.processed_slots[unique_id] = true

    local tree_group_name = baseid_cls.TreeGroup

    local tree_group = tree:FindByValue(tree_group_name);
    if tree:IsExist(tree_group) == 0 then

        -- another_warehouse_inven_slotset_and_title(tree, tree_group, tree_group_name, baseid_cls);
        tree_group = tree:Add(baseid_cls.TreeGroupCaption, baseid_cls.TreeGroup);
        local treeNode = tree:GetNodeByTreeItem(tree_group);
        treeNode:SetUserValue("BASE_CAPTION", baseid_cls.TreeGroupCaption)
    end

    local slotset_name = another_warehouse_get_slotset_name(baseid_cls)

    local slotset_node = tree:FindByValue(tree_group, slotset_name);

    if tree:IsExist(slotset_node) == 0 then
        --[[local slotset_title = 'ssettitle_' .. baseid_cls.ClassName;
        if baseid_cls.MergedTreeTitle ~= "NO" then
            slotset_title = 'ssettitle_' .. baseid_cls.MergedTreeTitle
        end]]

        -- local newSlotsname = MAKE_INVEN_SLOTSET_NAME(tree, slotset_title, baseid_cls.TreeSSetTitle)

        another_warehouse_inven_slotset_and_title(tree, tree_group, slotset_name, baseid_cls);
    end
    local slot_set = GET_CHILD_RECURSIVELY(tree, slotset_name, 'ui::CSlotSet');
    local slot_count = slot_set:GetSlotCount();

    local slot = nil;

    local count = GET_SLOTSET_COUNT(tree, baseid_cls)

    while slot_count <= count do
        slot_set:ExpandRow()
        slot_count = slot_set:GetSlotCount();
    end

    slot = slot_set:GetSlotByIndex(count);

    UPDATE_INVENTORY_SLOT(slot, inv_item, item_cls);

    local function _DRAW_ITEM(inv_item, slot)

        slot:SetSkinName('invenslot2')
        local item_cls = GetIES(inv_item:GetObject());
        local iconImg = GET_ITEM_ICON_IMAGE(item_cls);

        if geItemTable.IsStack(item_cls.ClassID) == 1 and is_stack_new_item(item_cls.ClassID) then
            slot:SetHeaderImage('new_inventory_icon');
        elseif geItemTable.IsStack(item_cls.ClassID) == 0 and
            is_stack_new_item(item_cls.ClassID .. "_" .. inv_item:GetIESID()) then
            slot:SetHeaderImage('new_inventory_icon');
        else
            slot:SetHeaderImage('None')
        end

        local new_sset = GET_CHILD_RECURSIVELY(frame, slotset_name)

        SET_SLOT_IMG(slot, iconImg)
        SET_SLOT_COUNT(slot, inv_item.count)

        SET_SLOT_STYLESET(slot, item_cls)
        SET_SLOT_IESID(slot, inv_item:GetIESID())
        SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, inv_item, item_cls, nil)
        slot:SetMaxSelectCount(inv_item.count);
        local icon = slot:GetIcon();
        icon:SetTooltipArg("accountwarehouse", inv_item.type, inv_item:GetIESID());
        SET_ITEM_TOOLTIP_TYPE(icon, item_cls.ClassID, item_cls, "accountwarehouse");
        SET_SLOT_ICOR_CATEGORY(slot, item_cls);

        if g.settings.display_change == 1 then

            if baseid_cls.TreeGroup == "Recipe" then

                local recipe_cls = GetClass('Recipe', item_cls.ClassName);
                if recipe_cls ~= nil then

                    local taget_item = GetClass("Item", recipe_cls.TargetItem);

                    if taget_item then
                        local image = GET_ITEM_ICON_IMAGE(taget_item)

                        local recipe_pic = slot:CreateOrGetControl('picture', 'recipe_pic' .. inv_item:GetIESID(), 0, 0,
                            25, 25)
                        AUTO_CAST(recipe_pic)
                        recipe_pic:SetEnableStretch(1)
                        recipe_pic:SetGravity(ui.LEFT, ui.TOP)
                        recipe_pic:SetImage(image)
                        recipe_pic:SetTooltipArg("accountwarehouse", inv_item.type, inv_item:GetIESID());
                        SET_ITEM_TOOLTIP_TYPE(recipe_pic, taget_item.ClassID, taget_item, "accountwarehouse");
                    end
                end

            end

            if string.find(baseid_cls.ClassName, "Card") and not string.find(baseid_cls.ClassName, "Summon") and
                not string.find(baseid_cls.ClassName, "CardAddExp") then

                local image = TryGetProp(item_cls, "TooltipImage", "None")
                if image ~= "None" then
                    icon:Set(image, 'Item', inv_item.type, inv_item.invIndex, inv_item:GetIESID(), inv_item.count);
                    --[[local label_slot =
                        slot:CreateOrGetControl('slot', 'label_slot' .. inv_item:GetIESID(), 0, 0, 60, 63)
                    AUTO_CAST(label_slot)
                    local margin = label_slot:GetMargin();
                    label_slot:SetMargin(margin.left - 3, margin.top - 4, margin.right, margin.bottom)
                    local icon_label = CreateIcon(label_slot)
                    if baseid_cls.ClassName == 'Card_CardRed' then
                        icon_label:SetImage('red_cardslot1')
                    elseif baseid_cls.ClassName == 'Card_CardBlue' then
                        icon_label:SetImage('blue_cardslot1')
                    elseif baseid_cls.ClassName == 'Card_CardPurple' then
                        icon_label:SetImage('purple_cardslot1')
                    elseif baseid_cls.ClassName == 'Card_CardGreen' then
                        icon_label:SetImage('green_cardslot1')
                    elseif baseid_cls.ClassName == 'Card_CardLeg' then
                        icon_label:SetImage('legendopen_cardslot')
                    elseif baseid_cls.ClassName == 'Card_CardGoddess' then
                        icon_label:SetImage('legendopen_cardslot')
                    end]]

                end
            end

            if baseid_cls.ClassName == "Gem_GemSkill" then

                for i = 1, 4 do
                    if TryGetProp(item_cls, 'RandomOption_' .. i, 'None') ~= 'None' and
                        TryGetProp(item_cls, 'RandomOptionValue_' .. i, 0) > 0 then

                        local star_pic = slot:CreateOrGetControl('richtext', 'star_pic' .. inv_item:GetIESID(), 0, 0,
                            18, 18)

                        star_pic:SetText("{img star_mark 18 18}")
                        star_pic:SetGravity(ui.RIGHT, ui.TOP);

                    end
                end

                local skill_cls = GetClass("Skill", TryGetProp(item_cls, 'SkillName', 'None'))

                if skill_cls then

                    local image = "icon_" .. GET_ITEM_ICON_IMAGE(skill_cls)

                    icon:Set(image, 'Item', inv_item.type, inv_item.invIndex, inv_item:GetIESID(), inv_item.count);

                    local skill_pic = slot:CreateOrGetControl('picture', 'skill_pic' .. inv_item:GetIESID(), 0, 0, 35,
                        35)
                    AUTO_CAST(skill_pic)

                    local image = GET_ITEM_ICON_IMAGE(item_cls)

                    skill_pic:SetEnableStretch(1)
                    skill_pic:SetGravity(ui.LEFT, ui.TOP)

                    skill_pic:SetImage(image)
                end

            elseif baseid_cls.ClassName == "Gem_High_Color" then

                local cls_name = item_cls.ClassName
                if string.find(cls_name, "540") then
                    slot:SetSkinName("invenslot_pic_goddess")
                elseif string.find(cls_name, "520") then
                    slot:SetSkinName("invenslot_legend")
                elseif string.find(cls_name, "500") then
                    slot:SetSkinName("invenslot_unique")
                elseif string.find(cls_name, "480") then
                    slot:SetSkinName("invenslot_rare")
                else
                    slot:SetSkinName("invenslot_nomal")
                end
            end

            if string.find(baseid_cls.ClassName, "OPTMisc_GoddessIcor") then
                local cls_name = item_cls.ClassName

                local is_special = string.find(cls_name, "EP17") or string.find(cls_name, "Weapon2") or
                                       string.find(cls_name, "Armor2")
                if not is_special then
                    slot:SetSkinName("invenslot_rare")
                end
            elseif string.find(baseid_cls.ClassName, "Armor") then
                local cls_name = item_cls.ClassName
                local is_special = string.find(cls_name, "EP17") or
                                       (string.find(cls_name, "EP16") and string.find(cls_name, "high")) or
                                       (string.find(cls_name, "EP13") and string.find(cls_name, "high2"))
                if not is_special and (string.find(cls_name, "belt") or string.find(cls_name, "shoulder")) then
                    slot:SetSkinName("invenslot_rare")
                end
            end

        end

        if inv_item.hasLifeTime == true or TryGetProp(item_cls, 'ExpireDateTime', 'None') ~= 'None' then
            ICON_SET_ITEM_REMAIN_LIFETIME(icon, IT_ACCOUNT_WAREHOUSE);
            slot:SetFrontImage('clock_inven');
        else
            CLEAR_ICON_REMAIN_LIFETIME(slot, icon);
        end

    end

    _DRAW_ITEM(inv_item, slot, nil)

    SET_SLOTSETTITLE_COUNT(tree, baseid_cls, 1)
    if (g.settings.enabledrag) then
        slot:EnableDrag(1)
    else
        slot:EnableDrag(0)
    end
    slot:SetEventScript(ui.LBUTTONUP, "another_warehouse_on_lbutton")
    slot:SetEventScript(ui.RBUTTONUP, "another_warehouse_on_rbutton")
    slot_set:MakeSelectionList();

end

function another_warehouse_check_search_and_filter(inv_item, item_cls, search_text)

    if search_text == "" then
        return true
    end

    local temp_cap = string.lower(search_text)

    local item_name = string.lower(dictionary.ReplaceDicIDInCompStr(item_cls.Name))
    if string.find(item_name, temp_cap) then
        return true
    end

    local prefix_class_name = TryGetProp(item_cls, "LegendPrefix")
    if prefix_class_name and prefix_class_name ~= "None" then
        local prefix_cls = GetClass('LegendSetItem', prefix_class_name)
        if prefix_cls then
            local prefix_name = string.lower(dictionary.ReplaceDicIDInCompStr(prefix_cls.Name))
            if string.find(prefix_name .. " " .. item_name, temp_cap) then
                return true
            end
        end
    end

    if TryGetProp(item_cls, 'GroupName', 'None') == 'Earring' then
        local max_option_count = shared_item_earring.get_max_special_option_count(TryGetProp(item_cls, 'UseLv', 1))
        for i = 1, max_option_count do
            local option_name = 'EarringSpecialOption_' .. i
            local job_id = TryGetProp(item_cls, option_name, 'None')
            if job_id ~= 'None' then
                local job_cls = GetClass('Job', job_id)
                if job_cls and string.find(string.lower(dictionary.ReplaceDicIDInCompStr(job_cls.Name)), temp_cap) then
                    return true
                end
            end
        end
    end

    if TryGetProp(item_cls, 'GroupName', 'None') == 'Icor' then
        local item = GetIES(inv_item:GetObject())
        for i = 1, 5 do
            local option = TryGetProp(item, 'RandomOption_' .. i, 'None')
            if option and option ~= "None" and
                string.find(string.lower(dictionary.ReplaceDicIDInCompStr(ClMsg(option))), temp_cap) then
                return true
            end
        end
    end

    return false
end

function another_warehouse_frame_update()

    g.processed_slots = {}

    local another_warehouse = ui.GetFrame("another_warehouse")
    local accountwarehouse = ui.GetFrame("accountwarehouse")
    local inventoryGbox = GET_CHILD_RECURSIVELY(another_warehouse, 'inventoryGbox', 'ui::CGroupBox')

    for type_no = 1, #g_invenTypeStrList do
        if not IsBlackListedTabName(g_invenTypeStrList[type_no]) then
            local tree_box = GET_CHILD_RECURSIVELY(inventoryGbox, 'treeGbox_' .. g_invenTypeStrList[type_no],
                'ui::CGroupBox')
            if tree_box then
                local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[type_no],
                    'ui::CTreeControl')
                if tree then
                    tree:Clear()
                    tree:EnableDrawFrame(false)
                    tree:SetFitToChild(true, 60)
                    tree:SetFontName(another_warehouse:GetUserConfig("TREE_GROUP_FONT"))
                    tree:SetTabWidth(another_warehouse:GetUserConfig("TREE_TAB_WIDTH"))
                end
            end
        end
    end

    local item_list = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local sorted_guid_list = item_list:GetSortedGuidList()
    local warehouse_item_list = {}
    for i = 0, sorted_guid_list:Count() - 1 do
        local warehouse_item = item_list:GetItemByGuid(sorted_guid_list:Get(i))
        if warehouse_item then
            table.insert(warehouse_item_list, warehouse_item)
        end
    end
    table.sort(warehouse_item_list, INVENTORY_SORT_BY_NAME)

    local categorized_items = {}
    for _, inv_item in ipairs(warehouse_item_list) do
        local item_cls = GetIES(inv_item:GetObject())
        local baseid_cls = INV_GET_INVEN_BASEIDCLS_BY_ITEMGUID(inv_item:GetIESID())

        if item_cls and baseid_cls then
            local title_name = baseid_cls.MergedTreeTitle ~= "NO" and baseid_cls.MergedTreeTitle or baseid_cls.ClassName
            if not categorized_items[title_name] then
                categorized_items[title_name] = {}
            end
            table.insert(categorized_items[title_name], inv_item)
        end
    end

    local baseid_cls_list, baseid_count = GetClassList("inven_baseid")
    local inven_title_name = {}
    for i = 1, baseid_count do
        local baseidcls = GetClassByIndexFromList(baseid_cls_list, i - 1)
        local temp_title = baseidcls.MergedTreeTitle ~= "NO" and baseidcls.MergedTreeTitle or baseidcls.ClassName
        if table.find(inven_title_name, temp_title) == 0 then
            table.insert(inven_title_name, temp_title)
        end
    end

    local search_edit = GET_CHILD_RECURSIVELY(accountwarehouse, "search_edit")
    local search_text = search_edit:GetText()

    for _, category_name in ipairs(inven_title_name) do
        local items_in_category = categorized_items[category_name]
        if items_in_category then
            for _, inv_item in ipairs(items_in_category) do
                local item_cls = GetIES(inv_item:GetObject())
                local baseid_cls = INV_GET_INVEN_BASEIDCLS_BY_ITEMGUID(inv_item:GetIESID())
                local type_str = GET_INVENTORY_TREEGROUP(baseid_cls)
                local make_slot = another_warehouse_check_search_and_filter(inv_item, item_cls, search_text)

                if make_slot and inv_item.count > 0 and baseid_cls.ClassName ~= 'Unused' then

                    local tree_box = GET_CHILD_RECURSIVELY(inventoryGbox, 'treeGbox_' .. type_str, 'ui::CGroupBox')
                    if tree_box then
                        local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. type_str, 'ui::CTreeControl')
                        if tree then
                            another_warehouse_insert_item_to_tree(another_warehouse, tree, inv_item, item_cls,
                                baseid_cls, type_str)

                        end
                    end

                    local tree_box_all = GET_CHILD_RECURSIVELY(inventoryGbox, 'treeGbox_All', 'ui::CGroupBox')
                    if tree_box_all then
                        local tree_all = GET_CHILD_RECURSIVELY(tree_box_all, 'inventree_All', 'ui::CTreeControl')
                        if tree_all then
                            another_warehouse_insert_item_to_tree(another_warehouse, tree_all, inv_item, item_cls,
                                baseid_cls, "All")
                        end
                    end
                end
            end
        end
    end

    -- local height = another_warehouse:GetHeight()
    for type_no = 1, #g_invenTypeStrList do
        if not IsBlackListedTabName(g_invenTypeStrList[type_no]) then
            local tree_box = GET_CHILD_RECURSIVELY(inventoryGbox, 'treeGbox_' .. g_invenTypeStrList[type_no],
                'ui::CGroupBox')
            if tree_box then
                local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[type_no],
                    'ui::CTreeControl')
                if tree then

                    local slot_set_name_list_count = ui.inventory.GetInvenSlotSetNameCount();
                    for i = 1, slot_set_name_list_count do
                        local get_slot_set_name = ui.inventory.GetInvenSlotSetNameByIndex(i - 1);
                        local slotset = GET_CHILD_RECURSIVELY(tree, get_slot_set_name, 'ui::CSlotSet');
                        if slotset ~= nil then
                            ui.InventoryHideEmptySlotBySlotSet(slotset);
                        end
                    end

                    ADD_GROUP_BOTTOM_MARGIN(another_warehouse, tree)
                    tree:OpenNodeAll();
                    tree:SetEventScript(ui.LBUTTONDOWN, "INVENTORY_TREE_OPENOPTION_CHANGE");
                    INVENTORY_CATEGORY_OPENCHECK(another_warehouse, tree);

                end
            end
        end
    end

    local active_tree_box = another_warehouse_find_activegbox(another_warehouse)
    if active_tree_box then
        AUTO_CAST(active_tree_box)
        local savedPos = active_tree_box:GetUserIValue("INVENTORY_CUR_SCROLL_POS")

        active_tree_box:SetScrollPos(savedPos)
        active_tree_box:InvalidateScrollBar();
    end

    local max_count = another_warehouse_get_maxcount()
    local item_count = another_warehouse_item_count()

    local count_text = GET_CHILD_RECURSIVELY(accountwarehouse, "count_text")
    AUTO_CAST(count_text)

    count_text:SetText("{@st42}" .. item_count .. "/" .. max_count .. "{/}")
    count_text:SetFontName("white_16_ol")

end

