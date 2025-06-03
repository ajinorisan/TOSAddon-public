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
-- v1.0.9 セット適用出来る様に。大変やった。
local addon_name = "GODDESS_ICOR_MANAGER"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.0.9"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]
local json = require("json")

g.settings_path = string.format('../addons/%s/settings.json', addon_name_lower)

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

local managed_list = {'RH', 'LH', "SHIRT", 'PANTS', 'GLOVES', 'BOOTS', 'RH_SUB', 'LH_SUB'}
local managed_slot_list = {{
    slot_name = 'RH',
    clmsg = 'RH'
}, {
    slot_name = 'LH',
    clmsg = 'LH'
}, {
    slot_name = 'SHIRT',
    clmsg = 'Shirt'
}, {
    slot_name = 'PANTS',
    clmsg = 'Pants'
}, {
    slot_name = 'GLOVES',
    clmsg = 'Gloves'
}, {
    slot_name = 'BOOTS',
    clmsg = 'Boots'
}, {
    slot_name = 'RH_SUB',
    clmsg = 'RH_SUB'
}, {
    slot_name = 'LH_SUB',
    clmsg = 'LH_SUB'
}}
---

function g.save_json(path, tbl)
    local file = io.open(path, "w")
    if file then
        local str = json.encode(tbl)
        file:write(str)
        file:close()
    end
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

function g.get_map_type()
    local map_name = session.GetMapName()
    local map_cls = GetClass("Map", map_name)
    local map_type = map_cls.MapType
    return map_type
end

function goddess_icor_manager_load_settings()

    local settings, err = g.load_json(g.settings_path)

    if not settings then
        settings = {
            check = 0
        }
    end

    if not settings[g.cid] then
        settings[g.cid] = {
            drop_items = {{
                set_name = "Set 1",
                set = {}
            }, {
                set_name = "Set 2",
                set = {}
            }, {
                set_name = "Set 3",
                set = {}
            }, {
                set_name = "Set 4",
                set = {}
            }, {
                set_name = "Set 5",
                set = {}
            }}
        }
    end
    g.settings = settings
    g.save_json(g.settings_path, g.settings)
end

function GODDESS_ICOR_MANAGER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    g.lang = option.GetCurrentCountry()
    g.cid = session.GetMySession():GetCID()

    if g.get_map_type() == "City" then
        addon:RegisterMsg("GAME_START", "goddess_icor_manager_GAME_START")
        addon:RegisterMsg('ESCAPE_PRESSED', 'goddess_icor_manager_list_close')
    end
end

function goddess_icor_manager_GAME_START()
    goddess_icor_manager_load_settings()
    goddess_icor_manager_frame_init()
end

function goddess_icor_manager_frame_init()
    --[[local frame = ui.GetFrame("goddess_equip_manager")
    local randomoption_bg = GET_CHILD_RECURSIVELY(frame, "randomoption_bg")
    local listbtn = randomoption_bg:CreateOrGetControl("button", "listbtn", 520, 12, 160, 40)
    AUTO_CAST(listbtn)
    listbtn:SetText("{ol}list")
    listbtn:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_list_init")]]

    local inventory = ui.GetFrame('inventory')
    local inventoryGbox = inventory:GetChild("inventoryGbox")
    local icor_btn = inventory:CreateOrGetControl("button", "icor_btn", 430, 345, 30, 30)
    AUTO_CAST(icor_btn)
    icor_btn:SetText("{img sysmenu_skill 30 30}")
    icor_btn:SetSkinName("test_red_button")
    icor_btn:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_list_init")
    icor_btn:SetTextTooltip("{ol}Goddes Icor Manager")
end

function goddess_icor_manager_list_init(frame, ctrl, str, page)

    local frame = ui.GetFrame("goddess_icor_manager")
    frame:Resize(1430, 1060) -- 1000
    frame:SetOffset(0, 10) -- 0,20
    frame:ShowWindow(1)
    frame:SetLayerLevel(121)
    frame:ShowTitleBar(0)
    frame:SetSkinName("test_frame_midle_light")
    frame:RemoveAllChild()
    goddess_icor_manager_newframe_init()
    if page == 2 then
        g.num = 2
        goddess_icor_manager_list_gb_init(frame, 2)
    else
        g.num = 1
        goddess_icor_manager_list_gb_init(frame, 1)
    end

end

function goddess_icor_manager_set_save(frame, ctrl, str, ctrl_key)

    local acc = GetMyAccountObj()
    local etc_obj = GetMyEtcObject()
    local remain_time = GET_REMAIN_SECOND_ENGRAVE_SLOT_EXTENSION_TIME(acc)
    local page_max = 0
    if tonumber(remain_time) == 0 then
        page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc)
    else
        page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc) + 5
    end

    local cur_strs = {}

    for i = 1, #managed_slot_list do
        local slot_info = managed_slot_list[i]
        local slot_name = slot_info.slot_name
        local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_name))

        if inv_item and inv_item:GetObject() then
            local item_obj = GetIES(inv_item:GetObject())
            local item_dic = GET_ITEM_RANDOMOPTION_DIC(item_obj)

            if item_dic then
                local size = item_dic["Size"] or 0
                if size ~= 0 then
                    local opts, grps, vals = {}, {}, {}
                    for j = 1, size do
                        local key_opt = "RandomOption_" .. j
                        local key_val = "RandomOptionValue_" .. j
                        local key_grp = "RandomOptionGroup_" .. j

                        local opt = item_dic[key_opt]
                        local val = item_dic[key_val]
                        local grp = item_dic[key_grp]

                        table.insert(opts, opt ~= nil and tostring(opt) or "")
                        table.insert(grps, grp ~= nil and tostring(grp) or "")
                        table.insert(vals, val ~= nil and tostring(val) or "")
                    end

                    if #opts > 0 then
                        local cur_opts = table.concat(opts, "/")
                        local cur_grps = table.concat(grps, "/")
                        local cur_vals = table.concat(vals, "/")

                        cur_strs[slot_name] = string.format("%s:%s:%s", cur_opts, cur_grps, cur_vals)
                    end
                end
            end
        end
    end

    local rh_str = cur_strs['RH']
    local rh_sub_str = cur_strs['RH_SUB']
    local rh_match = rh_str and rh_sub_str and rh_str == rh_sub_str

    local lh_str = cur_strs['LH']
    local lh_sub_str = cur_strs['LH_SUB']
    local lh_match = lh_str and lh_sub_str and lh_str == lh_sub_str

    local eng_count = 0

    for i = 1, page_max do
        for j = 1, #managed_slot_list do
            local current_slot_name = managed_slot_list[j].slot_name

            local eng_opts, eng_grps, eng_vals, is_goddess =
                goddess_icor_manager_GET_ENGRAVED_OPTION_LIST(etc_obj, j, current_slot_name)

            if eng_opts then
                local eng_strs = string.format("%s:%s:%s", tostring(eng_opts or ""), tostring(eng_grps or ""),
                    tostring(eng_vals or ""))

                if cur_strs[current_slot_name] and cur_strs[current_slot_name] == eng_strs then
                    eng_count = eng_count + 1
                    local temp_data = g.settings[g.cid].drop_items[ctrl_key]
                    temp_data.set[current_slot_name] = i .. ":::" .. current_slot_name .. ":::" .. j
                    if rh_match and current_slot_name == "RH" then
                        temp_data.set["RH_SUB"] = temp_data.set["RH"]
                        eng_count = eng_count + 1
                    elseif rh_match and current_slot_name == "RH_SUB" then
                        temp_data.set["RH"] = temp_data.set["RH_SUB"]
                        eng_count = eng_count + 1
                    elseif lh_match and current_slot_name == "LH" then
                        temp_data.set["LH_SUB"] = temp_data.set["LH"]
                        eng_count = eng_count + 1
                    elseif lh_match and current_slot_name == "LH_SUB" then
                        temp_data.set["LH"] = temp_data.set["LH_SUB"]
                        eng_count = eng_count + 1
                    end
                end
            end
        end
    end

    if eng_count == 8 then
        goddess_icor_INPUT_STRING_BOX(ctrl_key)
    else
        local text = g.lang == "Japanese" and "{ol}付替え不可のため保存できません" or
                         "{ol}Cannot be saved as it is not replaceable"
        ui.SysMsg(text)
    end
