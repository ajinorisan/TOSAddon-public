-- v0.0.1 陶芸家やったら自分で割るレベルでリリース
-- v0.0.2 イコルLV毎に色分け。次は装備関係か・・・ボチボチやろ
local addonName = "GODDESS_ICOR_MANAGER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.2"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")

local high500weapontbl = {{
    ["STR"] = 276
}, {
    ["DEX"] = 276
}, {
    ["INT"] = 276
}, {
    ["CON"] = 276
}, {
    ["MNA"] = 276
}, {
    ["BLK"] = 920
}, {
    ["BLK_BREAK"] = 920
}, {
    ["ADD_HR"] = 920
}, {
    ["ADD_DR"] = 920
}, {
    ["CRTHR"] = 920
}, {
    ["CRTDR"] = 920
}, {
    ["RHP"] = 920
}, {
    ["RSP"] = 920
}, {
    ["CRTDR"] = 920
}, {
    ["Cloth_Def"] = 1837
}, {
    ["Leather_Def"] = 1837
}, {
    ["Iron_Def"] = 1837
}, {
    ["MiddleSize_Def"] = 1837
}, {
    ["ResAdd_Damage"] = 2758
}, --[[{
    ["stun_res"] = 171
}, {
    ["high_fire_res"] = 171
}, {
    ["high_freezing_res"] = 171
}, {
    ["high_lighting_res"] = 171
}, {
    ["high_poison_res"] = 171
}, {
    ["high_laceration_res"] = 171
}, {
    ["portion_expansion"] = 30001
},]] {
    ["ADD_CLOTH"] = 1837
}, {
    ["ADD_LEATHER"] = 1837
}, {
    ["ADD_IRON"] = 1837
}, {
    ["ADD_SMALLSIZE"] = 1837
}, {
    ["ADD_MIDDLESIZE"] = 1837
}, {
    ["ADD_LARGESIZE"] = 1837
}, {
    ["ADD_GHOST"] = 1837
}, {
    ["ADD_FORESTER"] = 1837
}, {
    ["ADD_WIDLING"] = 1837
}, {
    ["ADD_VELIAS"] = 1837
}, {
    ["ADD_PARAMUNE"] = 1837
}, {
    ["ADD_KLAIDA"] = 1837
}, {
    ["Add_Damage_Atk"] = 2758
}, {
    ["AllMaterialType_Atk"] = 1802
}, {
    ["AllRace_Atk"] = 1802
}, {
    ["perfection"] = 4001
}, {
    ["revenge"] = 30001
}}

local high500armortbl = {{
    ["STR"] = 220
}, {
    ["DEX"] = 220
}, {
    ["INT"] = 220
}, {
    ["CON"] = 220
}, {
    ["MNA"] = 220
}, {
    ["BLK"] = 735
}, {
    ["BLK_BREAK"] = 735
}, {
    ["ADD_HR"] = 735
}, {
    ["ADD_DR"] = 735
}, {
    ["CRTHR"] = 735
}, {
    ["CRTDR"] = 735
}, {
    ["RHP"] = 735
}, {
    ["RSP"] = 735
}, {
    ["CRTDR"] = 735
}, {
    ["Cloth_Def"] = 1472
}, {
    ["Leather_Def"] = 1472
}, {
    ["Iron_Def"] = 1472
}, {
    ["MiddleSize_Def"] = 1472
}, {
    ["ResAdd_Damage"] = 1837
}, {
    ["stun_res"] = 171
}, {
    ["high_fire_res"] = 171
}, {
    ["high_freezing_res"] = 171
}, {
    ["high_lighting_res"] = 171
}, {
    ["high_poison_res"] = 171
}, {
    ["high_laceration_res"] = 171
}, {
    ["portion_expansion"] = 30001
}, {
    ["ADD_CLOTH"] = 1472
}, {
    ["ADD_LEATHER"] = 1472
}, {
    ["ADD_IRON"] = 1472
}, {
    ["ADD_SMALLSIZE"] = 1472
}, {
    ["ADD_MIDDLESIZE"] = 1472
}, {
    ["ADD_LARGESIZE"] = 1472
}, {
    ["ADD_GHOST"] = 1472
}, {
    ["ADD_FORESTER"] = 1472
}, {
    ["ADD_WIDLING"] = 1472
}, {
    ["ADD_VELIAS"] = 1472
}, {
    ["ADD_PARAMUNE"] = 1472
}, {
    ["ADD_KLAIDA"] = 1472
}, {
    ["Add_Damage_Atk"] = 1837
}, {
    ["AllMaterialType_Atk"] = 1252
}, {
    ["AllRace_Atk"] = 1252
} --[[{
    ["perfection"] = 4001
}, {
    ["revenge"] = 30001
}]] }

