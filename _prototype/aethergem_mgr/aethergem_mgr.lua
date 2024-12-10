-- v1.0.3 waitの時間見直し
-- v1.0.4 チーム倉庫開いている時の挙動見直し
-- v1.0.5 インベ表示微修正
-- v1.0.6 ディレイタイム設定機能
-- v1.0.7 CC_helper 連携強化
-- v1.0.8 SetupHookの競合修正
-- v1.0.9 23.09.05patch対応。LV500エーテルジェム対応。
-- v1.1.0 右クリックで着け外し機能削除
-- v1.1.1 UIをすっきりした。
-- v1.1.2 520対応。
local addonName = "AETHERGEM_MGR"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.1.2"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings_2412.json', addonNameLower)

local acutil = require("acutil")
local base = {}

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName];
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

function AETHERGEM_MGR_SAVE_SETTINGS()

    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function AETHERGEM_MGR_LOADSETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not settings then
        g.settings = {
            delay = 0.6
        }
    else
        g.settings = settings
    end

    local CID = session.GetMySession():GetCID()

    if g.settings[g.cid] == nil then
        g.settings[g.cid] = {}
    else
        g.settings[g.cid] = settings[g.cid]
    end
    AETHERGEM_MGR_SAVE_SETTINGS()
end

function AETHERGEM_MGR_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()
    g.cid = session.GetMySession():GetCID()

    AETHERGEM_MGR_LOADSETTINGS()
    addon:RegisterMsg("GAME_START_3SEC", "AETHERGEM_MGR_FRAME_INIT")
end

function AETHERGEM_MGR_FRAME_INIT()
    local invframe = ui.GetFrame('inventory')
    local item_cls = ""
    local icon_img = ""
    if g.settings[g.cid].gemid == 0 then
        item_cls = GetClassByType('Item', 850006)
        icon_img = GET_ITEM_ICON_IMAGE(item_cls, 'Icon')
    else
        item_cls = GetClassByType('Item', g.settings[g.cid].gemid)
        icon_img = GET_ITEM_ICON_IMAGE(item_cls, 'Icon')
    end

    local slot = invframe:CreateOrGetControl("slot", "slot", 470, 345, 30, 30)
    AUTO_CAST(slot)
    slot:SetSkinName("None")
    slot:EnablePop(0)
    slot:EnableDrop(0)
    slot:EnableDrag(0);

    local icon = CreateIcon(slot);
    AUTO_CAST(icon)
    icon:SetImage(icon_img);
    slot:Resize(30, 30)
    icon:SetTextTooltip(g.lang == "Japanese" and "{ol}右クリック：設定{nl}左クリック：作動" or
                            "{ol}Aethegem Manager{nl}Right click:Setup{nl}Left click:activation")
    slot:SetEventScript(ui.RBUTTONUP, "AETHERGEM_MGR_GEM_SETTING")
    slot:SetEventScript(ui.RBUTTONDOWN, "AETHERGEM_MGR_DELAY_FRAME_INIT")
    slot:SetEventScript(ui.LBUTTONUP, "AETHERGEM_MGR_REMOVEEQUIP_BUTTON_CLICK")

end

local gem_mapping = {
    ["480[STR]"] = 850006,
    ["480[INT]"] = 850007,
    ["480[CON]"] = 850010,
    ["480[SPR]"] = 850009,
    ["480[DEX]"] = 850008,
    ["500[STR]"] = 850011,
    ["500[INT]"] = 850012,
    ["500[CON]"] = 850015,
    ["500[SPR]"] = 850014,
    ["500[DEX]"] = 850013,
    ["520[STR]"] = 850016,
    ["520[INT]"] = 850017,
    ["520[CON]"] = 850020,
    ["520[SPR]"] = 850019,
    ["520[DEX]"] = 850018
}

local gem_order = {"480[STR]", "480[INT]", "480[CON]", "480[SPR]", "480[DEX]", "500[STR]", "500[INT]", "500[CON]",
                   "500[SPR]", "500[DEX]", "520[STR]", "520[INT]", "520[CON]", "520[SPR]", "520[DEX]"}

