-- v1.1.4 コード大幅見直し。ヘアアクセバグ修正。失敗した時にリトライ昨日追加。
-- v1.1.5 登録したカードと別のカードが付いていると無限ループに陥る問題修正
-- v1.1.6 多分もう少しだけ失敗しにくく
-- v1.1.7 入庫時のシステムチャットつけた。出庫時と装備の順番固定。多分早くなった。
-- v1.1.8 設定のコピー機能付けた。なんかダサイけど仕方ない。
-- v1.1.9 インベと倉庫閉じるチェック付けた。
-- v1.2.0 倉庫閉じるチェックボックスのセットチェック漏れてた。
-- v1.2.1 ロード処理見直し。
-- v1.2.2 エコモードバグってたの修正。
local addonName = "CC_HELPER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.2.2"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings_new.json', addonNameLower)
g.setFileLoc = string.format('../addons/%s/set.json', addonNameLower)

local acutil = require("acutil")
local os = require("os")

function cc_helper_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function cc_helper_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end
    if not settings then

        g.settings.delay = 0.3 -- 新しく追加
    end

    local LoginName = session.GetMySession():GetPCApc():GetName()

    local cid_settings = {}
    cid_settings = {
        name = LoginName,
        seal_iesid = "",
        seal_clsid = 0,
        seal_image = "",

        ark_iesid = "",
        ark_clsid = 0,
        ark_image = "",

        gem_clsid = 0,
        gem_image = "",

        leg_iesid = "",
        leg_clsid = 0,
        leg_image = "",

        god_iesid = "",
        god_clsid = 0,
        god_image = "",

        hair1_image = "",
        hair1_iesid = "",
        hair1_clsid = 0,

        hair2_image = "",
        hair2_iesid = "",
        hair2_clsid = 0,

        hair3_image = "",
        hair3_iesid = "",
        hair3_clsid = 0,

        crown_image = "",
        crown_iesid = "",
        crown_clsid = 0,

        mcc_use = 0,
        agm_use = 0
    }

    if g.settings[g.LOGINCID] == nil then
        g.settings[g.LOGINCID] = {}
        g.settings[g.LOGINCID] = cid_settings

    else

        g.settings[g.LOGINCID] = settings[g.LOGINCID]

    end

    cc_helper_save_settings()
end

g.load = false

function CC_HELPER_ON_INIT(addon, frame)
    -- CHAT_SYSTEM("CCHELPER")
    g.addon = addon
    g.frame = frame
    g.LOGINCID = info.GetCID(session.GetMyHandle())
    g.settings = g.settings or {}

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then

        acutil.setupEvent(addon, "ACCOUNTWAREHOUSE_CLOSE", "cc_helper_ACCOUNTWAREHOUSE_CLOSE");
        acutil.setupEvent(addon, "INVENTORY_CLOSE", "cc_helper_settings_close");
        acutil.setupEvent(addon, "UI_TOGGLE_INVENTORY", "cc_helper_invframe_init");
        acutil.setupEvent(addon, "INVENTORY_OPEN", "cc_helper_invframe_init");

        addon:RegisterMsg("OPEN_DLG_ACCOUNTWAREHOUSE", "cc_helper_accountwarehouse_init")
        if not g.load then
            g.check = 0 -- ここは後程見直し
            g.load = true
            cc_helper_load_settings()
        end
    end

end

function cc_helper_invframe_init()

    local invframe = ui.GetFrame("inventory")

    local setbtn = invframe:CreateOrGetControl("button", "set", 232, 345, 30, 30)
    AUTO_CAST(setbtn)
    setbtn:SetSkinName("None")
    setbtn:SetText("{img config_button_normal 30 30}")
    setbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_setting_frame_init")
    setbtn:SetTextTooltip("Character Change Helper{nl}" ..
                              "マウス左ボタンクリック、キャラ毎に出し入れするアイテム設定。{nl}" ..
                              "Left mouse button click, setting items to be moved in and out for each character.")

    local eco = invframe:CreateOrGetControl("richtext", "eco", 210, 342)
    eco:SetText("{#FF0000}{s10}Eco")

    local checkbox = invframe:CreateOrGetControl('checkbox', 'checkbox', 210, 350, 25, 25)
    AUTO_CAST(checkbox)
    checkbox:SetCheck(g.check)
    checkbox:SetEventScript(ui.LBUTTONUP, "cc_helper_check_setting")
    checkbox:ShowWindow(1)
    checkbox:SetTextTooltip("Character Change Helper{nl}" ..
                                "チェックすると外すのにシルバーが必要なレジェンドカードとエーテルジェムの動作をスキップします。{nl}" ..
                                "If checked, it skips the operation of legend cards and ether gems that require silver to remove.")

    local awhframe = ui.GetFrame("accountwarehouse")
    if awhframe:IsVisible() == 1 then
        local inbtn = invframe:CreateOrGetControl("button", "inv_in", 263, 345, 30, 30)
        AUTO_CAST(inbtn)
        inbtn:SetText("{img in_arrow 20 20}")
        inbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_in_btn_aethergem_mgr")

        inbtn:ShowWindow(1)
        inbtn:SetSkinName("test_pvp_btn")
        inbtn:SetTextTooltip("Character Change Helper{nl}" .. "装備を外して倉庫へ搬入します。{nl}" ..
                                 "The equipment is removed and brought into the warehouse.")

        local outbtn = invframe:CreateOrGetControl("button", "inv_out", 293, 345, 30, 30)
        AUTO_CAST(outbtn)
        outbtn:SetText("{@st66b}{img chul_arrow 20 20}")
        outbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_out_btn_start")
        outbtn:ShowWindow(1)
        outbtn:SetSkinName("test_pvp_btn")
        outbtn:SetTextTooltip("Character Change Helper{nl}" .. "倉庫から搬出して装備します。{nl}" ..
                                  "It is carried out from the warehouse and equipped.")
    end

end

