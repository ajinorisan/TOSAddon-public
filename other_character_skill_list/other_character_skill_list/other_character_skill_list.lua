local addonName = "OTHER_CHARACTER_SKILL_LIST"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

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
        addon:RegisterMsg("GAME_START", "other_character_skill_list_2sec")
        acutil.setupEvent(addon, "INVENTORY_OPEN", "other_character_skill_list_INVENTORY_OPEN")
        acutil.setupEvent(addon, "INVENTORY_CLOSE", "other_character_skill_list_INVENTORY_CLOSE")

    end
    g.SetupHook(other_character_skill_list_BARRACK_TO_GAME, "BARRACK_TO_GAME")
end

function other_character_skill_list_INVENTORY_OPEN()
    other_character_skill_list_save_enchant()
end

function other_character_skill_list_INVENTORY_CLOSE()
    other_character_skill_list_save_enchant()
end

function other_character_skill_list_2sec()

    ReserveScript("other_character_skill_list_frame_init()", 2.0)
    ReserveScript("other_character_skill_list_lord_settings()", 2.0)

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
    local accountInfo = session.barrack.GetMyAccount();
    local cnt = accountInfo:GetPCCount();

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

    frame:SetSkinName("None")
    frame:Resize(990, 300)
    frame:SetLayerLevel(80)

    ctrl:ShowWindow(0)

    local title = frame:CreateOrGetControl("groupbox", "title", 40, 5, 940, 35)
    AUTO_CAST(title)
    title:SetSkinName("test_frame_midle")
    local close = title:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.LEFT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "other_character_skill_list_frame_close")

    local y = 135
    for i = 0, 3 do
        local equip_text = title:CreateOrGetControl("richtext", "equip_text" .. i, y, 5, 100, 20)
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
        end
        y = y + 195
    end

    local gbox = frame:CreateOrGetControl("groupbox", "gbox", 40, 35, 940, 280)
    AUTO_CAST(gbox)
    gbox:RemoveAllChild()
    gbox:SetSkinName("test_frame_midle")

    local characters = {}

    -- g.settings のキーと値をキーと値のペアとして characters テーブルに追加
    for name, data in pairs(g.settings) do
        table.insert(characters, {
            name = name,
            layer = data.layer,
            index = data.index
        })
    end

    -- ソート関数
    local function sortCharacters(a, b)
        if a.layer == b.layer then
            return a.index < b.index
        else
            return a.layer < b.layer
        end
    end

    -- ソートを実行
    table.sort(characters, sortCharacters)

    -- 結果を出力
    local x = 10

    local langtbl = {}
    local language = option.GetCurrentCountry()
    if language == "Japanese" then
        langtbl = jatbl
    else
        langtbl = entbl
    end

    for _, character in ipairs(characters) do
        local name_text = gbox:CreateOrGetControl("richtext", "timer_text" .. character.name, 10, x, 120, 20)
        name_text:SetText("{ol}" .. character.name)
        name_text:AdjustFontSizeByWidth(130)

        local skill_list = GetClassList("Skill");

        for k, v in pairs(g.settings) do

            if tostring(k) == tostring(character.name) then
                local shirt_slot = gbox:CreateOrGetControl("slot", "shirt_slot" .. character.name, 135, x, 20, 20)
                AUTO_CAST(shirt_slot)
                shirt_slot:EnablePop(0)
                shirt_slot:EnableDrop(0)
                shirt_slot:EnableDrag(0)
                shirt_slot:SetSkinName('invenslot2');

                local character_settings = g.settings[character.name]
                if character_settings and character_settings.SHIRT then
                    local shirt_skill = GetClassByNameFromList(skill_list, g.settings[character.name].SHIRT.skillName)
                    local shirt_sklCls = GetClassByType("Skill", shirt_skill.ClassID);

                    local shirt_imageName = 'icon_' .. shirt_sklCls.Icon;
                    SET_SLOT_ICON(shirt_slot, shirt_imageName)
                    local shirt_name = gbox:CreateOrGetControl("richtext", "shirt_name" .. character.name, 195, x, 140,
                        20)

                    local shirt_lv = gbox:CreateOrGetControl("richtext", "shirt_lv" .. character.name, 160, x, 30, 20)
                    shirt_lv:SetText("{ol}{s14}Lv:" .. g.settings[character.name].SHIRT.skillLv)

                    for k2, v2 in pairs(langtbl) do

                        if tostring(k2) == tostring(g.settings[character.name].SHIRT.skillName) then
                            shirt_name:SetText("{ol}{s14}" .. v2)
                            shirt_name:AdjustFontSizeByWidth(140)
                        end

                    end
                end

            end

        end

        for k, v in pairs(g.settings) do

            if tostring(k) == tostring(character.name) then
                local pants_slot = gbox:CreateOrGetControl("slot", "pants_slot" .. character.name, 135 + 195, x, 20, 20)
                AUTO_CAST(pants_slot)
                pants_slot:EnablePop(0)
                pants_slot:EnableDrop(0)
                pants_slot:EnableDrag(0)
                pants_slot:SetSkinName('invenslot2');

                local character_settings = g.settings[character.name]
                if character_settings and character_settings.PANTS then
                    local pants_skill = GetClassByNameFromList(skill_list, g.settings[character.name].PANTS.skillName)
                    local pants_sklCls = GetClassByType("Skill", pants_skill.ClassID);

                    local pants_imageName = 'icon_' .. pants_sklCls.Icon;
                    SET_SLOT_ICON(pants_slot, pants_imageName)
                    local pants_name = gbox:CreateOrGetControl("richtext", "pants_name" .. character.name, 195 + 195, x,
                        140, 20)

                    local pants_lv = gbox:CreateOrGetControl("richtext", "pants_lv" .. character.name, 160 + 195, x, 30,
                        20)
                    pants_lv:SetText("{ol}{s14}Lv:" .. g.settings[character.name].PANTS.skillLv)
                    for k2, v2 in pairs(langtbl) do

                        if tostring(k2) == tostring(g.settings[character.name].PANTS.skillName) then
                            pants_name:SetText("{ol}{s14}" .. v2)
                            pants_name:AdjustFontSizeByWidth(140)
                        end

                    end
                end

            end

        end

        for k, v in pairs(g.settings) do

            if tostring(k) == tostring(character.name) then
                local gloves_slot = gbox:CreateOrGetControl("slot", "gloves_slot" .. character.name, 135 + 195 + 195, x,
                    20, 20)
                AUTO_CAST(gloves_slot)
                gloves_slot:EnablePop(0)
                gloves_slot:EnableDrop(0)
                gloves_slot:EnableDrag(0)
                gloves_slot:SetSkinName('invenslot2');

                local character_settings = g.settings[character.name]
                if character_settings and character_settings.GLOVES then
                    local gloves_skill = GetClassByNameFromList(skill_list, g.settings[character.name].GLOVES.skillName)
                    local gloves_sklCls = GetClassByType("Skill", gloves_skill.ClassID);

                    local gloves_imageName = 'icon_' .. gloves_sklCls.Icon;
                    SET_SLOT_ICON(gloves_slot, gloves_imageName)
                    local gloves_name = gbox:CreateOrGetControl("richtext", "gloves_name" .. character.name,
                        195 + 195 + 195, x, 140, 20)

                    local gloves_lv = gbox:CreateOrGetControl("richtext", "gloves_lv" .. character.name,
                        160 + 195 + 195, x, 30, 20)
                    gloves_lv:SetText("{ol}{s14}Lv:" .. g.settings[character.name].GLOVES.skillLv)
                    for k2, v2 in pairs(langtbl) do

                        if tostring(k2) == tostring(g.settings[character.name].GLOVES.skillName) then
                            gloves_name:SetText("{ol}{s14}" .. v2)
                            gloves_name:AdjustFontSizeByWidth(140)
                        end

                    end
                end

            end

        end
        for k, v in pairs(g.settings) do

            if tostring(k) == tostring(character.name) then
                local boots_slot = gbox:CreateOrGetControl("slot", "boots_slot" .. character.name,
                    135 + 195 + 195 + 195, x, 20, 20)
                AUTO_CAST(boots_slot)
                boots_slot:EnablePop(0)
                boots_slot:EnableDrop(0)
                boots_slot:EnableDrag(0)
                boots_slot:SetSkinName('invenslot2');

                local character_settings = g.settings[character.name]
                if character_settings and character_settings.BOOTS then
                    local boots_skill = GetClassByNameFromList(skill_list, g.settings[character.name].BOOTS.skillName)
                    local boots_sklCls = GetClassByType("Skill", boots_skill.ClassID);

                    local boots_imageName = 'icon_' .. boots_sklCls.Icon;
                    SET_SLOT_ICON(boots_slot, boots_imageName)
                    local boots_name = gbox:CreateOrGetControl("richtext", "boots_name" .. character.name,
                        195 + 195 + 195 + 195, x, 140, 20)

                    local boots_lv = gbox:CreateOrGetControl("richtext", "boots_lv" .. character.name,
                        160 + 195 + 195 + 195, x, 30, 20)
                    boots_lv:SetText("{ol}{s14}Lv:" .. g.settings[character.name].BOOTS.skillLv)
                    for k2, v2 in pairs(langtbl) do

                        if tostring(k2) == tostring(g.settings[character.name].BOOTS.skillName) then
                            boots_name:SetText("{ol}{s14}" .. v2)
                            boots_name:AdjustFontSizeByWidth(140)
                        end

                    end
                end

            end

        end

        x = x + 25

    end
    frame:Resize(990, x + 50)
    gbox:Resize(940, x + 10)
