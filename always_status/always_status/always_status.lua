-- v1.0.0 ebisukeさんのstatview_ex_rがバグってたので新たに作った。
-- v1.0.1 表示が永遠に増えていくバグ直したつもり
-- v1.0.2 loadがバグってたのを修正
local addonName = "always_status"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.2"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")
local os = require("os")
local json = require("json")

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

function always_status_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function always_status_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not settings then
        g.settings = {}
        g.settings.frame_X = 600
        g.settings.frame_Y = 300
        g.settings.enable = 1
        for i = 0, 10 do
            local key = "no_" .. i
            g.settings[key] = {
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

    end
    -- g.settings = settings
    local loginCID = info.GetCID(session.GetMyHandle())

    if g.settings[loginCID] == nil then

        g.settings[loginCID] = 1

    end

    for i = 1, 10 do

        if g.settings[loginCID] == i then
            local noKey = "no_" .. i
            -- print(g.settings[loginCID])
            g.no = g.settings[noKey]
            --  print(noKey)
        end
    end
    always_status_save_settings()
    always_status_frame_init()
    --[[for key, value in pairs(g.no) do
        print(key .. ":" .. value)
    end]]

end

function ALWAYS_STATUS_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    -- always_status_original_frame_reductio()
    addon:RegisterMsg("GAME_START", "always_status_original_frame_reduction")
    addon:RegisterMsg("GAME_START", "always_status_load_settings")

    acutil.setupEvent(addon, "STATUS_ONLOAD", "always_status_STATUS_ONLOAD");

end

function always_status_memo_save(frame, ctrl, argStr, argNum)
    local text = ctrl:GetText()
    local loginCID = info.GetCID(session.GetMyHandle())
    g.settings[loginCID] = argNum

    argNum = "no_" .. argNum

    g.settings[argNum].memo = text

    ui.SysMsg("MEMO registered.")

    always_status_save_settings()

    -- always_status_load_settings()
    always_status_info_setting(frame, ctrl, argStr, argNum)
end

function always_status_info_setting_load(number)
    local frame = ui.GetFrame(addonNameLower .. "new_frame")

    local gb = GET_CHILD_RECURSIVELY(frame, "gb")

    local setting_gb = gb:CreateOrGetControl("groupbox", "setting_gb", 10, 70, gb:GetWidth() - 10, gb:GetHeight() - 80)
    AUTO_CAST(setting_gb)

    frame:SetLayerLevel(150)
    setting_gb:SetSkinName("test_frame_midle_light")
    -- setting_gb:SetEventScript(ui.RBUTTONDOWN, "always_status_frame_close")

    local y = 20 -- 初期のY座標
    for _, status in ipairs(status_list) do
        local check = setting_gb:CreateOrGetControl("checkbox", "check" .. status, 260, y, 20, 20)
        AUTO_CAST(check)

        check:SetEventScript(ui.LBUTTONUP, "always_status_checkbox")
        check:SetEventScriptArgNumber(ui.LBUTTONUP, number);
        local control = setting_gb:CreateOrGetControl("richtext", status, 20, y)
        AUTO_CAST(control)
        if color_attribute[status] ~= nil then

            control:SetText("{s16}{ol}" .. ScpArgMsg(color_attribute[status]))
            control:AdjustFontSizeByWidth(250)
        else

            if status == "STR" then
                control:SetText("{s16}{ol}{#00FF00}" .. ClMsg("STR"))
            elseif status == "INT" then
                control:SetText("{s16}{ol}{#00FF00}" .. ClMsg("INT"))
            elseif status == "CON" then
                control:SetText("{s16}{ol}{#00FF00}" .. ClMsg("CON"))
            elseif status == "MNA" then
                control:SetText("{s16}{ol}{#00FF00}" .. ClMsg("MNA"))
            elseif status == "DEX" then
                control:SetText("{s16}{ol}{#00FF00}" .. ClMsg("DEX"))
            end
            if status == "gear_score" then
                control:SetText("{s16}{ol}{#00FF00}" .. ScpArgMsg("EquipedItemGearScore"))
            elseif status == "ability_point_score" then
                control:SetText("{s16}{ol}{#00FF00}" .. ScpArgMsg("AbilityPointScore"))
            else
                control:SetText("{s16}{ol}{#FF6600}" .. ScpArgMsg(status))
            end
            -- print(tostring(control:GetWidth()))
            control:AdjustFontSizeByWidth(250)
        end
        y = y + 30 -- 次のラベルのY座標を調整
    end
    local yohaku = setting_gb:CreateOrGetControl("richtext", "yohaku", 20, y)
    yohaku:SetText("{s16}{ol} ")
    for _, status in ipairs(status_list) do
        for key, value in pairs(g.no) do
            -- print(tostring(status .. ":" .. key))
            if key == status then
                local check = GET_CHILD_RECURSIVELY(setting_gb, "check" .. status)
                -- print(value)
                check:SetCheck(value)
                break
            end
        end

    end
    -- print(tostring(number) .. "aru")

    -- local frame = ui.GetFrame(addonNameLower .. "new_frame")

    -- local gb = GET_CHILD_RECURSIVELY(frame, "gb")
    for i = 1, 10 do
        local memo = GET_CHILD_RECURSIVELY(gb, "memo" .. i)
        if i == number then
            memo:ShowWindow(1)
        else
            memo:ShowWindow(0)
        end
    end

    local loginCID = info.GetCID(session.GetMyHandle())
    g.settings[loginCID] = number
    -- g.no = {}
    number = "no_" .. number
    -- g.no = g.settings[number]
    for _, key in ipairs(status_list) do

        local check = GET_CHILD_RECURSIVELY(frame, "check" .. key)
        check:SetCheck(g.settings[number][key])
    end
    always_status_save_settings()
    always_status_load_settings()

    -- always_status_frame_init()

end

function always_status_info_setting(frame, ctrl, argStr, argNum)
    local frame = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "new_frame", 0, 0, 70, 30)
    AUTO_CAST(frame)
    frame:EnableHittestFrame(1);
    frame:EnableHitTest(1)
    frame:Resize(340, 900)
    frame:SetPos(10, 10)
    frame:RemoveAllChild()
    frame:ShowWindow(1)
    local gb = frame:CreateOrGetControl("groupbox", "gb", 10, 10, frame:GetWidth() - 10, frame:GetHeight() - 10)
    AUTO_CAST(gb)
    gb:SetSkinName("test_frame_midle_light")
    -- gb:SetEventScript(ui.LBUTTONDOWN, "always_status_info_setting")
    local title = gb:CreateOrGetControl("richtext", "title", 10, 40)
    title:SetText("{s18}{ol}{#FFFFFF}Display Setting")
    -- gb:SetEventScript(ui.RBUTTONDOWN, "always_status_frame_close")
    local close = gb:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "always_status_frame_close")

    local loginCID = info.GetCID(session.GetMyHandle())
    -- print(g.settings[loginCID])

    local dropList = gb:CreateOrGetControl('droplist', 'setting_DropList', 80, 10, 180, 20)
    AUTO_CAST(dropList)
    dropList:SetSkinName('droplist_normal');
    dropList:EnableHitTest(1);
    dropList:SetTextAlign("center", "center");
    for i = 1, 10 do
        local num = "no_" .. i
        if g.settings[num].memo == "free memo " .. i then
            dropList:AddItem(i, tostring("Data ") .. i, 0, "always_status_info_setting_load(" .. i .. ")");
        else
            dropList:AddItem(i, g.settings[num].memo, 0, "always_status_info_setting_load(" .. i .. ")");
        end
        local memo = gb:CreateOrGetControl('edit', 'memo' .. i, 155, 35, 125, 30)
        AUTO_CAST(memo)
        memo:SetEventScript(ui.ENTERKEY, "always_status_memo_save")
        memo:SetEventScriptArgNumber(ui.ENTERKEY, i)
        memo:SetFontName("white_16_ol")
        memo:SetTextAlign("center", "center")

        memo:SetText(g.settings[num].memo)
        memo:ShowWindow(0)
    end
    dropList:SelectItem(tonumber(g.settings[loginCID]) - 1)
    local memo = GET_CHILD_RECURSIVELY(gb, "memo" .. tonumber(g.settings[loginCID]))
    memo:ShowWindow(1)

    -- print(memo:GetName())

    local enablecheck = gb:CreateOrGetControl("checkbox", "enablecheck", 285, 40, 20, 20)
    AUTO_CAST(enablecheck)
    enablecheck:SetEventScript(ui.LBUTTONUP, "always_status_checkbox")
    enablecheck:SetTextTooltip("チェックするとフレームが固定されます。{nl}" ..
                                   "If checked, the frame is fixed.")
    if g.settings.enable == 0 then
        enablecheck:SetCheck(1)
    else
        enablecheck:SetCheck(0)
    end
    always_status_info_setting_load(tonumber(g.settings[loginCID]))
