-- v1.1.4 コード大幅見直し。ヘアアクセバグ修正。失敗した時にリトライ昨日追加。
-- v1.1.5 登録したカードと別のカードが付いていると無限ループに陥る問題修正
-- v1.1.6 多分もう少しだけ失敗しにくく
-- v1.1.7 入庫時のシステムチャットつけた。出庫時と装備の順番固定。多分早くなった。
-- v1.1.8 設定のコピー機能付けた。なんかダサイけど仕方ない。
-- v1.1.9 インベと倉庫閉じるチェック付けた。
-- v1.2.0 倉庫閉じるチェックボックスのセットチェック漏れてた。
-- v1.2.1 ロード処理見直し。
-- v1.2.2 エコモードバグってたの修正。
-- v1.2.3 AGM連携の確認を切り替えられるように。ある程度日本語化
-- v1.2.4 AGM連携を4種類対応出来るように。コピーの仕様変更。コード見直し。
-- v1.2.5 バグってた。修正。
-- v1.2.6 agmとの連携バグってたの修正。
-- v1.2.7 json作る時バグってた。
-- v1.2.8 agmとの連携更にばぐってたの修正。
-- v1.2.9 読込遅かったのを修正。その他ちょいバグ修正。
-- v1.3.0 ヘアコスのエンチャントが3個じゃない場合バグってたの修正
-- v1.3.1 オードクローズバグってたの修正。agm全キャラ処理追加
-- v1.3.2 agm連携のトコ修正した
-- v1.3.3 コード全体見直し。mcc殺した。ペット登録可能に
-- v1.3.4 セーブデータのジョブバグってたの修正
-- v1.3.5 JSON作るのバグってたの修正したつもり。カード装着画面閉じる時間調整
-- v1.3.6 JSON作る階層バグってたの修正。疲れてたんやと思う。コアとレリック追加
local addon_name = "CC_HELPER"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.3.6"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

local acutil = require("acutil")
local json = require('json')

function g.mkdir_new_folder()
    local function create_folder(folder_path, file_path)
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

    local folder = string.format("../addons/%s", addon_name_lower)
    local file_path = string.format("../addons/%s/mkdir.txt", addon_name_lower)
    create_folder(folder, file_path)

    g.active_id = session.loginInfo.GetAID()
    local user_folder = string.format("../addons/%s/%s", addon_name_lower, g.active_id)
    local user_file_path = string.format("../addons/%s/%s/mkdir.txt", addon_name_lower, g.active_id)
    create_folder(user_folder, user_file_path)

    g.settings_path = string.format("../addons/%s/%s/settings_250621.json", addon_name_lower, g.active_id)
end
g.mkdir_new_folder()

function g.get_map_type()
    local map_name = session.GetMapName()
    local map_cls = GetClass("Map", map_name)
    local map_type = map_cls.MapType
    return map_type
end

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

local function ts(...)

    local num_args = select('#', ...)

    if num_args == 0 then
        return
    end

    local string_parts = {}

    for i = 1, num_args do
        local arg = select(i, ...)
        table.insert(string_parts, tostring(arg))
    end

    print(table.concat(string_parts, "\t"))
end

local DEFAULT_EQUIP_SLOT = {
    iesid = "",
    clsid = 0,
    image = "",
    skin = "",
    memo = ""
}

local DEFAULT_CHAR_SETTINGS = {
    name = "",
    mcc_use = 0,
    agm_use = 0,
    agm_check = 1,
    gender = 0,
    jobid = 0,
    seal = {},
    ark = {},
    leg = {},
    god = {},
    hair1 = {},
    hair2 = {},
    hair3 = {},
    gem1 = {},
    gem2 = {},
    gem3 = {},
    gem4 = {},
    pet = {},
    core = {},
    relic = {}
}

function cc_helper_save_settings()

    g.save_json(g.cid_settings_path, g.settings)
end

function cc_helper_load_settings()

    g.old_settings_path = string.format('../addons/%s/%s.json', addon_name_lower, g.cid)
    g.cid_settings_path = string.format('../addons/%s/%s/%s.json', addon_name_lower, g.active_id, g.cid)

    local share_settings = g.load_json(g.settings_path)

    if not share_settings then
        share_settings = {

            eco_mode = 0,
            auto_close = 1,
            all_agm = 0
        }
    end
    if not share_settings.all_agm then
        share_settings.all_agm = 0
    end
    g.share_settings = share_settings
    g.save_json(g.settings_path, g.share_settings)

    local old_settings = g.load_json(g.old_settings_path)

    if old_settings then
        -- print("古い形式の設定ファイルを発見しました。新しい形式に移行します...")
        g.save_json(g.cid_settings_path, old_settings)

        local new_file_check = io.open(g.cid_settings_path, "r")
        if new_file_check then
            new_file_check:close()

            -- print("新しい設定ファイルの作成に成功しました。古いファイルを削除します。")

            local success, err = os.remove(g.old_settings_path)

            if not success then
                -- print(string.format("古い設定ファイルの削除に失敗しました: %s", tostring(err)))
            end

        else
            -- print("警告：新しい設定ファイルの作成に失敗しました。古いファイルは、削除しませんでした。")
        end
    end

    local settings = g.load_json(g.cid_settings_path)

    if not settings then
        settings = {}
    end

    if not settings[g.cid] then
        settings[g.cid] = {}
    end

    for key, default_value in pairs(DEFAULT_CHAR_SETTINGS) do
        if settings[g.cid][key] == nil then
            settings[g.cid][key] = (type(default_value) == "table") and {} or default_value
        end
    end

    for key, value in pairs(settings[g.cid]) do

        if type(value) == "table" and type(DEFAULT_CHAR_SETTINGS[key]) == "table" then

            for sub_key, sub_default_value in pairs(DEFAULT_EQUIP_SLOT) do
                if value[sub_key] == nil then
                    value[sub_key] = sub_default_value
                end
            end
        end
    end

    local pc_info = session.barrack.GetMyAccount():GetByStrCID(g.cid)
    local pc_apc = pc_info:GetApc()
    local jobid = pc_info:GetRepID() or pc_apc:GetJob()
    local gender = pc_apc:GetGender()

    settings[g.cid].name = g.login_name
    settings[g.cid].jobid = jobid
    settings[g.cid].gender = gender

    g.settings = settings

    --[[print("--- g.settings の内容 ---")
    DebugPrintTable(g.settings)
    print("--- 表示完了 ---")]]

    local function cc_helper_filter_table_bykey(original_table, key_to_keep)
        local filtered_table = {}
        if original_table and original_table[key_to_keep] then
            filtered_table[key_to_keep] = original_table[key_to_keep]
        end
        return filtered_table
    end

    g.settings = cc_helper_filter_table_bykey(g.settings, g.cid)
    cc_helper_save_settings()
end

--[[function DebugPrintTable(tbl, indent)
    indent = indent or ""

    for key, value in pairs(tbl) do
        -- キーの文字列は変更なし
        local key_str = indent .. "[" .. tostring(key) .. "] ="
        local value_type = type(value)

        if value_type == "table" then
            print(key_str .. "{")
            DebugPrintTable(value, indent .. "  ")
            print(indent .. "}")
        else
            -- ★★★ 変更点: 値が文字列なら "'" で囲む ★★★
            if value_type == "string" then
                print(key_str .. "'" .. tostring(value) .. "'")
            else
                print(key_str .. tostring(value))
            end
        end
    end
end]]

function cc_helper_function_check()

    local agm_use = true

    if type(_G["AETHERGEM_MGR_ON_INIT"]) == "function" then

        return agm_use

    else
        agm_use = false
        if g.settings[g.cid].agm_use == 1 then
            g.settings[g.cid].agm_use = 0
        end
        cc_helper_save_settings()
    end

    return agm_use
end

function g.setup_hook_and_event(my_addon, origin_func_name, my_func_name, bool)

    g.FUNCS = g.FUNCS or {}
    if not g.FUNCS[origin_func_name] then
        g.FUNCS[origin_func_name] = _G[origin_func_name]
    end

    local origin_func = g.FUNCS[origin_func_name]

    local function hooked_function(...)

        local original_results

        if bool == true then
            original_results = {origin_func(...)}
        end

        g.ARGS = g.ARGS or {}
        g.ARGS[origin_func_name] = {...}
        imcAddOn.BroadMsg(origin_func_name)

        if original_results then
            return table.unpack(original_results)
        else
            return
        end
    end

    _G[origin_func_name] = hooked_function

    if not g.REGISTER[origin_func_name .. my_func_name] then -- g.REGISTERはON_INIT内で都度初期化
        g.REGISTER[origin_func_name .. my_func_name] = true
        my_addon:RegisterMsg(origin_func_name, my_func_name)
    end
end

function CC_HELPER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.cid = info.GetCID(session.GetMyHandle())
    g.lang = option.GetCurrentCountry()
    g.login_name = session.GetMySession():GetPCApc():GetName()

    g.REGISTER = {}

    if g.get_map_type() == "City" then

        addon:RegisterMsg("GAME_START", "cc_helper_load_settings")

        g.setup_hook_and_event(addon, "ACCOUNTWAREHOUSE_CLOSE", "cc_helper_ACCOUNTWAREHOUSE_CLOSE", true)
        g.setup_hook_and_event(addon, "INVENTORY_CLOSE", "cc_helper_settings_close", true)
        g.setup_hook_and_event(addon, "UI_TOGGLE_INVENTORY", "cc_helper_invframe_init", true)
        g.setup_hook_and_event(addon, "INVENTORY_OPEN", "cc_helper_invframe_init", true)
        g.setup_hook_and_event(addon, "AETHERGEM_MGR_SAVE_SETTINGS", "cc_helper_AETHERGEM_MGR_SAVE_SETTINGS", true)

        addon:RegisterMsg("OPEN_DLG_ACCOUNTWAREHOUSE", "cc_helper_accountwarehouse_init")

    end

end

function cc_helper_AETHERGEM_MGR_SAVE_SETTINGS(my_frame, my_msg)
    local agm_g = _G["ADDONS"]["norisan"]["AETHERGEM_MGR"]
    local agm_settings = agm_g.settings

    if agm_settings then

        if agm_settings[tostring(g.cid)] then
            local use_index = agm_settings[tostring(g.cid)]["use_index"]
            if use_index then
                local preset_data = agm_settings[tostring(use_index)]
                if preset_data then
                    for slot_number, gem_id in pairs(preset_data) do
                        g.settings[tostring(g.cid)]["gem" .. slot_number].clsid = gem_id
                        --[[print(string.format("スロット %s には、ジェムID %d がセットされています。",
                            slot_number, gem_id))]]
                    end
                end
            end
        end
    end
    cc_helper_save_settings()

    local frame_name = string.lower("AETHERGEM_MGR") .. "setting_frame"
    local agm_setting_frame = ui.GetFrame(frame_name)
    if not agm_setting_frame then
        return
    else
        AUTO_CAST(agm_setting_frame)
    end
    if agm_setting_frame:IsVisible() == 1 then
        cc_helper_setting_frame_init("", "", "minimum", "")
        return
    end
end

function cc_helper_invframe_init()

    local invframe = ui.GetFrame("inventory")
    -- invframe:ShowWindow(1)

    local setbtn = invframe:CreateOrGetControl("button", "set", 205, 345, 30, 30)
    AUTO_CAST(setbtn)
    setbtn:SetSkinName("None")
    setbtn:SetText("{img config_button_normal 30 30}")
    setbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_setting_frame_init")
    setbtn:SetTextTooltip(g.lang == "Japanese" and
                              "{ol}Character Change Helper{nl}マウス左ボタンクリック、キャラ毎に出し入れするアイテム設定。" or
                              "{ol}Character Change Helper{nl}Left mouse button click,{nl}setting items to be moved in and out for each character.")

    local awhframe = ui.GetFrame("accountwarehouse")
    if awhframe:IsVisible() == 1 then
        local in_btn = invframe:CreateOrGetControl("button", "in_btn", 235, 345, 30, 30)
        AUTO_CAST(in_btn)
        in_btn:SetText("{img in_arrow 20 20}")
        in_btn:SetEventScript(ui.LBUTTONUP, "cc_helper_putitem")
        in_btn:SetEventScriptArgString(ui.LBUTTONUP, "1")

        in_btn:ShowWindow(1)
        in_btn:SetSkinName("test_pvp_btn")
        in_btn:SetTextTooltip(g.lang == "Japanese" and
                                  "{ol}Character Change Helper{nl}装備を外して倉庫へ搬入します。" or
                                  "{ol}Character Change Helper{nl}The equipment is removed and brought into the warehouse.")

        local out_btn = invframe:CreateOrGetControl("button", "out_btn", 265, 345, 30, 30)
        AUTO_CAST(out_btn)
        out_btn:SetText("{@st66b}{img chul_arrow 20 20}")

        out_btn:SetEventScript(ui.LBUTTONUP, "cc_helper_take_item")
        out_btn:ShowWindow(1)
        out_btn:SetSkinName("test_pvp_btn")
        out_btn:SetTextTooltip(g.lang == "Japanese" and
                                   "{ol}Character Change Helper{nl}倉庫から搬出して装備します。" or
                                   "{ol}Character Change Helper{nl}It is carried out from the warehouse and equipped.")
    end
end

