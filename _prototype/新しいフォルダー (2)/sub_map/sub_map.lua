-- v1.0.1 チャレンジのボスの位置の取り方変更。その他色々修正
local addon_name = "SUB_MAP"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]
local json = require("json")

function g.mkdir_new_folder()
    local function create_folder(folder_path, file_path)
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

    local folder = string.format("../addons/%s", addon_name_lower)
    local file_path = string.format("../addons/%s/mkdir.txt", addon_name_lower)
    create_folder(folder, file_path)

    g.active_id = session.loginInfo.GetAID()
    local user_folder = string.format("../addons/%s/%s", addon_name_lower, g.active_id)
    local user_file_path = string.format("../addons/%s/%s/mkdir.txt", addon_name_lower, g.active_id)
    create_folder(user_folder, user_file_path)

    g.settings_path = string.format("../addons/%s/%s/settings.json", addon_name_lower, g.active_id)
end
g.mkdir_new_folder()

function g.get_map_type()
    local map_name = session.GetMapName()
    local map_cls = GetClass("Map", map_name)
    local map_type = map_cls.MapType
    return map_type
end

function g.save_settings()
    function g.save_json(path, tbl)
        local file = io.open(path, "w")
        local str = json.encode(tbl)
        file:write(str)
        file:close()
    end

    g.save_json(g.settings_path, g.settings)
end

function g.load_settings()

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

    local settings = g.load_json(g.settings_path)

    if not settings then
        settings = {
            x = 1200,
            y = 120,
            move = 1,
            hittest = 1,
            visible = 1,
            size = 200,
            mini_map = false
        }
    end

    g.settings = settings

    g.save_settings()
end

function SUB_MAP_ON_INIT(addon, frame)

    local start_time = os.clock() -- ★処理開始前の時刻を記録★
    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()
    g.cid = session.GetMySession():GetCID()
    g.login_name = session.GetMySession():GetPCApc():GetName()

    g.load_settings()
    g.try = 0
    local map_type = g.get_map_type()
    if map_type ~= "Instance" then
        addon:RegisterMsg('GAME_START_3SEC', "sub_map_frame_init")

    end

    local map_name = session.GetMapName()
    local colonyClsList, cnt = GetClassList('guild_colony')
    for i = 0, cnt - 1 do
        local colonyCls = GetClassByIndexFromList(colonyClsList, i)
        local check_word = "GuildColony_"
        if string.find(map_name, check_word) then
            addon:RegisterMsg('GAME_START_3SEC', "sub_map_frame_init")
            return
        end
    end
    local end_time = os.clock() -- ★処理終了後の時刻を記録★
    local elapsed_time = end_time - start_time
    CHAT_SYSTEM(string.format("%s: %.4f seconds", addon_name, elapsed_time))
end

