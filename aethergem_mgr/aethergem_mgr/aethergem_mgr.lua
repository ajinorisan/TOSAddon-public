-- v1.0.3 waitの時間見直し
-- v1.0.4 チーム倉庫開いている時の挙動見直し
-- ｖ1.0.5　インベ表示微修正
local addonName = "AETHERGEM_MGR"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.5"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")

if not g.loaded then
    g.settings = {
        pctbl = {}
        -- gemguid = {}
    }
end

function AETHERGEM_MGR_SAVE_SETTINGS(gemid)

    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function AETHERGEM_MGR_LOADSETTINGS(gemid)

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not settings then

        settings = g.settings
    end

    local loginCharID = info.GetCID(session.GetMyHandle())

    if g.settings.pctbl == nil then
        g.settings.pctbl = {}
    end

    if settings.pctbl[tostring(loginCharID)] ~= gemid and gemid ~= nil then
        local newTable = {
            [tostring(loginCharID)] = gemid
        }

        -- 新しいテーブルの内容をg.settings.pctblにマージする
        for k, v in pairs(newTable) do
            settings.pctbl[k] = v
        end

        AETHERGEM_MGR_SAVE_SETTINGS()
    end

    g.gemid = nil
    for charID, id in pairs(g.settings.pctbl) do
        if charID == tostring(loginCharID) then

            g.gemid = id

            break
        end
    end
    AETHERGEM_MGR_SAVE_SETTINGS()
end

function AETHERGEM_MGR_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    -- CHAT_SYSTEM(addonNameLower .. " loaded")
    acutil.setupHook(AETHERGEM_MGR_GODDESS_MGR_SOCKET_INV_RBTN, "GODDESS_MGR_SOCKET_INV_RBTN")
    -- acutil.setupHook(AETHERGEM_MGR_INVENTORY_RBDC_ITEMUSE, "INVENTORY_RBDC_ITEMUSE")
    -- acutil.setupHook(AETHERGEM_MGR_INVENTORY_ON_MSG, "INVENTORY_ON_MSG")
    -- acutil.setupHook(AETHERGEM_MGR_test, "GODDESS_MGR_SOCKET_AETHER_GEM_EQUIP")

    local loginCharID = info.GetCID(session.GetMyHandle())
    g.gemid = nil
    AETHERGEM_MGR_LOADSETTINGS(gemid)
    for charID, id in pairs(g.settings.pctbl) do
        if charID == tostring(loginCharID) then
            g.gemid = id
            break
        end
    end

    g.RH = nil
    g.LH = nil
    g.RH_SUB = nil
    g.LH_SUB = nil

    g.rh_icon = nil
    g.lh_icon = nil
    g.rh_sub_icon = nil
    g.lh_sub_icon = nil

    g.rh_icon_info = nil
    g.rh_guid = nil

    g.lh_icon_info = nil
    g.lh_guid = nil

    g.rh_sub_icon_info = nil
    g.rh_sub_guid = nil

    g.lh_sub_icon_info = nil
    g.lh_sub_guid = nil

    -- local channel = ui.GetFrame("channel")
    -- local channeltext = GET_CHILD_RECURSIVELY(channel, "curchannel")
    -- channeltext:SetOffset(50, 0)
    AETHERGEM_MGR_FRAME_INIT()

end

function AETHERGEM_MGR_GET_EQUIP()
    local eqpframe = ui.GetFrame("inventory")
    local equipItemList = session.GetEquipItemList();

    -- CHAT_SYSTEM("GETSTART")

    g.RH = GET_CHILD_RECURSIVELY(eqpframe, "RH")
    g.LH = GET_CHILD_RECURSIVELY(eqpframe, "LH")
    g.RH_SUB = GET_CHILD_RECURSIVELY(eqpframe, "RH_SUB")
    g.LH_SUB = GET_CHILD_RECURSIVELY(eqpframe, "LH_SUB")

    g.rh_icon = g.RH:GetIcon()
    if g.rh_icon ~= nil then
        -- g.rh_icon_name = g.rh_icon:GetName()
        g.rh_icon_info = g.rh_icon:GetInfo()
        g.rh_guid = g.rh_icon_info:GetIESID()

    end

    g.lh_icon = g.LH:GetIcon()
    if g.lh_icon ~= nil then
        g.lh_icon_info = g.lh_icon:GetInfo()
        g.lh_guid = g.lh_icon_info:GetIESID()

    end

    g.rh_sub_icon = g.RH_SUB:GetIcon()
    if g.rh_sub_icon ~= nil then
        g.rh_sub_icon_info = g.rh_sub_icon:GetInfo()
        g.rh_sub_guid = g.rh_sub_icon_info:GetIESID()

    end

    g.lh_sub_icon = g.LH_SUB:GetIcon()
    if g.lh_sub_icon ~= nil then
        g.lh_sub_icon_info = g.lh_sub_icon:GetInfo()
        g.lh_sub_guid = g.lh_sub_icon_info:GetIESID()

    end
    -- CHAT_SYSTEM("GETEND")
    AETHERGEM_MGR_UNEQUIP()