function AETHERGEM_MGR_GEM_SETTING(frame)
    local context = ui.CreateContextMenu("AETHERGEM_SETTING", "Aether Gem Setting", 0, 50, 180, 100)

    for _, handle in ipairs(gem_order) do
        local scp = string.format("AETHERGEM_MGR_SELECTED('%s')", handle)
        ui.AddContextMenuItem(context, handle, scp)

        -- 各カテゴリーに区切りを追加
        if handle == "480[DEX]" then
            ui.AddContextMenuItem(context, "  ")
        elseif handle == "500[DEX]" then
            ui.AddContextMenuItem(context, "   ")
        end
    end

    ui.AddContextMenuItem(context, " ")
    ui.AddContextMenuItem(context, "Cancel")
    ui.OpenContextMenu(context)
end

function AETHERGEM_MGR_SELECTED(handle)
    local CID = session.GetMySession():GetCID()
    local gemid = gem_mapping[handle]

    if gemid then
        g.settings[CID].gemid = gemid
        ui.SysMsg(g.lang == "Japanese" and "{ol}" .. handle .. " エーテルジェムを登録しました。" or
                      "{ol}" .. handle .. " Aether Gem set on this character.")
    end

    AETHERGEM_MGR_SAVE_SETTINGS()
    AETHERGEM_MGR_FRAME_INIT()
end

function AETHERGEM_MGR_DELAY_FRAME_INIT()
    local frame = ui.GetFrame("inventory")

    local delayframe = frame:CreateOrGetControl("groupbox", "delayframe", 430, 310, 70, 40)
    AUTO_CAST(delayframe)

    if delayframe:IsVisible() == 1 then
        delayframe:ShowWindow(0)
        return
    end
    delayframe:SetSkinName('None')
    delayframe:Resize(70, 40)

    delayframe:RemoveAllChild()

    local delay = delayframe:CreateOrGetControl('edit', 'delay', 5, 5, 60, 30)
    AUTO_CAST(delay)
    delay:SetText("{ol}" .. g.settings.delay)

    delay:SetFontName("white_16_ol")
    delay:SetTextAlign("center", "center")
    delay:SetEventScript(ui.ENTERKEY, "AETHERGEM_MGR_DELAY_SAVE")
    delay:SetTextTooltip(g.lang == "Japanese" and
                             "{ol}Aethegem Manager{nl}動作のディレイ時間を設定します。{nl}デフォルトは0.6秒。{nl}早過ぎると失敗が多発します。" or
                             "{ol}Aethegem Manager{nl}Sets the delay time for the operation.{nl}Default is 0.6 seconds.{nl}Too early and many failures will occur.")

    delayframe:ShowWindow(1)
end

function AETHERGEM_MGR_DELAY_SAVE(frame, ctrl, argStr, argNum)

    frame:ShowWindow(0)
    local delay = tonumber(ctrl:GetText())
    if delay > 0.3 and delay < 0.8 then
        ui.SysMsg(g.lang == "Japanese" and "ディレイタイムを" .. delay .. "秒に設定しました。" or
                      "Delay time is now set to " .. delay .. " seconds")
        g.settings.delay = delay
    else
        ui.SysMsg(g.lang == "Japanese" and "0.3～0.8秒の間で設定してください。" or
                      "Set between 0.3 and 0.8 seconds.")
        return
    end
    AETHERGEM_MGR_SAVE_SETTINGS()

end

function AETHERGEM_MGR_REMOVEEQUIP_BUTTON_CLICK()

    local frame = ui.GetFrame('goddess_equip_manager')
    AETHERGEM_MGR_LOADSETTINGS()
    AETHERGEM_MGR_GODDESS_EQUIP_MANAGER_OPEN(frame)
end

