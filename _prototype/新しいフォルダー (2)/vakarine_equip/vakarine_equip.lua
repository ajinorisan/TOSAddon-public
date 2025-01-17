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

function vakarine_equip_vakarine()
    local equip_item_list = session.GetEquipItemList();
    local equip_guid_list = equip_item_list:GetGuidList();
    local count = equip_guid_list:Count();
    local vakarine_count = 0
    for i = 0, count - 1 do
        local guid = equip_guid_list:Get(i);
        if guid ~= '0' then
            local equip_item = equip_item_list:GetItemByGuid(guid);
            if equip_item ~= nil and equip_item:GetObject() ~= nil then

                local item = GetIES(equip_item:GetObject())
                for j = 1, MAX_OPTION_EXTRACT_COUNT do
                    local propGroupName = "RandomOptionGroup_" .. j;
                    local propName = "RandomOption_" .. j;
                    local cls_msg = ScpArgMsg(item[propName])
                    if string.find(cls_msg, "vakarine_bless") ~= nil then
                        vakarine_count = vakarine_count + 1
                        break
                    end
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

function vakarine_equip_save_settings()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function vakarine_equip_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if not settings then
        settings = {}
    end
    g.settings = settings
    if not g.settings[tostring(g.cid)] then
        g.settings[tostring(g.cid)] = {
            use = 1,
            buffid = {},
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
    vakarine_equip_save_settings()
    local check_equip_tbl = {8, 9, 30, 31, 19, 17, 18, 3, 14, 4, 5, 34, 33}
    local check_str_tbl = {"NoWeapon", "NoWeapon", "NoWeapon", "NoWeapon", "NoNeck", "NoRing", "NoRing", "NoShirt",
                           "NoPants", "NoGloves", "NoBoots", "NoOuter", "NoOuter"}
    local equips_tbl = {"RH", "LH", "RH_SUB", "LH_SUB", "NECK", "RING1", "RING2", "SHIRT", "PANTS", "GLOVES", "BOOTS",
                        "SHOULDER", "BELT"}

    g.util_tbl = {}

    for i, equip_name in ipairs(equips_tbl) do
        if g.settings[tostring(g.cid)][equip_name] == 1 then
            g.util_tbl[i] = {}
            g.util_tbl[i][equip_name] = {}
            local equip_index = check_equip_tbl[i]
            local check_str = check_str_tbl[i]
            g.util_tbl[i][equip_name][equip_index] = check_str
        end
    end

    for i, equip in ipairs(g.util_tbl) do
        for equip_name, equip_info in pairs(equip) do
            for equip_index, check_str in pairs(equip_info) do
                print(string.format("装備名: %s, 装備ID: %d, チェック文字列: %s", equip_name, equip_index,
                                    check_str))
            end
        end
    end
end

function vakarine_equip_bufflist_close(frame, ctrl, str, num)
    frame:ShowWindow(0)
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
    local closeBtn = bufflistframe:CreateOrGetControl('button', 'closeBtn', 450, 0, 30, 30)
    AUTO_CAST(closeBtn)
    closeBtn:SetImage("testclose_button")
    closeBtn:SetGravity(ui.RIGHT, ui.TOP)
    closeBtn:SetEventScript(ui.LBUTTONUP, "vakarine_equip_bufflist_close");
    local sortedBuffIDs = {}
    for buffID, _ in pairs(g.settings[tostring(g.cid)]["buffid"]) do
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
            local check = g.settings[tostring(g.cid)]["buffid"][tostring(buffID)] or 0
            function vakarine_equip_buff_check(frame, ctrl, argStr, buffID)
                local check = ctrl:IsChecked()
                g.settings[tostring(g.cid)]["buffid"][tostring(buffID)] = check
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

function vakarine_equip_pic_lbtn(frame, ctrl, str, num)

    local frame = ui.GetFrame("headsupdisplay")
    local jobPic = GET_CHILD_RECURSIVELY(frame, "jobPic")
    local pic = GET_CHILD_RECURSIVELY(frame, "pic")

    pic:SetGravity(ui.RIGHT, ui.TOP);
    if ctrl ~= "GAME_START" then
        if g.settings[tostring(g.cid)].use == 0 then
            g.settings[tostring(g.cid)].use = 1
            pic:ShowWindow(1)
            pic:SetImage("itemslot_alchemy_mark")
            pic:SetEnableStretch(1);
            pic:EnableHitTest(1)
            pic:SetColorTone("FFFFFFFF")
            -- pic:SetEventScript(ui.LBUTTONUP, "vakarine_equip_buff_list")
        else
            pic:SetColorTone("FF555555")
            g.settings[tostring(g.cid)].use = 0
        end
        vakarine_equip_save_settings()
    else
        if g.settings[tostring(g.cid)].use == 0 then
            pic:SetColorTone("FF555555")
        else
            pic:ShowWindow(1)
            pic:SetImage("itemslot_alchemy_mark")
            pic:SetEnableStretch(1);
            pic:EnableHitTest(1)
            pic:SetColorTone("FFFFFFFF")
            -- pic:SetEventScript(ui.LBUTTONUP, "vakarine_equip_buff_list")
        end
    end
end

function vakarine_equip_switching(frame, msg, str, num)

    local frame = ui.GetFrame("headsupdisplay")
    local jobPic = GET_CHILD_RECURSIVELY(frame, "jobPic")
    AUTO_CAST(jobPic)
    local pic = jobPic:CreateOrGetControl("picture", "pic", 0, 0, 50, 50);
    AUTO_CAST(pic)
    pic:EnableHitTest(1)
    pic:SetEventScript(ui.LBUTTONUP, "vakarine_equip_pic_lbtn")
    pic:SetTextTooltip(g.lang == "Japanese" and "{ol}Vakarine Equip{nl}左クリックでON/OFF切替" or
                           "{ol}Vakarine Equip{nl}Left click to switch ON/OFF")
    vakarine_equip_pic_lbtn(frame, msg, str, num)
end

function vakarine_equip_BUFF_ON_MSG(frame, msg, str, buff_id)
    local exists = false
    for buffid, value in pairs(g.settings[tostring(g.cid)]["buffid"]) do
        if tonumber(buffid) == buff_id then
            exists = true
            if value == 1 then
                REMOVE_BUF(_, _, _, buff_id)
            end
            return
        end
    end
    if not exists then
        g.settings[tostring(g.cid)]["buffid"][tostring(buff_id)] = 0
        vakarine_equip_save_settings()
    end
end

function vakarine_equip_animus_unequip(frame, msg, str, num)

    session.ResetItemList();
    local equipItemList = session.GetEquipItemList();
    local cnt = equipItemList:Count();

    -- local unequip_tbl = {30, 8, 9, 19, 17, 18, 3, 14, 4, 5, 34, 33}
    local unequip_tbl = {30, 8, 9, 19, 17, 18, 3, 14, 4, 5}

    for i, spot_index in ipairs(unequip_tbl) do
        local equipItem = equipItemList:GetEquipItemByIndex(spot_index)
        if equipItem ~= nil then
            local spotName = item.GetEquipSpotName(equipItem.equipSpot)
            local iesid = tostring(equipItem:GetIESID())

            if iesid ~= "0" then
                item.UnEquip(spot_index)
                if i ~= #unequip_tbl then
                    ReserveScript("vakarine_equip_animus_unequip()", 0.15)
                    return
                end
            end
        end
    end

    --[[local equip_tbl = {"RH", "LH", "RH_SUB", "LH_SUB", "NECK", "RING1", "RING2", "SHIRT", "PANTS", "GLOVES", "BOOTS",
                       "SHOULDER", "BELT"}]]
    local equip_tbl = {"RH", "LH", "RH_SUB", "LH_SUB", "NECK", "RING1", "RING2", "SHIRT", "PANTS", "GLOVES", "BOOTS"}

    function vakarine_equip_item_equip()
        for i, spot_name in ipairs(equip_tbl) do
            local iesid = g.settings[tostring(g.cid)]["equip_iesid"][spot_name]

            if iesid ~= "0" and iesid ~= nil then
                local equip_item = session.GetInvItemByGuid(iesid);
                if spot_name == "NECK" then
                    local type = 584103 -- アニマス
                    equip_item = session.GetInvItemByType(type)
                    if equip_item == nil then
                        equip_item = session.GetInvItemByGuid(iesid);
                    end
                end
                if equip_item ~= nil then
                    local item_index = equip_item.invIndex
                    ITEM_EQUIP(item_index, spot_name)
                    g.settings[tostring(g.cid)]["equip_iesid"][spot_name] = nil
                    if i ~= #equip_tbl then
                        ReserveScript("vakarine_equip_item_equip()", 0.2)
                        return
                    end

                end
            end
            if i == #equip_tbl then
                ReserveScript("vakarine_equip_equips_check()", 0.2)
                -- vakarine_equip_equips_check()
                return
            end
        end
    end
    local frame = ui.GetFrame("inventory")
    if tonumber(USE_SUBWEAPON_SLOT) == 1 then
        DO_WEAPON_SLOT_CHANGE(frame, 1)
    else
        DO_WEAPON_SWAP(frame, 1)
    end
    vakarine_equip_item_equip()
end

function vakarine_equip_equips_check()
    local equipItemList = session.GetEquipItemList();
    local cnt = equipItemList:Count();

    --[[local check_equip_tbl = {8, 9, 30, 31, 19, 17, 18, 3, 14, 4, 5, 34, 33}
    local check_str_tbl = {"NoWeapon", "NoWeapon", "NoWeapon", "NoWeapon", "NoNeck", "NoRing", "NoRing", "NoShirt",
                           "NoPants", "NoGloves", "NoBoots", "NoOuter", "NoOuter"}]]
    local check_equip_tbl = {8, 9, 30, 31, 19, 17, 18, 3, 14, 4, 5}
    local check_str_tbl = {"NoWeapon", "NoWeapon", "NoWeapon", "NoWeapon", "NoNeck", "NoRing", "NoRing", "NoShirt",
                           "NoPants", "NoGloves", "NoBoots"}

    for i, spot_index in ipairs(check_equip_tbl) do
        local equipItem = equipItemList:GetEquipItemByIndex(spot_index)
        local obj = GetIES(session.GetEquipItemBySpot(spot_index):GetObject())
        local cls_name = obj.ClassName
        if string.find(cls_name, check_str_tbl[i]) ~= nil then
            local spotName = item.GetEquipSpotName(equipItem.equipSpot)
            imcAddOn.BroadMsg("NOTICE_Dm_!", spotName .. " Not equipped", 2);
            return
        end

    end
    imcAddOn.BroadMsg("NOTICE_Dm_stage_start", "[NH]End of Operation", 2);
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

    if not vakarine_equip_vakarine() then
        return
    end

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    -- print(tostring(mapCls.MapType))
    g.equip_iesids = g.equip_iesids or {}
    if mapCls.MapType == "Instance" then
        local unequip_tbl = {30 -- RH_SUB
        , 31 -- LH_SUB
        , 8 -- RH
        , 9 -- LH
        , 19 -- NECK
        , 17 -- RING1
        , 18 -- RING2
        , 3 -- SHIRT
        , 14 -- PANTS
        , 4 -- GLOVES
        , 5 -- BOOTS
        , 34 -- SHOULDER
        , 33 -- BELT
        }

        for i, equip in ipairs(g.util_tbl) do
            for equip_name, equip_info in pairs(equip) do
                for equip_index, check_str in pairs(equip_info) do
                    print(string.format("装備名: %s, 装備ID: %d, チェック文字列: %s", equip_name,
                                        equip_index, check_str))
                end
            end
        end

        session.ResetItemList();
        local equipItemList = session.GetEquipItemList();
        for _, spot_index in ipairs(unequip_tbl) do
            local equipItem = equipItemList:GetEquipItemByIndex(spot_index)
            if equipItem ~= nil then
                local spotName = item.GetEquipSpotName(equipItem.equipSpot)
                local iesid = tostring(equipItem:GetIESID())
                if iesid ~= "0" then
                    g.settings[tostring(g.cid)]["equip_iesid"][spotName] = iesid
                end
            end
        end
        vakarine_equip_save_settings()
        addon:RegisterMsg("GAME_START", "vakarine_equip_animus_unequip")

    elseif mapCls.MapType == "City" then

        function vakarine_equip_neck_equip(frame, msg, str, num)
            local equipItemList = session.GetEquipItemList();
            local equipItem = equipItemList:GetEquipItemByIndex(19);
            local iesid = equipItem:GetIESID()
            if iesid ~= g.settings[tostring(g.cid)]["equip_iesid"]["NECK"] then
                local equip_item = session.GetInvItemByGuid(g.settings[tostring(g.cid)]["equip_iesid"]["NECK"])
                local item_index = equip_item.invIndex
                item.Equip(item_index)
            end
        end
        addon:RegisterMsg("GAME_START", "vakarine_equip_neck_equip")
    end
end

--[[function vakarine_equip_animus_equip()

    for spot, iesid in pairs(g.settings[tostring(g.cid)]["equip_iesid"]) do
        local equip_item = session.GetInvItemByGuid(iesid);
        local item_index = equip_item.invIndex
        item.Equip(item_index)
    end
end]]
