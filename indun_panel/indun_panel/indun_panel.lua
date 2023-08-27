-- v1.0.2 チーム倉庫でESC押してもインベントリが表示される様に変更
-- v1.0.3 CCアイコンを配置、掃討の残りを表示（使っても減らないツライ）
-- v1.0.4　print排除
-- v1.0.5 イヤリングレイド
-- v1.0.6 チャレと分裂のチケット交換、表示更新機能
-- v1.0.7 当日分裂券が更新しないのを修正 イヤリングレイド回数表示更新 フレーム変えた。ヴェルニケのBUYUSE作成。コイン商店の残高表示
-- AUTOMODE時に直接ボタン押した状態に。ハードは再入場系が怖いのでそのまま
-- v1.0.8 チャレとか分裂券買う時にヴェルニケ券買っちゃうバグ修正('Д')
-- v1.0.9 分裂券を買う辺りを修正。不要になったので倉庫閉めたらインベも閉める
-- v1.1.0 ヴェルニケチケットの傭兵団コインの表示バグ修正。ゲームスタート時の傭兵団コインショップの閉じ方を修正。オートズーム機能
local addonName = "indun_panel"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.1.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")
local os = require("os")

g.settings = {
    ischecked = 0,
    zoom = 236
    -- ex = 0
}
g.ex = 0 -- 関数の外に定義

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

    -- local starttime = session.GetDBSysTime();

    indun_panel_load_settings()

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        local ipframe = ui.GetFrame("indun_panel")
        ipframe:RemoveAllChild()
        indun_panel_frame_init()
        if g.ex == 0 and INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") == 0 then
            -- addon:RegisterMsg('GAME_START', 'indunpanel_minimized_pvpmine_shop_init');
            indunpanel_minimized_pvpmine_shop_init()
            -- INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41")
            -- local frame = ui.GetFrame('earthtowershop')

            --            print(tostring(INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41")))

        end

    end

    if _G.ADDONS.norisan.AUTOMAPCHANGE ~= nil then

        acutil.setupHook(indun_panel_autozoom, "AUTOMAPCHANGE_CAMERA_ZOOM")
        addon:RegisterMsg('GAME_START', "indun_panel_autozoom")
    end
    --[[
    local shopframe = ui.GetFrame('earthtowershop')
    if shopframe:IsVisible() == 1 then
        addon:RegisterMsg('GAME_START_3SEC', 'INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART');
        -- addon:RegisterMsg('GAME_START_3SEC', 'indun_panel_earthtowershop_close');
    end
    -- acutil.setupEvent(addon, "ACCOUNTWAREHOUSE_CLOSE", "INDUN_PANEL_ACCOUNTWAREHOUSE_CLOSE");
    -- addon:RegisterMsg('ESCAPE_PRESSED', 'DIALOG_ON_PRESS_ESCAPE');
    -- addon:RegisterMsg('GAME_START', 'indun_panel_test');
]]
end

function indun_panel_autozoom()
    camera.CustomZoom(tonumber(g.settings.zoom))
end

function INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART()
    local shopframe = ui.GetFrame('earthtowershop')
    if shopframe:IsVisible() == 1 then
        -- CHAT_SYSTEM("close")
        ui.CloseFrame("earthtowershop")
        return 0
    else
        return 1
    end
end

function indunpanel_minimized_pvpmine_shop_init()
    -- CHAT_SYSTEM("a")
    pc.ReqExecuteTx_NumArgs("SCR_PVP_MINE_SHOP_OPEN", 0);
    g.ex = 1
    -- ui.CloseFrame("earthtowershop")
    local frame = ui.GetFrame('earthtowershop')
    frame:RunUpdateScript("INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART", 0.5)
    -- ReserveScript(string.format("INDUN_PANEL_EARTHTOWERSHOP_CLOSE('%s')", frame), 2.5)
end

function indun_panel_time_update(frame)

    local time = os.date("*t")
    local hour = time.hour
    local min = time.min

    -- print(tostring(formattedTime.hour))
    -- print(time)

    if hour >= 5 and hour <= 6 and g.ex == 1 then
        pc.ReqExecuteTx_NumArgs("SCR_PVP_MINE_SHOP_OPEN", 0);
        -- INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41")
        -- print(tostring(INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41")))
        local frame = ui.GetFrame('earthtowershop')
        -- pc.ReqExecuteTx_NumArgs("SCR_PVP_MINE_SHOP_OPEN", 0);
        ReserveScript(string.format("INDUN_PANEL_EARTHTOWERSHOP_CLOSE('%s')", frame), 1.5)
        g.ex = 2
        -- print(hour)
        -- print(min)
        -- CHAT_SYSTEM(hour)
        -- CHAT_SYSTEM(min)
        --[[
        REQ_PVP_MINE_SHOP_OPEN()
        local frame = ui.GetFrame('earthtowershop')

        ReserveScript(string.format("INDUN_PANEL_EARTHTOWERSHOP_CLOSE('%s')", frame), 1.0)
]]
        return 0
    end
    return 1
end

function INDUN_PANEL_DIALOG_ON_MSG(frame, msg, argStr, argNum)

    local frame = ui.GetFrame("dialog")
    AUTO_CAST(frame)
    local msg = tostring("DIALOG_CHANGE_SELECT")
    local argStr = tostring("WAREHOUSE_DLG")
    local argNum = 0
    -- ON_DIALOG_UPDATE_COLONY_TAX_RATE_SET(frame)
    DIALOG_ON_MSG(frame, msg, argStr, argNum)

    local dsframe = ui.GetFrame("dialogselect")
    AUTO_CAST(dsframe)
    DIALOGSELECT_ON_MSG(dsframe, msg, argStr, argNum)
    ui.CloseFrame('dialogselect');

    session.SetSelectDlgList();
    msg = "DIALOG_ADD_SELECT"
    argStr = string.format("!@#$WareHouse#@!")
    argNum = 1
    DIALOGSELECT_ITEM_ADD(dsframe, msg, argStr, argNum);
    local btn1 = GET_CHILD_RECURSIVELY(dsframe, 'item1Btn')
    AUTO_CAST(btn1)

    argStr = string.format("!@#$AccountWareHouse#@!")
    argNum = 2
    DIALOGSELECT_ITEM_ADD(dsframe, msg, argStr, argNum);
    local btn2 = GET_CHILD_RECURSIVELY(dsframe, 'item2Btn')
    AUTO_CAST(btn2)

    DIALOGSELECT_STRING_ENTER(frame, btn2)
    -- local strText = btn2:GetText();
    -- CHAT_SYSTEM(strText)

    argStr = string.format("!@#$Close#@!")
    argNum = 3
    DIALOGSELECT_ITEM_ADD(dsframe, msg, argStr, argNum);
    local btn3 = GET_CHILD_RECURSIVELY(dsframe, 'item3Btn')
    AUTO_CAST(btn3)
    ui.OpenFrame('dialogselect');
    --[[
    msg = "DIALOG_CLOSE"
    argStr = "None"
    argNum = 0
    DIALOG_ON_MSG(frame, msg, argStr, argNum)

    msg = "DIALOG_CLOSE"
    argStr = "None"
    argNum = 0
    DIALOGSELECT_ON_MSG(dsframe, msg, argStr, argNum)

    msg = "DIALOG_CLOSE"
    argStr = "accountwarehouse"
    argNum = 0
    DIALOG_ON_MSG(frame, msg, argStr, argNum)

    msg = "DIALOG_CLOSE"
    argStr = "accountwarehouse"
    argNum = 0
    DIALOGSELECT_ON_MSG(dsframe, msg, argStr, argNum)
]]

end

function indun_panel_overbuy_count()
    -- CHAT_SYSTEM("test")
    local aObj = GetMyAccountObj()
    local recipecls = GetClass('ItemTradeShop', "PVP_MINE_52");
    local overbuy_max = TryGetProp(recipecls, 'MaxOverBuyCount', 0)
    local overbuy_prop = TryGetProp(recipecls, 'OverBuyProperty', 'None')
    local overbuy_count = TryGetProp(aObj, overbuy_prop, 0)
    local overbuy = tonumber(overbuy_max) - tonumber(overbuy_count)
    -- CHAT_SYSTEM(tostring(overbuy))
    -- CHAT_SYSTEM(tostring(overbuy))
    return overbuy

end

function indun_panel_overbuy_amount()
    local aObj = GetMyAccountObj()
    local recipecls = GetClass('ItemTradeShop', "PVP_MINE_52");
    local overbuy_max = TryGetProp(recipecls, 'MaxOverBuyCount', 0)
    local overbuy_prop = TryGetProp(recipecls, 'OverBuyProperty', 'None')
    local overbuy_count = TryGetProp(aObj, overbuy_prop, 0)
    local overbuyamount = 0
    -- CHAT_SYSTEM(overbuy_count)
    -- print(INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_52"))

    if INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_52") == 1 and overbuy_count == 0 then
        overbuyamount = 1000
        -- return overbuyamount

        -- elseif tonumber(INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_52")) == -1 then
    elseif overbuy_count >= 0 then
        overbuyamount = overbuy_count * 50 + 1050
        -- CHAT_SYSTEM(overbuyamount)
    end
    -- print(overbuyamount)
    return overbuyamount
end
function INDUN_PANEL_MINIMIZED_PVPMINE_SHOP_BUTTON_CLICK(parent, ctrl)
    local frame = ui.GetFrame('earthtowershop')
    if frame:IsVisible() == 1 then
        ui.CloseFrame('earthtowershop')
    end
    local invframe = ui.GetFrame('inventory')
    INDUN_PANEL_INVENTORY_OPEN(invframe)

    -- local pc = GetMyPCObject();

    pc.ReqExecuteTx_NumArgs("SCR_PVP_MINE_SHOP_OPEN", 0);
    local strArg = "Entrance_Ticket"
    -- ReserveScript(string.format("CLICK_EXCHANGE_SHOP_CATEGORY(\"ctrlSet\",\"ctrl\",\"strArg\",%d", numArg), 0.2);
    ReserveScript(string.format("DRAW_EXCHANGE_SHOP_IETMS('%s')", strArg), 0.2)
    return
    --[[
    local bgCtrl = GET_CHILD_RECURSIVELY(frame, "bg_category")
    local btnCount = bgCtrl:GetChildCount(); -- ボタンの数を取得
    for i = 0, btnCount - 1 do
        local btn = bgCtrl:GetChildByIndex(i); -- インデックスを指定してボタンを取得
        local categoryName = btn:GetUserValue("CATEGORY_NAME"); -- ボタンのカテゴリーネームを取得
        CHAT_SYSTEM(categoryName); -- カテゴリーネームを表示するなどの処理を行う
    end
    ]]

end

function INDUN_PANEL_ACCOUNTWAREHOUSE_CLOSE(frame, msg)
    local frame = ui.GetFrame("inventory")
    frame = acutil.getEventArgs(msg);

    -- ui.CloseFrame("inventory")
    -- ReserveScript(string.format("INDUN_PANEL_INVENTORY_OPEN('%s')", frame, 1.0))
    ReserveScript(string.format("INDUN_PANEL_INVENTORY_OPEN('%s')", frame, 1.0))
    -- CHAT_SYSTEM("test")
    -- ReserveScript(string.format("cc_helper_legcard_equip(%d, '%s')", godcardslot, g.godiesid), 1.0)

end

function INDUN_PANEL_INVENTORY_OPEN(frame)
    -- CHAT_SYSTEM("test1")
    local frame = ui.GetFrame("inventory")
    frame:ShowWindow(1)
    frame:SetUserValue("MONCARDLIST_OPENED", 0);

    ui.Chat("/requpdateequip"); -- 내구도 회복 유료템 때문에 정확한 값을 지금 알아야 함.
    session.inventory.ReqTrustPoint();

    local savedPos = frame:GetUserValue("INVENTORY_CUR_SCROLL_POS");
    if savedPos == 'None' then
        savedPos = '0'
    end

    local tree_box = GET_CHILD_RECURSIVELY(frame, 'treeGbox_All')
    tree_box:SetScrollPos(tonumber(savedPos));

    session.CheckOpenInvCnt();
    ui.CloseFrame('layerscore');
    MAKE_WEAPON_SWAP_BUTTON();
    local questInfoSetFrame = ui.GetFrame('questinfoset_2');
    if questInfoSetFrame:IsVisible() == 1 then
        questInfoSetFrame:ShowWindow(0);
    end

    INV_HAT_VISIBLE_STATE(frame);
    INV_HAIR_WIG_VISIBLE_STATE(frame);

    local minimapFrame = ui.GetFrame('minimap');
    minimapFrame:ShowWindow(0);
end

function INDUN_PANEL_INDUNINFO_SET_BUTTONS(indunType)

    local frame = ui.GetFrame("indun_panel")
    local indunCls = GetClassByType('Indun', indunType)
    local dungeonType = TryGetProp(indunCls, "DungeonType", "None");
    local btnInfoCls = GetClassByStrProp("IndunInfoButton", "DungeonType", dungeonType);
    -- local subType = TryGetProp(indunCls, "SubType", "None");
    -- CHAT_SYSTEM(dungeonType)
    -- CHAT_SYSTEM(btnInfoCls)
    if dungeonType == "Raid" then
        -- CHAT_SYSTEM("Raid")
        -- CHAT_SYSTEM(indunCls.SubType)

        btnInfoCls = INDUNINFO_SET_BUTTONS_FIND_CLASS(indunCls);

        -- CHAT_SYSTEM(btnInfoCls.classID)
    end

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
        elseif indunType == 628 then
            redButton = GET_CHILD_RECURSIVELY(frame, "giltinehard")
            redButton:SetUserValue('MOVE_INDUN_CLASSID', indunCls.ClassID);
            redButton:SetEventScript(ui.LBUTTONUP, redButtonScp)
        else
            return;
        end

    end

end

function indun_panel_frame_init()

    local ipframe = ui.GetFrame(g.framename)

    ipframe:SetSkinName('None')
    ipframe:SetLayerLevel(30)
    ipframe:Resize(140, 40)
    ipframe:SetPos(665, 30)
    ipframe:SetTitleBarSkin("None")
    ipframe:EnableHittestFrame(1)
    ipframe:EnableHide(0)
    ipframe:EnableHitTest(1)

    ipframe:RemoveAllChild()
    -- ipframe:EnableHideProcess(0)
    local button = ipframe:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(button)
    button:SetText("{ol}{s11}INDUNPANEL")
    button:SetEventScript(ui.LBUTTONUP, "indun_panel_init")
    -- ipframe:EnableHideProcess(0)
    local ccbtn = ipframe:CreateOrGetControl('button', 'ccbtn', 95, 5, 35, 35)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    ccbtn:SetText("{img barrack_button_normal 35 35}")
    ccbtn:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")

    ipframe:ShowWindow(1)

    -- ipframe:RunUpdateScript("indun_panel_update_frame", 1.0)
    ipframe:RunUpdateScript("indun_panel_time_update", 300)
    indun_panel_judge(ipframe)
end

function indun_panel_judge(ipframe)

    local button = GET_CHILD_RECURSIVELY(ipframe, "indun_panel_open")

    if g.settings.ischecked == 0 then
        -- CHAT_SYSTEM("test")

        ipframe:SetSkinName('None')
        ipframe:SetLayerLevel(30)
        ipframe:Resize(140, 40)
        ipframe:SetPos(665, 30)
        ipframe:SetTitleBarSkin("None")
        ipframe:EnableHittestFrame(1)
        ipframe:EnableHide(0)
        ipframe:EnableHitTest(1)
        -- ipframe:SetAlpha(55)
        local ccbtn = ipframe:CreateOrGetControl('button', 'ccbtn', 95, 5, 35, 35)
        AUTO_CAST(ccbtn)
        ccbtn:SetSkinName("None")
        ccbtn:SetText("{img barrack_button_normal 35 35}")
        ccbtn:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")

        -- indun_panel_frame_init()

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

function indun_panel_autozoom_save(frame, ctrl)
    local value = tonumber(ctrl:GetText())

    if value < tonumber(0) or value > tonumber(700) then
        ui.SysMsg("Invalid value please set between 0 and 700")
        local text = GET_CHILD_RECURSIVELY(frame, "zoomedit")
        text:SetText("236")
        frame:Invalidate()
        g.settings.zoom = 236
        indun_panel_save_settings()
        indun_panel_load_settings()
        ReserveScript("indun_panel_autozoom()", 1.0)
        return
    end
    ui.SysMsg("Auto Zoom setting set to" .. value)
    g.settings.zoom = value
    indun_panel_save_settings()
    indun_panel_load_settings()
    ReserveScript("indun_panel_autozoom()", 1.0)
end

function indun_panel_init(ipframe)
    -- CHAT_SYSTEM(g.ex)
    --[[
    if g.ex == 0 then
        indun_panel_shop_open()

    end
    ]]
    ipframe:RemoveAllChild()

    local button = ipframe:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(button)
    button:SetText("{ol}{s11}INDUNPANEL")
    button:SetEventScript(ui.LBUTTONUP, "indun_panel_init")

    --[[
    local awbtn = ipframe:CreateOrGetControl('button', 'awbtn', 235, 5, 35, 35)
    AUTO_CAST(awbtn)
    awbtn:SetSkinName("None")
    awbtn:SetText("{img barrack_button_normal 35 35}")
    awbtn:SetEventScript(ui.LBUTTONUP, "INDUN_PANEL_ON_OPEN_ACCOUNTWAREHOUSE")
]]

    local zoomtext = ipframe:CreateOrGetControl("richtext", "zoomtext", 260, 15)
    zoomtext:SetText("{ol}{#FFFFFF}{s14}Auto Zoom")

    local zoomedit = ipframe:CreateOrGetControl('edit', 'zoomedit', 340, 5, 60, 35)
    AUTO_CAST(zoomedit)
    zoomedit:SetText("{ol}" .. g.settings.zoom)
    zoomedit:SetFontName("white_16_ol")
    zoomedit:SetTextAlign("center", "center")
    zoomedit:SetEventScript(ui.ENTERKEY, "indun_panel_autozoom_save")
    -- zoomedit:SetEventScript(ui.LOST_FOCUS, "indun_panel_autozoom_save")
    zoomedit:SetTextTooltip(
        "{@st59}0～700の値で入力。標準は236。マップ切り替え時に入力の値までZoomします。 Input a value from 0 to 700. Standard is 236. Zoom to the input value when switching maps.")

    local ccbtn = ipframe:CreateOrGetControl('button', 'ccbtn', 95, 5, 35, 35)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    ccbtn:SetText("{img barrack_button_normal 35 35}")
    ccbtn:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")

    local invbtn = ipframe:CreateOrGetControl('button', 'invbtn', 165, 5, 35, 35)
    AUTO_CAST(invbtn)
    invbtn:SetSkinName("None")
    invbtn:SetText("{img sysmenu_inv 35 35}")
    invbtn:SetEventScript(ui.LBUTTONUP, "INDUN_PANEL_INVENTORY_OPEN")

    local petbtn = ipframe:CreateOrGetControl('button', 'petbtn', 200, 5, 35, 35)
    AUTO_CAST(petbtn)
    petbtn:SetSkinName("None")
    petbtn:SetText("{img sysmenu_pet 35 35}")
    petbtn:SetEventScript(ui.LBUTTONUP, "UI_TOGGLE_PETLIST")

    local minebtn = ipframe:CreateOrGetControl('button', 'minebtn', 130, 5, 35, 35)
    AUTO_CAST(minebtn)
    minebtn:SetSkinName("None")
    minebtn:SetText("{img pvpmine_shop_btn_total 35 35}")
    minebtn:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_MINIMIZED_PVPMINE_SHOP_BUTTON_CLICK")
    -- minebtn:SetEventScript(ui.LBUTTONUP, "CLICK_EXCHANGE_SHOP_CATEGORY");
    -- minebtn:SetEventScriptArgString(ui.LBUTTONUP, "Entrance_Ticket");

    local checkbox = ipframe:CreateOrGetControl('checkbox', 'checkbox', 520, 5, 30, 30)
    tolua.cast(checkbox, 'ui::CCheckBox')
    checkbox:SetCheck(g.settings.ischecked)
    checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_checkbox_toggle")
    checkbox:SetTextTooltip("{@st59}チェックすると常時展開 IsCheck AlwaysOpen")

    --  local entext = ipframe:CreateOrGetControl("richtext", "entext", 415, 10)
    -- entext:SetText("{ol}{#FFFFFF}{s16}Always Open")

    ipframe:SetLayerLevel(93)
    ipframe:Resize(560, 630) -- 595
    -- ipframe:SetSkinName("test_Item_tooltip_equip")
    -- ipframe:SetSkinName("test_frame_low")
    -- ipframe:SetSkinName("market_listbase")
    ipframe:SetSkinName("bg")
    ipframe:SetAlpha(40)
    -- local title = ipframe:CreateOrGetControl("richtext", "indun_panel_title", 95, 10)
    -- title:SetText("{#000000}{s20}Indun Panel")

    local pvpmine = ipframe:CreateOrGetControl("richtext", "pvpmine", 395, 590)
    -- local pvpmine = ipframe:CreateOrGetControl("button", "pvpmine", 395, 590, 25, 25)
    pvpmine:SetText("{img pvpmine_shop_btn_total 25 25}")
    pvpmine:SetTextTooltip("{@st59}傭兵団コイン数量 Mercenary Badge count")
    -- local pvpmine:SetImage(sealimage)

    local pvpminecount = ipframe:CreateOrGetControl("richtext", "pvpminecount", 425, 590)
    pvpminecount:SetText(string.format("{ol}{#FFD900}{s20}%s", GET_COMMAED_STRING(indun_panel_pvpmaine_count())))

    local button = GET_CHILD_RECURSIVELY(ipframe, "indun_panel_open")
    button:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init")

    -- CHAT_SYSTEM("test4")

    local challenge = ipframe:CreateOrGetControl("richtext", "challenge", 15, 45)
    challenge:SetText("{ol}{#FFFFFF}{s21}Challenge")
    indun_panel_challenge_frame(ipframe)
    -- local expert = ipframe:CreateOrGetControl("richtext", "Expert", 10, 80)
    -- expert:SetText("{#000000}{s20}Expert")
    local roze = ipframe:CreateOrGetControl("richtext", "roze", 15, 120)
    roze:SetText("{ol}{#FFFFFF}{s21}Roze")
    indun_panel_roze_frame(ipframe)

    local falouros = ipframe:CreateOrGetControl("richtext", "falouros", 15, 195)
    falouros:SetText("{ol}{#FFFFFF}{s21}Falouros")
    indun_panel_falo_frame(ipframe)

    local spreader = ipframe:CreateOrGetControl("richtext", "spreader", 15, 270)
    spreader:SetText("{ol}{#FFFFFF}{s21}Spreader")
    indun_panel_spreader_frame(ipframe)

    local jellyzele = ipframe:CreateOrGetControl("richtext", "jellyzele", 15, 345)
    jellyzele:SetText("{ol}{#FFFFFF}{s21}Jellyzele")
    indun_panel_jellyzele_frame(ipframe)

    local delmore = ipframe:CreateOrGetControl("richtext", "delmore", 15, 385)
    delmore:SetText("{ol}{#FFFFFF}{s21}Delmore")
    indun_panel_Delmore_frame(ipframe)

    local telharsha = ipframe:CreateOrGetControl("richtext", "telharsha", 15, 425)
    telharsha:SetText("{ol}{#FFFFFF}{s21}TelHarsha")
    local telharshabutton = ipframe:CreateOrGetControl('button', 'telharshabutton', 135, 425, 80, 30)
    telharshabutton:SetText("{ol}IN")
    local telharshacount = ipframe:CreateOrGetControl("richtext", "telharshacount", 220, 430)
    telharshabutton:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_telharsha_solo")

    telharshacount:SetText("{ol}{#FFFFFF}{s16}(" ..
                               GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 623).PlayPerResetType) .. "/" ..
                               GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 623).PlayPerResetType) .. ")")

    local velnice = ipframe:CreateOrGetControl("richtext", "velnice", 15, 465)
    velnice:SetText("{ol}{#FFFFFF}{s21}Velnice")
    local velnicebutton = ipframe:CreateOrGetControl('button', 'velnicebutton', 135, 465, 80, 30)
    velnicebutton:SetText("{ol}IN")
    local velnicecount = ipframe:CreateOrGetControl("richtext", "velnicecount", 220, 470, 50, 30)
    velnicecount:SetText(
        "{ol}{#FFFFFF}(" .. GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 201).PlayPerResetType) .. "/" ..
            GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 201).PlayPerResetType) .. ")")
    velnicebutton:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_velnice_solo")

    local vrecipecls = GetClass('ItemTradeShop', "PVP_MINE_52");
    local voverbuy_max = TryGetProp(vrecipecls, 'MaxOverBuyCount', 0)

    local velnicebuyuse = ipframe:CreateOrGetControl('button', 'velnicebuyuse', 275, 465, 80, 30)
    AUTO_CAST(velnicebuyuse)
    velnicebuyuse:SetText("{ol}{#EE7800}{s14}BUYUSE")
    velnicebuyuse:SetEventScript(ui.LBUTTONUP, "indun_panel_velnice_buyuse")
    local velniceexchangecount = ipframe:CreateOrGetControl("richtext", "velniceexchangecount", 360, 470, 60, 30)

    local vexchangecount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_52")
    if vexchangecount < 0 then
        vexchangecount = 0
    end
    velniceexchangecount:SetText(string.format("{ol}{#FFFFFF}(%d", vexchangecount) .. "/" ..
                                     string.format("{ol}{#FF0000}%d", indun_panel_overbuy_count()) .. "{ol}{#FFFFFF})")

    local velniceamount = ipframe:CreateOrGetControl("richtext", " velniceamount", 425, 470, 50, 30)
    if tonumber(vexchangecount) == 1 then
        velniceamount:SetText("{ol}{#FFFFFF}(" .. "{img pvpmine_shop_btn_total 20 20}" .. "1,000)")
        -- elseif tonumber(vexchangecount) == 0 and voverbuy_max == 999 then
        -- velniceamount:SetText("{ol}{#FFFFFF}(1,050)")
        -- return
    else
        velniceamount:SetText("{ol}{#FFFFFF}(" .. "{img pvpmine_shop_btn_total 20 20}" ..
                                  string.format("{ol}{#FF0000}%s", GET_COMMAED_STRING(indun_panel_overbuy_amount())) ..
                                  "{ol}{#FFFFFF})")
    end
    -- 629solo 635auto 629pt
    local giltine = ipframe:CreateOrGetControl("richtext", "giltine", 15, 505)
    giltine:SetText("{ol}{#FFFFFF}{s21}Giltine")
    indun_panel_giltine_frame(ipframe)
    -- local ancient = ipframe:CreateOrGetControl("richtext", "ancient", 10, 360)
    -- ancient:SetText("{#000000}{s20}Ancient(アシスター)")
    indun_panel_autosweep(ipframe)

    -- 661solo 662ptn 663pth  ReqRaidAutoUIOpen(662)
    local earring = ipframe:CreateOrGetControl("richtext", "earring", 15, 545)
    earring:SetText("{ol}{#FFFFFF}{s21}Earring")
    indun_panel_earring_frame(ipframe)

    -- 
    ipframe:RunUpdateScript("indun_panel_update_frame", 1.0)
    -- ReserveScript("indun_panel_update_frame()", 1.0)
    return
