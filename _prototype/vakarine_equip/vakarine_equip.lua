-- v1.0.0 とりあえず作った。
local addonName = "vakarine_equip"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local function unicode_to_codepoint(char)
    local codepoint = utf8.codepoint(char)
    return string.format("%X", codepoint)
end

local function convert_to_ascii(input)
    local result = ""
    for char in input:gmatch(utf8.charpattern) do
        result = result .. unicode_to_codepoint(char)
    end
    return result
end

local input = GETMYFAMILYNAME()
local output = convert_to_ascii(input)
g.settingsFileLoc = string.format('../addons/%s/%s.json', addonNameLower, output .. "2501")

local acutil = require("acutil")
local json = require('json')

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

local equip_index = {8, 9, 30, 31, 19, 17, 18, 3, 14, 4, 5, 34, 33}
local equips_tbl = {"RH", "LH", "RH_SUB", "LH_SUB", "NECK", "RING1", "RING2", "SHIRT", "PANTS", "GLOVES", "BOOTS",
                    "SHOULDER", "BELT"}

function vakarine_equip_save_settings()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function vakarine_equip_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if not settings then
        settings = {
            buffid = {},
            delay = 0.2
        }
    end

    if not settings[g.cid] then
        settings[g.cid] = {
            use = 1,
            equip_tbl = {
                RH = 1,
                LH = 1,
                RH_SUB = 1,
                LH_SUB = 1,
                NECK = 1,
                RING1 = 1,
                RING2 = 1,
                SHIRT = 1,
                PANTS = 1,
                GLOVES = 1,
                BOOTS = 1,
                SHOULDER = 1,
                BELT = 1
            }
        }
    end
    g.settings = settings

    vakarine_equip_save_settings()

    g.util_tbl = {}

    for i, equip_name in ipairs(equips_tbl) do
        g.util_tbl[i] = {}
        table.insert(g.util_tbl[i], {equips_tbl[i], equip_index[i], "0"})
        local equip_index = check_equip_tbl[i]
        g.util_tbl[i][equip_name][equip_index] = {}
        g.util_tbl[i][equip_name][equip_index] = g.settings[g.cid]["equip_tbl"][equip_name]
    end

    --[[for i, equip in ipairs(g.util_tbl) do
        print("Index " .. i .. ":")
        for equip_name, equip_data in pairs(equip) do
            print("  Equip Name: " .. equip_name)
            for equip_index, value in pairs(equip_data) do
                print("    Equip Index: " .. equip_index .. ", Value: " .. value)
            end
        end
    end]]
end

function vakarine_equip_pic_lbtn(frame, ctrl, str, num)

    local frame = ui.GetFrame("headsupdisplay")
    local jobPic = GET_CHILD_RECURSIVELY(frame, "jobPic")
    local pic = GET_CHILD_RECURSIVELY(frame, "pic")
    pic:SetGravity(ui.RIGHT, ui.TOP);
    pic:SetImage("itemslot_alchemy_mark")
    pic:SetEnableStretch(1);
    pic:EnableHitTest(1)
    -- pic:SetEventScript(ui.LBUTTONUP, "vakarine_equip_buff_list")
    if ctrl ~= "GAME_START" then
        if g.settings[g.cid].use == 0 then
            g.settings[g.cid].use = 1
            pic:SetColorTone("FFFFFFFF")
        else
            pic:SetColorTone("FF555555")
            g.settings[g.cid].use = 0
        end
        vakarine_equip_save_settings()
    else
        if g.settings[g.cid].use == 0 then
            pic:SetColorTone("FF555555")
        else
            pic:SetColorTone("FFFFFFFF")

        end
    end
end

