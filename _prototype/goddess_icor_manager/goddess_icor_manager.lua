local addonName = "GODDESS_ICOR_MANAGER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")

function GODDESS_ICOR_MANAGER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    -- addon:RegisterMsg("PARTY_BUFFLIST_UPDATE", "test_norisan_ON_PARTYINFO_BUFFLIST_UPDATE");
    -- g.SetupHook(test_norisan_ON_PARTYINFO_BUFFLIST_UPDATE, "PARTY_BUFFLIST_UPDATE")
    -- acutil.setupHook(goddess_icor_manager_GODDESS_ENGRAVE_APPLY_CHECK, "GODDESS_ENGRAVE_APPLY_CHECK")

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then

        goddess_icor_manager_frame_init()
        return;
    end

end

-- 保存された刻印情報のオプション、グループ、値リストをそれぞれ返します。
function goddess_icor_manager_GET_ENGRAVED_OPTION_LIST(etc, index, spot)
    if etc == nil then
        return nil
    end

    local suffix = string.format('_%d_%s', tonumber(index), spot)

    local option_prop = TryGetProp(etc, 'RandomOptionPreset' .. suffix, 'None')
    local group_prop = TryGetProp(etc, 'RandomOptionGroupPreset' .. suffix, 'None')
    local value_prop = TryGetProp(etc, 'RandomOptionValuePreset' .. suffix, 'None')

    if option_prop == 'None' then
        return nil
    end

    local option_list = SCR_STRING_CUT(option_prop, '/')
    local group_list = SCR_STRING_CUT(group_prop, '/')
    local value_list = SCR_STRING_CUT(value_prop, '/')

    local is_goddess_option = TryGetProp(etc, 'IsGoddessIcorOption' .. suffix, 0)

    return option_prop, group_prop, value_prop, is_goddess_option
end

local managed_list = {'RH', 'LH', 'SHIRT', 'PANTS', 'GLOVES', 'BOOTS', 'RH_SUB', 'LH_SUB'}

function goddess_icor_manager_list_gb_init(frame)

    local acc = GetMyAccountObj()
    local etc = GetMyEtcObject()

    local page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc)
    for i = 1, 10 do
        local bg = GET_CHILD_RECURSIVELY(frame, "bg" .. i)
        if bg ~= nil then
            frame:RemoveChild("bg" .. i)
        end
    end
    local Y = 20
    local YY = 20
    local cnt = 1
    local parts1 = {}
    local parts2 = {}
    local parts3 = {}
    for i = 1, 10 do
        -- print(i)
        if i <= 5 then
            local bg = frame:CreateOrGetControl("groupbox", "bg" .. i, Y, 0, 265, 440)
            Y = Y + 265

            local pagename = bg:CreateOrGetControl("richtext", "pagename" .. i, 10, 5)
            pagename:SetText(goddess_icor_manager_get_pagename(i))

            local option_prop, group_prop, value_prop, is_goddess_option =
                goddess_icor_manager_GET_ENGRAVED_OPTION_LIST(etc, i, managed_list[i])

            -- print(cnt)
            -- ページごとにテーブルを初期化

            for part in option_prop:gmatch("([^/]+)") do
                table.insert(parts1, part)
            end

            for part in group_prop:gmatch("([^/]+)") do
                table.insert(parts2, part)
            end

            for part in value_prop:gmatch("([^/]+)") do
                table.insert(parts3, part)
            end

            -- print(tostring(parts1 .. parts2 .. parts3))

            -- テーブルの内容を表示

            bg:SetSkinName("bg")
            bg:ShowWindow(1)
        end

        --[[if i >= 6 then
            
            local bg = frame:CreateOrGetControl("groupbox", "bg" .. i, YY, 445, 265, 440)
            YY = YY + 265

            local pagename = bg:CreateOrGetControl("richtext", "pagename" .. i, 10, 5)
            pagename:SetText(goddess_icor_manager_get_pagename(i))
            bg:SetSkinName("bg")
            bg:ShowWindow(1)
        end]]
    end
    goddess_icor_manager_set_text(frame, parts1, parts2, parts3)
    -- local gemframe = ui.GetFrame("goddess_equip_manager")
    -- local randapplybg = GET_CHILD_RECURSIVELY(gemframe, 'rand_apply_bg')
    --  local rand_preset_list = GET_CHILD_RECURSIVELY(gemframe, 'rand_preset_list')
    --  local randomoption_bg = GET_CHILD_RECURSIVELY(gemframe, 'randomoption_bg')

end