end

function INDUN_PANEL_ON_OPEN_ACCOUNTWAREHOUSE()

    new_add_item = {}
    new_stack_add_item = {}
    custom_title_name = {}

    ui.OpenFrame("accountwarehouse");
end

function indun_panel_velnice_buyuse()
    -- CHAT_SYSTEM("TEST")
    if GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 201).PlayPerResetType) == 1 then
        local recipeName = "PVP_MINE_52"
        INDUN_PANEL_ITEM_BUY_USE(recipeName)
    else
        ui.SysMsg("The number of remains")
        return
    end

end

function indun_panel_pvpmaine_count()

    -- EARTH_TOWER_SET_PROPERTY_COUNT(propertyRemain, 'misc_pvp_mine2', "MISC_PVP_MINE2")    
    -- EARTH_TOWER_SET_PROPERTY_COUNT(ctrl, itemName, propName)
    local aObj = GetMyAccountObj()
    local coincount = TryGetProp(aObj, "MISC_PVP_MINE2", '0')
    local itemCls = GetClass('Item', 'misc_pvp_mine2')

    if coincount == 'None' then
        coincount = '0'
    end

    return coincount

end

function indun_panel_earring_frame(ipframe)
    local earringsoro = ipframe:CreateOrGetControl('button', 'earringsoro', 135, 545, 80, 30)
    local earringnormal = ipframe:CreateOrGetControl('button', 'earringauto', 220, 545, 80, 30)
    local earringhard = ipframe:CreateOrGetControl('button', 'earringhard', 305, 545, 80, 30)
    -- local earringcount = ipframe:CreateOrGetControl("richtext", "earringcount", 220, 550, 50, 30)
    -- local earringnormalcount = ipframe:CreateOrGetControl("richtext", "earringnormalcount", 305, 550, 50, 30)
    local earringcounthard = ipframe:CreateOrGetControl("richtext", "earringcounthard", 390, 550, 50, 30)
    -- local giltinesweep = ipframe:CreateOrGetControl('button', 'giltinesweep', 220, 305, 80, 30)
    -- local giltineticket = ipframe:CreateOrGetControl('button', 'giltineticket', 360, 225, 80, 30)
    --  local giltineticketcount = ipframe:CreateOrGetControl("richtext", "giltineticketcount", 445, 230, 50, 30)

    --  giltineticketcount:SetText("{ol}{#FFFFFF}{s16}(1/1)")
    earringsoro:SetText("{ol}SOLO")
    earringnormal:SetText("{ol}{s14}NORMAL")
    earringhard:SetText("{ol}{#FF0000}HARD")
    -- giltinesweep:SetText("SWEEP")
    --  giltineticket:SetText("BUY")
    -- earringcount:SetText(
    -- "{ol}{#FFFFFF}{s16}(" .. GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 661).PlayPerResetType) .. ")")

    earringcounthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                                 GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 663).PlayPerResetType) .. ")")

    earringsoro:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_earringsoro")
    earringnormal:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_earringnormal")
    earringhard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_earringhard")

    ipframe:ShowWindow(1)