function AETHERGEM_MGR_GODDESS_EQUIP_MANAGER_OPEN(frame)

    if TUTORIAL_CLEAR_CHECK(GetMyPCObject()) == false then
        ui.SysMsg(ClMsg('CanUseAfterTutorialClear'))
        frame:ShowWindow(0)
        return
    end

    local frame = ui.GetFrame('goddess_equip_manager')
    frame:ShowWindow(1)
    local main_tab = GET_CHILD_RECURSIVELY(frame, 'main_tab')
    main_tab:SelectTab(2)

    AETHERGEM_MGR_GET_EQUIP()

end

function AETHERGEM_MGR_GET_EQUIP()
    local frame = ui.GetFrame("inventory")
    local equipItemList = session.GetEquipItemList();

    local invTab = GET_CHILD_RECURSIVELY(frame, "inventype_Tab")
    invTab:SelectTab(1)

    if true == BEING_TRADING_STATE() then
        return;
    end

    local isEmptySlot = false;

    if session.GetInvItemList():Count() < MAX_INV_COUNT then
        isEmptySlot = true;
    end
    if isEmptySlot == true then

        if tonumber(USE_SUBWEAPON_SLOT) == 1 then
            DO_WEAPON_SLOT_CHANGE(frame, 1)
        else
            DO_WEAPON_SWAP(frame, 1)
        end

        local RH = GET_CHILD_RECURSIVELY(frame, "RH")
        local LH = GET_CHILD_RECURSIVELY(frame, "LH")
        local RH_SUB = GET_CHILD_RECURSIVELY(frame, "RH_SUB")
        local LH_SUB = GET_CHILD_RECURSIVELY(frame, "LH_SUB")

        local rh_sub_icon = RH_SUB:GetIcon()
        if rh_sub_icon ~= nil then
            local rh_sub_icon_info = rh_sub_icon:GetInfo()
            g.rh_sub_guid = rh_sub_icon_info:GetIESID()

        end

        local lh_sub_icon = LH_SUB:GetIcon()
        if lh_sub_icon ~= nil then
            local lh_sub_icon_info = lh_sub_icon:GetInfo()
            g.lh_sub_guid = lh_sub_icon_info:GetIESID()
            local lhlh_sub = 31

            imcSound.PlaySoundEvent('inven_unequip');
            item.UnEquip(tonumber(lhlh_sub));

            ReserveScript("AETHERGEM_MGR_GET_EQUIP()", g.settings.delay)
            return
        end

        local lh_icon = LH:GetIcon()
        if lh_icon ~= nil then
            local lh_icon_info = lh_icon:GetInfo()
            g.lh_guid = lh_icon_info:GetIESID()

            local lh = 9

            imcSound.PlaySoundEvent('inven_unequip');
            item.UnEquip(tonumber(lh));

            ReserveScript("AETHERGEM_MGR_GET_EQUIP()", g.settings.delay)
            return
        end

        local rh_icon = RH:GetIcon()
        if rh_icon ~= nil then
            local rh_icon_info = rh_icon:GetInfo()
            g.rh_guid = rh_icon_info:GetIESID()

            local rh = 8

            imcSound.PlaySoundEvent('inven_unequip');
            item.UnEquip(tonumber(rh));

            ReserveScript("AETHERGEM_MGR_GET_EQUIP()", g.settings.delay)
            return
        end

        AETHERGEM_MGR_REG_ITEM()
    else
        ui.SysMsg(ScpArgMsg("Auto_inBenToLie_Bin_SeulLosi_PilyoHapNiDa."))
        return
    end
end