end

function goddess_icor_manager_save_setname(inputstring, ctrl, str, ctrl_key)

    inputstring:ShowWindow(0)
    local edit = GET_CHILD(inputstring, 'input')
    local get_text = edit:GetText()
    if get_text == "" then
        local text = g.lang == "Japanese" and "{ol}文字を入力してください" or "{ol}Please enter text"
        ui.SysMsg(text)
        goddess_icor_INPUT_STRING_BOX(ctrl_key)
        return
    end
    local text = g.lang == "Japanese" and "{ol}セットを登録しました" or "{ol}Set registered"
    ui.SysMsg(text)

    text = g.lang == "Japanese" and "(保存済)" or "(saved)"

    g.settings[g.cid].drop_items[ctrl_key].set_name = get_text .. text
    g.save_json(g.settings_path, g.settings)
    goddess_icor_manager_newframe_init(ctrl_key)

end

function goddess_icor_INPUT_STRING_BOX(ctrl_key)
    local inputstring = ui.GetFrame("inputstring")
    inputstring:Resize(500, 220)
    inputstring:SetLayerLevel(999)
    local edit = GET_CHILD(inputstring, 'input', "ui::CEditControl")
    -- edit:SetEnableEditTag(1)
    edit:SetNumberMode(0)
    edit:SetMaxLen(999)
    edit:SetText("")

    inputstring:ShowWindow(1)
    inputstring:SetEnable(1)

    local title = inputstring:GetChild("title")
    AUTO_CAST(title)

    local text = g.lang == "Japanese" and "{ol}{#FFFFFF}セット名を入力" or "{ol}{#FFFFFF}Enter set name"
    title:SetText(text)

    local confirm = inputstring:GetChild("confirm")
    confirm:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_save_setname")
    confirm:SetEventScriptArgNumber(ui.LBUTTONUP, ctrl_key)

    edit:SetEventScript(ui.ENTERKEY, "goddess_icor_manager_save_setname")
    edit:SetEventScriptArgNumber(ui.ENTERKEY, ctrl_key)
    edit:AcquireFocus()

end

function goddess_icor_manager_set_delete_(ctrl_key)
    g.settings[g.cid].drop_items[ctrl_key] = nil
    g.settings[g.cid].drop_items[ctrl_key] = {
        set_name = "Set " .. ctrl_key,
        set = {}
    }
    g.save_json(g.settings_path, g.settings)

    local text = g.lang == "Japanese" and "{ol}セットを削除しました" or "{ol}Set removed"
    ui.SysMsg(text)

    goddess_icor_manager_newframe_init()
end

function goddess_icor_manager_set_delete(frame, ctrl, str, ctrl_key)

    local msg = g.lang == "Japanese" and "{ol}{#FFFFFF}セットを削除しますか？" or
                    "{ol}{#FFFFFF}Do you want to remove the set?"
    ui.MsgBox(msg, string.format("goddess_icor_manager_set_delete_(%d)", ctrl_key), "None")

end