end

function indun_panel_enter_earringsoro()
    ReqRaidAutoUIOpen(661)
    ReqMoveToIndun(1, 0)
end

function indun_panel_enter_earringnormal()
    ReqRaidAutoUIOpen(662)
    ReqMoveToIndun(1, 0)
end

function indun_panel_enter_earringhard()
    ReqRaidAutoUIOpen(663)
    ReqMoveToIndun(1, 0)
end

function indun_panel_sweep_count(buffid)
    -- print("indun_panel_sweep_count")
    local handle = session.GetMyHandle()
    local buffframe = ui.GetFrame("buff")
    local buffslotset = GET_CHILD_RECURSIVELY(buffframe, "buffslot")
    local buffslotcount = buffslotset:GetChildCount()
    local iconcount = 0
    for i = 0, buffslotcount - 1 do
        local achild = buffslotset:GetChildByIndex(i)
        local aicon = achild:GetIcon()
        local aiconinfo = aicon:GetInfo()
        local abuff = info.GetBuff(handle, aiconinfo.type)
        if abuff ~= nil then
            iconcount = iconcount + 1
        end
    end

    -- print(tostring(iconcount))

    local sweepcount = 0

    for i = 0, iconcount - 1 do
        local child = buffslotset:GetChildByIndex(i)
        local icon = child:GetIcon()
        local iconinfo = icon:GetInfo()
        local buff = info.GetBuff(handle, iconinfo.type)
        -- print(tostring(buff.buffID))

        if tostring(buff.buffID) == tostring(buffid) then

            sweepcount = buff.over
            -- print(sweepcount)

        end

    end
    -- print("sweep" .. sweepcount)
    return sweepcount