function goddess_icor_manager_set_text(frame, parts1, parts2, parts3)
    for i = 1, 10 do
        local bg = GET_CHILD_RECURSIVELY(frame, "bg" .. i)
        print(tostring(#parts1))
        for k = 1, #parts1 do
            local option = bg:CreateOrGetControl("richtext", "option" .. k, 10, i + 20 + k * 15)
            option:SetText(parts1[k] .. ":" .. parts3[k])
        end
    end
end

function goddess_icor_manager_list_init()
    local frame = ui.GetFrame("goddess_icor_manager")
    frame:Resize(1400, 900)
    frame:ShowWindow(1)
    frame:SetLayerLevel(120)
    local close = frame:CreateOrGetControl("button", "close", 0, 0, 30, 30)
    close:SetText("×")
    close:SetGravity(ui.RIGHT, ui.TOP);
    close:SetMargin(0, 0, 20, -70);
    close:ShowWindow(1)
    close:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_list_close")
    goddess_icor_manager_list_gb_init(frame)
    -- close:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_list_maxcount")
end

function goddess_icor_manager_list_close(frame)
    frame:ShowWindow(0)
end

function goddess_icor_manager_frame_init()
    local frame = ui.GetFrame("goddess_equip_manager")
    local randomoption_bg = GET_CHILD_RECURSIVELY(frame, "randomoption_bg")
    local listbtn = randomoption_bg:CreateOrGetControl("button", "listbtn", 520, 12, 160, 40)
    AUTO_CAST(listbtn)
    listbtn:SetText("{ol}list")
    listbtn:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_list_init")

end

function goddess_icor_manager_get_pagename(index)
    local pc_etc = GetMyEtcObject()
    local acc = GetMyAccountObj()
    if pc_etc == nil or acc == nil then
        return nil
    end
    local page_name = TryGetProp(pc_etc, 'RandomOptionPresetName_' .. index, 'None')
    if page_name == 'None' then
        return ScpArgMsg('EngravePageNumber{index}', 'index', index)
    else
        return page_name
    end

end
--[[function goddess_icor_manager_GODDESS_ENGRAVE_APPLY_CHECK(frame, ctrlset)
    local etc = GetMyEtcObject()
    if etc == nil then
        return false, 'None'
    end

    local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
    local index = randomoption_bg:GetUserValue('PRESET_INDEX')

    local slot = GET_CHILD(ctrlset, 'slot')
    local guid = slot:GetUserValue('ITEM_GUID')
    if guid == 'None' then
        return false, 'None'
    end

    local spot_name = slot:GetUserValue('EQUIP_SPOT')
    local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(spot_name))
    if inv_item == nil then
        return false, 'None'
    end

    local item_obj = GetIES(inv_item:GetObject())
    -- print(tostring(item_obj.ClassName))
    local item_dic = goddess_icor_manager_GET_ITEM_RANDOMOPTION_DIC(item_obj)
    -- print(tostring(item_dic))
    if item_dic == nil then
        return false, 'None'
    end

    local option_dic = goddess_icor_manager_GET_ENGRAVED_OPTION_BY_INDEX_SPOT(etc, index, spot_name)
    -- print(tostring(option_dic))
    if option_dic == nil then
        return false, 'None'
    end

    if COMPARE_ITEM_OPTION_TO_ENGRAVED_OPTION(item_dic, option_dic) == true then
        return false, 'SameEngraveAppliedAlready'
    end

    return true
end

function goddess_icor_manager_GET_ITEM_RANDOMOPTION_DIC(item_obj)
    if item_obj == nil then
        return nil
    end

    local option_dic = {}
    option_dic['Size'] = 4
    for i = 1, 4 do
        local prop_name = 'RandomOption_' .. i

        local group_name = 'RandomOptionGroup_' .. i

        local prop_value = 'RandomOptionValue_' .. i

        local prop = TryGetProp(item_obj, prop_name, 'None')
        if prop ~= 'None' then
            local group = TryGetProp(item_obj, group_name, 'None')
            local value = TryGetProp(item_obj, prop_value, 0)

            option_dic[prop_name] = prop
            print(tostring(prop))
            option_dic[group_name] = group
            print(tostring(group))
            option_dic[prop_value] = value
            print(tostring(value))
        else
            option_dic['Size'] = i - 1
            break
        end
    end

    if option_dic['Size'] == 0 then
        return nil
    end

    return option_dic
end]]
-- 保存された刻印情報ディクショナリをインポートする
--[[function goddess_icor_manager_GET_ENGRAVED_OPTION_BY_INDEX_SPOT(etc, index, spot)
    if etc == nil then
        return nil
    end

    local option_list, group_list, value_list = goddess_icor_manager_GET_ENGRAVED_OPTION_LIST(etc, index, spot)
    if option_list == nil then
        return nil
    end

    local option_dic = {}
    for i = 1, #option_list do
        local prop_name = 'RandomOption_' .. i
        local group_name = 'RandomOptionGroup_' .. i
        local prop_value = 'RandomOptionValue_' .. i

        option_dic[prop_name] = option_list[i]
        option_dic[group_name] = group_list[i]
        option_dic[prop_value] = tonumber(value_list[i])
    end

    option_dic['Size'] = #option_list

    return option_dic
end]]
