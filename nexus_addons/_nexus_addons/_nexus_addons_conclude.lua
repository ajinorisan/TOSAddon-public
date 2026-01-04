local addon_name = "_NEXUS_ADDONS"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]
local json = require("json")

local function ts(...)
    local num_args = select("#", ...)
    if num_args == 0 then
        print("ts() -- 引数がありません")
        return
    end
    local string_parts = {}
    for i = 1, num_args do
        local arg = select(i, ...)
        local arg_type = type(arg)
        local is_success, value_str = pcall(tostring, arg)
        if not is_success then
            value_str = "[tostringでエラー発生]"
        end
        table.insert(string_parts, string.format("(%s) %s", arg_type, value_str))
    end
    print(table.concat(string_parts, "   |   "))
end

-- goddess_icor_manager ここから
g.gim_slot_list = {{
    slot_name = 'RH',
    clmsg = 'RH'
}, {
    slot_name = 'LH',
    clmsg = 'LH'
}, {
    slot_name = 'SHIRT',
    clmsg = 'Shirt'
}, {
    slot_name = 'PANTS',
    clmsg = 'Pants'
}, {
    slot_name = 'GLOVES',
    clmsg = 'Gloves'
}, {
    slot_name = 'BOOTS',
    clmsg = 'Boots'
}, {
    slot_name = 'RH_SUB',
    clmsg = 'RH_SUB'
}, {
    slot_name = 'LH_SUB',
    clmsg = 'LH_SUB'
}}
function Goddess_icor_manager_save_settings()
    g.save_lua(g.gim_path, g.gim_settings)
end

function Goddess_icor_manager_load_settings()
    g.gim_path = string.format("../addons/%s/%s/goddess_icor_manager.lua", addon_name_lower, g.active_id)
    local old_json_path = string.format("../addons/%s/settings.json", "goddess_icor_manager")
    local settings = g.load_lua(g.gim_path)
    local need_save = false
    if not settings then
        local valid_cids = {}
        local sys_opt_path = string.format("../release/addon_setting/system_option/%s/settings.json", g.active_id)
        local sys_opt_file = io.open(sys_opt_path, "r")
        if sys_opt_file then
            local content = sys_opt_file:read("*a")
            sys_opt_file:close()
            if content and content ~= "" then
                local status, data = pcall(json.decode, content)
                if status and data and data.pc_id then
                    for cid, _ in pairs(data.pc_id) do
                        valid_cids[cid] = true
                    end
                end
            end
        end
        valid_cids[g.cid] = true
        local old_settings = g.load_json(old_json_path)
        if old_settings then
            settings = {
                delay = old_settings.delay or 0.6
            }
            for cid, data in pairs(old_settings) do
                if valid_cids[cid] then
                    settings[cid] = data
                end
            end
            need_save = true
        end
    end
    if not settings then
        settings = {
            delay = 0.6
        }
        need_save = true
    end
    g.gim_settings = settings
    if need_save then
        Goddess_icor_manager_save_settings()
    end
end

function Goddess_icor_manager_char_load_settings()
    if not g.gim_settings[g.cid] then
        g.gim_settings[g.cid] = {
            drop_items = {},
            icor_ids = {}
        }
        for i = 1, 9 do
            table.insert(g.gim_settings[g.cid].drop_items, {
                set_name = "Set " .. i,
                set = {}
            })
        end
        Goddess_icor_manager_save_settings()
    end
end

function goddess_icor_manager_on_init()
    if not g.gim_settings then
        Goddess_icor_manager_load_settings()
    end
    if g.get_map_type() == "City" then
        Goddess_icor_manager_char_load_settings()
        Goddess_icor_manager_frame_init()
    end
    g.addon:RegisterMsg('ESCAPE_PRESSED', 'Goddess_icor_manager_list_close')
    g.setup_hook(Goddess_icor_manager__GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_EXEC,
        "_GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_EXEC")
    g.setup_hook_and_event(g.addon, "GODDESS_EQUIP_MANAGER_OPEN", "Goddess_icor_manager_GODDESS_EQUIP_MANAGER_OPEN",
        true)
end

function Goddess_icor_manager_frame_init()
    local inventory = ui.GetFrame('inventory')
    local inventoryGbox = inventory:GetChild("inventoryGbox")
    inventoryGbox:RemoveChild("icor_btn")
    local icor_pic = inventory:CreateOrGetControl("picture", "icor_pic", 440, 345, 30, 30)
    AUTO_CAST(icor_pic) -- 11201008
    local icor_cls = GetClassByType("Item", 11201008)
    icor_pic:SetImage(icor_cls.Icon)
    icor_pic:SetEnableStretch(1)
    icor_pic:SetSkinName("test_red_button")
    icor_pic:SetEventScript(ui.LBUTTONUP, "Goddess_icor_manager_list_init")
    icor_pic:SetTextTooltip("{ol}Goddes Icor Manager")
end

function Goddess_icor_manager_list_init(frame, ctrl, str, page)
    local gim = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "gim", 0, 0, 0, 0)
    gim:Resize(1920, 1060) -- 1000
    gim:SetOffset(0, 5) -- 0,20
    gim:ShowWindow(1)
    gim:SetLayerLevel(121)
    gim:ShowTitleBar(0)
    gim:SetSkinName("test_frame_midle_light")
    gim:RemoveAllChild()
    Goddess_icor_manager_equip_gbox_init(gim, nil)
    --[[if page == 2 then
        g.num = 2
        Goddess_icor_manager_list_gb_init(frame, 2)
    else
        g.num = 1
        Goddess_icor_manager_list_gb_init(frame, 1)
    end]]
end

function Goddess_icor_manager_equip_gbox_init(gim, ctrl_key)
    local equip_gb = gim:CreateOrGetControl("groupbox", "equip_bg", 1430, 5, 485, 1050)
    AUTO_CAST(equip_gb)
    equip_gb:SetSkinName('test_frame_midle_light')
    equip_gb:RemoveAllChild()
    local close = equip_gb:CreateOrGetControl("button", "close", 0, 0, 30, 30)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "Goddess_icor_manager_list_close")
    local swapbtn = equip_gb:CreateOrGetControl("button", "swapbtn", 0, 0, 35, 35)
    swapbtn:SetText("{img sysmenu_skill 35 35}")
    AUTO_CAST(swapbtn)
    swapbtn:SetSkinName("test_pvp_btn")
    swapbtn:SetEventScript(ui.LBUTTONUP, "Goddess_icor_manager_swap_weapon")
    swapbtn:SetTextTooltip(g.lang == "Japanese" and "{ol}武器の裏表切替" or
                               "{ol}Swap the reverse side of weapons")
    local icor_save = equip_gb:CreateOrGetControl("button", "icor_save", 45, 0, 80, 35)
    local text = g.lang == "Japanese" and "{@st66b}刻印保存" or "{@st66b}Icor save"
    icor_save:SetText(text)
    AUTO_CAST(icor_save)
    icor_save:SetSkinName("test_pvp_btn")
    icor_save:SetEventScript(ui.LBUTTONUP, "Goddess_icor_manager_icor_save_open")
    local delay_edit = equip_gb:CreateOrGetControl('edit', 'delay_edit', 130, 2, 50, 30)
    AUTO_CAST(delay_edit)
    delay_edit:SetFontName("white_16_ol")
    delay_edit:SetTextAlign("center", "center")
    delay_edit:SetText(g.gim_settings.delay or 0.5)
    local msg = g.lang == "Japanese" and "{ol}ディレイ設定 デフォルトは0.6秒" or
                    "{ol}Delay setting Default is 0.6 sec."
    delay_edit:SetTextTooltip(msg)
    delay_edit:SetEventScript(ui.ENTERKEY, "Goddess_icor_manager_setting_delay")
    local set_droplist = equip_gb:CreateOrGetControl('droplist', 'set_droplist', 180, 35, 250, 35)
    AUTO_CAST(set_droplist)
    set_droplist:SetSkinName('droplist_normal')
    set_droplist:EnableHitTest(1)
    set_droplist:SetTextAlign("center", "center")
    set_droplist:SetSelectedScp("Goddess_icor_manager_droplist_select")
    set_droplist:AddItem(0, " ")
    set_droplist:SelectItem(ctrl_key or 0)
    set_droplist:Invalidate()
    for key, data in ipairs(g.gim_settings[g.cid].drop_items) do
        set_droplist:AddItem(key, "{ol}" .. data.set_name)
    end
    local save_btn = equip_gb:CreateOrGetControl("button", "save_btn", set_droplist:GetX() + 10, 5, 80, 30)
    AUTO_CAST(save_btn)
    save_btn:SetText(g.lang == "Japanese" and "{ol}保存" or "{ol}Save")
    -- save_btn:SetEventScript(ui.LBUTTONUP, "Goddess_icor_manager_set_save")
    save_btn:SetEventScriptArgNumber(ui.LBUTTONUP, ctrl_key)
    save_btn:SetTextTooltip(g.lang == "Japanese" and "{ol}装備中のイコルセットを保存します" or
                                "{ol}Save icorset being equipped")
    local delete_btn = equip_gb:CreateOrGetControl("button", "delete_btn", set_droplist:GetX() + 90, 5, 80, 30)
    AUTO_CAST(delete_btn)
    delete_btn:SetText(g.lang == "Japanese" and "{ol}削除" or "{ol}Delete")
    -- delete_btn:SetEventScript(ui.LBUTTONUP, "Goddess_icor_manager_set_delete")
    delete_btn:SetEventScriptArgNumber(ui.LBUTTONUP, ctrl_key)
    local keyword_jp = "(保存済)"
    local keyword_en = "(saved)"
    local found_jp = string.find(g.gim_settings[g.cid].drop_items[ctrl_key].set_name, keyword_jp, 1, true)
    local found_en = string.find(g.gim_settings[g.cid].drop_items[ctrl_key].set_name, keyword_en, 1, true)
    if found_jp or found_en then
        local change_btn = equip_gb:CreateOrGetControl("button", "change_btn", set_droplist:GetX() + 170, 5, 80, 30)
        AUTO_CAST(change_btn)
        change_btn:SetText(g.lang == "Japanese" and "{ol}付替" or "{ol}change")
        -- change_btn:SetEventScript(ui.LBUTTONUP, "Goddess_icor_manager_set_change")
        -- change_btn:SetEventScriptArgNumber(ui.LBUTTONUP, ctrl_key)
    end
    local x = 5
    local y = 50
    local yy = 50
    for i = 1, #g.gim_slot_list do
        local new_bg
        if i <= 2 or i >= 7 then
            new_bg = equip_gb:CreateOrGetControl("groupbox", "new_bg" .. i, x, y + 10, 240, 130)
            y = y + 131
        elseif i <= 6 or i >= 3 then
            new_bg = equip_gb:CreateOrGetControl("groupbox", "new_bg" .. i, x + 245, yy + 10, 240, 130)
            yy = yy + 131
        end
        AUTO_CAST(new_bg)
        new_bg:SetSkinName("test_frame_midle_light")
    end
    for i = 1, #g.gim_slot_list do
        local slot_info = g.gim_slot_list[i]
        local new_bg = GET_CHILD(equip_gb, "new_bg" .. i)
        local slot = new_bg:CreateOrGetControl("richtext", "slot" .. i, 5, 5)
        AUTO_CAST(slot)
        slot:SetText("{ol}" .. ClMsg(slot_info.clmsg))
        local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_info.slot_name))
        local item_obj = GetIES(inv_item:GetObject())
        local item_dic = GET_ITEM_RANDOMOPTION_DIC(item_obj)
        local size = item_dic["Size"]
        local y = 25
        if size ~= 0 then
            for j = 1, size do
                local key = "RandomOption_" .. j
                local value_key = "RandomOptionValue_" .. j
                local group_key = "RandomOptionGroup_" .. j
                local bg = GET_CHILD_RECURSIVELY(equip_gb, "new_bg" .. i)
                local text = bg:CreateOrGetControl("richtext", "text" .. j, 5, y)
                AUTO_CAST(text)
                local option = item_dic[key]
                local value = item_dic[value_key]
                local group = item_dic[group_key]
                -- local color = Goddess_icor_manager_color(tostring(group))
                -- text:SetText("{ol}" .. color .. Goddess_icor_manager_language(option) .. "{#FFFFFF} : " .. value)
                y = y + 20
            end
            local bg = GET_CHILD_RECURSIVELY(equip_gb, "new_bg" .. i)
            -- local colortone = Goddess_icor_manager_set_frame_color_equip(bg, size, item_dic, slot)
            -- bg:SetColorTone(colortone)
        end
    end
    local status_bg = equip_gb:CreateOrGetControl("groupbox", "status_bg", 5, 590, 485, 470)
    AUTO_CAST(status_bg)
    status_bg:SetSkinName("bg")
    if not ctrl_key then
        local status_table = {"Cloth_Atk", "Leather_Atk", "Iron_Atk", "Ghost_Atk", "MiddleSize_Def", "Cloth_Def",
                              "Leather_Def", "Iron_Def", "Forester_Atk", "Widling_Atk", "Klaida_Atk", "Paramune_Atk",
                              "Velnias_Atk", "perfection", "revenge"}
        local status = ui.GetFrame("status")
        if status:IsVisible() == 0 then
            ui.OpenFrame("status")
        end
        for i = 1, #status_table do
            local status_str = status_table[i]
            -- Goddess_icor_manager_newframe_set_status(status_bg, status, status_str, i)
        end
    end
    local inventory = ui.GetFrame("inventory")
    DO_WEAPON_SLOT_CHANGE(inventory, 1)