end

function AETHERGEM_MGR_UNEQUIP()

    local eqpframe = ui.GetFrame("inventory")

    if true == BEING_TRADING_STATE() then
        return;
    end

    local isEmptySlot = false;

    if session.GetInvItemList():Count() < MAX_INV_COUNT then
        isEmptySlot = true;
    end

    local frame = ui.GetFrame("goddess_equip_manager")
    local main_tab = GET_CHILD_RECURSIVELY(frame, 'main_tab')
    main_tab:SelectTab(2)

    if isEmptySlot == true then

        if tonumber(USE_SUBWEAPON_SLOT) == 1 then
            DO_WEAPON_SLOT_CHANGE(eqpframe, 1)
        else
            DO_WEAPON_SWAP(eqpframe, 1)
        end

        if g.lh_sub_icon ~= nil then
            local lhlh_sub = 31

            -- CHAT_SYSTEM("lh_sub_icon")

            imcSound.PlaySoundEvent('inven_unequip');
            item.UnEquip(tonumber(lhlh_sub));

            g.lh_sub_icon = nil
            ReserveScript("AETHERGEM_MGR_UNEQUIP()", 0.6)

            -- ReserveScript("AETHERGEM_MGR_REMOVE_OR_EQUIP()", 0.2)
            -- return

        elseif g.lh_icon ~= nil then
            local lh = 9

            imcSound.PlaySoundEvent('inven_unequip');
            item.UnEquip(tonumber(lh));
            g.lh_icon = nil
            ReserveScript("AETHERGEM_MGR_UNEQUIP()", 0.6)

        elseif g.rh_icon ~= nil then
            local rh = 8

            imcSound.PlaySoundEvent('inven_unequip');
            item.UnEquip(tonumber(rh));
            g.rh_icon = nil
            ReserveScript("AETHERGEM_MGR_UNEQUIP()", 0.6)

        else
            if g.rh_guid ~= nil and g.lh_guid ~= nil and g.rh_sub_guid ~= nil and g.lh_sub_guid ~= nil and g.rh_icon ==
                nil and g.lh_icon == nil and g.rh_icon_sub == nil and g.lh_icon_sub == nil then
                local inv_item = session.GetInvItemByGuid(g.rh_guid)
                if inv_item == nil then

                    return
                end
                local item_obj = GetIES(inv_item:GetObject())
                if item_obj == nil then

                    return
                end
                GODDESS_MGR_SOCKET_REG_ITEM(frame, inv_item, item_obj)
                -- AETHERGEM_MGR_GODDESS_MGR_SOCKET_AETHER_UPDATE(frame)
                GODDESS_MGR_SOCKET_AETHER_UPDATE(frame)
                -- AETHERGEM_MGR_REMOVE_AETHERGEM()
                AETHERGEM_MGR_REMOVE_OR_EQUIP()

            elseif g.rh_guid == nil and g.lh_guid ~= nil and g.rh_sub_guid ~= nil and g.lh_sub_guid ~= nil and g.rh_icon ==
                nil and g.lh_icon == nil and g.rh_icon_sub == nil and g.lh_icon_sub == nil then
                local inv_item = session.GetInvItemByGuid(g.lh_guid)
                if inv_item == nil then

                    return
                end
                local item_obj = GetIES(inv_item:GetObject())
                if item_obj == nil then

                    return
                end
                GODDESS_MGR_SOCKET_REG_ITEM(frame, inv_item, item_obj)
                -- AETHERGEM_MGR_GODDESS_MGR_SOCKET_AETHER_UPDATE(frame)
                GODDESS_MGR_SOCKET_AETHER_UPDATE(frame)
                -- AETHERGEM_MGR_REMOVE_AETHERGEM()
                AETHERGEM_MGR_REMOVE_OR_EQUIP()

            elseif g.rh_guid == nil and g.lh_guid == nil and g.rh_sub_guid ~= nil and g.lh_sub_guid ~= nil and g.rh_icon ==
                nil and g.lh_icon == nil and g.rh_icon_sub == nil and g.lh_icon_sub == nil then
                local inv_item = session.GetInvItemByGuid(g.rh_sub_guid)
                if inv_item == nil then

                    return
                end
                local item_obj = GetIES(inv_item:GetObject())
                if item_obj == nil then

                    return
                end
                GODDESS_MGR_SOCKET_REG_ITEM(frame, inv_item, item_obj)
                -- AETHERGEM_MGR_GODDESS_MGR_SOCKET_AETHER_UPDATE(frame)
                GODDESS_MGR_SOCKET_AETHER_UPDATE(frame)
                -- AETHERGEM_MGR_REMOVE_AETHERGEM()
                AETHERGEM_MGR_REMOVE_OR_EQUIP()

            elseif g.rh_guid == nil and g.lh_guid == nil and g.rh_sub_guid == nil and g.lh_sub_guid ~= nil and g.rh_icon ==
                nil and g.lh_icon == nil and g.rh_icon_sub == nil and g.lh_icon_sub == nil then
                local inv_item = session.GetInvItemByGuid(g.lh_sub_guid)
                if inv_item == nil then

                    return
                end
                local item_obj = GetIES(inv_item:GetObject())
                if item_obj == nil then

                    return
                end
                GODDESS_MGR_SOCKET_REG_ITEM(frame, inv_item, item_obj)
                -- AETHERGEM_MGR_GODDESS_MGR_SOCKET_AETHER_UPDATE(frame)
                GODDESS_MGR_SOCKET_AETHER_UPDATE(frame)
                -- AETHERGEM_MGR_REMOVE_AETHERGEM()
                AETHERGEM_MGR_REMOVE_OR_EQUIP()

                -- return;
            else
                return;
            end
        end
    else
        ui.SysMsg(ScpArgMsg("Auto_inBenToLie_Bin_SeulLosi_PilyoHapNiDa."))
    end