function AETHERGEM_MGR_REG_ITEM()

    local frame = ui.GetFrame('goddess_equip_manager')
    if g.rh_guid ~= nil then
        local inv_item = session.GetInvItemByGuid(g.rh_guid)
        if inv_item == nil then

            return
        end
        local item_obj = GetIES(inv_item:GetObject())
        if item_obj == nil then

            return
        end
        GODDESS_MGR_SOCKET_REG_ITEM(frame, inv_item, item_obj)
        GODDESS_MGR_SOCKET_AETHER_UPDATE(frame)
        AETHERGEM_MGR_REMOVE_OR_EQUIP(g.rh_guid)

    elseif g.lh_guid ~= nil then
        local inv_item = session.GetInvItemByGuid(g.lh_guid)
        if inv_item == nil then

            return
        end
        local item_obj = GetIES(inv_item:GetObject())
        if item_obj == nil then

            return
        end
        GODDESS_MGR_SOCKET_REG_ITEM(frame, inv_item, item_obj)
        GODDESS_MGR_SOCKET_AETHER_UPDATE(frame)
        AETHERGEM_MGR_REMOVE_OR_EQUIP(g.lh_guid)

    elseif g.rh_sub_guid ~= nil then
        local inv_item = session.GetInvItemByGuid(g.rh_sub_guid)
        if inv_item == nil then

            return
        end
        local item_obj = GetIES(inv_item:GetObject())
        if item_obj == nil then

            return
        end
        GODDESS_MGR_SOCKET_REG_ITEM(frame, inv_item, item_obj)
        GODDESS_MGR_SOCKET_AETHER_UPDATE(frame)
        AETHERGEM_MGR_REMOVE_OR_EQUIP(g.rh_sub_guid)

    elseif g.lh_sub_guid ~= nil then
        local inv_item = session.GetInvItemByGuid(g.lh_sub_guid)
        if inv_item == nil then

            return
        end
        local item_obj = GetIES(inv_item:GetObject())
        if item_obj == nil then

            return
        end
        GODDESS_MGR_SOCKET_REG_ITEM(frame, inv_item, item_obj)
        GODDESS_MGR_SOCKET_AETHER_UPDATE(frame)
        AETHERGEM_MGR_REMOVE_OR_EQUIP(g.lh_sub_guid)

    end

end

function AETHERGEM_MGR_REMOVE_OR_EQUIP(guid)

    if guid == g.rh_guid then
        g.rh_iesid = guid
        g.rh_guid = nil
    elseif guid == g.lh_guid then
        g.lh_iesid = guid
        g.lh_guid = nil
    elseif guid == g.rh_sub_guid then
        g.rh_sub_iesid = guid
        g.rh_sub_guid = nil
    elseif guid == g.lh_sub_guid then
        g.lh_sub_iesid = guid
        g.lh_sub_guid = nil
    end
    local eqpframe = ui.GetFrame("inventory")
    local invTab = GET_CHILD_RECURSIVELY(eqpframe, "inventype_Tab")
    invTab:SelectTab(6)

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
        -- 外す方
        local am_guid = am_socket:GetUserValue('ITEM_GUID')
        local am_tx_name = 'GODDESS_SOCKET_AETHER_GEM_UNEQUIP'
        local am_index = 2

        pc.ReqExecuteTx_Item(am_tx_name, am_guid, am_index)
        ReserveScript("AETHERGEM_MGR_REG_ITEM()", g.settings.delay)
        ReserveScript("AETHERGEM_MGR_SET_EQUIP()", g.settings.delay * 4 + 0.1)
        return
    else

        AETHERGEM_MGR_ITEM_PREPARATION()
        ReserveScript("AETHERGEM_MGR_REG_ITEM()", g.settings.delay)
        ReserveScript("AETHERGEM_MGR_SET_EQUIP()", g.settings.delay * 4 + 0.1)
        return
    end

end

function AETHERGEM_MGR_ITEM_PREPARATION()

    -- local itemClassID = 850006
    local CID = session.GetMySession():GetCID()

    local itemClassID = tonumber(g.settings[CID].gemid)

    if itemClassID == nil then
        ui.SysMsg(
            "このキャラクターには装着するエーテルジェム が登録されていません{nl}" ..
                "There are no[Lv.480] Aether Gem registered for this character to wear.")
        return
    end

    local am_equip_item = session.GetInvItemByType(itemClassID)

    if am_equip_item == nil then

        ui.SysMsg("登録したエーテルジェム がインベントリーにありません{nl}" ..
                      "The registered Aether Gem is missing from inventory.")
        return
    end

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

