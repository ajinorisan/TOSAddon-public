-- v1.0.1 skillnameがNoneの場合に表示バグってたの修正
-- v1.0.2 UI少し変更。CC時のカードやエンブレムの装備取り忘れ確認機能。
-- v1.0.3 読み込み早くしたつもり。自分では何も感じない。回線のせいか？
-- v1.0.4 3回目以降のCCはキャラクターリストを読み込まない様に変更
-- v1.0.5 書き直した。高速化したはず。
-- v1.0.6 instantcc使ってたら順番バグるの修正。フレーム開ける時に読み込みに変更。
-- v1.0.7 順番バグってたの再修正
local addonName = "OTHER_CHARACTER_SKILL_LIST"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.7"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/new_settings.json', addonNameLower)

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
-- g.tempFileLoc = string.format('../addons/%s/temp.dat', addonNameLower)
-- g.SetupHook(other_character_skill_list_BARRACK_TO_GAME, "BARRACK_TO_GAME")
-- g.loaded = false
function OTHER_CHARACTER_SKILL_LIST_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then

        other_character_skill_list_load_settings()

        addon:RegisterMsg("GAME_START_3SEC", "other_character_skill_list_frame_init")

        acutil.setupEvent(addon, "INVENTORY_OPEN", "other_character_skill_list_INVENTORY_OPEN")
        acutil.setupEvent(addon, "INVENTORY_CLOSE", "other_character_skill_list_INVENTORY_CLOSE")

        g.SetupHook(other_character_skill_list_BARRACK_TO_GAME, "BARRACK_TO_GAME")

        local accountInfo = session.barrack.GetMyAccount()
        local cnt = accountInfo:GetPCCount()
        -- print(g.layer)
        for i = 0, cnt - 1 do

            local pcInfo = accountInfo:GetPCByIndex(i)
            local pcApc = pcInfo:GetApc()
            local pcName = pcApc:GetName()

            for name, charData in pairs(g.settings.character) do

                if charData.name == pcName then
                    g.settings.character[name].index = i

                    if g.layer ~= nil and g.layer ~= g.settings.character[name].layer then
                        g.settings.character[name].layer = g.layer

                    end
                end
            end
        end
        g.layer = nil
        other_character_skill_list_save_settings()

    end

end

function other_character_skill_list_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    -- settings が nil または settings.character が空の場合に初期化処理を実行
    if not settings or not settings.character or next(settings.character) == nil then
        local accountInfo = session.barrack.GetMyAccount()
        local barrackPCCount = accountInfo:GetBarrackPCCount()

        settings = {
            character = {}
        }

        for i = 1, barrackPCCount do -- Lua の配列は 1 から始めるのが一般的です
            local barrackPCInfo = accountInfo:GetBarrackPCByIndex(i - 1) -- 0 インデックスの補正
            local barrackPCName = barrackPCInfo:GetName()

            settings.character[barrackPCName] = {
                SHIRT = {},
                PANTS = {},
                GLOVES = {},
                BOOTS = {},
                SEAL = {},
                ARK = {},
                RELIC = {},
                LEG = {},
                GOD = {},
                index = i,
                layer = 9,
                name = barrackPCName
            }
        end
        g.settings = settings
    else
        g.settings = settings
    end

    other_character_skill_list_save_settings()
end

