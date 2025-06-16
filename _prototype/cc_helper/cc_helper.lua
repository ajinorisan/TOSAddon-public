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
local addonName = "CC_HELPER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.3.2"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")
local json = require('json')
local base = {}

local active_id = session.loginInfo.GetAID()
-- 
g.settings_location = string.format('../addons/%s/settings.json', addonNameLower)

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName]
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

function cc_helper_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function cc_helper_load_settings()

    local start_time = os.clock()

    local share_settings = acutil.loadJSON(g.settings_location)

    if not share_settings then
        share_settings = {
            delay = 0.3,
            eco_mode = 0,
            auto_close = 1,
            all_agm = 0
        }

    end
    if not share_settings.all_agm then
        share_settings.all_agm = 0
    end
    g.share_settings = share_settings
    acutil.saveJSON(g.settings_location, g.share_settings)

    g.settingsFileLoc = string.format('../addons/%s/%s.json', addonNameLower, g.cid)

    local settings = acutil.loadJSON(g.settingsFileLoc)

    if not settings then
        settings = {}
    end

    local pc_info = session.barrack.GetMyAccount():GetByStrCID(g.cid)
    local pc_apc = pc_info:GetApc()
    local jobid = pc_info:GetRepID() or pc_apc:GetJob()
    local gender = pc_apc:GetGender()

    if not settings[g.cid] then
        local temp_tbl = {"name", "mcc_use", "agm_use", "agm_check", "seal", "ark", "leg", "god", "hair1", "hair2",
                          "hair3", "gem1", "gem2", "gem3", "gem4", "gender", "jobid"}
        settings[g.cid] = {}

        for i, key in ipairs(temp_tbl) do
            if key == "name" then
                settings[g.cid][key] = g.login_name
            elseif key == "mcc_use" then
                settings[g.cid][key] = 0
            elseif key == "agm_use" then
                settings[g.cid][key] = 0
            elseif key == "agm_check" then
                settings[g.cid][key] = 1
            elseif key == "gender" then
                settings[g.cid][key] = gender
            elseif key == "jobid" then
                settings[g.cid][key] = jobid
            else
                settings[g.cid][key] = {
                    iesid = "",
                    clsid = 0,
                    image = "",
                    skin = "",
                    memo = ""
                }
            end
        end

    end

    g.settings = settings

    local end_time = os.clock()
    local elapsed_time = end_time - start_time

    cc_helper_save_settings()

end

function cc_helper_function_check()
    local functionName = "AETHERGEM_MGR_ON_INIT" -- チェックしたい関数の名前を文字列として指定します
    if type(_G[functionName]) == "function" then
        g.agm_func = true
        g.agm = true
    else
        g.agm = false
        if g.settings[g.cid].agm_use then
            g.settings[g.cid].agm_use = 0
        end
    end

    if g.share_settings.all_agm and g.share_settings.all_agm == 1 then
        g.agm = false
    else
        local found = false
        for k, v in pairs(g.settings[g.cid]) do
            if string.find(k, "gem") and type(v) == "table" then
                for k2, v2 in pairs(v) do
                    if k2 == "clsid" then
                        if v2 > 0 then
                            found = true
                        end

                    end
                end
            end
        end

        if g.settings[g.cid].agm_use == 1 or found == false then
            g.agm = true
        else
            g.agm = false
        end
    end

    local functionName = "MONSTERCARD_CHANGE_ON_INIT" -- チェックしたい関数の名前を文字列として指定します
    if type(_G[functionName]) == "function" then
        g.mcc = true
    else
        g.mcc = false
        if g.settings[g.cid].mcc_use then
            g.settings[g.cid].mcc_use = 0
        end
    end

end

function CC_HELPER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.cid = info.GetCID(session.GetMyHandle())
    g.lang = option.GetCurrentCountry()
    g.login_name = session.GetMySession():GetPCApc():GetName()

    local pc = GetMyPCObject()
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        cc_helper_load_settings()
        acutil.setupEvent(addon, "ACCOUNTWAREHOUSE_CLOSE", "cc_helper_ACCOUNTWAREHOUSE_CLOSE")
        acutil.setupEvent(addon, "INVENTORY_CLOSE", "cc_helper_settings_close")
        acutil.setupEvent(addon, "UI_TOGGLE_INVENTORY", "cc_helper_invframe_init")
        acutil.setupEvent(addon, "INVENTORY_OPEN", "cc_helper_invframe_init")
        addon:RegisterMsg("OPEN_DLG_ACCOUNTWAREHOUSE", "cc_helper_accountwarehouse_init")
        addon:RegisterMsg("GAME_START", "cc_helper_function_check")
    end

end

function cc_helper_invframe_init()

    local invframe = ui.GetFrame("inventory")

    local setbtn = invframe:CreateOrGetControl("button", "set", 205, 345, 30, 30)
    AUTO_CAST(setbtn)
    setbtn:SetSkinName("None")
    setbtn:SetText("{img config_button_normal 30 30}")
    setbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_setting_frame_init")
    setbtn:SetTextTooltip(g.lang == "Japanese" and
                              "Character Change Helper{nl}マウス左ボタンクリック、キャラ毎に出し入れするアイテム設定。" or
                              "Character Change Helper{nl}Left mouse button click,{nl}setting items to be moved in and out for each character.")

    local awhframe = ui.GetFrame("accountwarehouse")
    if awhframe:IsVisible() == 1 then
        local in_btn = invframe:CreateOrGetControl("button", "in_btn", 235, 345, 30, 30)
        AUTO_CAST(in_btn)
        in_btn:SetText("{img in_arrow 20 20}")
        in_btn:SetEventScript(ui.LBUTTONUP, "cc_helper_putitem")

        in_btn:ShowWindow(1)
        in_btn:SetSkinName("test_pvp_btn")
        in_btn:SetTextTooltip(g.lang == "Japanese" and
                                  "Character Change Helper{nl}装備を外して倉庫へ搬入します。" or
                                  "Character Change Helper{nl}The equipment is removed and brought into the warehouse.")

        local out_btn = invframe:CreateOrGetControl("button", "out_btn", 265, 345, 30, 30)
        AUTO_CAST(out_btn)
        out_btn:SetText("{@st66b}{img chul_arrow 20 20}")
        -- !
        -- out_btn:SetEventScript(ui.LBUTTONUP, "cc_helper_out_btn_start")
        out_btn:SetEventScript(ui.LBUTTONUP, "cc_helper_take_item")
        out_btn:ShowWindow(1)
        out_btn:SetSkinName("test_pvp_btn")
        out_btn:SetTextTooltip(g.lang == "Japanese" and
                                   "Character Change Helper{nl}倉庫から搬出して装備します。" or
                                   "Character Change Helper{nl}It is carried out from the warehouse and equipped.")
    end
