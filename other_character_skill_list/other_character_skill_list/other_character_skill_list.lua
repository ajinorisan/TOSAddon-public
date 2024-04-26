-- v1.0.1 skillnameがNoneの場合に表示バグってたの修正
-- v1.0.2 UI少し変更。CC時のカードやエンブレムの装備取り忘れ確認機能。
-- v1.0.3 読み込み早くしたつもり。自分では何も感じない。回線のせいか？
local addonName = "OTHER_CHARACTER_SKILL_LIST"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.3"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.logpath = string.format('../addons/%s/log.txt', addonNameLower)

local acutil = require("acutil")
local json = require('json')
local os = require("os")
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

local jatbl = {
    ["Common_Peltasta_HardShield"] = "ハードシールド",
    ["Common_Swordman_PainBarrier"] = "ペインバリア",
    ["Common_Peltasta_Guardian"] = "ガーディアン",
    ["Common_Cataphract_Trot"] = "トロット",
    ["Common_Murmillo_Sprint"] = "スプリント",
    ["Common_BlossomBlader_StartUp"] = "起手式",
    ["Common_Rancer_Commence"] = "コメンス",
    ["Common_Rancer_Prevent"] = "プリベント",
    ["Common_Highlander_Defiance"] = "ディファイアンス",
    ["Common_Barbarian_Frenzy"] = "フレンジー",
    ["Common_Retiarii_DaggerGuard"] = "ダガーガード",
    ["Common_Archer_Jump"] = "後方跳躍",
    ["Common_PiedPiper_Marschierendeslied"] = "マシュレデスリート",
    ["Common_PiedPiper_LiedDerWeltbaum"] = "リートデスベルトバウム",
    ["Common_Arquebusier_DesperateDefense"] = "デスパレートデフェンス",
    ["Common_Appraiser_HighMagnifyingGlass"] = "高倍率拡大鏡",
    ["Common_QuarrelShooter_DeployPavise"] = "デプロイパヴィス",
    ["Common_Wizard_Teleportation"] = "テレポーテーション",
    ["Common_Cryomancer_SubzeroShield"] = "ザブゼロシールド",
    ["Common_Chronomancer_Pass"] = "パス",
    ["Common_Chronomancer_QuickCast"] = "クイックキャスト",
    ["Common_Shadowmancer_ShadowPool"] = "シャドウプール",
    ["Common_Sage_MissileHole"] = "ミサイルホール",
    ["Common_Oracle_Foretell"] = "フォアテル",
    ["Common_PlagueDoctor_Modafinil"] = "モダフィニル",
    ["Common_Appraiser_Devaluation"] = "デバリュエーション",
    ["Common_RuneCaster_Algiz"] = "保護のルーン",
    ["Common_Priest_Aspersion"] = "アスパーション",
    ["Common_Druid_Lycanthropy"] = "ライカンスロピー",
    ["Common_Pardoner_IncreaseMagicDEF"] = "インクリースMDEF",
    ["Common_Paladin_StoneSkin"] = "ストーンスキン",
    ["Common_Inquisitor_Judgment"] = "ジャッジメント",
    ["Common_Kabbalist_Ayin_sof"] = "アインソフ",
    ["Common_Zealot_Invulnerable"] = "インバナーブル",
    ["Common_Zealot_BeadyEyed"] = "ビーディアイズ",
    ["Common_Assassin_Hasisas"] = "ハシサス",
    ["Common_OutLaw_Bully"] = "ブリー",
    ["Common_Thaumaturge_SwellBody"] = "スウェルボディ",
    ["Common_Thaumaturge_SwellHands"] = "スウェルハンズ",
    ["Common_Enchanter_EnchantGlove"] = "エンチャントグローブ",
    ["Common_Enchanter_EnchantEarth"] = "エンチャントアース",
    ["Common_Enchanter_EnchantLightning"] = "エンチャントウェポン",
    ["Common_Linker_Physicallink"] = "フィジカルリンク",
    ["Common_Linker_UmbilicalCord"] = "アンビリカルコード",
    ["Common_Rogue_Evasion"] = "イヴェイジョン",
    ["Common_Schwarzereiter_EvasiveAction"] = "エヴァシブアクション",
    ["Common_Sheriff_Redemption"] = "リデンプション",
    ["Common_Recovery"] = "リカバリー"

}
local entbl = {
    ["Common_Peltasta_HardShield"] = "HardShield",
    ["Common_Swordman_PainBarrier"] = "PainBarrier",
    ["Common_Peltasta_Guardian"] = "Guardian",
    ["Common_Cataphract_Trot"] = "Trot",
    ["Common_Murmillo_Sprint"] = "Sprint",
    ["Common_BlossomBlader_StartUp"] = "StartUp",
    ["Common_Rancer_Commence"] = "Commence",
    ["Common_Rancer_Prevent"] = "Prevent",
    ["Common_Highlander_Defiance"] = "Defiance",
    ["Common_Barbarian_Frenzy"] = "Frenzy",
    ["Common_Retiarii_DaggerGuard"] = "DaggerGuard",
    ["Common_Archer_Jump"] = "Jump",
    ["Common_PiedPiper_Marschierendeslied"] = "Marschierendeslied",
    ["Common_PiedPiper_LiedDerWeltbaum"] = "LiedDerWeltbaum",
    ["Common_Arquebusier_DesperateDefense"] = "DesperateDefense",
    ["Common_Appraiser_HighMagnifyingGlass"] = "HighMagnifyingGlass",
    ["Common_QuarrelShooter_DeployPavise"] = "DeployPavise",
    ["Common_Wizard_Teleportation"] = "Teleportation",
    ["Common_Cryomancer_SubzeroShield"] = "SubzeroShield",
    ["Common_Chronomancer_Pass"] = "Pass",
    ["Common_Chronomancer_QuickCast"] = "QuickCast",
    ["Common_Shadowmancer_ShadowPool"] = "ShadowPool",
    ["Common_Sage_MissileHole"] = "MissileHole",
    ["Common_Oracle_Foretell"] = "Foretell",
    ["Common_PlagueDoctor_Modafinil"] = "Modafinil",
    ["Common_Appraiser_Devaluation"] = "Devaluation",
    ["Common_RuneCaster_Algiz"] = "Algiz",
    ["Common_Priest_Aspersion"] = "Aspersion",
    ["Common_Druid_Lycanthropy"] = "Lycanthropy",
    ["Common_Pardoner_IncreaseMagicDEF"] = "IncreaseMagicDEF",
    ["Common_Paladin_StoneSkin"] = "StoneSkin",
    ["Common_Inquisitor_Judgment"] = "Judgment",
    ["Common_Kabbalist_Ayin_sof"] = "Ayin_sof",
    ["Common_Zealot_Invulnerable"] = "Invulnerable",
    ["Common_Zealot_BeadyEyed"] = "BeadyEyed",
    ["Common_Assassin_Hasisas"] = "Hasisas",
    ["Common_OutLaw_Bully"] = "Bully",
    ["Common_Thaumaturge_SwellBody"] = "SwellBody",
    ["Common_Thaumaturge_SwellHands"] = "SwellHands",
    ["Common_Enchanter_EnchantGlove"] = "EnchantGlove",
    ["Common_Enchanter_EnchantEarth"] = "EnchantEarth",
    ["Common_Enchanter_EnchantLightning"] = "EnchantLightning",
    ["Common_Linker_Physicallink"] = "Physicallink",
    ["Common_Linker_UmbilicalCord"] = "UmbilicalCord",
    ["Common_Rogue_Evasion"] = "Evasion",
    ["Common_Schwarzereiter_EvasiveAction"] = "EvasiveAction",
    ["Common_Sheriff_Redemption"] = "Redemption",
    ["Common_Recovery"] = "Recovery"

}