end

function AETHERGEM_MGR_SET_EQUIP()

    if g.rh_guid ~= nil and g.lh_guid ~= nil and g.rh_sub_guid ~= nil and g.lh_sub_guid ~= nil and g.rh_icon == nil and
        g.lh_icon == nil and g.rh_icon_sub == nil and g.lh_icon_sub == nil then
        local frame = ui.GetFrame("inventory")

        local invitem = session.GetInvItemByGuid(g.rh_guid);

        local spotname = "RH"

        ITEM_EQUIP(invitem.invIndex, spotname)

        frame:Invalidate();
        g.rh_guid = nil

        ReserveScript("AETHERGEM_MGR_UNEQUIP()", 0.6)

    elseif g.rh_guid == nil and g.lh_guid ~= nil and g.rh_sub_guid ~= nil and g.lh_sub_guid ~= nil and g.rh_icon == nil and
        g.lh_icon == nil and g.rh_icon_sub == nil and g.lh_icon_sub == nil then

        local frame = ui.GetFrame("inventory")

        local invitem = session.GetInvItemByGuid(g.lh_guid);

        local spotname = "LH"

        ITEM_EQUIP(invitem.invIndex, spotname)

        frame:Invalidate();
        g.lh_guid = nil

        ReserveScript("AETHERGEM_MGR_UNEQUIP()", 0.6)

    elseif g.rh_guid == nil and g.lh_guid == nil and g.rh_sub_guid ~= nil and g.lh_sub_guid ~= nil and g.rh_icon == nil and
        g.lh_icon == nil and g.rh_icon_sub == nil and g.lh_icon_sub == nil then

        local frame = ui.GetFrame("inventory")

        local invitem = session.GetInvItemByGuid(g.rh_sub_guid);

        local spotname = "RH_SUB"

        ITEM_EQUIP(invitem.invIndex, spotname)

        frame:Invalidate();
        g.rh_sub_guid = nil

        ReserveScript("AETHERGEM_MGR_UNEQUIP()", 0.6)

    elseif g.rh_guid == nil and g.lh_guid == nil and g.rh_sub_guid == nil and g.lh_sub_guid ~= nil and g.rh_icon == nil and
        g.lh_icon == nil and g.rh_icon_sub == nil and g.lh_icon_sub == nil then

        local frame = ui.GetFrame("inventory")

        local invitem = session.GetInvItemByGuid(g.lh_sub_guid);

        local spotname = "LH_SUB"

        ITEM_EQUIP(invitem.invIndex, spotname)

        frame:Invalidate();
        g.lh_sub_guid = nil

        local gemframe = ui.GetFrame("goddess_equip_manager")
        local awframe = ui.GetFrame("accountwarehouse")

        if awframe:IsVisible() == 0 then
            gemframe:ShowWindow(0)
            -- ui.CloseFrame("goddess_equip_manager")
            GODDESS_EQUIP_MANAGER_CLOSE(gemframe)
            ui.SysMsg("[AGM]end")
            return
        else
            ui.SysMsg("[AGM]end")
            return
        end

        --[[
        local gemframe = ui.GetFrame("goddess_equip_manager")
        GODDESS_EQUIP_MANAGER_CLOSE(gemframe)
        ui.SysMsg("[AGM]end")
        
        ui.CloseFrame = ("goddess_equip_manager")
        
        ]]
        -- ReserveScript("AETHERGEM_MGR_UNEQUIP()", 0.5)
        return;
    else
        return;
    end
end

function AETHERGEM_MGR_CLOSE_FRAME()

end

