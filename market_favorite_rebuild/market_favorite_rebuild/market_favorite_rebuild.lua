-- v2.0.0 エビさんから引き継ぎな感じ。イコル検索と保存呼出を弄った
-- v2.0.1 キャンセルと期間終了の元の販売データを表示する様に
-- v2.0.2 アドオン名変更
-- v2.0.3 マーケットの開け閉め爆速に、検索ボタン入替え機能。検索開始位置調整機能、オプション見やすく。
local addon_name = 'MARKET_FAVORITE_REBUILD'
local addon_name_lower = string.lower(addon_name)
local author = 'ebisuke'
local base_ver = "1.1.1"
local ver = "2.0.3"
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addon_name] = _G['ADDONS'][author][addon_name] or {}
local g = _G['ADDONS'][author][addon_name]
local json = require('json')
local function ts(...)
    local num_args = select('#', ...)
    if num_args == 0 then
        return
    end
    local string_parts = {}
    for i = 1, num_args do
        local arg = select(i, ...)
        table.insert(string_parts, tostring(arg))
    end
    print(table.concat(string_parts, "\t"))
end

function g.truncate_text_by_byte_limit(text, lang)
    if not text or text == "" then
        return ""
    end
    local max_bytes
    if lang == "ja" or lang == "ko" then
        max_bytes = 48
    else
        max_bytes = 16
    end
    if string.len(text) <= max_bytes then
        return text
    end
    local current_bytes = 0
    local end_byte_pos = 0
    for pos, code in utf8.codes(text) do
        local char_len
        local next_pos = utf8.offset(text, 2, pos)
        if next_pos then
            char_len = next_pos - pos
        else
            char_len = #text - pos + 1
        end
        if current_bytes + char_len > max_bytes then
            break
        end
        current_bytes = current_bytes + char_len
        end_byte_pos = current_bytes
    end
    return string.sub(text, 1, end_byte_pos)
end

function g.judge_language(str)
    if not str or str == "" then
        return "unknown"
    end
    local has_korean = false
    local has_japanese = false
    local has_english = false
    for _, code in utf8.codes(str) do
        if code >= 0xAC00 and code <= 0xD7A3 then
            has_korean = true
        elseif (code >= 0x3040 and code <= 0x309F) or (code >= 0x30A0 and code <= 0x30FF) or
            (code >= 0x4E00 and code <= 0x9FFF) then
            has_japanese = true
        elseif (code >= 0x0041 and code <= 0x005A) or (code >= 0x0061 and code <= 0x007A) then
            has_english = true
        end
    end
    if has_korean then
        return "ko"
    end
    if has_japanese then
        return "ja"
    end
    if has_english then
        return "en"
    end
    return "unknown"
end

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

function market_favorite_rebuild_SAVE_SETTINGS()
    g.save_settings()
end

function market_favorite_rebuild_LOAD_SETTINGS()
    local settings = g.load_json(g.settings_path)
    if not settings then
        settings = {
            move = 0,
            always = 0,
            position = {
                x = 1420,
                y = 0
            },
            items = {},
            searchs = {}
        }
    end
    g.settings = settings
    if not g.settings.sell_items then
        g.settings.sell_items = {}
    end
    if not g.settings.sell_items[g.login_name] then
        g.settings.sell_items[g.login_name] = {}
    end
    local has_changed = false
    if g.settings.items and type(g.settings.items) == "table" then
        for _, item in ipairs(g.settings.items) do
            if type(item) == "table" and item.clsid ~= nil then
                if item.str_count == nil then
                    item.str_count = 1
                    has_changed = true
                end
                if type(item.clsid) == "string" then
                    item.clsid = tonumber(item.clsid)
                    has_changed = true
                end
            end
        end
    end
    if has_changed then
        market_favorite_rebuild_SAVE_SETTINGS()
    end
end

function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
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

function MARKET_FAVORITE_REBUILD_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()
    g.login_name = session.GetMySession():GetPCApc():GetName()
    if not g.settings then
        market_favorite_rebuild_LOAD_SETTINGS()
    end
    addon:RegisterMsg("OPEN_DLG_MARKET", "market_favorite_rebuild_ON_OPEN_MARKET")
    g.REGISTER = {}
    g.setup_hook_and_event(addon, "MARKET_SELL_FILTER_RESET", "market_favorite_rebuild_MARKET_SELL_FILTER_RESET", false)
    g.setup_hook_and_event(addon, "MARKET_CLOSE", "market_favorite_rebuild_MARKET_CLOSE", true)
    g.setup_hook_and_event(addon, "_MARKET_SAVE_CATEGORY_OPTION",
        "market_favorite_rebuild__MARKET_SAVE_CATEGORY_OPTION", true)
    g.setup_hook_and_event(addon, "MARKET_INIT_OPTION_GROUP_DROPLIST",
        "market_favorite_rebuild_MARKET_INIT_OPTION_GROUP_DROPLIST", true)
    g.setup_hook_and_event(addon, "MARKET_DELETE_SAVED_OPTION", "market_favorite_rebuild_MARKET_DELETE_SAVED_OPTION",
        false)
    g.setup_hook_and_event(addon, "MARKET_BUYMODE", "market_favorite_rebuild_MARKET_BUYMODE", true)
    g.setup_hook_and_event(addon, "ON_MARKET_SELL_LIST", "market_favorite_rebuild_ON_MARKET_SELL_LIST", false)
    g.setup_hook_and_event(addon, "ON_CABINET_ITEM_LIST", "market_favorite_rebuild_ON_CABINET_ITEM_LIST", false)
    g.setup_hook_and_event(addon, "MARKET_SELL_REGISTER", "market_favorite_rebuild_MARKET_SELL_REGISTER", false)
    g.setup_hook_and_event(addon, "MARKET_DRAW_CTRLSET_OPTMISC", "market_favorite_rebuild_MARKET_DRAW_CTRLSET_OPTMISC",
        false)
    g.setup_hook_and_event(addon, "MARKET_DRAW_CTRLSET_EQUIP", "market_favorite_rebuild_MARKET_DRAW_CTRLSET_EQUIP",
        false)
    g.temp_tbl = {}
end

local option_image_table = {
    ["Add_Damage_Atk"] = "{img tooltip_attribute1}",
    ["ADD_MATK"] = "{img tooltip_attribute1}",
    ["AllMaterialType_Atk"] = "{img tooltip_attribute1}",
    ["AllRace_Atk"] = "{img tooltip_attribute1}",
    ["PATK"] = "{img tooltip_attribute1}",
    ["ADD_DEF"] = "{img tooltip_attribute2}",
    ["ADD_MDEF"] = "{img tooltip_attribute2}",
    ["high_fire_res"] = "{img tooltip_attribute2}",
    ["high_freezing_res"] = "{img tooltip_attribute2}",
    ["high_laceration_res"] = "{img tooltip_attribute2}",
    ["high_lighting_res"] = "{img tooltip_attribute2}",
    ["high_poison_res"] = "{img tooltip_attribute2}",
    ["MiddleSize_Def"] = "{img tooltip_attribute2}",
    ["portion_expansion"] = "{img tooltip_attribute2}",
    ["ResAdd_Damage"] = "{img tooltip_attribute2}",
    ["stun_res"] = "{img tooltip_attribute2}",
    ["ADD_DR"] = "{img tooltip_attribute3}",
    ["ADD_HR"] = "{img tooltip_attribute3}",
    ["BLK"] = "{img tooltip_attribute3}",
    ["BLK_BREAK"] = "{img tooltip_attribute3}",
    ["CRTATK"] = "{img tooltip_attribute3}",
    ["CRTDR"] = "{img tooltip_attribute3}",
    ["CRTHR"] = "{img tooltip_attribute3}",
    ["CRTMATK"] = "{img tooltip_attribute3}",
    ["MHP"] = "{img tooltip_attribute3}",
    ["MSP"] = "{img tooltip_attribute3}",
    ["ALLSKILL"] = "{img tooltip_attribute5}",
    ["ignore_deadremove"] = "{img tooltip_attribute5}",
    ["MSPD"] = "{img tooltip_attribute5}",
    ["reduce_rsp_time"] = "{img tooltip_attribute5}",
    ["secret_medicine_time"] = "{img tooltip_attribute5}",
    ["walking_recover_sta"] = "{img tooltip_attribute5}"
}

