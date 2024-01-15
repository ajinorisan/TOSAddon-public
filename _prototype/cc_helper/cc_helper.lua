local addonName = "CC_HELPER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.1.4"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings_new.json', addonNameLower)

local acutil = require("acutil")

function CC_HELPER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    -- g.monstercard = nil

    if not g.loaded then
        g.loaded = true
    end

    acutil.setupEvent(addon, "ACCOUNTWAREHOUSE_CLOSE", "CC_HELPER_ACCOUNTWAREHOUSE_CLOSE");
    acutil.setupEvent(addon, "INVENTORY_CLOSE", "cc_helper_settings_close");
    addon:RegisterMsg("GAME_START", "cc_helper_load_settings")

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then

        addon:RegisterMsg("OPEN_DLG_ACCOUNTWAREHOUSE", "cc_helper_accountwarehouse_init")

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

        if not g.ischecked then
            g.ischecked = 0
        end

        local checkbox = invframe:CreateOrGetControl('checkbox', 'checkbox', 210, 350, 25, 25)
        AUTO_CAST(checkbox)
        checkbox:SetCheck(g.ischecked)
        checkbox:SetEventScript(ui.LBUTTONUP, "cc_helper_ischecked")
        checkbox:ShowWindow(1)
        checkbox:SetTextTooltip("Character Change Helper{nl}" ..
                                    "チェックすると外すのにシルバーが必要なレジェンドカードとエーテルジェムの動作をスキップします。{nl}" ..
                                    "If checked, it skips the operation of legend cards and ether gems that require silver to remove.")
    end
    return

end

function CC_HELPER_ACCOUNTWAREHOUSE_CLOSE(frame)

    local invframe = ui.GetFrame("inventory")
    local inbtn = GET_CHILD_RECURSIVELY(invframe, "inv_in")
    local outbtn = GET_CHILD_RECURSIVELY(invframe, "inv_out")

    inbtn:ShowWindow(0)
    outbtn:ShowWindow(0)

end

function cc_helper_accountwarehouse_init()

    local awhframe = ui.GetFrame("accountwarehouse")

    local awh_inbtn = awhframe:CreateOrGetControl("button", "in", 545, 120, 40, 30)
    AUTO_CAST(awh_inbtn)
    awh_inbtn:SetText("{img in_arrow 20 20}") -- {@st66}
    awh_inbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_in_btn_aethergem_mgr")
    awh_inbtn:ShowWindow(1) -- test_pvp_btn
    awh_inbtn:SetSkinName("test_pvp_btn")
    awh_inbtn:SetTextTooltip("Character Change Helper{nl}" .. "装備を外して倉庫へ搬入します。{nl}" ..
                                 "The equipment is removed and brought into the warehouse.")

    local awh_outbtn = awhframe:CreateOrGetControl("button", "out", 585, 120, 40, 30)
    AUTO_CAST(awh_outbtn)
    awh_outbtn:SetText("{@st66b}{img chul_arrow 20 20}")
    awh_outbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_out_btn")
    awh_outbtn:ShowWindow(1)
    awh_outbtn:SetSkinName("test_pvp_btn")
    awh_outbtn:SetTextTooltip(
        "{@st59}Character Change Helper{nl}" .. "倉庫から搬出して装備します。{nl}" ..
            "It is carried out from the warehouse and equipped.")

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

function cc_helper_invframe_init()

    local invframe = ui.GetFrame("inventory")

    local inbtn = invframe:CreateOrGetControl("button", "inv_in", 263, 345, 30, 30)
    AUTO_CAST(inbtn)
    inbtn:SetText("{img in_arrow 20 20}") -- {@st66}
    inbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_in_btn_aethergem_mgr")
    inbtn:ShowWindow(1) -- test_pvp_btn
    inbtn:SetSkinName("test_pvp_btn")
    inbtn:SetTextTooltip("Character Change Helper{nl}" .. "装備を外して倉庫へ搬入します。{nl}" ..
                             "The equipment is removed and brought into the warehouse.")

    local outbtn = invframe:CreateOrGetControl("button", "inv_out", 293, 345, 30, 30)
    AUTO_CAST(outbtn)
    outbtn:SetText("{@st66b}{img chul_arrow 20 20}")
    outbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_out_btn")
    outbtn:ShowWindow(1)
    outbtn:SetSkinName("test_pvp_btn")
    outbtn:SetTextTooltip("{@st59}Character Change Helper{nl}" .. "倉庫から搬出して装備します。{nl}" ..
                              "It is carried out from the warehouse and equipped.{/}")