end

function cc_helper_accountwarehouse_init()

    local awhframe = ui.GetFrame("accountwarehouse")

    local in_btn = awhframe:CreateOrGetControl("button", "in_btn", 565, 120, 30, 30)
    AUTO_CAST(in_btn)
    in_btn:SetText("{img in_arrow 20 20}")
    in_btn:SetEventScript(ui.LBUTTONUP, "cc_helper_in_btn_aethergem_mgr")
    in_btn:ShowWindow(1)
    in_btn:SetSkinName("test_pvp_btn")
    in_btn:SetTextTooltip(g.lang == "Japanese" and
                              "Character Change Helper{nl}装備を外して倉庫へ搬入します。" or
                              "Character Change Helper{nl}The equipment is removed and brought into the warehouse.")

    local out_btn = awhframe:CreateOrGetControl("button", "out_btn", 595, 120, 30, 30)
    AUTO_CAST(out_btn)
    out_btn:SetText("{@st66b}{img chul_arrow 20 20}")
    out_btn:SetEventScript(ui.LBUTTONUP, "cc_helper_out_btn_start")
    out_btn:ShowWindow(1)
    out_btn:SetSkinName("test_pvp_btn")
    out_btn:SetTextTooltip(g.lang == "Japanese" and
                               "Character Change Helper{nl}倉庫から搬出して装備します。" or
                               "Character Change Helper{nl}It is carried out from the warehouse and equipped.")

    local auto_close = awhframe:CreateOrGetControl("checkbox", "auto_close", 540, 120, 30, 30)
    AUTO_CAST(auto_close)
    auto_close:ShowWindow(1)
    auto_close:SetTextTooltip(
        g.lang == "Japanese" and "動作終了後倉庫とインベントリーを閉じます。" or
            "After the operation is completed,{nl}the warehouse and inventory are closed.")
    auto_close:SetEventScript(ui.LBUTTONUP, "cc_helper_check_setting")
    auto_close:SetCheck(g.share_settings.auto_close)

    -- if _G.ADDONS.norisan.monstercard_change ~= nil then
    if g.mcc then
        local mccbtn = awhframe:CreateOrGetControl("button", "mcc", 625, 120, 30, 30)
        AUTO_CAST(mccbtn)
        mccbtn:SetSkinName("test_red_button")
        mccbtn:SetTextAlign("right", "center")
        mccbtn:SetText("{img monsterbtn_image 30 20}")
        mccbtn:SetTextTooltip(g.lang == "Japanese" and "カード自動搬出入、自動着脱" or
                                  "Automatic card loading/unloading, automatic insertion/removal")
        mccbtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_MONSTERCARDPRESET_FRAME_OPEN")
    end

    cc_helper_invframe_init()
end

function cc_helper_ACCOUNTWAREHOUSE_CLOSE(frame)

    local invframe = ui.GetFrame("inventory")
    local inbtn = GET_CHILD_RECURSIVELY(invframe, "inv_in")
    local outbtn = GET_CHILD_RECURSIVELY(invframe, "inv_out")

    inbtn:ShowWindow(0)
    outbtn:ShowWindow(0)
end

function cc_helper_check_setting(frame, ctrl, argStr, argNum)
    local ischeck = ctrl:IsChecked()

    if ctrl:GetName() == "mccuse" then
        if ischeck == 0 then
            g.settings[g.cid].mcc_use = 0
        else
            g.settings[g.cid].mcc_use = 1
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

    elseif ctrl:GetName() == "auto_close" then
        if ischeck == 0 then
            g.share_settings.auto_close = 0
        else
            g.share_settings.auto_close = 1
        end
    elseif ctrl:GetName() == "all_agm" then
        if ischeck == 0 then
            g.share_settings.all_agm = 0
        else
            g.share_settings.all_agm = 1
        end
    end
    acutil.saveJSON(g.settings_location, g.share_settings)
    cc_helper_save_settings()
    cc_helper_setting_frame_init()
    frame:ShowWindow(1)
end

