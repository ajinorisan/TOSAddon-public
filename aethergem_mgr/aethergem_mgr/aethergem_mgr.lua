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
-- v1.1.3 付け替え対応。CCHはバグると思う。
-- v1.1.4 ちょいちょい修正版
local addonName = "AETHERGEM_MGR"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.1.4"

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
            delay = 0.4
        }
    else
        g.settings = settings
    end

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
    if not g.settings[g.cid].gemid then
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
    slot:SetEventScript(ui.LBUTTONUP, "AETHERGEM_MGR_GEM_OPERATION")

end
function AETHERGEM_MGR_GEM_SETTING_CLOSE(frame, ctrl, str, num)
    frame:ShowWindow(0)
end

function AETHERGEM_MGR_GEM_SETTING(frame, ctrl, str, num)
    local setting_frame = ui.CreateNewFrame("chat_memberlist", addonNameLower .. "setting_frame", 0, 0, 0, 0)
    AUTO_CAST(setting_frame)

    setting_frame:SetSkinName("test_frame_low")
    local x = frame:GetX()
    setting_frame:Resize(300, 400)
    setting_frame:SetPos(x - setting_frame:GetWidth(), 300)
    setting_frame:SetLayerLevel(121)
    setting_frame:RemoveAllChild()

    local setting_gb = setting_frame:CreateOrGetControl("groupbox", " setting_gb", 10, 35,
        setting_frame:GetWidth() - 20, setting_frame:GetHeight() - 45)
    AUTO_CAST(setting_gb)
    setting_gb:SetSkinName("bg")

    local close_button = setting_frame:CreateOrGetControl('button', 'close_button', 0, 0, 20, 20)
    AUTO_CAST(close_button)
    close_button:SetImage("testclose_button")
    close_button:SetGravity(ui.RIGHT, ui.TOP)
    close_button:SetEventScript(ui.LBUTTONUP, "AETHERGEM_MGR_GEM_SETTING_CLOSE");

    local title_text = setting_frame:CreateOrGetControl('richtext', 'title_text', 10, 10, 200, 30)
    AUTO_CAST(title_text)
    title_text:SetText("{ol}Aether Gem Setting")

    local delay_text = setting_gb:CreateOrGetControl('richtext', 'delay_text', 10, 15, 100, 30)
    AUTO_CAST(delay_text)
    delay_text:SetText("{ol}delay setting")

    function AETHERGEM_MGR_DELAY_SAVE(frame, ctrl, argStr, argNum)

        local delay = tonumber(ctrl:GetText())
        if delay >= 0.3 and delay <= 0.8 then
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

    local delay_edit = setting_gb:CreateOrGetControl('edit', 'delay_edit', 125, 10, 50, 30)
    AUTO_CAST(delay_edit)
    delay_edit:SetFontName("white_16_ol")
    delay_edit:SetTextAlign("center", "center")
    delay_edit:SetText("{ol}" .. g.settings.delay)
    delay_edit:SetEventScript(ui.ENTERKEY, "AETHERGEM_MGR_DELAY_SAVE")
    delay_edit:SetTextTooltip(g.lang == "Japanese" and
                                  "{ol}動作のディレイ時間を設定します。{nl}デフォルトは0.4秒。{nl}早過ぎると失敗が多発します。" or
                                  "{ol}Sets the delay time for the operation.{nl}Default is 0.4 seconds.{nl}Too early and many failures will occur.")

    function AETHERGEM_MGR_DROP(slotset, slot, str, num)

        local liftIcon = ui.GetLiftIcon()
        local info = liftIcon:GetInfo()
        local clsid = info.type
        local item_cls = GetClassByType("Item", clsid)
        local name = item_cls.ClassName
        local category = info:GetCategory()
        local index = string.gsub(slot:GetName(), "slot", "")
        local slotset_index = string.gsub(slotset:GetName(), "slotset", "")
        local image = info:GetImageName()
        if string.find(image, "highcolorgem") ~= nil then
            g.settings[slotset_index] = g.settings[slotset_index] or {}

            CreateIcon(slot)
            SET_SLOT_ITEM_CLS(slot, item_cls)
            if string.find(name, "480") ~= nil then
                local lv_text = slot:CreateOrGetControl('richtext', 'lv_text', 0, 25, 25, 25)
                AUTO_CAST(lv_text)
                lv_text:SetText("{ol}{s14}LV480")
                g.settings[slotset_index][index] = clsid
            elseif string.find(name, "500") ~= nil then
                local lv_text = slot:CreateOrGetControl('richtext', 'lv_text', 0, 25, 25, 25)
                AUTO_CAST(lv_text)
                lv_text:SetText("{ol}{s14}LV500")
                g.settings[slotset_index][index] = clsid
            elseif string.find(name, "520") ~= nil then
                local lv_text = slot:CreateOrGetControl('richtext', 'lv_text', 0, 25, 25, 25)
                AUTO_CAST(lv_text)
                lv_text:SetText("{ol}{s14}LV520")
                g.settings[slotset_index][index] = clsid
            else
                local lv_text = slot:CreateOrGetControl('richtext', 'lv_text', 0, 25, 25, 25)
                AUTO_CAST(lv_text)
                lv_text:SetText("{ol}{s14}LV460")
                g.settings[slotset_index][index] = clsid
            end
            AETHERGEM_MGR_SAVE_SETTINGS()
        end
    end

    function AETHERGEM_MGR_LBTN(slotset, setting_btn, slotset_index, num)
        if next(g.settings[slotset_index]) == nil then
            return
        end
        for i = 1, 6 do
            local etc_btn = GET_CHILD_RECURSIVELY(setting_frame, "setting_btn" .. i)
            etc_btn:SetSkinName("test_gray_button")
            etc_btn:SetText("{ol}not use")
        end

        if g.settings[g.cid].use_index ~= slotset_index or g.settings[g.cid].use_index == nil then
            g.settings[g.cid] = g.settings[slotset_index]
            g.settings[g.cid].use_index = slotset_index
            setting_btn:SetSkinName("test_red_button")
            setting_btn:SetText("{ol}use")
        end

        AETHERGEM_MGR_SAVE_SETTINGS()
    end

    for i = 1, 6 do
        local slotset = setting_gb:CreateOrGetControl('slotset', 'slotset' .. i, 90, i * 50, 0, 0)
        AUTO_CAST(slotset);
        slotset:EnablePop(1)
        slotset:EnableDrag(1)
        slotset:EnableDrop(1)
        slotset:EnableHitTest(1);
        slotset:SetColRow(4, 1)
        slotset:SetSlotSize(45, 45)
        slotset:SetSpc(2, 2)
        slotset:SetSkinName('invenslot2')
        slotset:CreateSlots()
        g.settings[tostring(i)] = g.settings[tostring(i)] or {}

        local slot_count = slotset:GetSlotCount()
        for j = 1, slot_count do
            local slot = GET_CHILD(slotset, "slot" .. j)
            AUTO_CAST(slot)
            slot:EnableDrop(1)
            local clsid = g.settings[tostring(i)][tostring(j)]
            if clsid then
                local item_cls = GetClassByType("Item", clsid)
                local name = item_cls.ClassName
                CreateIcon(slot)
                SET_SLOT_ITEM_CLS(slot, item_cls)
                if string.find(name, "480") ~= nil then
                    local lv_text = slot:CreateOrGetControl('richtext', 'lv_text', 0, 25, 25, 25)
                    AUTO_CAST(lv_text)
                    lv_text:SetText("{ol}{s14}LV480")

                elseif string.find(name, "500") ~= nil then
                    local lv_text = slot:CreateOrGetControl('richtext', 'lv_text', 0, 25, 25, 25)
                    AUTO_CAST(lv_text)
                    lv_text:SetText("{ol}{s14}LV500")

                elseif string.find(name, "520") ~= nil then
                    local lv_text = slot:CreateOrGetControl('richtext', 'lv_text', 0, 25, 25, 25)
                    AUTO_CAST(lv_text)
                    lv_text:SetText("{ol}{s14}LV520")

                else
                    local lv_text = slot:CreateOrGetControl('richtext', 'lv_text', 0, 25, 25, 25)
                    AUTO_CAST(lv_text)
                    lv_text:SetText("{ol}{s14}LV460")

                end

            end
            slot:SetEventScript(ui.RBUTTONUP, 'AETHERGEM_MGR_RBTN');
            slot:SetEventScript(ui.DROP, 'AETHERGEM_MGR_DROP')
        end

        local setting_btn = setting_gb:CreateOrGetControl('button', "setting_btn" .. i, 5, i * 50 + 5, 75, 30);
        AUTO_CAST(setting_btn);
        if g.settings[g.cid].use_index == tostring(i) then
            setting_btn:SetSkinName("test_red_button")
            setting_btn:SetText("{ol}use")

        else
            setting_btn:SetSkinName("test_gray_button")
            setting_btn:SetText("{ol}not use")
        end
        setting_btn:SetEventScript(ui.LBUTTONUP, 'AETHERGEM_MGR_LBTN');
        setting_btn:SetEventScriptArgString(ui.LBUTTONUP, i);
    end
    AETHERGEM_MGR_SAVE_SETTINGS()

    setting_frame:ShowWindow(1)
