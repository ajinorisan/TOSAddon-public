local addonName = "always_status"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.1.6"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")
local os = require("os")
local json = require("json")

local status_list = {"STR", "INT", "CON", "MNA", "DEX", "gear_score", "ability_point_score", "PATK", "MATK", "HEAL_PWR",
                     "SR", "HR", "BLK_BREAK", "CRTATK", "CRTMATK", "CRTHR", "DEF", "MDEF", "SDR", "DR", "BLK", "CRTDR",
                     "MSPD", "CastingSpeed", "Add_Damage_Atk", "ResAdd_Damage", "Aries_Atk", "Slash_Atk", "Strike_Atk",
                     "Arrow_Atk", "Cannon_Atk", "Gun_Atk", "Magic_Melee_Atk", "Magic_Fire_Atk", "Magic_Ice_Atk",
                     "Magic_Lightning_Atk", "Magic_Earth_Atk", "Magic_Poison_Atk", "Magic_Dark_Atk", "Magic_Holy_Atk",
                     "Magic_Soul_Atk", "BOSS_ATK", "Cloth_Atk", "Leather_Atk", "Iron_Atk", "Ghost_Atk",
                     "MiddleSize_Def", "Cloth_Def", "Leather_Def", "Iron_Def", "stun_res", "high_fire_res",
                     "high_freezing_res", "high_lighting_res", "high_poison_res", "high_laceration_res",
                     "portion_expansion", "Forester_Atk", "Widling_Atk", "Klaida_Atk", "Paramune_Atk", "Velnias_Atk",
                     "perfection", "revenge"}

local color_attribute = {}
color_attribute['Cloth_Def'] = 'Cloth_Def_status'
color_attribute['Leather_Def'] = 'Leather_Def_status'
color_attribute['Iron_Def'] = 'Iron_Def_status'
color_attribute['MiddleSize_Def'] = 'MiddleSize_Def_status'
color_attribute['AllMaterialType_Def'] = 'AllMaterialType_Def_status'
color_attribute['ResAdd_Damage'] = 'ResAdd_Damage_status'
color_attribute['SmallSize_Atk'] = 'SmallSize_Atk_status'
color_attribute['MiddleSize_Atk'] = 'MiddleSize_Atk_status'
color_attribute['LargeSize_Atk'] = 'LargeSize_Atk_status'
color_attribute['Cloth_Atk'] = 'Cloth_Atk_status'
color_attribute['Leather_Atk'] = 'Leather_Atk_status'
color_attribute['Iron_Atk'] = 'Iron_Atk_status'
color_attribute['Forester_Atk'] = 'Forester_Atk_status'
color_attribute['Widling_Atk'] = 'Widling_Atk_status'
color_attribute['Klaida_Atk'] = 'Klaida_Atk_status'
color_attribute['Paramune_Atk'] = 'Paramune_Atk_status'
color_attribute['Velnias_Atk'] = 'Velnias_Atk_status'
color_attribute['Ghost_Atk'] = 'Ghost_Atk_status'
color_attribute['Add_Damage_Atk'] = 'Add_Damage_Atk_status'
color_attribute['BOSS_ATK'] = 'BOSS_ATK_status'
color_attribute['AllMaterialType_Atk'] = 'AllMaterialType_Atk_status'
color_attribute['AllSize_Atk'] = 'AllSize_Atk_status'
color_attribute['AllRace_Atk'] = 'AllRace_Atk_status'
color_attribute['perfection'] = 'perfection_status'
color_attribute['revenge'] = 'revenge_status'
color_attribute['stun_res'] = 'stun_res_status'
color_attribute['high_fire_res'] = 'high_fire_res_status'
color_attribute['high_freezing_res'] = 'high_freezing_res_status'
color_attribute['high_lighting_res'] = 'high_lighting_res_status'
color_attribute['high_poison_res'] = 'high_poison_res_status'
color_attribute['high_laceration_res'] = 'high_laceration_res_status'
color_attribute['portion_expansion'] = 'portion_expansion_status'

local base = {}
function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName];
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