-- settingframe
function cc_helper_setting_frame_init()

    local awhframe = ui.GetFrame("accountwarehouse")
    ACCOUNTWAREHOUSE_CLOSE(awhframe)
    UI_TOGGLE_INVENTORY()

    local frame = ui.GetFrame("cc_helper")
    frame:RemoveAllChild()
    frame:SetSkinName("test_frame_low")
    frame:SetLayerLevel(93)
    frame:Resize(235, 470)
    frame:SetPos(1185, 380)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    frame:EnableHitTest(1)

    if frame:IsVisible() == 0 then
        frame:ShowWindow(1)
    else
        frame:ShowWindow(0)
    end

    INVENTORY_SET_CUSTOM_RBTNDOWN("cc_helper_inv_rbtn")

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
        }
    }

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
                            icon:SetTextTooltip(
                                "{ol}Rank: " .. result[4] .. "{nl}" .. result[1] .. "{nl}" .. result[2] .. "{nl}" ..
                                    result[3])
                        elseif #result == 3 then

                            icon:SetTextTooltip("{ol}Rank: " .. result[3] .. "{nl}" .. result[1] .. "{nl}" .. result[2])
                        elseif #result == 2 then

                            icon:SetTextTooltip("{ol}Rank: " .. result[2] .. "{nl}" .. result[1])

                        end

                    end
                elseif clsid ~= 0 then
                    icon:SetTooltipType('wholeitem')
                    icon:SetTooltipArg("None", clsid, iesid)
                end
            end
        end

        if g.settings[g.cid].agm_use == 0 and string.find(name, "gem") ~= nil then
            slot:ShowWindow(0)
        elseif g.settings[g.cid].agm_use == 1 and string.find(name, "gem") ~= nil then
            local agm_json = string.format('../addons/%s/%s.json', "aethergem_mgr", active_id)
            local settings = acutil.loadJSON(agm_json)
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
                        else
                            lv_text:SetText("{ol}{s14}LV460")
                        end
                        icon:SetTextTooltip(
                            g.lang == "Japanese" and "{ol}Aethergem Managerの設定を参照します" or
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

        --[[if string.find(name, "gem") ~= nil then
            slot:SetSkinName(g.settings[cid][name].skin)
        end]]

    end

    function cc_helper_load_copy(cid)

        local function deepCopy(original)
            local copy = {}
            for k, v in pairs(original) do
                if type(v) == "table" then
                    copy[k] = deepCopy(v) -- テーブルの場合は再帰的にコピー
                else
                    copy[k] = v
                end
            end
            return copy
        end

        -- 使用例
        g.settings[g.cid] = deepCopy(g.copy_settings[cid]) -- ディープコピーを行う
        g.settings[g.cid]["name"] = g.login_name -- name を更新

        cc_helper_save_settings()
        cc_helper_setting_frame_init()
        -- cc_helper_load_settings()
        -- cc_helper_function_check()
        frame:ShowWindow(1)
    end

    function cc_helper_setting_copy(frame, ctrl, str, num)

        local copy_settings_location = string.format('../addons/%s/%s_copy.json', addonNameLower, active_id)
        local copy_settings = acutil.loadJSON(copy_settings_location)
        g.copy_settings = copy_settings

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

    local copy = frame:CreateOrGetControl('button', 'copy', 180, 10, 40, 30)
    AUTO_CAST(copy)
    copy:SetText("{ol}copy")
    copy:SetEventScript(ui.LBUTTONUP, "cc_helper_setting_copy")

    function cc_helper_setting_save(frame, ctrl, str, num)

        local copy_settings_location = string.format('../addons/%s/%s_copy.json', addonNameLower, active_id)
        local copy_settings = acutil.loadJSON(copy_settings_location)
        if not copy_settings then
            copy_settings = {}
        end
        if not copy_settings[g.cid] then
            copy_settings[g.cid] = {}
        end
        copy_settings[g.cid] = g.settings[g.cid]

        g.copy_settings = copy_settings
        acutil.saveJSON(copy_settings_location, g.copy_settings)

        ui.SysMsg(g.lang == "Japanese" and "{#FFFF00}設定を保存しました" or "{#FFFF00}Settings saved")
        cc_helper_save_settings()
    end

    local save = frame:CreateOrGetControl('button', 'save', 130, 10, 40, 30)
    AUTO_CAST(save)
    save:SetText("{ol}save")
    save:SetEventScript(ui.LBUTTONUP, "cc_helper_setting_save")
    save:SetTextTooltip(g.lang == "Japanese" and "{ol}このキャラの設定をコピー用に保存します" or
                            "{ol}Save this character settings for copying")

    function cc_helper_setting_delete(frame, ctrl, str, num)
        local copy_settings_location = string.format('../addons/%s/%s_copy.json', addonNameLower, active_id)
        local copy_settings = acutil.loadJSON(copy_settings_location)
        if not copy_settings then
            copy_settings = {}
        end
        if not copy_settings[g.cid] then
            copy_settings[g.cid] = {}
        end
        copy_settings[g.cid] = {}
        g.copy_settings = copy_settings
        acutil.saveJSON(copy_settings_location, g.copy_settings)
        ui.SysMsg(g.lang == "Japanese" and "{#FFFF00}設定を削除しました" or "{#FFFF00}Settings deleted")
        cc_helper_save_settings()
    end

    local save_delete = frame:CreateOrGetControl('button', 'save_delete', 67, 10, 40, 30)
    AUTO_CAST(save_delete)
    save_delete:SetText("{ol}delete")
    save_delete:SetEventScript(ui.LBUTTONUP, "cc_helper_setting_delete")
    save_delete:SetTextTooltip(
        g.lang == "Japanese" and "{ol}このキャラのコピー用の設定を削除します" or
            "{ol}Delete settings for copying this character")

    if g.mcc then
        local mccuse = frame:CreateOrGetControl("checkbox", "mccuse", 10, 375, 25, 25)
        AUTO_CAST(mccuse)
        mccuse:SetText("{ol}mcc")
        mccuse:SetTextTooltip(g.lang == "Japanese" and
                                  "チェックを入れると[Monster Card Change]と連携します。" or
                                  "If checked, it will work with [Monster Card Change].")
        mccuse:SetCheck(g.settings[g.cid].mcc_use)
        mccuse:SetEventScript(ui.LBUTTONUP, "cc_helper_check_setting")
    end

    if g.agm_func then
        local all_agm = frame:CreateOrGetControl("checkbox", "all_agm", 10, 435, 25, 25)
        AUTO_CAST(all_agm)
        all_agm:SetText("{ol}all agm")
        all_agm:SetTextTooltip(g.lang == "Japanese" and
                                   "チェックを入れると、全てのキャラの{nl}エーテルジェム関係の動作をストップします。" or
                                   "If checked, stops all ether gem-related actions for all characters.")
        all_agm:SetEventScript(ui.LBUTTONUP, "cc_helper_check_setting")
        all_agm:SetCheck(g.share_settings.all_agm)

        if g.share_settings.all_agm == 1 then
            g.agm = false
        else
            local found = false
            for k, v in pairs(g.settings[g.cid]) do
                if string.find(k, "gem") and type(v) == "table" then
                    for k2, v2 in pairs(v) do
                        if k2 == "clsid" then
                            if v2 > 0 then
                                found = true
                            end

                        end
                    end
                end
            end
            if g.settings[g.cid].agm_use == 1 or found == false then
                g.agm = true
            else
                g.agm = false
            end
        end
    end

    -- if g.agm then
    local agmuse = frame:CreateOrGetControl("checkbox", "agmuse", 80, 375, 25, 25)
    AUTO_CAST(agmuse)
    agmuse:SetText("{ol}agm")
    agmuse:SetTextTooltip(
        g.lang == "Japanese" and "チェックを入れると[Aethergem Manager]と連携します。" or
            "If checked, it will work with [Aethergem Manager].")
    agmuse:SetEventScript(ui.LBUTTONUP, "cc_helper_check_setting")
    agmuse:SetCheck(g.settings[g.cid].agm_use)
    -- end

    function cc_helper_agm_setting(frame, ctrl, str, num)
        if g.settings[g.cid].agm_check == 0 then
            g.settings[g.cid].agm_check = 1
        else
            g.settings[g.cid].agm_check = 0
        end
        cc_helper_save_settings()
        cc_helper_setting_frame_init()
        frame:ShowWindow(1)

    end

    local agm_on_off = frame:CreateOrGetControl('button', 'agm_on_off', 150, 375, 60, 30)
    AUTO_CAST(agm_on_off)
    if g.settings[g.cid]["agm_use"] == 1 then -- !
        agm_on_off:ShowWindow(1)
        if g.settings[g.cid].agm_check == 1 then
            agm_on_off:SetSkinName("test_red_button")
            agm_on_off:SetText("{ol}ON")
            agm_on_off:SetTextTooltip(g.lang == "Japanese" and
                                          "[エーテルジェムマネージャー]との連携時に確認します" or
                                          "Check when working with [Aethergem Manager]")
        else
            agm_on_off:SetSkinName("test_gray_button")
            agm_on_off:SetText("{ol}OFF")
            agm_on_off:SetTextTooltip(g.lang == "Japanese" and
                                          "[エーテルジェムマネージャー]との連携時に確認しません" or
                                          "Not checked when working with [Aethergem Manager]")
        end
    else
        g.settings[g.cid].agm_check = 0
        agm_on_off:ShowWindow(0)
        cc_helper_save_settings()
    end

    agm_on_off:SetEventScript(ui.LBUTTONUP, "cc_helper_agm_setting")

    local ecouse = frame:CreateOrGetControl("checkbox", "ecouse", 10, 405, 25, 25)
    AUTO_CAST(ecouse)
    ecouse:SetText("{ol}eco")
    ecouse:SetTextTooltip(g.lang == "Japanese" and
                              "チェックを入れると、外すのにシルバーが必要な{nl}レジェンドカードとエーテルジェムの動作をスキップします。" or
                              "If checked, it skips the operation of legend cards and{nl}ether gems that require silver to remove.")
    ecouse:SetEventScript(ui.LBUTTONUP, "cc_helper_check_setting")
    ecouse:SetCheck(g.share_settings.eco_mode)

    --[[if agm_on_off then
        agm_on_off:ShowWindow(1)
    end]]

    local delay_title = frame:CreateOrGetControl("richtext", "delay_title", 130, 440)
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
        acutil.saveJSON(g.settings_location, g.share_settings)
    end
    local delay = frame:CreateOrGetControl('edit', 'delay', 175, 440, 50, 20)
    AUTO_CAST(delay)
    delay:SetText("{ol}" .. g.share_settings.delay)
    delay:SetFontName("white_16_ol")
    delay:SetTextAlign("center", "center")
    delay:SetEventScript(ui.ENTERKEY, "cc_helper_delay_change")
    delay:SetTextTooltip(g.lang == "Japanese" and
                             "動作のディレイ時間を設定します。デフォルトは0.3秒。{nl}早過ぎると失敗が多発します。" or
                             "Sets the delay time for the operation. Default is 0.3 seconds.{nl}Too early and many failures will occur.")

    function cc_helper_settings_close(frame)
        local frame = ui.GetFrame("cc_helper")
        frame:ShowWindow(0)
    end

    local close = frame:CreateOrGetControl('button', 'close', 0, 0, 30, 30)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.LEFT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "cc_helper_settings_close")

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

    function cc_helper_slot_create()
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
    cc_helper_slot_create()
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

    local char_belonging = TryGetProp(item_obj, 'CharacterBelonging', 0)

    local temp_tbl = {
        ["Seal"] = "seal",
        ["Ark"] = "ark",
        ["LEG"] = "leg",
        ["GODDESS"] = "god",
        ["sset_HairAcc_Acc1"] = "hair1",
        ["sset_HairAcc_Acc2"] = "hair2",
        ["sset_HairAcc_Acc3"] = "hair3"
        -- ["aether"] = "gem"
    }

    for key, value in pairs(temp_tbl) do
        if key == "Seal" and key == type and clsid ~= 614001 then
            cc_helper_settings_slot(frame, value, item_obj, iesid, clsid, image)
            return
        elseif key == "Ark" and key == type and char_belonging ~= 1 then
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
            skin = "invenslot_unique"
            slot:SetSkinName(skin)
        elseif string.find(item_obj.ClassName, "500") ~= nil then
            skin = "invenslot_legend"
            slot:SetSkinName(skin)
        elseif string.find(item_obj.ClassName, "520") ~= nil then
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
        ["sset_HairAcc_Acc3"] = "hair3"
        -- ["aether"] = "gem"
    }

    for key, value in pairs(temp_tbl) do
        if key == "Seal" and key == type and clsid ~= 614001 then
            cc_helper_settings_slot(frame, value, item_obj, iesid, clsid, image)
            return
        elseif key == "Ark" and key == type and char_belonging ~= 1 then
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
function cc_helper_putitem(frame, in_btn, str, step)
    if step == 0 then
        in_btn:SetUserValue("STEP", 0)
        cc_helper_unequip_card(in_btn)
    elseif step == 1 then
        in_btn:SetUserValue("STEP", 1)
        cc_helper_in_btn_start(in_btn)
    elseif step == 2 then
        in_btn:SetUserValue("STEP", 2)
        cc_helper_unequip_card(in_btn)
    elseif step == 3 then
        in_btn:SetUserValue("STEP", 3)
        in_btn:RunUpdateScript("cc_helper_inv_to_warehouse", 0.1)
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
        cc_helper_end_of_operation(in_btn)
    end
