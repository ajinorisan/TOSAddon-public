function g.setup_event(my_addon, original_function_name, my_function_name)
    local function_name = string.gsub(original_function_name, "%.", "");
    local original_func = _G[original_function_name]

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

    _G[function_name_abs] = hooked_function
    my_addon:RegisterMsg(function_name, my_function_name);
end

function g.get_event_args(event_msg)
    return table.unpack(_G['ADDONS']['EVENTS']['ARGS'][event_msg]);
end

local base = {}
function g.setupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName

    local originalFunc = _G[baseFuncName] -- 元の関数を変数に格納

    if not _G[replacementName] then
        _G[replacementName] = originalFunc -- 元の関数を保存
        _G[baseFuncName] = func -- 元の関数を新しい関数で置き換え
    end

    local hookedFunc = _G[replacementName] -- 保存した元の関数を別変数に格納
    base[baseFuncName] = hookedFunc -- baseテーブルに保存

end
