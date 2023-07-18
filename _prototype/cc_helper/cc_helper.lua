-- v1.0.0 エーテルジェム対応
local addonName = "CC_HELPER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

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
            sealimage = {},
            arkiesid = {},
            arkimage = {},
            gemid = {},
            legiesid = {},
            legimage = {},
            godiesid = {},
            godimage = {},
            legclassid = {},
            godclassid = {}

        }
    }
end

function CC_HELPER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    if not g.loaded then
        g.loaded = true
    end

    local invframe = ui.GetFrame("inventory")
    local inventoryGbox = invframe:GetChild("inventoryGbox")
    local setbtnX = inventoryGbox:GetWidth() - 200
    local setbtnY = inventoryGbox:GetHeight() - 290
    local setbtn = invframe:CreateOrGetControl("button", "set", setbtnX, setbtnY, 30, 30)
    AUTO_CAST(setbtn)
    setbtn:SetSkinName("None")
    setbtn:SetImage("config_button_normal")
    setbtn:Resize(30, 30)
    setbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_frame_init")
    -- cc_helper_load_settings()
    local uneqbtnX = inventoryGbox:GetWidth() - 287
    local uneqbtnY = inventoryGbox:GetHeight() - 290
    local uneqbtn = invframe:CreateOrGetControl("button", "unequip", uneqbtnX, uneqbtnY, 30, 30)
    AUTO_CAST(uneqbtn)
    uneqbtn:SetText("{s12}Remove")
    uneqbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_unequip_seal")
    -- uneqbtn:ShowWindow(1)

    local eqbtnX = inventoryGbox:GetWidth() - 232
    local eqbtnY = inventoryGbox:GetHeight() - 290
    local eqbtn = invframe:CreateOrGetControl("button", "g_equip", eqbtnX, eqbtnY, 30, 30)
    AUTO_CAST(eqbtn)
    eqbtn:SetText("{s12}Add")
    eqbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_equip")
    uneqbtn:ShowWindow(1)
    eqbtn:ShowWindow(1)

    print(addonNameLower .. " loaded")

    acutil.setupEvent(addon, "ACCOUNTWAREHOUSE_CLOSE", "CC_HELPER_ACCOUNTWAREHOUSE_CLOSE");

    -- acutil.setupEvent(addon, "CARD_SLOT_DROP", "CC_HELPER_CARD_SLOT_DROP");
    addon:RegisterMsg("GAME_START_3SEC", "cc_helper_load_settings")

    addon:RegisterMsg("OPEN_DLG_ACCOUNTWAREHOUSE", "cc_helper_invframe_init")

end

function CC_HELPER_ACCOUNTWAREHOUSE_CLOSE(frame)

    local invframe = ui.GetFrame("inventory")
    local inbtn = GET_CHILD_RECURSIVELY(invframe, "in")
    -- AUTO_CAST(inbtn)
    local outbtn = GET_CHILD_RECURSIVELY(invframe, "out")
    -- AUTO_CAST(outbtn)
    local uneqbtn = GET_CHILD_RECURSIVELY(invframe, "unequip")
    local eqbtn = GET_CHILD_RECURSIVELY(invframe, "g_equip")

    inbtn:ShowWindow(0)
    outbtn:ShowWindow(0)
    uneqbtn:ShowWindow(1)
    eqbtn:ShowWindow(1)

end

function cc_helper_invframe_init()
    local invframe = ui.GetFrame("inventory")
    local inventoryGbox = invframe:GetChild("inventoryGbox")
    -- ボタンの配置位置
    local inbtnX = inventoryGbox:GetWidth() - 285
    local inbtnY = inventoryGbox:GetHeight() - 290
    local inbtn = invframe:CreateOrGetControl("button", "in", inbtnX, inbtnY, 30, 30)
    AUTO_CAST(inbtn)
    inbtn:SetText("IN")
    inbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_in_btn")
    inbtn:ShowWindow(1)

    local outbtnX = inventoryGbox:GetWidth() - 252
    local outbtnY = inventoryGbox:GetHeight() - 290
    local outbtn = invframe:CreateOrGetControl("button", "out", outbtnX, outbtnY, 40, 30)
    AUTO_CAST(outbtn)

    outbtn:SetText("OUT")
    outbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_out_btn")

    outbtn:ShowWindow(1)

    local uneqbtn = GET_CHILD_RECURSIVELY(invframe, "unequip")
    local eqbtn = GET_CHILD_RECURSIVELY(invframe, "g_equip")
    uneqbtn:ShowWindow(0)
    eqbtn:ShowWindow(0)

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

    cc_helper_setting()