function vakarine_equip_pic_rbtn()
    local frame = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "config_frame", 0, 0, 0, 0)
    AUTO_CAST(frame)
    frame:RemoveAllChild()
    frame:SetLayerLevel(99);
    frame:SetSkinName("test_frame_low")

    local title_text = frame:CreateOrGetControl("richtext", "title_text", 10, 10)
    AUTO_CAST(title_text)
    title_text:SetText("{ol}Vakarine Equip Setting")

    local config_gb = frame:CreateOrGetControl("groupbox", "config_gb", 10, 40, 0, 0)
    AUTO_CAST(config_gb)
    config_gb:SetSkinName("bg")
    frame:SetPos(120, 50)

    function vakarine_equip_config_close(frame, ctrl, str, num)
        frame:ShowWindow(0)
    end

    local close_button = frame:CreateOrGetControl("button", "close_button", 0, 0, 20, 20)
    AUTO_CAST(close_button)
    close_button:SetImage("testclose_button")
    close_button:SetGravity(ui.RIGHT, ui.TOP)
    close_button:SetEventScript(ui.LBUTTONUP, "vakarine_equip_config_close")

    function vakarine_equip_delay_save(frame, ctrl, str, num)
        local delay = tonumber(ctrl:GetText())
        if delay > 1 then
            ui.SysMsg(g.lang == "Japanese" and "ディレイ設定は1秒未満" or "Delay setting is less than 1 sec")
            return
        end
        ui.SysMsg(g.lang == "Japanese" and "ディレイを設定しました" or "Delay set")
        g.settings.delay = delay
        vakarine_equip_save_settings()
        vakarine_equip_pic_rbtn()
    end

    local delay_text = config_gb:CreateOrGetControl("richtext", "delay_text", 20, 10)
    AUTO_CAST(delay_text)
    delay_text:SetText("{ol}Delay Time")

    local delay_edit = config_gb:CreateOrGetControl('edit', 'delay_edit', delay_text:GetWidth() + 20, 10, 50, 20)
    AUTO_CAST(delay_edit)
    delay_edit:SetFontName("white_14_ol")
    delay_edit:SetTextAlign("center", "center")
    delay_edit:SetEventScript(ui.ENTERKEY, "vakarine_equip_delay_save")
    delay_edit:SetText(g.settings.delay)

    local x = 0
    local y = 0

    function vakarine_equip_check_switch(frame, ctrl, equip_name, num)
        local ischeck = ctrl:IsChecked()
        g.settings[g.cid]["equip_tbl"][equip_name] = ischeck
        if equip_name == "RH_SUB" or equip_name == "LH_SUB" then
            g.settings[g.cid]["equip_tbl"]["RH_SUB"] = ischeck
            g.settings[g.cid]["equip_tbl"]["LH_SUB"] = ischeck
            vakarine_equip_pic_rbtn()
        elseif equip_name == "RH" or equip_name == "LH" then
            g.settings[g.cid]["equip_tbl"]["RH"] = ischeck
            g.settings[g.cid]["equip_tbl"]["LH"] = ischeck
            vakarine_equip_pic_rbtn()
        end
        vakarine_equip_save_settings()
    end
    for i, equip_name in ipairs(equips_tbl) do

        local check_box = config_gb:CreateOrGetControl('checkbox', "check_box" .. i, 20, i * 30, 30, 30);
        AUTO_CAST(check_box)
        check_box:SetCheck(g.settings[g.cid]["equip_tbl"][equip_name])
        check_box:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックした装備を脱着します" or
                                     "Remove and detach checked equipment.")
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
        local width = check_box:GetWidth()
        if x < width then
            x = width
        end
        y = i * 30

    end
    frame:Resize(x + 70, y + 90)
    config_gb:Resize(x + 50, y + 40)
    frame:ShowWindow(1)
end

function vakarine_equip_switching(frame, msg, str, num)

    local frame = ui.GetFrame("headsupdisplay")
    local jobPic = GET_CHILD_RECURSIVELY(frame, "jobPic")
    AUTO_CAST(jobPic)
    local pic = jobPic:CreateOrGetControl("picture", "pic", 0, 0, 50, 50);
    AUTO_CAST(pic)
    pic:EnableHitTest(1)
    pic:SetEventScript(ui.LBUTTONUP, "vakarine_equip_pic_lbtn")
    pic:SetEventScript(ui.RBUTTONUP, "vakarine_equip_pic_rbtn")
    pic:SetTextTooltip(g.lang == "Japanese" and
                           "{ol}Vakarine Equip{nl}左クリックでON/OFF切替{nl}右クリックで設定" or
                           "{ol}Vakarine Equip{nl}Left click to switch ON/OFF{nl}Right click to config")
    vakarine_equip_pic_lbtn(frame, msg, str, num)
end

function vakarine_equip_unequip_(equip_index)
    item.UnEquip(equip_index)
end

