-- v1.0.0 エーテルジェム対応
-- v1.0.1 シンプルモード搭載、搬入搬出速度見直し、終了時のメッセージタイミング見直し
-- v1.0.2　インベの表示微修正　print排除
-- v1.0.3 シンプルモード→エコモードに変更　エコモード時レジェカ外れない様に。チェックボックスをインベントリに移す
-- v1.0.4 エーテルジェムマネージャーとコラボ
-- v1.0.5 エーテルジェムマネージャーとコラボ見直し。ＩＮボタンをシームレスに
-- v1.0.6 縦長画面でのボタン位置修正。一部ツールチップ追加。
-- v1.0.7 インアウトボタンをチーム倉庫にも付けた。センス溢れるUIに。monstercard_changeのボタンもチーム倉庫に付けた。
local addonName = "CC_HELPER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.7"

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
    if not g.ischecked then
        g.ischecked = 0
    end

    if not g.loaded then
        g.loaded = true
    end

    local invframe = ui.GetFrame("inventory")

    local setbtn = invframe:CreateOrGetControl("button", "set", 230, 345, 30, 30)
    AUTO_CAST(setbtn)
    setbtn:SetSkinName("None")
    -- setbtn:SetImage("config_button_normal")
    setbtn:SetText("{img config_button_normal 30 30}")
    -- setbtn:Resize(30, 30)
    setbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_frame_init")
    setbtn:SetTextTooltip(
        "{@st59}マウス左ボタンクリック、キャラ毎に出し入れするアイテム設定。{nl}Left mouse button click, setting items to be moved in and out for each character.{/}")

    local eco = invframe:CreateOrGetControl("richtext", "eco", 210, 342)
    -- simplemode:SetText("{#FF0000}{s16}[CCH]SimpleMode on")
    eco:SetText("{#FF0000}{s10}Eco")

    local checkbox = invframe:CreateOrGetControl('checkbox', 'checkbox', 210, 350, 25, 25)
    AUTO_CAST(checkbox)
    checkbox:SetCheck(g.ischecked)
    checkbox:SetEventScript(ui.LBUTTONUP, "cc_helper_ischecked")
    checkbox:ShowWindow(1)
    checkbox:SetTextTooltip(
        "{@st59}チェックすると外すのにシルバーが必要なレジェンドカードとエーテルジェムの動作をスキップします。{nl}If checked, it skips the operation of legend cards and ether gems that require silver to remove.{/}")

    --[[local ecomode = invframe:CreateOrGetControl("richtext", "ecomode", 260, 355)
    -- simplemode:SetText("{#FF0000}{s16}[CCH]SimpleMode on")
    ecomode:SetText("{#FF0000}{s12}EcoMode")
    if g.ischecked == 1 and g.ischecked ~= nil then
        ecomode:ShowWindow(1)
    else
        ecomode:ShowWindow(0)
    end]]

    acutil.setupEvent(addon, "ACCOUNTWAREHOUSE_CLOSE", "CC_HELPER_ACCOUNTWAREHOUSE_CLOSE");
    addon:RegisterMsg("GAME_START_3SEC", "cc_helper_load_settings")
    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        -- addon:RegisterMsg("GAME_START", "cc_helper_invframe_init")
        addon:RegisterMsg("OPEN_DLG_ACCOUNTWAREHOUSE", "cc_helper_accountwarehouse_init")
    end

end

function CC_HELPER_ACCOUNTWAREHOUSE_CLOSE(frame)

    local invframe = ui.GetFrame("inventory")
    local inbtn = GET_CHILD_RECURSIVELY(invframe, "in")
    local outbtn = GET_CHILD_RECURSIVELY(invframe, "out")
    local uneqbtn = GET_CHILD_RECURSIVELY(invframe, "unequip")
    local eqbtn = GET_CHILD_RECURSIVELY(invframe, "g_equip")

    inbtn:ShowWindow(0)
    outbtn:ShowWindow(0)

end

function cc_helper_str(str)
    local langcode = option.GetCurrentCountry()

    if langcode == "Japanese" then
        if str == tostring("relese") then
            str = "解除"
        end
        if str == tostring("equip") then
            str = "装備"
        end

        return str
    end
    return str
end

