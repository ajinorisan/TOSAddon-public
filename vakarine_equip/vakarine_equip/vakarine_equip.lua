-- v1.0.0 とりあえず作った。
-- v1.0.1 ネックレス最後に処理に変更。知らんやんそんなん。
-- v1.0.2 ui.holdが手を出すには早かった。
-- v1.0.3 ローディング最適化
local addonName = "vakarine_equip"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.3"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local active_id = session.loginInfo.GetAID()
g.settingsFileLoc = string.format('../addons/%s/%s.json', addonNameLower, active_id)

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

local equip_index = {8, 9, 30, 31, 17, 18, 3, 14, 4, 5, 34, 33, 19}
local equips_tbl = {"RH", "LH", "RH_SUB", "LH_SUB", "RING1", "RING2", "SHIRT", "PANTS", "GLOVES", "BOOTS", "SHOULDER",
                    "BELT", "NECK"}

function vakarine_equip_save_settings()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function vakarine_equip_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if not settings then
        settings = {
            buffid = {},
            delay = 0.25
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

    vakarine_equip_save_settings()

end

function vakarine_equip_pic_lbtn(frame, ctrl, str, num)

    local frame = ui.GetFrame("headsupdisplay")
    local jobPic = GET_CHILD_RECURSIVELY(frame, "jobPic")
    local pic = GET_CHILD_RECURSIVELY(frame, "pic")
    pic:SetGravity(ui.RIGHT, ui.TOP);
    pic:SetImage("itemslot_alchemy_mark")
    pic:SetEnableStretch(1);
    pic:EnableHitTest(1)

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
    frame:SetPos(510, 10)

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
    -- 良くないね
    -- pic:SetEventScript(ui.RBUTTONDOWN, "vakarine_equip_buff_list")
    pic:SetTextTooltip(g.lang == "Japanese" and
                           "{ol}Vakarine Equip{nl}左クリックでON/OFF切替{nl}右クリックで設定" or
                           "{ol}Vakarine Equip{nl}Left click to switch ON/OFF{nl}Right click to config")
    vakarine_equip_pic_lbtn(frame, msg, str, num)
end

function vakarine_equip_unequip(frame, msg, str, num)

    for i, data in ipairs(g.equip_tbl) do

        local equip_index = data[2]
        local iesid = data[3]
        local use = data[4]
        item.UnEquip(equip_index)
        if use == 1 then

            data[4] = 0
            if i ~= #g.equip_tbl then
                ReserveScript("vakarine_equip_unequip()", g.settings.delay - 0.05)
            else
                ReserveScript("vakarine_equip_item_equip()", g.settings.delay)

            end
            return
        end
    end

end

function vakarine_equip_item_equip()

    for i, data in ipairs(g.equip_tbl) do
        local equip_name = data[1]
        local equip_index = data[2]
        local iesid = data[3]
        local use = data[4]
        if use == 0 then
            data[4] = 1
            local inv_item = session.GetInvItemByGuid(iesid);

            if equip_name == "NECK" then
                local type = 584103 -- アニマス
                inv_item = session.GetInvItemByType(type)
                if inv_item == nil then
                    inv_item = session.GetInvItemByGuid(iesid);
                end
            end
            local inv_index = inv_item.invIndex
            ITEM_EQUIP(inv_index, equip_name)
            ReserveScript("vakarine_equip_item_equip()", g.settings.delay)
            return
        end
    end

    if not g.neck then
        local type = 584103 -- アニマス
        local inv_item = session.GetInvItemByType(type)
        if inv_item ~= nil then
            local inv_index = inv_item.invIndex
            ITEM_EQUIP(inv_index, "NECK")
            g.neck = true
            ReserveScript("vakarine_equip_item_equip()", g.settings.delay)
            return
        end
    end

    ReserveScript("vakarine_equip_equips_check()", g.settings.delay)
    return
end

function vakarine_equip_equips_check()

    local equip_item_list = session.GetEquipItemList();
    for i, data in ipairs(g.equip_tbl) do
        local equip_name = data[1]
        local equip_index = data[2]
        local equip_item = equip_item_list:GetEquipItemByIndex(equip_index)
        local iesid = equip_item:GetIESID()

        if iesid == "0" then
            imcAddOn.BroadMsg("NOTICE_Dm_!", equip_name .. " Not equipped", 10);
            -- ui.SetHoldUI(false);
            return
        end
    end
    local invframe = ui.GetFrame("inventory")
    invframe:ShowWindow(0)
    -- ui.SetHoldUI(false);
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

function vakarine_equip_GAME_START(frame, msg, str, num)

    local pc = GetMyPCObject();
    local cur_map = GetZoneName(pc)
    local map_cls = GetClass("Map", cur_map)
    local cur_map_id = session.GetMapID()
    local map_id = session.GetMapID()

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

    if map_cls.MapType == "City" and g.neck then

        function vakarine_equip_neck_equip(frame, msg, str, num)
            local equip_item_list = session.GetEquipItemList();
            local equip_item = equip_item_list:GetEquipItemByIndex(19);
            local iesid = equip_item:GetIESID()
            if iesid ~= g.neck_iesid and g.neck_iesid ~= nil then
                local equip_item = session.GetInvItemByGuid(g.neck_iesid)
                g.neck_iesid = nil
                if equip_item ~= nil then
                    local item_index = equip_item.invIndex
                    item.Equip(item_index)
                    return 0
                else
                    return 0
                end
            end
            return 0
        end
        frame:RunUpdateScript("vakarine_equip_neck_equip", 3.0)
        -- g.addon:RegisterMsg("GAME_START_3SEC", "vakarine_equip_neck_equip")
    end

    -- 11244 聖域3F 11227 分裂

    -- if (map_cls.MapType == "Instance" or cur_map_id == 11244) and cur_map_id ~= 11227 then
    if (map_cls.MapType == "Instance") and cur_map_id ~= 11227 then

        g.util_tbl = {}
        for i, equip_name in ipairs(equips_tbl) do
            if g.settings[g.cid]["equip_tbl"][equip_name] == 1 then
                table.insert(g.util_tbl, {equips_tbl[i], equip_index[i], 1})
            else
                table.insert(g.util_tbl, {equips_tbl[i], equip_index[i], 0})
            end
        end
        session.ResetItemList();
        local equip_item_list = session.GetEquipItemList();
        g.equip_tbl = {}
        g.neck = false
        for i, data in ipairs(g.util_tbl) do
            local equip_name = data[1]
            local equip_index = data[2]
            local use = data[3]
            local equip_item = equip_item_list:GetEquipItemByIndex(equip_index)
            local iesid = equip_item:GetIESID()
            if use == 1 then
                if iesid ~= "0" then
                    if equip_name == "NECK" then
                        g.neck_iesid = iesid
                        g.neck = true
                    end
                    table.insert(g.equip_tbl, {equip_name, equip_index, iesid, use})
                end
            elseif use == 0 and equip_name == "NECK" then
                g.neck_iesid = iesid
            end
        end

        local invframe = ui.GetFrame("inventory")
        if tonumber(USE_SUBWEAPON_SLOT) == 1 then
            DO_WEAPON_SLOT_CHANGE(invframe, 1)
        else
            DO_WEAPON_SWAP(invframe, 1)
        end
        invframe:ShowWindow(1)
        function vakarine_equip_unequip_set_delay()
            vakarine_equip_unequip()
            -- ui.SetHoldUI(true);
            -- ReserveScript("vakarine_equip_unequip()", 1.0)
            return 0
        end
        frame:RunUpdateScript("vakarine_equip_unequip_set_delay", 3.0)
        -- g.addon:RegisterMsg("GAME_START_3SEC", "vakarine_equip_unequip_set_delay")

    end
end

function VAKARINE_EQUIP_ON_INIT(addon, frame)
    local start_time = os.clock() -- ★処理開始前の時刻を記録★
    g.addon = addon
    g.frame = frame
    g.cid = info.GetCID(session.GetMyHandle())
    g.lang = option.GetCurrentCountry()

    if not g.settings then
        vakarine_equip_load_settings()
    else
        if not g.settings[g.cid] then
            vakarine_equip_load_settings()
        end
    end

    addon:RegisterMsg('BUFF_ADD', 'vakarine_equip_BUFF_ON_MSG')
    addon:RegisterMsg('BUFF_UPDATE', 'vakarine_equip_BUFF_ON_MSG');
    addon:RegisterMsg('STAT_UPDATE', 'vakarine_equip_stat_update');
    addon:RegisterMsg('TAKE_DAMAGE', 'vakarine_equip_stat_update');
    addon:RegisterMsg('TAKE_HEAL', 'vakarine_equip_stat_update');

    addon:RegisterMsg("GAME_START", "vakarine_equip_switching")

    if g.settings[g.cid].use == 0 then
        return
    end
    addon:RegisterMsg("GAME_START", "vakarine_equip_GAME_START")
    local end_time = os.clock() -- ★処理終了後の時刻を記録★
    local elapsed_time = end_time - start_time
    -- CHAT_SYSTEM(string.format("%s: %.4f seconds", addonName, elapsed_time))

end

function vakarine_equip_BUFF_ON_MSG(frame, msg, str, buff_id)
    local exists = false
    for buffid, value in pairs(g.settings["buffid"]) do
        if tonumber(buffid) == buff_id then
            exists = true
            -- 良くないね
            --[[if value == 1 and g.vakarine then
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

function vakarine_equip_buff_list(frame, ctrl, str, num)
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
end

