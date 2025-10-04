-- v1.0.0 とりあえず作った。
-- v1.0.1 ネックレス最後に処理に変更。知らんやんそんなん。
-- v1.0.2 ui.holdが手を出すには早かった。
-- v1.0.3 ローディング最適化
-- v1.0.4 最適化。手動モード。JSRの起動ONOFF
-- v1.0.5 no_heal機能移植
-- v1.0.6 補助側を1回設定すると、直らなかったバグ修正
local addon_name = "vakarine_equip"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.0.6"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]
local json = require('json')

local function ts(...)
    local num_args = select('#', ...)
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

local active_id = session.loginInfo.GetAID()
g.settings_path = string.format('../addons/%s/%s.json', addon_name_lower, active_id)

function g.mkdir_new_folder()
    local folder_path = string.format("../addons/%s", addon_name_lower)
    local file_path = string.format("../addons/%s/mkdir.txt", addon_name_lower)
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

function g.get_map_type()
    local map_name = session.GetMapName()
    local map_cls = GetClass("Map", map_name)
    local map_type = map_cls.MapType
    return map_type
end

function g.save_settings()
    local function save_json(path, tbl)
        local file = io.open(path, "w")
        if file then
            local str = json.encode(tbl)
            file:write(str)
            file:close()
        end
    end
    save_json(g.settings_path, g.settings)
end

function g.load_json(path)

    local file = io.open(path, "r")
    if file then
        local content = file:read("*all")
        file:close()
        local table = json.decode(content)
        return table
    else
        return nil
    end
end

function g.setup_hook_and_event(my_addon, origin_func_name, my_func_name, bool)

    g.FUNCS = g.FUNCS or {}
    if not g.FUNCS[origin_func_name] then
        g.FUNCS[origin_func_name] = _G[origin_func_name]
    end

    local origin_func = g.FUNCS[origin_func_name]

    local function hooked_function(...)

        local original_results

        if bool == true then
            original_results = {origin_func(...)}
        end

        g.ARGS = g.ARGS or {}
        g.ARGS[origin_func_name] = {...}
        imcAddOn.BroadMsg(origin_func_name)

        if original_results then
            return table.unpack(original_results)
        else
            return
        end
    end

    _G[origin_func_name] = hooked_function

    if not g.REGISTER[origin_func_name .. my_func_name] then -- g.REGISTERはON_INIT内で都度初期化
        g.REGISTER[origin_func_name .. my_func_name] = true
        my_addon:RegisterMsg(origin_func_name, my_func_name)
    end
end

function g.get_event_args(origin_func_name)
    local args = g.ARGS[origin_func_name]
    if args then
        return table.unpack(args)
    end
    return nil
end

function vakarine_equip_load_settings()

    local settings, err = g.load_json(g.settings_path)
    if not settings then
        settings = {
            buffid = {},
            delay = 0.1
        }
    end

    settings.delay = 0.1

    if not settings.jsr then
        settings.jsr = 0
    end

    if not settings.x or not settings.y or not settings.move then
        settings.x = 1860
        settings.y = 300
        settings.move = 1
    end

    if not settings[g.cid] then
        settings[g.cid] = {
            use = 1,
            equip_tbl = {
                RH = 1,
                LH = 1,
                RH_SUB = 1,
                LH_SUB = 1,
                RING1 = 1,
                RING2 = 1,
                SHIRT = 1,
                PANTS = 1,
                GLOVES = 1,
                BOOTS = 1,
                SHOULDER = 1,
                BELT = 1,
                NECK = 1
            }
        }
    end
    g.settings = settings
    g.save_settings()
end

function vakarine_equip_FIELD_BOSS_JOIN_ENTER_CLICK_MSG()
    g.enter_field_boss = true

    ReqEnterFieldBossIndun()
end