end

function cc_helper_unequip_card(in_btn)

    local step = in_btn:GetUserIValue("STEP")
    local frame = ui.GetFrame("monstercardslot")
    if step == 0 then
        if g.settings[g.cid]["god"].clsid ~= 0 then
            local slot_index = 14
            local card_id = GETMYCARD_INFO(slot_index - 1)
            local card_info = equipcard.GetCardInfo(slot_index)

            if card_info ~= nil then
                if card_id == g.settings[g.cid]["god"].clsid then
                    MONSTERCARDSLOT_FRAME_OPEN()
                    local arg_str = slot_index - 1
                    arg_str = arg_str .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
                    pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", arg_str)
                end
            end
        end
        cc_helper_putitem(nil, in_btn, nil, 1)
    elseif step == 2 then
        if g.share_settings.eco_mode == 0 then
            if g.settings[g.cid]["leg"].clsid ~= 0 then
                local slot_index = 13
                local card_id = GETMYCARD_INFO(slot_index - 1)
                local card_info = equipcard.GetCardInfo(slot_index)
                if card_info ~= nil then
                    if card_id == g.settings[g.cid]["leg"].clsid then

                        if frame:IsVisible() == 0 then
                            MONSTERCARDSLOT_FRAME_OPEN()
                        end
                        local arg_str = slot_index - 1
                        arg_str = arg_str .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
                        pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", arg_str)
                    end
                end
            end
        end
        if frame:IsVisible() == 1 then
            frame:RunUpdateScript("MONSTERCARDSLOT_CLOSE", 1.0)
        end
        cc_helper_putitem(nil, in_btn, nil, 3)
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

