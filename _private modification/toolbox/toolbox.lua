-- dofile("../data/addon_d/toolbox/toolbox.lua");
local addonName = "TOOLBOX"
local author = "Micho"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
g.settings = {
    x = 600,
    y = 50,
    mini = 0,
    isclose = 0
};
local settingsFileLoc = string.format("%s/settings.json", string.lower(addonName));
-- local RList = { Moring = 522, Witch = 620, Giltine = 628, Vasilisa = 655,Delmore=665,Jellyzele=670};
local acutil = require('acutil');

function TOOLBOX_LOAD()
    local t, err = acutil.loadJSONX(settingsFileLoc);
    if not err then
        g.settings = t;
    end
end

function TOOLBOX_ON_INIT(addon, frame)
    TOOLBOX_LOAD();
    TOOLBOX_OPENFRAME();
    addon:RegisterMsg('FPS_UPDATE', 'TOOLBOX_OPENFRAME')
    frame:SetEventScript(ui.LBUTTONUP, "TOOLBOX_MOVEFRAME");
    acutil.slashCommand("/tb", TOOLBOX_CMD);
    acutil.slashCommand("/TB", ATOOLBOX_CMD);
end

function TOOLBOX_CMD(command)
    local cmd = "";
    if #command > 0 then
        cmd = table.remove(command, 1);
    else
        g.settings.isclose = 0;
        acutil.saveJSONX(settingsFileLoc, g.settings);
        TOOLBOX_OPENFRAME();
        return
    end
end

function TOOLBOX_WARP(id)
    local pc = GetMyPCObject();

    if session.world.IsIntegrateServer() == true or IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return
    end

end