function VAKARINE_EQUIP_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.cid = info.GetCID(session.GetMyHandle())
    g.lang = option.GetCurrentCountry()

    ui.SetHoldUI(false)

    -- vakarine_equip_load_settings()
    if not g.settings then
        vakarine_equip_load_settings()
    else
        if not g.settings[g.cid] then
            vakarine_equip_load_settings()
        end
    end

    g.REGISTER = {}
    g.setup_hook_and_event(addon, "FIELD_BOSS_JOIN_ENTER_CLICK_MSG", "vakarine_equip_FIELD_BOSS_JOIN_ENTER_CLICK_MSG",
        false)

    addon:RegisterMsg('STAT_UPDATE', 'vakarine_equip_stat_update')
    addon:RegisterMsg('TAKE_DAMAGE', 'vakarine_equip_stat_update')
    addon:RegisterMsg('TAKE_HEAL', 'vakarine_equip_stat_update')

    addon:RegisterMsg("GAME_START", "vakarine_equip_frame_init")
    addon:RegisterMsg("GAME_START_3SEC", "vakarine_equip_unequip_animas")

    if g.settings[g.cid].use == 0 then
        return
    end
    addon:RegisterMsg('BUFF_ADD', 'vakarine_equip_BUFF_ON_MSG')
    addon:RegisterMsg('BUFF_UPDATE', 'vakarine_equip_BUFF_ON_MSG')
    addon:RegisterMsg("GAME_START", "vakarine_equip_GAME_START")

end

function vakarine_equip_neck_equip(frame)
    if g.try_count >= g.max_tries then
        g.neck = false
        return 0
    end

    local equip_item_list = session.GetEquipItemList()
    if not equip_item_list then
        g.try_count = g.try_count + 1
        return 1
    end

    local equip_item = equip_item_list:GetEquipItemByIndex(19)

    if not equip_item then
        g.try_count = g.try_count + 1
        return 1
    end
    local iesid = equip_item:GetIESID()

    if g.neck_iesid and iesid ~= g.neck_iesid then
        local equip_item = session.GetInvItemByGuid(g.neck_iesid)
        if equip_item then
            item.Equip(equip_item.invIndex)
            g.try_count = g.try_count + 1
            return 1
        else
            g.try_count = g.try_count + 1
            return 1
        end
    elseif g.neck_iesid and iesid == g.neck_iesid then
        g.neck = false
        return 0
    elseif not g.neck_iesid then
        g.neck = false
        return 0
    end

    g.try_count = g.try_count + 1
    return 1
end

function vakarine_equip_unequip_animas(frame)

    g.try_count = 0
    g.max_tries = 3

    if g.get_map_type() == "City" and g.neck then
        frame:RunUpdateScript("vakarine_equip_neck_equip", 1.0)
    end
end

function vakarine_equip_location_fixed(frame, ctrl)

    if g.settings.move == 1 then
        g.settings.move = 0
        ui.SysMsg("frame fixed")
    else
        g.settings.move = 1
        ui.SysMsg("frame movable")
    end
    g.save_settings()
    vakarine_equip_frame_init()
end

function vakarine_equip_location_save(frame, ctrl, str, num)

    g.settings.x = frame:GetX()
    g.settings.y = frame:GetY()

    g.save_settings()
end