function AETHERGEM_MGR_REMOVE_OR_EQUIP()
    -- CHAT_SYSTEM("AETHERGEM_MGR_REMOVE_OR_EQUIP")
    local frame = ui.GetFrame("goddess_equip_manager")
    local am_aether_cover_bg = GET_CHILD_RECURSIVELY(frame, 'aether_cover_bg')
    local am_socket = GET_CHILD_RECURSIVELY(frame, "socket_slot")
    local am_aether_inner_bg = GET_CHILD_RECURSIVELY(frame, 'aether_inner_bg')
    local am_ctrlset = GET_CHILD(am_aether_inner_bg, 'AETHER_CSET_0')
    local am_do_remove = GET_CHILD(am_ctrlset, "do_remove")
    if am_aether_cover_bg:IsVisible() == 1 then

        return;
    end

    local isClickable = am_do_remove:IsEnable()
    if isClickable == 1 then

        local am_guid = am_socket:GetUserValue('ITEM_GUID')
        local am_tx_name = 'GODDESS_SOCKET_AETHER_GEM_UNEQUIP'
        local am_index = 2

        pc.ReqExecuteTx_Item(am_tx_name, am_guid, am_index)
        ReserveScript("AETHERGEM_MGR_SET_EQUIP()", 0.6)
        -- ReserveScript("AETHERGEM_MGR_REMOVE_OR_EQUIP()", 0.8)
    else
        -- ReserveScript("AETHERGEM_MGR_SET_EQUIP()", 0.5)
        AETHERGEM_MGR_ITEM_PREPARATION()
        ReserveScript("AETHERGEM_MGR_SET_EQUIP()", 0.6)

    end

end

function AETHERGEM_MGR_REMOVE_AETHERGEM()
    -- print("test2")
    local eqpframe = ui.GetFrame("inventory")

    local gemframe = ui.GetFrame("goddess_equip_manager")
    local am_socket = GET_CHILD_RECURSIVELY(gemframe, "socket_slot")

    local am_aether_inner_bg = GET_CHILD_RECURSIVELY(gemframe, 'aether_inner_bg')

    local am_ctrlset = GET_CHILD(am_aether_inner_bg, 'AETHER_CSET_0')
    local am_aether_cover_bg = GET_CHILD_RECURSIVELY(gemframe, 'aether_cover_bg')

    if am_aether_cover_bg:IsVisible() == 1 then
        -- CHAT_SYSTEM("あいてない")
        return;
        -- else
        -- CHAT_SYSTEM("あいてる")
    end

    local am_gem_slot = GET_CHILD(am_ctrlset, 'gem_slot', "ui::CSlot")

    local am_do_remove = GET_CHILD(am_ctrlset, "do_remove")

    local isClickable = am_do_remove:IsEnable()
    if isClickable == 1 then
        local am_guid = am_socket:GetUserValue('ITEM_GUID')
        local am_tx_name = 'GODDESS_SOCKET_AETHER_GEM_UNEQUIP'
        local am_index = 2

        pc.ReqExecuteTx_Item(am_tx_name, am_guid, am_index)
        local invTab = GET_CHILD_RECURSIVELY(eqpframe, "inventype_Tab")
        invTab:SelectTab(1)

        -- local frame = am_gem_slot:GetTopParentFrame()

        -- ReserveScript(string.format("GODDESS_MGR_SOCKET_CLEAR(" % s ")", frame), 0.5)

        -- CHAT_SYSTEM("押せる")
    else
        -- local invTab = GET_CHILD_RECURSIVELY(eqpframe, "inventype_Tab")
        -- invTab:SelectTab(6)

        -- AETHERGEM_MGR_GODDESS_MGR_SOCKET_AETHER_GEM_EQUIP()
        AETHERGEM_MGR_ITEM_PREPARATION()
    end

end

function AETHERGEM_MGR_GODDESS_MGR_SOCKET_INV_RBTN(item_obj, slot, guid)
    GODDESS_MGR_SOCKET_INV_RBTN_OLD(item_obj, slot, guid)

    AETHERGEM_MGR_REMOVE_AETHERGEM()
end

function AETHERGEM_MGR_REMOVEEQUIP_BUTTON_CLICK()
    -- print("rmequipボタンがクリックされました")
    local frame = ui.GetFrame('goddess_equip_manager')

    AETHERGEM_MGR_GODDESS_EQUIP_MANAGER_OPEN(frame)
end

function AETHERGEM_MGR_GODDESS_EQUIP_MANAGER_OPEN(frame)

    if TUTORIAL_CLEAR_CHECK(GetMyPCObject()) == false then
        ui.SysMsg(ClMsg('CanUseAfterTutorialClear'))
        frame:ShowWindow(0)
        return
    end

    ui.CloseFrame('rareoption')
    ui.CloseFrame('item_cabinet')
    for i = 1, #revertrandomitemlist do
        local revert_name = revertrandomitemlist[i]
        local revert_frame = ui.GetFrame(revert_name)
        if revert_frame ~= nil and revert_frame:IsVisible() == 1 then
            ui.CloseFrame(revert_name)
        end
    end

    ui.OpenFrame('goddess_equip_manager')
    local main_tab = GET_CHILD_RECURSIVELY(frame, 'main_tab')
    main_tab:SelectTab(2)

    -- CLEAR_GODDESS_EQUIP_MANAGER(frame)
    -- GODDESS_MGR_SOCKET_OPEN(frame)

    AETHERGEM_MGR_GET_EQUIP()

end

