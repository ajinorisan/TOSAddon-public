local addonName = "indun_panel"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")

g.settings = {
    ischecked = 0
}
--[[
local tickettbl = {
    challenge = "PVP_MINE_40",
    expertday = "PVP_MINE_41",
    expertweek = "PVP_MINE_42"

}
]]
function indun_panel_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function indun_panel_load_settings()

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

function INDUN_PANEL_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.framename = addonName
    CHAT_SYSTEM(addonNameLower .. " loaded")
    indun_panel_load_settings()

    -- acutil.setupHook(INDUN_PANEL_REQ_RAID_AUTO_UI_OPEN, "REQ_RAID_AUTO_UI_OPEN")
    -- acutil.setupHook(INDUN_PANEL_INDUNENTER_ENTER, "INDUNENTER_ENTER")
    -- acutil.setupHook(INDUN_PANEL_INDUNINFO_SET_BUTTONS, "INDUNINFO_SET_BUTTONS")

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        indun_panel_frame_init()
        -- indun_panel_init()
    end
    -- indun_panel_get_chllengerecipe_trade_count()
end

function INDUN_PANEL_INDUNINFO_SET_BUTTONS(indunType)

    local frame = ui.GetFrame("indun_panel")
    local indunCls = GetClassByType('Indun', indunType)
    local dungeonType = TryGetProp(indunCls, "DungeonType", "None");
    local btnInfoCls = GetClassByStrProp("IndunInfoButton", "DungeonType", dungeonType);

    if dungeonType == "Raid" then
        -- CHAT_SYSTEM("Raid")
        -- CHAT_SYSTEM(indunCls.SubType)

        btnInfoCls = INDUNINFO_SET_BUTTONS_FIND_CLASS(indunCls);

    end

    --[[ local auto_sweep_enable = TryGetProp(indunCls, "AutoSweepEnable", "None");
    local auto_sweep_btn_cls = INDUNINFO_SET_BUTTONS_FIND_AUTO_SWEEP_CLASS(indunCls);
    if auto_sweep_btn_cls ~= nil then
        btnInfoCls = auto_sweep_btn_cls;
    end]]

    local redButtonScp = TryGetProp(btnInfoCls, "RedButtonScp")
    local redButton -- 変数の宣言を条件分岐の外に移動

    if redButtonScp ~= 'None' then

        if indunType == 665 then
            redButton = GET_CHILD_RECURSIVELY(frame, "Delmorehard")
            redButton:SetUserValue('MOVE_INDUN_CLASSID', indunCls.ClassID);
            redButton:SetEventScript(ui.LBUTTONUP, redButtonScp)
            -- indun_panel_enter_Delmore_hard()
        elseif indunType == 670 then
            redButton = GET_CHILD_RECURSIVELY(frame, "jellyzelehard")
            redButton:SetUserValue('MOVE_INDUN_CLASSID', indunCls.ClassID);
            redButton:SetEventScript(ui.LBUTTONUP, redButtonScp)
        elseif indunType == 675 then
            redButton = GET_CHILD_RECURSIVELY(frame, "spreaderhard")
            redButton:SetUserValue('MOVE_INDUN_CLASSID', indunCls.ClassID);
            redButton:SetEventScript(ui.LBUTTONUP, redButtonScp)
        elseif indunType == 678 then
            redButton = GET_CHILD_RECURSIVELY(frame, "falohard")
            redButton:SetUserValue('MOVE_INDUN_CLASSID', indunCls.ClassID);
            redButton:SetEventScript(ui.LBUTTONUP, redButtonScp)
        elseif indunType == 681 then
            redButton = GET_CHILD_RECURSIVELY(frame, "rozehard")
            redButton:SetUserValue('MOVE_INDUN_CLASSID', indunCls.ClassID);
            redButton:SetEventScript(ui.LBUTTONUP, redButtonScp)
        else
            return;
        end

    end

    --[[
    if auto_sweep_enable == "YES" then
        SCR_OPEN_INDUNINFO_AUTOSWEEP(frame, indunCls.ClassID);
    else
        SCP_CLOSE_INDUNINFO_AUTOSWEEP(frame);
    end
    ]]