end

function other_character_skill_list_frame_close(frame, ctrl, argStr, argNum)
    local frame = ui.GetFrame(addonNameLower)

    local btn = GET_CHILD_RECURSIVELY(frame, "btn")
    btn:ShowWindow(1)
    frame:Resize(35, 35)
    btn:ShowWindow(1)
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

end

function other_character_skill_list_save_enchant()

    local pcName = session.GetMySession():GetPCApc():GetName()

    local equipItemList = session.GetEquipItemList();
    local count = equipItemList:Count();
    for i = 0, count - 1 do
        local equipItem = equipItemList:GetEquipItemByIndex(i);
        local spotName = item.GetEquipSpotName(equipItem.equipSpot);
        local iesid = tostring(equipItem:GetIESID())

        if spotName == "SHIRT" or spotName == "PANTS" or spotName == "GLOVES" or spotName == "BOOTS" then
            local Item = session.GetEquipItemBySpot(item.GetEquipSpotNum(spotName));
            local obj = GetIES(Item:GetObject());
            local slotcnt = TryGetProp(obj, 'EnchantSkillSlotCount', 0)
            local Name, Level = shared_skill_enchant.get_enchanted_skill(obj, 1)

            for k, v in pairs(g.settings) do

                if tostring(k) == tostring(pcName) then
                    if g.settings[k][spotName] == nil then
                        g.settings[k][spotName] = {}
                    end

                    g.settings[k][spotName].iesid = iesid
                    g.settings[k][spotName].skillName = Name
                    g.settings[k][spotName].skillLv = Level
                    g.settings[k][spotName].slotcnt = slotcnt
                end

            end

            -- break
        end
    end
    other_character_skill_list_save_settings()
end

