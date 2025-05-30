-- v0.0.1 陶芸家やったら自分で割るレベルでリリース
-- v0.0.2 イコルLV毎に色分け。次は装備関係か・・・ボチボチやろ
-- v1.0.0 とりあえず公開
-- v1.0.1 英語対応、装備裏表切替対応
-- v1.0.2 必要ステータス表示
-- v1.0.3 表示切替機能。インベントリにボタン付けた。
-- v1.0.4 装備ボタンが非表示になるバグ修正。細かいところ色々変更
-- v1.0.5 2ページ表示の場合に設定が即時反映されないバグ修正
-- v1.0.6 2ページ目のイコル付け替えた際に1ページ目に戻るの修正。イコルのLV表示取りやめ。
-- v1.0.7 settingsファイルが無い状態で読み込んだらバグってたの修正。ツールチップ併記取りやめ。
-- v1.0.8 種族特攻とかのMAX数値が間違ってたの修正。そんなん知らんかった。
local addonName = "GODDESS_ICOR_MANAGER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.8"

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
    ["Cloth_Def"] = 1837
}, {
    ["Leather_Def"] = 1837
}, {
    ["Iron_Def"] = 1837
}, {
    ["MiddleSize_Def"] = 1837
}, {
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
    ["ResAdd_Damage"] = 2758
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
    ["Cloth_Def"] = 1472
}, {
    ["Leather_Def"] = 1472
}, {
    ["Iron_Def"] = 1472
}, {
    ["MiddleSize_Def"] = 1472
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
    ["ResAdd_Damage"] = 1837
}, {
    ["Add_Damage_Atk"] = 1837
}, {
    ["AllMaterialType_Atk"] = 1252
}, {
    ["AllRace_Atk"] = 1252
}}

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
    ["Cloth_Def"] = 1696
}, {
    ["Leather_Def"] = 1696
}, {
    ["Iron_Def"] = 1696
}, {
    ["MiddleSize_Def"] = 1696
}, {
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
    ["ResAdd_Damage"] = 2546
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
    ["Cloth_Def"] = 1359
}, {
    ["Leather_Def"] = 1359
}, {
    ["Iron_Def"] = 1359
}, {
    ["MiddleSize_Def"] = 1359
}, {
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
    ["AllMaterialType_Atk"] = 1156
}, {
    ["AllRace_Atk"] = 1156
}}

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
    ["Cloth_Def"] = 1414
}, {
    ["Leather_Def"] = 1414
}, {
    ["Iron_Def"] = 1414
}, {
    ["MiddleSize_Def"] = 1414
}, {
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
    ["ResAdd_Damage"] = 2122
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
    ["Cloth_Def"] = 1133
}, {
    ["Leather_Def"] = 1133
}, {
    ["Iron_Def"] = 1133
}, {
    ["MiddleSize_Def"] = 1133
}, {
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
    ["AllMaterialType_Atk"] = 964
}, {
    ["AllRace_Atk"] = 964
}}

local low480weapontbl = {{
    ["STR"] = 171
}, {
    ["DEX"] = 171
}, {
    ["INT"] = 171
}, {
    ["CON"] = 171
}, {
    ["MNA"] = 171
}, {
    ["BLK"] = 567
}, {
    ["BLK_BREAK"] = 567
}, {
    ["ADD_HR"] = 567
}, {
    ["ADD_DR"] = 567
}, {
    ["CRTHR"] = 567
}, {
    ["CRTDR"] = 567
}, {
    ["RHP"] = 567
}, {
    ["RSP"] = 567
}, {
    ["Cloth_Def"] = 1132
}, {
    ["Leather_Def"] = 1132
}, {
    ["Iron_Def"] = 1132
}, {
    ["MiddleSize_Def"] = 1132
}, {
    ["ADD_CLOTH"] = 1132
}, {
    ["ADD_LEATHER"] = 1132
}, {
    ["ADD_IRON"] = 1132
}, {
    ["ADD_SMALLSIZE"] = 1132
}, {
    ["ADD_MIDDLESIZE"] = 1132
}, {
    ["ADD_LARGESIZE"] = 1132
}, {
    ["ADD_GHOST"] = 1132
}, {
    ["ADD_FORESTER"] = 1132
}, {
    ["ADD_WIDLING"] = 1132
}, {
    ["ADD_VELIAS"] = 1132
}, {
    ["ADD_PARAMUNE"] = 1132
}, {
    ["ADD_KLAIDA"] = 1132
}, {
    ["Add_Damage_Atk"] = 1698
}, {
    ["ResAdd_Damage"] = 1698
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
    ["AllMaterialType_Atk"] = 770
}, {
    ["AllRace_Atk"] = 770
}}

