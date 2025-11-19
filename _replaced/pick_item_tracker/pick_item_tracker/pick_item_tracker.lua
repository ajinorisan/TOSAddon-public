-- v1.0.0 とりあえず作った。BetterPickQueueの簡易版。
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
            x = 330,
            y = 330
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

    pick_item_tracker_load_settings()

    local pc = GetMyPCObject()
    local current_map = GetZoneName(pc)
    if g.get_map_type() ~= "City" and g.get_map_type() ~= "Instance" then
        if not g.current_map or current_map ~= g.current_map then
            g.current_map = current_map
            addon:RegisterMsg('ITEM_PICK', 'pick_item_tracker_ITEMMSG_ITEM_COUNT')
            g.start_time = imcTime.GetAppTimeMS()
            g.y = 45
            g.x = 120
            g.items = {}
            pick_item_tracker_frame_init("is_timer")
        else
            addon:RegisterMsg('ITEM_PICK', 'pick_item_tracker_ITEMMSG_ITEM_COUNT')
            pick_item_tracker_frame_init()
        end
    else
        pick_item_tracker_frame_init("is_city")
        g.y = 45
        g.current_map = current_map
    end
end

function pick_item_tracker_frame_move(frame, ctrl, str, num)
    if g.settings.x ~= frame:GetX() or g.settings.y ~= frame:GetY() then
        g.settings.x = frame:GetX()
        g.settings.y = frame:GetY()
        pick_item_tracker_save_settings()
    end
end

function pick_item_tracker_frame_lock(frame)

    local itemlock = GET_CHILD(frame, "itemlock")
    if g.settings.move == 1 then
        g.settings.move = 0
        itemlock:SetGrayStyle(0);
        -- itemlock:ShowWindow(1)
    else
        g.settings.move = 1
        itemlock:SetGrayStyle(1);
    end
    local frame = ui.GetFrame("pick_item_tracker")
    AUTO_CAST(frame)
    frame:EnableMove(g.settings.move)
    pick_item_tracker_save_settings()

end

function pick_item_tracker_frame_init(msg)

    local frame = ui.GetFrame("pick_item_tracker")
    AUTO_CAST(frame)
    frame:EnableHitTest(1)
    frame:EnableHittestFrame(1)
    frame:EnableMove(g.settings.move)
    frame:SetPos(g.settings.x, g.settings.y)
    frame:SetTitleBarSkin("None")
    frame:SetSkinName("None")
    frame:SetLayerLevel(61)
    frame:SetEventScript(ui.LBUTTONUP, "pick_item_tracker_frame_move") -- !
    frame:SetEventScript(ui.RBUTTONUP, "pick_item_tracker_frame_lock") -- !

    local title_text = frame:CreateOrGetControl("richtext", "title_text", 20, 10)
    AUTO_CAST(title_text)
    title_text:SetText("{ol}{S10}Pick Item Tracker")
    title_text:SetTextTooltip("{ol}Right click to position lock")
    title_text:SetEventScript(ui.LBUTTONUP, "pick_item_tracker_frame_move") -- !
    title_text:SetEventScript(ui.RBUTTONUP, "pick_item_tracker_frame_lock") -- !

    local itemlock = frame:CreateOrGetControlSet('inv_itemlock', "itemlock", 0, 0);
    AUTO_CAST(itemlock)
    itemlock:SetGravity(ui.LEFT, ui.TOP);

    if g.settings.move == 1 then
        itemlock:SetGrayStyle(1)
    else
        itemlock:SetGrayStyle(0)
    end

    frame:Resize(120, g.y or 25)
    if msg == "is_city" then
        return
    end

    local gb = frame:CreateOrGetControl("groupbox", "gb", 0, 45, 90, frame:GetHeight() - 45)
    gb:SetSkinName("None")
    AUTO_CAST(gb);

    local count = 0
    local keys = {}
    for k in pairs(g.items) do
        table.insert(keys, k)
    end
    table.sort(keys) -- ソート

    if #keys > 0 then

        for i, k in ipairs(keys) do
            local v = g.items[k]
            local item_text = gb:CreateOrGetControl("richtext", "item_text" .. k, 5, count * 25)
            AUTO_CAST(item_text)
            count = count + 1
            local item_cls = GetClassByType("Item", v.cls_id)
            local color = pick_item_tracker_item_grade(item_cls)
            item_text:SetText("{img " .. item_cls.Icon .. " 20 20}" .. "{ol}{s15}{" .. color .. "}" ..
                                  dictionary.ReplaceDicIDInCompStr(k) .. "{/}{ol}{s14}{#00FF00}( + " .. v.item_count ..
                                  " )")

            if g.x < item_text:GetWidth() then
                g.x = item_text:GetWidth()
            end
        end
        g.y = count * 25 + 50
        frame:Resize(g.x + 15, g.y)
        gb:Resize(frame:GetWidth(), frame:GetHeight() - 45)
    end

    local time_text = frame:CreateOrGetControl("richtext", "time_text", 25, 25)
    AUTO_CAST(time_text)
    local timer = frame:CreateOrGetControl("timer", "addontimer", 0, 0);
    AUTO_CAST(timer)
    timer:SetUpdateScript("pick_item_tracker_timer_update");
    timer:Start(1.0);

    frame:ShowWindow(1)