function market_favorite_rebuild_MARKET_DRAW_CTRLSET_EQUIP(my_frame, my_msg)
    local frame, isShowSocket = g.get_event_args(my_msg)
    if g.settings.op_text == 0 then
        g.FUNCS["MARKET_DRAW_CTRLSET_EQUIP"](frame, isShowSocket)
        return
    end
    local itemlist = GET_CHILD_RECURSIVELY(frame, "itemListGbox");
    itemlist:RemoveAllChild();
    local mySession = session.GetMySession();
    local cid = mySession:GetCID();
    local count = session.market.GetItemCount();
    MARKET_SELECT_SHOW_TITLE(frame, "equipTitle")
    local equipTitle_socket = GET_CHILD_RECURSIVELY(frame, "equipTitle_socket");
    local equipTitle_stats = GET_CHILD_RECURSIVELY(frame, "equipTitle_stats");
    if isShowSocket ~= nil and isShowSocket == false then
        equipTitle_socket:ShowWindow(0);
        equipTitle_stats:ShowWindow(0);
    else
        equipTitle_socket:ShowWindow(1)
        equipTitle_stats:ShowWindow(1);
    end
    local yPos = 0
    for i = 0, count - 1 do
        local marketItem = session.market.GetItemByIndex(i);
        local itemObj = GetIES(marketItem:GetObject());
        local refreshScp = itemObj.RefreshScp;
        if refreshScp ~= "None" then
            refreshScp = _G[refreshScp];
            refreshScp(itemObj);
        end
        local ctrlSet = itemlist:CreateControlSet("market_item_detail_equip", "ITEM_EQUIP_" .. i, ui.LEFT, ui.TOP, 0, 0,
            0, yPos);
        AUTO_CAST(ctrlSet)
        ctrlSet:SetUserValue("DETAIL_ROW", i);
        ctrlSet:SetUserValue("optionIndex", 0)
        local inheritanceItem = GetClass('Item', itemObj.InheritanceItemName)
        if inheritanceItem == nil then
            inheritanceItem = GetClass('Item', itemObj.InheritanceRandomItemName)
        end
        local function MARKET_CTRLSET_SET_ICON(ctrlSet, itemObj, marketItem)
            local pic = GET_CHILD_RECURSIVELY(ctrlSet, "pic");
            SET_SLOT_ITEM_CLS(pic, itemObj)
            SET_ITEM_TOOLTIP_ALL_TYPE(pic:GetIcon(), marketItem, itemObj.ClassName, "market", marketItem.itemType,
                marketItem:GetMarketGuid());
            SET_SLOT_STYLESET(pic, itemObj)
            SET_SLOT_ICOR_CATEGORY(pic, itemObj);
            if itemObj.MaxStack > 1 then
                local font = '{s16}{ol}{b}';
                if 100000 <= marketItem.count then -- 6자리 수 폰트 크기 조정
                    font = '{s14}{ol}{b}';
                end
                SET_SLOT_COUNT_TEXT(pic, marketItem.count, font);
            end
            SET_SLOT_STAR_TEXT(pic, itemObj);
        end
        MARKET_CTRLSET_SET_ICON(ctrlSet, itemObj, marketItem);
        local name = GET_CHILD_RECURSIVELY(ctrlSet, "name");
        local name_text = GET_FULL_NAME(itemObj)
        local grade = shared_item_earring.get_earring_grade(itemObj)
        if grade > 0 then
            name_text = name_text .. '(' .. grade .. ClMsg('Grade') .. ')'
        end
        name:SetTextByKey("value", name_text);
        local level = GET_CHILD_RECURSIVELY(ctrlSet, "level");
        level:SetTextByKey("value", itemObj.UseLv);
        local atkdefImageSize = ctrlSet:GetUserConfig("ATKDEF_IMAGE_SIZE")
        local basicProp = 'None';
        local atkdefText = "";
        if itemObj.BasicTooltipProp ~= 'None' then
            local basicTooltipPropList = StringSplit(itemObj.BasicTooltipProp, ';');
            for j = 1, #basicTooltipPropList do
                basicProp = basicTooltipPropList[j];
                local typeiconname, typestring, arg1, arg2
                if basicProp == 'ATK' then
                    typeiconname = 'test_sword_icon'
                    typestring = ScpArgMsg("Melee_Atk")
                    if TryGetProp(itemObj, 'EquipGroup') == "SubWeapon" then
                        typestring = ScpArgMsg("PATK_SUB")
                    end
                    arg1 = itemObj.MINATK;
                    arg2 = itemObj.MAXATK;
                elseif basicProp == 'MATK' then
                    typeiconname = 'test_sword_icon'
                    typestring = ScpArgMsg("Magic_Atk")
                    arg1 = itemObj.MATK;
                    arg2 = itemObj.MATK;
                else
                    typeiconname = 'test_shield_icon'
                    typestring = ScpArgMsg(basicProp);
                    if itemObj.RefreshScp ~= 'None' then
                        local scp = _G[itemObj.RefreshScp];
                        if scp ~= nil then
                            scp(itemObj);
                        end
                    end
                    arg1 = TryGetProp(itemObj, basicProp);
                    arg2 = TryGetProp(itemObj, basicProp);
                end
                local tempStr = string.format("{img %s %d %d}", typeiconname, atkdefImageSize, atkdefImageSize)
                local tempATKDEF = ""
                if arg1 == arg2 or arg2 == 0 then
                    tempATKDEF = " " .. arg1
                else
                    tempATKDEF = " " .. arg1 .. "~" .. arg2
                end
                if j == 1 then
                    atkdefText = atkdefText .. tempStr .. typestring .. tempATKDEF
                else
                    atkdefText = atkdefText .. "{nl}" .. tempStr .. typestring .. tempATKDEF
                end
            end
        end
        local atkdef = GET_CHILD_RECURSIVELY(ctrlSet, "atkdef");
        atkdef:SetTextByKey("value", atkdefText);
        local socket = GET_CHILD_RECURSIVELY(ctrlSet, "socket")
        local needAppraisal = TryGetProp(itemObj, "NeedAppraisal");
        local needRandomOption = TryGetProp(itemObj, "NeedRandomOption");
        local maxSocketCount = itemObj.MaxSocket
        local drawFlag = 0
        if maxSocketCount > 3 then
            drawFlag = 1
        end
        local curCount = 1;
        local socketText = "";
        local tempStr = "";
        for j = 0, maxSocketCount - 1 do
            if marketItem:IsAvailableSocket(j) == true then
                local isEquip = marketItem:GetEquipGemID(j);
                if isEquip == 0 then
                    tempStr = ctrlSet:GetUserConfig("SOCKET_IMAGE_EMPTY")
                    if drawFlag == 1 and curCount % 2 == 1 then
                        socketText = socketText .. tempStr
                    else
                        socketText = socketText .. tempStr .. "{nl}"
                    end
                else
                    local gemClass = GetClassByType("Item", isEquip);
                    if gemClass.ClassName == 'gem_circle_1' then
                        tempStr = ctrlSet:GetUserConfig("SOCKET_IMAGE_RED")
                    elseif gemClass.ClassName == 'gem_square_1' then
                        tempStr = ctrlSet:GetUserConfig("SOCKET_IMAGE_BLUE")
                    elseif gemClass.ClassName == 'gem_diamond_1' then
                        tempStr = ctrlSet:GetUserConfig("SOCKET_IMAGE_GREEN")
                    elseif gemClass.ClassName == 'gem_star_1' then
                        tempStr = ctrlSet:GetUserConfig("SOCKET_IMAGE_YELLOW")
                    elseif gemClass.ClassName == 'gem_White_1' then
                        tempStr = ctrlSet:GetUserConfig("SOCKET_IMAGE_WHITE")
                    elseif gemClass.EquipXpGroup == "Gem_Skill" then
                        tempStr = ctrlSet:GetUserConfig("SOCKET_IMAGE_MONSTER")
                    end
                    local gemLv = GET_ITEM_LEVEL_EXP(gemClass, marketItem:GetEquipGemExp(j));
                    tempStr = tempStr .. "Lv" .. gemLv
                    if drawFlag == 1 and curCount % 2 == 1 then
                        socketText = socketText .. tempStr
                    else
                        socketText = socketText .. tempStr .. "{nl}"
                    end
                end
            end
            curCount = curCount + 1
        end
        socket:SetTextByKey("value", socketText)
        local potential = GET_CHILD_RECURSIVELY(ctrlSet, "potential");
        if needAppraisal == 1 then
            potential:SetTextByKey("value1", "?")
            potential:SetTextByKey("value2", "?")
        else
            potential:SetTextByKey("value1", itemObj.PR)
            potential:SetTextByKey("value2", itemObj.MaxPR)
        end
        local originalItemObj = itemObj
        if inheritanceItem ~= nil then
            itemObj = inheritanceItem
        end
        if needAppraisal == 1 or needRandomOption == 1 then
            SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, '{@st66b}' .. ScpArgMsg("AppraisalItem"))
        end
        local basicList = GET_EQUIP_TOOLTIP_PROP_LIST(itemObj);
        local list = {};
        local basicTooltipPropList = StringSplit(itemObj.BasicTooltipProp, ';');
        for j = 1, #basicTooltipPropList do
            local basicTooltipProp = basicTooltipPropList[i];
            list = GET_CHECK_OVERLAP_EQUIPPROP_LIST(basicList, basicTooltipProp, list);
        end
        local list2 = GET_EUQIPITEM_PROP_LIST();
        local cnt = 0;
        local class = GetClassByType("Item", itemObj.ClassID);
        local maxRandomOptionCnt = MAX_OPTION_EXTRACT_COUNT;
        local randomOptionProp = {};
        for j = 1, maxRandomOptionCnt do
            if itemObj['RandomOption_' .. j] ~= 'None' then
                randomOptionProp[itemObj['RandomOption_' .. j]] = itemObj['RandomOptionValue_' .. j];
            end
        end
        for j = 1, #list do
            local propName = list[j];
            local propValue = TryGetProp(class, propName, 0);
            local needToShow = true;
            for k = 1, #basicTooltipPropList do
                if basicTooltipPropList[k] == propName then
                    needToShow = false;
                end
            end
            if needToShow == true and propValue ~= 0 and randomOptionProp[propName] == nil then -- 랜덤 옵션이랑 겹치는 프로퍼티는 여기서 출력하지 않음
                if itemObj.GroupName == 'Weapon' then
                    if propName ~= "MINATK" and propName ~= 'MAXATK' then
                        local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue);
                        SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                    end
                elseif itemObj.GroupName == 'Armor' then
                    if itemObj.ClassType == 'Gloves' then
                        if propName ~= "HR" then
                            local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue);
                            SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                        end
                    elseif itemObj.ClassType == 'Boots' then
                        if propName ~= "DR" then
                            local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue);
                            SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                        end
                    else
                        if propName ~= "DEF" then
                            local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue);
                            SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                        end
                    end
                else
                    local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue);
                    SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                end
            end
        end
        for j = 1, 3 do
            local propName = "HatPropName_" .. j;
            local propValue = "HatPropValue_" .. j;
            if itemObj[propValue] ~= 0 and itemObj[propName] ~= "None" then
                local opName
                local op_image = ""
                if string.find(itemObj[propName], 'ALLSKILL_') == nil then
                    opName = string.format("%s", ScpArgMsg(itemObj[propName]))
                    if option_image_table[itemObj[propName]] then
                        op_image = option_image_table[itemObj[propName]]
                    else
                        op_image = ScpArgMsg("PropUp")
                    end
                else
                    local job = StringSplit(itemObj[propName], '_')[2]
                    if job == 'ShadowMancer' then
                        job = 'Shadowmancer'
                    end
                    local classList, count = GetClassList('Job')
                    local real_name = ScpArgMsg(job)
                    for i = 0, count - 1 do
                        local class = GetClassByIndexFromList(classList, i)
                        if class.EngName == job then
                            real_name = string.gsub(dictionary.ReplaceDicIDInCompStr(class.Name), "{s18}", "")
                            break
                        end
                    end
                    opName = string.format("{ol}{#FFD700}%s", real_name .. ' ' .. ScpArgMsg('skill_lv_up_by_count'))
                    if option_image_table["ALLSKILL"] then
                        op_image = option_image_table["ALLSKILL"]
                    end
                end
                local function market_favorite_rebuild_ABILITY_DESC_PLUS(desc, cur, op_image)
                    if cur < 0 then
                        return string.format(" - %s " .. ScpArgMsg("PropDown") .. "%d", desc, math.abs(cur));
                    elseif string.find(desc, "{#FFD700}") then
                        return string.format(op_image .. "+ %d" .. " %s", math.abs(cur), desc)
                    else
                        return string.format(op_image .. " %s" .. " %s", GET_COMMAED_STRING(math.abs(cur)), desc)
                    end
                end
                local strInfo = market_favorite_rebuild_ABILITY_DESC_PLUS(opName, itemObj[propValue], op_image);
                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
            end
        end
        for j = 1, maxRandomOptionCnt do
            local propGroupName = "RandomOptionGroup_" .. j;
            local propName = "RandomOption_" .. j;
            local propValue = "RandomOptionValue_" .. j;
            local clientMessage = 'None'
            local propItem = originalItemObj
            if propItem[propGroupName] == 'ATK' then
                clientMessage = 'ItemRandomOptionGroupATK'
            elseif propItem[propGroupName] == 'DEF' then
                clientMessage = 'ItemRandomOptionGroupDEF'
            elseif propItem[propGroupName] == 'UTIL_WEAPON' then
                clientMessage = 'ItemRandomOptionGroupUTIL'
            elseif propItem[propGroupName] == 'UTIL_ARMOR' then
                clientMessage = 'ItemRandomOptionGroupUTIL'
            elseif propItem[propGroupName] == 'UTIL_SHILED' then
                clientMessage = 'ItemRandomOptionGroupUTIL'
            elseif propItem[propGroupName] == 'STAT' then
                clientMessage = 'ItemRandomOptionGroupSTAT'
            elseif propItem[propGroupName] == 'SPECIAL' then
                clientMessage = 'ItemRandomOptionGroupSPECIAL'
                --[[elseif propItem[propGroupName] == 'SPECIAL' then
                clientMessage = 'ItemRandomOptionGroupSPECIAL']]
            end
            if propItem[propValue] ~= 0 and propItem[propName] ~= "None" then
                local opName = string.format("%s %s", ClMsg(clientMessage), ScpArgMsg(propItem[propName]));
                local strInfo = ABILITY_DESC_NO_PLUS(opName, propItem[propValue], 0);
                local min, max = 0, 0
                if itemObj.ClassType == "BELT" then
                    min, max = shared_item_belt.get_option_value_range_equip(itemObj, itemObj[propName])
                    local per = string.sub(tonumber(propItem[propValue]) / max * 100, 1, 4) .. "%"
                    if g.settings.max_value == 1 then
                        strInfo =
                            "{@st66}{s14}" .. GET_COMMAED_STRING(propItem[propValue]) .. "{@st66}{s14}" .. opName ..
                                "{nl}{@st66}{s10}  (" .. per .. "/" .. GET_COMMAED_STRING(max) .. ")"
                    else
                        strInfo =
                            "{@st66}{s14}" .. GET_COMMAED_STRING(propItem[propValue]) .. "{@st66}{s14}" .. opName ..
                                "{nl}{@st66}{s12}  (" .. per .. ")"
                    end
                    local optionText = GET_CHILD_RECURSIVELY(ctrlSet, "randomoption_" .. j - 1)
                    optionText:Resize(250, 36)
                elseif itemObj.ClassType == 'SHOULDER' then
                    min, max = shared_item_shoulder.get_option_value_range_equip(itemObj, itemObj[propName])
                    local per = string.sub(tonumber(propItem[propValue]) / max * 100, 1, 4) .. "%"
                    if g.settings.max_value == 1 then
                        strInfo =
                            "{@st66}{s14}" .. GET_COMMAED_STRING(propItem[propValue]) .. "{@st66}{s14}" .. opName ..
                                "{nl}{@st66}{s10}  (" .. per .. "/" .. GET_COMMAED_STRING(max) .. ")"
                    else
                        strInfo =
                            "{@st66}{s14}" .. GET_COMMAED_STRING(propItem[propValue]) .. "{@st66}{s14}" .. opName ..
                                "{nl}{@st66}{s12}  (" .. per .. ")"
                    end
                    local optionText = GET_CHILD_RECURSIVELY(ctrlSet, "randomoption_" .. j - 1)
                    optionText:Resize(250, 36)
                end
                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
            end
        end
        local function _CREATE_SEAL_OPTION(ctrlSet, itemObj)
            if TryGetProp(itemObj, 'GroupName') ~= 'Seal' then
                return;
            end
            if TryGetProp(itemObj, "StringArg") == "Seal_Material" then
                return;
            end
            for j = 1, itemObj.MaxReinforceCount do
                local option = TryGetProp(itemObj, 'SealOption_' .. j, 'None');
                if option == 'None' then
                    break
                end
                local strInfo = GET_OPTION_VALUE_OR_PERCECNT_STRING(option, itemObj['SealOptionValue_' .. j]);
                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
            end
        end
        _CREATE_SEAL_OPTION(ctrlSet, itemObj);
        local function _CREATE_EARRING_OPTION(ctrlSet, itemObj)
            if TryGetProp(itemObj, 'GroupName') ~= 'Earring' then
                return;
            end
            for j = 1, shared_item_earring.get_max_special_option_count(TryGetProp(itemObj, 'ItemLv', 0)) do
                local ctrl = TryGetProp(itemObj, 'EarringSpecialOption_' .. j, 'None')
                if ctrl ~= 'None' then
                    local cls = GetClass('Job', ctrl)
                    local ctrl = TryGetProp(cls, 'Name', 'None')
                    local rank = TryGetProp(itemObj, 'EarringSpecialOptionRankValue_' .. j, 0)
                    local lv = TryGetProp(itemObj, 'EarringSpecialOptionLevelValue_' .. j, 0)
                    ctrl = string.gsub(dic.getTranslatedStr(ctrl), "{s18}", "")
                    local text = "{img tooltip_attribute5} {ol}{s15}{#32CD32}" .. ctrl .. "{/}{/}{s15}{#1E90FF}[" ..
                                     rank .. "]" .. ScpArgMsg("PropUp") .. "{s15}{#32CD32}" .. lv
                    SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, text); -- {#FFD700}
                end
            end
        end
        _CREATE_EARRING_OPTION(ctrlSet, itemObj);
        local function _CREATE_RADA_OPTION(ctrlSet, itemObj)
            if TryGetProp(itemObj, 'RadaOption', 'None') == 'None' then
                return;
            end
            local RadaOption = TryGetProp(itemObj, 'RadaOption', 'None')
            local equip_group = TryGetProp(itemObj, 'EquipGroup', 'None')
            if RadaOption ~= 'None' then
                local list = StringSplit(RadaOption, ';')
                for i = 1, #list do
                    local desc = ''
                    local prefix = ''
                    local suffix = ''
                    if SEASON_COIN_NAME ~= 'RadaCertificate' then
                        prefix = '{#7F7F7F}'
                        suffix = '{/}'
                    end
                    desc = prefix .. desc
                    local name = StringSplit(list[i], '/')[1]
                    local value = StringSplit(list[i], '/')[2]
                    local range = GET_RADAOPTION_RANGE(name, equip_group)
                    desc = desc .. ScpArgMsg(name, 'level', value, 'min', range[1], 'max', range[2]) .. '{nl}'
                    desc = desc .. suffix
                    SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, desc);
                end
            end
        end
        _CREATE_RADA_OPTION(ctrlSet, itemObj);
        for j = 1, #list2 do
            local propName = list2[j];
            local propValue = TryGetProp(itemObj, propName, 0);
            if propValue ~= 0 then
                local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue);
                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
            end
        end
        if itemObj.OptDesc ~= nil and itemObj.OptDesc ~= 'None' then
            SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, itemObj.OptDesc);
        end
        if originalItemObj['RandomOptionRareValue'] ~= 0 and originalItemObj['RandomOptionRare'] ~= "None" then
            local strInfo = _GET_RANDOM_OPTION_RARE_CLIENT_TEXT(originalItemObj['RandomOptionRare'],
                originalItemObj['RandomOptionRareValue'], '');
            if strInfo ~= nil then
                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
            end
        end
        if inheritanceItem == nil then
            if itemObj.IsAwaken == 1 then
                local opName = string.format("[%s] %s", ClMsg("AwakenOption"), ScpArgMsg(itemObj.HiddenProp));
                local strInfo = ABILITY_DESC_PLUS(opName, itemObj.HiddenPropValue);
                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
            end
        else
            if inheritanceItem.IsAwaken == 1 then
                local opName = string.format("[%s] %s", ClMsg("AwakenOption"), ScpArgMsg(inheritanceItem.HiddenProp));
                local strInfo = ABILITY_DESC_PLUS(opName, inheritanceItem.HiddenPropValue);
                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
            end
        end
        if itemObj.ReinforceRatio > 100 then
            local opName = ClMsg("ReinforceOption");
            local strInfo = ABILITY_DESC_PLUS(opName, math.floor(10 * itemObj.ReinforceRatio / 100));
            SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
        end
        if cid == marketItem:GetSellerCID() then
            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(0)
            buyBtn:SetEnable(0);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(1)
            cancelBtn:SetEnable(1)
            if USE_MARKET_REPORT == 1 then
                local reportBtn = GET_CHILD_RECURSIVELY(ctrlSet, "reportBtn");
                reportBtn:SetEnable(0);
            end
            local totalPrice_num = GET_CHILD_RECURSIVELY(ctrlSet, "totalPrice_num");
            totalPrice_num:SetTextByKey("value", 0);
            local totalPrice_text = GET_CHILD_RECURSIVELY(ctrlSet, "totalPrice_text");
            totalPrice_text:SetTextByKey("value", 0);
        else
            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(1)
            buyBtn:SetEnable(1);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(0)
            cancelBtn:SetEnable(0)
            MARKET_CTRLSET_SET_TOTAL_PRICE(ctrlSet, marketItem);
        end
        ctrlSet:SetUserValue("sellPrice", marketItem:GetSellPrice() or 0);
    end
    local ITEM_CTRLSET_INTERVAL_Y_MARGIN = tonumber(frame:GetUserConfig('ITEM_CTRLSET_INTERVAL_Y_MARGIN'));
    GBOX_AUTO_ALIGN(itemlist, 4, ITEM_CTRLSET_INTERVAL_Y_MARGIN, 0, true, false)
    local function MARKET_SET_PAGE_CONTROL(frame, pageControl)
        local category, _category, _subCategory = GET_CATEGORY_STRING(frame);
        local itemCntPerPage = GET_MARKET_SEARCH_ITEM_COUNT(_category);
        local maxPage = math.ceil(session.market.GetTotalCount() / itemCntPerPage);
        local curPage = session.market.GetCurPage();
        local pageController = GET_CHILD(frame, pageControl, 'ui::CPageController')
        if maxPage < 1 then
            maxPage = 1;
        end
        pageController:SetMaxPage(maxPage);
        pageController:SetCurPage(curPage);
    end
    MARKET_SET_PAGE_CONTROL(frame, "pagecontrol")