function goddess_icor_manager_color(str)

    if str == "UTIL_ARMOR" then
        return "{#9966CC}"
    elseif str == "STAT" then
        return "{#228B22}"
    elseif str == "ATK" then
        return "{#FF4500}"
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
        if str == "STR" then
            str = "力"
        end
        if str == "DEX" then
            str = "敏捷"
        end
        if str == "INT" then
            str = "知能"
        end
        if str == "CON" then
            str = "体力"
        end
        if str == "MNA" then
            str = "精神"
        end

        if str == "BLK" then
            str = "ブロック"
        end
        if str == "BLK_BREAK" then
            str = "ブロック貫通"
        end
        if str == "ADD_HR" then
            str = "命中"
        end
        if str == "ADD_DR" then
            str = "回避"
        end
        if str == "CRTHR" then
            str = "クリティカル発生"
        end
        if str == "CRTDR" then
            str = "クリティカル抵抗"
        end
        if str == "RHP" then
            str = "HP回復力"
        end
        if str == "RSP" then
            str = "SP回復力"
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
        if str == "MiddleSize_Def" then
            str = "中型対象攻撃力相殺"
        end

        if str == "ADD_LEATHER" then
            str = "レザー防御対象攻撃力"
        end
        if str == "ADD_IRON" then
            str = "プレート防御対象攻撃力"
        end
        if str == "ADD_CLOTH" then
            str = "クロース防御対象攻撃力"
        end
        if str == "ADD_GHOST" then
            str = "アストラル防御対象攻撃力"
        end
        if str == "ADD_SMALLSIZE" then
            str = "小型対象攻撃力"
        end
        if str == "ADD_MIDDLESIZE" then
            str = "中型対象攻撃力"
        end
        if str == "ADD_LARGESIZE" then
            str = "大型対象攻撃力"
        end
        if str == "ADD_FORESTER" then
            str = "植物型対象攻撃力"
        end
        if str == "ADD_WIDLING" then
            str = "野獣型対象攻撃力"
        end
        if str == "ADD_VELIAS" then
            str = "悪魔型対象攻撃力"
        end
        if str == "ADD_PARAMUNE" then
            str = "変異型対象攻撃力"
        end
        if str == "ADD_KLAIDA" then
            str = "昆虫型対象攻撃力"
        end

        if str == "Add_Damage_Atk" then
            str = "追加ダメージ"
        end
        if str == "ResAdd_Damage" then
            str = "追加ダメージ抵抗"
        end

        if str == "AllRace_Atk" then
            str = "全ての種族の対象攻撃力"
        end
        if str == "AllMaterialType_Atk" then
            str = "全ての防具の対象攻撃力"
        end

        if str == "perfection" then
            str = "パーフェクト効果"
        end
        if str == "revenge" then
            str = "復讐効果"
        end

        if str == "stun_res" then
            str = "極：気絶抵抗"
        end
        if str == "high_fire_res" then
            str = "極：滅火抵抗"
        end
        if str == "high_freezing_res" then
            str = "極：寒冷抵抗"
        end
        if str == "high_lighting_res" then
            str = "極：過電荷抵抗"
        end
        if str == "high_poison_res" then
            str = "極：強劇猛毒抵抗"
        end
        if str == "high_laceration_res" then
            str = "極：出血過多抵抗"
        end
        if str == "portion_expansion" then
            str = "HPエリクサー広域化"
        end

        if str == "rada_bless_1" then
            str = ClMsg("rada_bless_1")
        end
        if str == "gabija_bless_1" then
            str = ClMsg("gabija_bless_1")
        end
        if str == "vakarine_bless_1" then
            str = ClMsg("vakarine_bless_1")
        end
        if str == "jurate_bless_1" then
            str = ClMsg("jurate_bless_1")
        end
        if str == "saule_bless_1" then
            str = ClMsg("saule_bless_1")
        end
        if str == "payawoota_bless_1" then
            str = ClMsg("payawoota_bless_1")
        end
        if str == "zemyna_bless_1" then
            str = ClMsg("zemyna_bless_1")
        end
        if str == "cleric_bless_1" then
            str = ClMsg("cleric_bless_1")
        end
        if str == "priest_bless_1" then
            str = ClMsg("priest_bless_1")
        end
        if str == "dievdirbys_bless_1" then
            str = ClMsg("dievdirbys_bless_1")
        end
        if str == "chaplain_bless_1" then
            str = ClMsg("chaplain_bless_1")
        end
        if str == "retiarii_bless_1" then
            str = ClMsg("retiarii_bless_1")
        end
        if str == "appraiser_bless_1" then
            str = ClMsg("appraiser_bless_1")
        end
        if str == "plagueDoctor_bless_1" then
            str = ClMsg("plagueDoctor_bless_1")
        end
        if str == "fireMage_bless_1" then
            str = ClMsg("fireMage_bless_1")
        end
        if str == "dalia_bless_1" then
            str = ClMsg("dalia_bless_1")
        end

        if str == " 500Advanced" then
            str = " LV500 上級"
        end
        if str == " 480Advanced" then
            str = " LV480 上級"
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
        if str == "BOOTS" then
            str = "靴"
        end
        -- "ボタン左クリックでイコル装備します。{nl}Equip the icor with a left click of the button"
        if str == "Equip the icor with a left click of the button." then
            str = "ボタン左クリックでイコル装備します。"
        end
        -- "チェックを入れると一括表示に切り替えます。{nl}10 preset displays when checked.")
        if str == "Check the box to switch to batch display." then
            str = "チェックを入れると一括表示に切り替えます。"
        end
        -- "{ol}Check box to switch display number"
        if str == "{ol}Check box to switch display number" then
            str = "{ol}チェックボックスで表示数切替"
        end
        -- Right click to close.
        if str == "Right click to close." then
            str = "右クリックで閉じます。"
        end
        -- "Swap the reverse side of the weapon."
        if str == "Swap the reverse side of the weapon." then
            str = "武器の裏表を切り替えます。"
        end
        return str

    else
        if str == "STR" then
            str = "STR"
        end
        if str == "DEX" then
            str = "DEX"
        end
        if str == "INT" then
            str = "INT"
        end
        if str == "CON" then
            str = "CON"
        end
        if str == "MNA" then
            str = "SPR"
        end

        if str == "BLK" then
            str = "Block"
        end
        if str == "BLK_BREAK" then
            str = "Block penetration"
        end
        if str == "ADD_HR" then
            str = "Accuracy"
        end
        if str == "ADD_DR" then
            str = "Evasion"
        end
        if str == "CRTHR" then
            str = "Critical Rate"
        end
        if str == "CRTDR" then
            str = "Critical Resistance"
        end
        if str == "RHP" then
            str = "HP Recovery"
        end
        if str == "RSP" then
            str = ClMsg("RSP")
        end

        if str == "Leather_Def" then
            str = "DEF Leather armor"
        end
        if str == "Cloth_Def" then
            str = "DEF Cloth armor"
        end
        if str == "Iron_Def" then
            str = "DEF Plate armor"
        end
        if str == "MiddleSize_Def" then
            str = "DEF Medium size"
        end

        if str == "ADD_LEATHER" then
            str = "ATK Leather armor"
        end
        if str == "ADD_IRON" then
            str = "ATK Plate armor"
        end
        if str == "ADD_CLOTH" then
            str = "ATK Cloth armor"
        end
        if str == "ADD_GHOST" then
            str = "ATK Ghost armor"
        end
        if str == "ADD_SMALLSIZE" then
            str = "ATK Small size"
        end
        if str == "ADD_MIDDLESIZE" then
            str = "ATK Medium size"
        end
        if str == "ADD_LARGESIZE" then
            str = "ATK Large size"
        end
        if str == "ADD_FORESTER" then
            str = "ATK Plant-type"
        end
        if str == "ADD_WIDLING" then
            str = "ATK Beast-type"
        end
        if str == "ADD_VELIAS" then
            str = "ATK Devil-type"
        end
        if str == "ADD_PARAMUNE" then
            str = "ATK Mutant-type"
        end
        if str == "ADD_KLAIDA" then
            str = "ATK Insect-type"
        end

        if str == "Add_Damage_Atk" then
            str = "Additional Damage"
        end
        if str == "ResAdd_Damage" then
            str = "DEF Add Damage"
        end

        if str == "AllRace_Atk" then
            str = "ATK all creature type"
        end
        if str == "AllMaterialType_Atk" then
            str = "ATK every type of armor"
        end

        if str == "perfection" then
            str = "ATK Perfection"
        end
        if str == "revenge" then
            str = "ATK Revenge"
        end

        if str == "stun_res" then
            str = "Ex:Pass out"
        end
        if str == "high_fire_res" then
            str = "Ex:Inferno"
        end
        if str == "high_freezing_res" then
            str = "Ex:Frigid"
        end
        if str == "high_lighting_res" then
            str = "Ex:Overcharge"
        end
        if str == "high_poison_res" then
            str = "Ex:Virulent"
        end
        if str == "high_laceration_res" then
            str = "Ex:Heavy Bleeding"
        end
        if str == "portion_expansion" then
            str = "HP Elixir Broaden"
        end

        if str == "rada_bless_1" then
            str = ClMsg("rada_bless_1")
        end
        if str == "gabija_bless_1" then
            str = ClMsg("gabija_bless_1")
        end
        if str == "vakarine_bless_1" then
            str = ClMsg("vakarine_bless_1")
        end
        if str == "jurate_bless_1" then
            str = ClMsg("jurate_bless_1")
        end
        if str == "saule_bless_1" then
            str = ClMsg("saule_bless_1")
        end
        if str == "payawoota_bless_1" then
            str = ClMsg("payawoota_bless_1")
        end
        if str == "zemyna_bless_1" then
            str = ClMsg("zemyna_bless_1")
        end
        if str == "cleric_bless_1" then
            str = ClMsg("cleric_bless_1")
        end
        if str == "priest_bless_1" then
            str = ClMsg("priest_bless_1")
        end
        if str == "dievdirbys_bless_1" then
            str = ClMsg("dievdirbys_bless_1")
        end
        if str == "chaplain_bless_1" then
            str = ClMsg("chaplain_bless_1")
        end
        if str == "retiarii_bless_1" then
            str = ClMsg("retiarii_bless_1")
        end
        if str == "appraiser_bless_1" then
            str = ClMsg("appraiser_bless_1")
        end
        if str == "plagueDoctor_bless_1" then
            str = ClMsg("plagueDoctor_bless_1")
        end
        if str == "fireMage_bless_1" then
            str = ClMsg("fireMage_bless_1")
        end
        if str == "dalia_bless_1" then
            str = ClMsg("dalia_bless_1")
        end

        if str == " 500Advanced" then
            str = " LV500 Advanced"
        end
        if str == " 480Advanced" then
            str = " LV480 Advanced"
        end

        --[[if str == " disabled" then
            str = " 使用不可"
        end]]

        if str == "RH" then
            str = ClMsg("RH")
        end
        if str == "LH" then
            str = ClMsg("LH")
        end
        if str == "RH_SUB" then
            str = ClMsg("RH_SUB")
        end
        if str == "LH_SUB" then
            str = ClMsg("LH_SUB")
        end
        if str == "SHIRT" then
            str = ClMsg("Shirt")
        end
        if str == "PANTS" then
            str = ClMsg("Pants")
        end
        if str == "GLOVES" then
            str = ClMsg("GLOVES")
        end
        if str == "BOOTS" then
            str = ClMsg("BOOTS")
        end

        return str
    end
    return str
end

