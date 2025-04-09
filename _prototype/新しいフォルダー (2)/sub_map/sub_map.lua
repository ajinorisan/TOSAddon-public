local addon_name = "SUB_MAP"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

g.active_id = session.loginInfo.GetAID()
g.settings_path = string.format("../addons/%s/%s/settings.json", addon_name_lower, g.active_id)
local json = require("json")

function g.setup_hook(my_func, origin_func_name)
    g.funcs = g.funcs or {}
    local addon_upper = string.upper(addon_name)
    local rep_func_name = addon_upper .. "_BASE_" .. origin_func_name
    if (_G[rep_func_name] == nil) then
        _G[rep_func_name] = _G[origin_func_name]
        _G[origin_func_name] = my_func
    end
    g.funcs[origin_func_name] = _G[rep_func_name]
end

function g.setup_event(my_addon, origin_func_name, my_func_name)
    local function_name = string.gsub(origin_func_name, "%.", "")
    local original_func = _G[origin_func_name]

    if not _G["ADDONS"]["EVENTS"] then
        _G["ADDONS"]["EVENTS"] = {}
    end

    if not _G["ADDONS"]["EVENTS"]["ARGS"] then
        _G["ADDONS"]["EVENTS"]["ARGS"] = {}
    end

    local function hooked_function(...)
        local args = {...}
        local results = {original_func(...)}
        _G["ADDONS"]["EVENTS"]["ARGS"][function_name] = args
        imcAddOn.BroadMsg(function_name)
        return table.unpack(results)
    end

    _G[origin_func_name] = hooked_function
    my_addon:RegisterMsg(function_name, my_func_name)
end

function g.get_event_args(event_msg)
    return table.unpack(_G["ADDONS"]["EVENTS"]["ARGS"][event_msg])
end

function g.mkdir_new_folder()

    local folder = string.format("../addons/%s", addon_name_lower)
    local file_path = string.format("../addons/%s/mkdir.txt", addon_name_lower)
    local file = io.open(file_path, "r")
    if not file then
        os.execute('mkdir "' .. folder .. '"')
        file = io.open(file_path, "w")
        if file then
            file:write("A new file has been created")
            file:close()
        end
    else
        file:close()
    end

    local folder = string.format("../addons/%s/%s", addon_name_lower, g.active_id)
    local file_path = string.format("../addons/%s/%s/mkdir.txt", addon_name_lower, g.active_id)
    local file = io.open(file_path, "r")
    if not file then
        os.execute('mkdir "' .. folder .. '"')
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
    local pc = GetMyPCObject()
    local current_map = GetZoneName(pc)
    local map_cls = GetClass("Map", current_map)
    local map_type = map_cls.MapType
    return map_type
end

function g.save_json(path, tbl)
    local file = io.open(path, "w")
    local str = json.encode(tbl)
    file:write(str)
    file:close()
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

function g.save_settings()
    g.save_json(g.settings_path, g.settings)
end

function g.load_settings()

    local settings = g.load_json(g.settings_path)

    if not settings then
        settings = {
            x = 1200,
            y = 120,
            move = 1,
            hittest = 1,
            visible = 1,
            size = 200
        }
    end

    g.settings = settings

    g.save_settings()
end

function SUB_MAP_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()
    g.cid = session.GetMySession():GetCID()
    g.login_name = session.GetMySession():GetPCApc():GetName()

    g.load_settings()

    g.size = g.size or g.settings.size
    g.icon_size = g.icon_size or g.size * 0.08

    local map_type = g.get_map_type()

    if map_type ~= "Instance" then
        g.try = 0
        addon:RegisterMsg('GAME_START_3SEC', "sub_map_frame_init")
    end

    -- 流刑地1771　ゲナル1541　水路3740　男爵1176　サルビ2431　ヌオ滝2561
    local current_map_id = session.GetMapID()
    local map_name = GetClassByType("Map", current_map_id).ClassName

    local colonyClsList, cnt = GetClassList('guild_colony');
    for i = 0, cnt - 1 do
        local colonyCls = GetClassByIndexFromList(colonyClsList, i);

        local check_word = "GuildColony_"
        if string.find(map_name, check_word) then
            CHAT_SYSTEM(tostring(map_name))
            g.try = 0
            addon:RegisterMsg('GAME_START_3SEC', "sub_map_frame_init")
            return
        end
    end