function AETHERGEM_MGR_ITEM_PREPARATION()

    -- local itemClassID = 850006
    local itemClassID = tonumber(g.gemid)

    if itemClassID == nil then
        ui.SysMsg(
            "このキャラクターには装着する[Lv.480]エーテルジェム が登録されていません")
        ui.SysMsg("There are no[Lv.480] Aether Gem registered for this character to wear.")
        return
    end

    local am_equip_item = session.GetInvItemByType(itemClassID)

    if am_equip_item == nil then

        ui.SysMsg("登録した[Lv.480]エーテルジェム がインベントリーにありません")
        ui.SysMsg("The registered [Lv.480] Aether Gem is missing from inventory.")
        return
    else

        local guid = am_equip_item:GetIESID()

        local inv_item = session.GetInvItemByGuid(guid)

        if inv_item == nil then
            return
        end

        local item_obj = GetIES(inv_item:GetObject())

        if item_obj == nil then
            return
        end

        local gem_type = GET_EQUIP_GEM_TYPE(item_obj)
        local frame = ui.GetFrame('goddess_equip_manager')
        local aether_inner_bg = GET_CHILD_RECURSIVELY(frame, 'aether_inner_bg')
        local parent = GET_CHILD(aether_inner_bg, "AETHER_CSET_0")
        if gem_type == 'aether' then
            AETHERGEM_MGR_GODDESS_MGR_SOCKET_AETHER_GEM_EQUIP(parent, nil, inv_item, item_obj)
        end
    end
end

function AETHERGEM_MGR_GODDESS_MGR_SOCKET_AETHER_GEM_EQUIP(parent, slot, gem_item, gem_obj)

    local frame = parent:GetTopParentFrame()
    local equip_slot = GET_CHILD_RECURSIVELY(frame, 'socket_slot')
    local guid = equip_slot:GetUserValue('ITEM_GUID')
    if guid ~= 'None' then

        local equip_item = session.GetInvItemByGuid(guid)
        if equip_item == nil then
            return
        end

        local equip_obj = GetIES(equip_item:GetObject())

        local index = parent:GetUserIValue('SLOT_INDEX')

        if equip_item:IsAvailableSocket(index) == false then

            return
        end

        local gem_id = equip_item:GetEquipGemID(index)
        if gem_id ~= nil and gem_id ~= 0 then

            return
        end

        if item_goddess_socket.check_equipable_aether_gem(equip_obj, gem_obj, index) == false then

            return
        end

        session.ResetItemList()

        session.AddItemID(guid, 1)
        session.AddItemID(gem_item:GetIESID(), 1)

        local arg_list = NewStringList()
        arg_list:Add(tostring(index))

        local result_list = session.GetItemIDList()

        item.DialogTransaction('GODDESS_SOCKET_AETHER_GEM_EQUIP', result_list, '', arg_list)
    end

end

function AETHERGEM_MGR_FRAME_INIT()
    local invframe = ui.GetFrame('inventory')
    local inventoryGbox = invframe:GetChild("inventoryGbox")

    -- ボタンの配置位置
    local buttonX = inventoryGbox:GetWidth() - 28
    local buttonY = inventoryGbox:GetHeight() - 614

    local eqbutton = inventoryGbox:CreateOrGetControl("button", "eqbutton", buttonX, buttonY, 20, 20)
    -- eqbutton:SetText("AG_SET")
    AUTO_CAST(eqbutton)
    eqbutton:SetSkinName("None")
    eqbutton:SetImage("config_button_normal")
    eqbutton:Resize(30, 30)

    local rmbuttonX = inventoryGbox:GetWidth() - 70
    local rmbuttonY = inventoryGbox:GetHeight() - 614

    local rmeqbutton = inventoryGbox:CreateOrGetControl("button", "rmeqbutton", rmbuttonX, rmbuttonY, 40, 30)
    rmeqbutton:SetText("{s14}AGM")

    eqbutton:SetEventScript(ui.LBUTTONUP, "AETHERGEM_MGR_EQUIP_BUTTON_CLICK")
    rmeqbutton:SetEventScript(ui.LBUTTONUP, "AETHERGEM_MGR_REMOVEEQUIP_BUTTON_CLICK")
    -- rmeqbutton:SetEventScript(ui.LBUTTONUP, "AETHERGEM_MGR_EQUIP_BUTTON_CLICK")
end

function AETHERGEM_MGR_AGMFRAME_CLOSE()
    local agmframe = ui.GetFrame("aethergem_mgr")
    agmframe = ui.CloseFrame("aethergem_mgr")
end