local managed_list = {'RH', 'LH', 'SHIRT', 'PANTS', 'GLOVES', 'BOOTS', 'RH_SUB', 'LH_SUB'}
local managed_slot_list = {{
    SlotName = 'RH',
    SkinName = 'rh',
    ClMsg = 'RH'
}, {
    SlotName = 'LH',
    SkinName = 'lh',
    ClMsg = 'LH'
}, {
    SlotName = 'SHIRT',
    SkinName = 'shirt',
    ClMsg = 'Shirt'
}, {
    SlotName = 'PANTS',
    SkinName = 'pants',
    ClMsg = 'Pants'
}, {
    SlotName = 'GLOVES',
    SkinName = 'gloves',
    ClMsg = 'Gloves'
}, {
    SlotName = 'BOOTS',
    SkinName = 'boots',
    ClMsg = 'Boots'
}, {
    SlotName = 'RH_SUB',
    SkinName = 'rh',
    ClMsg = 'RH_SUB'
}, {
    SlotName = 'LH_SUB',
    SkinName = 'lh',
    ClMsg = 'LH_SUB'
}}

function GODDESS_ICOR_MANAGER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.settings = g.settings or {}

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        -- goddess_icor_manager_load_settings()

        goddess_icor_manager_frame_init()
        addon:RegisterMsg("GAME_START", "goddess_icor_manager_load_settings");
        addon:RegisterMsg('ESCAPE_PRESSED', 'goddess_icor_manager_list_close');
        return;
    end

end

function goddess_icor_manager_frame_init()
    local frame = ui.GetFrame("goddess_equip_manager")
    local randomoption_bg = GET_CHILD_RECURSIVELY(frame, "randomoption_bg")
    local listbtn = randomoption_bg:CreateOrGetControl("button", "listbtn", 520, 12, 160, 40)
    AUTO_CAST(listbtn)
    listbtn:SetText("{ol}list")
    listbtn:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_list_init")

    local invframe = ui.GetFrame('inventory')
    local inventoryGbox = invframe:GetChild("inventoryGbox")
    local icor_btn = invframe:CreateOrGetControl("button", "icor_btn", 420, 345, 30, 30)
    AUTO_CAST(icor_btn)
    icor_btn:SetText("{img sysmenu_skill 30 30}")
    icor_btn:SetSkinName("test_red_button")
    icor_btn:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_list_init")
    icor_btn:SetTextTooltip("{ol}Goddes Icor Manager Frame Open")
end

function goddess_icor_manager_list_init(frame, ctrl, argStr, argNum)

    local frame = ui.GetFrame("goddess_icor_manager")
    frame:Resize(1430, 1060) -- 1000
    frame:SetOffset(0, 10) -- 0,20
    frame:ShowWindow(1)
    frame:SetLayerLevel(121)
    frame:ShowTitleBar(0);
    frame:SetSkinName("test_frame_midle_light")
    frame:RemoveAllChild()
    goddess_icor_manager_newframe_init()
    if argNum == 2 then
        g.num = 2
        goddess_icor_manager_list_gb_init(frame, 2)

    else
        g.num = 1
        goddess_icor_manager_list_gb_init(frame, 1)
    end

end

function goddess_icor_manager_list_gb_init(frame, argNum)

    local acc = GetMyAccountObj()
    local etc = GetMyEtcObject()
    local remain_time = GET_REMAIN_SECOND_ENGRAVE_SLOT_EXTENSION_TIME(acc)

    local max_page = GET_MAX_ENGARVE_SLOT_COUNT(acc)
    local page_max = 0
    if tonumber(remain_time) == 0 then

        page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc) + 5
    else
        page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc)
    end

    if g.settings.check == nil then
        g.settings.check = 0
    end

    if g.settings.check == 0 then
        local Y = 10

        local left_btn = frame:CreateOrGetControl("button", "left_btn", 690, 1020, 30, 30)
        AUTO_CAST(left_btn)
        left_btn:SetText("{img white_left_arrow 18 18}")
        left_btn:SetSkinName("brown_3patch_btn")
        left_btn:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_list_init")
        left_btn:SetEventScriptArgNumber(ui.LBUTTONUP, 1)

        local right_btn = frame:CreateOrGetControl("button", "right_btn", 740, 1020, 30, 30)
        AUTO_CAST(right_btn)
        right_btn:SetText("{img white_right_arrow 18 18}")
        right_btn:SetSkinName("brown_3patch_btn")
        right_btn:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_list_init")
        right_btn:SetEventScriptArgNumber(ui.LBUTTONUP, 2)

        if argNum == 2 then

            for i = 6, page_max do
                local bg = frame:CreateOrGetControl("groupbox", "bg" .. i, Y, 10, 281, 1010) -- 490
                AUTO_CAST(bg)
                bg:RemoveAllChild()
                bg:SetEventScript(ui.RBUTTONUP, "goddess_icor_manager_list_close")
                bg:SetTextTooltip(goddess_icor_manager_language("Right click to close."))
                local pagename_text = bg:CreateOrGetControl("richtext", "pagename_text" .. i, 10, 5)
                AUTO_CAST(pagename_text)
                local pagename = goddess_icor_manager_get_pagename(i)
                Y = Y + 283

                if remain_time == 0 and tonumber(max_page) < i then
                    pagename_text:SetText("{ol}{#FF4500}" .. pagename .. goddess_icor_manager_language(" disabled"))
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
                    manage_bg:SetTextTooltip(goddess_icor_manager_language("Right click to close."))

                    local manage_text = manage_bg:CreateOrGetControl("richtext", "manage_text" .. j, 10, 0)
                    manage_text:SetText("{ol}" .. goddess_icor_manager_language(managed_list[j]))

                    manage_bg:SetSkinName("test_frame_midle_light");

                    manage_X = manage_X + 122
                    -- end
                    local parts1 = {}
                    local parts2 = {}
                    local parts3 = {}

                    local option_prop, group_prop, value_prop, is_goddess_option =
                        goddess_icor_manager_GET_ENGRAVED_OPTION_LIST(etc, i, managed_list[j])

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
                -- frame:Invalidate()
            end

        elseif argNum == 1 then

            for i = 1, 5 do
                local bg = frame:CreateOrGetControl("groupbox", "bg" .. i, Y, 10, 281, 1010) -- 490
                AUTO_CAST(bg)
                bg:RemoveAllChild()

                bg:SetEventScript(ui.RBUTTONUP, "goddess_icor_manager_list_close")
                bg:SetTextTooltip(goddess_icor_manager_language("Right click to close."))
                local pagename_text = bg:CreateOrGetControl("richtext", "pagename_text" .. i, 10, 5)
                AUTO_CAST(pagename_text)

                local pagename = goddess_icor_manager_get_pagename(i)

                Y = Y + 283

                if remain_time == 0 and tonumber(max_page) < i then
                    pagename_text:SetText("{ol}{#FF4500}" .. pagename .. goddess_icor_manager_language(" disabled"))
                else
                    pagename_text:SetText("{ol}{#FFFF00}" .. pagename)
                end

                bg:SetSkinName("bg")
                bg:ShowWindow(1)

                local manage_X = 0
                for j = 1, #managed_list do
                    local manage_bg = bg:CreateOrGetControl("groupbox", "manage_bg" .. j, 0, 30 + manage_X, 258, 120)
                    manage_bg:SetEventScript(ui.RBUTTONUP, "goddess_icor_manager_list_close")
                    manage_bg:SetTextTooltip(goddess_icor_manager_language("Right click to close."))
                    local manage_text = manage_bg:CreateOrGetControl("richtext", "manage_text" .. j, 10, 0)

                    manage_text:SetText("{ol}" .. goddess_icor_manager_language(managed_list[j]))
                    -- manage_bg:SetSkinName("chat_window_2");
                    -- manage_bg:SetSkinName("digitnotice_bg");
                    manage_bg:SetSkinName("test_frame_midle_light");
                    manage_X = manage_X + 122
                    -- end
                    local parts1 = {}
                    local parts2 = {}
                    local parts3 = {}

                    local option_prop, group_prop, value_prop, is_goddess_option =
                        goddess_icor_manager_GET_ENGRAVED_OPTION_LIST(etc, i, managed_list[j])
                    -- print(tostring(option_prop))
                    -- print(tostring(group_prop))
                    -- print(tostring(value_prop))
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
        goddess_icor_manager_check()
    end

    if g.settings.check == 1 then

        local Y = 10
        local YY = 10

        for i = 1, page_max do
            if i <= 5 then

                local bg = frame:CreateOrGetControl("groupbox", "bg" .. i, Y, 10, 281, 490)
                AUTO_CAST(bg)
                -- bg:SetOffset(0, 10)
                bg:SetEventScript(ui.RBUTTONUP, "goddess_icor_manager_list_close")
                bg:SetTextTooltip(goddess_icor_manager_language("Right click to close."))

                local pagename_text = bg:CreateOrGetControl("richtext", "pagename_text" .. i, 10, 5)
                AUTO_CAST(pagename_text)
                local pagename = goddess_icor_manager_get_pagename(i)
                Y = Y + 283

                if remain_time == 0 and tonumber(max_page) < i then
                    pagename_text:SetText("{ol}{#FF4500}" .. pagename .. goddess_icor_manager_language(" disabled"))
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
                    manage_bg:SetTextTooltip(goddess_icor_manager_language("Right click to close."))
                    local manage_text = manage_bg:CreateOrGetControl("richtext", "manage_text" .. j, 10, 0)

                    manage_text:SetText("{ol}" .. goddess_icor_manager_language(managed_list[j]))
                    -- manage_bg:SetSkinName("chat_window_2");
                    -- manage_bg:SetSkinName("digitnotice_bg");
                    manage_bg:SetSkinName("test_frame_midle_light");
                    manage_X = manage_X + 122
                    -- end
                    local parts1 = {}
                    local parts2 = {}
                    local parts3 = {}

                    local option_prop, group_prop, value_prop, is_goddess_option =
                        goddess_icor_manager_GET_ENGRAVED_OPTION_LIST(etc, i, managed_list[j])

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

            elseif i >= 6 then
                local bg = frame:CreateOrGetControl("groupbox", "bg" .. i, YY, 500, 281, 490)
                AUTO_CAST(bg)
                bg:SetEventScript(ui.RBUTTONUP, "goddess_icor_manager_list_close")
                bg:SetTextTooltip(goddess_icor_manager_language("Right click to close."))
                if remain_time == 0 and max_page < i then

                end
                YY = YY + 283
                local pagename_text = bg:CreateOrGetControl("richtext", "pagename_text" .. i, 10, 5)
                AUTO_CAST(pagename_text)
                local pagename = goddess_icor_manager_get_pagename(i)

                if remain_time == 0 and tonumber(max_page) < i then
                    pagename_text:SetText("{ol}{#FF4500}" .. pagename .. goddess_icor_manager_language(" disabled"))
                else
                    pagename_text:SetText("{ol}{#FFFF00}" .. pagename)
                end
                bg:SetSkinName("bg")
                bg:ShowWindow(1)

                local manage_X = 0
                for j = 1, #managed_list do
                    local manage_bg = bg:CreateOrGetControl("groupbox", "manage_bg" .. j, 0, 30 + manage_X, 258, 120)
                    manage_bg:SetEventScript(ui.RBUTTONUP, "goddess_icor_manager_list_close")
                    manage_bg:SetTextTooltip(goddess_icor_manager_language("Right click to close."))

                    local manage_text = manage_bg:CreateOrGetControl("richtext", "manage_text" .. j, 10, 0)
                    manage_text:SetText("{ol}" .. goddess_icor_manager_language(managed_list[j]))

                    manage_bg:SetSkinName("test_frame_midle_light");

                    manage_X = manage_X + 122
                    -- end
                    local parts1 = {}
                    local parts2 = {}
                    local parts3 = {}

                    local option_prop, group_prop, value_prop, is_goddess_option =
                        goddess_icor_manager_GET_ENGRAVED_OPTION_LIST(etc, i, managed_list[j])

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
        goddess_icor_manager_check()
        frame:Resize(1430, 1000)
        goddess_icor_manager_set_pos(frame, page_max)
    end
    frame:ShowWindow(1)
    frame:Invalidate()