function vakarine_equip_frame_init(frame, msg, str, num)

    local frame = ui.GetFrame("vakarine_equip")
    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")
    frame:Resize(40, 40)

    frame:EnableMove(g.settings.move)
    local map_frame = ui.GetFrame("map")
    local width = map_frame:GetWidth()
    if g.settings.x > 1920 and width <= 1920 then
        g.settings.x = 1860
        g.settings.y = 300
    end

    frame:SetPos(g.settings.x, g.settings.y)
    frame:SetEventScript(ui.LBUTTONUP, "vakarine_equip_location_save")
    frame:SetEventScript(ui.RBUTTONUP, "vakarine_equip_location_fixed")

    local vaka_pic = frame:CreateOrGetControl("picture", "vaka_pic", 0, 0, 30, 30)
    AUTO_CAST(vaka_pic)

    -- vaka_pic:SetImage("bakarine_emotion61")
    -- vaka_pic:SetImage("emoticon_0024")
    vaka_pic:SetImage("bakarine_emotion68")
    vaka_pic:SetColorTone("FFFFFFFF")
    vaka_pic:SetEnableStretch(1)
    vaka_pic:EnableHitTest(1)
    vaka_pic:SetGravity(ui.LEFT, ui.TOP)
    vaka_pic:SetTextTooltip(g.lang == "Japanese" and
                                "{ol}Vakarine Equip{nl}左クリック{nl}街: 設定{nl}街以外: 手動起動{nl}右クリック: ON/OFF{nl}フレーム右クリック: 場所固定" or
                                "{ol}Vakarine Equip{nl}Left click{nl}City: Setup{nl}Other cities: Manual activation{nl}Right clickto switch ON/OFF{nl} frame right click: fixed location")
    if g.settings[g.cid].use == 0 then
        vaka_pic:SetColorTone("FF555555")
    else
        vaka_pic:SetColorTone("FFFFFFFF")
    end
    vaka_pic:SetEventScript(ui.RBUTTONUP, "vakarine_equip_onoff_switch")
    vaka_pic:SetEventScript(ui.LBUTTONUP, "vakarine_equip_config_or_startup")

end

function vakarine_equip_config_frame_open()
    local frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "config_frame", 0, 0, 0, 0)
    AUTO_CAST(frame)
    frame:RemoveAllChild()
    frame:SetLayerLevel(99)
    frame:SetSkinName("test_frame_low")

    local title_text = frame:CreateOrGetControl("richtext", "title_text", 10, 10)
    AUTO_CAST(title_text)
    title_text:SetText("{ol}Vakarine Equip")

    local config_gb = frame:CreateOrGetControl("groupbox", "config_gb", 10, 40, 0, 0)
    AUTO_CAST(config_gb)
    config_gb:SetSkinName("bg")
    frame:SetPos(510, 10)

    function vakarine_equip_config_close(frame, ctrl, str, num)
        frame:ShowWindow(0)
    end

    local close_button = frame:CreateOrGetControl("button", "close_button", 0, 0, 20, 20)
    AUTO_CAST(close_button)
    close_button:SetImage("testclose_button")
    close_button:SetGravity(ui.RIGHT, ui.TOP)
    close_button:SetEventScript(ui.LBUTTONUP, "vakarine_equip_config_close")

    function vakarine_equip_check_switch(frame, ctrl, equip_name, num)

        local ischeck = ctrl:IsChecked()
        if ctrl:GetName() == "jsr_check" then
            if g.settings.jsr == 1 then
                g.settings.jsr = 0
            else
                g.settings.jsr = 1
            end
            g.save_settings()
            return
        end

        g.settings[g.cid]["equip_tbl"][equip_name] = ischeck
        if equip_name == "RH_SUB" or equip_name == "LH_SUB" then
            g.settings[g.cid]["equip_tbl"]["RH_SUB"] = ischeck
            g.settings[g.cid]["equip_tbl"]["LH_SUB"] = ischeck
            vakarine_equip_config_frame_open()
        end
        g.save_settings()
    end

    local jsr_check = config_gb:CreateOrGetControl('checkbox', "jsr_check", 10, 5, 30, 30)
    AUTO_CAST(jsr_check)
    jsr_check:SetCheck(g.settings.jsr)
    local text = g.lang == "Japanese" and "チェックするとJSRで作動" or "Activated in JSR when checked"
    jsr_check:SetText("{ol}" .. text)
    jsr_check:SetEventScript(ui.LBUTTONUP, "vakarine_equip_check_switch")

    local x = 0
    local width = jsr_check:GetWidth()
    if x < width then
        x = width
    end

    local y = 40

    local equips_tbl = {"RH", "LH", "RH_SUB", "LH_SUB", "RING1", "RING2", "SHIRT", "PANTS", "GLOVES", "BOOTS",
                        "SHOULDER", "BELT", "NECK"}
    for i, equip_name in ipairs(equips_tbl) do

        local check_box = config_gb:CreateOrGetControl('checkbox', "check_box" .. i, 20, y, 30, 30)
        AUTO_CAST(check_box)
        check_box:SetCheck(g.settings[g.cid]["equip_tbl"][equip_name])
        check_box:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックした装備を脱着します" or
                                     "{ol}Remove and detach checked equipment.")
        check_box:SetEventScript(ui.LBUTTONUP, "vakarine_equip_check_switch")
        check_box:SetEventScriptArgString(ui.LBUTTONUP, equip_name)
        if equip_name == "RING1" then
            equip_name = "Ring1"
        elseif equip_name == "RING2" then
            equip_name = "Ring2"
        elseif equip_name == "SHIRT" then
            equip_name = "Shirt"
        elseif equip_name == "PANTS" then
            equip_name = "Pants"
        end

        check_box:SetText("{ol}" .. ClMsg(equip_name))

        y = y + 30

    end
    frame:Resize(x + 50, y + 60)
    config_gb:Resize(x + 30, y + 10)
    frame:ShowWindow(1)