end

function Goddess_icor_manager_droplist_select(frame, ctrl)
    local gim = ui.GetFrame(addon_name_lower .. "gim")
    local ctrl_key = tonumber(ctrl:GetSelItemKey())
    local temp_data = g.gim_settings[g.cid].drop_items[ctrl_key]
    if ctrl_key == 0 then
        Goddess_icor_manager_equip_gbox_init(gim, nil)
    elseif not next(temp_data.set) then
        Goddess_icor_manager_equip_gbox_init(gim, ctrl_key)
    else
        Goddess_icor_manager_equip_gbox_init(gim, ctrl_key)
        local etc_obj = GetMyEtcObject()
        local status_bg = GET_CHILD(frame, "status_bg")
        status_bg:RemoveAllChild()
        g.same = 0
        g.rh = nil
        g.lh = nil
        g.rh_sub = nil
        g.lh_sub = nil
        local cur_strs = {}
        for i = 1, #g.gim_slot_list do
            local new_bg = GET_CHILD(frame, "new_bg" .. i)
            AUTO_CAST(new_bg)
            local slot_info = g.gim_slot_list[i]
            local slot_name = slot_info.slot_name
            local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_name))
            if inv_item and inv_item:GetObject() then
                local item_obj = GetIES(inv_item:GetObject())
                local item_dic = GET_ITEM_RANDOMOPTION_DIC(item_obj)
                if item_dic then
                    local size = item_dic["Size"] or 0
                    if size ~= 0 then
                        local opts, grps, vals = {}, {}, {}
                        for j = 1, size do
                            local key_opt = "RandomOption_" .. j
                            local key_val = "RandomOptionValue_" .. j
                            local key_grp = "RandomOptionGroup_" .. j
                            local opt = item_dic[key_opt]
                            local val = item_dic[key_val]
                            local grp = item_dic[key_grp]
                            table.insert(opts, opt ~= nil and tostring(opt) or "")
                            table.insert(grps, grp ~= nil and tostring(grp) or "")
                            table.insert(vals, val ~= nil and tostring(val) or "")
                        end
                        if #opts > 0 then
                            local cur_opts = table.concat(opts, "/")
                            local cur_grps = table.concat(grps, "/")
                            local cur_vals = table.concat(vals, "/")
                            cur_strs[slot_name] = string.format("%s:%s:%s", cur_opts, cur_grps, cur_vals)
                        end
                    end
                end
            end
            local tgt_str = temp_data.set[slot_name] or ""
            local load_index, load_equip_name = string.match(tgt_str, "^(.-):::(.+)$")
            local eng_opts, eng_grps, eng_vals
            if load_index and load_equip_name then
                eng_opts, eng_grps, eng_vals, _ = Goddess_icor_manager_GET_ENGRAVED_OPTION_LIST(etc_obj,
                    tonumber(load_index), load_equip_name)
            end
            local eng_strs = string.format("%s:%s:%s", tostring(eng_opts or ""), tostring(eng_grps or ""),
                tostring(eng_vals or ""))
            if cur_strs[slot_name] == eng_strs then
                g.same = g.same + 1
            else
                if slot_name == "RH" then
                    g.rh = true
                elseif slot_name == "LH" then
                    g.lh = true
                elseif slot_name == "RH_SUB" then
                    g.rh_sub = true
                elseif slot_name == "LH_SUB" then
                    g.lh_sub = true
                end
            end
            if eng_opts ~= nil then
                local parts1, parts2, parts3 = {}, {}, {}
                for part in eng_opts:gmatch("([^/]+)") do
                    table.insert(parts1, part)
                end
                if eng_grps then
                    for part in eng_grps:gmatch("([^/]+)") do
                        table.insert(parts2, part)
                    end
                end
                if eng_vals then
                    for part in eng_vals:gmatch("([^/]+)") do
                        table.insert(parts3, part)
                    end
                end
                for k_child = new_bg:GetChildCount() - 1, 0, -1 do
                    local child_to_remove = new_bg:GetChildByIndex(k_child)
                    if child_to_remove and string.sub(child_to_remove:GetName(), 1, 4) == "text" then
                        new_bg:RemoveChild(child_to_remove:GetName())
                    end
                end
                local y = 25
                for k = 1, #parts1 do
                    local opt_name = parts1[k]
                    local grp_name = parts2[k]
                    local val = parts3[k]
                    local text = new_bg:CreateOrGetControl("richtext", "text" .. k, 5, y)
                    AUTO_CAST(text)
                    local color = Goddess_icor_manager_color(grp_name)
                    text:SetText("{ol}" .. color .. Goddess_icor_manager_language(opt_name) .. "{ol}{#FFFFFF} : " .. val)
                    y = y + 20
                end
            end
        end
    end
end

function Goddess_icor_manager_icor_save_open(parent, ctrl)
    parent:ShowWindow(0)
    local inputstring = ui.GetFrame('inputstring')
    AUTO_CAST(inputstring)
    inputstring:SetLayerLevel(123) -- 98
    local inventory = ui.GetFrame("inventory")
    inventory:SetLayerLevel(122) -- 95
    local goddess_equip_manager = ui.GetFrame("goddess_equip_manager")
    goddess_equip_manager:ShowWindow(1)
    ui.CloseFrame('rareoption')
    ui.CloseFrame('item_cabinet')
    for i = 1, #revertrandomitemlist do
        local revert_name = revertrandomitemlist[i]
        local revert_frame = ui.GetFrame(revert_name)
        if revert_frame ~= nil and revert_frame:IsVisible() == 1 then
            ui.CloseFrame(revert_name)
        end
    end
    local main_tab = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'main_tab')
    main_tab:SelectTab(1)
    CLEAR_GODDESS_EQUIP_MANAGER(goddess_equip_manager)
    TOGGLE_GODDESS_EQUIP_MANAGER_TAB(goddess_equip_manager, 1)
    ui.OpenFrame('inventory')
    goddess_equip_manager:Resize(485, 460)
    goddess_equip_manager:SetPos(1430, 5)
    goddess_equip_manager:SetLayerLevel(122) -- 92
    local main_tab = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'main_tab')
    main_tab:ShowWindow(0)
    local bg = GET_CHILD(goddess_equip_manager, "bg")
    bg:ShowWindow(1)
    local manager_top = GET_CHILD(goddess_equip_manager, "manager_top")
    manager_top:ShowWindow(0)
    local close = GET_CHILD(goddess_equip_manager, "close")
    close:ShowWindow(0)
    local help = GET_CHILD(goddess_equip_manager, "help")
    help:ShowWindow(0)
    local bg = GET_CHILD(goddess_equip_manager, "bg")
    bg:SetMargin(0, 0, 0, 0)
    local bg_inner = GET_CHILD(bg, "bg_inner")
    bg_inner:SetSkinName("None")
    bg:Resize(485, 460)
    local randomoption_bg = GET_CHILD(bg, "randomoption_bg")
    randomoption_bg:SetSkinName("None")
    randomoption_bg:SetMargin(0, 0, 0, 0)
    local randomoption_tab = GET_CHILD(randomoption_bg, "randomoption_tab")
    randomoption_tab:ShowWindow(0)
    local rand_icor_text = GET_CHILD_RECURSIVELY(randomoption_bg, "rand_icor_text") --
    rand_icor_text:ShowWindow(0)
    local rand_icor_slot = GET_CHILD_RECURSIVELY(randomoption_bg, "rand_icor_slot")
    rand_icor_slot:SetMargin(10, 30, 0, 0)
    local goddess_icor_spot_text = GET_CHILD_RECURSIVELY(randomoption_bg, "goddess_icor_spot_text")
    goddess_icor_spot_text:SetMargin(10, 25, 0, 0)
    local goddess_icor_spot_list = GET_CHILD_RECURSIVELY(randomoption_bg, "goddess_icor_spot_list")
    goddess_icor_spot_list:SetMargin(10, 50, 0, 0)
    local before_preset_option_text = GET_CHILD_RECURSIVELY(randomoption_bg, "before_preset_option_text")
    before_preset_option_text:SetMargin(155, 180, 0, 0)
    local before_preset_option_bg = GET_CHILD_RECURSIVELY(randomoption_bg, "before_preset_option_bg")
    before_preset_option_bg:SetGravity(ui.RIGHT, ui.TOP)
    before_preset_option_bg:Resize(310, 140)
    local current_icor_option_text = GET_CHILD_RECURSIVELY(randomoption_bg, "current_icor_option_text")
    current_icor_option_text:SetMargin(0, 0, 205, 0)
    local current_icor_option_bg = GET_CHILD_RECURSIVELY(randomoption_bg, "current_icor_option_bg")
    AUTO_CAST(current_icor_option_bg)
    current_icor_option_bg:SetGravity(ui.RIGHT, ui.TOP)
    current_icor_option_bg:Resize(310, 140)
    local exec_btn = goddess_equip_manager:CreateOrGetControl("button", "exec_btn", 15, 345, 150, 60)
    local text = g.lang == "Japanese" and "{@st41b}{s18}刻印保存" or "{@st41b}{s18}Icor save"
    exec_btn:SetText(text)
    AUTO_CAST(exec_btn)
    exec_btn:SetSkinName("relic_btn_purple")
    exec_btn:SetEventScript(ui.LBUTTONUP, "GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_EXEC")
    local close_btn = goddess_equip_manager:CreateOrGetControl("button", "close_btn", 0, 0, 30, 30)
    AUTO_CAST(close_btn)
    close_btn:SetImage("testclose_button")
    close_btn:SetGravity(ui.RIGHT, ui.TOP)
    close_btn:SetEventScript(ui.LBUTTONUP, "Goddess_icor_manager_list_close")

    current_icor_option_bg:SetMargin(0, 30, 145, 0)
    before_preset_option_bg:SetMargin(0, 210, 145, 0)