end

function cc_helper_setting()

    local loginCharID = info.GetCID(session.GetMyHandle())
    local sealiesid = g.settings.charid.sealiesid[loginCharID]
    g.sealiesid = nil
    if sealiesid ~= nil then
        g.sealiesid = sealiesid
        -- CHAT_SYSTEM(g.sealiesid)
    end

    local sealimage = g.settings.charid.sealimage[loginCharID]
    g.sealimage = nil
    if sealimage ~= nil then
        g.sealimage = sealimage
        -- CHAT_SYSTEM(g.sealimage)
    end
    -- 
    local arkiesid = g.settings.charid.arkiesid[loginCharID]

    g.arkiesid = nil
    if arkiesid ~= nil then
        g.arkiesid = arkiesid
        -- CHAT_SYSTEM(g.arkiesid)
    end

    local arkimage = g.settings.charid.arkimage[loginCharID]
    g.arkimage = nil
    if arkimage ~= nil then
        g.arkimage = arkimage
        -- CHAT_SYSTEM(g.arkimage)
    end
    -- 
    -- CHAT_SYSTEM(arkiesid)
    local gemid = g.settings.charid.gemid[loginCharID]
    g.gemid = nil
    if gemid ~= nil then
        g.gemid = gemid
        -- CHAT_SYSTEM(g.gemid)
    end
    -- 
    local legiesid = g.settings.charid.legiesid[loginCharID]
    g.legiesid = nil
    if legiesid ~= nil then
        g.legiesid = legiesid
        --  CHAT_SYSTEM(g.legiesid)
    end
    -- CHAT_SYSTEM(legiesid)
    local legimage = g.settings.charid.legimage[loginCharID]
    g.legimage = nil
    if legimage ~= nil then
        g.legimage = legimage
        -- CHAT_SYSTEM(g.legimage)
    end
    -- CHAT_SYSTEM(legimage)
    local godiesid = g.settings.charid.godiesid[loginCharID]
    g.godiesid = nil
    if godiesid ~= nil then
        g.godiesid = godiesid
        -- CHAT_SYSTEM(g.godiesid)
    end
    -- 
    -- CHAT_SYSTEM(godiesid)
    local godimage = g.settings.charid.godimage[loginCharID]
    g.godimage = nil
    if godimage ~= nil then
        g.godimage = godimage
        -- CHAT_SYSTEM(g.godimage)
    end

    local legclassid = g.settings.charid.legclassid[loginCharID]
    g.legclassid = nil
    if legclassid ~= nil then
        g.legclassid = legclassid
        -- CHAT_SYSTEM(g.legclassid)
    end

    local godclassid = g.settings.charid.godclassid[loginCharID]
    g.godclassid = nil
    if godclassid ~= nil then
        g.godclassid = godclassid
        -- CHAT_SYSTEM(g.godclassid)
    end

end

function cc_helper_out_btn()

    local fromframe = ui.GetFrame("accountwarehouse")

    if fromframe:IsVisible() == 1 then
        if g.sealiesid ~= nil then
            local seal = cc_helper_check_items_in_warehouse(g.sealiesid)
            if seal == true then
                session.ResetItemList()
                session.AddItemID(tonumber(g.sealiesid), 1)
                item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                                                fromframe:GetUserIValue("HANDLE"))

                ReserveScript("cc_helper_out_btn()", 0.5)
                return
            end -- return
        end

        if g.arkiesid ~= nil then
            local ark = cc_helper_check_items_in_warehouse(g.arkiesid)
            if ark == true then
                session.ResetItemList()
                session.AddItemID(tonumber(g.arkiesid), 1)
                item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                                                fromframe:GetUserIValue("HANDLE"))
                ReserveScript("cc_helper_out_btn()", 0.5)
                return
            end
        end

        if g.legiesid ~= nil then
            local legcard = cc_helper_check_items_in_warehouse(g.legiesid)
            if legcard == true then
                session.ResetItemList()
                session.AddItemID(tonumber(g.legiesid), 1)
                item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                                                fromframe:GetUserIValue("HANDLE"))
                ReserveScript("cc_helper_out_btn()", 0.5)
                return
            end
        end

        if g.godiesid ~= nil then
            local godcard = cc_helper_check_items_in_warehouse(g.godiesid)
            if godcard == true then
                session.ResetItemList()
                session.AddItemID(tonumber(g.godiesid), 1)
                item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                                                fromframe:GetUserIValue("HANDLE"))
                ReserveScript("cc_helper_out_btn()", 0.5)
                return
            end

        end

    end
    cc_helper_equip()