end
--[[
function INDUN_PANEL_INDUNENTER_ENTER(frame, ctrl)
    local topFrame = frame:GetTopParentFrame();
    local useCount = tonumber(topFrame:GetUserValue("multipleCount"));
    local indunType = topFrame:GetUserValue('INDUN_TYPE');
    local indunCls = GetClassByType('Indun', indunType);
    local indunMinPCRank = TryGetProp(indunCls, 'PCRank')
    local totaljobcount = session.GetPcTotalJobGrade()

    if indunMinPCRank ~= nil then
        if indunMinPCRank > totaljobcount and indunMinPCRank ~= totaljobcount then
            ui.SysMsg(ScpArgMsg('IndunEnterNeedPCRank', 'NEED_RANK', indunMinPCRank))
            return;
        end
    end

    if useCount > 0 then
        local multipleItemList = GET_INDUN_MULTIPLE_ITEM_LIST();
        for i = 1, #multipleItemList do
            local itemName = multipleItemList[i];
            local invItem = session.GetInvItemByName(itemName);
            if invItem ~= nil and invItem.isLockState then
                ui.SysMsg(ClMsg("MaterialItemIsLock"));
                return;
            end
        end
    end

    local topFrame = frame:GetTopParentFrame();
    if INDUNENTER_CHECK_ADMISSION_ITEM(topFrame, 1) == false then
        return;
    end

    local playerCnt = TryGetProp(indunCls, 'PlayerCnt');
    local party = session.party.GetPartyMemberList(PARTY_NORMAL);
    local cnt = party:Count();
    if cnt > playerCnt then
        ui.SysMsg(ClMsg("OverIndunMaxPC"));
        return;
    end
    CHAT_SYSTEM(indunCls.ClassID)
    local textCount = topFrame:GetUserIValue("multipleCount");
    local yesScript = string.format("ReqMoveToIndun(%d,%d)", 1, textCount);
    ui.MsgBox(ScpArgMsg("EnterRightNow"), yesScript, "None");

end
--[[
function INDUN_PANEL_REQ_RAID_AUTO_UI_OPEN(frame, ctrl)
    -- 매칭 던전중이거나 pvp존이면 이용 불가
    if session.world.IsIntegrateServer() == true or IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end

    -- 퀘스트나 챌린지 모드로 인해 레이어 변경되면 이용 불가
    if world.GetLayer() ~= 0 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end

    -- 레이드 지역에서 이용 불가
    local map = GetClass('Map', session.GetMapName());
    local keyword = TryGetProp(map, 'Keyword', 'None');
    local keyword_table = StringSplit(keyword, ';');
    if table.find(keyword_table, 'IsRaidField') > 0 or table.find(keyword_table, 'WeeklyBossMap') > 0 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end

    local indun_classid = tonumber(ctrl:GetUserValue("MOVE_INDUN_CLASSID"));
    local indun_cls = GetClassByType("Indun", indun_classid);
    local dungeon_type = TryGetProp(indun_cls, "DungeonType", "None")
    if dungeon_type ~= "Raid" and string.find(dungeon_type, "MythicDungeon") ~= 1 then
        return;
    end

    ui.CloseFrame("induninfo");
    ReqRaidAutoUIOpen(indun_classid);

    CHAT_SYSTEM(indun_classid)

end
]]
function indun_panel_frame_init()

    local ipframe = ui.GetFrame(g.framename)

    ipframe:SetSkinName('None')
    ipframe:SetLayerLevel(30)
    ipframe:Resize(90, 35)
    ipframe:SetPos(665, 30)
    ipframe:SetTitleBarSkin("None")
    ipframe:EnableHittestFrame(1)
    ipframe:EnableHide(0)
    ipframe:EnableHitTest(1)
    ipframe:SetAlpha(70)
    ipframe:RemoveAllChild()
    -- ipframe:EnableHideProcess(0)
    local button = ipframe:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(button)
    button:SetText("INPANEL")
    button:SetEventScript(ui.LBUTTONUP, "indun_panel_init")
    -- ipframe:EnableHideProcess(0)
    ipframe:ShowWindow(1)

    indun_panel_judge(ipframe)
end

function indun_panel_judge(ipframe)

    local button = GET_CHILD_RECURSIVELY(ipframe, "indun_panel_open")

    if g.settings.ischecked == 0 then
        -- CHAT_SYSTEM("test")

        ipframe:SetSkinName('None')
        ipframe:SetLayerLevel(30)
        ipframe:Resize(90, 35)
        ipframe:SetPos(665, 30)
        ipframe:SetTitleBarSkin("None")
        ipframe:EnableHittestFrame(1)
        ipframe:EnableHide(0)
        ipframe:EnableHitTest(1)
        ipframe:SetAlpha(70)

        -- indun_panel_frame_init()
    elseif g.settings.ischecked == 1 then
        -- ipframe:EnableHittestFrame(1)
        -- ipframe:EnableHide(0)
        -- ipframe:EnableHitTest(1)
        indun_panel_init(ipframe)
    else
        return;
    end
end

function indun_panel_checkbox_toggle()
    local ipframe = ui.GetFrame(g.framename)
    local checkbox = GET_CHILD_RECURSIVELY(ipframe, "checkbox")
    tolua.cast(checkbox, 'ui::CCheckBox')
    local ischeck = checkbox:IsChecked();

    if ischeck == 1 then
        g.settings.ischecked = 1
        indun_panel_save_settings()
    elseif ischeck == 0 then
        g.settings.ischecked = 0
        indun_panel_save_settings()
    end
    -- CHAT_SYSTEM(g.settings.ischecked)
end

function indun_panel_inv_open()
    local frame = ui.GetFrame("inventory")
    frame:ShowWindow(1)
end

function indun_panel_init(ipframe)

    -- CHAT_SYSTEM("button_click")
    local invbtn = ipframe:CreateOrGetControl('button', 'invbtn', 265, 5, 30, 30)
    AUTO_CAST(invbtn)
    invbtn:SetImage("sysmenu_inv")
    invbtn:SetEventScript(ui.LBUTTONUP, "indun_panel_inv_open")

    local petbtn = ipframe:CreateOrGetControl('button', 'petbtn', 300, 5, 30, 30)
    AUTO_CAST(petbtn)
    petbtn:SetImage("sysmenu_pet")
    petbtn:SetEventScript(ui.LBUTTONUP, "UI_TOGGLE_PETLIST")

    local minebtn = ipframe:CreateOrGetControl('button', 'minebtn', 225, 5, 30, 30)
    AUTO_CAST(minebtn)
    minebtn:SetImage("pvpmine_shop_btn_total")
    minebtn:SetEventScript(ui.LBUTTONUP, "MINIMIZED_PVPMINE_SHOP_BUTTON_CLICK")

    local checkbox = ipframe:CreateOrGetControl('checkbox', 'checkbox', 520, 5, 30, 30)
    tolua.cast(checkbox, 'ui::CCheckBox')
    checkbox:SetCheck(g.settings.ischecked)
    checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_checkbox_toggle")
    -- checkbox:SetEventScriptArgNum(ui.LBUTTONUP, ischeck)

    local entext = ipframe:CreateOrGetControl("richtext", "entext", 380, 10)
    entext:SetText("{#000000}{s20}Always Open")

    ipframe:SetLayerLevel(93)
    ipframe:Resize(555, 510)
    -- ipframe:SetSkinName("chat_window")
    ipframe:SetSkinName("test_frame_low")

    local title = ipframe:CreateOrGetControl("richtext", "indun_panel_title", 100, 10)
    title:SetText("{#000000}{s20}Indun Panel")
    local button = GET_CHILD_RECURSIVELY(ipframe, "indun_panel_open")
    button:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init")

    local challenge = ipframe:CreateOrGetControl("richtext", "challenge", 10, 45)
    challenge:SetText("{#000000}{s20}Challenge")
    indun_panel_challenge_frame(ipframe)
    -- local expert = ipframe:CreateOrGetControl("richtext", "Expert", 10, 80)
    -- expert:SetText("{#000000}{s20}Expert")
    local roze = ipframe:CreateOrGetControl("richtext", "roze", 10, 120)
    roze:SetText("{#000000}{s20}Roze")
    indun_panel_roze_frame(ipframe)

    local falouros = ipframe:CreateOrGetControl("richtext", "falouros", 10, 195)
    falouros:SetText("{#000000}{s20}Falouros")
    indun_panel_falo_frame(ipframe)

    local spreader = ipframe:CreateOrGetControl("richtext", "spreader", 10, 270)
    spreader:SetText("{#000000}{s20}Spreader")
    indun_panel_spreader_frame(ipframe)

    local jellyzele = ipframe:CreateOrGetControl("richtext", "jellyzele", 10, 345)
    jellyzele:SetText("{#000000}{s20}Jellyzele")
    indun_panel_jellyzele_frame(ipframe)

    local delmore = ipframe:CreateOrGetControl("richtext", "delmore", 10, 385)
    delmore:SetText("{#000000}{s20}Delmore")
    indun_panel_Delmore_frame(ipframe)

    local telharsha = ipframe:CreateOrGetControl("richtext", "telharsha", 10, 425)
    telharsha:SetText("{#000000}{s20}TelHarsha")
    local telharshabutton = ipframe:CreateOrGetControl('button', 'telharshabutton', 135, 425, 80, 30)
    telharshabutton:SetText("IN")
    local telharshacount = ipframe:CreateOrGetControl("richtext", "telharshacount", 220, 430)
    telharshabutton:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_telharsha_solo")

    telharshacount:SetText("{#000000}{s16}(" ..
                               GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 623).PlayPerResetType) .. "/" ..
                               GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 623).PlayPerResetType) .. ")")

    local velnice = ipframe:CreateOrGetControl("richtext", "velnice", 10, 465)
    velnice:SetText("{#000000}{s20}Velnice")
    local velnicebutton = ipframe:CreateOrGetControl('button', 'velnicebutton', 135, 465, 80, 30)
    velnicebutton:SetText("IN")
    local velnicecount = ipframe:CreateOrGetControl("richtext", "velnicecount", 220, 470, 50, 30)
    velnicecount:SetText(
        "{#000000}{s16}(" .. GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 201).PlayPerResetType) .. "/" ..
            GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 201).PlayPerResetType) .. ")")
    velnicebutton:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_velnice_solo")

    -- local ancient = ipframe:CreateOrGetControl("richtext", "ancient", 10, 360)
    -- ancient:SetText("{#000000}{s20}Ancient(アシスター)")