function cc_helper_accountwarehouse_init()

    local awhframe = ui.GetFrame("accountwarehouse")
    awhframe:ShowWindow(1)

    local in_btn = awhframe:CreateOrGetControl("button", "in_btn", 565, 120, 30, 30)
    AUTO_CAST(in_btn)
    in_btn:SetText("{img in_arrow 20 20}")
    in_btn:SetEventScript(ui.LBUTTONUP, "cc_helper_putitem")
    in_btn:SetEventScriptArgString(ui.LBUTTONUP, "1")
    in_btn:ShowWindow(1)
    in_btn:SetSkinName("test_pvp_btn")
    in_btn:SetTextTooltip(g.lang == "Japanese" and
                              "{ol}Character Change Helper{nl}装備を外して倉庫へ搬入します。" or
                              "{ol}Character Change Helper{nl}The equipment is removed and brought into the warehouse.")

    local out_btn = awhframe:CreateOrGetControl("button", "out_btn", 595, 120, 30, 30)
    AUTO_CAST(out_btn)
    out_btn:SetText("{@st66b}{img chul_arrow 20 20}")
    out_btn:SetEventScript(ui.LBUTTONUP, "cc_helper_take_item")
    out_btn:ShowWindow(1)
    out_btn:SetSkinName("test_pvp_btn")
    out_btn:SetTextTooltip(g.lang == "Japanese" and
                               "{ol}Character Change Helper{nl}倉庫から搬出して装備します。" or
                               "{ol}Character Change Helper{nl}It is carried out from the warehouse and equipped.")

    local auto_close = awhframe:CreateOrGetControl("checkbox", "auto_close", 540, 120, 30, 30)
    AUTO_CAST(auto_close)
    auto_close:ShowWindow(1)
    auto_close:SetTextTooltip(g.lang == "Japanese" and
                                  "{ol}動作終了後倉庫とインベントリーを閉じます。" or
                                  "{ol}After the operation is completed,{nl}the warehouse and inventory are closed.")
    auto_close:SetEventScript(ui.LBUTTONUP, "cc_helper_check_setting")
    auto_close:SetCheck(g.share_settings.auto_close)

    -- if _G.ADDONS.norisan.monstercard_change ~= nil then
    --[[if g.mcc then
        local mccbtn = awhframe:CreateOrGetControl("button", "mcc", 625, 120, 30, 30)
        AUTO_CAST(mccbtn)
        mccbtn:SetSkinName("test_red_button")
        mccbtn:SetTextAlign("right", "center")
        mccbtn:SetText("{img monsterbtn_image 30 20}")
        mccbtn:SetTextTooltip(g.lang == "Japanese" and "カード自動搬出入、自動着脱" or
                                  "Automatic card loading/unloading, automatic insertion/removal")
        mccbtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_MONSTERCARDPRESET_FRAME_OPEN")
    end]]

    cc_helper_invframe_init()
end

function cc_helper_ACCOUNTWAREHOUSE_CLOSE(frame)

    local invframe = ui.GetFrame("inventory")
    local in_btn = GET_CHILD_RECURSIVELY(invframe, "in_btn")
    local out_btn = GET_CHILD_RECURSIVELY(invframe, "out_btn")

    in_btn:ShowWindow(0)
    out_btn:ShowWindow(0)
    INVENTORY_SET_CUSTOM_RBTNDOWN("None")
end

function cc_helper_check_setting(frame, ctrl)

    if ctrl:GetName() == "agm_on_off" then
        if g.settings[g.cid].agm_check == 0 then
            g.settings[g.cid].agm_check = 1
        else
            g.settings[g.cid].agm_check = 0
        end

    else
        local ischeck = ctrl:IsChecked()
        if ctrl:GetName() == "mccuse" then
            if ischeck == 0 then
                g.settings[g.cid].mcc_use = 0
            else
                g.settings[g.cid].mcc_use = 1
            end
        elseif ctrl:GetName() == "auto_close" then
            if ischeck == 0 then
                g.share_settings.auto_close = 0
            else
                g.share_settings.auto_close = 1
            end
        elseif ctrl:GetName() == "agmuse" then
            if ischeck == 0 then
                g.settings[g.cid].agm_use = 0

            else
                g.settings[g.cid].agm_use = 1
            end
        elseif ctrl:GetName() == "ecouse" then
            if ischeck == 0 then
                g.share_settings.eco_mode = 0
            else
                g.share_settings.eco_mode = 1
            end
        elseif ctrl:GetName() == "all_agm" then
            if ischeck == 0 then
                g.share_settings.all_agm = 0
            else
                g.share_settings.all_agm = 1
            end

        end
    end
    g.save_json(g.settings_path, g.share_settings)
    cc_helper_save_settings()
    if ctrl:GetName() ~= "auto_close" then
        cc_helper_setting_frame_init()
        frame:ShowWindow(1)
    end

end

-- settingframe

function cc_helper_setting_frame_close_by_agm(frame)
    local frame_name = string.lower("AETHERGEM_MGR") .. "setting_frame"
    local agm_setting_frame = ui.GetFrame(frame_name)
    if not agm_setting_frame then
        return 0
    else
        AUTO_CAST(agm_setting_frame)
    end
    if agm_setting_frame:IsVisible() == 0 then
        frame:ShowWindow(0)
        return 0
    end
    return 1
end

function cc_helper_settings_close(frame)
    --[[if type(_G["ANOTHER_WAREHOUSE_ON_INIT"]) == "function" then
        ts("aru")
        INVENTORY_SET_CUSTOM_RBTNDOWN("another_warehouse_setting_rbtn")
    else

    end]]
    local accountwarehouse = ui.GetFrame("accountwarehouse")
    if accountwarehouse:IsVisible() == 1 then
        INVENTORY_SET_CUSTOM_RBTNDOWN("ACCOUNT_WAREHOUSE_INV_RBTN")
    end
    -- 
    local cc_helper = ui.GetFrame("cc_helper")
    cc_helper:ShowWindow(0)
end

function cc_helper_load_copy(cid)

    local function cc_helper_deep_copy(original)
        local copy = {}
        for k, v in pairs(original) do
            if type(v) == "table" then
                copy[k] = cc_helper_deep_copy(v)
            else
                copy[k] = v
            end
        end
        return copy
    end

    g.settings[g.cid] = cc_helper_deep_copy(g.copy_settings[cid])
    g.settings[g.cid]["name"] = g.login_name

    cc_helper_save_settings()
    cc_helper_setting_frame_init()

    local frame = ui.GetFrame("cc_helper")
    frame:ShowWindow(1)
end

function cc_helper_setting_copy(frame, ctrl, str, num)

    local old_copy_path = string.format('../addons/%s/%s_copy.json', addon_name_lower, g.active_id)
    local new_copy_path = string.format('../addons/%s/%s/%s_copy.json', addon_name_lower, g.active_id, g.active_id)

    local old_copy_settings = g.load_json(old_copy_path)

    if old_copy_settings then
        print("古い形式のコピー設定ファイルを発見。移行します...")

        g.save_json(new_copy_path, old_copy_settings)

        local new_copy_file_check = io.open(new_copy_path, "r")
        if new_copy_file_check then
            new_copy_file_check:close()

            print("新しいコピー設定ファイルの作成に成功。古いファイルを削除します。")

            os.remove(old_copy_path)

        else
            print(
                "警告：新しいコピー設定ファイルの作成に失敗。古いファイルは削除しませんでした。")
        end
    end

    g.copy_settings = g.load_json(new_copy_path)

    local context = ui.CreateContextMenu("MAPFOG_CONTEXT", "{ol}Copy source", 0, 0, 0, 0)
    ui.AddContextMenuItem(context, "-----", "")

    for cid, tbl in pairs(g.copy_settings) do

        if next(tbl) then
            local job_cls = GetClassByType("Job", tbl.jobid)
            local job_name = GET_JOB_NAME(job_cls, tbl.gender)
            local name = tbl.name
            local text = name .. "(" .. job_name .. ")"
            local scp = ui.AddContextMenuItem(context, text, string.format("cc_helper_load_copy('%s')", cid))
        end

    end
    ui.OpenContextMenu(context)

end

function cc_helper_setting_save(frame, ctrl, str, num)

    local copy_settings_location = string.format('../addons/%s/%s/%s_copy.json', addon_name_lower, g.active_id,
        g.active_id)
    local copy_settings = g.load_json(copy_settings_location)
    if not copy_settings then
        copy_settings = {}
    end
    if not copy_settings[g.cid] then
        copy_settings[g.cid] = {}
    end
    local pc_info = session.barrack.GetMyAccount():GetByStrCID(g.cid)
    local pc_apc = pc_info:GetApc()
    local jobid = pc_info:GetRepID() or pc_apc:GetJob()
    local gender = pc_apc:GetGender()
    g.settings[g.cid].jobid = jobid
    g.settings[g.cid].gender = gender
    copy_settings[g.cid] = g.settings[g.cid]

    g.copy_settings = copy_settings
    g.save_json(copy_settings_location, g.copy_settings)

    ui.SysMsg(g.lang == "Japanese" and "{ol}{#FFFF00}設定を保存しました" or "{ol}{#FFFF00}Settings saved")
    cc_helper_save_settings()
end

function cc_helper_cancel(frame, ctrl, argstr, argnum)

    ctrl:ClearIcon()
    ctrl:RemoveAllChild()
    local name = ctrl:GetName()

    for key, value in pairs(g.settings[g.cid]) do
        if name == key then
            value.image = ""
            value.iesid = ""
            value.clsid = 0
            value.skin = ""
            value.memo = ""
            if string.find(name, "god") == nil and string.find(name, "leg") == nil then
                local skinName = "invenslot2"
                ctrl:SetSkinName(skinName)
            end
            break
        end
    end

    cc_helper_save_settings()
end

function cc_helper_tooltip(frame, ctrl, argStr, argNum)

    local tooltip = ui.GetTooltip("wholeitem")
    local rect = tooltip:GetMargin()
    tooltip:SetMargin(rect.left, rect.top - 50, rect.righ, rect.bottom)
    local equip_main = GET_CHILD_RECURSIVELY(tooltip, 'equip_main')
    local tooltip_ark_lv = GET_CHILD_RECURSIVELY(equip_main, "tooltip_ark_lv")
    local invitem = session.GetInvItemByGuid(g.settings[g.cid]["ark"].iesid)
    if invitem == nil then
        return
    end
    local item_obj = GetIES(invitem:GetObject())

    local ypos = 0

    ypos = DRAW_EQUIP_COMMON_TOOLTIP_SMALL_IMG(tooltip, item_obj, "equip_main")

    ypos = DRAW_ARK_LV(tooltip, item_obj, 170, "equip_main")

    ypos = DRAW_ARK_OPTION(tooltip, item_obj, ypos, "equip_main")
    ypos = DRAW_ARK_EXP(tooltip, item_obj, ypos, "equip_main")
    ypos = DRAW_EQUIP_MEMO(tooltip, item_obj, ypos, "equip_main")
    ypos = DRAW_EQUIP_ARK_DESC(tooltip, item_obj, ypos, "equip_main") -- 각종 설명문

    ypos = DRAW_EQUIP_TRADABILITY(tooltip, item_obj, ypos, "equip_main") -- 거래 제한
    ypos = DRAW_CANNOT_REINFORCE(tooltip, item_obj, ypos, "equip_main") -- 초월 및 강화불가

    local isHaveLifeTime = TryGetProp(item_obj, "LifeTime", 0) -- 기간제
    if 0 == tonumber(isHaveLifeTime) then
        ypos = DRAW_SELL_PRICE(tooltip, item_obj, ypos, "equip_main")
    else
        ypos = DRAW_REMAIN_LIFE_TIME(tooltip, item_obj, ypos, "equip_main")
    end

    ypos = ypos + 3
    -- ypos = DRAW_TOGGLE_EQUIP_DESC(tooltip, item_obj, ypos, "equip_main") -- 설명문 토글 여부

    local gBox = GET_CHILD(tooltip, "equip_main", 'ui::CGroupBox')
    gBox:Resize(gBox:GetWidth(), ypos + 20)
    tooltip:Resize(gBox:GetWidth(), ypos + 20)

end

function cc_helper_setting_delete_(cid)

    local copy_settings_location = string.format('../addons/%s/%s/%s_copy.json', addon_name_lower, g.active_id,
        g.active_id)
    local copy_settings = g.load_json(copy_settings_location)
    if not copy_settings then
        copy_settings = {}
    end
    if not copy_settings[cid] then
        copy_settings[cid] = {}
    end
    copy_settings[cid] = {}
    g.copy_settings = copy_settings
    g.save_json(copy_settings_location, g.copy_settings)
    ui.SysMsg(g.lang == "Japanese" and "{ol}{#FFFF00}設定を削除しました" or "{ol}{#FFFF00}Settings deleted")
    -- cc_helper_save_settings()
end

function cc_helper_setting_delete(frame, ctrl, str, num)

    local context = ui.CreateContextMenu("MAPFOG_CONTEXT", "{ol}{#FF0000}Delete Data", 0, 0, 0, 0)
    ui.AddContextMenuItem(context, "{ol}{#FF0000}" .. "-----", "")

    for cid, tbl in pairs(g.copy_settings) do

        if next(tbl) then
            local job_cls = GetClassByType("Job", tbl.jobid)
            local job_name = GET_JOB_NAME(job_cls, tbl.gender)
            local name = tbl.name
            local text = "{ol}{#FF0000}" .. name .. "(" .. job_name .. ")"
            local scp = ui.AddContextMenuItem(context, text, string.format("cc_helper_setting_delete_('%s')", cid))
        end

    end
    ui.OpenContextMenu(context)

end

