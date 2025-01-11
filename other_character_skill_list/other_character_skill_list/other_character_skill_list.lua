-- v1.0.1 skillnameがNoneの場合に表示バグってたの修正
-- v1.0.2 UI少し変更。CC時のカードやエンブレムの装備取り忘れ確認機能。
-- v1.0.3 読み込み早くしたつもり。自分では何も感じない。回線のせいか？
-- v1.0.4 3回目以降のCCはキャラクターリストを読み込まない様に変更
-- v1.0.5 書き直した。高速化したはず。
-- v1.0.6 instantcc使ってたら順番バグるの修正。フレーム開ける時に読み込みに変更。
-- v1.0.7 順番バグってたの再修正
-- v1.0.8 キャラの装備詳細見れる様にした。でも同一バラックじゃないと無理／(^o^)＼ 他の装備LVも可視化
-- v1.0.9 バグ修正
-- v1.1.0 高速化。ギアスコア表示。セーブデータは一旦消えます(´;ω;｀)
-- v1.1.1 セーブファイルの呼出修正
local addonName = "OTHER_CHARACTER_SKILL_LIST"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.1.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local function unicode_to_codepoint(char)
    local codepoint = utf8.codepoint(char)
    return string.format("%X", codepoint)
end

local function convert_to_ascii(input)
    local result = ""
    for char in input:gmatch(utf8.charpattern) do
        result = result .. unicode_to_codepoint(char)
    end
    return result
end

local input = GETMYFAMILYNAME()
local output = convert_to_ascii(input)
g.settingsFileLoc = string.format('../addons/%s/%s.json', addonNameLower, output .. "2501")
g.changeFileLoc = string.format('../addons/%s/%s.json', addonNameLower, "change" .. output .. "2501")
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

function g.mkdir_new_folder()
    local folder_path = string.format("../addons/%s", addonNameLower)
    local file_path = string.format("../addons/%s/mkdir.txt", addonNameLower)
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
g.mkdir_new_folder()

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

function OTHER_CHARACTER_SKILL_LIST_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.settings = g.settings or {}
    g.change = g.change or {}

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
        local equipments = {"RH", "LH", "RH_SUB", "LH_SUB", "NECK", "RING1", "RING2", "SHIRT", "PANTS", "GLOVES",
                            "BOOTS", "SEAL", "ARK", "RELIC", "LEG", "GOD"}
        for i = 0, cnt - 1 do

            local pcInfo = accountInfo:GetPCByIndex(i)
            local pcApc = pcInfo:GetApc()
            local pcName = pcApc:GetName()
            local pccid = pcInfo:GetCID()

            for name, charData in pairs(g.settings.character) do

                if name == pcName then

                    if g.change[name] ~= nil then
                        g.change[name] = pccid
                        acutil.saveJSON(g.changeFileLoc, g.change) -- 変更ファイルの保存

                    end

                    g.charFileLoc = string.format('../addons/%s/%s.json', addonNameLower, pccid)

                    local file = io.open(g.charFileLoc, "r")
                    if not file then
                        -- ファイルが存在しない場合、新しいテーブルを作成
                        local cid = {
                            name = pcName,
                            gear_score = 0
                        }
                        local equipments = {"RH", "LH", "RH_SUB", "LH_SUB", "NECK", "RING1", "RING2", "SHIRT", "PANTS",
                                            "GLOVES", "BOOTS", "SEAL", "ARK", "RELIC", "LEG", "GOD"}
                        for _, key in ipairs(equipments) do
                            cid[key] = {}

                        end
                        g.cid = cid
                        acutil.saveJSON(g.charFileLoc, g.cid)
                    else
                        file:close()
                    end

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

    if not settings or next(settings["character"]) == nil then
        local accountInfo = session.barrack.GetMyAccount()
        local barrackPCCount = accountInfo:GetBarrackPCCount()

        settings = {
            character = {}
        }

        for i = 0, barrackPCCount - 1 do
            local barrackPCInfo = accountInfo:GetBarrackPCByIndex(i)
            local barrackPCName = barrackPCInfo:GetName()

            settings.character[barrackPCName] = {

                index = i,
                layer = 9

            }
        end
        g.settings = settings
    end

    g.settings = settings

    other_character_skill_list_save_settings()

    local change, err = acutil.loadJSON(g.changeFileLoc, g.change)

    if not change or not next(change) then

        local accountInfo = session.barrack.GetMyAccount()
        local barrackPCCount = accountInfo:GetBarrackPCCount()
        change = {}

        for i = 0, barrackPCCount - 1 do
            local barrackPCInfo = accountInfo:GetBarrackPCByIndex(i)
            local barrackPCName = barrackPCInfo:GetName()
            change[barrackPCName] = "0"
        end
        g.change = change

    else
        g.change = change

    end
