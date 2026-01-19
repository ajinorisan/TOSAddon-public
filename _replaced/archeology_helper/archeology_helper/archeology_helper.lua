-- v0.0.8 オートスタミナ剤設定追加
local addon_name = "ARCHEOLOGY_HELPER"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "0.0.8"
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]
local json = require("json")
local function ts(...)
    local num_args = select('#', ...)
    if num_args == 0 then
        return
    end
    local string_parts = {}
    for i = 1, num_args do
        local arg = select(i, ...)
        local arg_type = type(arg)
        local is_success, value_str = pcall(tostring, arg)
        if not is_success then
            value_str = "error"
        end
        table.insert(string_parts, string.format("(%s) %s", arg_type, value_str))
    end
    print(table.concat(string_parts, " | "))
end

function g.mkdir_new_folder()
    g.active_id = session.loginInfo.GetAID()
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
    local user_folder = string.format("../addons/%s/%s", addon_name_lower, g.active_id)
    local user_file_path = string.format("../addons/%s/%s/mkdir.txt", addon_name_lower, g.active_id)
    create_folder(user_folder, user_file_path)
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

function g.setup_hook(my_func, origin_func_name)
    local addon_upper = string.upper(addon_name)
    local replace_name = addon_upper .. "_REPLACE_" .. origin_func_name
    g.FUNCS = g.FUNCS or {}
    if not _G[replace_name] then
        _G[replace_name] = _G[origin_func_name]
    end
    _G[origin_func_name] = my_func
    g.FUNCS[origin_func_name] = _G[replace_name]
end

function g.get_map_type()
    local map_name = session.GetMapName()
    local map_cls = GetClass("Map", map_name)
    local map_type = map_cls.MapType
    return map_type
end

function g.load_json(path)
    local file = io.open(path, "r")
    if not file then
        return nil, "Error opening file: " .. path
    end
    local content = file:read("*all")
    file:close()
    if not content or content == "" then
        return nil, "File content is empty or could not be read: " .. path
    end
    if string.sub(content, 1, 3) == "\239\187\191" then
        content = string.sub(content, 4)
    end
    local success, result = pcall(json.decode, content)
    if success then
        return result, nil
    else
        return nil, result
    end
end

function g.save_json(path, tbl)
    local file, err = io.open(path, "w")
    if not file then
        print(string.format("[g.save_json] Error opening file for write: %s (Error: %s)", tostring(path), tostring(err)))
        return false
    end
    local success, str = pcall(json.encode, tbl)
    if success then
        file:write(str)
        file:close()
        return true
    else
        file:close()
        print(string.format("[g.save_json] JSON Encode Error in '%s': %s", tostring(path), tostring(str)))
        return false
    end
end

function archeology_helper_save_settings()
    g.save_json(g.settings_path, g.settings)
end

function archeology_helper_load_settings()
    g.settings_path = string.format("../addons/%s/%s/settings.json", addon_name_lower, g.active_id)
    local settings = g.load_json(g.settings_path)
    if not settings then
        settings = {
            count = 0,
            is_archeology = false,
            map_info = {},
            x = 670,
            y = 70
        }
    end
    g.settings = settings -- ★この代入が抜けていたため、以降でg.settingsがnilになりクラッシュします
    archeology_helper_save_settings()
end

function ARCHEOLOGY_HELPER_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    g.REGISTER = {}
    g.lang = option.GetCurrentCountry()
    g.cid = session.GetMySession():GetCID()
    g.map_name = session.GetMapName()
    g.mkdir_new_folder()
    if not g.settings then
        archeology_helper_load_settings()
    end
    if not g.settings[g.cid] then
        g.settings[g.cid] = {
            sta_check = 0
        }
        archeology_helper_save_settings()
    end
    addon:RegisterMsg('GAME_START', 'archeology_helper_frame_init')
    g.setup_hook_and_event(g.addon, "_ARCHEOLOGY_MISSION_EXECUTE", "archeology_helper_ARCHEOLOGY_MISSION_EXECUTE", true)
    g.setup_hook_and_event(g.addon, "TARGETSPACE_PRECHECK", "archeology_helper_TARGETSPACE_PRECHECK", true)
    addon:RegisterMsg('GAME_START_3SEC', 'archeology_helper_GAME_START_3SEC')
end

