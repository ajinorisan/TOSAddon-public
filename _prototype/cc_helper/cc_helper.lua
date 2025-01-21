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
local addonName = "CC_HELPER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.2.3"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")
local json = require('json')
local base = {}

local active_id = session.loginInfo.GetAID()
g.settingsFileLoc = string.format('../addons/%s/%s.json', addonNameLower, active_id)

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

function cc_helper_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function cc_helper_load_settings()

    local settings = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if not settings then
        settings = {
            delay = 0.3,
            eco_mode = 0
        }
    end

    g.settings = settings
    if not g.settings[g.cid] then
        local temp_tbl = {"name", "mcc_use", "agm_use", "agm_check", "seal", "ark", "leg", "god", "hair1", "hair2",
                          "hair3", "gem1", "gem2", "gem3", "gem4"}
        local cid_settings = {}

        for i, key in ipairs(temp_tbl) do
            if key == "name" then
                cid_settings[key] = g.login_name
            elseif key == "mcc_use" or key == "agm_use" then
                cid_settings[key] = 0

            elseif key == "agm_check" then
                cid_settings[key] = 1
            else
                cid_settings[key] = {
                    iesid = "",
                    clsid = 0,
                    image = "",
                    skin = "",
                    memo = ""
                }
            end
        end

        g.settings[g.cid] = cid_settings
    else
        g.settings[g.cid] = settings[g.cid]
    end

    cc_helper_save_settings()

    local cid_name_file_location = string.format('../addons/%s/%s', addonNameLower, active_id .. "_cid_name.json")
    g.cid_name = {}
    local file = io.open(cid_name_file_location, "r")

    if file then
        local content = file:read("*all")
        file:close()
        g.cid_name = json.decode(content)
    end

    if g.cid_name[g.cid] == nil then
        g.cid_name[g.cid] = g.login_name
        file = io.open(cid_name_file_location, "w")
        file:write(json.encode(g.cid_name))
        file:close()
    end
end

function CC_HELPER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.cid = info.GetCID(session.GetMyHandle())
    g.lang = option.GetCurrentCountry()
    g.login_name = session.GetMySession():GetPCApc():GetName()
    -- ADDONS.norisan.AETHERGEM_MGR
    local functionName = "AETHERGEM_MGR_ON_INIT" -- チェックしたい関数の名前を文字列として指定します
    if type(_G[functionName]) == "function" then
        g.agm = true
    end
    CHAT_SYSTEM("agm" .. tostring(g.agm))
    -- cc_helper_load_settings()

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then

        acutil.setupEvent(addon, "ACCOUNTWAREHOUSE_CLOSE", "cc_helper_ACCOUNTWAREHOUSE_CLOSE");
        acutil.setupEvent(addon, "INVENTORY_CLOSE", "cc_helper_settings_close");
        acutil.setupEvent(addon, "UI_TOGGLE_INVENTORY", "cc_helper_invframe_init");
        acutil.setupEvent(addon, "INVENTORY_OPEN", "cc_helper_invframe_init");
        addon:RegisterMsg("OPEN_DLG_ACCOUNTWAREHOUSE", "cc_helper_accountwarehouse_init")
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
        local inbtn = invframe:CreateOrGetControl("button", "inv_in", 235, 345, 30, 30)
        AUTO_CAST(inbtn)
        inbtn:SetText("{img in_arrow 20 20}")
        inbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_in_btn_aethergem_mgr")

        inbtn:ShowWindow(1)
        inbtn:SetSkinName("test_pvp_btn")
        inbtn:SetTextTooltip(g.lang == "Japanese" and
                                 "Character Change Helper{nl}装備を外して倉庫へ搬入します。" or
                                 "Character Change Helper{nl}The equipment is removed and brought into the warehouse.")

        local outbtn = invframe:CreateOrGetControl("button", "inv_out", 265, 345, 30, 30)
        AUTO_CAST(outbtn)
        outbtn:SetText("{@st66b}{img chul_arrow 20 20}")
        outbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_out_btn_start")
        outbtn:ShowWindow(1)
        outbtn:SetSkinName("test_pvp_btn")
        outbtn:SetTextTooltip(g.lang == "Japanese" and
                                  "Character Change Helper{nl}倉庫から搬出して装備します。" or
                                  "Character Change Helper{nl}It is carried out from the warehouse and equipped.")
    end
end

