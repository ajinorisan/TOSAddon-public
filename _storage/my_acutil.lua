local addon_name = "ADDON_NAME"
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
    local addon_upper = string.upper(addon_name)
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

function g.save_json(path, tbl)
    local file = io.open(path, "w")
    local str = json.encode(tbl)
    file:write(str)
    file:close()
end

function g.load_json(path)

    local file = io.open(path, "r")

    if file then
        local content = file:read("*all")
        file:close()
        local table = json.decode(content)
        return table
    else
        return nil
    end
end

function g.save_settings()
    g.save_json(g.settings_path, g.settings)
end

function g.load_settings()

    local settings = g.load_json(g.settings_path)

    if not settings then
        settings = {
            x = 1000,
            y = 500,
            move = 1,
            hittest = 1,
            visible = 0
        }
    end

    g.settings = settings

    g.save_settings()
end

function ADDON_NAME_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()
    g.cid = session.GetMySession():GetCID()
    g.login_name = session.GetMySession():GetPCApc():GetName()

end

--[[xml
<?xml version="1.0" encoding="UTF-8"?>
<uiframe name="pick_item_tracker" x="0" y="0" width="0" height="0" create="open">
 <option visible="true" closebutton="false" autoopen="true" hideable="false"/>
 <input moveable="true" hittestframe="true"/>
  <controls>
    <timer name="addon_timer" rect="0 0 0 0" margin="0 0 0 0" layout_gravity="left top"/>
  </controls>
</uiframe>]]