function vakarine_equip_unequip(frame, msg, str, num)

    session.ResetItemList();
    local equip_item_list = session.GetEquipItemList();

    local delay = 0
    for i, equip in ipairs(g.util_tbl) do
        for equip_name, equip_data in pairs(equip) do
            for equip_index, use_value in pairs(equip_data) do
                if use_value ~= 0 then
                    print(equip_name)
                    local equip_item = equip_item_list:GetEquipItemByIndex(equip_index)
                    local iesid = equip_item:GetIESID()
                    if iesid ~= "0" then
                        ReserveScript(string.format("vakarine_equip_unequip_(%d)", equip_index), delay)
                        delay = g.settings.delay + delay
                        break
                    end
                end
                break
            end
            break
        end
    end
    ReserveScript(string.format("vakarine_equip_item_equip(%d)", delay), delay)
    local frame = ui.GetFrame("inventory")
    if tonumber(USE_SUBWEAPON_SLOT) == 1 then
        DO_WEAPON_SLOT_CHANGE(frame, 1)
    else
        DO_WEAPON_SWAP(frame, 1)
    end
end

function vakarine_equip_item_equip_(item_index, equip_name)
    ITEM_EQUIP(item_index, equip_name)
end

function vakarine_equip_item_equip(delay)
    print(delay)
    -- g.equip_iesids[equip_name], {equip_index, iesid})
    local equip_item_list = session.GetEquipItemList();
    for i, equip in ipairs(g.util_tbl) do
        for equip_name, equip_data in pairs(equip) do
            for equip_index, use_value in pairs(equip_data) do
                if use_value ~= 0 then
                    local equip_item = equip_item_list:GetEquipItemByIndex(equip_index)
                    local iesid = equip_item:GetIESID()
                    if equip_name == "NECK" then
                        local type = 584103 -- アニマス
                        equip_item = session.GetInvItemByType(type)
                        if equip_item == nil then
                            equip_item = session.GetInvItemByGuid(iesid);
                        end
                    end

                    if iesid ~= "0" then
                        ReserveScript(string.format("vakarine_equip_item_equip_(%d,'%s')", equip_index, equip_name),
                            delay)
                        delay = g.settings.delay + delay
                        print(delay)
                        break
                    end
                end
                break
            end
            break
        end
    end

    --[[for i, equip in ipairs(g.util_tbl) do
        local equip_name = equips_tbl[i]
        local equip_index = check_equip_tbl[i]
        local use_value = g.util_tbl[i][equip_name][equip_index]
        if use_value ~= 0 and use_value ~= nil then
            local iesid = g.equip_iesids[equip_name]
            if iesid then
                local equip_item = session.GetInvItemByGuid(iesid);
                if equip_name == "NECK" then
                    local type = 584103 -- アニマス
                    equip_item = session.GetInvItemByType(type)
                    if equip_item == nil then
                        equip_item = session.GetInvItemByGuid(iesid);
                    end
                end
                if equip_item ~= nil then
                    local item_index = equip_item.invIndex
                    g.equip_iesids[equip_name] = nil
                    ReserveScript(string.format("vakarine_equip_item_equip_(%d,'%s')", item_index, equip_name), delay)
                    delay = g.settings.delay + delay
                    print(delay)
                end
            end
        end
    end]]
    ReserveScript("vakarine_equip_equips_check()", delay)
    return
end

function vakarine_equip_equips_check()
    local equipItemList = session.GetEquipItemList();
    local cnt = equipItemList:Count();

    --[[local check_equip_tbl = {8, 9, 30, 31, 19, 17, 18, 3, 14, 4, 5, 34, 33}
    local check_str_tbl = {"NoWeapon", "NoWeapon", "NoWeapon", "NoWeapon", "NoNeck", "NoRing", "NoRing", "NoShirt",
                           "NoPants", "NoGloves", "NoBoots", "NoOuter", "NoOuter"}]
    local check_equip_tbl = {8, 9, 30, 31, 19, 17, 18, 3, 14, 4, 5}
    local check_str_tbl = {"NoWeapon", "NoWeapon", "NoWeapon", "NoWeapon", "NoNeck", "NoRing", "NoRing", "NoShirt",
                           "NoPants", "NoGloves", "NoBoots"}]]

    for i, equip in ipairs(g.util_tbl) do
        for equip_name, equip_data in pairs(equip) do
            for equip_index, use_value in pairs(equip_data) do
                -- for i, spot_index in ipairs(check_equip_tbl) do
                local equip_item = equipItemList:GetEquipItemByIndex(equip_index)
                local iesid = equip_item:GetIESID()
                if iesid ~= "0" then
                    local spotName = item.GetEquipSpotName(equip_item.equipSpot)
                    imcAddOn.BroadMsg("NOTICE_Dm_!", spotName .. " Not equipped", 3);
                    return
                end
            end
        end
    end
    imcAddOn.BroadMsg("NOTICE_Dm_stage_start", "[NH]End of Operation", 3);
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
    effecttext:SetGravity(ui.RIGHT, ui.TOP);
    effecttext:SetOffset(hp:GetX(), hp:GetY() - 25 - (15 - 15))
    local hptext = frame:CreateOrGetControl("richtext", "hptext", 0, 0, hp:GetWidth(), hp:GetHeight())
    hptext:SetText(string.format('{%s}{ol}{%s}%d%%', "s15", color, hp_now))
    hptext:SetGravity(ui.RIGHT, ui.TOP);
    hptext:SetOffset(hp:GetX(), hp:GetY() - 10 - (15 - 15))
