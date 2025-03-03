-- v1.0.0 取り急ぎ作った。barrackitemlist見たいなやつ。
local addonName = "CHARACTERS_ITEM_SERCH"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local active_id = session.loginInfo.GetAID()
local folder_path = string.format("../addons/%s/%s", addonNameLower, active_id)
local settings_path = string.format("../addons/%s/%s/settings.json", addonNameLower, active_id)
local warehouse_dat = string.format("../addons/%s/%s/warehouse.dat", addonNameLower, active_id)
local inventory_dat = string.format("../addons/%s/%s/inventory.dat", addonNameLower, active_id)
local equips_dat = string.format("../addons/%s/%s/equips.dat", addonNameLower, active_id)

local acutil = require("acutil")
local json = require("json")

function g.setup_hook(my_func, origin_func_name)
    g.funcs = g.funcs or {}
    local addon_upper = string.upper(addonName)
    local rep_func_name = addon_upper .. "_BASE_" .. origin_func_name
    if (_G[rep_func_name] == nil) then
        _G[rep_func_name] = _G[origin_func_name];
        _G[origin_func_name] = my_func
    end
    g.funcs[origin_func_name] = _G[rep_func_name]
end

function g.setup_event(my_addon, origin_func_name, my_func_name)
    local function_name = string.gsub(origin_func_name, "%.", "");
    local original_func = _G[origin_func_name]

    if not _G['ADDONS']['EVENTS'] then
        _G['ADDONS']['EVENTS'] = {}
    end

    if not _G['ADDONS']['EVENTS']['ARGS'] then
        _G['ADDONS']['EVENTS']['ARGS'] = {}
    end

    local function hooked_function(...)
        local args = {...}
        local results = {original_func(...)}
        _G['ADDONS']['EVENTS']['ARGS'][function_name] = args
        imcAddOn.BroadMsg(function_name);
        return table.unpack(results)
    end

    _G[origin_func_name] = hooked_function
    my_addon:RegisterMsg(function_name, my_func_name)
end

function g.get_event_args(event_msg)
    return table.unpack(_G['ADDONS']['EVENTS']['ARGS'][event_msg]);
end

function g.mkdir_new_folder()

    local folder = string.format("../addons/%s", addonNameLower)
    local file_path = string.format("../addons/%s/mkdir.txt", addonNameLower)
    local file = io.open(file_path, "r")
    if not file then
        os.execute('mkdir "' .. folder .. '"')
        file = io.open(file_path, "w")
        if file then
            file:write("A new file has been created")
            file:close()
        end
    else
        file:close()
    end

    local folder = string.format("../addons/%s/%s", addonNameLower, active_id)
    local file_path = string.format("../addons/%s/%s/mkdir.txt", addonNameLower, active_id)
    local file = io.open(file_path, "r")
    if not file then
        os.execute('mkdir "' .. folder .. '"')
        file = io.open(file_path, "w")
        if file then
            file:write("A new file has been created")
            file:close()
        end
    else
        file:close()
    end
end
g.mkdir_new_folder()

function g.saveJSON(path, tbl)
    local file = io.open(path, "w")
    local str = json.encode(tbl)
    file:write(str)
    file:close()
end

function g.loadJSON(path)

    local file, err = io.open(path, "r")

    if file then
        local content = file:read("*all")
        file:close()
        local table = json.decode(content)
        return table
    else
        return nil
    end
end

function characters_item_serch_save_settings()
    g.saveJSON(settings_path, g.settings)
end

function characters_item_serch_load_settings()

    local settings = g.loadJSON(settings_path)

    if not settings then
        settings = {}
    end

    g.settings = settings

    if not g.settings.chars then
        g.settings.chars = {}
    end

    local account_info = session.barrack.GetMyAccount()
    local barrack_char_count = account_info:GetBarrackPCCount()

    local existing_char_names = {}
    for i = 0, barrack_char_count - 1 do
        local barrack_char_info = account_info:GetBarrackPCByIndex(i)
        local barrack_char_name = barrack_char_info:GetName()
        existing_char_names[barrack_char_name] = true
        if not g.settings.chars[barrack_char_name] then
            g.settings.chars[barrack_char_name] = {
                layer = 9,
                index = 99
            }
        end
    end

    for char_name in pairs(g.settings.chars) do
        if not existing_char_names[char_name] then
            g.settings.chars[char_name] = nil
        end
    end

    characters_item_serch_save_settings()

    local dat_tbl = {string.format("../addons/%s/%s/warehouse.dat", addonNameLower, active_id),
                     string.format("../addons/%s/%s/inventory.dat", addonNameLower, active_id),
                     string.format("../addons/%s/%s/equips.dat", addonNameLower, active_id)}

    for _, dat in ipairs(dat_tbl) do
        local file = io.open(dat, "r")
        if not file then
            file = io.open(dat, "w")
            file:close()
        else
            file:close() -- 存在するファイルを閉じる
        end
    end