end

function Goddess_icor_manager_swap_weapon(parent, ctrl)
    local inventory = ui.GetFrame("inventory")
    inventory:ShowWindow(1)
    g.gim_guids = {}
    local equips = {"RH", "LH", "RH_SUB", "LH_SUB"}
    local equip_count = 0
    for _, slot_name in ipairs(equips) do
        local equip_slot = GET_CHILD_RECURSIVELY(inventory, slot_name)
        local icon = equip_slot:GetIcon()
        if icon then
            local icon_info = icon:GetInfo()
            local guid = icon_info:GetIESID()
            if guid ~= "0" then
                equip_count = equip_count + 1
                g.gim_guids[slot_name] = guid
            end
        end
    end
    if equip_count < 4 then
        local msg = g.lang == "Japanese" and "{ol}武器4ヶ所着けてください" or
                        "{ol}Please equip weapons in 4 slots"
        ui.SysMsg(msg)
        return
    end
    ctrl:SetUserValue("STEP", 1)
    ctrl:RunUpdateScript("Goddess_icor_manager_swap_weapon_run", 0.1)
end

function Goddess_icor_manager_swap_weapon_run(ctrl)
    local inventory = ui.GetFrame("inventory")
    if inventory:IsVisible() == 0 then
        ctrl:StopUpdateScript("Goddess_icor_manager_swap_weapon_run")
        inventory:SetLayerLevel(95)
        return 0
    end
    inventory:SetLayerLevel(122)
    DO_WEAPON_SLOT_CHANGE(inventory, 1)
    local step = ctrl:GetUserIValue("STEP")
    local spot_nums = {8, 9, 30}
    local equips = {"RH", "LH", "RH_SUB", "LH_SUB"}
    if step <= 3 then
        local guid = g.gim_guids[equips[step]]
        local equip_item = session.GetEquipItemByGuid(guid)
        if not equip_item then
            ctrl:SetUserValue("STEP", step + 1)
        else
            item.UnEquip(spot_nums[step])
        end
        return 1
    end
    if step >= 4 and step <= 7 then
        local guid = nil
        if step == 4 then
            guid = g.gim_guids["RH_SUB"]
        elseif step == 5 then
            guid = g.gim_guids["LH_SUB"]
        elseif step == 6 then
            guid = g.gim_guids["RH"]
        elseif step == 7 then
            guid = g.gim_guids["LH"]
        end
        local inv_item = session.GetInvItemByGuid(guid)
        if inv_item then
            local item_obj = GetIES(inv_item:GetObject())
            local spot_name = equips[step - 3]
            ITEM_EQUIP(inv_item.invIndex, spot_name)
            return 1
        else
            ctrl:SetUserValue("STEP", step + 1)
            return 1
        end
    end
    inventory:SetLayerLevel(95)
    ctrl:StopUpdateScript("Goddess_icor_manager_swap_weapon_run")
    return 0
end

function Goddess_icor_manager_list_close(frame)
    ui.DestroyFrame(addon_name_lower .. "gim")
    local status = ui.GetFrame("status")
    status:ShowWindow(0)
    local goddess_equip_manager = ui.GetFrame("goddess_equip_manager")
    goddess_equip_manager:SetLayerLevel(92) -- 92
    goddess_equip_manager:ShowWindow(0)
    local inventory = ui.GetFrame("inventory")
    inventory:SetLayerLevel(95) -- 95
    local inputstring = ui.GetFrame('inputstring')
    AUTO_CAST(inputstring)
    inputstring:SetLayerLevel(98) -- 98
end

function Goddess_icor_manager_setting_delay(parent, ctrl)
    local delay = tonumber(ctrl:GetText())
    if delay then
        g.gim_settings.delay = delay
        Goddess_icor_manager_save_settings()
        local text = g.lang == "Japanese" and "{ol}ディレイを" .. delay .. "秒に設定しました" or
                         "{ol}Delay is set to " .. delay .. " sec."
        ui.SysMsg(text)
    end
end

function Goddess_icor_manager__GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_EXEC()
    local goddess_equip_manager = ui.GetFrame('goddess_equip_manager')
    if not goddess_equip_manager then
        return
    end
    session.ResetItemList()
    local rand_icor_slot = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'rand_icor_slot')
    local tgt_guid = rand_icor_slot:GetUserValue('ITEM_GUID')
    local tgt_item = session.GetInvItemByGuid(tgt_guid)
    if not tgt_item then
        ui.SysMsg(ClMsg('NoSelectedItem'))
        return
    end
    if tgt_item.isLockState == true then
        ui.SysMsg(ClMsg('MaterialItemIsLock'))
        return
    end
    local obj = GetIES(tgt_item:GetObject())
    session.AddItemID(tgt_guid, 1)
    local randomoption_bg = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'randomoption_bg')
    local index = randomoption_bg:GetUserValue('PRESET_INDEX')
    local spot = rand_icor_slot:GetUserValue('EQUIP_SPOT')
    local arg_list = NewStringList()
    arg_list:Add(index)
    local cls_id = obj.ClassID
    if shared_item_goddess_icor.get_goddess_icor_grade(obj) > 0 then
        arg_list:Add(spot)
    end
    local settings_cid = g.gim_settings[g.cid]
    if not settings_cid.icor_ids then
        settings_cid.icor_ids = {}
    end
    if not settings_cid.icor_ids[index] or type(settings_cid.icor_ids[index]) ~= "table" then
        settings_cid.icor_ids[index] = {}
    end
    settings_cid.icor_ids[index][spot] = cls_id
    local result_list = session.GetItemIDList()
    item.DialogTransaction('ICOR_PRESET_ENGRAVE_ICOR', result_list, '', arg_list)
    Goddess_icor_manager_save_settings()
    local rand_icor_mat_bg = GET_CHILD_RECURSIVELY(goddess_equip_manager, "rand_icor_mat_bg")
    GODDESS_MGR_ENGRAVE_ICOR_CLEAR_BTN(rand_icor_mat_bg)
    ReserveScript("Goddess_icor_manager_list_init()", 0.5)
    ReserveScript("Goddess_icor_manager_newframe_close()", 0.6)
    return
end

function Goddess_icor_manager_GODDESS_EQUIP_MANAGER_OPEN(my_frame, my_msg)
    local goddess_equip_manager = ui.GetFrame("goddess_equip_manager")
    goddess_equip_manager:Resize(1270, 900)
    goddess_equip_manager:SetGravity(ui.LEFT, ui.CENTER_VERT)
    goddess_equip_manager:SetMargin(89, 0, 0, 0);
    goddess_equip_manager:SetLayerLevel(92)
    local main_tab = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'main_tab')
    main_tab:ShowWindow(1)
    local manager_top = GET_CHILD(goddess_equip_manager, "manager_top")
    manager_top:ShowWindow(1)
    local close = GET_CHILD(goddess_equip_manager, "close")
    close:ShowWindow(1)
    local help = GET_CHILD(goddess_equip_manager, "help")
    help:ShowWindow(1)
    local bg = GET_CHILD(goddess_equip_manager, "bg")
    bg:SetMargin(0, 10, 0, 0);
    local bg_inner = GET_CHILD(bg, "bg_inner")
    bg_inner:SetSkinName("relic_frame_bg")
    bg:Resize(1218, 890)
    local randomoption_bg = GET_CHILD(bg, "randomoption_bg")
    randomoption_bg:SetGravity(ui.LEFT, ui.TOP)
    randomoption_bg:SetMargin(112, 66, 0, 0);
    local randomoption_tab = GET_CHILD(randomoption_bg, "randomoption_tab")
    randomoption_tab:ShowWindow(1)
    local rand_icor_slot = GET_CHILD_RECURSIVELY(randomoption_bg, "rand_icor_slot")
    rand_icor_slot:SetMargin(50, 70, 0, 0);
    local goddess_icor_spot_text = GET_CHILD_RECURSIVELY(randomoption_bg, "goddess_icor_spot_text")
    goddess_icor_spot_text:SetMargin(50, 25, 0, 0);
    local goddess_icor_spot_list = GET_CHILD_RECURSIVELY(randomoption_bg, "goddess_icor_spot_list")
    goddess_icor_spot_list:SetMargin(50, 50, 0, 0);
    local before_preset_option_text = GET_CHILD_RECURSIVELY(randomoption_bg, "before_preset_option_text")
    before_preset_option_text:SetMargin(240, 280, 0, 0);
    local before_preset_option_bg = GET_CHILD_RECURSIVELY(randomoption_bg, "before_preset_option_bg")
    before_preset_option_bg:SetMargin(0, 310, 50, 0)
    before_preset_option_bg:Resize(319, 140)
    local current_icor_option_text = GET_CHILD_RECURSIVELY(randomoption_bg, "current_icor_option_text")
    current_icor_option_text:SetMargin(0, 40, 120, 0);
    local current_icor_option_bg = GET_CHILD_RECURSIVELY(randomoption_bg, "current_icor_option_bg")
    current_icor_option_bg:SetMargin(0, 70, 50, 0)
    current_icor_option_bg:Resize(319, 140)
    goddess_equip_manager:RemoveChild("exec_btn")
    goddess_equip_manager:RemoveChild("close_btn")