function cc_helper_accountwarehouse_init()
    local awhframe = ui.GetFrame("accountwarehouse")

    local awh_inbtn = awhframe:CreateOrGetControl("button", "in", 545, 120, 40, 30)
    AUTO_CAST(awh_inbtn)
    awh_inbtn:SetText("{img in_arrow 20 20}") -- {@st66}
    awh_inbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_in_btn_aethergem_mgr")
    awh_inbtn:ShowWindow(1) -- test_pvp_btn
    awh_inbtn:SetSkinName("test_pvp_btn")
    awh_inbtn:SetTextTooltip(
        "{@st59}Character Change Helper{nl}装備を外して倉庫へ搬入します。{nl}The equipment is removed and brought into the warehouse.{/}")

    local awh_outbtn = awhframe:CreateOrGetControl("button", "out", 585, 120, 40, 30)
    AUTO_CAST(awh_outbtn)
    awh_outbtn:SetText("{@st66b}{img chul_arrow 20 20}")
    awh_outbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_out_btn")
    awh_outbtn:ShowWindow(1)
    awh_outbtn:SetSkinName("test_pvp_btn")
    awh_outbtn:SetTextTooltip(
        "{@st59}Character Change Helper{nl}倉庫から搬出して装備します。{nl}It is carried out from the warehouse and equipped.{/}")

    if _G.ADDONS.norisan.monstercard_change ~= nil then

        local mccbtn = awhframe:CreateOrGetControl("button", "mcc", 625, 120, 30, 30)
        AUTO_CAST(mccbtn)
        mccbtn:SetSkinName("test_red_button")
        mccbtn:SetTextAlign("right", "center")
        mccbtn:SetText("{img monsterbtn_image 30 20}{/}")
        mccbtn:SetTextTooltip(
            "{@st59}カード自動搬出入、自動着脱{nl}Automatic card loading/unloading, automatic insertion/removal{/}")
        mccbtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_MONSTERCARDPRESET_FRAME_OPEN")
    end

    cc_helper_invframe_init()
end

function cc_helper_invframe_init()
    local invframe = ui.GetFrame("inventory")

    local inbtn = invframe:CreateOrGetControl("button", "inv_in", 260, 345, 30, 30)
    AUTO_CAST(inbtn)
    inbtn:SetText("{img in_arrow 20 20}") -- {@st66}
    inbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_in_btn_aethergem_mgr")
    inbtn:ShowWindow(1) -- test_pvp_btn
    inbtn:SetSkinName("test_pvp_btn")
    inbtn:SetTextTooltip(
        "{@st59}Character Change Helper{nl}装備を外して倉庫へ搬入します。{nl}The equipment is removed and brought into the warehouse.{/}")

    local outbtn = invframe:CreateOrGetControl("button", "inv_out", 290, 345, 30, 30)
    AUTO_CAST(outbtn)
    outbtn:SetText("{@st66b}{img chul_arrow 20 20}")
    outbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_out_btn")
    outbtn:ShowWindow(1)
    outbtn:SetSkinName("test_pvp_btn")
    outbtn:SetTextTooltip(
        "{@st59}Character Change Helper{nl}倉庫から搬出して装備します。{nl}It is carried out from the warehouse and equipped.{/}")
    --[[local invframe = ui.GetFrame("inventory")
    local inventoryGbox = invframe:GetChild("inventoryGbox")
    -- ボタンの配置位置
    local inbtnX = inventoryGbox:GetWidth() - 261
    local inbtnY = inventoryGbox:GetHeight() - 614
    local inbtn = invframe:CreateOrGetControl("button", "in", 234, 345, 30, 30)
    AUTO_CAST(inbtn)
    inbtn:SetText("{s13}In")
    -- CHAT_SYSTEM(tostring(g.gemid))
    -- if g.gemid ~= nil then
    inbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_in_btn_aethergem_mgr")
    -- else
    --  inbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_in_btn")
    -- end
    inbtn:ShowWindow(1)

    local outbtnX = inventoryGbox:GetWidth() - 231
    local outbtnY = inventoryGbox:GetHeight() - 614
    local outbtn = invframe:CreateOrGetControl("button", "out", 265, 345, 30, 30)
    AUTO_CAST(outbtn)

    outbtn:SetText("{s13}Out")
    outbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_out_btn")
    outbtn:ShowWindow(1)

    local uneqbtn = GET_CHILD_RECURSIVELY(invframe, "unequip")
    local eqbtn = GET_CHILD_RECURSIVELY(invframe, "g_equip")
    uneqbtn:ShowWindow(0)
    eqbtn:ShowWindow(0)]]

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
    end

    local sealimage = g.settings.charid.sealimage[loginCharID]
    g.sealimage = nil
    if sealimage ~= nil then
        g.sealimage = sealimage
    end
    -- 
    local arkiesid = g.settings.charid.arkiesid[loginCharID]

    g.arkiesid = nil
    if arkiesid ~= nil then
        g.arkiesid = arkiesid
    end

    local arkimage = g.settings.charid.arkimage[loginCharID]
    g.arkimage = nil
    if arkimage ~= nil then
        g.arkimage = arkimage
    end

    local gemid = g.settings.charid.gemid[loginCharID]
    g.gemid = nil
    if gemid ~= nil then
        g.gemid = gemid
    end

    local legiesid = g.settings.charid.legiesid[loginCharID]
    g.legiesid = nil
    if legiesid ~= nil then
        g.legiesid = legiesid
    end

    local legimage = g.settings.charid.legimage[loginCharID]
    g.legimage = nil
    if legimage ~= nil then
        g.legimage = legimage
    end

    local godiesid = g.settings.charid.godiesid[loginCharID]
    g.godiesid = nil
    if godiesid ~= nil then
        g.godiesid = godiesid
    end

    local godimage = g.settings.charid.godimage[loginCharID]
    g.godimage = nil
    if godimage ~= nil then
        g.godimage = godimage
    end

    local legclassid = g.settings.charid.legclassid[loginCharID]
    g.legclassid = nil
    if legclassid ~= nil then
        g.legclassid = legclassid
    end

    local godclassid = g.settings.charid.godclassid[loginCharID]
    g.godclassid = nil
    if godclassid ~= nil then
        g.godclassid = godclassid
    end

