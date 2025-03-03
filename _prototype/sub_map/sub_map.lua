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
            visible = 1
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

    local map_type = g.get_map_type()

    if map_type ~= "Instance" then
        addon:RegisterMsg("GAME_START_3SEC", "sub_map_frame_init")
        addon:RegisterMsg("GUILD_INFO_UPDATE", "sub_map_update_member_guild")
        addon:RegisterMsg("PARTY_INST_UPDATE", "sub_map_update_member_party")
        addon:RegisterMsg("PARTY_UPDATE", "sub_map_update_member_party")
    end

end

function sub_map_monster(frame, msg, argStr, argNum, info)

    local frame = ui.GetFrame("sub_map")
    local gbox = GET_CHILD(frame, "gbox")
    local handle = info.handle
    local ctrl_name = "_MONPOS_" .. handle

    local mon_pic = GET_CHILD_RECURSIVELY(frame, ctrl_name)
    if not mon_pic then
        mon_pic = gbox:CreateOrGetControl("picture", ctrl_name, 0, 0, 20, 20)
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

function sub_map_frame_init()

    local frame = ui.GetFrame("sub_map")
    frame:RemoveAllChild()

    frame:EnableMove(g.settings.move)
    frame:EnableHitTest(g.settings.hittest)

    local function sub_map_frame_end_drag(frame, ctrl)
        g.settings.x = frame:GetX()
        g.settings.y = frame:GetY()
        g.save_settings()
    end
    frame:SetEventScript(ui.LBUTTONUP, "sub_map_frame_end_drag")

    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")
    frame:SetPos(g.settings.x, g.settings.y)
    frame:SetLayerLevel(12)
    frame:ShowWindow(1)

    local title = frame:CreateOrGetControl("richtext", "title", 20, 5)
    title:SetText("{ol}{S10}Sub Map")

    local display = frame:CreateOrGetControl("picture", "display", 0, 3, 15, 15)
    AUTO_CAST(display)
    display:SetEnableStretch(1)
    display:EnableHitTest(1)
    display:SetEventScript(ui.LBUTTONUP, "sub_map_frame_toggle")
    display:SetTextTooltip("{ol}Display / hide")

    if g.settings.visible == 1 then
        display:SetImage("btn_minus");
        frame:Resize(230, 230)
    else
        display:SetImage("btn_plus");
        frame:Resize(230, 20)
        return
    end

    local gbox = frame:CreateOrGetControl("groupbox", "gbox", 200, 200, ui.LEFT, ui.BOTTOM, 0, 20, 0, 0)
    gbox:SetEventScript(ui.MOUSEON, "sub_map_frame_layer_change")
    gbox:SetEventScriptArgString(ui.MOUSEON, "ON")

    gbox:SetEventScript(ui.LBUTTONDOWN, "sub_map_frame_map_link")
    -- gbox:SetEventScript(ui.MOUSEOFF, "sub_map_frame_layer_change")
    -- gbox:SetEventScriptArgString(ui.MOUSEOFF, "OFF")

    local map_pic = gbox:CreateOrGetControl("picture", "map_pic", 200, 200, ui.LEFT, ui.TOP, 0, 0, 0, 0)
    AUTO_CAST(map_pic)
    map_pic:SetEnableStretch(1)
    map_pic:EnableHitTest(0)

    local my = gbox:CreateOrGetControl("picture", "my", 30, 30, ui.LEFT, ui.TOP, 0, 0, 0, 0)
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
    g.addon:RegisterMsg("FPS_UPDATE", "sub_map_set_pcicon_update")
    g.addon:RegisterMsg("GUILD_INFO_UPDATE", "sub_map_set_pcicon_update")
    g.addon:RegisterMsg("PARTY_INST_UPDATE", "sub_map_set_pcicon_update")
    g.addon:RegisterMsg("PARTY_UPDATE", "sub_map_set_pcicon_update")
    g.handle_tbl = {}
end

