-- v1.0.2 クエワに対応。バウンティ対策。街以外の登録禁止。
-- v1.0.3 ショトカ設定‗\ろ。フェディクエワをパヤウタに。
-- v1.0.4 ちょいイジリ
-- v1.0.5 ミスって謎の語り部クリアしてしまったので増やした。
local addonName = "LETS_GO_HOME"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.5"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
local acutil = require("acutil")

function LETS_GO_HOME_LOAD_SETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not settings then
        settings = {
            map = nil,
            ch = 1
        }
    end

    g.settings = settings
end

function LETS_GO_HOME_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()

    LETS_GO_HOME_LOAD_SETTINGS()
    LETS_GO_HOME_TOKENWARP_CD_FRAME()
    addon:RegisterMsg("GAME_START", "LETS_GO_HOME_FRAME_INIT")
    addon:RegisterMsg("FPS_UPDATE", "LETS_GO_HOME_BOUNTYHUNT")

    if g.warp == 1 then
        LETS_GO_HOME_CHANNEL_CHANGE()
        return
    end
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

    local channel, mapname = LETS_GO_HOME_GET_CHANNEL_AND_MAPNAME()
    g.settings.ch = channel
    g.settings.map = mapname
    LETS_GO_HOME_SAVE_SETTINGS()
    return
end

function LETS_GO_HOME_KEYPRESS(frame)

    if 1 == keyboard.IsKeyPressed("BACKSLASH") then
        LETS_GO_HOME_WARP(frame)
    end
    return 1
end

function LETS_GO_HOME_WARP(frame)

    local channel, mapname = LETS_GO_HOME_GET_CHANNEL_AND_MAPNAME()
    local save_ch = g.settings.ch
    local save_map = g.settings.map

    if save_map == nil then
        ui.MsgBox(g.lang == "Japanese" and "マップ未設定です" or "Not setting")
        return
    elseif save_ch == channel and save_map == mapname then
        return
    elseif save_ch ~= channel and save_map == mapname then
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

--[[local questIES = GetClassByType('QuestProgressCheck', 90171)
local pc = GetMyPCObject()
local result = SCR_QUEST_CHECK_C(pc, questIES.ClassName)
local questState = GET_QUEST_NPC_STATE(questIES, result)
print(tostring(result) .. ":" .. tostring(questState))]]

function LETS_GO_HOME_QUESTWARP(quest_id)

    g.warp = 1
    QUESTION_QUEST_WARP(nil, nil, nil, quest_id)
    return

end

function LETS_GO_HOME_NOT_QUESTWARP(map_name)

    local cd = GET_TOKEN_WARP_COOLDOWN()
    if cd == 0 then
        g.warp = 1

        LETS_GO_HOME_TOKENWARP(map_name)
        return
    end

    local warpItems = {
        ["c_Klaipe"] = 640073,
        ["c_orsha"] = 640156,
        ["c_fedimian"] = 640182
    }

    local channel, mapname = LETS_GO_HOME_GET_CHANNEL_AND_MAPNAME()
    local save_map = g.settings.map

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
            session.ResetItemList()
            TRY_TO_USE_WARP_ITEM(invItem, itemobj)
            INV_ICON_USE(invItem)
            g.warp = 1
            return
        end
    end

end

function LETS_GO_HOME_TOKENWARP(className)
    WORLDMAP2_TOKEN_WARP_REQUEST(className)
    return
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

function LETS_GO_HOME_TOKENWARP_CD_FRAME()

    local cdframe = ui.CreateNewFrame("notice_on_pc", "cdframe", 0, 0, 0, 0)
    AUTO_CAST(cdframe)
    cdframe:Resize(180, 30)
    cdframe:SetPos(1610, 335)
    cdframe:SetTitleBarSkin("None")
    cdframe:SetSkinName("None")

    cdframe:RunUpdateScript("LETS_GO_HOME_UPDATE_FRAME", 1.0)
    cdframe:ShowWindow(1)
end

function LETS_GO_HOME_UPDATE_FRAME(cdframe)
    local cdtext = cdframe:CreateOrGetControl('richtext', 'cdtext', 5, 5)
    AUTO_CAST(cdtext)
    local cd = GET_TOKEN_WARP_COOLDOWN()

    local minutes = math.floor(cd / 60)
    local seconds = cd % 60
    local cdtimer = string.format('%d:%02d', minutes, seconds)

    cdtext:SetText("{ol}{#FFFFFF}TokenWarp CD: " .. cdtimer)

    if cd > 0 then
        cdframe:ShowWindow(1)
        return 1
    else
        cdframe:ShowWindow(0)
        return 0
    end
end

function LETS_GO_HOME_CHANNEL_CHANGE()

    local channel, mapname = LETS_GO_HOME_GET_CHANNEL_AND_MAPNAME()
    local save_ch = g.settings.ch
    local save_map = g.settings.map

    if save_ch ~= channel and save_map == mapname then
        RUN_GAMEEXIT_TIMER("Channel", save_ch - 1);
        g.warp = 0
    else
        g.warp = 0
    end
end

function LETS_GO_HOME_GET_CHANNEL_AND_MAPNAME()
    local channel = session.loginInfo.GetChannel() + 1;
    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    local mapname = mapCls.ClassName
    return channel, mapname
end

function LETS_GO_HOME_SAVE_SETTINGS()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