--[[function other_character_skill_list_load_settings()

    local tempFilePath = string.format('../addons/%s/temp.json', addonNameLower)

    local settingsFile = io.open(g.settingsFileLoc, "r")
    if not settingsFile then
        local accountInfo = session.barrack.GetMyAccount()
        local barrackPCCount = accountInfo:GetBarrackPCCount()

        -- 設定がない場合、新しい設定を作成する
        local settings = {
            character = {}
        }

        -- BarrackPC の数だけループして設定を作成
        for i = 1, barrackPCCount do -- Lua の配列は 1 から始めるのが一般的です
            local barrackPCInfo = accountInfo:GetBarrackPCByIndex(i - 1) -- 0 インデックスの補正
            local barrackPCName = barrackPCInfo:GetName()

            settings.character[barrackPCName] = {
                SHIRT = {},
                PANTS = {},
                GLOVES = {},
                BOOTS = {},
                SEAL = {},
                ARK = {},
                RELIC = {},
                LEG = {},
                GOD = {},
                index = i,
                layer = 9,
                name = barrackPCName
            }
        end
        g.settings = settings
        other_character_skill_list_save_settings()

        settingsFile = io.open(g.settingsFileLoc, "r")
        local settingsContent = settingsFile:read("*all")
        settingsFile:close()
        acutil.saveJSON(tempFilePath, settingsContent)
    end

    settingsFile = io.open(g.settingsFileLoc, "r")
    local settingsContent = settingsFile:read("*all")
    settingsFile:close()

    if settingsContent == '{"character":[]}' then
        local accountInfo = session.barrack.GetMyAccount()
        local barrackPCCount = accountInfo:GetBarrackPCCount()

        -- 設定がない場合、新しい設定を作成する
        local settings = {
            character = {}
        }

        -- BarrackPC の数だけループして設定を作成
        for i = 1, barrackPCCount do -- Lua の配列は 1 から始めるのが一般的です
            local barrackPCInfo = accountInfo:GetBarrackPCByIndex(i - 1) -- 0 インデックスの補正
            local barrackPCName = barrackPCInfo:GetName()

            settings.character[barrackPCName] = {
                SHIRT = {},
                PANTS = {},
                GLOVES = {},
                BOOTS = {},
                SEAL = {},
                ARK = {},
                RELIC = {},
                LEG = {},
                GOD = {},
                index = i,
                layer = 9,
                name = barrackPCName
            }
        end
        g.settings = settings
        other_character_skill_list_save_settings()

        settingsFile = io.open(g.settingsFileLoc, "r")
        local settingsContent = settingsFile:read("*all")
        settingsFile:close()
        acutil.saveJSON(tempFilePath, settingsContent)
    end

    local currentSettingsFile = io.open(g.settingsFileLoc, "r")
    local currentSettingsContent = currentSettingsFile:read("*all")
    currentSettingsFile:close()

    local tempFile = io.open(tempFilePath, "r")
    local tempFileContent = tempFile:read("*all")
    tempFile:close()

    tempFileContent = tempFileContent:gsub("\\", "")
    tempFileContent = tempFileContent:gsub('^"', ''):gsub('"$', '')

    if currentSettingsContent ~= tempFileContent then
        local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
        g.settings = settings
        other_character_skill_list_save_settings()

        local settingsFile = io.open(g.settingsFileLoc, "r")
        local settingsContent = settingsFile:read("*all")
        settingsFile:close()
        acutil.saveJSON(tempFilePath, settingsContent)
        -- print("違う")

    else
        if not g.loaded then
            local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
            g.settings = settings
            other_character_skill_list_save_settings()

            local settingsFile = io.open(g.settingsFileLoc, "r")
            local settingsContent = settingsFile:read("*all")
            settingsFile:close()
            acutil.saveJSON(tempFilePath, settingsContent)
            -- print("最初")
            g.loaded = true
        else
            -- print("一緒")
        end

    end
    other_character_skill_list_sort()
end]]

function other_character_skill_list_sort()

    local function sortByLayerAndOrder(a, b)
        if a.layer ~= b.layer then
            return a.layer < b.layer
        else
            return a.index < b.index
        end
    end

    local characterList = {}
    for name, charData in pairs(g.settings.character) do
        table.insert(characterList, charData)
    end

    table.sort(characterList, sortByLayerAndOrder)

    g.characters = characterList
    g.layer = nil
    other_character_skill_list_frame_open()
    -- g.characters の中身を表示
    --[[for i, charData in ipairs(g.characters) do
        print(string.format("Character %d:", i))
        for key, value in pairs(charData) do
            print(string.format("  %s: %s", key, tostring(value)))
        end
    end]]

end

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