end

function sub_map_frame_init_reserve()

end

function sub_map_monster(frame, msg, argStr, argNum, info)

    local frame = ui.GetFrame("sub_map")
    local gbox = GET_CHILD(frame, "gbox")
    local handle = info.handle
    local ctrl_name = "_MONPOS_" .. handle

    local mon_pic = GET_CHILD_RECURSIVELY(frame, ctrl_name)
    if not mon_pic then
        mon_pic = gbox:CreateOrGetControl("picture", ctrl_name, 0, 0, g.icon_size, g.icon_size)
    end
    AUTO_CAST(mon_pic)

    if not mon_pic:HaveUpdateScript("sub_map_monpic_auto_update") then
        mon_pic:RunUpdateScript("sub_map_monpic_auto_update", 1.0)
    end

    mon_pic:SetUserValue("HANDLE", handle)

    local mon_cls = GetClassByType("Monster", info.type)
    local img_name = mon_cls.MinimapIcon
    mon_pic:SetImage(img_name)
    mon_pic:SetEnableStretch(1)
    mon_pic:ShowWindow(1)
end

function sub_map_monpic_auto_update(mon_pic)

    local frame = mon_pic:GetTopParentFrame()
    local gbox = GET_CHILD(frame, "gbox")
    local handle = mon_pic:GetUserIValue("HANDLE")
    local actor = world.GetActor(handle)

    if actor then
        local mapprop = session.GetCurrentMapProp()
        local map_pic = GET_CHILD_RECURSIVELY(frame, "map_pic", "ui::CPicture")
        local actor_pos = actor:GetPos()
        local mon_cls = GetClassByType("Monster", actor:GetType())
        if TryGetProp(mon_cls, "MonRank", "None") == "Boss" then
            local pos = mapprop:WorldPosToMinimapPos(actor_pos, map_pic:GetWidth(), map_pic:GetHeight())
            local x = (pos.x - mon_pic:GetWidth() / 2)
            local y = (pos.y - mon_pic:GetHeight() / 2)
            mon_pic:SetOffset(x, y)
        end
        return 1
    else
        gbox:RemoveChild("_MONPOS_" .. handle)
        return 1
    end

    return 1
end

function sub_map_frame_toggle(frame, ctrl)

    if g.settings.visible == 1 then
        g.settings.visible = 0
    else
        g.settings.visible = 1
    end
    g.save_settings()
    sub_map_frame_init()
    return
end

function sub_map_frame_layer_change(frame, ctrl, str, num)
    if str == "ON" then
        frame:SetLayerLevel(32)
        -- frame:SetSkinName("chat_window")
        -- frame:SetAlpha(30)
    end
end

function sub_map_frame_map_link(frame, ctrl)

    if keyboard.IsKeyPressed("LCTRL") ~= 1 then
        return;
    end

    local x, y = GET_LOCAL_MOUSE_POS(ctrl);

    local cur_map_id = session.GetMapID()
    local map_cls = GetClassByType("Map", cur_map_id)
    local map_name = map_cls.ClassName

    local mapprop = geMapTable.GetMapProp(map_name);
    local worldPos = mapprop:MinimapPosToWorldPos(x, y, ctrl:GetWidth(), ctrl:GetHeight());
    LINK_MAP_POS(map_name, worldPos.x, worldPos.y);
end

function sub_map_config_save(frame, ctrl)
    local ctrl_name = ctrl:GetName()
    if ctrl_name == "size_edit" then
        local size = tonumber(ctrl:GetText())
        if size and size >= 150 and size <= 350 then
            g.settings.size = size
            g.size = size
            g.icon_size = g.size * 0.08
        else
            ui.SysMsg(g.lang == "Japanese" and "{ol}範囲外です" or "{ol}Out of range")
            sub_map_config(frame, ctrl, "close")
            return
        end

    elseif ctrl_name == "move" then
        local is_check = ctrl:IsChecked()
        g.settings.move = is_check
    end
    sub_map_config(frame, ctrl, "close")
    sub_map_frame_init()
    g.save_settings()
end

