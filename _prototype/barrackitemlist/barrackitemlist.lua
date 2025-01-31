local addonName = "BARRACKITEMLIST"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

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

function g.mkdir_new_folder()

    local file_path = string.format("../addons/%s/%s/mkdir.txt", addonNameLower, active_id)
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
g.mkdir_new_folder()

function g.saveJSON(path, tbl)
    local file, err = io.open(path, "w")
    if err then
        return _, err
    end

    local str = json.encode(tbl)
    file:write(str)
    file:close()
end

function g.loadJSON(path)

    local file, err = io.open(path, "r")
    local table = nil

    if (err) then
        return _, err
    else
        local content = file:read("*all")
        file:close()
        table = json.decode(content)
        return table
    end
end

function barrack_item_list_save_settings()
    g.saveJSON(settings_path, g.settings)
end

function barrack_item_list_load_settings()

    local settings = g.loadJSON(settings_path)
    if not settings then
        settings = {}
    end
    g.settings = settings
    barrack_item_list_save_settings()

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

function barrack_item_list_close(frame, ctrl, str, num)
    frame:ShowWindow(0)
end

function barrack_item_list_context()
    local context = ui.CreateContextMenu("arrack_item_list_context", "Barrack Item List", 0, 0, 200, 0)
    ui.AddContextMenuItem(context, "-----")

    for _, name in ipairs(g.chars) do
        local str_scp
        str_scp = string.format("barrack_item_list_char_switching('%s')", name)
        ui.AddContextMenuItem(context, name, str_scp)
    end

    ui.OpenContextMenu(context)
end

function barrack_item_list_open()
    local frame = ui.CreateNewFrame("notice_on_pc", "barrack_item_list", 0, 0, 0, 0)
    AUTO_CAST(frame)
    frame:SetSkinName("test_frame_low")
    frame:Resize(670, 1080)
    frame:SetPos(0, 0)
    frame:EnableMove(0)
    frame:SetLayerLevel(100)
    frame:RemoveAllChild()
    frame:ShowWindow(1)

    local title_gb = frame:CreateOrGetControl("groupbox", "title_gb", 0, 0, frame:GetWidth(), 55)
    title_gb:SetSkinName("test_frame_top")
    AUTO_CAST(title_gb)
    local title_text = title_gb:CreateOrGetControl("richtext", "title_text", 0, 0, ui.CENTER_HORZ, ui.TOP, 0, 15, 0, 0)
    AUTO_CAST(title_text);
    title_text:SetText('{ol}{s26}Barrack Item List')

    local close = frame:CreateOrGetControl("button", "close", 0, 0, 25, 25)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "barrack_item_list_close")

    local login_name = frame:CreateOrGetControl("richtext", "login_name", 20, 60, 0, 0)
    AUTO_CAST(login_name);
    login_name:SetText('{ol}{s18}' .. g.login_name)

    local char_switch = frame:CreateOrGetControl("button", "char_switch", 20, 85, 150, 30)
    AUTO_CAST(char_switch)
    char_switch:SetText(g.lang == "Japanese" and "{ol}キャラクター切替" or "{ol}character switch")
    char_switch:SetSkinName("test_pvp_btn")
    char_switch:SetEventScript(ui.LBUTTONUP, "barrack_item_list_context")

    local search_edit = frame:CreateOrGetControl("edit", "search_edit", 200, 80, 250, 40)
    AUTO_CAST(search_edit)
    search_edit:SetFontName("white_18_ol")
    search_edit:SetTextAlign("left", "center")
    search_edit:SetSkinName("inventory_serch")

    local search_btn = search_edit:CreateOrGetControl("button", "search_btn", 0, 0, 60, 38)
    AUTO_CAST(search_btn)
    search_btn:SetImage("inven_s")
    search_btn:SetGravity(ui.RIGHT, ui.TOP)

    local gb = frame:CreateOrGetControl("groupbox", "gb", 20, 120, frame:GetWidth() - 40, frame:GetHeight() - 130)
    gb:SetSkinName("test_frame_midle")
    AUTO_CAST(gb);

    local tree = gb:CreateOrGetControl("tree", 'inventree_All', 0, 0, frame:GetWidth() - 40, frame:GetHeight() - 130)
    AUTO_CAST(tree)
    tree:Clear();
    tree:EnableDrawFrame(false)
    tree:SetFitToChild(true, 60)
    tree:SetFontName("white_20_ol");
    tree:SetTabWidth(30);
    tree:OpenNodeAll();

    local dat_tbl = {string.format("../addons/%s/%s/warehouse.dat", addonNameLower, active_id),
                     string.format("../addons/%s/%s/inventory.dat", addonNameLower, active_id),
                     string.format("../addons/%s/%s/equips.dat", addonNameLower, active_id)}

    local items = {}
    for i, dat in ipairs(dat_tbl) do
        for line in io.lines(dat) do
            local name = line:match("^(.-):::")
            if name == g.login_name then
                local parts = {}
                for part in line:gmatch("([^:]+)") do
                    table.insert(parts, part)
                end
                if i == 1 then
                    parts[1] = 'warehouse'
                elseif i == 2 then
                    parts[1] = 'inventory'
                elseif i == 3 then
                    parts[1] = 'equips'
                end
                table.insert(items, parts)
            end
        end
    end

    for j = 1, #items do
        local item = items[j]
        local clsid = item[3]
        local iesid = item[2]
        local item_count = item[4]

        local item_cls = GetClassByType('Item', clsid)
        if item_cls ~= nil and item_cls.MarketCategory ~= "None" then
            local baseidcls = INV_GET_INVEN_BASEIDCLS_BY_ITEMGUID(iesid)
            if baseidcls then
                local typeStr = GET_INVENTORY_TREEGROUP(baseidcls)
                if baseidcls.ClassName ~= 'Unused' then
                    barrack_item_list_insert_item_to_tree(frame, tree, item_cls, baseidcls, typeStr, item_count, iesid)
                end
            end
        end
    end