end

function vakarine_equip_config_or_startup(frame, ctrl)
    if g.get_map_type() == "City" then
        vakarine_equip_config_frame_open()
    else

        vakarine_equip_GAME_START()
    end
end

function vakarine_equip_holdui_release(frame)
    ui.SetHoldUI(false)
    return 0
end

function vakarine_equip_vakarine()
    local equip_item_list = session.GetEquipItemList()
    local equip_guid_list = equip_item_list:GetGuidList()
    local count = equip_guid_list:Count()
    local vakarine_count = 0
    for i = 0, count - 1 do
        local guid = equip_guid_list:Get(i)
        if guid ~= '0' then
            local equip_item = equip_item_list:GetItemByGuid(guid)
            local item = GetIES(equip_item:GetObject())
            for j = 1, MAX_OPTION_EXTRACT_COUNT do

                local prop_name = "RandomOption_" .. j
                local cls_msg = ScpArgMsg(item[prop_name])
                if string.find(cls_msg, "vakarine_bless") ~= nil then
                    vakarine_count = vakarine_count + 1
                    break
                end
            end
        end
    end

    if vakarine_count >= 5 then
        g.vakarine = true
        return true
    elseif vakarine_count == 4 then
        g.vakarine = true
        return false
    else
        g.vakarine = false
        return false
    end
end