function cc_helper_unequip(in_btn)

    local frame = ui.GetFrame("inventory")
    local eqp_tab = GET_CHILD_RECURSIVELY(frame, "inventype_Tab")
    eqp_tab:SelectTab(1)
    local equip_tbl = {0, 20, 1, 25, 27}
    local temp_tbl = {"hair1", "hair2", "hair3", "seal", "ark"}
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

function cc_helper_inv_to_warehouse(in_btn)

    if not cc_helper_get_warehouse_count() then
        return
    end

    local accountwarehouse = ui.GetFrame("accountwarehouse")
    local inventory = ui.GetFrame("inventory")
    local handle = accountwarehouse:GetUserIValue('HANDLE')
    local inventype_Tab = GET_CHILD_RECURSIVELY(inventory, "inventype_Tab")

    local temp_tbl = {"seal", "ark", "hair1", "hair2", "hair3", "leg", "god"}

    if accountwarehouse:IsVisible() == 1 then
        for i, equip_index in ipairs(temp_tbl) do
            local iesid = g.settings[g.cid][temp_tbl[i]].iesid
            local inv_item = session.GetInvItemByGuid(iesid)
            if inv_item then

                if i <= 5 then
                    inventype_Tab:SelectTab(1)
                else
                    inventype_Tab:SelectTab(4)
                end

                if cc_helper_checkvalid(iesid) then

                    local goal_index = cc_helper_get_goal_index()
                    local item_cls = GetClassByType('Item', g.settings[g.cid][temp_tbl[i]].clsid)
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
    cc_helper_putitem(nil, in_btn, nil, 4)
    return
end

function cc_helper_in_btn_aethergem_mgr(in_btn)

    local frame = ui.GetFrame("inventory")
    local equip_slots = {"RH", "LH", "RH_SUB", "LH_SUB"}
    if g.share_settings.eco_mode == 0 then
        if g.settings[g.cid].agm_use == 1 then
            for _, slot_name in ipairs(equip_slots) do
                local equip_slot = GET_CHILD_RECURSIVELY(frame, slot_name)
                local icon = equip_slot:GetIcon()
                if icon then
                    local icon_info = icon:GetInfo()
                    local type = icon_info.type
                    local equip_item = session.GetEquipItemByType(type)
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
            in_btn:StopUpdateScript("cc_helper_in_btn_agm_operation")
            cc_helper_putitem(nil, in_btn, nil, 5)
            return 0
        end
        in_btn:StopUpdateScript("cc_helper_GODDESS_MGR_SOCKET_REG_ITEM")
        in_btn:RunUpdateScript("cc_helper_in_btn_agm_operation", 0.1)
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

function cc_helper_end_of_operation(in_btn)

    local goddess_equip_manager = ui.GetFrame("goddess_equip_manager")
    goddess_equip_manager:ShowWindow(0)

    if g.share_settings.auto_close == 1 then
        local awframe = ui.GetFrame("accountwarehouse")
        ACCOUNTWAREHOUSE_CLOSE(awframe)
    end
    ui.SysMsg("{ol}[CCH]End of Operation")
end

