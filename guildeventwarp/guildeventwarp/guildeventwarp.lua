-- ｖ1.0.1--1chが満員の場合にエラーになるのでギルドイベント地域に飛んでからチャンネルチェンジ
local addonName = "GUILDEVENTWARP"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")

g.SettingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.ctrl = 0

function GUILDEVENTWARP_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    local frame = ui.GetFrame('guildeventwarp')
    frame:SetSkinName('None')
    frame:Resize(95, 30)
    frame:SetPos(1790, 5)
    frame:SetTitleBarSkin("None")

    GUILDEVENTWARP_FRAME_INIT(frame)

    CHAT_SYSTEM(addonNameLower .. " loaded")

    if g.ctrl == 1 then

        g.ctrl = 0
        addon:RegisterMsg("GAME_START_3SEC", "GUILDEVENTWARP_CH_CHANGE")
        -- GUILDEVENTWARP_ON_BORUTA_CLICK(frame)
    else
        g.ctrl = 0
        return;
    end

end

function GUILDEVENTWARP_FRAME_INIT(frame)

    -- ボルタボタン
    local borutabutton = frame:CreateOrGetControl('button', 'boruta', 0, 0, 30, 30)
    borutabutton:SetSkinName("test_red_button")
    borutabutton:SetText("{img emoticon_0007 29 29}")
    borutabutton:SetEventScript(ui.LBUTTONUP, "GUILDEVENTWARP_ON_BORUTA_CLICK")

    -- ギルティネボタン
    local giltinebutton = frame:CreateOrGetControl('button', 'giltine', 35, 0, 30, 30)
    giltinebutton:SetSkinName("test_red_button")
    giltinebutton:SetText("Gi")
    giltinebutton:SetEventScript(ui.LBUTTONUP, "GUILDEVENTWARP_ON_GILTINE_CLICK")

    -- バウバスボタン
    local baubasbutton = frame:CreateOrGetControl('button', 'baubas', 65, 0, 30, 30)
    baubasbutton:SetSkinName("test_red_button")
    baubasbutton:SetText("Ba")
    baubasbutton:SetEventScript(ui.LBUTTONUP, "GUILDEVENTWARP_ON_BAUBAS_CLICK")

    frame:ShowWindow(1)
end

function GUILDEVENTWARP_ON_BORUTA_CLICK(frame)
    -- CHAT_SYSTEM("ボルタボタンがクリックされました")

    g.ctrl = 1
    local indunCls = GetClass('GuildEvent', 'GM_BorutosKapas_1');

    if indunCls ~= nil then
        -- frame:ShowWindow(0)
        local indunClsID = TryGetProp(indunCls, 'ClassID', 0);
        _BORUTA_ZONE_MOVE_CLICK(indunClsID)
    end

end

function GUILDEVENTWARP_ON_GILTINE_CLICK(frame)
    -- CHAT_SYSTEM("ギルティネボタンがクリックされました")

    g.ctrl = 1
    local indunCls = GetClass('GuildEvent', 'GM_Giltine_1');

    if indunCls ~= nil then
        -- frame:ShowWindow(0)
        local indunClsID = TryGetProp(indunCls, 'ClassID', 0);
        _BORUTA_ZONE_MOVE_CLICK(indunClsID)
    end

end

function GUILDEVENTWARP_ON_BAUBAS_CLICK(frame)
    -- CHAT_SYSTEM("バウバスボタンがクリックされました")

    g.ctrl = 1
    local indunCls = GetClass('GuildEvent', 'GM_Baubas_1');

    if indunCls ~= nil then
        -- frame:ShowWindow(0)
        local indunClsID = TryGetProp(indunCls, 'ClassID', 0);
        _BORUTA_ZONE_MOVE_CLICK(indunClsID)
    end

end

function GUILDEVENTWARP_CH_CHANGE()
    local channelID = 0 -- 0が1chらしい
    local channelnum = session.loginInfo.GetChannel() + 1;
    if channelnum ~= 1 then
        -- CHAT_SYSTEM(channelnum)
        RUN_GAMEEXIT_TIMER("Channel", channelID);
    end
end