local low500weapontbl = {{
    ["STR"] = 255
}, {
    ["DEX"] = 255
}, {
    ["INT"] = 255
}, {
    ["CON"] = 255
}, {
    ["MNA"] = 255
}, {
    ["BLK"] = 849
}, {
    ["BLK_BREAK"] = 849
}, {
    ["ADD_HR"] = 849
}, {
    ["ADD_DR"] = 849
}, {
    ["CRTHR"] = 849
}, {
    ["CRTDR"] = 849
}, {
    ["RHP"] = 849
}, {
    ["RSP"] = 849
}, {
    ["CRTDR"] = 849
}, {
    ["Cloth_Def"] = 1696
}, {
    ["Leather_Def"] = 1696
}, {
    ["Iron_Def"] = 1696
}, {
    ["MiddleSize_Def"] = 1696
}, {
    ["ResAdd_Damage"] = 2546
}, --[[{
    ["stun_res"] = 131
}, {
    ["high_fire_res"] = 131
}, {
    ["high_freezing_res"] = 131
}, {
    ["high_lighting_res"] = 131
}, {
    ["high_poison_res"] = 131
}, {
    ["high_laceration_res"] = 131
}, {
    ["portion_expansion"] = 20001
},]] {
    ["ADD_CLOTH"] = 1696
}, {
    ["ADD_LEATHER"] = 1696
}, {
    ["ADD_IRON"] = 1696
}, {
    ["ADD_SMALLSIZE"] = 1696
}, {
    ["ADD_MIDDLESIZE"] = 1696
}, {
    ["ADD_LARGESIZE"] = 1696
}, {
    ["ADD_GHOST"] = 1696
}, {
    ["ADD_FORESTER"] = 1696
}, {
    ["ADD_WIDLING"] = 1696
}, {
    ["ADD_VELIAS"] = 1696
}, {
    ["ADD_PARAMUNE"] = 1696
}, {
    ["ADD_KLAIDA"] = 1696
}, {
    ["Add_Damage_Atk"] = 2546
}, --[[{
    ["AllMaterialType_Atk"] = 1562
}, {
    ["AllRace_Atk"] = 1562
},]] {
    ["perfection"] = 3200
}, {
    ["revenge"] = 24000
}}

local low500armortbl = {{
    ["STR"] = 203
}, {
    ["DEX"] = 203
}, {
    ["INT"] = 203
}, {
    ["CON"] = 203
}, {
    ["MNA"] = 203
}, {
    ["BLK"] = 679
}, {
    ["BLK_BREAK"] = 679
}, {
    ["ADD_HR"] = 679
}, {
    ["ADD_DR"] = 679
}, {
    ["CRTHR"] = 679
}, {
    ["CRTDR"] = 679
}, {
    ["RHP"] = 679
}, {
    ["RSP"] = 679
}, {
    ["CRTDR"] = 679
}, {
    ["Cloth_Def"] = 1359
}, {
    ["Leather_Def"] = 1359
}, {
    ["Iron_Def"] = 1359
}, {
    ["MiddleSize_Def"] = 1359
}, {
    ["ResAdd_Damage"] = 1696
}, {
    ["stun_res"] = 131
}, {
    ["high_fire_res"] = 131
}, {
    ["high_freezing_res"] = 131
}, {
    ["high_lighting_res"] = 131
}, {
    ["high_poison_res"] = 131
}, {
    ["high_laceration_res"] = 131
}, --[[{
    ["portion_expansion"] = 20001
},]] {
    ["ADD_CLOTH"] = 1359
}, {
    ["ADD_LEATHER"] = 1359
}, {
    ["ADD_IRON"] = 1359
}, {
    ["ADD_SMALLSIZE"] = 1359
}, {
    ["ADD_MIDDLESIZE"] = 1359
}, {
    ["ADD_LARGESIZE"] = 1359
}, {
    ["ADD_GHOST"] = 1359
}, {
    ["ADD_FORESTER"] = 1359
}, {
    ["ADD_WIDLING"] = 1359
}, {
    ["ADD_VELIAS"] = 1359
}, {
    ["ADD_PARAMUNE"] = 1359
}, {
    ["ADD_KLAIDA"] = 1359
}, {
    ["Add_Damage_Atk"] = 1696
}, {
    ["AllMaterialType_Atk"] = 1156
}, {
    ["AllRace_Atk"] = 1156
} --[[{
    ["perfection"] = 3200
}, {
    ["revenge"] = 24000
}]] }