end

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

        local cid = g.change[name]

        if cid then
            charData.name = name
            charData.cid = cid
            table.insert(characterList, charData)

        end
    end

    table.sort(characterList, sortByLayerAndOrder)
    g.characters = characterList
    other_character_skill_list_frame_open()

    --[[for cid, charData in pairs(characterList) do
        print(string.format("CID: %s", cid))
        print(string.format("  Name: %s", charData.name))
        print(string.format("  Layer: %d", charData.layer))
        print(string.format("  Index: %d", charData.index))
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

local function format_json(data, indent)
    local indent = indent or 0
    local formatting = string.rep(" ", indent)
    local result = ""

    if type(data) == "table" then
        result = result .. "{\n"
        local isFirst = true
        for k, v in pairs(data) do
            if not isFirst then
                result = result .. ",\n"
            end
            isFirst = false
            result = result .. formatting .. "  \"" .. tostring(k) .. "\": " .. format_json(v, indent + 2)
        end
        result = result .. "\n" .. formatting .. "}"
    elseif type(data) == "string" then
        result = result .. "\"" .. data .. "\""
    else
        result = result .. tostring(data)
    end

    return result
end

function other_character_skill_list_save_enchant()

    local ivframe = ui.GetFrame("inventory")
    local pcName = session.GetMySession():GetPCApc():GetName()
    local equipItemList = session.GetEquipItemList()
    local count = equipItemList:Count()
    local cid = session.GetMySession():GetCID()

    local path = string.format('../addons/%s/%s.json', addonNameLower, cid)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*all")
        file:close()
        local data = json.decode(content)
        local characterName = data.name

        -- 名前の比較をループの外で行う
        if characterName == pcName then
            local score = 0
            for i = 0, count - 1 do
                local equipItem = equipItemList:GetEquipItemByIndex(i)
                local spotName = item.GetEquipSpotName(equipItem.equipSpot)
                local iesid = tostring(equipItem:GetIESID())
                local Item = session.GetEquipItemBySpot(item.GetEquipSpotNum(spotName))
                local obj = GetIES(Item:GetObject())
                if obj.ClassName ~= "NoRing" then
                    score = GET_GEAR_SCORE(obj) + score
                end

                -- 各装備スポットの処理
                if spotName == "SHIRT" or spotName == "PANTS" or spotName == "GLOVES" or spotName == "BOOTS" then
                    local slot = GET_CHILD_RECURSIVELY(ivframe, spotName)
                    local icon = slot:GetIcon()

                    local lv, Name, Level, slotcnt
                    if icon ~= nil then
                        lv = TryGetProp(obj, "Reinforce_2", 0)
                        Name, Level = shared_skill_enchant.get_enchanted_skill(obj, 1)
                        slotcnt = TryGetProp(obj, 'EnchantSkillSlotCount', 0)
                        data[spotName] = {
                            clsid = obj.ClassID,
                            lv = lv,
                            iesid = iesid,
                            skillName = Name,
                            skillLv = Level
                        }
                    else
                        data[spotName] = {}
                    end
                elseif spotName == "RH" or spotName == "LH" or spotName == "RH_SUB" or spotName == "LH_SUB" then
                    local slot = GET_CHILD_RECURSIVELY(ivframe, spotName)
                    local icon = slot:GetIcon()

                    local lv, Name, Level, slotcnt
                    if icon ~= nil then
                        lv = TryGetProp(obj, "Reinforce_2", 0)
                        -- Name, Level = shared_skill_enchant.get_enchanted_skill(obj, 1)
                        slotcnt = TryGetProp(obj, 'EnchantSkillSlotCount', 0)
                        data[spotName] = {
                            clsid = obj.ClassID,
                            lv = lv,
                            iesid = iesid
                        }
                    else
                        data[spotName] = {}
                    end
                elseif spotName == "RING1" or spotName == "RING2" or spotName == "NECK" then
                    local slot = GET_CHILD_RECURSIVELY(ivframe, spotName)
                    local icon = slot:GetIcon()

                    local lv, Name, Level, slotcnt
                    if icon ~= nil then
                        lv = TryGetProp(obj, "Reinforce_2", 0)
                        -- Name, Level = shared_skill_enchant.get_enchanted_skill(obj, 1)
                        slotcnt = TryGetProp(obj, 'EnchantSkillSlotCount', 0)
                        data[spotName] = {
                            clsid = obj.ClassID,
                            lv = lv,
                            iesid = iesid
                        }
                    else
                        data[spotName] = {}
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
                        data[spotName] = {
                            clsid = obj.ClassID,
                            lv = lv,
                            iesid = iesid
                        }
                    else
                        data[spotName] = {}
                    end
                end
            end

            -- 装備カードの処理
            if equipcard.GetCardInfo(13) ~= nil then
                local info = equipcard.GetCardInfo(13)
                data["LEG"].clsid = info:GetCardID()
                data["LEG"].lv = info.cardLv
            else
                data["LEG"] = {}
            end

            if equipcard.GetCardInfo(14) ~= nil then
                local info = equipcard.GetCardInfo(14)
                data["GOD"].clsid = info:GetCardID()
                data["GOD"].lv = info.cardLv
            else
                data["GOD"] = {}
            end
            data.gear_score = score

            -- 更新されたデータをファイルに書き込む
            local file = io.open(path, "w")
            local formattedJson = format_json(data, 0)
            file:write(formattedJson)
            file:close()

        else
            print("Character name does not match.")
        end

    else
        --[[local file = io.open(path, "w")
        file:write({})
        file:Close()
        -- print("File not found or unable to open: " .. path)]]
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
    btn:SetTextTooltip("{ol}Other Character Skill List")

end

-- other_character_skill_list_load_settings()
function other_character_skill_list_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function other_character_skill_list_char_report_close(frame, ctrl, str, num)

    local parent = frame:GetParent()
    parent = parent:GetParent()

    parent:ShowWindow(0)
end

local skin_list = {}
function other_character_skill_list_char_report(frame, ctrl, str, num)
    -- print(tostring(frame:GetName()))
    local cid = ""
    for name, changecid in pairs(g.change) do
        if name == str then
            cid = changecid
            break
        end
    end
    local key = cid
    local ctrl_name = frame:GetUserValue("CTRL_NAME")
    if ctrl_name ~= "None" and ctrl_name ~= key then
        DESTROY_CHILD_BYNAME(frame, "char_" .. ctrl_name)
    else
        local char_frame = GET_CHILD_RECURSIVELY(frame, "char_" .. ctrl_name)
        if char_frame ~= nil then
            char_frame:ShowWindow(1)
        end
    end

    local bpc = barrack.GetBarrackPCInfoByCID(cid);

    if bpc == nil then
        local language = option.GetCurrentCountry()
        if language == "Japanese" then
            ui.SysMsg(
                "{ol}詳細表示は、ログイン中のキャラと同一バラックのキャラのみ対応しています (´;ω;｀)")

        else
            ui.SysMsg(
                "{ol}Detailed view is supported only for characters in the same barracks as the currently logged-in character.")
        end

        return

    end
    local name = str

    local charCtrl = frame:CreateOrGetControlSet('barrack_charlist', 'char_' .. cid, 150, 80);
    AUTO_CAST(charCtrl)
    frame:SetUserValue("CTRL_NAME", cid)
    charCtrl:SetUserValue("CID", cid);
    local mainBox = GET_CHILD(charCtrl, 'mainBox', 'ui::CGroupBox');
    local btn = mainBox:GetChild("btn");
    btn:SetSkinName('character_off');
    btn:SetSValue(name);
    btn:SetOverSound('button_over');
    btn:SetClickSound('button_click_2');
    -- btn:SetEventScript(ui.LBUTTONUP, "SELECT_CHARBTN_LBTNUP");
    -- btn:SetEventScriptArgString(ui.LBUTTONUP, cid);

    local indunBtn = mainBox:GetChild("indunBtn")
    AUTO_CAST(indunBtn)

    indunBtn:SetImage("testclose_button")
    -- indunBtn:ShowWindow(1)
    indunBtn:SetEventScript(ui.LBUTTONUP, "other_character_skill_list_char_report_close");

    btn:ShowWindow(1);
    local apc = bpc:GetApc();

    local gender = apc:GetGender();
    local jobid = apc:GetJob();
    local level = apc:GetLv()
    local pic = GET_CHILD(mainBox, "char_icon", "ui::CPicture");
    local headIconName = ui.CaptureModelHeadImageByApperance(apc);
    pic:SetImage(headIconName);

    local nameCtrl = GET_CHILD(mainBox, "name", "ui::CRichText");
    nameCtrl:SetText("{@st42b}{b}" .. name);

    local barrack_pc = session.barrack.GetMyAccount():GetByStrCID(key);
    if barrack_pc ~= nil and barrack_pc:GetRepID() ~= 0 then
        jobid = barrack_pc:GetRepID();
    end

    local jobCls = GetClassByType("Job", jobid);
    local jobCtrl = GET_CHILD(mainBox, "job", "ui::CRichText");
    jobCtrl:SetText("{@st42b}" .. GET_JOB_NAME(jobCls, gender));
    local levelCtrl = GET_CHILD(mainBox, "level", "ui::CRichText");
    levelCtrl:SetText("{@st42b}Lv." .. level);

    local detail = GET_CHILD(charCtrl, 'detailBox', 'ui::CGroupBox');
    local RH_SUB = detail:CreateOrGetControl("slot", "RH_SUB", 138, 214, 55, 55)
    local LH_SUB = detail:CreateOrGetControl("slot", "LH_SUB", 198, 214, 55, 55)
    local mapNameCtrl = GET_CHILD(detail, 'mapName', 'ui::CRichText');

    local mapCls = GetClassByType("Map", apc.mapID);
    if mapCls ~= nil then
        local mapName = mapCls.Name;
        mapNameCtrl:SetText("{@st66b}" .. mapName);
    end

    local spotCount = item.GetEquipSpotCount() - 1;

    for i = 0, spotCount do
        local eqpObj = bpc:GetEquipObj(i);
        local esName = item.GetEquipSpotName(i);

        if eqpObj ~= nil then

            local obj = GetIES(eqpObj);
            local eqpType = TryGet_Str(obj, "EqpType");
            if eqpType == "HELMET" then
                if item.IsNoneItem(obj.ClassID) == 0 then
                    esName = "HAIR";
                end
            end

            if esName == "TRINKET" and obj ~= nil and item.IsNoneItem(obj.ClassID) == 0 then
                esName = "LH"
            end

        end

        local eqpSlot = GET_CHILD(detail, esName, "ui::CSlot");
        -- AUTO_CAST(eqpSlot)

        if eqpSlot ~= nil then
            if eqpSlot:GetName() == "SHIRT" then
                eqpSlot:SetMargin(-120, 150, 0, 0);
            elseif eqpSlot:GetName() == "PANTS" then
                eqpSlot:SetMargin(-60, 150, 0, 0);
            elseif eqpSlot:GetName() == "GLOVES" then
                eqpSlot:SetMargin(0, 150, 0, 0);
            elseif eqpSlot:GetName() == "BOOTS" then
                eqpSlot:SetMargin(60, 150, 0, 0);
            elseif eqpSlot:GetName() == "RH" then
                eqpSlot:SetMargin(-120, 214, 0, 0);
            elseif eqpSlot:GetName() == "LH" then
                eqpSlot:SetMargin(-60, 214, 0, 0);
            elseif eqpSlot:GetName() == "ARK" then
                eqpSlot:SetMargin(120, 150, 0, 0);
            elseif eqpSlot:GetName() == "RELIC" then
                eqpSlot:SetMargin(120, 214, 0, 0);
                -- local rect = eqpSlot:GetMargin();
                -- print(rect.left .. ":" .. rect.top .. ":" .. rect.right .. ":" .. rect.bottom);
            end
            if skin_list[esName] == nil then
                skin_list[esName] = eqpSlot:GetSkinName()
            end

            eqpSlot:EnableDrag(0);
            if eqpObj == nil then
                CLEAR_SLOT_ITEM_INFO(eqpSlot);
            else
                local obj = GetIES(eqpObj);

                local refreshScp = obj.RefreshScp;
                if refreshScp ~= "None" then
                    refreshScp = _G[refreshScp];
                    refreshScp(obj);
                end

                if 0 == item.IsNoneItem(obj.ClassID) then
                    CLEAR_SLOT_ITEM_INFO(eqpSlot);
                    SET_SLOT_ITEM_OBJ(eqpSlot, obj, gender, 1);

                else
                    local skin_name = skin_list[esName]
                    if skin_name ~= nil then
                        eqpSlot:SetSkinName(skin_name)
                    end
                    SET_SLOT_TRANSCEND_LEVEL(eqpSlot, 0)
                    SET_SLOT_REINFORCE_LEVEL(eqpSlot, 0)
                    CLEAR_SLOT_ITEM_INFO(eqpSlot);
                end
            end
        end
    end

    -- charCtrl:Resize(charCtrl:GetWidth(), 128);

end

function other_character_skill_list_frame_open(frame, ctrl, argStr, argNum)

    local frame = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "new_frame", 0, 0, 70, 30)
    AUTO_CAST(frame)

    frame:SetSkinName("test_frame_midle")
    frame:Resize(990, 300)
    frame:SetLayerLevel(103)

    local title = frame:CreateOrGetControl("groupbox", "title", 0, 0, 1070, 40)
    AUTO_CAST(title)
    title:SetSkinName("None")

    local close = title:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.LEFT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "other_character_skill_list_frame_close")

    local help = title:CreateOrGetControl('button', "help", 40, 0, 35, 35)
    AUTO_CAST(help);

    help:SetText("{ol}{img question_mark 20 20}")
    help:SetSkinName("test_pvp_btn")
    local language = option.GetCurrentCountry()
    if language ~= "Japanese" then
        help:SetTextTooltip(
            "{ol}順番に並ばない場合は一度バラックに戻ってバラック1､2､3毎にログインしてください。{nl}" ..
                "InstantCCアドオンを使用している場合は「Return To Barrack」で戻ってください。{nl} {nl}" ..
                "{ol}名前部分を押すと、ログインキャラと同一バラックの各キャラの装備詳細が見れます。")
    else
        help:SetTextTooltip("{ol}If you do not line up in order,{nl}" ..
                                "please return to the barracks once and log in for each barracks 1,2,3.{nl}" ..
                                "If you are using the InstantCC add-on, please return with [Return To Barrack].{nl} {nl}" ..
                                "{ol}Press the name section to see the equipment details of each character{nl}in the same barrack as the login character.")
    end

    local weapon = title:CreateOrGetControl("richtext", "weapon", 160, 10, 100, 20)

    if language == "Japanese" then
        weapon:SetText("{ol}" .. "武器")
    else
        weapon:SetText("{ol}" .. "weapons")
    end

    local Accessory = title:CreateOrGetControl("richtext", "Accessory", 280, 10, 100, 20)

    if language == "Japanese" then
        Accessory:SetText("{ol}" .. "アクセ")
    else
        Accessory:SetText("{ol}" .. "Accessory")
    end

    weapon:AdjustFontSizeByWidth(100)
    local y = 370
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

    local langtbl = {}

    if language == "Japanese" then
        langtbl = jatbl
    else
        langtbl = entbl
    end

    local x = 10
    local yy = 370
    local yyy = 0
    local equips = {"SHIRT", "PANTS", "GLOVES", "BOOTS", "LEG", "GOD", "SEAL", "ARK", "RELIC", "RH", "LH", "RH_SUB",
                    "LH_SUB", "RING1", "RING2", "NECK"}

    local cnt = 0
    for _, character in ipairs(g.characters) do
        -- print(tostring(character.cid))
        local path = string.format('../addons/%s/%s.json', addonNameLower, character.cid)
        local file = io.open(path, "r")
        if file then
            local content = file:read("*all")
            file:close()
            local data = json.decode(content)
            local name_text = gbox:CreateOrGetControl("richtext", "name_text" .. character.name, 10, x, 145, 20)
            AUTO_CAST(name_text)
            name_text:SetText("{ol}" .. character.name)
            name_text:AdjustFontSizeByWidth(150)
            name_text:SetEventScript(ui.LBUTTONUP, "other_character_skill_list_char_report")
            name_text:SetEventScriptArgString(ui.LBUTTONUP, character.name)

            local gear_score = data.gear_score
            local gs_str = ""

            if gear_score ~= 0 then
                gs_str = gear_score
            else
                gs_str = "NoData"
            end

            if language == "Japanese" then
                name_text:SetTextTooltip("{ol}GearScore: " .. gs_str .. "{nl} {nl}" ..
                                             "名前部分を押すと各キャラの装備詳細が見れます。")
            else
                name_text:SetTextTooltip("{ol}GearScore: " .. gs_str .. "{nl} {nl}" ..
                                             "Press the name part to see the{nl}equipment details of each character.")
            end

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

                    local clsID = data[equipType].clsid

                    if clsID ~= nil then
                        local lv = data[equipType].lv
                        local itemCls = GetClassByType("Item", clsID);
                        local imageName = itemCls.Icon;
                        SET_SLOT_ICON(equip, imageName)

                        SET_SLOT_BG_BY_ITEMGRADE(equip, itemCls)
                        equip:SetText('{s12}{ol}{#FFFF00}+' .. lv, 'count', ui.RIGHT, ui.BOTTOM, 0, 0);
                        local icon = equip:GetIcon()
                        icon:SetTextTooltip(itemCls.Name);
                    end

                    local skill = GetClassByNameFromList(skill_list, data[equipType].skillName)

                    if skill ~= nil then
                        local sklCls = GetClassByType("Skill", skill.ClassID);

                        local imageName = 'icon_' .. sklCls.Icon;
                        SET_SLOT_ICON(slot, imageName)
                        local skill_name = gbox:CreateOrGetControl("richtext",
                            "skill_name" .. equipType .. character.name, yy + 60 + (225 * (i - 1)), x, 140, 20)

                        slot:SetText('{s14}{ol}{#FFFF00}' .. data[equipType].skillLv, 'count', ui.RIGHT, ui.BOTTOM, -2,
                            -2)

                        local icon = slot:GetIcon()
                        icon:SetTooltipType('skill');
                        icon:SetTooltipArg("Level", skill.ClassID, data[equipType].skillLv);

                        for k, v in pairs(langtbl) do

                            if tostring(k) == tostring(data[equipType].skillName) then
                                skill_name:SetText("{ol}{s16}" .. v)
                                skill_name:AdjustFontSizeByWidth(160)
                            end

                        end
                    end
                elseif i >= 5 and i <= 9 then
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
                    local itemCls = GetClassByType("Item", data[equipType].clsid)
                    if itemCls ~= nil then

                        local imageName = itemCls.Icon;
                        SET_SLOT_ICON(slot, imageName)
                        local icon = slot:GetIcon()
                        icon:SetTextTooltip(itemCls.Name);
                        slot:SetText(text .. data[equipType].lv, 'count', ui.RIGHT, ui.BOTTOM, 0, 0);
                    end
                    yyy = yyy + 30
                elseif i >= 10 then
                    local slot = gbox:CreateOrGetControl("slot", "slot" .. equipType .. character.name,
                        155 + 30 * (i - 10), x, 25, 24)
                    AUTO_CAST(slot)
                    slot:EnablePop(0)
                    slot:EnableDrop(0)
                    slot:EnableDrag(0)
                    slot:SetSkinName('invenslot2');

                    local clsID = data[equipType].clsid

                    if clsID ~= nil then
                        local lv = data[equipType].lv
                        local itemCls = GetClassByType("Item", clsID);
                        local imageName = itemCls.Icon;
                        SET_SLOT_ICON(slot, imageName)

                        SET_SLOT_BG_BY_ITEMGRADE(slot, itemCls)
                        slot:SetText('{s12}{ol}{#FFFF00}+' .. lv, 'count', ui.RIGHT, ui.BOTTOM, 0, 0);
                        local icon = slot:GetIcon()
                        icon:SetTextTooltip(itemCls.Name);
                    end
                end

            end
            yyy = 0
            x = x + 25
            cnt = cnt + 1

            -- else
            -- print("File not found or unable to open: " .. path)
        end

    end

    local framex = cnt * 25
    frame:Resize(1435, framex + 60)
    title:Resize(1425, 40)
    gbox:Resize(1425, framex + 20)

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