function AETHERGEM_MGR_ON_BUTTON_SELECTED(frame, ctrl, argStr, argNum)
    -- CHAT_SYSTEM("ボタンが押されました: " .. argStr)
    local STR_guid = 850006
    local INT_guid = 850007
    local DEX_guid = 850008
    local SPR_guid = 850009
    local CON_guid = 850010
    -- 選択されたラジオボタンの処理を記述
    if argStr == 'STR' then
        frame:ShowWindow(0)
        local gemid = STR_guid
        g.settings.pctbl[info.GetCID(session.GetMyHandle())] = gemid
        -- g.settings.pctbl = info.GetCID(session.GetMyHandle())
        -- g.gemguid = STR_guid
        -- local frame = ui.GetFrame('goddess_equip_manager')

        -- AETHERGEM_MGR_GODDESS_EQUIP_MANAGER_OPEN(frame)
        ui.SysMsg("[Lv.480]エーテルジェム - 力 を登録しました。")
        ui.SysMsg("[Lv.480] Aether Gem - STR set on this character.")
        -- AETHERGEM_MGR_SAVE_SETTINGS(gemid)
        AETHERGEM_MGR_LOADSETTINGS(gemid)
        -- STRボタンが選択された場合の処理
    elseif argStr == 'INT' then
        frame:ShowWindow(0)
        local gemid = INT_guid
        g.settings.pctbl[info.GetCID(session.GetMyHandle())] = gemid

        ui.SysMsg("[Lv.480]エーテルジェム - 知能 を登録しました。")
        ui.SysMsg("[Lv.480] Aether Gem - INT set on this character.")
        AETHERGEM_MGR_LOADSETTINGS(gemid)
        -- INTボタンが選択された場合の処理
    elseif argStr == 'CON' then
        frame:ShowWindow(0)
        local gemid = CON_guid
        g.settings.pctbl[info.GetCID(session.GetMyHandle())] = gemid

        ui.SysMsg("[Lv.480]エーテルジェム - 体力 を登録しました。")
        ui.SysMsg("[Lv.480] Aether Gem - CON set on this character.")
        AETHERGEM_MGR_LOADSETTINGS(gemid)
        -- CONボタンが選択された場合の処理
    elseif argStr == 'SPR' then
        frame:ShowWindow(0)
        local gemid = SPR_guid
        g.settings.pctbl[info.GetCID(session.GetMyHandle())] = gemid

        ui.SysMsg("[Lv.480]エーテルジェム - 精神 を登録しました。")
        ui.SysMsg("[Lv.480] Aether Gem - SPR set on this character.")
        AETHERGEM_MGR_LOADSETTINGS(gemid)
        -- SPRボタンが選択された場合の処理
    elseif argStr == 'DEX' then
        frame:ShowWindow(0)
        local gemid = DEX_guid
        g.settings.pctbl[info.GetCID(session.GetMyHandle())] = gemid
        ui.SysMsg("[Lv.480]エーテルジェム - 敏捷 を登録しました。")
        ui.SysMsg("[Lv.480] Aether Gem - DEX set on this character.")
        AETHERGEM_MGR_LOADSETTINGS(gemid)
        -- DEXボタンが選択された場合の処理
    end
end

function AETHERGEM_MGR_EQUIP_BUTTON_CLICK()
    local agmframe = ui.GetFrame("aethergem_mgr")
    if agmframe:IsVisible() == 1 then
        agmframe:ShowWindow(0)
        return
    end
    agmframe:SetSkinName('None')
    agmframe:Resize(60, 180)
    agmframe:ShowTitleBar(0)
    agmframe:EnableHitTest(1)
    agmframe:SetLayerLevel(100)
    local screenWidth = ui.GetClientInitialWidth()
    local offsetX = screenWidth - 80
    local screenHeight = ui.GetClientInitialHeight()
    local offsetY = 170
    agmframe:SetOffset(offsetX, offsetY)
    agmframe:RemoveAllChild()

    local closeBtn = agmframe:CreateOrGetControl("button", "closeBtn", 30, 0, 30, 30)
    AUTO_CAST(closeBtn)
    closeBtn:SetText("×")
    closeBtn:SetEventScript(ui.LBUTTONUP, "AETHERGEM_MGR_AGMFRAME_CLOSE")

    -- local titleText = agmframe:CreateOrGetControl('richtext', 'titleText', 0, 5, 80, 30)
    -- AUTO_CAST(titleText)
    -- titleText:SetText("{s16}{#00FFFF}AG SELECT")

    local strbtn = agmframe:CreateOrGetControl('button', 'strbtn', 0, 30, 60, 30)
    AUTO_CAST(strbtn)
    strbtn:SetText("{s16}{#F00000}STR")
    strbtn:SetEventScript(ui.LBUTTONUP, 'AETHERGEM_MGR_ON_BUTTON_SELECTED')
    strbtn:SetEventScriptArgString(ui.LBUTTONUP, "STR") -- ボタンが押されたことを示す文字列を渡す

    local intbtn = agmframe:CreateOrGetControl('button', 'intbtn', 0, 60, 60, 30)
    AUTO_CAST(intbtn)
    intbtn:SetText("{s16}{#00FFFF}INT")
    intbtn:SetEventScript(ui.LBUTTONUP, 'AETHERGEM_MGR_ON_BUTTON_SELECTED')
    intbtn:SetEventScriptArgString(ui.LBUTTONUP, "INT") -- ボタンが押されたことを示す文字列を渡す

    local conbtn = agmframe:CreateOrGetControl('button', 'conbtn', 0, 90, 60, 30)
    AUTO_CAST(conbtn)
    conbtn:SetText("{s16}{#FFFFFF}CON")
    conbtn:SetEventScript(ui.LBUTTONUP, 'AETHERGEM_MGR_ON_BUTTON_SELECTED')
    conbtn:SetEventScriptArgString(ui.LBUTTONUP, "CON") -- ボタンが押されたことを示す文字列を渡す

    local sprbtn = agmframe:CreateOrGetControl('button', 'sprbtn', 0, 120, 60, 30)
    AUTO_CAST(sprbtn)
    sprbtn:SetText("{s16}{#F0F000}SPR")
    sprbtn:SetEventScript(ui.LBUTTONUP, 'AETHERGEM_MGR_ON_BUTTON_SELECTED')
    sprbtn:SetEventScriptArgString(ui.LBUTTONUP, "SPR") -- ボタンが押されたことを示す文字列を渡す

    local dexbtn = agmframe:CreateOrGetControl('button', 'dexbtn', 0, 150, 60, 30)
    AUTO_CAST(dexbtn)
    dexbtn:SetText("{s16}{#00F000}DEX")
    dexbtn:SetEventScript(ui.LBUTTONUP, 'AETHERGEM_MGR_ON_BUTTON_SELECTED')
    dexbtn:SetEventScriptArgString(ui.LBUTTONUP, "DEX") -- ボタンが押されたことを示す文字列を渡す

    agmframe:ShowWindow(1)