function cc_helper_accountwarehouse_init()

    cc_helper_load_settings()

    local awhframe = ui.GetFrame("accountwarehouse")

    local awh_inbtn = awhframe:CreateOrGetControl("button", "in", 565, 120, 30, 30)
    AUTO_CAST(awh_inbtn)
    awh_inbtn:SetText("{img in_arrow 20 20}")
    awh_inbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_in_btn_aethergem_mgr")
    awh_inbtn:ShowWindow(1)
    awh_inbtn:SetSkinName("test_pvp_btn")
    awh_inbtn:SetTextTooltip(g.lang == "Japanese" and
                                 "Character Change Helper{nl}装備を外して倉庫へ搬入します。" or
                                 "Character Change Helper{nl}The equipment is removed and brought into the warehouse.")

    local awh_outbtn = awhframe:CreateOrGetControl("button", "out", 595, 120, 30, 30)
    AUTO_CAST(awh_outbtn)
    awh_outbtn:SetText("{@st66b}{img chul_arrow 20 20}")
    awh_outbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_out_btn_start")
    awh_outbtn:ShowWindow(1)
    awh_outbtn:SetSkinName("test_pvp_btn")
    awh_outbtn:SetTextTooltip(g.lang == "Japanese" and
                                  "Character Change Helper{nl}倉庫から搬出して装備します。" or
                                  "Character Change Helper{nl}It is carried out from the warehouse and equipped.")

    local auto_close = awhframe:CreateOrGetControl("checkbox", "auto_close", 540, 120, 30, 30)
    AUTO_CAST(auto_close)
    auto_close:ShowWindow(1)
    auto_close:SetTextTooltip(
        g.lang == "Japanese" and "動作終了後倉庫とインベントリーを閉じます。" or
            "After the operation is completed,{nl}the warehouse and inventory are closed.")
    auto_close:SetEventScript(ui.LBUTTONUP, "cc_helper_check_setting")
    auto_close:SetCheck(g.settings.auto_close)

    if _G.ADDONS.norisan.monstercard_change ~= nil then

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
    local ischeck = ctrl:IsChecked();

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
            g.settings.eco_mode = 0
        else
            g.settings.eco_mode = 1
        end
    elseif ctrl:GetName() == "auto_close" then
        if ischeck == 0 then
            g.settings.auto_close = 0
        else
            g.settings.auto_close = 1
        end
    end
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
    frame:Resize(235, 440)
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

        local item_cls = GetClassByType("Item", clsid);
        SET_SLOT_ITEM_CLS(slot, item_cls);
        SET_SLOT_IMG(slot, image)
        SET_SLOT_IESID(slot, iesid);

        if name ~= "leg" and name ~= "god" then
            SET_SLOT_BG_BY_ITEMGRADE(slot, item_cls)
        end
        if string.find(name, "hair") ~= nil then
            slot:SetSkinName(g.settings[cid][name].skin)
        end
        if string.find(name, "gem") ~= nil then
            slot:SetSkinName(g.settings[cid][name].skin)
        end
        local icon = slot:GetIcon();
        local inv_item = session.GetInvItemByGuid(iesid);
        if inv_item ~= nil then
            icon:SetTooltipType('wholeitem');
            icon:SetTooltipArg("None", clsid, iesid);
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
                local result = split(str, ":::")

                icon:SetTextTooltip("{ol}Rank: " .. result[4] .. "{nl}" .. result[1] .. "{nl}" .. result[2] .. "{nl}" ..
                                        result[3])
            elseif clsid ~= 0 then
                icon:SetTooltipType('wholeitem');
                icon:SetTooltipArg("None", clsid, iesid);
            end
        end

    end

    function cc_helper_load_copy(cid)

        for name, info in pairs(slot_info) do
            for key, value in pairs(g.settings[cid]) do
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
                        value.iesid, value.image, cid)
                    break
                end
            end
        end

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
        g.settings[g.cid] = deepCopy(g.settings[cid]) -- ディープコピーを行う
        g.settings[g.cid]["name"] = g.login_name -- name を更新

        cc_helper_save_settings()
        return
    end

    function cc_helper_setting_copy(frame, ctrl, str, num)

        local context = ui.CreateContextMenu("MAPFOG_CONTEXT", "Copy source", 0, 0, 0, 0);
        ui.AddContextMenuItem(context, "-----", "")
        for cid, name in pairs(g.cid_name) do
            local scp = ui.AddContextMenuItem(context, name, string.format("cc_helper_load_copy('%s')", cid))
        end
        ui.OpenContextMenu(context);

    end

    local copy = frame:CreateOrGetControl('button', 'copy', 180, 10, 40, 30)
    AUTO_CAST(copy)
    copy:SetText("{ol}copy")
    copy:SetEventScript(ui.LBUTTONUP, "cc_helper_setting_copy")

    local mccuse = frame:CreateOrGetControl("checkbox", "mccuse", 10, 375, 25, 25)
    AUTO_CAST(mccuse)
    mccuse:SetText("{ol}mcc")
    mccuse:SetTextTooltip(g.lang == "Japanese" and
                              "チェックを入れると[Monster Card Change]と連携します。" or
                              "If checked, it will work with [Monster Card Change].")
    mccuse:SetCheck(g.settings[g.cid].mcc_use)
    mccuse:SetEventScript(ui.LBUTTONUP, "cc_helper_check_setting")

    local agmuse = frame:CreateOrGetControl("checkbox", "agmuse", 80, 375, 25, 25)
    AUTO_CAST(agmuse)
    agmuse:SetText("{ol}agm")
    agmuse:SetTextTooltip(
        g.lang == "Japanese" and "チェックを入れると[Aethergem Manager]と連携します。" or
            "If checked, it will work with [Aethergem Manager].")
    agmuse:SetEventScript(ui.LBUTTONUP, "cc_helper_check_setting")
    agmuse:SetCheck(g.settings[g.cid].agm_use)

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
    ecouse:SetCheck(g.settings.eco_mode)

    local delay_title = frame:CreateOrGetControl("richtext", "delay_title", 130, 410)
    delay_title:SetText("{ol}delay")
    function cc_helper_delay_change(frame, ctrl, argStr, argNum)
        local value = tonumber(ctrl:GetText())

        if value ~= nil then
            ui.SysMsg("Delay Time setting set to" .. value)
            g.settings.delay = value
        else
            ui.SysMsg("Invalid value. Please enter one-byte numbers.")
            local text = GET_CHILD_RECURSIVELY(frame, "delay")
            text:SetText("0.3")
            g.settings.delay = 0.3
        end
        cc_helper_save_settings()
    end
    local delay = frame:CreateOrGetControl('edit', 'delay', 175, 410, 50, 20)
    AUTO_CAST(delay)
    delay:SetText("{ol}" .. g.settings.delay)
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
        local invitem = session.GetInvItemByGuid(g.settings[g.cid]["ark"].iesid);
        if invitem == nil then
            return
        end
        local item_obj = GetIES(invitem:GetObject());

        local ypos = 0

        ypos = DRAW_EQUIP_COMMON_TOOLTIP_SMALL_IMG(tooltip, item_obj, "equip_main");

        ypos = DRAW_ARK_LV(tooltip, item_obj, 170, "equip_main")

        ypos = DRAW_ARK_OPTION(tooltip, item_obj, ypos, "equip_main")
        ypos = DRAW_ARK_EXP(tooltip, item_obj, ypos, "equip_main")
        ypos = DRAW_EQUIP_MEMO(tooltip, item_obj, ypos, "equip_main");
        ypos = DRAW_EQUIP_ARK_DESC(tooltip, item_obj, ypos, "equip_main"); -- 각종 설명문

        ypos = DRAW_EQUIP_TRADABILITY(tooltip, item_obj, ypos, "equip_main"); -- 거래 제한
        ypos = DRAW_CANNOT_REINFORCE(tooltip, item_obj, ypos, "equip_main"); -- 초월 및 강화불가

        local isHaveLifeTime = TryGetProp(item_obj, "LifeTime", 0); -- 기간제
        if 0 == tonumber(isHaveLifeTime) then
            ypos = DRAW_SELL_PRICE(tooltip, item_obj, ypos, "equip_main");
        else
            ypos = DRAW_REMAIN_LIFE_TIME(tooltip, item_obj, ypos, "equip_main");
        end

        ypos = ypos + 3;
        -- ypos = DRAW_TOGGLE_EQUIP_DESC(tooltip, item_obj, ypos, "equip_main"); -- 설명문 토글 여부

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
    local frame = ui.GetFrame("cc_helper");
    if frame:IsVisible() == 0 then
        INVENTORY_SET_CUSTOM_RBTNDOWN("None")
        return
    end
    local icon = slot:GetIcon();
    local iconInfo = icon:GetInfo();
    local iesid = iconInfo:GetIESID()
    local inv_item = session.GetInvItemByGuid(iesid);
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
        ["sset_HairAcc_Acc3"] = "hair3",
        ["aether"] = "gem"
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
            local str = cc_helper_hair_option()
            cc_helper_settings_slot(frame, value, item_obj, iesid, clsid, image, str)
        elseif key == "sset_HairAcc_Acc2" and key == parent_name then
            local str = cc_helper_hair_option()
            cc_helper_settings_slot(frame, value, item_obj, iesid, clsid, image, str)
        elseif key == "sset_HairAcc_Acc3" and key == parent_name then
            local str = cc_helper_hair_option()

            cc_helper_settings_slot(frame, value, item_obj, iesid, clsid, image, str)
        elseif gemtype == "aether" and key == "aether" then
            for i = 1, 4 do
                if g.settings[g.cid][tostring(value) .. i].clsid == 0 then
                    cc_helper_settings_slot(frame, value .. i, item_obj, iesid, clsid, image)
                    break
                end
            end

        end

    end
end

function cc_helper_hair_option(item_obj)
    local strInfo = ""
    for i = 1, 3 do
        local propName = "HatPropName_" .. i;
        local propValue = "HatPropValue_" .. i;
        if item_obj[propValue] ~= 0 and item_obj[propName] ~= "None" then
            local opName
            if string.find(item_obj[propName], 'ALLSKILL_') == nil then
                opName = string.format("%s", ScpArgMsg(item_obj[propName]));
            else
                local job = StringSplit(item_obj[propName], '_')[2]
                if job == 'ShadowMancer' then
                    job = 'Shadowmancer'
                end
                opName = string.format("%s", ScpArgMsg(job) .. ' ' .. ScpArgMsg('skill_lv_up_by_count'));
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
    local item_cls = GetClassByType("Item", clsid);
    SET_SLOT_ITEM_CLS(slot, item_cls);
    SET_SLOT_IMG(slot, image)
    SET_SLOT_IESID(slot, iesid);
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
    local icon = slot:GetIcon();
    icon:SetTooltipType('wholeitem');
    icon:SetTooltipArg("None", clsid, iesid);
    g.settings[g.cid][value].iesid = iesid
    g.settings[g.cid][value].image = image
    g.settings[g.cid][value].clsid = clsid
    g.settings[g.cid][value].skin = skin
    g.settings[g.cid][value].memo = str
    cc_helper_save_settings()
end

function cc_helper_frame_drop(frame, ctrl, argstr, argnum)

    local slot = AUTO_CAST(ctrl)
    local lifticon = ui.GetLiftIcon();
    local iconinfo = lifticon:GetInfo();
    local iesid = iconinfo:GetIESID()

    local parent = lifticon:GetParent();
    local fromslot = parent:GetParent();
    local parent_name = fromslot:GetName()

    local inv_item = session.GetInvItemByGuid(iesid);
    local item_obj = GetIES(inv_item:GetObject());
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
        ["aether"] = "gem"
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
        elseif gemtype == "aether" and key == "aether" then
            for i = 1, 4 do
                if g.settings[g.cid][tostring(value) .. i].clsid == 0 then
                    cc_helper_settings_slot(frame, value .. i, item_obj, iesid, clsid, image)
                    break
                end
            end
        end
    end
end

-- putitem
function cc_helper_in_btn_aethergem_mgr()

    local frame = ui.GetFrame("inventory")
    local equip_slots = {"RH", "LH", "RH_SUB", "LH_SUB"}
    if g.agm and g.settings.eco_mode == 0 and g.settings[g.cid].agm_use == 1 then

        for _, slot_name in ipairs(equip_slots) do
            local equip_slot = GET_CHILD_RECURSIVELY(frame, slot_name)

            local icon = equip_slot:GetIcon()
            if icon ~= nil then
                local icon_info = icon:GetInfo()
                local type = icon_info.type
                local equip_item = session.GetEquipItemByType(type)
                local gem = equip_item:GetEquipGemID(2)

                for i = 1, 4 do
                    local gemKey = "gem" .. i

                    if tostring(gem) == tostring(g.settings[g.cid][gemKey].clsid) then
                        cc_helper_msgbox_frame()
                        return
                    end
                end

            end

        end
    end

    cc_helper_in_btn_start()