end

function cc_helper_equip()
    -- CHAT_SYSTEM("equip")
    local frame = ui.GetFrame("inventory")
    local sealitem = session.GetInvItemByGuid(tonumber(g.sealiesid));
    if sealitem ~= nil then
        local sealspot = "SEAL"
        ITEM_EQUIP(sealitem.invIndex, sealspot)

        frame:Invalidate();
        ReserveScript("cc_helper_equip()", 0.5)
        return
    end

    local arkitem = session.GetInvItemByGuid(tonumber(g.arkiesid));
    if arkitem ~= nil then
        local arkspot = "ARK"
        ITEM_EQUIP(arkitem.invIndex, arkspot)

        frame:Invalidate();
        -- ReserveScript("cc_helper_equip()", 0.5)
    end
    MONSTERCARDSLOT_FRAME_OPEN()
    ReserveScript("cc_helper_card_equip()", 0.5)
    return
end

function cc_helper_card_equip()

    local frame = ui.GetFrame("monstercardslot")

    local legcardslotset = GET_CHILD_RECURSIVELY(frame, "LEGcard_slotset")
    local legitem = session.GetInvItemByGuid(g.legiesid)
    local goditem = session.GetInvItemByGuid(g.godiesid)
    local legcardslot = 12
    local godcardslot = 13
    -- CHAT_SYSTEM(godcardslot)
    -- CHAT_SYSTEM(tostring(legcardslot))
    -- local groupNameStr = "LEG"
    if legitem ~= nil then
        cc_helper_legcard_equip(legcardslot, g.legiesid)
        return
    end
    if goditem ~= nil then
        ReserveScript(string.format("cc_helper_legcard_equip(%d, '%s')", godcardslot, g.godiesid), 1.0)
        return
    end
    ReserveScript("cc_helper_gem_to_account_warehouse()", 0.5)
    return
end

function cc_helper_legcard_equip(slotIndex, itemGuid)
    -- CHAT_SYSTEM("leg")
    local argStr = string.format("%d#%s", slotIndex, tostring(itemGuid));
    pc.ReqExecuteTx("SCR_TX_EQUIP_CARD_SLOT", argStr);
end

function cc_helper_gem_to_account_warehouse()
    local fromframe = ui.GetFrame("accountwarehouse")
    if fromframe:IsVisible() == 1 then
        if g.gemid ~= nil then

            local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
            local guidList = itemList:GetGuidList();
            local sortedGuidList = itemList:GetSortedGuidList();
            local sortedCnt = sortedGuidList:Count();
            for i = 0, sortedCnt - 1 do
                local guid = sortedGuidList:Get(i)
                local invItem = itemList:GetItemByGuid(guid)
                local iesid = invItem:GetIESID()
                -- print(tostring(iesid))
                local obj = GetIES(invItem:GetObject());
                if obj.ClassName ~= MONEY_NAME then
                    -- print(tostring(obj.ClassID))
                    if tostring(obj.ClassID) == tostring(g.gemid) then

                        session.ResetItemList()
                        session.AddItemID(tonumber(iesid), 1)
                        item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                                                        fromframe:GetUserIValue("HANDLE"))
                        ReserveScript("cc_helper_out_btn()", 0.5)
                        break
                        -- return

                    end
                end
            end
        else
            ReserveScript("MONSTERCARDSLOT_CLOSE()", 2.0)
            ui.SysMsg("[CCH]finish")
            return
        end
    end
    ui.SysMsg("[CCH]finish")
    return
end

function cc_helper_check_items_in_warehouse(iesid)
    local item = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iesid)
    if item == nil then
        -- CHAT_SYSTEM("Item with IESID " .. iesid .. " is nil")
        return false
    else
        -- CHAT_SYSTEM("Item with IESID " .. iesid .. " exists")
        return true
    end