end

--[[
function AETHERGEM_MGR_GODDESS_MGR_SOCKET_AETHER_UPDATE(frame)
    -- print("test")
    local aether_inner_bg = GET_CHILD_RECURSIVELY(frame, 'aether_inner_bg')
    aether_inner_bg:RemoveAllChild()

    local aether_cover_bg = GET_CHILD_RECURSIVELY(frame, 'aether_cover_bg')

    local socket_slot = GET_CHILD_RECURSIVELY(frame, 'socket_slot')
    local guid = socket_slot:GetUserValue('ITEM_GUID')
    if guid ~= 'None' then
        --  session.ResetItemList()
        -- local inv_item_list = session.GetInvItemList()

        local equipItemList = session.GetEquipItemList();
        local inv_item = equipItemList:GetItemByGuid(guid)

        if inv_item == nil then
            CHAT_SYSTEM("inv_item = nil")
            return
        end

        local item_obj = GetIES(inv_item:GetObject())
        local use_lv = TryGetProp(item_obj, 'UseLv', 0)
        local max_normal_cnt = GET_MAX_GODDESS_NORMAL_SOCKET_COUNT(use_lv)
        local aether_available = item_goddess_socket.enable_aether_socket_add(item_obj)
        if aether_available == false then
            aether_cover_bg:ShowWindow(0)
            if inv_item:IsAvailableSocket(max_normal_cnt) == false then
                return
            end
            local item_obj = GetIES(inv_item:GetObject())
            local use_lv = TryGetProp(item_obj, 'UseLv', 0)
            local max_aether_cnt = GET_MAX_GODDESS_AETHER_SOCKET_COUNT(use_lv)
            local not_available = false
            for i = 0, max_aether_cnt - 1 do
                local aether_index = i + max_normal_cnt
                local ctrlset = aether_inner_bg:CreateOrGetControlSet('eachsocket_in_goddessmgr', 'AETHER_CSET_' .. i,
                    5, i * 90)
                ctrlset:SetUserValue('SLOT_INDEX', aether_index)

                local gem_slot = GET_CHILD(ctrlset, 'gem_slot')
                local socket_name = GET_CHILD(ctrlset, 'socket_name')
                local do_remove = GET_CHILD(ctrlset, 'do_remove')
                local do_enable = GET_CHILD(ctrlset, 'do_enable')
                local socket_questionmark = GET_CHILD(ctrlset, 'socket_questionmark')

                local socketname = ScpArgMsg('NotDecidedYet')
                local enable = inv_item:IsAvailableSocket(aether_index)
                if enable == true then
                    local gem_id = inv_item:GetEquipGemID(aether_index)
                    local gem_exp = inv_item:GetEquipGemExp(aether_index)
                    local gem_equipped = 0
                    if gem_id == 0 then
                        local socket_cls = GetClassByType('Socket', GET_COMMON_SOCKET_TYPE())
                        socketname = socket_cls.Name .. ' ' .. ScpArgMsg('JustSocket')
                        socketicon = socket_cls.SlotIcon
                    else
                        local gem_cls = GetClassByType('Item', gem_id)
                        socketname = gem_cls.Name
                        socketicon = gem_cls.Icon
                        gem_equipped = 1
                        --  print("test1")
                        -- AETHERGEM_MGR_REMOVE_AETHERGEM()
                    end

                    ctrlset:SetUserValue('GEM_ID', gem_id)

                    socket_questionmark:ShowWindow(0)
                    gem_slot:ShowWindow(1)
                    local icon = CreateIcon(gem_slot)
                    icon:SetImage(socketicon)
                    do_enable:ShowWindow(0)
                    do_remove:ShowWindow(1)
                    do_remove:SetEnable(gem_equipped)
                else
                    gem_slot:ShowWindow(0)
                    socket_questionmark:ShowWindow(1)
                    do_remove:ShowWindow(0)
                    if not_available == false then
                        do_enable:ShowWindow(1)
                    else
                        do_enable:ShowWindow(0)
                    end

                    not_available = true
                end

                socket_name:SetTextByKey('name', socketname)
            end
        else
            aether_cover_bg:ShowWindow(1)
            local aether_open_btn = GET_CHILD(aether_cover_bg, 'aether_open_btn')
            aether_open_btn:SetEnable(0)
            local lock_pic = GET_CHILD(aether_cover_bg, 'lock_pic')
            lock_pic:ShowWindow(1)
        end
    else
        aether_cover_bg:ShowWindow(0)
    end
end
]]