function ALWAYS_STATUS_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    ReserveScript("always_status_original_frame_reduction()", 1.0)
    ReserveScript("always_status_load_settings()", 1.5)

    addon:RegisterMsg("GAME_START_3SEC", "always_status_original_frame_sound_config")

    acutil.setupEvent(addon, "STATUS_ONLOAD", "always_status_STATUS_ONLOAD");
    acutil.setupEvent(addon, "CONFIG_SOUNDVOL", "always_status_CONFIG_SOUNDVOL");

end

function always_status_original_frame_reduction()

    config.SetSoundVolume(0)
    local frame = ui.GetFrame("status")
    frame:ShowWindow(1)
    frame:Resize(0, 0)
    return
end

function always_status_CONFIG_SOUNDVOL(frame, msg)
    local ctrl = acutil.getEventArgs(msg)
    AUTO_CAST(ctrl)
    local volume = tonumber(ctrl:GetLevel())
    g.settings.volume = volume
    always_status_save_settings()
end

function always_status_STATUS_ONLOAD()
    local frame = ui.GetFrame("status")
    frame:Resize(500, 1080)
    frame:ShowWindow(1)
end

function always_status_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function always_status_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    local loginCID = info.GetCID(session.GetMyHandle())
    local volume = config.GetSoundVolume()

    if not settings then

        settings = {}
        settings.frame_X = 600
        settings.frame_Y = 300
        settings.enable = 1
        settings.volume = volume
        for i = 0, 10 do

            settings[tostring(i)] = {
                memo = "free memo " .. i,
                STR = 1,
                INT = 1,
                CON = 0,
                MNA = 0,
                DEX = 0,
                gear_score = 0,
                ability_point_score = 0,
                PATK = 1,
                MATK = 1,
                HEAL_PWR = 0,
                SR = 0,
                HR = 1,
                BLK_BREAK = 1,
                CRTATK = 1,
                CRTMATK = 1,
                CRTHR = 1,
                DEF = 0,
                MDEF = 0,
                SDR = 0,
                DR = 1,
                BLK = 0,
                CRTDR = 1,
                MSPD = 1,
                CastingSpeed = 1,
                Add_Damage_Atk = 0,
                ResAdd_Damage = 0,
                Aries_Atk = 0,
                Slash_Atk = 0,
                Strike_Atk = 0,
                Arrow_Atk = 0,
                Cannon_Atk = 0,
                Gun_Atk = 0,
                Magic_Melee_Atk = 0,
                Magic_Fire_Atk = 0,
                Magic_Ice_Atk = 0,
                Magic_Lightning_Atk = 0,
                Magic_Earth_Atk = 0,
                Magic_Poison_Atk = 0,
                Magic_Dark_Atk = 0,
                Magic_Holy_Atk = 0,
                Magic_Soul_Atk = 0,
                BOSS_ATK = 1,
                Cloth_Atk = 0,
                Leather_Atk = 0,
                Iron_Atk = 0,
                Ghost_Atk = 0,
                MiddleSize_Def = 1,
                Cloth_Def = 0,
                Leather_Def = 1,
                Iron_Def = 0,
                stun_res = 0,
                high_fire_res = 0,
                high_freezing_res = 0,
                high_lighting_res = 0,
                high_poison_res = 0,
                high_laceration_res = 0,
                portion_expansion = 0,
                Forester_Atk = 0,
                Widling_Atk = 0,
                Klaida_Atk = 0,
                Paramune_Atk = 0,
                Velnias_Atk = 0,
                perfection = 1,
                revenge = 0
            }

        end

        g.settings = settings

    else
        g.settings = settings

    end

    if g.settings[loginCID] == nil then
        g.settings[loginCID] = {
            key = 1,
            use = 1
        }

    end

    always_status_save_settings()

    always_status_frame_init()
end