function other_character_skill_list_BARRACK_TO_GAME()
    local frame = ui.GetFrame("barrack_charlist")
    local layer = tonumber(frame:GetUserValue("SelectBarrackLayer"))
    g.layer = layer

    local gsframe = ui.GetFrame("barrack_gamestart")
    local checkbtn = gsframe:GetChildRecursively("hidelogin")
    AUTO_CAST(checkbtn)
    checkbtn:SetCheck(1)
    barrack.SetHideLogin(1);

    -- BARRACK_TO_GAME_OLD()
    base["BARRACK_TO_GAME"]()
end

function OTHER_CHARACTER_SKILL_LIST_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.settings = g.settings or {}
    g.CID = info.GetCID(session.GetMyHandle())

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        other_character_skill_list_lord_settings()
        addon:RegisterMsg("GAME_START", "other_character_skill_list_frame_init")
        addon:RegisterMsg("GAME_START_3SEC", "other_character_skill_list_3sec")
        acutil.setupEvent(addon, "INVENTORY_OPEN", "other_character_skill_list_INVENTORY_OPEN")
        acutil.setupEvent(addon, "INVENTORY_CLOSE", "other_character_skill_list_INVENTORY_CLOSE")

    end
    g.SetupHook(other_character_skill_list_BARRACK_TO_GAME, "BARRACK_TO_GAME")

end

function other_character_skill_list_INVENTORY_OPEN()
    local frame = ui.GetFrame(addonNameLower)
    frame:ShowWindow(0)
    local newframe = ui.GetFrame(addonNameLower .. "new_frame")
    newframe:ShowWindow(0)
    other_character_skill_list_save_enchant()
end

function other_character_skill_list_INVENTORY_CLOSE()
    local frame = ui.GetFrame(addonNameLower)
    frame:ShowWindow(1)
    other_character_skill_list_save_enchant()
end