function cc_helper_accountwarehouse_init()

    local awhframe = ui.GetFrame("accountwarehouse")

    local awh_inbtn = awhframe:CreateOrGetControl("button", "in", 545, 120, 40, 30)
    AUTO_CAST(awh_inbtn)
    awh_inbtn:SetText("{img in_arrow 20 20}")
    awh_inbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_in_btn_aethergem_mgr")
    awh_inbtn:ShowWindow(1)
    awh_inbtn:SetSkinName("test_pvp_btn")
    awh_inbtn:SetTextTooltip("Character Change Helper{nl}" .. "装備を外して倉庫へ搬入します。{nl}" ..
                                 "The equipment is removed and brought into the warehouse.")

    local awh_outbtn = awhframe:CreateOrGetControl("button", "out", 585, 120, 40, 30)
    AUTO_CAST(awh_outbtn)
    awh_outbtn:SetText("{@st66b}{img chul_arrow 20 20}")
    awh_outbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_out_btn_start")
    awh_outbtn:ShowWindow(1)
    awh_outbtn:SetSkinName("test_pvp_btn")
    awh_outbtn:SetTextTooltip("Character Change Helper{nl}" .. "倉庫から搬出して装備します。{nl}" ..
                                  "It is carried out from the warehouse and equipped.")

    local auto_close = awhframe:CreateOrGetControl("checkbox", "auto_close", 515, 120, 30, 30)
    AUTO_CAST(auto_close)
    auto_close:ShowWindow(1)
    auto_close:SetTextTooltip("After the operation is completed,{nl}the warehouse and inventory are closed.{nl}" ..
                                  "動作終了後倉庫とインベントリーを閉じます。")
    auto_close:SetEventScript(ui.LBUTTONUP, "cc_helper_check_setting")
    auto_close:SetCheck(g.settings.auto_close)

    if _G.ADDONS.norisan.monstercard_change ~= nil then

        local mccbtn = awhframe:CreateOrGetControl("button", "mcc", 625, 120, 30, 30)
        AUTO_CAST(mccbtn)
        mccbtn:SetSkinName("test_red_button")
        mccbtn:SetTextAlign("right", "center")
        mccbtn:SetText("{img monsterbtn_image 30 20}{/}")
        mccbtn:SetTextTooltip("カード自動搬出入、自動着脱{nl}" ..
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

function cc_helper_set_load(characterName)
    local LoginName = session.GetMySession():GetPCApc():GetName()

    local set, err = acutil.loadJSON(g.setFileLoc, g.set)

    g.set = set

    local characterData = {}

    -- キャラクターデータを検索
    for key, data in pairs(g.set) do
        -- print(string.format("確認中 CharacterName: %s", characterName))
        if type(data) == "table" and key == characterName then
            characterData = data
            break
        end
    end

    --[[ `characterData` の中身を表示
    print("characterData の中身:")
    for key, value in pairs(characterData) do
        print(string.format("%s: %s", key, tostring(value)))
    end]]

    if characterData then
        g.settings[g.LOGINCID] = characterData
        g.settings[g.LOGINCID].name = LoginName
        -- print(g.settings[g.LOGINCID].name)
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
        seal_iesid = g.settings[g.LOGINCID].seal_iesid,
        seal_clsid = g.settings[g.LOGINCID].seal_clsid,
        seal_image = g.settings[g.LOGINCID].seal_image,

        ark_iesid = g.settings[g.LOGINCID].ark_iesid,
        ark_clsid = g.settings[g.LOGINCID].ark_clsid,
        ark_image = g.settings[g.LOGINCID].ark_image,

        gem_clsid = g.settings[g.LOGINCID].gem_clsid,
        gem_image = g.settings[g.LOGINCID].gem_image,

        leg_iesid = g.settings[g.LOGINCID].leg_iesid,
        leg_clsid = g.settings[g.LOGINCID].leg_clsid,
        leg_image = g.settings[g.LOGINCID].leg_image,

        god_iesid = g.settings[g.LOGINCID].god_iesid,
        god_clsid = g.settings[g.LOGINCID].god_clsid,
        god_image = g.settings[g.LOGINCID].god_image,

        hair1_image = g.settings[g.LOGINCID].hair1_image,
        hair1_iesid = g.settings[g.LOGINCID].hair1_iesid,
        hair1_clsid = g.settings[g.LOGINCID].hair1_clsid,

        hair2_image = g.settings[g.LOGINCID].hair2_image,
        hair2_iesid = g.settings[g.LOGINCID].hair2_iesid,
        hair2_clsid = g.settings[g.LOGINCID].hair2_clsid,

        hair3_image = g.settings[g.LOGINCID].hair3_image,
        hair3_iesid = g.settings[g.LOGINCID].hair3_iesid,
        hair3_clsid = g.settings[g.LOGINCID].hair3_clsid,

        crown_image = g.settings[g.LOGINCID].crown_image,
        crown_iesid = g.settings[g.LOGINCID].crown_iesid,
        crown_clsid = g.settings[g.LOGINCID].crown_clsid,

        mcc_use = g.settings[g.LOGINCID].mcc_use,
        agm_use = g.settings[g.LOGINCID].agm_use

    }
    for index, jobid in ipairs(jobtbl) do
        local key = string.format("job_%d", index) -- ユニークなキーを作成
        set[LoginName][key] = jobid
    end

    g.set = set
    ui.SysMsg("Saved set.")
    acutil.saveJSON(g.setFileLoc, g.set)
end