end

function indun_panel_autosweep(ipframe)
    -- 80017ファロ掃討　/80015ロゼ掃討　/80016プロパ掃討
    local spreadersweepcount = ipframe:CreateOrGetControl("richtext", "spreadersweepcount", 305, 310, 50, 30)
    local falosweepcount = ipframe:CreateOrGetControl("richtext", "falosweepcount", 305, 235, 50, 30)
    local rozesweepcount = ipframe:CreateOrGetControl("richtext", "rozesweepcount", 305, 160, 50, 30)
    -- print("test")
    -- indun_panel_sweep_count_Preparation()

    -- print("test2")
    local rBuffID = 80015 -- 対象のバフID
    local sweepcount = 0
    local buffFound = false

    sweepcount = indun_panel_sweep_count(rBuffID)

    rozesweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. sweepcount .. ")")

    local fBuffID = 80017 -- 対象のバフID

    sweepcount = indun_panel_sweep_count(fBuffID)
    falosweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. sweepcount .. ")")

    local sBuffID = 80016 -- 対象のバフID

    sweepcount = indun_panel_sweep_count(sBuffID)

    spreadersweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. sweepcount .. ")")

end

function indun_panel_giltine_frame(ipframe)
    local giltinesoro = ipframe:CreateOrGetControl('button', 'giltinesoro', 135, 505, 80, 30)
    local giltineauto = ipframe:CreateOrGetControl('button', 'giltineauto', 220, 505, 80, 30)
    local giltinehard = ipframe:CreateOrGetControl('button', 'giltinehard', 360, 505, 80, 30)
    local giltinecount = ipframe:CreateOrGetControl("richtext", "giltinecount", 305, 510, 50, 30)
    local giltinecounthard = ipframe:CreateOrGetControl("richtext", "giltinecounthard", 445, 510, 50, 30)
    -- local giltinesweep = ipframe:CreateOrGetControl('button', 'giltinesweep', 220, 305, 80, 30)
    -- local giltineticket = ipframe:CreateOrGetControl('button', 'giltineticket', 360, 225, 80, 30)
    --  local giltineticketcount = ipframe:CreateOrGetControl("richtext", "giltineticketcount", 445, 230, 50, 30)

    --  giltineticketcount:SetText("{ol}{#FFFFFF}{s16}(1/1)")
    giltinesoro:SetText("{ol}SOLO")
    giltineauto:SetText("{ol}{#FFD900}AUTO")
    giltinehard:SetText("{ol}{#FF0000}HARD")
    -- giltinesweep:SetText("SWEEP")
    --  giltineticket:SetText("BUY")
    giltinecount:SetText("{ol}{#FFFFFF}{s16}(" ..
                             GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 635).PlayPerResetType) .. "/" ..
                             GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 635).PlayPerResetType) .. ")")
    giltinecounthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                                 GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 628).PlayPerResetType) .. ")")

    giltinesoro:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_giltine_solo")
    giltineauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_giltine_auto")
    g.giltine_hard_flag = false
    -- giltinehard:SetUserValue('MOVE_INDUN_CLASSID', 628);
    giltinehard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_giltine_hard")
    -- giltinesweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep_giltine")