end

function characters_item_serch_char_data(frame, msg, str, num)
    if not g.layer then
        return
    end

    local account_info = session.barrack.GetMyAccount()
    local layer_pc_count = account_info:GetPCCount()

    local char_list = {}
    for i = 0, layer_pc_count - 1 do
        local pc_info = account_info:GetPCByIndex(i)
        local pc_apc = pc_info:GetApc()
        local pc_name = pc_apc:GetName()
        g.settings.chars[pc_name] = {
            index = i,
            layer = g.layer
        }
    end

    characters_item_serch_save_settings()
    g.layer = nil

    local sorted_chars = {}
    for name, data in pairs(g.settings.chars) do
        table.insert(sorted_chars, {
            name = name,
            data = data
        })
    end

    table.sort(sorted_chars, function(a, b)
        return a.data.layer < b.data.layer or (a.data.layer == b.data.layer and a.data.index < b.data.index)
    end)

    g.chars = {}
    local existing_names = {}
    for i, char in ipairs(sorted_chars) do
        for line in io.lines(inventory_dat) do
            local name = line:match("^(.-):::")
            if name == char.name and not existing_names[name] then
                table.insert(g.chars, name)
                existing_names[name] = true
                break
            end
        end
    end
    --[[for i = 1, #g.chars do
        print(i .. ": " .. tostring(g.chars[i]))
    end]]

end

function characters_item_serch_SELECT_BARRACK_LAYER(frame, ctrl, arg, layer)
    characters_item_serch_SELECT_BARRACK_LAYER_(frame, ctrl, arg, layer)
end

local current_layer = 1
function characters_item_serch_SELECT_BARRACK_LAYER_(frame, ctrl, arg, layer)

    g.layer = layer
    local before = frame:GetUserValue("SelectBarrackLayer");
    local isMoving = frame:GetUserValue("MovingBarrackLayer");
    if tostring(before) == tostring(layer) then
        return;
    end

    if tostring(isMoving) == '1' then
        return;
    end

    frame:SetUserValue("MovingBarrackLayer", 1);

    local pccount = GET_CHILD(frame, "pccount", "ui::CRichText");
    local layerCtrl_1 = GET_CHILD(frame, "changeLayer1", "ui::CButton");
    local layerCtrl_2 = GET_CHILD(frame, "changeLayer2", "ui::CButton");
    local layerCtrl_3 = GET_CHILD(frame, "changeLayer3", "ui::CButton");
    if ctrl:GetName() == 'changeLayer1' then
        layerCtrl_1:SetImage('barrack_on_one_btn');
        layerCtrl_2:SetImage('barrack_off_two_btn');
        layerCtrl_3:SetImage('barrack_off_three_btn');
        pccount:SetTextByKey("value", '1');
    elseif ctrl:GetName() == 'changeLayer2' then
        layerCtrl_1:SetImage('barrack_off_one_btn');
        layerCtrl_2:SetImage('barrack_on_two_btn');
        layerCtrl_3:SetImage('barrack_off_three_btn');
        pccount:SetTextByKey("value", '2');
    else
        layerCtrl_1:SetImage('barrack_off_one_btn');
        layerCtrl_2:SetImage('barrack_off_two_btn');
        layerCtrl_3:SetImage('barrack_on_three_btn');
        pccount:SetTextByKey("value", '3');
    end

    barrack.SelectBarrackLayer(layer);
    frame:SetUserValue("SelectBarrackLayer", layer);
    current_layer = layer
    local scrollBox = frame:GetChild("scrollBox");
    scrollBox:RemoveAllChild();
    disable_char_btn(frame)
    disable_layer_btn(frame)
    AddLuaTimerFunc('enable_layer_btn', 5000, 0)
    AddLuaTimerFunc('reset_moving_barrack_layer', 5000, 0) -- 5초뒤에 강제로 해제.