end

function cc_helper_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function cc_helper_load_settings()
    print("testload")
    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    local pc = GetMyPCObject();
    g.LOGINCID = info.GetCID(session.GetMyHandle())

    local cid_settings = {
        name = pc.Name,
        seal_iesid = 0,
        seal_clsid = 0,
        seal_image = "",
        seal_obj = "",
        ark_iesid = 0,
        ark_clsid = 0,
        ark_image = "",
        ark_obj = "",
        gem_clsid = 0,
        gem_image = "",
        gem_obj = "",
        leg_iesid = 0,
        leg_clsid = 0,
        leg_image = "",
        leg_obj = "",
        god_iesid = 0,
        god_clsid = 0,
        god_image = "",
        god_obj = "",
        hair1_image = "",
        hair1_iesid = 0,
        hair1_clsid = 0,
        hair1_obj = "",
        hair1_str = "",
        hair2_image = "",
        hair2_iesid = 0,
        hair2_clsid = 0,
        hair2_obj = "",
        hair2_str = "",
        hair3_image = "",
        hair3_iesid = 0,
        hair3_clsid = 0,
        hair3_obj = "",
        hair3_str = "",
        crown_image = "",
        crown_iesid = 0,
        crown_clsid = 0,
        crown_obj = "",
        mcc_use = 0,
        agm_use = 0
    }

    -- 修正: g.settings が nil の場合のみ初期化
    if g.settings == nil then
        g.settings = {}
    end

    -- 修正: g.settings[LOGINCID] が nil の場合のみ初期化
    if g.settings[g.LOGINCID] == nil then
        g.settings[g.LOGINCID] = cid_settings
        g.settings.delay = 0.3 -- 新しく追加
    else
        -- 修正: settings が nil でない場合は g.settings[LOGINCID] に代入する
        if settings then
            g.settings[g.LOGINCID] = settings[g.LOGINCID]
        end
    end

    cc_helper_save_settings()
end

function cc_helper_take_items_from_warehouse(iesid)
    session.ResetItemList()
    session.AddItemID(tonumber(iesid), 1)
    item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
        ui.GetFrame("accountwarehouse"):GetUserIValue("HANDLE"))
end

function cc_helper_check_items_in_warehouse(iesid)

    local invframe = ui.GetFrame("inventory")
    local invTab = GET_CHILD_RECURSIVELY(invframe, "inventype_Tab")

    if iesid ~= 0 then

        local item_type = iesid.type
        if item_type == "god" then
            invTab:SelectTab(4)

            cc_helper_take_items_from_warehouse(iesid)
        elseif item_type == "leg" and g.check == 0 then
            invTab:SelectTab(4)
            cc_helper_take_items_from_warehouse(iesid)
        else

            invTab:SelectTab(1)
            cc_helper_take_items_from_warehouse(iesid)
        end

    end

end

function cc_helper_out_btn()

    local iesids = {{
        id = g.settings[g.LOGINCID].crown_iesid,

        type = "crown"

    }, {
        id = g.settings[g.LOGINCID].seal_iesid,
        type = "seal"
    }, {
        id = g.settings[g.LOGINCID].ark_iesid,
        type = "ark"
    }, {
        id = g.settings[g.LOGINCID].hair1_iesid,
        type = "hair1"

    }, {
        id = g.settings[g.LOGINCID].hair2_iesid,
        type = "hair2"

    }, {
        id = g.settings[g.LOGINCID].hair3_iesid,
        type = "hair3"

    }, {
        id = g.settings[g.LOGINCID].leg_iesid,
        type = "leg"

    }, {
        id = g.settings[g.LOGINCIDs].god_iesid,
        type = "god"

    }}
    -- print(tostring(g.settings[LOGINCID].crown_iesid))
    local fromframe = ui.GetFrame("accountwarehouse")

    for _, iesid in ipairs(iesids) do
        print(tostring(iesid.id))
        ReserveScript(string.format("cc_helper_check_items_in_warehouse('%s')", iesid), g.settings.delay)
        -- return
    end

    -- cc_helper_equip()