function sub_map_config(frame, ctrl, str)

    local x = frame:GetWidth() - 85
    local size_edit = frame:CreateOrGetControl('edit', 'size_edit', x, 0, 50, 25)
    AUTO_CAST(size_edit)
    size_edit:SetFontName('white_14_ol')
    size_edit:SetSkinName('test_weight_skin')
    size_edit:SetTextAlign('center', 'center')
    size_edit:SetEventScript(ui.ENTERKEY, "sub_map_config_save");
    size_edit:SetText(g.settings.size or tonumber(200))
    size_edit:SetTextTooltip(g.lang == "Japanese" and "{ol}150～350" or "{ol}150～350")

    if str == 0 then

        size_edit:ShowWindow(1)
    else
        size_edit:ShowWindow(0)
    end

    local move = frame:CreateOrGetControl('checkbox', 'move', 0, 0, 25, 25)
    AUTO_CAST(move)

    move:SetCheck(g.settings.move)
    move:SetGravity(ui.RIGHT, ui.TOP)
    move:SetEventScript(ui.LBUTTONUP, "sub_map_config_save")
    move:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックを外すとフレーム固定" or
                            "{ol}Frame fixed when unchecked")

    if str == 0 then
        move:ShowWindow(1)
    else
        move:ShowWindow(0)
    end
end

function sub_map_frame_end_drag(frame, ctrl)
    g.settings.x = frame:GetX()
    g.settings.y = frame:GetY()
    g.save_settings()
end

function sub_map_frame_init()
    -- CHAT_SYSTEM("sub_map_frame_init")
    local frame = ui.GetFrame("sub_map")
    frame:RemoveAllChild()

    frame:EnableMove(g.settings.move)
    frame:EnableHitTest(g.settings.hittest)

    frame:SetEventScript(ui.LBUTTONUP, "sub_map_frame_end_drag")
    frame:SetEventScript(ui.RBUTTONUP, "sub_map_config")

    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")
    frame:SetPos(g.settings.x, g.settings.y)
    frame:SetLayerLevel(12)
    frame:ShowWindow(1)

    local title = frame:CreateOrGetControl("richtext", "title", 20, 5)
    local map_id = session.GetMapID()
    local map_name = GetClassByType("Map", map_id).Name
    title:SetText("{ol}{S10}" .. map_name)

    local display = frame:CreateOrGetControl("picture", "display", 0, 3, 15, 15)
    AUTO_CAST(display)
    display:SetEnableStretch(1)
    display:EnableHitTest(1)
    display:SetEventScript(ui.LBUTTONUP, "sub_map_frame_toggle")
    display:SetTextTooltip("{ol}Display / hide")

    if g.settings.visible == 1 then
        display:SetImage("btn_minus");
        frame:Resize(g.size + 10, g.size + 40)
    else
        display:SetImage("btn_plus");
        frame:Resize(g.size + 10, 40)
        return
    end

    local gbox = frame:CreateOrGetControl("groupbox", "gbox", g.size + 10, g.size + 10, ui.LEFT, ui.BOTTOM, 0, 30, 0, 0)
    gbox:SetEventScript(ui.MOUSEON, "sub_map_frame_layer_change")
    gbox:SetEventScriptArgString(ui.MOUSEON, "ON")
    -- gbox:SetScrollBar(0);
    -- gbox:EnableScrollBar(0);

    gbox:SetEventScript(ui.LBUTTONDOWN, "sub_map_frame_map_link")
    gbox:SetTextTooltip(g.lang == "Japanese" and
                            "{ol}右クリック:設定{nl}LCTRL+左クリック:マップリンク" or
                            "{ol}{ol}Right click:Settings{nl}LCTRL+Left click:Map Link")
    -- gbox:SetEventScript(ui.MOUSEOFF, "sub_map_frame_layer_change")
    -- gbox:SetEventScriptArgString(ui.MOUSEOFF, "OFF")

    local map_pic = gbox:CreateOrGetControl("picture", "map_pic", g.size, g.size, ui.LEFT, ui.TOP, 0, 0, 0, 0)
    AUTO_CAST(map_pic)
    map_pic:SetEnableStretch(1)
    map_pic:EnableHitTest(0)

    local my = gbox:CreateOrGetControl("picture", "my", g.icon_size, g.icon_size, ui.LEFT, ui.TOP, 0, 0, 0, 0)
    AUTO_CAST(my)
    my:SetImage("minimap_leader")
    my:SetEnableStretch(1)

    local cur_map_id = session.GetMapID()
    local map_cls = GetClassByType("Map", cur_map_id)
    local map_name = map_cls.ClassName
    map_pic:SetImage(map_name)

    sub_map_MAP_CHARACTER_UPDATE(frame)
    sub_map_set_warp_point(frame, map_name)

    g.addon:RegisterMsg("MAP_CHARACTER_UPDATE", "sub_map_MAP_CHARACTER_UPDATE")
    g.addon:RegisterMsg("MON_MINIMAP", "sub_map_monster")

    g.addon:RegisterMsg("FPS_UPDATE", "sub_map_mapicon_update")

    -- g.addon:RegisterMsg("FPS_UPDATE", "sub_map_set_pcicon_update")
    g.addon:RegisterMsg("GUILD_INFO_UPDATE", "sub_map_MAP_UPDATE_GUILD")
    g.addon:RegisterMsg("PARTY_INST_UPDATE", "sub_map_MAP_UPDATE_PARTY_INST")
    addon:RegisterOpenOnlyMsg('PARTY_UPDATE', 'sub_map_MAP_UPDATE_PARTY');
    -- g.addon:RegisterMsg("PARTY_UPDATE", "sub_map_set_pcicon_update")
    g.handle_tbl = {}

    if g.try == 0 then
        frame:RunUpdateScript("sub_map_frame_init", 2.0)
        g.try = 1
    end
