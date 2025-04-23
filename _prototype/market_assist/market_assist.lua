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
        local str = json.encode(tbl)
        file:write(str)
        file:close()
    end
    g.save_json(g.settings_path, g.settings)
end

function g.load_settings()

    local function load_json(path)

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

    local settings = g.load_json(g.settings_path)

    if not settings then
        settings = {}
    end

    g.settings = settings
    g.save_settings()
end

function g.setup_hook_and_event(my_addon, origin_func_name, my_func_name, bool)

    if not g.FUNCS[origin_func_name] then
        g.FUNCS[origin_func_name] = _G[origin_func_name]
    end
    local origin_func = g.FUNCS[origin_func_name]
    local function hooked_function(...)

        local original_results
        local original_success = false

        if bool == true then
            original_results = {pcall(origin_func, ...)}
        end

        g.ARGS[origin_func_name] = {...}
        local b_success = pcall(imcAddOn.BroadMsg, origin_func_name)
        if bool == true and original_success then
            return table.unpack(original_results, 2, #original_results)
        else
            return
        end
    end

    _G[origin_func_name] = hooked_function
    pcall(my_addon.RegisterMsg, my_addon, origin_func_name, my_func_name)
end

function g.get_event_args(origin_func_name)
    local args = g.ARGS[origin_func_name]
    if args then
        return table.unpack(args)
    end
    return nil
end

function g.log_to_file(message)

    local file, err = io.open(g.log_file_path, "a")

    if file then
        local timestamp = os.date("[%Y-%m-%d %H:%M:%S] ")
        file:write(timestamp .. tostring(message) .. "\n")
        file:close()
    end
end

function market_assist_MARKET_LOAD_CATEGORY_OPTION(parent, ctrl, argStr)
    local frame = parent:GetTopParentFrame();
    local optionBox = GET_CHILD_RECURSIVELY(frame, 'optionBox');
    optionBox:ShowWindow(0);
    CHAT_SYSTEM("TEST")
    function g._MARKET_LOAD_CATEGORY_OPTION(frame, configKey)
        frame = frame:GetTopParentFrame();
        local configText = session.market.GetCategoryConfig(configKey);
        if configText == nil or configText == '' then
            return false;
        end

        -- parse
        local configList = StringSplit(configText, '@');
        local configTable = {};
        for i = 1, #configList do
            local config = configList[i];
            local idx = string.find(config, ':');
            if idx == nil then
                return false;
            end
            local propName = string.sub(config, 0, idx - 1);
            local propValue = string.sub(config, idx + 1);
            configTable[propName] = propValue;
        end

        -- set category
        local categoryStr = configTable['category'];
        local underBarIdx = string.find(categoryStr, '_');
        local category = categoryStr;
        local subCategory = '';
        if underBarIdx ~= nil then
            category = string.sub(categoryStr, 0, underBarIdx - 1);
            subCategory = string.sub(categoryStr, underBarIdx + 1);
        end
        if category == '' then
            category = 'IntegrateRetreive';
        end

        local categoryCtrlset = GET_CHILD_RECURSIVELY(frame, 'CATEGORY_' .. category);
        MARKET_CATEGORY_CLICK(categoryCtrlset, categoryCtrlset:GetChild('bgBox'), false, true);

        if subCategory ~= '' then
            local subCategoryCtrlset = GET_CHILD_RECURSIVELY(frame, 'SUB_CATE_' .. subCategory);
            if subCategoryCtrlset ~= nil then
                MARKET_SUB_CATEOGRY_CLICK(subCategoryCtrlset:GetParent(), subCategoryCtrlset, false);
            end
        end

        -- set price order
        local checkIdx = configTable['order'];
        local priceOrderCheck = GET_CHILD_RECURSIVELY(frame, 'priceOrderCheck_' .. checkIdx);
        priceOrderCheck:SetCheck(1);
        MARKET_UPDATE_PRICE_ORDER(frame, priceOrderCheck);

        -- set level range
        if configTable['CT_UseLv'] ~= nil or configTable['Level'] ~= nil then
            local levelRangeSet = GET_CHILD_RECURSIVELY(frame, 'levelRangeSet');
            if levelRangeSet ~= nil and levelRangeSet:IsVisible() == 1 then
                local rangeValue = configTable['CT_UseLv'];
                if configTable['Level'] ~= nil then
                    rangeValue = configTable['Level'];
                end
                local minValue, maxValue = GET_MINMAX_VALUE_BY_QUERY_STRING(rangeValue);
                local minEdit = GET_CHILD_RECURSIVELY(levelRangeSet, 'minEdit');
                local maxEdit = GET_CHILD_RECURSIVELY(levelRangeSet, 'maxEdit');
                minEdit:SetText(minValue);
                maxEdit:SetText(maxValue);
            end
        end

        -- set item grade	
        local gradeCheckSet = GET_CHILD_RECURSIVELY(frame, 'gradeCheckSet');
        if gradeCheckSet ~= nil then
            local gradeChildCnt = gradeCheckSet:GetChildCount(); -- init
            for i = 0, gradeChildCnt - 1 do
                local child = gradeCheckSet:GetChildByIndex(i);
                if string.find(child:GetName(), 'gradeCheck_') ~= nil then
                    AUTO_CAST(child);
                    child:SetCheck(0);
                end
            end
            if configTable['CT_ItemGrade'] ~= nil then
                if gradeCheckSet ~= nil and gradeCheckSet:IsVisible() == 1 then
                    local checkValue = configTable['CT_ItemGrade'];
                    local checkValueList = StringSplit(checkValue, ';');

                    -- set check
                    for i = 1, #checkValueList do
                        local gradeCheck = GET_CHILD(gradeCheckSet, 'gradeCheck_' .. checkValueList[i]);
                        gradeCheck:SetCheck(1);
                    end
                end
            end
        end

        -- set search text
        local itemSearchSet = GET_CHILD_RECURSIVELY(frame, 'itemSearchSet');
        local searchEdit = GET_CHILD_RECURSIVELY(itemSearchSet, 'searchEdit');
        searchEdit:SetText(configTable['searchText']);

        -- set appraisal check
        if configTable['Random_Item'] ~= nil then
            local appCheckSet = GET_CHILD_RECURSIVELY(frame, 'appCheckSet');
            if appCheckSet ~= nil and appCheckSet:IsVisible() == 1 then
                local configValue = tonumber(configTable['Random_Item']);
                local checkCtrl = nil;
                if configValue == 1 then
                    checkCtrl = GET_CHILD(appCheckSet, 'appCheck_1');
                elseif configValue == 2 then
                    checkCtrl = GET_CHILD(appCheckSet, 'appCheck_0');
                end
                if checkCtrl ~= nil then
                    checkCtrl:SetCheck(1);
                    MARKET_UPDATE_APPRAISAL_CHECK(checkCtrl:GetParent(), checkCtrl);
                end
            end
        end

        -- detail setting
        local detailOptionSet = GET_CHILD_RECURSIVELY(frame, 'detailOptionSet');
        if detailOptionSet ~= nil and detailOptionSet:IsVisible() == 1 then
            local added = false;
            for configName, configValue in pairs(configTable) do
                if IS_MARKET_DETAIL_SETTING_OPTION(configName) == true then
                    local selectSet = MARKET_ADD_SEARCH_DETAIL_SETTING(detailOptionSet);
                    local groupList = GET_CHILD(selectSet, 'groupList');
                    groupList:SelectItemByKey(configName);

                    local minValue, maxValue = GET_MINMAX_VALUE_BY_QUERY_STRING(configValue);
                    local minEdit, maxEdit = GET_CHILD_RECURSIVELY(selectSet, 'minEdit'),
                        GET_CHILD_RECURSIVELY(selectSet, 'maxEdit');
                    minEdit:SetText(minValue);
                    maxEdit:SetText(maxValue);

                    added = true;
                end
            end
            if added == false then
                ALIGN_OPTION_GROUP_SET(detailOptionSet);
            end
        end

        -- option group
        local optionGroupSet = GET_CHILD_RECURSIVELY(frame, 'optionGroupSet');
        if optionGroupSet ~= nil and optionGroupSet:IsVisible() == 1 then
            local added = false;
            for configName, configValue in pairs(configTable) do
                local isOptionGroup, group = IS_MARKET_SEARCH_OPTION_GROUP(configName);
                if isOptionGroup == true then
                    local selectSet = MARKET_ADD_SEARCH_OPTION_GROUP(optionGroupSet);
                    local groupList = GET_CHILD(selectSet, 'groupList');
                    groupList:SelectItemByKey(group);
                    MARKET_INIT_OPTION_GROUP_VALUE_DROPLIST(groupList:GetParent(), groupList);

                    local nameList = GET_CHILD(selectSet, 'nameList');
                    nameList:SelectItemByKey(configName);

                    local minValue, maxValue = GET_MINMAX_VALUE_BY_QUERY_STRING(configValue);
                    local minEdit, maxEdit = GET_CHILD_RECURSIVELY(selectSet, 'minEdit'),
                        GET_CHILD_RECURSIVELY(selectSet, 'maxEdit');
                    minEdit:SetText(minValue);
                    maxEdit:SetText(maxValue);

                    added = true;
                end
            end
            if added == false then
                ALIGN_OPTION_GROUP_SET(optionGroupSet);
            end
        end

        -- gem
        local gemOptionSet = GET_CHILD_RECURSIVELY(frame, 'gemOptionSet');
        if gemOptionSet ~= nil then
            if configTable['GemLevel'] ~= nil then
                local minValue, maxValue = GET_MINMAX_VALUE_BY_QUERY_STRING(configTable['GemLevel']);
                local minEdit, maxEdit = GET_CHILD_RECURSIVELY(selectSet, 'levelMinEdit'),
                    GET_CHILD_RECURSIVELY(selectSet, 'levelMaxEdit');
                minEdit:SetText(minValue);
                maxEdit:SetText(maxValue);
            end
            if configTable['CardLevel'] ~= nil then
                local minValue, maxValue = GET_MINMAX_VALUE_BY_QUERY_STRING(configTable['CardLevel']);
                local minEdit, maxEdit = GET_CHILD_RECURSIVELY(selectSet, 'levelMinEdit'),
                    GET_CHILD_RECURSIVELY(selectSet, 'levelMaxEdit');
                minEdit:SetText(minValue);
                maxEdit:SetText(maxValue);
            end
            if configTable['GemRoastingLv'] ~= nil then
                local minValue, maxValue = GET_MINMAX_VALUE_BY_QUERY_STRING(configTable['CardLevel']);
                local minEdit, maxEdit = GET_CHILD_RECURSIVELY(selectSet, 'levelMinEdit'),
                    GET_CHILD_RECURSIVELY(selectSet, 'levelMaxEdit');
                minEdit:SetText(minValue);
                maxEdit:SetText(maxValue);
            end
        end

        -- saveBtn
        local saveCheck = GET_CHILD_RECURSIVELY(frame, 'saveCheck');
        if saveCheck ~= nil then
            saveCheck:SetCheck(1);
        end

        ALIGN_ALL_CATEGORY(frame);
        MARKET_REQ_LIST(frame);
        return true;
    end
    g._MARKET_LOAD_CATEGORY_OPTION(frame, argStr);
end

function MARKET_ASSIST_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()
    g.cid = session.GetMySession():GetCID()
    g.login_name = session.GetMySession():GetPCApc():GetName()
    g.map_id = session.GetMapID()
    g.map_name = session.GetMapName();

    -- g.setup_hook_and_event(addon, "MARKET_LOAD_CATEGORY_OPTION", "market_assist_MARKET_LOAD_CATEGORY_OPTION", false)
end