end

function indun_panel_enter_giltine_hard()

    local indunType = 628
    local indunCls = GetClassByType("Indun", indunType)

    if g.giltine_hard_flag == false then
        -- INDUN_PANEL_INDUNINFO_SET_BUTTONS(indunType)
        local frame = ui.GetFrame("induninfo")
        -- CHAT_SYSTEM("test1")
        INDUN_PANEL_INDUNINFO_SET_BUTTONS(indunType)

        g.giltine_hard_flag = true
        ReserveScript("indun_panel_enter_giltine_hard()", 0.5)
        -- else
    elseif g.giltine_hard_flag == true then

        -- local frame = ui.GetFrame("indunenter")
        -- frame:ShwWindow(1)
        SHOW_INDUNENTER_DIALOG(indunType, isAlreadyPlaying, enableAutoMatch, enableEnterRight, enablePartyMatch)
        g.giltine_hard_flag = false
        return
    end
end

function indun_panel_enter_giltine_auto()
    -- CHAT_SYSTEM("auto")
    ReqRaidAutoUIOpen(635)
    local topFrame = ui.GetFrame("indunenter")
    -- CHAT_SYSTEM(tostring(topFrame:GetName()))
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
    ReserveScript(string.format("ReqMoveToIndun(%d,%d)", 2, 0), 0.3)
end