end

function indun_panel_enter_velnice_solo()
    -- ReqRaidSoloUIOpen(201)
    local indun_cls_id = 201
    local indun_cls = GetClassByType("Indun", indun_cls_id)
    if indun_cls ~= nil then
        local name = TryGetProp(indun_cls, "Name", "None")
        local account_obj = GetMyAccountObj()
        if account_obj ~= nil then
            local stage = TryGetProp(account_obj, "SOLO_DUNGEON_MINI_CLEAR_STAGE", 0)
            local yesScp = "INDUNINFO_MOVE_TO_SOLO_DUNGEON_PRECHECK"
            local title = ScpArgMsg("Select_Stage_SoloDungeon", "Stage", stage + 5)
            INDUN_EDITMSGBOX_FRAME_OPEN(indun_cls_id, title, "", yesScp, "", 1, stage + 5, 1)
        end
    end
    ReqMoveToIndun(1, 0)
end

function indun_panel_enter_telharsha_solo()
    ReqRaidSoloUIOpen(623)
    ReqMoveToIndun(1, 0)
end

function indun_panel_Delmore_frame(ipframe)
    local Delmoresoro = ipframe:CreateOrGetControl('button', 'Delmoresoro', 135, 385, 80, 30)
    local Delmoreauto = ipframe:CreateOrGetControl('button', 'Delmoreauto', 220, 385, 80, 30)
    local Delmorehard = ipframe:CreateOrGetControl('button', 'Delmorehard', 360, 385, 80, 30)
    local Delmorecount = ipframe:CreateOrGetControl("richtext", "Delmorecount", 305, 390, 50, 30)
    local Delmorecounthard = ipframe:CreateOrGetControl("richtext", "Delmorecounthard", 445, 390, 50, 30)
    -- local Delmoresweep = ipframe:CreateOrGetControl('button', 'Delmoresweep', 220, 305, 80, 30)
    -- local Delmoreticket = ipframe:CreateOrGetControl('button', 'Delmoreticket', 360, 225, 80, 30)
    --  local Delmoreticketcount = ipframe:CreateOrGetControl("richtext", "Delmoreticketcount", 445, 230, 50, 30)

    --  Delmoreticketcount:SetText("{#000000}{s16}(1/1)")
    Delmoresoro:SetText("SOLO")
    Delmoreauto:SetText("AUTO")
    Delmorehard:SetText("HARD")
    -- Delmoresweep:SetText("SWEEP")
    --  Delmoreticket:SetText("BUY")
    Delmorecount:SetText(
        "{#000000}{s16}(" .. GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 667).PlayPerResetType) .. "/" ..
            GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 667).PlayPerResetType) .. ")")
    Delmorecounthard:SetText("{#000000}{s16}(" ..
                                 GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 665).PlayPerResetType) .. "/" ..
                                 GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 665).PlayPerResetType) .. ")")

    Delmoresoro:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_Delmore_solo")
    Delmoreauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_Delmore_auto")
    g.Delmore_hard_flag = false
    Delmorehard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_Delmore_hard")
    -- Delmoresweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep_Delmore")