end

function always_status_checkbox(frame, ctrl, argStr, argNum)

    argNum = "no_" .. argNum
    -- g.no = g.settings[argNum]

    local ischeck = ctrl:IsChecked()
    local name = ctrl:GetName()
    if name == "enablecheck" then
        if ischeck == 1 then
            g.settings.enable = 0
            local asframe = ui.GetFrame(addonNameLower)
            asframe:EnableMove(0)
        else
            g.settings.enable = 1
            local asframe = ui.GetFrame(addonNameLower)
            asframe:EnableMove(1)
        end
    end

    for _, status in ipairs(status_list) do

        if tostring("check" .. status) == ctrl:GetName() then

            g.settings[argNum][status] = ischeck
            always_status_save_settings()
            -- g.no = g.settings[argNum]
            g.no[status] = ischeck
            -- print(tostring(g.settings[argNum][status]))
        end

    end

    -- always_status_load_settings()
    always_status_frame_init()
end

function always_status_update()
    local frame = ui.GetFrame(addonNameLower)
    local statframe = ui.GetFrame("status")
    local box = GET_CHILD_RECURSIVELY(statframe, "internalstatusBox")

    local pc = GetMyPCObject();
    for _, status in ipairs(status_list) do
        local as_title = GET_CHILD_RECURSIVELY(frame, status)
        if as_title ~= nil then
            local as_stat = GET_CHILD_RECURSIVELY(frame, "stat" .. status)
            local as_stat_text = string.gsub(as_stat:GetText(), ": ", "")
            -- print(as_stat_text)
            if status ~= "STR" and status ~= "INT" and status ~= "CON" and status ~= "MNA" and status ~= "DEX" then
                local controlset = GET_CHILD_RECURSIVELY(box, status)
                local title = GET_CHILD_RECURSIVELY(controlset, "title")

                local stat = GET_CHILD_RECURSIVELY(controlset, "stat")

                if tostring(as_stat_text) ~= tostring("{ol}{s16}" .. stat:GetText()) then
                    -- print("test")
                    as_stat:SetText("{ol}{s16}: " .. stat:GetText())
                    if status == "gear_score" then
                        as_stat:AdjustFontSizeByWidth(60);
                    elseif status == "ability_point_score" then
                        as_stat:AdjustFontSizeByWidth(80);
                    end
                end
            else
                for i = 0, 4 do
                    local typeStr = GetStatTypeStr(i);

                    if status == typeStr then
                        local totalValue = pc[typeStr] + session.GetUserConfig(typeStr .. "_UP");
                        as_stat:SetText("{ol}{s16}: " .. totalValue)

                    end
                end
            end

        end
    end
    return 1