end
g.setup_hook(characters_item_serch_SELECT_BARRACK_LAYER, 'SELECT_BARRACK_LAYER')
function CHARACTERS_ITEM_SERCH_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()
    g.cid = session.GetMySession():GetCID()
    g.login_name = session.GetMySession():GetPCApc():GetName()

    characters_item_serch_load_settings()

    g.layer = g.layer or 1
    -- CHAT_SYSTEM(tostring(g.layer))

    -- g.setup_event(addon, 'SELECT_BARRACK_LAYER', 'characters_item_serch_SELECT_BARRACK_LAYER')
    acutil.setupEvent(addon, "SELECT_BARRACK_LAYER", "characters_item_serch_SELECT_BARRACK_LAYER");

    g.setup_event(addon, 'GAME_TO_BARRACK', 'characters_item_serch_inventory_save_list')
    g.setup_event(addon, 'GAME_TO_LOGIN', 'characters_item_serch_inventory_save_list')
    g.setup_event(addon, 'DO_QUIT_GAME', 'characters_item_serch_inventory_save_list')
    g.setup_event(addon, "INVENTORY_CLOSE", "characters_item_serch_inventory_save_list")

    g.setup_event(addon, 'WAREHOUSE_CLOSE', 'characters_item_serch_warehouse_save_list')
    local sysmenu_frame = ui.GetFrame("sysmenu")
    local inven = GET_CHILD(sysmenu_frame, "inven")
    AUTO_CAST(inven)
    inven:SetEventScript(ui.RBUTTONUP, "characters_item_serch_toggle_frame")

    local function get_localized_tooltip(lang)
        if lang == "Japanese" then
            return "{@st59}インベントリ (F2){nl}Right click: Characters Item Serch"
        elseif lang == "kr" then
            return "{@st59}인벤토리 (F2){nl}Right click: Characters Item Serch"
        else
            return "{@st59}Inventory (F2){nl}Right click: Characters Item Serch"
        end
    end
    local tooltip = get_localized_tooltip(g.lang)
    inven:SetTextTooltip(tooltip)

    addon:RegisterMsg("GAME_START_3SEC", "characters_item_serch_char_data")
end

function characters_item_serch_toggle_frame(frame, ctrlstr, num)
    local frame = ui.GetFrame("characters_item_serch")

    if frame:IsVisible() == 0 then
        characters_item_serch_open(frame)
    else
        characters_item_serch_close(frame)
    end
end

function characters_item_serch_warehouse_save_list(frame, msg)

    local frame = ui.GetFrame('warehouse')
    local gbox = frame:GetChild("gbox");
    local slotset = gbox:GetChild("slotset");
    AUTO_CAST(slotset)

    local items = {}

    for i = 0, slotset:GetSlotCount() - 1 do
        local slot = slotset:GetSlotByIndex(i)
        local icon = slot:GetIcon()

        if icon then
            local icon_info = icon:GetInfo();
            local iesid = icon_info:GetIESID();
            local obj = GetObjectByGuid(iesid)
            local clsid = obj.ClassID
            local item_cls = GetClassByType('Item', clsid)
            local category = "false"
            if item_cls ~= nil and item_cls.MarketCategory ~= "None" then
                category = item_cls.MarketCategory:match("^(.-)_")
            end
            local item_name = string.lower(dictionary.ReplaceDicIDInCompStr(obj.Name));
            table.insert(items, {g.login_name, iesid, clsid, icon_info.count, item_name, "warehouse", category})
        end
    end

    local lines = {}
    for line in io.lines(warehouse_dat) do
        local name = line:match("^(.-):::")
        if name ~= g.login_name then
            table.insert(lines, line)
        end
    end

    local file = io.open(warehouse_dat, "w")
    if file then
        if #lines > 0 then
            file:write(table.concat(lines, "\n") .. "\n")
        end

        for _, item in ipairs(items) do
            local line = string.format("%s:::%s:::%d:::%d:::%s:::%s:::%s\n", item[1], item[2], item[3], item[4],
                                       item[5], item[6], item[7])
            file:write(line)
        end
        file:flush()
        file:close()
    end
end