--[[v1.0.0のコード
function GUILDEVENTWARP_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    local frame = ui.GetFrame('guildeventwarp')
    frame:SetSkinName('None')
    frame:Resize(95, 30)
    frame:SetPos(1790, 5)
    frame:SetTitleBarSkin("None")

    GUILDEVENTWARP_FRAME_INIT(frame)

    CHAT_SYSTEM(addonNameLower .. " loaded")

    if g.ctrl == 1 then

        g.ctrl = 0
        addon:RegisterMsg("GAME_START_3SEC", "GUILDEVENTWARP_ON_BORUTA_CLICK")
        GUILDEVENTWARP_ON_BORUTA_CLICK(frame)

    elseif g.ctrl == 2 then

        g.ctrl = 0
        addon:RegisterMsg("GAME_START_3SEC", "GUILDEVENTWARP_ON_GILTINE_CLICK")
        GUILDEVENTWARP_ON_GILTINE_CLICK(frame)

    elseif g.ctrl == 3 then

        g.ctrl = 0
        addon:RegisterMsg("GAME_START_3SEC", "GUILDEVENTWARP_ON_BAUBAS_CLICK")
        GUILDEVENTWARP_ON_BAUBAS_CLICK(frame)

    end

end

function GUILDEVENTWARP_FRAME_INIT(frame)

    -- ボルタボタン
    local borutabutton = frame:CreateOrGetControl('button', 'boruta', 0, 0, 30, 30)
    borutabutton:SetSkinName("test_red_button")
    borutabutton:SetText("{img emoticon_0007 29 29}")
    borutabutton:SetEventScript(ui.LBUTTONUP, "GUILDEVENTWARP_ON_BORUTA_CLICK")

    -- ギルティネボタン
    local giltinebutton = frame:CreateOrGetControl('button', 'giltine', 35, 0, 30, 30)
    giltinebutton:SetSkinName("test_red_button")
    giltinebutton:SetText("Gi")
    giltinebutton:SetEventScript(ui.LBUTTONUP, "GUILDEVENTWARP_ON_GILTINE_CLICK")

    -- バウバスボタン
    local baubasbutton = frame:CreateOrGetControl('button', 'baubas', 65, 0, 30, 30)
    baubasbutton:SetSkinName("test_red_button")
    baubasbutton:SetText("Ba")
    baubasbutton:SetEventScript(ui.LBUTTONUP, "GUILDEVENTWARP_ON_BAUBAS_CLICK")

    frame:ShowWindow(1)
end

function GUILDEVENTWARP_ON_BORUTA_CLICK(frame)
    -- CHAT_SYSTEM("ボルタボタンがクリックされました")

    local channelnum = session.loginInfo.GetChannel() + 1;
    if channelnum ~= 1 then
        g.ctrl = 1
        GUILDEVENTWARP_CH_CHANGE()
    else
        g.ctrl = 0
        local indunCls = GetClass('GuildEvent', 'GM_BorutosKapas_1');

        if indunCls ~= nil then
            -- frame:ShowWindow(0)
            local indunClsID = TryGetProp(indunCls, 'ClassID', 0);
            _BORUTA_ZONE_MOVE_CLICK(indunClsID)
        end
    end
end

function GUILDEVENTWARP_ON_GILTINE_CLICK(frame)
    -- CHAT_SYSTEM("ギルティネボタンがクリックされました")
    local channelnum = session.loginInfo.GetChannel() + 1;
    if channelnum ~= 1 then
        g.ctrl = 2
        GUILDEVENTWARP_CH_CHANGE()
    else
        g.ctrl = 0
        local indunCls = GetClass('GuildEvent', 'GM_Giltine_1');

        if indunCls ~= nil then
            -- frame:ShowWindow(0)
            local indunClsID = TryGetProp(indunCls, 'ClassID', 0);
            _BORUTA_ZONE_MOVE_CLICK(indunClsID)
        end
    end
end

function GUILDEVENTWARP_ON_BAUBAS_CLICK(frame)
    -- CHAT_SYSTEM("バウバスボタンがクリックされました")
    local channelnum = session.loginInfo.GetChannel() + 1;
    if channelnum ~= 1 then
        g.ctrl = 3
        GUILDEVENTWARP_CH_CHANGE()
    else
        g.ctrl = 0
        local indunCls = GetClass('GuildEvent', 'GM_Baubas_1');

        if indunCls ~= nil then
            -- frame:ShowWindow(0)
            local indunClsID = TryGetProp(indunCls, 'ClassID', 0);
            _BORUTA_ZONE_MOVE_CLICK(indunClsID)
        end
    end
end

function GUILDEVENTWARP_CH_CHANGE()
    local channelID = 0 -- 0が1chらしい
    local channelnum = session.loginInfo.GetChannel() + 1;
    if channelnum ~= 1 then
        -- CHAT_SYSTEM(channelnum)
        RUN_GAMEEXIT_TIMER("Channel", channelID);
    end
end
]]

