--[[ function MONSTERCARDSLOT_FRAME_OPEN() モンスターカードフレームを開く
    --function ACCOUNT_WAREHOUSE_INV_RBTN(itemObj, slot) これでインベから倉庫へ入れられそう

        local enableTeamTrade = TryGetProp(itemCls, "TeamTrade"); このコードあたりでトレード出来ないアークを表示するの制御できそう
    if enableTeamTrade ~= nil and enableTeamTrade == "NO" then
        ui.SysMsg(ClMsg("ItemIsNotTradable"));
        return;
    end

    local belongingCount = TryGetProp(obj, 'BelongingCount', 0)
    if belongingCount > 0 and belongingCount >= invItem.count then
        ui.SysMsg(ClMsg("ItemIsNotTradable"));
        return;
    end

    if TryGetProp(obj, 'CharacterBelonging', 0) == 1 then
        ui.SysMsg(ClMsg("ItemIsNotTradable"));
        return;
    end 

    --function INVENTORY_ON_DROP(frame, control, argStr, argNum) 倉庫から取り出すっぽい

        --function PUT_ITEM_TO_INV(slotSet, slot)こっちの方が良いかな

            local warehouse = session.GetEtcItemList(IT_WAREHOUSE)
local warehouseCount = warehouse:GetItemCount()

for i = 0, warehouseCount - 1 do　--gemidからIESIDを取得するコード。合ってるんか？
    local item = warehouse:GetItemByIndex(i)
    local itemIESID = item.ClassID -- IESIDの取得　tonumber(g.gemid)
    -- itemIESIDを使って個別の処理を行う
    -- 例: CHAT_SYSTEM(itemIESID)
end

local legcardslot = 13 --レジェカを外すコード
    local frame = ui.GetFrame("monstercardslot")
    local argStr = legcardslot - 1

    argStr = argStr .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
    pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)

    local legcardslot = 14　--ゴッデスカード外す
    local frame = ui.GetFrame("monstercardslot")
    local argStr = legcardslot - 1

    argStr = argStr .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
    pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)

    function EQUIP_CARD()　--カード装備
    local slotIndex = 既知のslotIndex
    local itemGuid = 既知のIESID
    local invFrame = ui.GetFrame("inventory")
    invFrame:SetUserValue("EQUIP_CARD_GUID", itemGuid)
    invFrame:SetUserValue("EQUIP_CARD_SLOTINDEX", slotIndex)
    local argStr = string.format("%d#%s", slotIndex, itemGuid)
    pc.ReqExecuteTx("SCR_TX_EQUIP_CARD_SLOT", argStr)
    invFrame:SetUserValue("EQUIP_CARD_GUID", "")
    invFrame:SetUserValue("EQUIP_CARD_SLOTINDEX", "")
end
 ]] --
local addonName = "CC_HELPER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")

if not g.loaded then
    g.settings = {
        charid = {
            sealiesid = {},
            arkiesid = {},
            gemid = {},
            legiesid = {},
            legimage = {},
            godiesid = {},
            godimage = {}

        }
    }
end

function CC_HELPER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    local invframe = ui.GetFrame("inventory")
    local inventoryGbox = invframe:GetChild("inventoryGbox")
    -- ボタンの配置位置
    local inbtnX = inventoryGbox:GetWidth() - 285
    local inbtnY = inventoryGbox:GetHeight() - 290
    local inbtn = invframe:CreateOrGetControl("button", "in", inbtnX, inbtnY, 30, 30)
    AUTO_CAST(inbtn)
    inbtn:SetText("IN")
    inbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_in_btn")

    local outbtnX = inventoryGbox:GetWidth() - 252
    local outbtnY = inventoryGbox:GetHeight() - 290
    local outbtn = invframe:CreateOrGetControl("button", "out", outbtnX, outbtnY, 40, 30)
    AUTO_CAST(outbtn)
    outbtn:SetText("OUT")

    local setbtnX = inventoryGbox:GetWidth() - 207
    local setbtnY = inventoryGbox:GetHeight() - 290
    local setbtn = invframe:CreateOrGetControl("button", "set", setbtnX, setbtnY, 30, 30)
    AUTO_CAST(setbtn)
    setbtn:SetSkinName("None")
    setbtn:SetImage("config_button_normal")
    setbtn:Resize(30, 30)
    setbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_frame_init")
    -- if not g.loaded then
    -- g.loaded = true
    -- end
    -- cc_helper_load_settings()
    CHAT_SYSTEM(addonNameLower .. " loaded")
    addon:RegisterMsg("GAME_START_3SEC", "cc_helper_load_settings")