end

function AETHERGEM_MGR_GEM_OPERATION()

    local setting_frame = ui.GetFrame(addonNameLower .. "setting_frame")
    if setting_frame ~= nil then
        AUTO_CAST(setting_frame)
        setting_frame:ShowWindow(0)
    end

    local frame = ui.GetFrame('goddess_equip_manager')
    if TUTORIAL_CLEAR_CHECK(GetMyPCObject()) == false then
        ui.SysMsg(ClMsg('CanUseAfterTutorialClear'))
        frame:ShowWindow(0)
        return
    end

    frame:ShowWindow(1)
    local main_tab = GET_CHILD_RECURSIVELY(frame, 'main_tab')
    main_tab:SelectTab(2)
    AETHERGEM_MGR_GET_INVENTRY_GEM()
end

function AETHERGEM_MGR_GET_INVENTRY_GEM()
    session.ResetItemList()
    local invItemList = session.GetInvItemList()
    local inv_guidList = invItemList:GetGuidList()
    local cnt = inv_guidList:Count()
    g.level = {}
    for i = 0, cnt - 1 do
        local guid = inv_guidList:Get(i)
        local inv_Item = invItemList:GetItemByGuid(guid)
        local iesid = inv_Item:GetIESID()
        local inv_obj = GetIES(inv_Item:GetObject())
        local inv_clsid = inv_obj.ClassID

        for index, clsid in pairs(g.settings[g.cid]) do
            if clsid == inv_clsid then
                local level = get_current_aether_gem_level(inv_obj)
                table.insert(g.level, {
                    level = level,
                    iesid = iesid,
                    clsid = clsid
                })
                break
            end
        end

    end

    table.sort(g.level, function(a, b)
        return a.level > b.level
    end)
    --[[for i, item in ipairs(g.level) do
        print(string.format("Level: %d, IESID: %s, CLSID: %d", item.level, item.iesid, item.clsid))
    end]]
    g.guids = {}
    ReserveScript("AETHERGEM_MGR_GET_EQUIP()", g.settings.delay)
