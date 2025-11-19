-- v1.0.2 クエワに対応。バウンティ対策。街以外の登録禁止。
-- v1.0.3 ショトカ設定‗\ろ。フェディクエワをパヤウタに。
-- v1.0.4 ちょいイジリ
-- v1.0.5 ミスって謎の語り部クリアしてしまったので増やした。
-- v1.0.6 レティーシャワープ付けた。トークンワープのカウントダウンをフレームに収めた。
-- v1.0.7 ワープ出来ないマップでSysMsgが永遠出続けるの直した。
-- v1.0.8 チャンネルチェンジするタイミングでたまに固まるの修正
-- v1.0.9 ウルトラワイド対応
-- v1.1.0 最適化
-- v1.1.1 ショートカット変更
local addon_name = "LETS_GO_HOME"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.1.1"

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

function g.save_json(path, tbl)
    local file = io.open(path, "w")
    if file then
        local str = json.encode(tbl)
        file:write(str)
        file:close()
    end
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

    local decoded_table, decode_err = json.decode(content)

    if not decoded_table then
        return nil, decode_err
    end

    return decoded_table, nil
end

function lets_go_home_save_settings()
    g.save_json(g.settings_path, g.settings)
end

function lets_go_home_load_settings()

    local settings = g.load_json(g.settings_path)

    if not settings then
        settings = {
            map = "",
            ch = 1,
            leticia = 0,
            screen = {
                x = 1610,
                y = 305
            }
        }
    elseif not settings.screen then
        settings.screen = {
            x = 1610,
            y = 305
        }
    end

    g.settings = settings
    lets_go_home_save_settings()
end

function lets_go_home_key_press(frame)

    if 1 == keyboard.IsKeyPressed("BACKSLASH") and 1 == keyboard.IsKeyPressed("RSHIFT") then
        if ENABLE_WARP_CHECK(GetMyPCObject()) == false then
            ui.SysMsg(ScpArgMsg("WarpBanBountyHunt"))
            return 1
        end
        lets_go_home_warp_do(frame)
    end
    return 1
end

function lets_go_home_frame_move_reserve(frame, ctrl, str, num)
    AUTO_CAST(frame)
    frame:SetSkinName("chat_window")
    frame:Resize(45, 30)
    frame:EnableHitTest(1)
    frame:EnableHittestFrame(1)
    frame:EnableMove(1)
    frame:SetEventScript(ui.LBUTTONUP, "lets_go_home_frame_move_save")
end

function lets_go_home_frame_move_save(frame, ctrl, str, num)
    local x = frame:GetX()
    local y = frame:GetY()
    g.settings["screen"] = {
        x = x,
        y = y
    }
    lets_go_home_save_settings()
    frame:StopUpdateScript("lets_go_home_frame_move_setskin")
    frame:RunUpdateScript("lets_go_home_frame_move_setskin", 5.0)

end

function lets_go_home_frame_move_setskin(frame)
    frame:SetSkinName("None")
    frame:Resize(30, 30)
end

function lets_go_home_frame_init()
    local frame = ui.GetFrame("lets_go_home")
    frame:SetSkinName('None')
    frame:Resize(30, 30)

    local map_frame = ui.GetFrame("map")
    local width = map_frame:GetWidth()

    if g.settings.screen.x > 1920 and width <= 1920 then
        g.settings.screen = {
            x = 1610,
            y = 305
        }
    end

    frame:SetPos(g.settings.screen.x, g.settings.screen.y)
    frame:SetTitleBarSkin("None")

    local btn = frame:CreateOrGetControl('button', 'home', 0, 0, 30, 30)
    AUTO_CAST(btn)
    btn:SetGravity(ui.LEFT, ui.TOP)
    btn:SetSkinName("None")
    btn:SetText("{img btn_housing_editmode_small_resize 30 30}")
    btn:SetTextTooltip(g.lang == "Japanese" and
                           "{ol}右クリック:ホーム設定{nl}左クリック:ワープ{nl}ショートカット:BackSlash+RSHIFT{nl}フレームの端を掴んで動かせます{/}" or
                           "{ol}Rightclick:Home Setting{nl}Leftclick:Warp{nl}Shortcut:BackSlash+RSHIFT{nl}Grab the edge of the frame and move it{/}")
    btn:SetEventScript(ui.RBUTTONUP, "lets_go_home_settings")
    btn:SetEventScript(ui.LBUTTONDOWN, "lets_go_home_warp_do")
    frame:ShowWindow(1)
    frame:RunUpdateScript("lets_go_home_key_press", 0.2)

    frame:RunUpdateScript("lets_go_home_update_frame", 1.0)

    btn:SetEventScript(ui.MOUSEON, "lets_go_home_frame_move_reserve")
    btn:SetEventScript(ui.MOUSEOFF, "lets_go_home_frame_move_save")

    lets_go_home_change_move()