function other_character_skill_list_save_enchant()

    local ivframe = ui.GetFrame("inventory")
    local pcName = session.GetMySession():GetPCApc():GetName()
    local equipItemList = session.GetEquipItemList()
    local count = equipItemList:Count()

    -- キャラクター名に一致する場合の処理をループでまとめる
    for name, spot in pairs(g.settings.character) do
        if tostring(name) == tostring(pcName) then
            for i = 0, count - 1 do
                local equipItem = equipItemList:GetEquipItemByIndex(i)
                local spotName = item.GetEquipSpotName(equipItem.equipSpot)
                local iesid = tostring(equipItem:GetIESID())
                local Item = session.GetEquipItemBySpot(item.GetEquipSpotNum(spotName))
                local obj = GetIES(Item:GetObject())

                -- 各装備スポットの処理
                if spotName == "SHIRT" or spotName == "PANTS" or spotName == "GLOVES" or spotName == "BOOTS" then
                    local slot = GET_CHILD_RECURSIVELY(ivframe, spotName)
                    local icon = slot:GetIcon()

                    local lv, Name, Level, slotcnt
                    if icon ~= nil then
                        lv = TryGetProp(obj, "Reinforce_2", 0)
                        Name, Level = shared_skill_enchant.get_enchanted_skill(obj, 1)
                        slotcnt = TryGetProp(obj, 'EnchantSkillSlotCount', 0)
                        g.settings.character[name][spotName] = {
                            clsid = obj.ClassID,
                            lv = lv,
                            iesid = iesid,
                            skillName = Name,
                            skillLv = Level,
                            slotcnt = slotcnt
                        }
                    else
                        g.settings.character[name][spotName] = {}
                    end

                elseif spotName == "SEAL" or spotName == "ARK" or spotName == "RELIC" then
                    local slot = GET_CHILD_RECURSIVELY(ivframe, spotName)
                    local icon = slot:GetIcon()

                    local lv
                    if spotName == "SEAL" then
                        lv = GET_CURRENT_SEAL_LEVEL(obj)
                    elseif spotName == "ARK" then
                        lv = TryGetProp(obj, 'ArkLevel', 1)
                    elseif spotName == "RELIC" then
                        lv = TryGetProp(obj, 'Relic_LV', 1)
                    end
                    if icon ~= nil then
                        g.settings.character[name][spotName] = {
                            clsid = obj.ClassID,
                            lv = lv,
                            iesid = iesid
                        }
                    else
                        g.settings.character[name][spotName] = {}
                    end
                end

            end
            if equipcard.GetCardInfo(13) ~= nil then
                local info = equipcard.GetCardInfo(13)
                g.settings.character[name]["LEG"].clsid = info:GetCardID()
                g.settings.character[name]["LEG"].lv = info.cardLv
                -- g.settings.character[name]["LEG"].iesid = iesid
            else
                g.settings.character[name]["LEG"] = {}
            end
            if equipcard.GetCardInfo(14) ~= nil then
                local info = equipcard.GetCardInfo(14)
                g.settings.character[name]["GOD"].clsid = info:GetCardID()
                g.settings.character[name]["GOD"].lv = info.cardLv
            else
                g.settings.character[name]["GOD"] = {}
            end

            other_character_skill_list_save_settings()
            return
        end
    end

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
    -- other_character_skill_list_sort()
    -- btn:SetEventScript(ui.LBUTTONDOWN, "other_character_skill_list_load_settings")
    btn:SetEventScript(ui.LBUTTONDOWN, "other_character_skill_list_sort")
    btn:SetTextTooltip("Other Character Skill List")

end