--[[ とりあえず動いた
    function AETHERGEM_MGR_SET_EQUIP_LIST()
    CHAT_SYSTEM("AETHERGEM_MGR_SET_EQUIP_LIST")
    local frame = ui.GetFrame("inventory")
    CHAT_SYSTEM("test")
    -- local itemlist = session.GetInvItemList()
    local invitem = session.GetInvItemByGuid(g.rh_guid);
    CHAT_SYSTEM(invitem.invIndex)
    local spotname = "RH"
    CHAT_SYSTEM("test3")
    -- ITEM_EQUIP_MSG(invitem.invIndex, spotname)
    ITEM_EQUIP(invitem.invIndex, spotname)

    frame:Invalidate();

end
function AETHERGEM_MGR_UNEQUIP()
    local eqpframe = ui.GetFrame("inventory")

    if true == BEING_TRADING_STATE() then
        return;
    end

    local isEmptySlot = false;

    local invItemList = session.GetInvItemList();
    local itemCount = session.GetInvItemList():Count();

    if session.GetInvItemList():Count() < MAX_INV_COUNT then
        isEmptySlot = true;
    end

    local RH = GET_CHILD_RECURSIVELY(eqpframe, "RH")
    local LH = GET_CHILD_RECURSIVELY(eqpframe, "LH")
    local RH_SUB = GET_CHILD_RECURSIVELY(eqpframe, "RH_SUB")
    local LH_SUB = GET_CHILD_RECURSIVELY(eqpframe, "LH_SUB")

    if isEmptySlot == true then

        if tonumber(USE_SUBWEAPON_SLOT) == 1 then
            DO_WEAPON_SLOT_CHANGE(eqpframe, 1)
        else
            DO_WEAPON_SWAP(eqpframe, 1)
        end

        local rh_icon = RH:GetIcon()
        local lh_icon = LH:GetIcon()
        local rh_sub_icon = RH_SUB:GetIcon()
        local lh_sub_icon = LH_SUB:GetIcon()

        if rh_sub_icon ~= nil then
            local rhlh_sub = 30

            local rh_sub_icon_info = rh_sub_icon:GetInfo()
            local rh_sub_iesid = rh_sub_icon_info:GetIESID()
            print(rh_sub_iesid)

            local lh_sub_icon_info = lh_sub_icon:GetInfo()
            local lh_sub_iesid = lh_sub_icon_info:GetIESID()
            print(lh_sub_iesid)

            imcSound.PlaySoundEvent('inven_unequip');
            item.UnEquip(tonumber(rhlh_sub));
            -- AETHERGEM_MGR_REMOVE_AETHERGEM(eqpframe, guid)

            ReserveScript("AETHERGEM_MGR_UNEQUIP()", 0.5)
        elseif lh_icon ~= nil then
            local lh = 9

            local lh_icon_info = lh_icon:GetInfo()
            local lh_iesid = lh_icon_info:GetIESID()
            print(lh_iesid)

            imcSound.PlaySoundEvent('inven_unequip');
            item.UnEquip(tonumber(lh));
            ReserveScript("AETHERGEM_MGR_UNEQUIP()", 0.5)
        elseif rh_icon ~= nil then
            local rh = 8

            local rh_icon_info = rh_icon:GetInfo()
            local rh_iesid = rh_icon_info:GetIESID()
            print(rh_iesid)

            imcSound.PlaySoundEvent('inven_unequip');
            item.UnEquip(tonumber(rh));

            ReserveScript("AETHERGEM_MGR_UNEQUIP()", 0.5)
        else
            local invTab = GET_CHILD_RECURSIVELY(eqpframe, "inventype_Tab")
            invTab:SelectTab(1)
            -- local WEAPON_bg = GET_CHILD_RECURSIVELY(eqpframe, "WEAPON_bg")
            AETHERGEM_MGR_REMOVE_AETHERGEM(eqpframe)
            return
        end

    else
        ui.SysMsg(ScpArgMsg("Auto_inBenToLie_Bin_SeulLosi_PilyoHapNiDa."))
    end

end
]]