end

function indun_panel_enter_Delmore_hard()
    local indunType = 665

    if g.Delmore_hard_flag == false then
        INDUN_PANEL_INDUNINFO_SET_BUTTONS(indunType)
        g.Delmore_hard_flag = true
        ReserveScript("indun_panel_enter_Delmore_hard()", 0.5)
        -- else
    elseif g.Delmore_hard_flag == true then

        local frame = ui.GetFrame("indunenter")
        frame:ShwWindow(1)
        SHOW_INDUNENTER_DIALOG(indunType, isAlreadyPlaying, enableAutoMatch, enableEnterRight, enablePartyMatch)
        g.Delmore_hard_flag = false
        return
    end

end

function indun_panel_enter_Delmore_auto()
    -- CHAT_SYSTEM("auto")
    ReqRaidAutoUIOpen(666)
end

function indun_panel_enter_Delmore_solo()
    -- CHAT_SYSTEM("solo")
    ReqRaidSoloUIOpen(667)
    ReqMoveToIndun(1, 0)
end

function indun_panel_jellyzele_frame(ipframe)
    local jellyzelesoro = ipframe:CreateOrGetControl('button', 'jellyzelesoro', 135, 345, 80, 30)
    local jellyzeleauto = ipframe:CreateOrGetControl('button', 'jellyzeleauto', 220, 345, 80, 30)
    local jellyzelehard = ipframe:CreateOrGetControl('button', 'jellyzelehard', 360, 345, 80, 30)
    local jellyzelecount = ipframe:CreateOrGetControl("richtext", "jellyzelecount", 305, 350, 50, 30)
    local jellyzelecounthard = ipframe:CreateOrGetControl("richtext", "jellyzelecounthard", 445, 350, 50, 30)
    -- local jellyzelesweep = ipframe:CreateOrGetControl('button', 'jellyzelesweep', 220, 305, 80, 30)
    -- local jellyzeleticket = ipframe:CreateOrGetControl('button', 'jellyzeleticket', 360, 225, 80, 30)
    --  local jellyzeleticketcount = ipframe:CreateOrGetControl("richtext", "jellyzeleticketcount", 445, 230, 50, 30)

    --  jellyzeleticketcount:SetText("{#000000}{s16}(1/1)")
    jellyzelesoro:SetText("SOLO")
    jellyzeleauto:SetText("AUTO")
    jellyzelehard:SetText("HARD")
    -- jellyzelesweep:SetText("SWEEP")
    --  jellyzeleticket:SetText("BUY")
    jellyzelecount:SetText("{#000000}{s16}(" ..
                               GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 672).PlayPerResetType) .. "/" ..
                               GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 672).PlayPerResetType) .. ")")
    jellyzelecounthard:SetText("{#000000}{s16}(" ..
                                   GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 670).PlayPerResetType) .. "/" ..
                                   GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 670).PlayPerResetType) .. ")")

    jellyzelesoro:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_jellyzele_solo")
    jellyzeleauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_jellyzele_auto")
    g.jellyzele_hard_flag = false
    jellyzelehard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_jellyzele_hard")
    -- jellyzelesweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep_jellyzele")