end

function Goddess_icor_manager_set_save(frame, ctrl, str, ctrl_key)
    local acc = GetMyAccountObj()
    local etc_obj = GetMyEtcObject()
    local remain_time = GET_REMAIN_SECOND_ENGRAVE_SLOT_EXTENSION_TIME(acc)
    local page_max = 0
    if tonumber(remain_time) == 0 then
        page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc)
    else
        page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc) + 5
    end
    local cur_strs = {}
    for i = 1, #g.gim_slot_list do
        local slot_info = g.gim_slot_list[i]
        local slot_name = slot_info.slot_name
        local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_name))
        if inv_item and inv_item:GetObject() then
            local item_obj = GetIES(inv_item:GetObject())
            local item_dic = GET_ITEM_RANDOMOPTION_DIC(item_obj)
            if item_dic then
                local size = item_dic["Size"] or 0
                if size ~= 0 then
                    local opts, grps, vals = {}, {}, {}
                    for j = 1, size do
                        local key_opt = "RandomOption_" .. j
                        local key_val = "RandomOptionValue_" .. j
                        local key_grp = "RandomOptionGroup_" .. j
                        local opt = item_dic[key_opt]
                        local val = item_dic[key_val]
                        local grp = item_dic[key_grp]
                        table.insert(opts, opt ~= nil and tostring(opt) or "")
                        table.insert(grps, grp ~= nil and tostring(grp) or "")
                        table.insert(vals, val ~= nil and tostring(val) or "")
                    end
                    if #opts > 0 then
                        local cur_opts = table.concat(opts, "/")
                        local cur_grps = table.concat(grps, "/")
                        local cur_vals = table.concat(vals, "/")
                        cur_strs[slot_name] = string.format("%s:%s:%s", cur_opts, cur_grps, cur_vals)
                    end
                end
            end
        end
    end
    local eng_count = 0
    local temp_data = g.settings[g.cid].drop_items[ctrl_key]
    for base_equip_name, strs in pairs(cur_strs) do
        for i = 1, page_max do
            temp_data.set[base_equip_name] = ""
            local eng_opts, eng_grps, eng_vals, is_goddess =
                Goddess_icor_manager_GET_ENGRAVED_OPTION_LIST(etc_obj, i, base_equip_name)
            if eng_opts then
                local eng_strs = string.format("%s:%s:%s", tostring(eng_opts or ""), tostring(eng_grps or ""),
                    tostring(eng_vals or ""))
                if strs == eng_strs then
                    temp_data.set[base_equip_name] = i .. ":::" .. base_equip_name
                    eng_count = eng_count + 1
                    if not string.find(base_equip_name, "_SUB") then
                        if cur_strs[base_equip_name] == cur_strs[base_equip_name .. "_SUB"] then
                            temp_data.set[base_equip_name .. "_SUB"] = i .. ":::" .. base_equip_name
                            eng_count = eng_count + 1
                        end
                    else
                        if cur_strs[base_equip_name] == cur_strs[string.gsub(base_equip_name, "_SUB", "")] then
                            temp_data.set[string.gsub(base_equip_name, "_SUB", "")] = i .. ":::" .. base_equip_name
                            eng_count = eng_count + 1
                        end
                    end
                    break
                end
            end
            if temp_data.set[base_equip_name] == "" then
                local change_equip_name = nil
                if base_equip_name == "RH" then
                    change_equip_name = "RH_SUB"
                elseif base_equip_name == "RH_SUB" then
                    change_equip_name = "RH"
                elseif base_equip_name == "LH" then
                    change_equip_name = "LH_SUB"
                elseif base_equip_name == "LH_SUB" then
                    change_equip_name = "LH"
                end
                local eng_opts, eng_grps, eng_vals, is_goddess =
                    Goddess_icor_manager_GET_ENGRAVED_OPTION_LIST(etc_obj, i, change_equip_name)
                if eng_opts then
                    local eng_strs = string.format("%s:%s:%s", tostring(eng_opts or ""), tostring(eng_grps or ""),
                        tostring(eng_vals or ""))
                    if strs == eng_strs then
                        temp_data.set[base_equip_name] = i .. ":::" .. change_equip_name
                        eng_count = eng_count + 1
                        break
                    end
                end
            end
        end
    end
    if eng_count >= 8 then
        Goddess_icor_INPUT_STRING_BOX(ctrl_key)
    else
        local text = g.lang == "Japanese" and "{ol}付替え不可のため保存できません" or
                         "{ol}Cannot be saved as it is not replaceable"
        ui.SysMsg(text)
    end
end

function Goddess_icor_manager_GET_ENGRAVED_OPTION_LIST(etc, index, spot)
    if etc == nil then
        return nil
    end
    local suffix = string.format('_%d_%s', tonumber(index), spot)
    local option_prop = TryGetProp(etc, 'RandomOptionPreset' .. suffix, 'None')
    local group_prop = TryGetProp(etc, 'RandomOptionGroupPreset' .. suffix, 'None')
    local value_prop = TryGetProp(etc, 'RandomOptionValuePreset' .. suffix, 'None')
    if option_prop == 'None' then
        return nil
    end
    local option_list = SCR_STRING_CUT(option_prop, '/')
    local group_list = SCR_STRING_CUT(group_prop, '/')
    local value_list = SCR_STRING_CUT(value_prop, '/')
    local is_goddess_option = TryGetProp(etc, 'IsGoddessIcorOption' .. suffix, 0)
    return option_prop, group_prop, value_prop, is_goddess_option
end

function Goddess_icor_manager_save_setname(inputstring, ctrl, str, ctrl_key)
    inputstring:ShowWindow(0)
    local edit = GET_CHILD(inputstring, 'input')
    local get_text = edit:GetText()
    if get_text == "" then
        local text = g.lang == "Japanese" and "{ol}文字を入力してください" or "{ol}Please enter text"
        ui.SysMsg(text)
        Goddess_icor_INPUT_STRING_BOX(ctrl_key)
        return
    end
    local text = g.lang == "Japanese" and "{ol}セットを登録しました" or "{ol}Set registered"
    ui.SysMsg(text)
    text = g.lang == "Japanese" and "(保存済)" or "(saved)"
    g.settings[g.cid].drop_items[ctrl_key].set_name = get_text .. text
    g.save_json(g.settings_path, g.settings)
    Goddess_icor_manager_newframe_init(ctrl_key)
end

function Goddess_icor_INPUT_STRING_BOX(ctrl_key)
    local inputstring = ui.GetFrame("inputstring")
    inputstring:Resize(500, 220)
    inputstring:SetLayerLevel(999)
    local edit = GET_CHILD(inputstring, 'input', "ui::CEditControl")
    edit:SetNumberMode(0)
    edit:SetMaxLen(999)
    edit:SetText("")
    inputstring:ShowWindow(1)
    inputstring:SetEnable(1)
    local title = inputstring:GetChild("title")
    AUTO_CAST(title)
    local text = g.lang == "Japanese" and "{ol}{#FFFFFF}セット名を入力" or "{ol}{#FFFFFF}Enter set name"
    title:SetText(text)
    local confirm = inputstring:GetChild("confirm")
    confirm:SetEventScript(ui.LBUTTONUP, "Goddess_icor_manager_save_setname")
    confirm:SetEventScriptArgNumber(ui.LBUTTONUP, ctrl_key)
    edit:SetEventScript(ui.ENTERKEY, "Goddess_icor_manager_save_setname")
    edit:SetEventScriptArgNumber(ui.ENTERKEY, ctrl_key)
    edit:AcquireFocus()
end

function Goddess_icor_manager_set_delete_(ctrl_key)
    g.settings[g.cid].drop_items[ctrl_key] = nil
    g.settings[g.cid].drop_items[ctrl_key] = {
        set_name = "Set " .. ctrl_key,
        set = {}
    }
    g.save_json(g.settings_path, g.settings)
    local text = g.lang == "Japanese" and "{ol}セットを削除しました" or "{ol}Set removed"
    ui.SysMsg(text)
    Goddess_icor_manager_newframe_init()
end

function Goddess_icor_manager_set_delete(frame, ctrl, str, ctrl_key)
    local msg = g.lang == "Japanese" and "{ol}{#FFFFFF}セットを削除しますか？" or
                    "{ol}{#FFFFFF}Do you want to remove the set?"
    ui.MsgBox(msg, string.format("Goddess_icor_manager_set_delete_(%d)", ctrl_key), "None")
end

function Goddess_icor_manager_set_end()
    local notice = ui.GetFrame("notice")
    AUTO_CAST(notice)
    notice:ShowWindow(0)
    ui.SysMsg("{#FFFF00}[GIM]End of Operation")
    ReserveScript(string.format("Goddess_icor_manager_list_init('%s','%s','%s',%d)", _, _, _, g.num or 1),
        g.settings.delay or 0.5)
    return
end

function Goddess_icor_manager_set_error_end(frame)
    local newframe = ui.GetFrame("Goddess_icor_manager_newframe")
    if newframe:IsVisible() == 0 then
        local notice = ui.GetFrame("notice")
        AUTO_CAST(notice)
        notice:ShowWindow(0)
        local msg = g.lang == "Japanese" and "{ol}{s30}{#FFFF00}[GIM]エラーのため動作を終了します" or
                        "{ol}{s30}{#FFFF00}[GIM]Operation terminated due to error"
        ui.SysMsg(msg)
        Goddess_icor_manager_newframe_init()
        return
    end