-- takeitem
function cc_helper_take_item(frame, out_btn, str, step)
    print(tostring(step))
    local inv_frame = ui.GetFrame("inventory")
    local out_btn = GET_CHILD_RECURSIVELY(inv_frame, "out_btn")
    if step == 0 then
        out_btn:SetUserValue("STEP", 0)
        out_btn:RunUpdateScript("cc_helper_equip_take_warehouse_item", 0.1)
    elseif step == 1 then
        out_btn:SetUserValue("STEP", 1)
        out_btn:RunUpdateScript("cc_helper_equip_card", 0.1)
    elseif step == 2 then
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
        }}
        out_btn:SetUserValue("STEP", 2)
        out_btn:RunUpdateScript("cc_helper_equips", 0.1)
    elseif step == 3 then
        out_btn:SetUserValue("STEP", 3)
        out_btn:RunUpdateScript("cc_helper_equip_card", 0.1)
    elseif step == 4 then
        out_btn:SetUserValue("STEP", 4)
        cc_helper_take_agm_reserve(out_btn)
    elseif step == 5 then
        out_btn:SetUserValue("STEP", 5)
        cc_helper_out_btn_agm_reserve(out_btn)
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
    else
        local msg = g.lang == "Japanese" and "{ol}武器4ヶ所着けてください" or
                        "{ol}Please equip weapons in 4 slots"
        ui.SysMsg(msg)
        cc_helper_take_item(nil, out_btn, nil, 7) -- ここでエンドもありえる
        return
    end
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
                    local msg = g.lang == "Japanese" and "{ol}{#FFFFFF}エーテルジェムを付替えますか？" or
                                    "{ol}{#FFFFFF}Would you like to swap Aether Gems?"
                    local yes_scp = "cc_helper_out_btn_agm()"
                    -- local no_scp = "cc_helper_no_scp()"
                    ui.MsgBox(msg, yes_scp, "None")
                else
                    cc_helper_take_agm(out_btn) -- !
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

function cc_helper_equips(out_btn)
    local inventory = ui.GetFrame("inventory")
    local inv_tab = GET_CHILD_RECURSIVELY(inventory, "inventype_Tab")
    inv_tab:SelectTab(1)

    if next(g.equip_tbl) then
        for i, data in ipairs(g.equip_tbl) do
            for spot, equip in pairs(data) do
                local guid = g.settings[g.cid][equip].iesid
                if guid ~= "" then
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
                else
                    g.equip_tbl[i] = nil
                    return 1
                end
            end
        end
    end
    cc_helper_take_item(nil, out_btn, nil, 3)
end

function cc_helper_equip_card(out_btn)
    local inventory = ui.GetFrame("inventory")
    local monstercardslot = ui.GetFrame("monstercardslot")

    local step = out_btn:GetUserIValue("STEP")
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
                end
            end
        end
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
        if monstercardslot:IsVisible() == 1 then
            monstercardslot:RunUpdateScript("MONSTERCARDSLOT_CLOSE", 1.0)
        end
        cc_helper_take_item(nil, out_btn, nil, 4)
    end

end

function cc_helper_equip_take_warehouse_item(out_btn)

    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local sortedGuidList = itemList:GetSortedGuidList()
    local sortedCnt = sortedGuidList:Count()
    local accountwarehouse = ui.GetFrame("accountwarehouse")
    local handle = accountwarehouse:GetUserIValue("HANDLE")

    local temp_tbl = {"seal", "ark", "leg", "god", "hair1", "hair2", "hair3"}

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

    if count == 0 then
        cc_helper_take_item(nil, out_btn, nil, 1)
    else
        return 1
    end
end

--[==[function cc_helper_out_btn_start()

    cc_helper_equip_take_warehouse()
end

function cc_helper_equip_take_warehouse()

    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local sortedGuidList = itemList:GetSortedGuidList()
    local sortedCnt = sortedGuidList:Count()
    local fromframe = ui.GetFrame("accountwarehouse")
    local handle = fromframe:GetUserIValue("HANDLE")

    local temp_tbl = {"seal", "ark", "leg", "god", "hair1", "hair2", "hair3"}

    session.ResetItemList()
    for _, equip in pairs(temp_tbl) do
        local iesid = g.settings[g.cid][equip].iesid
        if iesid ~= "0" then
            local inv_item = itemList:GetItemByGuid(iesid)
            if inv_item ~= nil then
                session.AddItemID(tonumber(iesid), 1)
            end
        end
    end
    item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), handle)

    MONSTERCARDSLOT_FRAME_OPEN()
    ReserveScript("cc_helper_equip_reserve()", g.share_settings.delay)
end