-- settingframe
function cc_helper_setting_frame_init()
    local awhframe = ui.GetFrame("accountwarehouse")
    ACCOUNTWAREHOUSE_CLOSE(awhframe)
    UI_TOGGLE_INVENTORY()

    cc_helper_load_settings()

    local frame = ui.GetFrame(addonNameLower)
    frame:SetSkinName("test_frame_low")
    frame:SetLayerLevel(93)
    frame:Resize(270, 285)
    frame:SetPos(1140, 380)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    frame:EnableHitTest(1)

    if frame:IsVisible() == 0 then
        frame:ShowWindow(1)
    else
        frame:ShowWindow(0)
    end

    local load = frame:CreateOrGetControl('button', 'load', 40, 10, 40, 30)
    AUTO_CAST(load)
    load:SetText("load")
    load:SetEventScript(ui.LBUTTONUP, "cc_helper_context")

    local save = frame:CreateOrGetControl('button', 'save', 90, 10, 40, 30)
    AUTO_CAST(save)
    save:SetText("save")
    save:SetEventScript(ui.LBUTTONUP, "cc_helper_set_save")

    local delete = frame:CreateOrGetControl('button', 'delete', 140, 10, 60, 30)
    AUTO_CAST(delete)
    delete:SetText("delete")
    delete:SetEventScript(ui.LBUTTONUP, "cc_helper_delete_context")

    INVENTORY_SET_CUSTOM_RBTNDOWN("cc_helper_inv_rbtn")

    -- local title = frame:CreateOrGetControl("richtext", "title", 40, 15)
    -- title:SetText("{ol}{s18}CC Helper " .. "{s16}" .. ver)

    local mcc_title = frame:CreateOrGetControl("richtext", "mcc_title", 10, 250)
    mcc_title:SetText("{ol}mcc")
    local mccuse = frame:CreateOrGetControl("checkbox", "mccuse", 45, 250, 25, 25)
    AUTO_CAST(mccuse)
    mccuse:SetTextTooltip("チェックを入れると[Monster Card Change]と連携します。{nl}" ..
                              "If checked, it will work with [Monster Card Change].")
    mccuse:SetCheck(g.settings[g.LOGINCID].mcc_use)
    mccuse:SetEventScript(ui.LBUTTONUP, "cc_helper_check_setting")

    local agm_title = frame:CreateOrGetControl("richtext", "agm_title", 80, 250)
    agm_title:SetText("{ol}agm")
    local agmuse = frame:CreateOrGetControl("checkbox", "agmuse", 115, 250, 25, 25)
    AUTO_CAST(agmuse)
    agmuse:SetTextTooltip("チェックを入れると[Aethergem Manager]と連携します。{nl}" ..
                              "If checked, it will work with [Aethergem Manager].")
    agmuse:SetEventScript(ui.LBUTTONUP, "cc_helper_check_setting")
    agmuse:SetCheck(g.settings[g.LOGINCID].agm_use)

    local close = frame:CreateOrGetControl('button', 'close', 0, 0, 30, 30)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.LEFT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "cc_helper_settings_close")

    local delay_title = frame:CreateOrGetControl("richtext", "delay_title", 150, 250)
    delay_title:SetText("{ol}Delay")
    local delay = frame:CreateOrGetControl('edit', 'delay', 200, 245, 60, 30)
    AUTO_CAST(delay)

    delay:SetText("{ol}" .. g.settings.delay)

    delay:SetFontName("white_16_ol")
    delay:SetTextAlign("center", "center")
    delay:SetEventScript(ui.ENTERKEY, "cc_helper_delay_change")
    delay:SetTextTooltip(
        "動作のディレイ時間を設定します。デフォルトは0.3秒。早過ぎると失敗が多発します。{nl}" ..
            "Sets the delay time for the operation. Default is 0.3 seconds. Too early and many failures will occur.")

    if g.settings[g.LOGINCID] == nil then
        g.settings[g.LOGINCID] = {}
    end

    local function createSlot(frame, name, x, y, width, height, skin, text, dropHandler, cancelHandler, image, iesid)
        local slot = frame:CreateOrGetControl("slot", name, x, y, width, height)
        AUTO_CAST(slot)
        slot:SetSkinName(skin)
        slot:SetText(text)
        slot:EnablePop(1)
        slot:EnableDrag(1)
        slot:EnableDrop(1)
        slot:SetEventScript(ui.DROP, dropHandler)
        slot:SetEventScript(ui.RBUTTONDOWN, cancelHandler)
        slot:SetEventScript(ui.MOUSEON, "cc_helper_tooltip")

        if image ~= nil then
            SET_SLOT_IMG(slot, image)
            SET_SLOT_IESID(slot, iesid);

        end
    end

    local slotInfo = {{
        name = "seal_slot",
        x = 210,
        y = 70,
        width = 50,
        height = 50,
        skin = "invenslot2",
        text = "{ol}{s14}SEAL",
        dropHandler = "cc_helper_frame_drop",
        cancelHandler = "cc_helper_cancel",
        iesid = g.settings[g.LOGINCID].seal_iesid,
        image = g.settings[g.LOGINCID].seal_image,
        index = 2
    }, {
        name = "ark_slot",
        x = 210,
        y = 130,
        width = 50,
        height = 50,
        skin = "invenslot2",
        text = "{ol}{s14}ARK",
        dropHandler = "cc_helper_frame_drop",
        cancelHandler = "cc_helper_cancel",
        iesid = g.settings[g.LOGINCID].ark_iesid,
        image = g.settings[g.LOGINCID].ark_image,
        index = 3
    }, {
        name = "agem_slot",
        x = 210,
        y = 10,
        width = 50,
        height = 50,
        skin = "invenslot2",
        text = "{ol}{s12}AETHER{nl}GEM",
        dropHandler = "cc_helper_frame_drop",
        cancelHandler = "cc_helper_cancel",
        iesid = g.settings[g.LOGINCID].gem_clsid,
        image = g.settings[g.LOGINCID].gem_image,
        index = 5
    }, {
        name = "legcard_slot",
        x = 10,
        y = 50,
        width = 90,
        height = 130,
        skin = "legendopen_cardslot",
        text = "{ol}{s14}LEGEND{nl}CARD",
        dropHandler = "cc_helper_frame_drop",
        cancelHandler = "cc_helper_cancel",
        iesid = g.settings[g.LOGINCID].leg_iesid,
        image = g.settings[g.LOGINCID].leg_image,
        index = 1
    }, {
        name = "godcard_slot",
        x = 110,
        y = 50,
        width = 90,
        height = 130,
        skin = "goddess_card__activation",
        text = "{ol}{s14}GODDESS{nl}CARD",
        dropHandler = "cc_helper_frame_drop",
        cancelHandler = "cc_helper_cancel",
        iesid = g.settings[g.LOGINCID].god_iesid,
        image = g.settings[g.LOGINCID].god_image,
        index = 9
    }, {
        name = "crown_slot",
        x = 210,
        y = 190,
        width = 50,
        height = 50,
        skin = "invenslot2",
        text = "{ol}{s12}CROWN",
        dropHandler = "cc_helper_frame_drop",
        cancelHandler = "cc_helper_cancel",
        iesid = g.settings[g.LOGINCID].crown_iesid,
        image = g.settings[g.LOGINCID].crown_image,
        index = 4
    }, {
        name = "hair_slot1",
        x = 10,
        y = 190,
        width = 50,
        height = 50,
        skin = "invenslot2",
        text = "{ol}{s14}HAIR1",
        dropHandler = "cc_helper_frame_drop",
        cancelHandler = "cc_helper_cancel",
        iesid = g.settings[g.LOGINCID].hair1_iesid,
        image = g.settings[g.LOGINCID].hair1_image,
        index = 6
    }, {
        name = "hair_slot2",
        x = 70,
        y = 190,
        width = 50,
        height = 50,
        skin = "invenslot2",
        text = "{ol}{s14}HAIR2",
        dropHandler = "cc_helper_frame_drop",
        cancelHandler = "cc_helper_cancel",
        iesid = g.settings[g.LOGINCID].hair2_iesid,
        image = g.settings[g.LOGINCID].hair2_image,
        index = 7
    }, {
        name = "hair_slot3",
        x = 130,
        y = 190,
        width = 50,
        height = 50,
        skin = "invenslot2",
        text = "{ol}{s14}HAIR3",
        dropHandler = "cc_helper_frame_drop",
        cancelHandler = "cc_helper_cancel",
        iesid = g.settings[g.LOGINCID].hair3_iesid,
        image = g.settings[g.LOGINCID].hair3_image,
        index = 8
    }}

    for _, info in ipairs(slotInfo) do

        createSlot(frame, info.name, info.x, info.y, info.width, info.height, info.skin, info.text, info.dropHandler,
            info.cancelHandler, info.image, info.iesid)
    end

end

function cc_helper_settings_close(frame)
    local frame = ui.GetFrame("cc_helper")
    frame:ShowWindow(0)
    --[[if frame:IsVisible() == 1 then
        frame:ShowWindow(0)
        cc_helper_load_settings()
    end]]
end

function cc_helper_cancel(frame, ctrl, argstr, argnum)

    ctrl:ClearIcon()
    ctrl:RemoveAllChild()

    if ctrl:GetName() == "hair_slot1" then

        g.settings[g.LOGINCID].hair1_image = ""
        g.settings[g.LOGINCID].hair1_iesid = ""
        g.settings[g.LOGINCID].hair1_clsid = 0

    elseif ctrl:GetName() == "hair_slot2" then
        g.settings[g.LOGINCID].hair2_image = ""
        g.settings[g.LOGINCID].hair2_iesid = ""
        g.settings[g.LOGINCID].hair2_clsid = 0

    elseif ctrl:GetName() == "hair_slot3" then
        g.settings[g.LOGINCID].hair3_image = ""
        g.settings[g.LOGINCID].hair3_iesid = ""
        g.settings[g.LOGINCID].hair3_clsid = 0

    elseif ctrl:GetName() == "crown_slot" then

        g.settings[g.LOGINCID].crown_iesid = ""
        g.settings[g.LOGINCID].crown_clsid = 0

        g.settings[g.LOGINCID].crown_image = ""

    elseif ctrl:GetName() == "seal_slot" then
        g.settings[g.LOGINCID].seal_iesid = ""
        g.settings[g.LOGINCID].seal_clsid = 0

        g.settings[g.LOGINCID].seal_image = ""

    elseif ctrl:GetName() == "ark_slot" then
        g.settings[g.LOGINCID].ark_iesid = ""
        g.settings[g.LOGINCID].ark_clsid = 0

        g.settings[g.LOGINCID].ark_image = ""

    elseif ctrl:GetName() == "agem_slot" then
        g.settings[g.LOGINCID].gem_clsid = 0

        g.settings[g.LOGINCID].gem_image = ""

    elseif ctrl:GetName() == "legcard_slot" then
        g.settings[g.LOGINCID].leg_iesid = ""
        g.settings[g.LOGINCID].leg_clsid = 0

        g.settings[g.LOGINCID].leg_image = ""

    elseif ctrl:GetName() == "godcard_slot" then
        g.settings[g.LOGINCID].god_iesid = ""
        g.settings[g.LOGINCID].god_clsid = 0

        g.settings[g.LOGINCID].god_image = ""

    end
    cc_helper_save_settings()

end