end

function cc_helper_out_btn()
    g.agmin = 0
    local fromframe = ui.GetFrame("accountwarehouse")
    local invframe = ui.GetFrame("inventory")
    local invTab = GET_CHILD_RECURSIVELY(invframe, "inventype_Tab")
    invTab:SelectTab(1)

    if fromframe:IsVisible() == 1 then
        if g.sealiesid ~= nil then
            local seal = cc_helper_check_items_in_warehouse(g.sealiesid)
            if seal == true then
                session.ResetItemList()
                session.AddItemID(tonumber(g.sealiesid), 1)
                item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                    fromframe:GetUserIValue("HANDLE"))

                ReserveScript("cc_helper_out_btn()", 0.3)
                return
            end
        end

        if g.arkiesid ~= nil then
            local ark = cc_helper_check_items_in_warehouse(g.arkiesid)
            if ark == true then
                session.ResetItemList()
                session.AddItemID(tonumber(g.arkiesid), 1)
                item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                    fromframe:GetUserIValue("HANDLE"))
                ReserveScript("cc_helper_out_btn()", 0.3)
                return
            end
        end

        local cardTab = GET_CHILD_RECURSIVELY(invframe, "inventype_Tab")
        cardTab:SelectTab(4)

        if g.legiesid ~= nil and (g.ischecked == 0 or g.ischecked == nil) then
            local legcard = cc_helper_check_items_in_warehouse(g.legiesid)
            if legcard == true then
                session.ResetItemList()
                session.AddItemID(tonumber(g.legiesid), 1)
                item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                    fromframe:GetUserIValue("HANDLE"))
                ReserveScript("cc_helper_out_btn()", 0.3)
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
                ReserveScript("cc_helper_out_btn()", 0.3)
                return
            end

        end

    end
    cc_helper_equip()
end

function cc_helper_equip()

    local frame = ui.GetFrame("inventory")
    local sealitem = session.GetInvItemByGuid(tonumber(g.sealiesid));
    if sealitem ~= nil then
        local sealspot = "SEAL"
        ITEM_EQUIP(sealitem.invIndex, sealspot)

        frame:Invalidate();
        ReserveScript("cc_helper_equip()", 0.3)
        return
    end

    local arkitem = session.GetInvItemByGuid(tonumber(g.arkiesid));
    if arkitem ~= nil then
        local arkspot = "ARK"
        ITEM_EQUIP(arkitem.invIndex, arkspot)

        frame:Invalidate();

    end

    if g.legiesid ~= nil or g.godiesid ~= nil or g.gemid ~= nil then

        ReserveScript("cc_helper_card_equip()", 0.3)
        return
    else
        cc_helper_end_of_operation()
        return
        -- ui.SysMsg("[CCH]end of operation")
    end
end

function cc_helper_card_equip()

    local frame = ui.GetFrame("monstercardslot")

    local legcardslotset = GET_CHILD_RECURSIVELY(frame, "LEGcard_slotset")
    local legitem = session.GetInvItemByGuid(g.legiesid)
    local goditem = session.GetInvItemByGuid(g.godiesid)
    local legcardslot = 12
    local godcardslot = 13

    if legitem ~= nil or goditem ~= nil and frame:IsVisible() == 0 then
        MONSTERCARDSLOT_FRAME_OPEN()
    end

    if legitem ~= nil and (g.ischecked == 0 or g.ischecked == nil) then

        cc_helper_legcard_equip(legcardslot, g.legiesid)
        -- return

    elseif goditem ~= nil and g.ischecked == 0 then
        ReserveScript(string.format("cc_helper_legcard_equip(%d, '%s')", godcardslot, g.godiesid), 1.0)
        return
    elseif goditem ~= nil and g.ischecked == 1 then
        cc_helper_legcard_equip(godcardslot, g.godiesid)

    elseif legitem == nil and goditem == nil and g.ischecked == 1 or g.gemid == nil then
        MONSTERCARDSLOT_CLOSE()
        cc_helper_end_of_operation()
        -- ui.SysMsg("[CCH]end of operation")
        return
    elseif legitem == nil and goditem == nil and g.gemid ~= nil then
        ReserveScript("cc_helper_gem_to_account_warehouse()", 0.3)
        return
    else
        MONSTERCARDSLOT_CLOSE()
        cc_helper_end_of_operation()
        -- ui.SysMsg("[CCH]end of operation")
        return
    end