function goddess_icor_manager_droplist_select(frame, ctrl)

    local ctrl_key = tonumber(ctrl:GetSelItemKey())

    local temp_data = g.settings[g.cid].drop_items[ctrl_key]

    if ctrl_key == 0 then
        goddess_icor_manager_newframe_init()
    elseif next(temp_data.set) == nil then
        goddess_icor_manager_newframe_init(ctrl_key)
    else
        goddess_icor_manager_newframe_init(ctrl_key)
        local etc_obj = GetMyEtcObject()

        local status_bg = GET_CHILD(frame, "status_bg")
        status_bg:RemoveAllChild()

        g.rh = nil
        g.lh = nil
        g.rh_sub = nil
        g.lh_sub = nil

        for base_equip_name, data in pairs(temp_data.set) do

            local _, save_equip_name, _ = string.match(data, "^(.-):::(.-):::(.+)$")
            if save_equip_name then
                if base_equip_name ~= save_equip_name then
                    if base_equip_name == "RH" then
                        g.rh = true
                    elseif base_equip_name == "LH" then
                        g.lh = true
                    elseif base_equip_name == "RH_SUB" then
                        g.rh_sub = true
                    elseif base_equip_name == "LH_SUB" then
                        g.lh_sub = true
                    end
                end
            end
        end

        for i = 1, #managed_slot_list do
            local new_bg = GET_CHILD(frame, "new_bg" .. i)
            AUTO_CAST(new_bg)
            local slot = GET_CHILD(new_bg, "slot" .. i)
            AUTO_CAST(slot)

            local slot_info = managed_slot_list[i]
            local slot_name = slot_info.slot_name
            local tgt_str = temp_data.set[slot_name]
            local load_index, load_equip_name = string.match(tgt_str, "^(.-):::(.-):::(.+)$")

            local eng_opts, eng_grps, eng_vals, is_goddess =
                goddess_icor_manager_GET_ENGRAVED_OPTION_LIST(etc_obj, tonumber(load_index), load_equip_name)

            local _, count = string.gsub(eng_opts, "/", "")
            local size = count + 1
            for j = 1, size do

                local parts1 = {}
                local parts2 = {}
                local parts3 = {}
                if eng_opts ~= nil then
                    for part in eng_opts:gmatch("([^/]+)") do
                        table.insert(parts1, part)
                    end
                    for part in eng_grps:gmatch("([^/]+)") do
                        table.insert(parts2, part)
                    end
                    for part in eng_vals:gmatch("([^/]+)") do
                        table.insert(parts3, part)
                    end

                    local y = 25
                    for k = 1, #parts1 do
                        local opt_name = parts1[k]
                        local grp_name = parts2[k]
                        local val = parts3[k]

                        local text = new_bg:CreateOrGetControl("richtext", "text" .. k, 5, y)
                        AUTO_CAST(text)

                        local color = goddess_icor_manager_color(grp_name)
                        text:SetText("{ol}" .. color .. goddess_icor_manager_language(opt_name) .. "{ol}{#FFFFFF} : " ..
                                         val)
                        y = y + 20
                    end
                end
            end
        end
    end
end

function goddess_icor_manager_set_change(frame, ctrl, str, ctrl_key)

    for i = 1, #managed_slot_list do
        local slot_info = managed_slot_list[i]
        local slot_name = slot_info.slot_name
        local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_name))
        local guid = inv_item:GetIESID()

        if guid == "0" then
            local text = g.lang == "Japanese" and "{ol}装備を8ヶ所に着けてから起動してください" or
                             "{ol}Wear the equipment in 8 places before activating it"
            ui.SysMsg(text)
            return
        end
    end

    local acc = GetMyAccountObj()
    local etc_obj = GetMyEtcObject()
    local remain_time = GET_REMAIN_SECOND_ENGRAVE_SLOT_EXTENSION_TIME(acc)
    local page_max = 0
    if tonumber(remain_time) == 0 then
        page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc)
    else
        page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc) + 5
    end

    for j = 1, #managed_slot_list do
        local cur_slot_name = managed_slot_list[j].slot_name
        local tgt_str = g.settings[g.cid].drop_items[ctrl_key].set[cur_slot_name]
        local load_index, load_equip_name = string.match(tgt_str, "^(.-):::(.-):::(.+)$")
        if tonumber(load_index) > page_max then
            local text = g.lang == "Japanese" and
                             "{ol}保存しているイコルが使用不可のため、終了します" or
                             "{ol}Process terminated Stored Icor is unavailable"
            ui.SysMsg(text)

            return
        end
    end

    local notice = g.lang == "Japanese" and
                       "{ol}[GIM]セット適用中{nl}バグ防止のため操作をしないでください" or
                       "{ol}[GIM]set is being applied{nl}Do not operate to prevent bugs"

    imcAddOn.BroadMsg("NOTICE_Dm_stage_start", notice)

    local cur_strs = {}

    for i = 1, #managed_slot_list do
        local slot_info = managed_slot_list[i]
        local slot_name = slot_info.slot_name
        local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_name))

        if inv_item and inv_item:GetObject() then
            local item_obj = GetIES(inv_item:GetObject())
            local item_dic = GET_ITEM_RANDOMOPTION_DIC(item_obj)

            if item_dic then
                local size = item_dic["Size"] or 0
                if size ~= 0 then
                    local opts, grps, vals = {}, {}, {}
                    for j = 1, size do
                        local key_opt = "RandomOption_" .. j
                        local key_val = "RandomOptionValue_" .. j
                        local key_grp = "RandomOptionGroup_" .. j

                        local opt = item_dic[key_opt]
                        local val = item_dic[key_val]
                        local grp = item_dic[key_grp]

                        table.insert(opts, opt ~= nil and tostring(opt) or "")
                        table.insert(grps, grp ~= nil and tostring(grp) or "")
                        table.insert(vals, val ~= nil and tostring(val) or "")
                    end

                    if #opts > 0 then
                        local cur_opts = table.concat(opts, "/")
                        local cur_grps = table.concat(grps, "/")
                        local cur_vals = table.concat(vals, "/")

                        cur_strs[slot_name] = string.format("%s:%s:%s", cur_opts, cur_grps, cur_vals)

                    end
                end
            end
        end
    end

    local spot_names = ""

    if g.rh then
        spot_names = spot_names .. ":::" .. "RH_DAMMY"
    end
    if g.lh then
        spot_names = spot_names .. ":::" .. "LH_DAMMY"
    end
    if g.rh_sub then
        spot_names = spot_names .. ":::" .. "RH_SUB_DAMMY"
    end
    if g.lh_sub then
        spot_names = spot_names .. ":::" .. "LH_SUB_DAMMY"
    end

    for i = 1, page_max do
        for j = 1, #managed_slot_list do
            local cur_slot_name = managed_slot_list[j].slot_name
            local tgt_str = g.settings[g.cid].drop_items[ctrl_key].set[cur_slot_name]
            local load_index, load_equip_name = string.match(tgt_str, "^(.-):::(.-):::(.+)$")
            load_index = tonumber(load_index)

            local eng_opts, eng_grps, eng_vals, is_goddess =
                goddess_icor_manager_GET_ENGRAVED_OPTION_LIST(etc_obj, load_index, load_equip_name)

            if eng_opts then

                local eng_strs = string.format("%s:%s:%s", tostring(eng_opts or ""), tostring(eng_grps or ""),
                    tostring(eng_vals or ""))

                local base_condition = cur_strs[cur_slot_name] and cur_strs[cur_slot_name] ~= eng_strs

                if base_condition then

                    cur_strs[cur_slot_name] = nil
                    local spot_name_found = true
                    if cur_slot_name == "RH" then
                        if g.rh or g.rh_sub then
                            spot_name_found = false
                        end
                    elseif cur_slot_name == "LH" then
                        if g.lh or g.lh_sub then
                            spot_name_found = false
                        end
                    elseif cur_slot_name == "RH_SUB" then
                        if g.rh_sub or g.rh then
                            spot_name_found = false
                        end
                    elseif cur_slot_name == "LH_SUB" then
                        if g.lh_sub or g.lh then
                            spot_name_found = false
                        end
                    end
                    if spot_name_found then
                        spot_names = spot_names .. ":::" .. cur_slot_name
                    end
                end
            end
        end
    end
    print(tostring(g.rh) .. ":" .. tostring(g.lh) .. ":" .. tostring(g.rh_sub) .. ":" .. tostring(g.lh_sub))
    print(tostring(spot_names))
    if spot_names ~= "" then
        local _, dammy_count = string.gsub(spot_names, "_DAMMY", "")
        local _, count = string.gsub(spot_names, ":::", "")
        g.try = count - dammy_count

        goddess_icor_manager_set_change_action(ctrl_key, spot_names)
    else
        local text = g.lang == "Japanese" and "{ol}現在装備中と同一のセットです" or
                         "{ol}This is the same set you currently have equipped"
        ui.SysMsg(text)
        local notice = ui.GetFrame("notice")
        AUTO_CAST(notice)
        notice:ShowWindow(0)
    end