function vakarine_equip_GAME_START(frame, msg, str, num)

    g.start_time = os.clock() -- ★処理開始前の時刻を記録★
    local frame = ui.GetFrame("vakarine_equip")

    if g.enter_field_boss and g.settings.jsr == 0 then
        g.enter_field_boss = nil
        return
    elseif g.enter_field_boss and g.settings.jsr == 1 then
        g.enter_field_boss = nil
    end

    local vakarine_judgment = vakarine_equip_vakarine()
    if not vakarine_judgment then
        return
    end

    -- print(tostring(g.enter_field_boss) .. ":" .. tostring(g.settings.jsr))
    -- 11244 聖域3F 11227 分裂 8022 ヴェルニケ

    local cur_map_id = session.GetMapID()

    if (g.get_map_type() == "Instance" and cur_map_id ~= 11227) or cur_map_id == 8022 or cur_map_id == 11244 then

        ui.SetHoldUI(true)
        frame:RunUpdateScript("vakarine_equip_holdui_release", 10.0)

        local cls_name = "NECK04_103"
        local inv_item = session.GetInvItemByName(cls_name)
        if inv_item then
            g.animas_iesid = inv_item:GetIESID()
        else
            g.animas_iesid = nil
        end

        local equips = {{
            RH = 8
        }, {
            LH = 9
        }, {
            RH_SUB = 30
        }, {
            LH_SUB = 31
        }, {
            RING1 = 17
        }, {
            RING2 = 18
        }, {
            SHIRT = 3
        }, {
            PANTS = 14
        }, {
            GLOVES = 4
        }, {
            BOOTS = 5
        }, {
            SHOULDER = 34
        }, {
            BELT = 33
        }, {
            NECK = 19
        }}

        session.ResetItemList()
        local equip_item_list = session.GetEquipItemList()
        g.equip_tbl = {}
        g.neck = false
        g.sub = false
        for index, data in ipairs(equips) do
            local equip_name = nil
            local equip_index = nil
            for key_data, value_data in pairs(data) do
                equip_name = key_data
                equip_index = value_data
                break
            end

            local use = g.settings[g.cid].equip_tbl[equip_name]

            local equip_item = equip_item_list:GetEquipItemByIndex(equip_index)
            local iesid = equip_item:GetIESID()

            if use == 1 then
                if iesid ~= "0" then
                    if equip_name == "NECK" then
                        g.neck_iesid = iesid
                        g.neck = true
                    elseif equip_name == "RH_SUB" then
                        g.sub = true
                    end
                    table.insert(g.equip_tbl, {equip_name, equip_index, iesid, use})
                end
            end
        end

        local invframe = ui.GetFrame("inventory")
        invframe:ShowWindow(1)
        if g.sub then
            DO_WEAPON_SLOT_CHANGE(invframe, 2)
            item.UnEquip(30)
            for index, data in ipairs(g.equip_tbl) do
                local equip_index = data[2]
                if equip_index == 30 then
                    data[4] = false
                elseif equip_index == 31 then
                    data[4] = false
                    break
                end
            end

        elseif g.settings[g.cid].equip_tbl["LH"] == 1 then
            DO_WEAPON_SLOT_CHANGE(invframe, 1)
            item.UnEquip(9)
            for index, data in ipairs(g.equip_tbl) do
                local equip_index = data[2]
                if equip_index == 9 then
                    data[4] = false
                end
            end
        end

        frame:RunUpdateScript("vakarine_equip_unequip", g.settings.delay)

    end
end

function vakarine_equip_unequip(frame)

    local equip_item_list = session.GetEquipItemList()
    for i, data in ipairs(g.equip_tbl) do

        local equip_index = data[2]
        local use = data[4]

        if use then
            item.UnEquip(equip_index)
            local equip_item = equip_item_list:GetEquipItemByIndex(equip_index)
            local iesid = equip_item:GetIESID()
            if iesid == "0" then
                data[4] = false
                return 1
            else
                return 1
            end
        end
    end

    frame:RunUpdateScript("vakarine_equip_item_equip", g.settings.delay)
    return 0
end

function vakarine_equip_item_equip(frame)

    local equip_item_list = session.GetEquipItemList()
    local neck_index = nil
    local neck_iesid = nil
    local neck_name = nil
    for i, data in ipairs(g.equip_tbl) do
        local equip_name = data[1]
        local equip_index = data[2]
        local invframe = ui.GetFrame("inventory")
        if equip_name == "RH" or equip_name == "LH" then
            DO_WEAPON_SLOT_CHANGE(invframe, 1)
        elseif equip_name == "RH_SUB" or equip_name == "LH_SUB" then
            DO_WEAPON_SLOT_CHANGE(invframe, 2)
        end
        local iesid = data[3]
        local use = data[4]

        if not use then
            local inv_item = nil
            if equip_name ~= "NECK" then
                inv_item = session.GetInvItemByGuid(iesid)
            else
                inv_item = session.GetInvItemByGuid(g.animas_iesid or iesid)
            end

            if inv_item then

                local inv_index = inv_item.invIndex
                -- ITEM_EQUIP(inv_index, equip_name)
                item.Equip(inv_index, equip_name)
                return 1
            else
                data[4] = true
                return 1
            end
        end
    end

    local invframe = ui.GetFrame("inventory")
    invframe:ShowWindow(0)

    ui.SetHoldUI(false)

    imcAddOn.BroadMsg("NOTICE_Dm_stage_start", "[VE]End of Operation", 3)
    local end_time = os.clock() -- ★処理終了後の時刻を記録★
    local elapsed_time = end_time - g.start_time
    -- CHAT_SYSTEM(string.format("%s: %.4f seconds", addon_name, elapsed_time))
    return 0