end

function cc_helper_legcard_equip(slotIndex, itemGuid)

    local argStr = string.format("%d#%s", slotIndex, tostring(itemGuid));
    pc.ReqExecuteTx("SCR_TX_EQUIP_CARD_SLOT", argStr);

    ReserveScript("cc_helper_card_equip()", 0.3)
    return

end

function cc_helper_gem_to_account_warehouse()
    -- CHAT_SYSTEM("cc_helper_gem_to_account_warehouse()")
    local fromframe = ui.GetFrame("accountwarehouse")

    if fromframe:IsVisible() == 1 then
        if g.gemid ~= nil then

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

                    if tostring(obj.ClassID) == tostring(g.gemid) then

                        session.ResetItemList()
                        session.AddItemID(tonumber(iesid), 1)
                        item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                            fromframe:GetUserIValue("HANDLE"))
                        ReserveScript("cc_helper_gem_to_account_warehouse()", 0.3)

                        return

                    end
                end
            end

            -- end
            MONSTERCARDSLOT_CLOSE()
            -- ReserveScript("cc_helper_end_of_operation()", 0.3)
            cc_helper_end_of_operation()
            return
        end
    end
    MONSTERCARDSLOT_CLOSE()
    -- ReserveScript("cc_helper_end_of_operation()", 0.3)
    cc_helper_end_of_operation()

end

function cc_helper_end_of_operation()
    local frame = ui.GetFrame("inventory")
    local allTab = GET_CHILD_RECURSIVELY(frame, "inventype_Tab")
    allTab:SelectTab(0)
    if g.agmin == 0 then
        if ADDONS.norisan.AETHERGEM_MGR ~= nil and (g.ischecked == 0 or g.ischecked == nil) then
            -- local frame = ui.GetFrame("inventory")
            if g.gemid ~= nil then
                local equipItemList = session.GetEquipItemList();
                local rh = GET_CHILD_RECURSIVELY(frame, "RH")
                local lh = GET_CHILD_RECURSIVELY(frame, "LH")
                local rh_sub = GET_CHILD_RECURSIVELY(frame, "RH_SUB")
                local lh_sub = GET_CHILD_RECURSIVELY(frame, "LH_SUB")

                local rh_icon = rh:GetIcon()
                local lh_icon = lh:GetIcon()
                local rh_sub_icon = rh_sub:GetIcon()
                local lh_sub_icon = lh_sub:GetIcon()

                if rh_icon ~= nil then
                    local rh_icon_info = rh_icon:GetInfo()
                    local rh_guid = rh_icon_info:GetIESID()

                    local itemCls = GetClassByType("Item", session.GetEquipItemByGuid(rh_guid).type);
                    local classID = itemCls.ClassID;
                    local equip_item = session.GetEquipItemByType(classID)
                    local gem = equip_item:GetEquipGemID(2)
                    -- gem 無い場合は0　ある場合はIES
                    -- cc_helper_end_of_operation()
                    -- CHAT_SYSTEM(tostring(gem))
                    if gem == 0 then

                        local msg = "Call Aethrgem Manager?"
                        local yes_scp = "AETHERGEM_MGR_GET_EQUIP()"
                        -- local no_scp = "cc_helper_in_btn()"
                        ui.MsgBox(msg, yes_scp, "None");

                        return
                    end
                    -- print(tostring(gem))
                elseif lh_icon ~= nil then
                    local lh_icon_info = lh_icon:GetInfo()
                    local lh_guid = lh_icon_info:GetIESID()

                    local itemCls = GetClassByType("Item", session.GetEquipItemByGuid(lh_guid).type);
                    local classID = itemCls.ClassID;
                    local equip_item = session.GetEquipItemByType(classID)
                    local gem = equip_item:GetEquipGemID(2)
                    if gem == 0 then

                        local msg = "Call Aethrgem Manager?"
                        local yes_scp = "AETHERGEM_MGR_GET_EQUIP()"
                        -- local no_scp = "cc_helper_in_btn()"
                        ui.MsgBox(msg, yes_scp, "None");

                        return

                    end
                elseif rh_sub_icon ~= nil then
                    local rh_sub_icon_info = lh_icon:GetInfo()
                    local rh_sub_guid = rh_sub_icon_info:GetIESID()

                    local itemCls = GetClassByType("Item", session.GetEquipItemByGuid(rh_sub_guid).type);
                    local classID = itemCls.ClassID;
                    local equip_item = session.GetEquipItemByType(classID)
                    local gem = equip_item:GetEquipGemID(2)
                    if gem == 0 then

                        local msg = "Call Aethrgem Manager?"
                        local yes_scp = "AETHERGEM_MGR_GET_EQUIP()"
                        -- local no_scp = "cc_helper_in_btn()"
                        ui.MsgBox(msg, yes_scp, "None");

                        return

                    end
                elseif lh_sub_icon ~= nil then
                    local lh_sub_icon_info = lh_icon:GetInfo()
                    local lh_sub_guid = lh_sub_icon_info:GetIESID()

                    local itemCls = GetClassByType("Item", session.GetEquipItemByGuid(lh_sub_guid).type);
                    local classID = itemCls.ClassID;
                    local equip_item = session.GetEquipItemByType(classID)
                    local gem = equip_item:GetEquipGemID(2)
                    if gem == 0 then

                        local msg = "Call Aethrgem Manager?"
                        local yes_scp = "AETHERGEM_MGR_GET_EQUIP()"
                        -- local no_scp = "cc_helper_in_btn()"
                        ui.MsgBox(msg, yes_scp, "None");

                        return

                    end
                end
            else
                ui.SysMsg("[CCH]end of operation")
                return
            end
        else
            ui.SysMsg("[CCH]end of operation")
            return
        end

        ui.SysMsg("[CCH]end of operation")
        return
    end
    ui.SysMsg("[CCH]end of operation")
    return