end

local icor_table = { -- { "オプション名", "category", 武器突破, 武器通常, 防具突破, 防具通常 },
{"revenge", "ATK", 90000, 60000, nil, nil}, {"perfection", "ATK", 14040, 9360, nil, nil},
{"AllMaterialType_Atk", "ATK", 4746, 3164, 3804, 2536}, {"AllRace_Atk", "ATK", 4746, 3164, 3804, 2536},
{"Add_Damage_Atk", "ATK", 8385, 5590, 5583, 3722}, {"ADD_SMALLSIZE", "ATK", 5583, 3722, 4473, 2982},
{"ADD_PARAMUNE", "ATK", 5583, 3722, 4473, 2982}, {"ADD_IRON", "ATK", 5583, 3722, 4473, 2982},
{"ADD_VELIAS", "ATK", 5583, 3722, 4473, 2982}, {"ADD_GHOST", "ATK", 5583, 3722, 4473, 2982},
{"ADD_MIDDLESIZE", "ATK", 5583, 3722, 4473, 2982}, {"ADD_FORESTER", "ATK", 5583, 3722, 4473, 2982},
{"ADD_CLOTH", "ATK", 5583, 3722, 4473, 2982}, {"ADD_LARGESIZE", "ATK", 5583, 3722, 4473, 2982},
{"ADD_WIDLING", "ATK", 5583, 3722, 4473, 2982}, {"ADD_KLAIDA", "ATK", 5583, 3722, 4473, 2982},
{"ADD_LEATHER", "ATK", 5583, 3722, 4473, 2982}, {"ResAdd_Damage", "DEF", 8385, 5590, 5583, 3722},
{"MiddleSize_Def", "DEF", 5583, 3722, 4473, 2982}, {"Iron_Def", "DEF", 5583, 3722, 4473, 2982},
{"Leather_Def", "DEF", 5583, 3722, 4473, 2982}, {"Cloth_Def", "DEF", 5583, 3722, 4473, 2982},
{"portion_expansion", "DEF", nil, nil, 116707, 77805}, {"high_lighting_res", "DEF", nil, nil, 798, 532},
{"high_poison_res", "DEF", nil, nil, 798, 532}, {"stun_res", "DEF", nil, nil, 798, 532},
{"high_laceration_res", "DEF", nil, nil, 798, 532}, {"high_freezing_res", "DEF", nil, nil, 798, 532},
{"high_fire_res", "DEF", nil, nil, 798, 532}, {"RHP", "UTIL", 2793, 1862, 2230, 1487},
{"ADD_HR", "UTIL", 2793, 1862, 2230, 1487}, {"ADD_DR", "UTIL", 2793, 1862, 2230, 1487},
{"CRTHR", "UTIL", 2793, 1862, 2230, 1487}, {"BLK_BREAK", "UTIL", 2793, 1862, 2230, 1487},
{"CRTDR", "UTIL", 2793, 1862, 2230, 1487}, {"BLK", "UTIL", 2793, 1862, 2230, 1487}, {"INT", "STAT", 834, 556, 663, 442},
{"CON", "STAT", 834, 556, 663, 442}, {"STR", "STAT", 834, 556, 663, 442}, {"DEX", "STAT", 834, 556, 663, 442},
{"MNA", "STAT", 834, 556, 663, 442}}
function market_favorite_rebuild_MARKET_DRAW_CTRLSET_OPTMISC(my_frame, my_msg)
    local frame = g.get_event_args(my_msg)
    if g.settings.op_text == 0 then
        g.FUNCS["MARKET_DRAW_CTRLSET_OPTMISC"](frame)
        return
    end
    local itemlist = GET_CHILD_RECURSIVELY(frame, "itemListGbox");
    itemlist:RemoveAllChild();
    local mySession = session.GetMySession();
    local cid = mySession:GetCID();
    local count = session.market.GetItemCount();
    MARKET_SELECT_SHOW_TITLE(frame, "OPTMiscTitle")
    local yPos = 0
    for i = 0, count - 1 do
        local marketItem = session.market.GetItemByIndex(i);
        local itemObj = GetIES(marketItem:GetObject());
        local refreshScp = itemObj.RefreshScp;
        if refreshScp ~= "None" then
            refreshScp = _G[refreshScp];
            refreshScp(itemObj);
        end
        local ctrlSet = itemlist:CreateControlSet("market_item_detail_OPTMisc", "ITEM_EQUIP_" .. i, ui.LEFT, ui.TOP, 0,
            0, 0, yPos);
        AUTO_CAST(ctrlSet)
        ctrlSet:SetUserValue("DETAIL_ROW", i);
        ctrlSet:SetUserValue("optionIndex", 0)
        local type = GET_CHILD_RECURSIVELY(ctrlSet, "type");
        type:ShowWindow(0);
        local inheritanceItem = GetClass('Item', itemObj.InheritanceItemName)
        if inheritanceItem == nil then
            inheritanceItem = GetClass('Item', itemObj.InheritanceRandomItemName)
        end
        local function MARKET_CTRLSET_SET_ICON(ctrlSet, itemObj, marketItem)
            local pic = GET_CHILD_RECURSIVELY(ctrlSet, "pic");
            SET_SLOT_ITEM_CLS(pic, itemObj)
            SET_ITEM_TOOLTIP_ALL_TYPE(pic:GetIcon(), marketItem, itemObj.ClassName, "market", marketItem.itemType,
                marketItem:GetMarketGuid());
            SET_SLOT_STYLESET(pic, itemObj)
            SET_SLOT_ICOR_CATEGORY(pic, itemObj);
            if itemObj.MaxStack > 1 then
                local font = '{s16}{ol}{b}';
                if 100000 <= marketItem.count then
                    font = '{s14}{ol}{b}';
                end
                SET_SLOT_COUNT_TEXT(pic, marketItem.count, font);
            end
            SET_SLOT_STAR_TEXT(pic, itemObj);
        end
        MARKET_CTRLSET_SET_ICON(ctrlSet, itemObj, marketItem);
        local name = GET_CHILD_RECURSIVELY(ctrlSet, "name");
        local real_name = dictionary.ReplaceDicIDInCompStr(GET_FULL_NAME(itemObj))
        if not string.find(real_name, "540") then
            real_name = ScpArgMsg("PropDown") .. "{ol}{#FF0000}" .. real_name
        elseif string.find(real_name, "540") and string.find(real_name, "上級") then
            real_name = "{ol}{#FFA500}" .. real_name
        end
        name:SetTextByKey("value", real_name)
        local originalItemObj = itemObj
        if inheritanceItem ~= nil then
            itemObj = inheritanceItem
            type:SetTextByKey("value", ClMsg(inheritanceItem.ClassType));
            type:ShowWindow(1);
            if needAppraisal == 1 or needRandomOption == 1 then
                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, '{@st66b}' .. ScpArgMsg("AppraisalItem"))
            end
            local basicList = GET_EQUIP_TOOLTIP_PROP_LIST(itemObj);
            local list = {};
            local basicTooltipPropList = StringSplit(itemObj.BasicTooltipProp, ';');
            for i = 1, #basicTooltipPropList do
                local basicTooltipProp = basicTooltipPropList[i];
                list = GET_CHECK_OVERLAP_EQUIPPROP_LIST(basicList, basicTooltipProp, list);
            end
            local list2 = GET_EUQIPITEM_PROP_LIST();
            local cnt = 0;
            local class = GetClassByType("Item", itemObj.ClassID);
            local maxRandomOptionCnt = MAX_OPTION_EXTRACT_COUNT;
            local randomOptionProp = {};
            for i = 1, maxRandomOptionCnt do
                if itemObj['RandomOption_' .. i] ~= 'None' then
                    randomOptionProp[itemObj['RandomOption_' .. i]] = itemObj['RandomOptionValue_' .. i];
                end
            end
            for i = 1, #list do
                local propName = list[i];
                local propValue = TryGetProp(class, propName, 0);
                local needToShow = true;
                for j = 1, #basicTooltipPropList do
                    if basicTooltipPropList[j] == propName then
                        needToShow = false;
                    end
                end
                if needToShow == true and propValue ~= 0 and randomOptionProp[propName] == nil then -- 랜덤 옵션이랑 겹치는 프로퍼티는 여기서 출력하지 않음
                    if itemObj.GroupName == 'Weapon' then
                        if propName ~= "MINATK" and propName ~= 'MAXATK' then
                            local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue);
                            SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                        end
                    elseif itemObj.GroupName == 'Armor' then
                        if itemObj.ClassType == 'Gloves' then
                            if propName ~= "HR" then
                                local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue);
                                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                            end
                        elseif itemObj.ClassType == 'Boots' then
                            if propName ~= "DR" then
                                local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue);
                                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                            end
                        else
                            if propName ~= "DEF" then
                                local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue);
                                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                            end
                        end
                    else
                        local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue);
                        SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                    end
                end
            end
            for i = 1, 3 do
                local propName = "HatPropName_" .. i;
                local propValue = "HatPropValue_" .. i;
                if itemObj[propValue] ~= 0 and itemObj[propName] ~= "None" then
                    local opName
                    if string.find(itemObj[propName], 'ALLSKILL_') == nil then
                        opName = string.format("[%s] %s", ClMsg("EnchantOption"), ScpArgMsg(itemObj[propName]));
                    else
                        local job = StringSplit(itemObj[propName], '_')[2]
                        if job == 'ShadowMancer' then
                            job = 'Shadowmancer'
                        end
                        opName = string.format("[%s] %s", ClMsg("EnchantOption"),
                            ScpArgMsg(job) .. ' ' .. ScpArgMsg('skill_lv_up_by_count'));
                    end
                    local strInfo = ABILITY_DESC_PLUS(opName, itemObj[propValue]);
                    SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                end
            end
            for i = 1, maxRandomOptionCnt do
                local propGroupName = "RandomOptionGroup_" .. i;
                local propName = "RandomOption_" .. i;
                local propValue = "RandomOptionValue_" .. i;
                local clientMessage = 'None'
                local propItem = originalItemObj
                if propItem[propGroupName] == 'ATK' then
                    clientMessage = 'ItemRandomOptionGroupATK'
                elseif propItem[propGroupName] == 'DEF' then
                    clientMessage = 'ItemRandomOptionGroupDEF'
                elseif propItem[propGroupName] == 'UTIL_WEAPON' then
                    clientMessage = 'ItemRandomOptionGroupUTIL'
                elseif propItem[propGroupName] == 'UTIL_ARMOR' then
                    clientMessage = 'ItemRandomOptionGroupUTIL'
                elseif propItem[propGroupName] == 'UTIL_SHILED' then
                    clientMessage = 'ItemRandomOptionGroupUTIL'
                elseif propItem[propGroupName] == 'STAT' then
                    clientMessage = 'ItemRandomOptionGroupSTAT'
                elseif propItem[propGroupName] == 'SPECIAL' then
                    clientMessage = 'ItemRandomOptionGroupSPECIAL'
                end
                if propItem[propValue] ~= 0 and propItem[propName] ~= "None" then
                    local opName = string.format("%s %s", ClMsg(clientMessage), ScpArgMsg(propItem[propName]));
                    local strInfo = ABILITY_DESC_NO_PLUS(opName, propItem[propValue], 0);
                    SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                end
            end
            local function _CREATE_SEAL_OPTION(parent, ypos, width, height, option, optionValue, idx, xMargin)
                local richtext = parent:CreateControl('richtext', 'OPTION_' .. idx, xMargin, ypos, width - 10, height);
                local str = string.format('{img tooltip_attribute2 20 20} %d%s : %s', idx, ClMsg('Step'),
                    GET_OPTION_VALUE_OR_PERCECNT_STRING(option, optionValue));
                richtext:SetTextFixWidth(1);
                richtext:EnableTextOmitByWidth(1);
                richtext:SetText(str);
                richtext:SetFontName('white_16_b_ol');
                ypos = ypos + height;
                return ypos;
            end
            _CREATE_SEAL_OPTION(ctrlSet, itemObj);
            for i = 1, #list2 do
                local propName = list2[i];
                local propValue = TryGetProp(itemObj, propName, 0);
                if propValue ~= 0 then
                    local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue);
                    SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                end
            end
            if itemObj.OptDesc ~= nil and itemObj.OptDesc ~= 'None' then
                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, itemObj.OptDesc);
            end
            if originalItemObj['RandomOptionRareValue'] ~= 0 and originalItemObj['RandomOptionRare'] ~= "None" then
                local strInfo = _GET_RANDOM_OPTION_RARE_CLIENT_TEXT(originalItemObj['RandomOptionRare'],
                    originalItemObj['RandomOptionRareValue'], '');
                if strInfo ~= nil then
                    SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                end
            end
            if inheritanceItem == nil then
                if itemObj.IsAwaken == 1 then
                    local opName = string.format("[%s] %s", ClMsg("AwakenOption"), ScpArgMsg(itemObj.HiddenProp));
                    local strInfo = ABILITY_DESC_PLUS(opName, itemObj.HiddenPropValue);
                    SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                end
            else
                if inheritanceItem.IsAwaken == 1 then
                    local opName =
                        string.format("[%s] %s", ClMsg("AwakenOption"), ScpArgMsg(inheritanceItem.HiddenProp));
                    local strInfo = ABILITY_DESC_PLUS(opName, inheritanceItem.HiddenPropValue);
                    SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                end
            end
            if itemObj.ReinforceRatio > 100 then
                local opName = ClMsg("ReinforceOption");
                local strInfo = ABILITY_DESC_PLUS(opName, math.floor(10 * itemObj.ReinforceRatio / 100));
                SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
            end
        end
        local goddessIcor = string.find(itemObj.StringArg, "GoddessIcor")
        if goddessIcor ~= nil then
            local maxRandomOptionCnt = MAX_OPTION_EXTRACT_COUNT;
            local randomOptionProp = {};
            for i = 1, maxRandomOptionCnt do
                if itemObj['RandomOption_' .. i] ~= 'None' then
                    randomOptionProp[itemObj['RandomOption_' .. i]] = itemObj['RandomOptionValue_' .. i];
                end
            end
            for j = 1, maxRandomOptionCnt do
                local propGroupName = "RandomOptionGroup_" .. j;
                local propName = "RandomOption_" .. j;
                local propValue = "RandomOptionValue_" .. j;
                local clientMessage = 'None'
                local propItem = originalItemObj
                if propItem[propGroupName] == 'ATK' then
                    clientMessage = 'ItemRandomOptionGroupATK'
                elseif propItem[propGroupName] == 'DEF' then
                    clientMessage = 'ItemRandomOptionGroupDEF'
                elseif propItem[propGroupName] == 'UTIL_WEAPON' then
                    clientMessage = 'ItemRandomOptionGroupUTIL'
                elseif propItem[propGroupName] == 'UTIL_ARMOR' then
                    clientMessage = 'ItemRandomOptionGroupUTIL'
                elseif propItem[propGroupName] == 'UTIL_SHILED' then
                    clientMessage = 'ItemRandomOptionGroupUTIL'
                elseif propItem[propGroupName] == 'STAT' then
                    clientMessage = 'ItemRandomOptionGroupSTAT'
                elseif propItem[propGroupName] == 'SPECIAL' then
                    clientMessage = 'ItemRandomOptionGroupSPECIAL'
                end
                if propItem[propValue] ~= 0 and propItem[propName] ~= "None" then
                    local opName = string.format("%s %s", ClMsg(clientMessage), ScpArgMsg(propItem[propName]));
                    local strInfo = ABILITY_DESC_NO_PLUS(opName, propItem[propValue], 0);
                    if not string.find(opName, "_bless_") and string.find(itemObj.StringArg, "EP17") then
                        local tag_part = string.match(strInfo, "({.-})")
                        local number_part = string.gsub(string.match(strInfo, "([%+%,%d]+)$"), ",", "")
                        number_part = tonumber(number_part)
                        local middle_part = strInfo
                        if tag_part then
                            middle_part = string.gsub(middle_part, "({.-})", "", 1)
                        end
                        if number_part then
                            middle_part = string.gsub(middle_part, "([%+%,%d]+)$", "", 1)
                        end
                        middle_part = string.gsub(middle_part, "!@#$PropUp#@!", "")
                        middle_part = middle_part:match("^%s*(.-)%s*$")
                        local pattern = "^%!@#%$(.-)%#@%!$"
                        local extracted_text = string.match(middle_part, pattern)
                        local per_text = ""
                        for i, row_data in ipairs(icor_table) do
                            local op_name = row_data[1]
                            if extracted_text == op_name then
                                if string.find(itemObj.StringArg, "Weapon") then
                                    local op_break_limit = row_data[3]
                                    local op_max = row_data[4]
                                    local per = string.sub(tonumber(propItem[propValue]) / op_max * 100, 1, 4) .. "%"
                                    if g.settings.max_value == 1 then
                                        per_text = "{nl}{@st66}{s10}  (" .. per .. "/" .. GET_COMMAED_STRING(op_max) ..
                                                       ")"
                                    else
                                        per_text = "{nl}{@st66}{s12}  (" .. per .. ")"
                                    end
                                    local optionText = GET_CHILD_RECURSIVELY(ctrlSet, "randomoption_" .. j - 1)
                                    optionText:Resize(250, 36)
                                    if number_part == op_break_limit then
                                        number_part = "{#9932CC}{ol}" .. GET_COMMAED_STRING(number_part) .. "{/}{/}"
                                    elseif number_part == op_max then
                                        number_part = "{#98FB98}{ol}" .. GET_COMMAED_STRING(number_part) .. "{/}{/}"
                                    elseif number_part >= math.ceil(op_max * 0.9) then
                                        number_part = "{#FFA500}{ol}" .. GET_COMMAED_STRING(number_part) .. "{/}{/}"
                                    else
                                        number_part = GET_COMMAED_STRING(number_part)
                                    end
                                elseif string.find(itemObj.StringArg, "Armor") then
                                    local op_break_limit = row_data[5]
                                    local op_max = row_data[6]
                                    local per = string.sub(tonumber(propItem[propValue]) / op_max * 100, 1, 4) .. "%"
                                    if g.settings.max_value == 1 then
                                        per_text = "{nl}{@st66}{s10}  (" .. per .. "/" .. GET_COMMAED_STRING(op_max) ..
                                                       ")"
                                    else
                                        per_text = "{nl}{@st66}{s12}  (" .. per .. ")"
                                    end
                                    local optionText = GET_CHILD_RECURSIVELY(ctrlSet, "randomoption_" .. j - 1)
                                    optionText:Resize(250, 36)
                                    if number_part == op_break_limit then
                                        number_part = "{#9932CC}{ol}" .. GET_COMMAED_STRING(number_part) .. "{/}{/}"
                                    elseif number_part == op_max then
                                        number_part = "{#98FB98}{ol}" .. GET_COMMAED_STRING(number_part) .. "{/}{/}"
                                    elseif number_part >= math.ceil(op_max * 0.9) then
                                        number_part = "{#FFA500}{ol}" .. GET_COMMAED_STRING(number_part) .. "{/}{/}"
                                    else
                                        number_part = GET_COMMAED_STRING(number_part)
                                    end
                                end
                            end
                        end
                        strInfo = number_part .. "" .. tag_part .. "" .. middle_part .. per_text
                    end
                    SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                end
            end
        end
        if cid == marketItem:GetSellerCID() then
            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(0)
            buyBtn:SetEnable(0);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(1)
            cancelBtn:SetEnable(1)
            if USE_MARKET_REPORT == 1 then
                local reportBtn = GET_CHILD_RECURSIVELY(ctrlSet, "reportBtn");
                reportBtn:SetEnable(0);
            end
            local totalPrice_num = GET_CHILD_RECURSIVELY(ctrlSet, "totalPrice_num");
            totalPrice_num:SetTextByKey("value", 0);
            local totalPrice_text = GET_CHILD_RECURSIVELY(ctrlSet, "totalPrice_text");
            totalPrice_text:SetTextByKey("value", 0);
        else
            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(1)
            buyBtn:SetEnable(1);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(0)
            cancelBtn:SetEnable(0)
            MARKET_CTRLSET_SET_TOTAL_PRICE(ctrlSet, marketItem);
        end
        ctrlSet:SetUserValue("sellPrice", marketItem:GetSellPrice());
    end
    local ITEM_CTRLSET_INTERVAL_Y_MARGIN = tonumber(frame:GetUserConfig('ITEM_CTRLSET_INTERVAL_Y_MARGIN'));
    GBOX_AUTO_ALIGN(itemlist, 4, ITEM_CTRLSET_INTERVAL_Y_MARGIN, 0, true, false);
    local function MARKET_SET_PAGE_CONTROL(frame, pageControl)
        local category, _category, _subCategory = GET_CATEGORY_STRING(frame);
        local itemCntPerPage = GET_MARKET_SEARCH_ITEM_COUNT(_category);
        local maxPage = math.ceil(session.market.GetTotalCount() / itemCntPerPage);
        local curPage = session.market.GetCurPage();
        local pageController = GET_CHILD(frame, pageControl, 'ui::CPageController')
        if maxPage < 1 then
            maxPage = 1;
        end
        pageController:SetMaxPage(maxPage);
        pageController:SetCurPage(curPage);
    end
    MARKET_SET_PAGE_CONTROL(frame, "pagecontrol")