function characters_item_serch_inventory_save_list(frame, msg)
    local inv_item_list = session.GetInvItemList()
    local inv_guid_list = inv_item_list:GetGuidList()
    local cnt = inv_guid_list:Count()

    -- inventory save
    local items = {}

    for i = 0, cnt - 1 do
        local guid = inv_guid_list:Get(i)
        local inv_Item = inv_item_list:GetItemByGuid(guid)
        local inv_obj = GetIES(inv_Item:GetObject())
        local inv_clsid = inv_obj.ClassID
        local inv_count = inv_Item.count
        local item_cls = GetClassByType('Item', inv_clsid)
        local category = "false"
        if item_cls ~= nil and item_cls.MarketCategory ~= "None" then
            category = item_cls.MarketCategory:match("^(.-)_")
        end
        local item_name = string.lower(dictionary.ReplaceDicIDInCompStr(inv_obj.Name));
        table.insert(items, {g.login_name, guid, inv_clsid, inv_count, item_name, "inventory", category})
    end

    local lines = {}
    for line in io.lines(inventory_dat) do
        local name = line:match("^(.-):::")
        if name ~= g.login_name then
            table.insert(lines, line)
        end
    end

    local file = io.open(inventory_dat, "w")
    if file then
        if #lines > 0 then
            file:write(table.concat(lines, "\n") .. "\n")
        end

        for _, item in ipairs(items) do
            local line = string.format("%s:::%s:::%d:::%d:::%s:::%s:::%s\n", item[1], item[2], item[3], item[4],
                                       item[5], item[6], item[7])
            file:write(line)
        end
        file:flush()
        file:close()
    end

    -- equips save
    local items = {}

    local equiplist = session.GetEquipItemList()
    for i = 0, equiplist:Count() - 1 do
        local equip_item = equiplist:GetEquipItemByIndex(i);
        local obj = GetIES(equip_item:GetObject());
        if obj ~= nil then
            local iesid = equip_item:GetIESID()
            if iesid ~= "0" then
                local clsid = obj.ClassID
                local item_cls = GetClassByType('Item', clsid)
                local category = "false"
                if item_cls ~= nil and item_cls.MarketCategory ~= "None" then
                    category = item_cls.MarketCategory:match("^(.-)_")
                end
                local item_name = string.lower(dictionary.ReplaceDicIDInCompStr(obj.Name))
                table.insert(items, {g.login_name, iesid, clsid, 1, item_name, "equips", category})
            end
        end
    end

    local mc_frame = ui.GetFrame("monstercardslot")
    for i = 1, 14 do
        local card_info = equipcard.GetCardInfo(i);
        if card_info then
            local clsid = card_info:GetCardID()
            local item_cls = GetClassByType("Item", clsid)
            local item_name = string.lower(dictionary.ReplaceDicIDInCompStr(item_cls.Name))
            local category = "false"
            if item_cls ~= nil and item_cls.MarketCategory ~= "None" then
                category = item_cls.MarketCategory:match("^(.-)_")
            end

            table.insert(items, {g.login_name, "None" .. i, clsid, 1, item_name, "equips", category})
        end

    end

    local lines = {}
    for line in io.lines(equips_dat) do
        local name = line:match("^(.-):::")
        if name ~= g.login_name then
            table.insert(lines, line)
        end
    end

    local file = io.open(equips_dat, "w")

    if file then
        if #lines > 0 then
            file:write(table.concat(lines, "\n") .. "\n")
        end

        for _, item in ipairs(items) do
            local line = string.format("%s:::%s:::%d:::%d:::%s:::%s:::%s\n", item[1], item[2], item[3], item[4],
                                       item[5], item[6], item[7])
            file:write(line)
        end
        file:flush()
        file:close()
    end
    -- characters_item_serch_char_data()
end