end

function cc_helper_check_items_in_warehouse(iesid)
    local item = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iesid)
    if item == nil then

        return false
    else

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
        g.settings.charid.sealiesid[tostring(loginCharID)] = nil
        g.settings.charid.sealimage[tostring(loginCharID)] = nil

        g.sealiesid = nil
        g.sealimage = nil

    end

    if ctrl:GetName() == tostring("arkslot") then
        g.settings.charid.arkiesid[tostring(loginCharID)] = nil
        g.settings.charid.arkimage[tostring(loginCharID)] = nil
        g.arkiesid = nil
        g.arkimage = nil
    end

    if ctrl:GetName() == tostring("agemslot") then
        g.settings.charid.gemid[tostring(loginCharID)] = nil
        g.gemid = nil

    end

    if ctrl:GetName() == tostring("legcardslot") then
        g.settings.charid.legiesid[tostring(loginCharID)] = nil
        g.settings.charid.legimage[tostring(loginCharID)] = nil
        g.settings.charid.legclassid[tostring(loginCharID)] = nil
        g.legiesid = nil
        g.legimage = nil
        g.legclassid = nil

    end

    if ctrl:GetName() == tostring("godcardslot") then
        g.settings.charid.godiesid[tostring(loginCharID)] = nil
        g.settings.charid.godimage[tostring(loginCharID)] = nil
        g.settings.charid.godclassid[tostring(loginCharID)] = nil
        g.godiesid = nil
        g.godimage = nil
        g.godclassid = nil
    end

    cc_helper_save_settings()

end

function cc_helper_on_legendcard_drop(frame, ctrl, argstr, argnum)

    local lifticon = ui.GetLiftIcon();
    local liftframe = ui.GetLiftFrame():GetTopParentFrame()
    local slot = tolua.cast(ctrl, 'ui::CSlot')
    local iconinfo = lifticon:GetInfo();
    local item = GET_PC_ITEM_BY_GUID(iconinfo:GetIESID());
    local legiesid = iconinfo:GetIESID()
    local itemobj = GetIES(item:GetObject());
    local legclassid = itemobj.ClassID
    local iesid = iconinfo:GetIESID()
    local type = itemobj.ClassType

    local cardobj = GetClassByType("Item", legclassid)
    if cardobj.CardGroupName ~= "LEG" then
        ui.SysMsg(ClMsg("ToEquipSameCardGroup"));
        return
    end
    local legimage = TryGetProp(cardobj, "TooltipImage", "None")

    SET_SLOT_IMG(ctrl, legimage)
    SET_SLOT_IESID(ctrl, item:GetIESID());
    cc_helper_enddrop(sealiesid, arkiesid, gemid, legiesid, legimage, godiesid, godimage, sealimage, arkimage,
        legclassid, godclassid)

end

