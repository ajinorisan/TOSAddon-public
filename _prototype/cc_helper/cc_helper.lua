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
local os = require("os")

function CC_HELPER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.LOGINCID = info.GetCID(session.GetMyHandle())
    -- g.monstercard = nil

    acutil.setupEvent(addon, "ACCOUNTWAREHOUSE_CLOSE", "cc_helper_ACCOUNTWAREHOUSE_CLOSE");
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

function cc_helper_settings_close(frame)
    local frame = ui.GetFrame(addonNameLower)
    frame:ShowWindow(0)
end

function cc_helper_ACCOUNTWAREHOUSE_CLOSE(frame)

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
    awh_outbtn:SetTextTooltip("Character Change Helper{nl}" .. "倉庫から搬出して装備します。{nl}" ..
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

    if not settings then
        g.settings = {}
        g.settings.delay = 0.3 -- 新しく追加
    end

    local pc = GetMyPCObject();
    print(tostring(pc))

    print(tostring(g.LOGINCID))

    local cid_settings = {}
    cid_settings = {
        name = pc.Name,
        seal_iesid = 0,
        seal_clsid = 0,
        seal_image = "",

        ark_iesid = 0,
        ark_clsid = 0,
        ark_image = "",

        gem_clsid = 0,
        gem_image = "",

        leg_iesid = 0,
        leg_clsid = 0,
        leg_image = "",

        god_iesid = 0,
        god_clsid = 0,
        god_image = "",

        hair1_image = "",
        hair1_iesid = 0,
        hair1_clsid = 0,

        hair2_image = "",
        hair2_iesid = 0,
        hair2_clsid = 0,

        hair3_image = "",
        hair3_iesid = 0,
        hair3_clsid = 0,

        crown_image = "",
        crown_iesid = 0,
        crown_clsid = 0,

        mcc_use = 0,
        agm_use = 0
    }

    -- 修正: g.settings[LOGINCID] が nil の場合のみ初期化
    if g.settings[g.LOGINCID] == nil then
        g.settings[g.LOGINCID] = cid_settings

    else
        -- 修正: settings が nil でない場合は g.settings[LOGINCID] に代入する
        if settings then
            g.settings[g.LOGINCID] = settings[g.LOGINCID]
        end
    end

    cc_helper_save_settings()
end

function cc_helper_take_items_from_warehouse(iesid, type)
    print(tostring(type))
    print(tostring(iesid))
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
        id = g.settings[g.LOGINCID].god_iesid,
        type = "god"
    }}
    -- print(tostring(g.settings[LOGINCID].crown_iesid))
    local fromframe = ui.GetFrame("accountwarehouse")
    local delay = 0
    for _, iesid in ipairs(iesids) do
        if iesid.id ~= 0 then
            ReserveScript(string.format("cc_helper_take_items_from_warehouse('%s','%s')", iesid.id, iesid.type), delay)
            delay = delay + g.settings.delay
        end
    end
    print(delay)
    ReserveScript("cc_helper_equip_reserve()", delay)
end

function cc_helper_equip(spot, iesid, index)
    -- print("test")
    -- print(tostring(frame:GetName()))
    print(tostring(spot))
    print(tostring(iesid))
    print(tostring(index) .. tostring(type(index)))
    ITEM_EQUIP(index, spot)
    -- frame:Invalidate()
end