function archeology_helper_GAME_START_3SEC()
    if g.get_map_type() == "City" and g.settings[g.cid].sta_check == 1 then
        local inv_item = session.GetInvItemByType(640009)
        if inv_item then
            if inv_item.count <= 10 then
                local msg = g.lang == "Japanese" and "スタミナ錠が残り少ないです" or
                                "Stamina pills are running low"
                imcAddOn.BroadMsg("NOTICE_Dm_!", msg, 10)
            end
        end
    end
    g.addon:RegisterMsg("MAP_CHARACTER_UPDATE", "archeology_helper_MAP_CHARACTER_UPDATE")
    local archeology_helper = ui.GetFrame("archeology_helper")
    archeology_helper:RunUpdateScript("archeology_helper_run_update", 1.0)
    archeology_helper:RunUpdateScript("archeology_helper_frame_update", 1.0)
end

function archeology_helper_frame_update(archeology_helper)
    local au_map = ui.GetFrame(addon_name_lower .. "au_map")
    if au_map and au_map:IsVisible() == 0 then
        archeology_helper_frame_init(archeology_helper)
    end
    return 1
end

function archeology_helper_run_update(archeology_helper)
    g.setup_hook_and_event(g.addon, "DRAW_CHAT_MSG", "archeology_helper_DRAW_CHAT_MSG", true)
end

function archeology_helper_DRAW_CHAT_MSG(my_frame, my_msg)
    if not g.settings then
        return
    end
    local groupboxname, startindex = g.get_event_args(my_msg)
    if not groupboxname or type(groupboxname) ~= "string" then
        return
    end
    local size = session.ui.GetMsgInfoSize(groupboxname)
    if size == 0 then
        return
    end
    local chat = session.ui.GetChatMsgInfo(groupboxname, size - 1)
    if not chat then
        return
    end
    local msg = chat:GetMsg()
    local config = nil
    if g.lang == "Japanese" then
        local jp_configs = {
            ["@dicID_^*$ETC_20220210_065695$*^"] = {
                size = 50,
                color = "FFFF0000"
            }, -- かなり遠い
            ["@dicID_^*$ETC_20220210_065696$*^"] = {
                size = 50,
                color = "FFFFA500"
            }, -- 遠い
            ["@dicID_^*$ETC_20220210_065697$*^"] = {
                size = 25,
                color = "FFFFFF00"
            }, -- 近い
            ["@dicID_^*$ETC_20220210_065699$*^"] = {
                size = 25,
                color = "FFFFFFFF"
            }, -- かなり近い
            ["@dicID_^*$ETC_20220210_065693$*^"] = {
                is_exit = true
            } -- 終了
        }
        config = jp_configs[msg]
    elseif g.lang == "kr" then
        if string.find(msg, "유물이") and string.find(msg, "것 같습니다") then -- 考古学メッセージ特有の単語（遺物が/ようです）で絞り込み
            if string.find(msg, "매우") and string.find(msg, "멀리") then
                config = {
                    size = 50,
                    color = "FFFF0000"
                } -- かなり遠い
            elseif string.find(msg, "매우") and string.find(msg, "가까이") then
                config = {
                    size = 25,
                    color = "FFFFFFFF"
                } -- かなり近い
            elseif string.find(msg, "멀리") then
                config = {
                    size = 50,
                    color = "FFFFA500"
                } -- 遠い
            elseif string.find(msg, "가까이") then
                config = {
                    size = 25,
                    color = "FFFFFF00"
                } -- 近い
            end
        elseif string.find(msg, "발굴 시도") and string.find(msg, "다시 임무") then
            config = {
                is_exit = true
            } -- 終了
        end
    else
        local en_configs = {
            ["@dicID_^*$ETC_20220204_066856$*^"] = {
                size = 50,
                color = "FFFF0000"
            }, -- かなり遠い
            ["@dicID_^*$ETC_20220204_066857$*^"] = {
                size = 50,
                color = "FFFFA500"
            }, -- 遠い
            ["@dicID_^*$ETC_20220204_066858$*^"] = {
                size = 25,
                color = "FFFFFF00"
            }, -- 近い
            ["@dicID_^*$ETC_20220204_066860$*^"] = {
                size = 25,
                color = "FFFFFFFF"
            }, -- かなり近い
            ["@dicID_^*$ETC_20220204_066854$*^"] = {
                is_exit = true
            } -- 終了
        }
        config = en_configs[msg]
    end
    if not config then
        return
    end
    local now = imcTime.GetAppTime()
    if g.ah_last_chat_time and (now - g.ah_last_chat_time < 1.0) then
        return
    end
    g.ah_last_chat_time = now
    local au_map = ui.GetFrame(addon_name_lower .. "au_map")
    if not au_map then
        return
    end
    if config.is_exit then
        g.archeology_helper_display = 1
        g.settings.is_archeology = false
        g.settings.count = 0
        g.settings.map_info = {}
        archeology_helper_frame_init()
    else
        local cur_map = session.GetMapName()
        local gbox = GET_CHILD(au_map, "gbox" .. cur_map)
        local map_pic = GET_CHILD(gbox, "map_pic" .. cur_map)
        if not map_pic then
            return
        end
        local my_handle = session.GetMyHandle()
        local pos = info.GetPositionInMap(my_handle, map_pic:GetWidth(), map_pic:GetHeight())
        archeology_helper_create_marker(map_pic, pos, config.size, config.color)
        local count_text = GET_CHILD(au_map, "count_text")
        if count_text then
            count_text:SetText("{ol}" .. g.settings.count .. "/50")
        end
    end
    archeology_helper_save_settings()
