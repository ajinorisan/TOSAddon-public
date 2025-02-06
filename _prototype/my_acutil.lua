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

    local file_path = string.format("../addons/%s/mkdir.txt", addonNameLower)
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