end

function vakarine_equip_onoff_switch(parent, ctrl, str, num)

    if keyboard.IsKeyPressed("LSHIFT") == 1 then
        vakarine_equip_buff_list()
        return
    end

    vakarine_equip_vakarine()
    -- print(tostring(g.vakarine))

    local parent = ui.GetFrame("vakarine_equip")
    local vaka_pic = GET_CHILD(parent, "vaka_pic")

    if g.settings[g.cid].use == 0 then
        g.settings[g.cid].use = 1
        vaka_pic:SetColorTone("FFFFFFFF")
    else
        vaka_pic:SetColorTone("FF555555")
        g.settings[g.cid].use = 0
    end
    g.save_settings()
end

function vakarine_equip_stat_update()

    local frame = ui.GetFrame("charbaseinfo1_my")
    if (not frame) then
        return
    end

    local hp = GET_CHILD(frame, "pcHpGauge")
    AUTO_CAST(hp)
    local handle = session.GetMyHandle()
    local stat = info.GetStat(handle)
    local hp_now = (stat.HP * 100) / stat.maxHP

    local status = ''
    local color = ""
    if (hp_now == 100) then
        color = '#00EC00'
        status = 'Perfect'
    elseif g.vakarine and (hp_now <= 45) then
        color = '#EA0000'
        status = 'Revenge'
    elseif not g.vakarine and (hp_now <= 35) then
        color = '#EA0000'
        status = 'Revenge'
    elseif hp_now == 0 then
        color = '#FFFFFF'
    else
        color = '#FFFFFF'
    end

    local effecttext = frame:CreateOrGetControl("richtext", "effecttext", 0, 0, hp:GetWidth(), hp:GetHeight())
    effecttext:SetText(string.format('{ol}{%s}{%s}%s', "s15", color, status))
    effecttext:SetGravity(ui.RIGHT, ui.TOP)
    effecttext:SetOffset(hp:GetX(), hp:GetY() - 25 - (15 - 15))
    local hptext = frame:CreateOrGetControl("richtext", "hptext", 0, 0, hp:GetWidth(), hp:GetHeight())
    hptext:SetText(string.format('{%s}{ol}{%s}%d%%', "s15", color, hp_now))
    hptext:SetGravity(ui.RIGHT, ui.TOP)
    hptext:SetOffset(hp:GetX(), hp:GetY() - 10 - (15 - 15))
end

function vakarine_equip_BUFF_ON_MSG(frame, msg, str, buff_id)

    local exists = false
    if g.settings and g.settings["buffid"] then
        for id_str, val in pairs(g.settings["buffid"]) do
            if tonumber(id_str) == buff_id then
                exists = true
                -- 良くないね
                if g.settings.auto_remove == 1 then
                    if val == 1 and g.vakarine then
                        REMOVE_BUF(_, _, _, buff_id)
                    end
                end
                return
            end
        end
    end

    if not exists then
        if g.settings and not g.settings["buffid"] then
            g.settings["buffid"] = {}
        end
        if g.settings then
            g.settings["buffid"][tostring(buff_id)] = 0
            g.save_settings()
        end
    end
end

function vakarine_equip_bufflist_frame_close()
    local frame_bufflist = ui.GetFrame(addon_name_lower .. "_bufflist")
    frame_bufflist:ShowWindow(0)
end

function vakarine_equip_buff_aoto_remove(frame, ctrl, str, num)
    if not g.settings.auto_remove then
        g.settings.auto_remove = 0
    end

    if g.settings.auto_remove == 0 then
        g.settings.auto_remove = 1
    else
        g.settings.auto_remove = 0
    end
    g.save_settings()
end

