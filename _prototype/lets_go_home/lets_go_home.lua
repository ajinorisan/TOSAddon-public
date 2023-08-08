local addonName = "LETS_GO_HOME"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

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

    session.ResetItemList()

    local frame = ui.GetFrame("lets_go_home")
    frame:SetSkinName('None')
    frame:Resize(30, 30)
    frame:SetPos(1610, 305)
    frame:SetTitleBarSkin("None")

    local btn = frame:CreateOrGetControl('button', 'home', 0, 0, 30, 30)
    btn:SetSkinName("None")
    btn:SetText("{img btn_housing_editmode_small_resize 30 30}")
    btn:SetTextTooltip("{@st59}RightButton:Setting LeftButton:Warp{/}")
    btn:SetEventScript(ui.RBUTTONUP, "LETS_GO_HOME_SETTING")
    -- btn:SetEventScript(ui.LBUTTONUP, "LETS_GO_HOME_WARP")
    btn:SetEventScript(ui.LBUTTONDOWN, "LETS_GO_HOME_WARP")
    frame:ShowWindow(1)

    LETS_GO_HOME_LOAD_SETTINGS()

end

function LETS_GO_HOME_WARP()

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
            -- break
            return
        elseif tostring(itemobj.ClassID) == tostring(OrshaID) and g.settings.map == tostring("c_orsha") and
            tostring(mapname) ~= g.settings.map then

            session.ResetItemList()
            TRY_TO_USE_WARP_ITEM(invItem, itemobj)
            INV_ICON_USE(invItem)
            -- break
            return

        elseif tostring(itemobj.ClassID) == tostring(FedimianID) and g.settings.map == tostring("c_fedimian") and
            tostring(mapname) ~= g.settings.map then

            session.ResetItemList()
            TRY_TO_USE_WARP_ITEM(invItem, itemobj)
            INV_ICON_USE(invItem)
            -- break
            return
        else
            LETS_GO_HOME_CHANNEL_CHANGE()
            return
        end
        -- 
    end
    --[[
    if g.settings.map == tostring("c_Klaipe") and tostring(mapname) ~= g.settings.map then
        CHAT_SYSTEM("a")
        if Scroll_Warp_Klaipe ~= nil then
            -- for i = 0, cnt - 1 do
            CHAT_SYSTEM("Scroll_Warp_Klaipe aru")
            local invItem = session.GetInvItem(640073);
            INV_ICON_USE(invItem) -- break
            -- end
            -- return
        else
            CHAT_SYSTEM("Scroll_Warp_Klaipe Have Not Item")
            ui.SysMsg("Scroll_Warp_Klaipe Have Not Item")
        end
    elseif g.settings.map == tostring("c_orsha") and tostring(mapname) ~= g.settings.map then
        CHAT_SYSTEM("i")
        if Scroll_Warp_Orsha ~= nil then
            INV_ICON_USE(OrshaID)
            session.ResetItemList()
        else
            CHAT_SYSTEM("Scroll_Warp_Orsha Have Not Item")
            ui.SysMsg("Scroll_Warp_Orsha Have Not Item")
        end
    elseif g.settings.map == tostring("c_fedimian") and tostring(mapname) ~= g.settings.map then
        CHAT_SYSTEM("u")
        if Scroll_Warp_Fedimian ~= nil then
            INV_ICON_USE(FedimianID)
            session.ResetItemList()
        else
            CHAT_SYSTEM("Scroll_Warp_Fedimian Have Not Item")
            ui.SysMsg("Scroll_Warp_Fedimian Have Not Item")
        end
    else
        -- LETS_GO_HOME_CHANNEL_CHANGE()
        return
    end
]]
end

function LETS_GO_HOME_CHANNEL_CHANGE()
    RUN_GAMEEXIT_TIMER("Channel", g.settings.ch - 1);
end

function LETS_GO_HOME_SETTING()
    local msg = "Do you want your current map and channel to be your home town?"
    local yes_scp = "LETS_GO_HOME_SETTING_REG()"
    -- local no_scp = "ANCIENT_SETTING_CANCEL()"
    ui.MsgBox(msg, yes_scp, "None");

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
