local addonName = "GUILDEVENTWARP"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")

g.SettingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

-- GUILDEVENTWARP_CH_CHANGE()

function GUILDEVENTWARP_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    CHAT_SYSTEM(addonNameLower .. " loaded")

    GUILDEVENTWARP_FRAME_INIT()
    -- GUILDEVENTWARP_CH_CHANGE()
end

function GUILDEVENTWARP_FRAME_INIT()

    local gewframe = ui.GetFrame('guildeventwarp')
    gewframe:SetSkinName('None')
    gewframe:Resize(95, 30)
    gewframe:SetPos(1790, 5)
    gewframe:SetTitleBarSkin("None")
    -- ボルタボタン
    local borutabutton = gewframe:CreateOrGetControl('button', 'boruta', 0, 0, 30, 30)
    borutabutton:SetSkinName("test_red_button")
    borutabutton:SetText("{img emoticon_0007 29 29}")
    borutabutton:SetEventScript(ui.LBUTTONUP, "GUILDEVENTWARP_ON_BORUTA_CLICK")

    -- ギルティネボタン
    local giltinebutton = gewframe:CreateOrGetControl('button', 'giltine', 35, 0, 30, 30)
    giltinebutton:SetSkinName("test_red_button")
    giltinebutton:SetText("Gi")
    giltinebutton:SetEventScript(ui.LBUTTONUP, "GUILDEVENTWARP_ON_GILTINE_CLICK")

    -- バウバスボタン
    local baubasbutton = gewframe:CreateOrGetControl('button', 'baubas', 65, 0, 30, 30)
    baubasbutton:SetSkinName("test_red_button")
    baubasbutton:SetText("Ba")
    baubasbutton:SetEventScript(ui.LBUTTONUP, "GUILDEVENTWARP_ON_BAUBAS_CLICK")
    --[[
    -- バウバスボタン
    local baubasbutton = gewframe:CreateOrGetControl('button', 'baubas', 65, 0, 30, 30)
    baubasbutton:SetSkinName("test_red_button")
    baubasbutton:SetText("Ba")
    baubasbutton:SetEventScript(ui.LBUTTONUP, "GUILDEVENTWARP_ON_BAUBAS_CLICK")
]]
    gewframe:ShowWindow(1)
end

function GUILDEVENTWARP_ON_BORUTA_CLICK(gewframe)
    -- CHAT_SYSTEM("ボルタボタンがクリックされました")
    local channelnum = session.loginInfo.GetChannel() + 1;
    if channelnum ~= 1 then
        GUILDEVENTWARP_CH_CHANGE()
    else
        local indunCls = GetClass('GuildEvent', 'GM_BorutosKapas_1');

        if indunCls ~= nil then
            -- gewframe:ShowWindow(0)
            local indunClsID = TryGetProp(indunCls, 'ClassID', 0);
            _BORUTA_ZONE_MOVE_CLICK(indunClsID)
        end
    end
end

function GUILDEVENTWARP_ON_GILTINE_CLICK(gewframe)
    -- CHAT_SYSTEM("ギルティネボタンがクリックされました")
    local channelnum = session.loginInfo.GetChannel() + 1;
    if channelnum ~= 1 then
        GUILDEVENTWARP_CH_CHANGE()
    else
        local indunCls = GetClass('GuildEvent', 'GM_Giltine_1');

        if indunCls ~= nil then
            -- gewframe:ShowWindow(0)
            local indunClsID = TryGetProp(indunCls, 'ClassID', 0);
            _BORUTA_ZONE_MOVE_CLICK(indunClsID)
        end
    end
end

function GUILDEVENTWARP_ON_BAUBAS_CLICK(gewframe)
    -- CHAT_SYSTEM("バウバスボタンがクリックされました")
    local channelnum = session.loginInfo.GetChannel() + 1;
    if channelnum ~= 1 then
        GUILDEVENTWARP_CH_CHANGE()
    else
        local indunCls = GetClass('GuildEvent', 'GM_Baubas_1');

        if indunCls ~= nil then
            -- gewframe:ShowWindow(0)
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