end

function goddess_icor_manager_set_change_action(ctrl_key, spot_names)

    if g.try == 0 and (g.rh or g.lh or g.rh_sub or g.lh_sub) then

        g.auto_set = true
        g.ctrl_key = ctrl_key
        if g.rh then
            g.rh = false
        end
        if g.lh then
            g.lh = false
        end
        if g.rh_sub then
            g.rh_sub = false
        end
        if g.lh_sub then
            g.lh_sub = false
        end
        goddess_icor_manager_swap_weapon()
        return
    elseif g.try == 0 and (g.rh == false or g.lh == false or g.rh_sub == false or g.lh_sub == false) then
        g.auto_set = false
        goddess_icor_manager_swap_weapon()
        return
    end

    local frame = ui.GetFrame('goddess_equip_manager')
    frame:ShowWindow(1)

    local spot_name = string.match(spot_names, "^:::([A-Z0-9_]+)")

    if spot_name then
        spot_names = string.gsub(spot_names, "^:::" .. spot_name, "", 1)
    end

    local tgt_str = g.settings[g.cid].drop_items[ctrl_key].set[spot_name]
    local load_index = string.match(tgt_str, "^(.-):::(.-):::(.+)$")

    session.ResetItemList()

    local arg_list = NewStringList()
    local tgt_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(spot_name))

    if tgt_item then
        if tgt_item.isLockState == true then
            ui.SysMsg(ClMsg('MaterialItemIsLock'))
            return
        end
        local guid = tgt_item:GetIESID()

        if guid ~= 'None' and guid ~= '0' then
            session.AddItemID(guid, 1)
            arg_list:Add(spot_name)
        end
    end

    if load_index then
        arg_list:Add(load_index)
        local result_list = session.GetItemIDList()
        item.DialogTransaction('ICOR_PRESET_ENGRAVE_APPLY', result_list, '', arg_list)
        if g.try > 0 then
            g.try = g.try - 1
            ReserveScript(string.format("goddess_icor_manager_set_change_action(%d,'%s')", ctrl_key, spot_names), 1.0)
            return
        else
            local notice = ui.GetFrame("notice")
            AUTO_CAST(notice)
            notice:ShowWindow(0)
            goddess_icor_manager_list_close()
        end
    end
end