end

function archeology_helper_TARGETSPACE_PRECHECK(my_frame, my_msg)
    local handle = g.get_event_args(my_msg)
    local actor = world.GetActor(handle)
    if not actor then
        return
    end
    if actor:GetType() == 155003 then
        g.settings.count = g.settings.count + 1
        local map_name = session.GetMapName()
        if not g.settings.map_info[map_name] then
            g.settings.map_info[map_name] = {}
        end
        g.settings.map_info[map_name].markers = {}
        g.settings.map_info[map_name].get_count = (g.settings.map_info[map_name].get_count or 0) + 1
        local is_all_complete = true
        local acc_obj = GetMyAccountObj()
        for i = 1, (max_archeology_map_count or 3) do
            local m_name = TryGetProp(acc_obj, "archeology_map_" .. i, "None")
            if m_name ~= "None" then
                local info = g.settings.map_info[m_name]
                if not info or (info.get_count or 0) < 3 then
                    is_all_complete = false
                    break
                end
            end
        end
        if is_all_complete then
            g.settings.is_archeology = false
            g.settings.count = 0
            g.settings.map_info = {}
            g.archeology_helper_display = 1
            ui.SysMsg(g.lang == "Japanese" and "全てのMAPの発掘が完了しました" or
                          "Archeology completed for all maps")
        end
        archeology_helper_save_settings()
        archeology_helper_frame_init()
    end
end

function archeology_helper_MAP_CHARACTER_UPDATE()
    local my_handle = session.GetMyHandle()
    if g.settings[g.cid].sta_check == 1 then
        local sta_item = 640009
        local stat = info.GetStat(my_handle)
        local sta_num = math.floor(stat.Stamina / 1000)
        if sta_num <= 1 then
            local now = imcTime.GetAppTime()
            if not g.ah_last_sta_time or (now - g.ah_last_sta_time >= 10.0) then
                local inv_item = session.GetInvItemByType(sta_item)
                if inv_item then
                    INV_ICON_USE(inv_item)
                    g.ah_last_sta_time = now
                end
            end
        end
    end
    local au_map = ui.GetFrame(addon_name_lower .. "au_map")
    if not au_map then
        return
    end
    AUTO_CAST(au_map)
    local map_pic = GET_CHILD_RECURSIVELY(au_map, "map_pic" .. g.map_name)
    AUTO_CAST(map_pic)
    local pos = info.GetPositionInMap(my_handle, map_pic:GetWidth(), map_pic:GetHeight())
    local my = GET_CHILD_RECURSIVELY(au_map, "my")
    if not my then
        return
    end
    AUTO_CAST(my)
    my:ShowWindow(0)
    my:SetOffset(pos.x - my:GetWidth() / 2, pos.y - my:GetHeight() / 2)
    local mapprop = session.GetCurrentMapProp()
    local angle = info.GetAngle(my_handle) - mapprop.RotateAngle
    my:SetAngle(angle)
    my:ShowWindow(1)
    map_pic:Invalidate()
end