function cc_helper_setting_frame_init(frame, ctrl, minimum, num)

    -- local awhframe = ui.GetFrame("accountwarehouse")
    -- ACCOUNTWAREHOUSE_CLOSE(awhframe)
    -- UI_TOGGLE_INVENTORY()

    local frame = ui.GetFrame("cc_helper")
    frame:RemoveAllChild()
    frame:SetSkinName("test_frame_low")
    frame:SetLayerLevel(93)

    if minimum == "minimum" then
        frame:SetPos(885, 300)
        frame:RunUpdateScript("cc_helper_setting_frame_close_by_agm", 0.3)
    else
        frame:SetPos(1185, 380)
    end
    frame:Resize(235, 470)
    -- frame:SetPos(1185, 380)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    frame:EnableHitTest(1)

    if frame:IsVisible() == 0 then
        frame:ShowWindow(1)
    elseif minimum == "minimum" then
        frame:ShowWindow(1)
    else
        frame:ShowWindow(0)
    end

    if minimum ~= "minimum" then
        local close = frame:CreateOrGetControl('button', 'close', 0, 0, 30, 30)
        AUTO_CAST(close)
        close:SetImage("testclose_button")
        close:SetGravity(ui.LEFT, ui.TOP)
        close:SetEventScript(ui.LBUTTONUP, "cc_helper_settings_close")

    end
    INVENTORY_SET_CUSTOM_RBTNDOWN("cc_helper_inv_rbtn")

    local copy = frame:CreateOrGetControl('button', 'copy', 180, 10, 40, 30)
    AUTO_CAST(copy)
    copy:SetText("{ol}copy")
    copy:SetEventScript(ui.LBUTTONUP, "cc_helper_setting_copy")

    local save = frame:CreateOrGetControl('button', 'save', 130, 10, 40, 30)
    AUTO_CAST(save)
    save:SetText("{ol}save")
    save:SetEventScript(ui.LBUTTONUP, "cc_helper_setting_save")
    save:SetTextTooltip(g.lang == "Japanese" and "{ol}このキャラの設定をコピー用に保存します" or
                            "{ol}Save this character settings for copying")

    local save_delete = frame:CreateOrGetControl('button', 'save_delete', 67, 10, 40, 30)
    AUTO_CAST(save_delete)
    save_delete:SetText("{ol}delete")
    save_delete:SetEventScript(ui.LBUTTONUP, "cc_helper_setting_delete")
    save_delete:SetTextTooltip(
        g.lang == "Japanese" and "{ol}このキャラのコピー用の設定を削除します" or
            "{ol}Delete settings for copying this character")

    local ecouse = frame:CreateOrGetControl("checkbox", "ecouse", 10, 375, 25, 25)
    AUTO_CAST(ecouse)
    ecouse:SetText("{ol}eco mode")
    ecouse:SetTextTooltip(g.lang == "Japanese" and
                              "{ol}チェックを入れると、外すのにシルバーが必要な{nl}レジェンドカードとエーテルジェムの動作をスキップします。" or
                              "{ol}If checked, it skips the operation of legend cards and{nl}ether gems that require silver to remove.")
    ecouse:SetEventScript(ui.LBUTTONUP, "cc_helper_check_setting")
    ecouse:SetCheck(g.share_settings.eco_mode)

    local agm_use = cc_helper_function_check()
    if agm_use then

        local all_agm = frame:CreateOrGetControl("checkbox", "all_agm", 10, 435, 25, 25)
        AUTO_CAST(all_agm)
        all_agm:SetText("{ol}all agm stop")
        all_agm:SetTextTooltip(g.lang == "Japanese" and
                                   "{ol}チェックを入れると、全てのキャラの{nl}エーテルジェム関係の動作をストップします" or
                                   "{ol}If checked, stops all ether gem-related actions for all characters")
        all_agm:SetEventScript(ui.LBUTTONUP, "cc_helper_check_setting")
        all_agm:SetCheck(g.share_settings.all_agm)

        local agmuse = frame:CreateOrGetControl("checkbox", "agmuse", 10, 405, 25, 25)
        AUTO_CAST(agmuse)
        agmuse:SetText("{ol}agm")
        agmuse:SetTextTooltip(g.lang == "Japanese" and
                                  "{ol}チェックを入れると[Aethergem Manager]と連携します。" or
                                  "{ol}If checked, it will work with [Aethergem Manager].")
        agmuse:SetEventScript(ui.LBUTTONUP, "cc_helper_check_setting")
        agmuse:SetCheck(g.settings[g.cid].agm_use)

        if g.settings[g.cid]["agm_use"] == 1 then
            local agm_on_off = frame:CreateOrGetControl('button', 'agm_on_off', 80, 405, 60, 30)
            AUTO_CAST(agm_on_off)
            agm_on_off:ShowWindow(1)
            agm_on_off:SetEventScript(ui.LBUTTONUP, "cc_helper_check_setting")

            if g.settings[g.cid].agm_check == 1 then
                agm_on_off:SetSkinName("test_red_button")
                agm_on_off:SetText("{ol}ON")
                agm_on_off:SetTextTooltip(g.lang == "Japanese" and
                                              "{ol}[Aethergem Manager]との連携時に確認します" or
                                              "{ol}Check when working with [Aethergem Manager]")
            else
                agm_on_off:SetSkinName("test_gray_button")
                agm_on_off:SetText("{ol}OFF")
                agm_on_off:SetTextTooltip(g.lang == "Japanese" and
                                              "{ol}[Aethergem Manager]との連携時に確認しません" or
                                              "{ol}Not checked when working with [Aethergem Manager]")
            end
        end

    end

    local pet_select = frame:CreateOrGetControl('button', 'pet_select', 140, 375, 40, 30)
    AUTO_CAST(pet_select)
    pet_select:SetText("{ol}pet select")
    pet_select:SetEventScript(ui.LBUTTONUP, "cc_helper_context_pet")

    cc_helper_slot_create()
    --[[if g.mcc then
        local mccuse = frame:CreateOrGetControl("checkbox", "mccuse", 10, 375, 25, 25)
        AUTO_CAST(mccuse)
        mccuse:SetText("{ol}mcc")
        mccuse:SetTextTooltip(g.lang == "Japanese" and
                                  "チェックを入れると[Monster Card Change]と連携します。" or
                                  "If checked, it will work with [Monster Card Change].")
        mccuse:SetCheck(g.settings[g.cid].mcc_use)
        mccuse:SetEventScript(ui.LBUTTONUP, "cc_helper_check_setting")
    end]]

    --[[local delay_title = frame:CreateOrGetControl("richtext", "delay_title", 130, 440)
    delay_title:SetText("{ol}delay")
    function cc_helper_delay_change(frame, ctrl, argStr, argNum)
        local value = tonumber(ctrl:GetText())

        if value ~= nil then
            ui.SysMsg("Delay Time setting set to" .. value)
            g.share_settings.delay = value
        else
            ui.SysMsg("Invalid value. Please enter one-byte numbers.")
            local text = GET_CHILD_RECURSIVELY(frame, "delay")
            text:SetText("0.3")
            g.share_settings.delay = 0.3
        end
        g.save_json(g.settings_path, g.share_settings)
    end
    local delay = frame:CreateOrGetControl('edit', 'delay', 175, 440, 50, 20)
    AUTO_CAST(delay)
    delay:SetText("{ol}" .. g.share_settings.delay)
    delay:SetFontName("white_16_ol")
    delay:SetTextAlign("center", "center")
    delay:SetEventScript(ui.ENTERKEY, "cc_helper_delay_change")
    delay:SetTextTooltip(g.lang == "Japanese" and
                             "動作のディレイ時間を設定します。デフォルトは0.3秒。{nl}早過ぎると失敗が多発します。" or
                             "Sets the delay time for the operation. Default is 0.3 seconds.{nl}Too early and many failures will occur.")]]
end

function cc_helper_create_slot(frame, name, x, y, width, height, skin, text, clsid, iesid, image, cid)
    local slot = frame:CreateOrGetControl("slot", name, x, y, width, height)
    AUTO_CAST(slot)

    slot:SetSkinName(skin)
    slot:SetText(text)
    slot:EnablePop(1)
    slot:EnableDrag(1)
    slot:EnableDrop(1)
    slot:SetEventScript(ui.DROP, "cc_helper_frame_drop")
    slot:SetEventScript(ui.RBUTTONDOWN, "cc_helper_cancel")
    if name == "ark" then
        slot:SetEventScript(ui.MOUSEON, "cc_helper_tooltip")
    end

    if string.find(name, "gem") == nil then
        local item_cls = GetClassByType("Item", clsid)
        SET_SLOT_ITEM_CLS(slot, item_cls)
        SET_SLOT_IMG(slot, image)
        SET_SLOT_IESID(slot, iesid)
        if name ~= "leg" and name ~= "god" then
            SET_SLOT_BG_BY_ITEMGRADE(slot, item_cls)
        end
        if string.find(name, "hair") ~= nil then
            slot:SetSkinName(g.settings[cid][name].skin)
        end
        local icon = slot:GetIcon()
        local inv_item = session.GetInvItemByGuid(iesid)
        if inv_item ~= nil then
            icon:SetTooltipType('wholeitem')
            icon:SetTooltipArg("None", clsid, iesid)
        else
            -- inv_item が nil の場合も次に進む
            if clsid ~= 0 and string.find(name, "hair") ~= nil then

                local function split(str, sep)
                    local parts = {}
                    for part in str:gmatch("([^" .. sep .. "]+)") do
                        table.insert(parts, part)
                    end
                    return parts
                end

                local str = g.settings[cid][name].memo
                if string.find(str, ":::") then
                    local result = split(str, ":::")

                    if #result == 4 then
                        icon:SetTextTooltip("{ol}Rank: " .. result[4] .. "{nl}" .. result[1] .. "{nl}" .. result[2] ..
                                                "{nl}" .. result[3])
                    elseif #result == 3 then

                        icon:SetTextTooltip("{ol}Rank: " .. result[3] .. "{nl}" .. result[1] .. "{nl}" .. result[2])
                    elseif #result == 2 then

                        icon:SetTextTooltip("{ol}Rank: " .. result[2] .. "{nl}" .. result[1])

                    end

                end
            elseif clsid ~= 0 and name ~= "pet" then
                icon:SetTooltipType('wholeitem')
                icon:SetTooltipArg("None", clsid, iesid)
            elseif clsid ~= 0 and name == "pet" then
                icon:SetTextTooltip(g.settings[g.cid].pet.memo)
            end
        end
    end

    if string.find(name, "gem") and g.settings[g.cid].agm_use == 0 then
        slot:ShowWindow(0)
    elseif string.find(name, "gem") and g.settings[g.cid].agm_use == 1 then
        local agm_json = string.format('../addons/%s/%s.json', "aethergem_mgr", g.active_id)
        local settings = g.load_json(agm_json)
        local agm_tbl = settings
        if agm_tbl ~= nil then
            local use_index = settings[g.cid]["use_index"]
            if use_index ~= nil then
                local name_index = string.gsub(name, "gem", "")
                local item_type = agm_tbl[use_index][name_index]
                local gemKey = "gem" .. name_index

                g.settings[g.cid][gemKey].clsid = item_type
                cc_helper_save_settings()
                if item_type ~= nil and item_type ~= 0 then
                    local gem_cls = GetClassByType("Item", item_type)
                    local gem_name = gem_cls.ClassName
                    local icon = CreateIcon(slot)
                    SET_SLOT_ITEM_CLS(slot, gem_cls)
                    local lv_text = slot:CreateOrGetControl('richtext', 'lv_text', 0, 30, 25, 25)
                    AUTO_CAST(lv_text)
                    if string.find(gem_name, "480") ~= nil then
                        lv_text:SetText("{ol}{s14}LV480")
                    elseif string.find(gem_name, "500") ~= nil then
                        lv_text:SetText("{ol}{s14}LV500")
                    elseif string.find(gem_name, "520") ~= nil then
                        lv_text:SetText("{ol}{s14}LV520")
                    elseif string.find(gem_name, "540") ~= nil then
                        lv_text:SetText("{ol}{s14}LV540")
                    else
                        lv_text:SetText("{ol}{s14}LV460")
                    end
                    icon:SetTextTooltip(g.lang == "Japanese" and "{ol}Aethergem Managerの設定を参照します" or
                                            "{ol}Browse Aethergem Manager settings")
                end
            end
        end
        slot:EnablePop(0)
        slot:EnableDrag(0)
        slot:EnableDrop(0)
        slot:SetEventScript(ui.DROP, "None")
        slot:SetEventScript(ui.RBUTTONDOWN, "None")
    end
end

local slot_info = {
    ["seal"] = {
        x = 10,
        y = 210,
        text = "{ol}{s14}SEAL"
    },
    ["ark"] = {
        x = 65,
        y = 210,
        text = "{ol}{s14}ARK"
    },
    ["core"] = {
        x = 120,
        y = 210,
        text = "{ol}{s14}CORE"
    },
    ["relic"] = {
        x = 175,
        y = 210,
        text = "{ol}{s14}RELIC"
    },
    ["gem1"] = {
        x = 10,
        y = 320,
        text = "{ol}{s12}AETHER{nl}GEM1"
    },
    ["gem2"] = {
        x = 65,
        y = 320,
        text = "{ol}{s12}AETHER{nl}GEM2"
    },
    ["gem3"] = {
        x = 120,
        y = 320,
        text = "{ol}{s12}AETHER{nl}GEM3"
    },
    ["gem4"] = {
        x = 175,
        y = 320,
        text = "{ol}{s12}AETHER{nl}GEM4"
    },
    ["leg"] = {
        x = 10,
        y = 45,
        text = "{ol}{s14}LEGEND{nl}CARD"
    },
    ["god"] = {
        x = 120,
        y = 45,
        text = "{ol}{s14}GODDESS{nl}CARD"
    },
    ["hair1"] = {
        x = 10,
        y = 265,
        text = "{ol}{s14}HAIR1"
    },
    ["hair2"] = {
        x = 65,
        y = 265,
        text = "{ol}{s14}HAIR2"
    },
    ["hair3"] = {
        x = 120,
        y = 265,
        text = "{ol}{s14}HAIR3"
    },
    ["pet"] = {
        x = 160,
        y = 410,
        text = "{ol}{s14}PET"
    }
}