function cc_helper_equip_reserve()
    local frame = ui.GetFrame("inventory")
    local inv_tab = GET_CHILD_RECURSIVELY(frame, "inventype_Tab")

    local temp_tbl = {"god", "hair1", "hair2", "hair3", "seal", "ark", "leg"}

    session.ResetItemList()
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList()
    local cnt = guidList:Count()

    local equip_item_list = session.GetEquipItemList()
    for _, equip in ipairs(temp_tbl) do
        if equip == "god" then
            local card_index = 13
            local cardid = GETMYCARD_INFO(card_index)
            local iesid = g.settings[g.cid][equip].iesid

            if session.GetInvItemByGuid(iesid) ~= nil then
                if cardid == 0 and iesid ~= "" then
                    inv_tab:SelectTab(4)
                    local argstr = string.format("%d#%s", card_index, tostring(iesid))
                    pc.ReqExecuteTx("SCR_TX_EQUIP_CARD_SLOT", argstr)
                    ReserveScript("cc_helper_equip_reserve()", g.share_settings.delay)
                    return
                end
            end

        elseif equip == "leg" then
            if g.share_settings.eco_mode == 0 then
                local card_index = 12
                local cardid = GETMYCARD_INFO(card_index)
                local iesid = g.settings[g.cid][equip].iesid

                if session.GetInvItemByGuid(iesid) ~= nil then
                    if cardid == 0 and iesid ~= "" then
                        inv_tab:SelectTab(4)
                        local argstr = string.format("%d#%s", card_index, tostring(iesid))
                        pc.ReqExecuteTx("SCR_TX_EQUIP_CARD_SLOT", argstr)
                        ReserveScript("cc_helper_equip_reserve()", g.share_settings.delay)
                        return
                    end
                end
            end
        else
            function cc_helper_equip(spot, iesid)
                local item = session.GetInvItemByGuid(iesid)
                if item then
                    local item_index = item.invIndex
                    ITEM_EQUIP(item_index, spot)
                end
            end

            local equip_tbl = {{
                ["HAT"] = "hair1"
            }, {
                ["HAT_T"] = "hair2"
            }, {
                ["HAT_L"] = "hair3"
            }, {
                ["SEAL"] = "seal"
            }, {
                ["ARK"] = "ark"
            }}

            for i, data in ipairs(equip_tbl) do
                for spot, equip in pairs(data) do
                    inv_tab:SelectTab(1)
                    local guid = g.settings[g.cid][equip].iesid
                    if session.GetInvItemByGuid(guid) ~= nil then
                        cc_helper_equip(spot, guid)
                        ReserveScript("cc_helper_equip_reserve()", g.share_settings.delay)
                        return
                    end
                end
            end

        end
    end
    ReserveScript("MONSTERCARDSLOT_CLOSE()", g.share_settings.delay)
    ReserveScript("cc_helper_end_operation()", g.share_settings.delay + 0.1)

end

function cc_helper_end_operation()

    local frame = ui.GetFrame("inventory")
    local inv_tab = GET_CHILD_RECURSIVELY(frame, "inventype_Tab")
    inv_tab:SelectTab(0)

    --[[print(tostring(g.agm) .. ":" .. tostring(g.share_settings.eco_mode) .. ":" .. tostring(g.settings[g.cid].agm_use) ..
              ":" .. tostring(g.temp))]]
    if g.agm and g.share_settings.eco_mode == 0 and g.settings[g.cid].agm_use == 1 and g.temp == nil then
        cc_helper_handle_aether_gem_management()
        return
    end

    g.temp = nil
    ui.SysMsg("[CCH]End of Operation")
    if g.share_settings.auto_close == 1 then
        local awframe = ui.GetFrame("accountwarehouse")
        ACCOUNTWAREHOUSE_CLOSE(awframe)
        --[[local frame = ui.GetFrame("inventory")
        frame:ShowWindow(0)
        local awframe = ui.GetFrame("accountwarehouse")
        awframe:ShowWindow(0)]]
    end
    if g.mcc and g.share_settings.eco_mode == 0 and g.settings[g.cid].mcc_use == 1 then
        g.monstercard = 1
        cc_helper_handle_monstercard_change()
    end

end

function cc_helper_no_scp()

    if g.share_settings.auto_close == 1 then

        local awframe = ui.GetFrame("accountwarehouse")
        ACCOUNTWAREHOUSE_CLOSE(awframe)
        --[[local frame = ui.GetFrame("inventory")
        frame:ShowWindow(0)
        local awframe = ui.GetFrame("accountwarehouse")
        awframe:ShowWindow(0)]]
    end
    ui.SysMsg("[CCH]End of Operation")
    return
end

function cc_helper_handle_aether_gem_management()

    local equipSlots = {"RH", "LH", "RH_SUB", "LH_SUB"}
    local found = false

    for _, slotName in ipairs(equipSlots) do
        local equipSlot = GET_CHILD_RECURSIVELY(ui.GetFrame("inventory"), slotName)
        local icon = equipSlot:GetIcon()

        if icon then
            local iconInfo = icon:GetInfo()
            local guid = iconInfo:GetIESID()
            local itemCls = GetClassByType("Item", session.GetEquipItemByGuid(guid).type)
            local classID = itemCls.ClassID
            local equipItem = session.GetEquipItemByType(classID)
            local gem = equipItem:GetEquipGemID(2)

            if gem == 0 then
                found = true
                if g.settings[g.cid].agm_check == 1 then
                    local msg = g.lang == "Japanese" and "[Aether Gem Manager]を起動しますか？" or
                                    "Call[Aether Gem Manager]?"
                    local yes_scp = "cc_helper_out_btn_agm()"
                    local no_scp = "cc_helper_no_scp()"
                    ui.MsgBox(msg, yes_scp, no_scp)
                    break
                else
                    cc_helper_out_btn_agm() -- !
                    break
                end
            end
        end
    end

    if not found then
        g.temp = true
        ReserveScript("cc_helper_end_operation()", g.share_settings.delay)
    end
end

function cc_helper_out_btn_start_reserve()
    g.time = g.time + g.share_settings.delay
    if g.time <= 5 then
        return 1
    end
    local inv_frame = ui.GetFrame("inventory")
    local equip_slot = GET_CHILD_RECURSIVELY(inv_frame, "LH_SUB")
    local icon = equip_slot:GetIcon()
    if icon ~= nil then
        g.temp = true

        ReserveScript("cc_helper_end_operation()", g.share_settings.delay)
        return 0
    else
        return 1
    end
end