function cc_helper_on_goddesscard_drop(frame, ctrl, argstr, argnum)

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

    local cardobj = GetClassByType("Item", godclassid)
    if cardobj.CardGroupName ~= "GODDESS" then
        ui.SysMsg(ClMsg("ToEquipSameCardGroup"));
        return
    end
    local godimage = TryGetProp(cardobj, "TooltipImage", "None")

    SET_SLOT_IMG(ctrl, godimage)
    SET_SLOT_IESID(ctrl, item:GetIESID());

    cc_helper_enddrop(sealiesid, arkiesid, gemid, legiesid, legimage, godiesid, godimage, sealimage, arkimage,
        legclassid, godclassid)

end

function cc_helper_onark_drop(frame, ctrl, argstr, argnum)

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
    local arkimage = TryGetProp(arkobj, "TooltipImage", "None")

    local itemcls = GetClassByType("Item", item.type);
    local enableTeamTrade = TryGetProp(itemcls, "TeamTrade");

    if enableTeamTrade ~= nil and enableTeamTrade == "NO" then
        ui.SysMsg(ClMsg("ItemIsNotTradable"));
        return;
    end

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

    local close = frame:CreateOrGetControl('button', 'close', 10, 10, 30, 30)
    AUTO_CAST(close)
    close:SetText("×")
    close:SetEventScript(ui.LBUTTONUP, "cc_helper_settings_close")

    local sealslot = frame:CreateOrGetControl("slot", "sealslot", 210, 70, 50, 50)
    AUTO_CAST(sealslot)
    sealslot:SetSkinName("invenslot2")
    sealslot:SetText("{s14}SEAL")
    sealslot:EnablePop(1)
    sealslot:EnableDrag(1)
    sealslot:EnableDrop(1)
    sealslot:SetEventScript(ui.DROP, "cc_helper_onseal_drop")
    sealslot:SetEventScript(ui.RBUTTONDOWN, "cc_helper_cancel")

    if g.sealiesid ~= nil then

        SET_SLOT_IMG(sealslot, g.sealimage);

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

        SET_SLOT_IMG(legcardslot, g.legimage)

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

    end

end

function cc_helper_ischecked()
    local frame = ui.GetFrame(addonNameLower)

    local invframe = ui.GetFrame("inventory")
    local checkbox = GET_CHILD_RECURSIVELY(invframe, "checkbox")
    local simplemode = GET_CHILD_RECURSIVELY(invframe, "ecomode")
    local ischeck = checkbox:IsChecked();

    if ischeck == 1 then
        g.ischecked = 1
        simplemode:ShowWindow(1)
        return
    else
        g.ischecked = 0
        simplemode:ShowWindow(0)

        return
    end

end

function cc_helper_in_btn_aethergem_mgr()
    -- CHAT_SYSTEM("TEST")
    g.agmin = 1
    local frame = ui.GetFrame("inventory")
    if ADDONS.norisan.AETHERGEM_MGR ~= nil then
        local equipItemList = session.GetEquipItemList();
        local rh = GET_CHILD_RECURSIVELY(frame, "RH")
        local lh = GET_CHILD_RECURSIVELY(frame, "LH")
        local rh_sub = GET_CHILD_RECURSIVELY(frame, "RH_SUB")
        local lh_sub = GET_CHILD_RECURSIVELY(frame, "LH_SUB")

        local rh_icon = rh:GetIcon()
        local lh_icon = lh:GetIcon()
        local rh_sub_icon = rh_sub:GetIcon()
        local lh_sub_icon = lh_sub:GetIcon()

        if rh_icon ~= nil then
            local rh_icon_info = rh_icon:GetInfo()
            local rh_guid = rh_icon_info:GetIESID()

            local itemCls = GetClassByType("Item", session.GetEquipItemByGuid(rh_guid).type);
            local classID = itemCls.ClassID;
            local equip_item = session.GetEquipItemByType(classID)
            local gem = equip_item:GetEquipGemID(2)
            -- gem 無い場合は0　ある場合はIES
            -- cc_helper_end_of_operation()
            -- CHAT_SYSTEM(tostring(gem))
            if tostring(gem) == tostring(g.gemid) then
                cc_helper_msgbox_frame()
                return
            end
            -- print(tostring(gem))
        elseif lh_icon ~= nil then
            local lh_icon_info = lh_icon:GetInfo()
            local lh_guid = lh_icon_info:GetIESID()

            local itemCls = GetClassByType("Item", session.GetEquipItemByGuid(lh_guid).type);
            local classID = itemCls.ClassID;
            local equip_item = session.GetEquipItemByType(classID)
            local gem = equip_item:GetEquipGemID(2)
            if tostring(gem) == tostring(g.gemid) then
                cc_helper_msgbox_frame()
                return
            end
        elseif rh_sub_icon ~= nil then
            local rh_sub_icon_info = lh_icon:GetInfo()
            local rh_sub_guid = rh_sub_icon_info:GetIESID()

            local itemCls = GetClassByType("Item", session.GetEquipItemByGuid(rh_sub_guid).type);
            local classID = itemCls.ClassID;
            local equip_item = session.GetEquipItemByType(classID)
            local gem = equip_item:GetEquipGemID(2)
            if tostring(gem) == tostring(g.gemid) then
                cc_helper_msgbox_frame()
                return
            end
        elseif lh_sub_icon ~= nil then
            local lh_sub_icon_info = lh_icon:GetInfo()
            local lh_sub_guid = lh_sub_icon_info:GetIESID()

            local itemCls = GetClassByType("Item", session.GetEquipItemByGuid(lh_sub_guid).type);
            local classID = itemCls.ClassID;
            local equip_item = session.GetEquipItemByType(classID)
            local gem = equip_item:GetEquipGemID(2)
            if tostring(gem) == tostring(g.gemid) then
                cc_helper_msgbox_frame()
                return
            else

                cc_helper_in_btn()
            end
        else

            cc_helper_in_btn()
        end
    else
        cc_helper_in_btn()
    end

    cc_helper_in_btn()