end

function sub_map_MAP_UPDATE_PARTY_INST(frame, msg, str, partyType)
    local mapprop = session.GetCurrentMapProp();
    local myInfo = session.party.GetMyPartyObj(partyType);

    local list = session.party.GetPartyMemberList(partyType);
    local count = list:Count();

    local header = "PM_";
    if partyType == PARTY_GUILD then
        header = "GM_";
    end
    for i = 0, count - 1 do
        local skip = false
        local pcInfo = list:Element(i);
        if myInfo ~= pcInfo then
            if is_my_guild_member(pcInfo:GetAID()) then
                DESTROY_GUILD_MEMBER_ICON(frame, msg, pcInfo:GetAID())
            end

            local instInfo = pcInfo:GetInst();
            local name = header .. pcInfo:GetAID();
            local pic = GET_CHILD_RECURSIVELY(frame, name);
            AUTO_CAST(pic)
            if pic ~= nil then
                local iconinfo = pcInfo:GetIconInfo()
                sub_map_SET_PM_MINIMAP_ICON(pic, instInfo.hp, pcInfo:GetAID());
                -- tolua.cast(pic, "ui::CControlSet")
                sub_map_SET_PM_MAPPOS(frame, pic, instInfo, mapprop)
            else
                -- local mapFrame = ui.GetFrame('map');
                local mapFrame = ui.GetFrame('sub_map');
                sub_map_MAP_UPDATE_PARTY(mapFrame, "PARTY_UPDATE", nil, 0);
                return;
            end
        end
    end

end

function MAP_UPDATE_PARTY(frame, msg, arg, type, info)
    DESTROY_CHILD_BYNAME(frame, 'PM_');

    local mapprop = session.GetCurrentMapProp();
    local list = session.party.GetPartyMemberList();
    local count = list:Count();

    if count == 1 then
        return;
    end

    for i = 0, count - 1 do
        local pcInfo = list:Element(i);
        sub_map_CREATE_PM_PICTURE(frame, pcInfo, type, mapprop);
    end
end

function sub_map_MAP_UPDATE_GUILD(frame, msg, arg, type, info)
    DESTROY_CHILD_BYNAME(frame, 'GM_');
    if session.world.IsIntegrateServer() == true then
        DESTROY_GUILD_MEMBER_ICON()
        return;
    end

    local mapprop = session.GetCurrentMapProp();
    local list = session.party.GetPartyMemberList(PARTY_GUILD);
    local count = list:Count();
    if count == 1 then
        return;
    end

    for i = 0, count - 1 do
        local pcInfo = list:Element(i)
        if pcInfo:GetHandle() ~= 0 then
            local show_flag = true
            if pcInfo:GetHandle() ~= session.GetMyHandle() then
                local actor = world.GetActor(pcInfo:GetHandle())
                if actor ~= nil and session.friendly_fight.IsFriendlyFightState() == true and actor:IsVisiableState() ==
                    false then
                    show_flag = false
                end
            end

            if show_flag == true then
                sub_map_CREATE_PM_PICTURE(frame, pcInfo, PARTY_GUILD, mapprop)
            end
        end
    end