local high480weapontbl = {{
    ["STR"] = 213
}, {
    ["DEX"] = 213
}, {
    ["INT"] = 213
}, {
    ["CON"] = 213
}, {
    ["MNA"] = 213
}, {
    ["BLK"] = 708
}, {
    ["BLK_BREAK"] = 708
}, {
    ["ADD_HR"] = 708
}, {
    ["ADD_DR"] = 708
}, {
    ["CRTHR"] = 708
}, {
    ["CRTDR"] = 708
}, {
    ["RHP"] = 708
}, {
    ["RSP"] = 708
}, {
    ["CRTDR"] = 708
}, {
    ["Cloth_Def"] = 1414
}, {
    ["Leather_Def"] = 1414
}, {
    ["Iron_Def"] = 1414
}, {
    ["MiddleSize_Def"] = 1414
}, {
    ["ResAdd_Damage"] = 2122
}, --[[{
    ["stun_res"] = 131
}, {
    ["high_fire_res"] = 131
}, {
    ["high_freezing_res"] = 131
}, {
    ["high_lighting_res"] = 131
}, {
    ["high_poison_res"] = 131
}, {
    ["high_laceration_res"] = 131
}, {
    ["portion_expansion"] = 20001
},]] {
    ["ADD_CLOTH"] = 1414
}, {
    ["ADD_LEATHER"] = 1414
}, {
    ["ADD_IRON"] = 1414
}, {
    ["ADD_SMALLSIZE"] = 1414
}, {
    ["ADD_MIDDLESIZE"] = 1414
}, {
    ["ADD_LARGESIZE"] = 1414
}, {
    ["ADD_GHOST"] = 1414
}, {
    ["ADD_FORESTER"] = 1414
}, {
    ["ADD_WIDLING"] = 1414
}, {
    ["ADD_VELIAS"] = 1414
}, {
    ["ADD_PARAMUNE"] = 1414
}, {
    ["ADD_KLAIDA"] = 1414
}, {
    ["Add_Damage_Atk"] = 2122
}, {
    ["AllMaterialType_Atk"] = 1202
}, {
    ["AllRace_Atk"] = 1202
}, {
    ["perfection"] = 2001
}, {
    ["revenge"] = 10001
}}

local high480armortbl = {{
    ["STR"] = 170
}, {
    ["DEX"] = 170
}, {
    ["INT"] = 170
}, {
    ["CON"] = 170
}, {
    ["MNA"] = 170
}, {
    ["BLK"] = 566
}, {
    ["BLK_BREAK"] = 566
}, {
    ["ADD_HR"] = 566
}, {
    ["ADD_DR"] = 566
}, {
    ["CRTHR"] = 566
}, {
    ["CRTDR"] = 566
}, {
    ["RHP"] = 566
}, {
    ["RSP"] = 566
}, {
    ["CRTDR"] = 566
}, {
    ["Cloth_Def"] = 1133
}, {
    ["Leather_Def"] = 1133
}, {
    ["Iron_Def"] = 1133
}, {
    ["MiddleSize_Def"] = 1133
}, {
    ["ResAdd_Damage"] = 1414
}, {
    ["stun_res"] = 101
}, {
    ["high_fire_res"] = 101
}, {
    ["high_freezing_res"] = 101
}, {
    ["high_lighting_res"] = 101
}, {
    ["high_poison_res"] = 101
}, {
    ["high_laceration_res"] = 101
}, --[[{
    ["portion_expansion"] = 20001
},]] {
    ["ADD_CLOTH"] = 1133
}, {
    ["ADD_LEATHER"] = 1133
}, {
    ["ADD_IRON"] = 1133
}, {
    ["ADD_SMALLSIZE"] = 1133
}, {
    ["ADD_MIDDLESIZE"] = 1133
}, {
    ["ADD_LARGESIZE"] = 1133
}, {
    ["ADD_GHOST"] = 1133
}, {
    ["ADD_FORESTER"] = 1133
}, {
    ["ADD_WIDLING"] = 1133
}, {
    ["ADD_VELIAS"] = 1133
}, {
    ["ADD_PARAMUNE"] = 1133
}, {
    ["ADD_KLAIDA"] = 1133
}, {
    ["Add_Damage_Atk"] = 1414
}, {
    ["AllMaterialType_Atk"] = 964
}, {
    ["AllRace_Atk"] = 964
} --[[{
    ["perfection"] = 3200
}, {
    ["revenge"] = 24000
}]] }

