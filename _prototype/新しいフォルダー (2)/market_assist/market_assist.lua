local addon_name = "ADDON_NAME"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.0.0"
--
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

function ADDON_NAME_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()
    g.cid = session.GetMySession():GetCID()
    g.login_name = session.GetMySession():GetPCApc():GetName()

    market_assist_load_settings()

    g.setup_hook(market_assist_MARKET_FIND_PAGE, "MARKET_FIND_PAGE")

end

function market_assist_MARKET_MARKET_FIND_PAGE(frame, page)
    market_assist_MARKET_MARKET_FIND_PAGE_(frame, page)
end

function market_assist_MARKET_MARKET_FIND_PAGE_(frame, page)

    local function CLAMP_MARKET_PAGE_NUMBER(frame, pageControllerName, page)
        if page == nil then
            return 0;
        end
        local pagecontrol = GET_CHILD(frame, pageControllerName);
        local MaxPage = pagecontrol:GetMaxPage();
        if page >= MaxPage then
            page = MaxPage - 1;
        elseif page <= 0 then
            page = 0;
        end
        return page;
    end

    page = CLAMP_MARKET_PAGE_NUMBER(frame, 'pagecontrol', page);

    local function GET_SEARCH_PRICE_ORDER(frame)
        local priceOrderCheck_0 = GET_CHILD_RECURSIVELY(frame, 'priceOrderCheck_0');
        local priceOrderCheck_1 = GET_CHILD_RECURSIVELY(frame, 'priceOrderCheck_1');
        if priceOrderCheck_0 == nil or priceOrderCheck_1 == nil then
            return -1;
        end

        if priceOrderCheck_0:IsChecked() == 1 then
            return 0;
        end
        if priceOrderCheck_1:IsChecked() == 1 then
            return 1;
        end
        return 0; -- default
    end
    local orderByDesc = GET_SEARCH_PRICE_ORDER(frame);
    if orderByDesc < 0 then
        return;
    end

    local function GET_SEARCH_TEXT(frame)
        local defaultValue = '';
        local market_search = GET_CHILD_RECURSIVELY(frame, 'itemSearchSet');
        if market_search ~= nil and market_search:IsVisible() == 1 then
            local searchEdit = GET_CHILD_RECURSIVELY(market_search, 'searchEdit');
            local findItem = searchEdit:GetText();
            searchEdit:Focus()
            local minLength = 0;
            local findItemStrLength = findItem.len(findItem);
            local maxLength = 60;
            if config.GetServiceNation() == "GLOBAL" then
                minLength = 1;
                maxLength = 20;
            elseif config.GetServiceNation() == "JPN" then
                maxLength = 60;
            elseif config.GetServiceNation() == "KOR" or config.GetServiceNation() == "GLOBAL_KOR" then
                maxLength = 60;
            end
            if findItemStrLength ~= 0 then -- 있다면 길이 조건 체크
                if findItemStrLength <= minLength then
                    ui.SysMsg(ClMsg("InvalidFindItemQueryMin"));
                    return defaultValue;
                elseif findItemStrLength > maxLength then
                    ui.SysMsg(ClMsg("InvalidFindItemQueryMax"));
                    return defaultValue;
                end
            end
            return findItem;
        end
        return defaultValue;
    end
    local searchText = GET_SEARCH_TEXT(frame);
    local category, _category, _subCategory = GET_CATEGORY_STRING(frame);
    if category == '' and searchText == '' then
        return;
    end

    --[[if searchText ~= '' and ui.GetPaperLength(searchText) < 2 then
        ui.SysMsg(ClMsg('InvalidFindItemQueryMin'));
        return;
    end]]

    local function GET_SEARCH_OPTION(frame)
        local optionName, optionValue = {}, {};
        local optionSet = {}; -- for checking duplicate option
        local category = frame:GetUserValue('SELECTED_CATEGORY');

        local function GET_MINMAX_QUERY_VALUE_STRING(minEdit, maxEdit)
            local queryValue = '';
            local minValue = -1000000;
            local maxValue = 1000000;
            local valid = false;
            if minEdit:GetText() ~= nil and minEdit:GetText() ~= '' then
                minValue = tonumber(minEdit:GetText());
                valid = true;
            end
            if maxEdit:GetText() ~= nil and maxEdit:GetText() ~= '' then
                maxValue = tonumber(maxEdit:GetText());
                valid = true;
            end

            if valid == false then
                return queryValue;
            end

            queryValue = minValue .. ';' .. maxValue;
            return queryValue;
        end

        -- level range
        local levelRangeSet = GET_CHILD_RECURSIVELY(frame, 'levelRangeSet');
        if levelRangeSet ~= nil and levelRangeSet:IsVisible() == 1 then
            local minEdit = GET_CHILD_RECURSIVELY(levelRangeSet, 'minEdit');
            local maxEdit = GET_CHILD_RECURSIVELY(levelRangeSet, 'maxEdit');
            local opValue = GET_MINMAX_QUERY_VALUE_STRING(minEdit, maxEdit);
            if opValue ~= '' then
                local opName = 'CT_UseLv';
                if category == 'OPTMisc' then
                    opName = 'Level';
                end
                optionName[#optionName + 1] = opName;
                optionValue[#optionValue + 1] = opValue;
                optionSet[opName] = true;
            end
        end

        -- grade
        local gradeCheckSet = GET_CHILD_RECURSIVELY(frame, 'gradeCheckSet');
        if gradeCheckSet ~= nil and gradeCheckSet:IsVisible() == 1 then
            local checkStr = '';
            local matchCnt, lastMatch = 0, nil;
            local childCnt = gradeCheckSet:GetChildCount();
            for i = 0, childCnt - 1 do
                local child = gradeCheckSet:GetChildByIndex(i);
                if string.find(child:GetName(), 'gradeCheck_') ~= nil then
                    AUTO_CAST(child);
                    if child:IsChecked() == 1 then
                        local grade = string.sub(child:GetName(), string.find(child:GetName(), '_') + 1);
                        checkStr = checkStr .. grade .. ';';
                        matchCnt = matchCnt + 1;
                        lastMatch = grade;
                    end
                end
            end
            if checkStr ~= '' then
                if matchCnt == 1 then
                    checkStr = checkStr .. lastMatch;
                end
                local opName = 'CT_ItemGrade';
                optionName[#optionName + 1] = opName;
                optionValue[#optionValue + 1] = checkStr;
                optionSet[opName] = true;
            end
        end

        -- random option flag
        local appCheckSet = GET_CHILD_RECURSIVELY(frame, 'appCheckSet');
        if appCheckSet ~= nil and appCheckSet:IsVisible() == 1 then
            local ranOpName, ranOpValue;
            local appCheck_0 = GET_CHILD(appCheckSet, 'appCheck_0');
            if appCheck_0:IsChecked() == 1 then
                ranOpName = 'Random_Item';
                ranOpValue = '2'
            end

            local appCheck_1 = GET_CHILD(appCheckSet, 'appCheck_1');
            if appCheck_1:IsChecked() == 1 then
                ranOpName = 'Random_Item';
                ranOpValue = '1'
            end

            if ranOpName ~= nil then
                optionName[#optionName + 1] = ranOpName;
                optionValue[#optionValue + 1] = ranOpValue;
                optionSet[ranOpName] = true;
            end
        end

        -- detail setting
        local detailOptionSet = GET_CHILD_RECURSIVELY(frame, 'detailOptionSet');
        if detailOptionSet ~= nil and detailOptionSet:IsVisible() == 1 then
            local curCnt = detailOptionSet:GetUserIValue('ADD_SELECT_COUNT');
            for i = 0, curCnt do
                local selectSet = GET_CHILD_RECURSIVELY(detailOptionSet, 'SELECT_' .. i);
                if selectSet ~= nil and selectSet:IsVisible() == 1 then
                    local nameList = GET_CHILD(selectSet, 'groupList');
                    local opName = nameList:GetSelItemKey();
                    if opName ~= '' then
                        local opValue = GET_MINMAX_QUERY_VALUE_STRING(GET_CHILD_RECURSIVELY(selectSet, 'minEdit'),
                                                                      GET_CHILD_RECURSIVELY(selectSet, 'maxEdit'));
                        if opValue ~= '' and optionSet[opName] == nil then
                            optionName[#optionName + 1] = opName;
                            optionValue[#optionValue + 1] = opValue;
                            optionSet[opName] = true;
                        end
                    end
                end
            end
        end

        -- option group
        local optionGroupSet = GET_CHILD_RECURSIVELY(frame, 'optionGroupSet');
        if optionGroupSet ~= nil and optionGroupSet:IsVisible() == 1 then
            local curCnt = optionGroupSet:GetUserIValue('ADD_SELECT_COUNT');
            for i = 0, curCnt do
                local selectSet = GET_CHILD_RECURSIVELY(optionGroupSet, 'SELECT_' .. i);
                if selectSet ~= nil then
                    local nameList = GET_CHILD(selectSet, 'nameList');
                    local opName = nameList:GetSelItemKey();
                    if opName ~= '' then
                        local opValue = GET_MINMAX_QUERY_VALUE_STRING(GET_CHILD_RECURSIVELY(selectSet, 'minEdit'),
                                                                      GET_CHILD_RECURSIVELY(selectSet, 'maxEdit'));
                        if opValue ~= '' and optionSet[opName] == nil then
                            optionName[#optionName + 1] = opName;
                            optionValue[#optionValue + 1] = opValue;
                            optionSet[opName] = true;
                        end
                    end
                end
            end
        end

        -- gem option
        local gemOptionSet = GET_CHILD_RECURSIVELY(frame, 'gemOptionSet');
        if gemOptionSet ~= nil and gemOptionSet:IsVisible() == 1 then
            local levelMinEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'levelMinEdit');
            local levelMaxEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'levelMaxEdit');
            local roastingMinEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'roastingMinEdit');
            local roastingMaxEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'roastingMaxEdit');
            if category == 'Gem' then
                local opValue = GET_MINMAX_QUERY_VALUE_STRING(levelMinEdit, levelMaxEdit);
                if opValue ~= '' then
                    optionName[#optionName + 1] = 'GemLevel';
                    optionValue[#optionValue + 1] = opValue;
                    optionSet['GemLevel'] = true;
                end

                local roastOpValue = GET_MINMAX_QUERY_VALUE_STRING(roastingMinEdit, roastingMaxEdit);
                if roastOpValue ~= '' then
                    optionName[#optionName + 1] = 'GemRoastingLv';
                    optionValue[#optionValue + 1] = roastOpValue;
                    optionSet['GemRoastingLv'] = true;
                end
            elseif category == 'Card' then
                local opValue = GET_MINMAX_QUERY_VALUE_STRING(levelMinEdit, levelMaxEdit);
                if opValue ~= '' then
                    optionName[#optionName + 1] = 'CardLevel';
                    optionValue[#optionValue + 1] = opValue;
                    optionSet['CardLevel'] = true;
                end
            end
        end

        return optionName, optionValue;
    end

    local optionKey, optionValue = GET_SEARCH_OPTION(frame);
    local itemCntPerPage = GET_MARKET_SEARCH_ITEM_COUNT(_category);
    MarketSearch(page + 1, orderByDesc, searchText, category, optionKey, optionValue, itemCntPerPage);
    DISABLE_BUTTON_DOUBLECLICK_WITH_CHILD(frame:GetName(), 'commitSet', 'searchBtn', 1);
    MARKET_OPTION_BOX_CLOSE_CLICK(frame);
end