end

function AETHERGEM_MGR_GET_EQUIP()

    local frame = ui.GetFrame("inventory")
    session.ResetItemList()
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

    local equips = {"RH", "LH", "RH_SUB", "LH_SUB"}
    local delay = g.settings.delay
    if isEmptySlot == true then

        for _, equip in ipairs(equips) do
            local child = GET_CHILD_RECURSIVELY(frame, equip)
            if child ~= nil then
                local icon = child:GetIcon()
                if icon ~= nil then
                    local guid = icon:GetInfo():GetIESID()
                    table.insert(g.guids, guid)
                end
            end
        end

        function AETHERGEM_MGR_UNEQUIP(equip_index)
            item.UnEquip(equip_index)
        end

        for _, equip in ipairs(equips) do
            local child = GET_CHILD_RECURSIVELY(frame, equip)
            if child ~= nil then
                local icon = child:GetIcon()
                if icon ~= nil then
                    local guid = icon:GetInfo():GetIESID()

                    if equip == "RH" then
                        AETHERGEM_MGR_UNEQUIP(8)
                    elseif equip == "LH" then
                        ReserveScript(string.format("AETHERGEM_MGR_UNEQUIP(%d)", 9), delay)
                    elseif equip == "RH_SUB" then
                        ReserveScript(string.format("AETHERGEM_MGR_UNEQUIP(%d)", 30), delay * 2)
                    end
                end

            end
        end
        ReserveScript("AETHERGEM_MGR_REG_ITEM_RESERVE()", delay * 3)
    else
        ui.SysMsg(ScpArgMsg("Auto_inBenToLie_Bin_SeulLosi_PilyoHapNiDa."))
        return
    end

end

function AETHERGEM_MGR_REG_ITEM(index)

    local frame = ui.GetFrame('goddess_equip_manager')
    local guid = g.guids[index]

    local inv_item = session.GetInvItemByGuid(guid)
    local item_obj = GetIES(inv_item:GetObject())
    GODDESS_MGR_SOCKET_REG_ITEM(frame, inv_item, item_obj)
    GODDESS_MGR_SOCKET_AETHER_UPDATE(frame)
    AETHERGEM_MGR_REMOVE_OR_EQUIP(guid, index)
end

function AETHERGEM_MGR_REG_ITEM_RESERVE()

    local delay = g.settings.delay
    for i = 1, 4 do

        ReserveScript(string.format("AETHERGEM_MGR_REG_ITEM(%d)", i), delay)
        delay = delay + delay

    end
end