local low480weapontbl = {{
    ["STR"] = 169
}, {
    ["DEX"] = 169
}, {
    ["INT"] = 169
}, {
    ["CON"] = 169
}, {
    ["MNA"] = 169
}, {
    ["BLK"] = 565
}, {
    ["BLK_BREAK"] = 565
}, {
    ["ADD_HR"] = 565
}, {
    ["ADD_DR"] = 565
}, {
    ["CRTHR"] = 565
}, {
    ["CRTDR"] = 565
}, {
    ["RHP"] = 565
}, {
    ["RSP"] = 565
}, {
    ["CRTDR"] = 565
}, {
    ["Cloth_Def"] = 1130
}, {
    ["Leather_Def"] = 1130
}, {
    ["Iron_Def"] = 1130
}, {
    ["MiddleSize_Def"] = 1130
}, {
    ["ResAdd_Damage"] = 1696
}, --[[{
    ["stun_res"] = 131
}, {
    ["high_fire_res"] = 131
}, {
    ["high_freezing_res"] = 131
}, {
    ["high_lighting_res"] = 131
}, {
    ["high_poison_res"] = 131
}, {
    ["high_laceration_res"] = 131
}, {
    ["portion_expansion"] = 20001
},]] {
    ["ADD_CLOTH"] = 1130
}, {
    ["ADD_LEATHER"] = 1130
}, {
    ["ADD_IRON"] = 1130
}, {
    ["ADD_SMALLSIZE"] = 1130
}, {
    ["ADD_MIDDLESIZE"] = 1130
}, {
    ["ADD_LARGESIZE"] = 1130
}, {
    ["ADD_GHOST"] = 1130
}, {
    ["ADD_FORESTER"] = 1130
}, {
    ["ADD_WIDLING"] = 1130
}, {
    ["ADD_VELIAS"] = 1130
}, {
    ["ADD_PARAMUNE"] = 1130
}, {
    ["ADD_KLAIDA"] = 1130
}, {
    ["Add_Damage_Atk"] = 1696
}, {
    ["AllMaterialType_Atk"] = 960
}, {
    ["AllRace_Atk"] = 960
}, {
    ["perfection"] = 1600
}, {
    ["revenge"] = 8000
}}

