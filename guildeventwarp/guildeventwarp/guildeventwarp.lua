-- v1.0.1 1chが満員の場合にエラーになるのでギルドイベント地域に飛んでからチャンネルチェンジ
-- v1.0.2 23.09.05patch対応。ボルタからドラグーンに変更
-- v1.0.3 TPショップ開くと消えるのを修正
-- v1.0.4 UI気に食わなかったので修正
local addonName = "GUILDEVENTWARP"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.3"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")
local base = {}

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName];
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

g.SettingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.ctrl = 0

function GUILDEVENTWARP_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    local frame = ui.GetFrame('guildeventwarp')
    frame:SetSkinName('None')
    frame:Resize(100, 30)
    frame:SetPos(1785, 4)
    frame:SetTitleBarSkin("None")

    GUILDEVENTWARP_FRAME_INIT(frame)

    -- g.SetupHook(GUILDEVENTWARP_BORUTA_ZONE_MOVE_CLICK, "BORUTA_ZONE_MOVE_CLICK")
    -- CHAT_SYSTEM(addonNameLower .. " loaded")

    if g.ctrl == 1 then

        g.ctrl = 0
        addon:RegisterMsg("GAME_START_3SEC", "GUILDEVENTWARP_CH_CHANGE")
        -- GUILDEVENTWARP_ON_BORUTA_CLICK(frame)
    else
        g.ctrl = 0
        return;
    end

end

function GUILDEVENTWARP_BORUTA_ZONE_MOVE_CLICK(parent, ctrl)

    -- local indunClsID = ctrl:GetUserValue('MOVE_INDUN_CLASSID');
    -- CHAT_SYSTEM(tostring(indunClsID.ClassName))
    -- print(tostring(indunClsID))
    _BORUTA_ZONE_MOVE_CLICK("500")
    -- ui.MsgBox(ClMsg('Auto_JiyeogeuLo{nl}_iDongHaSiKessSeupNiKka?'), '_BORUTA_ZONE_MOVE_CLICK(' .. indunClsID .. ')',
    --     'None')
end

function GUILDEVENTWARP_ON_DRAGOON_CLICK()
    g.ctrl = 1
    _BORUTA_ZONE_MOVE_CLICK("500")
end

function GUILDEVENTWARP_FRAME_INIT(frame)

    -- ボルタボタン
    --[[local borutabutton = frame:CreateOrGetControl('button', 'boruta', 5, 0, 30, 30)
    AUTO_CAST(borutabutton)
    borutabutton:SetSkinName("test_red_button")
    borutabutton:SetText("D")
    borutabutton:SetEventScript(ui.LBUTTONUP, "GUILDEVENTWARP_ON_DRAGOON_CLICK")
    borutabutton:SetTextTooltip("{@st59}Guild events, move to the Dragoon map.{nl}" ..
                                    "{@st59}ギルドイベント、ドラグーンのマップに移動します。{/}")]]
    frame:RemoveAllChild()

    local dragoon_slot = frame:CreateOrGetControl("slot", "dragoon_slot", 0, 0, 28, 28)
    AUTO_CAST(dragoon_slot)
    dragoon_slot:EnablePop(0)
    dragoon_slot:EnableDrop(0)
    dragoon_slot:EnableDrag(0)
    dragoon_slot:SetEventScript(ui.LBUTTONUP, "GUILDEVENTWARP_ON_DRAGOON_CLICK")
    local dragoon_monCls = GetClass("Monster", "guild_boss_dragoon_ex")
    local dragoon_icon = CreateIcon(dragoon_slot);
    AUTO_CAST(dragoon_icon)
    dragoon_icon:SetImage(dragoon_monCls.Icon)
    dragoon_icon:SetTextTooltip("{@st59}Guild events, move to the Dragoon map.{nl}" ..
                                    "{@st59}ギルドイベント、ドラグーンのマップに移動します。{/}")
    -- SET_SLOT_IMG(dragoon_slot, dragoon_monCls.Icon);

    --[[local monClsName = 'boss_dragoon_ex'
    local monCls = GetClass("Monster", monClsName)
    borutabutton:SetImage(monCls.Icon)
    CHAT_SYSTEM("test")
    borutabutton:SetEventScript(ui.LBUTTONUP, "GUILDEVENTWARP_ON_DRAGOON_CLICK")]]

    -- ギルティネボタン
    --[[local giltinebutton = frame:CreateOrGetControl('button', 'giltine', 35, 0, 30, 30)
    giltinebutton:SetSkinName("test_red_button")
    giltinebutton:SetText("G")
    giltinebutton:SetEventScript(ui.LBUTTONUP, "GUILDEVENTWARP_ON_GILTINE_CLICK")
    giltinebutton:SetTextTooltip("{@st59}Guild events, move to the Guiltine map.{nl}" ..
                                     "{@st59}ギルドイベント、ギルティネのマップに移動します。{/}")]]

    local giltine_slot = frame:CreateOrGetControl("slot", "giltine_slot", 35, 0, 28, 28)
    AUTO_CAST(giltine_slot)
    giltine_slot:EnablePop(0)
    giltine_slot:EnableDrop(0)
    giltine_slot:EnableDrag(0)
    giltine_slot:SetEventScript(ui.LBUTTONUP, "GUILDEVENTWARP_ON_GILTINE_CLICK")

    local giltine_monCls = GetClass("Monster", "Legend_Boss_Giltine_Guild")
    local giltine_icon = CreateIcon(giltine_slot);
    AUTO_CAST(giltine_icon)
    giltine_icon:SetImage(giltine_monCls.Icon)
    giltine_icon:SetTextTooltip("{@st59}Guild events, move to the Guiltine map.{nl}" ..
                                    "{@st59}ギルドイベント、ギルティネのマップに移動します。{/}")
    -- SET_SLOT_IMG(giltine_slot, giltine_monCls.Icon);

    -- バウバスボタン
    --[[local baubasbutton = frame:CreateOrGetControl('button', 'baubas', 65, 0, 30, 30)
    baubasbutton:SetSkinName("test_red_button")
    baubasbutton:SetText("B")
    baubasbutton:SetEventScript(ui.LBUTTONUP, "GUILDEVENTWARP_ON_BAUBAS_CLICK")
    baubasbutton:SetTextTooltip("{@st59}Guild event, move to the Baubus map.{nl}" ..
                                    "{@st59}ギルドイベント、バウバスのマップに移動します。{/}")]]

    local baubas_slot = frame:CreateOrGetControl("slot", "baubas_slot", 70, 0, 28, 28)
    AUTO_CAST(baubas_slot)
    baubas_slot:EnablePop(0)
    baubas_slot:EnableDrop(0)
    baubas_slot:EnableDrag(0)
    baubas_slot:SetEventScript(ui.LBUTTONUP, "GUILDEVENTWARP_ON_BAUBAS_CLICK")

    local baubas_monCls = GetClass("Monster", "GuildEvent_npc_baubas2")
    local baubas_icon = CreateIcon(baubas_slot);
    AUTO_CAST(baubas_icon)
    baubas_icon:SetImage(baubas_monCls.Icon)
    baubas_icon:SetTextTooltip("{@st59}Guild event, move to the Baubus map.{nl}" ..
                                   "{@st59}ギルドイベント、バウバスのマップに移動します。{/}")
    -- SET_SLOT_IMG(baubas_slot, baubas_monCls.Icon);

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