function cc_helper_tooltip(frame, ctrl, argStr, argNum)

    local icon = ctrl:GetIcon()
    local icon_info = icon:GetInfo()
    local icon_iesid = icon_info:GetIESID()

    icon:SetTooltipType('wholeitem');
    if icon_iesid ~= "0" then
        if ctrl:GetName() == "seal_slot" then

            icon:SetTooltipArg("None", g.settings[g.LOGINCID].seal_clsid, g.settings[g.LOGINCID].seal_iesid);
        elseif ctrl:GetName() == "ark_slot" then
            icon:SetTooltipArg("None", g.settings[g.LOGINCID].ark_clsid, g.settings[g.LOGINCID].ark_iesid);
        elseif ctrl:GetName() == "legcard_slot" then
            icon:SetTooltipArg("None", g.settings[g.LOGINCID].leg_clsid, g.settings[g.LOGINCID].leg_iesid);
        elseif ctrl:GetName() == "godcard_slot" then
            icon:SetTooltipArg("None", g.settings[g.LOGINCID].god_clsid, g.settings[g.LOGINCID].god_iesid);
        elseif ctrl:GetName() == "crown_slot" then
            icon:SetTooltipArg("None", g.settings[g.LOGINCID].crown_clsid, g.settings[g.LOGINCID].crown_iesid);
        elseif ctrl:GetName() == "hair_slot1" then
            icon:SetTooltipArg("None", g.settings[g.LOGINCID].hair1_clsid, g.settings[g.LOGINCID].hair1_iesid);
        elseif ctrl:GetName() == "hair_slot2" then
            icon:SetTooltipArg("None", g.settings[g.LOGINCID].hair2_clsid, g.settings[g.LOGINCID].hair2_iesid);
        elseif ctrl:GetName() == "hair_slot3" then
            icon:SetTooltipArg("None", g.settings[g.LOGINCID].hair3_clsid, g.settings[g.LOGINCID].hair3_iesid);
        elseif ctrl:GetName() == "agem_slot" then
            icon:SetTooltipArg("None", g.settings[g.LOGINCID].gem_clsid, nil);
        end

    else
        ctrl:ClearIcon();
        return
    end

end

function cc_helper_check_setting(frame, ctrl, argStr, argNum)
    local ischeck = ctrl:IsChecked();

    if ctrl:GetName() == "mccuse" then
        if ischeck == 0 then
            g.settings[g.LOGINCID].mcc_use = 0
        else
            g.settings[g.LOGINCID].mcc_use = 1
        end
    elseif ctrl:GetName() == "agmuse" then
        if ischeck == 0 then
            g.settings[g.LOGINCID].agm_use = 0
        else
            g.settings[g.LOGINCID].agm_use = 1
        end
    elseif ctrl:GetName() == "checkbox" then
        if ischeck == 0 then
            g.check = 0
        else
            g.check = 1
        end
    elseif ctrl:GetName() == "auto_close" then
        if ischeck == 0 then
            g.settings.auto_close = 0
        else
            g.settings.auto_close = 1
        end
    end
    cc_helper_save_settings()

end

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

function cc_helper_inv_rbtn(itemObj, slot)
    local frame = ui.GetFrame("cc_helper");
    if frame:IsVisible() == 0 then
        INVENTORY_SET_CUSTOM_RBTNDOWN("None")
        return
    end
    local icon = slot:GetIcon();
    local iconInfo = icon:GetInfo();
    local iesid = iconInfo:GetIESID()
    local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());
    local obj = GetIES(invItem:GetObject());
    local image = TryGetProp(obj, "TooltipImage", "None")
    local classid = obj.ClassID
    local type = obj.ClassType

    local gemtype = GET_EQUIP_GEM_TYPE(obj)

    if type == "Seal" and classid ~= 614001 then

        local seal_slot = GET_CHILD_RECURSIVELY(frame, "seal_slot")
        SET_SLOT_IMG(seal_slot, image);
        SET_SLOT_IESID(seal_slot, iesid);

        g.settings[g.LOGINCID].seal_iesid = iesid
        g.settings[g.LOGINCID].seal_image = image
        g.settings[g.LOGINCID].seal_clsid = classid
    elseif type == "Ark" then

        local ark_slot = GET_CHILD_RECURSIVELY(frame, "ark_slot")
        SET_SLOT_IMG(ark_slot, image);
        SET_SLOT_IESID(ark_slot, iesid);
        g.settings[g.LOGINCID].ark_iesid = iesid
        g.settings[g.LOGINCID].ark_image = image
        g.settings[g.LOGINCID].ark_clsid = classid
    elseif obj.CardGroupName == "LEG" then

        local legcard_slot = GET_CHILD_RECURSIVELY(frame, "legcard_slot")
        SET_SLOT_IMG(legcard_slot, image)
        SET_SLOT_IESID(legcard_slot, iesid);
        g.settings[g.LOGINCID].leg_iesid = iesid
        g.settings[g.LOGINCID].leg_image = image
        g.settings[g.LOGINCID].leg_clsid = classid
    elseif obj.CardGroupName == "GODDESS" then

        local godcard_slot = GET_CHILD_RECURSIVELY(frame, "godcard_slot")
        SET_SLOT_IMG(godcard_slot, image)
        SET_SLOT_IESID(godcard_slot, iesid);
        g.settings[g.LOGINCID].god_iesid = iesid
        g.settings[g.LOGINCID].god_image = image
        g.settings[g.LOGINCID].god_clsid = classid
    elseif slot:GetParent():GetName() == "sset_HairAcc_Acc1" then

        local hair_slot1 = GET_CHILD_RECURSIVELY(frame, "hair_slot1")
        SET_SLOT_IMG(hair_slot1, image)
        SET_SLOT_IESID(hair_slot1, iesid);
        g.settings[g.LOGINCID].hair1_iesid = iesid
        g.settings[g.LOGINCID].hair1_image = image
        g.settings[g.LOGINCID].hair1_clsid = classid
    elseif slot:GetParent():GetName() == "sset_HairAcc_Acc2" then

        local hair_slot2 = GET_CHILD_RECURSIVELY(frame, "hair_slot2")
        SET_SLOT_IMG(hair_slot2, image)
        SET_SLOT_IESID(hair_slot2, iesid);
        g.settings[g.LOGINCID].hair2_iesid = iesid
        g.settings[g.LOGINCID].hair2_image = image
        g.settings[g.LOGINCID].hair2_clsid = classid
    elseif slot:GetParent():GetName() == "sset_HairAcc_Acc3" then

        local hair_slot3 = GET_CHILD_RECURSIVELY(frame, "hair_slot3")
        SET_SLOT_IMG(hair_slot3, image)
        SET_SLOT_IESID(hair_slot3, iesid);
        g.settings[g.LOGINCID].hair3_iesid = iesid
        g.settings[g.LOGINCID].hair3_image = image
        g.settings[g.LOGINCID].hair3_clsid = classid
    elseif type == "Relic" then

        local crown_slot = GET_CHILD_RECURSIVELY(frame, "crown_slot")
        SET_SLOT_IMG(crown_slot, image)
        SET_SLOT_IESID(crown_slot, iesid);
        g.settings[g.LOGINCID].crown_iesid = iesid
        g.settings[g.LOGINCID].crown_image = image
        g.settings[g.LOGINCID].crown_clsid = classid
    elseif gemtype == "aether" then
        local agem_slot = GET_CHILD_RECURSIVELY(frame, "agem_slot")
        SET_SLOT_IMG(agem_slot, image)
        SET_SLOT_IESID(agem_slot, iesid);

        g.settings[g.LOGINCID].gem_image = image
        g.settings[g.LOGINCID].gem_clsid = classid

    end

    cc_helper_save_settings()
    -- cc_helper_load_settings()
end