end

function cc_helper_cancel(frame, ctrl, argstr, argnum)

    ctrl:ClearIcon()
    ctrl:RemoveAllChild()
    print(tostring(ctrl:GetName()))
    for i = 1, 3 do
        if ctrl:GetName() == "Hair_slot" .. i then
            if i == 1 then
                g.settings[g.LOGINCID].hair1_image = ""
                g.settings[g.LOGINCID].hair1_iesid = 0
                g.settings[g.LOGINCID].hair1_clsid = 0
                g.settings[g.LOGINCID].hair1_obj = ""
                g.settings[g.LOGINCID].hair1_str = ""

            elseif i == 2 then
                g.settings[g.LOGINCID].hair2_image = ""
                g.settings[g.LOGINCID].hair2_iesid = 0
                g.settings[g.LOGINCID].hair2_clsid = 0
                g.settings[g.LOGINCID].hair2_obj = ""
                g.settings[g.LOGINCID].hair2_str = ""

            elseif i == 3 then
                g.settings[g.LOGINCID].hair3_image = ""
                g.settings[g.LOGINCID].hair3_iesid = 0
                g.settings[g.LOGINCID].hair3_clsid = 0
                g.settings[g.LOGINCID].hair3_obj = ""
                g.settings[g.LOGINCID].hair3_str = ""

            end
        end
    end

    if ctrl:GetName() == "crown_slot" then

        g.settings[g.LOGINCID].crown_iesid = 0
        g.settings[g.LOGINCID].crown_clsid = 0
        g.settings[g.LOGINCID].crown_obj = ""
        g.settings[g.LOGINCID].crown_image = ""

    elseif ctrl:GetName() == "seal_slot" then
        g.settings[g.LOGINCID].seal_iesid = 0
        g.settings[g.LOGINCID].seal_clsid = 0
        g.settings[g.LOGINCID].seal_obj = ""
        g.settings[g.LOGINCID].seal_image = ""

    elseif ctrl:GetName() == "ark_slot" then
        g.settings[g.LOGINCID].ark_iesid = 0
        g.settings[g.LOGINCID].ark_clsid = 0
        g.settings[g.LOGINCID].ark_obj = ""
        g.settings[g.LOGINCID].ark_image = ""

    elseif ctrl:GetName() == "agem_slot" then
        g.settings[g.LOGINCID].agem_clsid = 0
        g.settings[g.LOGINCID].agem_obj = ""
        g.settings[g.LOGINCID].agem_image = ""

    elseif ctrl:GetName() == "legcard_slot" then
        g.settings[g.LOGINCID].leg_iesid = 0
        g.settings[g.LOGINCID].leg_clsid = 0
        g.settings[g.LOGINCID].leg_obj = ""
        g.settings[g.LOGINCID].leg_image = ""

    elseif ctrl:GetName() == "godcard_slot" then
        g.settings[g.LOGINCID].god_iesid = 0
        g.settings[g.LOGINCID].god_clsid = 0
        g.settings[g.LOGINCID].god_obj = ""
        g.settings[g.LOGINCID].god_image = ""

    end
    cc_helper_save_settings()

end