function sub_map_frame_init(frame)

    if g.try == 0 then
        frame:RunUpdateScript("sub_map_frame_init", 2.0)
        g.try = 1
        return
    end

    local minimap = ui.GetFrame("minimap")

    local isAutoChallengeMap = session.IsAutoChallengeMap()
    local isSoloChallengeMap = session.IsSoloChallengeMap()

    if isAutoChallengeMap or isSoloChallengeMap then
        g.challenge = true
    else
        g.challenge = false
    end

    if g.challenge then
        g.size = minimap:GetWidth()
    elseif g.settings.mini_map then
        g.size = minimap:GetWidth()
    elseif not g.settings.mini_map then
        g.size = g.settings.size
    end

    g.icon_size = g.size * 0.08

    local frame = ui.GetFrame("sub_map")
    frame:RemoveAllChild()

    frame:EnableMove(g.settings.move)
    frame:EnableHitTest(g.settings.hittest)

    frame:SetEventScript(ui.LBUTTONUP, "sub_map_frame_end_drag")
    frame:SetEventScript(ui.RBUTTONUP, "sub_map_config")

    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")

    local map_frame = ui.GetFrame("map")
    local width = map_frame:GetWidth()

    local x = g.settings.x
    if width <= 1920 and x > 1920 then
        x = g.settings.x / 21 * 16
    end

    frame:SetPos(x, g.settings.y)
    frame:SetLayerLevel(12)
    frame:ShowWindow(0)

    local title = frame:CreateOrGetControl("richtext", "title", 25, 2)
    AUTO_CAST(title)
    local map_id = session.GetMapID()
    local map_name = GetClassByType("Map", map_id).Name
    title:SetText("{ol}{S12}" .. map_name)
    title:SetEventScript(ui.RBUTTONUP, "sub_map_config")

    local display = frame:CreateOrGetControl("picture", "display", 5, 3, 15, 15)
    AUTO_CAST(display)
    display:SetEnableStretch(1)
    display:EnableHitTest(1)
    display:SetEventScript(ui.LBUTTONUP, "sub_map_frame_toggle")
    display:SetTextTooltip("{ol}Display / hide")
    display:ShowWindow(1)

    if g.settings.visible == 1 then
        display:SetImage("btn_minus")
        frame:Resize(g.size + 10, g.size + 40)
    else
        display:SetImage("btn_plus")
        frame:Resize(g.size + 10, 40)
        frame:ShowWindow(1)
        return
    end

    function sub_map_frame_layer_change(frame, ctrl, str, num)
        if str == "ON" then
            frame:SetLayerLevel(32)
        end
    end

    local gbox = frame:CreateOrGetControl("groupbox", "gbox", g.size + 10, g.size + 10, ui.LEFT, ui.BOTTOM, 0, 30, 0, 0)
    AUTO_CAST(gbox)
    gbox:SetEventScript(ui.MOUSEON, "sub_map_frame_layer_change")
    gbox:SetEventScriptArgString(ui.MOUSEON, "ON")

    gbox:SetEventScript(ui.LBUTTONDOWN, "sub_map_frame_map_link")
    gbox:SetTextTooltip(g.lang == "Japanese" and
                            "{ol}右クリック:設定{nl}LCTRL+右クリック:ミニマップモード{nl}LCTRL+左クリック:マップリンク" or
                            "{ol}{ol}Right click:Settings{nl}LCTRL+Right click:Minimap mode{nl}LCTRL+Left click:Map Link")

    local map_pic = gbox:CreateOrGetControl("picture", "map_pic", g.size, g.size, ui.LEFT, ui.TOP, 0, 0, 0, 0)
    AUTO_CAST(map_pic)
    map_pic:SetEnableStretch(1)
    map_pic:EnableHitTest(0)

    local my = gbox:CreateOrGetControl("picture", "my", g.icon_size * 2, g.icon_size * 2, ui.LEFT, ui.TOP, 0, 0, 0, 0)
    AUTO_CAST(my)
    my:SetImage("minimap_leader")
    my:SetEnableStretch(1)

    local cur_map_id = session.GetMapID()
    local map_cls = GetClassByType("Map", cur_map_id)
    local map_name = map_cls.ClassName
    map_pic:SetImage(map_name)

    sub_map_MAP_CHARACTER_UPDATE(frame)
    if not g.challenge then
        sub_map_set_warp_point(frame, map_name)
        g.addon:RegisterMsg("FPS_UPDATE", "sub_map_mapicon_update")
    end

    g.addon:RegisterMsg("MAP_CHARACTER_UPDATE", "sub_map_MAP_CHARACTER_UPDATE")
    g.addon:RegisterMsg("MON_MINIMAP", "sub_map_MAP_MON_MINIMAP")
    g.addon:RegisterMsg('MON_MINIMAP_END', 'sub_map_ON_MON_MINIMAP_END');

    g.addon:RegisterMsg("PARTY_INST_UPDATE", "sub_map_MAP_UPDATE_PARTY_INST")
    g.addon:RegisterMsg("PARTY_UPDATE", "sub_map_ipdate_party_or_guild")
    g.addon:RegisterMsg("GUILD_INFO_UPDATE", "sub_map_ipdate_party_or_guild")

    g.handles = {}

    if MAP_USE_FOG(map_name) ~= 0 then
        -- g.fogs = {}
        -- g.fog_get = false
        g.addon:RegisterMsg("FPS_UPDATE", "sub_map_draw_fog")
    end

    if g.challenge then
        display:ShowWindow(0)
        sub_map_change_minimap_mode(frame, "challenge")
        g.challenge_count = 0
        g.addon:RegisterMsg("FPS_UPDATE", "sub_map_callenge_pcicon_update")
        return
    elseif g.settings.mini_map then
        display:ShowWindow(0)
        local minimap = ui.GetFrame("minimap")
        minimap:ShowWindow(0)
        sub_map_change_minimap_mode(frame)
    else
        frame:ShowWindow(1)
    end

    g.icons = {}
    g.addon:RegisterMsg("FPS_UPDATE", "sub_map_update_remove_member")
end

function sub_map_callenge_pcicon_update(frame, msg, str, num)

    local frame = ui.GetFrame("sub_map")
    local gbox = GET_CHILD(frame, "gbox")

    local aids = {}

    for i = 0, gbox:GetChildCount() - 1 do
        local child = gbox:GetChildByIndex(i)
        if child then
            local aid = tonumber(child:GetName())
            if aid then
                aids[tostring(aid)] = true
            end
        end
    end

    gbox:SetEventScript(ui.MOUSEON, "None")
<<<<<<< HEAD

    local start_frame = ui.GetFrame("skill_notice_freestart_frame")
    if start_frame then
        AUTO_CAST(start_frame)
        start_frame:SetLayerLevel(78)
    end

    function sub_map_time_update(frame)
        local server_time = geTime.GetServerSystemTime()
        local hour = server_time.wHour
        local min = server_time.wMinute

        local ampm = "AM"
        local display_hour = hour

        if hour == 0 then -- 0時を12時AMにする
            display_hour = 12
            ampm = "AM"
        elseif hour == 12 then -- 12時を12時PMにする
            display_hour = 12
            ampm = "PM"
        elseif hour > 12 then -- 午後
            display_hour = hour - 12
            ampm = "PM"
        end

        local display_min = string.format("%02d", min) -- 分を2桁表示にする

        local clock_text = string.format("{ol}{s18}%s %d:%s", ampm, display_hour, display_min)

        local clock = frame:CreateOrGetControl("richtext", "clock", 0, 0)
        AUTO_CAST(clock)
        clock:SetGravity(ui.RIGHT, ui.BOTTOM)
        clock:SetMargin(0, 0, 10, 5)
        clock:SetText(clock_text)
    end

    local timer = frame:CreateOrGetControl("timer", "addontimer", 0, 0)
    AUTO_CAST(timer)
    timer:Stop()
    timer:SetUpdateScript("sub_map_time_update")
    timer:Start(1.0)