end

function cc_helper_msgbox_frame()

    if g.settings[g.cid].agm_check == 1 then
        local msg = g.lang == "Japanese" and "[Aether Gem Manager]を起動しますか？" or
                        "Do you want to start[Aether Gem Manager]first?"
        local yes_scp = "cc_helper_in_btn_agm()"
        local no_scp = "cc_helper_in_btn_start()"
        ui.MsgBox(msg, yes_scp, no_scp);
    else
        cc_helper_in_btn_agm()
    end
end

--[[function cc_helper_aether_gem_get_equip()

    local frame = ui.GetFrame("inventory")
    session.ResetItemList()
    local equipItemList = session.GetEquipItemList();
    local inv_tab = GET_CHILD_RECURSIVELY(frame, "inventype_Tab")
    inv_tab:SelectTab(1)

    local isEmptySlot = false;
    if session.GetInvItemList():Count() < MAX_INV_COUNT then
        isEmptySlot = true;
    end
    local equips = {"RH", "LH", "RH_SUB", "LH_SUB"}
    local delay = 0

    if isEmptySlot == true then

        function cc_helper_aether_gem_unequip(equip_index)
            item.UnEquip(equip_index)
        end

        for _, equip in ipairs(equips) do
            local child = GET_CHILD_RECURSIVELY(frame, equip)

            local icon = child:GetIcon()
            local guid = icon:GetInfo():GetIESID()
            if guid ~= "0" then
                if equip == "RH" then
                    cc_helper_aether_gem_unequip(8)
                elseif equip == "LH" then
                    delay = g.settings.delay
                    ReserveScript(string.format("cc_helper_aether_gem_unequip(%d)", 9), delay)
                elseif equip == "RH_SUB" then
                    delay = g.settings.delay + delay
                    ReserveScript(string.format("cc_helper_aether_gem_unequip(%d)", 30), delay)
                end
            end
        end
        cc_helper_aether_gem_reg_item_reserve(delay)
    else
        ui.SysMsg(ScpArgMsg("Auto_inBenToLie_Bin_SeulLosi_PilyoHapNiDa."))
        return
    end
end
function cc_helper_aether_gem_reg_item_reserve(delay)

    for i = 1, 4 do
        ReserveScript(string.format("cc_helper_aether_gem_reg_item(%d,%d)", i, delay), g.settings.delay * i)
        delay = delay + g.settings.delay
    end
end

function cc_helper_aether_gem_reg_item(index, delay)
    print(delay)
    local frame = ui.GetFrame('goddess_equip_manager')
    local equips = {"RH", "LH", "RH_SUB", "LH_SUB"}
    local guid_tbl = {}
    for _, equip in ipairs(equips) do
        local child = GET_CHILD_RECURSIVELY(frame, equip)
        local icon = child:GetIcon()
        local guid = icon:GetInfo():GetIESID()
        table.insert(guid_tbl, guid)
    end
    local guid = guid_tbl[index]
    if guid ~= "0" then
        local inv_item = session.GetInvItemByGuid(guid)
        local item_obj = GetIES(inv_item:GetObject())
        GODDESS_MGR_SOCKET_REG_ITEM(frame, inv_item, item_obj)
        GODDESS_MGR_SOCKET_AETHER_UPDATE(frame)
        cc_helper_aether_gem_remove(guid, index, delay, guid_tbl)
    end
end

function cc_helper_aether_gem_remove(guid, index, delay, guid_tbl)

    local eqpframe = ui.GetFrame("inventory")
    local invTab = GET_CHILD_RECURSIVELY(eqpframe, "inventype_Tab")
    invTab:SelectTab(6)

    local frame = ui.GetFrame("goddess_equip_manager")
    local aether_cover_bg = GET_CHILD_RECURSIVELY(frame, 'aether_cover_bg')
    local socket_slot = GET_CHILD_RECURSIVELY(frame, "socket_slot")
    local aether_inner_bg = GET_CHILD_RECURSIVELY(frame, 'aether_inner_bg')
    local ctrlset = GET_CHILD(aether_inner_bg, 'AETHER_CSET_0')
    local do_remove = GET_CHILD(ctrlset, "do_remove")
    if aether_cover_bg:IsVisible() == 1 then
        return;
    end

    local is_clickable = do_remove:IsEnable()
    if is_clickable == 1 then
        -- 外す方
        local item_guid = socket_slot:GetUserValue('ITEM_GUID')
        local tx_name = 'GODDESS_SOCKET_AETHER_GEM_UNEQUIP'
        pc.ReqExecuteTx_Item(tx_name, item_guid, 2)
        if index == 4 then
            -- ReserveScript("AETHERGEM_MGR_EQUIP()", g.settings.delay)
            delay = delay + g.settings.delay
            ReserveScript(string.format("cc_helper_aether_gem_equip(%d,'%s')", delay, guid_tbl), g.settings.delay)

            return
        end
    end
end

function cc_helper_aether_gem_equip(delay, guid_tbl)

    local frame = ui.GetFrame("inventory")
    local delay = g.settings.delay
    for i = 1, 4 do
        local guid = guid_tbl[i]
        local invitem = session.GetInvItemByGuid(guid);

        if invitem ~= nil then
            local index = invitem.invIndex
            local spotname = nil
            if i == 1 then
                DO_WEAPON_SLOT_CHANGE(frame, 1)
                spotname = "RH"
            elseif i == 2 then
                spotname = "LH"
            elseif i == 3 then
                spotname = "RH_SUB"
            elseif i == 4 then
                spotname = "LH_SUB"
            end
            ReserveScript(string.format("ITEM_EQUIP(%d,'%s')", index, spotname), delay)
            if i ~= 4 then
                delay = delay + delay
            end
            frame:Invalidate();
        end
    end
    return delay
end]]

function cc_helper_in_btn_agm()

    local frame = ui.GetFrame("cc_helper")
    frame:ShowWindow(0)

    local agm = ADDONS.norisan.AETHERGEM_MGR
    agm.guids = {}
    AETHERGEM_MGR_GET_EQUIP()

    ReserveScript("cc_helper_in_btn_start()", g.settings.delay * 10)
end

function cc_helper_in_btn_start()

    g.monstercard = 1 -- !
    g.unequip = 1 -- !

    local frame = ui.GetFrame("inventory")
    if true == BEING_TRADING_STATE() then
        return
    end

    local isEmptySlot = false;
    if session.GetInvItemList():Count() < MAX_INV_COUNT then
        isEmptySlot = true;
    end

    if isEmptySlot == true then
        cc_helper_unequip()
    else
        ui.SysMsg(ScpArgMsg("Auto_inBenToLie_Bin_SeulLosi_PilyoHapNiDa."))
    end

end

function cc_helper_unequip()

    local frame = ui.GetFrame("inventory")
    local eqpTab = GET_CHILD_RECURSIVELY(frame, "inventype_Tab")
    eqpTab:SelectTab(1)
    local equip_tbl = {0, 20, 1, 25, 27}

    local equip_item_list = session.GetEquipItemList();
    for i, equip_index in ipairs(equip_tbl) do
        local equip_item = equip_item_list:GetEquipItemByIndex(equip_index)
        local iesid = equip_item:GetIESID()
        if iesid ~= "0" then
            item.UnEquip(equip_index)
            if i ~= #equip_tbl then
                ReserveScript(string.format("cc_helper_unequip('%s')", frame), g.settings.delay)
                return
            end
        end
    end
    cc_helper_unequip_card()
end

function cc_helper_unequip_card()

    if g.settings[g.cid]["god"].clsid ~= 0 and (g.settings[g.cid]["leg"].clsid ~= 0 and g.settings.eco_mode == 0) then
        MONSTERCARDSLOT_FRAME_OPEN()
    end

    if g.settings[g.cid]["leg"].clsid ~= 0 and g.settings.eco_mode == 0 then

        local slot_index = 13
        local cardid = GETMYCARD_INFO(slot_index - 1)
        local card_info = equipcard.GetCardInfo(slot_index);
        if card_info ~= nil and tostring(cardid) == tostring(g.settings[g.cid]["leg"].clsid) then
            local argStr = slot_index - 1
            argStr = argStr .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
            pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)
            ReserveScript("cc_helper_unequip_card()", g.settings.delay * 3)
            return
        end
    end
    if g.settings[g.cid]["god"].clsid ~= 0 then

        local slot_index = 14
        local cardid = GETMYCARD_INFO(slot_index - 1)
        local card_info = equipcard.GetCardInfo(slot_index);
        if card_info ~= nil and tostring(cardid) == tostring(g.settings[g.cid]["god"].clsid) then
            local argStr = slot_index - 1
            argStr = argStr .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
            pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)

        end
    end
    local frame = ui.GetFrame("monstercardslot")
    if frame:IsVisible() == 1 then
        frame:RunUpdateScript("MONSTERCARDSLOT_CLOSE", 1.0)
    end
    ReserveScript("cc_helper_inv_to_warehouse()", g.settings.delay)