function archeology_helper_ARCHEOLOGY_MISSION_EXECUTE(my_frame, my_msg)
    g.settings.count = 0
    g.settings.is_archeology = true
    g.settings.map_info = {}
    archeology_helper_save_settings()
    g.archeology_helper_display = 0
    ui.DestroyFrame(addon_name_lower .. "au_map")
    local archeology_helper = ui.GetFrame("archeology_helper")
    archeology_helper:RunUpdateScript("archeology_helper_frame_init", 1.0)
end

function archeology_helper_frame_init(archeology_helper)
    g.map_name = session.GetMapName()
    if not g.settings.is_archeology then
        g.archeology_helper_display = 1
    end
    local au_map = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "au_map", 0, 0, 0, 0)
    AUTO_CAST(au_map)
    au_map:SetSkinName("None")
    au_map:SetLayerLevel(94)
    au_map:EnableHittestFrame(1)
    au_map:EnableMove(1)
    au_map:ShowTitleBar(0)
    au_map:RemoveAllChild()
    au_map:SetPos(g.settings.x or 670, g.settings.y or 70)
    au_map:SetEventScript(ui.LBUTTONUP, "archeology_helper_frame_save")
    local acc_obj = GetMyAccountObj()
    local disp_count = 0 -- ★追加: 表示位置計算用のカウンター
    for i = 1, (max_archeology_map_count or 3) do
        local map_name = TryGetProp(acc_obj, "archeology_map_" .. i, "None")
        if not g.settings.map_info[map_name] then
            g.settings.map_info[map_name] = {
                get_count = 0
            }
        end
        local map_cls = GetClass("Map", map_name)
        local is_complete = TryGetProp(acc_obj, 'archeology_map_' .. i .. '_complete', 0)
        if map_cls then
            local gbox = au_map:CreateOrGetControl("picture", "gbox" .. map_name, disp_count * 200, 20, 198, 220)
            AUTO_CAST(gbox)
            gbox:SetImage("fullwhite")
            gbox:SetEnableStretch(1)
            gbox:SetColorTone("AA696969")
            gbox:SetAlpha(50)
            -- gbox:SetSkinName("bg2")
            local title = gbox:CreateOrGetControl("richtext", "title", 5, 5)
            AUTO_CAST(title)
            title:SetText("{ol}{s13}" .. map_cls.Name)
            for j = 0, 2 do
                local mark = gbox:CreateOrGetControl("richtext", "mark" .. j, j * 15 + 10, 20)
                AUTO_CAST(mark)
                if (g.settings.map_info[map_name].get_count or 0) > j then
                    mark:SetText("{#00FF00}●")
                else
                    mark:SetText("{#808080}●")
                end
            end
            local map_pic = gbox:CreateOrGetControl("picture", "map_pic" .. map_name, 0, 20, 198, 200)
            AUTO_CAST(map_pic)
            map_pic:SetEnableStretch(1)
            map_pic:EnableHitTest(1)
            if g.map_name == map_name then
                local my = map_pic:CreateOrGetControl("picture", "my", 0, 0, 15, 15)
                AUTO_CAST(my)
                my:ShowWindow(0)
                my:SetImage("minimap_leader")
                my:SetEnableStretch(1)
                archeology_helper_char_update(my, map_pic)
            end
            archeology_helper_draw_markers(map_pic, map_name)
            local is_valid = ui.IsImageExist(map_name .. "_fog")
            if is_valid == false then
                world.PreloadMinimap(map_name)
            end
            map_pic:SetImage(map_name .. "_fog")
            local icon_group = map_pic:CreateOrGetControl("picture", "icon_group", ui.CENTER_HORZ, ui.CENTER_VERT,
                map_pic:GetWidth(), map_pic:GetHeight())
            AUTO_CAST(icon_group)
            icon_group:SetSkinName("None")
            local name_group = map_pic:CreateOrGetControl("picture", "name_group", ui.CENTER_HORZ, ui.CENTER_VERT,
                map_pic:GetWidth(), map_pic:GetHeight())
            AUTO_CAST(name_group)
            name_group:SetSkinName("None")
            -- UPDATE_MAP_BY_NAME(icon_group, map_name, map_pic, map_pic:GetWidth(), map_pic:GetHeight(), 0, 0)
            -- MAKE_MAP_AREA_INFO(name_group, map_name, "{s10}", map_pic:GetWidth(), map_pic:GetHeight(), -100, -30)
            local my_handle = session.GetMyHandle()
            local buff_info = info.GetBuff(my_handle, 70002)
            -- local is_token_state = session.loginInfo.IsPremiumState(ITEM_TOKEN)
            local image_name = ""
            if buff_info and GET_TOKEN_WARP_COOLDOWN() == 0 then
                image_name = "{img worldmap2_token_gold 30 30} {@st101lightbrown_16}"
            else
                image_name = "{img worldmap2_token_gray 30 30} {@st101lightbrown_16}"
            end
            local token = gbox:CreateOrGetControl("button", "token" .. i, 0, 0, 30, 30)
            AUTO_CAST(token)
            token:SetGravity(ui.RIGHT, ui.TOP)
            token:SetSkinName("None")
            token:SetText(image_name)
            token:SetUserValue("MAP_NAME", map_name)
            token:SetEventScript(ui.LBUTTONUP, "archeology_helper_tokenwarp")
            disp_count = disp_count + 1 -- ★追加: 表示したらカウントアップ
        end
    end
    local display = au_map:CreateOrGetControl("picture", "display", 0, 0, 20, 20)
    AUTO_CAST(display)
    display:SetEnableStretch(1)
    display:EnableHitTest(1)
    local image = ""
    if not g.archeology_helper_display or g.archeology_helper_display == 0 then
        g.archeology_helper_display = 0
        au_map:Resize(620, 240)
        image = "btn_minus"
    elseif g.archeology_helper_display == 1 then
        image = "btn_plus"
        au_map:Resize(20, 20)
    end
    display:SetImage(image)
    display:SetEventScript(ui.LBUTTONUP, "archeology_helper_frame_toggle")
    display:SetEventScript(ui.RBUTTONUP, "archeology_helper_setting_frame")
    display:SetTextTooltip("{ol}left-click: Display / hide{nl}right-click: settings")
    local cool_down = au_map:CreateOrGetControl("richtext", "cool_down", 20, 0)
    AUTO_CAST(cool_down)
    local cd = GET_TOKEN_WARP_COOLDOWN()
    local minutes = math.floor(cd / 60)
    local seconds = cd % 60
    local timer = string.format("%d:%02d", minutes, seconds)
    cool_down:SetText("{ol}{#FFFFFF}TokenWarp CD: " .. timer)
    cool_down:RunUpdateScript("archeology_helper_tokenwarp_cd", 1.0)
    local count_text = au_map:CreateOrGetControl("richtext", "count_text", cool_down:GetWidth() + 40, 0)
    AUTO_CAST(count_text)
    count_text:SetText("{ol}" .. g.settings.count .. "/50")
    local x = cool_down:GetWidth() + 40 + count_text:GetWidth()
    local slot = au_map:CreateOrGetControl('slot', 'slot', x + 10, 0, 20, 20)
    AUTO_CAST(slot)
    local item_cls = GetClassByType('Item', 11030018)
    SET_SLOT_ITEM_CLS(slot, item_cls)
    local item_count = au_map:CreateOrGetControl("richtext", "item_count", x + 35, 0)
    AUTO_CAST(item_count)
    local arc_text = au_map:CreateOrGetControl("richtext", "arc_text", x + 100, 0)
    AUTO_CAST(arc_text)
    local msg = ""
    if g.settings.is_archeology == true then
        msg = g.lang == "Japanese" and "{ol}{#FF0000}※進行中" or "{ol}{#FF0000}In Progress"
    else
        msg = g.lang == "Japanese" and "{ol}{#FF0000}※終了" or "{ol}{#FF0000}Ended"
        count_text:SetText("{ol}50/50")
    end
    arc_text:SetText(msg)
    local base_btn = au_map:CreateOrGetControl("button", "base_btn", 550, 0, 50, 20)
    AUTO_CAST(base_btn)
    base_btn:SetText("{ol}{s12}Base")
    base_btn:SetEventScript(ui.LBUTTONUP, "archeology_helper_frame_base_pos")
    archeology_helper_save_settings()
    au_map:ShowWindow(1)
    return 0