function characters_item_serch_serch_load_data(search_text)
    local dat_tbl = {string.format("../addons/%s/%s/warehouse.dat", addonNameLower, active_id),
                     string.format("../addons/%s/%s/inventory.dat", addonNameLower, active_id),
                     string.format("../addons/%s/%s/equips.dat", addonNameLower, active_id)}

    local function split(input, delimiter)
        local parts = {}
        for part in input:gmatch("([^" .. delimiter .. "]+)") do
            table.insert(parts, part)
        end
        return parts
    end

    local items = {}
    for _, dat_file_path in ipairs(dat_tbl) do
        for line in io.lines(dat_file_path) do

            if string.find(string.lower(line), string.lower(search_text)) then
                local parts = {}
                local start = 1
                while true do
                    local s, e = string.find(line, ":::", start, true)
                    if not s then
                        local last_part = string.sub(line, start)
                        if last_part ~= "" then
                            table.insert(parts, last_part)
                        end
                        break
                    end
                    local part = string.sub(line, start, s - 1)
                    table.insert(parts, part)
                    start = e + 1
                end
                parts[2] = tonumber(parts[2]) or 0
                table.insert(items, parts)
            end
        end
    end

    table.sort(items, function(a, b)
        return a[2] < b[2]
    end)

    return items
end

function characters_item_serch_item_search(frame, ctrl, str, num)

    local frame = ctrl:GetTopParentFrame()
    local search_edit = GET_CHILD(frame, "search_edit")
    AUTO_CAST(search_edit)
    local search_text = search_edit:GetText()
    if search_text == "" then
        characters_item_serch_open(frame, g.login_name)
        return
    end
    local gb = GET_CHILD(frame, "gb")
    gb:RemoveAllChild()
    local tree = gb:CreateOrGetControl("tree", 'name_tree', 0, 0, 0, 0)
    AUTO_CAST(tree)
    tree:Clear();
    tree:EnableDrawFrame(false)
    tree:SetFitToChild(true, 10)
    tree:SetFontName("white_16_ol");

    local items = characters_item_serch_serch_load_data(search_text)
    --[[for i = 1, #items do
        local sub_table = items[i]
        print("Item " .. i .. ":")
        for j = 1, #sub_table do
            print("  " .. j .. ": " .. tostring(sub_table[j]))
        end
    end]]
    local names = {}

    for i = 1, #items do
        local item = items[i]
        local name = item[1]

        if not names[name] then
            names[name] = true
            local slot_set = characters_item_serch_make_inven_slotset(tree, name)
            tree:Add(name)
            tree:Add(slot_set, name)
        end

    end

    for i = 1, #items do
        local item = items[i]
        local name = item[1]
        local clsid = item[3]
        local item_count = item[4]
        local slot_set = GET_CHILD(tree, name)
        characters_item_serch_insert_item_to_tree(slot_set, clsid, item_count)
    end
    tree:Resize(frame:GetWidth() - 40, frame:GetHeight() - 135)
    tree:OpenNodeAll()
end

function characters_item_serch_open(frame, select_name)

    if frame ~= "frame" then
        select_name = nil
    end

    local frame = ui.GetFrame("characters_item_serch")

    AUTO_CAST(frame)
    frame:SetSkinName("test_frame_low")
    frame:Resize(670, 1080)
    frame:SetPos(0, 0)
    frame:EnableMove(0)
    frame:SetLayerLevel(100)
    frame:SetTitleBarSkin("None")
    frame:RemoveAllChild()
    frame:ShowWindow(1)

    local title_gb = frame:CreateOrGetControl("groupbox", "title_gb", 0, 0, frame:GetWidth(), 55)
    title_gb:SetSkinName("test_frame_top")
    AUTO_CAST(title_gb)
    local title_text = title_gb:CreateOrGetControl("richtext", "title_text", 0, 0, ui.CENTER_HORZ, ui.TOP, 0, 15, 0, 0)
    AUTO_CAST(title_text);
    title_text:SetText('{ol}{s26}Characters Item Serch')

    function characters_item_serch_close(frame, ctrl, str, num)
        frame:ShowWindow(0)
    end

    local close = frame:CreateOrGetControl("button", "close", 0, 0, 25, 25)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "characters_item_serch_close")

    local login_name = frame:CreateOrGetControl("richtext", "login_name", 20, 60, 0, 0)
    AUTO_CAST(login_name);
    login_name:SetText(select_name == nil and '{ol}{s18}' .. g.login_name or '{ol}{s18}' .. select_name)

    function characters_item_serch_context()
        local context = ui.CreateContextMenu("characters_item_serch_context", "Characters", 0, 0, 120, 0)
        ui.AddContextMenuItem(context, "-----")

        for _, name in ipairs(g.chars) do
            local str_scp
            str_scp = string.format("characters_item_serch_open('%s','%s')", "frame", name)
            ui.AddContextMenuItem(context, name, str_scp)
        end

        ui.OpenContextMenu(context)
    end

    local char_switch = frame:CreateOrGetControl("button", "char_switch", 20, 85, 150, 30)
    AUTO_CAST(char_switch)
    char_switch:SetText(g.lang == "Japanese" and "{ol}キャラクター切替" or "{ol}character switch")
    char_switch:SetSkinName("test_pvp_btn")
    char_switch:SetEventScript(ui.LBUTTONUP, "characters_item_serch_context")

    local search_edit = frame:CreateOrGetControl("edit", "search_edit", 200, 80, 250, 40)
    AUTO_CAST(search_edit)
    search_edit:SetFontName("white_18_ol")
    search_edit:SetTextAlign("left", "center")
    search_edit:SetSkinName("inventory_serch")
    search_edit:SetEventScript(ui.ENTERKEY, "characters_item_serch_item_search")

    local search_btn = search_edit:CreateOrGetControl("button", "search_btn", 0, 0, 60, 38)
    AUTO_CAST(search_btn)
    search_btn:SetImage("inven_s")
    search_btn:SetGravity(ui.RIGHT, ui.TOP)
    search_btn:SetEventScript(ui.LBUTTONUP, "characters_item_serch_item_search")

    local gb = frame:CreateOrGetControl("groupbox", "gb", 20, 120, frame:GetWidth() - 40, frame:GetHeight() - 135)
    gb:SetSkinName("test_frame_midle")
    AUTO_CAST(gb);

    local tree = gb:CreateOrGetControl("tree", 'tree', 0, 0, 0, 0)
    AUTO_CAST(tree)
    tree:Clear();
    tree:EnableDrawFrame(false)
    tree:SetFitToChild(true, 10)
    tree:SetFontName("white_16_ol");
    -- tree:SetTabWidth(80);

    characters_item_serch_build_tree(frame, tree, select_name)