function cc_helper_out_btn_agm()

    local agm_json = string.format('../addons/%s/%s.json', "aethergem_mgr", active_id)
    local agm_tbl = acutil.loadJSON(agm_json)
    local gems = {}
    for i = 1, 4 do
        if agm_tbl ~= nil then
            local use_index = agm_tbl[g.cid]["use_index"]
            if use_index ~= nil then

                local item_type = agm_tbl[use_index][tostring(i)]
                local gemKey = "gem" .. i

                g.settings[g.cid][gemKey].clsid = item_type

            end
        end

        local clsid = g.settings[g.cid]["gem" .. i].clsid
        if not gems[clsid] then
            gems[clsid] = 1
        else
            gems[clsid] = gems[clsid] + 1
        end
    end
    cc_helper_save_settings()
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

    local filtered_gems = {}

    for _, gem in pairs(g.take_gem) do
        if gems[gem.clsid] and gems[gem.clsid] > 0 then
            local iesid = gem.iesid

            local exists = false
            for _, existing in pairs(filtered_gems) do
                if existing.iesid == iesid then
                    exists = true
                    break
                end
            end

            if not exists then
                table.insert(filtered_gems, {
                    iesid = iesid
                })
            end
            gems[gem.clsid] = gems[gem.clsid] - 1
        end
    end

    g.take_gem = filtered_gems
    session.ResetItemList()
    for _, gems in pairs(g.take_gem) do
        local iesid = gems.iesid
        session.AddItemID(tonumber(iesid), 1)
    end
    item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), handle)
    -- ReserveScript("cc_helper_equip_take_warehouse()", g.share_settings.delay)

    ReserveScript("aethergem_mgr_gem_operation()", g.share_settings.delay)
    local inv_frame = ui.GetFrame("inventory")
    g.time = g.share_settings.delay + 0.1
    inv_frame:RunUpdateScript("cc_helper_out_btn_start_reserve", g.share_settings.delay + 0.1)
end

--[[function cc_helper_in_btn_start_reserve()
    g.time = g.time + g.share_settings.delay
    if g.time <= 5 then
        return 1
    end
    local inv_frame = ui.GetFrame("inventory")
    local equip_slot = GET_CHILD_RECURSIVELY(inv_frame, "LH_SUB")

    local icon = equip_slot:GetIcon()
    if icon == nil then

        return 1
    else
        ReserveScript("cc_helper_in_btn_start()", g.share_settings.delay)
        return 0
    end
end

function cc_helper_lang(str)
    local language = option.GetCurrentCountry()
    if language == "Japanese" then
        if str == "Item to warehousing" then
            str = "倉庫に格納しました"
        end
    end
    return str
end

function cc_helper_endput_operation()
    ui.SysMsg("[CCH]End of Operation")
    if g.share_settings.auto_close == 1 then

        local awframe = ui.GetFrame("accountwarehouse")
        ACCOUNTWAREHOUSE_CLOSE(awframe)
      
    end
    if g.mcc and g.share_settings.eco_mode == 0 and g.settings[g.cid].mcc_use == 1 then
        g.monstercard = 1
        cc_helper_handle_monstercard_change()
    end
end

-- mcc_use
function cc_helper_handle_monstercard_change()

    function cc_helper_monstercard_change(frame, ctrl)

        if tostring(ctrl:GetName()) == "cancel_btn" then
            frame:ShowWindow(0)
            return
        elseif tostring(ctrl:GetName()) == "open_btn" then
            frame:ShowWindow(0)
            monstercard_change_MONSTERCARDPRESET_FRAME_OPEN()
            return
        elseif tostring(ctrl:GetName()) == "remove_btn" then
            frame:ShowWindow(0)
            monstercard_change_MONSTERCARDPRESET_FRAME_OPEN()
            ReserveScript("monstercard_change_get_info_accountwarehouse()", g.share_settings.delay)
            return
        elseif tostring(ctrl:GetName()) == "equip_btn" then
            frame:ShowWindow(0)
            monstercard_change_MONSTERCARDPRESET_FRAME_OPEN()
            ReserveScript("monstercard_change_get_presetinfo()", g.share_settings.delay)
            return
        end

    end
    local msgframe = ui.CreateNewFrame("chat_memberlist", "monstercardchange_msg")
    msgframe:SetLayerLevel(110)

    local screenWidth, screenHeight = ui.GetClientInitialWidth(), ui.GetClientInitialHeight()
    msgframe:Resize(390, 90)
    local frameWidth, frameHeight = msgframe:GetWidth(), msgframe:GetHeight()
    msgframe:SetPos((screenWidth - frameWidth) / 2, (screenHeight - frameHeight) / 2)

    local text = msgframe:CreateOrGetControl('richtext', 'text', 15, 15)
    text:SetText("{#FFA500}{ol}Call monstercard change Addon?")

    local buttons = {{
        name = "equip_btn",
        text = "EQUIP",
        tooltip = g.lang == "Japanese" and "カードプリセットの1番目のセットを装備します。" or
            "Equip the first set of card presets.",
        enable = g.monstercard,
        skin = g.monstercard == 0 and "test_red_button" or "test_gray_button"
    }, {
        name = "remove_btn",
        text = "REMOVE",
        tooltip = g.lang == "Japanese" and "モンスターカードを外して倉庫に搬入します。" or
            "Remove the monster card and bring it into the warehouse.",
        enable = g.monstercard,
        skin = g.monstercard == 1 and "test_red_button" or "test_gray_button"
    }, {
        name = "open_btn",
        text = "OPEN",
        tooltip = g.lang == "Japanese" and
            "モンスターカードとモンスターカードプリセットを開きます。" or
            "Open the Monster Card and Monster Card Preset.",
        enable = true,
        skin = "test_red_button"
    }, {
        name = "cancel_btn",
        text = "CANCEL",
        tooltip = "",
        enable = true,
        skin = "test_gray_button"
    }}

    for i, btn in ipairs(buttons) do
        local button = msgframe:CreateOrGetControl('button', btn.name, 20 + (i - 1) * 85, 45, 80, 30)
        button:SetText("{ol}" .. btn.text)
        button:SetTextTooltip(btn.tooltip)
        button:SetEventScript(ui.LBUTTONUP, "cc_helper_monstercard_change")
        if btn.enable then
            button:SetEnable(1)
        else
            button:SetEnable(0)
        end
        button:SetSkinName(btn.skin)
    end
    msgframe:ShowWindow(1)
end]==]
