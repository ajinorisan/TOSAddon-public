-- v1.0.2 クエワに対応。バウンティ対策。街以外の登録禁止。
local addonName = "LETS_GO_HOME"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.2"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")

if not g.loaded then
    g.settings = {
        map = nil,
        ch = 1
    }
end

function LETS_GO_HOME_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    LETS_GO_HOME_LOAD_SETTINGS()

    session.ResetItemList()

    -- acutil.setupEvent(addon, "BOUNTYHUNT_MILESTONE_OPEN", "LETS_GO_HOME_BOUNTYHUNT_MILESTONE_OPEN");
    -- acutil.setupEvent(addon, "BOUNTYHUNT_YESSCP_EXITMSGBOX", "LETS_GO_HOME_BOUNTYHUNT_YESSCP_EXITMSGBOX");
    -- local bouframe = ui.GetFrame("bountyhunt_milestone");
    -- if bouframe:IsVisible() == 1 then
    addon:RegisterMsg("GAME_START", "LETS_GO_HOME_FRAME_INIT")
    addon:RegisterMsg("FPS_UPDATE", "LETS_GO_HOME_BOUNTYHUNT")

    LETS_GO_HOME_TOKENWARP_CD_FRAME()

    if g.warp == 1 then
        LETS_GO_HOME_CHANNEL_CHANGE()
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
    btn:SetTextTooltip("{@st59}RightButton:Setting LeftButton:Warp{/}" ..
                           "{@st59}右クリック:ホーム設定 左クリック:ワープ{/}")
    btn:SetEventScript(ui.RBUTTONUP, "LETS_GO_HOME_SETTING")
    -- btn:SetEventScript(ui.LBUTTONUP, "LETS_GO_HOME_WARP")

    btn:SetEventScript(ui.LBUTTONDOWN, "LETS_GO_HOME_WARP")
    -- btn:SetEventScript(ui.LBUTTONUP, "LETS_GO_HOME_TOKENWARP")
    btn:SetEventScriptArgString(ui.LBUTTONDOWN, tostring(g.settings.map))
    -- CHAT_SYSTEM(tostring(g.settings.map))
    frame:ShowWindow(1)
    -- frame:RunUpdateScript("LETS_GO_HOME_BOUNTYHUNT", 1.0)
end

function LETS_GO_HOME_BOUNTYHUNT()
    local frame = ui.GetFrame("lets_go_home")
    local bouframe = ui.GetFrame("bountyhunt_milestone");
    local bouframevisible = bouframe:IsVisible()
    -- CHAT_SYSTEM(tostring(bouframevisible))
    if bouframe:IsVisible() == 1 then

        frame:ShowWindow(0)
        return
    else
        frame:ShowWindow(1)
        return
    end
end

function LETS_GO_HOME_QUESTWARP(questID)

    if questID == 72159 then -- フェディミアン"c_fedimian"
        local questIES = GetClassByType('QuestProgressCheck', questID)
        local pc = GetMyPCObject()
        local result = SCR_QUEST_CHECK_C(pc, questIES.ClassName)
        local questState = GET_QUEST_NPC_STATE(questIES, result)
        if tostring(result) == "SUCCESS" and tostring(questState) == "End" then
            g.warp = 1
            QUESTION_QUEST_WARP(nil, nil, nil, questID);
            return
        else
            local className = "c_fedimian"
            LETS_GO_HOME_NOT_QUESTWARP(_, _, className, _)
        end
    elseif questID == 90170 then -- オルシャ"c_orsha"
        local questIES = GetClassByType('QuestProgressCheck', questID)
        local pc = GetMyPCObject()
        local result = SCR_QUEST_CHECK_C(pc, questIES.ClassName)
        local questState = GET_QUEST_NPC_STATE(questIES, result)
        if tostring(result) == "SUCCESS" and tostring(questState) == "End" then
            g.warp = 1
            QUESTION_QUEST_WARP(nil, nil, nil, questID);
            return
        else
            local className = "c_orsha"
            LETS_GO_HOME_NOT_QUESTWARP(_, _, className, _)

        end
    elseif questID == 91055 then -- クラペダ"c_Klaipe"
        local questIES = GetClassByType('QuestProgressCheck', questID)
        local pc = GetMyPCObject()
        local result = SCR_QUEST_CHECK_C(pc, questIES.ClassName)
        local questState = GET_QUEST_NPC_STATE(questIES, result)
        if tostring(result) == "POSSIBLE" and tostring(questState) == "Start" then
            g.warp = 1
            QUESTION_QUEST_WARP(nil, nil, nil, questID);
            return
        else
            local className = "c_Klaipe"
            LETS_GO_HOME_NOT_QUESTWARP(_, _, className, _)
        end
    end