end
--- 

function sub_map_set_pcicon_update(frame, msg, str, num, info)

    local frame = ui.GetFrame("sub_map")

    sub_map_change_minimap_mode(frame, msg)

    local gbox = GET_CHILD(frame, "gbox")
    gbox:SetEventScript(ui.MOUSEON, "None")
    local map_pic = frame:GetChildRecursively("map_pic")
=======
    local map_pic = GET_CHILD(gbox, "map_pic")
>>>>>>> 7e9382280df7e8e4efbac0673855255b562fe1f5
    local mapprop = session.GetCurrentMapProp()
    local party_list = session.party.GetPartyMemberList(PARTY_NORMAL)
    local party_count = party_list:Count()
    local my_info = session.party.GetMyPartyObj(PARTY_NORMAL)

    for i = 0, party_count - 1 do
        local pc_info = party_list:Element(i)
        local aid = pc_info:GetAID()
        if my_info ~= pc_info then

            aids[aid] = false
            local inst_info = pc_info:GetInst()
            local worldPos = inst_info:GetPos()
            local hp = inst_info.hp

            local pc_icon = GET_CHILD(gbox, aid)
            if not pc_icon then
                pc_icon = gbox:CreateOrGetControl("picture", aid, 0, 0, g.icon_size, g.icon_size)
            end
            AUTO_CAST(pc_icon)
            pc_icon:SetTextTooltip("{ol}{s10}" .. pc_info:GetName())
            pc_icon:SetEnableStretch(1)

            local pos = mapprop:WorldPosToMinimapPos(worldPos, map_pic:GetWidth(), map_pic:GetHeight())

            local x = (pos.x - g.icon_size / 2)
            local y = (pos.y - g.icon_size / 2)

            pc_icon:SetPos(x, y)
            pc_icon:ShowWindow(1)

            local image_name = 'Archer_party'
            if hp <= 0 then
                image_name = 'die_party'
            end
            pc_icon:SetImage(image_name)
        end
    end

    for aid, remove in pairs(aids) do
        if remove == true then
            gbox:RemoveChild(aid)
        end
    end

    -- sub_map_MAP_UPDATE_PARTY_INST(frame, msg, str, PARTY_NORMAL)
end

function sub_map_ipdate_party_or_guild(frame, msg, arg, num, info)

    local party_type = 0
    if msg == "GUILD_INFO_UPDATE" then
        party_type = 1
    end
    local list = session.party.GetPartyMemberList(party_type)
    local count = list:Count()
    if count == 1 then
        return
    end

<<<<<<< HEAD
    local my_handle = session.GetMyHandle()
    local selected_objects, selected_objects_count = SelectObject(GetMyPCObject(), 1000, "ALL")

    for i = 1, selected_objects_count do

        local handle = GetHandle(selected_objects[i])
        if handle and info.IsPC(handle) == 1 then
            local actor = world.GetActor(handle)

            for j = 0, count - 1 do
                local pc_info = list:Element(j)
                if my_handle ~= handle and handle ~= 0 then
                    local instInfo = pc_info:GetInst()
                    local worldPos = actor:GetPos()
                    local pos = mapprop:WorldPosToMinimapPos(worldPos, map_pic:GetWidth(), map_pic:GetHeight())
                    local x = (pos.x - g.icon_size / 2)
                    local y = (pos.y - g.icon_size / 2)
                    local icon = GET_CHILD_RECURSIVELY(gbox, "pm_" .. handle)

                    if icon then
                        AUTO_CAST(icon)
                        icon:SetTextTooltip("{ol}{s10}" .. pc_info:GetName())
                        icon:SetEnableStretch(1)
                    else
                        icon = gbox:CreateOrGetControl("picture", "pm_" .. handle, x, y, g.icon_size, g.icon_size)
                        AUTO_CAST(icon)
                        icon:SetTextTooltip("{ol}{s10}" .. pc_info:GetName())
                        icon:SetEnableStretch(1)
                    end
                    icon:SetPos(x, y)
                    local pcinfo_hp = instInfo.hp
                    if pcinfo_hp > 0 then
                        icon:SetImage("Archer_party")
                    else
                        icon:SetImage("die_party")
                    end
                end
            end
        end
    end
    gbox:Invalidate()
end