end

function characters_item_serch_load_data(select_name)
    local dat_tbl = {string.format("../addons/%s/%s/warehouse.dat", addonNameLower, active_id),
                     string.format("../addons/%s/%s/inventory.dat", addonNameLower, active_id),
                     string.format("../addons/%s/%s/equips.dat", addonNameLower, active_id)}

    local function split(input, delimiter)
        local parts = {}
        for part in input:gmatch("([^" .. delimiter .. "]+)") do
            table.insert(parts, part)
        end
        return parts
    end

    local items = {}
    for _, dat_file_path in ipairs(dat_tbl) do
        for line in io.lines(dat_file_path) do
            local name = line:match("^(.-):::")
            local select_name = select_name == nil and g.login_name or select_name
            if name == select_name then
                local parts = {}
                local start = string.len(name) + 4 -- 「name:::」の長さをスキップ
                while true do
                    local s, e = string.find(line, ":::", start, true)
                    if not s then
                        local last_part = string.sub(line, start)
                        if last_part ~= "" then
                            table.insert(parts, last_part)
                        end
                        break
                    end
                    local part = string.sub(line, start, s - 1)
                    table.insert(parts, part)
                    start = e + 1
                end
                table.insert(items, parts)
            end
        end
    end
    return items
end

function characters_item_serch_get_sorted_sub_categories(items)
    local subcategories = {} -- サブカテゴリを保存するテーブル
    local subcategory_list = {}

    local subcategory_order = {
        ["false"] = 1,
        ["equips"] = 2,
        ["warehouse"] = 3,
        ["Weapon"] = 4,
        ["Armor"] = 5,
        ["HairAcc"] = 6,
        ["Accessory"] = 7,
        ["nil"] = 8,
        ["Premium"] = 9,
        ["Look"] = 10,
        ["ChangeEquip"] = 11,
        ["Misc"] = 12,
        ["Consume"] = 13,
        ["Recipe"] = 14,
        ["Card"] = 15,
        ["Gem"] = 16,
        ["Ancient"] = 17,
        ["OPTMisc"] = 18,
        ["PHousing"] = 19
    }

    local function get_order(name)
        local order = subcategory_order[name]
        if order == nil then
            return 100 -- デフォルト値を設定
        else
            return order
        end
    end

    for i = 1, #items do
        local item = items[i]
        local category = item[5]
        local sub_category = item[6]

        if category == "warehouse" or category == "equips" then
            if not subcategories[category] then
                subcategories[category] = true
                table.insert(subcategory_list, category)
            end
        elseif category == "inventory" then
            if not subcategories[sub_category] then
                subcategories[sub_category] = true
                table.insert(subcategory_list, sub_category)
            end
        end
    end

    local function sort_subcategories(a, b)
        return get_order(a) < get_order(b)
    end

    table.sort(subcategory_list, sort_subcategories)
    return subcategory_list