end

function goddess_icor_manager_equip_button(frame, ctrl, argStr, argNum)

    local frame = ui.GetFrame('goddess_equip_manager')
    frame:ShowWindow(1)

    GODDESS_MGR_RANDOMOPTION_APPLY_OPEN(frame)
    session.ResetItemList()

    local arg_list = NewStringList()

    local apply_cnt = 0
    for i = 1, #managed_slot_list do
        local slot_info = managed_slot_list[i]
        local ctrlset = GET_CHILD_RECURSIVELY(frame, 'rand_slot_' .. slot_info.SlotName)
        local tgt_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_info.SlotName))
        local checkbox = GET_CHILD(ctrlset, 'checkbox')
        if tonumber(argStr) == 1 and i == 1 then
            checkbox:SetCheck(1);
        elseif tonumber(argStr) == 2 and i == 2 then
            checkbox:SetCheck(1);
        elseif tonumber(argStr) == 3 and i == 3 then
            checkbox:SetCheck(1);
        elseif tonumber(argStr) == 4 and i == 4 then
            checkbox:SetCheck(1);
        elseif tonumber(argStr) == 5 and i == 5 then
            checkbox:SetCheck(1);
        elseif tonumber(argStr) == 6 and i == 6 then
            checkbox:SetCheck(1);
        elseif tonumber(argStr) == 7 and i == 7 then
            checkbox:SetCheck(1);
        elseif tonumber(argStr) == 8 and i == 8 then
            checkbox:SetCheck(1);
        end
        if tgt_item ~= nil and checkbox:IsChecked() == 1 then
            if tgt_item.isLockState == true then
                ui.SysMsg(ClMsg('MaterialItemIsLock'))
                return
            end
            local slot = GET_CHILD(ctrlset, 'slot')
            AUTO_CAST(slot)

            local guid = slot:GetUserValue('ITEM_GUID')

            if guid ~= 'None' then
                session.AddItemID(guid, 1)
                arg_list:Add(slot_info.SlotName)
                apply_cnt = apply_cnt + 1
            end
        end
    end

    if apply_cnt == 0 then
        ui.SysMsg(ClMsg('NoSelectedItem'))
        return
    end

    local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')

    local index = argNum

    arg_list:Add(index)

    local result_list = session.GetItemIDList()
    item.DialogTransaction('ICOR_PRESET_ENGRAVE_APPLY', result_list, '', arg_list)

    local acc = GetMyAccountObj()
    local page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc) + 5

    if g.settings.check == 1 then
        for i = 1, page_max do
            local bg = GET_CHILD_RECURSIVELY(frame, "bg" .. i)
            AUTO_CAST(bg)
            local curpos = bg:GetScrollCurPos();
            if curpos == 514 then
                curpos = 0
            end
            g.settings[tostring(i)] = curpos
            goddess_icor_manager_save_settings()

        end
    end

    local argNum = g.num
    ReserveScript(string.format("goddess_icor_manager_list_init('%s','%s','%s',%d)", frame, "", "", argNum), 0.5)

end

function goddess_icor_manager_set_pos(frame, page_max)

    for i = 1, page_max do

        local bg = GET_CHILD_RECURSIVELY(frame, "bg" .. i)
        AUTO_CAST(bg)

        local pos = tonumber(g.settings[tostring(i)])

        bg:SetScrollPos(0);
        if pos ~= 0 then
            bg:EnableScrollBar(1);
            bg:EnableDrawFrame(1);
            bg:SetScrollPos(pos);
        end

    end