function goddess_icor_manager_newframe_init(ctrl_key)
    g.auto_set = nil
    local newframe = ui.CreateNewFrame("notice_on_pc", "goddess_icor_manager_newframe", 0, 0, 0, 0)
    AUTO_CAST(newframe)
    newframe:SetOffset(1430, 10)
    newframe:Resize(500, 1065)
    newframe:SetSkinName('test_frame_midle_light')
    newframe:SetLayerLevel(121)
    newframe:RemoveAllChild()

    local change_check = newframe:CreateOrGetControl('checkbox', 'change_check', 10, 30, 30, 30)
    AUTO_CAST(change_check)
    change_check:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_check_save")
    change_check:SetCheck(g.settings.check)
    change_check:SetText(g.lang == "Japanese" and "{ol}チェックで表示切替" or "{ol}Check to switch display")

    local closebtn = newframe:CreateOrGetControl("button", "closebtn", 470, 0, 30, 30)
    closebtn:SetText("{img testclose_button 30 30}")
    AUTO_CAST(closebtn)
    closebtn:SetGravity(ui.RIGHT, ui.TOP)
    closebtn:SetSkinName("None")
    closebtn:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_list_close")
    closebtn:SetTextTooltip("{ol}Frame Close.")

    local swapbtn = newframe:CreateOrGetControl("button", "swapbtn", 0, 0, 35, 35)
    swapbtn:SetText("{img sysmenu_skill 35 35}")
    AUTO_CAST(swapbtn)
    closebtn:SetGravity(ui.LEFT, ui.TOP)
    swapbtn:SetSkinName("test_pvp_btn")
    swapbtn:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_swap_weapon")
    swapbtn:SetTextTooltip(g.lang == "Japanese" and "{ol}武器の裏表切替" or
                               "{ol}Swap the reverse side of weapons")

    local set_droplist = newframe:CreateOrGetControl('droplist', 'set_droplist', change_check:GetWidth() + 50, 35, 250,
        30)
    AUTO_CAST(set_droplist)
    set_droplist:SetSkinName('droplist_normal')
    set_droplist:EnableHitTest(1)
    set_droplist:SetTextAlign("center", "center")
    set_droplist:SetSelectedScp("goddess_icor_manager_droplist_select")
    set_droplist:AddItem(0, " ")
    set_droplist:SelectItem(ctrl_key or 0)
    set_droplist:Invalidate()
    for key, data in ipairs(g.settings[g.cid].drop_items) do
        set_droplist:AddItem(key, "{ol}" .. data.set_name)
    end

    if ctrl_key then
        local save_btn = newframe:CreateOrGetControl("button", "save_btn", set_droplist:GetX(), 5, 50, 30)
        AUTO_CAST(save_btn)
        save_btn:SetText(g.lang == "Japanese" and "{ol}保存" or "{ol}Save")
        save_btn:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_set_save")
        save_btn:SetEventScriptArgNumber(ui.LBUTTONUP, ctrl_key)
        save_btn:SetTextTooltip(g.lang == "Japanese" and "{ol}装備中のイコルセットを保存します" or
                                    "{ol}Save icorset being equipped")

        local delete_btn = newframe:CreateOrGetControl("button", "delete_btn", set_droplist:GetX() + 60, 5, 50, 30)
        AUTO_CAST(delete_btn)
        delete_btn:SetText(g.lang == "Japanese" and "{ol}削除" or "{ol}Delete")
        delete_btn:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_set_delete")
        delete_btn:SetEventScriptArgNumber(ui.LBUTTONUP, ctrl_key)

        local keyword_jp = "(保存済)"
        local keyword_en = "(saved)"
        local found_jp = string.find(g.settings[g.cid].drop_items[ctrl_key].set_name, keyword_jp, 1, true)
        local found_en = string.find(g.settings[g.cid].drop_items[ctrl_key].set_name, keyword_en, 1, true)
        if found_jp or found_en then
            local change_btn = newframe:CreateOrGetControl("button", "change_btn", set_droplist:GetX() + 120, 5, 50, 30)
            AUTO_CAST(change_btn)
            change_btn:SetText(g.lang == "Japanese" and "{ol}付替" or "{ol}change")
            change_btn:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_set_change")
            change_btn:SetEventScriptArgNumber(ui.LBUTTONUP, ctrl_key)
        end
    end

    local x = 5
    local y = 50
    local yy = 50
    for i = 1, #managed_slot_list do
        local new_bg
        if i <= 2 or i >= 7 then
            new_bg = newframe:CreateOrGetControl("groupbox", "new_bg" .. i, x, y + 10, 240, 130)
            -- new_bg = newframe:CreateOrGetControl("picture", "new_bg" .. i, x, y + 10, 240, 130)
            y = y + 131

        elseif i <= 6 or i >= 3 then
            new_bg = newframe:CreateOrGetControl("groupbox", "new_bg" .. i, x + 245, yy + 10, 240, 130)
            -- new_bg = newframe:CreateOrGetControl("picture", "new_bg" .. i, x + 245, yy + 10, 240, 130)
            yy = yy + 131

        end
        AUTO_CAST(new_bg)
        new_bg:SetSkinName("test_frame_midle_light")

    end

    newframe:ShowWindow(1)

    for i = 1, #managed_slot_list do

        local slot_info = managed_slot_list[i]
        local new_bg = GET_CHILD(newframe, "new_bg" .. i)
        local slot = new_bg:CreateOrGetControl("richtext", "slot" .. i, 5, 5)
        AUTO_CAST(slot)
        slot:SetText("{ol}" .. ClMsg(slot_info.clmsg))

        local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_info.slot_name))
        local item_obj = GetIES(inv_item:GetObject())
        local item_dic = GET_ITEM_RANDOMOPTION_DIC(item_obj)
        local size = item_dic["Size"]

        local y = 25
        if size ~= 0 then
            for j = 1, size do

                local key = "RandomOption_" .. j
                local value_key = "RandomOptionValue_" .. j
                local group_key = "RandomOptionGroup_" .. j
                local bg = GET_CHILD_RECURSIVELY(newframe, "new_bg" .. i)
                local text = bg:CreateOrGetControl("richtext", "text" .. j, 5, y)
                AUTO_CAST(text)
                local option = item_dic[key]
                local value = item_dic[value_key]
                local group = item_dic[group_key]
                local color = goddess_icor_manager_color(tostring(group))
                text:SetText("{ol}" .. color .. goddess_icor_manager_language(option) .. "{#FFFFFF} : " .. value)
                y = y + 20

            end
            local bg = GET_CHILD_RECURSIVELY(newframe, "new_bg" .. i)
            local colortone = goddess_icor_manager_set_frame_color_equip(bg, size, item_dic, slot)
            bg:SetColorTone(colortone)
        end

    end

    local status_bg = newframe:CreateOrGetControl("groupbox", "status_bg", 5, 590, 490, 470)
    AUTO_CAST(status_bg)
    status_bg:SetSkinName("bg")
    if not ctrl_key then
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
end