--[[function sub_map_set_pcicon_update(frame, msg, str, num, info)

    local frame = ui.GetFrame("sub_map")

    sub_map_change_minimap_mode(frame, msg)

    local gbox = GET_CHILD(frame, "gbox")
    gbox:SetEventScript(ui.MOUSEON, "None")
    local map_pic = frame:GetChildRecursively("map_pic")
    local mapprop = session.GetCurrentMapProp()

    local list = session.party.GetPartyMemberList(PARTY_NORMAL)
    local count = list:Count()

    if count == 1 then
        sub_map_DESTROY_CHILD_BYNAME(gbox, "pm_")
        return
    end

    local my_handle = session.GetMyHandle()
=======
    local my_info = session.party.GetMyPartyObj(party_type)
    if not my_info then
        return
    end

    local frame = ui.GetFrame('sub_map')
    local mapprop = session.GetCurrentMapProp()
>>>>>>> 7e9382280df7e8e4efbac0673855255b562fe1f5

    for i = 0, count - 1 do
        local pc_info = list:Element(i)

        if my_info ~= pc_info and my_info:GetMapID() == pc_info:GetMapID() and my_info:GetChannel() ==
            pc_info:GetChannel() then
            sub_map_CREATE_PICTURE(frame, pc_info, party_type, mapprop, info)
        end
    end
end

function sub_map_CREATE_PICTURE(frame, pc_info, party_type, mapprop, info)

    local aid = pc_info:GetAID()
    local gbox = GET_CHILD(frame, "gbox")

    local pc_icon = GET_CHILD(gbox, aid)
    if not pc_icon then
        pc_icon = gbox:CreateOrGetControl("picture", aid, 0, 0, g.icon_size, g.icon_size)
        AUTO_CAST(pc_icon)
    end

    pc_icon:SetEnableStretch(1)
    pc_icon:SetTooltipType("partymap")
    pc_icon:SetTooltipArg(pc_info:GetName(), party_type)
    pc_icon:ShowWindow(1)

    local inst_info = pc_info:GetInst()

    sub_map_SET_MINIMAP_ICON(pc_icon, inst_info.hp, aid)
    sub_map_SET_MAPPOS(frame, pc_icon, inst_info, mapprop, info)
end

function sub_map_SET_MAPPOS(frame, pc_icon, inst_info, mapprop, info)

    local worldPos = inst_info:GetPos()

    local map_pic = GET_CHILD_RECURSIVELY(frame, 'map_pic')
    local pos
    if info then
        pos = mapprop:WorldPosToMinimapPos(info.x, info.z, map_pic:GetWidth(), map_pic:GetHeight())
    else
        pos = mapprop:WorldPosToMinimapPos(worldPos, map_pic:GetWidth(), map_pic:GetHeight())
    end
    local x = (pos.x - g.icon_size / 2)
    local y = (pos.y - g.icon_size / 2)

    pc_icon:SetPos(x, y)
end

function sub_map_SET_MINIMAP_ICON(pc_icon, hp, aid)

    local image_name = 'die_party'
    if hp > 0 then
        if session.party.GetPartyMemberInfoByAID(PARTY_NORMAL, aid) ~= nil then
            image_name = 'Archer_party'
        elseif session.party.GetPartyMemberInfoByAID(PARTY_GUILD, aid) ~= nil then
            image_name = 'Wizard_party'
        end
    end
    pc_icon:SetImage(image_name)

end

function sub_map_update_remove_member(frame, msg, str, num)

    local frame = ui.GetFrame('sub_map')
    local gbox = GET_CHILD(frame, "gbox")

    for i = 0, gbox:GetChildCount() - 1 do
        local child = gbox:GetChildByIndex(i)
        if child then
            local aid = tonumber(child:GetName())
            if aid then
                g.icons[aid] = true
            end
        end
    end

    local function process_member_list(party_type)
        local list = session.party.GetPartyMemberList(party_type)
        local my_handle = session.GetMyHandle()
        local my_info = session.party.GetMyPartyObj(party_type)

        if my_info then
            for i = 0, list:Count() - 1 do
                local pc_info = list:Element(i)
                local aid = tonumber(pc_info:GetAID())

                local handle = pc_info:GetHandle()
                if handle ~= my_handle and pc_info:GetMapID() == my_info:GetMapID() and pc_info:GetChannel() ==
                    my_info:GetChannel() then
                    g.icons[aid] = false
                end
            end
        end
    end

    process_member_list(PARTY_NORMAL)
    process_member_list(PARTY_GUILD)

    for aid, remove in pairs(g.icons) do
        if remove == true then
            gbox:RemoveChild(tostring(aid))
        end
    end
end

-- PARTY_GUILD=1:number
-- PARTY_NORMAL=0:number

function sub_map_MAP_UPDATE_PARTY_INST(frame, msg, str, party_type)

    local frame = ui.GetFrame('sub_map')
    local gbox = GET_CHILD(frame, "gbox")
    local mapprop = session.GetCurrentMapProp()
    local my_info = session.party.GetMyPartyObj(party_type)

    local list = session.party.GetPartyMemberList(party_type)
    local count = list:Count()

    for i = 0, count - 1 do
        local pc_info = list:Element(i)
        if my_info ~= pc_info then
            local aid = pc_info:GetAID()
            local pc_icon = GET_CHILD(gbox, aid)
            if pc_icon then
                local inst_info = pc_info:GetInst()
                sub_map_SET_MINIMAP_ICON(pc_icon, inst_info.hp, aid)
                sub_map_SET_MAPPOS(frame, pc_icon, inst_info, mapprop)
            end
        end
    end
<<<<<<< HEAD
    gbox:Invalidate()
end]]
=======
end
>>>>>>> 7e9382280df7e8e4efbac0673855255b562fe1f5

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