function cc_helper_setting_hairslot(frame, index, fx)
    print(fx)
    -- x=10,70,130
    local Hairslot = frame:CreateOrGetControl("slot", "Hair_slot" .. index, fx, 190, 50, 50)
    AUTO_CAST(Hairslot)
    Hairslot:SetSkinName("invenslot2")
    Hairslot:SetText("{ol}{s14}HAIR" .. index)
    Hairslot:EnablePop(1)
    Hairslot:EnableDrag(1)
    Hairslot:EnableDrop(1)
    Hairslot:SetEventScript(ui.DROP, "cc_helper_drop")
    Hairslot:SetEventScript(ui.RBUTTONDOWN, "cc_helper_cancel")
    Hairslot:SetEventScript(ui.MOUSEON, "cc_helper_tooltip")

    -- Hairslot:SetEventScript(ui.MOUSEON, "cc_helper_tooltip")

    local hair1_image = g.settings[g.LOGINCID].hair1_image
    local hair2_image = g.settings[g.LOGINCID].hair2_image
    local hair3_image = g.settings[g.LOGINCID].hair3_image

    local hair1_iesid = g.settings[g.LOGINCID].hair1_iesid
    local hair2_iesid = g.settings[g.LOGINCID].hair2_iesid
    local hair3_iesid = g.settings[g.LOGINCID].hair3_iesid

    -- local hair1_image = "icon_item_accessory_ep12demonlord02"
    -- local hair2_image = "icon_item_accessory_blackglass"
    -- local hair3_image = "icon_item_accessory_ep14rider03"

    if hair1_image ~= "" and index == 1 then
        -- SET_SLOT_IMG(Hairslot, "icon_item_accessory_ep14rider03");
        SET_SLOT_IMG(Hairslot, hair1_image);
        SET_SLOT_IESID(Hairslot, hair1_iesid);
        Hairslot:SetEventScript(ui.MOUSEON, "cc_helper_tooltip")
        Hairslot:SetEventScriptArgString(ui.MOUSEON, hair1_iesid);
    elseif hair2_image ~= "" and index == 2 then

        SET_SLOT_IMG(Hairslot, hair2_image);
        SET_SLOT_IESID(Hairslot, hair2_iesid);
        Hairslot:SetEventScript(ui.MOUSEON, "cc_helper_tooltip")
        Hairslot:SetEventScriptArgString(ui.MOUSEON, hair2_iesid);
    elseif hair3_image ~= "" and index == 3 then

        SET_SLOT_IMG(Hairslot, hair3_image);
        SET_SLOT_IESID(Hairslot, hair3_iesid);
        Hairslot:SetEventScript(ui.MOUSEON, "cc_helper_tooltip")
        Hairslot:SetEventScriptArgString(ui.MOUSEON, hair3_iesid);
    end

end

function cc_helper_tooltip(frame, ctrl, argStr, argNum)

    local item = session.GetInvItemByGuid(tonumber(argStr));
    local obj = ""
    if item ~= nil then
        local itemobj = GetIES(item:GetObject());

        if ctrl:GetName() == "seal_slot" then
            g.settings[g.LOGINCID].seal_obj = itemobj
            obj = g.settings[g.LOGINCID].seal_obj
        elseif ctrl:GetName() == "ark_slot" then
            g.settings[g.LOGINCID].ark_obj = itemobj
            obj = g.settings[g.LOGINCID].ark_obj
        elseif ctrl:GetName() == "legcard_slot" then
            g.settings[g.LOGINCID].leg_obj = itemobj
            obj = g.settings[g.LOGINCID].leg_obj
        elseif ctrl:GetName() == "godcard_slot" then
            g.settings[g.LOGINCID].god_obj = itemobj
            obj = g.settings[g.LOGINCID].god_obj
        elseif ctrl:GetName() == "crown_slot" then
            g.settings[g.LOGINCID].crown_obj = itemobj
            obj = g.settings[g.LOGINCID].crown_obj
        end
    end
    local classid = obj.ClassID
    local classname = obj.ClassName
    local icon = ctrl:GetIcon()
    icon:SetTooltipArg("", classid, tonumber(argStr));
    SET_ITEM_TOOLTIP_TYPE(icon, classid, obj, "");
    cc_helper_save_settings()
end