function indun_panel_enter_giltine_solo()
    -- CHAT_SYSTEM("solo")
    ReqRaidSoloUIOpen(669)
    ReqMoveToIndun(1, 0)
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

    --  Delmoreticketcount:SetText("{ol}{#FFFFFF}{s16}(1/1)")
    Delmoresoro:SetText("{ol}SOLO")
    Delmoreauto:SetText("{ol}{#FFD900}AUTO")
    Delmorehard:SetText("{ol}{#FF0000}HARD")
    -- Delmoresweep:SetText("SWEEP")
    --  Delmoreticket:SetText("BUY")
    Delmorecount:SetText("{ol}{#FFFFFF}{s16}(" ..
                             GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 667).PlayPerResetType) .. "/" ..
                             GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 667).PlayPerResetType) .. ")")
    Delmorecounthard:SetText("{ol}{#FFFFFF}{s16}(" ..
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
    local topFrame = ui.GetFrame("indunenter")
    -- CHAT_SYSTEM(tostring(topFrame:GetName()))
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
    ReserveScript(string.format("ReqMoveToIndun(%d,%d)", 2, 0), 0.3)
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

    --  jellyzeleticketcount:SetText("{ol}{#FFFFFF}{s16}(1/1)")
    jellyzelesoro:SetText("{ol}SOLO")
    jellyzeleauto:SetText("{ol}{#FFD900}AUTO")
    jellyzelehard:SetText("{ol}{#FF0000}HARD")
    -- jellyzelesweep:SetText("SWEEP")
    --  jellyzeleticket:SetText("BUY")
    jellyzelecount:SetText("{ol}{#FFFFFF}{s16}(" ..
                               GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 672).PlayPerResetType) .. "/" ..
                               GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 672).PlayPerResetType) .. ")")
    jellyzelecounthard:SetText("{ol}{#FFFFFF}{s16}(" ..
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
        ReserveScript("indun_panel_enter_jellyzele_hard()", 0.5)
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
    local topFrame = ui.GetFrame("indunenter")
    -- CHAT_SYSTEM(tostring(topFrame:GetName()))
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
    ReserveScript(string.format("ReqMoveToIndun(%d,%d)", 2, 0), 0.3)
end

function indun_panel_enter_jellyzele_solo()
    -- CHAT_SYSTEM("solo")
    ReqRaidSoloUIOpen(672)
    ReqMoveToIndun(1, 0)
end

function indun_panel_update_frame(frame)
    local ipframe = ui.GetFrame(g.framename)

    local invbtn = GET_CHILD_RECURSIVELY(ipframe, "invbtn")

    if invbtn:IsVisible() == 1 then

        local velnicecount = GET_CHILD_RECURSIVELY(ipframe, "velnicecount")
        velnicecount:SetText("{ol}{#FFFFFF}(" ..
                                 GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 201).PlayPerResetType) .. "/" ..
                                 GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 201).PlayPerResetType) .. ")")

        local vrecipecls = GetClass('ItemTradeShop', "PVP_MINE_52");
        local voverbuy_max = TryGetProp(recipecls, 'MaxOverBuyCount', 0)

        local pvpminecount = GET_CHILD_RECURSIVELY(ipframe, "pvpminecount")
        pvpminecount:SetText(string.format("{ol}{#FFD900}{s20}%s", GET_COMMAED_STRING(indun_panel_pvpmaine_count())))

        local velniceexchangecount = GET_CHILD_RECURSIVELY(ipframe, "velniceexchangecount")
        local vexchangecount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_52")

        if vexchangecount < 0 then
            vexchangecount = 0
        end
        velniceexchangecount:SetText(string.format("{ol}{#FFFFFF}(%d", vexchangecount) .. "/" ..
                                         string.format("{ol}{#FF0000}%d", indun_panel_overbuy_count()) ..
                                         "{ol}{#FFFFFF})")

        local velniceamount = GET_CHILD_RECURSIVELY(ipframe, " velniceamount")
        --[[
        if tonumber(vexchangecount) == 1 and voverbuy_max == 999 then
            velniceamount:SetText("{ol}{#FFFFFF}(1,000)")
        elseif tonumber(vexchangecount) == 0 and voverbuy_max == 999 then
            velniceamount:SetText("{ol}{#FFFFFF}(1,050)")
        else
             end
            ]]
        velniceamount:SetText("{ol}{#FFFFFF}(" .. "{img pvpmine_shop_btn_total 20 20}" ..
                                  string.format("{ol}{#FF0000}%s", GET_COMMAED_STRING(indun_panel_overbuy_amount())) ..
                                  "{ol}{#FFFFFF})")

        -- CHAT_SYSTEM("test 1")
        local challengeticketcount = GET_CHILD_RECURSIVELY(ipframe, "challengeticketcount")
        local challengeexpertticketcount = GET_CHILD_RECURSIVELY(ipframe, "challengeexpertticketcount")
        local challengecount = GET_CHILD_RECURSIVELY(ipframe, "challengecount")
        local challengeexpertcount = GET_CHILD_RECURSIVELY(ipframe, "challengeexpertcount")
        -- 80017ファロ掃討　/80015ロゼ掃討　/80016プロパ掃討
        local spreadersweepcount = GET_CHILD_RECURSIVELY(ipframe, "spreadersweepcount")
        local falosweepcount = GET_CHILD_RECURSIVELY(ipframe, "falosweepcount")
        local rozesweepcount = GET_CHILD_RECURSIVELY(ipframe, "rozesweepcount")

        local spreadercount = GET_CHILD_RECURSIVELY(ipframe, "spreadercount")
        local falocount = GET_CHILD_RECURSIVELY(ipframe, "falocount")
        local rozecount = GET_CHILD_RECURSIVELY(ipframe, "rozecount")

        local earringcounthard = GET_CHILD_RECURSIVELY(ipframe, "earringcounthard")

        local giltinecounthard = GET_CHILD_RECURSIVELY(ipframe, "giltinecounthard")

        challengeticketcount:SetText(
            "{ol}{#FFFFFF}{s16}(" .. INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40") .. "/" ..
                INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_40") .. ")")

        challengeexpertticketcount:SetText(
            "{ol}{#FFFFFF}{s16}(d" .. INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") .. "/w" ..
                INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42") .. "/" ..
                (INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_41") +
                    INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_42")) .. ")")

        challengecount:SetText("{ol}{#FFFFFF}{s16}(" ..
                                   GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType) .. "/" ..
                                   GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType) .. ")")
        challengeexpertcount:SetText("{ol}{#FFFFFF}{s16}(" ..
                                         GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 647).PlayPerResetType) ..
                                         "" .. ")")

        rozesweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(80015) .. ")")
        spreadersweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(80016) .. ")")
        falosweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(80017) .. ")")

        spreadercount:SetText("{ol}{#FFFFFF}{s16}(" ..
                                  GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType) .. "/" ..
                                  GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType) .. ")")

        falocount:SetText("{ol}{#FFFFFF}{s16}(" ..
                              GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType) .. "/" ..
                              GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType) .. ")")

        rozecount:SetText("{ol}{#FFFFFF}{s16}(" ..
                              GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 679).PlayPerResetType) .. "/" ..
                              GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 679).PlayPerResetType) .. ")")

        earringcounthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                                     GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 663).PlayPerResetType) .. ")")

        giltinecounthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                                     GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 628).PlayPerResetType) .. ")")
        ipframe:Invalidate()

        return 1
    else
        -- CHAT_SYSTEM("test 0")
        return 0
    end

end

function indun_panel_spreader_frame(ipframe)
    local spreadersoro = ipframe:CreateOrGetControl('button', 'spreadersoro', 135, 270, 80, 30)
    local spreaderauto = ipframe:CreateOrGetControl('button', 'spreaderauto', 220, 270, 80, 30)
    local spreaderhard = ipframe:CreateOrGetControl('button', 'spreaderhard', 360, 270, 80, 30)
    local spreadercount = ipframe:CreateOrGetControl("richtext", "spreadercount", 305, 275, 50, 30)
    local spreadercounthard = ipframe:CreateOrGetControl("richtext", "spreadercounthard", 445, 275, 50, 30)
    local spreadersweep = ipframe:CreateOrGetControl('button', 'spreadersweep', 220, 305, 80, 30)

    -- local spreaderticket = ipframe:CreateOrGetControl('button', 'spreaderticket', 360, 225, 80, 30)
    --  local spreaderticketcount = ipframe:CreateOrGetControl("richtext", "spreaderticketcount", 445, 230, 50, 30)

    --  spreaderticketcount:SetText("{ol}{#FFFFFF}{s16}(1/1)")
    spreadersoro:SetText("{ol}SOLO")
    spreaderauto:SetText("{ol}{#FFD900}AUTO")
    spreaderhard:SetText("{ol}{#FF0000}HARD")
    spreadersweep:SetText("{ol}{#00FF00}SWEEP")
    --  spreaderticket:SetText("BUY")
    spreadercount:SetText("{ol}{#FFFFFF}{s16}(" ..
                              GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType) .. "/" ..
                              GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType) .. ")")
    spreadercounthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                                  GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 678).PlayPerResetType) .. "/" ..
                                  GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 678).PlayPerResetType) .. ")")
    -- local buffcount = indun_panel_sweep_count(80016)
    -- if buffcount ~= 0 then
    -- CHAT_SYSTEM(buffcount)

    -- end
    spreadersoro:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_spreader_solo")
    spreaderauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_spreader_auto")
    g.spreader_hard_flag = false
    spreaderhard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_spreader_hard")
    spreadersweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep_spreader")