end

function vakarine_equip_BUFF_ON_MSG(frame, msg, str, buff_id)
    local exists = false
    for buffid, value in pairs(g.settings["buffid"]) do
        if tonumber(buffid) == buff_id then
            exists = true
            -- 良くないね
            --[[if value == 1 then
                
                REMOVE_BUF(_, _, _, buff_id)
            end]]
            return
        end
    end
    if not exists then
        g.settings["buffid"][tostring(buff_id)] = 0
        vakarine_equip_save_settings()
    end
end

function VAKARINE_EQUIP_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.cid = info.GetCID(session.GetMyHandle())
    g.lang = option.GetCurrentCountry()
    vakarine_equip_load_settings()

    addon:RegisterMsg('BUFF_ADD', 'vakarine_equip_BUFF_ON_MSG')
    addon:RegisterMsg('BUFF_UPDATE', 'vakarine_equip_BUFF_ON_MSG');
    addon:RegisterMsg('STAT_UPDATE', 'vakarine_equip_stat_update');
    addon:RegisterMsg('TAKE_DAMAGE', 'vakarine_equip_stat_update');
    addon:RegisterMsg('TAKE_HEAL', 'vakarine_equip_stat_update');

    addon:RegisterMsg("GAME_START", "vakarine_equip_switching")
    if g.settings[g.cid].use == 0 then
        return
    end
    local pc = GetMyPCObject();
    local cur_map = GetZoneName(pc)
    local map_cls = GetClass("Map", cur_map)
    local cur_map_id = session.GetMapID()
    print(tostring(map_cls.MapType))

    function vakarine_equip_vakarine()
        local equip_item_list = session.GetEquipItemList();
        local equip_guid_list = equip_item_list:GetGuidList();
        local count = equip_guid_list:Count();
        local vakarine_count = 0
        for i = 0, count - 1 do
            local guid = equip_guid_list:Get(i);
            if guid ~= '0' then
                local equip_item = equip_item_list:GetItemByGuid(guid);
                local item = GetIES(equip_item:GetObject())
                for j = 1, MAX_OPTION_EXTRACT_COUNT do
                    -- local prop_group_name = "RandomOptionGroup_" .. j;
                    local prop_name = "RandomOption_" .. j;
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

    local vakarine_judgment = vakarine_equip_vakarine()
    if not vakarine_judgment then
        return
    end

    if map_cls.MapType == "Instance" or cur_map_id == 11244 or map_cls.MapType == "Field" then
        g.equip_iesids = {}
        session.ResetItemList();
        local equip_item_list = session.GetEquipItemList();

        for i, equip in ipairs(g.util_tbl) do
            for equip_name, equip_index in pairs(equip) do
                for equip_name, equip_data in pairs(equip) do
                    for equip_index, use_value in pairs(equip_data) do
                        if use_value ~= 0 then
                            local equip_item = equip_item_list:GetEquipItemByIndex(equip_index)
                            local iesid = equip_item:GetIESID()
                            if iesid ~= "0" then
                                table.insert(g.equip_iesids[equip_name], {equip_index, iesid})
                                -- g.equip_iesids[equip_name] = iesid
                                break
                            end
                        end
                    end
                    break
                end
                break
            end
        end
        addon:RegisterMsg("GAME_START_3SEC", "vakarine_equip_unequip")

    elseif map_cls.MapType == "City" then

        function vakarine_equip_neck_equip(frame, msg, str, num)
            local equip_item_list = session.GetEquipItemList();
            local equip_item = equip_item_list:GetEquipItemByIndex(19);
            local iesid = equip_item:GetIESID()
            if iesid ~= g.equip_iesids["NECK"] then
                local equip_item = session.GetInvItemByGuid(g.equip_iesids["NECK"])
                if equip_item ~= nil then
                    local item_index = equip_item.invIndex
                    item.Equip(item_index)
                end
            end
        end
        addon:RegisterMsg("GAME_START_3SEC", "vakarine_equip_neck_equip")
    end