end

function Goddess_icor_manager_set_change(frame, ctrl, str, ctrl_key, step)
    g.ctrl_key = ctrl_key
    for i = 1, #g.gim_slot_list do
        local slot_info = g.gim_slot_list[i]
        local slot_name = slot_info.slot_name
        local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_name))
        local guid = inv_item:GetIESID()
        if guid == "0" then
            local text = g.lang == "Japanese" and "{ol}装備を8ヶ所に着けてから起動してください" or
                             "{ol}Wear the equipment in 8 places before activating it"
            ui.SysMsg(text)
            return
        end
    end
    if g.same == 8 then
        local text = g.lang == "Japanese" and "{ol}現在装備中と同一のセットです" or
                         "{ol}This is the same set you currently have equipped"
        ui.SysMsg(text)
        return
    end
    local acc = GetMyAccountObj()
    local remain_time = GET_REMAIN_SECOND_ENGRAVE_SLOT_EXTENSION_TIME(acc)
    local page_max = 0
    if tonumber(remain_time) == 0 then
        page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc)
    else
        page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc) + 5
    end
    for j = 1, #g.gim_slot_list do
        local cur_slot_name = g.gim_slot_list[j].slot_name
        local tgt_str = g.settings[g.cid].drop_items[ctrl_key].set[cur_slot_name]
        local load_index, load_equip_name = string.match(tgt_str, "^(.-):::(.+)$")
        if tonumber(load_index) > page_max then
            local text = g.lang == "Japanese" and
                             "{ol}保存しているイコルが使用不可のため、終了します" or
                             "{ol}Process terminated Stored Icor is unavailable"
            ui.SysMsg(text)
            return
        end
    end
    local notice = g.lang == "Japanese" and
                       "{ol}[GIM]セット適用中{nl}バグ防止のため操作をしないでください" or
                       "{ol}[GIM]set is being applied{nl}Do not operate to prevent bugs"
    imcAddOn.BroadMsg("NOTICE_Dm_stage_start", notice)
    local newframe = ui.GetFrame("Goddess_icor_manager_newframe")
    newframe:ShowWindow(0)
    local Goddess_icor_manager = ui.GetFrame("Goddess_icor_manager")
    Goddess_icor_manager:RunUpdateScript("Goddess_icor_manager_set_error_end", (g.settings.delay or 0.5) * 6 * 2)
    local etc_obj = GetMyEtcObject()
    local temp_data = g.settings[g.cid].drop_items[ctrl_key]
    local cur_strs = {}
    local spot_names = ""
    step = step or 1
    for i = 1, #g.gim_slot_list do
        local slot_info = g.gim_slot_list[i]
        local slot_name = slot_info.slot_name
        local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_name))
        if inv_item and inv_item:GetObject() then
            local item_obj = GetIES(inv_item:GetObject())
            local item_dic = GET_ITEM_RANDOMOPTION_DIC(item_obj)
            if item_dic then
                local size = item_dic["Size"] or 0
                if size ~= 0 then
                    local opts, grps, vals = {}, {}, {}
                    for j = 1, size do
                        local key_opt = "RandomOption_" .. j
                        local key_val = "RandomOptionValue_" .. j
                        local key_grp = "RandomOptionGroup_" .. j
                        local opt = item_dic[key_opt]
                        local val = item_dic[key_val]
                        local grp = item_dic[key_grp]
                        table.insert(opts, opt ~= nil and tostring(opt) or "")
                        table.insert(grps, grp ~= nil and tostring(grp) or "")
                        table.insert(vals, val ~= nil and tostring(val) or "")
                    end
                    if #opts > 0 then
                        local cur_opts = table.concat(opts, "/")
                        local cur_grps = table.concat(grps, "/")
                        local cur_vals = table.concat(vals, "/")
                        cur_strs[slot_name] = string.format("%s:%s:%s", cur_opts, cur_grps, cur_vals)
                    end
                end
            end
        end
    end
    if step == 1 then
        for base_equip_name, strs in pairs(cur_strs) do
            if not string.find(base_equip_name, "RH") and not string.find(base_equip_name, "LH") then
                local tgt_str = temp_data.set[base_equip_name]
                local load_index, load_equip_name = string.match(tgt_str, "^(.-):::(.+)$")
                local eng_opts, eng_grps, eng_vals, is_goddess =
                    Goddess_icor_manager_GET_ENGRAVED_OPTION_LIST(etc_obj, tonumber(load_index), load_equip_name)
                local eng_strs = string.format("%s:%s:%s", tostring(eng_opts or ""), tostring(eng_grps or ""),
                    tostring(eng_vals or ""))
                if cur_strs[base_equip_name] ~= eng_strs then
                    spot_names = spot_names .. ":::" .. base_equip_name
                end
            end
        end
        if spot_names ~= "" then
            Goddess_icor_manager_set_change_action(ctrl_key, spot_names, step)
        else
            if g.rh or g.lh or g.rh_sub or g.lh_sub then
                Goddess_icor_manager_set_change(_, _, _, ctrl_key, 2)
            else
                Goddess_icor_manager_set_end()
            end
        end
    elseif step == 2 then -- ぶ
        g.swap = nil
        for base_equip_name, strs in pairs(cur_strs) do
            if string.find(base_equip_name, "RH") or string.find(base_equip_name, "LH") then
                local tgt_str = temp_data.set[base_equip_name]
                local load_index, load_equip_name = string.match(tgt_str, "^(.-):::(.+)$")
                if base_equip_name == "RH" and g.rh then
                    if base_equip_name == load_equip_name then
                        spot_names = spot_names .. ":::" .. base_equip_name
                        g.rh = false
                    end
                elseif base_equip_name == "LH" and g.lh then
                    if base_equip_name == load_equip_name then
                        spot_names = spot_names .. ":::" .. base_equip_name
                        g.lh = false
                    end
                elseif base_equip_name == "RH_SUB" and g.rh_sub then
                    if base_equip_name == load_equip_name then
                        spot_names = spot_names .. ":::" .. base_equip_name
                        g.rh_sub = false
                    end
                elseif base_equip_name == "LH_SUB" and g.lh_sub then
                    if base_equip_name == load_equip_name then
                        spot_names = spot_names .. ":::" .. base_equip_name
                        g.lh_sub = false
                    end
                end
            end
        end
        if spot_names ~= "" then
            Goddess_icor_manager_set_change_action(ctrl_key, spot_names, step)
        else
            if g.rh or g.lh or g.rh_sub or g.lh_sub then
                Goddess_icor_manager_set_change(_, _, _, ctrl_key, 3)
            else
                Goddess_icor_manager_set_end()
            end
        end
    elseif step == 3 then -- swap
        if g.rh or g.lh or g.rh_sub or g.lh_sub then
            g.swap = true
            Goddess_icor_manager_swap_weapon()
        else
            Goddess_icor_manager_set_end()
        end
    elseif step == 4 then -- 裏武器
        for base_equip_name, strs in pairs(cur_strs) do
            if string.find(base_equip_name, "RH") or string.find(base_equip_name, "LH") then
                local tgt_str = temp_data.set[base_equip_name]
                local load_index, load_equip_name = string.match(tgt_str, "^(.-):::(.+)$")
                if base_equip_name == "RH" and g.rh then
                    spot_names = spot_names .. ":::" .. load_equip_name
                    g.rh = false
                elseif base_equip_name == "LH" and g.lh then
                    spot_names = spot_names .. ":::" .. load_equip_name
                    g.lh = false
                elseif base_equip_name == "RH_SUB" and g.rh_sub then
                    spot_names = spot_names .. ":::" .. load_equip_name
                    g.rh_sub = false
                elseif base_equip_name == "LH_SUB" and g.lh_sub then
                    spot_names = spot_names .. ":::" .. load_equip_name
                    g.lh_sub = false
                end
            end
        end
        if spot_names ~= "" then
            Goddess_icor_manager_set_change_action(ctrl_key, spot_names, step)
        end
    elseif step == 5 then -- 元戻す
        g.swap = false
        Goddess_icor_manager_swap_weapon()
    end
end

function Goddess_icor_manager_set_change_action(ctrl_key, spot_names, step)
    local _, count = string.gsub(spot_names, ":::", "")
    if count <= 0 then
        step = step + 1
        Goddess_icor_manager_set_change(_, _, _, ctrl_key, step)
        return
    end
    local frame = ui.GetFrame('goddess_equip_manager')
    frame:ShowWindow(1)
    local spot_name = string.match(spot_names, "^:::([A-Z0-9_]+)")
    if spot_name then
        spot_names = string.gsub(spot_names, "^:::" .. spot_name, "", 1)
    end
    local tgt_str
    if step == 4 then
        if spot_name == "RH" then
            tgt_str = g.settings[g.cid].drop_items[ctrl_key].set["RH_SUB"]
        elseif spot_name == "LH" then
            tgt_str = g.settings[g.cid].drop_items[ctrl_key].set["LH_SUB"]
        elseif spot_name == "RH_SUB" then
            tgt_str = g.settings[g.cid].drop_items[ctrl_key].set["RH"]
        elseif spot_name == "LH_SUB" then
            tgt_str = g.settings[g.cid].drop_items[ctrl_key].set["LH"]
        end
    else
        tgt_str = g.settings[g.cid].drop_items[ctrl_key].set[spot_name]
    end
    local load_index, load_equip_name = string.match(tgt_str, "^(.-):::(.+)$")
    load_index = tonumber(load_index)
    session.ResetItemList()
    local arg_list = NewStringList()
    local tgt_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(spot_name))
    if tgt_item then
        if tgt_item.isLockState == true then
            ui.SysMsg(ClMsg('MaterialItemIsLock'))
            return
        end
        local guid = tgt_item:GetIESID()
        if guid ~= 'None' and guid ~= '0' then
            session.AddItemID(guid, 1)
            arg_list:Add(spot_name)
        end
    end
    if load_index then
        arg_list:Add(load_index)
        local result_list = session.GetItemIDList()
        item.DialogTransaction('ICOR_PRESET_ENGRAVE_APPLY', result_list, '', arg_list)
        if count > 0 then
            ReserveScript(
                string.format("Goddess_icor_manager_set_change_action(%d,'%s',%d)", ctrl_key, spot_names, step),
                g.settings.delay or 0.5)
            return
        end
    end