function vakarine_equip_bufflist_search(frame, ctrl)
    if ctrl:GetName() == "search_btn" then
        ctrl = frame
    end
    local search_text = ctrl:GetText()

    if search_text == "" then
        vakarine_equip_buff_list()
        return
    end

    local top_frame = ctrl:GetTopParentFrame()

    local bufflist_bg = GET_CHILD(top_frame, "bufflist_bg")
    bufflist_bg:RemoveAllChild()

    local buffs = {}
    local search_id = tonumber(search_text)

    if search_id then
        if g.settings and g.settings["buffid"] then
            for id_str, check_val in pairs(g.settings["buffid"]) do
                if string.find(id_str, search_text, 1, true) then
                    table.insert(buffs, {
                        buff_id = tonumber(id_str),
                        check = check_val
                    })
                end
            end
        end
    else
        if g.settings and g.settings["buffid"] then
            for id_str, check_val in pairs(g.settings["buffid"]) do
                local buff_cls = GetClassByType("Buff", id_str)
                if buff_cls then
                    local buff_name = dic.getTranslatedStr(buff_cls.Name)
                    if string.find(buff_name, search_text, 1, true) then
                        table.insert(buffs, {
                            buff_id = tonumber(id_str),
                            check = check_val
                        })
                    end
                end
            end
        end
    end

    local y = 0
    for _, buff_data in ipairs(buffs) do
        local buff_id = buff_data.buff_id
        local check_val = buff_data.check
        local slot_ui = bufflist_bg:CreateOrGetControl('slot', 'buff_slot' .. buff_id, 10, y + 5, 30, 30)
        AUTO_CAST(slot_ui)
        local buff_cls_obj = GetClassByType("Buff", buff_id)

        if buff_cls_obj then
            local img_name = GET_BUFF_ICON_NAME(buff_cls_obj)
            if img_name ~= "icon_None" then
                SET_SLOT_IMG(slot_ui, img_name)

                local icon_ui = CreateIcon(slot_ui)
                AUTO_CAST(icon_ui)
                icon_ui:SetTooltipType('buff')
                icon_ui:SetTooltipArg(buff_cls_obj.Name, buff_id, 0)

                local check_ui = bufflist_bg:CreateOrGetControl('checkbox', 'buffcheck' .. buff_id, 45, y + 5, 30, 30)
                AUTO_CAST(check_ui)
                check_ui:SetCheck(check_val)
                check_ui:SetEventScript(ui.LBUTTONUP, "vakarine_equip_buff_check")
                check_ui:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id)
                check_ui:SetText("{ol}" .. buff_cls_obj.Name)
                check_ui:SetTextTooltip(g.lang == "Japanese" and "{ol}" .. buff_id ..
                                            "{nl}チェックすると自動でバフ削除" or "{ol}" .. buff_id ..
                                            "{nl}Check to automatically remove buff")
                y = y + 35
            end
        end
    end

end

function vakarine_equip_buff_check(frame, ctrl, argStr, buffID)
    local check = ctrl:IsChecked()

    if g.settings["buffid"] then
        g.settings["buffid"][tostring(buffID)] = check
        g.save_settings()
    end

end