function cc_helper_setting_frame_init()

    local frame = ui.GetFrame(addonNameLower)
    frame:SetSkinName("test_frame_low")
    frame:SetLayerLevel(93)
    frame:Resize(270, 255)
    frame:SetPos(1140, 380)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    frame:EnableHitTest(1)

    if frame:IsVisible() == 0 then

        frame:ShowWindow(1)

    else
        frame:ShowWindow(0)
    end

    local title = frame:CreateOrGetControl("richtext", "title", 40, 15)
    title:SetText("{#000000}{s16}CC Helper")

    local close = frame:CreateOrGetControl('button', 'close', 0, 0, 30, 30)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.LEFT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "cc_helper_settings_close")

    local delay = frame:CreateOrGetControl('edit', 'delay', 120, 10, 60, 30)
    AUTO_CAST(delay)
    delay:SetText("{ol}" .. g.settings.delay)
    delay:SetFontName("white_16_ol")
    delay:SetTextAlign("center", "center")
    delay:SetEventScript(ui.ENTERKEY, "cc_helper_delay_change")
    delay:SetTextTooltip(
        "動作のディレイ時間を設定します。デフォルトは0.3秒。早過ぎると失敗が多発します。{nl}" ..
            "Sets the delay time for the operation. Default is 0.3 seconds. Too early and many failures will occur.")

    local fx = 10
    for i = 1, 3 do
        cc_helper_setting_hairslot(frame, i, fx)
        fx = fx + 60
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
        slot:SetEventScriptArgString(ui.MOUSEON, iesid);
        -- slot:SetEventScriptArgNumber(ui.MOUSEON, iesid);

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
        image = g.settings[g.LOGINCID].seal_image
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
        image = g.settings[g.LOGINCID].ark_image
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
        image = g.settings[g.LOGINCID].gem_image
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
        image = g.settings[g.LOGINCID].leg_image
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
        image = g.settings[g.LOGINCID].god_image
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
        image = g.settings[g.LOGINCID].crown_image
    }}

    for _, info in ipairs(slotInfo) do
        createSlot(frame, info.name, info.x, info.y, info.width, info.height, info.skin, info.text, info.dropHandler,
            info.cancelHandler, info.image, info.iesid)
    end

end

function cc_helper_frame_drop(frame, ctrl, argstr, argnum)
    local lifticon = ui.GetLiftIcon();

    local slot = tolua.cast(ctrl, 'ui::CSlot')
    local iconinfo = lifticon:GetInfo();
    local item = GET_PC_ITEM_BY_GUID(iconinfo:GetIESID());
    local itemobj = GetIES(item:GetObject());
    local classid = itemobj.ClassID
    local iesid = iconinfo:GetIESID()
    local image = TryGetProp(itemobj, "TooltipImage", "None")
    local slot_name = ctrl:GetName()
    print(tostring(image))
    print(argstr)
    local type = itemobj.ClassType
    -- local gemtype = GET_EQUIP_GEM_TYPE(itemobj)

    if slot_name == "seal_slot" then
        if type == "Seal" and classid ~= 614001 then
            SET_SLOT_IMG(slot, image);
            SET_SLOT_IESID(slot, iesid);
            -- SET_ITEM_TOOLTIP_BY_TYPE(slot:GetIcon(), iesid)
            g.settings[g.LOGINCID].seal_iesid = iesid
            g.settings[g.LOGINCID].seal_image = image
            g.settings[g.LOGINCID].seal_obj = tostring(itemobj)
        elseif type == "Seal" and classid == 614001 then
            ui.SysMsg("This item cannot be set.")
        else
            ui.SysMsg("Drop it in the correct slot.")
        end

    elseif slot_name == "ark_slot" then
        if type == "Ark" then
            if TryGetProp(itemobj, 'CharacterBelonging', 0) == 1 then
                ui.SysMsg(ClMsg("ItemIsNotTradable"));
                return;
            end
            SET_SLOT_IMG(slot, image);
            SET_SLOT_IESID(slot, iesid);
            g.settings[g.LOGINCID].ark_iesid = iesid
            g.settings[g.LOGINCID].ark_image = image

        else
            ui.SysMsg("Drop it in the correct slot.")
        end
    elseif slot_name == "legcard_slot" then
        local cardobj = GetClassByType("Item", classid)
        if itemobj.CardGroupName ~= "LEG" then
            ui.SysMsg(ClMsg("ToEquipSameCardGroup"));
            return
        end

        SET_SLOT_IMG(ctrl, image)
        SET_SLOT_IESID(ctrl, iesid);
        g.settings[g.LOGINCID].leg_iesid = iesid
        g.settings[g.LOGINCID].leg_image = image

    end
    cc_helper_save_settings()
end