function cc_helper_slot_create()
    local frame = ui.GetFrame("cc_helper")
    for name, info in pairs(slot_info) do
        for key, value in pairs(g.settings[g.cid]) do
            if name == key then
                local width = 50
                local height = 50
                if name == "leg" or name == "god" then
                    -- 9:13
                    width = 105
                    height = 160
                end
                local skin = "invenslot2"
                if name == "leg" then
                    skin = "legendopen_cardslot"
                elseif name == "god" then
                    skin = "goddess_card__activation"
                end

                cc_helper_create_slot(frame, name, info.x, info.y, width, height, skin, info.text, value.clsid,
                    value.iesid, value.image, g.cid)
                break
            end
        end
    end
end

-- !
function cc_helper_context_pet_set(cls_id, pet_iesid, memo)

    local mon_cls = GetClassByType("Monster", cls_id)
    local frame = ui.GetFrame("cc_helper")
    local slot = GET_CHILD_RECURSIVELY(frame, "pet")
    AUTO_CAST(slot)
    local image = mon_cls.Icon
    SET_SLOT_ITEM_CLS(slot, mon_cls)
    SET_SLOT_IMG(slot, image)
    SET_SLOT_IESID(slot, pet_iesid)
    g.settings[g.cid].pet.iesid = pet_iesid
    g.settings[g.cid].pet.clsid = cls_id
    g.settings[g.cid].pet.image = image
    g.settings[g.cid].pet.memo = memo
    cc_helper_save_settings()
    cc_helper_slot_create()
end

function cc_helper_context_pet()
    local etcObj = GetMyEtcObject();
    local petType = etcObj.SelectedPet;
    local pet_list = session.pet.GetPetInfoVec();
    local mySession = session.GetMySession();
    local cid = mySession:GetCID();

    local context = ui.CreateContextMenu("PET_SELECT", "{ol}Pet Select", 400, -350, -400, 0);

    for i = 0, pet_list:size() - 1 do
        local info = pet_list:at(i);

        local obj = GetIES(info:GetObject())
        local name = info:GetName()
        local pet_iesid = info:GetStrGuid()

        local cls_name = obj.ClassName
        local cls_id = obj.ClassID
        local sin_name = obj.Name

        local cls_list, list_cnt = GetClassList('Companion')
        for index = 0, list_cnt - 1 do
            local companion_ies = GetClassByIndexFromList(cls_list, index)
            local ies_cls_name = companion_ies.ClassName
            if cls_name == ies_cls_name then
                local job_id = tonumber(companion_ies.JobID)
                if job_id ~= 3014 then
                    local memo = "{ol}[LV:" .. obj.Lv .. "] " .. name .. " ( " .. dic.getTranslatedStr(sin_name) ..
                                     " ) "
                    local Companion_cls = GetClass("Companion", TryGetProp(obj, "ClassName", "None"))
                    local pet_buff = TryGetProp(Companion_cls, "PetBuff", "None")
                    local buff_cls = GetClass("Buff", pet_buff);

                    if buff_cls then
                        local tool_tip = TryGetProp(buff_cls, 'ToolTip', 'None')
                        if tool_tip ~= 'None' then
                            memo = memo .. "{nl}" .. dic.getTranslatedStr(tool_tip)
                        end
                    end
                    local scp = string.format("cc_helper_context_pet_set(%d,'%s','%s')", cls_id, pet_iesid, memo)
                    ui.AddContextMenuItem(context,
                        "{img " .. obj.Icon .. " 20 20}" .. "{ol} [LV:" .. obj.Lv .. "] " .. name .. " ( " ..
                            dic.getTranslatedStr(sin_name) .. " ) ", scp);
                    break
                end
            end
        end

    end
    ui.OpenContextMenu(context);
end

function cc_helper_inv_rbtn(item_obj, slot)
    local frame = ui.GetFrame("cc_helper")
    if frame:IsVisible() == 0 then
        INVENTORY_SET_CUSTOM_RBTNDOWN("None")
        return
    end
    local icon = slot:GetIcon()
    local iconInfo = icon:GetInfo()
    local iesid = iconInfo:GetIESID()
    local inv_item = session.GetInvItemByGuid(iesid)
    local item_obj = GetIES(inv_item:GetObject())
    local image = TryGetProp(item_obj, "TooltipImage", "None")
    local clsid = item_obj.ClassID
    local type = item_obj.ClassType
    local gemtype = GET_EQUIP_GEM_TYPE(item_obj)
    local parent_name = slot:GetParent():GetName()
    ts(type)
    local char_belonging = TryGetProp(item_obj, 'CharacterBelonging', 0)

    local temp_tbl = {
        ["Seal"] = "seal",
        ["Ark"] = "ark",
        ["LEG"] = "leg",
        ["GODDESS"] = "god",
        ["sset_HairAcc_Acc1"] = "hair1",
        ["sset_HairAcc_Acc2"] = "hair2",
        ["sset_HairAcc_Acc3"] = "hair3",
        ["CORE"] = "core",
        ["Relic"] = "relic"
        -- ["aether"] = "gem"
    }

    for key, value in pairs(temp_tbl) do

        if key == "Seal" and key == type and clsid ~= 614001 then
            cc_helper_settings_slot(frame, value, item_obj, iesid, clsid, image)
            return
        elseif key == "Ark" and key == type and char_belonging ~= 1 then
            cc_helper_settings_slot(frame, value, item_obj, iesid, clsid, image)
            return
        elseif key == "CORE" and key == type then

            cc_helper_settings_slot(frame, value, item_obj, iesid, clsid, image)
        elseif key == "Relic" and key == type then
            cc_helper_settings_slot(frame, value, item_obj, iesid, clsid, image)
            return
        elseif key == "LEG" and key == item_obj.CardGroupName then
            cc_helper_settings_slot(frame, value, item_obj, iesid, clsid, image)
        elseif key == "GODDESS" and key == item_obj.CardGroupName then
            cc_helper_settings_slot(frame, value, item_obj, iesid, clsid, image)
        elseif key == "sset_HairAcc_Acc1" and key == parent_name then
            local str = cc_helper_hair_option(item_obj)
            cc_helper_settings_slot(frame, value, item_obj, iesid, clsid, image, str)
        elseif key == "sset_HairAcc_Acc2" and key == parent_name then
            local str = cc_helper_hair_option(item_obj)
            cc_helper_settings_slot(frame, value, item_obj, iesid, clsid, image, str)
        elseif key == "sset_HairAcc_Acc3" and key == parent_name then
            local str = cc_helper_hair_option(item_obj)
            cc_helper_settings_slot(frame, value, item_obj, iesid, clsid, image, str)
            --[[elseif gemtype == "aether" and key == "aether" then
            for i = 1, 4 do
                if g.settings[g.cid][tostring(value) .. i].clsid == 0 then
                    cc_helper_settings_slot(frame, value .. i, item_obj, iesid, clsid, image)
                    break
                end
            end]]

        end

    end
end

function cc_helper_hair_option(item_obj)
    local strInfo = ""
    for i = 1, 3 do
        local propName = "HatPropName_" .. i
        local propValue = "HatPropValue_" .. i
        if item_obj[propValue] ~= 0 and item_obj[propName] ~= "None" then
            local opName
            if string.find(item_obj[propName], 'ALLSKILL_') == nil then
                opName = string.format("%s", ScpArgMsg(item_obj[propName]))
            else
                local job = StringSplit(item_obj[propName], '_')[2]
                if job == 'ShadowMancer' then
                    job = 'Shadowmancer'
                end
                opName = string.format("%s", ScpArgMsg(job) .. ' ' .. ScpArgMsg('skill_lv_up_by_count'))
            end

            strInfo = strInfo .. ABILITY_DESC_PLUS(opName, item_obj[propValue]) .. ":::"

        end
    end
    strInfo = strInfo:gsub(" - ", "")
    strInfo = strInfo:gsub("-", "")

    return strInfo
end

function cc_helper_settings_slot(frame, value, item_obj, iesid, clsid, image, str)
    local slot = GET_CHILD_RECURSIVELY(frame, value)
    local item_cls = GetClassByType("Item", clsid)
    SET_SLOT_ITEM_CLS(slot, item_cls)
    SET_SLOT_IMG(slot, image)
    SET_SLOT_IESID(slot, iesid)
    if value ~= "leg" and value ~= "god" then
        SET_SLOT_BG_BY_ITEMGRADE(slot, item_cls)
    end

    local skin = ""
    if string.find(value, "gem") ~= nil then
        if string.find(item_obj.ClassName, "480") ~= nil then
            skin = "invenslot_rare"
            slot:SetSkinName(skin)
        elseif string.find(item_obj.ClassName, "500") ~= nil then
            skin = "invenslot_unique"
            slot:SetSkinName(skin)
        elseif string.find(item_obj.ClassName, "520") ~= nil then
            skin = "invenslot_legend"
            slot:SetSkinName(skin)
        elseif string.find(item_obj.ClassName, "540") ~= nil then -- invenslot_rare
            skin = "invenslot_pic_goddess"
            slot:SetSkinName(skin)
        end
    end
    if str ~= nil then
        local rank = shared_enchant_special_option.get_item_rank(item_obj)

        if rank == "A" then
            str = str .. "A"
            skin = "invenslot_pic_goddess"
            slot:SetSkinName(skin)
        elseif rank == "B" then
            str = str .. "B"
            skin = "invenslot_legend"
            slot:SetSkinName(skin)
        elseif rank == "C" then
            str = str .. "C"
            skin = "invenslot_unique"
            slot:SetSkinName(skin)
        else
            str = str .. "D"
        end
    end
    local icon = slot:GetIcon()
    icon:SetTooltipType('wholeitem')
    icon:SetTooltipArg("None", clsid, iesid)
    g.settings[g.cid][value].iesid = iesid
    g.settings[g.cid][value].image = image
    g.settings[g.cid][value].clsid = clsid
    g.settings[g.cid][value].skin = skin
    g.settings[g.cid][value].memo = str
    cc_helper_save_settings()
end

function cc_helper_frame_drop(frame, ctrl, argstr, argnum)

    local slot = AUTO_CAST(ctrl)
    local lifticon = ui.GetLiftIcon()
    local iconinfo = lifticon:GetInfo()
    local iesid = iconinfo:GetIESID()

    local parent = lifticon:GetParent()
    local fromslot = parent:GetParent()
    local parent_name = fromslot:GetName()

    local inv_item = session.GetInvItemByGuid(iesid)
    local item_obj = GetIES(inv_item:GetObject())
    local clsid = item_obj.ClassID
    local image = TryGetProp(item_obj, "TooltipImage", "None")
    local type = item_obj.ClassType
    local gemtype = GET_EQUIP_GEM_TYPE(item_obj)
    local char_belonging = TryGetProp(item_obj, 'CharacterBelonging', 0)

    local temp_tbl = {
        ["Seal"] = "seal",
        ["Ark"] = "ark",
        ["LEG"] = "leg",
        ["GODDESS"] = "god",
        ["sset_HairAcc_Acc1"] = "hair1",
        ["sset_HairAcc_Acc2"] = "hair2",
        ["sset_HairAcc_Acc3"] = "hair3",
        ["CORE"] = "core",
        ["Relic"] = "relic"

    }

    for key, value in pairs(temp_tbl) do
        if key == "Seal" and key == type and clsid ~= 614001 then
            cc_helper_settings_slot(frame, value, item_obj, iesid, clsid, image)
            return
        elseif key == "Ark" and key == type and char_belonging ~= 1 then
            cc_helper_settings_slot(frame, value, item_obj, iesid, clsid, image)
            return
        elseif key == "CORE" and key == type then
            cc_helper_settings_slot(frame, value, item_obj, iesid, clsid, image)
        elseif key == "Relic" and key == type then
            cc_helper_settings_slot(frame, value, item_obj, iesid, clsid, image)
            return
        elseif key == "LEG" and key == item_obj.CardGroupName then
            cc_helper_settings_slot(frame, value, item_obj, iesid, clsid, image)
        elseif key == "GODDESS" and key == item_obj.CardGroupName then
            cc_helper_settings_slot(frame, value, item_obj, iesid, clsid, image)
        elseif key == "sset_HairAcc_Acc1" and key == parent_name then
            local str = cc_helper_hair_option(item_obj)
            cc_helper_settings_slot(frame, value, item_obj, iesid, clsid, image, str)
        elseif key == "sset_HairAcc_Acc2" and key == parent_name then
            local str = cc_helper_hair_option(item_obj)
            cc_helper_settings_slot(frame, value, item_obj, iesid, clsid, image, str)
        elseif key == "sset_HairAcc_Acc3" and key == parent_name then
            local str = cc_helper_hair_option(item_obj)
            cc_helper_settings_slot(frame, value, item_obj, iesid, clsid, image, str)
            --[[elseif gemtype == "aether" and key == "aether" then
            for i = 1, 4 do
                if g.settings[g.cid][tostring(value) .. i].clsid == 0 then
                    cc_helper_settings_slot(frame, value .. i, item_obj, iesid, clsid, image)
                    break
                end
            end]]
        end
    end
end