end

function cc_helper_get_warehouse_count()
    local frame = ui.GetFrame("accountwarehouse")
    local accountObj = GetMyAccountObj();
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
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetSortedGuidList();
    local invItemCount = sortedGuidList:Count();

    if invItemCount < max_count then
        return true
    else
        ui.SysMsg(ClMsg('CannotPutBecauseMaxSlot'));
        return false
    end

end

function cc_helper_inv_to_warehouse()

    if not cc_helper_get_warehouse_count() then

        return
    else

    end

    local frame = ui.GetFrame("accountwarehouse");
    local fromFrame = ui.GetFrame("inventory");
    local handle = frame:GetUserIValue('HANDLE')
    local inv_tab = GET_CHILD_RECURSIVELY(fromFrame, "inventype_Tab")

    local temp_tbl = {"seal", "ark", "hair1", "hair2", "hair3", "leg", "god"}
    if frame:IsVisible() == 1 then
        for i, equip_index in ipairs(temp_tbl) do
            local spot = session.GetInvItemByGuid(g.settings[g.cid][temp_tbl[i]].iesid)
            if spot ~= nil then

                local item_cls = GetClassByType('Item', g.settings[g.cid][temp_tbl[i]].clsid)
                local Name = item_cls.Name
                CHAT_SYSTEM(cc_helper_lang("Item to warehousing") .. "：[" .. "{#EE82EE}" .. Name .. "{#FFFF00}]×" ..
                                "{#EE82EE}" .. 1)
                if i <= 5 then
                    inv_tab:SelectTab(1)
                else
                    inv_tab:SelectTab(4)
                end
                item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.settings[g.cid][temp_tbl[i]].iesid, 1, handle)
                imcSound.PlaySoundEvent("sys_jam_slot_equip");
                if i ~= #temp_tbl then
                    ReserveScript("cc_helper_inv_to_warehouse()", g.settings.delay)
                    return
                end
            end

        end
    end
    if g.settings[g.cid].agm_use == 1 and g.settings.eco_mode == 0 then
        ReserveScript("cc_helper_gem_inv_to_warehouse_reserve()", g.settings.delay)
    else
        ReserveScript("cc_helper_end_operation()", g.settings.delay)
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

function cc_helper_gem_inv_to_warehouse_reserve()

    local gems = {}

    for i = 1, 4 do
        local clsid = g.settings[g.cid]["gem" .. i].clsid
        gems[clsid] = true -- clsidをキーとして、値はtrueに設定
    end

    session.ResetItemList()
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList()
    local cnt = guidList:Count()

    g.put_gem = {}

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
        end
    end

    table.sort(g.put_gem, function(a, b)
        return a.level > b.level
    end)

    local index = 1

    -- cc_helper_gem_inv_to_warehouse(index)
    -- put_gemの中身を表示する
    for _, gem in ipairs(g.put_gem) do
        print("level: " .. gem.level .. ", iesid: " .. gem.iesid .. ", clsid: " .. gem.clsid)
    end
    -- レベルを降順に並べ替え
    --[[table.sort(levelTable, function(a, b)
        return a.level > b.level
    end)

    for i, data in ipairs(levelTable) do
        if i <= 4 then
            table.insert(take, data.iesid)
        else
            break -- 上位4つを超えたらループを終了
        end
    end

    local fromframe = ui.GetFrame("accountwarehouse")

    -- アイテムの取得
    for _, item in ipairs(iesids) do
        local id = item.id

        for i = 0, sortedCnt - 1 do
            local guid = sortedGuidList:Get(i)
            local invItem = itemList:GetItemByGuid(guid)
            local iesid = invItem:GetIESID()
            if g.check == 0 then

                if id == iesid then

                    table.insert(take, iesid)
                    break
                end
            else
                if id == iesid and item.type ~= "leg" then

                    table.insert(take, iesid)
                    break
                end
            end
        end

    end
    l
    if frame:IsVisible() == 1 then
       
        gemTab:SelectTab(6)

        local invItemList = session.GetInvItemList()
        local guidList = invItemList:GetGuidList();
        local cnt = guidList:Count();

        for i = 0, cnt - 1 do
            local guid = guidList:Get(i);
            local invItem = invItemList:GetItemByGuid(guid)
            local itemobj = GetIES(invItem:GetObject())
            local iesid = invItem:GetIESID()
            local itemCls = GetClassByType('Item', invItem.type)
            local Name = itemCls.Name

            if tostring(itemobj.ClassID) == tostring(g.settings[g.cid].gem_clsid) then
                local goal_index = cc_helper_get_goal_index()
                CHAT_SYSTEM(cc_helper_lang("Item to warehousing") .. "：[" .. "{#EE82EE}" .. Name .. "{#FFFF00}]×" ..
                                "{#EE82EE}" .. 1)
                item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, iesid, 1, handle, goal_index)
                session.ResetItemList()
                ReserveScript("cc_helper_gem_inv_to_warehouse()", g.settings.delay)

                return
            end

        end

    end

    ReserveScript("cc_helper_end_operation()", g.settings.delay)
    return]]

end

function cc_helper_gem_inv_to_warehouse(index)

    if not cc_helper_get_warehouse_count() then
        return
    end

    local frame = ui.GetFrame("accountwarehouse");
    local fromFrame = ui.GetFrame("inventory");
    local handle = frame:GetUserIValue('HANDLE')
    local gem_tab = GET_CHILD_RECURSIVELY(fromFrame, "inventype_Tab")
    if frame:IsVisible() == 1 then
        gem_tab:SelectTab(6)
    end

    if frame:IsVisible() == 1 then
        session.ResetItemList()
        local invItemList = session.GetInvItemList()
        local guidList = invItemList:GetGuidList();
        local cnt = guidList:Count();

        for i = 0, cnt - 1 do
            local guid = guidList:Get(i);
            local inv_item = invItemList:GetItemByGuid(guid)
            local item_obj = GetIES(inv_item:GetObject())
            local gem_level = get_current_aether_gem_level(item_obj)
            local type = item_obj.ClassID
            local item_cls = GetClassByType('Item', inv_item.type)
            local Name = item_cls.Name

            local clsid = 0
            local level = 0
            for i, gem in ipairs(g.put_gem) do
                clsid = gem.clsid
                level = gem.level
                if type == clsid and gem_level == level then
                    g.put_gem[i] = nil
                    CHAT_SYSTEM(
                        cc_helper_lang("Item to warehousing") .. "：[" .. "{#EE82EE}" .. Name .. "{#FFFF00}]×" ..
                            "{#EE82EE}" .. 1)
                    -- item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, guid, 1, handle)
                    if index < 4 then
                        index = index + 1
                        ReserveScript(string.format("cc_helper_gem_inv_to_warehouse(%d)", index), g.settings.delay)
                        return
                    end
                end
            end

            --[[if #g.put_gem > 0 then -- g.put_gemが空でない場合にのみループを実行
                for i = 1, #g.put_gem do
                    local gem = g.put_gem[i]
                    local clsid = gem[clsid]
                    print(clsid)
                    local level = gem.level
                    g.put_gem[i] = nil -- 現在の要素をnilに設定（削除）
                    index = index + 1
                    break
                end
            end
            print(type .. ":" .. clsid .. ":" .. gem_level .. ":" .. level)
            if type == clsid and gem_level == level then
                CHAT_SYSTEM(cc_helper_lang("Item to warehousing") .. "：[" .. "{#EE82EE}" .. Name .. "{#FFFF00}]×" ..
                                "{#EE82EE}" .. 1)
                item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, guid, 1, handle)
                if index < 4 and #g.put_gem > 0 then
                    ReserveScript("cc_helper_gem_inv_to_warehouse()", g.settings.delay)
                    return
                end
            end]]
        end
    end