function cc_helper_frame_drop(frame, ctrl, argstr, argnum)

    local lifticon = ui.GetLiftIcon();
    local parent = lifticon:GetParent();
    local fromslot = parent:GetParent();

    local slot = tolua.cast(ctrl, 'ui::CSlot')
    local iconinfo = lifticon:GetInfo();

    local item = GET_PC_ITEM_BY_GUID(iconinfo:GetIESID());
    local itemobj = GetIES(item:GetObject());
    local classid = itemobj.ClassID

    local iesid = iconinfo:GetIESID()
    local image = TryGetProp(itemobj, "TooltipImage", "None")
    local slot_name = ctrl:GetName()

    local type = itemobj.ClassType

    local gemtype = GET_EQUIP_GEM_TYPE(itemobj)

    if slot_name == "seal_slot" then

        if type == "Seal" and classid ~= 614001 then
            SET_SLOT_IMG(slot, image);
            SET_SLOT_IESID(slot, iesid);

            g.settings[g.LOGINCID].seal_iesid = iesid
            g.settings[g.LOGINCID].seal_image = image
            g.settings[g.LOGINCID].seal_clsid = classid

        else
            ui.SysMsg("This item cannot be set.")
            return

        end

    elseif slot_name == "ark_slot" then

        if type == "Ark" then

            SET_SLOT_IMG(slot, image);
            SET_SLOT_IESID(slot, iesid);
            g.settings[g.LOGINCID].ark_iesid = iesid
            g.settings[g.LOGINCID].ark_image = image
            g.settings[g.LOGINCID].ark_clsid = classid

        else
            ui.SysMsg("Drop it in the correct slot.")
            return
        end
    elseif slot_name == "legcard_slot" then

        if itemobj.CardGroupName ~= "LEG" then
            ui.SysMsg(ClMsg("ToEquipSameCardGroup"));
            return
        end

        SET_SLOT_IMG(ctrl, image)
        SET_SLOT_IESID(ctrl, iesid);
        g.settings[g.LOGINCID].leg_iesid = iesid
        g.settings[g.LOGINCID].leg_image = image
        g.settings[g.LOGINCID].leg_clsid = classid

    elseif slot_name == "godcard_slot" then

        if itemobj.CardGroupName ~= "GODDESS" then
            ui.SysMsg(ClMsg("ToEquipSameCardGroup"));
            return
        end

        SET_SLOT_IMG(ctrl, image)
        SET_SLOT_IESID(ctrl, iesid);
        g.settings[g.LOGINCID].god_iesid = iesid
        g.settings[g.LOGINCID].god_image = image
        g.settings[g.LOGINCID].god_clsid = classid

    elseif slot_name == "hair_slot1" then
        if fromslot:GetName() == "sset_HairAcc_Acc1" then

            SET_SLOT_IMG(ctrl, image)
            SET_SLOT_IESID(ctrl, iesid);
            g.settings[g.LOGINCID].hair1_iesid = iesid
            g.settings[g.LOGINCID].hair1_image = image
            g.settings[g.LOGINCID].hair1_clsid = classid
        else
            ui.SysMsg("This item cannot be set.")
            return
        end
    elseif slot_name == "hair_slot2" then
        if fromslot:GetName() == "sset_HairAcc_Acc2" then

            SET_SLOT_IMG(ctrl, image)
            SET_SLOT_IESID(ctrl, iesid);
            g.settings[g.LOGINCID].hair2_iesid = iesid
            g.settings[g.LOGINCID].hair2_image = image
            g.settings[g.LOGINCID].hair2_clsid = classid
        else
            ui.SysMsg("This item cannot be set.")
            return
        end
    elseif slot_name == "hair_slot3" then
        if fromslot:GetName() == "sset_HairAcc_Acc3" then

            SET_SLOT_IMG(ctrl, image)
            SET_SLOT_IESID(ctrl, iesid);
            g.settings[g.LOGINCID].hair3_iesid = iesid
            g.settings[g.LOGINCID].hair3_image = image
            g.settings[g.LOGINCID].hair3_clsid = classid
        else
            ui.SysMsg("This item cannot be set.")
            return
        end
    elseif slot_name == "crown_slot" then
        if type == "Relic" then
            SET_SLOT_IMG(ctrl, image)
            SET_SLOT_IESID(ctrl, iesid);
            g.settings[g.LOGINCID].crown_iesid = iesid
            g.settings[g.LOGINCID].crown_image = image
            g.settings[g.LOGINCID].crown_clsid = classid
        else
            ui.SysMsg("This item cannot be set.")
            return
        end
    elseif slot_name == "agem_slot" then
        if gemtype == "aether" then
            SET_SLOT_IMG(ctrl, image)
            SET_SLOT_IESID(ctrl, iesid);

            g.settings[g.LOGINCID].gem_image = image
            g.settings[g.LOGINCID].gem_clsid = classid
        else
            ui.SysMsg("This item cannot be set.")
            return
        end
    else
        return

    end
    cc_helper_save_settings()
end

-- putitem
function cc_helper_in_btn_aethergem_mgr()

    local frame = ui.GetFrame("inventory")
    local equipSlots = {"RH", "LH", "RH_SUB", "LH_SUB"}
    if ADDONS.norisan.AETHERGEM_MGR ~= nil and g.check == 0 and g.settings[g.LOGINCID].agm_use == 1 then

        for _, slotName in ipairs(equipSlots) do
            local equipSlot = GET_CHILD_RECURSIVELY(frame, slotName)
            local Icon = equipSlot:GetIcon()

            if Icon ~= nil then
                local IconInfo = Icon:GetInfo()
                local guid = IconInfo:GetIESID()
                local type = IconInfo.type
                local itemCls = GetClassByType("Item", session.GetEquipItemByGuid(guid).type);
                local classID = itemCls.ClassID;

                local equipItem = session.GetEquipItemByType(classID)
                local gem = equipItem:GetEquipGemID(2)

                if tostring(gem) == tostring(g.settings[g.LOGINCID].gem_clsid) then
                    cc_helper_msgbox_frame()
                    return
                end
            end
        end

    end

    cc_helper_in_btn_start()
end

function cc_helper_msgbox_frame()

    local msg = "Do you want to start Aethrgem Manager first?"
    local yes_scp = "cc_helper_in_btn_agm()"
    local no_scp = "cc_helper_in_btn_start()"
    ui.MsgBox(msg, yes_scp, no_scp);

    return
end

function cc_helper_in_btn_agm()
    local cchframe = ui.GetFrame("cc_helper")
    cchframe:ShowWindow(0)
    g.agm = 0
    AETHERGEM_MGR_GET_EQUIP()

    local a = ADDONS.norisan.AETHERGEM_MGR

    local delay = a.settings.delay

    ReserveScript("cc_helper_in_btn_start()", delay * 10)

end

function cc_helper_in_btn_start()
    -- print("cc_helper_in_btn_start")
    g.monstercard = 1
    g.unequip = 1
    -- g.agm = 1
    -- g.equip = 0
    local frame = ui.GetFrame("inventory")

    if true == BEING_TRADING_STATE() then
        return;
    end

    local isEmptySlot = false;

    if session.GetInvItemList():Count() < MAX_INV_COUNT then
        isEmptySlot = true;
    end

    if isEmptySlot == true then

        local induninfo = ui.GetFrame("induninfo")
        local indunenter = ui.GetFrame("indunenter")

        if induninfo:IsVisible() == 0 or indunenter:IsVisible() == 0 then
            cc_helper_unequip()
            return

        end
    else
        ui.SysMsg(ScpArgMsg("Auto_inBenToLie_Bin_SeulLosi_PilyoHapNiDa."))
    end

end

function cc_helper_unequip()

    local frame = ui.GetFrame("inventory")
    local eqpTab = GET_CHILD_RECURSIVELY(frame, "inventype_Tab")
    eqpTab:SelectTab(1)
    local equip_tbl = {{
        type = "SEAL",
        iesid_key = "seal_iesid",
        slot_index = 25
    }, {
        type = "RELIC",
        iesid_key = "crown_iesid",
        slot_index = 29
    }, {
        type = "ARK",
        iesid_key = "ark_iesid",
        slot_index = 27
    }, {
        type = "HAT",
        iesid_key = "hair1_iesid",
        slot_index = 0
    }, {
        type = "HAT_L",
        iesid_key = "hair3_iesid",
        slot_index = 1
    }, {
        type = "HAT_T",
        iesid_key = "hair2_iesid",
        slot_index = 20
    }}

    for _, equip in ipairs(equip_tbl) do
        local slot = GET_CHILD_RECURSIVELY(frame, equip.type)
        local icon = slot:GetIcon()
        if icon then
            local icon_info = icon:GetInfo()
            if icon_info then
                local iesid = icon_info:GetIESID()
                if iesid and tostring(iesid) == g.settings[g.LOGINCID][equip.iesid_key] then
                    item.UnEquip(equip.slot_index)
                    ReserveScript(string.format("cc_helper_unequip('%s')", frame), g.settings.delay)
                    return
                end
            end
        end
    end

    eqpTab:SelectTab(1)
    local legtrue = 0
    cc_helper_unequip_card(legtrue)
