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
-- v1.1.5 設定フレームから削除できなかったの修正。コード最適化
local addonName = "AETHERGEM_MGR"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.1.5"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local active_id = session.loginInfo.GetAID()
g.settingsFileLoc = string.format('../addons/%s/%s.json', addonNameLower, active_id)

local acutil = require("acutil")
local json = require("json")
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

function g.mkdir_new_folder()
    local folder_path = string.format("../addons/%s", addonNameLower)
    local file_path = string.format("../addons/%s/mkdir.txt", addonNameLower)
    local file = io.open(file_path, "r")
    if not file then
        os.execute('mkdir "' .. folder_path .. '"')
        file = io.open(file_path, "w")
        if file then
            file:write("A new file has been created")
            file:close()
        end
    else
        file:close()
    end
end
g.mkdir_new_folder()

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
    slot:SetEventScript(ui.LBUTTONUP, "aethergem_mgr_gem_operation")

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

    function AETHERGEM_MGR_GEM_SETTING_CLOSE(setting_frame, close_button, str, num)
        setting_frame:ShowWindow(0)
    end

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

    function AETHERGEM_MGR_DELAY_SAVE(frame, delay_edit, argStr, argNum)

        local delay = tonumber(delay_edit:GetText())
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

    function AETHERGEM_MGR_RBTN(slotset, slot, str, num)

        local index = string.gsub(slot:GetName(), "slot", "")
        local slotset_index = string.gsub(slotset:GetName(), "slotset", "")
        g.settings[slotset_index][index] = 0
        AETHERGEM_MGR_SAVE_SETTINGS()
        AETHERGEM_MGR_GEM_SETTING(frame, nil, nil, nil)
    end

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
            local lv_text = slot:CreateOrGetControl('richtext', 'lv_text', 0, 25, 25, 25)
            AUTO_CAST(lv_text)
            if string.find(name, "480") ~= nil then
                lv_text:SetText("{ol}{s14}LV480")
                g.settings[slotset_index][index] = clsid
            elseif string.find(name, "500") ~= nil then

                lv_text:SetText("{ol}{s14}LV500")
                g.settings[slotset_index][index] = clsid
            elseif string.find(name, "520") ~= nil then

                lv_text:SetText("{ol}{s14}LV520")
                g.settings[slotset_index][index] = clsid
            else

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
            -- g.settings[g.cid] = g.settings[slotset_index]
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

            if clsid ~= 0 then
                local item_cls = GetClassByType("Item", clsid)
                if item_cls ~= nil then

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

local equips = {"RH", "LH", "RH_SUB", "LH_SUB"}