end

function indun_panel_enter_jellyzele_hard()

    local indunType = 670

    if g.jellyzele_hard_flag == false then
        INDUN_PANEL_INDUNINFO_SET_BUTTONS(indunType)
        g.jellyzele_hard_flag = true
        ReserveScript("indun_panel_enter_Delmore_hard()", 0.5)
        -- else
    elseif g.jellyzele_hard_flag == true then

        local frame = ui.GetFrame("indunenter")
        frame:ShwWindow(1)
        SHOW_INDUNENTER_DIALOG(indunType, isAlreadyPlaying, enableAutoMatch, enableEnterRight, enablePartyMatch)
        g.jellyzele_hard_flag = false
        return
    end
end

function indun_panel_enter_jellyzele_auto()
    -- CHAT_SYSTEM("auto")
    ReqRaidAutoUIOpen(671)
end

function indun_panel_enter_jellyzele_solo()
    -- CHAT_SYSTEM("solo")
    ReqRaidSoloUIOpen(672)
    ReqMoveToIndun(1, 0)
end
-- プロゲハード675
-- プロゲソロ674
-- プロパゲオート673
-- クラゲオード671
-- ムーア自動666
function indun_panel_spreader_frame(ipframe)
    local spreadersoro = ipframe:CreateOrGetControl('button', 'spreadersoro', 135, 270, 80, 30)
    local spreaderauto = ipframe:CreateOrGetControl('button', 'spreaderauto', 220, 270, 80, 30)
    local spreaderhard = ipframe:CreateOrGetControl('button', 'spreaderhard', 360, 270, 80, 30)
    local spreadercount = ipframe:CreateOrGetControl("richtext", "spreadercount", 305, 275, 50, 30)
    local spreadercounthard = ipframe:CreateOrGetControl("richtext", "spreadercounthard", 445, 275, 50, 30)
    local spreadersweep = ipframe:CreateOrGetControl('button', 'spreadersweep', 220, 305, 80, 30)
    -- local spreaderticket = ipframe:CreateOrGetControl('button', 'spreaderticket', 360, 225, 80, 30)
    --  local spreaderticketcount = ipframe:CreateOrGetControl("richtext", "spreaderticketcount", 445, 230, 50, 30)

    --  spreaderticketcount:SetText("{#000000}{s16}(1/1)")
    spreadersoro:SetText("SOLO")
    spreaderauto:SetText("AUTO")
    spreaderhard:SetText("HARD")
    spreadersweep:SetText("SWEEP")
    --  spreaderticket:SetText("BUY")
    spreadercount:SetText("{#000000}{s16}(" ..
                              GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType) .. "/" ..
                              GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType) .. ")")
    spreadercounthard:SetText("{#000000}{s16}(" ..
                                  GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 678).PlayPerResetType) .. "/" ..
                                  GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 678).PlayPerResetType) .. ")")

    spreadersoro:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_spreader_solo")
    spreaderauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_spreader_auto")
    g.spreader_hard_flag = false
    spreaderhard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_spreader_hard")
    spreadersweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep_spreader")