end

function archeology_helper_setting_frame(au_map, display)
    local setting = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "archeology_helper_setting", 0, 0, 0, 0)
    setting:SetPos(au_map:GetX(), au_map:GetY() + 240)
    setting:SetSkinName("test_frame_low")
    setting:EnableHittestFrame(1)
    setting:EnableHitTest(1)
    setting:SetLayerLevel(999)
    setting:RemoveAllChild()
    local title_text = setting:CreateOrGetControl('richtext', 'title_text', 20, 15, 50, 30)
    AUTO_CAST(title_text)
    title_text:SetText("{ol}Archeology Helper Config")
    local close = setting:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "archeology_helper_setting_frame_close")
    local gbox = setting:CreateOrGetControl("groupbox", "gbox", 10, 40, setting:GetWidth() - 20,
        setting:GetHeight() - 50) -- 945
    AUTO_CAST(gbox)
    gbox:EnableScrollBar(0)
    gbox:SetSkinName("test_frame_midle_light")
    local sta_check = gbox:CreateOrGetControl('checkbox', "sta_check", 10, 10, 30, 30)
    AUTO_CAST(sta_check)
    if not g.settings[g.cid] then
        g.settings[g.cid] = {
            sta_check = 0
        }
        archeology_helper_save_settings()
    end
    sta_check:SetCheck(g.settings[g.cid].sta_check)
    sta_check:SetText(g.lang == "Japanese" and
                          "{ol}チェックするとスタミナ錠自動使用{nl}設定はキャラ毎です" or
                          "{ol}If checked, it will automatically use stamina pills{nl}Settings are per character")
    sta_check:SetEventScript(ui.LBUTTONUP, "archeology_helper_setting_change")
    setting:Resize(sta_check:GetWidth() + 40, 120)
    gbox:Resize(setting:GetWidth() - 20, 70)
    setting:ShowWindow(1)