end

function market_favorite_rebuild_MARKET_INIT_OPTION_GROUP_DROPLIST(my_frame, my_msg)
    local dropList = g.get_event_args(my_msg)
    local frame = ui.GetFrame("market")
    local optionGroupSet = GET_CHILD_RECURSIVELY(frame, 'optionGroupSet');
    local curSelectCnt = optionGroupSet:GetUserIValue('ADD_SELECT_COUNT');
    local childIdx = curSelectCnt - 1
    local selectSet = GET_CHILD_RECURSIVELY(optionGroupSet, 'SELECT_' .. childIdx)
    if selectSet then
        local minEdit = GET_CHILD_RECURSIVELY(selectSet, 'minEdit');
        if minEdit and minEdit:GetText() == "" then
            minEdit:SetText('0');
        end
    end
end

function market_favorite_rebuild_MARKET_SELL_REGISTER(my_frame, my_msg)
    local parent, ctrl = g.get_event_args(my_msg)
    local count = session.market.GetItemCount();
    local userType = session.loginInfo.GetPremiumState();
    local maxCount = GetCashValue(userType, "marketUpMax");
    if true == session.loginInfo.IsPremiumState(ITEM_TOKEN) then
        local tokenCnt = GetCashValue(ITEM_TOKEN, "marketUpMax");
        if tokenCnt > maxCount then
            maxCount = tokenCnt;
        end
    end
    if count + 1 > maxCount then
        ui.SysMsg(ClMsg("MarketRegitCntOver"));
        return;
    end
    local frame = parent:GetTopParentFrame();
    local groupbox = frame:GetChild("groupbox");
    local slot_item = GET_CHILD_RECURSIVELY(groupbox, "slot_item", "ui::CSlot");
    local edit_count = GET_CHILD_RECURSIVELY(groupbox, "edit_count");
    local edit_price = GET_CHILD_RECURSIVELY(groupbox, "edit_price");
    local invitem = GET_SLOT_ITEM(slot_item);
    if invitem == nil then
        return;
    end
    local count = tonumber(edit_count:GetText());
    local price = GET_NOT_COMMAED_NUMBER(edit_price:GetText());
    if price < 100 then
        ui.SysMsg(ClMsg("SellPriceMustOverThen100Silver"));
        return;
    end
    local limitMoneyStr = GET_REMAIN_MARKET_TRADE_AMOUNT_STR();
    if limitMoneyStr == nil then
        ui.SysMsg(ClMsg('LoadingTradeLimitAmount'));
        return;
    end
    if IsGreaterThanForBigNumber(math.mul_int_for_lua(price, count), limitMoneyStr) == 1 then
        ui.SysMsg(ScpArgMsg('MarketMaxSilverLimit{LIMIT}Over', 'LIMIT', GET_COMMAED_STRING(limitMoneyStr)));
        return;
    end
    local strprice = tostring(price);
    if string.len(strprice) < 3 then
        return
    end
    local floorprice = strprice.sub(strprice, 0, 2);
    for i = 0, string.len(strprice) - 3 do
        floorprice = floorprice .. "0"
    end
    if strprice ~= floorprice then
        edit_price:SetText(GET_COMMAED_STRING(floorprice));
        ui.SysMsg(ScpArgMsg("AutoAdjustToMinPrice"));
        price = tonumber(floorprice);
        local sellPriceGbox = GET_CHILD_RECURSIVELY(frame, 'sellPriceGbox');
        local priceText = GET_CHILD(sellPriceGbox, 'priceText');
        priceText:SetTextByKey('priceText', GetMonetaryString(floorprice));
    end
    if count <= 0 then
        ui.SysMsg(ClMsg("SellCountMustOverThenZeo"));
        return;
    end
    local isPrivate = GET_CHILD_RECURSIVELY(groupbox, "isPrivate", "ui::CCheckBox");
    local itemGuid = invitem:GetIESID();
    local obj = GetIES(invitem:GetObject());
    local radioCtrl = GET_CHILD_RECURSIVELY(frame, "feePerTime_1")
    local selecIndex = GET_RADIOBTN_NUMBER(radioCtrl) - 1;
    local needTime = frame:GetUserIValue('TIME_' .. selecIndex);
    local free = tonumber(frame:GetUserValue('FREE_' .. selecIndex));
    local registerFeeValueCtrl = GET_CHILD_RECURSIVELY(frame, "registerFeeValue");
    local commission = registerFeeValueCtrl:GetTextByKey("value")
    commission = string.gsub(commission, ",", "")
    commission = math.max(tonumber(commission), 1);
    if IsGreaterThanForBigNumber(commission, GET_TOTAL_MONEY_STR()) == 1 then
        ui.SysMsg(ClMsg("Auto_SilBeoKa_BuJogHapNiDa."));
        return;
    end
    UPDATE_FEE_INFO(frame, free, count, price)
    local sellPriceGbox = GET_CHILD_RECURSIVELY(groupbox, "sellPriceGbox");
    local down = sellPriceGbox:GetChild("minPrice");
    local minPrice = down:GetTextByKey("value");
    local iminPrice = GET_NOT_COMMAED_NUMBER(minPrice);
    local iPrice = tonumber(price);
    if IGNORE_ITEM_AVG_TABLE_FOR_TOKEN == 1 then
        if false == session.loginInfo.IsPremiumState(ITEM_TOKEN) then
            if 0 ~= iminPrice and iPrice < iminPrice then
                ui.SysMsg(ScpArgMsg("PremiumRegMinPrice{Price}", "Price", minPrice));
                return;
            end
        end
    else
        if 0 ~= iminPrice and iPrice < iminPrice then
            ui.SysMsg(ScpArgMsg("PremiumRegMinPrice{Price}", "Price", minPrice));
            return;
        end
    end
    if obj.ClassName == "PremiumToken" and iPrice < tonumber(TOKEN_MARKET_REG_LIMIT_PRICE) then
        ui.SysMsg(ScpArgMsg("PremiumRegMinPrice{Price}", "Price", TOKEN_MARKET_REG_LIMIT_PRICE));
        return;
    end
    if obj.ClassName == "PremiumToken" and iPrice > tonumber(TOKEN_MARKET_REG_MAX_PRICE) then
        ui.SysMsg(ScpArgMsg("PremiumRegMaxPrice{Price}", "Price", TOKEN_MARKET_REG_MAX_PRICE));
        return;
    end
    if true == invitem.isLockState then
        ui.SysMsg(ClMsg("MaterialItemIsLock"));
        return false;
    end
    local invframe = ui.GetFrame("inventory");
    if true == IS_TEMP_LOCK(invframe, invitem) then
        ui.SysMsg(ClMsg("MaterialItemIsLock"));
        return false;
    end
    local itemProp = geItemTable.GetProp(obj.ClassID);
    local pr = TryGetProp(obj, "PR");
    local noTradeCnt = TryGetProp(obj, "BelongingCount");
    local tradeCount = invitem.count
    if nil ~= noTradeCnt and 0 < tonumber(noTradeCnt) then
        local wareItem = nil;
        if obj.MaxStack > 1 then
            wareItem = session.GetWarehouseItemByType(obj.ClassID);
        end
        local wareCnt = 0;
        if nil ~= wareItem then
            wareCnt = wareItem.count;
        end
        tradeCount = (invitem.count + wareCnt) - tonumber(noTradeCnt);
        if tradeCount <= 0 then
            ui.AlarmMsg("ItemIsNotTradable");
            return false;
        end
    end
    if itemProp:IsEnableMarketTrade() == false or itemProp:IsMoney() == true or
        ((pr ~= nil and pr < 1) and itemProp:NeedCheckPotential() == true) then
        ui.AlarmMsg("ItemIsNotTradable");
        return false;
    end
    if false == session.loginInfo.IsPremiumState(ITEM_TOKEN) then
        local maxPrice = GET_CHILD_RECURSIVELY(frame, "maxPrice");
        local maxPriceStr = GET_NOT_COMMAED_NUMBER(maxPrice:GetTextByKey('value'), true);
        if tonumber(maxPriceStr) ~= 0 and IsGreaterThanForBigNumber(floorprice, maxPriceStr) == 1 then
            ui.SysMsg(ClMsg('MaxAllowPriceError'));
            return false;
        end
    end
    local clsid = obj.ClassID
    local yesScp = string.format("market_favorite_rebuild_req_register_item(\'%s\', %s, %d, 1, %d,%d)", itemGuid,
        floorprice, count, needTime, clsid);
    commission = registerFeeValueCtrl:GetTextByKey("value");
    commission = string.gsub(commission, ",", "");
    commission = math.max(tonumber(commission), 1);
    if nil ~= obj and obj.ItemType == 'Equip' then
        if 0 < obj.BuffValue then
            ui.MsgBox(ScpArgMsg("BuffDestroy{Price}", "Price", tostring(commission)), yesScp, "None");
        else
            ui.MsgBox(ScpArgMsg("CommissionRegMarketItem{Price}", "Price", GetMonetaryString(commission)), yesScp,
                "None");
        end
    else
        ui.MsgBox(ScpArgMsg("CommissionRegMarketItem{Price}", "Price", GetMonetaryString(commission)), yesScp, "None");
    end
