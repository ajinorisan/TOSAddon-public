-- v1.0.2 クエワに対応。バウンティ対策。街以外の登録禁止。
-- v1.0.3 ショトカ設定‗\ろ。フェディクエワをパヤウタに。
-- v1.0.4 ちょいイジリ
-- v1.0.5 ミスって謎の語り部クリアしてしまったので増やした。
-- v1.0.6 レティーシャワープ付けた。トークンワープのカウントダウンをフレームに収めた。
-- v1.0.7 ワープ出来ないマップでSysMsgが永遠出続けるの直した。
local addonName = "LETS_GO_HOME"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.7"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local base = {}
local active_id = session.loginInfo.GetAID()
g.settingsFileLoc = string.format('../addons/%s/%s.json', addonNameLower, active_id)

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

local acutil = require("acutil")

function LETS_GO_HOME_SAVE_SETTINGS()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function LETS_GO_HOME_LOAD_SETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if not settings then
        settings = {
            map = "",
            ch = 1,
            leticia = 0
        }
    end

    g.settings = settings
    LETS_GO_HOME_SAVE_SETTINGS()
end

function LETS_GO_HOME_KEYPRESS(frame)

    if ENABLE_WARP_CHECK(GetMyPCObject()) == false then
        ui.SysMsg(ScpArgMsg("WarpBanBountyHunt"))
        return 0
    end

    if 1 == keyboard.IsKeyPressed("BACKSLASH") then
        LETS_GO_HOME_WARP(frame)
    end
    return 1
end

function LETS_GO_HOME_FRAME_INIT()
    local frame = ui.GetFrame("lets_go_home")
    frame:SetSkinName('None')
    frame:Resize(30, 30)
    frame:SetPos(1610, 305)
    frame:SetTitleBarSkin("None")

    local btn = frame:CreateOrGetControl('button', 'home', 0, 0, 30, 30)
    btn:SetSkinName("None")
    btn:SetText("{img btn_housing_editmode_small_resize 30 30}")
    btn:SetTextTooltip(g.lang == "Japanese" and
                           "{ol}右クリック:ホーム設定{nl}左クリック:ワープ{nl}ショートカット:BackSlash{/}" or
                           "{ol}Rightclick:Home Setting{nl}Leftclick:Warp{nl}Shortcut:BackSlash{/}")
    btn:SetEventScript(ui.RBUTTONUP, "LETS_GO_HOME_SETTING")
    btn:SetEventScript(ui.LBUTTONDOWN, "LETS_GO_HOME_WARP")
    frame:ShowWindow(1)
    frame:RunUpdateScript("LETS_GO_HOME_KEYPRESS", 0.2)
end

function LETS_GO_HOME_BOUNTYHUNT()
    local frame = ui.GetFrame("lets_go_home")
    local bouframe = ui.GetFrame("bountyhunt_milestone");
    if bouframe:IsVisible() == 1 then
        frame:ShowWindow(0)
        return
    else
        frame:ShowWindow(1)
        return
    end
end

function LETS_GO_HOME_SETTING()

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        local msg = g.lang == "Japanese" and "現在のマップとチャンネルをホームにしますか？" or
                        "Do you want to home in on the current map and channel?"
        local yes_scp = string.format("LETS_GO_HOME_SETTING_REG()")
        ui.MsgBox(msg, yes_scp, "None");
    else
        ui.SysMsg(g.lang == "Japanese" and "このマップは設定できません" or "This map cannot be set up")
    end

end

function LETS_GO_HOME_SETTING_REG()

    local channel, mapname, map_name = LETS_GO_HOME_GET_CHANNEL_AND_MAPNAME()
    g.settings.ch = channel
    g.settings.map = mapname
    g.settings.leticia = 0
    ui.SysMsg(g.lang == "Japanese" and "マップ名: " .. map_name .. " チャンネル: " .. channel ..
                  "を登録{nl}レティーシャへの移動を無効にしました" or "MapName: " .. map_name ..
                  " Channel: " .. channel .. "Registered{nl}Move to Leticia disabled")
    LETS_GO_HOME_SAVE_SETTINGS()

    local msg = g.lang == "Japanese" and "レティーシャへ移動は使用しますか？" or
                    "Do you use Move to Leticia?"
    local yes_scp = string.format("LETS_GO_HOME_SETTING_REG_2()")
    ui.MsgBox(msg, yes_scp, "None");
    return
end

function LETS_GO_HOME_SETTING_REG_2()
    ui.SysMsg(g.lang == "Japanese" and "レティーシャへの移動を有効にしました" or
                  "Move to Leticia enabled")
    g.settings.leticia = 1
    LETS_GO_HOME_SAVE_SETTINGS()
    return
end