function AETHERGEM_MGR_SET_EQUIP()

    local frame = ui.GetFrame("inventory")
    if g.rh_iesid ~= nil then

        local invitem = session.GetInvItemByGuid(g.rh_iesid);
        local spotname = "RH"
        ITEM_EQUIP(invitem.invIndex, spotname)
        frame:Invalidate();
        g.rh_iesid = nil

    elseif g.lh_iesid ~= nil then

        local invitem = session.GetInvItemByGuid(g.lh_iesid);

        local spotname = "LH"

        ITEM_EQUIP(invitem.invIndex, spotname)
        frame:Invalidate();
        g.lh_iesid = nil

    elseif g.rh_sub_iesid ~= nil then

        local invitem = session.GetInvItemByGuid(g.rh_sub_iesid);
        local spotname = "RH_SUB"
        ITEM_EQUIP(invitem.invIndex, spotname)

        frame:Invalidate();
        g.rh_sub_iesid = nil

    elseif g.lh_sub_iesid ~= nil then

        local invitem = session.GetInvItemByGuid(g.lh_sub_iesid);
        local spotname = "LH_SUB"

        ITEM_EQUIP(invitem.invIndex, spotname)

        frame:Invalidate();
        g.lh_sub_iesid = nil
        ReserveScript("AETHERGEM_MGR_END()", g.settings.delay)
    end
end

function AETHERGEM_MGR_END()
    local gemframe = ui.GetFrame("goddess_equip_manager")

    gemframe:ShowWindow(0)
    ui.SysMsg("[AGM]end of operation")
    return;
end