end
function goddess_icor_manager_check()

    local frame = ui.GetFrame("goddess_icor_manager")
    local equipframe = ui.GetFrame("goddess_icor_manager_newframe")
    local acc = GetMyAccountObj()

    local remain_time = GET_REMAIN_SECOND_ENGRAVE_SLOT_EXTENSION_TIME(acc)

    local page_max = 0
    if tonumber(remain_time) ~= 0 then

        page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc) + 5
    else
        page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc)

    end

    if g.settings.check ~= 0 then
        for i = 1, page_max do
            local pagename_text = GET_CHILD_RECURSIVELY(frame, "pagename_text" .. i)

            local bg = GET_CHILD_RECURSIVELY(frame, "bg" .. i)
            for j = 1, 8 do
                local new_bg = GET_CHILD_RECURSIVELY(equipframe, "new_bg" .. j)

                local equip_textcount = new_bg:GetChildCount() - 2

                local equip_text = ""
                for k = 1, equip_textcount do
                    local text = GET_CHILD_RECURSIVELY(new_bg, "text" .. k):GetText()
                    equip_text = equip_text .. text
                end
                equip_text = equip_text:gsub("{[^}]+}", "")

                local icor_text = ""
                local manage_bg = GET_CHILD_RECURSIVELY(bg, "manage_bg" .. j)
                if manage_bg ~= nil then
                    local bg_textcount = manage_bg:GetChildCount() - 2

                    for k = 1, bg_textcount do
                        local text = GET_CHILD_RECURSIVELY(manage_bg, "option" .. k):GetText()
                        icor_text = icor_text .. text

                    end
                    icor_text = icor_text:gsub("{[^}]+}", "")

                    if tostring(equip_text) == tostring(icor_text) and equip_text ~= "" then
                        local star = manage_bg:CreateOrGetControl("richtext", "star" .. j, 25, 25)
                        -- local manage_text = GET_CHILD_RECURSIVELY(manage_bg, "manage_text" .. j)
                        star:SetText("{img monster_card_starmark 25 25}")
                        star:SetOffset(230, 0)
                    elseif tostring(equip_text) ~= tostring(icor_text) and icor_text ~= "" then
                        local equip_button = manage_bg:CreateOrGetControl("button", "equip_button", 225, 0, 30, 25)
                        AUTO_CAST(equip_button)
                        equip_button:SetText("{ol}{s14}E")
                        equip_button:SetSkinName("test_red_button")
                        equip_button:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_equip_button")
                        equip_button:SetEventScriptArgNumber(ui.LBUTTONUP, i); -- sets the 4th parameter (numarg)
                        equip_button:SetEventScriptArgString(ui.LBUTTONUP, j);
                        equip_button:SetTextTooltip(goddess_icor_manager_language(
                            "Equip the icor with a left click of the button."))
                    end
                end
            end
        end
    else
        local pagename_text1 = GET_CHILD_RECURSIVELY(frame, "pagename_text1")

        if pagename_text1 ~= nil then
            local page = math.min(5, page_max)
            for i = 1, page do
                local pagename_text = GET_CHILD_RECURSIVELY(frame, "pagename_text" .. i)

                local bg = GET_CHILD_RECURSIVELY(frame, "bg" .. i)
                for j = 1, 8 do
                    local new_bg = GET_CHILD_RECURSIVELY(equipframe, "new_bg" .. j)

                    local equip_textcount = new_bg:GetChildCount() - 2

                    local equip_text = ""
                    for k = 1, equip_textcount do
                        local text = GET_CHILD_RECURSIVELY(new_bg, "text" .. k):GetText()
                        equip_text = equip_text .. text
                    end
                    equip_text = equip_text:gsub("{[^}]+}", "")

                    local icor_text = ""
                    local manage_bg = GET_CHILD_RECURSIVELY(bg, "manage_bg" .. j)
                    if manage_bg ~= nil then
                        local bg_textcount = manage_bg:GetChildCount() - 2

                        for k = 1, bg_textcount do
                            local text = GET_CHILD_RECURSIVELY(manage_bg, "option" .. k):GetText()
                            icor_text = icor_text .. text

                        end
                        icor_text = icor_text:gsub("{[^}]+}", "")

                        if tostring(equip_text) == tostring(icor_text) and equip_text ~= "" then
                            local star = manage_bg:CreateOrGetControl("richtext", "star" .. j, 25, 25)
                            -- local manage_text = GET_CHILD_RECURSIVELY(manage_bg, "manage_text" .. j)
                            star:SetText("{img monster_card_starmark 25 25}")
                            star:SetOffset(230, 0)
                        elseif tostring(equip_text) ~= tostring(icor_text) and icor_text ~= "" then

                            local equip_button = manage_bg:CreateOrGetControl("button", "equip_button", 225, 0, 30, 25)
                            AUTO_CAST(equip_button)
                            equip_button:SetText("{ol}{s14}E")
                            equip_button:SetSkinName("test_red_button")
                            equip_button:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_equip_button")
                            equip_button:SetEventScriptArgNumber(ui.LBUTTONUP, i); -- sets the 4th parameter (numarg)
                            equip_button:SetEventScriptArgString(ui.LBUTTONUP, j);
                            equip_button:SetTextTooltip(goddess_icor_manager_language(
                                "Equip the icor with a left click of the button."))

                        end
                    end
                end

            end
        else
            for i = 6, page_max do
                local pagename_text = GET_CHILD_RECURSIVELY(frame, "pagename_text" .. i)

                local bg = GET_CHILD_RECURSIVELY(frame, "bg" .. i)
                for j = 1, 8 do
                    local new_bg = GET_CHILD_RECURSIVELY(equipframe, "new_bg" .. j)

                    local equip_textcount = new_bg:GetChildCount() - 2

                    local equip_text = ""
                    for k = 1, equip_textcount do
                        local text = GET_CHILD_RECURSIVELY(new_bg, "text" .. k):GetText()
                        equip_text = equip_text .. text
                    end
                    equip_text = equip_text:gsub("{[^}]+}", "")

                    local icor_text = ""
                    local manage_bg = GET_CHILD_RECURSIVELY(bg, "manage_bg" .. j)
                    if manage_bg ~= nil then
                        local bg_textcount = manage_bg:GetChildCount() - 2

                        for k = 1, bg_textcount do
                            local text = GET_CHILD_RECURSIVELY(manage_bg, "option" .. k):GetText()
                            icor_text = icor_text .. text

                        end
                        icor_text = icor_text:gsub("{[^}]+}", "")

                        if tostring(equip_text) == tostring(icor_text) and equip_text ~= "" then
                            local star = manage_bg:CreateOrGetControl("richtext", "star" .. j, 25, 25)
                            -- local manage_text = GET_CHILD_RECURSIVELY(manage_bg, "manage_text" .. j)
                            star:SetText("{img monster_card_starmark 25 25}")
                            star:SetOffset(230, 0)
                        elseif tostring(equip_text) ~= tostring(icor_text) and icor_text ~= "" then
                            local equip_button = manage_bg:CreateOrGetControl("button", "equip_button", 225, 0, 30, 25)
                            AUTO_CAST(equip_button)
                            equip_button:SetText("{ol}{s14}E")
                            equip_button:SetSkinName("test_red_button")
                            equip_button:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_equip_button")
                            equip_button:SetEventScriptArgNumber(ui.LBUTTONUP, i); -- sets the 4th parameter (numarg)
                            equip_button:SetEventScriptArgString(ui.LBUTTONUP, j);
                            equip_button:SetTextTooltip(goddess_icor_manager_language(
                                "Equip the icor with a left click of the button."))
                        end
                    end
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

        local colortone = goddess_icor_manager_set_frame_color(manage_bg, parts1, parts2, parts3, manage_text)

        manage_bg:SetColorTone(colortone)

    end

end