function sub_map_frame_map_link(frame, ctrl)

    if keyboard.IsKeyPressed("LCTRL") ~= 1 then
        return
    end

    local x, y = GET_LOCAL_MOUSE_POS(ctrl)

    local cur_map_id = session.GetMapID()
    local map_cls = GetClassByType("Map", cur_map_id)
    local map_name = map_cls.ClassName

    local mapprop = geMapTable.GetMapProp(map_name)
    local worldPos = mapprop:MinimapPosToWorldPos(x, y, ctrl:GetWidth(), ctrl:GetHeight())
    LINK_MAP_POS(map_name, worldPos.x, worldPos.y)
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

    if keyboard.IsKeyPressed("LCTRL") == 1 then
        if not g.settings.mini_map then
            -- sub_map_change_minimap_mode(frame)
            g.settings.mini_map = true
            sub_map_frame_init()
        else
            local minimap = ui.GetFrame("minimap")
            minimap:ShowWindow(1)
            g.settings.mini_map = false
            sub_map_frame_init()
        end
        g.save_settings()
        return
    end

    local x = frame:GetWidth() - 85
    local size_edit = frame:CreateOrGetControl('edit', 'size_edit', x, 0, 50, 25)
    AUTO_CAST(size_edit)
    size_edit:SetFontName('white_14_ol')
    size_edit:SetSkinName('test_weight_skin')
    size_edit:SetTextAlign('center', 'center')
    size_edit:SetEventScript(ui.ENTERKEY, "sub_map_config_save")
    size_edit:SetText(g.settings.size or tonumber(200))
    size_edit:SetTextTooltip(g.lang == "Japanese" and "{ol}150～350" or "{ol}150～350")

    local move = frame:CreateOrGetControl('checkbox', 'move', 0, 0, 25, 25)
    AUTO_CAST(move)

    move:SetCheck(g.settings.move)
    move:SetGravity(ui.RIGHT, ui.TOP)
    move:SetEventScript(ui.LBUTTONUP, "sub_map_config_save")
    move:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックを外すとフレーム固定" or
                            "{ol}Frame fixed when unchecked")

    if size_edit:IsVisible() == 1 then
        size_edit:ShowWindow(0)
        move:ShowWindow(0)
    else
        size_edit:ShowWindow(1)
        move:ShowWindow(1)
    end

end

function sub_map_frame_end_drag(frame, ctrl)
    g.settings.x = frame:GetX()
    g.settings.y = frame:GetY()
    g.save_settings()
end

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
        local return_data = {}
        for match in string.gmatch(str, "[^" .. delim .. "]+") do
            table.insert(return_data, match)
        end
        return return_data
    end

    for i, data in ipairs(info_table) do

        if string.find(data.class_type, "treasure_box") then

            local item_split = split(data.argstr2, ":")

            local item_name = GetClass("Item", item_split[2]).Name

            local icon = gbox:CreateOrGetControl("picture", "icon_" .. i, g.icon_size, g.icon_size, ui.LEFT, ui.TOP, 0,
                                                 0, 0, 0)
            AUTO_CAST(icon)

            icon:SetTextTooltip("{ol}{s10}" .. data.argstr1 .. "{nl}" .. item_name)
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
            icon:SetTextTooltip("{ol}{s10}" .. data.name)
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
                    local map_cls = GetClass("Map", cls_name)
                    icon:SetTextTooltip("{ol}{s10}" .. map_cls.Name)
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

    if not g.challenge then
        sub_map_mapicon_update(frame, msg, str, num)
    end
end

function sub_map_draw_fog()

    local map_id = session.GetMapID()
    local map_name = GetClassByType("Map", map_id).ClassName

    if MAP_USE_FOG(map_name) == 0 then
        return
    end

    local frame = ui.GetFrame("sub_map")
    local gbox = GET_CHILD(frame, "gbox")
    local map_pic = frame:GetChildRecursively("map_pic")
    AUTO_CAST(map_pic)
    HIDE_CHILD_BYNAME(map_pic, "sub_map_fog_")

    local map_frame = ui.GetFrame('map')
    local map = GET_CHILD(map_frame, "map", 'ui::CPicture')

    local map_zoom = math.abs(tonumber(map_pic:GetWidth()) / tonumber(map:GetWidth()))

    local list = session.GetMapFogList(session.GetMapName())
    local cnt = list:Count()
    for i = 0, cnt - 1 do
        local tile = list:PtrAt(i)

        if tile.revealed == 0 then

            local name = string.format("sub_map_fog_%d", i)
            local tilePosX = (tile.x * map_zoom)
            local tilePosY = (tile.y * map_zoom)
            local tileWidth = math.ceil(tile.w * map_zoom)

            local tileHeight = math.ceil(tile.h * map_zoom)

            local pic = map_pic:CreateOrGetControl("picture", name, tilePosX, tilePosY, tileWidth, tileHeight)
            AUTO_CAST(pic)

            pic:ShowWindow(1)
            pic:SetImage("fullred")
            pic:SetEnableStretch(1)
            pic:SetAlpha(40)
            pic:EnableHitTest(0)

        end
    end

    frame:Invalidate()