end

function cc_helper_enddrop(sealiesid, arkiesid, gemid, legiesid, legimage, godiesid, godimage, sealimage, arkimage,
                           legclassid, godclassid)
    -- CHAT_SYSTEM("enddrop")
    local loginCharID = info.GetCID(session.GetMyHandle())
    if sealiesid ~= nil then
        g.settings.charid.sealiesid[tostring(loginCharID)] = sealiesid
    end
    if sealimage ~= nil then
        g.settings.charid.sealimage[tostring(loginCharID)] = sealimage
    end
    if arkiesid ~= nil then
        g.settings.charid.arkiesid[tostring(loginCharID)] = arkiesid
    end
    if arkimage ~= nil then
        g.settings.charid.arkimage[tostring(loginCharID)] = arkimage
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
    if legclassid ~= nil then
        g.settings.charid.legclassid[tostring(loginCharID)] = legclassid
    end
    if godclassid ~= nil then
        g.settings.charid.godclassid[tostring(loginCharID)] = godclassid
    end
    cc_helper_save_settings()
    cc_helper_setting()

end

function cc_helper_cancel(frame, ctrl, argstr, argnum)

    ctrl:ClearIcon()
    ctrl:SetMaxSelectCount(0)
    ctrl:RemoveAllChild()

    -- CHAT_SYSTEM(ctrl:GetName())
    local loginCharID = info.GetCID(session.GetMyHandle())

    if ctrl:GetName() == tostring("sealslot") then
        g.settings.charid.sealiesid[tostring(loginCharID)] = {}
        g.settings.charid.sealimage[tostring(loginCharID)] = {}
        g.sealiesid = nil
        g.sealimage = nil

    end

    if ctrl:GetName() == tostring("arkslot") then
        g.settings.charid.arkiesid[tostring(loginCharID)] = {}
        g.settings.charid.arkimage[tostring(loginCharID)] = {}
        g.arkiesid = nil
        g.arkimage = nil
    end

    if ctrl:GetName() == tostring("agemslot") then
        g.settings.charid.gemid[tostring(loginCharID)] = {}
        g.gemid = nil

    end

    if ctrl:GetName() == tostring("legcardslot") then
        g.settings.charid.legiesid[tostring(loginCharID)] = {}
        g.settings.charid.legimage[tostring(loginCharID)] = {}
        g.settings.charid.legclassid[tostring(loginCharID)] = {}
        g.legiesid = nil
        g.legimage = nil
        g.legclassid = nil

    end

    if ctrl:GetName() == tostring("godcardslot") then
        g.settings.charid.godiesid[tostring(loginCharID)] = {}
        g.settings.charid.godimage[tostring(loginCharID)] = {}
        g.settings.charid.godclassid[tostring(loginCharID)] = {}
        g.godiesid = nil
        g.godimage = nil
        g.godclassid = nil
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
    local legclassid = itemobj.ClassID
    -- CHAT_SYSTEM(tostring(legclassid))
    local iesid = iconinfo:GetIESID()
    local type = itemobj.ClassType

    local cardobj = GetClassByType("Item", legclassid)
    -- CHAT_SYSTEM(tostring(classid))
    -- CHAT_SYSTEM(cardobj.CardGroupName)
    if cardobj.CardGroupName ~= "LEG" then
        ui.SysMsg(ClMsg("ToEquipSameCardGroup"));
        return
    end
    local legimage = TryGetProp(cardobj, "TooltipImage", "None")

    SET_SLOT_IMG(ctrl, legimage)
    SET_SLOT_IESID(ctrl, item:GetIESID());
    cc_helper_enddrop(sealiesid, arkiesid, gemid, legiesid, legimage, godiesid, godimage, sealimage, arkimage,
                      legclassid, godclassid)
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
    local godclassid = itemobj.ClassID
    local iesid = iconinfo:GetIESID()
    local type = itemobj.ClassType
    -- CHAT_SYSTEM(godiesid)

    local cardobj = GetClassByType("Item", godclassid)
    -- CHAT_SYSTEM(cardobj.CardGroupName)
    if cardobj.CardGroupName ~= "GODDESS" then
        ui.SysMsg(ClMsg("ToEquipSameCardGroup"));
        return
    end
    local godimage = TryGetProp(cardobj, "TooltipImage", "None")

    SET_SLOT_IMG(ctrl, godimage)
    SET_SLOT_IESID(ctrl, item:GetIESID());

    cc_helper_enddrop(sealiesid, arkiesid, gemid, legiesid, legimage, godiesid, godimage, sealimage, arkimage,
                      legclassid, godclassid)
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
    local arkobj = GetClassByType("Item", classid)
    -- local cardobj = GetClassByType("Item", classid)
    -- local arkimage = iconinfo:GetImageName()
    local arkimage = TryGetProp(arkobj, "TooltipImage", "None")

    local itemcls = GetClassByType("Item", item.type);
    local enableTeamTrade = TryGetProp(itemcls, "TeamTrade");
    -- CHAT_SYSTEM(enableTeamTrade)
    if enableTeamTrade ~= nil and enableTeamTrade == "NO" then
        ui.SysMsg(ClMsg("ItemIsNotTradable"));
        return;
    end
    -- IS_ENABLE_TRADE_BY_TRADE_TYPE(item, property)

    -- Arkのチームトレードの可否を調べるコードがわからん--わかった
    if ctrl == GET_CHILD_RECURSIVELY(frame, "arkslot") then
        if type == "Ark" then
            if TryGetProp(itemobj, 'CharacterBelonging', 0) == 1 then
                ui.SysMsg(ClMsg("ItemIsNotTradable"));
                return;
            end
            SET_SLOT_IMG(slot, itemobj.Icon);
            SET_SLOT_IESID(slot, item:GetIESID());
            local arkiesid = iconinfo:GetIESID()
            cc_helper_enddrop(sealiesid, arkiesid, gemid, legiesid, legimage, godiesid, godimage, sealimage, arkimage)
        else
            ui.SysMsg("Drop it in the correct slot.")
        end
    end

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
    local sealobj = GetClassByType("Item", classid)
    local sealiesid = item:GetIESID()

    local sealimage = TryGetProp(sealobj, "TooltipImage", "None")
    --  CHAT_SYSTEM(sealimage)

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
    cc_helper_enddrop(sealiesid, arkiesid, gemid, legiesid, legimage, godiesid, godimage, sealimage, arkimage)

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
            cc_helper_enddrop(sealiesid, arkiesid, gemid, legiesid, legimage, godiesid, godimage, sealimage, arkimage)
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

    local title = frame:CreateOrGetControl("richtext", "title", 45, 15)
    title:SetText("{#000000}{s20}CC Helper")

    -- CHAT_SYSTEM("TEST")
    local close = frame:CreateOrGetControl('button', 'close', 10, 10, 30, 30)
    AUTO_CAST(close)
    close:SetText("×")
    close:SetEventScript(ui.LBUTTONUP, "cc_helper_settings_close")

    -- CHAT_SYSTEM("test")

    local sealslot = frame:CreateOrGetControl("slot", "sealslot", 210, 70, 50, 50)
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

        SET_SLOT_IMG(sealslot, g.sealimage);
        -- CHAT_SYSTEM("test3")

    end

    local arkslot = frame:CreateOrGetControl("slot", "arkslot", 210, 130, 50, 50)
    AUTO_CAST(arkslot)
    arkslot:SetSkinName("invenslot2")
    arkslot:SetText("{s14}ARK")
    arkslot:EnablePop(1)
    arkslot:EnableDrag(1)
    arkslot:EnableDrop(1)
    arkslot:SetEventScript(ui.DROP, "cc_helper_onark_drop")
    arkslot:SetEventScript(ui.RBUTTONDOWN, "cc_helper_cancel")

    if g.arkiesid ~= nil then
        SET_SLOT_IMG(arkslot, g.arkimage);

    end

    local agemslot = frame:CreateOrGetControl("slot", "agemslot", 210, 10, 50, 50)
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

    if g.legimage ~= nil then
        -- CHAT_SYSTEM(g.legiesid)

        -- local itemCls = GetClassByType("Item", g.legiesid)

        SET_SLOT_IMG(legcardslot, g.legimage)

        -- SET_SLOT_IESID(legcardslot, tonumber(g.legiesid));

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

    if g.godimage ~= nil then

        SET_SLOT_IMG(godcardslot, g.godimage)
        -- SET_SLOT_IESID(godcardslot, tonumber(g.godiesid));

    end