function aethergem_mgr_gem_operation()

    local setting_frame = ui.GetFrame(addonNameLower .. "setting_frame")
    if setting_frame ~= nil then
        AUTO_CAST(setting_frame)
        setting_frame:ShowWindow(0)
    end

    if TUTORIAL_CLEAR_CHECK(GetMyPCObject()) == false then
        ui.SysMsg(ClMsg('CanUseAfterTutorialClear'))
        return
    end

    local equip_count = 0
    local unequip_count = 0
    g.guids = {}

    local inv_frame = ui.GetFrame("inventory")
    for _, slot_name in ipairs(equips) do
        local equip_slot = GET_CHILD_RECURSIVELY(inv_frame, slot_name)
        local icon = equip_slot:GetIcon()

        if icon ~= nil then
            local icon_info = icon:GetInfo()
            local guid = icon_info:GetIESID()
            local equip_item = session.GetEquipItemByGuid(guid)
            --[[local type = icon_info.type
            local item_cls = GetClassByType("Item", type)
            local equipItem = session.GetEquipItemByType(type)]]
            local available = equip_item:IsAvailableSocket(2)
            if available then
                local gem_id = equip_item:GetEquipGemID(2)

                if gem_id ~= 0 then
                    table.insert(g.guids, guid)
                    equip_count = equip_count + 1
                else
                    table.insert(g.guids, guid)
                    unequip_count = unequip_count + 1
                end
            end
        end
    end

    local frame = ui.GetFrame("goddess_equip_manager")

    local delay = g.settings.delay
    if equip_count == 4 then

        for _, equip in ipairs(equips) do
            if equip == "RH" then
                item.UnEquip(8)
            elseif equip == "LH" then
                ReserveScript(string.format("item.UnEquip(%d)", 9), delay)
            elseif equip == "RH_SUB" then
                ReserveScript(string.format("item.UnEquip(%d)", 30), delay)
            end
            delay = delay + g.settings.delay
        end

        DO_WEAPON_SLOT_CHANGE(inv_frame, 1)
        local inv_tab = GET_CHILD_RECURSIVELY(inv_frame, "inventype_Tab")
        inv_tab:SelectTab(6)

        frame:ShowWindow(1)
        local main_tab = GET_CHILD_RECURSIVELY(frame, 'main_tab')
        main_tab:SelectTab(2)
        frame:SetLayerLevel(101)

        function aethergem_mgr_gem_remove(guid)
            local tx_name = 'GODDESS_SOCKET_AETHER_GEM_UNEQUIP'
            pc.ReqExecuteTx_Item(tx_name, guid, 2)
        end

        for i, iesid in ipairs(g.guids) do
            local scp = string.format("aethergem_mgr_GODDESS_MGR_SOCKET_REG_ITEM('%s')", iesid)
            ReserveScript(scp, delay)
            delay = delay + g.settings.delay
            scp = string.format("aethergem_mgr_gem_remove('%s')", iesid)
            ReserveScript(scp, delay)
            delay = delay + g.settings.delay
        end
        ReserveScript("aethergem_mgr_equip()", delay)
    elseif unequip_count == 4 then

        if next(g.settings[g.cid]) == nil then
            ui.SysMsg(g.lang == "Japanese" and
                          "このキャラクターには装着するエーテルジェム が登録されていません" or
                          "There are no Aether Gem registered for this character to wear.")
            return
        end
        local use_index = g.settings[g.cid].use_index
        for i = 1, 4 do

            local clsid = g.settings[use_index][tostring(i)]
            local gem_item = session.GetInvItemByType(clsid)
            if gem_item == nil then
                ui.SysMsg(g.lang == "Japanese" and
                              "登録したエーテルジェム がインベントリーにありません" or
                              "The registered Aether Gem is missing from inventory.")
                return
            end
        end

        for _, equip in ipairs(equips) do
            if equip == "RH" then
                item.UnEquip(8)
            elseif equip == "LH" then
                ReserveScript(string.format("item.UnEquip(%d)", 9), delay)
            elseif equip == "RH_SUB" then
                ReserveScript(string.format("item.UnEquip(%d)", 30), delay)
            end
            delay = delay + g.settings.delay
        end

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

            for index, clsid in pairs(g.settings[use_index]) do
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

        DO_WEAPON_SLOT_CHANGE(inv_frame, 1)
        local inv_tab = GET_CHILD_RECURSIVELY(inv_frame, "inventype_Tab")
        inv_tab:SelectTab(6)

        frame:ShowWindow(1)
        local main_tab = GET_CHILD_RECURSIVELY(frame, 'main_tab')
        main_tab:SelectTab(2)
        frame:SetLayerLevel(101)

        for i = 1, 4 do
            local iesid = g.guids[i]
            local scp = string.format("aethergem_mgr_GODDESS_MGR_SOCKET_REG_ITEM('%s')", iesid)
            ReserveScript(scp, delay)
            delay = delay + g.settings.delay
            scp = string.format("aethergem_mgr_gem_equip(%d)", i)
            ReserveScript(scp, delay)
            delay = delay + g.settings.delay
        end
        ReserveScript("aethergem_mgr_equip()", delay)
    else
        ui.SysMsg(g.lang == "Japanese" and "武器を4ケ所装備して使用してください" or
                      "Please equip 4 places with weapons before use.")
        return
    end
end