local low480armortbl = {{
    ["STR"] = 135
}, {
    ["DEX"] = 135
}, {
    ["INT"] = 135
}, {
    ["CON"] = 135
}, {
    ["MNA"] = 135
}, {
    ["BLK"] = 452
}, {
    ["BLK_BREAK"] = 452
}, {
    ["ADD_HR"] = 452
}, {
    ["ADD_DR"] = 452
}, {
    ["CRTHR"] = 452
}, {
    ["CRTDR"] = 452
}, {
    ["RHP"] = 452
}, {
    ["RSP"] = 452
}, {
    ["Cloth_Def"] = 905
}, {
    ["Leather_Def"] = 905
}, {
    ["Iron_Def"] = 905
}, {
    ["MiddleSize_Def"] = 905
}, {
    ["ResAdd_Damage"] = 1130
}, {
    ["stun_res"] = 80
}, {
    ["high_fire_res"] = 80
}, {
    ["high_freezing_res"] = 80
}, {
    ["high_lighting_res"] = 80
}, {
    ["high_poison_res"] = 80
}, {
    ["high_laceration_res"] = 80
}, {
    ["portion_expansion"] = 15000
}, {
    ["ADD_CLOTH"] = 905
}, {
    ["ADD_LEATHER"] = 905
}, {
    ["ADD_IRON"] = 905
}, {
    ["ADD_SMALLSIZE"] = 905
}, {
    ["ADD_MIDDLESIZE"] = 905
}, {
    ["ADD_LARGESIZE"] = 905
}, {
    ["ADD_GHOST"] = 905
}, {
    ["ADD_FORESTER"] = 905
}, {
    ["ADD_WIDLING"] = 905
}, {
    ["ADD_VELIAS"] = 905
}, {
    ["ADD_PARAMUNE"] = 905
}, {
    ["ADD_KLAIDA"] = 905
}, {
    ["Add_Damage_Atk"] = 1130
}, {
    ["AllMaterialType_Atk"] = 770
}, {
    ["AllRace_Atk"] = 770
} --[[{
    ["perfection"] = 3200
}, {
    ["revenge"] = 24000
}]] }

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
    local remain_time = GET_REMAIN_SECOND_ENGRAVE_SLOT_EXTENSION_TIME(acc)
    -- print(tostring(remain_time))
    local max_page = GET_MAX_ENGARVE_SLOT_COUNT(acc)
    -- print(tostring(max_page))
    local page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc) + 5
    for i = 1, page_max do
        local bg = GET_CHILD_RECURSIVELY(frame, "bg" .. i)
        if bg ~= nil then
            frame:RemoveChild("bg" .. i)
        end
    end
    local Y = 10
    local YY = 10

    for i = 1, page_max do
        if i <= 5 then

            local bg = frame:CreateOrGetControl("groupbox", "bg" .. i, Y, 10, 281, 490)
            AUTO_CAST(bg)
            -- bg:SetOffset(0, 10)
            bg:SetEventScript(ui.RBUTTONUP, "goddess_icor_manager_list_close")
            bg:SetTextTooltip("右クリックで閉じます。{nl}Right click to close.")
            Y = Y + 283
            local pagename_text = bg:CreateOrGetControl("richtext", "pagename_text" .. i, 10, 5)
            AUTO_CAST(pagename_text)
            local pagename = goddess_icor_manager_get_pagename(i)

            if remain_time == 0 and tonumber(max_page) < i then
                pagename_text:SetText("{ol}{#FF0000}" .. pagename .. goddess_icor_manager_language(" disabled"))
            else
                pagename_text:SetText("{ol}{#FFFF00}" .. pagename)
            end
            -- pagename_text:SetText(pagename)
            bg:SetSkinName("bg")
            bg:ShowWindow(1)

            local manage_X = 0
            for j = 1, #managed_list do
                local manage_bg = bg:CreateOrGetControl("groupbox", "manage_bg" .. j, 0, 30 + manage_X, 258, 120)
                manage_bg:SetEventScript(ui.RBUTTONUP, "goddess_icor_manager_list_close")
                manage_bg:SetTextTooltip("右クリックで閉じます。{nl}Right click to close.")
                local manage_text = manage_bg:CreateOrGetControl("richtext", "manage_text" .. j, 10, 0)
                manage_text:SetText("{ol}" .. goddess_icor_manager_language(managed_list[j]))
                -- manage_bg:SetSkinName("chat_window_2");
                manage_bg:SetSkinName("test_Item_tooltip_equip_sub");
                manage_X = manage_X + 122
                -- end
                local parts1 = {}
                local parts2 = {}
                local parts3 = {}

                -- for j = 1, #managed_list do

                local option_prop, group_prop, value_prop, is_goddess_option =
                    goddess_icor_manager_GET_ENGRAVED_OPTION_LIST(etc, i, managed_list[j])
                -- print(tostring(option_prop))
                if option_prop ~= nil then
                    --[[local gemframe = ui.GetFrame("goddess_equip_manager")
                    local randomoption_bg = GET_CHILD_RECURSIVELY(gemframe, "randomoption_bg")
                    local slot = GET_CHILD(randomoption_bg, 'slot')
                    local guid = slot:GetUserValue('ITEM_GUID')
                    print(tostring(guid))]]
                    for part in option_prop:gmatch("([^/]+)") do
                        table.insert(parts1, part)
                    end

                    for part in group_prop:gmatch("([^/]+)") do
                        table.insert(parts2, part)
                    end

                    for part in value_prop:gmatch("([^/]+)") do
                        table.insert(parts3, part)
                    end
                    --[[for k = 1, #managed_list do
                    local option = bg:CreateOrGetControl("richtext", "option" .. k, 10, i + 20 + k * 15)
                    option:SetText(parts1[k] .. ":" .. parts3[k])
                end]]

                    goddess_icor_manager_set_text(manage_bg, parts1, parts2, parts3, manage_text)
                end
            end

        elseif i >= 6 then
            local bg = frame:CreateOrGetControl("groupbox", "bg" .. i, YY, 500, 281, 490)
            AUTO_CAST(bg)
            bg:SetEventScript(ui.RBUTTONUP, "goddess_icor_manager_list_close")
            bg:SetTextTooltip("右クリックで閉じます。{nl}Right click to close.")
            if remain_time == 0 and max_page < i then
                -- bg:SetEnable(0)
                -- bg:SetGrayStyle(0);
            end
            YY = YY + 283
            local pagename_text = bg:CreateOrGetControl("richtext", "pagename_text" .. i, 10, 5)
            AUTO_CAST(pagename_text)
            local pagename = goddess_icor_manager_get_pagename(i)

            if remain_time == 0 and tonumber(max_page) < i then
                pagename_text:SetText("{ol}{#FF0000}" .. pagename .. goddess_icor_manager_language(" disabled"))
            else
                pagename_text:SetText("{ol}{#FFFF00}" .. pagename)
            end
            bg:SetSkinName("bg")
            bg:ShowWindow(1)

            local manage_X = 0
            for j = 1, #managed_list do
                local manage_bg = bg:CreateOrGetControl("groupbox", "manage_bg" .. j, 0, 30 + manage_X, 258, 120)
                manage_bg:SetEventScript(ui.RBUTTONUP, "goddess_icor_manager_list_close")
                manage_bg:SetTextTooltip("右クリックで閉じます。{nl}Right click to close.")

                local manage_text = manage_bg:CreateOrGetControl("richtext", "manage_text" .. j, 10, 0)
                manage_text:SetText("{ol}" .. goddess_icor_manager_language(managed_list[j]))
                -- manage_text:SetText(managed_list[j])
                -- manage_bg:SetSkinName("tooltip1");
                manage_bg:SetSkinName("test_Item_tooltip_equip_sub");
                -- manage_bg:SetColorTone('CC808080')
                manage_X = manage_X + 122
                -- end
                local parts1 = {}
                local parts2 = {}
                local parts3 = {}

                -- for j = 1, #managed_list do

                local option_prop, group_prop, value_prop, is_goddess_option =
                    goddess_icor_manager_GET_ENGRAVED_OPTION_LIST(etc, i, managed_list[j])
                -- print(tostring(option_prop))
                if option_prop ~= nil then
                    for part in option_prop:gmatch("([^/]+)") do
                        table.insert(parts1, part)
                    end

                    for part in group_prop:gmatch("([^/]+)") do
                        table.insert(parts2, part)
                    end

                    for part in value_prop:gmatch("([^/]+)") do
                        table.insert(parts3, part)
                    end

                    goddess_icor_manager_set_text(manage_bg, parts1, parts2, parts3, manage_text)
                end
            end
        end
    end