function goddess_icor_manager_list_gb_init(frame, page)

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

        local s_index, e_index
        if page == 2 then
            s_index, e_index = 6, page_max
        elseif page == 1 then
            s_index, e_index = 1, 5
        end

        for i = s_index, e_index do
            local bg = frame:CreateOrGetControl("groupbox", "bg" .. i, Y, 10, 281, 1010) -- 490
            AUTO_CAST(bg)
            bg:RemoveAllChild()
            local pagename_text = bg:CreateOrGetControl("richtext", "pagename_text" .. i, 10, 5)
            AUTO_CAST(pagename_text)
            local pagename = goddess_icor_manager_get_pagename(i)
            Y = Y + 283

            if remain_time == 0 and tonumber(max_page) < i then
                local text = g.lang == "Japanese" and " 使用不可" or " disabled"
                pagename_text:SetText("{ol}{#FF0000}" .. pagename .. text)
            else
                pagename_text:SetText("{ol}{#FFFF00}" .. pagename)
            end
            bg:SetSkinName("bg")
            bg:ShowWindow(1)

            local manage_X = 0
            for j = 1, #managed_list do
                local manage_bg = bg:CreateOrGetControl("groupbox", "manage_bg" .. j, 0, 30 + manage_X, 258, 120)

                local manage_text = manage_bg:CreateOrGetControl("richtext", "manage_text" .. j, 10, 0)

                manage_text:SetText("{ol}" .. ClMsg(managed_slot_list[j].clmsg))

                manage_bg:SetSkinName("test_frame_midle_light")

                manage_X = manage_X + 122

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

    local function goddess_icor_manager_draw_manage_sections(parent_bg, current_i)
        local manage_y = 0

        for j = 1, #managed_list do

            local m_bg = parent_bg:CreateOrGetControl("groupbox", "manage_bg" .. j, 0, manage_y + 5, 258, 120)

            m_bg:SetSkinName("test_frame_midle_light")

            local m_text = m_bg:CreateOrGetControl("richtext", "manage_text" .. j, 10, 0)
            m_text:SetText("{ol}" .. goddess_icor_manager_language(managed_list[j]))
            local p1, p2, p3 = {}, {}, {}

            local opt_prop, grp_prop, val_prop, is_goddess =
                goddess_icor_manager_GET_ENGRAVED_OPTION_LIST(etc, current_i, managed_list[j])

            if opt_prop then
                for part in opt_prop:gmatch("([^/]+)") do
                    table.insert(p1, part)
                end
                for part in grp_prop:gmatch("([^/]+)") do
                    table.insert(p2, part)
                end
                for part in val_prop:gmatch("([^/]+)") do
                    table.insert(p3, part)
                end
                goddess_icor_manager_set_text(m_bg, p1, p2, p3, m_text)
            end
            manage_y = manage_y + 122
        end
    end

    if g.settings.check == 1 then
        local bg_x = 10
        local y1 = 10
        local y2 = 535

        for i = 1, page_max do

            local bg_y = 0

            if i <= 5 then
                bg_y = y1
            elseif i >= 6 then

                bg_y = y2
            end

            local bg = frame:CreateOrGetControl("groupbox", "bg" .. i, bg_x, bg_y + 20, 281, 495)
            AUTO_CAST(bg)
            bg:SetSkinName("bg")

            local p_text = frame:CreateOrGetControl("richtext", "pagename_text" .. i, bg_x + 10, bg_y)
            AUTO_CAST(p_text)
            local p_name = goddess_icor_manager_get_pagename(i)

            if remain_time == 0 and tonumber(max_page) < i then
                local text = g.lang == "Japanese" and " 使用不可" or " disabled"
                p_text:SetText("{ol}{#FF0000}" .. p_name .. text)
            else
                p_text:SetText("{ol}{#FFFF00}" .. p_name)
            end
            bg:ShowWindow(1)

            goddess_icor_manager_draw_manage_sections(bg, i)
            if i <= 4 then
                bg_x = bg_x + 283
            elseif i == 5 then
                bg_x = 10
            else
                bg_x = bg_x + 283
            end

        end

        goddess_icor_manager_set_pos(frame, page_max)
    end
    goddess_icor_manager_check()
    frame:Resize(1430, 1065)

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
        local ctrlset = GET_CHILD_RECURSIVELY(frame, 'rand_slot_' .. slot_info.slot_name)
        local tgt_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_info.slot_name))
        local checkbox = GET_CHILD(ctrlset, 'checkbox')
        if tonumber(argStr) == 1 and i == 1 then
            checkbox:SetCheck(1)
        elseif tonumber(argStr) == 2 and i == 2 then
            checkbox:SetCheck(1)
        elseif tonumber(argStr) == 3 and i == 3 then
            checkbox:SetCheck(1)
        elseif tonumber(argStr) == 4 and i == 4 then
            checkbox:SetCheck(1)
        elseif tonumber(argStr) == 5 and i == 5 then
            checkbox:SetCheck(1)
        elseif tonumber(argStr) == 6 and i == 6 then
            checkbox:SetCheck(1)
        elseif tonumber(argStr) == 7 and i == 7 then
            checkbox:SetCheck(1)
        elseif tonumber(argStr) == 8 and i == 8 then
            checkbox:SetCheck(1)
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
                arg_list:Add(slot_info.slot_name)
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
            local curpos = bg:GetScrollCurPos()
            if curpos == 514 then
                curpos = 0
            end
            g.settings[tostring(i)] = curpos
            g.save_json(g.settings_path, g.settings)

        end
    end

    ReserveScript(string.format("goddess_icor_manager_list_init('%s','%s','%s',%d)", frame, "", "", g.num), 0.5)

end

function goddess_icor_manager_set_pos(frame, page_max)

    for i = 1, page_max do

        local bg = GET_CHILD_RECURSIVELY(frame, "bg" .. i)
        AUTO_CAST(bg)

        local pos = tonumber(g.settings[tostring(i)])

        bg:SetScrollPos(0)
        if pos ~= 0 then
            bg:EnableScrollBar(1)
            bg:EnableDrawFrame(1)
            bg:SetScrollPos(pos)
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
                        equip_button:SetEventScriptArgNumber(ui.LBUTTONUP, i) -- sets the 4th parameter (numarg)
                        equip_button:SetEventScriptArgString(ui.LBUTTONUP, j)
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
                            equip_button:SetEventScriptArgNumber(ui.LBUTTONUP, i) -- sets the 4th parameter (numarg)
                            equip_button:SetEventScriptArgString(ui.LBUTTONUP, j)
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
                            equip_button:SetEventScriptArgNumber(ui.LBUTTONUP, i) -- sets the 4th parameter (numarg)
                            equip_button:SetEventScriptArgString(ui.LBUTTONUP, j)
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
    g.save_json(g.settings_path, g.settings)
    local frame = ui.GetFrame("goddess_icor_manager")
    ReserveScript(string.format("goddess_icor_manager_list_init('%s','%s','%s',%d)", frame, "", "", 1), 0.5)

end