end

function indun_panel_autosweep_spreader()
    local indun_classid = tonumber(673);
    ReqUseRaidAutoSweep(indun_classid);
end

function indun_panel_enter_spreader_hard()

    local indunType = 675
    if g.spreader_hard_flag == false then
        INDUN_PANEL_INDUNINFO_SET_BUTTONS(indunType)
        g.spreader_hard_flag = true
        ReserveScript("indun_panel_enter_Delmore_hard()", 0.5)
        -- else
    elseif g.spreader_hard_flag == true then

        local frame = ui.GetFrame("indunenter")
        frame:ShwWindow(1)
        SHOW_INDUNENTER_DIALOG(indunType, isAlreadyPlaying, enableAutoMatch, enableEnterRight, enablePartyMatch)
        g.spreader_hard_flag = false
        return
    end
end

function indun_panel_enter_spreader_auto()
    ReqRaidAutoUIOpen(673)
end

function indun_panel_enter_spreader_solo()
    ReqRaidSoloUIOpen(674)
    ReqMoveToIndun(1, 0)
end

function indun_panel_falo_frame(ipframe)
    local falosoro = ipframe:CreateOrGetControl('button', 'falosoro', 135, 195, 80, 30)
    local faloauto = ipframe:CreateOrGetControl('button', 'faloauto', 220, 195, 80, 30)
    local falohard = ipframe:CreateOrGetControl('button', 'falohard', 360, 195, 80, 30)
    local falocount = ipframe:CreateOrGetControl("richtext", "falocount", 305, 200, 50, 30)
    local falocounthard = ipframe:CreateOrGetControl("richtext", "falocounthard", 445, 200, 50, 30)
    local falosweep = ipframe:CreateOrGetControl('button', 'falosweep', 220, 230, 80, 30)
    -- local faloticket = ipframe:CreateOrGetControl('button', 'faloticket', 360, 225, 80, 30)
    --  local faloticketcount = ipframe:CreateOrGetControl("richtext", "faloticketcount", 445, 230, 50, 30)

    --  faloticketcount:SetText("{#000000}{s16}(1/1)")
    falosoro:SetText("SOLO")
    faloauto:SetText("AUTO")
    falohard:SetText("HARD")
    falosweep:SetText("SWEEP")
    --  faloticket:SetText("BUY")
    falocount:SetText("{#000000}{s16}(" .. GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType) ..
                          "/" .. GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType) .. ")")
    falocounthard:SetText("{#000000}{s16}(" ..
                              GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 678).PlayPerResetType) .. "/" ..
                              GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 678).PlayPerResetType) .. ")")

    falosoro:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_falo_solo")
    faloauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_falo_auto")
    g.falo_hard_flag = false
    falohard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_falo_hard")
    falosweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep_falo")