function lets_go_home_leticia_move()

    local guid = 309
    local cls = GetClassByType("full_screen_navigation_menu", guid);
    if cls ~= nil then
        local name = TryGetProp(cls, "Name", "None");

        local move_zone_select = TryGetProp(cls, "MoveZoneSelect", "NO");
        local move_zone = TryGetProp(cls, "MoveZone", "None");
        local move_npc_dialog = TryGetProp(cls, "MoveNpcDialog", "None");
        local move_zone_select_msg = TryGetProp(cls, "MoveZoneSelectMsg", "None");
        local move_only_in_town = TryGetProp(cls, "MoveOnlyInTown", "None");
        if move_zone ~= "None" and move_npc_dialog ~= "None" then
            -- 매칭 던전중이거나 pvp존이면 이용 불가
            local pc = GetMyPCObject();
            if session.world.IsIntegrateServer() == true or IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
                ui.SysMsg(ScpArgMsg("ThisLocalUseNot"));
                return;
            end
            -- 퀘스트나 챌린지 모드로 인해 레이어 변경되면 이용 불가
            if world.GetLayer() ~= 0 then
                ui.SysMsg(ScpArgMsg("ThisLocalUseNot"));
                return;
            end
            -- 프리던전 맵에서 이용 불가
            local cur_map = GetClass("Map", session.GetMapName());
            local map_type = TryGetProp(cur_map, "MapType");
            if map_type == "Dungeon" then
                ui.SysMsg(ScpArgMsg("ThisLocalUseNot"));
                return;
            end
            -- 레이드 지역에서 이용 불가
            local zoneKeyword = TryGetProp(cur_map, 'Keyword', 'None')
            local keywordTable = StringSplit(zoneKeyword, ';')
            if table.find(keywordTable, 'IsRaidField') > 0 or table.find(keywordTable, 'WeeklyBossMap') > 0 then
                ui.SysMsg(ScpArgMsg('ThisLocalUseNot'))
                return
            end
            FullScreenMenuMoveNpc(name, move_zone_select, move_zone, move_npc_dialog, move_zone_select_msg,
                                  move_only_in_town);
            ui.CloseFrame("fullscreen_navigation_menu");
        end
    end
end

function LETS_GO_HOME_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()

    LETS_GO_HOME_LOAD_SETTINGS()

    local frame = ui.GetFrame("lets_go_home")
    frame:RunUpdateScript("LETS_GO_HOME_UPDATE_FRAME", 1.0)
    addon:RegisterMsg("GAME_START", "LETS_GO_HOME_FRAME_INIT")
    addon:RegisterMsg("FPS_UPDATE", "LETS_GO_HOME_BOUNTYHUNT")

    if g.settings.map ~= session.GetMapName() then
        g.warp = 0
        return
    end

    local channel = session.loginInfo.GetChannel() + 1;

    if g.warp == 1 then
        if channel ~= g.settings.ch then

            if g.settings.leticia == 1 then
                g.warp = 2
            end
            addon:RegisterMsg("GAME_START", "LETS_GO_HOME_CHANNEL_CHANGE")
            -- RUN_GAMEEXIT_TIMER("Channel", g.settings.ch - 1)
            return
        else
            g.warp = 0
            if g.settings.leticia == 1 then
                addon:RegisterMsg("GAME_START", "lets_go_home_leticia_move")
            end
        end
    end

    if g.warp == 2 then
        addon:RegisterMsg("GAME_START", "lets_go_home_leticia_move")
        g.warp = 0
    end

    if g.warp == 3 then
        g.warp = 0
    end
end

function LETS_GO_HOME_GET_CHANNEL_AND_MAPNAME()
    local channel = session.loginInfo.GetChannel() + 1;
    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    local mapname = mapCls.ClassName
    local map_name = mapCls.Name
    return channel, mapname, map_name
end

function LETS_GO_HOME_CHANNEL_CHANGE()

    RUN_GAMEEXIT_TIMER("Channel", g.settings.ch - 1)
end

function LETS_GO_HOME_WARP(frame)

    local channel, mapname = LETS_GO_HOME_GET_CHANNEL_AND_MAPNAME()
    local save_ch = g.settings.ch
    local save_map = g.settings.map

    if save_map == "" then
        ui.MsgBox(g.lang == "Japanese" and "マップ未設定です" or "Not Map setting")
        return
    elseif save_ch == channel and save_map == mapname then
        return
    elseif save_ch ~= channel and save_map == mapname then
        g.warp = 3
        LETS_GO_HOME_CHANNEL_CHANGE()
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
        LETS_GO_HOME_QUESTWARP(quest_id)
    else
        LETS_GO_HOME_NOT_QUESTWARP(save_map)
    end

end

function LETS_GO_HOME_QUESTWARP(quest_id)
    g.warp = 1
    QUESTION_QUEST_WARP(nil, nil, nil, quest_id)
    return

end

function LETS_GO_HOME_NOT_QUESTWARP(map_name)

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

    local channel, mapname = LETS_GO_HOME_GET_CHANNEL_AND_MAPNAME()
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

function LETS_GO_HOME_UPDATE_FRAME(cdframe)

    local frame = ui.GetFrame("lets_go_home")
    local home = GET_CHILD(frame, "home")
    local cdtext = home:CreateOrGetControl('richtext', 'cdtext', 5, 10)
    AUTO_CAST(cdtext)
    local cd = GET_TOKEN_WARP_COOLDOWN()

    cdtext:SetText("{ol}{#FFFFFF}{s13}" .. cd)

    if cd >= 100 then
        cdtext:ShowWindow(1)
        return 1
    elseif cd < 100 and cd >= 10 then
        cdtext:SetOffset(9, 10)
        return 1
    elseif cd < 10 and cd >= 1 then
        cdtext:SetOffset(13, 10)
        return 1
    else
        cdtext:ShowWindow(0)
        return 0
    end
end

--[[function LETS_GO_HOME_TOKENWARP(className)
    WORLDMAP2_TOKEN_WARP_REQUEST(className)
    return
end]]

--[[function LETS_GO_HOME_TOKENWARP_CD_FRAME()

    local cdframe = ui.CreateNewFrame("notice_on_pc", "cdframe", 0, 0, 0, 0)
    AUTO_CAST(cdframe)
    cdframe:Resize(180, 30)
    cdframe:SetPos(1610, 335)
    cdframe:SetTitleBarSkin("None")
    cdframe:SetSkinName("None")
    cdframe:RunUpdateScript("LETS_GO_HOME_UPDATE_FRAME", 1.0)
    cdframe:ShowWindow(1)

    local frame = ui.GetFrame("lets_go_home")
    frame:RunUpdateScript("LETS_GO_HOME_UPDATE_FRAME", 1.0)

end]]