end

function LETS_GO_HOME_NOT_QUESTWARP(_, _, className, _)

    local Scroll_Warp_Klaipe = session.GetInvItemByType(640073)
    local Scroll_Warp_Orsha = session.GetInvItemByType(640156)
    local Scroll_Warp_Fedimian = session.GetInvItemByType(640182)

    local KlaipeID = 640073
    local OrshaID = 640156
    local FedimianID = 640182

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    local mapname = mapCls.ClassName

    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList();
    local cnt = guidList:Count();

    local channelnum = session.loginInfo.GetChannel() + 1;

    local cd = GET_TOKEN_WARP_COOLDOWN()
    if cd == 0 then
        LETS_GO_HOME_TOKENWARP(_, _, className, _)

    else
        for i = 0, cnt - 1 do
            local guid = guidList:Get(i);
            local invItem = invItemList:GetItemByGuid(guid)
            local itemobj = GetIES(invItem:GetObject())
            local iesid = invItem:GetIESID()

            if tostring(itemobj.ClassID) == tostring(KlaipeID) and g.settings.map == tostring("c_Klaipe") and
                tostring(mapname) ~= g.settings.map then

                session.ResetItemList()
                TRY_TO_USE_WARP_ITEM(invItem, itemobj)
                INV_ICON_USE(invItem)
                g.warp = 1
                -- LETS_GO_HOME_CHANNEL_CHANGE()
                -- break
                return

            elseif tostring(itemobj.ClassID) == tostring(OrshaID) and g.settings.map == tostring("c_orsha") and
                tostring(mapname) ~= g.settings.map then

                session.ResetItemList()
                TRY_TO_USE_WARP_ITEM(invItem, itemobj)
                INV_ICON_USE(invItem)
                g.warp = 1
                -- break
                return

            elseif tostring(itemobj.ClassID) == tostring(FedimianID) and g.settings.map == tostring("c_fedimian") and
                tostring(mapname) ~= g.settings.map then

                session.ResetItemList()
                TRY_TO_USE_WARP_ITEM(invItem, itemobj)
                INV_ICON_USE(invItem)
                g.warp = 1
                -- break
                return

            end

        end
    end

end

function LETS_GO_HOME_TOKENWARP_CD_FRAME()
    -- CHAT_SYSTEM("cd0")
    local cdframe = ui.CreateNewFrame("notice_on_pc", "cdframe", 0, 0, 0, 0)
    AUTO_CAST(cdframe)
    cdframe:Resize(90, 30)
    cdframe:SetPos(1610, 335)
    cdframe:SetTitleBarSkin("None")
    cdframe:SetSkinName("None")
    local cdtext = cdframe:CreateOrGetControl('richtext', 'cdtext', 5, 5)
    AUTO_CAST(cdtext)
    cdframe:RunUpdateScript("LETS_GO_HOME_UPDATE_FRAME", 1.0)
    -- addon:RegisterMsg("FPS_UPDATE", "LETS_GO_HOME_UPDATE_FRAME")

    -- 
    cdframe:ShowWindow(1)

end

function LETS_GO_HOME_UPDATE_FRAME(cdframe)
    -- local cdframe = ui.GetFrame("cdframe")
    local cdtext = GET_CHILD_RECURSIVELY(cdframe, 'cdtext')
    local cd = GET_TOKEN_WARP_COOLDOWN()
    local cdtimer = string.format('{#FFFFFF}{ol}%03d', cd)
    cdtext:SetText("{#FFFFFF}{ol}twcd:" .. cdtimer)

    if cd > 0 then
        cdframe:ShowWindow(1)
        return 1
    else
        cdframe:ShowWindow(0)
        -- CHAT_SYSTEM("cd0")
        return 0
    end

end

function LETS_GO_HOME_TOKENWARP(_, _, className, _)
    movie.InteWarp(session.GetMyHandle(), string.format("/intewarpByToken %s", className))
    packet.ClientDirect("InteWarp")
    g.warp = 1

    WORLDMAP2_CLOSE()