function goddess_icor_manager_newframe_set_status(status_bg, stframe, status_str, index)

    local child_frame = GET_CHILD_RECURSIVELY(stframe, status_str)

    local language = option.GetCurrentCountry()

    local level = info.GetLevel(session.GetMyHandle())
    local setting_num = level * 30
    local setting_num2 = level * 15

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
    --[[local icorframe = ui.GetFrame("goddess_icor_manager")
    icorframe:RemoveAllChild()
    local icornewframe = ui.GetFrame("goddess_icor_manager_newframe")
    icornewframe:RemoveAllChild()
    ui.CloseFrame("goddess_icor_manager")
    ui.CloseFrame("goddess_icor_manager_newframe")]]

    local inventory = ui.GetFrame("inventory")
    inventory:ShowWindow(1)

    local RH = GET_CHILD_RECURSIVELY(inventory, "RH")
    local LH = GET_CHILD_RECURSIVELY(inventory, "LH")
    local RH_SUB = GET_CHILD_RECURSIVELY(inventory, "RH_SUB")
    local LH_SUB = GET_CHILD_RECURSIVELY(inventory, "LH_SUB")

    local function goddess_icor_manager_swap_guid(slot_name, bool)

        local icon = slot_name:GetIcon()
        if bool then
            if icon then
                return true
            else
                return nil
            end
        end
        local icon_info = icon:GetInfo()
        local icon_guid = icon_info:GetIESID()
        return icon_guid
    end

    g.lh_sub_guid = goddess_icor_manager_swap_guid(LH_SUB)
    g.rh_sub_guid = goddess_icor_manager_swap_guid(RH_SUB)
    g.rh_guid = goddess_icor_manager_swap_guid(RH)
    g.lh_guid = goddess_icor_manager_swap_guid(LH)

    if goddess_icor_manager_swap_guid(LH_SUB, true) and goddess_icor_manager_swap_guid(RH_SUB, true) then
        local lh_sub_index = 31
        goddess_icor_manager_unequip(inventory, lh_sub_index)
    end
end

function goddess_icor_manager_unequip(inventory, lh_sub_index)
    imcSound.PlaySoundEvent('inven_unequip')
    item.UnEquip(lh_sub_index)
    DO_WEAPON_SLOT_CHANGE(inventory, 1)
    ReserveScript("goddess_icor_manager_equip()", 0.5)
    return
end

function goddess_icor_manager_equip()

    local function goddess_icor_manager_swap_equip(spot_name, guid)
        local inv_item = session.GetInvItemByGuid(guid)
        if inv_item then
            local inventory = ui.GetFrame("inventory")
            if string.find(spot_name, "_SUB") then
                DO_WEAPON_SLOT_CHANGE(inventory, 2)
            else
                DO_WEAPON_SLOT_CHANGE(inventory, 1)
            end
            ITEM_EQUIP(inv_item.invIndex, spot_name)
            ReserveScript("goddess_icor_manager_equip()", 0.6)
            return
        end
    end

    if g.rh_sub_guid then
        goddess_icor_manager_swap_equip("RH", g.rh_sub_guid)
        g.rh_sub_guid = nil
    elseif g.lh_sub_guid then
        goddess_icor_manager_swap_equip("LH", g.lh_sub_guid)
        g.lh_sub_guid = nil
    elseif g.rh_guid then
        goddess_icor_manager_swap_equip("RH_SUB", g.rh_guid)
        g.rh_guid = nil
    elseif g.lh_guid then
        goddess_icor_manager_swap_equip("LH_SUB", g.lh_guid)
        g.lh_guid = nil
    else
        local inventory = ui.GetFrame("inventory")
        inventory:Invalidate()

        if g.auto_set then
            goddess_icor_manager_set_change(_, _, _, g.ctrl_key)
        elseif g.auto_set == false then

            local notice = ui.GetFrame("notice")
            AUTO_CAST(notice)
            notice:ShowWindow(0)
            goddess_icor_manager_list_close()
            return
        else
            ReserveScript(string.format("goddess_icor_manager_list_init('%s','%s','%s',%d)", _, _, _, g.num or 1), 0.5)
        end
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
            local curpos = bg:GetScrollCurPos()
            if curpos == 514 then
                curpos = 0
            end
            g.settings[tostring(i)] = curpos
            g.save_json(g.settings_path, g.settings)
            -- bg:SetUserValue("SAVE_POS", curpos)

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

-- ReserveScript(string.format("goddess_icor_manager_list_init('%s','%s','%s',%d)", frame, "", "", argNum), 0.5)
--[[function goddess_icor_manager_swap_weapon()
    local icorframe = ui.GetFrame("goddess_icor_manager")
    icorframe:RemoveAllChild()
    local icornewframe = ui.GetFrame("goddess_icor_manager_newframe")
    icornewframe:RemoveAllChild()
    ui.CloseFrame("goddess_icor_manager")
    ui.CloseFrame("goddess_icor_manager_newframe")

    local inventory = ui.GetFrame("inventory")
    local equipItemList = session.GetEquipItemList()
    local RH = GET_CHILD_RECURSIVELY(inventory, "RH")
    local LH = GET_CHILD_RECURSIVELY(inventory, "LH")
    local RH_SUB = GET_CHILD_RECURSIVELY(inventory, "RH_SUB")
    local LH_SUB = GET_CHILD_RECURSIVELY(inventory, "LH_SUB")

    local function goddess_icor_manager_swap_slot(slot_name)

        local icon = slot_name:GetIcon()
        local icon_info = icon:GetInfo()
        local icon_guid = icon_info:GetIESID()
        return icon_guid
    end

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
        goddess_icor_manager_unequip(inventory, lh_sub)
        DO_WEAPON_SLOT_CHANGE(inventory, 1)
        ReserveScript("goddess_icor_manager_equip()", 0.5)
    end

end

function goddess_icor_manager_equip()

    local frame = ui.GetFrame("inventory")
    if g.rh_sub_guid ~= nil then
        local invitem = session.GetInvItemByGuid(g.rh_sub_guid)
        local spotname = "RH"
        ITEM_EQUIP(invitem.invIndex, spotname)
        frame:Invalidate()
        g.rh_sub_guid = nil
        ReserveScript("goddess_icor_manager_equip()", 0.6)
        return
    elseif g.lh_sub_guid ~= nil then

        local invitem = session.GetInvItemByGuid(g.lh_sub_guid)
        local spotname = "LH"
        ITEM_EQUIP(invitem.invIndex, spotname)
        frame:Invalidate()
        g.lh_sub_guid = nil
        ReserveScript("goddess_icor_manager_equip()", 0.6)
        return

    elseif g.rh_guid ~= nil then
        DO_WEAPON_SLOT_CHANGE(frame, 2)
        local invitem = session.GetInvItemByGuid(g.rh_guid)
        local spotname = "RH_SUB"
        ITEM_EQUIP(invitem.invIndex, spotname)
        frame:Invalidate()
        g.rh_guid = nil
        ReserveScript("goddess_icor_manager_equip()", 0.6)
        return

    elseif g.lh_guid ~= nil then
        DO_WEAPON_SLOT_CHANGE(frame, 2)
        local invitem = session.GetInvItemByGuid(g.lh_guid)
        local spotname = "LH_SUB"
        ITEM_EQUIP(invitem.invIndex, spotname)
        frame:Invalidate()
        g.lh_guid = nil
        ReserveScript("goddess_icor_manager_equip()", 0.6)
        return

    else
        local gimframe = ui.GetFrame("goddess_icor_manager")
        ReserveScript(string.format("goddess_icor_manager_list_init('%s','%s','%s',%d)", gimframe, "", "", 1), 0.5)
        if g.auto_set then
            goddess_icor_manager_set_change(_, _, _, g.ctrl_key)
        end
        return
    end

end

function goddess_icor_manager_unequip(frame, num)

    local invTab = GET_CHILD_RECURSIVELY(frame, "inventype_Tab")
    invTab:SelectTab(1)
    if true == BEING_TRADING_STATE() then
        return
    end

    local isEmptySlot = false
    if session.GetInvItemList():Count() < MAX_INV_COUNT then
        isEmptySlot = true
    end
    if isEmptySlot == true then

        imcSound.PlaySoundEvent('inven_unequip')
        item.UnEquip(tonumber(num))

        ReserveScript("goddess_icor_manager_swap_weapon()", 0.5)
        return
    end

end]]