end

function Goddess_icor_manager_list_gb_init(frame, page)
    local acc = GetMyAccountObj()
    local etc = GetMyEtcObject()
    local remain_time = GET_REMAIN_SECOND_ENGRAVE_SLOT_EXTENSION_TIME(acc)
    local max_page = GET_MAX_ENGARVE_SLOT_COUNT(acc)
    local page_max = 0
    if tonumber(remain_time) == 0 then
        page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc) + 5
    else
        page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc)
    end
    if g.settings.check == nil then
        g.settings.check = 0
    end
    if g.settings.check == 0 then
        local Y = 10
        local left_btn = frame:CreateOrGetControl("button", "left_btn", 690, 1020, 30, 30)
        AUTO_CAST(left_btn)
        left_btn:SetText("{img white_left_arrow 18 18}")
        left_btn:SetSkinName("brown_3patch_btn")
        left_btn:SetEventScript(ui.LBUTTONUP, "Goddess_icor_manager_list_init")
        left_btn:SetEventScriptArgNumber(ui.LBUTTONUP, 1)
        local right_btn = frame:CreateOrGetControl("button", "right_btn", 740, 1020, 30, 30)
        AUTO_CAST(right_btn)
        right_btn:SetText("{img white_right_arrow 18 18}")
        right_btn:SetSkinName("brown_3patch_btn")
        right_btn:SetEventScript(ui.LBUTTONUP, "Goddess_icor_manager_list_init")
        right_btn:SetEventScriptArgNumber(ui.LBUTTONUP, 2)
        local s_index, e_index
        if page == 2 then
            s_index, e_index = 6, page_max
        elseif page == 1 then
            s_index, e_index = 1, 5
        end
        for i = s_index, e_index do
            local bg = frame:CreateOrGetControl("groupbox", "bg" .. i, Y, 10, 281, 1010) -- 490
            AUTO_CAST(bg)
            bg:RemoveAllChild()
            local pagename_text = bg:CreateOrGetControl("richtext", "pagename_text" .. i, 10, 5)
            AUTO_CAST(pagename_text)
            local pagename = Goddess_icor_manager_get_pagename(i)
            Y = Y + 283
            if remain_time == 0 and tonumber(max_page) < i then
                local text = g.lang == "Japanese" and " 使用不可" or " disabled"
                pagename_text:SetText("{ol}{#FF0000}" .. pagename .. text)
            else
                pagename_text:SetText("{ol}{#FFFF00}" .. pagename)
            end
            bg:SetSkinName("bg")
            bg:ShowWindow(1)
            local manage_X = 0
            for j = 1, #managed_list do
                local manage_bg = bg:CreateOrGetControl("groupbox", "manage_bg" .. j, 0, 30 + manage_X, 258, 120)
                local manage_text = manage_bg:CreateOrGetControl("richtext", "manage_text" .. j, 10, 0)
                local temp_name = ""
                if type(g.settings[g.cid].icor_ids[tostring(i)]) == "table" then
                    local spot_data = g.settings[g.cid].icor_ids[tostring(i)][g.gim_slot_list[j].slot_name]
                    if spot_data then
                        local temp_cls = GetClassByType("Item", spot_data)
                        if temp_cls then
                            local cls_name = temp_cls.ClassName
                            if string.find(cls_name, "EP17", 1, true) then
                                if string.find(cls_name, "high", 1, true) then
                                    temp_name = g.lang == "Japanese" and " [540]上級" or " [540]Advanced"
                                else
                                    temp_name = " [540]"
                                end
                            elseif string.find(cls_name, "EP16", 1, true) then
                                if string.find(cls_name, "high", 1, true) then
                                    temp_name = g.lang == "Japanese" and " [520]上級" or " [520]Advanced"
                                else
                                    temp_name = " [520]"
                                end
                            elseif string.find(cls_name, "EP15", 1, true) and
                                (string.find(cls_name, "Weapon2", 1, true) or string.find(cls_name, "Armor2", 1, true)) then
                                temp_name = g.lang == "Japanese" and " [500]継承" or " [500]Succession"
                            end
                        end
                    end
                end
                manage_text:SetText("{ol}" .. ClMsg(g.gim_slot_list[j].clmsg) .. temp_name)
                manage_bg:SetSkinName("test_frame_midle_light")
                manage_X = manage_X + 122
                local parts1 = {}
                local parts2 = {}
                local parts3 = {}
                local option_prop, group_prop, value_prop, is_goddess_option =
                    Goddess_icor_manager_GET_ENGRAVED_OPTION_LIST(etc, i, managed_list[j])
                if option_prop ~= nil then
                    for part in option_prop:gmatch("([^/]+)") do
                        table.insert(parts1, part)
                    end
                    for part in group_prop:gmatch("([^/]+)") do
                        table.insert(parts2, part)
                    end
                    for part in value_prop:gmatch("([^/]+)") do
                        table.insert(parts3, part)
                    end
                    Goddess_icor_manager_set_text(manage_bg, parts1, parts2, parts3, manage_text)
                end
            end
        end
    end
    local function Goddess_icor_manager_draw_manage_sections(parent_bg, current_i)
        local manage_y = 0
        for j = 1, #managed_list do
            local m_bg = parent_bg:CreateOrGetControl("groupbox", "manage_bg" .. j, 0, manage_y + 5, 258, 120)
            m_bg:SetSkinName("test_frame_midle_light")
            local m_text = m_bg:CreateOrGetControl("richtext", "manage_text" .. j, 10, 0)
            local temp_name = ""
            if type(g.settings[g.cid].icor_ids[tostring(current_i)]) == "table" then
                local spot_data = g.settings[g.cid].icor_ids[tostring(current_i)][g.gim_slot_list[j].slot_name]
                if spot_data then
                    local temp_cls = GetClassByType("Item", spot_data)
                    if temp_cls then
                        local cls_name = temp_cls.ClassName
                        if string.find(cls_name, "EP17", 1, true) then
                            if string.find(cls_name, "high", 1, true) then
                                temp_name = g.lang == "Japanese" and " [540]上級" or " [540]Advanced"
                            else
                                temp_name = " [540]"
                            end
                        elseif string.find(cls_name, "EP16", 1, true) then
                            if string.find(cls_name, "high", 1, true) then
                                temp_name = g.lang == "Japanese" and " [520]上級" or " [520]Advanced"
                            else
                                temp_name = " [520]"
                            end
                        elseif string.find(cls_name, "EP15", 1, true) and
                            (string.find(cls_name, "Weapon2", 1, true) or string.find(cls_name, "Armor2", 1, true)) then
                            temp_name = g.lang == "Japanese" and " [500]継承" or " [500]Succession"
                        end
                    end
                end
            end
            m_text:SetText("{ol}" .. Goddess_icor_manager_language(managed_list[j]) .. temp_name)
            local p1, p2, p3 = {}, {}, {}
            local opt_prop, grp_prop, val_prop, is_goddess =
                Goddess_icor_manager_GET_ENGRAVED_OPTION_LIST(etc, current_i, managed_list[j])
            if opt_prop then
                for part in opt_prop:gmatch("([^/]+)") do
                    table.insert(p1, part)
                end
                for part in grp_prop:gmatch("([^/]+)") do
                    table.insert(p2, part)
                end
                for part in val_prop:gmatch("([^/]+)") do
                    table.insert(p3, part)
                end
                Goddess_icor_manager_set_text(m_bg, p1, p2, p3, m_text)
            end
            manage_y = manage_y + 122
        end
    end
    if g.settings.check == 1 then
        local bg_x = 10
        local y1 = 10
        local y2 = 535
        for i = 1, page_max do
            local bg_y = 0
            if i <= 5 then
                bg_y = y1
            elseif i >= 6 then
                bg_y = y2
            end
            local bg = frame:CreateOrGetControl("groupbox", "bg" .. i, bg_x, bg_y + 20, 281, 495)
            AUTO_CAST(bg)
            bg:SetSkinName("bg")
            local p_text = frame:CreateOrGetControl("richtext", "pagename_text" .. i, bg_x + 10, bg_y)
            AUTO_CAST(p_text)
            local p_name = Goddess_icor_manager_get_pagename(i)
            if remain_time == 0 and tonumber(max_page) < i then
                local text = g.lang == "Japanese" and " 使用不可" or " disabled"
                p_text:SetText("{ol}{#FF0000}" .. p_name .. text)
            else
                p_text:SetText("{ol}{#FFFF00}" .. p_name)
            end
            bg:ShowWindow(1)
            Goddess_icor_manager_draw_manage_sections(bg, i)
            if i <= 4 then
                bg_x = bg_x + 283
            elseif i == 5 then
                bg_x = 10
            else
                bg_x = bg_x + 283
            end
        end
        Goddess_icor_manager_set_pos(frame, page_max)
    end
    Goddess_icor_manager_check()
    frame:Resize(1430, 1065)
    frame:ShowWindow(1)
    frame:Invalidate()
end

function Goddess_icor_manager_equip_button(frame, ctrl, argStr, argNum)
    local frame = ui.GetFrame('goddess_equip_manager')
    frame:ShowWindow(1)
    GODDESS_MGR_RANDOMOPTION_APPLY_OPEN(frame)
    session.ResetItemList()
    local arg_list = NewStringList()
    local apply_cnt = 0
    for i = 1, #g.gim_slot_list do
        local slot_info = g.gim_slot_list[i]
        local ctrlset = GET_CHILD_RECURSIVELY(frame, 'rand_slot_' .. slot_info.slot_name)
        local tgt_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_info.slot_name))
        local checkbox = GET_CHILD(ctrlset, 'checkbox')
        if tonumber(argStr) == 1 and i == 1 then
            checkbox:SetCheck(1)
        elseif tonumber(argStr) == 2 and i == 2 then
            checkbox:SetCheck(1)
        elseif tonumber(argStr) == 3 and i == 3 then
            checkbox:SetCheck(1)
        elseif tonumber(argStr) == 4 and i == 4 then
            checkbox:SetCheck(1)
        elseif tonumber(argStr) == 5 and i == 5 then
            checkbox:SetCheck(1)
        elseif tonumber(argStr) == 6 and i == 6 then
            checkbox:SetCheck(1)
        elseif tonumber(argStr) == 7 and i == 7 then
            checkbox:SetCheck(1)
        elseif tonumber(argStr) == 8 and i == 8 then
            checkbox:SetCheck(1)
        end
        if tgt_item ~= nil and checkbox:IsChecked() == 1 then
            if tgt_item.isLockState == true then
                ui.SysMsg(ClMsg('MaterialItemIsLock'))
                return
            end
            local slot = GET_CHILD(ctrlset, 'slot')
            AUTO_CAST(slot)
            local guid = slot:GetUserValue('ITEM_GUID')
            if guid ~= 'None' then
                session.AddItemID(guid, 1)
                arg_list:Add(slot_info.slot_name)
                apply_cnt = apply_cnt + 1
            end
        end
    end
    if apply_cnt == 0 then
        ui.SysMsg(ClMsg('NoSelectedItem'))
        return
    end
    local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
    local index = argNum
    arg_list:Add(index)
    local result_list = session.GetItemIDList()
    item.DialogTransaction('ICOR_PRESET_ENGRAVE_APPLY', result_list, '', arg_list)
    local acc = GetMyAccountObj()
    local page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc) + 5
    if g.settings.check == 1 then
        for i = 1, page_max do
            local bg = GET_CHILD_RECURSIVELY(frame, "bg" .. i)
            AUTO_CAST(bg)
            local curpos = bg:GetScrollCurPos()
            if curpos >= 484 then
                curpos = 0
            end
            g.settings[tostring(i)] = curpos
            g.save_json(g.settings_path, g.settings)

        end
    end
    ReserveScript(string.format("Goddess_icor_manager_list_init('%s','%s','%s',%d)", frame, "", "", g.num),
        g.settings.delay or 0.5)