end

function sub_map_ON_MON_MINIMAP_END(frame, msg, argStr, handle)

    local frame = ui.GetFrame("sub_map")
    local gbox = GET_CHILD(frame, "gbox")

    local ctrl_name = "_MONPOS_" .. handle
    local mon_pic = GET_CHILD(gbox, ctrl_name)
    if mon_pic then
        g.handles[tostring(handle)] = 2
        gbox:RemoveChild(ctrl_name)
        gbox:Invalidate()
    end
end

function sub_map_MAP_MON_MINIMAP(frame, msg, argStr, argNum, info)

    local frame = ui.GetFrame("sub_map")
    local gbox = GET_CHILD(frame, "gbox")

    local handle = info.handle
    local mon_cls = GetClassByType("Monster", info.type)

    if mon_cls and TryGetProp(mon_cls, "MonRank", "None") == "Boss" and not g.handles[tostring(handle)] then
        g.handles[tostring(handle)] = 1
        local ctrl_name = "_MONPOS_" .. handle
        local mon_pic = GET_CHILD_RECURSIVELY(gbox, ctrl_name)

        if not mon_pic then

            mon_pic = gbox:CreateOrGetControl("picture", ctrl_name, 0, 0, g.icon_size, g.icon_size)
            AUTO_CAST(mon_pic)

            mon_pic:SetUserValue("HANDLE", handle)

            local img_name = mon_cls.MinimapIcon
            mon_pic:SetImage(img_name)
            mon_pic:SetEnableStretch(1)

            local mapprop = session.GetCurrentMapProp()
            local map_pic = GET_CHILD_RECURSIVELY(frame, "map_pic", "ui::CPicture")
            if map_pic then
                local pos = mapprop:WorldPosToMinimapPos(info.x, info.z, map_pic:GetWidth(), map_pic:GetHeight())
                local initial_x = pos.x - mon_pic:GetWidth() / 2
                local initial_y = pos.y - mon_pic:GetHeight() / 2
                mon_pic:SetOffset(initial_x, initial_y)
            end
            mon_pic:ShowWindow(1)
            if not mon_pic:HaveUpdateScript("sub_map_monpic_auto_update") then
                mon_pic:RunUpdateScript("sub_map_monpic_auto_update", 0.5)
            end
        end
    end
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

        if mon_cls and TryGetProp(mon_cls, "MonRank", "None") == "Boss" then
            local pos = mapprop:WorldPosToMinimapPos(actor_pos, map_pic:GetWidth(), map_pic:GetHeight())
            local x = pos.x - mon_pic:GetWidth() / 2
            local y = pos.y - mon_pic:GetHeight() / 2
            mon_pic:SetOffset(x, y)
        end
    end
    return 1
end

function sub_map_change_minimap_mode(frame, msg)

    if g.settings.visible ~= 1 then
        return
    end

    local minimap = ui.GetFrame("minimap")
    local minimap_x = minimap:GetX()
    local minimap_y = minimap:GetY()
    minimap:ShowWindow(0)
    frame:ShowWindow(1)

    -- frame:SetSkinName("textbutton")
    frame:SetSkinName("chat_window")
    frame:EnableMove(0)
    frame:SetAlpha(100)
    frame:SetLayerLevel(79)
    frame:SetEventScript(ui.LBUTTONUP, "None")

    if msg then
        frame:SetLayerLevel(94)
    end

    frame:Resize(minimap:GetWidth(), minimap:GetWidth() + 30)

    local rect = minimap:GetMargin()

    frame:SetGravity(ui.RIGHT, ui.TOP)
    frame:SetMargin(rect.left, rect.top, rect.right, rect.bottom)
    local gbox = GET_CHILD(frame, "gbox")
    gbox:SetEventScript(ui.MOUSEON, "None")

    local start_frame = ui.GetFrame("skill_notice_freestart_frame")
    if start_frame then
        AUTO_CAST(start_frame)
        start_frame:SetLayerLevel(78)
    end

    function sub_map_time_update(frame)
        local server_time = geTime.GetServerSystemTime()
        local hour = server_time.wHour
        local min = server_time.wMinute

        local ampm = "AM"
        local display_hour = hour

        if hour == 0 then -- 0時を12時AMにする
            display_hour = 12
            ampm = "AM"
        elseif hour == 12 then -- 12時を12時PMにする
            display_hour = 12
            ampm = "PM"
        elseif hour > 12 then -- 午後
            display_hour = hour - 12
            ampm = "PM"
        end

        local display_min = string.format("%02d", min) -- 分を2桁表示にする

        local clock_text = string.format("{ol}{s18}%s %d:%s", ampm, display_hour, display_min)

        local clock = frame:CreateOrGetControl("richtext", "clock", 0, 0)
        AUTO_CAST(clock)
        clock:SetGravity(ui.RIGHT, ui.BOTTOM)
        clock:SetMargin(0, 0, 10, 5)
        clock:SetText(clock_text)
    end

    local timer = frame:CreateOrGetControl("timer", "addontimer", 0, 0)
    AUTO_CAST(timer)
    timer:Stop()
    timer:SetUpdateScript("sub_map_time_update")
    timer:Start(1.0)