end

function barrack_item_list_get_slotset_name(baseidcls)
    if not baseidcls then
        return 'error'
    end
    local className = baseidcls.MergedTreeTitle ~= "NO" and baseidcls.MergedTreeTitle or baseidcls.ClassName
    return 'sset_' .. className
end

function barrack_item_list_make_inven_slotset(tree, name)
    local newslotset = tree:CreateOrGetControl('slotset', name, 0, 0, 0, 0)
    tolua.cast(newslotset, "ui::CSlotSet")

    newslotset:EnablePop(0)
    newslotset:EnableDrag(0)
    newslotset:EnableDrop(0)
    newslotset:SetMaxSelectionCount(999)
    newslotset:SetSlotSize(54, 54)
    newslotset:SetColRow(10, 1)
    newslotset:SetSpc(0, 0)
    newslotset:SetSkinName('invenslot')
    newslotset:EnableSelection(0)
    newslotset:CreateSlots()
    ui.inventory.AddInvenSlotSetName(name)
    return newslotset
end

function barrack_item_list_inven_slotset_and_title(tree, treegroup, slotsetname, baseidcls)
    local slotsettitle = 'ssettitle_' ..
                             (baseidcls.MergedTreeTitle ~= "NO" and baseidcls.MergedTreeTitle or baseidcls.ClassName)
    local newSlotsname = MAKE_INVEN_SLOTSET_NAME(tree, slotsettitle, baseidcls.TreeSSetTitle)
    local newSlots = barrack_item_list_make_inven_slotset(tree, slotsetname)

    tree:Add(treegroup, newSlotsname, slotsettitle)
    local slotHandle = tree:Add(treegroup, newSlots, slotsetname)
    local slotNode = tree:GetNodeByTreeItem(slotHandle)
    slotNode:SetUserValue("IS_ITEM_SLOTSET", 1)
end

function barrack_item_list_insert_item_to_tree(frame, tree, item_cls, baseidcls, typeStr, item_count, iesid)
    local treegroupname = baseidcls.TreeGroup
    local treegroup = tree:FindByValue(treegroupname)

    if tree:IsExist(treegroup) == 0 then
        treegroup = tree:Add(baseidcls.TreeGroupCaption, baseidcls.TreeGroup)
        local treeNode = tree:GetNodeByTreeItem(treegroup)
        treeNode:SetUserValue("BASE_CAPTION", baseidcls.TreeGroupCaption)
    end

    local slotsetname = barrack_item_list_get_slotset_name(baseidcls)
    local slotsetnode = tree:FindByValue(treegroup, slotsetname)

    if tree:IsExist(slotsetnode) == 0 then
        barrack_item_list_inven_slotset_and_title(tree, treegroup, slotsetname, baseidcls)
    end

    local slotset = GET_CHILD_RECURSIVELY(tree, slotsetname, 'ui::CSlotSet')
    local slotCount = slotset:GetSlotCount()
    local cnt = slotset:GetUserIValue("SLOT_ITEM_COUNT") or 0

    -- スロット数を自動的に拡張
    while slotCount <= cnt do
        slotset:ExpandRow()
        slotCount = slotset:GetSlotCount()
    end

    local slot = slotset:GetSlotByIndex(cnt)
    cnt = cnt + 1
    slotset:SetUserValue("SLOT_ITEM_COUNT", cnt)
    slot:ShowWindow(1)

    -- アイテムをスロットに描画
    local function draw_item(item_cls, slot)
        slot:SetSkinName('invenslot2')
        local iconImg = GET_ITEM_ICON_IMAGE(item_cls)
        slot:SetHeaderImage('None')
        SET_SLOT_IMG(slot, iconImg)
        SET_SLOT_COUNT(slot, item_count)
        SET_SLOT_STYLESET(slot, item_cls)
        SET_SLOT_IESID(slot, iesid)
        slot:SetMaxSelectCount(item_count)
        local icon = slot:GetIcon()
        icon:SetTooltipArg("accountwarehouse", item_cls.ClassID, iesid)
        SET_ITEM_TOOLTIP_TYPE(icon, item_cls.ClassID, item_cls, "accountwarehouse")
        SET_SLOT_ICOR_CATEGORY(slot, item_cls)
    end

    draw_item(item_cls, slot)
end

function barrack_item_list_char_data()

    g.chars = {}
    local existing_names = {}

    for line in io.lines(inventory_dat) do
        local name = line:match("^(.-):::")
        if name and not existing_names[name] then
            table.insert(g.chars, name)
            existing_names[name] = true
        end
    end

