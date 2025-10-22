-- pick_item_tracker
local addon_name = "PICK_ITEM_TRACKER"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

g.active_id = session.loginInfo.GetAID()
g.settings_path = string.format("../addons/%s/%s/settings.json", addon_name_lower, g.active_id)
local json = require("json")

function g.setup_hook(my_func, origin_func_name)
    g.funcs = g.funcs or {}
    local func_name = string.gsub(origin_func_name, "%.", "");
    local upper = string.upper(func_name)
    local replace_name = upper .. "_BASE_" .. func_name
    local origin_func = _G[origin_func_name]
    if not _G[replace_name] then
        _G[replace_name] = origin_func
        _G[origin_func_name] = my_func
    end
    local hooked_func = _G[replace_name]
    g.funcs[origin_func_name] = hooked_func
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

    local folder = string.format("../addons/%s", addon_name_lower)
    local file_path = string.format("../addons/%s/mkdir.txt", addon_name_lower)
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

    local folder = string.format("../addons/%s/%s", addon_name_lower, g.active_id)
    local file_path = string.format("../addons/%s/%s/mkdir.txt", addon_name_lower, g.active_id)
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

function g.get_map_type()
    local pc = GetMyPCObject();
    local current_map = GetZoneName(pc)
    local map_cls = GetClass("Map", current_map)
    local map_type = map_cls.MapType
    return map_type
end

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

function pick_item_tracker_save_settings()
    g.saveJSON(g.settings_path, g.settings)
end

function pick_item_tracker_load_settings()

    local settings = g.loadJSON(g.settings_path)

    if not settings then
        settings = {
            move = 1,
            x = 200,
            y = 200
        }
    end

    g.settings = settings

    pick_item_tracker_save_settings()
end

function PICK_ITEM_TRACKER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()
    g.cid = session.GetMySession():GetCID()
    g.login_name = session.GetMySession():GetPCApc():GetName()

    local pc = GetMyPCObject();
    local current_map = GetZoneName(pc)

    if not g.current_map or current_map ~= g.current_map then
        g.current_map = current_map
        g.items = {}
    end

    if g.get_map_type() ~= "City" then
        g.current_map = current_map
        addon:RegisterMsg('ITEM_PICK', 'pick_item_tracker_ITEMMSG_ITEM_COUNT')
        pick_item_tracker_frame_init("is_timer")
    else
        pick_item_tracker_frame_init()
    end
end

function pick_item_tracker_frame_move(frame)

    if g.settings.x ~= frame:GetX() or g.settings.y ~= frame:GetY() then
        g.settings.x = frame:GetX()
        g.settings.y = frame:GetY()
        pick_item_tracker_save_settings()
    end
end

function pick_item_tracker_frame_lock(frame)

    if g.settings.move == 1 then
        g.settings.move = 0
    else
        g.settings.move = 1
    end
    pick_item_tracker_save_settings()
    pick_item_tracker_frame_init()
end

function pick_item_tracker_frame_init(msg)

    local frame = ui.GetFrame("pick_item_tracker")
    frame:RemoveAllChild()
    frame:Resize(0, 0)
    frame:EnableHitTest(1)
    frame:EnableMove(g.settings.move)
    frame:SetPos(g.settings.x, g.settings.y)
    frame:SetTitleBarSkin("None")
    frame:SetSkinName("None")
    frame:SetLayerLevel(11)
    frame:SetEventScript(ui.LBUTTONUP, "pick_item_tracker_frame_move") -- !
    frame:SetEventScript(ui.RBUTTONUP, "pick_item_tracker_frame_lock") -- !

    local title_text = frame:CreateOrGetControl("richtext", "title_text", 5, 5)
    AUTO_CAST(title_text)
    title_text:SetText("{ol}{S10}Pick Item Tracker")

    frame:Resize(title_text:GetWidth() + 30, title_text:GetHeight() + 10)

    if not msg then
        local time_text = frame:CreateOrGetControl("richtext", "time_text", 10, frame:GetHeight() + 5)
        AUTO_CAST(time_text)
        g.start_time = imcTime.GetAppTimeMS()
        local timer = GET_CHILD(frame, "addontimer");
        AUTO_CAST(timer)
        timer:Stop();
        timer:SetUpdateScript("pick_item_tracker_timer_update");
        timer:Start(1);
        frame:Resize(frame:GetWidth(), frame:GetHeight() + time_text:GetHeight() + 5)
    end

    local itemlock = frame:CreateOrGetControlSet('inv_itemlock', "itemlock", 0, 0);
    AUTO_CAST(itemlock)
    itemlock:SetGravity(ui.RIGHT, ui.TOP);
    if g.settings.move == 1 then
        itemlock:ShowWindow(1)
    else
        itemlock:ShowWindow(0)
    end
end

function pick_item_tracker_timer_update(frame, timer)

    g.time = imcTime.GetAppTimeMS() - g.start_time
    local h = math.floor(g.time / (60 * 60 * 1000))
    local m = math.floor((g.time / (60 * 1000)) % 60)
    local s = math.floor((g.time / 1000) % 60)
    local time_text = GET_CHILD(frame, "time_text")
    time_text:SetText(string.format("{ol}%02d:%02d:%02d{/}", h, m, s))
end

function pick_item_tracker_frame_update(item_name, item_count, cls_id)

    local frame = ui.GetFrame("pick_item_tracker")
    local item_text = frame:CreateOrGetControl("richtext", "item_text" .. item_name, 10, frame:GetHeight() + 5)
    AUTO_CAST(item_text)
    local item_cls = GetClassByType("Item", cls_id);
    item_text:SetText("img icon_" .. item_cls.Icon .. " 20 20" .. "{ol}" .. item_name .. ": " .. item_count)
    local x = frame:GetWidth()
    if x < item_text:GetWidth() then
        x = item_text:GetWidth()
    end
    frame:Resize(x, frame:GetHeight() + item_text:GetHeight() + 5)
end

function pick_item_tracker_ITEMMSG_ITEM_COUNT(frame, msg, cls_id, item_count)

    cls_id = tonumber(cls_id);
    local item_cls = GetClassByType("Item", cls_id);
    if item_cls.ClassName ~= "Vis" then
        return
    end

    local item_name = string.lower(dictionary.ReplaceDicIDInCompStr(item_cls.Name))

    local function sort_g_items(item_name, item_count)
        local keys = {}
        for k in pairs(g.items) do
            table.insert(keys, k)
        end

        table.sort(keys, function(a, b)
            return a < b
        end)

        for i, k in ipairs(keys) do
            local name = keys[i]
            local value = g.items[name]
            g.items[name] = value
        end
        pick_item_tracker_frame_update(item_name, item_count, cls_id)
    end

    if not g.items[item_name] then
        g.items[item_name] = item_count
        sort_g_items(item_name, item_count, cls_id)
    else
        g.items[item_name] = g.items[item_name] + item_count
        pick_item_tracker_frame_update(item_name, g.items[item_name] + item_count, cls_id)
    end

end
