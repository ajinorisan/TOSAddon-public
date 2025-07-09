local addon_name = "MARKET_ASSIST"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]
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
end
g.mkdir_new_folder()

function g.get_map_type()
    local map_name = session.GetMapName()
    local map_cls = GetClass("Map", map_name)
    local map_type = map_cls.MapType
    return map_type
end

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

function market_assist_load_settings()
    local settings = g.load_json(g.settings_path)

    if not settings then
        settings = {
            frame_x = 10,
            frame_y = 10,
            favorites = {}
        }
    end

    g.settings = settings
    g.save_settings()
end

function MARKET_ASSIST_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    g.REGISTER = {}

    g.lang = option.GetCurrentCountry()
    g.cid = session.GetMySession():GetCID()
    g.login_name = session.GetMySession():GetPCApc():GetName()
    g.map_id = session.GetMapID()
    g.map_name = session.GetMapName();

    addon:RegisterMsg("OPEN_DLG_MARKET", "market_assist_ON_OPEN_MARKET")
    -- g.setup_hook_and_event(addon, "MARKET_LOAD_CATEGORY_OPTION", "market_assist_MARKET_LOAD_CATEGORY_OPTION", false)
end

function market_assist_ON_OPEN_MARKET()
    local market = ui.GetFrame("market")
    local open_btn = market:CreateOrGetControl("button", "open_btn", 610, 120, 100, 30)
    AUTO_CAST(open_btn)
    open_btn:SetSkinName("tab2_btn")
    local text = g.lang ~= "Japanese" and "{@st66b18}お気に入り" or "{@st66b18}Favorites"
    open_btn:SetText(text)
    open_btn:SetEventScript(ui.LBUTTONUP, "market_assist_open_slotset")
end

function market_assist_close_slotset(frame, ctrl)
    local favorite_items = ui.GetFrame(addon_name_lower .. "favorite_items")
    favorite_items:ShowWindow(0)
end

function market_assist_drop_slotset(frame, slot)
    local lift_icon = ui.GetLiftIcon()
    local icon_info = lift_icon:GetInfo()
    local inv_item = GET_ITEM_BY_GUID(icon_info:GetIESID())

    if icon_info == nil or slot == nil or inv_item == nil then
        return
    end
    local lift_parent = lift_icon:GetParent()

    local item_obj = GetIES(inv_item:GetObject())
    local item_cls = GetClassByType("Item", item_obj.ClassID)
    if not item_cls then
        return
    end

    SET_SLOT_ITEM_CLS(slot, item_cls)
    SET_SLOT_STYLESET(slot, item_cls)

end

function market_assist_open_slotset(frame, ctrl)

    local inventory = ui.GetFrame("inventory")
    local favorite_items = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "favorite_items", 0, 0, 0, 0)
    AUTO_CAST(favorite_items)
    favorite_items:SetSkinName("test_frame_low")
    favorite_items:SetPos(inventory:GetX(), 0)
    favorite_items:SetLayerLevel(100)
    favorite_items:Resize(510, 390)
    favorite_items:EnableHittestFrame(1)
    favorite_items:EnableMove(1)
    favorite_items:RemoveAllChild()

    local close = favorite_items:CreateOrGetControl("button", "close", 0, 0, 25, 25)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "market_assist_close_slotset")

    local gbox = favorite_items:CreateOrGetControl("groupbox", " gbox", 10, 40, 0, 0)
    AUTO_CAST(gbox)
    gbox:SetSkinName("test_frame_midle_light")
    gbox:Resize(490, 340)
    favorite_items:ShowWindow(1)

    local favorite_slotset = gbox:CreateOrGetControl('slotset', 'favorite_slotset', 5, 3, 0, 0)
    AUTO_CAST(favorite_slotset);
    favorite_slotset:SetSlotSize(40, 40)
    favorite_slotset:EnablePop(1)
    favorite_slotset:EnableDrag(1)
    favorite_slotset:EnableDrop(1)
    favorite_slotset:SetEventScript(ui.DROP, "market_assist_drop_slotset")

    favorite_slotset:SetColRow(12, 8)
    favorite_slotset:SetSpc(0, 2)
    favorite_slotset:SetSkinName('invenslot2')

    favorite_slotset:CreateSlots()
    --[[local slotcount = favorite_slotset:GetSlotCount()

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
    end]]
end