end
-- cc_helper_gem_inv_to_warehouse_reserve()
-- takeitem
function cc_helper_out_btn_start()

    g.monstercard = 0
    g.unequip = 0
    g.agm = 1
    -- g.equip = 1
    local iesids = {{
        id = g.settings[g.cid].crown_iesid,
        type = "crown",
        name = "RELIC"
    }, {
        id = g.settings[g.cid].seal_iesid,
        type = "seal",
        name = "SEAL"
    }, {
        id = g.settings[g.cid].ark_iesid,
        type = "ark",
        name = "ARK"
    }, {
        id = g.settings[g.cid].hair1_iesid,
        type = "hair1",
        name = "HAT"
    }, {
        id = g.settings[g.cid].hair2_iesid,
        type = "hair2",
        name = "HAT_T"
    }, {
        id = g.settings[g.cid].hair3_iesid,
        type = "hair3",
        name = "HAT_L"
    }, {
        id = g.settings[g.cid].leg_iesid,
        type = "leg"

    }, {
        id = g.settings[g.cid].god_iesid,
        type = "god"

    }}

    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local sortedGuidList = itemList:GetSortedGuidList()
    local sortedCnt = sortedGuidList:Count()

    local take = {}

    if g.check == 0 then
        local levelTable = {}

        local clsid = g.settings[g.cid].gem_clsid
        for i = 0, sortedCnt - 1 do
            local guid = sortedGuidList:Get(i)
            local invItem = itemList:GetItemByGuid(guid)
            local iesid = invItem:GetIESID()
            local classid = invItem.type
            local obj = GetIES(invItem:GetObject())
            if clsid == classid then
                local level = get_current_aether_gem_level(obj)
                -- レベルとアイテム情報をテーブルに保存
                table.insert(levelTable, {
                    level = level,
                    iesid = iesid
                })
                -- break
            end
        end

        -- レベルを降順に並べ替え
        table.sort(levelTable, function(a, b)
            return a.level > b.level
        end)

        for i, data in ipairs(levelTable) do
            if i <= 4 then
                table.insert(take, data.iesid)
            else
                break -- 上位4つを超えたらループを終了
            end
        end
    end
    local fromframe = ui.GetFrame("accountwarehouse")

    -- アイテムの取得
    for _, item in ipairs(iesids) do
        local id = item.id

        for i = 0, sortedCnt - 1 do
            local guid = sortedGuidList:Get(i)
            local invItem = itemList:GetItemByGuid(guid)
            local iesid = invItem:GetIESID()
            if g.check == 0 then

                if id == iesid then

                    table.insert(take, iesid)
                    break
                end
            else
                if id == iesid and item.type ~= "leg" then

                    table.insert(take, iesid)
                    break
                end
            end
        end

    end

    session.ResetItemList()
    for _, iesid in pairs(take) do
        session.AddItemID(tonumber(iesid), 1)
    end
    item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), fromframe:GetUserIValue("HANDLE"))

    ReserveScript("cc_helper_equip_reserve()", g.settings.delay)
end

function cc_helper_equip_reserve()
    local frame = ui.GetFrame("inventory")

    local iesid_data = {{
        spot = "GODCARD",
        index = 13,
        iesid = g.settings[g.cid].god_iesid
    }, {
        spot = "HAT",
        index = nil,
        iesid = g.settings[g.cid].hair1_iesid
    }, {
        spot = "HAT_T",
        index = nil,
        iesid = g.settings[g.cid].hair2_iesid
    }, {
        spot = "HAT_L",
        index = nil,
        iesid = g.settings[g.cid].hair3_iesid
    }, {
        spot = "SEAL",
        index = nil,
        iesid = g.settings[g.cid].seal_iesid
    }, {
        spot = "ARK",
        index = nil,
        iesid = g.settings[g.cid].ark_iesid
    }, {
        spot = "RELIC",
        index = nil,
        iesid = g.settings[g.cid].crown_iesid
    }, {
        spot = "LEGCARD",
        index = 12,
        iesid = g.settings[g.cid].leg_iesid
    }}

    local delay = 0
    for _, data in ipairs(iesid_data) do
        local spot, index, iesid = data.spot, data.index, data.iesid
        if spot == "GODCARD" then
            local card_index = 13
            local cardid = GETMYCARD_INFO(card_index)

            if cardid == 0 and iesid ~= "" then
                ReserveScript(string.format("cc_helper_card_equip('%s', '%s')", spot, iesid), delay)
                delay = delay + g.settings.delay * 3
            end
        elseif spot == "LEGCARD" then
            if g.check == 0 then
                local card_index = 12
                local cardid = GETMYCARD_INFO(card_index)

                if cardid == 0 and iesid ~= "" then
                    ReserveScript(string.format("cc_helper_card_equip('%s', '%s')", spot, iesid), delay)
                    delay = delay + g.settings.delay * 3
                end
            end
        else
            if iesid ~= "" then
                ReserveScript(string.format("cc_helper_equip('%s', '%s')", spot, iesid), delay)
                delay = delay + g.settings.delay * 1.5
            end
        end
    end

    ReserveScript("cc_helper_end_operation()", delay + 1.0)
end

function cc_helper_equip(spot, iesid)
    local item = session.GetInvItemByGuid(iesid)
    if item then
        local item_index = item.invIndex
        ITEM_EQUIP(item_index, spot)
    end
end

function cc_helper_card_equip(spot, iesid)
    MONSTERCARDSLOT_FRAME_OPEN()

    local card_index
    if spot == "GODCARD" then
        card_index = 13
    elseif spot == "LEGCARD" then
        card_index = 12
    end

    if card_index then
        local argStr = string.format("%d#%s", card_index, tostring(iesid))
        pc.ReqExecuteTx("SCR_TX_EQUIP_CARD_SLOT", argStr)
    end
end

function cc_helper_end_operation()
    -- 装備解除が必要かどうかをチェック
    local function check_unequip(iesid, start_func)
        if iesid ~= "" then
            local item = session.GetInvItemByGuid(iesid)
            if item then
                ReserveScript(start_func, g.settings.delay)
                return true
            end
        end
        return false
    end

    -- カードスロットの装備解除をチェック
    local function check_card_unequip(slot_index, iesid, start_func)
        local cardid = GETMYCARD_INFO(slot_index - 1)
        if cardid ~= 0 and iesid == tostring(cardid) then
            ReserveScript(start_func, g.settings.delay)
            return true
        end
        return check_unequip(iesid, start_func)
    end

    -- 装備解除の処理
    if g.unequip == 1 then
        local unequip_items = {{
            iesid = g.settings[g.cid].seal_iesid,
            start_func = "cc_helper_in_btn_start()"
        }, {
            iesid = g.settings[g.cid].ark_iesid,
            start_func = "cc_helper_in_btn_start()"
        }, {
            iesid = g.settings[g.cid].hair1_iesid,
            start_func = "cc_helper_in_btn_start()"
        }, {
            iesid = g.settings[g.cid].hair2_iesid,
            start_func = "cc_helper_in_btn_start()"
        }, {
            iesid = g.settings[g.cid].hair3_iesid,
            start_func = "cc_helper_in_btn_start()"
        }, {
            iesid = g.settings[g.cid].crown_iesid,
            start_func = "cc_helper_in_btn_start()"
        }}

        for _, item in ipairs(unequip_items) do
            if check_unequip(item.iesid, item.start_func) then
                return
            end
        end

        if g.settings[g.cid].leg_iesid ~= "" and g.check == 0 then
            if check_card_unequip(13, g.settings[g.cid].leg_iesid, "cc_helper_in_btn_start()") then
                return
            end
        end

        if g.settings[g.cid].god_iesid ~= "" then
            if check_card_unequip(14, g.settings[g.cid].god_iesid, "cc_helper_in_btn_start()") then
                return
            end
        end

        g.unequip = 0
    end

    -- インベントリフレームを開いて全てのタブを選択
    local frame = ui.GetFrame("inventory")
    local allTab = GET_CHILD_RECURSIVELY(frame, "inventype_Tab")
    allTab:SelectTab(0)

    -- モンスターカードスロットを閉じるスクリプトを予約
    ReserveScript("MONSTERCARDSLOT_CLOSE()", g.settings.delay * 3)

    ui.SysMsg("[CCH]end of operation")
    if g.settings.auto_close == 1 and g.settings[g.cid].agm_use ~= 1 and g.settings[g.cid].mcc_use ~= 1 then
        frame:ShowWindow(0)
        local awframe = ui.GetFrame("accountwarehouse")
        awframe:ShowWindow(0)
    end

    cc_helper_handle_monstercard_change()
    cc_helper_handle_aether_gem_management()

end

function cc_helper_handle_aether_gem_management()
    if g.agm == 1 and ADDONS.norisan.AETHERGEM_MGR and g.check == 0 and g.settings[g.cid].agm_use == 1 then
        local equipSlots = {"RH", "LH", "RH_SUB", "LH_SUB"}

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
                    if g.settings[g.cid].agm_check == true then
                        local msg = g.lang == "Japanese" and "[Aether Gem Manager]を起動しますか？" or
                                        "Call[Aether Gem Manager]?"
                        local yes_scp = "AETHERGEM_MGR_GET_EQUIP()"
                        ui.MsgBox(msg, yes_scp, "None")
                        break
                    else
                        AETHERGEM_MGR_GET_EQUIP()
                        break
                    end
                    -- return
                end
            end
        end
    end