end

--[[function sub_map_draw_fog()
    local frame = ui.GetFrame("sub_map")
    local gbox = GET_CHILD(frame, "gbox")
    local map_pic = GET_CHILD(gbox, "map_pic")
    AUTO_CAST(map_pic)
    HIDE_CHILD_BYNAME(map_pic, "sub_map_fog_");
    local map_id = session.GetMapID()
    local map_name = GetClassByType("Map", map_id).ClassName
    -- local map_name = session.GetMapName()
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
end]]

--[[function sub_map_draw_fog(frame)

    local map_name = session.GetMapName()

    local frame = ui.GetFrame("sub_map")
    local gbox = GET_CHILD(frame, "gbox")
    local map_pic = frame:GetChildRecursively("map_pic")
    AUTO_CAST(map_pic)

    local map_frame = ui.GetFrame('map')
    local map = GET_CHILD(map_frame, "map", 'ui::CPicture')
    local map_zoom = math.abs(tonumber(map_pic:GetWidth()) / tonumber(map:GetWidth()))

    local list = session.GetMapFogList(map_name)
    if g.fog_get and #g.fogs > 0 then
        local temp = {}
        for key, index in ipairs(g.fogs) do
            local info = list:PtrAt(index)
            if info.revealed == 1 then
                local name = string.format("sub_map_fog_%d", index)
                local pic = GET_CHILD(map_pic, name)
                AUTO_CAST(pic)
                pic:ShowWindow(0)
                table.insert(temp, key)
            end
        end
        if #temp > 0 then
            table.sort(temp, function(a, b)
                return a > b
            end)
            for _, index_to_remove in ipairs(temp) do
                table.remove(g.fogs, index_to_remove)
            end
            frame:Invalidate()
        end
    else
        local cnt = list:Count()
        for i = 0, cnt - 1 do
            local info = list:PtrAt(i);
            if info.revealed == 0 then
                local name = string.format("sub_map_fog_%d", i)
                local x = info.x * map_zoom
                local y = info.y * map_zoom
                local w = math.ceil(info.w * map_zoom)
                local h = math.ceil(info.h * map_zoom)

                local tileHeight = math.ceil(tile.h * map_zoom)
                local pic = map_pic:CreateOrGetControl("picture", name, x, y, w, h);
                AUTO_CAST(pic)
                pic:ShowWindow(1)
                pic:SetImage("fullred")
                pic:SetEnableStretch(1)
                pic:SetAlpha(40)
                pic:EnableHitTest(0)
                pic:ShowWindow(1);
                table.insert(g.fogs, i)
            end
        end
        g.fog_get = true
        frame:Invalidate()
    end

end]]