end

function indun_panel_enter_falo_hard()

    local indunType = 678
    if g.falo_hard_flag == false then
        INDUN_PANEL_INDUNINFO_SET_BUTTONS(indunType)
        g.falo_hard_flag = true
        ReserveScript("indun_panel_enter_Delmore_hard()", 0.5)
        -- else
    elseif g.falo_hard_flag == true then

        local frame = ui.GetFrame("indunenter")
        frame:ShwWindow(1)
        SHOW_INDUNENTER_DIALOG(indunType, isAlreadyPlaying, enableAutoMatch, enableEnterRight, enablePartyMatch)
        g.falo_hard_flag = false
        return
    end
end

function indun_panel_enter_falo_auto()
    ReqRaidAutoUIOpen(676)
end

function indun_panel_enter_falo_solo()
    ReqRaidSoloUIOpen(677)
    ReqMoveToIndun(1, 0)
end

function indun_panel_autosweep_falo()
    local indun_classid = tonumber(676);
    ReqUseRaidAutoSweep(indun_classid);
end

function indun_panel_roze_frame(ipframe)
    local rozesoro = ipframe:CreateOrGetControl('button', 'rozesoro', 135, 120, 80, 30)
    local rozeauto = ipframe:CreateOrGetControl('button', 'rozeauto', 220, 120, 80, 30)
    local rozehard = ipframe:CreateOrGetControl('button', 'rozehard', 360, 120, 80, 30)
    local rozecount = ipframe:CreateOrGetControl("richtext", "rozecount", 305, 125, 50, 30)
    local rozecounthard = ipframe:CreateOrGetControl("richtext", "rozecounthard", 445, 125, 50, 30)
    local rozesweep = ipframe:CreateOrGetControl('button', 'rozesweep', 220, 155, 80, 30)
    -- local rozeticket = ipframe:CreateOrGetControl('button', 'rozeticket', 360, 155, 80, 30)
    -- local rozeticketcount = ipframe:CreateOrGetControl("richtext", "rozeticketcount", 445, 160, 50, 30)

    --  rozeticketcount:SetText("{#000000}{s16}(1/1)")
    rozesoro:SetText("SOLO")
    rozeauto:SetText("AUTO")
    rozehard:SetText("HARD")
    rozesweep:SetText("SWEEP")
    --  rozeticket:SetText("BUY")
    rozecount:SetText("{#000000}{s16}(" .. GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 679).PlayPerResetType) ..
                          "/" .. GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 679).PlayPerResetType) .. ")")
    rozecounthard:SetText("{#000000}{s16}(" ..
                              GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 681).PlayPerResetType) .. "/" ..
                              GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 681).PlayPerResetType) .. ")")
    rozesoro:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_roze_solo")
    rozeauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_roze_auto")
    g.roze_hard_flag = false
    rozehard:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_roze_hard")
    rozesweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep_roze")

end

function indun_panel_enter_roze_hard()

    local indunType = 681
    if g.roze_hard_flag == false then
        INDUN_PANEL_INDUNINFO_SET_BUTTONS(indunType)
        g.roze_hard_flag = true
        ReserveScript("indun_panel_enter_Delmore_hard()", 0.5)
        -- else
    elseif g.roze_hard_flag == true then

        local frame = ui.GetFrame("indunenter")
        frame:ShwWindow(1)
        SHOW_INDUNENTER_DIALOG(indunType, isAlreadyPlaying, enableAutoMatch, enableEnterRight, enablePartyMatch)
        g.roze_hard_flag = false
        return
    end