end

function cc_helper_msgbox_frame()
    --[[
    local cchframe = ui.GetFrame("cc_helper")
    cchframe:Resize(400, 140)
    cchframe:SetPos(980, 300)
    cchframe:SetTitleBarSkin("None")
    -- cchframe:SetSkinName("test_Item_tooltip_equip");
    -- cchframe:SetSkinName("market_listbase");
    cchframe:SetSkinName("test_frame_midle")

    -- cchframe:SetSkinName("bg");

    local text1 = cchframe:CreateOrGetControl('richtext', 'text1', 15, 20)
    AUTO_CAST(text1)
    text1:SetText("{#808080}{s16}{ol}Do you want to start Aethrgem Manager first?")
    local text2 = cchframe:CreateOrGetControl('richtext', 'text2', 25, 45)
    AUTO_CAST(text2)
    text2:SetText("{#808080}{s20}{ol}Aethrgem Manager 起動しますか？")

    local yesbtn = cchframe:CreateOrGetControl('button', 'yes', 115, 80, 80, 40)
    yesbtn:SetSkinName("test_red_button")
    yesbtn:SetText("{ol}YES")
    yesbtn:SetEventScript(ui.LBUTTONDOWN, "AETHERGEM_MGR_GET_EQUIP")
    yesbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_in_btn_strat")

    local nobtn = cchframe:CreateOrGetControl('button', 'no', 215, 80, 80, 40)
    nobtn:SetSkinName("test_gray_button")
    nobtn:SetText("{ol}NO")
    nobtn:SetEventScript(ui.LBUTTONDOWN, "cc_helper_in_btn")

    cchframe:ShowWindow(1)
    ]]
    local msg = "Do you want to start Aethrgem Manager first?"
    local yes_scp = "cc_helper_in_btn_strat()"
    local no_scp = "cc_helper_in_btn()"
    ui.MsgBox(msg, yes_scp, no_scp);

    -- ReserveScript("cc_helper_in_btn()", 2.5)

    return
end

function cc_helper_in_btn_strat()
    local cchframe = ui.GetFrame("cc_helper")
    cchframe:ShowWindow(0)
    AETHERGEM_MGR_GET_EQUIP()
    ReserveScript("cc_helper_in_btn()", 4.0)
end

function cc_helper_in_btn()
    -- CHAT_SYSTEM("test")
    local cchframe = ui.GetFrame("cc_helper")
    cchframe:ShowWindow(0)

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

    local frame = ui.GetFrame("inventory")

    local eqpTab = GET_CHILD_RECURSIVELY(frame, "inventype_Tab")
    eqpTab:SelectTab(1)

    local seal = GET_CHILD_RECURSIVELY(frame, "SEAL")

    local sealicon = seal:GetIcon()
    if sealicon ~= nil then

        local sealinfo = sealicon:GetInfo()
        if sealinfo ~= nil then

            local sealiesid = sealinfo:GetIESID()

            if sealiesid ~= nil and tostring(sealiesid) == tostring(g.sealiesid) then
                local sealindex = 25 -- スロットインデックスを適切な値に設定する必要があります
                item.UnEquip(sealindex)
                ReserveScript("cc_helper_unequip_ark()", 0.3)

                return;
            else
                ReserveScript("cc_helper_unequip_ark()", 0.3)
                return;
            end
        end
    else
        ReserveScript("cc_helper_unequip_ark()", 0.3)
        return;
    end

end