end

function goddess_icor_manager_set_text(manage_bg, parts1, parts2, parts3, manage_text)

    for k = 1, #parts1 do

        local option = manage_bg:CreateOrGetControl("richtext", "option" .. k, 10, k * 20)
        local color = goddess_icor_manager_color(tostring(parts2[k]))
        option:SetText("{ol}" .. color .. goddess_icor_manager_language(parts1[k]) .. "{ol}{#FFFFFF} : " ..
                           "{ol}{#FFFFFF}" .. parts3[k])
        -- manage_bg:SetColorTone("AAFFD700"); -- 500上級
        -- manage_bg:SetColorTone("AAFFFF00"); -- 500普通
        -- manage_bg:SetColorTone("AAFF4500"); -- 480上級
        -- manage_bg:SetColorTone("AAFFA500"); -- 480普通
        local colortone = goddess_icor_manager_set_frame_color(manage_bg, parts1, parts2, parts3, manage_text)
        -- print(tostring(colortone))
        manage_bg:SetColorTone(colortone)
        -- print(parts1[k] .. ":" .. tonumber(parts3[k]))
        -- local mnage_color = goddess_icor_manager_set_frame_color(parts1, parts3)
        -- goddess_icor_manager_set_frame_color(manage_bg, parts1, parts2, parts3)
    end

end
-- print(tostring(ClMsg("ADD_MATK")))