end

function indun_panel_autosweep_spreader()
    local indun_classid = tonumber(673);
    local sBuffID = 80016 -- 対象のバフID
    local sweepcount = 0
    sweepcount = indun_panel_sweep_count(sBuffID)
    if sweepcount >= 1 then
        ReqUseRaidAutoSweep(indun_classid);
        -- local ipframe = ui.GetFrame(g.framename)
        -- ipframe:ShowWindow(0)
        -- ReserveScript(string.format(" indun_panel_update_frame('%s')", ipframe, 0.1))

        return
        -- ipframe:RemoveAllChild()
        -- indun_panel_init(ipframe)
    else
        -- local ipframe = ui.GetFrame(g.framename)
        -- ipframe:ShowWindow(0)
        -- ReserveScript(string.format(" indun_panel_update_frame('%s')", ipframe, 0.1))
        -- ReserveScript(string.format("indun_panel_init('%s')", ipframe, 0.3))
        -- return
        ui.SysMsg("Does not have a sweeping buff")
        return
    end
end

function indun_panel_enter_spreader_hard()

    local indunType = 675
    if g.spreader_hard_flag == false then
        INDUN_PANEL_INDUNINFO_SET_BUTTONS(indunType)
        g.spreader_hard_flag = true
        ReserveScript("indun_panel_enter_spreader_hard()", 0.5)
        -- else
    elseif g.spreader_hard_flag == true then

        local frame = ui.GetFrame("indunenter")
        frame:ShwWindow(1)
        SHOW_INDUNENTER_DIALOG(indunType, isAlreadyPlaying, enableAutoMatch, enableEnterRight, enablePartyMatch)
        g.spreader_hard_flag = false
        -- ReqMoveToIndun(1, 0)
        return
    end
end

function indun_panel_enter_spreader_auto()
    ReqRaidAutoUIOpen(673)
    local topFrame = ui.GetFrame("indunenter")
    -- CHAT_SYSTEM(tostring(topFrame:GetName()))
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
    ReserveScript(string.format("ReqMoveToIndun(%d,%d)", 2, 0), 0.3)
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

    --  faloticketcount:SetText("{ol}{#FFFFFF}{s16}(1/1)")
    falosoro:SetText("{ol}SOLO")
    faloauto:SetText("{ol}{#FFD900}AUTO")
    falohard:SetText("{ol}{#FF0000}HARD")
    falosweep:SetText("{ol}{#00FF00}SWEEP")
    --  faloticket:SetText("BUY")
    falocount:SetText("{ol}{#FFFFFF}{s16}(" ..
                          GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType) .. "/" ..
                          GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType) .. ")")
    falocounthard:SetText("{ol}{#FFFFFF}{s16}(" ..
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
        ReserveScript("indun_panel_enter_falo_hard()", 0.5)
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
    local topFrame = ui.GetFrame("indunenter")
    -- CHAT_SYSTEM(tostring(topFrame:GetName()))
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
    ReserveScript(string.format("ReqMoveToIndun(%d,%d)", 2, 0), 0.3)
end

function indun_panel_enter_falo_solo()
    ReqRaidSoloUIOpen(677)
    ReqMoveToIndun(1, 0)
end

function indun_panel_autosweep_falo()
    local indun_classid = tonumber(676);
    local fBuffID = 80017
    local sweepcount = 0
    sweepcount = indun_panel_sweep_count(fBuffID)
    if sweepcount >= 1 then
        ReqUseRaidAutoSweep(indun_classid);
        -- local ipframe = ui.GetFrame(g.framename)
        -- indun_panel_ini00999t(ipframe)
        -- ipframe:ShowWindow(0)
        return
    else
        --  ReqUseRaidAutoSweep(indun_classid);
        ui.SysMsg("Does not have a sweeping buff")
        return
    end
    -- indun_panel_init(ipframe)
    -- ReserveScript(string.format("indun_panel_init('%s')", ipframe), 0.1)
    -- ipframe:ShowWindow(0)
    -- ReserveScript(string.format("indun_panel_init('%s')", tostring(ipframe)), 0.1)
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

    --  rozeticketcount:SetText("{ol}{#FFFFFF}{s16}(1/1)")
    rozesoro:SetText("{ol}SOLO")
    rozeauto:SetText("{ol}{#FFD900}AUTO")
    rozehard:SetText("{ol}{#FF0000}HARD")
    rozesweep:SetText("{ol}{#00FF00}SWEEP")
    --  rozeticket:SetText("BUY")
    rozecount:SetText("{ol}{#FFFFFF}{s16}(" ..
                          GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 679).PlayPerResetType) .. "/" ..
                          GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 679).PlayPerResetType) .. ")")
    rozecounthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                              GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 681).PlayPerResetType) .. "/" ..
                              GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 681).PlayPerResetType) .. ")")
    rozesoro:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_roze_solo")
    rozeauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_roze_auto")
    g.roze_hard_flag = false
    rozehard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_roze_hard")
    rozesweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep_roze")

end

function indun_panel_enter_roze_hard()

    local indunType = 681
    if g.roze_hard_flag == false then
        INDUN_PANEL_INDUNINFO_SET_BUTTONS(indunType)
        g.roze_hard_flag = true
        ReserveScript("indun_panel_enter_roze_hard()", 0.5)
        -- else
    elseif g.roze_hard_flag == true then

        local frame = ui.GetFrame("indunenter")
        frame:ShwWindow(1)
        SHOW_INDUNENTER_DIALOG(indunType, isAlreadyPlaying, enableAutoMatch, enableEnterRight, enablePartyMatch)
        g.roze_hard_flag = false
        -- ReqMoveToIndun(3, 1)
        return
    end
end

function indun_panel_enter_roze_auto()
    ReqRaidAutoUIOpen(679)
    local topFrame = ui.GetFrame("indunenter")
    -- CHAT_SYSTEM(tostring(topFrame:GetName()))
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
    ReserveScript(string.format("ReqMoveToIndun(%d,%d)", 2, 0), 0.3)
    -- ReqMoveToIndun(1, 0)
end

function indun_panel_enter_roze_solo()
    ReqRaidSoloUIOpen(680)
    ReqMoveToIndun(1, 0)
end

function indun_panel_autosweep_roze()
    local indun_classid = tonumber(679);

    local rBuffID = 80015 -- 対象のバフID
    local sweepcount = 0
    sweepcount = indun_panel_sweep_count(rBuffID)
    if sweepcount >= 1 then
        ReqUseRaidAutoSweep(indun_classid);
        -- local ipframe = ui.GetFrame(g.framename)
        -- ipframe:ShowWindow(0)
        -- indun_panel_init(ipframe)
        return
    else
        ui.SysMsg("Does not have a sweeping buff")
        return
    end

end

