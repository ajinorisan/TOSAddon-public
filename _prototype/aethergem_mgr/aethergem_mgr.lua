local addonName = "AETHERGEM_MGR"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")

function AETHERGEM_MGR_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    CHAT_SYSTEM(addonNameLower .. " loaded")
    acutil.setupHook(AETHERGEM_MGR_GODDESS_MGR_SOCKET_INV_RBTN, "GODDESS_MGR_SOCKET_INV_RBTN")
    -- acutil.setupHook(AETHERGEM_MGR_GODDESS_MGR_SOCKET_AETHER_GEM_EQUIP, "GODDESS_MGR_SOCKET_AETHER_GEM_EQUIP")
    AETHERGEM_MGR_FRAME_INIT()

end

function AETHERGEM_MGR_GODDESS_MGR_SOCKET_INV_RBTN(item_obj, slot, guid)
    GODDESS_MGR_SOCKET_INV_RBTN_OLD(item_obj, slot, guid)
    AETHERGEM_MGR_REMOVE_AETHERGEM()
end

function AETHERGEM_MGR_FRAME_INIT()
    local invframe = ui.GetFrame('inventory')
    local inventoryGbox = invframe:GetChild("inventoryGbox")

    -- ボタンの配置位置
    -- local buttonX = inventoryGbox:GetWidth() - 240
    -- local buttonY = inventoryGbox:GetHeight() - 610

    -- local eqbutton = inventoryGbox:CreateOrGetControl("button", "eqbutton", buttonX, buttonY, 50, 30)
    -- eqbutton:SetText("equip")

    local rmbuttonX = inventoryGbox:GetWidth() - 105
    local rmbuttonY = inventoryGbox:GetHeight() - 610

    local rmeqbutton = inventoryGbox:CreateOrGetControl("button", "rmeqbutton", rmbuttonX, rmbuttonY, 60, 30)
    rmeqbutton:SetText("AG_MGR")

    -- eqbutton:SetEventScript(ui.LBUTTONUP, "AETHERGEM_MGR_EQUIP_BUTTON_CLICK")
    rmeqbutton:SetEventScript(ui.LBUTTONUP, "AETHERGEM_MGR_REMOVEEQUIP_BUTTON_CLICK")

end
--[[
function AETHERGEM_MGR_EQUIP_BUTTON_CLICK()
    print("equipボタンがクリックされました")

end
]]
function AETHERGEM_MGR_REMOVE_AETHERGEM()
    -- CHAT_SYSTEM("TEST")
    local eqpframe = ui.GetFrame("inventory")

    local gemframe = ui.GetFrame("goddess_equip_manager")
    local am_socket = GET_CHILD_RECURSIVELY(gemframe, "socket_slot")

    local am_aether_inner_bg = GET_CHILD_RECURSIVELY(gemframe, 'aether_inner_bg')

    local am_ctrlset = GET_CHILD(am_aether_inner_bg, 'AETHER_CSET_0')
    local am_aether_cover_bg = GET_CHILD_RECURSIVELY(gemframe, 'aether_cover_bg')

    if am_aether_cover_bg:IsVisible() == 1 then
        return;

    end

    local am_gem_slot = GET_CHILD(am_ctrlset, 'gem_slot', "ui::CSlot")
    -- local am_gem_name = GET_CHILD(am_ctrlset, 'socket_name', "ui::CRichText")
    -- CHAT_SYSTEM(am_gem_name:GetText())
    local am_do_remove = GET_CHILD(am_ctrlset, "do_remove")
    local isClickable = am_do_remove:IsEnable()
    if isClickable == 1 then
        local am_guid = am_socket:GetUserValue('ITEM_GUID')
        local am_tx_name = 'GODDESS_SOCKET_AETHER_GEM_UNEQUIP'
        local am_index = 2

        pc.ReqExecuteTx_Item(am_tx_name, am_guid, am_index)
        local invTab = GET_CHILD_RECURSIVELY(eqpframe, "inventype_Tab")
        invTab:SelectTab(1)

        local frame = gemframe

        GODDESS_MGR_SOCKET_CLEAR(frame)

        -- CHAT_SYSTEM("押せる")
    else
        local invTab = GET_CHILD_RECURSIVELY(eqpframe, "inventype_Tab")
        invTab:SelectTab(6)

        -- AETHERGEM_MGR_GODDESS_MGR_SOCKET_AETHER_GEM_EQUIP()
        AETHERGEM_MGR_ITEM_PREPARATION()
    end

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
    CLEAR_GODDESS_EQUIP_MANAGER(frame)
    GODDESS_MGR_SOCKET_OPEN(frame)
    AETHERGEM_MGR_UNEQUIP()
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
--[[

local frameName = "gem_select"
local frame = ui.CreateNewFrame("chat_window", frameName)
local P_guid = 850006
    local I_guid = 850007
    local A_guid = 850008
    local S_guid = 850009
    local V_guid = 850010
]]
function AETHERGEM_MGR_ITEM_PREPARATION()
    local itemClassID = 850006
    local equip_item = session.GetInvItemByType(itemClassID)
    if equip_item ~= nil then
        CHAT_SYSTEM("test1")
        local guid = equip_item:GetIESID()
        local inv_item = session.GetInvItemByGuid(guid)
        if inv_item == nil then
            return
        end

        local item_obj = GetIES(inv_item:GetObject())
        if item_obj == nil then
            return
        end

        local gem_type = GET_EQUIP_GEM_TYPE(item_obj)
        local parent = ui.GetFrame('goddess_equip_manager')
        if gem_type == 'aether' then
            CHAT_SYSTEM("test4")
            GODDESS_MGR_SOCKET_AETHER_GEM_EQUIP(parent, nil, inv_item, item_obj)
        end
    else
        return
    end
end
--[[
function GODDESS_MGR_SOCKET_AETHER_GEM_EQUIP(parent, slot, gem_item, gem_obj)
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

]]