function always_status_frame_init()

    local frame = ui.GetFrame(addonNameLower)

    frame:RemoveAllChild()
    frame:EnableHitTest(1)
    frame:EnableMove(g.settings.enable)
    frame:SetPos(g.settings.frame_X, g.settings.frame_Y)
    frame:SetTitleBarSkin("None")
    frame:SetSkinName("None")
    frame:SetLayerLevel(10)
    frame:SetEventScript(ui.LBUTTONUP, "always_status_frame_move") -- !
    frame:SetEventScript(ui.RBUTTONDOWN, "always_status_info_setting") -- !

    local as_text = frame:CreateOrGetControl("richtext", "as_text", 20, 5)
    as_text:SetText("{ol}{S10}Always Status")
    as_text:SetEventScript(ui.RBUTTONDOWN, "always_status_info_setting")
    as_text:SetTextTooltip("右クリックで表示設定{nl}" .. "Right-click to set display")

    local loginCID = info.GetCID(session.GetMyHandle())
    if g.settings_use[loginCID].use ~= 1 then

        local plus_slot = frame:CreateOrGetControl("slot", "plus_slot", 0, 3, 15, 15)
        AUTO_CAST(plus_slot)
        plus_slot:SetSkinName("None")
        plus_slot:EnablePop(0)
        plus_slot:EnableDrop(0)
        plus_slot:EnableDrag(0);
        plus_slot:SetEventScript(ui.LBUTTONUP, "always_status_frame_toggle") -- !
        local icon = CreateIcon(plus_slot);
        AUTO_CAST(icon)
        icon:SetImage("btn_plus");
        icon:SetTextTooltip("{ol}キャラクター毎に表示非表示を切り替えます。{nl}" ..
                                "Display and hide for each character.");
        frame:Resize(150, 20)
        frame:ShowWindow(1)
        return
    else

        local minus_slot = frame:CreateOrGetControl("slot", "minus_slot", 0, 3, 15, 15)
        AUTO_CAST(minus_slot)
        minus_slot:SetSkinName("None")
        minus_slot:EnablePop(0)
        minus_slot:EnableDrop(0)
        minus_slot:EnableDrag(0);
        minus_slot:SetEventScript(ui.LBUTTONUP, "always_status_frame_toggle")
        local icon = CreateIcon(minus_slot);
        AUTO_CAST(icon)
        icon:SetImage("btn_minus");
        icon:SetTextTooltip("{ol}キャラクター毎に表示非表示を切り替えます。{nl}" ..
                                "Display and hide for each character.");

        local y = 20
        local pc = GetMyPCObject();
        local statframe = ui.GetFrame("status")
        local box = GET_CHILD_RECURSIVELY(statframe, "internalstatusBox")
        local key = 0

        for i = 0, 10 do
            if g.settings[loginCID].key == i then
                key = i
                break
            end
        end

        for _, status in ipairs(status_list) do
            for k, v in pairs(g.settings[key]) do
                if status == k then
                    if v == 1 then
                        local title = frame:CreateOrGetControl("richtext", "title" .. k, 10, y)
                        AUTO_CAST(title)

                        if status == "STR" then
                            title:SetText(ClMsg("STR"))
                        elseif status == "INT" then
                            title:SetText(ClMsg("INT"))
                        elseif status == "CON" then
                            title:SetText(ClMsg("CON"))
                        elseif status == "MNA" then
                            title:SetText(ClMsg("MNA"))
                        elseif status == "DEX" then
                            title:SetText(ClMsg("DEX"))
                        elseif status == "gear_score" then
                            title:SetText(ScpArgMsg("EquipedItemGearScore"))
                        elseif status == "ability_point_score" then
                            title:SetText(ScpArgMsg("AbilityPointScore"))
                        elseif color_attribute[status] ~= nil then
                            title:SetText(ScpArgMsg(color_attribute[status]))
                        end
                        title:AdjustFontSizeByWidth(150)
                    end
                end
            end
        end

        -- iの昇順にソート
        local sortedSettings = {}
        for key, _ in pairs(sorted) do
            table.insert(sortedSettings, {
                key = key,
                value = g.no[key]
            })
        end
        table.sort(sortedSettings, function(a, b)
            return sorted[a.key] < sorted[b.key]
        end)

        local len = 0

        for _, entry in ipairs(sortedSettings) do
            -- for key, value in pairs(g.settings) do
            local key = tostring(entry.key)

            if entry.value == 1 then

                local title = frame:CreateOrGetControl("richtext", key, 10, y)
                AUTO_CAST(title)
                title:SetEventScript(ui.RBUTTONDOWN, "always_status_info_setting")
                title:SetTextTooltip("右クリックで表示設定{nl}" .. "Right-click to set display")

                if color_attribute[key] ~= nil then

                    title:SetText("{s16}{ol}" .. ScpArgMsg(color_attribute[key]))
                    title:AdjustFontSizeByWidth(150)
                    if string.len(title:GetText()) > len then
                        len = string.len(title:GetText())
                    end

                else
                    if key == "STR" then
                        title:SetText("{s16}{ol}{#00FF00}" .. ClMsg("STR"))

                    elseif key == "INT" then
                        title:SetText("{s16}{ol}{#00FF00}" .. ClMsg("INT"))
                    elseif key == "CON" then
                        title:SetText("{s16}{ol}{#00FF00}" .. ClMsg("CON"))
                    elseif key == "MNA" then
                        title:SetText("{s16}{ol}{#00FF00}" .. ClMsg("MNA"))
                    elseif key == "DEX" then
                        title:SetText("{s16}{ol}{#00FF00}" .. ClMsg("DEX"))
                    end
                    if key == "gear_score" then
                        title:SetText("{s16}{ol}{#00FF00}" .. ScpArgMsg("EquipedItemGearScore"))
                    elseif key == "ability_point_score" then
                        title:SetText("{s16}{ol}{#00FF00}" .. ScpArgMsg("AbilityPointScore"))
                    else
                        title:SetText("{s16}{ol}{#FF6600}" .. ScpArgMsg(key))
                    end
                    title:AdjustFontSizeByWidth(150)
                    if string.len(title:GetText()) > len then
                        len = string.len(title:GetText())
                    end
                end
                if (option.GetCurrentCountry() == "Japanese") then
                    -- print(title:GetText())
                    title:SetText(always_status_lang(title:GetText()))
                    title:AdjustFontSizeByWidth(150)
                end
                y = y + 20
                -- break
            end

        end

        y = 20
        for _, entry in ipairs(sortedSettings) do
            -- for key, value in pairs(g.settings) do
            local key = tostring(entry.key)
            if entry.value == 1 then
                local stat = frame:CreateOrGetControl("richtext", "stat" .. key, len * 3 + 5, y)
                AUTO_CAST(stat)
                stat:SetEventScript(ui.RBUTTONDOWN, "always_status_info_setting")
                stat:SetTextTooltip("右クリックで表示設定{nl}" .. "Right-click to set display")
                if key ~= "STR" and key ~= "INT" and key ~= "CON" and key ~= "MNA" and key ~= "DEX" then
                    local controlset = GET_CHILD_RECURSIVELY(box, key)
                    local status = GET_CHILD_RECURSIVELY(controlset, "stat")

                    stat:SetText("{ol}{s16}: " .. status:GetText())
                    if key == "gear_score" then
                        stat:AdjustFontSizeByWidth(60);
                    elseif key == "ability_point_score" then
                        stat:AdjustFontSizeByWidth(80);
                    end
                else
                    for i = 0, 4 do
                        local typeStr = GetStatTypeStr(i);

                        if key == typeStr then
                            local totalValue = pc[typeStr] + session.GetUserConfig(typeStr .. "_UP");
                            stat:SetText("{ol}{s16}: " .. totalValue)
                            -- print(typeStr .. totalValue)
                            break

                        end
                    end
                end
                if (option.GetCurrentCountry() == "Japanese") then
                    -- print(title:GetText())
                    stat:SetOffset(125, y)

                end
                y = y + 20
                -- break

            end

        end
        if (option.GetCurrentCountry() == "Japanese") then
            frame:Resize(260, y + 10)
        else
            frame:Resize(300, y + 10)
        end
        frame:ShowWindow(1)
        frame:RunUpdateScript("always_status_update", 0.5);
    end
end