end

function BARRACKITEMLIST_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()
    g.cid = session.GetMySession():GetCID()
    g.login_name = session.GetMySession():GetPCApc():GetName()

    barrack_item_list_load_settings()
    barrack_item_list_char_data()

    acutil.setupEvent(addon, 'GAME_TO_BARRACK', 'barrack_item_list_inventory_save_list')
    acutil.setupEvent(addon, 'GAME_TO_LOGIN', 'barrack_item_list_inventory_save_list')
    acutil.setupEvent(addon, 'DO_QUIT_GAME', 'barrack_item_list_inventory_save_list')
    acutil.setupEvent(addon, 'WAREHOUSE_CLOSE', 'barrack_item_list_warehouse_save_list')
    acutil.addSysIcon("barrackitemlist", "sysmenu_inv", "Barrack Item List", "barrack_item_list_open")
end

function barrack_item_list_warehouse_save_list(frame, msg)

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
            local item_name = string.lower(dictionary.ReplaceDicIDInCompStr(obj.Name));
            table.insert(items, {g.login_name, iesid, clsid, icon_info.count, item_name})
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
            local line = string.format("%s:::%s:::%d:::%d:::%s\n", item[1], item[2], item[3], item[4], item[5])
            file:write(line)
        end
        file:flush()
        file:close()
    end
end

function barrack_item_list_inventory_save_list(frame, msg)
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
        local item_name = string.lower(dictionary.ReplaceDicIDInCompStr(inv_obj.Name));
        table.insert(items, {g.login_name, guid, inv_clsid, inv_count, item_name})
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
            local line = string.format("%s:::%s:::%d:::%d:::%s\n", item[1], item[2], item[3], item[4], item[5])
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
                local item_name = string.lower(dictionary.ReplaceDicIDInCompStr(obj.Name))
                table.insert(items, {g.login_name, iesid, clsid, 1, item_name})
            end
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
            local line = string.format("%s:::%s:::%d:::%d:::%s\n", item[1], item[2], item[3], item[4], item[5])
            file:write(line)
        end
        file:flush()
        file:close()
    end