end
g.equip_iesids = {}
session.ResetItemList();
local equip_item_list = session.GetEquipItemList();
for i, equip in ipairs(g.util_tbl) do
    for equip_name, equip_data in pairs(equip) do
        for equip_index, use_value in pairs(equip_data) do
            if use_value ~= 0 then
                local equip_item = equip_item_list:GetEquipItemByIndex(equip_index)
                local iesid = equip_item:GetIESID()
                if iesid ~= "0" then
                    if not g.equip_iesids[i] then
                        g.equip_iesids[i] = {}
                    end
                    table.insert(g.equip_iesids[i], {equip_name, equip_index, iesid})
                    break
                end
            end
        end
    end
end
for i, items in ipairs(g.equip_iesids) do
    print("Index " .. i .. ":")
    for _, item in ipairs(items) do
        local equip_name = item[1]
        local equip_index = item[2]
        local iesid = item[3]
        print("  Equip Name: " .. equip_name .. ", Equip Index: " .. equip_index .. ", IESID: " .. iesid)
    end
end
--[[function vakarine_equip_buff_list(frame, ctrl, str, num)
    local bufflistframe = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "_bufflist", 0, 0, 10, 10)
    AUTO_CAST(bufflistframe)
    bufflistframe:SetSkinName("bg")
    bufflistframe:Resize(500, 1060)
    bufflistframe:SetPos(10, 10)
    bufflistframe:SetLayerLevel(121)
    bufflistframe:RemoveAllChild()
    local bg = bufflistframe:CreateOrGetControl("groupbox", "bufflist_bg", 5, 35, 490, 1015)
    AUTO_CAST(bg)
    bg:SetSkinName("bg")

    function vakarine_equip_bufflist_close(frame, ctrl, str, num)
    frame:ShowWindow(0)
    end

    local closeBtn = bufflistframe:CreateOrGetControl('button', 'closeBtn', 450, 0, 30, 30)
    AUTO_CAST(closeBtn)
    closeBtn:SetImage("testclose_button")
    closeBtn:SetGravity(ui.RIGHT, ui.TOP)
    closeBtn:SetEventScript(ui.LBUTTONUP, "vakarine_equip_bufflist_close");
    local sortedBuffIDs = {}
    for buffID, _ in pairs(g.settings["buffid"]) do
        table.insert(sortedBuffIDs, tonumber(buffID))
    end
    table.sort(sortedBuffIDs)
    local bufflisttext = bufflistframe:CreateOrGetControl('richtext', 'bufflisttext', 90, 10, 200, 30)
    AUTO_CAST(bufflisttext)
    bufflisttext:SetText("{ol}Vakarine Equip Buff List")
    local y = 0
    local i = 1
    for _, buffID in ipairs(sortedBuffIDs) do
        local buffslot = bg:CreateOrGetControl('slot', 'buffslot' .. i, 10, y + 5, 30, 30)
        AUTO_CAST(buffslot)
        local buffCls = GetClassByType("Buff", buffID);
        if buffCls ~= nil then
            SET_SLOT_IMG(buffslot, GET_BUFF_ICON_NAME(buffCls));
            local icon = CreateIcon(buffslot)
            AUTO_CAST(icon)
            icon:SetTooltipType('buff');
            icon:SetTooltipArg(buffCls.Name, buffID, 0);
            local buffcheck = bg:CreateOrGetControl('checkbox', 'buffcheck' .. i, 45, y + 5, 30, 30)
            AUTO_CAST(buffcheck)
            local check = g.settings["buffid"][tostring(buffID)] or 0
            function vakarine_equip_buff_check(frame, ctrl, argStr, buffID)
                local check = ctrl:IsChecked()
                g.settings["buffid"][tostring(buffID)] = check
                vakarine_equip_save_settings()
            end
            buffcheck:SetCheck(check)
            buffcheck:SetEventScript(ui.LBUTTONUP, "vakarine_equip_buff_check")
            buffcheck:SetEventScriptArgNumber(ui.LBUTTONUP, buffID)
            buffcheck:SetText("{ol}" .. buffCls.Name)
            buffcheck:SetTextTooltip(g.lang == "Japanese" and "{ol}" .. buffID ..
                                         "{nl}チェックするとバフを削除" or "{ol}" .. buffID ..
                                         "{nl}Check to remove buffs")
            y = y + 35
            i = i + 1
        end
    end
    bufflistframe:ShowWindow(1)
end]]