-- other_character_skill_list_load_settings()
function other_character_skill_list_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function other_character_skill_list_frame_open(frame, ctrl, argStr, argNum)

    local frame = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "new_frame", 0, 0, 70, 30)
    AUTO_CAST(frame)

    frame:SetSkinName("test_frame_midle")
    frame:Resize(990, 300)
    frame:SetLayerLevel(103)
    -- frame:ShowWindow(1)
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

    local help = title:CreateOrGetControl('button', "help", 40, 0, 35, 35)
    AUTO_CAST(help);
    -- help:SetSkinName("None")
    help:SetText("{ol}{img question_mark 20 20}")
    help:SetSkinName("test_pvp_btn")
    local language = option.GetCurrentCountry()
    if language == "Japanese" then
        help:SetTextTooltip(
            "{ol}順番に並ばない場合は一度バラックに戻ってバラック1､2､3毎にログインしてください。{nl}" ..
                "InstantCCアドオンを使用している場合は「Return To Barrack」で戻ってください。")
    else
        help:SetTextTooltip("{olIf you do not line up in order,{nl}" ..
                                "please return to the barracks once and log in for each barracks 1,2,3.{nl}" ..
                                "If you are using the InstantCC add-on, please return with [Return To Barrack].")
    end

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

    local langtbl = {}

    if language == "Japanese" then
        langtbl = jatbl
    else
        langtbl = entbl
    end

    local x = 10
    local yy = 155
    local yyy = 0
    local equips = {"SHIRT", "PANTS", "GLOVES", "BOOTS", "LEG", "GOD", "SEAL", "ARK", "RELIC"}

    for _, character in ipairs(g.characters) do

        local name_text = gbox:CreateOrGetControl("richtext", "name_text" .. character.name, 10, x, 145, 20)
        name_text:SetText("{ol}" .. character.name)
        name_text:AdjustFontSizeByWidth(150)

        local skill_list = GetClassList("Skill");

        for i, equipType in ipairs(equips) do

            if i <= 4 then
                local slot = gbox:CreateOrGetControl("slot", "slot" .. equipType .. character.name,
                    yy + (225 * (i - 1)) + 30, x, 25, 24)
                AUTO_CAST(slot)
                slot:EnablePop(0)
                slot:EnableDrop(0)
                slot:EnableDrag(0)
                slot:SetSkinName('invenslot2');

                local equip = gbox:CreateOrGetControl("slot", "equip" .. equipType .. character.name,
                    yy + (225 * (i - 1)), x, 25, 24)
                AUTO_CAST(equip)
                equip:EnablePop(0)
                equip:EnableDrop(0)
                equip:EnableDrag(0)
                equip:SetSkinName('invenslot2');

                local clsID = g.settings["character"][character.name][equipType].clsid

                if clsID ~= nil then
                    local lv = g.settings["character"][character.name][equipType].lv
                    local itemCls = GetClassByType("Item", clsID);
                    local imageName = itemCls.Icon;
                    SET_SLOT_ICON(equip, imageName)

                    SET_SLOT_BG_BY_ITEMGRADE(equip, itemCls)
                    equip:SetText('{s12}{ol}{#FFFF00}+' .. lv, 'count', ui.RIGHT, ui.BOTTOM, 0, 0);
                    local icon = equip:GetIcon()
                    icon:SetTextTooltip(itemCls.Name);
                end

                local skill = GetClassByNameFromList(skill_list,
                    g.settings["character"][character.name][equipType].skillName)

                if skill ~= nil then
                    local sklCls = GetClassByType("Skill", skill.ClassID);

                    local imageName = 'icon_' .. sklCls.Icon;
                    SET_SLOT_ICON(slot, imageName)
                    local skill_name = gbox:CreateOrGetControl("richtext", "skill_name" .. equipType .. character.name,
                        yy + 60 + (225 * (i - 1)), x, 140, 20)

                    slot:SetText('{s14}{ol}{#FFFF00}' .. g.settings["character"][character.name][equipType].skillLv,
                        'count', ui.RIGHT, ui.BOTTOM, -2, -2)

                    local icon = slot:GetIcon()
                    icon:SetTooltipType('skill');
                    icon:SetTooltipArg("Level", skill.ClassID,
                        g.settings["character"][character.name][equipType].skillLv);

                    for k, v in pairs(langtbl) do

                        if tostring(k) == tostring(g.settings["character"][character.name][equipType].skillName) then
                            skill_name:SetText("{ol}{s16}" .. v)
                            skill_name:AdjustFontSizeByWidth(160)
                        end

                    end
                end
            elseif i >= 5 then
                local slot = gbox:CreateOrGetControl("slot", "etc_slot" .. equipType .. character.name,
                    yy + 225 * 4 + yyy, x, 25, 24)
                AUTO_CAST(slot)
                slot:EnablePop(0)
                slot:EnableDrop(0)
                slot:EnableDrag(0)
                slot:SetSkinName('invenslot2');

                local text = ""
                if i >= 5 and i <= 6 then
                    text = "{s12}{ol}{#FFFF00}{img mon_legendstar 10 10}{nl}"
                else
                    text = "{s12}{ol}{#FFFF00}+"
                end
                local itemCls = GetClassByType("Item", g.settings["character"][character.name][equipType].clsid)
                if itemCls ~= nil then

                    local imageName = itemCls.Icon;
                    SET_SLOT_ICON(slot, imageName)
                    local icon = slot:GetIcon()
                    icon:SetTextTooltip(itemCls.Name);
                    slot:SetText(text .. g.settings["character"][character.name][equipType].lv, 'count', ui.RIGHT,
                        ui.BOTTOM, 0, 0);
                end
                yyy = yyy + 30
            end

        end
        yyy = 0
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

end

function other_character_skill_list_frame_close(frame, ctrl, argStr, argNum)
    local frame = ui.GetFrame(addonNameLower .. "new_frame")
    frame:ShowWindow(0)

end