-- putitem
function cc_helper_putitem(frame, in_btn, try, step)

    -- g.try = g.try or tonumber(try)

    local inventory = ui.GetFrame("inventory")
    -- local inventype_Tab = GET_CHILD_RECURSIVELY(inventory, "inventype_Tab")
    -- local index = inventype_Tab:GetSelectItemIndex()

    local in_btn = GET_CHILD_RECURSIVELY(inventory, "in_btn")

    if step == 0 then
        in_btn:SetUserValue("STEP", 0)

        g.god = nil
        in_btn:RunUpdateScript("cc_helper_unequip_card", 0.1)
    elseif step == 1 then

        local step = in_btn:GetUserIValue("STEP")
        in_btn:SetUserValue("STEP", 1)
        cc_helper_in_btn_start(in_btn)

    elseif step == 2 then
        in_btn:SetUserValue("STEP", 2)
        g.leg = nil
        local temp_tbl = {"hair1", "hair2", "hair3", "seal", "ark", "core"}
        g.delay = 0.8
        for _, equip in ipairs(temp_tbl) do
            if g.settings[g.cid][equip].clsid ~= 0 then
                g.delay = g.delay - 0.1
            end
        end
        if g.delay > 0.3 then
            g.delay = 0.3
        end

        in_btn:RunUpdateScript("cc_helper_unequip_card", g.delay)
    elseif step == 3 then

        local step = in_btn:GetUserIValue("STEP")
        in_btn:SetUserValue("STEP", 3)
        in_btn:RunUpdateScript("cc_helper_inv_to_warehouse", 0.2)

    elseif step == 4 then
        in_btn:SetUserValue("STEP", 4)
        cc_helper_in_btn_aethergem_mgr(in_btn)
    elseif step == 5 then
        in_btn:SetUserValue("STEP", 5)
        in_btn:RunUpdateScript("cc_helper_in_btn_equip", 0.1)
    elseif step == 6 then
        in_btn:SetUserValue("STEP", 6)
        in_btn:RunUpdateScript("cc_helper_gem_inv_to_warehouse_reserve", 0.1)
    elseif step == 7 then
        in_btn:SetUserValue("STEP", 7)
        in_btn:RunUpdateScript("cc_helper_end_of_operation", 0.1)
        -- cc_helper_end_of_operation(in_btn)
    end
end

function cc_helper_unequip_card(in_btn)

    local step = in_btn:GetUserIValue("STEP")
    local monstercardslot = ui.GetFrame("monstercardslot")
    if step == 0 then

        if g.settings[g.cid]["god"].clsid ~= 0 then
            local slot_index = 14
            -- local card_id = GETMYCARD_INFO(slot_index - 1)
            local card_info = equipcard.GetCardInfo(slot_index)

            if card_info ~= nil then
                local card_id = card_info:GetCardID()

                if card_id == g.settings[g.cid]["god"].clsid then

                    if monstercardslot:IsVisible() == 0 then
                        MONSTERCARDSLOT_FRAME_OPEN()
                    end

                    if not g.god then
                        g.god = true
                        local arg_str = slot_index - 1
                        arg_str = arg_str .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
                        pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", arg_str)
                        return 1
                    else
                        return 1
                    end
                end
            end
        end
        cc_helper_putitem(nil, in_btn, nil, 1)
        return 0
    elseif step == 2 then
        g.delay = nil
        if g.share_settings.eco_mode == 0 then
            if g.settings[g.cid]["leg"].clsid ~= 0 then
                local slot_index = 13
                -- local card_id = GETMYCARD_INFO(slot_index - 1)
                local card_info = equipcard.GetCardInfo(slot_index)

                if card_info ~= nil then
                    local card_id = card_info:GetCardID()

                    if card_id == g.settings[g.cid]["leg"].clsid then

                        if monstercardslot:IsVisible() == 0 then
                            MONSTERCARDSLOT_FRAME_OPEN()
                        end
                        if not g.leg then
                            g.leg = true
                            local arg_str = slot_index - 1
                            arg_str = arg_str .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
                            pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", arg_str)
                            return 1
                        else
                            return 1
                        end
                    end
                end
            end
        end

        cc_helper_putitem(nil, in_btn, nil, 3)
        return 0
    end
end

function cc_helper_in_btn_start(in_btn)

    local frame = ui.GetFrame("inventory")
    if true == BEING_TRADING_STATE() then
        return
    end

    local isEmptySlot = false
    if session.GetInvItemList():Count() < MAX_INV_COUNT then
        isEmptySlot = true
    end

    if isEmptySlot == true then
        in_btn:RunUpdateScript("cc_helper_unequip", 0.1)
    else
        ui.SysMsg(ScpArgMsg("Auto_inBenToLie_Bin_SeulLosi_PilyoHapNiDa."))
        return
    end

end

-- spot番号調べるコード
--[[local equipList = session.GetEquipItemList();
for i = 0, equipList:Count() - 1 do
    local equipItem = equipList:GetEquipItemByIndex(i);
    local spotName = item.GetEquipSpotName(equipItem.equipSpot);
    ts(i, spotName)

end]]

function cc_helper_unequip(in_btn)

    local frame = ui.GetFrame("inventory")
    local eqp_tab = GET_CHILD_RECURSIVELY(frame, "inventype_Tab")
    eqp_tab:SelectTab(1)
    local equip_tbl = {0, 20, 1, 25, 27, 29, 35}
    local temp_tbl = {"hair1", "hair2", "hair3", "seal", "ark", "relic", "core"}
    local equip_item_list = session.GetEquipItemList()
    for i, equip_index in ipairs(equip_tbl) do
        local equip_item = equip_item_list:GetEquipItemByIndex(equip_index)
        local iesid = equip_item:GetIESID()
        if iesid ~= "0" then
            if g.settings[g.cid][temp_tbl[i]].iesid == iesid then
                item.UnEquip(equip_index)
                return 1
            end
        end
    end
    in_btn:StopUpdateScript("cc_helper_unequip")
    cc_helper_putitem(nil, in_btn, nil, 2)
    return 0
end

function cc_helper_get_warehouse_count(check)
    local frame = ui.GetFrame("accountwarehouse")
    local accountObj = GetMyAccountObj()
    local warehouse_count = 0
    local max_count = 0
    local isTokenState = session.loginInfo.IsPremiumState(ITEM_TOKEN)
    if isTokenState == true then
        warehouse_count = accountObj.BasicAccountWarehouseSlotCount + accountObj.MaxAccountWarehouseCount +
                              accountObj.AccountWareHouseExtend + accountObj.AccountWareHouseExtendByItem +
                              ADDITIONAL_SLOT_COUNT_BY_TOKEN

        max_count = warehouse_count + 280
    else
        warehouse_count = accountObj.BasicAccountWarehouseSlotCount + accountObj.MaxAccountWarehouseCount +
                              accountObj.AccountWareHouseExtend + accountObj.AccountWareHouseExtendByItem
        max_count = warehouse_count
    end
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local guidList = itemList:GetGuidList()
    local sortedGuidList = itemList:GetSortedGuidList()
    local invItemCount = sortedGuidList:Count()

    if check ~= nil then
        return invItemCount, max_count
    end

    if invItemCount < max_count then
        return true
    else
        ui.SysMsg(ClMsg('CannotPutBecauseMaxSlot'))
        return false
    end

end

function cc_helper_checkvalid(iesid)
    local invItem = session.GetInvItemByGuid(iesid)

    local obj = GetIES(invItem:GetObject())
    local itemcnt, maxcount = cc_helper_get_warehouse_count("check")

    if maxcount <= itemcnt then

        ui.SysMsg(ClMsg('CannotPutBecauseMaxSlot'))
        return false
    end
    if true == invItem.isLockState then

        ui.SysMsg(ClMsg("MaterialItemIsLock"))

        return false
    end

    local itemCls = GetClassByType("Item", obj.ClassID)
    if itemCls.ItemType == 'Quest' then

        ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"))

        return false
    end

    local enableTeamTrade = TryGetProp(itemCls, "TeamTrade")
    if enableTeamTrade ~= nil and enableTeamTrade == "NO" then

        ui.SysMsg(ClMsg("ItemIsNotTradable"))

        return false

    end
    return true
end

function cc_helper_get_goal_index()
    local frame = ui.GetFrame("accountwarehouse")
    local tab = GET_CHILD(frame, "accountwarehouse_tab")
    local gbox = GET_CHILD_RECURSIVELY(frame, "gbox")

    local accountObj = GetMyAccountObj()
    local basecount = accountObj.BasicAccountWarehouseSlotCount + accountObj.MaxAccountWarehouseCount +
                          accountObj.AccountWareHouseExtend + accountObj.AccountWareHouseExtendByItem +
                          ADDITIONAL_SLOT_COUNT_BY_TOKEN

    local itemcnt, maxcount = cc_helper_get_warehouse_count("check")

    local function GetLeftCount(itemcnt)
        local length = #itemcnt:GetText()
        if length == 14 then
            return tonumber(string.sub(itemcnt:GetText(), length - 6, length - 6))
        else
            return tonumber(string.sub(itemcnt:GetText(), length - 7, length - 6))
        end
    end

    local function GetTabLeftCount(tab, gbox)
        local itemcnt = GET_CHILD(gbox, "itemcnt")
        return GetLeftCount(itemcnt)
    end

    local tabIndices = {4, 3, 2, 1, 0}

    for index = 1, #tabIndices do
        local i = tabIndices[index]
        tab:SelectTab(i)
        if i > 0 then
            local left = GetTabLeftCount(tab, gbox)
            if left < 70 then
                return basecount + i * 70
            end
        else
            local slotset = GET_CHILD_RECURSIVELY(frame, "slotset")
            for j = 1, basecount do
                local slot = slotset:GetSlotByIndex(j)
                AUTO_CAST(slot)
                if slot:GetIcon() == nil then
                    return j
                end
            end
        end
    end
end

-- treeの名前調べる
--[[local inventory = ui.GetFrame("inventory")
local inventree_Equip = GET_CHILD_RECURSIVELY(inventory, "inventree_Card")
local childNames = {}
local childCount = inventree_Equip:GetChildCount()
for i = 0, childCount - 1 do
    local child = inventree_Equip:GetChildByIndex(i)
    local child_name = child:GetName()
    local child_y = child:GetY()
    ts(child:GetY(), child:GetName())
end]]

function cc_helper_inv_to_warehouse(in_btn)

    if not cc_helper_get_warehouse_count() then
        return
    end
    -- local step = in_btn:GetUserIValue("STEP")
    local inventory = ui.GetFrame("inventory")
    local in_btn = GET_CHILD_RECURSIVELY(inventory, "in_btn")

    local accountwarehouse = ui.GetFrame("accountwarehouse")

    local handle = accountwarehouse:GetUserIValue('HANDLE')
    local inventype_Tab = GET_CHILD_RECURSIVELY(inventory, "inventype_Tab")

    local temp_tbl = {{
        key = "seal",
        value = "sset_Accessory_Seal"
    }, {
        key = "ark",
        value = "sset_Accessory_Ark"
    }, {
        key = "core",
        value = "sset_Accessory_Core"
    }, {
        key = "relic",
        value = "sset_Relic"
    }, {
        key = "hair1",
        value = "sset_HairAcc_Acc1"
    }, {
        key = "hair2",
        value = "sset_HairAcc_Acc2"
    }, {
        key = "hair3",
        value = "sset_HairAcc_Acc3"
    }, {
        key = "leg",
        value = "sset_Card_CardLeg"
    }, {
        key = "god",
        value = "sset_Card_CardGoddess"
    }}
    -- , "ark", "core", "hair1", "hair2", "hair3", "leg", "god"
    if accountwarehouse:IsVisible() == 1 then
        for i, data in ipairs(temp_tbl) do
            local key = data.key
            local value = data.value
            local iesid = g.settings[g.cid][key].iesid

            local inv_item = session.GetInvItemByGuid(iesid)

            if inv_item then

                if i <= 5 then
                    inventype_Tab:SelectTab(1)
                    local inventree_Equip = GET_CHILD_RECURSIVELY(inventory, "inventree_Equip")
                    local childNames = {}
                    local childCount = inventree_Equip:GetChildCount()
                    for j = 0, childCount - 1 do
                        local child = inventree_Equip:GetChildByIndex(j)
                        local child_name = child:GetName()
                        if child_name == value then

                            local child_y = child:GetY()
                            local treeGbox_Equip = GET_CHILD_RECURSIVELY(inventory, "treeGbox_Equip")
                            treeGbox_Equip:SetScrollPos(tonumber(child_y))
                            break
                        end
                    end

                else
                    inventype_Tab:SelectTab(4)
                    local inventree_Card = GET_CHILD_RECURSIVELY(inventory, "inventree_Card")
                    local childNames = {}
                    local childCount = inventree_Card:GetChildCount()
                    for j = 0, childCount - 1 do
                        local child = inventree_Card:GetChildByIndex(j)
                        local child_name = child:GetName()
                        if child_name == value then
                            local child_y = child:GetY()
                            local treeGbox_Card = GET_CHILD_RECURSIVELY(inventory, "treeGbox_Card")
                            treeGbox_Card:SetScrollPos(tonumber(child_y))
                            break
                        end
                    end
                end

                if cc_helper_checkvalid(iesid) then

                    local goal_index = cc_helper_get_goal_index()
                    local item_cls = GetClassByType('Item', g.settings[g.cid][key].clsid)

                    local item_name = item_cls.Name
                    local log = g.lang == "Japanese" and "倉庫に格納しました" .. "：[" .. "{#EE82EE}" ..
                                    item_name .. "{#FFFF00}]×" .. "{#EE82EE}1" or "Item to warehousing" .. "：[" ..
                                    "{#EE82EE}" .. item_name .. "{#FFFF00}]×" .. "{#EE82EE}1"
                    CHAT_SYSTEM(log)
                    item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, iesid, 1, handle, goal_index)
                    imcSound.PlaySoundEvent("sys_jam_slot_equip")
                    return 1
                end

            end

        end
    end
    in_btn:StopUpdateScript("cc_helper_inv_to_warehouse")
    cc_helper_putitem(nil, in_btn, nil, 4)
    return