end

function market_favorite_rebuild_req_register_item(itemGuid, floorprice, count, _, needTime, clsid)
    local server_time_str = date_time.get_lua_now_datetime_str() -- "YYYY-MM-DD HH:MM:SS"
    local year, month, day, hour, min = server_time_str:match("(%d+)-(%d+)-(%d+) (%d+):(%d+)")
    local formatted_time = ""
    if year then
        local short_year = string.sub(year, 3, 4)
        formatted_time = string.format("%s-%s-%s %s:%s", short_year, month, day, hour, min)
    else
        formatted_time = server_time_str
    end
    local data = {
        iesid = itemGuid,
        clsid = clsid,
        price = floorprice,
        count = count,
        time = needTime,
        register_time = formatted_time,
        status = "selling"
    }
    table.insert(g.settings.sell_items[g.login_name], data)
    g.item_index = #g.settings.sell_items[g.login_name]
    market.ReqRegisterItem(itemGuid, tonumber(floorprice), tonumber(count), 1, tonumber(needTime))
end

function market_favorite_rebuild_ON_CABINET_ITEM_LIST(my_frame, my_msg)
    local frame = g.get_event_args(my_msg)
    local itemGbox = GET_CHILD(frame, "itemGbox");
    local itemlist = GET_CHILD(itemGbox, "itemlist", "ui::CDetailListBox");
    itemlist:RemoveAllChild();
    local cnt = session.market.GetCabinetItemCount();
    local sysTime = geTime.GetServerSystemTime();
    local cab_items = {}
    for i = 0, cnt - 1 do
        local cabinetItem = session.market.GetCabinetItemByIndex(i)
        local item_id = tostring(cabinetItem:GetItemID())
        cab_items[item_id] = cabinetItem:GetWhereFrom()
    end
    local clean_items = {}
    if g.settings.sell_items and g.settings.sell_items[g.login_name] then
        for _, saved_item in ipairs(g.settings.sell_items[g.login_name]) do
            if cab_items[saved_item.iesid] then
                saved_item.status = cab_items[saved_item.iesid]
                table.insert(clean_items, saved_item)
            elseif saved_item.status == 'selling' then
                table.insert(clean_items, saved_item)
            end
        end
    end
    g.settings.sell_items[g.login_name] = clean_items
    market_favorite_rebuild_SAVE_SETTINGS()
    for i = 0, cnt - 1 do
        local cabinetItem = session.market.GetCabinetItemByIndex(i);
        local itemID = cabinetItem:GetItemID();
        local itemObj = GetIES(cabinetItem:GetObject());
        local registerTime = cabinetItem:GetRegSysTime();
        local difSec = imcTime.GetDifSec(registerTime, sysTime);
        if 0 >= difSec then
            difSec = 0;
        end
        local timeString = GET_TIME_TXT(difSec);
        local refreshScp = itemObj.RefreshScp;
        if refreshScp ~= "None" then
            refreshScp = _G[refreshScp];
            refreshScp(itemObj);
        end
        local ctrlSet = INSERT_CONTROLSET_DETAIL_LIST(itemlist, i, 0, "market_cabinet_item_detail");
        ctrlSet:Resize(itemlist:GetWidth() - 20, ctrlSet:GetHeight());
        AUTO_CAST(ctrlSet);
        local BUY_SUCCESS_IMAGE = ctrlSet:GetUserConfig('BUY_SUCCESS_IMAGE');
        local SELL_SUCCESS_IMAGE = ctrlSet:GetUserConfig('SELL_SUCCESS_IMAGE');
        local SELL_CANCEL_IMAGE = ctrlSet:GetUserConfig('SELL_CANCEL_IMAGE');
        local DEFAULT_TYPE_IMAGE = ctrlSet:GetUserConfig('DEFAULT_TYPE_IMAGE');
        local BUY_SUCCESS_TEXT_STYLE = ctrlSet:GetUserConfig('BUY_SUCCESS_TEXT_STYLE');
        local SELL_SUCCESS_TEXT_STYLE = ctrlSet:GetUserConfig('SELL_SUCCESS_TEXT_STYLE');
        local SELL_CANCEL_TEXT_STYLE = ctrlSet:GetUserConfig('SELL_CANCEL_TEXT_STYLE');
        local typeBox = GET_CHILD_RECURSIVELY(ctrlSet, 'typeBox');
        local typeText = typeBox:GetChild('typeText');
        AUTO_CAST(typeText)
        local whereFrom = cabinetItem:GetWhereFrom();
        ctrlSet:SetUserValue('CABINET_TYPE', whereFrom);
        if whereFrom == 'market_sell' then -- 판매 완료
            typeText:SetTextByKey('type', ClMsg('SellSuccess'));
        elseif whereFrom == 'market_buy' then -- 구매 완료
            typeText:SetTextByKey('type', ClMsg('BuySuccess'));
        elseif whereFrom == 'market_cancel' or whereFrom == 'market_expire' then -- 판매 취소, 판매 기한 완료
            typeText:SetTextByKey('type', ClMsg('SellCancel'));
        end
        local pic = GET_CHILD(ctrlSet, "pic", "ui::CSlot");
        local itemImage = GET_ITEM_ICON_IMAGE(itemObj);
        local icon = CreateIcon(pic)
        local iconInfo = icon:GetInfo();
        SET_SLOT_ITEM_CLS(pic, itemObj)
        icon:SetImage(itemImage);
        SET_SLOT_STYLESET(pic, itemObj)
        if itemObj.ClassName ~= MONEY_NAME and itemObj.MaxStack > 1 then
            if whereFrom == "market_sell" then
                SET_SLOT_COUNT_TEXT(pic, cabinetItem.sellItemAmount, '{s16}{ol}{b}');
            elseif whereFrom ~= "market_sell" then
                SET_SLOT_COUNT_TEXT(pic, cabinetItem.count or tonumber(cabinetItem:GetCount()), '{s16}{ol}{b}');
            end
        end
        local name = ctrlSet:GetChild("name");
        name:SetTextByKey("value", GET_FULL_NAME(itemObj));
        local etcBox = GET_CHILD_RECURSIVELY(ctrlSet, 'etcBox');
        local etcShow = false;
        if whereFrom ~= 'market_sell' and whereFrom ~= 'market_buy' and itemObj.ClassName ~= MONEY_NAME then
            local etcText = etcBox:GetChild('etcText');
            etcText:SetTextByKey('count', cabinetItem.count or tonumber(cabinetItem:GetCount()));
            etcBox:ShowWindow(1);
            etcShow = true;
        else
            etcBox:ShowWindow(0);
        end
        local timeBox = GET_CHILD_RECURSIVELY(ctrlSet, 'timeBox');
        local endTime = timeBox:GetChild("endTime");
        if (etcShow == true and difSec <= 0) or whereFrom ~= 'market_sell' then
            timeBox:ShowWindow(0);
        else
            endTime:SetTextByKey("value", timeString);
            if 0 == difSec then
                endTime:SetTextByKey("value", ClMsg("Auto_JongLyo"));
            else
                endTime:SetUserValue("REMAINSEC", difSec);
                endTime:SetUserValue("STARTSEC", imcTime.GetAppTime());
                SHOW_REMAIN_NEXT_TIME_GET_CABINET(medalFreeTime);
                endTime:RunUpdateScript("SHOW_REMAIN_NEXT_TIME_GET_CABINET");
            end
        end
        local totalPrice = GET_CHILD_RECURSIVELY(ctrlSet, "totalPrice"); -- 10,000 처럼 표기
        local totalPriceStr = GET_CHILD_RECURSIVELY(ctrlSet, "totalPriceStr"); -- 1만    처럼 표기
        if itemObj.ClassName == MONEY_NAME or (whereFrom == 'market_sell' and etcShow == false) then
            local count = cabinetItem.count or tonumber(cabinetItem:GetCount())
            if count and count < 70 then
                ClientRemoteLog("CABINET_ITEM_PRICE_ERROR - " .. cabinetItem.count or tonumber(cabinetItem:GetCount()));
            end
            local amount = tonumber(cabinetItem:GetCount())
            totalPrice:SetTextByKey("value", GET_COMMAED_STRING(amount));
            totalPriceStr:SetTextByKey("value", GetMonetaryString(amount));
        else
            totalPrice:ShowWindow(0);
            totalPriceStr:ShowWindow(0);
        end
        SET_ITEM_TOOLTIP_ALL_TYPE(ctrlSet, cabinetItem, itemObj.ClassName, "cabinet", cabinetItem.itemType,
            cabinetItem:GetItemID());
        local btn = GET_CHILD(ctrlSet, "btn");
        btn:SetTextByKey("value", ClMsg("Receieve"));
        btn:UseOrifaceRectTextpack(true)
        btn:SetEventScript(ui.LBUTTONUP, "CABINET_ITEM_BUY");
        btn:SetEventScriptArgString(ui.LBUTTONUP, cabinetItem:GetItemID());
        if 0 >= difSec or whereFrom ~= 'market_sell' then
            btn:SetEnable(1);
        else
            btn:SetEnable(0);
        end
        if whereFrom == 'market_cancel' or whereFrom == 'market_expire' then -- 판매 취소, 판매 기한 완료
            for index, data in ipairs(g.settings.sell_items[g.login_name]) do
                local iesid = data.iesid
                if tostring(itemID) == iesid then
                    local register_time = data.register_time
                    local price = data.price
                    local count = data.count
                    local period = data.time
                    local temp_text = g.lang == "Japanese" and "{ol}登録日: " .. register_time ..
                                          "{nl}販売期間: " .. period .. "日{nl}販売単価: " .. price ..
                                          "{nl}販売個数: " .. count or "{ol}Reg. Date: " .. register_time ..
                                          "{nl}Sales Period: " .. period .. " Days{nl}Unit Price: " .. price ..
                                          "{nl}Quantity: " .. count
                    typeText:SetTextTooltip(temp_text)
                    btn:SetTextTooltip(temp_text)
                    break
                end
            end
        end
    end
    GBOX_AUTO_ALIGN(itemlist:GetGroupBox(), 3, 0, 0, true, true);
    itemlist:RealignItems();
    local buySuccessCheckBox = GET_CHILD_RECURSIVELY(frame, 'buySuccessCheckBox');
    local sellSuccessCheckBox = GET_CHILD_RECURSIVELY(frame, 'sellSuccessCheckBox');
    local sellCancelCheckBox = GET_CHILD_RECURSIVELY(frame, 'sellCancelCheckBox');
    local etcCheckBox = GET_CHILD_RECURSIVELY(frame, 'etcCheckBox');
    buySuccessCheckBox:SetCheck(1);
    sellSuccessCheckBox:SetCheck(1);
    sellCancelCheckBox:SetCheck(1);
    etcCheckBox:SetCheck(1);
    MARKET_CABINET_FILTER(frame);
end

function market_favorite_rebuild_ON_MARKET_SELL_LIST(my_frame, my_msg)
    local frame, msg, argStr, argNum = g.get_event_args(my_msg)
    if msg == MARKET_ITEM_LIST then
        local str = GET_TIME_TXT(argNum);
        ui.SysMsg(ScpArgMsg("MarketCabinetAfter{TIME}", "Time", str));
        if frame:IsVisible() == 0 then
            return;
        end
    end
    local itemlist = GET_CHILD(frame, "itemlist", "ui::CDetailListBox");
    itemlist:RemoveAllChild();
    local sysTime = geTime.GetServerSystemTime();
    local count = session.market.GetItemCount();
    local live_guids = {}
    for i = 0, count - 1 do
        local marketItem = session.market.GetItemByIndex(i);
        local itemObj = GetIES(marketItem:GetObject());
        local refreshScp = itemObj.RefreshScp;
        if refreshScp ~= "None" then
            refreshScp = _G[refreshScp];
            refreshScp(itemObj);
        end
        local ctrlSet = INSERT_CONTROLSET_DETAIL_LIST(itemlist, i, 0, "market_sell_item_detail");
        local pic = GET_CHILD(ctrlSet, "pic", "ui::CSlot");
        local imgName = GET_ITEM_ICON_IMAGE(itemObj);
        local icon = CreateIcon(pic)
        SET_SLOT_ITEM_CLS(pic, itemObj)
        icon:SetImage(imgName);
        SET_SLOT_STYLESET(pic, itemObj)
        if itemObj.MaxStack > 1 then
            SET_SLOT_COUNT_TEXT(pic, marketItem.count, '{s16}{ol}{b}');
        end
        local nameCtrl = ctrlSet:GetChild("name");
        nameCtrl:SetTextByKey("value", GET_FULL_NAME(itemObj));
        local totalPriceCtrl = ctrlSet:GetChild("totalPrice");
        local totalPriceValue = math.mul_int_for_lua(marketItem:GetSellPrice(), marketItem.count);
        local totalPrice = GET_COMMAED_STRING(totalPriceValue);
        totalPriceCtrl:SetTextByKey("value", totalPrice);
        local totalPriceStrCtrl = ctrlSet:GetChild("totalPriceStr");
        local totalPriceStr = GetMonetaryString(totalPriceValue);
        totalPriceStrCtrl:SetTextByKey("value", totalPriceStr);
        local remainTimeCtrl = ctrlSet:GetChild("remainTime");
        if marketItem:IsWatingForRegister() == true then
            remainTimeCtrl:SetTextByKey("value", ClMsg("PleaseWaiting"));
        else
            local endSYSTime = marketItem:GetEndTime();
            local difSec = imcTime.GetDifSec(endSYSTime, sysTime);
            remainTimeCtrl:SetUserValue("REMAINSEC", difSec);
            remainTimeCtrl:SetUserValue("STARTSEC", imcTime.GetAppTime());
            remainTimeCtrl:RunUpdateScript("SHOW_REMAIN_MARKET_SELL_TIME");
        end
        local cashValue = GetCashValue(marketItem.premuimState, "marketSellCom") * 0.01;
        local stralue = GetCashValue(marketItem.premuimState, "marketSellCom");
        local feeValueCtrl = ctrlSet:GetChild("feeValue");
        local feeValue = math.floor(math.mul_int_for_lua(totalPriceValue, cashValue));
        local feeStr = GET_COMMAED_STRING(feeValue);
        feeValueCtrl:SetTextByKey("value", feeStr);
        local feeValueStrCtrl = ctrlSet:GetChild("feeValueStr");
        local feeValueStr = GetMonetaryString(feeValue);
        feeValueStrCtrl:SetTextByKey("value", feeValueStr);
        if msg == "MARKET_SELL_LIST" then
            live_guids[tostring(marketItem:GetMarketGuid())] = true
            if not g.temp_tbl[tostring(marketItem:GetMarketGuid())] then
                if not g.settings.sell_items then
                    g.settings.sell_items = {}
                end
                if not g.settings.sell_items[g.login_name] then
                    g.settings.sell_items[g.login_name] = {}
                end
                if g.settings.sell_items[g.login_name][g.item_index] then
                    g.settings.sell_items[g.login_name][g.item_index].market_guid = tostring(marketItem:GetMarketGuid())
                    g.item_index = nil
                end
            end
            g.temp_tbl[tostring(marketItem:GetMarketGuid())] = true
        end
        SET_ITEM_TOOLTIP_ALL_TYPE(ctrlSet, marketItem, itemObj.ClassName, "market", marketItem.itemType,
            marketItem:GetMarketGuid());
        local btn = GET_CHILD(ctrlSet, "btn");
        btn:SetTextByKey("value", ClMsg("Cancel"));
        btn:SetEventScript(ui.LBUTTONUP, "CANCEL_MARKET_ITEM");
        btn:SetEventScriptArgString(ui.LBUTTONUP, marketItem:GetMarketGuid());
    end
    if msg == "MARKET_SELL_LIST" then
        for _, saved_item in ipairs(g.settings.sell_items[g.login_name]) do
            if saved_item.market_guid and saved_item.status == 'selling' then
                local market_guid = saved_item.market_guid
                if not live_guids[market_guid] then
                    saved_item.status = "nothing"

                end
            end
        end
    end
    market_favorite_rebuild_SAVE_SETTINGS()
    itemlist:RealignItems();
    GBOX_AUTO_ALIGN(itemlist:GetGroupBox(), 2, 0, 0, false, true);