end

function archeology_helper_setting_change()
    g.settings[g.cid].sta_check = 1 - g.settings[g.cid].sta_check
    archeology_helper_save_settings()
end

function archeology_helper_setting_frame_close(setting)
    ui.DestroyFrame(setting:GetName())
end

function archeology_helper_frame_toggle(au_map, display)
    if not g.archeology_helper_display or g.archeology_helper_display == 1 then
        display:SetImage("btn_minus")
        g.archeology_helper_display = 0
        au_map:Resize(620, 240)
    else
        display:SetImage("btn_plus")
        g.archeology_helper_display = 1
        au_map:Resize(20, 20)
    end
end

function archeology_helper_frame_save(au_map)
    g.settings.x = au_map:GetX()
    g.settings.y = au_map:GetY()
    archeology_helper_save_settings()
end

function archeology_helper_frame_base_pos(au_map, base_btn)
    g.settings.x = 670
    g.settings.y = 70
    archeology_helper_save_settings()
    archeology_helper_frame_init()
end

function archeology_helper_draw_markers(map_pic, map_name)
    local markers = g.settings.map_info[map_name] and g.settings.map_info[map_name].markers or {}
    for _, m in ipairs(markers) do
        local circle = map_pic:CreateOrGetControl('picture', "circle" .. m.count, m.x - (m.size / 2),
            m.y - (m.size / 2), m.size, m.size)
        AUTO_CAST(circle)
        circle:SetImage("questmap")
        circle:SetColorTone(m.color)
        circle:SetEnableStretch(1)
        circle:SetEnable(0)
        local text_color = string.sub(m.color, 3)
        local marker_text = map_pic:CreateOrGetControl('richtext', "text" .. m.count, 0, 0)
        AUTO_CAST(marker_text)
        marker_text:SetText("{ol}{#" .. text_color .. "}{s14}" .. m.count)
        marker_text:SetOffset(m.x - (marker_text:GetWidth() / 2), m.y - (marker_text:GetHeight() / 2))
        circle:ShowWindow(1)
    end
end