function cc_helper_equip_reserve()
    local frame = ui.GetFrame("inventory")
    print("test2")
    local iesids = {
        SEAL = g.settings[g.LOGINCID].seal_iesid,
        ARK = g.settings[g.LOGINCID].ark_iesid,
        HAT = g.settings[g.LOGINCID].hair1_iesid,
        HAT_T = g.settings[g.LOGINCID].hair2_iesid,
        HAT_L = g.settings[g.LOGINCID].hair3_iesid,
        RELIC = g.settings[g.LOGINCID].crown_iesid,
        LEGCARD = g.settings[g.LOGINCID].leg_iesid,
        GODCARD = g.settings[g.LOGINCID].god_iesid
    }
    local delay = g.settings.delay
    for spot, iesid in pairs(iesids) do
        local item = session.GetInvItemByGuid(tonumber(iesid))

        if item ~= nil and (spot ~= "LEGCARD" or spot ~= "GODCARD") then
            -- print(tostring(item))
            local index = item.invIndex
            -- print(tostring(index))
            if iesid ~= 0 then

                ReserveScript(string.format("cc_helper_equip('%s','%s',%d)", spot, iesid, index), delay)
                delay = delay + g.settings.delay
            end
        elseif item ~= nil and spot ~= "LEGCARD" and g.check ~= 0 or spot ~= "GODCARD" then
            MONSTERCARDSLOT_FRAME_OPEN()
        end
    end

    -- 他の処理も同様にループ内で行う

    -- ...

    -- ループが終了したら最終処理を行う
    -- cc_helper_end_of_operation()
end

function cc_helper_cancel(frame, ctrl, argstr, argnum)

    ctrl:ClearIcon()
    ctrl:RemoveAllChild()
    print(tostring(ctrl:GetName()))

    if ctrl:GetName() == "hair_slot1" then

        g.settings[g.LOGINCID].hair1_image = ""
        g.settings[g.LOGINCID].hair1_iesid = 0
        g.settings[g.LOGINCID].hair1_clsid = 0

    elseif ctrl:GetName() == "hair_slot2" then
        g.settings[g.LOGINCID].hair2_image = ""
        g.settings[g.LOGINCID].hair2_iesid = 0
        g.settings[g.LOGINCID].hair2_clsid = 0

    elseif ctrl:GetName() == "hair_slot3" then
        g.settings[g.LOGINCID].hair3_image = ""
        g.settings[g.LOGINCID].hair3_iesid = 0
        g.settings[g.LOGINCID].hair3_clsid = 0

    elseif ctrl:GetName() == "crown_slot" then

        g.settings[g.LOGINCID].crown_iesid = 0
        g.settings[g.LOGINCID].crown_clsid = 0

        g.settings[g.LOGINCID].crown_image = ""

    elseif ctrl:GetName() == "seal_slot" then
        g.settings[g.LOGINCID].seal_iesid = 0
        g.settings[g.LOGINCID].seal_clsid = 0

        g.settings[g.LOGINCID].seal_image = ""

    elseif ctrl:GetName() == "ark_slot" then
        g.settings[g.LOGINCID].ark_iesid = 0
        g.settings[g.LOGINCID].ark_clsid = 0

        g.settings[g.LOGINCID].ark_image = ""

    elseif ctrl:GetName() == "agem_slot" then
        g.settings[g.LOGINCID].agem_clsid = 0

        g.settings[g.LOGINCID].agem_image = ""

    elseif ctrl:GetName() == "legcard_slot" then
        g.settings[g.LOGINCID].leg_iesid = 0
        g.settings[g.LOGINCID].leg_clsid = 0

        g.settings[g.LOGINCID].leg_image = ""

    elseif ctrl:GetName() == "godcard_slot" then
        g.settings[g.LOGINCID].god_iesid = 0
        g.settings[g.LOGINCID].god_clsid = 0

        g.settings[g.LOGINCID].god_image = ""

    end
    cc_helper_save_settings()

end