function goddess_icor_manager_set_frame_color(manage_bg, parts1, parts2, parts3, manage_text)
    local frameName = manage_bg:GetName()

    if frameName == "manage_bg1" or frameName == "manage_bg2" or frameName == "manage_bg7" or frameName == "manage_bg8" then
        for i = 1, #high500weapontbl do
            local key = high500weapontbl[i]
            local keyName = next(key)
            local value = key[next(key)] -- 次のキー（最初のキー）の値を取得
            for j = 1, #parts1 do

                if tostring(parts1[j]) == tostring(keyName) and tonumber(parts3[j]) >= tonumber(value) then
                    -- local manage_text = GET_CHILD_RECURSIVELY(manage_bg, "manage_text" .. j)

                    --[[local text = manage_text:GetText()
                    if string.find(text, goddess_icor_manager_language(" 500Advanced")) == nil then
                        manage_text:SetText(text .. "{ol}" .. goddess_icor_manager_language(" 500Advanced"))

                    end]]
                    return "FFFFD700"
                end
            end
        end
        for i = 1, #low500weapontbl do
            local key = low500weapontbl[i]
            local keyName = next(key)
            local value = key[next(key)] -- 次のキー（最初のキー）の値を取得
            for j = 1, #parts1 do
                if tostring(parts1[j]) == tostring(keyName) and tonumber(parts3[j]) >= tonumber(value) then
                    --[[ local text = manage_text:GetText()
                    if string.find(text, " LV500") == nil then
                        manage_text:SetText(text .. "{ol} LV500")
                    end]]
                    return "FFDAA520"
                end
            end
        end
        for i = 1, #high480weapontbl do
            local key = high480weapontbl[i]
            local keyName = next(key)
            local value = key[next(key)] -- 次のキー（最初のキー）の値を取得
            for j = 1, #parts1 do

                if tostring(parts1[j]) == tostring(keyName) and tonumber(parts3[j]) >= tonumber(value) then
                    --[[local text = manage_text:GetText()
                    if string.find(text, goddess_icor_manager_language(" 480Advanced")) == nil then
                        manage_text:SetText(text .. "{ol}" .. goddess_icor_manager_language(" 480Advanced"))

                    end]]
                    return "FF808080"
                end
            end
        end
        for i = 1, #low480weapontbl do
            local key = low480weapontbl[i]
            local keyName = next(key)
            local value = key[next(key)] -- 次のキー（最初のキー）の値を取得
            for j = 1, #parts1 do

                if tostring(parts1[j]) == tostring(keyName) and tonumber(parts3[j]) >= tonumber(value) then
                    --[[local text = manage_text:GetText()
                    if string.find(text, " LV480") == nil then
                        manage_text:SetText(text .. "{ol} LV480")
                    end]]
                    return "FF808080"
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
                    --[[local text = manage_text:GetText()
                    if string.find(text, goddess_icor_manager_language(" 500Advanced")) == nil then
                        manage_text:SetText(text .. "{ol}" .. goddess_icor_manager_language(" 500Advanced"))

                    end]]
                    return "FFFFD700"
                end
            end
        end
        for i = 1, #low500armortbl do
            local key = low500armortbl[i]
            local keyName = next(key)
            local value = key[next(key)] -- 次のキー（最初のキー）の値を取得
            for j = 1, #parts1 do
                if tostring(parts1[j]) == tostring(keyName) and tonumber(parts3[j]) >= tonumber(value) then
                    --[[ local text = manage_text:GetText()
                    if string.find(text, " LV500") == nil then
                        manage_text:SetText(text .. "{ol} LV500")
                    end]]
                    return "FFDAA520"
                    -- return "AAC0C0C0"
                end
            end
        end
        for i = 1, #high480armortbl do
            local key = high480armortbl[i]
            local keyName = next(key)
            local value = key[next(key)] -- 次のキー（最初のキー）の値を取得
            for j = 1, #parts1 do

                if tostring(parts1[j]) == tostring(keyName) and tonumber(parts3[j]) >= tonumber(value) then
                    --[[local text = manage_text:GetText()
                    if string.find(text, goddess_icor_manager_language(" 480Advanced")) == nil then
                        manage_text:SetText(text .. "{ol}" .. goddess_icor_manager_language(" 480Advanced"))

                    end]]
                    return "FF808080"
                end
            end
        end
        for i = 1, #low480armortbl do
            local key = low480armortbl[i]
            local keyName = next(key)
            local value = key[next(key)] -- 次のキー（最初のキー）の値を取得
            for j = 1, #parts1 do

                if tostring(parts1[j]) == tostring(keyName) and tonumber(parts3[j]) >= tonumber(value) then
                    --[[local text = manage_text:GetText()
                    if string.find(text, " LV480") == nil then
                        manage_text:SetText(text .. "{ol} LV480")
                    end]]
                    return "FF808080"
                end
            end
        end
    end
    return "FF000000"
end

function goddess_icor_manager_check_save(frame, ctrl, argStr, argNum)
    local ischeck = ctrl:IsChecked()
    g.settings.check = ischeck
    goddess_icor_manager_save_settings()
    local frame = ui.GetFrame("goddess_icor_manager")

    ReserveScript(string.format("goddess_icor_manager_list_init('%s','%s','%s',%d)", frame, "", "", 1), 0.5)

end

function goddess_icor_manager_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not settings then

        settings = {
            check = 0
        }
    end
    g.settings = settings
    goddess_icor_manager_save_settings()
end

function goddess_icor_manager_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function goddess_icor_manager_newframe_init()

    local newframe = ui.CreateNewFrame("notice_on_pc", "goddess_icor_manager_newframe", 0, 0, 0, 0)
    AUTO_CAST(newframe)
    newframe:SetOffset(1420, 5)
    newframe:Resize(500, 1070)
    -- newframe:SetSkinName('bg')
    newframe:SetSkinName('test_frame_midle_light')
    -- newframe:SetSkinName('None')
    newframe:SetLayerLevel(121)
    newframe:RemoveAllChild();

    local change_check = newframe:CreateOrGetControl('checkbox', 'change_check', 60, 20, 30, 30)
    AUTO_CAST(change_check)
    change_check:SetTextTooltip(goddess_icor_manager_language("Check the box to switch to batch display."))
    change_check:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_check_save")
    change_check:SetCheck(g.settings.check)

    local change_text = newframe:CreateOrGetControl("richtext", 'change_text', 90, 30, 0, 40)
    AUTO_CAST(change_text)
    change_text:SetText(goddess_icor_manager_language("{ol}Check box to switch display number"))
    change_text:AdjustFontSizeByWidth(350)
    --[[local close_bg = newframe:CreateOrGetControl("groupbox", "close_bg", 290, 10, 200, 60)
    AUTO_CAST(close_bg)
    -- close_bg:SetSkinName("test_frame_midle_light");
    close_bg:SetSkinName("None");
    -- close_bg:RemoveAllChild();]]

    local closebtn = newframe:CreateOrGetControl("button", "closebtn", 445, 10, 40, 45)
    closebtn:SetText("{img testclose_button 40 40}")
    AUTO_CAST(closebtn)
    closebtn:SetSkinName("None")
    closebtn:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_list_close")
    closebtn:SetTextTooltip("Frame Close.")

    local swapbtn = newframe:CreateOrGetControl("button", "swapbtn", 10, 10, 40, 45)
    swapbtn:SetText("{img sysmenu_skill 40 40}")
    AUTO_CAST(swapbtn)
    swapbtn:SetSkinName("test_pvp_btn")
    swapbtn:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_swap_weapon")
    swapbtn:SetTextTooltip(goddess_icor_manager_language("Swap the reverse side of the weapon."))

    local x = 50
    local xx = 50
    -- local new_bg1
    for i = 1, #managed_list do
        if i <= 2 or i >= 7 then
            local new_bg = newframe:CreateOrGetControl("groupbox", "new_bg" .. i, 5, x + 10, 240, 130)
            AUTO_CAST(new_bg)
            new_bg:SetSkinName("test_frame_midle_light");
            new_bg:RemoveAllChild();
            new_bg:SetEventScript(ui.RBUTTONUP, "goddess_icor_manager_list_close")
            new_bg:SetTextTooltip(goddess_icor_manager_language("Right click to close."))
            x = x + 131

        elseif i <= 6 or i >= 3 then
            local new_bg = newframe:CreateOrGetControl("groupbox", "new_bg" .. i, 250, xx + 10, 240, 130)
            AUTO_CAST(new_bg)
            new_bg:SetSkinName("test_frame_midle_light");
            new_bg:RemoveAllChild();
            new_bg:SetEventScript(ui.RBUTTONUP, "goddess_icor_manager_list_close")
            new_bg:SetTextTooltip(goddess_icor_manager_language("Right click to close."))
            xx = xx + 131
        end
    end

    newframe:ShowWindow(1)

    for i = 1, #managed_list do

        local slot_info = managed_list[i]
        local new_bg = GET_CHILD_RECURSIVELY(newframe, "new_bg" .. i)
        local slot = new_bg:CreateOrGetControl("richtext", "slot" .. i, 5, 5)
        AUTO_CAST(slot)
        -- slot:SetText("")
        slot:SetText("{ol}" .. goddess_icor_manager_language(slot_info))

        local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_info))
        local item_obj = GetIES(inv_item:GetObject())
        local item_dic = GET_ITEM_RANDOMOPTION_DIC(item_obj)
        local size = item_dic["Size"]

        local jx = 25
        if size ~= 0 then
            for j = 1, size do

                local key = "RandomOption_" .. j
                local value_key = "RandomOptionValue_" .. j
                local group_key = "RandomOptionGroup_" .. j
                local bg = GET_CHILD_RECURSIVELY(newframe, "new_bg" .. i)
                local text = bg:CreateOrGetControl("richtext", "text" .. j, 5, jx)
                AUTO_CAST(text)
                -- text:SetText("")
                local option = item_dic[key]
                local value = item_dic[value_key]
                local group = item_dic[group_key]
                -- manage_text:SetText("{ol}" .. goddess_icor_manager_language(managed_list[j]))
                local color = goddess_icor_manager_color(tostring(group))
                -- option:SetText("{ol}" .. color .. goddess_icor_manager_language(parts1[k]) .. "{ol}{#FFFFFF} : " ..
                --                   "{ol}{#FFFFFF}" .. parts3[k])

                text:SetText("{ol}" .. color .. goddess_icor_manager_language(option) .. "{#FFFFFF} : " .. value) -- aa
                -- text:SetEventScript(ui.RBUTTONUP, "goddess_icor_manager_list_close")
                -- text:SetTextTooltip(goddess_icor_manager_language(option) .. " : " .. value)
                jx = jx + 20

            end
            local bg = GET_CHILD_RECURSIVELY(newframe, "new_bg" .. i)
            local colortone = goddess_icor_manager_set_frame_color_equip(bg, size, item_dic, slot)
            bg:SetColorTone(colortone)
        end

    end

    local status_bg = newframe:CreateOrGetControl("groupbox", "status_bg", 5, 590, 490, 470)
    AUTO_CAST(status_bg)
    -- close_bg:SetSkinName("test_frame_midle_light");
    status_bg:SetSkinName("bg");

    local status_table = {"Cloth_Atk", "Leather_Atk", "Iron_Atk", "Ghost_Atk", "MiddleSize_Def", "Cloth_Def",
                          "Leather_Def", "Iron_Def", "Forester_Atk", "Widling_Atk", "Klaida_Atk", "Paramune_Atk",
                          "Velnias_Atk", "perfection", "revenge"}
    local stframe = ui.GetFrame("status")
    if stframe:IsVisible() == 0 then
        ui.OpenFrame("status")
    end
    for i = 1, #status_table do
        local status_str = status_table[i]

        goddess_icor_manager_newframe_set_status(status_bg, stframe, status_str, i)
    end