end

function cc_helper_handle_monstercard_change()
    if ADDONS.norisan.monstercard_change and g.check == 0 and g.settings[g.cid].mcc_use == 1 then
        local msgframe = ui.CreateNewFrame("chat_memberlist", "monstercardchange_msg")
        msgframe:SetLayerLevel(110)

        -- メッセージフレームの配置
        local screenWidth, screenHeight = ui.GetClientInitialWidth(), ui.GetClientInitialHeight()
        msgframe:Resize(390, 90)
        local frameWidth, frameHeight = msgframe:GetWidth(), msgframe:GetHeight()
        msgframe:SetPos((screenWidth - frameWidth) / 2, (screenHeight - frameHeight) / 2)

        -- メッセージフレームのコンテンツ
        local text = msgframe:CreateOrGetControl('richtext', 'text', 15, 15)
        text:SetText("{#FFA500}{ol}Call monstercard change Addon?")

        -- ボタン作成
        local buttons = {{
            name = "equip_btn",
            text = "EQUIP",
            tooltip = "カードプリセットの1番目のセットを装備します。{nl}Equip the first set of card presets.",
            func = "cc_helper_monstercard_change",
            enable = g.monstercard == 0,
            skin = g.monstercard == 0 and "test_red_button" or "test_gray_button"
        }, {
            name = "remove_btn",
            text = "REMOVE",
            tooltip = "モンスターカードを外して倉庫に搬入します。{nl}Remove the monster card and bring it into the warehouse.",
            func = "cc_helper_monstercard_change",
            enable = g.monstercard == 1,
            skin = g.monstercard == 1 and "test_red_button" or "test_gray_button"
        }, {
            name = "open_btn",
            text = "OPEN",
            tooltip = "モンスターカードとモンスターカードプリセットを開きます。{nl}Open the Monster Card and Monster Card Preset.",
            func = "cc_helper_monstercard_change",
            enable = true,
            skin = "test_red_button"
        }, {
            name = "cancel_btn",
            text = "CANCEL",
            tooltip = "",
            func = "cc_helper_monstercard_change",
            enable = true,
            skin = "test_gray_button"
        }}

        for i, btn in ipairs(buttons) do
            local button = msgframe:CreateOrGetControl('button', btn.name, 20 + (i - 1) * 85, 45, 80, 30)
            button:SetText("{ol}" .. btn.text)
            button:SetTextTooltip(btn.tooltip)
            button:SetEventScript(ui.LBUTTONUP, btn.func)
            if btn.enable then
                button:SetEnable(1)
            else
                button:SetEnable(0)
            end
            button:SetSkinName(btn.skin)
        end

        msgframe:ShowWindow(1)
    end
end

-- !
-- mccframe
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
        ReserveScript("monstercard_change_get_info_accountwarehouse()", g.settings.delay)
        return
    elseif tostring(ctrl:GetName()) == "equip_btn" then
        frame:ShowWindow(0)
        monstercard_change_MONSTERCARDPRESET_FRAME_OPEN()
        ReserveScript("monstercard_change_get_presetinfo()", g.settings.delay)
        return
    else
        return
    end

end

--[[function cc_helper_set_load(characterName)
    local LoginName = session.GetMySession():GetPCApc():GetName()

    local set, err = acutil.loadJSON(g.setFileLoc, g.set)

    g.set = set

    local characterData = {}

    for key, data in pairs(g.set) do

        if type(data) == "table" and key == characterName then
            characterData = data
            break
        end
    end

    if characterData then
        g.settings[g.cid] = characterData
        g.settings[g.cid].name = LoginName

        cc_helper_save_settings()
        local frame = ui.GetFrame("cc_helper")
        frame:ShowWindow(0)
        ReserveScript("cc_helper_setting_frame_init()", 0.5)
        return
    end
end

function cc_helper_context(frame, ctr, str, num)

    local set, err = acutil.loadJSON(g.setFileLoc, g.set)
    local context = ui.CreateContextMenu("MAPFOG_CONTEXT", "set load", 0, 0, 0, 0);
    ui.AddContextMenuItem(context, "-----", "")
    for characterName, data in pairs(set) do

        local jobidStr = "" -- jobid を格納する変数

        -- data 内の jobid をすべて取得して連結する
        for key, value in pairs(data) do
            if key:match("^job_%d+$") then -- "job_" で始まるキーをチェック
                local jobClass = GetClassByType("Job", tonumber(value))

                local jobname = TryGetProp(jobClass, "Name", "None")
                local start_index, end_index = string.find(jobname, '@dicID')

                if start_index == 1 then
                    jobname = dic.getTranslatedStr(TryGetProp(jobClass, "Name", "None"))
                end

                if jobidStr == "" then

                    jobidStr = tostring(jobname)
                else
                    jobidStr = jobidStr .. ", " .. tostring(jobname)
                end
            end
        end

        -- jobid を characterName に連結
        local displayText = characterName
        if jobidStr ~= "" then
            displayText = characterName .. " (" .. jobidStr .. ")"
        end

        local scp =
            ui.AddContextMenuItem(context, displayText, string.format("cc_helper_set_load('%s')", characterName))
    end
    ui.OpenContextMenu(context);
end

function cc_helper_set_delete(characterName)

    g.set[characterName] = nil
    ui.SysMsg("Deleted set.")
    acutil.saveJSON(g.setFileLoc, g.set)

end

function cc_helper_delete_context(frame, ctr, str, num)

    local set, err = acutil.loadJSON(g.setFileLoc, g.set)
    local context = ui.CreateContextMenu("MAPFOG_CONTEXT", "set delete", 0, 0, 100, 100);

    ui.AddContextMenuItem(context, "-----", "")

    for characterName, data in pairs(set) do
        local jobidStr = "" -- jobid を格納する変数

        -- data 内の jobid をすべて取得して連結する
        for key, value in pairs(data) do
            if key:match("^job_%d+$") then -- "job_" で始まるキーをチェック
                local jobClass = GetClassByType("Job", tonumber(value))

                local jobname = TryGetProp(jobClass, "Name", "None")
                local start_index, end_index = string.find(jobname, '@dicID')

                if start_index == 1 then
                    jobname = dic.getTranslatedStr(TryGetProp(jobClass, "Name", "None"))
                end

                if jobidStr == "" then

                    jobidStr = tostring(jobname)
                else
                    jobidStr = jobidStr .. ", " .. tostring(jobname)
                end
            end
        end

        -- jobid を characterName に連結
        local displayText = characterName
        if jobidStr ~= "" then
            displayText = characterName .. " (" .. jobidStr .. ")"
        end

        local scp = ui.AddContextMenuItem(context, displayText,
            string.format("cc_helper_set_delete('%s')", characterName))
    end
    ui.OpenContextMenu(context);

end

function cc_helper_set_save(frame, ctr, str, num)
    local set, err = acutil.loadJSON(g.setFileLoc, g.set)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not set then
        set = {}
    end

    local jobtbl = {}
    local mainSession = session.GetMainSession();
    local pcJobInfo = mainSession:GetPCJobInfo();
    local jobCount = pcJobInfo:GetJobCount();
    for i = 0, jobCount - 1 do
        local jobInfo = pcJobInfo:GetJobInfoByIndex(i);
        local jobid = tonumber(jobInfo.jobID)
        table.insert(jobtbl, jobid) -- jobtbl に jobid を追加
    end

    local LoginName = session.GetMySession():GetPCApc():GetName()

    set[LoginName] = {
        seal_iesid = g.settings[g.cid].seal_iesid,
        seal_clsid = g.settings[g.cid].seal_clsid,
        seal_image = g.settings[g.cid].seal_image,

        ark_iesid = g.settings[g.cid].ark_iesid,
        ark_clsid = g.settings[g.cid].ark_clsid,
        ark_image = g.settings[g.cid].ark_image,

        gem_clsid = g.settings[g.cid].gem_clsid,
        gem_image = g.settings[g.cid].gem_image,

        leg_iesid = g.settings[g.cid].leg_iesid,
        leg_clsid = g.settings[g.cid].leg_clsid,
        leg_image = g.settings[g.cid].leg_image,

        god_iesid = g.settings[g.cid].god_iesid,
        god_clsid = g.settings[g.cid].god_clsid,
        god_image = g.settings[g.cid].god_image,

        hair1_image = g.settings[g.cid].hair1_image,
        hair1_iesid = g.settings[g.cid].hair1_iesid,
        hair1_clsid = g.settings[g.cid].hair1_clsid,

        hair2_image = g.settings[g.cid].hair2_image,
        hair2_iesid = g.settings[g.cid].hair2_iesid,
        hair2_clsid = g.settings[g.cid].hair2_clsid,

        hair3_image = g.settings[g.cid].hair3_image,
        hair3_iesid = g.settings[g.cid].hair3_iesid,
        hair3_clsid = g.settings[g.cid].hair3_clsid,

        crown_image = g.settings[g.cid].crown_image,
        crown_iesid = g.settings[g.cid].crown_iesid,
        crown_clsid = g.settings[g.cid].crown_clsid,

        mcc_use = g.settings[g.cid].mcc_use,
        agm_use = g.settings[g.cid].agm_use

    }
    for index, jobid in ipairs(jobtbl) do
        local key = string.format("job_%d", index) -- ユニークなキーを作成
        set[LoginName][key] = jobid
    end

    g.set = set
    ui.SysMsg("Saved set.")
    acutil.saveJSON(g.setFileLoc, g.set)
end]]