--[[function AETHERGEM_MGR_CLOSE_FRAME()

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
        invTab:SelectTab(6)

        -- local frame = am_gem_slot:GetTopParentFrame()

        -- ReserveScript(string.format("GODDESS_MGR_SOCKET_CLEAR(" % s ")", frame), 0.5)

        -- CHAT_SYSTEM("押せる")
    else
        local invTab = GET_CHILD_RECURSIVELY(eqpframe, "inventype_Tab")
        invTab:SelectTab(6)

        -- AETHERGEM_MGR_GODDESS_MGR_SOCKET_AETHER_GEM_EQUIP()
        AETHERGEM_MGR_ITEM_PREPARATION()
    end

end

function AETHERGEM_MGR_GODDESS_MGR_SOCKET_INV_RBTN(item_obj, slot, guid)
    base["GODDESS_MGR_SOCKET_INV_RBTN"](item_obj, slot, guid)

    AETHERGEM_MGR_REMOVE_AETHERGEM()
end

function AETHERGEM_MGR_AGMFRAME_CLOSE()
    local agmframe = ui.GetFrame("aethergem_mgr")
    agmframe = ui.CloseFrame("aethergem_mgr")
    local delayframe = ui.GetFrame("delayframe")
    if delayframe:IsVisible() == 1 then
        delayframe = ui.CloseFrame("delayframe")
    end
end

function AETHERGEM_MGR_ON_BUTTON_SELECTED(frame, ctrl, argStr, argNum)
    CHAT_SYSTEM("ボタンが押されました: " .. argStr)
    local STR_guid = 850006
    local INT_guid = 850007
    local DEX_guid = 850008
    local SPR_guid = 850009
    local CON_guid = 850010

    local STR_guid_500 = 850011
    local INT_guid_500 = 850012
    local DEX_guid_500 = 850013
    local SPR_guid_500 = 850014
    local CON_guid_500 = 850015

    if argStr == '500STR' then
        frame:ShowWindow(0)
        local gemid = STR_guid_500
        g.settings.pctbl[info.GetCID(session.GetMyHandle())] = gemid

        ui.SysMsg(
            "[Lv.500]エーテルジェム-力を登録しました。{nl}[Lv.500] Aether Gem - STR set on this character.")

        AETHERGEM_MGR_LOADSETTINGS(gemid)

    elseif argStr == '500INT' then
        frame:ShowWindow(0)
        local gemid = INT_guid_500
        g.settings.pctbl[info.GetCID(session.GetMyHandle())] = gemid

        ui.SysMsg(
            "[Lv.500]エーテルジェム-知能を登録しました。{nl}[Lv.500] Aether Gem - INT set on this character.")
        AETHERGEM_MGR_LOADSETTINGS(gemid)

    elseif argStr == '500CON' then
        frame:ShowWindow(0)
        local gemid = CON_guid
        g.settings.pctbl[info.GetCID(session.GetMyHandle())] = gemid

        ui.SysMsg(
            "[Lv.500]エーテルジェム-体力を登録しました。{nl}[Lv.500] Aether Gem - CON set on this character.")
        AETHERGEM_MGR_LOADSETTINGS(gemid)

    elseif argStr == '500SPR' then
        frame:ShowWindow(0)
        local gemid = SPR_guid
        g.settings.pctbl[info.GetCID(session.GetMyHandle())] = gemid

        ui.SysMsg(
            "[Lv.500]エーテルジェム-精神を登録しました。{nl}[Lv.500] Aether Gem - SPR set on this character.")
        AETHERGEM_MGR_LOADSETTINGS(gemid)

    elseif argStr == '500DEX' then
        frame:ShowWindow(0)
        local gemid = DEX_guid
        g.settings.pctbl[info.GetCID(session.GetMyHandle())] = gemid

        ui.SysMsg(
            "[Lv.500]エーテルジェム-敏捷を登録しました。{nl}[Lv.500] Aether Gem - DEX set on this character.")
        AETHERGEM_MGR_LOADSETTINGS(gemid)

    end

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
    agmframe:SetSkinName('bg')
    agmframe:Resize(215, 190)
    agmframe:ShowTitleBar(0)
    agmframe:EnableHitTest(1)
    agmframe:SetLayerLevel(100)
    local screenWidth = ui.GetClientInitialWidth()
    local offsetX = screenWidth - 230
    local screenHeight = ui.GetClientInitialHeight()
    local offsetY = 170
    agmframe:SetOffset(offsetX, offsetY)
    agmframe:RemoveAllChild()

    local closeBtn = agmframe:CreateOrGetControl("button", "closeBtn", 180, 0, 30, 30)
    AUTO_CAST(closeBtn)
    closeBtn:SetText("×")
    closeBtn:SetEventScript(ui.LBUTTONUP, "AETHERGEM_MGR_AGMFRAME_CLOSE")

    -- local titleText = agmframe:CreateOrGetControl('richtext', 'titleText', 0, 5, 80, 30)
    -- AUTO_CAST(titleText)
    -- titleText:SetText("{s16}{#00FFFF}AG SELECT")

    local strbtn = agmframe:CreateOrGetControl('button', 'strbtn', 110, 30, 100, 30)
    AUTO_CAST(strbtn)
    strbtn:SetText("{s16}{#F00000}480[STR]")
    strbtn:SetEventScript(ui.LBUTTONUP, 'AETHERGEM_MGR_ON_BUTTON_SELECTED')
    strbtn:SetEventScriptArgString(ui.LBUTTONUP, "STR") -- ボタンが押されたことを示す文字列を渡す

    local intbtn = agmframe:CreateOrGetControl('button', 'intbtn', 110, 60, 100, 30)
    AUTO_CAST(intbtn)
    intbtn:SetText("{s16}{#00FFFF}480[INT]")
    intbtn:SetEventScript(ui.LBUTTONUP, 'AETHERGEM_MGR_ON_BUTTON_SELECTED')
    intbtn:SetEventScriptArgString(ui.LBUTTONUP, "INT") -- ボタンが押されたことを示す文字列を渡す

    local conbtn = agmframe:CreateOrGetControl('button', 'conbtn', 110, 90, 100, 30)
    AUTO_CAST(conbtn)
    conbtn:SetText("{s16}{#FFFFFF}480[CON]")
    conbtn:SetEventScript(ui.LBUTTONUP, 'AETHERGEM_MGR_ON_BUTTON_SELECTED')
    conbtn:SetEventScriptArgString(ui.LBUTTONUP, "CON") -- ボタンが押されたことを示す文字列を渡す

    local sprbtn = agmframe:CreateOrGetControl('button', 'sprbtn', 110, 120, 100, 30)
    AUTO_CAST(sprbtn)
    sprbtn:SetText("{s16}{#F0F000}480[SPR]")
    sprbtn:SetEventScript(ui.LBUTTONUP, 'AETHERGEM_MGR_ON_BUTTON_SELECTED')
    sprbtn:SetEventScriptArgString(ui.LBUTTONUP, "SPR") -- ボタンが押されたことを示す文字列を渡す

    local dexbtn = agmframe:CreateOrGetControl('button', 'dexbtn', 110, 150, 100, 30)
    AUTO_CAST(dexbtn)
    dexbtn:SetText("{s16}{#00F000}480[DEX]")
    dexbtn:SetEventScript(ui.LBUTTONUP, 'AETHERGEM_MGR_ON_BUTTON_SELECTED')
    dexbtn:SetEventScriptArgString(ui.LBUTTONUP, "DEX") -- ボタンが押されたことを示す文字列を渡す

    local strbtn2 = agmframe:CreateOrGetControl('button', 'strbtn2', 5, 30, 100, 30)
    AUTO_CAST(strbtn2)
    strbtn2:SetText("{s16}{#F00000}500[STR]")
    strbtn2:SetEventScript(ui.LBUTTONUP, 'AETHERGEM_MGR_ON_BUTTON_SELECTED')
    strbtn2:SetEventScriptArgString(ui.LBUTTONUP, "500STR") -- ボタンが押されたことを示す文字列を渡す

    local intbtn2 = agmframe:CreateOrGetControl('button', 'intbtn2', 5, 60, 100, 30)
    AUTO_CAST(intbtn2)
    intbtn2:SetText("{s16}{#00FFFF}500[INT]")
    intbtn2:SetEventScript(ui.LBUTTONUP, 'AETHERGEM_MGR_ON_BUTTON_SELECTED')
    intbtn2:SetEventScriptArgString(ui.LBUTTONUP, "500INT") -- ボタンが押されたことを示す文字列を渡す

    local conbtn2 = agmframe:CreateOrGetControl('button', 'conbtn2', 5, 90, 100, 30)
    AUTO_CAST(conbtn2)
    conbtn2:SetText("{s16}{#FFFFFF}500[CON]")
    conbtn2:SetEventScript(ui.LBUTTONUP, 'AETHERGEM_MGR_ON_BUTTON_SELECTED')
    conbtn2:SetEventScriptArgString(ui.LBUTTONUP, "500CON") -- ボタンが押されたことを示す文字列を渡す

    local sprbtn2 = agmframe:CreateOrGetControl('button', 'sprbtn2', 5, 120, 100, 30)
    AUTO_CAST(sprbtn2)
    sprbtn2:SetText("{s16}{#F0F000}500[SPR]")
    sprbtn2:SetEventScript(ui.LBUTTONUP, 'AETHERGEM_MGR_ON_BUTTON_SELECTED')
    sprbtn2:SetEventScriptArgString(ui.LBUTTONUP, "500SPR") -- ボタンが押されたことを示す文字列を渡す

    local dexbtn2 = agmframe:CreateOrGetControl('button', 'dexbtn2', 5, 150, 100, 30)
    AUTO_CAST(dexbtn2)
    dexbtn2:SetText("{s16}{#00F000}500[DEX]")
    dexbtn2:SetEventScript(ui.LBUTTONUP, 'AETHERGEM_MGR_ON_BUTTON_SELECTED')
    dexbtn2:SetEventScriptArgString(ui.LBUTTONUP, "500DEX") -- ボタンが押されたことを示す文字列を渡す

    agmframe:ShowWindow(1)
end]]

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