end

function market_favorite_rebuild_MARKET_BUYMODE(my_frame, my_msg)
    local frame = ui.GetFrame('market_favorite_rebuild')
    if g.settings.always == 1 then
        market_favorite_rebuild_TOGGLE_FRAME("true")
        frame:ShowWindow(1)
    end
end

function market_favorite_rebuild_MARKET_DELETE_SAVED_OPTION(my_frame, my_msg)
    local parent, ctrl = g.get_event_args(my_msg)
    local nameText = GET_CHILD(parent, 'nameText');
    session.market.DeleteCategoryConfig(nameText:GetText());
    MARKET_TRY_LOAD_CATEGORY_OPTION(parent);
    local delete_text = nameText:GetText()
    for i, key in ipairs(g.settings.searchs) do
        if key == delete_text then
            g.settings.searchs[i] = ""

            break
        end
    end
    market_favorite_rebuild_SAVE_SETTINGS()
    market_favorite_rebuild_TOGGLE_FRAME("true")
end

function market_favorite_rebuild_MARKET_SELL_FILTER_RESET(my_frame, my_msg)
    local frame = g.get_event_args(my_msg)
    local option = GET_CHILD_RECURSIVELY(frame, "marketfilter", "ui::CCheckBox");
    if option ~= nil and option:IsChecked() == 1 then
        option:SetCheck(0);
        ui.inventory.ApplyInventoryFilter("inventory", IVF_MARKET_TRADE, 0);
    end
end

function market_favorite_rebuild_MARKET_CLOSE(my_frame, my_msg)
    local market_favorite_rebuild = ui.GetFrame("market_favorite_rebuild")
    market_favorite_rebuild:ShowWindow(0)
end

function market_favorite_rebuild_MARKET_LOAD_CATEGORY_OPTION(parent, ctrl, configKey, left_or_right)
    if keyboard.IsKeyPressed('LSHIFT') == 1 and left_or_right == 2 then
        market_favorite_rebuild_delete_load_option(parent, ctrl, configKey)
        return
    end
    local market = ui.GetFrame("market")
    local optionBox = GET_CHILD_RECURSIVELY(market, 'optionBox')
    optionBox:ShowWindow(0)
    market_favorite_rebuild__MARKET_LOAD_CATEGORY_OPTION(market, configKey)
end

function market_favorite_rebuild__MARKET_LOAD_CATEGORY_OPTION(frame, configKey)
    frame = frame:GetTopParentFrame()
    local configText = session.market.GetCategoryConfig(configKey)
    if configText == nil or configText == '' then
        return false
    end
    local configList = StringSplit(configText, '@')
    local configTable = {}
    for i = 1, #configList do
        local config = configList[i]
        local idx = string.find(config, ':')
        if idx == nil then
            return false
        end
        local propName = string.sub(config, 0, idx - 1)
        local propValue = string.sub(config, idx + 1)
        configTable[propName] = propValue
    end
    local categoryStr = configTable['category']
    local underBarIdx = string.find(categoryStr, '_')
    local category = categoryStr
    local subCategory = ''
    if underBarIdx ~= nil then
        category = string.sub(categoryStr, 0, underBarIdx - 1)
        subCategory = string.sub(categoryStr, underBarIdx + 1)
    end
    if category == '' then
        category = 'IntegrateRetreive'
    end
    local categoryCtrlset = GET_CHILD_RECURSIVELY(frame, 'CATEGORY_' .. category)
    MARKET_CATEGORY_CLICK(categoryCtrlset, categoryCtrlset:GetChild('bgBox'), false, true)
    if subCategory ~= '' then
        local subCategoryCtrlset = GET_CHILD_RECURSIVELY(frame, 'SUB_CATE_' .. subCategory)
        if subCategoryCtrlset ~= nil then
            MARKET_SUB_CATEOGRY_CLICK(subCategoryCtrlset:GetParent(), subCategoryCtrlset, false)
        end
    end
    local checkIdx = configTable['order']
    local priceOrderCheck = GET_CHILD_RECURSIVELY(frame, 'priceOrderCheck_' .. checkIdx)
    priceOrderCheck:SetCheck(1)
    MARKET_UPDATE_PRICE_ORDER(frame, priceOrderCheck)
    local function GET_MINMAX_VALUE_BY_QUERY_STRING(queryString)
        local semiColonIdx = string.find(queryString, ';')
        local minValue = tonumber(string.sub(queryString, 0, semiColonIdx - 1))
        local maxValue = tonumber(string.sub(queryString, semiColonIdx + 1))
        minValue = math.max(minValue, 0)
        maxValue = math.max(maxValue, 0)
        return minValue, maxValue
    end
    if configTable['CT_UseLv'] ~= nil or configTable['Level'] ~= nil then
        local levelRangeSet = GET_CHILD_RECURSIVELY(frame, 'levelRangeSet')
        if levelRangeSet ~= nil and levelRangeSet:IsVisible() == 1 then
            local rangeValue = configTable['CT_UseLv']
            if configTable['Level'] ~= nil then
                rangeValue = configTable['Level']
            end
            local minValue, maxValue = GET_MINMAX_VALUE_BY_QUERY_STRING(rangeValue)
            local minEdit = GET_CHILD_RECURSIVELY(levelRangeSet, 'minEdit')
            local maxEdit = GET_CHILD_RECURSIVELY(levelRangeSet, 'maxEdit')
            minEdit:SetText(minValue)
            maxEdit:SetText(maxValue)
        end
    end
    local gradeCheckSet = GET_CHILD_RECURSIVELY(frame, 'gradeCheckSet')
    if gradeCheckSet ~= nil then
        local gradeChildCnt = gradeCheckSet:GetChildCount() -- init
        for i = 0, gradeChildCnt - 1 do
            local child = gradeCheckSet:GetChildByIndex(i)
            if string.find(child:GetName(), 'gradeCheck_') ~= nil then
                AUTO_CAST(child)
                child:SetCheck(0)
            end
        end
        if configTable['CT_ItemGrade'] ~= nil then
            if gradeCheckSet ~= nil and gradeCheckSet:IsVisible() == 1 then
                local checkValue = configTable['CT_ItemGrade']
                local checkValueList = nil
                if string.find(checkValue, ";") then
                    checkValueList = StringSplit(checkValue, ';')
                else
                    checkValueList = StringSplit(checkValue, '')
                end
                for i = 1, #checkValueList do
                    local gradeCheck = GET_CHILD(gradeCheckSet, 'gradeCheck_' .. checkValueList[i])
                    gradeCheck:SetCheck(1)
                end
            end
        end
    end
    local itemSearchSet = GET_CHILD_RECURSIVELY(frame, 'itemSearchSet')
    local searchEdit = GET_CHILD_RECURSIVELY(itemSearchSet, 'searchEdit')
    searchEdit:SetText(configTable['searchText'])
    if configTable['Random_Item'] ~= nil then
        local appCheckSet = GET_CHILD_RECURSIVELY(frame, 'appCheckSet')
        if appCheckSet ~= nil and appCheckSet:IsVisible() == 1 then
            local configValue = tonumber(configTable['Random_Item'])
            local checkCtrl = nil
            if configValue == 1 then
                checkCtrl = GET_CHILD(appCheckSet, 'appCheck_1')
            elseif configValue == 2 then
                checkCtrl = GET_CHILD(appCheckSet, 'appCheck_0')
            end
            if checkCtrl ~= nil then
                checkCtrl:SetCheck(1)
                MARKET_UPDATE_APPRAISAL_CHECK(checkCtrl:GetParent(), checkCtrl)
            end
        end
    end
    local function ALIGN_OPTION_GROUP_SET(optionGroupSet)
        local Y_ADD_MARGIN = 6
        local staticText = GET_CHILD(optionGroupSet, 'staticText')
        local ypos = staticText:GetY() + staticText:GetHeight() + Y_ADD_MARGIN
        local childCnt = optionGroupSet:GetChildCount()
        local visibleSelectChildCount = 0
        local visibleChild = nil
        for i = 0, childCnt - 1 do
            local child = optionGroupSet:GetChildByIndex(i)
            if string.find(child:GetName(), 'SELECT_') ~= nil then
                child:SetOffset(child:GetX(), ypos)
                visibleChild = child
                ypos = ypos + child:GetHeight()
                visibleSelectChildCount = visibleSelectChildCount + 1
            end
        end
        local addOptionBtn = GET_CHILD(optionGroupSet, 'addOptionBtn')
        addOptionBtn:SetOffset(0, ypos)
        ypos = ypos + addOptionBtn:GetHeight() + Y_ADD_MARGIN
        optionGroupSet:Resize(optionGroupSet:GetWidth(), ypos)
        return visibleSelectChildCount, visibleChild
    end
    local detailOptionSet = GET_CHILD_RECURSIVELY(frame, 'detailOptionSet')
    if detailOptionSet ~= nil and detailOptionSet:IsVisible() == 1 then
        local added = false
        for configName, configValue in pairs(configTable) do
            if IS_MARKET_DETAIL_SETTING_OPTION(configName) == true then
                local selectSet = MARKET_ADD_SEARCH_DETAIL_SETTING(detailOptionSet)
                local groupList = GET_CHILD(selectSet, 'groupList')
                groupList:SelectItemByKey(configName)
                local minValue, maxValue = GET_MINMAX_VALUE_BY_QUERY_STRING(configValue)
                local minEdit, maxEdit = GET_CHILD_RECURSIVELY(selectSet, 'minEdit'),
                    GET_CHILD_RECURSIVELY(selectSet, 'maxEdit')
                minEdit:SetText(minValue)
                maxEdit:SetText(maxValue)
                added = true
            end
        end
        if added == false then
            ALIGN_OPTION_GROUP_SET(detailOptionSet)
        end
    end
    local optionGroupSet = GET_CHILD_RECURSIVELY(frame, 'optionGroupSet')
    if optionGroupSet ~= nil and optionGroupSet:IsVisible() == 1 then
        local added = false
        for configName, configValue in pairs(configTable) do
            local isOptionGroup, group = IS_MARKET_SEARCH_OPTION_GROUP(configName)
            if isOptionGroup == true then
                local selectSet = MARKET_ADD_SEARCH_OPTION_GROUP(optionGroupSet)
                local groupList = GET_CHILD(selectSet, 'groupList')
                groupList:SelectItemByKey(group)
                MARKET_INIT_OPTION_GROUP_VALUE_DROPLIST(groupList:GetParent(), groupList)
                local nameList = GET_CHILD(selectSet, 'nameList')
                nameList:SelectItemByKey(configName)
                local minValue, maxValue = GET_MINMAX_VALUE_BY_QUERY_STRING(configValue)
                local minEdit, maxEdit = GET_CHILD_RECURSIVELY(selectSet, 'minEdit'),
                    GET_CHILD_RECURSIVELY(selectSet, 'maxEdit')
                minEdit:SetText(minValue)
                maxEdit:SetText(maxValue)
                added = true
            end
        end
        if added == false then
            ALIGN_OPTION_GROUP_SET(optionGroupSet)
        end
    end
    local gemOptionSet = GET_CHILD_RECURSIVELY(frame, 'gemOptionSet')
    if gemOptionSet ~= nil then
        local optionGroupSet = GET_CHILD_RECURSIVELY(frame, 'optionGroupSet')
        local selectSet = MARKET_ADD_SEARCH_OPTION_GROUP(optionGroupSet)
        if configTable['GemLevel'] ~= nil then
            local minValue, maxValue = GET_MINMAX_VALUE_BY_QUERY_STRING(configTable['GemLevel'])
            local minEdit, maxEdit = GET_CHILD_RECURSIVELY(selectSet, 'levelMinEdit'),
                GET_CHILD_RECURSIVELY(selectSet, 'levelMaxEdit')
            minEdit:SetText(minValue)
            maxEdit:SetText(maxValue)
        end
        if configTable['CardLevel'] ~= nil then
            local minValue, maxValue = GET_MINMAX_VALUE_BY_QUERY_STRING(configTable['CardLevel'])
            local minEdit, maxEdit = GET_CHILD_RECURSIVELY(selectSet, 'levelMinEdit'),
                GET_CHILD_RECURSIVELY(selectSet, 'levelMaxEdit')
            minEdit:SetText(minValue)
            maxEdit:SetText(maxValue)
        end
        if configTable['GemRoastingLv'] ~= nil then
            local minValue, maxValue = GET_MINMAX_VALUE_BY_QUERY_STRING(configTable['CardLevel'])
            local minEdit, maxEdit = GET_CHILD_RECURSIVELY(selectSet, 'levelMinEdit'),
                GET_CHILD_RECURSIVELY(selectSet, 'levelMaxEdit')
            minEdit:SetText(minValue)
            maxEdit:SetText(maxValue)
        end
    end
    local saveCheck = GET_CHILD_RECURSIVELY(frame, 'saveCheck')
    if saveCheck ~= nil then
        saveCheck:SetCheck(1)
    end
    local function ALIGN_ALL_CATEGORY(frame)
        local cateListBox = GET_CHILD_RECURSIVELY(frame, 'cateListBox')
        local selectedCtrlset = GET_CHILD_RECURSIVELY(frame, 'CATEGORY_' .. frame:GetUserValue('SELECTED_CATEGORY'))
        local subCateBox = GET_CHILD_RECURSIVELY(frame, 'detailBox')
        GBOX_AUTO_ALIGN(subCateBox, 0, 1, 0, true, true)
        ALIGN_CATEGORY_BOX(cateListBox, selectedCtrlset, subCateBox)
    end
    ALIGN_ALL_CATEGORY(frame)
    frame:RunUpdateScript("MARKET_REQ_LIST", 0.2)
    return true