function other_character_skill_list_instantcc()

    local ic = _G["ADDONS"]["ebisuke"]["INSTANTCC"]
    ic.settingsFileLoc = string.format('../addons/%s/settings.json', "instantcc")
    ic.settings = acutil.loadJSON(ic.settingsFileLoc, ic.settings)

    for gChar, _ in pairs(g.settings) do

        local found = false

        for _, icChar in ipairs(ic.settings.charactors) do
            if icChar.name == gChar then
                -- 同じ名前が見つかった場合、上書き
                g.settings[gChar].layer = icChar.layer
                g.settings[gChar].index = icChar.order
                found = true
                break
            end
        end

        if not found then
            -- 見つからない場合、デフォルトの値を代入
            gChar.layer = 9
            gChar.order = 99
        end
    end

    other_character_skill_list_save_settings()

    local function sortCharactors(a, b)
        if a.layer == b.layer then
            return a.index < b.index
        else
            return a.layer < b.layer
        end
    end

    -- ソートを実行
    table.sort(g.settings, sortCharactors)
    g.characters = {}

    local accountInfo = session.barrack.GetMyAccount();
    local bpcnt = accountInfo:GetBarrackPCCount()

    for i = 0, bpcnt - 1 do
        local pcInfo = accountInfo:GetBarrackPCByIndex(i)
        local pcName = pcInfo:GetName()
        for k, v in pairs(g.settings) do

            if pcName == k then

                table.insert(g.characters, {
                    name = k,
                    layer = g.settings[k].layer,
                    index = g.settings[k].index
                })
            end
        end
    end
    -- ソートを実行
    table.sort(g.characters, sortCharactors)
    --[[for _, character in ipairs(g.characters) do
        print("Name: " .. character.name)
        print("Layer: " .. character.layer)
        print("Index: " .. character.index)
    end]]
    -- indun_list_viewer_load_settings()

end

function other_character_skill_list_3sec()

    local functionName = "INSTANTCC_ON_INIT" -- チェックしたい関数の名前を文字列として指定します
    if type(_G[functionName]) == "function" then
        other_character_skill_list_instantcc()
        return
    else
        other_character_skill_list_sort()
        return
    end

end
function other_character_skill_list_sort()

    local accountInfo = session.barrack.GetMyAccount();
    local cnt = accountInfo:GetPCCount();
    -- print(cnt)
    if g.layer ~= nil then
        for i = 0, cnt - 1 do
            local pcInfo = accountInfo:GetPCByIndex(i);
            local pcApc = pcInfo:GetApc();
            local pcName = pcApc:GetName()
            for k, v in pairs(g.settings) do

                if tostring(k) == tostring(pcName) then
                    g.settings[k].layer = g.layer
                    g.settings[k].index = i

                end

            end
        end

    end
    other_character_skill_list_save_settings()

    local function sortCharacters(a, b)
        if a.layer == b.layer then
            return a.index < b.index
        else
            return a.layer < b.layer
        end
    end
    g.characters = {}
    local bpcnt = accountInfo:GetBarrackPCCount()

    for i = 0, bpcnt - 1 do
        local pcInfo = accountInfo:GetBarrackPCByIndex(i)
        local pcName = pcInfo:GetName()
        for k, v in pairs(g.settings) do

            if pcName == k then
                table.insert(g.characters, {
                    name = k,
                    layer = g.settings[k].layer,
                    index = g.settings[k].index
                })
            end
        end
    end

    -- ソートを実行
    table.sort(g.characters, sortCharacters)

end
function other_character_skill_list_lord_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not settings then
        settings = g.settings
    end

    local accountInfo = session.barrack.GetMyAccount();
    local cnt = accountInfo:GetBarrackPCCount()

    for i = 0, cnt - 1 do
        local pcInfo = accountInfo:GetBarrackPCByIndex(i)
        local pcName = pcInfo:GetName()

        if settings[pcName] == nil then
            settings[pcName] = {
                layer = 9,
                index = 99
            }
        end
    end

    g.settings = settings
    other_character_skill_list_save_settings()
end