end

function cc_helper_in_btn()
    CHAT_SYSTEM("click")
    local frame = ui.GetFrame("inventory")

    local loginCharID = info.GetCID(session.GetMyHandle()) -- ログイン中のキャラクターIDを取得

    local seal = GET_CHILD_RECURSIVELY(frame, "SEAL")
    local ark = GET_CHILD_RECURSIVELY(frame, "ARK")
    -- local sealinfo = seal:GetIcon():GetInfo()
    local sealiesid = seal:GetIcon():GetInfo():GetIESID()
    local arkiesid = ark:GetIcon():GetInfo():GetIESID()
    CHAT_SYSTEM(sealiesid)
    local equipItemList = session.GetEquipItemList()
    for i = 0, equipItemList:Count() - 1 do
        local equipItem = equipItemList:GetEquipItemByIndex(i)
        -- local itemObj = GetIES(equipItem:GetObject())

        local induninfo = ui.GetFrame("induninfo")
        local indunenter = ui.GetFrame("indunenter")

        if induninfo:IsVisible() == 0 or indunenter:IsVisible() == 0 then
            if seal:GetIcon() ~= nil then
                if g.settings.pcitem[loginCharID] and tostring(sealiesid) == tostring(g.settings.pcitem.iesid) then
                    item.UnEquip(tonumber(25));
                    ReserveScript("test_norisan_in_btn()", 0.5)
                    break
                else
                    ReserveScript("test_norisan_in_btn()", 0.5)
                    break
                end
            end

            if ark:GetIcon() ~= nil then
                if g.settings.pcitem[loginCharID] and tostring(arkiesid) == tostring(g.settings.pcitem.iesid) then
                    item.UnEquip(tonumber(27));
                    break
                end

            end
        else
            return

        end
    end

    CHAT_SYSTEM("test")
    local monstercard = ui.GetFrame("monstercardslot")
    local goddesscard = ui.GetFrame("goddesscardslot")
    CHAT_SYSTEM("test1")
    monstercard:ShowWindow(1)
    goddesscard:ShowWindow(1)
end

function cc_helper_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function cc_helper_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    -- local loginCharID = tostring(info.GetCID(session.GetMyHandle()))

    cc_helper_setting()

end

function cc_helper_setting()
    local loginCharID = info.GetCID(session.GetMyHandle())
    local sealiesid = g.settings.charid.sealiesid[loginCharID]
    g.sealiesid = nil
    if sealiesid ~= nil then
        g.sealiesid = sealiesid
        CHAT_SYSTEM(g.sealiesid)
    end
    -- 
    local arkiesid = g.settings.charid.arkiesid[loginCharID]

    g.arkiesid = nil
    if arkiesid ~= nil then
        g.arkiesid = arkiesid
        CHAT_SYSTEM(g.arkiesid)
    end
    -- 
    -- CHAT_SYSTEM(arkiesid)
    local gemid = g.settings.charid.gemid[loginCharID]
    g.gemid = nil
    if gemid ~= nil then
        g.gemid = gemid
        CHAT_SYSTEM(g.gemid)
    end
    -- 
    local legiesid = g.settings.charid.legiesid[loginCharID]
    g.legiesid = nil
    if legiesid ~= nil then
        g.legiesid = legiesid
        CHAT_SYSTEM(g.legiesid)
    end
    -- CHAT_SYSTEM(legiesid)
    local legimage = g.settings.charid.legimage[loginCharID]
    g.legimage = nil
    if legimage ~= nil then
        g.legimage = legimage
        CHAT_SYSTEM(g.legimage)
    end
    -- CHAT_SYSTEM(legimage)
    local godiesid = g.settings.charid.godiesid[loginCharID]
    g.godiesid = nil
    if godiesid ~= nil then
        g.godiesid = godiesid
        CHAT_SYSTEM(g.godiesid)
    end
    -- 
    -- CHAT_SYSTEM(godiesid)
    local godimage = g.settings.charid.godimage[loginCharID]
    g.godimage = nil
    if godimage ~= nil then
        g.godimage = godimage
        CHAT_SYSTEM(g.godimage)
    end
    -- 
    -- CHAT_SYSTEM(godimage)