function cc_helper_unequip_ark()

    local frame = ui.GetFrame("inventory")
    local ark = GET_CHILD_RECURSIVELY(frame, "ARK")

    local arkicon = ark:GetIcon()

    if arkicon ~= nil then

        local arkinfo = arkicon:GetInfo()

        if arkinfo ~= nil then

            local arkiesid = arkinfo:GetIESID()

            if arkiesid ~= nil and tostring(arkiesid) == tostring(g.arkiesid) then

                local arkindex = 27 -- スロットインデックスを適切な値に設定する必要があります
                item.UnEquip(arkindex)

                ReserveScript("cc_helper_unequip_legcard()", 0.3)
                return;

            else

                ReserveScript("cc_helper_unequip_legcard()", 0.3)

                return;
            end
        end
    else

        ReserveScript("cc_helper_unequip_legcard()", 0.3)
        return;
    end

end

function cc_helper_unequip_legcard()

    local frame = ui.GetFrame("monstercardslot")

    local godcardslot = 14 -- レジェカを外すコード
    local godcardid = GETMYCARD_INFO(godcardslot - 1)
    local godcardInfo = equipcard.GetCardInfo(godcardslot);

    local legcardslotset = GET_CHILD_RECURSIVELY(frame, "LEGcard_slotset")
    local legcardslot = 13
    local legcardid = GETMYCARD_INFO(legcardslot - 1)
    local cardInfo = equipcard.GetCardInfo(legcardslot);

    if godcardInfo == nil and cardInfo == nil then
        local awframe = ui.GetFrame("accountwarehouse");
        if awframe:IsVisible() == 1 then
            ReserveScript("cc_helper_inv_to_warehouse()", 0.3)
            return
        else
            cc_helper_end_of_operation()
        end
    else
        MONSTERCARDSLOT_FRAME_OPEN()

        local invframe = ui.GetFrame("inventory")
        local cardTab = GET_CHILD_RECURSIVELY(invframe, "inventype_Tab")
        cardTab:SelectTab(4)
    end

    if cardInfo ~= nil and tostring(legcardid) == tostring(g.legclassid) and g.ischecked ~= 1 then

        local argStr = legcardslot - 1
        argStr = argStr .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
        pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)
        ReserveScript("cc_helper_unequip_godcard()", 1.0)
        return;

    end
    ReserveScript("cc_helper_unequip_godcard()", 0.3)
    return
end

function cc_helper_unequip_godcard()

    local frame = ui.GetFrame("monstercardslot")
    local godcardslot = 14 -- レジェカを外すコード
    local godcardid = GETMYCARD_INFO(godcardslot - 1)

    local cardInfo = equipcard.GetCardInfo(godcardslot);

    if cardInfo ~= nil and tostring(godcardid) == tostring(g.godclassid) then

        local argStr = godcardslot - 1
        argStr = argStr .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
        pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)
        MONSTERCARDSLOT_CLOSE()

    end
    MONSTERCARDSLOT_CLOSE()

    local awframe = ui.GetFrame("accountwarehouse");
    if awframe:IsVisible() == 1 then
        ReserveScript("cc_helper_inv_to_warehouse()", 0.3)
        return

    end
end

function cc_helper_inv_to_warehouse()

    local frame = ui.GetFrame("accountwarehouse");
    local fromFrame = ui.GetFrame("inventory");

    if frame:IsVisible() == 1 then
        local seal = session.GetInvItemByGuid(tonumber(g.sealiesid));
        local ark = session.GetInvItemByGuid(tonumber(g.arkiesid));
        local leg = session.GetInvItemByGuid(tonumber(g.legiesid));
        local god = session.GetInvItemByGuid(tonumber(g.godiesid));

        if seal ~= nil then
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.sealiesid, 1, nil, nil)
            ReserveScript("cc_helper_inv_to_warehouse()", 0.3)
            return
        elseif ark ~= nil then
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.arkiesid, 1, nil, nil)
            ReserveScript("cc_helper_inv_to_warehouse()", 0.3)
            return
        elseif leg ~= nil then
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.legiesid, 1, nil, nil)
            ReserveScript("cc_helper_inv_to_warehouse()", 0.3)
            return
        elseif god ~= nil then
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.godiesid, 1, nil, nil)
            ReserveScript("cc_helper_inv_to_warehouse()", 0.3)
            return

        else
            ReserveScript("cc_helper_gem_inv_to_warehouse()", 0.3)
            return
        end
    end
end

function cc_helper_gem_inv_to_warehouse()

    local frame = ui.GetFrame("accountwarehouse");
    local fromFrame = ui.GetFrame("inventory");

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

            if tostring(itemobj.ClassID) == tostring(g.gemid) then
                item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, iesid, 1, nil, nil)
                session.ResetItemList()
                ReserveScript("cc_helper_gem_inv_to_warehouse()", 0.3)
                -- break
                return
            end
            -- 
        end

    end
    cc_helper_end_of_operation()

end