end

function sub_map_CREATE_PM_PICTURE(frame, pcInfo, type, mapprop)
    local myInfo = session.party.GetMyPartyObj(type);

    if nil == myInfo then
        return;
    end

    if myInfo == pcInfo then
        return;
    end

    if myInfo:GetMapID() ~= pcInfo:GetMapID() or myInfo:GetChannel() ~= pcInfo:GetChannel() then
        return;
    end

    local header = "PM_";
    if type == PARTY_GUILD then
        header = "GM_";
    end
    local name = header .. pcInfo:GetAID()

    if pcInfo:GetMapID() == 0 then
        frame:RemoveChild(name);
        return
    end

    if type == PARTY_GUILD then
        if frame:GetChild("GM_" .. pcInfo:GetAID()) ~= nil then
            return;
        end
    else
        if frame:GetChild("PM_" .. pcInfo:GetAID()) ~= nil then
            return;
        end
    end

    local instInfo = pcInfo:GetInst();
    local gbox = GET_CHILD(frame, "gbox")

    -- local map_partymember_iconset = gbox:CreateOrGetControlSet('map_partymember_iconset', name, 0, 0);
    local map_partymember_iconset = gbox:CreateOrGetControl("picture", name, 0, 0, g.icon_size, g.icon_size)
    AUTO_CAST(map_partymember_iconset)
    map_partymember_iconset:SetEnableStretch(1)
    -- print(tostring(g.icon_size))
    map_partymember_iconset:SetTooltipType("partymap");
    map_partymember_iconset:SetTooltipArg(pcInfo:GetName(), type);

    --[[local pm_name_rtext = GET_CHILD_RECURSIVELY(map_partymember_iconset, "pm_name", "ui::CRichText")

    pm_name_rtext:SetTextByKey("pm_fname", pcInfo:GetName())
    local iconinfo = pcInfo:GetIconInfo();]]
    sub_map_SET_PM_MINIMAP_ICON(map_partymember_iconset, instInfo.hp, pcInfo:GetAID());
    sub_map_SET_PM_MAPPOS(frame, map_partymember_iconset, instInfo, mapprop)
end

function sub_map_SET_PM_MAPPOS(frame, controlset, instInfo, mapprop)
    local worldPos = instInfo:GetPos();

    sub_map_SET_MINIMAP_CTRLSET_POS(frame, controlset, worldPos, mapprop);
end

function sub_map_SET_MINIMAP_CTRLSET_POS(parent, ctrlSet, worldPos, mapprop)

    if parent:GetValue2() == 1 then
        local map_pic = GET_CHILD_RECURSIVELY(parent, 'map_pic');

        local minimapw = g.icon_size
        local minimaph = g.icon_size

        local pos = mapprop:WorldPosToMinimapPos(worldPos, map_pic:GetWidth(), map_pic:GetHeight());
        local x = (pos.x - g.icon_size / 2)
        local y = (pos.y - g.icon_size / 2)

        ctrlSet:SetPos(x, y);
        return;
    end
    local map_pic = GET_CHILD_RECURSIVELY(parent, 'map_pic');

    local minimapw = g.icon_size
    local minimaph = g.icon_size

    local pos = mapprop:WorldPosToMinimapPos(worldPos, map_pic:GetWidth(), map_pic:GetHeight());
    -- print(tostring(pos.x))
    local x = (pos.x - g.icon_size / 2)
    local y = (pos.y - g.icon_size / 2)

    ctrlSet:SetPos(x, y);
end

function sub_map_SET_PM_MINIMAP_ICON(map_partymember_iconset, pcHP, aid)
    -- local pm_icon = GET_CHILD_RECURSIVELY(map_partymember_iconset, "pm_icon");
    if pcHP > 0 then
        if session.party.GetPartyMemberInfoByAID(PARTY_NORMAL, aid) ~= nil then
            map_partymember_iconset:SetImage('Archer_party');
        elseif session.party.GetPartyMemberInfoByAID(PARTY_GUILD, aid) ~= nil then
            map_partymember_iconset:SetImage('Wizard_party');
        else
            map_partymember_iconset:SetImage('die_party');
        end
    else
        map_partymember_iconset:SetImage('die_party');
    end