function indun_panel_challenge_frame(ipframe)
    local challenge460 = ipframe:CreateOrGetControl('button', 'challenge460', 135, 45, 80, 30)
    local challenge480 = ipframe:CreateOrGetControl('button', 'challenge480', 220, 45, 80, 30)
    local challengept = ipframe:CreateOrGetControl('button', 'challengept', 305, 45, 80, 30)

    local challengecount = ipframe:CreateOrGetControl("richtext", "challengecount", 390, 50, 40, 30)

    local challengeexpert = ipframe:CreateOrGetControl('button', 'challengeexpert', 445, 45, 80, 30)
    local challengeexpertcount = ipframe:CreateOrGetControl("richtext", "challengeexpertcount", 530, 50, 30, 30)

    local challengeticket = ipframe:CreateOrGetControl('button', 'challengeticket', 220, 80, 80, 30)
    challengeticket:SetText("{ol}{#EE7800}{s14}BUYUSE")
    challengeticket:SetEventScript(ui.LBUTTONUP, "indun_panel_challenge_buyuse")
    -- challengeticket:RunUpdateScript("indun_panel_update_frame", 1.5)

    local challengeticketcount = ipframe:CreateOrGetControl("richtext", "challengeticketcount", 305, 85, 40, 30)
    challengeticketcount:SetText("{ol}{#FFFFFF}{s16}(" .. INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40") .. "/" ..
                                     INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_40") .. ")")

    local challengeexpertticket = ipframe:CreateOrGetControl('button', 'challengeexpertticket', 390, 80, 80, 30)
    challengeexpertticket:SetText("{ol}{#EE7800}{s14}BUYUSE")
    challengeexpertticket:SetEventScript(ui.LBUTTONUP, "indun_panel_challengeex_buyuse")

    local challengeexpertticketcount = ipframe:CreateOrGetControl("richtext", "challengeexpertticketcount", 475, 85, 40,
        30)
    challengeexpertticketcount:SetText("{ol}{#FFFFFF}{s16}(d" .. INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") ..
                                           "/w" .. INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42") .. "/" ..
                                           (INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_41") +
                                               INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_42")) .. ")")
    -- test
    --  
    -- 
    --  
    challenge460:SetText("{ol}460")
    challenge480:SetText("{ol}480")
    challengept:SetText("{ol}{#FFD900}PT") -- 
    challengeexpert:SetText("{ol}{#FF0000}EX")
    challengecount:SetText("{ol}{#FFFFFF}{s16}(" ..
                               GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType) .. "/" ..
                               GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType) .. ")")
    challengeexpertcount:SetText("{ol}{#FFFFFF}{s16}(" ..
                                     GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 647).PlayPerResetType) .. "" ..
                                     ")")

    challenge460:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge460")
    challenge480:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge480")
    challengept:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challengept")
    challengeexpert:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challengeexpert")
end
--[[
function indun_panel_shop_open()
    -- if INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") == 1 then
    -- g.ex = 1
    -- end

    -- if g.ex ~= 1 then
    local shopframe = ui.GetFrame('earthtowershop')
    pc.ReqExecuteTx_NumArgs("SCR_PVP_MINE_SHOP_OPEN", 0);

    local ipframe = ui.GetFrame("indun_panel")
    local challengeexpertticketcount = GET_CHILD_RECURSIVELY(ipframe, 'challengeexpertticketcount')
    ipframe:RemoveChild(challengeexpertticketcount)
    challengeexpertticketcount:SetText("{ol}{#FFFFFF}{s16}(d" .. INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") ..
                                           "/w" .. INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42") .. "/" ..
                                           (INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_41") +
                                               INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_42")) .. ")")
    ipframe:Invalidate()
    indun_panel_challengeex_buyuse()
    ReserveScript(string.format("INDUN_PANEL_EARTHTOWERSHOP_CLOSE('%s')", shopframe), 1.0)
    return
    -- else
    --      indun_panel_challengeex_buyuse()
    --  end

end
]]
function indun_panel_challengeex_buyuse()

    local dcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41")
    local wcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42")
    if GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 647).PlayPerResetType) == 0 then
        if dcount == 0 then
            local recipeName = "PVP_MINE_42"
            INDUN_PANEL_ITEM_BUY_USE(recipeName)
        else
            g.ex = 1
            local recipeName = "PVP_MINE_41"
            INDUN_PANEL_ITEM_BUY_USE(recipeName)
            -- g.ex = 2
        end
    else
        ui.SysMsg("The number Challenge EX remains")
    end
end

function indun_panel_challenge_buyuse()
    -- CHAT_SYSTEM("test")
    if GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType) == 1 then
        local recipeName = "PVP_MINE_40"
        INDUN_PANEL_ITEM_BUY_USE(recipeName)
    else
        ui.SysMsg("The number of challenge remains")
    end
end

function INDUN_PANEL_EARTHTOWERSHOP_CLOSE(shopframe)
    local shopframe = ui.GetFrame('earthtowershop')
    ui.CloseFrame('earthtowershop')
    -- shopframe:ShowWindow(0)
    -- print("test")
end

function INDUN_PANEL_ITEM_BUY_USE(recipeName)
    -- local shopframe = ui.GetFrame('earthtowershop')
    -- ReserveScript(string.format("INDUN_PANEL_EARTHTOWERSHOP_CLOSE('%s'))", shopframe), 1.0)
    -- local shopframe = ui.GetFrame('earthtowershop')

    local vrecipecls = GetClass('ItemTradeShop', "PVP_MINE_52");
    local voverbuy_max = TryGetProp(vrecipecls, 'MaxOverBuyCount', 0)

    local count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT(recipeName)
    if voverbuy_max >= 1 and recipeName == "PVP_MINE_52" then
        indun_panel_item_overbuy_use(vrecipecls)
        return

    elseif count <= 0 then
        ui.SysMsg("No trade count.")
        return
    end

    local recipeCls = GetClass("ItemTradeShop", recipeName)
    session.ResetItemList()
    session.AddItemID(tostring(0), 1)
    local itemlist = session.GetItemIDList()
    local cntText = string.format("%s %s", tostring(recipeCls.ClassID), tostring(1))
    item.DialogTransaction("PVP_MINE_SHOP", itemlist, cntText)

    local itemCls = GetClass("Item", recipeCls.TargetItem)
    ReserveScript(string.format("INV_ICON_USE(session.GetInvItemByType(%d));", itemCls.ClassID), 1)
    return

end

function indun_panel_item_overbuy_use(recipeCls)
    -- CHAT_SYSTEM(" indun_panel_item_overbuy_use(recipecls)")
    session.ResetItemList()
    session.AddItemID(tostring(0), 1)
    local itemlist = session.GetItemIDList()
    local cntText = string.format("%s %s", tostring(recipeCls.ClassID), tostring(1))
    item.DialogTransaction("PVP_MINE_SHOP", itemlist, cntText)

    local itemCls = GetClass("Item", recipeCls.TargetItem)
    ReserveScript(string.format("INV_ICON_USE(session.GetInvItemByType(%d));", itemCls.ClassID), 1)
    return
end

function INDUN_PANEL_GET_RECIPE_TRADE_COUNT(recipeName)
    local recipeCls = GetClass("ItemTradeShop", recipeName)
    -- DBGOUT("recipeCls: " .. recipeName)
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

function INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT(recipeName)
    local recipeCls = GetClass("ItemTradeShop", recipeName)
    local accountCls = GetClassByType("Account", 1)
    if recipeCls.NeedProperty ~= "None" and recipeCls.NeedProperty ~= "" then
        local sObj = GetSessionObject(GetMyPCObject(), "ssn_shop")
        local sCount = TryGetProp(accountCls, recipeCls.NeedProperty)

        if sCount then
            return sCount
        end
    end

    if recipeCls.AccountNeedProperty ~= "None" and recipeCls.AccountNeedProperty ~= "" then
        -- local aObj = GetMyAccountObj()
        local sCount = TryGetProp(accountCls, recipeCls.AccountNeedProperty)

        if sCount then
            return sCount
        end
    end
    return nil
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
    local topFrame = ui.GetFrame("indunenter")
    -- CHAT_SYSTEM(tostring(topFrame:GetName()))
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
    ReserveScript(string.format("ReqMoveToIndun(%d,%d)", 2, 0), 0.3)

end

function indun_panel_enter_challengeexpert()
    ReqChallengeAutoUIOpen(647)
    local topFrame = ui.GetFrame("indunenter")
    -- CHAT_SYSTEM(tostring(topFrame:GetName()))
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
    ReserveScript(string.format("ReqMoveToIndun(%d,%d)", 2, 0), 0.3)
    -- ReqMoveToIndun(2, 0)
end