end

function goddess_icor_manager_newframe_set_status(status_bg, stframe, status_str, index)

    local child_frame = GET_CHILD_RECURSIVELY(stframe, status_str)

    local language = option.GetCurrentCountry()

    local level = info.GetLevel(session.GetMyHandle());
    local setting_num = level * 30
    local setting_num2 = level * 15
    -- print(tostring(level))

    if language == "Japanese" then
        local child_title = GET_CHILD(child_frame, "title", "ui::CRichText"):GetText()

        local titletext = status_bg:CreateOrGetControl("richtext", "titletext" .. index, 10, index * 30 - 20)
        titletext:SetText("{ol}" .. child_title)

        local child_stat = GET_CHILD(child_frame, "stat", "ui::CRichText"):GetText()

        local stattext = status_bg:CreateOrGetControl("richtext", "stattext" .. index, 240, index * 30 - 20)

        if index <= 4 or (index >= 9 and index <= 13) then

            stattext:SetText("{ol}" .. child_stat .. " {#FFFFFF}(" .. setting_num .. ")")
        elseif index >= 5 and index <= 8 then
            stattext:SetText("{ol}" .. child_stat .. " {#FFFFFF}(" .. setting_num2 .. ")")

        elseif index >= 14 then
            stattext:SetText("{ol}" .. child_stat)

        end
    else
        local child_title = GET_CHILD(child_frame, "title", "ui::CRichText"):GetText()

        local titletext = status_bg:CreateOrGetControl("richtext", "titletext" .. index, 10, index * 45 - 30)
        titletext:SetText("{ol}" .. child_title)

        local child_stat = GET_CHILD(child_frame, "stat", "ui::CRichText"):GetText()

        local stattext = status_bg:CreateOrGetControl("richtext", "stattext" .. index, 200, index * 45 - 10)

        local line = status_bg:CreateOrGetControl("labelline", "line" .. index, 10, index * 45 + 7, 455, 5)

        if index <= 4 or (index >= 9 and index <= 13) then

            stattext:SetText("{ol}" .. child_stat .. " {#FFFFFF}(" .. setting_num .. ")")
        elseif index >= 5 and index <= 8 then

            stattext:SetText("{ol}" .. child_stat .. " {#FFFFFF}(" .. setting_num2 .. ")")

        elseif index >= 14 then
            stattext:SetText("{ol}" .. child_stat)

        end
    end
end

function goddess_icor_manager_swap_weapon()
    local icorframe = ui.GetFrame("goddess_icor_manager")
    icorframe:RemoveAllChild()
    local icornewframe = ui.GetFrame("goddess_icor_manager_newframe")
    icornewframe:RemoveAllChild()
    ui.CloseFrame("goddess_icor_manager")
    ui.CloseFrame("goddess_icor_manager_newframe")

    local frame = ui.GetFrame("inventory")
    local equipItemList = session.GetEquipItemList();
    local RH = GET_CHILD_RECURSIVELY(frame, "RH")
    local LH = GET_CHILD_RECURSIVELY(frame, "LH")
    local RH_SUB = GET_CHILD_RECURSIVELY(frame, "RH_SUB")
    local LH_SUB = GET_CHILD_RECURSIVELY(frame, "LH_SUB")

    local lh_sub_icon = LH_SUB:GetIcon()
    local lh_sub_icon_info = lh_sub_icon:GetInfo()
    g.lh_sub_guid = lh_sub_icon_info:GetIESID()

    local rh_sub_icon = RH_SUB:GetIcon()
    local rh_sub_icon_info = rh_sub_icon:GetInfo()
    g.rh_sub_guid = rh_sub_icon_info:GetIESID()

    local rh_icon = RH:GetIcon()
    local rh_icon_info = rh_icon:GetInfo()
    g.rh_guid = rh_icon_info:GetIESID()

    local lh_icon = LH:GetIcon()
    local lh_icon_info = lh_icon:GetInfo()
    g.lh_guid = lh_icon_info:GetIESID()

    if lh_sub_icon ~= nil and rh_sub_icon ~= nil then
        local lh_sub = 31

        goddess_icor_manager_unequip(frame, lh_sub)
        DO_WEAPON_SLOT_CHANGE(frame, 1)
        ReserveScript("goddess_icor_manager_equip()", 0.5)
    end

end

function goddess_icor_manager_equip()

    local frame = ui.GetFrame("inventory")
    if g.rh_sub_guid ~= nil then
        local invitem = session.GetInvItemByGuid(g.rh_sub_guid);
        local spotname = "RH"
        ITEM_EQUIP(invitem.invIndex, spotname)
        frame:Invalidate();
        g.rh_sub_guid = nil
        ReserveScript("goddess_icor_manager_equip()", 0.6)
        return
    elseif g.lh_sub_guid ~= nil then

        local invitem = session.GetInvItemByGuid(g.lh_sub_guid);
        local spotname = "LH"
        ITEM_EQUIP(invitem.invIndex, spotname)
        frame:Invalidate();
        g.lh_sub_guid = nil
        ReserveScript("goddess_icor_manager_equip()", 0.6)
        return

    elseif g.rh_guid ~= nil then
        DO_WEAPON_SLOT_CHANGE(frame, 2)
        local invitem = session.GetInvItemByGuid(g.rh_guid);
        local spotname = "RH_SUB"
        ITEM_EQUIP(invitem.invIndex, spotname)
        frame:Invalidate();
        g.rh_guid = nil
        ReserveScript("goddess_icor_manager_equip()", 0.6)
        return

    elseif g.lh_guid ~= nil then
        DO_WEAPON_SLOT_CHANGE(frame, 2)
        local invitem = session.GetInvItemByGuid(g.lh_guid);
        local spotname = "LH_SUB"
        ITEM_EQUIP(invitem.invIndex, spotname)
        frame:Invalidate();
        g.lh_guid = nil
        ReserveScript("goddess_icor_manager_equip()", 0.6)
        return

    else
        local gimframe = ui.GetFrame("goddess_icor_manager")
        ReserveScript(string.format("goddess_icor_manager_list_init('%s','%s','%s',%d)", gimframe, "", "", 1), 0.5)
        return
    end