end

function cc_helper_in_btn()
    -- CHAT_SYSTEM("click")
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
            cc_helper_unequip_seal()
            return

        end
    else
        ui.SysMsg(ScpArgMsg("Auto_inBenToLie_Bin_SeulLosi_PilyoHapNiDa."))
    end
end

function cc_helper_unequip_seal()
    -- CHAT_SYSTEM("cc_helper_unequip_seal")
    local frame = ui.GetFrame("inventory")
    local seal = GET_CHILD_RECURSIVELY(frame, "SEAL")
    --  CHAT_SYSTEM("cc_helper_unequip_seal-1")
    local sealicon = seal:GetIcon()
    if sealicon ~= nil then
        -- CHAT_SYSTEM("cc_helper_unequip_seal-2")
        local sealinfo = sealicon:GetInfo()
        if sealinfo ~= nil then
            --   CHAT_SYSTEM("cc_helper_unequip_seal-3")
            local sealiesid = sealinfo:GetIESID()
            -- CHAT_SYSTEM("cc_helper_unequip_seal-4")
            if sealiesid ~= nil and tostring(sealiesid) == tostring(g.sealiesid) then
                local sealindex = 25 -- スロットインデックスを適切な値に設定する必要があります
                item.UnEquip(sealindex)
                ReserveScript("cc_helper_unequip_ark()", 0.5)
                -- frame:RunUpdateScript(cc_helper_unequip_ark(frame), 1.0)
                return;
            else
                ReserveScript("cc_helper_unequip_ark()", 0.5)
                return;
            end
        end
    else
        ReserveScript("cc_helper_unequip_ark()", 0.5)
        return;
    end