end

function Goddess_icor_manager_set_pos(frame, page_max)
    for i = 1, page_max do
        local bg = GET_CHILD_RECURSIVELY(frame, "bg" .. i)
        AUTO_CAST(bg)
        local pos = tonumber(g.settings[tostring(i)])
        bg:SetScrollPos(0)
        bg:Invalidate()
    end
end
function Goddess_icor_manager_check()
    local frame = ui.GetFrame("Goddess_icor_manager")
    local equipframe = ui.GetFrame("Goddess_icor_manager_newframe")
    local acc = GetMyAccountObj()
    local remain_time = GET_REMAIN_SECOND_ENGRAVE_SLOT_EXTENSION_TIME(acc)
    local page_max = 0
    if tonumber(remain_time) ~= 0 then
        page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc) + 5
    else
        page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc)
    end
    if g.settings.check ~= 0 then
        for i = 1, page_max do
            local pagename_text = GET_CHILD_RECURSIVELY(frame, "pagename_text" .. i)
            local bg = GET_CHILD_RECURSIVELY(frame, "bg" .. i)
            for j = 1, 8 do
                local new_bg = GET_CHILD_RECURSIVELY(equipframe, "new_bg" .. j)
                local equip_textcount = new_bg:GetChildCount() - 2
                local equip_text = ""
                for k = 1, equip_textcount do
                    local text = GET_CHILD_RECURSIVELY(new_bg, "text" .. k):GetText()
                    equip_text = equip_text .. text
                end
                equip_text = equip_text:gsub("{[^}]+}", "")
                local icor_text = ""
                local manage_bg = GET_CHILD_RECURSIVELY(bg, "manage_bg" .. j)
                if manage_bg ~= nil then
                    local bg_textcount = manage_bg:GetChildCount() - 2
                    for k = 1, bg_textcount do
                        local text = GET_CHILD_RECURSIVELY(manage_bg, "option" .. k):GetText()
                        icor_text = icor_text .. text
                    end
                    icor_text = icor_text:gsub("{[^}]+}", "")
                    if tostring(equip_text) == tostring(icor_text) and equip_text ~= "" then
                        local star = manage_bg:CreateOrGetControl("richtext", "star" .. j, 25, 25)
                        star:SetText("{img monster_card_starmark 25 25}")
                        star:SetOffset(230, 0)
                    elseif tostring(equip_text) ~= tostring(icor_text) and icor_text ~= "" then
                        local equip_button = manage_bg:CreateOrGetControl("button", "equip_button", 225, 0, 30, 25)
                        AUTO_CAST(equip_button)
                        equip_button:SetText("{ol}{s14}E")
                        equip_button:SetSkinName("test_red_button")
                        equip_button:SetEventScript(ui.LBUTTONUP, "Goddess_icor_manager_equip_button")
                        equip_button:SetEventScriptArgNumber(ui.LBUTTONUP, i) -- sets the 4th parameter (numarg)
                        equip_button:SetEventScriptArgString(ui.LBUTTONUP, j)
                        equip_button:SetTextTooltip(Goddess_icor_manager_language(
                            "Equip the icor with a left click of the button."))
                    end
                end
            end
        end
    else
        local pagename_text1 = GET_CHILD_RECURSIVELY(frame, "pagename_text1")
        if pagename_text1 ~= nil then
            local page = math.min(5, page_max)
            for i = 1, page do
                local pagename_text = GET_CHILD_RECURSIVELY(frame, "pagename_text" .. i)
                local bg = GET_CHILD_RECURSIVELY(frame, "bg" .. i)
                for j = 1, 8 do
                    local new_bg = GET_CHILD_RECURSIVELY(equipframe, "new_bg" .. j)
                    local equip_textcount = new_bg:GetChildCount() - 2
                    local equip_text = ""
                    for k = 1, equip_textcount do
                        local text = GET_CHILD_RECURSIVELY(new_bg, "text" .. k):GetText()
                        equip_text = equip_text .. text
                    end
                    equip_text = equip_text:gsub("{[^}]+}", "")
                    local icor_text = ""
                    local manage_bg = GET_CHILD_RECURSIVELY(bg, "manage_bg" .. j)
                    if manage_bg ~= nil then
                        local bg_textcount = manage_bg:GetChildCount() - 2
                        for k = 1, bg_textcount do
                            local text = GET_CHILD_RECURSIVELY(manage_bg, "option" .. k):GetText()
                            icor_text = icor_text .. text
                        end
                        icor_text = icor_text:gsub("{[^}]+}", "")
                        if tostring(equip_text) == tostring(icor_text) and equip_text ~= "" then
                            local star = manage_bg:CreateOrGetControl("richtext", "star" .. j, 25, 25)
                            star:SetText("{img monster_card_starmark 25 25}")
                            star:SetOffset(230, 0)
                        elseif tostring(equip_text) ~= tostring(icor_text) and icor_text ~= "" then
                            local equip_button = manage_bg:CreateOrGetControl("button", "equip_button", 225, 0, 30, 25)
                            AUTO_CAST(equip_button)
                            equip_button:SetText("{ol}{s14}E")
                            equip_button:SetSkinName("test_red_button")
                            equip_button:SetEventScript(ui.LBUTTONUP, "Goddess_icor_manager_equip_button")
                            equip_button:SetEventScriptArgNumber(ui.LBUTTONUP, i) -- sets the 4th parameter (numarg)
                            equip_button:SetEventScriptArgString(ui.LBUTTONUP, j)
                            equip_button:SetTextTooltip(Goddess_icor_manager_language(
                                "Equip the icor with a left click of the button."))
                        end
                    end
                end
            end
        else
            for i = 6, page_max do
                local pagename_text = GET_CHILD_RECURSIVELY(frame, "pagename_text" .. i)
                local bg = GET_CHILD_RECURSIVELY(frame, "bg" .. i)
                for j = 1, 8 do
                    local new_bg = GET_CHILD_RECURSIVELY(equipframe, "new_bg" .. j)
                    local equip_textcount = new_bg:GetChildCount() - 2
                    local equip_text = ""
                    for k = 1, equip_textcount do
                        local text = GET_CHILD_RECURSIVELY(new_bg, "text" .. k):GetText()
                        equip_text = equip_text .. text
                    end
                    equip_text = equip_text:gsub("{[^}]+}", "")
                    local icor_text = ""
                    local manage_bg = GET_CHILD_RECURSIVELY(bg, "manage_bg" .. j)
                    if manage_bg ~= nil then
                        local bg_textcount = manage_bg:GetChildCount() - 2
                        for k = 1, bg_textcount do
                            local text = GET_CHILD_RECURSIVELY(manage_bg, "option" .. k):GetText()
                            icor_text = icor_text .. text
                        end
                        icor_text = icor_text:gsub("{[^}]+}", "")
                        if tostring(equip_text) == tostring(icor_text) and equip_text ~= "" then
                            local star = manage_bg:CreateOrGetControl("richtext", "star" .. j, 25, 25)
                            star:SetText("{img monster_card_starmark 25 25}")
                            star:SetOffset(230, 0)
                        elseif tostring(equip_text) ~= tostring(icor_text) and icor_text ~= "" then
                            local equip_button = manage_bg:CreateOrGetControl("button", "equip_button", 225, 0, 30, 25)
                            AUTO_CAST(equip_button)
                            equip_button:SetText("{ol}{s14}E")
                            equip_button:SetSkinName("test_red_button")
                            equip_button:SetEventScript(ui.LBUTTONUP, "Goddess_icor_manager_equip_button")
                            equip_button:SetEventScriptArgNumber(ui.LBUTTONUP, i) -- sets the 4th parameter (numarg)
                            equip_button:SetEventScriptArgString(ui.LBUTTONUP, j)
                            equip_button:SetTextTooltip(Goddess_icor_manager_language(
                                "Equip the icor with a left click of the button."))
                        end
                    end
                end
            end
        end
    end
end

function Goddess_icor_manager_set_text(manage_bg, parts1, parts2, parts3, manage_text)
    for k = 1, #parts1 do
        local option = manage_bg:CreateOrGetControl("richtext", "option" .. k, 10, k * 20)
        local color = Goddess_icor_manager_color(tostring(parts2[k]))
        option:SetText("{ol}" .. color .. Goddess_icor_manager_language(parts1[k]) .. "{ol}{#FFFFFF} : " ..
                           "{ol}{#FFFFFF}" .. parts3[k])
        local colortone = Goddess_icor_manager_set_frame_color(manage_bg, parts1, parts2, parts3, manage_text)
        manage_bg:SetColorTone(colortone)
    end
end