end

function cc_helper_in_btn_aethergem_mgr(in_btn)

    local frame = ui.GetFrame("inventory")
    local equip_slots = {"RH", "LH", "RH_SUB", "LH_SUB"}
    if g.share_settings.eco_mode == 0 then
        if g.share_settings.all_agm == 0 then
            if g.settings[g.cid].agm_use == 1 then
                for _, slot_name in ipairs(equip_slots) do
                    local equip_slot = GET_CHILD_RECURSIVELY(frame, slot_name)
                    local icon = equip_slot:GetIcon()
                    if icon then
                        local icon_info = icon:GetInfo()
                        local gem_type = icon_info.type
                        local equip_item = session.GetEquipItemByType(gem_type)
                        local gem_id = equip_item:GetEquipGemID(2)

                        for i = 1, 4 do
                            local gemKey = "gem" .. i

                            if gem_id == g.settings[g.cid][gemKey].clsid then
                                cc_helper_msgbox_frame(in_btn)
                                return
                            end
                        end

                    end

                end
            end
        end
    end
    cc_helper_putitem(nil, in_btn, nil, 7)
end

function cc_helper_msgbox_frame(in_btn)

    if g.settings[g.cid].agm_check == 1 then
        local msg = g.lang == "Japanese" and "{ol}{#FFFFFF}エーテルジェムを付替えますか？" or
                        "{ol}{#FFFFFF}Would you like to swap Aether Gems?"
        local yes_scp = string.format("cc_helper_in_btn_agm_reserve('%s')", in_btn)
        local no_scp = string.format("cc_helper_end_of_operation('%s')", in_btn)
        ui.MsgBox(msg, yes_scp, no_scp)
    else
        cc_helper_in_btn_agm_reserve(in_btn)
    end
end

function cc_helper_in_btn_agm_reserve(in_btn)
    local inv_frame = ui.GetFrame("inventory")
    in_btn = GET_CHILD_RECURSIVELY(inv_frame, "in_btn")
    AUTO_CAST(in_btn)
    g.guid_tbl = {}
    local eq_count = 0
    local equips = {"RH_SUB", "LH_SUB", "RH", "LH"}
    local inv_frame = ui.GetFrame("inventory")
    for _, slot_name in ipairs(equips) do
        local equip_slot = GET_CHILD_RECURSIVELY(inv_frame, slot_name)
        local icon = equip_slot:GetIcon()
        if icon then
            local icon_info = icon:GetInfo()
            local iesid = icon_info:GetIESID()
            if not g.guid_tbl[slot_name] then
                g.guid_tbl[slot_name] = iesid
                eq_count = eq_count + 1
            end
        end
    end
    if eq_count == 4 then
        in_btn:RunUpdateScript("cc_helper_in_btn_agm", 0.1)
    else
        local msg = g.lang == "Japanese" and "{ol}武器4ヶ所着けてください" or
                        "{ol}Please equip weapons in 4 slots"
        ui.SysMsg(msg)
        -- end
        return
    end
end

function cc_helper_in_btn_agm(in_btn)

    local equips = {"RH_SUB", "LH_SUB", "RH", "LH"}
    local inv_frame = ui.GetFrame("inventory")
    for _, slot_name in ipairs(equips) do
        local equip_slot = GET_CHILD_RECURSIVELY(inv_frame, slot_name)
        local icon = equip_slot:GetIcon()
        if icon then
            if string.find(slot_name, "_SUB") then
                DO_WEAPON_SLOT_CHANGE(inv_frame, 2)
                item.UnEquip(30)
            else
                DO_WEAPON_SLOT_CHANGE(inv_frame, 1)
                if slot_name == "LH" then
                    item.UnEquip(9)
                elseif slot_name == "RH" then
                    item.UnEquip(8)
                end
            end
            return 1
        end
    end
    DO_WEAPON_SLOT_CHANGE(inv_frame, 1)
    local inv_tab = GET_CHILD_RECURSIVELY(inv_frame, "inventype_Tab")
    inv_tab:SelectTab(6)
    in_btn:SetUserValue("SPOT_NAME_", "RH")
    in_btn:StopUpdateScript("cc_helper_in_btn_agm")
    cc_helper_in_btn_agm_operation(in_btn)

    return 0

end

function cc_helper_in_btn_agm_operation(in_btn)

    local goddess_equip_manager = ui.GetFrame("goddess_equip_manager")

    if goddess_equip_manager:IsVisible() == 0 then
        goddess_equip_manager:ShowWindow(1)
        local main_tab = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'main_tab')
        main_tab:SelectTab(2)
        goddess_equip_manager:SetLayerLevel(101)
    end
    local spot_name = in_btn:GetUserValue("SPOT_NAME_")

    if spot_name == "RH" then
        in_btn:SetUserValue("SPOT_NAME_", "RH")
        in_btn:SetUserValue("IESID_", g.guid_tbl["RH"])
        in_btn:RunUpdateScript("cc_helper_GODDESS_MGR_SOCKET_REG_ITEM", 0.1)
    end
    if spot_name == "LH" then

        in_btn:SetUserValue("SPOT_NAME_", "LH")
        in_btn:SetUserValue("IESID_", g.guid_tbl["LH"])
        in_btn:RunUpdateScript("cc_helper_GODDESS_MGR_SOCKET_REG_ITEM", 0.1)
    end
    if spot_name == "RH_SUB" then

        in_btn:SetUserValue("SPOT_NAME_", "RH_SUB")
        in_btn:SetUserValue("IESID_", g.guid_tbl["RH_SUB"])
        in_btn:RunUpdateScript("cc_helper_GODDESS_MGR_SOCKET_REG_ITEM", 0.1)
    end
    if spot_name == "LH_SUB" then

        in_btn:SetUserValue("SPOT_NAME_", "LH_SUB")
        in_btn:SetUserValue("IESID_", g.guid_tbl["LH_SUB"])
        in_btn:RunUpdateScript("cc_helper_GODDESS_MGR_SOCKET_REG_ITEM", 0.1)

    end

end

function cc_helper_GODDESS_MGR_SOCKET_REG_ITEM(in_btn)
    local goddess_equip_manager = ui.GetFrame("goddess_equip_manager")
    local iesid = in_btn:GetUserValue("IESID_")
    local inv_item = session.GetInvItemByGuid(iesid)
    local item_obj = GetIES(inv_item:GetObject())

    if inv_item == nil or item_obj == nil then
        return
    end

    if item_goddess_transcend.is_able_to_socket(item_obj) == false then
        ui.SysMsg(ClMsg('WebService_38'))
        return
    end

    if TryGetProp(item_obj, 'ItemGrade', 0) < 6 then
        ui.SysMsg(ClMsg('GoddessGradeItemOnly'))
        return
    end

    local weapon_tooltip_title = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'weapon_tooltip_title')
    local weapon_tooltip = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'weapon_tooltip')
    local armor_tooltip_title = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'armor_tooltip_title')
    local armor_tooltip = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'armor_tooltip')

    weapon_tooltip_title:ShowWindow(1)
    weapon_tooltip:ShowWindow(1)
    armor_tooltip_title:ShowWindow(0)
    armor_tooltip:ShowWindow(0)

    local slot = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'socket_slot')
    SET_SLOT_ITEM(slot, inv_item)
    slot:SetUserValue('ITEM_GUID', inv_item:GetIESID())
    slot:SetUserValue('ITEM_USE_LEVEL', TryGetProp(item_obj, 'UseLv', 1))

    local slot_pic = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'socket_slot_bg_image')
    slot_pic:ShowWindow(0)

    local socket_item_text = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'socket_item_text')
    socket_item_text:ShowWindow(0)

    local socket_item_name = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'socket_item_name')
    socket_item_name:SetTextByKey('name', dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'NONE')))
    socket_item_name:ShowWindow(1)

    local open_mat_slot = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'aether_open_mat_slot')
    open_mat_slot:ClearIcon()

    GODDESS_MGR_SOCKET_AETHER_UPDATE(goddess_equip_manager)
    _GODDESS_MGR_SOCKET_REQ_GEM_REMOVE(2)

    inv_item = session.GetInvItemByGuid(iesid)
    local gem_id = inv_item:GetEquipGemID(2)
    if gem_id == nil or gem_id == 0 then
        local spot_name = in_btn:GetUserValue("SPOT_NAME_")
        if spot_name == "RH" then
            in_btn:SetUserValue("SPOT_NAME_", "LH")
        elseif spot_name == "LH" then
            in_btn:SetUserValue("SPOT_NAME_", "RH_SUB")
        elseif spot_name == "RH_SUB" then
            in_btn:SetUserValue("SPOT_NAME_", "LH_SUB")
        elseif spot_name == "LH_SUB" then
            in_btn:StopUpdateScript("cc_helper_GODDESS_MGR_SOCKET_REG_ITEM")
            in_btn:StopUpdateScript("cc_helper_in_btn_agm_operation")
            cc_helper_putitem(nil, in_btn, nil, 5)
            return 0
        end
        in_btn:StopUpdateScript("cc_helper_GODDESS_MGR_SOCKET_REG_ITEM")
        in_btn:RunUpdateScript("cc_helper_in_btn_agm_operation", 0.2)
        return 0
    else
        return 1
    end

end

function cc_helper_gem_inv_to_warehouse_reserve(in_btn)

    local gems = {}

    for i = 1, 4 do
        local clsid = g.settings[g.cid]["gem" .. i].clsid

        if not gems[clsid] then
            gems[clsid] = 1
        else
            gems[clsid] = gems[clsid] + 1
        end
    end

    session.ResetItemList()
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList()
    local cnt = guidList:Count()

    g.put_gem = {}
    local count = 0
    for i = 0, cnt - 1 do
        local iesid = guidList:Get(i)
        local inv_item = invItemList:GetItemByGuid(iesid)
        local type = inv_item.type
        local obj = GetIES(inv_item:GetObject())
        if gems[type] then
            local level = get_current_aether_gem_level(obj)
            table.insert(g.put_gem, {
                level = level,
                iesid = iesid,
                clsid = type
            })
            count = count + 1
        end
    end

    if count ~= 4 then
        return 1
    end

    table.sort(g.put_gem, function(a, b)
        return a.level > b.level
    end)

    local filtered_gems = {}
    local max_gems = 4
    for i, gem in ipairs(g.put_gem) do
        if i <= max_gems then
            if gems[gem.clsid] and gems[gem.clsid] > 0 then
                table.insert(filtered_gems, gem)
                gems[gem.clsid] = gems[gem.clsid] - 1
            end
        end
    end
    g.put_gem = filtered_gems
    in_btn:StopUpdateScript("cc_helper_gem_inv_to_warehouse_reserve")
    in_btn:RunUpdateScript("cc_helper_gem_inv_to_warehouse", 0.1)
end

function cc_helper_gem_inv_to_warehouse(in_btn)

    if not cc_helper_get_warehouse_count() then
        return
    end

    local accountwarehouse = ui.GetFrame("accountwarehouse")
    local handle = accountwarehouse:GetUserIValue('HANDLE')

    local inventory = ui.GetFrame("inventory")
    local gem_tab = GET_CHILD_RECURSIVELY(inventory, "inventype_Tab")
    if inventory:IsVisible() == 1 then
        gem_tab:SelectTab(6)
    end

    if accountwarehouse:IsVisible() == 1 then
        session.ResetItemList()
        local invItemList = session.GetInvItemList()
        local guidList = invItemList:GetGuidList()
        local cnt = guidList:Count()

        for i = 0, cnt - 1 do
            local guid = guidList:Get(i)
            local inv_item = invItemList:GetItemByGuid(guid)
            local item_obj = GetIES(inv_item:GetObject())
            -- local gem_level = get_current_aether_gem_level(item_obj)
            local type = item_obj.ClassID
            local item_cls = GetClassByType('Item', inv_item.type)
            local item_name = item_cls.Name

            for i, gem in pairs(g.put_gem) do
                local iesid = gem.iesid
                local clsid = gem.clsid

                if guid == iesid then
                    if cc_helper_checkvalid(iesid) then
                        local goal_index = cc_helper_get_goal_index()
                        local item_cls = GetClassByType('Item', clsid)
                        local item_name = item_cls.Name
                        local log = g.lang == "Japanese" and "倉庫に格納しました" .. "：[" .. "{#EE82EE}" ..
                                        item_name .. "{#FFFF00}]×" .. "{#EE82EE}1" or "Item to warehousing" .. "：[" ..
                                        "{#EE82EE}" .. item_name .. "{#FFFF00}]×" .. "{#EE82EE}1"
                        CHAT_SYSTEM(log)
                        item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, guid, 1, handle, goal_index)
                        return 1
                    end
                end
            end
        end
    end
    in_btn:StopUpdateScript("cc_helper_gem_inv_to_warehouse")
    cc_helper_putitem(nil, in_btn, nil, 7)
end