function other_character_skill_list_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function other_character_skill_list_frame_open(frame, ctrl, argStr, argNum)
    -- other_character_skill_list_instantcc()

    local frame = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "new_frame", 0, 0, 70, 30)
    AUTO_CAST(frame)

    frame:SetSkinName("test_frame_midle")
    frame:Resize(990, 300)
    frame:SetLayerLevel(103)

    -- ctrl:ShowWindow(0)

    local title = frame:CreateOrGetControl("groupbox", "title", 0, 0, 1070, 40)
    AUTO_CAST(title)
    title:SetSkinName("None")
    -- title:SetSkinName("chat_window")
    local close = title:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.LEFT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "other_character_skill_list_frame_close")

    local language = option.GetCurrentCountry()

    local y = 155
    for i = 0, 4 do
        local equip_text = title:CreateOrGetControl("richtext", "equip_text" .. i, y, 10, 100, 20)
        if i == 0 then
            equip_text:SetText("{ol}" .. ClMsg("Shirt"))
            equip_text:AdjustFontSizeByWidth(100)
        elseif i == 1 then
            equip_text:SetText("{ol}" .. ClMsg("Pants"))
            equip_text:AdjustFontSizeByWidth(100)
        elseif i == 2 then
            equip_text:SetText("{ol}" .. ClMsg("GLOVES"))
            equip_text:AdjustFontSizeByWidth(100)
        elseif i == 3 then
            equip_text:SetText("{ol}" .. ClMsg("BOOTS"))
            equip_text:AdjustFontSizeByWidth(100)

        elseif i == 4 then
            if language == "Japanese" then
                equip_text:SetText("{ol}その他")
                equip_text:AdjustFontSizeByWidth(100)
            else
                equip_text:SetText("{ol}etc.")
                equip_text:AdjustFontSizeByWidth(100)
            end
        end
        y = y + 225
    end

    local gbox = frame:CreateOrGetControl("groupbox", "gbox", 5, 35, 1070, 280)
    AUTO_CAST(gbox)
    gbox:RemoveAllChild()
    gbox:SetSkinName("test_frame_midle_light")
    -- gbox:SetSkinName("chat_window")

    -- 結果を出力
    local x = 10

    local langtbl = {}

    if language == "Japanese" then
        langtbl = jatbl
    else
        langtbl = entbl
    end
    local yy = 155

    for _, character in ipairs(g.characters) do

        local name_text = gbox:CreateOrGetControl("richtext", "timer_text" .. character.name, 10, x, 145, 20)
        name_text:SetText("{ol}" .. character.name)
        name_text:AdjustFontSizeByWidth(150)

        local skill_list = GetClassList("Skill");

        for k, v in pairs(g.settings) do

            if tostring(k) == tostring(character.name) then
                local shirt_slot = gbox:CreateOrGetControl("slot", "shirt_slot" .. character.name, yy + 30, x, 25, 24)
                AUTO_CAST(shirt_slot)
                shirt_slot:EnablePop(0)
                shirt_slot:EnableDrop(0)
                shirt_slot:EnableDrag(0)
                shirt_slot:SetSkinName('invenslot2');

                local shirt_equip = gbox:CreateOrGetControl("slot", "shirt_equip" .. character.name, yy, x, 25, 24)
                AUTO_CAST(shirt_equip)

                shirt_equip:EnablePop(0)
                shirt_equip:EnableDrop(0)
                shirt_equip:EnableDrag(0)
                shirt_equip:SetSkinName('invenslot2');

                local character_settings = g.settings[character.name]

                if character_settings and character_settings.SHIRT then

                    local clsID = g.settings[character.name].SHIRT.clsid
                    local lv = g.settings[character.name].SHIRT.lv

                    if clsID ~= nil then
                        local itemCls = GetClassByType("Item", clsID);
                        local imageName = itemCls.Icon;
                        SET_SLOT_ICON(shirt_equip, imageName)

                        SET_SLOT_BG_BY_ITEMGRADE(shirt_equip, itemCls)
                        shirt_equip:SetText('{s12}{ol}{#FFFF00}+' .. lv, 'count', ui.RIGHT, ui.BOTTOM, 0, 0);
                        local icon = shirt_equip:GetIcon()
                        icon:SetTextTooltip(itemCls.Name);
                    end

                    local shirt_skill = GetClassByNameFromList(skill_list, g.settings[character.name].SHIRT.skillName)
                    if shirt_skill ~= nil then

                        local shirt_sklCls = GetClassByType("Skill", shirt_skill.ClassID);
                        -- print(tostring("cls" .. shirt_sklCls))
                        local shirt_imageName = 'icon_' .. shirt_sklCls.Icon;
                        SET_SLOT_ICON(shirt_slot, shirt_imageName)
                        local shirt_name = gbox:CreateOrGetControl("richtext", "shirt_name" .. character.name, yy + 60,
                            x, 140, 20)

                        -- local shirt_lv = gbox:CreateOrGetControl("richtext", "shirt_lv" .. character.name, yy + 60, x,30, 20)
                        shirt_slot:SetText('{s14}{ol}{#FFFF00}' .. g.settings[character.name].SHIRT.skillLv, 'count',
                            ui.RIGHT, ui.BOTTOM, -2, -2)

                        local icon = shirt_slot:GetIcon()
                        icon:SetTooltipType('skill');
                        -- print(tostring(g.settings[character.name].SHIRT.skillLv))
                        icon:SetTooltipArg("Level", shirt_skill.ClassID, g.settings[character.name].SHIRT.skillLv);

                        for k2, v2 in pairs(langtbl) do

                            if tostring(k2) == tostring(g.settings[character.name].SHIRT.skillName) then
                                shirt_name:SetText("{ol}{s16}" .. v2)
                                shirt_name:AdjustFontSizeByWidth(160)
                            end

                        end
                    end
                end

            end

        end

        for k, v in pairs(g.settings) do

            if tostring(k) == tostring(character.name) then
                local pants_slot = gbox:CreateOrGetControl("slot", "pants_slot" .. character.name, yy + 225 + 30, x, 25,
                    24)
                AUTO_CAST(pants_slot)
                pants_slot:EnablePop(0)
                pants_slot:EnableDrop(0)
                pants_slot:EnableDrag(0)
                pants_slot:SetSkinName('invenslot2');

                local pants_equip =
                    gbox:CreateOrGetControl("slot", "pants_equip" .. character.name, yy + 225, x, 25, 24)
                AUTO_CAST(pants_equip)

                pants_equip:EnablePop(0)
                pants_equip:EnableDrop(0)
                pants_equip:EnableDrag(0)
                pants_equip:SetSkinName('invenslot2');

                local character_settings = g.settings[character.name]
                if character_settings and character_settings.PANTS then

                    local clsID = g.settings[character.name].PANTS.clsid
                    local lv = g.settings[character.name].PANTS.lv

                    if clsID ~= nil then
                        local itemCls = GetClassByType("Item", clsID);
                        local imageName = itemCls.Icon;
                        SET_SLOT_ICON(pants_equip, imageName)

                        SET_SLOT_BG_BY_ITEMGRADE(pants_equip, itemCls)
                        pants_equip:SetText('{s12}{ol}{#FFFF00}+' .. lv, 'count', ui.RIGHT, ui.BOTTOM, 0, 0);
                        local icon = pants_equip:GetIcon()
                        icon:SetTextTooltip(itemCls.Name);
                    end

                    local pants_skill = GetClassByNameFromList(skill_list, g.settings[character.name].PANTS.skillName)
                    if pants_skill ~= nil then
                        local pants_sklCls = GetClassByType("Skill", pants_skill.ClassID);

                        local pants_imageName = 'icon_' .. pants_sklCls.Icon;
                        SET_SLOT_ICON(pants_slot, pants_imageName)
                        local pants_name = gbox:CreateOrGetControl("richtext", "pants_name" .. character.name,
                            yy + 225 + 60, x, 140, 20)

                        pants_slot:SetText('{s14}{ol}{#FFFF00}' .. g.settings[character.name].PANTS.skillLv, 'count',
                            ui.RIGHT, ui.BOTTOM, -2, -2)

                        local icon = pants_slot:GetIcon()
                        icon:SetTooltipType('skill');
                        icon:SetTooltipArg("Level", pants_skill.ClassID, g.settings[character.name].PANTS.skillLv);

                        for k2, v2 in pairs(langtbl) do

                            if tostring(k2) == tostring(g.settings[character.name].PANTS.skillName) then
                                pants_name:SetText("{ol}{s16}" .. v2)
                                pants_name:AdjustFontSizeByWidth(160)
                            end

                        end
                    end
                end

            end

        end

        for k, v in pairs(g.settings) do

            if tostring(k) == tostring(character.name) then
                local gloves_slot = gbox:CreateOrGetControl("slot", "gloves_slot" .. character.name, yy + 225 * 2 + 30,
                    x, 25, 24)
                AUTO_CAST(gloves_slot)
                gloves_slot:EnablePop(0)
                gloves_slot:EnableDrop(0)
                gloves_slot:EnableDrag(0)
                gloves_slot:SetSkinName('invenslot2');

                local gloves_equip = gbox:CreateOrGetControl("slot", "gloves_equip" .. character.name, yy + 225 * 2, x,
                    25, 24)
                AUTO_CAST(gloves_equip)

                gloves_equip:EnablePop(0)
                gloves_equip:EnableDrop(0)
                gloves_equip:EnableDrag(0)
                gloves_equip:SetSkinName('invenslot2');

                local character_settings = g.settings[character.name]
                if character_settings and character_settings.GLOVES then

                    local clsID = g.settings[character.name].GLOVES.clsid
                    local lv = g.settings[character.name].GLOVES.lv

                    if clsID ~= nil then
                        local itemCls = GetClassByType("Item", clsID);
                        local imageName = itemCls.Icon;
                        SET_SLOT_ICON(gloves_equip, imageName)
                        SET_SLOT_BG_BY_ITEMGRADE(gloves_equip, itemCls)
                        gloves_equip:SetText('{s12}{ol}{#FFFF00}+' .. lv, 'count', ui.RIGHT, ui.BOTTOM, 0, 0);
                        local icon = gloves_equip:GetIcon()
                        icon:SetTextTooltip(itemCls.Name);
                    end

                    local gloves_skill = GetClassByNameFromList(skill_list, g.settings[character.name].GLOVES.skillName)
                    if gloves_skill ~= nil then
                        local gloves_sklCls = GetClassByType("Skill", gloves_skill.ClassID);

                        local gloves_imageName = 'icon_' .. gloves_sklCls.Icon;
                        SET_SLOT_ICON(gloves_slot, gloves_imageName)
                        local gloves_name = gbox:CreateOrGetControl("richtext", "gloves_name" .. character.name,
                            yy + 225 * 2 + 60, x, 140, 20)

                        gloves_slot:SetText('{s16}{ol}{#FFFF00}' .. g.settings[character.name].GLOVES.skillLv, 'count',
                            ui.RIGHT, ui.BOTTOM, -2, -2)

                        local icon = gloves_slot:GetIcon()
                        icon:SetTooltipType('skill');
                        icon:SetTooltipArg("Level", gloves_skill.ClassID, g.settings[character.name].GLOVES.skillLv);

                        for k2, v2 in pairs(langtbl) do

                            if tostring(k2) == tostring(g.settings[character.name].GLOVES.skillName) then
                                gloves_name:SetText("{ol}{s16}" .. v2)
                                gloves_name:AdjustFontSizeByWidth(160)
                            end

                        end
                    end
                end

            end

        end
        for k, v in pairs(g.settings) do

            if tostring(k) == tostring(character.name) then
                local boots_slot = gbox:CreateOrGetControl("slot", "boots_slot" .. character.name, yy + 225 * 3 + 30, x,
                    25, 24)
                AUTO_CAST(boots_slot)
                boots_slot:EnablePop(0)
                boots_slot:EnableDrop(0)
                boots_slot:EnableDrag(0)
                boots_slot:SetSkinName('invenslot2');

                local boots_equip = gbox:CreateOrGetControl("slot", "boots_equip" .. character.name, yy + 225 * 3, x,
                    25, 24)
                AUTO_CAST(boots_equip)

                boots_equip:EnablePop(0)
                boots_equip:EnableDrop(0)
                boots_equip:EnableDrag(0)
                boots_equip:SetSkinName('invenslot2');

                local character_settings = g.settings[character.name]
                if character_settings and character_settings.BOOTS then

                    local clsID = g.settings[character.name].BOOTS.clsid
                    local lv = g.settings[character.name].BOOTS.lv

                    if clsID ~= nil then
                        local itemCls = GetClassByType("Item", clsID);
                        local imageName = itemCls.Icon;
                        SET_SLOT_ICON(boots_equip, imageName)
                        SET_SLOT_BG_BY_ITEMGRADE(boots_equip, itemCls)
                        boots_equip:SetText('{s12}{ol}{#FFFF00}+' .. lv, 'count', ui.RIGHT, ui.BOTTOM, 0, 0);
                        local icon = boots_equip:GetIcon()
                        icon:SetTextTooltip(itemCls.Name);
                    end

                    local boots_skill = GetClassByNameFromList(skill_list, g.settings[character.name].BOOTS.skillName)
                    if boots_skill ~= nil then
                        local boots_sklCls = GetClassByType("Skill", boots_skill.ClassID);

                        local boots_imageName = 'icon_' .. boots_sklCls.Icon;
                        SET_SLOT_ICON(boots_slot, boots_imageName)
                        local boots_name = gbox:CreateOrGetControl("richtext", "boots_name" .. character.name,
                            yy + 225 * 3 + 60, x, 140, 20)

                        boots_slot:SetText('{s14}{ol}{#FFFF00}' .. g.settings[character.name].BOOTS.skillLv, 'count',
                            ui.RIGHT, ui.BOTTOM, -2, -2)

                        local icon = boots_slot:GetIcon()
                        icon:SetTooltipType('skill');
                        icon:SetTooltipArg("Level", boots_skill.ClassID, g.settings[character.name].BOOTS.skillLv);

                        for k2, v2 in pairs(langtbl) do

                            if tostring(k2) == tostring(g.settings[character.name].BOOTS.skillName) then

                                boots_name:SetText("{ol}{s16}" .. v2)
                                boots_name:AdjustFontSizeByWidth(160)
                            end

                        end
                    end
                end

            end

        end

        local itemCls = nil
        for k, v in pairs(g.settings) do

            if tostring(k) == tostring(character.name) then
                local leg_slot = gbox:CreateOrGetControl("slot", "leg_slot" .. character.name, yy + 225 * 4, x, 25, 24)
                AUTO_CAST(leg_slot)
                leg_slot:EnablePop(0)
                leg_slot:EnableDrop(0)
                leg_slot:EnableDrag(0)
                leg_slot:SetSkinName('invenslot2');

                itemCls = GetClassByType("Item", g.settings[k].legid);
                if itemCls ~= nil then
                    -- print(tostring(itemCls.ClassName))
                    local imageName = itemCls.Icon;
                    SET_SLOT_ICON(leg_slot, imageName)
                    local icon = leg_slot:GetIcon()
                    icon:SetTextTooltip(itemCls.Name);
                    leg_slot:SetText('{s12}{ol}{#FFFF00}{img mon_legendstar 10 10}{nl}' .. g.settings[k].leglv, 'count',
                        ui.RIGHT, ui.BOTTOM, 0, 0);
                end

                local god_slot = gbox:CreateOrGetControl("slot", "god_slot" .. character.name, yy + 225 * 4 + 30, x, 25,
                    24)
                AUTO_CAST(god_slot)
                god_slot:EnablePop(0)
                god_slot:EnableDrop(0)
                god_slot:EnableDrag(0)
                god_slot:SetSkinName('invenslot2');

                itemCls = GetClassByType("Item", g.settings[k].godid);
                if itemCls ~= nil then
                    local imageName = itemCls.Icon;
                    SET_SLOT_ICON(god_slot, imageName)
                    local icon = god_slot:GetIcon()
                    icon:SetTextTooltip(itemCls.Name);
                    god_slot:SetText('{s12}{ol}{#FFFF00}{img mon_legendstar 10 10}{nl}' .. g.settings[k].godlv, 'count',
                        ui.RIGHT, ui.BOTTOM, 0, 0);
                end

                local seal_slot = gbox:CreateOrGetControl("slot", "seal_slot" .. character.name, yy + 225 * 4 + 60, x,
                    25, 24)
                AUTO_CAST(seal_slot)
                seal_slot:EnablePop(0)
                seal_slot:EnableDrop(0)
                seal_slot:EnableDrag(0)
                seal_slot:SetSkinName('invenslot2');

                itemCls = GetClassByType("Item", g.settings[k].sealclsid);
                if itemCls ~= nil then
                    local imageName = itemCls.Icon;
                    SET_SLOT_ICON(seal_slot, imageName)
                    local icon = seal_slot:GetIcon()
                    icon:SetTextTooltip(itemCls.Name);
                    seal_slot:SetText('{s12}{ol}{#FFFF00}+' .. g.settings[k].seallv, 'count', ui.RIGHT, ui.BOTTOM, 0, 0);
                end

                local ark_slot = gbox:CreateOrGetControl("slot", "ark_slot" .. character.name, yy + 225 * 4 + 90, x, 25,
                    24)
                AUTO_CAST(ark_slot)
                ark_slot:EnablePop(0)
                ark_slot:EnableDrop(0)
                ark_slot:EnableDrag(0)
                ark_slot:SetSkinName('invenslot2');

                itemCls = GetClassByType("Item", g.settings[k].arkclsid);
                if itemCls ~= nil then
                    local imageName = itemCls.Icon;
                    SET_SLOT_ICON(ark_slot, imageName)
                    local icon = ark_slot:GetIcon()
                    icon:SetTextTooltip(itemCls.Name);
                    ark_slot:SetText('{s12}{ol}{#FFFF00}+' .. g.settings[k].arklv, 'count', ui.RIGHT, ui.BOTTOM, 0, 0);
                end

                local relic_slot = gbox:CreateOrGetControl("slot", "relic_slot" .. character.name, yy + 225 * 4 + 120,
                    x, 25, 24)
                AUTO_CAST(relic_slot)
                relic_slot:EnablePop(0)
                relic_slot:EnableDrop(0)
                relic_slot:EnableDrag(0)
                relic_slot:SetSkinName('invenslot2');

                itemCls = GetClassByType("Item", g.settings[k].relicclsid);
                if itemCls ~= nil then
                    local imageName = itemCls.Icon;
                    SET_SLOT_ICON(relic_slot, imageName)
                    local icon = relic_slot:GetIcon()
                    icon:SetTextTooltip(itemCls.Name);
                    relic_slot:SetText('{s12}{ol}{#FFFF00}+' .. g.settings[k].reliclv, 'count', ui.RIGHT, ui.BOTTOM, 0,
                        0);
                end

            end
        end

        x = x + 25

    end
    local cnt = #g.characters

    local framex = cnt * 25
    frame:Resize(1220, framex + 60)
    title:Resize(1210, 40)
    gbox:Resize(1210, framex + 20)

    local myw = frame:GetWidth()
    local mapFrame = ui.GetFrame("map");
    local w = mapFrame:GetWidth()
    frame:SetPos((w - myw) / 2, 0)
    frame:ShowWindow(1)
    -- frame:Resize(1120, x + 50)
    -- gbox:Resize(1070, x + 10)