function sub_map_set_pcicon_update(frame, msg, str, num, info)

    local frame = ui.GetFrame("sub_map")
    local gbox = GET_CHILD(frame, "gbox")
    local map_pic = frame:GetChildRecursively("map_pic")
    local mapprop = session.GetCurrentMapProp()
    local handle_tbl = {}

    local function sub_map_display_party_member(party_type, type_str, default_icon)
        local my_info = session.party.GetMyPartyObj(party_type)
        if not my_info then
            return
        end

        local my_handle = session.GetMyHandle()
        local list = session.party.GetPartyMemberList(party_type)
        local count = list:Count()

        if count == 1 then
            return
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
                local x = (pos.x - 10)
                local y = (pos.y - 10)
                local icon = GET_CHILD_RECURSIVELY(gbox, type_str .. handle)
                if icon then
                    if math.floor(x) ~= icon:GetX() then
                        gbox:RemoveChild(handle)
                        icon = gbox:CreateOrGetControl("picture", type_str .. handle, x, y, 20, 20)
                        AUTO_CAST(icon)

                        icon:SetTextTooltip("{ol}{s10}" .. pc_info:GetName());
                        icon:SetEnableStretch(1)

                    end
                else
                    icon = gbox:CreateOrGetControl("picture", type_str .. handle, x, y, 20, 20)
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

            end
        end
    end
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
        return
    end

    for handle, str_type in pairs(g.handle_tbl) do
        if not handle_tbl[handle] then
            local icon = GET_CHILD_RECURSIVELY(gbox, str_type .. handle)
            if icon then
                gbox:RemoveChild(str_type .. handle)
            end
            g.handle_tbl[handle] = nil -- g.handle_tbl から削除
        end
    end

    gbox:Invalidate()

end

function sub_map_set_warp_point(frame, map_name)

    local mapprop = geMapTable.GetMapProp(map_name)
    local mongens = mapprop.mongens
    local count = mongens:Count()

    local gbox = frame:GetChild("gbox")

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

                    local mappos = mapprop:WorldPosToMinimapPos(pos.x, pos.z, gbox:GetWidth(), gbox:GetHeight())
                    local icon = gbox:CreateOrGetControl("picture", "icon_" .. cls_name, 20, 20, ui.LEFT, ui.TOP, 0, 0,
                        0, 0)
                    AUTO_CAST(icon)
                    local map_cls = GetClass("Map", cls_name);
                    icon:SetTextTooltip("{ol}{s10}" .. map_cls.Name);
                    icon:SetImage(mon_prop:GetMinimapIcon())
                    icon:SetOffset(mappos.x - 10, mappos.y - 10)
                    icon:SetEnableStretch(1)

                end
            end
        end
    end
    gbox:Invalidate()
end

function sub_map_MAP_CHARACTER_UPDATE(frame, msg, str, num)

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