end

function lets_go_home_settings()

    local pc = GetMyPCObject()
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        local msg = g.lang == "Japanese" and "現在のマップとチャンネルをホームにしますか？" or
                        "Do you want to home in on the current map and channel?"
        local yes_scp = string.format("lets_go_home_settings_reg()")
        ui.MsgBox(msg, yes_scp, "None")
    else
        ui.SysMsg(g.lang == "Japanese" and "このマップは設定できません" or "This map cannot be set up")
    end

end

function lets_go_home_settings_reg()

    local channel, mapname, map_name = lets_go_home_get_channel_and_mapname()
    g.settings.ch = channel
    g.settings.map = mapname
    g.settings.leticia = 0
    ui.SysMsg(g.lang == "Japanese" and "マップ名: " .. map_name .. " チャンネル: " .. channel ..
                  "を登録{nl}レティーシャへの移動を無効にしました" or "MapName: " .. map_name ..
                  " Channel: " .. channel .. "Registered{nl}Move to Leticia disabled")
    lets_go_home_save_settings()

    local msg = g.lang == "Japanese" and "レティーシャへ移動は使用しますか？" or
                    "Do you use Move to Leticia?"
    local yes_scp = string.format("lets_go_home_settings_reg_2()")
    ui.MsgBox(msg, yes_scp, "None")
    return
end

function lets_go_home_settings_reg_2()
    ui.SysMsg(g.lang == "Japanese" and "レティーシャへの移動を有効にしました" or
                  "Move to Leticia enabled")
    g.settings.leticia = 1
    lets_go_home_save_settings()
    return
end

function lets_go_home_leticia_move()

    local guid = 309
    local cls = GetClassByType("full_screen_navigation_menu", guid)
    if cls ~= nil then
        local name = TryGetProp(cls, "Name", "None")

        local move_zone_select = TryGetProp(cls, "MoveZoneSelect", "NO")
        local move_zone = TryGetProp(cls, "MoveZone", "None")
        local move_npc_dialog = TryGetProp(cls, "MoveNpcDialog", "None")
        local move_zone_select_msg = TryGetProp(cls, "MoveZoneSelectMsg", "None")
        local move_only_in_town = TryGetProp(cls, "MoveOnlyInTown", "None")
        if move_zone ~= "None" and move_npc_dialog ~= "None" then
            -- 매칭 던전중이거나 pvp존이면 이용 불가
            local pc = GetMyPCObject()
            if session.world.IsIntegrateServer() == true or IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
                ui.SysMsg(ScpArgMsg("ThisLocalUseNot"))
                return
            end
            -- 퀘스트나 챌린지 모드로 인해 레이어 변경되면 이용 불가
            if world.GetLayer() ~= 0 then
                ui.SysMsg(ScpArgMsg("ThisLocalUseNot"))
                return
            end
            -- 프리던전 맵에서 이용 불가
            local cur_map = GetClass("Map", session.GetMapName())
            local map_type = TryGetProp(cur_map, "MapType")
            if map_type == "Dungeon" then
                ui.SysMsg(ScpArgMsg("ThisLocalUseNot"))
                return
            end
            -- 레이드 지역에서 이용 불가
            local zoneKeyword = TryGetProp(cur_map, 'Keyword', 'None')

            --[[print(
                string.format("[LETS_GO_HOME DEBUG] Map: %s, Keyword: %s", session.GetMapName(), tostring(zoneKeyword)))]]

            local keywordTable = StringSplit(zoneKeyword, '')
            if table.find(keywordTable, 'IsRaidField') > 0 or table.find(keywordTable, 'WeeklyBossMap') > 0 then
                ui.SysMsg(ScpArgMsg('ThisLocalUseNot'))
                return
            end
            FullScreenMenuMoveNpc(name, move_zone_select, move_zone, move_npc_dialog, move_zone_select_msg,
                move_only_in_town)
            ui.CloseFrame("fullscreen_navigation_menu")
        end
    end
end

function lets_go_home_change_move()
    if g.settings.map ~= session.GetMapName() then
        g.warp = 0
        return
    end

    local channel = session.loginInfo.GetChannel() + 1

    if g.warp == 1 then
        if channel ~= g.settings.ch then

            if g.settings.leticia == 1 then
                g.warp = 2
            end

            lets_go_home_channel_change()

            return
        else
            g.warp = 0
            if g.settings.leticia == 1 then

                lets_go_home_leticia_move()
            end
        end
    end

    if g.warp == 2 then
        lets_go_home_leticia_move()
        g.warp = 0
    end

    if g.warp == 3 then
        g.warp = 0
    end