--[[

function sub_map_MAP_UPDATE_PARTY_INST(frame, msg, str, partyType)
    local gbox = GET_CHILD(frame, "gbox") -- gbox を取得
    local mapprop = session.GetCurrentMapProp()
    local myInfo = session.party.GetMyPartyObj(partyType)

    local list = session.party.GetPartyMemberList(partyType)
    local count = list:Count()

    local header = "PM_"
    if partyType == PARTY_GUILD then
        header = "GM_"
    end
    for i = 0, count - 1 do
        local skip = false
        local pcInfo = list:Element(i)
        if myInfo ~= pcInfo then
            -- DESTROY_GUILD_MEMBER_ICON の挙動が不明だけど、とりあえずそのまま
            if is_my_guild_member(pcInfo:GetAID()) then
                DESTROY_GUILD_MEMBER_ICON(frame, msg, pcInfo:GetAID())
            end

            local instInfo = pcInfo:GetInst()
            local name = header .. pcInfo:GetAID()
            -- local pic = GET_CHILD_RECURSIVELY(frame, name) -- frame じゃなく gbox から探す
            local pic = gbox:GetChild(name) -- 直接 gbox から名前で取得
            AUTO_CAST(pic)
            if pic ~= nil then
                local iconinfo = pcInfo:GetIconInfo() -- これは使ってない？
                sub_map_SET_PM_MINIMAP_ICON(pic, instInfo.hp, pcInfo:GetAID()) -- aid を渡す
                -- tolua.cast(pic, "ui::CControlSet") -- ControlSetじゃなくPictureで作ってるからこれは不要か？
                sub_map_SET_PM_MAPPOS(frame, pic, instInfo, mapprop)
            else
                -- アイコンが見つからない場合、全体更新をかけるのはアリ
                -- ただし、これが頻繁に呼ばれると重くなるかも
                local mapFrame = ui.GetFrame('sub_map')
                -- PARTY_UPDATE なのか GUILD_UPDATE なのか partyType で判断した方がいいかも？
                if partyType == PARTY_GUILD then
                    sub_map_MAP_UPDATE_GUILD(mapFrame, "GUILD_UPDATE", nil, 0) -- GUILD更新を呼ぶ
                else
                    sub_map_MAP_UPDATE_PARTY(mapFrame, "PARTY_UPDATE", nil, 0) -- PARTY更新を呼ぶ
                end
                -- return しちゃうと以降のメンバーが見られなくなるので注意。場合によっては return しない方がいいかも？
                -- return
            end
        end
    end
end

function sub_map_DESTROY_CHILD_BYNAME(parent_control, searchname) -- frame じゃなく親コントロールを渡す
    local children_to_remove = {}
    -- まず削除対象のリストを作る（ループ中に削除するとインデックスずれる問題対策）
    for i = 0, parent_control:GetChildCount() - 1 do
        local childObj = parent_control:GetChildByIndex(i)
        if childObj ~= nil then -- 念のため nil チェック
            local name = childObj:GetName()
            if string.find(name, searchname) ~= nil then
                table.insert(children_to_remove, name) -- 名前で覚えておく
            end
        end
    end

    -- リストアップしたコントロールを名前で削除
    for _, child_name in ipairs(children_to_remove) do
        parent_control:RemoveChild(child_name)
    end
end

function sub_map_MAP_UPDATE_GUILD(frame, msg, arg, type, info)

    local gbox = GET_CHILD(frame, "gbox")
    sub_map_DESTROY_CHILD_BYNAME(gbox, 'GM_')
    -- print(tostring(session.world.IsIntegrateServer()))
    if session.world.IsIntegrateServer() == true then
        DESTROY_GUILD_MEMBER_ICON()
        return
    end

    local mapprop = session.GetCurrentMapProp()
    local list = session.party.GetPartyMemberList(PARTY_GUILD)
    local count = list:Count()
    if count == 1 then
        return
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

function sub_map_SET_PM_MINIMAP_ICON(map_partymember_iconset, pcHP, aid)

    -- local pm_icon = GET_CHILD_RECURSIVELY(map_partymember_iconset, "pm_icon")
    if pcHP > 0 then
        if session.party.GetPartyMemberInfoByAID(PARTY_NORMAL, aid) ~= nil then
            map_partymember_iconset:SetImage('Archer_party')
        elseif session.party.GetPartyMemberInfoByAID(PARTY_GUILD, aid) ~= nil then
            map_partymember_iconset:SetImage('Wizard_party')
        else
            map_partymember_iconset:SetImage('die_party')
        end
    else
        map_partymember_iconset:SetImage('die_party')
    end
end]]

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
    local gbox = GET_CHILD(frame, "gbox")

    -- local map_partymember_iconset = gbox:CreateOrGetControlSet('map_partymember_iconset', name, 0, 0)
    local map_partymember_iconset = gbox:CreateOrGetControl("picture", name, 0, 0, g.icon_size, g.icon_size)
    AUTO_CAST(map_partymember_iconset)
    map_partymember_iconset:SetEnableStretch(1)
    -- print(tostring(g.icon_size))
    map_partymember_iconset:SetTooltipType("partymap")
    map_partymember_iconset:SetTooltipArg(pcInfo:GetName(), type)

   
    sub_map_SET_PM_MINIMAP_ICON(map_partymember_iconset, instInfo.hp, pcInfo:GetAID())
    sub_map_SET_PM_MAPPOS(frame, map_partymember_iconset, instInfo, mapprop)
end]]

--[[function sub_map_DESTROY_CHILD_BYNAME(frame, searchname)
    local index = 0
    while 1 do
        if index >= frame:GetChildCount() then
            break
        end

        local childObj = frame:GetChildByIndex(index)
        local name = childObj:GetName()

        if string.find(name, searchname) ~= nil then
            frame:RemoveChildByIndex(index)
        else
            index = index + 1
        end
    end
end]]
--[[function sub_map_MAP_UPDATE_PARTY_INST(frame, msg, str, partyType)
    local mapprop = session.GetCurrentMapProp()
    local myInfo = session.party.GetMyPartyObj(partyType)

    local list = session.party.GetPartyMemberList(partyType)
    local count = list:Count()

    local header = "PM_"
    if partyType == PARTY_GUILD then
        header = "GM_"
    end
    for i = 0, count - 1 do
        local skip = false
        local pcInfo = list:Element(i)
        if myInfo ~= pcInfo then
            if is_my_guild_member(pcInfo:GetAID()) then
                DESTROY_GUILD_MEMBER_ICON(frame, msg, pcInfo:GetAID())
            end

            local instInfo = pcInfo:GetInst()
            local name = header .. pcInfo:GetAID()
            local pic = GET_CHILD_RECURSIVELY(frame, name)
            AUTO_CAST(pic)
            if pic ~= nil then
                local iconinfo = pcInfo:GetIconInfo()
                sub_map_SET_PM_MINIMAP_ICON(pic, instInfo.hp, pcInfo:GetAID())
                -- tolua.cast(pic, "ui::CControlSet")
                sub_map_SET_PM_MAPPOS(frame, pic, instInfo, mapprop)
            else
                -- local mapFrame = ui.GetFrame('map')
                local mapFrame = ui.GetFrame('sub_map')
                sub_map_MAP_UPDATE_PARTY(mapFrame, "PARTY_UPDATE", nil, 0)
                return
            end
        end
    end

end]]