end

function cc_helper_enddrop(sealiesid, arkiesid, gemid, legiesid, legimage, godiesid, godimage)
    CHAT_SYSTEM("enddrop")
    local loginCharID = info.GetCID(session.GetMyHandle())
    if sealiesid ~= nil then
        g.settings.charid.sealiesid[tostring(loginCharID)] = sealiesid
    end
    if arkiesid ~= nil then
        g.settings.charid.arkiesid[tostring(loginCharID)] = arkiesid
    end
    if gemid ~= nil then
        g.settings.charid.gemid[tostring(loginCharID)] = tostring(gemid)
    end
    if legiesid ~= nil then
        g.settings.charid.legiesid[tostring(loginCharID)] = legiesid
    end
    if legimage ~= nil then
        g.settings.charid.legimage[tostring(loginCharID)] = legimage
    end
    if godiesid ~= nil then
        g.settings.charid.godiesid[tostring(loginCharID)] = godiesid
    end
    if godiesid ~= nil then
        g.settings.charid.godimage[tostring(loginCharID)] = godimage
    end
    cc_helper_save_settings()

end

function cc_helper_cancel(frame, ctrl, argstr, argnum)

    ctrl:ClearIcon()
    ctrl:SetMaxSelectCount(0)
    ctrl:RemoveAllChild()

    local loginCharID = info.GetCID(session.GetMyHandle())
    if GET_CHILD_RECURSIVELY(frame, "sealslot") then
        g.settings.charid.sealiesid = nil
    end

    if GET_CHILD_RECURSIVELY(frame, "arkslot") then
        g.settings.charid.arkiesid = nil
    end

    if GET_CHILD_RECURSIVELY(frame, "agemslot") then
        g.settings.charid.gemid = nil
    end

    if GET_CHILD_RECURSIVELY(frame, "legcardslot") then
        g.settings.charid.legiesid = nil
        g.settings.charid.legimage = nil
    end

    if GET_CHILD_RECURSIVELY(frame, "godcardslot") then
        g.settings.charid.godiesid = nil
        g.settings.charid.godimage = nil
    end

    cc_helper_save_settings()

end

function cc_helper_on_legendcard_drop(frame, ctrl, argstr, argnum)

    -- CHAT_SYSTEM(ctrl:GetName())

    local lifticon = ui.GetLiftIcon();
    local liftframe = ui.GetLiftFrame():GetTopParentFrame()
    local slot = tolua.cast(ctrl, 'ui::CSlot')
    local iconinfo = lifticon:GetInfo();
    local item = GET_PC_ITEM_BY_GUID(iconinfo:GetIESID());
    local legiesid = iconinfo:GetIESID()
    local itemobj = GetIES(item:GetObject());
    local classid = itemobj.ClassID
    local iesid = iconinfo:GetIESID()
    local type = itemobj.ClassType

    local cardobj = GetClassByType("Item", classid)
    -- CHAT_SYSTEM(cardobj.CardGroupName)
    if cardobj.CardGroupName ~= "LEG" then
        ui.SysMsg(ClMsg("ToEquipSameCardGroup"));
        return
    end
    local legimage = TryGetProp(cardobj, "TooltipImage", "None")

    SET_SLOT_IMG(ctrl, legimage)
    SET_SLOT_IESID(ctrl, item:GetIESID());
    cc_helper_enddrop(sealiesid, arkiesid, gemid, legiesid, legimage, godiesid, godimage)
    -- cc_helper_enddrop(iesid, type, classid)