end
-- PARTY_GUILD=1:number
-- PARTY_NORMAL=0:number

function sub_map_get_mapinfo()
    local map_class_name = session.GetMapName()

    if map_class_name == nil or map_class_name == "" or map_class_name == "None" then
        return
    end

    local frame = ui.GetFrame("sub_map")
    local map_pic = frame:GetChildRecursively("map_pic")

    local property = geMapTable.GetMapProp(map_class_name)

    local class_list, class_count = GetClassList("GenType_" .. map_class_name)
    local mongens = property.mongens
    local temp_tbl = {}
    local count = mongens:Count()

    for i = 0, count - 1 do
        local mon_prop = mongens:Element(i)
        local ies_data = GetClassByIndexFromList(class_list, i)
        local class_type = ies_data.ClassType

        local state = GetNPCState(map_class_name, ies_data.GenType)

        if not state then
            state = false
        end

        local gen_list = mon_prop.GenList
        local map_pos
        if gen_list:Count() > 0 then
            map_pos = property:WorldPosToMinimapPos(gen_list:Element(0), map_pic:GetWidth(), map_pic:GetHeight())
        end
        local icon_name = mon_prop:GetMinimapIcon()

        if string.find(class_type, "treasure_box") then

            if ies_data.ArgStr1 ~= "None" then
                local data = {
                    class_type = class_type,
                    state = state,
                    map_pos = map_pos,
                    icon_name = icon_name,
                    argstr1 = ies_data.ArgStr1,
                    argstr2 = ies_data.ArgStr2,
                    argstr3 = ies_data.ArgStr3,
                    name = ies_data.Name
                }
                table.insert(temp_tbl, data)
            end
        elseif string.find(class_type, "statue_zemina") or string.find(class_type, "statue_vakarine") or
            string.find(class_type, "klaipeda_square_statue") or string.find(class_type, "npc_orsha_goddess") then
            local data = {
                class_type = class_type,
                state = state,
                map_pos = map_pos,
                icon_name = icon_name,
                argstr1 = ies_data.ArgStr1,
                argstr2 = ies_data.ArgStr2,
                argstr3 = ies_data.ArgStr3,
                name = ies_data.Name
            }
            table.insert(temp_tbl, data)
        end
    end

    return temp_tbl
end

function sub_map_mapicon_update(frame, msg, str, num)

    local info_table = sub_map_get_mapinfo()

    local frame = ui.GetFrame("sub_map")
    local gbox = GET_CHILD(frame, "gbox")

    local function split(str, delim)
        local return_data = {};
        for match in string.gmatch(str, "[^" .. delim .. "]+") do
            table.insert(return_data, match);
        end
        return return_data
    end

    for i, data in ipairs(info_table) do

        if string.find(data.class_type, "treasure_box") then

            local item_split = split(data.argstr2, ":");

            local item_name = GetClass("Item", item_split[2]).Name

            local icon = gbox:CreateOrGetControl("picture", "icon_" .. i, g.icon_size, g.icon_size, ui.LEFT, ui.TOP, 0,
                                                 0, 0, 0)
            AUTO_CAST(icon)

            icon:SetTextTooltip("{ol}{s10}" .. data.argstr1 .. "{nl}" .. item_name);
            icon:SetOffset(data.map_pos.x - icon:GetWidth() / 2, data.map_pos.y - icon:GetHeight() / 2)
            icon:SetEnableStretch(1)

            if data.state then
                icon:SetImage("icon_item_box")
            else
                icon:SetText("{ol}{s10}" .. data.argstr1)
                icon:SetImage("compen_btn")
            end

        end

        if string.find(data.class_type, "statue_vakarine") or string.find(data.class_type, "klaipeda_square_statue") or
            string.find(data.class_type, "npc_orsha_goddess") or string.find(data.class_type, "statue_zemina") then

            local icon = gbox:CreateOrGetControl("picture", "icon_" .. i, g.icon_size, g.icon_size, ui.LEFT, ui.TOP, 0,
                                                 0, 0, 0)
            AUTO_CAST(icon)
            icon:SetTextTooltip("{ol}{s10}" .. data.name);
            icon:SetImage(data.icon_name)
            icon:SetOffset(data.map_pos.x - icon:GetWidth() / 2, data.map_pos.y - icon:GetHeight() / 2)
            icon:SetEnableStretch(1)

            if data.state then
                icon:SetColorTone("FFFFFFFF")
            else
                icon:SetColorTone("FF555555")
            end

        end

    end
    gbox:Invalidate()