--[[function sub_map_set_pcicon(frame, msg, str, num)

    local frame = ui.GetFrame("sub_map")
    local gbox = GET_CHILD(frame, "gbox")
    local map_pic = frame:GetChildRecursively("map_pic")
    local mapprop = session.GetCurrentMapProp()
    local handle_tbl = {}

    local function sub_map_display_party_member(party_type, icon_prefix, default_icon)
        local my_info = session.party.GetMyPartyObj(party_type)
        if not my_info then
            return
        end

        local my_handle = session.GetMyHandle()
        local list = session.party.GetPartyMemberList(party_type)
        local count = list:Count()

        if count == 1 then
            return
        end

        for i = 0, count - 1 do
            local pc_info = list:Element(i)
            local handle = pc_info:GetHandle()

            if my_info:GetMapID() == pc_info:GetMapID() and my_info:GetChannel() == pc_info:GetChannel() and my_handle ~=
                handle and handle ~= 0 and not handle_tbl[handle] then
                -- print(handle)
                local actor = world.GetActor(handle)

                if not actor then
                    local icon = GET_CHILD_RECURSIVELY(frame, icon_prefix .. handle)

                    if icon then
                        gbox:RemoveChild(icon_prefix .. handle)
                    end

                else
                    handle_tbl[handle] = true
                    local icon = GET_CHILD_RECURSIVELY(frame, icon_prefix .. handle)
                    if not icon then
                        icon = gbox:CreateOrGetControl("picture", icon_prefix .. handle, 0, 0, 20, 20)
                    end
                    AUTO_CAST(icon)
                    icon:SetEnableStretch(1)

                    local actor_pos = actor:GetPos()
                    local pos = mapprop:WorldPosToMinimapPos(actor_pos, map_pic:GetWidth(), map_pic:GetHeight())
                    local x = (pos.x - icon:GetWidth() / 2)
                    local y = (pos.y - icon:GetHeight() / 2)
                    icon:SetOffset(x, y)
                    local inst_info = pc_info:GetInst()
                    local pcinfo_hp = inst_info.hp
                    if pcinfo_hp > 0 then
                        icon:SetImage(default_icon)
                    else
                        icon:SetImage("die_party")
                    end
                end

            end
        end
    end
    sub_map_display_party_member(PARTY_NORMAL, "pm", "Archer_party")
    sub_map_display_party_member(PARTY_GUILD, "gm", "Wizard_party")
    gbox:Invalidate()

end

function sub_map_update_member_party(frame, msg, arg, type, info)

    if session.world.IsIntegrateServer() == true then
        DESTROY_GUILD_MEMBER_ICON()
        return
    end

    local myInfo = session.party.GetMyPartyObj(PARTY_NORMAL)
    local mapprop = session.GetCurrentMapProp()
    local list = session.party.GetPartyMemberList(PARTY_NORMAL)
    local count = list:Count()

    if count == 1 then
        return
    end

    for i = 0, count - 1 do
        local pcInfo = list:Element(i)

        if myInfo:GetMapID() == pcInfo:GetMapID() and myInfo:GetChannel() == pcInfo:GetChannel() and myInfo:GetName() ~=
            pcInfo:GetName() then

            if pcInfo:GetHandle() ~= 0 then
                local show_flag = true
                if pcInfo:GetHandle() ~= session.GetMyHandle() then

                    if show_flag == true then

                        local gbox = frame:GetChildRecursively("gbox")
                        local map_pic = frame:GetChildRecursively("map_pic")

                        gbox:RemoveChild(pcInfo:GetName())
                        local pm_icon = gbox:CreateOrGetControl("picture", pcInfo:GetName(), 0, 0, 20, 20)
                        AUTO_CAST(pm_icon)
                        pm_icon:SetEnableStretch(1)
                        local instInfo = pcInfo:GetInst()
                        -- print(tostring(pcInfo:GetName()))
                        local worldPos = instInfo:GetPos()
                        local pos = mapprop:WorldPosToMinimapPos(worldPos, map_pic:GetWidth(), map_pic:GetHeight())
                        local x = (pos.x - pm_icon:GetWidth() / 2)
                        local y = (pos.y - pm_icon:GetHeight() / 2)

                        pm_icon:SetOffset(x, y)
                        local pcinfo_hp = instInfo.hp
                        if pcinfo_hp > 0 then
                            pm_icon:SetImage("Archer_party")
                        else
                            pm_icon:SetImage("die_party")
                        end
                    end
                end
            end
        end
    end
end

function sub_map_update_member_guild(frame, msg, arg, type, info)

    if session.world.IsIntegrateServer() == true then
        DESTROY_GUILD_MEMBER_ICON()
        return
    end

    local myInfo = session.party.GetMyPartyObj(PARTY_GUILD)
    local mapprop = session.GetCurrentMapProp()
    local list = session.party.GetPartyMemberList(PARTY_GUILD)
    local count = list:Count()

    if count == 1 then
        return
    end

    for i = 0, count - 1 do
        local pcInfo = list:Element(i)

        if myInfo:GetMapID() == pcInfo:GetMapID() and myInfo:GetChannel() == pcInfo:GetChannel() and myInfo:GetName() ~=
            pcInfo:GetName() then
            if pcInfo:GetHandle() ~= 0 then
                local show_flag = true
                if pcInfo:GetHandle() ~= session.GetMyHandle() then

                    if show_flag == true then
                        local gbox = frame:GetChildRecursively("gbox")
                        local map_pic = frame:GetChildRecursively("map_pic")

                        gbox:RemoveChild(pcInfo:GetName())
                        local gm_icon = gbox:CreateOrGetControl("picture", pcInfo:GetName(), 0, 0, 20, 20)
                        AUTO_CAST(gm_icon)
                        gm_icon:SetEnableStretch(1)
                        local instInfo = pcInfo:GetInst()

                        local worldPos = instInfo:GetPos()
                        local pos = mapprop:WorldPosToMinimapPos(worldPos, map_pic:GetWidth(), map_pic:GetHeight())
                        local x = (pos.x - gm_icon:GetWidth() / 2)
                        local y = (pos.y - gm_icon:GetHeight() / 2)

                        gm_icon:SetOffset(x, y)
                        local pcinfo_hp = instInfo.hp
                        if pcinfo_hp > 0 then
                            local party_list = session.party.GetPartyMemberList(PARTY_NORMAL)
                            local party_count = party_list:Count()
                            local alreadySet = false -- フラグを追加

                            for j = 0, party_count - 1 do
                                local party_pcInfo = party_list:Element(j)

                                if party_pcInfo then
                                    local party_pc_name = party_pcInfo:GetName()
                                    if pcInfo:GetName() == party_pc_name then
                                        gm_icon:SetImage("Archer_party")
                                        alreadySet = true -- 設定されたことを記録
                                    end
                                end
                            end
                            if not alreadySet then
                                gm_icon:SetImage("Wizard_party")
                            end
                        else
                            gm_icon:SetImage("die_party")
                        end
                    end
                end
            end
        end
    end
end

--[[function sub_map_CREATE_PM_PICTURE(frame, pcInfo, type, mapprop)
    local myInfo = session.party.GetMyPartyObj(type)
    if nil == myInfo then
        return
    end

    if myInfo == pcInfo then
        return
    end

    if myInfo:GetMapID() ~= pcInfo:GetMapID() or myInfo:GetChannel() ~= pcInfo:GetChannel() then
        return
    end

    local header = "PM_"
    if type == PARTY_GUILD then
        header = "GM_"
    end

    local name = header .. pcInfo:GetAID()
    if pcInfo:GetMapID() == 0 then
        frame:RemoveChild(name)
        return
    end

    if type == PARTY_GUILD then
        if frame:GetChild("GM_" .. pcInfo:GetAID()) ~= nil then
            return
        end
    else
        if frame:GetChild("PM_" .. pcInfo:GetAID()) ~= nil then
            return
        end
    end

    local instInfo = pcInfo:GetInst()
    local map_partymember_iconset = frame:CreateOrGetControlSet("map_partymember_iconset", name, 30, 30)
    map_partymember_iconset:SetTooltipType("partymap")
    map_partymember_iconset:SetTooltipArg(pcInfo:GetName(), type)

    local pm_name_rtext = GET_CHILD_RECURSIVELY(map_partymember_iconset, "pm_name", "ui::CRichText")
    pm_name_rtext:SetTextByKey("pm_fname", pcInfo:GetName())
    local iconinfo = pcInfo:GetIconInfo()
    sub_map_SET_PM_MINIMAP_ICON(map_partymember_iconset, instInfo.hp, pcInfo:GetAID())
    SET_PM_MAPPOS(frame, map_partymember_iconset, instInfo, mapprop)
end

function sub_map_SET_PM_MINIMAP_ICON(map_partymember_iconset, pcHP, aid)
    local pm_icon = GET_CHILD_RECURSIVELY(map_partymember_iconset, "pm_icon")
    if pcHP > 0 then
        if session.party.GetPartyMemberInfoByAID(PARTY_NORMAL, aid) ~= nil then
            pm_icon:SetImage("Archer_party")
        elseif session.party.GetPartyMemberInfoByAID(PARTY_GUILD, aid) ~= nil then

            pm_icon:SetImage("Wizard_party")
        else
            pm_icon:SetImage("die_party")
        end
    else
        pm_icon:SetImage("die_party")
    end
end]]