end

function cc_helper_on_goddesscard_drop(frame, ctrl, argstr, argnum)

    -- CHAT_SYSTEM(ctrl:GetName())

    local lifticon = ui.GetLiftIcon();
    local liftframe = ui.GetLiftFrame():GetTopParentFrame()
    local slot = tolua.cast(ctrl, 'ui::CSlot')
    local iconinfo = lifticon:GetInfo();
    local item = GET_PC_ITEM_BY_GUID(iconinfo:GetIESID());
    local godiesid = iconinfo:GetIESID()
    local itemobj = GetIES(item:GetObject());
    local classid = itemobj.ClassID
    local iesid = iconinfo:GetIESID()
    local type = itemobj.ClassType
    -- CHAT_SYSTEM(godiesid)

    local cardobj = GetClassByType("Item", classid)
    -- CHAT_SYSTEM(cardobj.CardGroupName)
    if cardobj.CardGroupName ~= "GODDESS" then
        ui.SysMsg(ClMsg("ToEquipSameCardGroup"));
        return
    end
    local godimage = TryGetProp(cardobj, "TooltipImage", "None")

    SET_SLOT_IMG(ctrl, godimage)
    SET_SLOT_IESID(ctrl, item:GetIESID());

    cc_helper_enddrop(sealiesid, arkiesid, gemid, legiesid, legimage, godiesid, godimage)
    -- cc_helper_enddrop(iesid, type, classid)

end

function cc_helper_onark_drop(frame, ctrl, argstr, argnum)
    -- CHAT_SYSTEM(frame:GetName())

    local lifticon = ui.GetLiftIcon();
    local liftframe = ui.GetLiftFrame():GetTopParentFrame()
    local slot = tolua.cast(ctrl, 'ui::CSlot')
    local iconinfo = lifticon:GetInfo();
    local item = GET_PC_ITEM_BY_GUID(iconinfo:GetIESID());
    local itemobj = GetIES(item:GetObject());
    local classid = itemobj.ClassID
    local iesid = iconinfo:GetIESID()
    local type = itemobj.ClassType
    local gemtype = GET_EQUIP_GEM_TYPE(itemobj)
    local gemcls = GetClassByType("Item", classid)

    local itemcls = GetClassByType("Item", item.type);
    local enableTeamTrade = TryGetProp(itemcls, "TeamTrade");
    -- CHAT_SYSTEM(enableTeamTrade)
    if enableTeamTrade ~= nil and enableTeamTrade == "NO" then
        ui.SysMsg(ClMsg("ItemIsNotTradable"));
        return;
    end
    -- IS_ENABLE_TRADE_BY_TRADE_TYPE(item, property)
    -- CHAT_SYSTEM(gemtype)
    -- CHAT_SYSTEM(iesid)
    -- CHAT_SYSTEM(type)

    -- Arkのチームトレードの可否を調べるコードがわからん
    if ctrl == GET_CHILD_RECURSIVELY(frame, "arkslot") then
        if type == "Ark" then
            SET_SLOT_IMG(slot, itemobj.Icon);
            SET_SLOT_IESID(slot, item:GetIESID());
            local arkiesid = iconinfo:GetIESID()
            cc_helper_enddrop(sealiesid, arkiesid, gemid, legiesid, legimage, godiesid, godimage)
        else
            ui.SysMsg("Drop it in the correct slot.")
        end
    end

    -- pcitem = {},
    -- pcitemtype = {}

    -- g.settings.pcitemtype[info.GetCID(session.GetMyHandle())] = iesid
    -- cc_helper_enddrop(iesid, type, classid)

end