--[[function cc_helper_unequip()

    local frame = ui.GetFrame("inventory")
    local eqpTab = GET_CHILD_RECURSIVELY(frame, "inventype_Tab")
    eqpTab:SelectTab(1)
    local equip_tbl = {
        [1] = "SEAL",
        [3] = "RELIC",
        [2] = "ARK",
        [4] = "HAT",
        [5] = "HAT_L",
        [6] = "HAT_T"
    }
    for i = 1, 6 do
        for key, value in pairs(equip_tbl) do
            local slot = GET_CHILD_RECURSIVELY(frame, value)
            local icon = slot:GetIcon()
            if icon ~= nil then
                local icon_info = icon:GetInfo()

                if icon_info ~= nil then
                    local iesid = icon_info:GetIESID()

                    if value == "SEAL" and i == key then

                        if iesid ~= nil and tostring(iesid) == g.settings[g.cid].seal_iesid then

                            local index = 25
                            item.UnEquip(index)
                            ReserveScript(string.format("cc_helper_unequip('%s')", frame), g.settings.delay)
                            return
                        end
                    end
                    if value == "RELIC" and i == key then

                        if iesid ~= nil and tostring(iesid) == g.settings[g.cid].crown_iesid then
                            local index = 29 -- スロットインデックスを適切な値に設定する必要があります
                            item.UnEquip(index)
                            ReserveScript(string.format("cc_helper_unequip('%s')", frame), g.settings.delay)
                            return
                        end
                    end
                    if value == "ARK" and i == key then

                        if iesid ~= nil and tostring(iesid) == g.settings[g.cid].ark_iesid then
                            local index = 27 -- スロットインデックスを適切な値に設定する必要があります
                            item.UnEquip(index)
                            ReserveScript(string.format("cc_helper_unequip('%s')", frame), g.settings.delay)
                            return

                        end
                    end
                    if value == "HAT" and i == key then

                        if iesid ~= nil and tostring(iesid) == g.settings[g.cid].hair1_iesid then
                            local index = 0 -- スロットインデックスを適切な値に設定する必要があります
                            item.UnEquip(index)
                            ReserveScript(string.format("cc_helper_unequip('%s')", frame), g.settings.delay)
                            return
                        end
                    end
                    if value == "HAT_T" and i == key then

                        if iesid ~= nil and tostring(iesid) == g.settings[g.cid].hair2_iesid then

                            local index = 20 -- スロットインデックスを適切な値に設定する必要があります
                            item.UnEquip(index)
                            ReserveScript(string.format("cc_helper_unequip('%s')", frame), g.settings.delay)
                            return
                        end
                    end
                    if value == "HAT_L" and i == key then

                        if iesid ~= nil and tostring(iesid) == g.settings[g.cid].hair3_iesid then

                            local index = 1 -- スロットインデックスを適切な値に設定する必要があります
                            item.UnEquip(index)
                            ReserveScript(string.format("cc_helper_unequip('%s')", frame), g.settings.delay)
                            return
                        end
                    end
                end
            end

        end
    end
    eqpTab:SelectTab(1)
    local legtrue = 0
    cc_helper_unequip_card(legtrue)
end]]

-- itemequip
--[[function cc_helper_equip_reserve()
    local frame = ui.GetFrame("inventory")

    local iesids = {
        [1] = {
            GODCARD = g.settings[g.cid].god_iesid
        },
        [2] = {
            HAT = g.settings[g.cid].hair1_iesid
        },
        [3] = {
            HAT_T = g.settings[g.cid].hair2_iesid
        },
        [4] = {
            HAT_L = g.settings[g.cid].hair3_iesid
        },
        [5] = {
            SEAL = g.settings[g.cid].seal_iesid
        },
        [6] = {
            ARK = g.settings[g.cid].ark_iesid
        },

        [7] = {
            RELIC = g.settings[g.cid].crown_iesid
        },
        [8] = {
            LEGCARD = g.settings[g.cid].leg_iesid
        }

    }
    local delay = 0
    for index, data in ipairs(iesids) do
        local spot, iesid = next(data) -- テーブルの最初のキーと値を取得

        if spot == "GODCARD" then
            local god_index = 13
            local cardid = GETMYCARD_INFO(god_index)

            if cardid == 0 and iesid ~= nil then

                ReserveScript(string.format("cc_helper_card_equip('%s','%s')", spot, iesid), delay)
                delay = delay + g.settings.delay * 3

            end

        elseif spot ~= "LEGCARD" and spot ~= "GODCARD" then

            -- print("item" .. delay)
            if iesid ~= "" then

                ReserveScript(string.format("cc_helper_equip('%s','%s')", spot, iesid), delay)
                delay = delay + g.settings.delay * 1.5

            end

        elseif spot == "LEGCARD" and g.check == 0 then
            local leg_index = 12
            local cardid = GETMYCARD_INFO(leg_index)
            -- print(delay)
            if cardid == 0 and iesid ~= nil then
                ReserveScript(string.format("cc_helper_card_equip('%s','%s')", spot, iesid), delay)
            end
        end

    end

    ReserveScript("cc_helper_end_operation()", delay + 1.0)

end

function cc_helper_equip(spot, iesid)
    local item = session.GetInvItemByGuid(tonumber(iesid))
    if item ~= nil then

        local item_index = item.invIndex
        ITEM_EQUIP(item_index, spot)
    end
end

function cc_helper_card_equip(spot, iesid)

    MONSTERCARDSLOT_FRAME_OPEN()

    if spot == "GODCARD" then
        local god_index = 13
        local argStr = string.format("%d#%s", god_index, tostring(iesid));
        pc.ReqExecuteTx("SCR_TX_EQUIP_CARD_SLOT", argStr);
        return
    elseif spot == "LEGCARD" then

        local leg_index = 12
        local argStr = string.format("%d#%s", leg_index, tostring(iesid));
        pc.ReqExecuteTx("SCR_TX_EQUIP_CARD_SLOT", argStr);
        return
    end

end]]