function cc_helper_tooltip(frame, ctrl, argStr, argNum)

    local icon = ctrl:GetIcon()
    local icon_info = icon:GetInfo()
    local icon_iesid = icon_info:GetIESID()
    -- local item = GET_PC_ITEM_BY_GUID(icon_info:GetIESID())
    -- local itemobj = GetIES(item:GetObject());
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
        end

    else
        ctrl:ClearIcon();
        return
    end

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

    local delay = frame:CreateOrGetControl('edit', 'delay', 140, 10, 60, 30)
    AUTO_CAST(delay)
    delay:SetText("{ol}" .. g.settings.delay)
    delay:SetFontName("white_16_ol")
    delay:SetTextAlign("center", "center")
    delay:SetEventScript(ui.ENTERKEY, "cc_helper_delay_change")
    delay:SetTextTooltip(
        "動作のディレイ時間を設定します。デフォルトは0.3秒。早過ぎると失敗が多発します。{nl}" ..
            "Sets the delay time for the operation. Default is 0.3 seconds. Too early and many failures will occur.")

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
        image = g.settings[g.LOGINCID].hair1_image
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
        image = g.settings[g.LOGINCID].hair2_image
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
        image = g.settings[g.LOGINCID].hair3_image
    }}

    for _, info in ipairs(slotInfo) do
        createSlot(frame, info.name, info.x, info.y, info.width, info.height, info.skin, info.text, info.dropHandler,
            info.cancelHandler, info.image, info.iesid)
    end

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

    print(tostring(type))
    -- local gemtype = GET_EQUIP_GEM_TYPE(itemobj)

    if slot_name == "seal_slot" then

        if type == "Seal" and classid ~= 614001 then
            SET_SLOT_IMG(slot, image);
            SET_SLOT_IESID(slot, iesid);
            -- SET_ITEM_TOOLTIP_BY_TYPE(slot:GetIcon(), iesid)
            g.settings[g.LOGINCID].seal_iesid = iesid
            g.settings[g.LOGINCID].seal_image = image
            g.settings[g.LOGINCID].seal_clsid = classid

        else
            ui.SysMsg("This item cannot be set.")
            return

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
    else
        return

    end
    cc_helper_save_settings()
end

--[[--[[function cc_helper_check_items_in_warehouse(iesid, type)
    print(tostring(type))
    print(tostring(iesid))
    local invframe = ui.GetFrame("inventory")
    local invTab = GET_CHILD_RECURSIVELY(invframe, "inventype_Tab")

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
function cc_helper_setting_hairslot(frame, index, fx)
    -- print(fx)

    -- x=10,70,130
    local hairslot = frame:CreateOrGetControl("slot", "hair_slot" .. index, fx, 190, 50, 50)
    AUTO_CAST(hairslot)
    local icon = hairslot:GetIcon()
    local icon_info = icon:GetInfo()
    local item = GET_PC_ITEM_BY_GUID(icon_info:GetIESID());
    local itemobj = GetIES(item:GetObject());
    local classid = itemobj.ClassID

    hairslot:SetSkinName("invenslot2")
    hairslot:SetText("{ol}{s14}HAIR" .. index)
    hairslot:EnablePop(1)
    hairslot:EnableDrag(1)
    hairslot:EnableDrop(1)
    hairslot:SetEventScript(ui.DROP, "cc_helper_frame_drop")
    hairslot:SetEventScript(ui.RBUTTONDOWN, "cc_helper_cancel")
    hairslot:SetEventScript(ui.MOUSEON, "cc_helper_tooltip")

    if g.settings[g.LOGINCID].hair1_image ~= "" and index == 1 then

        SET_SLOT_IMG(hairslot, g.settings[g.LOGINCID].hair1_image);
        SET_SLOT_IESID(hairslot, g.settings[g.LOGINCID].hair1_iesid);
        -- g.settings[g.LOGINCID].hair1_clsid = classid

    elseif g.settings[g.LOGINCID].hair2_image ~= "" and index == 2 then

        SET_SLOT_IMG(hairslot, g.settings[g.LOGINCID].hair2_image);
        SET_SLOT_IESID(hairslot, g.settings[g.LOGINCID].hair2_iesid);
        -- g.settings[g.LOGINCID].hair2_clsid = classid

    elseif g.settings[g.LOGINCID].hair3_image ~= "" and index == 3 then

        SET_SLOT_IMG(hairslot, g.settings[g.LOGINCID].hair3_image);
        SET_SLOT_IESID(hairslot, g.settings[g.LOGINCID].hair3_iesid);
        -- g.settings[g.LOGINCID].hair3_clsid = classid

    end
    -- cc_helper_save_settings()
end]]