end

function indun_panel_enter_roze_auto()
    ReqRaidAutoUIOpen(679)
    -- ReqMoveToIndun(1, 0)
end

function indun_panel_enter_roze_solo()
    ReqRaidSoloUIOpen(680)
    ReqMoveToIndun(1, 0)
end

function indun_panel_autosweep_roze()
    local indun_classid = tonumber(679);
    ReqUseRaidAutoSweep(indun_classid);
end

function indun_panel_challenge_frame(ipframe)
    local challenge460 = ipframe:CreateOrGetControl('button', 'challenge460', 135, 45, 80, 30)
    local challenge480 = ipframe:CreateOrGetControl('button', 'challenge480', 220, 45, 80, 30)
    local challengept = ipframe:CreateOrGetControl('button', 'challengept', 305, 45, 80, 30)
    local challengecount = ipframe:CreateOrGetControl("richtext", "challengecount", 390, 50, 40, 30)

    local challengeexpert = ipframe:CreateOrGetControl('button', 'challengeexpert', 435, 45, 80, 30)
    local challengeexpertcount = ipframe:CreateOrGetControl("richtext", "challengeexpertcount", 520, 50, 30, 30)
    --  local challengeticket = ipframe:CreateOrGetControl('button', 'challengeticket', 445, 45, 80, 30)
    --  local challengeticketcount = ipframe:CreateOrGetControl("richtext", "challengeticketcount", 530, 50, 50, 30)
    --  local challengeexpertticket = ipframe:CreateOrGetControl('button', 'challengeexpertticket', 255, 80, 80, 30)
    -- test
    --  challengeticketcount:SetText(indun_panel_get_chllengerecipe_trade_count)
    --  challengeexpertticket:SetText("BUY")
    --  challengeticket:SetText("BUY")
    challenge460:SetText("460")
    challenge480:SetText("480")
    challengept:SetText("PT")
    challengeexpert:SetText("EX")
    challengecount:SetText("{#000000}{s16}(" ..
                               GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType) .. "/" ..
                               GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType) .. ")")
    challengeexpertcount:SetText("{#000000}{s16}(" ..
                                     GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 647).PlayPerResetType) .. "" ..
                                     ")")

    challenge460:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge460")
    challenge480:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge480")
    challengept:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challengept")
    challengeexpert:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challengeexpert")
end

function indun_panel_enter_challenge460()
    ReqChallengeAutoUIOpen(644)
    -- local ieframe = ui.GetFrame("indunenter")
    -- ieframe:ShowWindow(0)
    -- ReserveScript("ReqMoveToIndun(1,0)", 0.3)
    ReqMoveToIndun(1, 0)
end

function indun_panel_enter_challenge480()
    ReqChallengeAutoUIOpen(645)
    ReqMoveToIndun(1, 0)
end

function indun_panel_enter_challengept()
    ReqChallengeAutoUIOpen(646)
    -- ReqMoveToIndun(1, 0)
    local frame = ui.GETFrame("indunenter")
    -- local str = "INDUNENTER_AUTOMATCH(frame,nil)"
    -- ReserveScript(str, 0.5)
end

function indun_panel_enter_challengeexpert()
    ReqChallengeAutoUIOpen(647)
    -- ReqMoveToIndun(2, 0)
end
--[[
function indun_panel_get_chllengerecipe_trade_count()
    local chllengerecipe = "PVP_MINE_40"
    local recipeCls = GetClass("ItemTradeShop", chllengerecipe)
    if recipeCls ~= nil then
        CHAT_SYSTEM("aru")
    end
    if recipeCls.NeedProperty ~= "None" and recipeCls.NeedProperty ~= "" then
        local sObj = GetSessionObject(GetMyPCObject(), "ssn_shop")
        local sCount = TryGetProp(sObj, recipeCls.NeedProperty)

        if sCount then
            return sCount
        end
    end
    if recipeCls.AccountNeedProperty ~= "None" and recipeCls.AccountNeedProperty ~= "" then

        local aObj = GetMyAccountObj()
        local sCount = TryGetProp(aObj, recipeCls.AccountNeedProperty)

        if sCount then
            return sCount
        end
    end

    return nil
end
]]
