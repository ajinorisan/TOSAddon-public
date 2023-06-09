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

if not g.loaded then
    g.settings = {

        pctbl = {}

    }
end

function AETHERGEM_MGR_SAVE_SETTINGS()
    -- CHAT_SYSTEM("save")
    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function AETHERGEM_MGR_LOADSETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end
    if not settings then
        settings = g.settings
    end

    g.settings = settings
end

--[[
local agmframe = ui.GetFrame("aethergem_mgr")
agmframe:SetSkinName('chat_window');
-- agmframe:SetSkinName("test_skin_01_btn");
agmframe:Resize(80, 150)
-- agmframe:Resize(300, 300)
agmframe:ShowTitleBar(0)
agmframe:EnableHitTest(0)
agmframe:SetLayerLevel(100);
agmframe:SetOffset(1810, 385);
agmframe:ShowWindow(1)

local function OnRadioButtonSelected(ctrl)
    -- 選択されたラジオボタンの処理を記述
    if ctrl:GetName() == 'strbtn' then
        local gemid=STR_guid
        g.settings.pctbl[info.GetCID(session.GetMyHandle())] = gemid
        -- STRボタンが選択された場合の処理
    elseif ctrl:GetName() == 'intbtn' then
        local gemid=INT_guid
        g.settings.pctbl[info.GetCID(session.GetMyHandle())] = gemid
        -- INTボタンが選択された場合の処理
    elseif ctrl:GetName() == 'conbtn' then
        local gemid=CON_guid
        g.settings.pctbl[info.GetCID(session.GetMyHandle())] = gemid
        -- CONボタンが選択された場合の処理
    elseif ctrl:GetName() == 'sprbtn' then
        local gemid=APR_guid
        g.settings.pctbl[info.GetCID(session.GetMyHandle())] = gemid
        -- SPRボタンが選択された場合の処理
    elseif ctrl:GetName() == 'dexbtn' then
        local gemid=DEX_guid
        g.settings.pctbl[info.GetCID(session.GetMyHandle())] = gemid
        -- DEXボタンが選択された場合の処理
    end
end

local strbtn = agmframe:CreateOrGetControl('radio', 'strbtn', 0, 0, 80, 30)
AUTO_CAST(strbtn)
strbtn:SetText("STR")
strbtn:SetGroupID(1)
strbtn:SetEventScript(ui.LBUTTONUP, 'OnRadioButtonSelected')

local intbtn = agmframe:CreateOrGetControl('radio', 'intbtn', 0, 30, 80, 30)
AUTO_CAST(intbtn)
intbtn:SetText("INT")
intbtn:SetGroupID(1)
intbtn:SetEventScript(ui.LBUTTONUP, 'OnRadioButtonSelected')

local conbtn = agmframe:CreateOrGetControl('radio', 'conbtn', 0, 60, 80, 30)
AUTO_CAST(conbtn)
conbtn:SetText("CON")
conbtn:SetGroupID(1)
conbtn:SetEventScript(ui.LBUTTONUP, 'OnRadioButtonSelected')

local sprbtn = agmframe:CreateOrGetControl('radio', 'sprbtn', 0, 90, 80, 30)
AUTO_CAST(sprbtn)
sprbtn:SetText("SPR")
sprbtn:SetGroupID(1)
sprbtn:SetEventScript(ui.LBUTTONUP, 'OnRadioButtonSelected')

local dexbtn = agmframe:CreateOrGetControl('radio', 'dexbtn', 0, 120, 80, 30)
AUTO_CAST(dexbtn)
dexbtn:SetText("DEX")
dexbtn:SetGroupID(1)
dexbtn:SetEventScript(ui.LBUTTONUP, 'OnRadioButtonSelected')
]]
function AETHERGEM_MGR_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    CHAT_SYSTEM(addonNameLower .. " loaded")
    acutil.setupHook(AETHERGEM_MGR_GODDESS_MGR_SOCKET_INV_RBTN, "GODDESS_MGR_SOCKET_INV_RBTN")
    -- acutil.setupHook(AETHERGEM_MGR_test, "GODDESS_MGR_SOCKET_AETHER_GEM_EQUIP")
    local loginCharID = info.GetCID(session.GetMyHandle())
    g.gemguid = nil
    for charID, charGemguid in pairs(g.settings.gemguid) do
        if charID == loginCharID then
            g.gemguid = charGemguid
            break
        end
    end
    -- AETHERGEM_MGR_LOADSETTINGS()
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
    local buttonX = inventoryGbox:GetWidth() - 105
    local buttonY = inventoryGbox:GetHeight() - 580

    local eqbutton = inventoryGbox:CreateOrGetControl("button", "eqbutton", buttonX, buttonY, 50, 30)
    eqbutton:SetText("AG_SET")

    local rmbuttonX = inventoryGbox:GetWidth() - 105
    local rmbuttonY = inventoryGbox:GetHeight() - 610

    local rmeqbutton = inventoryGbox:CreateOrGetControl("button", "rmeqbutton", rmbuttonX, rmbuttonY, 60, 30)
    rmeqbutton:SetText("AG_MGR")

    eqbutton:SetEventScript(ui.LBUTTONUP, "AETHERGEM_MGR_EQUIP_BUTTON_CLICK")
    rmeqbutton:SetEventScript(ui.LBUTTONUP, "AETHERGEM_MGR_REMOVEEQUIP_BUTTON_CLICK")