function goddess_icor_manager_set_frame_color(manage_bg, parts1, parts2, parts3, manage_text)
    local frameName = manage_bg:GetName()
    -- print(tostring(manage_bg:GetName()))
    if frameName == "manage_bg1" or frameName == "manage_bg2" or frameName == "manage_bg7" or frameName == "manage_bg8" then
        for i = 1, #high500weapontbl do
            local key = high500weapontbl[i]
            local keyName = next(key)
            local value = key[next(key)] -- 次のキー（最初のキー）の値を取得
            for j = 1, #parts1 do

                if tostring(parts1[j]) == tostring(keyName) and tonumber(parts3[j]) >= tonumber(value) then
                    -- local manage_text = GET_CHILD_RECURSIVELY(manage_bg, "manage_text" .. j)

                    local text = manage_text:GetText()
                    if string.find(text, goddess_icor_manager_language(" 500Advanced")) == nil then
                        manage_text:SetText(text .. "{ol}" .. goddess_icor_manager_language(" 500Advanced"))

                    end
                    return "AAFFD700"
                end
            end
        end
        for i = 1, #low500weapontbl do
            local key = low500weapontbl[i]
            local keyName = next(key)
            local value = key[next(key)] -- 次のキー（最初のキー）の値を取得
            for j = 1, #parts1 do
                if tostring(parts1[j]) == tostring(keyName) and tonumber(parts3[j]) >= tonumber(value) then
                    local text = manage_text:GetText()
                    if string.find(text, " LV500") == nil then
                        manage_text:SetText(text .. "{ol} LV500")
                    end
                    return "AAFFFACD"
                end
            end
        end
        for i = 1, #high480weapontbl do
            local key = high480weapontbl[i]
            local keyName = next(key)
            local value = key[next(key)] -- 次のキー（最初のキー）の値を取得
            for j = 1, #parts1 do

                if tostring(parts1[j]) == tostring(keyName) and tonumber(parts3[j]) >= tonumber(value) then
                    local text = manage_text:GetText()
                    if string.find(text, goddess_icor_manager_language(" 480Advanced")) == nil then
                        manage_text:SetText(text .. "{ol}" .. goddess_icor_manager_language(" 480Advanced"))

                    end
                    return "AAFF00FF"
                end
            end
        end
        for i = 1, #low480weapontbl do
            local key = low480weapontbl[i]
            local keyName = next(key)
            local value = key[next(key)] -- 次のキー（最初のキー）の値を取得
            for j = 1, #parts1 do

                if tostring(parts1[j]) == tostring(keyName) and tonumber(parts3[j]) >= tonumber(value) then
                    local text = manage_text:GetText()
                    if string.find(text, " LV480") == nil then
                        manage_text:SetText(text .. "{ol} LV480")
                    end
                    return "AADDA0DD"
                end
            end
        end
    else
        for i = 1, #high500armortbl do
            local key = high500armortbl[i]
            local keyName = next(key)
            local value = key[next(key)] -- 次のキー（最初のキー）の値を取得
            for j = 1, #parts1 do

                if tostring(parts1[j]) == tostring(keyName) and tonumber(parts3[j]) >= tonumber(value) then
                    local text = manage_text:GetText()
                    if string.find(text, goddess_icor_manager_language(" 500Advanced")) == nil then
                        manage_text:SetText(text .. "{ol}" .. goddess_icor_manager_language(" 500Advanced"))

                    end
                    return "AAFFD700"
                end
            end
        end
        for i = 1, #low500armortbl do
            local key = low500armortbl[i]
            local keyName = next(key)
            local value = key[next(key)] -- 次のキー（最初のキー）の値を取得
            for j = 1, #parts1 do
                if tostring(parts1[j]) == tostring(keyName) and tonumber(parts3[j]) >= tonumber(value) then
                    local text = manage_text:GetText()
                    if string.find(text, " LV500") == nil then
                        manage_text:SetText(text .. "{ol} LV500")
                    end
                    return "AAFFFACD"
                end
            end
        end
        for i = 1, #high480armortbl do
            local key = high480armortbl[i]
            local keyName = next(key)
            local value = key[next(key)] -- 次のキー（最初のキー）の値を取得
            for j = 1, #parts1 do

                if tostring(parts1[j]) == tostring(keyName) and tonumber(parts3[j]) >= tonumber(value) then
                    local text = manage_text:GetText()
                    if string.find(text, goddess_icor_manager_language(" 480Advanced")) == nil then
                        manage_text:SetText(text .. "{ol}" .. goddess_icor_manager_language(" 480Advanced"))

                    end
                    return "AAFF00FF"
                end
            end
        end
        for i = 1, #low480armortbl do
            local key = low480armortbl[i]
            local keyName = next(key)
            local value = key[next(key)] -- 次のキー（最初のキー）の値を取得
            for j = 1, #parts1 do

                if tostring(parts1[j]) == tostring(keyName) and tonumber(parts3[j]) >= tonumber(value) then
                    local text = manage_text:GetText()
                    if string.find(text, " LV480") == nil then
                        manage_text:SetText(text .. "{ol} LV480")
                    end
                    return "AADDA0DD"
                end
            end
        end
    end
    return "AA000000"
end

function goddess_icor_manager_color(str)

    if str == "UTIL_ARMOR" then
        return "{#9966CC}"
    elseif str == "STAT" then
        return "{#228B22}"
    elseif str == "ATK" then
        return "{#FF0000}"
    elseif str == "DEF" then
        return "{#00FFFF}"
    elseif str == "SPECIAL" then
        return "{#FFD700}"
    else
        return "{#FFFFFF}"
    end

end