function aethergem_mgr_gem_equip(i)

    local use_index = g.settings[g.cid].use_index
    local clsid = g.settings[use_index][tostring(i)]
    local gem_item = session.GetInvItemByType(clsid)
    local gem_guid = nil

    for j, item in ipairs(g.level) do
        local level = item.level
        local cls_id = item.clsid
        local iesid = item.iesid
        if cls_id == clsid then
            gem_guid = iesid
            table.remove(g.level, j)
            break
        end
    end

    local gem_obj = GetIES(gem_item:GetObject())
    local equip_item = session.GetInvItemByGuid(g.guids[i])

    if equip_item == nil then
        return
    end
    local equip_obj = GetIES(equip_item:GetObject())

    session.ResetItemList()
    session.AddItemID(g.guids[i], 1)
    session.AddItemID(gem_guid, 1)
    local arg_list = NewStringList()
    arg_list:Add(tostring(2))
    local result_list = session.GetItemIDList()
    item.DialogTransaction('GODDESS_SOCKET_AETHER_GEM_EQUIP', result_list, '', arg_list)

    local frame = ui.GetFrame("goddess_equip_manager")
    frame:RunUpdateScript("aethergem_mgr_end", g.settings.delay + 0.1)
end

function aethergem_mgr_end()
    local inv_frame = ui.GetFrame("inventory")
    local equip_slot = GET_CHILD_RECURSIVELY(inv_frame, "LH_SUB")
    local icon = equip_slot:GetIcon()
    g.time = g.time + g.settings.delay
    if icon ~= nil then

        local frame = ui.GetFrame("goddess_equip_manager")
        frame:SetVisible(0);
        ui.SysMsg("[AGM]End of Operation")
        return 0
    elseif icon == nil and g.time >= g.settings.delay * 6 then
        local frame = ui.GetFrame("goddess_equip_manager")
        frame:StopUpdateScript("aethergem_mgr_end")
        aethergem_mgr_equip()
        return 0
    else
        return 1
    end
end

function aethergem_mgr_equip()

    local delay = 0
    for i = 1, 4 do
        local guid = g.guids[i]
        local invitem = session.GetInvItemByGuid(guid);
        if invitem ~= nil then
            local index = invitem.invIndex
            local spotname = nil
            if i == 1 then
                spotname = "RH"
            elseif i == 2 then
                spotname = "LH"
            elseif i == 3 then
                spotname = "RH_SUB"
            elseif i == 4 then
                spotname = "LH_SUB"
            end
            if i ~= 4 then
                ReserveScript(string.format("ITEM_EQUIP(%d,'%s')", index, spotname), delay)
                delay = delay + g.settings.delay
            else
                ReserveScript(string.format("ITEM_EQUIP(%d,'%s')", index, spotname), delay + g.settings.delay)
            end
        end
    end
    g.time = 0
    local frame = ui.GetFrame("goddess_equip_manager")
    frame:RunUpdateScript("aethergem_mgr_end", g.settings.delay)
end