function AETHERGEM_MGR_REMOVE_OR_EQUIP(guid, index)

    local eqpframe = ui.GetFrame("inventory")
    local invTab = GET_CHILD_RECURSIVELY(eqpframe, "inventype_Tab")
    invTab:SelectTab(6)

    local frame = ui.GetFrame("goddess_equip_manager")
    local aether_cover_bg = GET_CHILD_RECURSIVELY(frame, 'aether_cover_bg')
    local socket_slot = GET_CHILD_RECURSIVELY(frame, "socket_slot")
    local aether_inner_bg = GET_CHILD_RECURSIVELY(frame, 'aether_inner_bg')
    local ctrlset = GET_CHILD(aether_inner_bg, 'AETHER_CSET_0')
    local do_remove = GET_CHILD(ctrlset, "do_remove")
    if aether_cover_bg:IsVisible() == 1 then
        return;
    end

    local is_clickable = do_remove:IsEnable()
    if is_clickable == 1 then
        -- 外す方
        local item_guid = socket_slot:GetUserValue('ITEM_GUID')
        local tx_name = 'GODDESS_SOCKET_AETHER_GEM_UNEQUIP'
        pc.ReqExecuteTx_Item(tx_name, item_guid, 2)
        if index == 4 then

            ReserveScript("AETHERGEM_MGR_EQUIP()", g.settings.delay)
            return
        end
    else
        AETHERGEM_MGR_GEM_EQUIP(index)
        return

    end

end

function AETHERGEM_MGR_GEM_EQUIP(index)

    local frame = ui.GetFrame("goddess_equip_manager")
    local aether_inner_bg = GET_CHILD_RECURSIVELY(frame, 'aether_inner_bg')
    local socket_slot = GET_CHILD_RECURSIVELY(frame, "socket_slot")
    local ctrlset = GET_CHILD(aether_inner_bg, 'AETHER_CSET_0')
    local clsid = 0
    if next(g.settings[g.cid]) == nil then
        ui.SysMsg(g.lang == "Japanese" and
                      "このキャラクターには装着するエーテルジェム が登録されていません" or
                      "There are no Aether Gem registered for this character to wear.")
        return
    else

        clsid = g.settings[g.cid][tostring(index)]
    end

    local gem_item = session.GetInvItemByType(clsid)
    if gem_item == nil then
        ui.SysMsg(g.lang == "Japanese" and
                      "登録したエーテルジェム がインベントリーにありません" or
                      "The registered Aether Gem is missing from inventory.")
        return
    end
    local gem_guid = nil
    local itemToRemoveIndex = nil

    -- g.levelをループ
    for i, item in ipairs(g.level) do
        local level = item.level
        local cls_id = item.clsid
        local iesid = item.iesid

        if cls_id == clsid then
            gem_guid = iesid
            itemToRemoveIndex = i
            break
        end
    end

    if itemToRemoveIndex then
        table.remove(g.level, itemToRemoveIndex)
    end

    local gem_obj = GetIES(gem_item:GetObject())
    local equip_guid = socket_slot:GetUserValue('ITEM_GUID')

    if gem_guid ~= 'None' then
        local equip_item = session.GetInvItemByGuid(g.guids[index])
        if equip_item == nil then
            return
        end

        local equip_obj = GetIES(equip_item:GetObject())

        local slot_index = ctrlset:GetUserIValue('SLOT_INDEX')
        if equip_item:IsAvailableSocket(slot_index) == false then
            return
        end

        local gem_id = equip_item:GetEquipGemID(slot_index)
        if gem_id ~= nil and gem_id ~= 0 then
            return
        end

        session.ResetItemList()
        session.AddItemID(equip_guid, 1)
        session.AddItemID(gem_guid, 1)
        local arg_list = NewStringList()
        arg_list:Add(tostring(slot_index))
        local result_list = session.GetItemIDList()
        item.DialogTransaction('GODDESS_SOCKET_AETHER_GEM_EQUIP', result_list, '', arg_list)
    end

    if index == 4 then
        ReserveScript("AETHERGEM_MGR_EQUIP()", g.settings.delay)
    end
end

function AETHERGEM_MGR_END()
    local frame = ui.GetFrame("goddess_equip_manager")

    frame:ShowWindow(0)
    ui.SysMsg("[AGM]End of Operation")
    return;
end

function AETHERGEM_MGR_EQUIP()

    local frame = ui.GetFrame("inventory")
    local delay = g.settings.delay
    for i = 1, 4 do
        local guid = g.guids[i]
        local invitem = session.GetInvItemByGuid(guid);

        if invitem ~= nil then
            local index = invitem.invIndex
            local spotname = nil
            if i == 1 then
                DO_WEAPON_SLOT_CHANGE(frame, 1)
                spotname = "RH"
            elseif i == 2 then
                spotname = "LH"
            elseif i == 3 then
                spotname = "RH_SUB"
            elseif i == 4 then
                spotname = "LH_SUB"
            end
            ReserveScript(string.format("ITEM_EQUIP(%d,'%s')", index, spotname), delay)
            if i ~= 4 then
                delay = delay + delay
            end
            frame:Invalidate();
        end
    end
    ReserveScript("AETHERGEM_MGR_END()", delay)
end