end

function always_status_frame_init()
    -- print(g.settings.enable)
    local frame = ui.GetFrame(addonNameLower)

    frame:EnableHitTest(1)
    frame:EnableMove(g.settings.enable)

    frame:RemoveAllChild()

    frame:SetPos(g.settings.frame_X, g.settings.frame_Y)
    frame:SetTitleBarSkin("None")
    frame:SetSkinName("None")
    frame:SetLayerLevel(31)

    frame:SetEventScript(ui.LBUTTONUP, "always_status_frame_move")
    frame:SetEventScript(ui.RBUTTONDOWN, "always_status_info_setting")

    local as_text = frame:CreateOrGetControl("richtext", "as_text", 10, 5)
    as_text:SetText("{ol}{S10}Always Status")
    as_text:SetEventScript(ui.RBUTTONDOWN, "always_status_info_setting")
    as_text:SetTextTooltip("右クリックで表示設定{nl}" .. "Right-click to set display")

    local y = 20
    local pc = GetMyPCObject();
    local statframe = ui.GetFrame("status")
    local box = GET_CHILD_RECURSIVELY(statframe, "internalstatusBox")

    local sorted = {}
    local i = 1
    for _, status in ipairs(status_list) do
        for key, value in pairs(g.no) do
            if key == status then
                sorted[key] = i
                i = i + 1
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
            y = y + 20
            -- break
        end

    end
    -- print(len)
    frame:Resize(300, y + 10)
    frame:ShowWindow(1)
    frame:RunUpdateScript("always_status_update", 0.5);