function aethergem_mgr_GODDESS_MGR_SOCKET_REG_ITEM(iesid)
    local frame = ui.GetFrame('goddess_equip_manager')
    local inv_item = session.GetInvItemByGuid(iesid)
    local item_obj = GetIES(inv_item:GetObject())

    if inv_item == nil or item_obj == nil then
        return
    end

    if item_goddess_transcend.is_able_to_socket(item_obj) == false then
        ui.SysMsg(ClMsg('WebService_38'))
        return
    end

    if TryGetProp(item_obj, 'ItemGrade', 0) < 6 then
        ui.SysMsg(ClMsg('GoddessGradeItemOnly'))
        return
    end

    local weapon_tooltip_title = GET_CHILD_RECURSIVELY(frame, 'weapon_tooltip_title')
    local weapon_tooltip = GET_CHILD_RECURSIVELY(frame, 'weapon_tooltip')
    local armor_tooltip_title = GET_CHILD_RECURSIVELY(frame, 'armor_tooltip_title')
    local armor_tooltip = GET_CHILD_RECURSIVELY(frame, 'armor_tooltip')

    local slot = GET_CHILD_RECURSIVELY(frame, 'socket_slot')
    SET_SLOT_ITEM(slot, inv_item)
    slot:SetUserValue('ITEM_GUID', inv_item:GetIESID())
    slot:SetUserValue('ITEM_USE_LEVEL', TryGetProp(item_obj, 'UseLv', 1))

    local slot_pic = GET_CHILD_RECURSIVELY(frame, 'socket_slot_bg_image')
    slot_pic:ShowWindow(0)

    local socket_item_text = GET_CHILD_RECURSIVELY(frame, 'socket_item_text')
    socket_item_text:ShowWindow(0)

    local socket_item_name = GET_CHILD_RECURSIVELY(frame, 'socket_item_name')
    socket_item_name:SetTextByKey('name', dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'NONE')))
    socket_item_name:ShowWindow(1)

    local open_mat_slot = GET_CHILD_RECURSIVELY(frame, 'aether_open_mat_slot')
    open_mat_slot:ClearIcon()

    local equipGroup = TryGetProp(item_obj, 'EquipGroup', 'None')
    if equipGroup == 'THWeapon' or equipGroup == 'SubWeapon' or equipGroup == 'Weapon' then
        weapon_tooltip_title:ShowWindow(1)
        weapon_tooltip:ShowWindow(1)
        armor_tooltip_title:ShowWindow(0)
        armor_tooltip:ShowWindow(0)
    elseif equipGroup == 'SHIRT' or equipGroup == 'PANTS' or equipGroup == 'BOOTS' or equipGroup == 'GLOVES' then
        weapon_tooltip_title:ShowWindow(0)
        weapon_tooltip:ShowWindow(0)
        armor_tooltip_title:ShowWindow(1)
        armor_tooltip:ShowWindow(1)
    end

    GODDESS_MGR_SOCKET_NORMAL_UPDATE(frame)
    GODDESS_MGR_SOCKET_AETHER_UPDATE(frame)
end

--[[function aethergem_mgr_un_equip()

    ReserveScript("aethergem_mgr_gemframe_set()", g.settings.delay * 3)
end

function aethergem_mgr_gemframe_set()
    local frame = ui.GetFrame('goddess_equip_manager')
    frame:ShowWindow(1)
    local main_tab = GET_CHILD_RECURSIVELY(frame, 'main_tab')
    main_tab:SelectTab(2)
    frame:SetLayerLevel(101)
    ReserveScript("aethergem_mgr_reg_item()", g.settings.delay)
end

function aethergem_mgr_reg_item(frame)

    for i, iesid in ipairs(g.guids) do
        local scp = string.format("aethergem_mgr_GODDESS_MGR_SOCKET_REG_ITEM('%s')", iesid)
        ReserveScript(scp, i * g.settings.delay)
        scp = string.format("aethergem_mgr_gem_remove('%s')", iesid)
        ReserveScript(scp, (i * g.settings.delay) + (g.settings.delay / 2))
    end
end

function AETHERGEM_MGR_EQUIP()

    local frame = ui.GetFrame("inventory")
    local delay = g.settings.delay
    DO_WEAPON_SLOT_CHANGE(frame, 1)
    for i = 1, 4 do
        local guid = g.guids[i]
        local invitem = session.GetInvItemByGuid(guid);
        if invitem ~= nil then
            local index = invitem.invIndex
            local spotname = nil
            if i == 1 then
                spotname = "RH"
            elseif i == 2 then
                spotname = "LH"
            elseif i == 3 then
                spotname = "RH_SUB"
            elseif i == 4 then
                spotname = "LH_SUB"
            end
            ReserveScript(string.format("ITEM_EQUIP(%d,'%s')", index, spotname), delay)
            if i < 4 then
                delay = delay + delay
            end
        end
    end

    frame:RunUpdateScript("AETHERGEM_MGR_END", g.settings.delay)
    -- ReserveScript("AETHERGEM_MGR_END()", delay + 0.1)
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