end

function LETS_GO_HOME_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()

    if not g.settings then
        lets_go_home_load_settings()
    end

    addon:RegisterMsg("GAME_START_3SEC", "lets_go_home_frame_init")

end

function lets_go_home_get_channel_and_mapname()
    local channel = session.loginInfo.GetChannel() + 1
    local pc = GetMyPCObject()
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    local mapname = mapCls.ClassName
    local map_name = mapCls.Name
    return channel, mapname, map_name
end

function lets_go_home_channel_change()

    RUN_GAMEEXIT_TIMER("Channel", g.settings.ch - 1)
end

function lets_go_home_warp_do(frame)

    local channel, mapname = lets_go_home_get_channel_and_mapname()
    local save_ch = g.settings.ch
    local save_map = g.settings.map

    if save_map == "" then
        ui.MsgBox(g.lang == "Japanese" and "マップ未設定です" or "Not Map setting")
        return
    elseif save_ch == channel and save_map == mapname then
        return
    elseif save_ch ~= channel and save_map == mapname then
        g.warp = 3
        lets_go_home_channel_change()
        return
    end

    local quests = {
        ["c_Klaipe"] = {{
            quest_id = 91055,
            result = "POSSIBLE",
            state = "Start"
        }, {
            quest_id = 72165,
            result = "SUCCESS",
            state = "End"
        }},
        ["c_orsha"] = {{
            quest_id = 90170,
            result = "SUCCESS",
            state = "End"
        }, {
            quest_id = 90171,
            result = "SUCCESS",
            state = "End"
        }},
        ["c_fedimian"] = {{
            quest_id = 60400,
            result = "POSSIBLE",
            state = "Start"
        }}
    }
    local pc = GetMyPCObject()
    local quest_id = nil
    for key, value in pairs(quests) do
        if key == save_map then
            for key2, value2 in pairs(value) do
                local questIES = GetClassByType('QuestProgressCheck', value2.quest_id)
                local result = SCR_QUEST_CHECK_C(pc, questIES.ClassName)
                local questState = GET_QUEST_NPC_STATE(questIES, result)
                if result == value2.result and questState == value2.state then
                    quest_id = value2.quest_id
                    break
                end
            end
        end
    end

    if quest_id then
        lets_go_home_quest_warp(quest_id)
    else
        lets_go_home_not_quest_warp(save_map)
    end

end

function lets_go_home_quest_warp(quest_id)
    g.warp = 1
    QUESTION_QUEST_WARP(nil, nil, nil, quest_id)
    return

end

function lets_go_home_not_quest_warp(map_name)

    local cd = GET_TOKEN_WARP_COOLDOWN()
    if cd == 0 then
        g.warp = 1
        WORLDMAP2_TOKEN_WARP_REQUEST(map_name)
        return
    end

    local warpItems = {
        ["c_Klaipe"] = 640073,
        ["c_orsha"] = 640156,
        ["c_fedimian"] = 640182
    }

    local channel, mapname = lets_go_home_get_channel_and_mapname()
    local save_map = g.settings.map

    session.ResetItemList()
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList()
    local cnt = guidList:Count()

    for i = 0, cnt - 1 do
        local guid = guidList:Get(i)
        local invItem = invItemList:GetItemByGuid(guid)
        local itemobj = GetIES(invItem:GetObject())
        local iesid = invItem:GetIESID()

        local targetID = warpItems[save_map]
        if itemobj.ClassID == targetID and mapname ~= save_map then
            TRY_TO_USE_WARP_ITEM(invItem, itemobj)
            INV_ICON_USE(invItem)
            g.warp = 1
            return
        end
    end

end

function lets_go_home_update_frame(frame)

    local home = GET_CHILD(frame, "home")
    local cd_text = home:CreateOrGetControl('richtext', 'cd_text', 5, 10)
    AUTO_CAST(cd_text)
    local cd = GET_TOKEN_WARP_COOLDOWN()

    cd_text:SetText("{ol}{#FFFFFF}{s13}" .. cd)

    if cd >= 100 then
        cd_text:ShowWindow(1)
        return 1
    elseif cd < 100 and cd >= 10 then
        cd_text:SetOffset(9, 10)
        return 1
    elseif cd < 10 and cd >= 1 then
        cd_text:SetOffset(13, 10)
        return 1
    else
        cd_text:ShowWindow(0)
        return 0
    end
end