end

function always_status_frame_close(frame)
    -- print(tostring(frame:GetName()))
    local frame = ui.GetFrame(addonNameLower .. "new_frame")

    frame:ShowWindow(0)

end

function always_status_STATUS_ONLOAD()
    local frame = ui.GetFrame("status")
    frame:Resize(500, 1080)
end

function always_status_original_frame_reduction()
    local frame = ui.GetFrame("status")

    frame:ShowWindow(1)
    frame:Resize(0, 0)

end

function always_status_frame_move(frame)

    if g.settings.frame_X ~= frame:GetX() or g.settings.frame_Y ~= frame:GetY() then
        g.settings.frame_X = frame:GetX()
        g.settings.frame_Y = frame:GetY()
        always_status_save_settings()
    end
end

--[[function always_status_save_settings_reserve(frame, ctrl, argStr, argNum)

    local dropList = GET_CHILD_RECURSIVELY(frame, "setting_DropList")
    print(tostring(dropList:GetName()))
    local Data = tonumber(dropList:GetSelItemKey())
    print(Data)
    local loginCID = info.GetCID(session.GetMyHandle())
    Data = "no_" .. Data
    g.settings[loginCID] = Data

    for _, status in ipairs(status_list) do
        local check = GET_CHILD_RECURSIVELY(frame, "check" .. status)
        print(check:IsChecked())
        for key, value in pairs(g.settings[Data]) do
            print(key .. value)
            g.settings[Data][status] = check:IsChecked()
        end
    end
    -- g.settings.no = argNum
    local yes = "always_status_save_settings()"
    ui.MsgBox("このキャラに登録しますか？", yes, "None")
end
function always_status_newframe_init()

    local newframe = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "new_frame", 0, 0, 70, 30)
    AUTO_CAST(newframe)
    newframe:Resize(70, 30)
    newframe:SetPos(600, 30)
    -- newframe:SetOffset(1375, 15)
    newframe:ShowWindow(1)
    newframe:SetSkinName("None")
    local btn = newframe:CreateOrGetControl("button", "btn1", 0, 0, 30, 30)
    AUTO_CAST(btn)
    btn:SetSkinName("None")
    btn:SetText("{img config_button_normal 30 30}")
    btn:SetEventScript(ui.LBUTTONDOWN, "always_status_update")

end

function always_status_info()
    print("always_status_info")
    local frame = ui.GetFrame("status")
    local box = GET_CHILD_RECURSIVELY(frame, "internalstatusBox")

    for _, status in ipairs(status_list) do

        if status ~= "STR" and status ~= "INT" and status ~= "CON" and status ~= "MNA" and status ~= "DEX" then

            local controlset = GET_CHILD_RECURSIVELY(box, status)
            local title = GET_CHILD_RECURSIVELY(controlset, "title")
            local stat = GET_CHILD_RECURSIVELY(controlset, "stat")
            -- print(tostring(title:GetText()) .. ":" .. tostring(stat:GetText()))

        end

    end

end]]