function cc_helper_onseal_drop(frame, ctrl, argstr, argnum)
    -- CHAT_SYSTEM(frame:GetName())

    local lifticon = ui.GetLiftIcon();
    local liftframe = ui.GetLiftFrame():GetTopParentFrame()
    local slot = tolua.cast(ctrl, 'ui::CSlot')
    local iconinfo = lifticon:GetInfo();
    local item = GET_PC_ITEM_BY_GUID(iconinfo:GetIESID());
    local itemobj = GetIES(item:GetObject());
    local classid = itemobj.ClassID
    local iesid = iconinfo:GetIESID()
    local type = itemobj.ClassType
    local gemtype = GET_EQUIP_GEM_TYPE(itemobj)
    local gemcls = GetClassByType("Item", classid)
    local sealiesid = item:GetIESID()

    if ctrl == GET_CHILD_RECURSIVELY(frame, "sealslot") then
        if type == "Seal" and classid ~= 614001 then
            SET_SLOT_IMG(slot, itemobj.Icon);
            SET_SLOT_IESID(slot, item:GetIESID());

        elseif type == "Seal" and classid == 614001 then
            ui.SysMsg("This item cannot be set.")
        else
            ui.SysMsg("Drop it in the correct slot.")
        end
    end
    cc_helper_enddrop(sealiesid, arkiesid, gemid, legiesid, legimage, godiesid, godimage)

end

function cc_helper_ongem_drop(frame, ctrl, argstr, argnum)
    -- CHAT_SYSTEM(frame:GetName())

    local lifticon = ui.GetLiftIcon();
    local liftframe = ui.GetLiftFrame():GetTopParentFrame()
    local slot = tolua.cast(ctrl, 'ui::CSlot')
    local iconinfo = lifticon:GetInfo();
    local item = GET_PC_ITEM_BY_GUID(iconinfo:GetIESID());
    local itemobj = GetIES(item:GetObject());
    local classid = itemobj.ClassID
    local iesid = iconinfo:GetIESID()
    local type = itemobj.ClassType
    local gemtype = GET_EQUIP_GEM_TYPE(itemobj)
    local gemcls = GetClassByType("Item", classid)

    if ctrl == GET_CHILD_RECURSIVELY(frame, "agemslot") then
        if gemtype == "aether" then
            SET_SLOT_IMG(slot, itemobj.Icon);
            SET_SLOT_IESID(slot, item:GetIESID());
            local gemid = classid
            cc_helper_enddrop(sealiesid, arkiesid, gemid, legiesid, legimage, godiesid, godimage)
        else
            ui.SysMsg("Drop it in the correct slot.")
        end
    end

end

function cc_helper_settings_close(frame)
    frame:ShowWindow(0)
end