end

function cc_helper_unequip_ark()
    --  CHAT_SYSTEM("cc_helper_unequip_ark-0")
    local frame = ui.GetFrame("inventory")
    local ark = GET_CHILD_RECURSIVELY(frame, "ARK")
    --  CHAT_SYSTEM("cc_helper_unequip_ark-1")
    local arkicon = ark:GetIcon()

    if arkicon ~= nil then
        --  CHAT_SYSTEM("cc_helper_unequip_ark-2")
        local arkinfo = arkicon:GetInfo()

        if arkinfo ~= nil then
            --   CHAT_SYSTEM("cc_helper_unequip_ark-3")
            local arkiesid = arkinfo:GetIESID()
            --  CHAT_SYSTEM("cc_helper_unequip_ark-4")
            if arkiesid ~= nil and tostring(arkiesid) == tostring(g.arkiesid) then
                -- print("ark")
                local arkindex = 27 -- スロットインデックスを適切な値に設定する必要があります
                item.UnEquip(arkindex)
                -- MONSTERCARDSLOT_FRAME_OPEN()
                ReserveScript("cc_helper_unequip_legcard()", 0.5)
                return;
                -- 
                -- frame:StopUpdateScript(cc_helper_unequip_ark(frame))
            else
                -- MONSTERCARDSLOT_FRAME_OPEN()
                ReserveScript("cc_helper_unequip_legcard()", 0.5)
                -- cc_helper_unequip_legcard()
                return;
            end
        end
    else
        -- MONSTERCARDSLOT_FRAME_OPEN()
        ReserveScript("cc_helper_unequip_legcard()", 0.5)
        return;
    end
    -- CHAT_SYSTEM("cc_helper_unequip_ark-1")

    -- ReserveScript("cc_helper_unequip_legcard()", 0.5)

    -- ReserveScript("MONSTERCARDSLOT_FRAME_OPEN()", 0.5)
end

function cc_helper_unequip_legcard()
    -- CHAT_SYSTEM("cc_helper_unequip_legcard")
    MONSTERCARDSLOT_FRAME_OPEN()

    local frame = ui.GetFrame("monstercardslot")
    -- frame:ShowWindow(0)
    local legcardslotset = GET_CHILD_RECURSIVELY(frame, "LEGcard_slotset")

    local legcardslot = 13

    local legcardid = GETMYCARD_INFO(legcardslot - 1)
    -- print(tostring(legcardid))
    local cardInfo = equipcard.GetCardInfo(legcardslot);

    if cardInfo ~= nil and tostring(legcardid) == tostring(g.legclassid) then
        -- CHAT_SYSTEM("legaru")

        -- レジェカを外すコード
        local argStr = legcardslot - 1
        argStr = argStr .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
        pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)
        ReserveScript("cc_helper_unequip_godcard()", 1.0)
        return;

    end
    ReserveScript("cc_helper_unequip_godcard()", 1.0)
    return