end

function LETS_GO_HOME_WARP(_, _, className, _)

    local Scroll_Warp_Klaipe = session.GetInvItemByType(640073)
    local Scroll_Warp_Orsha = session.GetInvItemByType(640156)
    local Scroll_Warp_Fedimian = session.GetInvItemByType(640182)

    local KlaipeID = 640073
    local OrshaID = 640156
    local FedimianID = 640182

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    local mapname = mapCls.ClassName

    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList();
    local cnt = guidList:Count();

    local channelnum = session.loginInfo.GetChannel() + 1;

    if g.settings.map == nil then
        ui.MsgBox("[LGH]Not setting")
        return
    end

    if g.settings.ch == channelnum and g.settings.map == mapname then
        return
    end

    if g.settings.ch ~= channelnum and g.settings.map == mapname then

        LETS_GO_HOME_CHANNEL_CHANGE()
        return

    end

    if g.settings.map == "c_Klaipe" then
        LETS_GO_HOME_QUESTWARP(91055)
    elseif g.settings.map == "c_orsha" then
        LETS_GO_HOME_QUESTWARP(90170)
    elseif g.settings.map == "c_fedimian" then
        LETS_GO_HOME_QUESTWARP(72159)
    end
    --[[
    local cd = GET_TOKEN_WARP_COOLDOWN()
    if cd == 0 then
        LETS_GO_HOME_TOKENWARP(_, _, className, _)

    else
        for i = 0, cnt - 1 do
            local guid = guidList:Get(i);
            local invItem = invItemList:GetItemByGuid(guid)
            local itemobj = GetIES(invItem:GetObject())
            local iesid = invItem:GetIESID()

            if tostring(itemobj.ClassID) == tostring(KlaipeID) and g.settings.map == tostring("c_Klaipe") and
                tostring(mapname) ~= g.settings.map then

                session.ResetItemList()
                TRY_TO_USE_WARP_ITEM(invItem, itemobj)
                INV_ICON_USE(invItem)
                g.warp = 1
                -- LETS_GO_HOME_CHANNEL_CHANGE()
                -- break
                return

            elseif tostring(itemobj.ClassID) == tostring(OrshaID) and g.settings.map == tostring("c_orsha") and
                tostring(mapname) ~= g.settings.map then

                session.ResetItemList()
                TRY_TO_USE_WARP_ITEM(invItem, itemobj)
                INV_ICON_USE(invItem)
                g.warp = 1
                -- break
                return

            elseif tostring(itemobj.ClassID) == tostring(FedimianID) and g.settings.map == tostring("c_fedimian") and
                tostring(mapname) ~= g.settings.map then

                session.ResetItemList()
                TRY_TO_USE_WARP_ITEM(invItem, itemobj)
                INV_ICON_USE(invItem)
                g.warp = 1
                -- break
                return

            end

        end
    end
    ]]

end

function LETS_GO_HOME_CHANNEL_CHANGE()
    local channelnum = session.loginInfo.GetChannel() + 1;
    -- CHAT_SYSTEM(channelnum)
    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    local mapname = mapCls.ClassName

    if g.settings.ch ~= channelnum and g.settings.map == mapname then
        RUN_GAMEEXIT_TIMER("Channel", g.settings.ch - 1);
        g.warp = 0
    else
        g.warp = 0
    end
end

function LETS_GO_HOME_SETTING()

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        local msg = "Do you want your current map and channel to be your home town?"
        local yes_scp = "LETS_GO_HOME_SETTING_REG()"
        -- local no_scp = "ANCIENT_SETTING_CANCEL()"
        ui.MsgBox(msg, yes_scp, "None");
    else
        ui.SysMsg("[LGH]This is an area that cannot be set up.")
    end

end

function LETS_GO_HOME_SETTING_REG()
    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    local mapname = mapCls.ClassName
    g.settings.map = mapname
    local channelID = 0 -- 0が1chらしい
    local channelnum = session.loginInfo.GetChannel() + 1;
    g.settings.ch = channelnum
    LETS_GO_HOME_SAVE_SETTINGS()
    return
end

function LETS_GO_HOME_SAVE_SETTINGS()

    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function LETS_GO_HOME_LOAD_SETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not settings then
        settings = g.settings
    end

    g.settings = settings

end