end

function AETHERGEM_MGR_EQUIP_BUTTON_CLICK()
    print("equipボタンがクリックされました")
    local agmframe = ui.GetFrame("aethergem_mgr")
    agmframe:SetSkinName('chat_window');
    -- agmframe:SetSkinName("test_skin_01_btn");
    agmframe:Resize(80, 150)
    -- agmframe:Resize(300, 300)
    agmframe:ShowTitleBar(0)
    agmframe:EnableHitTest(0)
    agmframe:SetLayerLevel(100);
    agmframe:SetOffset(1810, 385);
    agmframe:ShowWindow(1)

    local strbtn = agmframe:CreateOrGetControl('radio', 'strbtn', 0, 0, 80, 30)
    AUTO_CAST(strbtn)
    strbtn:SetText("STR")
    strbtn:SetGroupID(1)
    strbtn:SetEventScript(ui.LBUTTONUP, 'OnRadioButtonSelected')

    local intbtn = agmframe:CreateOrGetControl('radio', 'intbtn', 0, 30, 80, 30)
    AUTO_CAST(intbtn)
    intbtn:SetText("INT")
    intbtn:SetGroupID(1)
    intbtn:SetEventScript(ui.LBUTTONUP, 'OnRadioButtonSelected')

    local conbtn = agmframe:CreateOrGetControl('radio', 'conbtn', 0, 60, 80, 30)
    AUTO_CAST(conbtn)
    conbtn:SetText("CON")
    conbtn:SetGroupID(1)
    conbtn:SetEventScript(ui.LBUTTONUP, 'OnRadioButtonSelected')

    local sprbtn = agmframe:CreateOrGetControl('radio', 'sprbtn', 0, 90, 80, 30)
    AUTO_CAST(sprbtn)
    sprbtn:SetText("SPR")
    sprbtn:SetGroupID(1)
    sprbtn:SetEventScript(ui.LBUTTONUP, 'OnRadioButtonSelected')

    local dexbtn = agmframe:CreateOrGetControl('radio', 'dexbtn', 0, 120, 80, 30)
    AUTO_CAST(dexbtn)
    dexbtn:SetText("DEX")
    dexbtn:SetGroupID(1)
    dexbtn:SetEventScript(ui.LBUTTONUP, 'OnRadioButtonSelected')

    local function OnRadioButtonSelected(ctrl)
        local STR_guid = 850006
        local INT_guid = 850007
        local DEX_guid = 850008
        local APR_guid = 850009
        local CON_guid = 850010
        -- 選択されたラジオボタンの処理を記述
        if ctrl:GetName() == 'strbtn' then
            local gemid = STR_guid
            g.settings.pctbl[info.GetCID(session.GetMyHandle())] = gemid
            AETHERGEM_MGR_SAVE_SETTINGS()
            -- STRボタンが選択された場合の処理
        elseif ctrl:GetName() == 'intbtn' then
            local gemid = INT_guid
            g.settings.pctbl[info.GetCID(session.GetMyHandle())] = gemid
            AETHERGEM_MGR_SAVE_SETTINGS()
            -- INTボタンが選択された場合の処理
        elseif ctrl:GetName() == 'conbtn' then
            local gemid = CON_guid
            g.settings.pctbl[info.GetCID(session.GetMyHandle())] = gemid
            AETHERGEM_MGR_SAVE_SETTINGS()
            -- CONボタンが選択された場合の処理
        elseif ctrl:GetName() == 'sprbtn' then
            local gemid = APR_guid
            g.settings.pctbl[info.GetCID(session.GetMyHandle())] = gemid
            AETHERGEM_MGR_SAVE_SETTINGS()
            -- SPRボタンが選択された場合の処理
        elseif ctrl:GetName() == 'dexbtn' then
            local gemid = DEX_guid
            g.settings.pctbl[info.GetCID(session.GetMyHandle())] = gemid
            AETHERGEM_MGR_SAVE_SETTINGS()
            -- DEXボタンが選択された場合の処理
        end
    end