end

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

                        if iesid ~= nil and tostring(iesid) == g.settings[g.LOGINCID].seal_iesid then

                            local index = 25
                            item.UnEquip(index)
                            ReserveScript(string.format("cc_helper_unequip('%s')", frame), g.settings.delay)
                            return
                        end
                    end
                    if value == "RELIC" and i == key then

                        if iesid ~= nil and tostring(iesid) == g.settings[g.LOGINCID].crown_iesid then
                            local index = 29 -- スロットインデックスを適切な値に設定する必要があります
                            item.UnEquip(index)
                            ReserveScript(string.format("cc_helper_unequip('%s')", frame), g.settings.delay)
                            return
                        end
                    end
                    if value == "ARK" and i == key then

                        if iesid ~= nil and tostring(iesid) == g.settings[g.LOGINCID].ark_iesid then
                            local index = 27 -- スロットインデックスを適切な値に設定する必要があります
                            item.UnEquip(index)
                            ReserveScript(string.format("cc_helper_unequip('%s')", frame), g.settings.delay)
                            return

                        end
                    end
                    if value == "HAT" and i == key then

                        if iesid ~= nil and tostring(iesid) == g.settings[g.LOGINCID].hair1_iesid then
                            local index = 0 -- スロットインデックスを適切な値に設定する必要があります
                            item.UnEquip(index)
                            ReserveScript(string.format("cc_helper_unequip('%s')", frame), g.settings.delay)
                            return
                        end
                    end
                    if value == "HAT_T" and i == key then

                        if iesid ~= nil and tostring(iesid) == g.settings[g.LOGINCID].hair2_iesid then

                            local index = 20 -- スロットインデックスを適切な値に設定する必要があります
                            item.UnEquip(index)
                            ReserveScript(string.format("cc_helper_unequip('%s')", frame), g.settings.delay)
                            return
                        end
                    end
                    if value == "HAT_L" and i == key then

                        if iesid ~= nil and tostring(iesid) == g.settings[g.LOGINCID].hair3_iesid then

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

function cc_helper_unequip_card(legtrue)

    if g.settings[g.LOGINCID].leg_clsid ~= 0 and g.check == 0 and legtrue == 0 then

        MONSTERCARDSLOT_FRAME_OPEN()
        local slot_index = 13
        local cardid = GETMYCARD_INFO(slot_index - 1)

        local cardInfo = equipcard.GetCardInfo(slot_index);
        if cardInfo ~= nil and tostring(cardid) == tostring(g.settings[g.LOGINCID].leg_clsid) then
            local argStr = slot_index - 1
            argStr = argStr .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
            pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)
            legtrue = 1
            ReserveScript(string.format("cc_helper_unequip_card(%d)", legtrue), g.settings.delay * 3)
            return
        elseif cardInfo ~= nil and tostring(cardid) ~= tostring(g.settings[g.LOGINCID].leg_clsid) then
            legtrue = 1
            ReserveScript(string.format("cc_helper_unequip_card(%d)", legtrue), g.settings.delay * 3)
        end
    end
    if g.settings[g.LOGINCID].god_clsid ~= 0 then

        MONSTERCARDSLOT_FRAME_OPEN()
        local slot_index = 14
        local cardid = GETMYCARD_INFO(slot_index - 1)
        local cardInfo = equipcard.GetCardInfo(slot_index);

        if cardInfo ~= nil and tostring(cardid) == tostring(g.settings[g.LOGINCID].god_clsid) then
            local argStr = slot_index - 1
            argStr = argStr .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
            pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)

        end
    end
    if ui.GetFrame("monstercardslot"):IsVisible() == 1 then

        ReserveScript("cc_helper_inv_to_warehouse()", g.settings.delay * 3 + g.settings.delay)
        if GETMYCARD_INFO(12) == 0 and GETMYCARD_INFO(13) == 0 then
            -- ReserveScript("MONSTERCARDSLOT_CLOSE()", g.settings.delay * 3)
        end
    else

        ReserveScript("cc_helper_inv_to_warehouse()", g.settings.delay)
    end

end

function cc_helper_get_goal_index()
    local frame = ui.GetFrame("accountwarehouse")
    local tab = GET_CHILD(frame, "accountwarehouse_tab");
    local gbox = GET_CHILD_RECURSIVELY(frame, "gbox")
    local itemcnt = GET_CHILD(gbox, "itemcnt")
    local length = #itemcnt:GetText()
    local index = 0
    local accountObj = GetMyAccountObj();
    local right0 = accountObj.BasicAccountWarehouseSlotCount + accountObj.MaxAccountWarehouseCount +
                       accountObj.AccountWareHouseExtend + accountObj.AccountWareHouseExtendByItem +
                       ADDITIONAL_SLOT_COUNT_BY_TOKEN

    local maxcnt = right0 + 280
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetSortedGuidList();
    local invItemCount = sortedGuidList:Count();

    if invItemCount < maxcnt then
        for i = 4, 0, -1 do

            if i == 4 then
                tab:SelectTab(i)
                itemcnt = GET_CHILD(gbox, "itemcnt")
                length = #itemcnt:GetText()
                local left4 = 0

                if length == 14 then
                    left4 = string.sub(itemcnt:GetText(), length - 6, length - 6) * 1 -- 左側の数字を取得
                else
                    left4 = string.sub(itemcnt:GetText(), length - 7, length - 6) * 1 -- 左側の数字を取得
                end

                if left4 < 70 then
                    index = right0 + 210 + left4 - 1
                    return index
                end
            elseif i == 3 then
                tab:SelectTab(i)
                itemcnt = GET_CHILD(gbox, "itemcnt")
                length = #itemcnt:GetText()
                local left3 = 0

                if length == 14 then
                    left3 = string.sub(itemcnt:GetText(), length - 6, length - 6) * 1 -- 左側の数字を取得
                else
                    left3 = string.sub(itemcnt:GetText(), length - 7, length - 6) * 1 -- 左側の数字を取得
                end

                if left3 < 70 then
                    index = right0 + 140 + left3 - 1
                    return index
                end
            elseif i == 2 then
                tab:SelectTab(i)
                itemcnt = GET_CHILD(gbox, "itemcnt")
                length = #itemcnt:GetText()
                local left2 = 0

                if length == 14 then
                    left2 = string.sub(itemcnt:GetText(), length - 6, length - 6) * 1 -- 左側の数字を取得
                else
                    left2 = string.sub(itemcnt:GetText(), length - 7, length - 6) * 1 -- 左側の数字を取得
                end

                if left2 < 70 then
                    index = right0 + 70 + left2 - 1
                    return index
                end
            elseif i == 1 then
                tab:SelectTab(i)
                itemcnt = GET_CHILD(gbox, "itemcnt")
                length = #itemcnt:GetText()
                local left1 = 0

                if length == 14 then
                    left1 = string.sub(itemcnt:GetText(), length - 6, length - 6) * 1 -- 左側の数字を取得
                else
                    left1 = string.sub(itemcnt:GetText(), length - 7, length - 6) * 1 -- 左側の数字を取得
                end

                if left1 < 70 then
                    index = right0 + left1 - 1
                    return index
                end
            elseif i == 0 then
                tab:SelectTab(i)
                local j = 1
                for j = 1, right0 do
                    local slotset = GET_CHILD_RECURSIVELY(frame, "slotset");
                    local slot = GET_CHILD(slotset, "slot" .. j)
                    local icon = slot:GetIcon()
                    local iconInfo = icon:GetInfo();
                    if iconInfo == nil then
                        index = j
                        return index
                    end
                end

            end
        end
    else
        ui.SysMsg(ClMsg('CannotPutBecauseMaxSlot'));
        return
    end