end

function pick_item_tracker_timer_update(frame, timer)

    g.time = imcTime.GetAppTimeMS() - g.start_time
    local h = math.floor(g.time / (60 * 60 * 1000))
    local m = math.floor((g.time / (60 * 1000)) % 60)
    local s = math.floor((g.time / 1000) % 60)
    local time_text = GET_CHILD(frame, "time_text")
    time_text:SetText(string.format("{ol}{s14}%02d:%02d:%02d{/}", h, m, s))
end

function pick_item_tracker_item_grade(item_cls)

    local itemProp = geItemTable.GetProp(item_cls.ClassID);
    local grade = item_cls.ItemGrade;
    if (grade == 0) then
        return "#FFBF33";
    elseif (grade == 1) then
        return "#FFFFFF";
    elseif (grade == 2) then
        return "#108CFF";
    elseif (grade == 3) then
        return "#9F30FF";
    elseif (grade == 4) then
        return "#FF4F00";
    elseif (grade == 5) then
        return "#FFFF53";
    else
        return "#FFFFFF"
    end
end

function pick_item_tracker_frame_update(item_name, item_count, cls_id, new)
    local frame = ui.GetFrame("pick_item_tracker")
    local gb = GET_CHILD(frame, "gb")
    if new == "new" then
        gb:RemoveAllChild()
        local count = 0
        local keys = {}
        for k in pairs(g.items) do
            table.insert(keys, k)
        end
        table.sort(keys) -- ソート

        for i, k in ipairs(keys) do
            local v = g.items[k]
            local item_text = gb:CreateOrGetControl("richtext", "item_text" .. k, 5, count * 25)
            AUTO_CAST(item_text)
            count = count + 1
            local item_cls = GetClassByType("Item", v.cls_id)
            local color = pick_item_tracker_item_grade(item_cls)
            item_text:SetText("{img " .. item_cls.Icon .. " 20 20}" .. "{ol}{s15}{" .. color .. "}" ..
                                  dictionary.ReplaceDicIDInCompStr(k) .. "{/}{ol}{s14}{#00FF00}( + " .. v.item_count ..
                                  " )")

            if g.x < item_text:GetWidth() then
                g.x = item_text:GetWidth()
            end
        end
        g.y = count * 25 + 50
        frame:Resize(g.x + 15, g.y)
        gb:Resize(frame:GetWidth(), frame:GetHeight() - 45)
    else
        local item_text = GET_CHILD(gb, "item_text" .. item_name)

        local item_cls = GetClassByType("Item", cls_id)
        local color = pick_item_tracker_item_grade(item_cls)
        item_text:SetText("{img " .. item_cls.Icon .. " 20 20}" .. "{ol}{s15}{" .. color .. "}" ..
                              dictionary.ReplaceDicIDInCompStr(item_name) .. "{/}{ol}{s14}{#00FF00}( + " .. item_count ..
                              " )")
        frame:Resize(g.x + 15, g.y)
        gb:Resize(frame:GetWidth(), frame:GetHeight() - 45)
    end
end

function pick_item_tracker_ITEMMSG_ITEM_COUNT(frame, msg, cls_id, item_count)
    cls_id = tonumber(cls_id)
    local item_cls = GetClassByType("Item", cls_id)
    local item_name = item_cls.Name

    if not g.items[item_name] then
        g.items[item_name] = {
            cls_id = cls_id,
            item_count = item_count
        }
        pick_item_tracker_frame_update(item_name, item_count, cls_id, "new")
    else
        g.items[item_name].cls_id = cls_id
        g.items[item_name].item_count = g.items[item_name].item_count + item_count
        pick_item_tracker_frame_update(item_name, g.items[item_name].item_count, g.items[item_name].cls_id)
    end

end