function cc_helper_in_btn_equip(in_btn)
    local equips = {"RH", "LH", "RH_SUB", "LH_SUB"}
    local inv_frame = ui.GetFrame("inventory")
    for _, slot_name in ipairs(equips) do
        local equip_slot = GET_CHILD_RECURSIVELY(inv_frame, slot_name)
        local icon = equip_slot:GetIcon()
        if not icon then
            local inv_item = session.GetInvItemByGuid(g.guid_tbl[slot_name])
            local inv_index = inv_item.invIndex
            if string.find(slot_name, "_SUB") then
                DO_WEAPON_SLOT_CHANGE(inv_frame, 2)
                item.Equip(inv_index, slot_name)
            else
                DO_WEAPON_SLOT_CHANGE(inv_frame, 1)
                if slot_name == "LH" then
                    item.Equip(inv_index, slot_name)
                elseif slot_name == "RH" then
                    item.Equip(inv_index, slot_name)
                end
            end
            return 1
        end
    end
    in_btn:StopUpdateScript("cc_helper_in_btn_equip")
    cc_helper_putitem(nil, in_btn, nil, 6)
end

function cc_helper_end_of_operation(btn)

    local goddess_equip_manager = ui.GetFrame("goddess_equip_manager")
    goddess_equip_manager:ShowWindow(0)
    local inv_frame = ui.GetFrame("inventory")
    local inv_tab = GET_CHILD_RECURSIVELY(inv_frame, "inventype_Tab")
    if inv_tab then
        inv_tab:SelectTab(0)
    end

    if g.share_settings.auto_close == 1 then

        local accountwarehouse = ui.GetFrame("accountwarehouse")

        -- ACCOUNTWAREHOUSE_CLOSE(accountwarehouse)
        accountwarehouse:RunUpdateScript("ACCOUNTWAREHOUSE_CLOSE", 1.0)
    end
    local monstercardslot = ui.GetFrame("monstercardslot")
    if monstercardslot:IsVisible() == 1 then
        -- MONSTERCARDSLOT_CLOSE(monstercardslot)
        monstercardslot:RunUpdateScript("MONSTERCARDSLOT_CLOSE", 1.0)
    end

    ui.SysMsg("{ol}[CCH]End of Operation")

    local btn_name = btn:GetName()
    if btn_name == "out_btn" then
        -- <uiframe name="companionlist" x="0" y="0" width="305" height="335">
        local save_clsid = g.settings[g.cid].pet.clsid
        if save_clsid ~= 0 then

            local companionlist = ui.GetFrame("companionlist")
            companionlist:Resize(0, 0)
            local summoned_pet = session.pet.GetSummonedPet()
            if not summoned_pet then
                ON_OPEN_COMPANIONLIST()
                companionlist:SetUserValue("FUNCTION_", "not")
                companionlist:RunUpdateScript("cc_helper_change_summoned_pet", 0.5)

            else -- Different
                local summoned_iesid = summoned_pet:GetStrGuid()
                local save_iesid = g.settings[g.cid].pet.iesid
                if summoned_iesid ~= save_iesid then
                    ON_OPEN_COMPANIONLIST()
                    companionlist:SetUserValue("FUNCTION_", "different")
                    companionlist:RunUpdateScript("cc_helper_change_summoned_pet", 0.5)

                end
            end
        end
    end

    return 0
end

function cc_helper_change_summoned_pet(companionlist)

    local save_iesid = g.settings[g.cid].pet.iesid
    local save_clsid = g.settings[g.cid].pet.clsid

    local state = companionlist:GetUserValue("FUNCTION_")

    local petList = session.pet.GetPetInfoVec()
    for i = 0, petList:size() - 1 do

        local info = petList:at(i)
        local obj = GetIES(info:GetObject())
        local id = obj.ClassID

        local setName = "_CTRLSET_" .. i
        local ctrlset = GET_CHILD_RECURSIVELY(companionlist, setName)

        if ctrlset then
            local slot = GET_CHILD_RECURSIVELY(ctrlset, "slot")
            local icon = slot:GetIcon()
            local iconInfo = icon:GetInfo()
            local pet_guid = iconInfo:GetIESID()

            if state == "not" then
                if pet_guid == save_iesid then
                    ICON_USE(icon)
                    break
                end
            elseif state == "different" then
                local summoned_pet = session.pet.GetSummonedPet()
                local summoned_iesid = summoned_pet:GetStrGuid()
                if pet_guid == summoned_iesid then
                    companionlist:SetUserValue("FUNCTION_", "not")
                    control.SummonPet(0, 0, 0)
                    return 1
                end
            end

        end
    end

    local function USE_COMPANION_ICON_AFTER_ACTION()
        local canClose = false;
        local frame = ui.GetFrame("pet_info");
        if frame ~= nil then
            -- 펫정보 창이 열리지 않은 상태라면 컴패니언 목록을 닫는다.
            if frame:IsVisible() == 0 then
                canClose = true;
            end
        else
            canClose = true;
        end

        if canClose == true then

            CLOSE_COMPANIONLIST();
            CLOSE_PETLIST();
        end
    end
    USE_COMPANION_ICON_AFTER_ACTION()
    companionlist:Resize(305, 335)
    return 0
end

-- takeitem
function cc_helper_take_item(frame, out_btn, str, step)

    local inv_frame = ui.GetFrame("inventory")
    local out_btn = GET_CHILD_RECURSIVELY(inv_frame, "out_btn")
    if step == 0 then
        out_btn:SetUserValue("STEP", 0)
        out_btn:RunUpdateScript("cc_helper_equip_take_warehouse_item", 0.1)
    elseif step == 1 then
        out_btn:SetUserValue("STEP", 1)
        out_btn:SetUserValue("TRY", 1)
        out_btn:RunUpdateScript("cc_helper_equip_card", 0.1)
    elseif step == 2 then

        out_btn:SetUserValue("STEP", 2)
        cc_helper_equips_reserve(out_btn)

    elseif step == 3 then
        out_btn:SetUserValue("STEP", 3)
        out_btn:RunUpdateScript("cc_helper_equip_card", 0.1)
    elseif step == 4 then
        out_btn:SetUserValue("STEP", 4)
        out_btn:RunUpdateScript("cc_helper_take_agm_reserve", 0.1)
        -- cc_helper_take_agm_reserve(out_btn)
    elseif step == 5 then
        out_btn:SetUserValue("STEP", 5)
        out_btn:RunUpdateScript("cc_helper_out_btn_agm_reserve", 0.1)
        -- cc_helper_out_btn_agm_reserve(out_btn)
    elseif step == 6 then
        out_btn:SetUserValue("STEP", 6)
        out_btn:RunUpdateScript("cc_helper_out_btn_equip", 0.1)
    elseif step == 7 then
        out_btn:SetUserValue("STEP", 7)
        cc_helper_end_of_operation(out_btn)
    end
end

function cc_helper_out_btn_equip(out_btn)
    local equips = {"RH", "LH", "RH_SUB", "LH_SUB"}
    local inv_frame = ui.GetFrame("inventory")
    for _, slot_name in ipairs(equips) do
        local equip_slot = GET_CHILD_RECURSIVELY(inv_frame, slot_name)
        local icon = equip_slot:GetIcon()
        if not icon then
            local inv_item = session.GetInvItemByGuid(g.guid_tbl[slot_name])
            local inv_index = inv_item.invIndex
            if string.find(slot_name, "_SUB") then
                DO_WEAPON_SLOT_CHANGE(inv_frame, 2)
                item.Equip(inv_index, slot_name)
            else
                DO_WEAPON_SLOT_CHANGE(inv_frame, 1)
                if slot_name == "LH" then
                    item.Equip(inv_index, slot_name)
                elseif slot_name == "RH" then
                    item.Equip(inv_index, slot_name)
                end
            end
            return 1
        end
    end
    out_btn:StopUpdateScript("cc_helper_out_btn_equip")
    cc_helper_take_item(nil, out_btn, nil, 7)
end

function cc_helper_out_btn_agm_reserve(out_btn)

    g.guid_tbl = {}
    local eq_count = 0
    local equips = {"RH_SUB", "LH_SUB", "RH", "LH"}
    local inv_frame = ui.GetFrame("inventory")
    for _, slot_name in ipairs(equips) do
        local equip_slot = GET_CHILD_RECURSIVELY(inv_frame, slot_name)
        local icon = equip_slot:GetIcon()
        if icon then
            local icon_info = icon:GetInfo()
            local iesid = icon_info:GetIESID()
            if not g.guid_tbl[slot_name] then
                g.guid_tbl[slot_name] = iesid
                eq_count = eq_count + 1
            end
        end
    end

    if eq_count == 4 then
        out_btn:RunUpdateScript("cc_helper_out_btn_agm", 0.1)
        return
    end

    local msg = g.lang == "Japanese" and "{ol}武器4ヶ所着けてください" or
                    "{ol}Please equip weapons in 4 slots"
    ui.SysMsg(msg)
    cc_helper_take_item(nil, out_btn, nil, 7) -- ここでエンドもありえる

end

function cc_helper_out_btn_agm(out_btn)

    local equips = {"RH_SUB", "LH_SUB", "RH", "LH"}
    local inv_frame = ui.GetFrame("inventory")
    for _, slot_name in ipairs(equips) do
        local equip_slot = GET_CHILD_RECURSIVELY(inv_frame, slot_name)
        local icon = equip_slot:GetIcon()
        if icon then
            if string.find(slot_name, "_SUB") then
                DO_WEAPON_SLOT_CHANGE(inv_frame, 2)
                item.UnEquip(30)
            else
                DO_WEAPON_SLOT_CHANGE(inv_frame, 1)
                if slot_name == "LH" then
                    item.UnEquip(9)
                elseif slot_name == "RH" then
                    item.UnEquip(8)
                end
            end
            return 1
        end
    end
    DO_WEAPON_SLOT_CHANGE(inv_frame, 1)
    local inv_tab = GET_CHILD_RECURSIVELY(inv_frame, "inventype_Tab")
    inv_tab:SelectTab(6)
    out_btn:SetUserValue("SPOT_NAME_", "RH")
    out_btn:StopUpdateScript("cc_helper_out_btn_agm")
    cc_helper_out_btn_agm_operation(out_btn)
    return 0

end

function cc_helper_out_btn_agm_operation(out_btn)

    local goddess_equip_manager = ui.GetFrame("goddess_equip_manager")

    if goddess_equip_manager:IsVisible() == 0 then
        goddess_equip_manager:ShowWindow(1)
        local main_tab = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'main_tab')
        main_tab:SelectTab(2)
        goddess_equip_manager:SetLayerLevel(101)
    end
    local spot_name = out_btn:GetUserValue("SPOT_NAME_")

    if spot_name == "RH" then
        out_btn:SetUserValue("SPOT_NAME_", "RH")
        out_btn:SetUserValue("IESID_", g.guid_tbl["RH"])
        out_btn:RunUpdateScript("cc_helper_out_btn_GODDESS_MGR_SOCKET_REG_ITEM", 0.1)
    end
    if spot_name == "LH" then

        out_btn:SetUserValue("SPOT_NAME_", "LH")
        out_btn:SetUserValue("IESID_", g.guid_tbl["LH"])
        out_btn:RunUpdateScript("cc_helper_out_btn_GODDESS_MGR_SOCKET_REG_ITEM", 0.1)
    end
    if spot_name == "RH_SUB" then

        out_btn:SetUserValue("SPOT_NAME_", "RH_SUB")
        out_btn:SetUserValue("IESID_", g.guid_tbl["RH_SUB"])
        out_btn:RunUpdateScript("cc_helper_out_btn_GODDESS_MGR_SOCKET_REG_ITEM", 0.1)
    end
    if spot_name == "LH_SUB" then

        out_btn:SetUserValue("SPOT_NAME_", "LH_SUB")
        out_btn:SetUserValue("IESID_", g.guid_tbl["LH_SUB"])
        out_btn:RunUpdateScript("cc_helper_out_btn_GODDESS_MGR_SOCKET_REG_ITEM", 0.1)

    end

end

function cc_helper_out_btn_GODDESS_MGR_SOCKET_REG_ITEM(out_btn)

    local goddess_equip_manager = ui.GetFrame("goddess_equip_manager")
    local iesid = out_btn:GetUserValue("IESID_")
    local inv_item = session.GetInvItemByGuid(iesid)
    local item_obj = GetIES(inv_item:GetObject())

    if inv_item == nil or item_obj == nil then
        return
    end

    if item_goddess_transcend.is_able_to_socket(item_obj) == false then
        ui.SysMsg(ClMsg('WebService_38'))
        return
    end

    if TryGetProp(item_obj, 'ItemGrade', 0) < 6 then
        ui.SysMsg(ClMsg('GoddessGradeItemOnly'))
        return
    end

    local weapon_tooltip_title = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'weapon_tooltip_title')
    local weapon_tooltip = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'weapon_tooltip')
    local armor_tooltip_title = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'armor_tooltip_title')
    local armor_tooltip = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'armor_tooltip')

    weapon_tooltip_title:ShowWindow(1)
    weapon_tooltip:ShowWindow(1)
    armor_tooltip_title:ShowWindow(0)
    armor_tooltip:ShowWindow(0)

    local slot = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'socket_slot')
    SET_SLOT_ITEM(slot, inv_item)
    slot:SetUserValue('ITEM_GUID', inv_item:GetIESID())
    slot:SetUserValue('ITEM_USE_LEVEL', TryGetProp(item_obj, 'UseLv', 1))

    local slot_pic = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'socket_slot_bg_image')
    slot_pic:ShowWindow(0)

    local socket_item_text = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'socket_item_text')
    socket_item_text:ShowWindow(0)

    local socket_item_name = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'socket_item_name')
    socket_item_name:SetTextByKey('name', dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'NONE')))
    socket_item_name:ShowWindow(1)

    local open_mat_slot = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'aether_open_mat_slot')
    open_mat_slot:ClearIcon()

    GODDESS_MGR_SOCKET_AETHER_UPDATE(goddess_equip_manager)
    session.ResetItemList()

    session.AddItemID(iesid, 1)
    for _, gem_data in pairs(g.take_gem) do
        local gem_iesid = gem_data.iesid
        local inv_item = session.GetInvItemByGuid(gem_iesid)
        if inv_item then
            session.AddItemID(tostring(gem_iesid), 1)
            break
        end
    end

    local arg_list = NewStringList()
    arg_list:Add(tostring(2))

    local result_list = session.GetItemIDList()

    item.DialogTransaction('GODDESS_SOCKET_AETHER_GEM_EQUIP', result_list, '', arg_list)
    -- _GODDESS_MGR_SOCKET_REQ_GEM_REMOVE(2)

    inv_item = session.GetInvItemByGuid(iesid)
    local gem_id = inv_item:GetEquipGemID(2)
    if gem_id ~= 0 then
        local spot_name = out_btn:GetUserValue("SPOT_NAME_")
        if spot_name == "RH" then
            out_btn:SetUserValue("SPOT_NAME_", "LH")
        elseif spot_name == "LH" then
            out_btn:SetUserValue("SPOT_NAME_", "RH_SUB")
        elseif spot_name == "RH_SUB" then
            out_btn:SetUserValue("SPOT_NAME_", "LH_SUB")
        elseif spot_name == "LH_SUB" then
            out_btn:StopUpdateScript("cc_helper_out_btn_GODDESS_MGR_SOCKET_REG_ITEM")
            out_btn:StopUpdateScript("cc_helper_out_btn_agm_operation")
            cc_helper_take_item(nil, out_btn, nil, 6)
            return 0
        end
        out_btn:StopUpdateScript("cc_helper_out_btn_GODDESS_MGR_SOCKET_REG_ITEM")
        out_btn:RunUpdateScript("cc_helper_out_btn_agm_operation", 0.1)
        return 0
    else
        return 1
    end