end
function cc_helper_inv_to_warehouse()
    local frame = ui.GetFrame("accountwarehouse");
    local fromFrame = ui.GetFrame("inventory");
    local handle = frame:GetUserIValue('HANDLE')
    local invTab = GET_CHILD_RECURSIVELY(fromFrame, "inventype_Tab")

    if frame:IsVisible() == 1 then
        local seal = session.GetInvItemByGuid(g.settings[g.LOGINCID].seal_iesid);
        local ark = session.GetInvItemByGuid(g.settings[g.LOGINCID].ark_iesid);
        local leg = session.GetInvItemByGuid(g.settings[g.LOGINCID].leg_iesid);
        local god = session.GetInvItemByGuid(g.settings[g.LOGINCID].god_iesid);
        local hair1 = session.GetInvItemByGuid(g.settings[g.LOGINCID].hair1_iesid);
        local hair2 = session.GetInvItemByGuid(g.settings[g.LOGINCID].hair2_iesid);
        local hair3 = session.GetInvItemByGuid(g.settings[g.LOGINCID].hair3_iesid);
        local crown = session.GetInvItemByGuid(g.settings[g.LOGINCID].crown_iesid);

        local goal_index = cc_helper_get_goal_index()

        if crown ~= nil then
            local itemCls = GetClassByType('Item', crown.type)
            local Name = itemCls.Name
            CHAT_SYSTEM(cc_helper_lang("Item to warehousing") .. "：[" .. "{#EE82EE}" .. Name .. "{#FFFF00}]×" ..
                            "{#EE82EE}" .. 1)
            invTab:SelectTab(1)
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.settings[g.LOGINCID].crown_iesid, 1, handle, goal_index)
            ReserveScript("cc_helper_inv_to_warehouse()", g.settings.delay)
            return

        elseif hair1 ~= nil then
            local itemCls = GetClassByType('Item', hair1.type)
            local Name = itemCls.Name
            CHAT_SYSTEM(cc_helper_lang("Item to warehousing") .. "：[" .. "{#EE82EE}" .. Name .. "{#FFFF00}]×" ..
                            "{#EE82EE}" .. 1)
            invTab:SelectTab(1)
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.settings[g.LOGINCID].hair1_iesid, 1, handle, goal_index)
            ReserveScript("cc_helper_inv_to_warehouse()", g.settings.delay)
            return

        elseif hair2 ~= nil then
            local itemCls = GetClassByType('Item', hair2.type)
            local Name = itemCls.Name
            CHAT_SYSTEM(cc_helper_lang("Item to warehousing") .. "：[" .. "{#EE82EE}" .. Name .. "{#FFFF00}]×" ..
                            "{#EE82EE}" .. 1)
            invTab:SelectTab(1)
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.settings[g.LOGINCID].hair2_iesid, 1, handle, goal_index)
            ReserveScript("cc_helper_inv_to_warehouse()", g.settings.delay)
            return

        elseif hair3 ~= nil then
            local itemCls = GetClassByType('Item', hair3.type)
            local Name = itemCls.Name
            CHAT_SYSTEM(cc_helper_lang("Item to warehousing") .. "：[" .. "{#EE82EE}" .. Name .. "{#FFFF00}]×" ..
                            "{#EE82EE}" .. 1)
            invTab:SelectTab(1)
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.settings[g.LOGINCID].hair3_iesid, 1, handle, goal_index)
            ReserveScript("cc_helper_inv_to_warehouse()", g.settings.delay)
            return
        elseif seal ~= nil then
            local itemCls = GetClassByType('Item', seal.type)
            local Name = itemCls.Name
            CHAT_SYSTEM(cc_helper_lang("Item to warehousing") .. "：[" .. "{#EE82EE}" .. Name .. "{#FFFF00}]×" ..
                            "{#EE82EE}" .. 1)
            invTab:SelectTab(1)
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.settings[g.LOGINCID].seal_iesid, 1, handle, goal_index)
            ReserveScript("cc_helper_inv_to_warehouse()", g.settings.delay)
            return
        elseif ark ~= nil then
            local itemCls = GetClassByType('Item', ark.type)
            local Name = itemCls.Name
            CHAT_SYSTEM(cc_helper_lang("Item to warehousing") .. "：[" .. "{#EE82EE}" .. Name .. "{#FFFF00}]×" ..
                            "{#EE82EE}" .. 1)
            invTab:SelectTab(1)
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.settings[g.LOGINCID].ark_iesid, 1, handle, goal_index)
            ReserveScript("cc_helper_inv_to_warehouse()", g.settings.delay)
            return
        elseif leg ~= nil then
            local itemCls = GetClassByType('Item', leg.type)
            local Name = itemCls.Name
            CHAT_SYSTEM(cc_helper_lang("Item to warehousing") .. "：[" .. "{#EE82EE}" .. Name .. "{#FFFF00}]×" ..
                            "{#EE82EE}" .. 1)
            invTab:SelectTab(4)
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.settings[g.LOGINCID].leg_iesid, 1, handle, goal_index)
            ReserveScript("cc_helper_inv_to_warehouse()", g.settings.delay)

            return
        elseif god ~= nil then
            local itemCls = GetClassByType('Item', god.type)
            local Name = itemCls.Name
            CHAT_SYSTEM(cc_helper_lang("Item to warehousing") .. "：[" .. "{#EE82EE}" .. Name .. "{#FFFF00}]×" ..
                            "{#EE82EE}" .. 1)
            invTab:SelectTab(4)
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.settings[g.LOGINCID].god_iesid, 1, handle, goal_index)
            ReserveScript("cc_helper_inv_to_warehouse()", g.settings.delay)

            return
        else
            ReserveScript("cc_helper_gem_inv_to_warehouse()", g.settings.delay)
            return

        end
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

function cc_helper_gem_inv_to_warehouse()

    local frame = ui.GetFrame("accountwarehouse");
    local fromFrame = ui.GetFrame("inventory");
    local handle = frame:GetUserIValue('HANDLE')
    if frame:IsVisible() == 1 then
        local gemTab = GET_CHILD_RECURSIVELY(fromFrame, "inventype_Tab")
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

            if tostring(itemobj.ClassID) == tostring(g.settings[g.LOGINCID].gem_clsid) then
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
    return

end