end

function AETHERGEM_MGR_REMOVE_AETHERGEM()

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

        -- ReserveScript(string.format("GODDESS_MGR_SOCKET_CLEAR("%s")", frame), 0.5)

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

]]
function AETHERGEM_MGR_ITEM_PREPARATION()
    if g.gemguid ~= nil then
        -- local itemClassID = 850006
        local itemClassID = g.gemguid
    else
        return
    end
    local am_equip_item = session.GetInvItemByType(itemClassID)
    -- CHAT_SYSTEM(equip_item)
    if am_equip_item == nil then
        ui.SysMsg("[Lv.480]エーテルジェム - 力 がインベントリーにありません")
        ui.SysMsg("[Lv.480] Aether Gem - STR  is missing from inventory")
    else
        CHAT_SYSTEM("test1")
        local guid = am_equip_item:GetIESID()
        CHAT_SYSTEM(guid)
        local inv_item = session.GetInvItemByGuid(guid)
        CHAT_SYSTEM(inv_item)
        if inv_item == nil then
            return
        end

        local item_obj = GetIES(inv_item:GetObject())
        CHAT_SYSTEM(item_obj)
        if item_obj == nil then
            return
        end

        local gem_type = GET_EQUIP_GEM_TYPE(item_obj)
        local frame = ui.GetFrame('goddess_equip_manager')
        local aether_inner_bg = GET_CHILD_RECURSIVELY(frame, 'aether_inner_bg')
        local parent = GET_CHILD(aether_inner_bg, "AETHER_CSET_0")
        if gem_type == 'aether' then
            CHAT_SYSTEM("test4")
            AETHERGEM_MGR_GODDESS_MGR_SOCKET_AETHER_GEM_EQUIP(parent, nil, inv_item, item_obj)
        end

    end
    -- ui.SysMsg("[Lv.480]エーテルジェム - 力 がインベントリーにありません")
    -- ui.SysMsg("[Lv.480] Aether Gem - STR  is missing from inventory")
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
        CHAT_SYSTEM(index)
        if equip_item:IsAvailableSocket(index) == false then
            CHAT_SYSTEM("test7")
            return
        end

        local gem_id = equip_item:GetEquipGemID(index)
        CHAT_SYSTEM(gem_id)
        if gem_id ~= nil and gem_id ~= 0 then
            CHAT_SYSTEM("test8")
            return
        end

        if item_goddess_socket.check_equipable_aether_gem(equip_obj, gem_obj, index) == false then
            CHAT_SYSTEM("test9")
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
    CHAT_SYSTEM("test7")
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