--[[g.rh_match = false
    g.lh_match = false

    local rh_str = slot_opt_strs['RH']
    local rh_sub = slot_opt_strs['RH_SUB']

    if rh_str and rh_sub and rh_str == rh_sub then
        g.rh_match = true
    end

    local lh_str = slot_opt_strs['LH']
    local lh_sub = slot_opt_strs['LH_SUB']

    if lh_str and lh_sub and lh_str == lh_sub then
        g.lh_match = true
    end]]

--[[AUTO_CAST(new_bg)
            new_bg:SetImage("fullwhite")
            new_bg:SetEnableStretch(1)
            new_bg:SetColorTone("FFB8860B")]]
--[==[
function goddess_icor_manager_set_change_action(ctrl_key, spot_names)

    if g.try == 0 and (g.rh or g.lh or g.rh_sub or g.lh_sub) then

        g.auto_set = true
        g.ctrl_key = ctrl_key
        if g.rh then
            g.rh = false
        end
        if g.lh then
            g.lh = false
        end
        if g.rh_sub then
            g.rh_sub = false
        end
        if g.lh_sub then
            g.lh_sub = false
        end
        goddess_icor_manager_swap_weapon()
        return
    elseif g.try == 0 and (g.rh == false or g.lh == false or g.rh_sub == false or g.lh_sub == false) then
        g.auto_set = false
        goddess_icor_manager_swap_weapon()
        return
    end

    --[[if g.swap then
    g.swap = g.swap - 1
end
print("swap" .. tostring(g.swap))
if g.swap and g.swap == 0 then
    g.auto_set = false
    goddess_icor_manager_swap_weapon()
end]]

    local frame = ui.GetFrame('goddess_equip_manager')
    frame:ShowWindow(1)
    local goddess_icor_manager = ui.GetFrame("goddess_icor_manager")
    goddess_icor_manager:ShowWindow(0)

    local _, count = string.gsub(spot_names, ":::", "")
    local spot_name = string.match(spot_names, "^:::([A-Z_0-9]+)")

    local tgt_str = g.settings[g.cid].drop_items[ctrl_key].set[spot_name]
    local load_index, load_equip_name = string.match(tgt_str, "^(.-):::(.-):::(.+)$")
    load_index = tonumber(load_index)

    if spot_name then
        if count > 1 then
            spot_names = string.gsub(spot_names, spot_name .. ":::", "", 1)
        else
            spot_names = string.gsub(spot_names, spot_name, "", 1)
        end
    end

    session.ResetItemList()

    -- local apply_cnt = 0

    --[[local frame = ui.GetFrame('goddess_equip_manager')
    frame:ShowWindow(1)
    local main_tab = GET_CHILD_RECURSIVELY(frame, "main_tab")
    main_tab:SelectTab(1)
    local randomoption_bg = GET_CHILD_RECURSIVELY(frame, "randomoption_bg")
    local randomoption_tab = GET_CHILD_RECURSIVELY(randomoption_bg, "randomoption_tab")
    randomoption_tab:SelectTab(1)
    local rand_icor_slot_bg = GET_CHILD_RECURSIVELY(randomoption_bg, "rand_icor_slot_bg")]]

    local arg_list = NewStringList()
    local tgt_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(spot_name))

    if tgt_item then
        if tgt_item.isLockState == true then
            ui.SysMsg(ClMsg('MaterialItemIsLock'))
            return
        end
        local guid = tgt_item:GetIESID()
        --[[local ctrlset = GET_CHILD_RECURSIVELY(randomoption_bg, 'rand_slot_' .. spot_name)
        local slot = GET_CHILD(ctrlset, 'slot')
        AUTO_CAST(slot)
        local guid = slot:GetUserValue('ITEM_GUID')]]

        if guid ~= 'None' and guid ~= '0' then
            session.AddItemID(guid, 1)
            arg_list:Add(spot_name)
            -- apply_cnt = apply_cnt + 1
        end
    end
    print(tostring(iesid) .. ":" .. spot_name .. ":" .. load_index)
    --[[if apply_cnt == 0 then
        ui.SysMsg(ClMsg('NoSelectedItem'))
        return
    end]]

    if load_index then
        arg_list:Add(load_index)
        local result_list = session.GetItemIDList()
        item.DialogTransaction('ICOR_PRESET_ENGRAVE_APPLY', result_list, '', arg_list)
        if g.try > 0 then
            print(g.try .. " try")
            g.try = g.try - 1
            ReserveScript(string.format("goddess_icor_manager_set_change_action(%d,'%s')", ctrl_key, spot_names), 2.0)
            return
        end
    end
end
--]==]