end

function sub_map_draw_fog()
    local frame = ui.GetFrame("sub_map")
    local gbox = GET_CHILD(frame, "gbox")
    local map_pic = frame:GetChildRecursively("map_pic")
    AUTO_CAST(map_pic)
    HIDE_CHILD_BYNAME(map_pic, "sub_map_fog_");
    local map_id = session.GetMapID()
    local map_name = GetClassByType("Map", map_id).ClassName

    if MAP_USE_FOG(map_name) == 0 then
        return
    end

    local map_frame = ui.GetFrame('map');
    local map = GET_CHILD(map_frame, "map", 'ui::CPicture');

    local map_zoom = math.abs(tonumber(map_pic:GetWidth()) / tonumber(map:GetWidth()))

    local list = session.GetMapFogList(session.GetMapName());
    local cnt = list:Count();
    for i = 0, cnt - 1 do
        local tile = list:PtrAt(i);

        if tile.revealed == 0 then

            local name = string.format("sub_map_fog_%d", i);
            local tilePosX = (tile.x * map_zoom)
            local tilePosY = (tile.y * map_zoom)
            local tileWidth = math.ceil(tile.w * map_zoom)

            local tileHeight = math.ceil(tile.h * map_zoom)

            local pic = map_pic:CreateOrGetControl("picture", name, tilePosX, tilePosY, tileWidth, tileHeight);
            AUTO_CAST(pic)

            pic:ShowWindow(1);
            pic:SetImage("fullred");
            pic:SetEnableStretch(1);
            pic:SetAlpha(40);
            pic:EnableHitTest(0);

        end
    end

    frame:Invalidate();
end

function sub_map_set_warp_point(frame, map_name)

    local mapprop = geMapTable.GetMapProp(map_name)
    local mongens = mapprop.mongens
    local count = mongens:Count()

    local gbox = frame:GetChild("gbox")
    local map_pic = gbox:GetChild("map_pic")

    for i = 0, count - 1 do
        local mon_prop = mongens:Element(i)
        local icon_name = mon_prop:GetMinimapIcon()
        if icon_name == "minimap_portal" or icon_name == "minimap_erosion" then
            local gen_list = mon_prop.GenList
            local gen_count = gen_list:Count()
            for j = 0, gen_count - 1 do
                local dialog = mon_prop:GetDialog()
                local warp_cls = GetClass("Warp", mon_prop:GetDialog())
                if not warp_cls then
                    for match in mon_prop:GetDialog():gmatch("[a-zA-Z]+_(.*)") do
                        warp_cls = GetClass("Warp", match)
                    end
                end
                if warp_cls then
                    local cls_name = TryGetProp(warp_cls, "TargetZone", "None")
                    local pos = gen_list:Element(j)

                    local mappos = mapprop:WorldPosToMinimapPos(pos.x, pos.z, map_pic:GetWidth(), map_pic:GetHeight())
                    local icon = gbox:CreateOrGetControl("picture", "icon_" .. cls_name, g.icon_size, g.icon_size,
                                                         ui.LEFT, ui.TOP, 0, 0, 0, 0)
                    AUTO_CAST(icon)
                    local map_cls = GetClass("Map", cls_name);
                    icon:SetTextTooltip("{ol}{s10}" .. map_cls.Name);
                    icon:SetImage(mon_prop:GetMinimapIcon())
                    icon:SetOffset(mappos.x - icon:GetWidth() / 2, mappos.y - icon:GetHeight() / 2)
                    icon:SetEnableStretch(1)

                end
            end
        end
    end

    gbox:Invalidate()
end

function sub_map_MAP_CHARACTER_UPDATE(frame, msg, str, num)

    sub_map_draw_fog()

    local myHandle = session.GetMyHandle()
    local map_pic = frame:GetChildRecursively("map_pic")
    local pos = info.GetPositionInMap(session.GetMyHandle(), map_pic:GetWidth(), map_pic:GetHeight())
    local my = frame:GetChildRecursively("my")
    AUTO_CAST(my)
    my:ShowWindow(0)
    my:SetOffset(pos.x - my:GetWidth() / 2, pos.y - my:GetHeight() / 2)
    local mapprop = session.GetCurrentMapProp()
    local angle = info.GetAngle(myHandle) - mapprop.RotateAngle
    my:SetAngle(angle)
    my:ShowWindow(1)
    map_pic:Invalidate()