end

function market_favorite_rebuild_delete_load_option(frame, ctrl, delete_text)
    local configKeyList = GetMarketCategoryConfigKeyList();
    for i = 1, #configKeyList do
        if configKeyList[i] ~= '' then
            local text = configKeyList[i]
            if delete_text == text then
                session.market.DeleteCategoryConfig(delete_text);
                break
            end
        end
    end
    for i, key in ipairs(g.settings.searchs) do
        if key == delete_text then
            g.settings.searchs[i] = ""
            break
        end
    end
    market_favorite_rebuild_SAVE_SETTINGS()
    market_favorite_rebuild_TOGGLE_FRAME("true")
end

function market_favorite_change_start_str_count(inputstring, ctrl, str, num)
    inputstring:ShowWindow(0)
    local edit = GET_CHILD(inputstring, 'input')
    local get_text = tonumber(edit:GetText())
    if get_text > 15 then
        ui.SysMsg("The max is 15")
        market_favorite_INPUT_STRING_BOX(num)
        return
    end
    if g.settings.items[num].str_count then
        g.settings.items[num].str_count = get_text
    end
    market_favorite_rebuild_SAVE_SETTINGS()
    market_favorite_rebuild_TOGGLE_FRAME("true")
end

function market_favorite_INPUT_STRING_BOX(num)
    local inputstring = ui.GetFrame("inputstring")
    inputstring:Resize(500, 220)
    inputstring:SetLayerLevel(999)
    local edit = GET_CHILD(inputstring, 'input', "ui::CEditControl")
    edit:SetNumberMode(1)
    edit:SetMaxLen(2)
    edit:SetText("1")
    inputstring:ShowWindow(1)
    inputstring:SetEnable(1)
    local title = inputstring:GetChild("title")
    AUTO_CAST(title)
    local text = g.lang == "Japanese" and
                     "{ol}{s16}{#FFFFFF}入力した数値分、検索開始位置をずらします(MAX15)" or
                     "{ol}{s16}{#FFFFFF}Shifts the search start point by the entered value{nl}(MAX15)"
    title:SetText(text)
    local confirm = inputstring:GetChild("confirm")
    confirm:SetEventScript(ui.LBUTTONUP, "market_favorite_change_start_str_count")
    confirm:SetEventScriptArgNumber(ui.LBUTTONUP, num)
    edit:SetEventScript(ui.ENTERKEY, "market_favorite_change_start_str_count")
    edit:SetEventScriptArgNumber(ui.ENTERKEY, num)
    edit:AcquireFocus()
end

function market_favorite_rebuild_ON_LBUTTONDOWN(frame, ctrl, str, num)
    if keyboard.IsKeyPressed('LSHIFT') == 1 then
        market_favorite_INPUT_STRING_BOX(num)
        return
    end
    g.settings.items[num] = {}
    g.slot_index = num
    g.slot = ctrl
end

function market_favorite_rebuild_swap_btn(frame, ctrl, key, index)
    g.settings.searchs[index] = ""
    g.from_slot = ctrl
    g.from_slot_key = key
    g.from_slot_index = index
end

function market_favorite_rebuild_on_drop_btn(frame, ctrl, key, slot_index)
    if g.from_slot then
        g.settings.searchs[g.from_slot_index] = key
        g.settings.searchs[slot_index] = g.from_slot_key
        g.from_slot = nil
        g.from_slot_key = nil
        g.from_slot_index = nil
    end
    market_favorite_rebuild_SAVE_SETTINGS()
    market_favorite_rebuild_TOGGLE_FRAME("true")
end

function market_favorite_rebuild_TOGGLE_FRAME(bool)
    if bool ~= "true" then
        ui.ToggleFrame('market_favorite_rebuild')
    end
    local frame = ui.GetFrame('market_favorite_rebuild')
    if frame:IsVisible() == 1 then
        frame:RemoveChild("slot_set")
        local slot_set = frame:CreateOrGetControl('slotset', 'slot_set', 15, 75, 0, 0)
        AUTO_CAST(slot_set)
        slot_set:SetColRow(7, 8)
        slot_set:SetSlotSize(50, 50)
        slot_set:EnableDrag(1)
        slot_set:EnableDrop(1)
        slot_set:EnablePop(1)
        slot_set:SetSpc(0, 0)
        slot_set:SetSkinName('invenslot2')
        slot_set:CreateSlots()
        local slotCount = slot_set:GetSlotCount()
        for i = 1, slotCount do
            local slot = slot_set:GetSlotByIndex(i - 1)
            slot:SetEventScript(ui.RBUTTONDOWN, 'market_favorite_rebuild_ON_RCLICK')
            slot:SetEventScriptArgNumber(ui.RBUTTONDOWN, i)
            slot:SetEventScript(ui.DROP, 'market_favorite_rebuild_ON_DROP')
            slot:SetEventScriptArgNumber(ui.DROP, i)
            slot:SetEventScript(ui.LBUTTONDOWN, 'market_favorite_rebuild_ON_LBUTTONDOWN')
            slot:SetEventScriptArgNumber(ui.LBUTTONDOWN, i)
            if g.settings.items then
                local item = g.settings.items[i]
                if item and item['clsid'] then
                    slot:SetUserValue('clsid', tostring(item['clsid']))
                    if item['str_count'] then
                        slot:SetUserValue('STR_COUNT', item['str_count'])
                    end
                    local item_cls = GetClassByType("Item", item['clsid'])
                    SET_SLOT_ITEM_CLS(slot, item_cls)
                    SET_SLOT_STYLESET(slot, item_cls)
                    SET_SLOT_COUNT_TEXT(slot, item.str_count)
                else
                    g.settings.items[i] = {}
                end
            end
        end
        local tips = frame:CreateOrGetControl('richtext', "tips", 15, 480, 95, 25)
        AUTO_CAST(tips)
        local text = g.lang == "Japanese" and
                         "{ol}右クリック: マーケット検索{nl}LSHIFT+左クリック: 検索開始位置調整{nl}右下の数字が調整数{nl}LSHIFT+右クリック: スロット初期化" or
                         "{ol}{s13}Right-click: Market Search{nl}LSHIFT + Left-click: Adjust search start position{nl}The number in the bottom right is the{nl}adjustment value{nl}LSHIFT + Right-click: Initialize Slot"
        tips:SetText(text)
        for i = 1, 18 do
            local search_btn = GET_CHILD(frame, 'search_btn' .. i)
            if search_btn then
                frame:RemoveChild(search_btn)
            end
        end
        frame:RemoveChild("btn_slot_set")
        local btn_slot_set = frame:CreateOrGetControl('slotset', 'btn_slot_set', 10, 555, 0, 0)
        AUTO_CAST(btn_slot_set)
        btn_slot_set:SetColRow(2, 9)
        btn_slot_set:SetSlotSize(177, 35)
        btn_slot_set:EnableDrag(1)
        btn_slot_set:EnableDrop(1)
        btn_slot_set:EnablePop(1)
        btn_slot_set:SetSpc(5, 5)
        btn_slot_set:SetSkinName("invenslot2")
        btn_slot_set:CreateSlots()
        local slot_count = btn_slot_set:GetSlotCount()
        local max_slots = 18
        local new_searchs = {}
        local needs_reset = false
        if g.settings.searchs then
            for _, entry in ipairs(g.settings.searchs) do
                if type(entry) == "table" then
                    needs_reset = true
                    break
                end
            end
        end
        if needs_reset or not g.settings.searchs then
            for i = 1, max_slots do
                new_searchs[i] = ""
            end
        else
            for i = 1, max_slots do
                new_searchs[i] = g.settings.searchs[i] or ""
            end
        end
        local config_key_list = GetMarketCategoryConfigKeyList()
        if config_key_list then
            local existing_keys = {}
            for _, key in ipairs(new_searchs) do
                if key ~= "" then
                    existing_keys[key] = true
                end
            end
            for i, tos_str in ipairs(config_key_list) do
                if tos_str ~= "" then
                    if not existing_keys[tos_str] then
                        for i = 1, max_slots do
                            if new_searchs[i] == "" then
                                new_searchs[i] = tos_str
                                existing_keys[tos_str] = true
                                break
                            end
                        end
                    end
                end
            end
        end
        g.settings.searchs = new_searchs
        for i = 1, slot_count do
            local btn_slot = btn_slot_set:GetSlotByIndex(i - 1)
            local icon = CreateIcon(btn_slot)
            local text = ""
            local key = g.settings.searchs[i]
            if key then
                btn_slot:SetUserValue("SLOT_INDEX", i)
                btn_slot:SetEventScript(ui.LBUTTONDOWN, "market_favorite_rebuild_swap_btn")
                btn_slot:SetEventScriptArgString(ui.LBUTTONDOWN, key)
                btn_slot:SetEventScriptArgNumber(ui.LBUTTONDOWN, i)
                btn_slot:SetEventScript(ui.DROP, 'market_favorite_rebuild_on_drop_btn')
                btn_slot:SetEventScriptArgString(ui.DROP, key)
                btn_slot:SetEventScriptArgNumber(ui.DROP, i)
            end
            if key ~= '' then
                text = g.lang == "Japanese" and
                           "{ol}右クリック: 検索{nl}LSHIFT+右クリック: オプション削除{nl}左クリック: 入替" or
                           "{ol}Right-click: Search{nl}LSHIFT + Right-click: Delete Option{nl}Left-click: Swap"
                icon:SetTextTooltip(text)
                btn_slot:SetEventScript(ui.RBUTTONUP, "market_favorite_rebuild_MARKET_LOAD_CATEGORY_OPTION")
                btn_slot:SetEventScriptArgString(ui.RBUTTONUP, key)
                btn_slot:SetEventScriptArgNumber(ui.RBUTTONUP, 2)
                btn_slot:SetText("{ol}{#FFFFFF}" .. key)
                btn_slot:SetTextAlign("center", "center");
                icon:SetImage("fullwhite")
                icon:SetColorTone("BB800000")
            else
                btn_slot:SetText("")
                btn_slot:SetTextAlign("center", "center");
                icon:SetImage("fullwhite")
                icon:SetColorTone("BB696969")
            end
        end
        slot_set:ShowWindow(1)
        btn_slot_set:ShowWindow(1)
    end
    market_favorite_rebuild_SAVE_SETTINGS()
    local y = 920
    local always_check = frame:CreateOrGetControl('checkbox', "always_check", 15, y, 25, 25)
    AUTO_CAST(always_check)
    local text = g.lang == "Japanese" and "{ol}チェックすると自動表示" or "{ol}Check to auto-display"
    always_check:SetText(text)
    always_check:SetCheck(g.settings.always or 0)
    always_check:SetEventScript(ui.LBUTTONUP, "market_favorite_rebuild_toggle_check")
    y = y + 30
    local move_check = frame:CreateOrGetControl('checkbox', "move_check", 15, y, 25, 25)
    AUTO_CAST(move_check)
    local text = g.lang == "Japanese" and "{ol}チェックするとフレーム固定" or "{ol}Check to lock frame"
    move_check:SetText(text)
    move_check:SetCheck(g.settings.move or 0)
    move_check:SetEventScript(ui.LBUTTONUP, "market_favorite_rebuild_toggle_check")
    y = y + 30
    if not g.settings.op_text then
        g.settings.op_text = 0
        market_favorite_rebuild_SAVE_SETTINGS()
    end
    local op_check = frame:CreateOrGetControl('checkbox', "op_check", 15, y, 25, 25)
    AUTO_CAST(op_check)
    local text = g.lang == "Japanese" and "{ol}チェックするとオプション表示変更" or
                     "{ol}Check to change option display"
    op_check:SetText(text)
    op_check:SetCheck(g.settings.op_text or 0)
    op_check:SetEventScript(ui.LBUTTONUP, "market_favorite_rebuild_toggle_check")
    local toggle = frame:CreateOrGetControl('picture', "toggle", op_check:GetWidth() + 20, y, 60, 25);
    AUTO_CAST(toggle)
    if not g.settings.max_value then
        g.settings.max_value = 1
    end
    local icon_name = "test_com_ability_on"
    if g.settings.max_value == 0 then
        icon_name = "test_com_ability_off"
    end
    toggle:SetImage(icon_name)
    toggle:SetEnableStretch(1)
    toggle:EnableHitTest(1)
    local text = g.lang == "Japanese" and "{ol}MAX数値表示" or "{ol}Display Max Value"
    toggle:SetTextTooltip(text)
    toggle:SetEventScript(ui.LBUTTONUP, "market_favorite_rebuild_toggle_check")
    local xBtn = GET_CHILD_RECURSIVELY(frame, "xBtn")
    AUTO_CAST(xBtn)
    xBtn:SetEventScript(ui.LBUTTONUP, "market_favorite_rebuild_CLOSE")
    y = y + 40
    frame:Resize(frame:GetWidth(), y)
end

function market_favorite_rebuild_toggle_check(frame, ctrl)
    local ctrl_name = ctrl:GetName()
    if ctrl_name == "toggle" then
        if g.settings.max_value == 0 then
            g.settings.max_value = 1
            AUTO_CAST(ctrl)
            ctrl:SetImage("test_com_ability_on")
        else
            AUTO_CAST(ctrl)
            ctrl:SetImage("test_com_ability_off")
            g.settings.max_value = 0
        end
        market_favorite_rebuild_SAVE_SETTINGS()
        market_favorite_rebuild_TOGGLE_FRAME("true")
        return
    end
    local is_check = ctrl:IsChecked()
    if ctrl_name == "op_check" then
        if is_check == 1 then
            g.settings.op_text = 1
        else
            g.settings.op_text = 0
        end
    end
    if ctrl_name == "always_check" then
        if is_check == 1 then
            g.settings.always = 1
        else
            g.settings.always = 0
        end
    end
    if ctrl_name == "move_check" then
        if is_check == 1 then
            g.settings.move = 1
            frame:EnableMove(0)
        else
            g.settings.move = 0
            frame:EnableMove(1)
        end
    end
    market_favorite_rebuild_SAVE_SETTINGS()
    market_favorite_rebuild_TOGGLE_FRAME("true")