function vakarine_equip_buff_list(frame, ctrl, str, num)

    local list_frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "_bufflist", 0, 0, 10, 10)
    AUTO_CAST(list_frame)
    list_frame:SetSkinName("test_frame_low")
    list_frame:Resize(500, 1060)
    list_frame:SetPos(10, 10)
    list_frame:SetLayerLevel(121)
    list_frame:RemoveAllChild()

    local bufflist_bg = list_frame:CreateOrGetControl("groupbox", "bufflist_bg", 10, 45, 480, 1005)
    AUTO_CAST(bufflist_bg)
    bufflist_bg:SetSkinName("bg")

    local close_btn = list_frame:CreateOrGetControl('button', 'close_btn', 450, 0, 30, 30)
    AUTO_CAST(close_btn)
    close_btn:SetImage("testclose_button")
    close_btn:SetGravity(ui.RIGHT, ui.TOP)
    close_btn:SetEventScript(ui.LBUTTONUP, "vakarine_equip_bufflist_frame_close")

    local func_toggle = list_frame:CreateOrGetControl('checkbox', 'func_toggle', 435, 10, 25, 25)
    AUTO_CAST(func_toggle)
    func_toggle:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると自動バフ削除有効化" or
                                   "{ol}Check to enable auto buff removal")
    func_toggle:SetEventScript(ui.LBUTTONUP, "vakarine_equip_buff_aoto_remove")
    func_toggle:SetCheck(g.settings.auto_remove or 0)

    local list_title = list_frame:CreateOrGetControl('richtext', 'bufflisttext', 10, 15, 200, 30)
    AUTO_CAST(list_title)
    list_title:SetText("{ol}BUFF LIST")

    local search_edit = list_frame:CreateOrGetControl("edit", "search_edit", 120, 10, 305, 38)
    AUTO_CAST(search_edit)
    search_edit:SetFontName("white_18_ol")
    search_edit:SetTextAlign("left", "center")
    search_edit:SetSkinName("inventory_serch")

    search_edit:SetEventScript(ui.ENTERKEY, "vakarine_equip_bufflist_search")

    local search_btn = search_edit:CreateOrGetControl("button", "search_btn", 0, 0, 40, 38)
    AUTO_CAST(search_btn)
    search_btn:SetImage("inven_s")
    search_btn:SetGravity(ui.RIGHT, ui.TOP)
    search_btn:SetEventScript(ui.LBUTTONUP, "vakarine_equip_bufflist_search")

    local sort_list = {}
    if g.settings and g.settings["buffid"] then
        for id_str, check_val in pairs(g.settings["buffid"]) do
            table.insert(sort_list, {
                id = tonumber(id_str),
                checked = (check_val == 0)
            })
        end
    end

    table.sort(sort_list, function(a, b)
        if b.checked and not a.checked then
            return true
        elseif not b.checked and a.checked then
            return false
        else
            return a.id < b.id
        end
    end)

    local y_pos = 0
    for item_idx, buff_item in ipairs(sort_list) do
        local buff_id_val = buff_item.id
        local slot_ui_disp = bufflist_bg:CreateOrGetControl('slot', 'buffslot' .. buff_id_val, 10, y_pos + 5, 30, 30)
        AUTO_CAST(slot_ui_disp)
        local buff_cls = GetClassByType("Buff", buff_id_val)

        if buff_cls then
            local img_name_disp = GET_BUFF_ICON_NAME(buff_cls)
            if img_name_disp ~= "icon_None" then
                SET_SLOT_IMG(slot_ui_disp, img_name_disp)
                if buff_cls.Name ~= "None" then

                    local icon_disp = CreateIcon(slot_ui_disp)
                    AUTO_CAST(icon_disp)
                    icon_disp:SetTooltipType('buff')
                    icon_disp:SetTooltipArg(buff_cls.Name, buff_id_val, 0)

                    local check_ui_disp = bufflist_bg:CreateOrGetControl('checkbox', 'buffcheck' .. buff_id_val, 45,
                        y_pos + 5, 30, 30)
                    AUTO_CAST(check_ui_disp)
                    check_ui_disp:SetCheck((g.settings["buffid"] and g.settings["buffid"][tostring(buff_id_val)]) or 0)
                    check_ui_disp:SetEventScript(ui.LBUTTONUP, "vakarine_equip_buff_check")
                    check_ui_disp:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id_val)
                    check_ui_disp:SetText("{ol}" .. buff_cls.Name)
                    check_ui_disp:SetTextTooltip(g.lang == "Japanese" and "{ol}" .. buff_id_val ..
                                                     "{nl}チェックすると自動でバフ削除" or "{ol}" ..
                                                     buff_id_val .. "{nl}Check to automatically remove buff")
                    y_pos = y_pos + 35
                end
            end
        end
    end
    list_frame:ShowWindow(1)

end