function Goddess_icor_manager_set_frame_color(manage_bg, parts1, parts2, parts3, manage_text)
    local frameName = manage_bg:GetName()
    if frameName == "manage_bg1" or frameName == "manage_bg2" or frameName == "manage_bg7" or frameName == "manage_bg8" then
        for i = 1, #high500weapontbl do
            local key = high500weapontbl[i]
            local keyName = next(key)
            local value = key[next(key)] -- 次のキー（最初のキー）の値を取得
            for j = 1, #parts1 do
                if tostring(parts1[j]) == tostring(keyName) and tonumber(parts3[j]) >= tonumber(value) then
                    return "FFFFD700"
                end
            end
        end
        for i = 1, #low500weapontbl do
            local key = low500weapontbl[i]
            local keyName = next(key)
            local value = key[next(key)] -- 次のキー（最初のキー）の値を取得
            for j = 1, #parts1 do
                if tostring(parts1[j]) == tostring(keyName) and tonumber(parts3[j]) >= tonumber(value) then
                    return "FFDAA520"
                end
            end
        end
        for i = 1, #high480weapontbl do
            local key = high480weapontbl[i]
            local keyName = next(key)
            local value = key[next(key)] -- 次のキー（最初のキー）の値を取得
            for j = 1, #parts1 do
                if tostring(parts1[j]) == tostring(keyName) and tonumber(parts3[j]) >= tonumber(value) then
                    return "FF808080"
                end
            end
        end
        for i = 1, #low480weapontbl do
            local key = low480weapontbl[i]
            local keyName = next(key)
            local value = key[next(key)] -- 次のキー（最初のキー）の値を取得
            for j = 1, #parts1 do
                if tostring(parts1[j]) == tostring(keyName) and tonumber(parts3[j]) >= tonumber(value) then
                    return "FF808080"
                end
            end
        end
    else
        for i = 1, #high500armortbl do
            local key = high500armortbl[i]
            local keyName = next(key)
            local value = key[next(key)] -- 次のキー（最初のキー）の値を取得
            for j = 1, #parts1 do
                if tostring(parts1[j]) == tostring(keyName) and tonumber(parts3[j]) >= tonumber(value) then
                    return "FFFFD700"
                end
            end
        end
        for i = 1, #low500armortbl do
            local key = low500armortbl[i]
            local keyName = next(key)
            local value = key[next(key)] -- 次のキー（最初のキー）の値を取得
            for j = 1, #parts1 do
                if tostring(parts1[j]) == tostring(keyName) and tonumber(parts3[j]) >= tonumber(value) then
                    return "FFDAA520"
                end
            end
        end
        for i = 1, #high480armortbl do
            local key = high480armortbl[i]
            local keyName = next(key)
            local value = key[next(key)] -- 次のキー（最初のキー）の値を取得
            for j = 1, #parts1 do
                if tostring(parts1[j]) == tostring(keyName) and tonumber(parts3[j]) >= tonumber(value) then
                    return "FF808080"
                end
            end
        end
        for i = 1, #low480armortbl do
            local key = low480armortbl[i]
            local keyName = next(key)
            local value = key[next(key)] -- 次のキー（最初のキー）の値を取得
            for j = 1, #parts1 do
                if tostring(parts1[j]) == tostring(keyName) and tonumber(parts3[j]) >= tonumber(value) then
                    return "FF808080"
                end
            end
        end
    end
    return "FF000000"
end

function Goddess_icor_manager_check_save(frame, ctrl, argStr, argNum)
    local ischeck = ctrl:IsChecked()
    g.settings.check = ischeck
    g.save_json(g.settings_path, g.settings)
    local frame = ui.GetFrame("Goddess_icor_manager")
    ReserveScript(string.format("Goddess_icor_manager_list_init('%s','%s','%s',%d)", frame, "", "", 1),
        g.settings.delay or 0.5)
end

function Goddess_icor_manager_newframe_set_status(status_bg, stframe, status_str, index)
    local child_frame = GET_CHILD_RECURSIVELY(stframe, status_str)
    local language = option.GetCurrentCountry()
    local level = info.GetLevel(session.GetMyHandle())
    local setting_num = level * 30
    local setting_num2 = level * 15
    if language == "Japanese" then
        local child_title = GET_CHILD(child_frame, "title", "ui::CRichText"):GetText()
        local titletext = status_bg:CreateOrGetControl("richtext", "titletext" .. index, 10, index * 30 - 20)
        titletext:SetText("{ol}" .. child_title)
        local child_stat = GET_CHILD(child_frame, "stat", "ui::CRichText"):GetText()
        local stattext = status_bg:CreateOrGetControl("richtext", "stattext" .. index, 240, index * 30 - 20)
        if index <= 4 or (index >= 9 and index <= 13) then
            stattext:SetText("{ol}" .. child_stat .. " {#FFFFFF}(" .. setting_num .. ")")
        elseif index >= 5 and index <= 8 then
            stattext:SetText("{ol}" .. child_stat .. " {#FFFFFF}(" .. setting_num2 .. ")")
        elseif index >= 14 then
            stattext:SetText("{ol}" .. child_stat)
        end
    else
        local child_title = GET_CHILD(child_frame, "title", "ui::CRichText"):GetText()
        local titletext = status_bg:CreateOrGetControl("richtext", "titletext" .. index, 10, index * 45 - 30)
        titletext:SetText("{ol}" .. child_title)
        local child_stat = GET_CHILD(child_frame, "stat", "ui::CRichText"):GetText()
        local stattext = status_bg:CreateOrGetControl("richtext", "stattext" .. index, 200, index * 45 - 10)
        local line = status_bg:CreateOrGetControl("labelline", "line" .. index, 10, index * 45 + 7, 455, 5)
        if index <= 4 or (index >= 9 and index <= 13) then
            stattext:SetText("{ol}" .. child_stat .. " {#FFFFFF}(" .. setting_num .. ")")
        elseif index >= 5 and index <= 8 then
            stattext:SetText("{ol}" .. child_stat .. " {#FFFFFF}(" .. setting_num2 .. ")")
        elseif index >= 14 then
            stattext:SetText("{ol}" .. child_stat)
        end
    end
end

function Goddess_icor_manager_set_frame_color_equip(bg, size, item_dic, slot)
    local frameName = bg:GetName()
    if frameName == "new_bg1" or frameName == "new_bg2" or frameName == "new_bg7" or frameName == "new_bg8" then
        for i = 1, #high500weapontbl do
            local tblkey = high500weapontbl[i]
            local keyname = next(tblkey)
            local tblvalue = tblkey[next(tblkey)]
            for j = 1, size do
                local key = "RandomOption_" .. j
                local value_key = "RandomOptionValue_" .. j
                local option = item_dic[key]
                local value = item_dic[value_key]
                if tostring(option) == tostring(keyname) and tonumber(value) >= tonumber(tblvalue) then
                    local text = slot:GetText()
                    return "FFFFD700"
                end
            end
        end
        for i = 1, #low500weapontbl do
            local tblkey = low500weapontbl[i]
            local keyname = next(tblkey)
            local tblvalue = tblkey[next(tblkey)]
            for j = 1, size do
                local key = "RandomOption_" .. j
                local value_key = "RandomOptionValue_" .. j
                local option = item_dic[key]
                local value = item_dic[value_key]
                if tostring(option) == tostring(keyname) and tonumber(value) >= tonumber(tblvalue) then
                    return "FFDAA520"
                end
            end
        end
        for i = 1, #high480weapontbl do
            local tblkey = high480weapontbl[i]
            local keyname = next(tblkey)
            local tblvalue = tblkey[next(tblkey)]
            for j = 1, size do
                local key = "RandomOption_" .. j
                local value_key = "RandomOptionValue_" .. j
                local option = item_dic[key]
                local value = item_dic[value_key]
                if tostring(option) == tostring(keyname) and tonumber(value) >= tonumber(tblvalue) then
                    return "FF808080"
                end
            end
        end
        for i = 1, #low480weapontbl do
            local tblkey = low480weapontbl[i]
            local keyname = next(tblkey)
            local tblvalue = tblkey[next(tblkey)]
            for j = 1, size do
                local key = "RandomOption_" .. j
                local value_key = "RandomOptionValue_" .. j
                local option = item_dic[key]
                local value = item_dic[value_key]
                if tostring(option) == tostring(keyname) and tonumber(value) >= tonumber(tblvalue) then
                    return "FF808080"
                end
            end
        end
    else
        for i = 1, #high500armortbl do
            local tblkey = high500armortbl[i]
            local keyname = next(tblkey)
            local tblvalue = tblkey[next(tblkey)]
            for j = 1, size do
                local key = "RandomOption_" .. j
                local value_key = "RandomOptionValue_" .. j
                local option = item_dic[key]
                local value = item_dic[value_key]
                if tostring(option) == tostring(keyname) and tonumber(value) >= tonumber(tblvalue) then
                    return "FFFFD700"
                end
            end
        end
        for i = 1, #low500armortbl do
            local tblkey = low500armortbl[i]
            local keyname = next(tblkey)
            local tblvalue = tblkey[next(tblkey)]
            for j = 1, size do
                local key = "RandomOption_" .. j
                local value_key = "RandomOptionValue_" .. j
                local option = item_dic[key]
                local value = item_dic[value_key]
                if tostring(option) == tostring(keyname) and tonumber(value) >= tonumber(tblvalue) then
                    return "FFDAA520"
                end
            end
        end
        for i = 1, #high480armortbl do
            local tblkey = high480armortbl[i]
            local keyname = next(tblkey)
            local tblvalue = tblkey[next(tblkey)]
            for j = 1, size do
                local key = "RandomOption_" .. j
                local value_key = "RandomOptionValue_" .. j
                local option = item_dic[key]
                local value = item_dic[value_key]
                if tostring(option) == tostring(keyname) and tonumber(value) >= tonumber(tblvalue) then
                    return "FF808080"
                end
            end
        end
        for i = 1, #low480armortbl do
            local tblkey = low480armortbl[i]
            local keyname = next(tblkey)
            local tblvalue = tblkey[next(tblkey)]
            for j = 1, size do
                local key = "RandomOption_" .. j
                local value_key = "RandomOptionValue_" .. j
                local option = item_dic[key]
                local value = item_dic[value_key]
                if tostring(option) == tostring(keyname) and tonumber(value) >= tonumber(tblvalue) then
                    return "FF808080"
                end
            end
        end

    end
    return "FF000000"
end

function Goddess_icor_manager_get_pagename(index)
    local pc_etc = GetMyEtcObject()
    local acc = GetMyAccountObj()
    if pc_etc == nil or acc == nil then
        return nil
    end
    local page_name = TryGetProp(pc_etc, 'RandomOptionPresetName_' .. index, 'None')
    if page_name == 'None' then
        return ScpArgMsg('EngravePageNumber{index}', 'index', index)
    else
        return page_name
    end
end
-- goddess_icor_manager ここまで