--[[ 終了処理
function cc_helper_end_operation()

    if g.unequip == 1 then
        if g.settings[g.cid].seal_iesid ~= "" then

            local seal = session.GetInvItemByGuid(g.settings[g.cid].seal_iesid)

            if seal ~= nil then
                ReserveScript("cc_helper_in_btn_start()", g.settings.delay)
                return
            end
        end
        if g.settings[g.cid].ark_iesid ~= "" then
            local ark = session.GetInvItemByGuid(g.settings[g.cid].ark_iesid)

            if ark ~= nil then
                ReserveScript("cc_helper_in_btn_start()", g.settings.delay)
                return
            end
        end

        if g.settings[g.cid].hair1_iesid ~= "" then
            local hair1 = session.GetInvItemByGuid(g.settings[g.cid].hair1_iesid)

            if hair1 ~= nil then
                ReserveScript("cc_helper_in_btn_start()", g.settings.delay)
                return
            end
        end
        if g.settings[g.cid].hair2_iesid ~= "" then
            local hair2 = session.GetInvItemByGuid(g.settings[g.cid].hair2_iesid)

            if hair2 ~= nil then
                ReserveScript("cc_helper_in_btn_start()", g.settings.delay)
                return
            end
        end
        if g.settings[g.cid].hair3_iesid ~= "" then
            local hair3 = session.GetInvItemByGuid(g.settings[g.cid].hair3_iesid)

            if hair3 ~= nil then
                ReserveScript("cc_helper_in_btn_start()", g.settings.delay)
                return
            end
        end
        if g.settings[g.cid].crown_iesid ~= "" then
            local crown = session.GetInvItemByGuid(g.settings[g.cid].crown_iesid)

            if crown ~= nil then
                ReserveScript("cc_helper_in_btn_start()", g.settings.delay)
                return
            end
        end
        if g.settings[g.cid].leg_iesid ~= "" and g.check == 0 then
            local slot_index = 13
            local cardid = GETMYCARD_INFO(slot_index - 1)
            if cardid ~= 0 and g.settings[g.cid].leg_iesid == tostring(cardid) then
                ReserveScript("cc_helper_in_btn_start()", g.settings.delay)
                return
            end
            local leg = session.GetInvItemByGuid(g.settings[g.cid].leg_iesid)

            if leg ~= nil then
                ReserveScript("cc_helper_in_btn_start()", g.settings.delay)
                return
            end
        end
        if g.settings[g.cid].god_iesid ~= "" then
            local slot_index = 14
            local cardid = GETMYCARD_INFO(slot_index - 1)
            if cardid ~= 0 and g.settings[g.cid].god_iesid == tostring(cardid) then
                ReserveScript("cc_helper_in_btn_start()", g.settings.delay)
                return
            end
            local god = session.GetInvItemByGuid(g.settings[g.cid].god_iesid)

            if god ~= nil then
                ReserveScript("cc_helper_in_btn_start()", g.settings.delay)
                return
            end
        end

        g.unequip = 0

    end

    

    local frame = ui.GetFrame("inventory")
    local allTab = GET_CHILD_RECURSIVELY(frame, "inventype_Tab")
    allTab:SelectTab(0)

    ReserveScript("MONSTERCARDSLOT_CLOSE()", g.settings.delay * 3)

    if ADDONS.norisan.monstercard_change ~= nil and g.check == 0 and g.settings[g.cid].mcc_use == 1 then

        local msgframe = ui.CreateNewFrame("chat_memberlist", "monstercardchange_msg");
        AUTO_CAST(msgframe)
        msgframe:SetLayerLevel(110);

        local screenWidth = ui.GetClientInitialWidth()
        local screenHeight = ui.GetClientInitialHeight()
        msgframe:Resize(390, 90)
        local frameWidth = msgframe:GetWidth()
        local frameHeight = msgframe:GetHeight()

        local posX = (screenWidth - frameWidth) / 2
        local posY = (screenHeight - frameHeight) / 2

        msgframe:SetPos(posX, posY)

        local text = msgframe:CreateOrGetControl('richtext', 'text', 15, 15)
        AUTO_CAST(text)
        text:SetText("{#FFA500}{ol}Call monstercard change Addon?")

        local equip_btn = msgframe:CreateOrGetControl('button', 'equip_btn', 20, 45, 80, 30)
        AUTO_CAST(equip_btn)
        equip_btn:SetText("{ol}EQUIP")
        equip_btn:SetTextTooltip(
            "カードプリセットの1番目のセットを装備します。{nl}Equip the first set of card presets.")
        equip_btn:SetEventScript(ui.LBUTTONUP, "cc_helper_monstercard_change")
        if g.monstercard == 1 then
            equip_btn:SetEnable(0)
            equip_btn:SetSkinName("test_gray_button")
        elseif g.monstercard == 0 then
            equip_btn:SetEnable(1)
            equip_btn:SetSkinName("test_red_button")
        else
            equip_btn:SetEnable(0)
            equip_btn:SetSkinName("test_gray_button")
        end

        local remove_btn = msgframe:CreateOrGetControl('button', 'remove_btn', 105, 45, 90, 30)
        AUTO_CAST(remove_btn)
        remove_btn:SetText("{ol}REMOVE")
        remove_btn:SetTextTooltip(
            "モンスターカードを外して倉庫に搬入します。{nl}Remove the monster card and bring it into the warehouse.")
        remove_btn:SetEventScript(ui.LBUTTONUP, "cc_helper_monstercard_change")
        if g.monstercard == 1 then
            remove_btn:SetEnable(1)
            remove_btn:SetSkinName("test_red_button")
        elseif g.monstercard == 0 then
            remove_btn:SetEnable(0)
            remove_btn:SetSkinName("test_gray_button")
        else
            remove_btn:SetEnable(0)
            remove_btn:SetSkinName("test_gray_button")
        end

        local open_btn = msgframe:CreateOrGetControl('button', 'open_btn', 200, 45, 80, 30)
        AUTO_CAST(open_btn)
        open_btn:SetText("{ol}OPEN")
        open_btn:SetTextTooltip(
            "モンスターカードとモンスターカードプリセットを開きます。{nl}Open the Monster Card and Monster Card Preset.")
        open_btn:SetEventScript(ui.LBUTTONUP, "cc_helper_monstercard_change")

        local cancel_btn = msgframe:CreateOrGetControl('button', 'cancel_btn', 285, 45, 80, 30)
        AUTO_CAST(cancel_btn)
        cancel_btn:SetText("{ol}CANCEL")
        cancel_btn:SetEventScript(ui.LBUTTONUP, "cc_helper_monstercard_change")

        msgframe:ShowWindow(1)

    end

    

    if g.agm == 1 then
        if ADDONS.norisan.AETHERGEM_MGR ~= nil and g.check == 0 and g.settings[g.cid].agm_use == 1 then
            local equipSlots = {"RH", "LH", "RH_SUB", "LH_SUB"}

            for _, slotName in ipairs(equipSlots) do
                local equipSlot = GET_CHILD_RECURSIVELY(frame, slotName)
                local Icon = equipSlot:GetIcon()

                if Icon ~= nil then
                    local IconInfo = Icon:GetInfo()
                    local Guid = IconInfo:GetIESID()

                    local itemCls = GetClassByType("Item", session.GetEquipItemByGuid(Guid).type);
                    local classID = itemCls.ClassID;
                    local equipItem = session.GetEquipItemByType(classID)
                    local gem = equipItem:GetEquipGemID(2)

                    if gem == 0 then
                        g.agm = 0
                        local msg = "Call Aether Gem Manager?"
                        local yes_scp = "AETHERGEM_MGR_GET_EQUIP()"
                        ui.MsgBox(msg, yes_scp, "None");
                        return
                    end
                end
            end
        end
    end

    ui.SysMsg("[CCH]end of operation")
end]]

--[[function cc_helper_take_items_from_warehouse(iesid, type)

    local invframe = ui.GetFrame("inventory")
    local invTab = GET_CHILD_RECURSIVELY(invframe, "inventype_Tab")
    if type == "god" then
        invTab:SelectTab(4)
    elseif type == "leg" and g.check == 0 then
        invTab:SelectTab(4)
    else
        invTab:SelectTab(1)
    end

    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local invItem = itemList:GetItemByGuid(iesid)
    local obj = GetIES(invItem:GetObject());
    if obj.ClassName ~= MONEY_NAME then

        session.ResetItemList()
        session.AddItemID(tonumber(iesid), 1)
        item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
            ui.GetFrame("accountwarehouse"):GetUserIValue("HANDLE"))

        return
    end
end

function cc_helper_take_gem_item_from_warehouse(delay)
    g.agm = 1
    local fromframe = ui.GetFrame("accountwarehouse")

    if fromframe:IsVisible() == 1 then
        if g.settings[g.cid].gem_clsid ~= 0 and g.check == 0 then

            local invframe = ui.GetFrame("inventory")
            local gemTab = GET_CHILD_RECURSIVELY(invframe, "inventype_Tab")
            gemTab:SelectTab(6)

            local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
            local guidList = itemList:GetGuidList();
            local sortedGuidList = itemList:GetSortedGuidList();
            local sortedCnt = sortedGuidList:Count();
            for i = 0, sortedCnt - 1 do
                local guid = sortedGuidList:Get(i)
                local invItem = itemList:GetItemByGuid(guid)
                local iesid = invItem:GetIESID()

                local obj = GetIES(invItem:GetObject());
                if obj.ClassName ~= MONEY_NAME then

                    if tostring(obj.ClassID) == tostring(g.settings[g.cid].gem_clsid) then

                        session.ResetItemList()
                        session.AddItemID(tonumber(iesid), 1)
                        item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                            fromframe:GetUserIValue("HANDLE"))
                        delay = delay + g.settings.delay
                        ReserveScript(string.format("cc_helper_take_gem_item_from_warehouse(%d)", delay),
                            g.settings.delay)

                        return

                    end
                end

            end
            ReserveScript("cc_helper_equip_reserve()", delay)
        else
            ReserveScript("cc_helper_equip_reserve()", delay)
        end
    end

end]]