end

function cc_helper_take_agm_reserve(out_btn)

    if g.share_settings.eco_mode == 0 then
        if g.share_settings.all_agm == 0 then
            if g.settings[g.cid].agm_use == 1 then
                local equipSlots = {"RH", "LH", "RH_SUB", "LH_SUB"}
                local found_count = 0
                local inventory = ui.GetFrame("inventory")

                for _, slot_name in ipairs(equipSlots) do
                    local equipSlot = GET_CHILD_RECURSIVELY(inventory, slot_name)
                    local icon = equipSlot:GetIcon()

                    if icon then
                        local icon_info = icon:GetInfo()
                        local guid = icon_info:GetIESID()
                        local equip_item = session.GetEquipItemByGuid(guid)
                        local gem_id = equip_item:GetEquipGemID(2)
                        if gem_id == 0 then
                            found_count = found_count + 1
                        end
                    end
                end

                if found_count == 4 then
                    if g.settings[g.cid].agm_check == 1 then
                        local msg = g.lang == "Japanese" and
                                        "{ol}{#FFFFFF}エーテルジェムを付替えますか？" or
                                        "{ol}{#FFFFFF}Would you like to swap Aether Gems?"
                        local yes_scp = string.format("cc_helper_take_agm('%s')", out_btn)
                        local no_scp = string.format("cc_helper_end_of_operation('%s')", out_btn)
                        ui.MsgBox(msg, yes_scp, no_scp)
                        return
                    else
                        cc_helper_take_agm(out_btn)
                        return
                    end
                end
            end
        end
    end
    cc_helper_take_item(nil, out_btn, nil, 7)
end

function cc_helper_take_agm(out_btn)

    local gems = {}
    for i = 1, 4 do
        local clsid = g.settings[g.cid]["gem" .. i].clsid
        if not gems[clsid] then
            gems[clsid] = 1
        else
            gems[clsid] = gems[clsid] + 1
        end
    end

    g.take_gem = {}

    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local sortedGuidList = itemList:GetSortedGuidList()
    local sortedCnt = sortedGuidList:Count()
    local fromframe = ui.GetFrame("accountwarehouse")
    local handle = fromframe:GetUserIValue("HANDLE")

    for i = 0, sortedCnt - 1 do
        local iesid = sortedGuidList:Get(i)
        local inv_item = itemList:GetItemByGuid(iesid)
        local type = inv_item.type
        local obj = GetIES(inv_item:GetObject())
        if gems[type] then
            local level = get_current_aether_gem_level(obj)
            table.insert(g.take_gem, {
                level = level,
                iesid = iesid,
                clsid = type
            })
        end
    end

    table.sort(g.take_gem, function(a, b)
        return a.level > b.level
    end)

    if #g.take_gem < 4 then
        local msg = g.lang == "Japanese" and "{ol}指定のエーテルジェムが4個倉庫にありません" or
                        "{ol}You don't have 4 of the Aether Gems in your Storage"
        ui.SysMsg(msg)
        cc_helper_take_item(nil, out_btn, nil, 7)
        return -- ここでエンドもありえる
    end

    if #g.take_gem > 4 then
        local kept_gems = {}
        for i = 1, 4 do

            table.insert(kept_gems, g.take_gem[i])
        end
        g.take_gem = kept_gems
    end

    session.ResetItemList()
    for _, gem_data in pairs(g.take_gem) do
        local iesid = gem_data.iesid
        session.AddItemID(tostring(iesid), 1)
    end
    item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), handle)

    cc_helper_take_item(nil, out_btn, nil, 5)
end

function cc_helper_equips_reserve(out_btn)
    g.equip_tbl = {{
        ["HAT"] = "hair1"
    }, {
        ["HAT_T"] = "hair2"
    }, {
        ["HAT_L"] = "hair3"
    }, {
        ["SEAL"] = "seal"
    }, {
        ["ARK"] = "ark"
    }, {
        ["RELIC"] = "relic"
    }, {
        ["CORE"] = "core"
    }}

    out_btn:RunUpdateScript("cc_helper_equips", 0.1)
end

function cc_helper_equips(out_btn)

    local inventory = ui.GetFrame("inventory")
    local inv_tab = GET_CHILD_RECURSIVELY(inventory, "inventype_Tab")
    inv_tab:SelectTab(1)

    for i, data in ipairs(g.equip_tbl) do
        for spot, equip in pairs(data) do
            local guid = g.settings[g.cid][equip].iesid

            local inv_item = session.GetInvItemByGuid(guid)

            if inv_item then
                local equip_slot = GET_CHILD_RECURSIVELY(inventory, spot)
                local icon = equip_slot:GetIcon()
                if not icon then
                    local item_index = inv_item.invIndex
                    ITEM_EQUIP(item_index, spot)
                    return 1
                end
            end
        end
    end

    out_btn:StopUpdateScript("cc_helper_equips")
    cc_helper_take_item(nil, out_btn, nil, 3)
end

function Cc_helper_equip_card(out_btn)
    local inventory = ui.GetFrame("inventory")
    local monstercardslot = ui.GetFrame("monstercardslot")
    local step = out_btn:GetUserIValue("STEP")
    local try = out_btn:GetUserIValue("TRY")
    if step == 1 then
        local card_index = 13
        local card_id = GETMYCARD_INFO(card_index)
        if card_id == 0 then
            local iesid = g.cc_helper_settings[g.cid].items["god"].iesid
            if iesid ~= "" then
                local inv_item = session.GetInvItemByGuid(iesid)
                if inv_item then
                    local inv_tab = GET_CHILD_RECURSIVELY(inventory, "inventype_Tab")
                    inv_tab:SelectTab(4)
                    MONSTERCARDSLOT_FRAME_OPEN()
                    local arg_str = string.format("%d#%s", card_index, tostring(iesid))
                    pc.ReqExecuteTx("SCR_TX_EQUIP_CARD_SLOT", arg_str)
                    return 1
                elseif not inv_item and try <= 5 then
                    try = try + 1
                    out_btn:SetUserValue("TRY", try)
                    return 1
                end
            end
        end
        out_btn:StopUpdateScript("cc_helper_equip_card")
        Cc_helper_take_item(nil, out_btn, nil, 2)
    elseif step == 3 then
        if g.cc_helper_settings.etc.eco == 0 then
            local card_index = 12
            local card_id = GETMYCARD_INFO(card_index)
            if card_id == 0 then
                local iesid = g.cc_helper_settings[g.cid].items["leg"].iesid
                if iesid ~= "" then
                    local inv_item = session.GetInvItemByGuid(iesid)
                    if inv_item then
                        local inv_tab = GET_CHILD_RECURSIVELY(inventory, "inventype_Tab")
                        inv_tab:SelectTab(4)
                        if monstercardslot:IsVisible() == 0 then
                            MONSTERCARDSLOT_FRAME_OPEN()
                        end
                        local arg_str = string.format("%d#%s", card_index, tostring(iesid))
                        pc.ReqExecuteTx("SCR_TX_EQUIP_CARD_SLOT", arg_str)
                        return 1
                    end
                end
            end
        end
        out_btn:StopUpdateScript("cc_helper_equip_card")
        Cc_helper_take_item(nil, out_btn, nil, 4)
    end
end

--[=[function cc_helper_equip_card(out_btn)
    local inventory = ui.GetFrame("inventory")
    local monstercardslot = ui.GetFrame("monstercardslot")

    local step = out_btn:GetUserIValue("STEP")
    local try = out_btn:GetUserIValue("TRY")
    if step == 1 then
        local card_index = 13
        local card_id = GETMYCARD_INFO(card_index)
        if card_id == 0 then
            local iesid = g.settings[g.cid]["god"].iesid
            if iesid ~= "" then
                local inv_item = session.GetInvItemByGuid(iesid)
                if inv_item then
                    local inv_tab = GET_CHILD_RECURSIVELY(inventory, "inventype_Tab")
                    inv_tab:SelectTab(4)

                    MONSTERCARDSLOT_FRAME_OPEN()
                    local arg_str = string.format("%d#%s", card_index, tostring(iesid))
                    pc.ReqExecuteTx("SCR_TX_EQUIP_CARD_SLOT", arg_str)
                    return 1
                elseif not inv_item and try <= 3 then
                    try = try + 1
                    out_btn:SetUserValue("TRY", try)
                    return 1
                end
            end
        end
        out_btn:StopUpdateScript("cc_helper_equip_card")
        cc_helper_take_item(nil, out_btn, nil, 2)

    elseif step == 3 then
        if g.share_settings.eco_mode == 0 then
            local card_index = 12
            local card_id = GETMYCARD_INFO(card_index)

            if card_id == 0 then
                local iesid = g.settings[g.cid]["leg"].iesid
                if iesid ~= "" then
                    local inv_item = session.GetInvItemByGuid(iesid)
                    if inv_item then
                        local inv_tab = GET_CHILD_RECURSIVELY(inventory, "inventype_Tab")
                        inv_tab:SelectTab(4)
                        if monstercardslot:IsVisible() == 0 then
                            MONSTERCARDSLOT_FRAME_OPEN()
                        end
                        local arg_str = string.format("%d#%s", card_index, tostring(iesid))
                        pc.ReqExecuteTx("SCR_TX_EQUIP_CARD_SLOT", arg_str)
                        return 1
                    end
                end

            end
        end
        --[[if monstercardslot:IsVisible() == 1 then
            monstercardslot:RunUpdateScript("MONSTERCARDSLOT_CLOSE", 1.0)
        end]]
        out_btn:StopUpdateScript("cc_helper_equip_card")
        cc_helper_take_item(nil, out_btn, nil, 4)
    end

end]=]

function cc_helper_equip_take_warehouse_item(out_btn)

    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local sortedGuidList = itemList:GetSortedGuidList()
    local sortedCnt = sortedGuidList:Count()
    local accountwarehouse = ui.GetFrame("accountwarehouse")
    local handle = accountwarehouse:GetUserIValue("HANDLE")

    local temp_tbl = {"seal", "ark", "relic", "core", "leg", "god", "hair1", "hair2", "hair3"}
    if g.share_settings.eco_mode == 1 then
        temp_tbl = {"seal", "ark", "relic", "core", "god", "hair1", "hair2", "hair3"}
    end

    local iesids = {}
    session.ResetItemList()
    for _, equip in pairs(temp_tbl) do

        local iesid = g.settings[g.cid][equip].iesid
        if iesid ~= "" then
            local inv_item = itemList:GetItemByGuid(iesid)
            if inv_item ~= nil then
                session.AddItemID(tonumber(iesid), 1)
                table.insert(iesids, iesid)
            end
        end
    end
    item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), handle)

    local count = #iesids
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList()
    local cnt = guidList:Count()

    for i = 0, cnt - 1 do
        local guid = guidList:Get(i)
        local inv_item = invItemList:GetItemByGuid(guid)

        if inv_item then

            for _, target_iesid in ipairs(iesids) do
                if guid == target_iesid then
                    count = count - 1
                    break
                end
            end

        end
    end

    local equip_item_list = session.GetEquipItemList();
    local equip_guid_list = equip_item_list:GetGuidList();
    local eq_count = equip_guid_list:Count();
    for i = 0, eq_count - 1 do
        local guid = equip_guid_list:Get(i);
        for _, target_iesid in ipairs(iesids) do
            if guid == target_iesid then
                count = count - 1
                break
            end
        end
    end

    if count == 0 then

        out_btn:StopUpdateScript("cc_helper_equip_take_warehouse_item")
        cc_helper_take_item(nil, out_btn, nil, 1)
    else
        return 1
    end
end
--[[g.settings_path = string.format('../addons/%s/%s/settings_250621.json', addon_name_lower, g.active_id)

function g.mkdir_new_folder()
    local folder_path = string.format("../addons/%s", addon_name_lower)
    local file_path = string.format("../addons/%s/mkdir.txt", addon_name_lower)
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
g.mkdir_new_folder()]]