function goddess_icor_manager_language(str)
    local language = option.GetCurrentCountry()

    if language == "Japanese" then
        if str == " 500Advanced" then
            str = " 500上級"
        end
        if str == " 480Advanced" then
            str = " 480上級"
        end
        if str == "MiddleSize_Def" then
            str = "中型対象攻撃力相殺"
        end
        if str == "Leather_Def" then
            str = "レザー対象攻撃力相殺"
        end
        if str == "Cloth_Def" then
            str = "クロース対象攻撃力相殺"
        end
        if str == "Iron_Def" then
            str = "プレート対象攻撃力相殺"
        end
        if str == "Add_Damage_Atk" then
            str = "追加ダメージ"
        end
        if str == "ResAdd_Damage" then
            str = "追加ダメージ抵抗"
        end
        if str == " disabled" then
            str = " 使用不可"
        end
        if str == "RH" then
            str = "武器"
        end
        if str == "LH" then
            str = "補助"
        end
        if str == "RH_SUB" then
            str = "裏武器"
        end
        if str == "LH_SUB" then
            str = "裏補助"
        end
        if str == "SHIRT" then
            str = "上半身"
        end
        if str == "PANTS" then
            str = "下半身"
        end
        if str == "GLOVES" then
            str = "手袋"
        end
        if str == "GLOVES" then
            str = "手袋"
        end
        if str == "BOOTS" then
            str = "靴"
        end
        if str == "CRTHR" then
            str = "クリティカル発生"
        end
        if str == "STR" then
            str = "力"
        end
        if str == "perfection" then
            str = "パーフェクト効果"
        end
        if str == "AllRace_Atk" then
            str = "全ての種族の対象攻撃力"
        end
        if str == "AllMaterialType_Atk" then
            str = "全ての防具の対象攻撃力"
        end
        if str == "ADD_HR" then
            str = "命中"
        end

        if str == "ADD_MIDDLESIZE" then
            str = "中型対象攻撃力"
        end

        if str == "high_laceration_res" then
            str = "極：出血過多抵抗"
        end
        if str == "CON" then
            str = "体力"
        end
        if str == "BLK_BREAK" then
            str = "ブロック貫通"
        end
        if str == "ADD_IRON" then
            str = "プレート防御対象攻撃力"
        end
        if str == "ADD_LEATHER" then
            str = "レザー防御対象攻撃力"
        end
        if str == "DEX" then
            str = "敏捷"
        end
        if str == "ADD_GHOST" then
            str = "アストラル防御対象攻撃力"
        end
        if str == "ADD_PARAMUNE" then
            str = "変異型対象攻撃力"
        end
        if str == "ADD_KLAIDA" then
            str = "昆虫型対象攻撃力"
        end
        if str == "ADD_WIDLING" then
            str = "野獣型対象攻撃力"
        end
        if str == "rada_bless_1" then
            str = "ラダの恩恵(+1)"
        end
        if str == "INT" then
            str = "知能"
        end

        if str == "CRTDR" then
            str = "クリティカル抵抗"
        end
        if str == "high_freezing_res" then
            str = "極：寒冷抵抗"
        end
        if str == "RHP" then
            str = "HP回復力"
        end
        if str == "BLK" then
            str = "ブロック"
        end
        if str == "ADD_DR" then
            str = "回避"
        end
        if str == "ADD_FORESTER" then
            str = "植物型対象攻撃力"
        end
        if str == "ADD_CLOTH" then
            str = "クロース防御対象攻撃力"
        end
        if str == "ADD_VELIAS" then
            str = "悪魔型対象攻撃力"
        end
        if str == "high_lighting_res" then
            str = "極：過電荷抵抗"
        end
        if str == "ADD_LARGESIZE" then
            str = "大型対象攻撃力"
        end
        if str == "stun_res" then
            str = "極：気絶抵抗"
        end
        if str == "portion_expansion" then
            str = "HP回復エリクサー広域化"
        end
        if str == "MNA" then
            str = "精神"
        end

        if str == "dievdirbys_bless_1" then
            str = "テスラの恩恵(+1)"
        end
        if str == "zemyna_bless_1" then
            str = "ジェミナの恩恵(+1)"
        end
        if str == "payawoota_bless_1" then
            str = "パヤウタの恩恵(+1)"
        end
        if str == "fireMage_bless_1" then
            str = "メリンの恩恵(+1)"
        end
        if str == "saule_bless_1" then
            str = "サウレの恩恵(+1)"
        end

        return str
    end
end

function goddess_icor_manager_list_init()
    local frame = ui.GetFrame("goddess_icor_manager")
    frame:Resize(1430, 1000)
    frame:SetOffset(0, 20)
    frame:ShowWindow(1)
    frame:SetLayerLevel(120)
    frame:ShowTitleBar(0);
    frame:SetSkinName('base_btn')
    --[[local close = frame:CreateOrGetControl("button", "close", 0, 0, 30, 30)
    close:SetText("×")
    close:SetGravity(ui.RIGHT, ui.TOP);
    close:SetMargin(0, 0, 20, -70);
    close:ShowWindow(1)
    close:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_list_close")]]
    goddess_icor_manager_list_gb_init(frame)
    -- close:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_list_maxcount")
end

function goddess_icor_manager_list_close(frame)
    local frame = ui.GetFrame("goddess_icor_manager")
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

    local spot_name = slot:GetUserValue('EQUIP]]