function TOOLBOX_OPENFRAME()
    local frame = ui.GetFrame("toolbox");
    local tbutton = frame:CreateOrGetControl('button', 'close', 88, 2, 24, 24);
    --	tbutton = frame:CreateOrGetControl('button', 'help', 111, 2, 24, 24);
    tbutton = frame:CreateOrGetControl('button', 'minimize', 135, 2, 24, 24);
    if g.settings.isclose == 1 then
        frame:ShowWindow(0);
        return
    else
        frame:ShowWindow(1);
    end
    if g.settings.mini == 1 then
        frame:Resize(160, 32);
        frame:SetOffset(g.settings.x, g.settings.y);
        return
    else
        frame:Resize(160, 460 + 31);
    end
    frame:SetOffset(g.settings.x, g.settings.y);
    local i = 0;
    local aObj = GetMyAccountObj()
    local pc = GetMyPCObject()
    -- 銀幣
    local silver_group = frame:CreateOrGetControl('groupbox', 'silver_group', 5, (36 + i * 31), 150, 30);
    silver_group:SetSkinName('systemmenu_vertical');
    local silver_title = silver_group:CreateOrGetControl('richtext', 'silver_title', 5, 3, 95, 30);
    silver_title:SetText("{ol}{img icon_item_silver 26 26} " .. "");
    local silver_content = silver_group:CreateOrGetControl('richtext', 'silver_content', 40, 6, 41, 30);
    silver_content:SetText("{ol}" .. formatNumber(GET_TOTAL_MONEY_STR()));
    i = i + 1;
    -- 傭兵
    local PVP1_group = frame:CreateOrGetControl('groupbox', 'PVP1_group', 5, (36 + i * 31), 150, 30);
    PVP1_group:SetSkinName('systemmenu_vertical');
    local PVP1_title = PVP1_group:CreateOrGetControl('richtext', 'PVP1_title', 5, 2, 95, 30);
    PVP1_title:SetText("{ol}{img icon_item_pvpmine_2 28 27} " .. "");
    PVP1_title:SetEventScript(ui.LBUTTONUP, "REQ_PVP_MINE_SHOP_OPEN");
    local PVP1_content = PVP1_group:CreateOrGetControl('richtext', 'PVP1_content', 40, 6, 41, 30);
    PVP1_content:SetText("{ol}" .. formatNumber(TryGetProp(aObj, "MISC_PVP_MINE2", "0")));
    i = i + 1;
    -- 加比婭
    local Gabi1_group = frame:CreateOrGetControl('groupbox', 'Gabi1_group', 5, (36 + i * 31), 150, 30);
    Gabi1_group:SetSkinName('systemmenu_vertical');
    local Gabi1_title = Gabi1_group:CreateOrGetControl('richtext', 'Gabi1_title', 5, 2, 95, 30);
    Gabi1_title:SetText("{ol}{img icon_item_season_coin_gabia 26 26} " .. "");
    Gabi1_title:SetEventScript(ui.LBUTTONUP, "REQ_GabijaCertificate_SHOP_OPEN");
    local Gabi1_content = Gabi1_group:CreateOrGetControl('richtext', 'Gabi1_content', 40, 6, 41, 30);
    Gabi1_content:SetText("{ol}" .. formatNumber(TryGetProp(aObj, "GabijaCertificate", "0")));
    i = i + 1;
    -- 瓦卡麗涅
    local Vaka1_group = frame:CreateOrGetControl('groupbox', 'Vaka1_group', 5, (36 + i * 31), 150, 30);
    Vaka1_group:SetSkinName('systemmenu_vertical');
    local Vaka1_title = Vaka1_group:CreateOrGetControl('richtext', 'Vaka1_title', 5, 2, 95, 30);
    Vaka1_title:SetText("{ol}{img icon_item_season_coin_vakarine 26 26} " .. "");
    Vaka1_title:SetEventScript(ui.LBUTTONUP, "REQ_VakarineCertificate_SHOP_OPEN");
    local Vaka1_content = Vaka1_group:CreateOrGetControl('richtext', 'Vaka1_content', 40, 6, 41, 30);
    Vaka1_content:SetText("{ol}" .. formatNumber(TryGetProp(aObj, "VakarineCertificate", "0")));
    i = i + 1;
    -- 拉達
    local Rada1_group = frame:CreateOrGetControl('groupbox', 'Rada1_group', 5, (36 + i * 31), 150, 30);
    Rada1_group:SetSkinName('systemmenu_vertical');
    local Rada1_title = Rada1_group:CreateOrGetControl('richtext', 'Rada1_title', 5, 2, 95, 30);
    Rada1_title:SetText("{ol}{img icon_item_season_coin_Rada 26 26} " .. "");
    Rada1_title:SetEventScript(ui.LBUTTONUP, "REQ_RadaCertificate_SHOP_OPEN");
    local Rada1_content = Rada1_group:CreateOrGetControl('richtext', 'Rada1_content', 40, 6, 41, 30);
    Rada1_content:SetText("{ol}" .. formatNumber(TryGetProp(aObj, "RadaCertificate", "0")));
    i = i + 1;

    local Jurate1_group = frame:CreateOrGetControl('groupbox', 'Jurate1_group', 5, (36 + i * 31), 150, 30);
    Jurate1_group:SetSkinName('systemmenu_vertical');
    local Jurate1_title = Jurate1_group:CreateOrGetControl('richtext', 'Jurate1_title', 5, 2, 95, 30);
    Jurate1_title:SetText("{ol}{img icon_item_season_coin_Jurate 26 26} " .. "");
    Jurate1_title:SetEventScript(ui.LBUTTONUP, "REQ_JurateCertificate_SHOP_OPEN");
    local Jurate1_content = Jurate1_group:CreateOrGetControl('richtext', 'Jurate1_content', 40, 6, 41, 30);
    Jurate1_content:SetText("{ol}" .. formatNumber(TryGetProp(aObj, "JurateCertificate", "0")));
    i = i + 1;
    -- TOS鑄幣
    local TOS_group = frame:CreateOrGetControl('groupbox', 'TOS_group', 5, (36 + i * 31), 150, 30);
    TOS_group:SetSkinName('systemmenu_vertical');
    local TOS_title = TOS_group:CreateOrGetControl('richtext', 'TOS_title', 5, 3, 95, 30);
    TOS_title:SetText("{ol}{img icon_item_Tos_Event_Coin 26 26} " .. "");
    TOS_title:SetEventScript(ui.LBUTTONUP, "REQ_TOS_SHOP_OPEN");
    local TOS_content = TOS_group:CreateOrGetControl('richtext', 'TOS_content', 40, 6, 41, 30);
    TOS_content:SetText("{ol}" .. formatNumber(TryGetProp(aObj, "EVENT_TOS_WHOLE_TOTAL_COIN", "0")));
    i = i + 1;
    -- 綜合
    local Con_group = frame:CreateOrGetControl('groupbox', 'Con_group', 5, (36 + i * 31), 150, 30);
    Con_group:SetSkinName('systemmenu_vertical');
    local Con_title = Con_group:CreateOrGetControl('richtext', 'Con_title', 5, 2, 95, 30);
    Con_title:SetText("{ol}{img icon_item_silver_gacha_ticket 27 27} " .. "");
    Con_title:SetEventScript(ui.LBUTTONUP, "COLLECTION");
    local Con_content = Con_group:CreateOrGetControl('richtext', 'Con_content', 40, 6, 41, 30);
    Con_content:SetText("{ol}" .. formatNumber(TryGetProp(aObj, "CONTENTS_TOTAL_POINT", "0")));
    i = i + 1;
    -- 王國
    local RE_group = frame:CreateOrGetControl('groupbox', 'RE_group', 5, (36 + i * 31), 150, 30);
    RE_group:SetSkinName('systemmenu_vertical');
    local RE_title = RE_group:CreateOrGetControl('richtext', 'RE_title', 5, 3, 95, 30);
    RE_title:SetText("{ol}{img icon_item_reputation_coin_01 26 23} " .. "");
    RE_title:SetEventScript(ui.LBUTTONUP, "REPUTATION");
    local RE_content = RE_group:CreateOrGetControl('richtext', 'RE_content', 40, 6, 41, 30);
    RE_content:SetText("{ol}" .. formatNumber(TryGetProp(aObj, "REPUTATION_COIN_EP13", "0")));
    i = i + 1;
    -- TP
    local TP_group = frame:CreateOrGetControl('groupbox', 'TP_group', 5, (36 + i * 31), 150, 30);
    TP_group:SetSkinName('systemmenu_vertical');
    local TP_title = TP_group:CreateOrGetControl('richtext', 'TP_title', 5, 6, 95, 30);
    TP_title:SetText("{ol}{img icon_item_tpbox_100 20 20} " .. "");
    local TP_content = TP_group:CreateOrGetControl('richtext', 'TP_content', 40, 6, 41, 30);
    TP_content:SetText("{ol}" .. formatNumber(aObj.GiftMedal + aObj.PremiumMedal));
    i = i + 1;
    -- 活動TP
    local FTP_group = frame:CreateOrGetControl('groupbox', 'FTP_group', 5, (36 + i * 31), 150, 30);
    FTP_group:SetSkinName('systemmenu_vertical');
    local FTP_title = FTP_group:CreateOrGetControl('richtext', 'FTP_title', 5, 6, 95, 30);
    FTP_title:SetText("{ol}{img icon_item_tpbox_30 20 20} " .. "      (Free)");
    local FTP_content = FTP_group:CreateOrGetControl('richtext', 'FTP_content', 40, 6, 41, 30);
    FTP_content:SetText("{ol}" .. formatNumber(aObj.Medal));
    i = i + 1;
    -- 重量(%)
    local WE_group = frame:CreateOrGetControl('groupbox', 'WE_group', 5, (36 + i * 31), 150, 30);
    WE_group:SetSkinName('systemmenu_vertical');
    local WE_title = WE_group:CreateOrGetControl('richtext', 'WE_title', 5, 6, 95, 30);
    WE_title:SetText("{ol}{img icon_item_archeology_compass 20 20} " .. "");
    local WE_content = WE_group:CreateOrGetControl('richtext', 'WE_content', 40, 6, 41, 30);
    WE_content:SetText("{ol}" .. math.floor(pc.NowWeight * 100 / pc.MaxWeight) .. "%");
    i = i + 1;
    -- 裝備分數
    local WS_group = frame:CreateOrGetControl('groupbox', 'WS_group', 5, (36 + i * 31), 150, 30);
    WS_group:SetSkinName('systemmenu_vertical');
    local WS_title = WS_group:CreateOrGetControl('richtext', 'WS_title', 5, 3, 95, 30);
    WS_title:SetText("{ol}{img icon_item_upinis_iron_armor 25 25} " .. "");
    local WS_content = WS_group:CreateOrGetControl('richtext', 'WS_content', 40, 6, 41, 30);
    WS_content:SetText("{ol}" .. formatNumber(GET_PLAYER_GEAR_SCORE(pc)));
    i = i + 1;
    -- 米酒
    local WSSSS_group = frame:CreateOrGetControl('groupbox', 'WSSSS_group', 5, (36 + i * 31), 150, 30);
    WSSSS_group:SetSkinName('systemmenu_vertical');
    local WSSSS_title = WSSSS_group:CreateOrGetControl('richtext', 'WSSSS_title', 0, 1, 95, 30);
    WSSSS_title:SetText("        {ol}By Micho" .. " {ol}{img icon_item_helmet_afro_poporion 27 27}");