end
-- barrack_item_list_inventory_save_list(frame, msg)
-- barrack_item_list_inventory_save_list(frame, msg)
--[===[  setfenv is gone since Lua 5.2
-- copied from https://leafo.net/guides/setfenv-in-lua52-and-above.html
local setfenv = _G['setfenv']
if not setfenv then
    setfenv = function(fn, env)
        local i = 1
        while true do
            local name = debug.getupvalue(fn, i)
            if name == "_ENV" then
                debug.upvaluejoin(fn, i, (function()
                    return env
                end), 1)
                break
            elseif not name then
                break
            end

            i = i + 1
        end
        return fn
    end
end

-- referenced from http://d.hatena.ne.jp/Ko-Ta/20100830/p1
-- lua
-- テーブルシリアライズ
local function value2str(v)
    local vt = type(v);

    if (vt == "nil") then
        return "nil";
    end
    if (vt == "number") then
        return string.format("%d", v);
    end
    if (vt == "string") then
        return string.format('"%s"', v);
    end
    if (vt == "boolean") then
        if (v == true) then
            return "true";
        else
            return "false";
        end
    end
    if (vt == "function") then
        return '"*function"';
    end
    if (vt == "thread") then
        return '"*thread"';
    end
    if (vt == "userdata") then
        return '"*userdata"';
    end
    return '"UnsupportFormat"';
end

local function field2str(v)
    local vt = type(v);

    if (vt == "number") then
        return string.format("[%d]", v);
    end
    if (vt == "string") then
        return string.format("%s", v);
    end
    return 'UnknownField';
end

local function serialize(t)
    local f, v, buf;

    -- テーブルじゃない場合
    if not (type(t) == "table") then
        return value2str(t);
    end

    buf = "";
    f, v = next(t, nil);
    while f do
        -- ,を付加する
        if (buf ~= "") then
            buf = buf .. ",";
        end
        -- 値
        if (type(v) == "table") then
            buf = buf .. field2str(f) .. "=" .. serialize(v);
        else
            buf = buf .. field2str(f) .. "=" .. value2str(v);
        end
        -- 次の要素
        f, v = next(t, f);
    end

    buf = "{" .. buf .. "}";
    return buf;
end
local function loadfromfile_internal(path, dummy)
    local result, data = pcall(dofile, path)
    if (result) then
        return data
    else
        -- print("FAIL"..data)
        return dummy
    end
end
local function loadfromfile(path, dummy)
    local env = {
        dofile = dofile,
        pcall = pcall
    }
    local lff = loadfromfile_internal
    setfenv(lff, env)
    local result, data = pcall(lff, path, dummy)
    if (result) then
        return data
    else

        return dummy
    end
end
local function savetofile(path, data)
    local s = "return " .. serialize(data)
    -- CHAT_SYSTEM(tostring(#s))
    local fn = io.open(path, "w+")
    fn:write(s)
    fn:flush()
    fn:close()
end
local function treat(key)
    if (tonumber(key) ~= nil) then
        return "c" .. tostring(key)
    else
        return key
    end
end

local translationtable = {
    Unused = {
        jp = "シルバー",
        en = "Silver"
    },
    Weapon = {
        jp = "武器",
        en = "Weapon"
    },
    SubWeapon = {
        jp = "サブ武器",
        en = "SubWeapon"
    },
    Armor = {
        jp = "アーマー",
        en = "Armor"
    },
    Drug = {
        jp = "消費アイテム",
        en = "Consumable"
    },
    Recipe = {
        jp = "レシピ",
        en = "Recipe"
    },
    Material = {
        jp = "素材",
        en = "Material"
    },
    Gem = {
        jp = "ジェム",
        en = "Gem"
    },
    Card = {
        jp = "カード",
        en = "Card"
    },
    Collection = {
        jp = "コレクション",
        en = "Collection"
    },
    Quest = {
        jp = "クエスト",
        en = "Quest"
    },
    Event = {
        jp = "イベント",
        en = "Event"
    },
    Cube = {
        jp = "キューブ",
        en = "Cube"
    },
    Premium = {
        jp = "プレミアム",
        en = "Premium"
    },
    warehouse = {
        jp = "倉庫",
        en = "Storage"
    },

    SaveInventoryTip = {
        jp = "現在のキャラのインベントリを保存する",
        en = "Save the current character inventory"
    },
    SilverIs = {
        jp = "シルバー： ",
        en = "Silver: "
    },
    Inventory_2 = {
        jp = "インベントリ",
        en = "Inventory"
    },
    Warehouse_2 = {
        jp = "倉庫",
        en = "Storage"
    },
    SlotPerRow = {
        jp = "一行のスロット数",
        en = "Slots per line"
    },
    NodeOpen = {
        jp = "{s30}{#000000}始めからノードを展開する",
        en = "{s30}{#000000}All open"
    },
    ItemListTab = {
        jp = "アイテムリスト",
        en = "List"
    },
    SearchListTab = {
        jp = "アイテム検索",
        en = "Search"
    },
    SettingTab = {
        jp = "設定",
        en = "Settings"
    },
    btnDetete = {
        jp = "{@st41b}データ削除",
        en = "{@st41b}Delete"
    },
    warnDelete = {
        jp = "指定したキャラを一覧から削除します。{nl}" ..
            "(アイテムデータが入ったファイルは削除されません){nl}" .. "よろしいですか？",
        en = "This character is removed from the list." .. "(The item data file is not deleted.){nl} " ..
            " {nl} Proceed?"
    }

}

local function L_(str)
    if (option.GetCurrentCountry() == "Japanese") then
        return translationtable[str].jp
    else
        return translationtable[str].en
    end
end

function BARRACKITEMLIST_DBG_CLEANUP()
    g.itemlist = {}
    g.userlist = {}
end

g.userlist = loadfromfile(g.settingPath .. 'userlist_fl.lua', nil) or {}
g.warehouseList = loadfromfile(g.settingPath .. 'warehouse_fl.lua', nil) or {}
g.nodeList = {{"Unused", L_("Unused")}, {"Weapon", L_("Weapon")}, {"SubWeapon", L_("SubWeapon")},
              {"Armor", L_("Armor")}, {"Drug", L_("Drug")}, {"Recipe", L_("Recipe")}, {"Material", L_("Material")},
              {"Gem", L_("Gem")}, {"Card", L_("Card")}, {"Collection", L_("Collection")}, {"Quest", L_("Quest")},
              {"Event", L_("Event")}, {"Cube", L_("Cube")}, {"Premium", L_("Premium")}, {"warehouse", L_("warehouse")}}
g.setting = loadfromfile(g.settingPath .. 'setting_fl.lua', nil)
if not g.setting then
    g.setting = {}
    g.setting.col = 14
    g.setting.hideNode = {}
    g.setting.OpenNodeAll = false
    savetofile(g.settingPath .. 'setting_fl.lua', g.setting)
end

g.itemlist = g.itemlist or {}
for k, v in pairs(g.userlist) do
    if not g.itemlist[treat(k)] then
        g.itemlist[treat(k)] = loadfromfile(g.settingPath .. treat(k) .. '_fl.lua', nil)
    end
end

function OPEN_BARRACKITEMLIST()
    ui.ToggleFrame('barrackitemlist')
end

function BARRACKITEMLIST_ON_INIT(addon, frame)
    local cid = info.GetCID(session.GetMyHandle())
    g.userlist[treat(cid)] = info.GetPCName(session.GetMyHandle())
    savetofile(g.settingPath .. 'userlist_fl.lua', g.userlist)
    acutil.slashCommand('/itemlist', BARRACKITEMLIST_COMMAND)
    acutil.slashCommand('/il', BARRACKITEMLIST_COMMAND)

    acutil.setupEvent(addon, 'GAME_TO_BARRACK', 'BARRACKITEMLIST_SAVE_LIST')
    acutil.setupEvent(addon, 'GAME_TO_LOGIN', 'BARRACKITEMLIST_SAVE_LIST')
    acutil.setupEvent(addon, 'DO_QUIT_GAME', 'BARRACKITEMLIST_SAVE_LIST')
    acutil.setupEvent(addon, 'WAREHOUSE_CLOSE', 'BARRACKITEMLIST_SAVE_WAREHOUSE')
    -- acutil.setupEvent(addon, 'SELECT_CHARBTN_LBTNUP', 'SELECT_CHARBTN_LBTNUP_EVENT')

    -- addon:RegisterMsg('GAME_START_3SEC','BARRACKITEMLIST_CREATE_VAR_ICONS')
    acutil.addSysIcon("barrackitemlist", "sysmenu_inv", "Barrack Item List", "OPEN_BARRACKITEMLIST")
    BARRACKITEMLIST_PREPAREUSERLIST(frame)
    -- local droplist = tolua.cast(frame:GetChild("droplist"), "ui::CDropList");
    -- droplist:ClearItems()
    -- --droplist:AddItem(1,'None')
    -- for k,v in pairs(g.userlist) do
    --     droplist:AddItem(treat(k),"{s20}"..v.."{/}",0,'BARRACKITEMLIST_SHOW_LIST()');
    -- end
    tolua.cast(frame:GetChild('tab'), "ui::CTabControl"):SelectTab(0)
    frame:GetChild('saveBtn'):SetTextTooltip('現在のキャラのインベントリを保存する')
    BARRACKITEMLIST_CREATE_SETTINGMENU()
    BARRACKITEMLIST_TAB_CHANGE(frame)

    -- translation xml
    BARRACKITEMLIST_TRANSLATION(frame)

    frame:Invalidate()
    frame:ShowWindow(0)
    BARRACKITEMLIST_SAVE_LIST()
end
function BARRACKITEMLIST_PREPAREUSERLIST(frame)
    local droplist = tolua.cast(frame:GetChild("droplist"), "ui::CDropList");
    droplist:ClearItems()
    -- droplist:AddItem(1,'None')
    for k, v in pairs(g.userlist) do
        droplist:AddItem(treat(k), "{s20}" .. v .. "{/}", 0, 'BARRACKITEMLIST_SHOW_LIST()');
    end
end

function BARRACKITEMLIST_TRANSLATION(frame)
    if (frame == nil) then
        frame = ui.GetFrame("barrackitemlist")
    end
    GET_CHILD_RECURSIVELY(frame, "openNodeChbox"):SetText(L_("NodeOpen"))
    GET_CHILD_RECURSIVELY(frame, "slotColTxt"):SetText(L_("SlotPerRow"))
    local tc = GET_CHILD_RECURSIVELY(frame, "tab", "ui::CTabControl")
    tc:ClearItemAll()
    tc:AddItemWithName(L_("ItemListTab"), "ItemListTab")
    tc:AddItemWithName(L_("SearchListTab"), "SearchListTab")
    tc:AddItemWithName(L_("SettingTab"), "SettingTab")

end

-- function SELECT_CHARBTN_LBTNUP_EVENT(addonFrame, eventMsg)
--     local parent, ctrl, cid, argNum = acutil.getEventArgs(eventMsg);
--     BARRACKITEMLIST_SHOW_LIST(cid)
-- end

function BARRACKITEMLIST_TAB_CHANGE(frame, obj, argStr, argNum)
    local treeGbox = frame:GetChild('treeGbox')
    local droplist = frame:GetChild("droplist")
    local searchGbox = frame:GetChild('searchGbox')
    local settingGbox = frame:GetChild('settingGbox')
    local tabObj = tolua.cast(frame:GetChild('tab'), "ui::CTabControl");
    local tabIndex = tabObj:GetSelectItemIndex();

    if (tabIndex == 0) then
        treeGbox:ShowWindow(1)
        droplist:ShowWindow(1)
        searchGbox:ShowWindow(0)
        settingGbox:ShowWindow(0)
        BARRACKITEMLIST_SHOW_LIST()
        BARRACKITEMLIST_SAVE_SETTINGMENU()
    elseif (tabIndex == 1) then
        treeGbox:ShowWindow(0)
        droplist:ShowWindow(0)
        searchGbox:ShowWindow(1)
        settingGbox:ShowWindow(0)
        BARRACKITEMLIST_SAVE_SETTINGMENU()
        BARRACKITEMLIST_SHOW_SEARCH_ITEMS()
    else
        treeGbox:ShowWindow(0)
        droplist:ShowWindow(0)
        searchGbox:ShowWindow(0)
        settingGbox:ShowWindow(1)
    end
end

function BARRACKITEMLIST_COMMAND(command)
    BARRACKITEMLIST_CREATE_SETTINGMENU()
    ui.ToggleFrame('barrackitemlist')
end

function BARRACKITEMLIST_SAVE_LIST()
    local list = {}
    session.BuildInvItemSortedList()
    local invItemList = session.GetInvItemSortedList();

    for i = 1, invItemList:size() - 1 do
        local invItem = invItemList:at(i);
        if invItem ~= nil then
            local obj = GetIES(invItem:GetObject());
            list[obj.GroupName] = list[obj.GroupName] or {}
            table.insert(list[obj.GroupName], GetItemData(obj, invItem))
        end
    end
    local cid = info.GetCID(session.GetMyHandle())
    savetofile(g.settingPath .. treat(cid) .. '_fl.lua', list)
    g.itemlist[treat(cid)] = list
end

function BARRACKITEMLIST_SHOW_LIST(cid)
    local frame = ui.GetFrame('barrackitemlist')
    frame:ShowWindow(1)
    local gbox = GET_CHILD(frame, 'treeGbox', 'ui::CGroupBox');
    local droplist = GET_CHILD(frame, 'droplist', "ui::CDropList")
    if not cid then
        cid = droplist:GetSelItemKey()
    end
    for k, v in pairs(g.userlist) do

        local child = gbox:GetChild("tree" .. treat(k))
        if child then
            child:ShowWindow(0)
        end
    end
    local list = g.itemlist[treat(cid)]
    if not list then
        list, e = loadfromfile(g.settingPath .. treat(cid) .. '_fl.lua', {})
        if (e) then
            return
        end
    end
    g.warehouseList[treat(cid)] = g.warehouseList[treat(cid)] or {}
    list.warehouse = g.warehouseList[treat(cid)].warehouse or {};
    local tree = gbox:CreateOrGetControl('tree', 'tree' .. treat(cid), 25, 50, 545, 0)
    -- if tree:GetUserValue('exist_data') ~= '1' then
    -- tree:SetUserValue('exist_data',1) 
    tolua.cast(tree, 'ui::CTreeControl')
    tree:ResizeByResolutionRecursively(1)
    tree:Clear()
    tree:EnableDrawFrame(true);
    tree:SetFitToChild(true, 60);
    tree:SetFontName("white_20_ol");
    local nodeName, parentCategory
    local slot, slotset, icon
    local nodeList = g.nodeList
    for i, value in ipairs(nodeList) do
        local nodeItemList = list[value[1]]
        if nodeItemList and not g.setting.hideNode[i] then
            if value[1] == "Unused" then
                tree:Add(L_("SilverIs") .. acutil.addThousandsSeparator(nodeItemList[1][2]));
            else
                tree:Add(value[2]);
                parentCategory = tree:FindByCaption(value[2]);
                slotset = BARRACKITEMLIST_MAKE_SLOTSET(tree, value[1])
                tree:Add(parentCategory, slotset, 'slotset_' .. value[1]);
                for i, v in ipairs(nodeItemList) do
                    slot = slotset:GetSlotByIndex(i - 1)
                    slot:SetText(string.format('{s14}{#f0dcaa}{b}{ol}%s', v[2]))
                    slot:SetTextMaxWidth(1000)
                    icon = CreateIcon(slot)
                    icon:SetImage(v[3])
                    icon:SetTextTooltip(string.format("%s : %s", v[1], v[2]))
                    if (i % g.setting.col) == 0 then
                        slotset:ExpandRow()
                    end
                end
            end
        end
        -- end
    end
    if g.setting.OpenNodeAll then
        tree:OpenNodeAll()
    end

    tree:ShowWindow(1)
    frame:ShowWindow(1)

    frame:EnableResize(1)
    tree:Invalidate()

    local btnDetete = gbox:CreateOrGetControl("button", "btnDelete", gbox:GetWidth() - 160, 0, 120, 40)
    tolua.cast(btnDetete, "ui::CButton")
    btnDetete:SetClickSound("button_click_big")
    btnDetete:SetOverSound("button_over")
    btnDetete:SetSkinName("test_red_button")
    btnDetete:SetText("{@st41b}" .. L_("btnDetete"))
    btnDetete:SetEventScript(ui.LBUTTONUP, "BARRACKITEMLIST_DELETE_CHARACTERDATA")
    btnDetete:SetEventScriptArgString(ui.LBUTTONUP, cid)

end
function BARRACKITEMLIST_DELETE_CHARACTERDATA(frame, ctrl, argstr, argnum)
    g.deletecharacid = argstr
    WARNINGMSGBOX_FRAME_OPEN(L_("warnDelete"), 'BARRACKITEMLIST_DO_DELETE_CHARACTERDATA', 'None');
end
function BARRACKITEMLIST_DO_DELETE_CHARACTERDATA()
    -- キャラクタデータの削除を試みる
    local frame = ui.GetFrame('barrackitemlist')
    local gbox = GET_CHILD(frame, 'treeGbox', 'ui::CGroupBox');

    for k, v in pairs(g.userlist) do

        local child = gbox:GetChild("tree" .. treat(k))
        if child then
            child:ShowWindow(0)
        end
    end
    g.userlist[g.deletecharacid] = nil;
    savetofile(g.settingPath .. 'userlist_fl.lua', g.userlist)
    -- リスト再構築
    BARRACKITEMLIST_PREPAREUSERLIST(ui.GetFrame("barrackitemlist"))
    BARRACKITEMLIST_SHOW_LIST()
end
function BARRACKITEMLIST_MAKE_SLOTSET(tree, name)
    local col = g.setting.col
    local slotsize = math.floor(tree:GetWidth() / (col + 1))
    local slotsetTitle = 'slotset_titile_' .. name
    local newslotset = tree:CreateOrGetControl('slotset', 'slotset_' .. name, 0, 0, 0, 0)
    tolua.cast(newslotset, "ui::CSlotSet");

    newslotset:EnablePop(0)
    newslotset:EnableDrag(0)
    newslotset:EnableDrop(0)
    newslotset:SetMaxSelectionCount(999)
    newslotset:SetSlotSize(slotsize, slotsize);
    newslotset:SetColRow(col, 1)
    newslotset:SetSpc(0, 0)
    newslotset:SetSkinName('invenslot2')
    newslotset:EnableSelection(0)
    newslotset:ResizeByResolutionRecursively(1)
    newslotset:CreateSlots()
    return newslotset;
end

function BARRACKITEMLIST_SEARCH_ITEMS(itemlist, itemName, iswarehouse)

    local items = {}
    for cid, name in pairs(g.userlist) do
        if itemlist[treat(cid)] then
            for group, list in pairs(itemlist[treat(cid)]) do
                if group ~= 'warehouse' or iswarehouse then
                    for i, v in ipairs(list) do

                        if string.find(string.lower(v[1]), string.lower(itemName)) then
                            items[treat(cid)] = items[treat(cid)] or {}
                            table.insert(items[treat(cid)], v)
                        end
                    end
                end
            end
        end
    end
    return items
end

function BARRACKITEMLIST_SHOW_SEARCH_ITEMS(frame, obj, argStr, argNum)
    local frame = ui.GetFrame('barrackitemlist')
    local searchGbox = frame:GetChild('searchGbox')
    local editbox = tolua.cast(searchGbox:GetChild('searchEdit'), "ui::CEditControl");
    local tree = searchGbox:CreateOrGetControl('tree', 'saerchTree', 25, 50, 545, 0)
    tolua.cast(tree, 'ui::CTreeControl')
    tree:ResizeByResolutionRecursively(1)
    tree:Clear()
    tree:EnableDrawFrame(true);
    tree:SetFitToChild(true, 60);
    tree:SetFontName("white_20_ol");
    if editbox:GetText() == '' or not editbox:GetText() then
        return
    end
    local invItems = BARRACKITEMLIST_SEARCH_ITEMS(g.itemlist, editbox:GetText(), false)
    local warehouseItems = BARRACKITEMLIST_SEARCH_ITEMS(g.warehouseList, editbox:GetText(), true)
    tree:Add(L_("Inventory_2"))
    _BARRACKITEMLIST_SEARCH_ITEMS(tree, invItems, '_i')
    tree:Add(L_("Warehouse_2"))
    _BARRACKITEMLIST_SEARCH_ITEMS(tree, warehouseItems, '_w')
    tree:OpenNodeAll()
    tree:ShowWindow(1)
end

function _BARRACKITEMLIST_SEARCH_ITEMS(tree, items, type)
    local nodeName, parentCategory
    local slot, slotset, icon
    for k, value in pairs(items) do
        tree:Add(g.userlist[k] .. type);
        parentCategory = tree:FindByCaption(g.userlist[k] .. type);
        slotset = BARRACKITEMLIST_MAKE_SLOTSET(tree, k .. type)
        tree:Add(parentCategory, slotset, 'slotset_' .. k .. type);
        for i, v in ipairs(value) do
            slot = slotset:GetSlotByIndex(i - 1)
            slot:SetText(string.format('{s14}{#f0dcaa}{b}{ol}%s', v[2]))
            slot:SetTextAlign(30, 30)
            -- slot:SetTextMaxWidth(1000)
            icon = CreateIcon(slot)
            icon:SetImage(v[3])
            icon:SetTextTooltip(string.format("%s : %s", v[1], v[2]))
            if (i % g.setting.col) == 0 then
                slotset:ExpandRow()
            end
        end
    end

end

function BARRACKITEMLIST_SAVE_WAREHOUSE()
    local frame = ui.GetFrame('warehouse')
    local slotset = frame:GetChild("gbox"):GetChild('slotset')
    tolua.cast(slotset, 'ui::CSlotSet')
    local items = {}
    local slot, item
    for i = 0, slotset:GetSlotCount() - 1 do
        slot = slotset:GetSlotByIndex(i)
        item = GetItemData(GetObjBySlot(slot))
        if item then
            table.insert(items, item)
        end
    end
    local cid = tostring(info.GetCID(session.GetMyHandle()))
    g.warehouseList[treat(cid)] = {}
    g.warehouseList[treat(cid)].warehouse = items
    savetofile(g.settingPath .. 'warehouse_fl.lua', g.warehouseList)
end

function GetItemData(obj, item)
    if not obj then
        return
    end
    local itemName = dictionary.ReplaceDicIDInCompStr(obj.Name)
    local itemCount = item.count
    local iconImg = obj.Icon
    if obj.GroupName == 'Gem' or obj.GroupName == 'Card' then
        itemCount = 'Lv' .. GET_ITEM_LEVEL(obj)
    end
    if obj.ItemType == 'Equip' and obj.ClassType == 'Outer' then
        local tempiconname = string.sub(obj.Icon, string.len(obj.Icon) - 1);
        if tempiconname ~= "_m" and tempiconname ~= "_f" then
            if gender == nil then
                gender = GetMyPCObject().Gender;
            end
            if gender == 1 then
                iconImg = iconImg .. "_m"
            else
                iconImg = iconImg .. "_f"
            end
        end
    end
    return {itemName, itemCount, iconImg}
end

function GetObjBySlot(slot)
    local icon = slot:GetIcon()
    if not icon then
        return
    end
    local info = icon:GetInfo()
    local IESID = info:GetIESID()
    return GetObjectByGuid(IESID), info, IESID
end

function BARRACKITEMLIST_CREATE_SETTINGMENU()
    local frame = ui.GetFrame('barrackitemlist')
    local settingGbox = frame:GetChild('settingGbox')
    local hideNodeGbox = settingGbox:GetChild('hideNodeGbox')

    -- create slotsize droplist
    local droplist = tolua.cast(settingGbox:GetChild("slotColDList"), "ui::CDropList");
    droplist:ClearItems()
    for i = 7, 14 do
        droplist:AddItem(i, "{s20}" .. i .. "{/}");
    end
    droplist:SelectItemByKey(g.setting.col)

    -- create hide node list
    local checkbox
    for i = 1, #g.nodeList do
        checkbox = hideNodeGbox:CreateOrGetControl('checkbox', 'checkbox' .. i, 30, i * 30, 200, 30)
        tolua.cast(checkbox, 'ui::CCheckBox')
        checkbox:SetText('{s30}{#000000}' .. g.nodeList[i][2])
        if not g.setting.hideNode[i] then
            checkbox:SetCheck(1)
        end
    end
    checkbox = tolua.cast(settingGbox:GetChild('openNodeChbox'), 'ui::CCheckBox')
    if g.setting.OpenNodeAllthen then
        checkbox:SetCheck(1)
    end

end

function BARRACKITEMLIST_SAVE_SETTINGMENU()
    local frame = ui.GetFrame('barrackitemlist')
    local settingGbox = frame:GetChild('settingGbox')
    local hideNodeGbox = settingGbox:GetChild('hideNodeGbox')
    -- save slotsize droplist
    local droplist = tolua.cast(settingGbox:GetChild("slotColDList"), "ui::CDropList");
    g.setting.col = droplist:GetSelItemKey()
    -- save hide node list
    local checkbox
    for i = 1, #g.nodeList do
        checkbox = tolua.cast(hideNodeGbox:GetChild('checkbox' .. i), 'ui::CCheckBox')
        if checkbox:IsChecked() ~= 1 then
            g.setting.hideNode[i] = true
        else
            g.setting.hideNode[i] = false
        end
    end

    checkbox = tolua.cast(settingGbox:GetChild('openNodeChbox'), 'ui::CCheckBox')
    if checkbox:IsChecked() == 1 then
        g.setting.OpenNodeAll = true
    else
        g.setting.OpenNodeAll = false
    end
    savetofile(g.settingPath .. 'setting_fl.lua', g.setting)
end

function BARRACKITEMLIST_CREATE_VAR_ICONS()
    local frame = ui.GetFrame("sysmenu");
    if false == VARICON_VISIBLE_STATE_CHANTED(frame, "necronomicon", "necronomicon") and false ==
        VARICON_VISIBLE_STATE_CHANTED(frame, "grimoire", "grimoire") and false ==
        VARICON_VISIBLE_STATE_CHANTED(frame, "guild", "guild") and false ==
        VARICON_VISIBLE_STATE_CHANTED(frame, "poisonpot", "poisonpot") then
        return;
    end

    DESTROY_CHILD_BY_USERVALUE(frame, "IS_VAR_ICON", "YES");

    local extraBag = frame:GetChild('extraBag');
    local status = frame:GetChild("status");
    local offsetX = status:GetX() - extraBag:GetX();
    local rightMargin = extraBag:GetMargin().right + offsetX;

    rightMargin = SYSMENU_CREATE_VARICON(frame, extraBag, "guild", "guild", "sysmenu_guild", rightMargin, offsetX,
                                         "Guild");
    rightMargin = SYSMENU_CREATE_VARICON(frame, extraBag, "necronomicon", "necronomicon", "sysmenu_card", rightMargin,
                                         offsetX);
    rightMargin =
        SYSMENU_CREATE_VARICON(frame, extraBag, "grimoire", "grimoire", "sysmenu_neacro", rightMargin, offsetX);
    rightMargin = SYSMENU_CREATE_VARICON(frame, extraBag, "poisonpot", "poisonpot", "sysmenu_wugushi", rightMargin,
                                         offsetX);
    if _G["EXPCARDCALCULATOR"] then
        rightMargin = SYSMENU_CREATE_VARICON(frame, status, "expcardcalculator", "expcardcalculator",
                                             "addonmenu_expcard", rightMargin, offsetX, "Experience Card Calculator") or
                          rightMargin
    end
    rightMargin = SYSMENU_CREATE_VARICON(frame, status, "barrackitemlist", "barrackitemlist", "sysmenu_inv",
                                         rightMargin, offsetX, "barrack item list");
    local expcardcalculatorButton = GET_CHILD(frame, "expcardcalculator", "ui::CButton");
    if expcardcalculatorButton ~= nil then
        expcardcalculatorButton:SetTextTooltip("{@st59}expcardcalculator");
    end

    local barrackitemlistButton = GET_CHILD(frame, "barrackitemlist", "ui::CButton");
    if barrackitemlistButton ~= nil then
        barrackitemlistButton:SetTextTooltip("{@st59}barrackitemlist");
    end
end]===]