end

function market_favorite_rebuild_END_DRAG(frame)
    g.settings.position.x = frame:GetX()
    g.settings.position.y = frame:GetY()
    market_favorite_rebuild_SAVE_SETTINGS()
end

function market_favorite_rebuild_ON_OPEN_MARKET(frame, msg)
    frame = ui.GetFrame('market_favorite_rebuild')
    frame:Move(0, 0)
    frame:SetOffset(g.settings.position.x, g.settings.position.y)
    frame:ShowWindow(0)
    frame:SetEventScript(ui.LBUTTONUP, 'market_favorite_rebuild_END_DRAG')
    frame:EnableMove(g.settings.move == 1 and 0 or 1)
    if g.settings.always == 1 then
        market_favorite_rebuild_TOGGLE_FRAME()
        frame:ShowWindow(1)
    end
    local market = ui.GetFrame("market")
    local open_btn = market:CreateOrGetControl("button", "open_btn", 610, 120, 100, 30)
    AUTO_CAST(open_btn)
    if g.lang ~= "Japanese" and g.lang ~= "kr" then
        open_btn:SetOffset(620, 120)
    end
    open_btn:SetSkinName("tab2_btn")
    local text = g.lang == "Japanese" and "{@st66b18}お気に入り" or "{@st66b18}Favorites"
    open_btn:SetText(text)
    open_btn:SetEventScript(ui.LBUTTONUP, "market_favorite_rebuild_TOGGLE_FRAME")
end

function market_favorite_rebuild_CLOSE(frame)
    frame:ShowWindow(0)
end

function market_favorite_rebuild__MARKET_SAVE_CATEGORY_OPTION(my_frame, my_msg)
    local frame, configKey, orderByDesc, searchText, category, optionKey, optionValue = g.get_event_args(my_msg)
    local format_str = "%s:%s:%s:%s:%s:%s:%s"
    if type(g.settings.searchs) ~= "table" then
        g.settings.searchs = {}
    end
    local key_str = tostring(configKey)
    if not key_str then
        return
    end
    table.insert(g.settings.searchs, key_str)
    market_favorite_rebuild_SAVE_SETTINGS()
    market_favorite_rebuild_TOGGLE_FRAME("true")
end

function market_favorite_rebuild_ON_DROP(frame, slot, str, slot_index)
    local liftIcon = ui.GetLiftIcon()
    local liftParent = liftIcon:GetParent()
    local slot = tolua.cast(slot, 'ui::CSlot')
    local iconInfo = liftIcon:GetInfo()
    if iconInfo == nil or slot == nil then
        return
    end
    if (iconInfo:GetIESID() == '0') then
        if (liftParent:GetName() == 'pic') then
            local parent = liftParent:GetParent()
            while (string.starts(parent:GetName(), 'ITEM') == false) do
                parent = parent:GetParent()
                if (parent == nil) then
                    CHAT_SYSTEM('失敗')
                    return
                end
            end
            local row = tonumber(parent:GetUserValue('DETAIL_ROW'))
            local marketItem = session.market.GetItemByIndex(row)
            local obj = GetIES(marketItem:GetObject())
            local item_cls = GetClassByType("Item", obj.ClassID)
            if item_cls then
                slot:SetUserValue('clsid', tostring(obj.ClassID))
                g.settings.items[slot_index] = {
                    ["clsid"] = tonumber(obj.ClassID),
                    ["str_count"] = 1
                }
            end
        else
            if g.slot_index then
                local cls_id = g.slot:GetUserValue("clsid")
                local from_count = g.slot:GetUserIValue("STR_COUNT")
                local drop_clsid = slot:GetUserValue("clsid")
                local to_count = slot:GetUserIValue("STR_COUNT")
                local item_cls = GetClassByType("Item", cls_id)
                if item_cls then
                    slot:SetUserValue('clsid', tostring(cls_id))
                    g.settings.items[slot_index] = {
                        ["clsid"] = tonumber(cls_id),
                        ["str_count"] = from_count or 1
                    }
                    local drop_item_cls = GetClassByType("Item", drop_clsid)
                    if drop_item_cls then
                        g.slot:SetUserValue('clsid', tostring(drop_clsid))
                        g.settings.items[g.slot_index] = {
                            ["clsid"] = tonumber(drop_clsid),
                            ["str_count"] = to_count or 1
                        }
                    else
                        g.settings.items[g.slot_index] = {}
                    end
                end
                g.slot_index = nil
                g.slot = nil
            end
        end
    else
        local invitem = GET_ITEM_BY_GUID(iconInfo:GetIESID())
        local itemobj = GetIES(invitem:GetObject())
        local item_cls = GetClassByType("Item", itemobj.ClassID)
        local market_trade = TryGetProp(item_cls, "MarketTrade")
        if market_trade == "NO" then
            ui.SysMsg(ClMsg("NoMarketTrade"))
            return
        end
        if item_cls then
            slot:SetUserValue('clsid', tostring(itemobj.ClassID))
            g.settings.items[slot_index] = {
                ["clsid"] = tonumber(itemobj.ClassID),
                ["str_count"] = 1
            }
        end
    end
    market_favorite_rebuild_SAVE_SETTINGS()
    market_favorite_rebuild_TOGGLE_FRAME("true")
end

function market_favorite_rebuild_ON_RCLICK(frame, slot, argstr, argnum)
    if keyboard.IsKeyPressed('LSHIFT') == 1 then
        g.settings.items[argnum] = {}
        market_favorite_rebuild_SAVE_SETTINGS()
        market_favorite_rebuild_TOGGLE_FRAME("true")
    else
        if (ui.GetFrame('market'):IsVisible() == 0) then
            CHAT_SYSTEM(L_("HavntopenMarket"))
            return
        end
        local frame = ui.GetFrame('market')
        local clsid = slot:GetUserValue('clsid')
        if (clsid == nil) then
            return
        end
        local invitem = GetClassByType('Item', tonumber(clsid))
        if (invitem == nil) then
            return
        end
        MARKET_BUYMODE(frame)
        MARKET_INIT_CATEGORY(frame)
        local searchtext = GET_CHILD_RECURSIVELY(frame, 'searchEdit')
        AUTO_CAST(searchtext)
        local realname = dictionary.ReplaceDicIDInCompStr(invitem.Name)
        local str_shift = g.settings.items[argnum].str_count
        local start_byte = utf8.offset(realname, str_shift, 1)
        realname = string.sub(realname, start_byte)
        local cls_name = invitem.ClassName
        local armor = nil
        local weapon = nil
        if string.find(cls_name, "GoddessIcor_Weapon", 1, true) and not string.find(cls_name, "piece", 1, true) then
            weapon = true
        elseif string.find(cls_name, "GoddessIcor_Armor", 1, true) and not string.find(cls_name, "piece", 1, true) then
            armor = true
        end
        if weapon or armor then
            local marketCategory = GET_CHILD_RECURSIVELY(frame, 'marketCategory')
            local bgBox = GET_CHILD(marketCategory, 'bgBox')
            local cateListBox = GET_CHILD_RECURSIVELY(marketCategory, 'cateListBox')
            cateListBox:RemoveAllChild()
            local function SORT_CATEGORY(categoryList, sortFunc)
                table.sort(categoryList, sortFunc)
                return categoryList
            end
            local marketCategorySortCriteria = { -- 숫자가 작은 순서로 나오고, 없는 애들은 밑에 감
                Weapon = 1,
                Armor = 2,
                Consume = 3,
                Accessory = 4,
                Recipe = 5,
                Card = 6,
                Misc = 7,
                Gem = 8
            }
            local categoryList = SORT_CATEGORY(GetMarketCategoryList('root'), function(lhs, rhs)
                local lhsValue = marketCategorySortCriteria[lhs]
                local rhsValue = marketCategorySortCriteria[rhs]
                if lhsValue == nil then
                    lhsValue = 200000000
                end
                if rhsValue == nil then
                    rhsValue = 200000000
                end
                return lhsValue < rhsValue
            end)
            for i = 0, #categoryList do
                local group
                if i == 0 then
                    group = 'IntegrateRetreive'
                else
                    group = categoryList[i]
                end
                local ctrlSet =
                    cateListBox:CreateControlSet("market_tree", "CATEGORY_" .. group, ui.LEFT, 0, 0, 0, 0, 0)
                AUTO_CAST(ctrlSet)
                local part = ctrlSet:GetChild("part")
                part:SetTextByKey("value", ClMsg(group))
                ctrlSet:SetUserValue('CATEGORY', group)
            end
            GBOX_AUTO_ALIGN(cateListBox, 0, 0, 0, true, false)
            local optionBox = GET_CHILD_RECURSIVELY(frame, 'optionBox')
            optionBox:ShowWindow(0)
            frame:SetUserValue('SELECTED_CATEGORY', 'None')
            frame:SetUserValue('SELECTED_SUB_CATEGORY', 'None')
            local categoryCtrlset = GET_CHILD_RECURSIVELY(frame, 'CATEGORY_' .. "OPTMisc")
            AUTO_CAST(categoryCtrlset)
            MARKET_CATEGORY_CLICK(categoryCtrlset, categoryCtrlset:GetChild('bgBox'), false, true)
            local subCategoryCtrlset = nil
            if weapon then
                subCategoryCtrlset = GET_CHILD_RECURSIVELY(frame, 'SUB_CATE_' .. "GoddessIcorWeapon")
            elseif armor then
                subCategoryCtrlset = GET_CHILD_RECURSIVELY(frame, 'SUB_CATE_' .. "GoddessIcorArmor")
            end
            AUTO_CAST(subCategoryCtrlset)
            MARKET_SUB_CATEOGRY_CLICK(subCategoryCtrlset:GetParent(), subCategoryCtrlset, true)
            local market_search = GET_CHILD_RECURSIVELY(frame, 'itemSearchSet')
            local searchEdit = GET_CHILD_RECURSIVELY(market_search, 'searchEdit')
            AUTO_CAST(searchEdit)
            local lang_code = g.judge_language(realname)
            if lang_code == "ko" or lang_code == "ja" then
                realname = g.truncate_text_by_byte_limit(realname, lang_code)
            elseif lang_code == "en" then
                realname = g.truncate_text_by_byte_limit(realname, lang_code)
            else
                return
            end
            searchEdit:SetText(realname)
            frame:RunUpdateScript("MARKET_REQ_LIST", 0.1) -- (frame)
            return
        end
        local lang_code = g.judge_language(realname)
        if lang_code == "ko" or lang_code == "ja" then
            realname = g.truncate_text_by_byte_limit(realname, lang_code)
        elseif lang_code == "en" then
            realname = g.truncate_text_by_byte_limit(realname, lang_code)
        else
            return
        end
        searchtext:SetText(realname)
        MARKET_REQ_LIST(frame)
    end
end

--[[function market_favorite_rebuild_MARKET_FIND_PAGE(my_frame, my_msg)
    local frame, page = g.get_event_args(my_msg)

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

    if searchText ~= '' and ui.GetPaperLength(searchText) < 2 then
        ui.SysMsg(ClMsg('InvalidFindItemQueryMin'));
        return;
    end

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
    local test_category = frame:GetUserValue('SELECTED_CATEGORY');
    local optionKey, optionValue
    if test_category == "Gem" then
        optionKey, optionValue = market_favorite_GET_SEARCH_OPTION(frame);
    else
        optionKey, optionValue = GET_SEARCH_OPTION(frame);
    end
    local itemCntPerPage = GET_MARKET_SEARCH_ITEM_COUNT(_category);
    MarketSearch(page + 1, orderByDesc, searchText, category, optionKey, optionValue, itemCntPerPage);
    DISABLE_BUTTON_DOUBLECLICK_WITH_CHILD(frame:GetName(), 'commitSet', 'searchBtn', 1);
    MARKET_OPTION_BOX_CLOSE_CLICK(frame);
end

function market_favorite_GET_SEARCH_OPTION(frame)
    local optionName, optionValue = {}, {};
    local optionSet = {}; -- for checking duplicate option
    local category = frame:GetUserValue('SELECTED_CATEGORY');
    local sub_category = frame:GetUserValue('SELECTED_SUB_CATEGORY');

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

    -- gem option
    local gemOptionSet = GET_CHILD_RECURSIVELY(frame, 'gemOptionSet');
    if gemOptionSet ~= nil and gemOptionSet:IsVisible() == 1 then
        local levelMinEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'levelMinEdit');
        local levelMaxEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'levelMaxEdit');
        local roastingMinEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'roastingMinEdit');
        local roastingMaxEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'roastingMaxEdit');
        if category == 'Gem' then
            if sub_category == "GemSkill" then
                -- local opValue = GET_MINMAX_QUERY_VALUE_STRING(levelMinEdit, levelMaxEdit);
                local opValue = 99 .. ';' .. 99
                if opValue ~= '' then
                    ts(sub_category, opValue)
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
            else
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
end]]

--[[for i = 1, 18 do
            local search_btn = frame:CreateOrGetControl('button', 'search_btn' .. i, x, y, 180, 40)
            AUTO_CAST(search_btn)
            local text = ""
            local key = false
            if g.settings.searchs and g.settings.searchs[i] then
                key = g.settings.searchs[i].key

                text = g.lang == "Japanese" and "{ol}LSHIFT+右クリック: オプション削除" or
                           "{ol}LSHIFT + Right-click: Delete Option"

                search_btn:SetTextTooltip(text)
                search_btn:SetEventScript(ui.LBUTTONUP, "market_favorite_rebuild_MARKET_LOAD_CATEGORY_OPTION")
                search_btn:SetEventScriptArgString(ui.LBUTTONUP, key)
                search_btn:SetEventScriptArgNumber(ui.LBUTTONUP, 1)

                search_btn:SetEventScript(ui.RBUTTONUP, "market_favorite_rebuild_MARKET_LOAD_CATEGORY_OPTION")
                search_btn:SetEventScriptArgString(ui.RBUTTONUP, key)
                search_btn:SetEventScriptArgNumber(ui.RBUTTONUP, 2)

                search_btn:SetSkinName("test_red_button")
            else
                local text = g.lang == "Japanese" and "{ol}保存されたオプションはありません" or
                                 "{ol}No saved Option"
                search_btn:SetTextTooltip(text)
                search_btn:SetSkinName('test_gray_button')
            end
            if key then
                search_btn:SetText("{ol}" .. key)
            else
                search_btn:SetText("")
            end
            y = y + 40

            search_btn:ShowWindow(1)
            if i == 9 then
                x = 190
                y = 555
            end
        end]]

--[[function market_favorite_rebuild_req_register_item(itemGuid, floorprice, count, _, needTime, clsid)
    -- !

    local current_time = os.date("%y-%m-%d %H:%M")

    local data = {
        iesid = itemGuid,
        clsid = clsid,
        price = floorprice,
        count = count,
        time = needTime,
        register_time = current_time,
        status = "selling"
    }
    table.insert(g.settings.sell_items[g.login_name], data)
    g.item_index = #g.settings.sell_items[g.login_name]
    market.ReqRegisterItem(itemGuid, tonumber(floorprice), tonumber(count), 1, tonumber(needTime))

end]]