-- takeitem
function cc_helper_out_btn_start()

    g.monstercard = 0
    g.unequip = 0
    g.agm = 1
    -- g.equip = 1
    local iesids = {{
        id = g.settings[g.LOGINCID].crown_iesid,
        type = "crown",
        name = "RELIC"
    }, {
        id = g.settings[g.LOGINCID].seal_iesid,
        type = "seal",
        name = "SEAL"
    }, {
        id = g.settings[g.LOGINCID].ark_iesid,
        type = "ark",
        name = "ARK"
    }, {
        id = g.settings[g.LOGINCID].hair1_iesid,
        type = "hair1",
        name = "HAT"
    }, {
        id = g.settings[g.LOGINCID].hair2_iesid,
        type = "hair2",
        name = "HAT_T"
    }, {
        id = g.settings[g.LOGINCID].hair3_iesid,
        type = "hair3",
        name = "HAT_L"
    }, {
        id = g.settings[g.LOGINCID].leg_iesid,
        type = "leg"

    }, {
        id = g.settings[g.LOGINCID].god_iesid,
        type = "god"

    }}

    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local sortedGuidList = itemList:GetSortedGuidList()
    local sortedCnt = sortedGuidList:Count()

    local take = {}

    if g.check == 0 then
        local levelTable = {}

        local clsid = g.settings[g.LOGINCID].gem_clsid
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

    --[[for _, iesid in ipairs(take) do
        print("Selected item iesid:" .. iesid)
    end]]

    -- アイテムの倉庫からの移動と装備
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
        iesid = g.settings[g.LOGINCID].god_iesid
    }, {
        spot = "HAT",
        index = nil,
        iesid = g.settings[g.LOGINCID].hair1_iesid
    }, {
        spot = "HAT_T",
        index = nil,
        iesid = g.settings[g.LOGINCID].hair2_iesid
    }, {
        spot = "HAT_L",
        index = nil,
        iesid = g.settings[g.LOGINCID].hair3_iesid
    }, {
        spot = "SEAL",
        index = nil,
        iesid = g.settings[g.LOGINCID].seal_iesid
    }, {
        spot = "ARK",
        index = nil,
        iesid = g.settings[g.LOGINCID].ark_iesid
    }, {
        spot = "RELIC",
        index = nil,
        iesid = g.settings[g.LOGINCID].crown_iesid
    }, {
        spot = "LEGCARD",
        index = 12,
        iesid = g.settings[g.LOGINCID].leg_iesid
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

-- itemequip
--[[function cc_helper_equip_reserve()
    local frame = ui.GetFrame("inventory")

    local iesids = {
        [1] = {
            GODCARD = g.settings[g.LOGINCID].god_iesid
        },
        [2] = {
            HAT = g.settings[g.LOGINCID].hair1_iesid
        },
        [3] = {
            HAT_T = g.settings[g.LOGINCID].hair2_iesid
        },
        [4] = {
            HAT_L = g.settings[g.LOGINCID].hair3_iesid
        },
        [5] = {
            SEAL = g.settings[g.LOGINCID].seal_iesid
        },
        [6] = {
            ARK = g.settings[g.LOGINCID].ark_iesid
        },

        [7] = {
            RELIC = g.settings[g.LOGINCID].crown_iesid
        },
        [8] = {
            LEGCARD = g.settings[g.LOGINCID].leg_iesid
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
            iesid = g.settings[g.LOGINCID].seal_iesid,
            start_func = "cc_helper_in_btn_start()"
        }, {
            iesid = g.settings[g.LOGINCID].ark_iesid,
            start_func = "cc_helper_in_btn_start()"
        }, {
            iesid = g.settings[g.LOGINCID].hair1_iesid,
            start_func = "cc_helper_in_btn_start()"
        }, {
            iesid = g.settings[g.LOGINCID].hair2_iesid,
            start_func = "cc_helper_in_btn_start()"
        }, {
            iesid = g.settings[g.LOGINCID].hair3_iesid,
            start_func = "cc_helper_in_btn_start()"
        }, {
            iesid = g.settings[g.LOGINCID].crown_iesid,
            start_func = "cc_helper_in_btn_start()"
        }}

        for _, item in ipairs(unequip_items) do
            if check_unequip(item.iesid, item.start_func) then
                return
            end
        end

        if g.settings[g.LOGINCID].leg_iesid ~= "" and g.check == 0 then
            if check_card_unequip(13, g.settings[g.LOGINCID].leg_iesid, "cc_helper_in_btn_start()") then
                return
            end
        end

        if g.settings[g.LOGINCID].god_iesid ~= "" then
            if check_card_unequip(14, g.settings[g.LOGINCID].god_iesid, "cc_helper_in_btn_start()") then
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
    if g.settings.auto_close == 1 and g.settings[g.LOGINCID].agm_use ~= 1 and g.settings[g.LOGINCID].mcc_use ~= 1 then
        frame:ShowWindow(0)
        local awframe = ui.GetFrame("accountwarehouse")
        awframe:ShowWindow(0)
    end

    cc_helper_handle_monstercard_change()
    cc_helper_handle_aether_gem_management()

end

function cc_helper_handle_aether_gem_management()
    if g.agm == 1 and ADDONS.norisan.AETHERGEM_MGR and g.check == 0 and g.settings[g.LOGINCID].agm_use == 1 then
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

                    local msg = "Call Aether Gem Manager?"
                    local yes_scp = "AETHERGEM_MGR_GET_EQUIP()"
                    ui.MsgBox(msg, yes_scp, "None")
                    break
                    -- return
                end
            end
        end
    end
end

function cc_helper_handle_monstercard_change()
    if ADDONS.norisan.monstercard_change and g.check == 0 and g.settings[g.LOGINCID].mcc_use == 1 then
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

--[[ 終了処理
function cc_helper_end_operation()

    if g.unequip == 1 then
        if g.settings[g.LOGINCID].seal_iesid ~= "" then

            local seal = session.GetInvItemByGuid(g.settings[g.LOGINCID].seal_iesid)

            if seal ~= nil then
                ReserveScript("cc_helper_in_btn_start()", g.settings.delay)
                return
            end
        end
        if g.settings[g.LOGINCID].ark_iesid ~= "" then
            local ark = session.GetInvItemByGuid(g.settings[g.LOGINCID].ark_iesid)

            if ark ~= nil then
                ReserveScript("cc_helper_in_btn_start()", g.settings.delay)
                return
            end
        end

        if g.settings[g.LOGINCID].hair1_iesid ~= "" then
            local hair1 = session.GetInvItemByGuid(g.settings[g.LOGINCID].hair1_iesid)

            if hair1 ~= nil then
                ReserveScript("cc_helper_in_btn_start()", g.settings.delay)
                return
            end
        end
        if g.settings[g.LOGINCID].hair2_iesid ~= "" then
            local hair2 = session.GetInvItemByGuid(g.settings[g.LOGINCID].hair2_iesid)

            if hair2 ~= nil then
                ReserveScript("cc_helper_in_btn_start()", g.settings.delay)
                return
            end
        end
        if g.settings[g.LOGINCID].hair3_iesid ~= "" then
            local hair3 = session.GetInvItemByGuid(g.settings[g.LOGINCID].hair3_iesid)

            if hair3 ~= nil then
                ReserveScript("cc_helper_in_btn_start()", g.settings.delay)
                return
            end
        end
        if g.settings[g.LOGINCID].crown_iesid ~= "" then
            local crown = session.GetInvItemByGuid(g.settings[g.LOGINCID].crown_iesid)

            if crown ~= nil then
                ReserveScript("cc_helper_in_btn_start()", g.settings.delay)
                return
            end
        end
        if g.settings[g.LOGINCID].leg_iesid ~= "" and g.check == 0 then
            local slot_index = 13
            local cardid = GETMYCARD_INFO(slot_index - 1)
            if cardid ~= 0 and g.settings[g.LOGINCID].leg_iesid == tostring(cardid) then
                ReserveScript("cc_helper_in_btn_start()", g.settings.delay)
                return
            end
            local leg = session.GetInvItemByGuid(g.settings[g.LOGINCID].leg_iesid)

            if leg ~= nil then
                ReserveScript("cc_helper_in_btn_start()", g.settings.delay)
                return
            end
        end
        if g.settings[g.LOGINCID].god_iesid ~= "" then
            local slot_index = 14
            local cardid = GETMYCARD_INFO(slot_index - 1)
            if cardid ~= 0 and g.settings[g.LOGINCID].god_iesid == tostring(cardid) then
                ReserveScript("cc_helper_in_btn_start()", g.settings.delay)
                return
            end
            local god = session.GetInvItemByGuid(g.settings[g.LOGINCID].god_iesid)

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

    if ADDONS.norisan.monstercard_change ~= nil and g.check == 0 and g.settings[g.LOGINCID].mcc_use == 1 then

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
        if ADDONS.norisan.AETHERGEM_MGR ~= nil and g.check == 0 and g.settings[g.LOGINCID].agm_use == 1 then
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
        if g.settings[g.LOGINCID].gem_clsid ~= 0 and g.check == 0 then

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

                    if tostring(obj.ClassID) == tostring(g.settings[g.LOGINCID].gem_clsid) then

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