function cc_helper_frame_init()

    local frame = ui.GetFrame(addonNameLower)
    frame:SetSkinName("test_frame_low")
    frame:SetLayerLevel(93)
    frame:Resize(270, 190)
    frame:SetPos(1140, 200)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    -- frame:EnableDrop(1)
    -- frame:EnablePop(1)
    -- frame:EnableDrag(1)
    -- ipframe:EnableHide(0)
    frame:EnableHitTest(1)
    -- frame:ShowWindow(1)

    if frame:IsVisible() == 0 then

        frame:ShowWindow(1)

    else
        frame:ShowWindow(0)
    end

    local title = frame:CreateOrGetControl("richtext", "indun_panel_title", 45, 15)
    title:SetText("{#000000}{s20}CC Helper")

    -- CHAT_SYSTEM("TEST")
    local close = frame:CreateOrGetControl('button', 'minebtn', 10, 10, 30, 30)
    AUTO_CAST(close)
    close:SetText("×")
    close:SetEventScript(ui.LBUTTONUP, "cc_helper_settings_close")

    -- CHAT_SYSTEM("test")

    local sealslot = frame:CreateOrGetControl("slot", "sealslot", 210, 10, 50, 50)
    AUTO_CAST(sealslot)
    sealslot:SetSkinName("invenslot2")
    sealslot:SetText("{s14}SEAL")
    sealslot:EnablePop(1)
    sealslot:EnableDrag(1)
    sealslot:EnableDrop(1)
    sealslot:SetEventScript(ui.DROP, "cc_helper_onseal_drop")
    sealslot:SetEventScript(ui.RBUTTONDOWN, "cc_helper_cancel")
    -- print(tostring(g.settings.charid))
    -- CHAT_SYSTEM(g.sealiesid)
    if g.sealiesid ~= nil then
        local sealitem = GET_PC_ITEM_BY_GUID(tonumber(g.sealiesid));

        local sealitemobj = GetIES(sealitem:GetObject());

        SET_SLOT_IMG(sealslot, sealitemobj.Icon);

        SET_SLOT_IESID(sealslot, sealitem:GetIESID());

    end

    local arkslot = frame:CreateOrGetControl("slot", "arkslot", 210, 70, 50, 50)
    AUTO_CAST(arkslot)
    arkslot:SetSkinName("invenslot2")
    arkslot:SetText("{s14}ARK")
    arkslot:EnablePop(1)
    arkslot:EnableDrag(1)
    arkslot:EnableDrop(1)
    arkslot:SetEventScript(ui.DROP, "cc_helper_onark_drop")
    arkslot:SetEventScript(ui.RBUTTONDOWN, "cc_helper_cancel")

    if g.arkiesid ~= nil then
        local arkitem = GET_PC_ITEM_BY_GUID(tonumber(g.arkiesid));

        local arkitemobj = GetIES(arkitem:GetObject());

        SET_SLOT_IMG(arkslot, arkitemobj.Icon);

        SET_SLOT_IESID(arkslot, arkitem:GetIESID());

    end

    local agemslot = frame:CreateOrGetControl("slot", "agemslot", 210, 130, 50, 50)
    AUTO_CAST(agemslot)
    agemslot:SetSkinName("invenslot2")
    agemslot:SetText("{s14}AETHER GEM")
    agemslot:EnablePop(1)
    agemslot:EnableDrag(1)
    agemslot:EnableDrop(1)
    agemslot:SetEventScript(ui.DROP, "cc_helper_ongem_drop")
    agemslot:SetEventScript(ui.RBUTTONDOWN, "cc_helper_cancel")

    if g.gemid ~= nil then
        local itemCls = GetClassByType("Item", g.gemid)
        local gemicon = itemCls.Icon

        SET_SLOT_IMG(agemslot, gemicon);

    end

    local legcardslot = frame:CreateOrGetControl("slot", "legcardslot", 10, 50, 90, 130)
    AUTO_CAST(legcardslot)
    legcardslot:SetSkinName("legendopen_cardslot")
    legcardslot:SetText("{s14}LEGEND CARD")
    legcardslot:EnablePop(1)
    legcardslot:EnableDrag(1)
    legcardslot:EnableDrop(1)
    legcardslot:SetEventScript(ui.DROP, "cc_helper_on_legendcard_drop")
    legcardslot:SetEventScript(ui.RBUTTONDOWN, "cc_helper_cancel")

    if g.legiesid ~= nil then
        local legitem = GET_PC_ITEM_BY_GUID(tonumber(g.legiesid));

        local legitemobj = GetIES(legitem:GetObject());

        SET_SLOT_IMG(legcardslot, g.legimage)
        SET_SLOT_IESID(legcardslot, tonumber(g.legiesid));

    end

    local godcardslot = frame:CreateOrGetControl("slot", "godcardslot", 110, 50, 90, 130)
    AUTO_CAST(godcardslot)
    godcardslot:SetSkinName("goddess_card__activation")
    godcardslot:SetText("{s14}GODDESS CARD")
    godcardslot:EnablePop(1)
    godcardslot:EnableDrag(1)
    godcardslot:EnableDrop(1)
    godcardslot:SetEventScript(ui.DROP, "cc_helper_on_goddesscard_drop")
    godcardslot:SetEventScript(ui.RBUTTONDOWN, "cc_helper_cancel")

    if g.godiesid ~= nil then
        local goditem = GET_PC_ITEM_BY_GUID(tonumber(g.godiesid));

        local goditemobj = GetIES(goditem:GetObject());

        SET_SLOT_IMG(godcardslot, g.godimage)
        SET_SLOT_IESID(godcardslot, tonumber(g.godiesid));

    end

end