end

function TOOLBOX_MINIMIZE()
    local frame = ui.GetFrame('toolbox');

    if g.settings.mini == 0 then
        g.settings.mini = 1;
        TOOLBOX_OPENFRAME()
    else
        g.settings.mini = 0;
        TOOLBOX_OPENFRAME()
    end
    acutil.saveJSONX(settingsFileLoc, g.settings);
end

function TOOLBOX_CLOSEFRAME()
    local frame = ui.GetFrame('toolbox');
    g.settings.isclose = 1;
    frame:ShowWindow(0);
    acutil.saveJSONX(settingsFileLoc, g.settings);
end

function TOOLBOX_MOVEFRAME()
    local frame = ui.GetFrame("toolbox");
    g.settings.x = frame:GetX();
    g.settings.y = frame:GetY();
    acutil.saveJSONX(settingsFileLoc, g.settings);
end

function REQ_TOS_SHOP_OPEN()
    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'EVENT_TOS_WHOLE_SHOP');
    ui.OpenFrame('earthtowershop');
end

function COLLECTION()
    FullScreenMenuMoveNpc(" 飛雷神", "NO", "c_Klaipe/c_orsha", "COLLECTION_SHOP/ORSHA_COLLECTION_SHOP", "", "YES")
end

function REPUTATION()
    FullScreenMenuMoveNpc(" 飛雷神", "NO", "c_Klaipe/c_orsha/c_fedimian",
        "REPUTATION_QUEST_BOARD_01/EP13_WEEK_REPUTATION_01/REPUTATION_QUEST_BOARD_01", "", "YES")
end

function formatNumber(i)
    return tostring(i):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end