end

function other_character_skill_list_frame_close(frame, ctrl, argStr, argNum)
    local frame = ui.GetFrame(addonNameLower .. "new_frame")
    frame:ShowWindow(0)
    -- local btn = GET_CHILD_RECURSIVELY(frame, "btn")
    -- btn:ShowWindow(1)
    -- frame:Resize(35, 35)
    -- frame:SetPos(715, 0)
    -- btn:ShowWindow(1)
end

function other_character_skill_list_frame_init()
    local frame = ui.GetFrame(addonNameLower)
    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")
    frame:Resize(35, 35)
    frame:SetPos(715, 0)

    frame:ShowWindow(1)

    local btn = frame:CreateOrGetControl('button', 'btn', 0, 0, 35, 35)
    AUTO_CAST(btn)
    btn:SetSkinName("None")
    btn:SetText("{img sysmenu_friend 35 35}")
    btn:SetEventScript(ui.LBUTTONDOWN, "other_character_skill_list_frame_open")
    btn:SetTextTooltip("Other Character Skill List")

end

function other_character_skill_list_save_enchant()

    local ivframe = ui.GetFrame("inventory")

    local pcName = session.GetMySession():GetPCApc():GetName()

    local equipItemList = session.GetEquipItemList();
    local count = equipItemList:Count();
    for i = 0, count - 1 do
        local equipItem = equipItemList:GetEquipItemByIndex(i);
        local spotName = item.GetEquipSpotName(equipItem.equipSpot);
        local iesid = tostring(equipItem:GetIESID())
        local Item = session.GetEquipItemBySpot(item.GetEquipSpotNum(spotName));
        local obj = GetIES(Item:GetObject());

        if spotName == "SHIRT" or spotName == "PANTS" or spotName == "GLOVES" or spotName == "BOOTS" then

            local slotcnt = TryGetProp(obj, 'EnchantSkillSlotCount', 0)
            local Name, Level = shared_skill_enchant.get_enchanted_skill(obj, 1)

            for k, v in pairs(g.settings) do

                if tostring(k) == tostring(pcName) then
                    if g.settings[k][spotName] == nil then
                        g.settings[k][spotName] = {}
                    end
                    local slot = GET_CHILD_RECURSIVELY(ivframe, spotName)
                    local icon = slot:GetIcon()
                    if icon ~= nil then
                        local lv = TryGetProp(obj, "Reinforce_2", 0);
                        g.settings[k][spotName].clsid = obj.ClassID
                        g.settings[k][spotName].lv = lv
                        g.settings[k][spotName].iesid = iesid
                        g.settings[k][spotName].skillName = Name
                        g.settings[k][spotName].skillLv = Level
                        g.settings[k][spotName].slotcnt = slotcnt
                    else
                        g.settings[k][spotName].clsid = nil
                        g.settings[k][spotName].lv = nil
                        g.settings[k][spotName].iesid = nil
                        g.settings[k][spotName].skillName = nil
                        g.settings[k][spotName].skillLv = nil
                        g.settings[k][spotName].slotcnt = nil
                    end
                end

            end
        elseif spotName == "SEAL" then
            for k, v in pairs(g.settings) do

                if tostring(k) == tostring(pcName) then
                    -- local ivframe = ui.GetFrame("inventory")
                    -- local sealslot = GET_CHILD_RECURSIVELY(ivframe, "SEAL")
                    -- local seallv = GET_CHILD_RECURSIVELY(sealslot, "lev")
                    local sealslot = GET_CHILD_RECURSIVELY(ivframe, "SEAL")
                    local icon = sealslot:GetIcon()
                    -- print(tostring(icon))
                    if icon ~= nil then
                        local lv = GET_CURRENT_SEAL_LEVEL(obj);

                        g.settings[k].seallv = lv
                        g.settings[k].sealiesid = iesid
                        g.settings[k].sealclsid = obj.ClassID
                    else
                        g.settings[k].seallv = nil
                        g.settings[k].sealiesid = nil
                        g.settings[k].sealclsid = nil
                    end
                end

            end
        elseif spotName == "ARK" then
            for k, v in pairs(g.settings) do

                if tostring(k) == tostring(pcName) then
                    local arkslot = GET_CHILD_RECURSIVELY(ivframe, "ARK")
                    local icon = arkslot:GetIcon()

                    if icon ~= nil then
                        local lv = TryGetProp(obj, 'ArkLevel', 1)

                        g.settings[k].arklv = lv
                        g.settings[k].arkiesid = iesid
                        g.settings[k].arkclsid = obj.ClassID
                    else
                        g.settings[k].arklv = nil
                        g.settings[k].arkiesid = nil
                        g.settings[k].arkclsid = nil
                    end

                end

            end
        elseif spotName == "RELIC" then
            for k, v in pairs(g.settings) do

                if tostring(k) == tostring(pcName) then
                    local relicslot = GET_CHILD_RECURSIVELY(ivframe, "RELIC")
                    local icon = relicslot:GetIcon()

                    if icon ~= nil then
                        local lv = TryGetProp(obj, 'Relic_LV', 1)
                        g.settings[k].reliclv = lv
                        g.settings[k].reliciesid = iesid
                        g.settings[k].relicclsid = obj.ClassID
                    else
                        g.settings[k].reliclv = nil
                        g.settings[k].reliciesid = nil
                        g.settings[k].relicclsid = nil
                    end

                end

            end
            -- break
        end
    end
    for k, v in pairs(g.settings) do

        if tostring(k) == tostring(pcName) then
            local leg_slot_index = 13
            local leg_cardid, leg_cardlv = GETMYCARD_INFO(leg_slot_index - 1)
            g.settings[k].legid = leg_cardid
            g.settings[k].leglv = leg_cardlv

            local god_slot_index = 14
            local god_cardid, god_cardlv = GETMYCARD_INFO(god_slot_index - 1)
            g.settings[k].godid = god_cardid
            g.settings[k].godlv = god_cardlv
        end
    end

    other_character_skill_list_save_settings()
end