end

function cc_helper_unequip_godcard()
    --  CHAT_SYSTEM("cc_helper_unequip_godcard")
    local frame = ui.GetFrame("monstercardslot")
    local godcardslot = 14 -- レジェカを外すコード
    local godcardid = GETMYCARD_INFO(godcardslot - 1)
    --   CHAT_SYSTEM(tostring(godcardid))
    local cardInfo = equipcard.GetCardInfo(godcardslot);

    if cardInfo ~= nil and tostring(godcardid) == tostring(g.godclassid) then
        --  CHAT_SYSTEM("godaru")

        -- レジェカを外すコード
        local argStr = godcardslot - 1
        argStr = argStr .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
        pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)
        MONSTERCARDSLOT_CLOSE()

        -- return;
    else
        MONSTERCARDSLOT_CLOSE()
    end
    MONSTERCARDSLOT_CLOSE()

    local awframe = ui.GetFrame("accountwarehouse");
    if awframe:IsVisible() == 1 then
        ReserveScript("cc_helper_inv_to_warehouse()", 1.0)
        return
    else
        return
    end
end

function cc_helper_inv_to_warehouse()
    -- CHAT_SYSTEM("test")
    local frame = ui.GetFrame("accountwarehouse");
    local fromFrame = ui.GetFrame("inventory");

    if frame:IsVisible() == 1 then
        local seal = session.GetInvItemByGuid(tonumber(g.sealiesid));
        local ark = session.GetInvItemByGuid(tonumber(g.arkiesid));
        local leg = session.GetInvItemByGuid(tonumber(g.legiesid));
        local god = session.GetInvItemByGuid(tonumber(g.godiesid));

        -- CHAT_SYSTEM("start")
        -- CHAT_SYSTEM(tostring(seal))
        if seal ~= nil then
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.sealiesid, 1, nil, nil)
            ReserveScript("cc_helper_inv_to_warehouse()", 0.5)
            return
        elseif ark ~= nil then
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.arkiesid, 1, nil, nil)
            ReserveScript("cc_helper_inv_to_warehouse()", 0.5)
            return
        elseif leg ~= nil then
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.legiesid, 1, nil, nil)
            ReserveScript("cc_helper_inv_to_warehouse()", 0.5)
            return
        elseif god ~= nil then
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.godiesid, 1, nil, nil)
            ReserveScript("cc_helper_inv_to_warehouse()", 0.5)
            return

        else
            ReserveScript("cc_helper_gem_inv_to_warehouse()", 0.5)
            return
        end
    end
end

function cc_helper_gem_inv_to_warehouse()

    local frame = ui.GetFrame("accountwarehouse");
    local fromFrame = ui.GetFrame("inventory");
    if frame:IsVisible() == 1 then
        local invItemList = session.GetInvItemList()
        local guidList = invItemList:GetGuidList();
        local cnt = guidList:Count();
        -- print(tostring(invItemCount))
        for i = 0, cnt - 1 do
            local guid = guidList:Get(i);
            local invItem = invItemList:GetItemByGuid(guid)
            local itemobj = GetIES(invItem:GetObject())
            local iesid = invItem:GetIESID()
            -- print(tostring(iesid))
            if tostring(itemobj.ClassID) == tostring(g.gemid) then
                item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, iesid, 1, nil, nil)
                session.ResetItemList()
                ReserveScript("cc_helper_gem_inv_to_warehouse()", 0.5)
                break
                -- return
            end

        end
    end
    ui.SysMsg("[CCH]finish")
end
--[[
function CC_helper_isItemInWarehouse()
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetSortedGuidList();
    local sortedCnt = sortedGuidList:Count();
    for i = 0, sortedCnt - 1 do
        local guid = sortedGuidList:Get(i)
        local invItem = itemList:GetItemByGuid(guid)
        local obj = GetIES(invItem:GetObject());
        if obj.ClassName ~= MONEY_NAME then
            if obj.ClassID == g.gemid then
                return true
            else
                return false
            end
        end
    end
end
]]