end

--[[local function sub_map_display_party_member(party_type, type_str, default_icon)

    local remove = false
    local my_info = session.party.GetMyPartyObj(party_type)

    if not my_info then
        remove = true
    end

    local list = session.party.GetPartyMemberList(party_type)
    local count = list:Count()

    if count == 1 then
        remove = true
    end

    local my_handle = session.GetMyHandle()

    if remove then

        for handle, _ in pairs(g.handle_tbl) do

            local icon = GET_CHILD_RECURSIVELY(gbox, "pm" .. handle)
            if icon then
                gbox:RemoveChild(icon:GetName())
                g.handle_tbl[handle] = nil
            end

            local icon = GET_CHILD_RECURSIVELY(gbox, "gm" .. handle)
            if icon then
                gbox:RemoveChild(icon:GetName())
                g.handle_tbl[handle] = nil
            end

        end
        -- return
    end

    for i = 0, count - 1 do
        local pc_info = list:Element(i)
        local handle = pc_info:GetHandle()

        if my_info:GetMapID() == pc_info:GetMapID() and my_info:GetChannel() == pc_info:GetChannel() and my_handle ~=
            handle and handle ~= 0 and not handle_tbl[handle] then

            handle_tbl[handle] = true
            g.handle_tbl[handle] = type_str

            local instInfo = pc_info:GetInst()
            local worldPos = instInfo:GetPos()
            local pos = mapprop:WorldPosToMinimapPos(worldPos, map_pic:GetWidth(), map_pic:GetHeight())
            local x = (pos.x - g.icon_size / 2)
            local y = (pos.y - g.icon_size / 2)
            local icon = GET_CHILD_RECURSIVELY(gbox, type_str .. handle)
            if icon then
                if math.floor(x) ~= icon:GetX() then
                    gbox:RemoveChild(handle)
                    icon = gbox:CreateOrGetControl("picture", type_str .. handle, x, y, g.icon_size, g.icon_size)
                    AUTO_CAST(icon)

                    icon:SetTextTooltip("{ol}{s10}" .. pc_info:GetName());
                    icon:SetEnableStretch(1)

                end
            else
                icon = gbox:CreateOrGetControl("picture", type_str .. handle, x, y, g.icon_size, g.icon_size)
                AUTO_CAST(icon)
                icon:SetTextTooltip("{ol}{s10}" .. pc_info:GetName());
                icon:SetEnableStretch(1)
            end

            local pcinfo_hp = instInfo.hp
            if pcinfo_hp > 0 then
                icon:SetImage(default_icon)
            else
                icon:SetImage("die_party")
            end
        else
            local icon = GET_CHILD_RECURSIVELY(gbox, "pm" .. handle)

            if icon then
                gbox:RemoveChild(icon:GetName())
                g.handle_tbl[handle] = nil
            end

            local icon = GET_CHILD_RECURSIVELY(gbox, "gm" .. handle)

            if icon then
                gbox:RemoveChild(icon:GetName())
                g.handle_tbl[handle] = nil
            end

        end
    end
end

function sub_map_set_pcicon_update(frame, msg, str, num, info)

    local frame = ui.GetFrame("sub_map")
    local gbox = GET_CHILD(frame, "gbox")
    local map_pic = frame:GetChildRecursively("map_pic")
    local mapprop = session.GetCurrentMapProp()
    local handle_tbl = {}

    sub_map_display_party_member(PARTY_NORMAL, "pm", "Archer_party")

    local isAutoChallengeMap = session.IsAutoChallengeMap();
    local isSoloChallengeMap = session.IsSoloChallengeMap();

    if not isAutoChallengeMap and not isSoloChallengeMap then
        sub_map_display_party_member(PARTY_GUILD, "gm", "Wizard_party")

    else
        for handle, str_type in pairs(g.handle_tbl) do
            if str_type == "gm" then
                local icon = GET_CHILD_RECURSIVELY(gbox, str_type .. handle)
                if icon then
                    gbox:RemoveChild(str_type .. handle)
                end
                g.handle_tbl[handle] = nil
            end
        end
    end
    gbox:Invalidate()

end]]