end

function goddess_icor_manager_unequip(frame, num)

    local invTab = GET_CHILD_RECURSIVELY(frame, "inventype_Tab")
    invTab:SelectTab(1)
    if true == BEING_TRADING_STATE() then
        return;
    end

    local isEmptySlot = false;
    if session.GetInvItemList():Count() < MAX_INV_COUNT then
        isEmptySlot = true;
    end
    if isEmptySlot == true then

        imcSound.PlaySoundEvent('inven_unequip');
        item.UnEquip(tonumber(num));

        ReserveScript("goddess_icor_manager_swap_weapon()", 0.5)
        return
    end

end

function goddess_icor_manager_set_frame_color_equip(bg, size, item_dic, slot)
    local frameName = bg:GetName()

    if frameName == "new_bg1" or frameName == "new_bg2" or frameName == "new_bg7" or frameName == "new_bg8" then
        for i = 1, #high500weapontbl do
            local tblkey = high500weapontbl[i]
            local keyname = next(tblkey)
            local tblvalue = tblkey[next(tblkey)]
            for j = 1, size do
                local key = "RandomOption_" .. j
                local value_key = "RandomOptionValue_" .. j
                local option = item_dic[key]
                local value = item_dic[value_key]
                if tostring(option) == tostring(keyname) and tonumber(value) >= tonumber(tblvalue) then
                    local text = slot:GetText()

                    --[[if string.find(text, goddess_icor_manager_language(" 500Advanced")) == nil then

                        slot:SetText(text .. "{ol}" .. goddess_icor_manager_language(" 500Advanced"))
                    end]]
                    return "FFFFD700"
                end
            end
        end

        for i = 1, #low500weapontbl do
            local tblkey = low500weapontbl[i]
            local keyname = next(tblkey)
            local tblvalue = tblkey[next(tblkey)]
            for j = 1, size do
                local key = "RandomOption_" .. j
                local value_key = "RandomOptionValue_" .. j
                local option = item_dic[key]
                local value = item_dic[value_key]
                if tostring(option) == tostring(keyname) and tonumber(value) >= tonumber(tblvalue) then
                    --[[local text = slot:GetText()

                    if string.find(text, " LV500") == nil then

                        slot:SetText(text .. "{ol} LV500")
                    end]]
                    return "FFDAA520"
                end
            end
        end

        for i = 1, #high480weapontbl do
            local tblkey = high480weapontbl[i]
            local keyname = next(tblkey)
            local tblvalue = tblkey[next(tblkey)]
            for j = 1, size do
                local key = "RandomOption_" .. j
                local value_key = "RandomOptionValue_" .. j
                local option = item_dic[key]
                local value = item_dic[value_key]
                if tostring(option) == tostring(keyname) and tonumber(value) >= tonumber(tblvalue) then
                    --[[local text = slot:GetText()

                    if string.find(text, goddess_icor_manager_language(" 480Advanced")) == nil then

                        slot:SetText(text .. "{ol}" .. goddess_icor_manager_language(" 480Advanced"))
                    end]]
                    return "FF808080"
                end
            end
        end

        for i = 1, #low480weapontbl do
            local tblkey = low480weapontbl[i]
            local keyname = next(tblkey)
            local tblvalue = tblkey[next(tblkey)]
            for j = 1, size do
                local key = "RandomOption_" .. j
                local value_key = "RandomOptionValue_" .. j
                local option = item_dic[key]
                local value = item_dic[value_key]
                if tostring(option) == tostring(keyname) and tonumber(value) >= tonumber(tblvalue) then
                    --[[local text = slot:GetText()

                    if string.find(text, " LV480") == nil then

                        slot:SetText(text .. "{ol} LV480")
                    end]]
                    return "FF808080"
                end
            end
        end

    else
        for i = 1, #high500armortbl do
            local tblkey = high500armortbl[i]
            local keyname = next(tblkey)
            local tblvalue = tblkey[next(tblkey)]
            for j = 1, size do
                local key = "RandomOption_" .. j
                local value_key = "RandomOptionValue_" .. j
                local option = item_dic[key]
                local value = item_dic[value_key]
                if tostring(option) == tostring(keyname) and tonumber(value) >= tonumber(tblvalue) then
                    --[[local text = slot:GetText()

                    if string.find(text, goddess_icor_manager_language(" 500Advanced")) == nil then
                        slot:SetText(text .. "{ol}" .. goddess_icor_manager_language(" 500Advanced"))
                    end]]
                    return "FFFFD700"
                end
            end
        end

        for i = 1, #low500armortbl do
            local tblkey = low500armortbl[i]
            local keyname = next(tblkey)
            local tblvalue = tblkey[next(tblkey)]
            for j = 1, size do
                local key = "RandomOption_" .. j
                local value_key = "RandomOptionValue_" .. j
                local option = item_dic[key]
                local value = item_dic[value_key]
                if tostring(option) == tostring(keyname) and tonumber(value) >= tonumber(tblvalue) then
                    --[[local text = slot:GetText()

                    if string.find(text, " LV500") == nil then
                        slot:SetText(text .. "{ol} LV500")
                    end]]
                    return "FFDAA520"
                end
            end
        end

        for i = 1, #high480armortbl do
            local tblkey = high480armortbl[i]
            local keyname = next(tblkey)
            local tblvalue = tblkey[next(tblkey)]
            for j = 1, size do
                local key = "RandomOption_" .. j
                local value_key = "RandomOptionValue_" .. j
                local option = item_dic[key]
                local value = item_dic[value_key]
                if tostring(option) == tostring(keyname) and tonumber(value) >= tonumber(tblvalue) then
                    --[[local text = slot:GetText()

                    if string.find(text, goddess_icor_manager_language(" 480Advanced")) == nil then
                        slot:SetText(text .. "{ol}" .. goddess_icor_manager_language(" 480Advanced"))
                    end]]
                    return "FF808080"
                end
            end
        end

        for i = 1, #low480armortbl do
            local tblkey = low480armortbl[i]
            local keyname = next(tblkey)
            local tblvalue = tblkey[next(tblkey)]
            for j = 1, size do
                local key = "RandomOption_" .. j
                local value_key = "RandomOptionValue_" .. j
                local option = item_dic[key]
                local value = item_dic[value_key]
                if tostring(option) == tostring(keyname) and tonumber(value) >= tonumber(tblvalue) then
                    --[[local text = slot:GetText()

                    if string.find(text, " LV480") == nil then
                        slot:SetText(text .. "{ol} LV480")
                    end]]
                    return "FF808080"
                end
            end
        end

    end
    return "FF000000"

end

--[[ local token = StringSplit(arg_str, ';')
local name = token[1]
local before = token[2]
local record = token[3]]
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

function goddess_icor_manager_list_close(frame)
    local frame = ui.GetFrame("goddess_icor_manager")
    local newframe = ui.GetFrame("goddess_icor_manager_newframe")
    local statusframe = ui.GetFrame("status")
    local icorframe = ui.GetFrame("goddess_equip_manager")
    frame:ShowWindow(0)
    newframe:ShowWindow(0)
    statusframe:ShowWindow(0)
    icorframe:ShowWindow(0)
    if g.settings.check == 1 then
        local acc = GetMyAccountObj()
        local etc = GetMyEtcObject()
        local remain_time = GET_REMAIN_SECOND_ENGRAVE_SLOT_EXTENSION_TIME(acc)

        local max_page = GET_MAX_ENGARVE_SLOT_COUNT(acc)
        local page_max = 0
        if tonumber(remain_time) == 0 then

            page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc) + 5
        else
            page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc)
        end

        for i = 1, page_max do
            local bg = GET_CHILD_RECURSIVELY(frame, "bg" .. i)
            AUTO_CAST(bg)
            local curpos = bg:GetScrollCurPos();
            if curpos == 514 then
                curpos = 0
            end
            g.settings[tostring(i)] = curpos
            goddess_icor_manager_save_settings()
            -- bg:SetUserValue("SAVE_POS", curpos);

        end
    end
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