end

function characters_item_serch_build_tree(frame, tree, select_name)

    local items = characters_item_serch_load_data(select_name) -- データ読み込み
    local sub_category_list = characters_item_serch_get_sorted_sub_categories(items)

    local silver = 0
    for i = 1, #items do
        local item = items[i]
        local iesid = item[1]
        local item_count = item[3]
        if iesid == "0" then
            silver = item_count
            break
        end
    end

    -- ソートされたリストを使ってツリーを構築
    local iesids = {}
    for i = 1, #sub_category_list do
        local category = sub_category_list[i]
        local disp_category = category

        if disp_category == "false" then
            disp_category = "     " .. "{img icon_item_silver 20 20}" .. " " .. GET_COMMAED_STRING(tonumber(silver))
            tree:Add(disp_category)
        end
        if category ~= "false" then
            local new_slots = characters_item_serch_make_inven_slotset(tree, category)

            if disp_category == "warehouse" then
                disp_category = g.lang == "Japanese" and "倉庫" or "Warehouse"
            elseif disp_category == "equips" then
                disp_category = g.lang == "Japanese" and "装備中" or "Equips"
            elseif disp_category == "Ancient" then
                disp_category = g.lang == "Japanese" and "アシスター" or "Ancient"
            elseif disp_category == "nil" then
                disp_category = g.lang == "Japanese" and "レリック" or "Relic"
            elseif disp_category == "PHousing" then
                disp_category = g.lang == "Japanese" and "家具" or "Housing"
            else
                disp_category = ClMsg(category)
            end

            tree:Add(disp_category)
            tree:Add(new_slots, category)

            for i = 1, #items do
                local item = items[i]
                local iesid = item[1]
                local clsid = item[2]
                local item_count = item[3]
                local item_name = item[4]
                local cate = item[5]
                local sub_cate = item[6]

                if not iesids[iesid] then -- iesid が未登録の場合
                    if sub_cate == category or cate == category then
                        iesids[iesid] = true
                        characters_item_serch_insert_item_to_tree(new_slots, clsid, item_count)
                    end
                end
            end
        end
    end

    tree:Resize(frame:GetWidth() - 40, frame:GetHeight() - 135)
    tree:OpenNodeAll()
end

function characters_item_serch_insert_item_to_tree(new_slots, clsid, item_count)

    local slot_count = new_slots:GetSlotCount()
    local count = new_slots:GetUserIValue("SLOT_ITEM_COUNT") or 0

    while slot_count <= count do
        new_slots:ExpandRow()
        slot_count = new_slots:GetSlotCount()
    end

    local slot = new_slots:GetSlotByIndex(count)
    count = count + 1
    new_slots:SetUserValue("SLOT_ITEM_COUNT", count)
    slot:ShowWindow(1)

    local item_cls = GetClassByType('Item', clsid)
    if item_cls then

        slot:SetSkinName('invenslot2')
        SET_SLOT_ITEM_CLS(slot, item_cls)
        SET_SLOT_BG_BY_ITEMGRADE(slot, item_cls)
        if tonumber(item_count) > 1 then
            SET_SLOT_COUNT_TEXT(slot, item_count, "{ol}{s14}");
        end
    end
end

function characters_item_serch_make_inven_slotset(tree, name)

    local new_slotset = tree:CreateOrGetControl('slotset', name, 20, 0, 0, 0)
    tolua.cast(new_slotset, "ui::CSlotSet")

    new_slotset:EnablePop(0)
    new_slotset:EnableDrag(0)
    new_slotset:EnableDrop(0)
    new_slotset:SetMaxSelectionCount(999)
    new_slotset:SetSlotSize(40, 40)
    new_slotset:SetColRow(15, 1)
    new_slotset:SetSpc(0, 0)
    new_slotset:SetSkinName('invenslot')
    new_slotset:EnableSelection(0)
    new_slotset:CreateSlots()

    return new_slotset
end