function archeology_helper_tokenwarp_cd(cool_down)
    local cd = GET_TOKEN_WARP_COOLDOWN()
    local minutes = math.floor(cd / 60)
    local seconds = cd % 60
    local timer = string.format("%d:%02d", minutes, seconds)
    cool_down:SetText("{ol}{#FFFFFF}TokenWarp CD: " .. timer)
    local my_handle = session.GetMyHandle()
    local au_map = cool_down:GetTopParentFrame()
    for i = 1, (max_archeology_map_count or 3) do
        local buff_info = info.GetBuff(my_handle, 70002)
        local image_name = ""
        if buff_info and GET_TOKEN_WARP_COOLDOWN() == 0 then
            image_name = "{img worldmap2_token_gold 30 30} {@st101lightbrown_16}"
        else
            image_name = "{img worldmap2_token_gray 30 30} {@st101lightbrown_16}"
        end
        local token = GET_CHILD_RECURSIVELY(au_map, "token" .. i)
        if token then
            AUTO_CAST(token)
            token:SetText(image_name)
        end
    end
    local slot = GET_CHILD(au_map, "slot")
    local icon = slot:GetIcon()
    if not icon then
        icon = CreateIcon(slot)
    end
    local item_count = GET_CHILD(au_map, "item_count")
    local inv_item = session.GetInvItemByType(11030018)
    if inv_item then
        icon:SetColorTone('FFFFFFFF')
        item_count:SetText("{ol}(" .. inv_item.count .. ")")
    else
        icon:SetColorTone('FFFF0000')
        item_count:SetText("{ol}(0)")
    end
    return 1
end

function archeology_helper_create_marker(map_pic, pos, size, color)
    g.settings.count = (g.settings.count or 0) + 1
    local map_name = session.GetMapName()
    if not g.settings.map_info[map_name].markers then
        g.settings.map_info[map_name].markers = {}
    end
    table.insert(g.settings.map_info[map_name].markers, {
        x = pos.x,
        y = pos.y,
        size = size,
        color = color,
        count = g.settings.count
    })
    archeology_helper_save_settings()
    local circle = map_pic:CreateOrGetControl('picture', "circle" .. g.settings.count, pos.x - (size / 2),
        pos.y - (size / 2), size, size)
    AUTO_CAST(circle)
    circle:SetImage("questmap")
    circle:SetColorTone(color)
    circle:SetEnableStretch(1)
    circle:SetEnable(0)
    local text_color = string.sub(color, 3)
    local marker_text = map_pic:CreateOrGetControl('richtext', "text" .. g.settings.count, 0, 0)
    AUTO_CAST(marker_text)
    marker_text:SetText("{ol}{#" .. text_color .. "}{s14}" .. g.settings.count)
    local offsetX = pos.x - (marker_text:GetWidth() / 2)
    local offsetY = pos.y - (marker_text:GetHeight() / 2)
    marker_text:SetOffset(offsetX, offsetY)
    circle:ShowWindow(1)
end

function archeology_helper_char_update(my, map_pic)
    local my_handle = session.GetMyHandle()
    local pos = info.GetPositionInMap(my_handle, map_pic:GetWidth(), map_pic:GetHeight())
    my:SetOffset(pos.x - my:GetWidth() / 2, pos.y - my:GetHeight() / 2)
    local map_prop = session.GetCurrentMapProp()
    local angle = info.GetAngle(my_handle) - map_prop.RotateAngle
    my:SetAngle(angle)
    my:ShowWindow(1)
    map_pic:Invalidate()
end

function archeology_helper_tokenwarp(frame, ctrl)
    local map_name = ctrl:GetUserValue("MAP_NAME")
    if map_name ~= "None" then
        WORLDMAP2_TOKEN_WARP(map_name)
    end
end

-- "@dicID_^*$ETC_20220210_065693$*^"　終わり
-- "@dicID_^*$ETC_20220210_065695$*^" かなり遠く
-- "@dicID_^*$ETC_20220210_065697$*^"近く
-- "@dicID_^*$ETC_20220210_065699$*^" かなり近く
-- "@dicID_^*$ETC_20220210_065696$*^" 遠く
-- @dicID_^*$ETC_20220210_065689$*^ 開始
--[[very far ----> 유물이 매우 멀리 있는 것 같습니다.
far ----> 유물이 멀리 있는 것 같습니다.
near ----> 유물이 가까이 있는 것 같습니다.
very near ----> 유물이 매우 가까이 있는 것 같습니다.
give up ---->  수 많은 발굴 시도에도 유물을 발견하지 못해 더 이상 유물을 발견할 수 없을 것 같습니다. 다시 임무를 받아주세요.]]
--[[very far ----> ETC_20220204_066856
far ----> ETC_20220204_066857
near ----> ETC_20220204_066858
very near ----> ETC_20220204_066860
give up ---->  ETC_20220204_066854]]
