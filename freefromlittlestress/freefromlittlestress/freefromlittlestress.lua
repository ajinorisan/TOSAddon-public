-- v1.0.4 画面右上のミニボタンを街意外だと消す。街にいる場合はマーケットボタンとかが押せるような状態で表示
-- v1.0.4 instantCC用にコンパニオンリストを表示する。既に召喚している場合は表示しない。
-- v1.0.5 ミニお知らせの挙動変更　街ではマケとか見れる様に、フィールドは通常、レイドは全消し
-- v1.0.6 倉庫をチーム倉庫優先に変更
-- v1.0.7 倉庫のダイアログ制御オルシャとフェディにも対応。住居クポルの制御、各種レイド制御。
-- v1.0.8　4人以下押したときの確認を削除
-- v1.0.9 SetupHookの競合修正
-- v1.1.0 激動入り間違え機能を無効に。ペットリストの呼び出しをキャラ毎に設定できるように。
-- v1.1.1 ギルティネハードダイアログ修正
local addonName = "FREEFROMLITTLESTRESS"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.1.1"

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

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

g.settings = {
    rrfp_x = 1100,
    rrfp_y = 100,
    charid = {},
    allcall = 0
}

-- indunframe:ShowWindow(1)

function FREEFROMLITTLESTRESS_SAVE_SETTINGS()
    -- CHAT_SYSTEM("save")
    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function FREEFROMLITTLESTRESS_LOAD_SETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    local loginCharID = info.GetCID(session.GetMyHandle())

    if not settings then
        g.settings = {
            rrfp_x = 1100,
            rrfp_y = 100,
            charid = {
                [loginCharID] = 0
            },
            allcall = 0
        }
        FREEFROMLITTLESTRESS_SAVE_SETTINGS()
        -- ReserveScript("FREEFROMLITTLESTRESS_LOAD_SETTINGS()", 0.1)
        settings = g.settings
    end

    g.settings = settings

    for CharID, v in pairs(g.settings.charid) do
        if not g.settings.charid[loginCharID] then
            g.settings.charid[loginCharID] = 0
            FREEFROMLITTLESTRESS_SAVE_SETTINGS()
            ReserveScript("FREEFROMLITTLESTRESS_LOAD_SETTINGS()", 0.1)
            return
        end
    end

    -- キャラクターIDごとに設定をチェック
    for CharID, v in pairs(g.settings.charid) do
        if CharID == loginCharID then
            g.settings.charid[loginCharID] = v -- キャラクターIDに対応する値を取得
            if v == 1 then
                g.check = 1
                -- CHAT_SYSTEM("CharID " .. CharID .. " has check flag set to 1.")
            else
                g.check = 0
                -- CHAT_SYSTEM("CharID " .. CharID .. " has check flag set to 0.")
            end
        end
    end
end

-- g.settings = setting

function FREEFROMLITTLESTRESS_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    -- CHAT_SYSTEM(addonNameLower .. " loaded")
    FREEFROMLITTLESTRESS_LOAD_SETTINGS()

    g.SetupHook(FREEFROMLITTLESTRESS_INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW, "INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW")
    g.SetupHook(FREEFROMLITTLESTRESS_RAID_RECORD_INIT, "RAID_RECORD_INIT")
    -- g.SetupHook(FREEFROMLITTLESTRESS_SET_PARTYINFO_ITEM, "SET_PARTYINFO_ITEM")
    -- g.SetupHook(FREEFROMLITTLESTRESS_UI_TOGGLE_PETLIST, "UI_TOGGLE_PETLIST")
    -- g.SetupHook(FREEFROMLITTLESTRESS_ON_PARTYINFO_BUFFLIST_UPDATE, "ON_PARTYINFO_BUFFLIST_UPDATE")

    addon:RegisterMsg("RESTART_HERE", "FREEFROMLITTLESTRESS_FRAME_MOVE")
    addon:RegisterMsg("RESTART_CONTENTS_HERE", "FREEFROMLITTLESTRESS_FRAME_MOVE")
    addon:RegisterMsg("DIALOG_CHANGE_SELECT", "FREEFROMLITTLESTRESS_DIALOG_CHANGE_SELECT")

    -- addon:RegisterMsg("PARTY_BUFFLIST_UPDATE", "FREEFROMLITTLESTRESS_BUFFLIST_UPDATE");
    -- addon:RegisterMsg("PARTY_UPDATE", "FREEFROMLITTLESTRESS_BUFFLIST_UPDATE");
    -- addon:RegisterMsg("PARTY_INST_UPDATE", "FREEFROMLITTLESTRESS_BUFFLIST_UPDATE");
    -- addon:RegisterMsg("PARTY_OUT", "FREEFROMLITTLESTRESS_BUFFLIST_UPDATE");
    -- addon:RegisterMsg("INDUNINFO_MAKE_DETAIL_BOSS_SELECT_BY_RAID_TYPE", "FREEFROMLITTLESTRESS_INDUNINFO_UPDATE")

    -- acutil.setupHook(FREEFROMLITTLESTRESS_INDUNINFO_CHAT_OPEN, "INDUNINFO_CHAT_OPEN")

    -- 右上のミニボタンを消したりする機能
    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    -- if mapCls.MapType == "City" then
    if mapCls.MapType ~= "Field" and mapCls.MapType ~= "City" then
        addon:RegisterMsg("GAME_START", "FREEFROMLITTLESTRESS_MINIMIZED_CLOSE")

    end

    if mapCls.MapType == "City" then
        addon:RegisterMsg("GAME_START", "MINIMIZED_TOTAL_SHOP_BUTTON_CLICK")
    end

    -- CHAT_SYSTEM(tostring(g.settings.charid))
    addon:RegisterMsg("GAME_START_3SEC", "FREEFROMLITTLESTRESS_PETLIST_FRAME_INIT")
    addon:RegisterMsg("GAME_START_3SEC", "FREEFROMLITTLESTRESS_PETINFO")
    -- addon:RegisterMsg("GAME_START_3SEC", "FREEFROMLITTLESTRESS_SLOTSET_RESIZE")

    -- addon:RegisterMsg("GAME_START_3SEC", "FREEFROMLITTLESTRESS_ON_OPEN_COMPANIONLIST")

end
-- パーティーバフ欄に必要ないバフID
local excludedBuffIDs = {4732, 4733, 4736, 4735, 4737, 70002, 4731, 4734, 7574, 358, 359, 360, 370, 4136, 4023, 4087,
                         4021, 4024, 3128, 4022, 70056, 70037, 14132, 7771, 7774, 7775, 7776, 7763, 7764, 7765, 7766,
                         7767, 4740, 170005}

function FREEFROMLITTLESTRESS_ON_PARTYINFO_BUFFLIST_UPDATE(frame)
    local frame = ui.GetFrame("partyinfo");
    if frame == nil then
        return;
    end
    local pcparty = session.party.GetPartyInfo();
    if pcparty == nil then
        DESTROY_CHILD_BYNAME(frame, 'PTINFO_');
        frame:ShowWindow(0);
        return;
    end

    local partyInfo = pcparty.info;
    local obj = GetIES(pcparty:GetObject());
    local list = session.party.GetPartyMemberList(0);
    local count = list:Count();
    local memberIndex = 0;

    local myInfo = session.party.GetMyPartyObj();
    -- 접속중 파티원 버프리스트
    for i = 0, count - 1 do
        local partyMemberInfo = list:Element(i);
        if geMapTable.GetMapName(partyMemberInfo:GetMapID()) ~= 'None' then
            local buffCount = partyMemberInfo:GetBuffCount();
            local partyInfoCtrlSet = frame:GetChild('PTINFO_' .. partyMemberInfo:GetAID());
            if partyInfoCtrlSet ~= nil then
                local buffListSlotSet = GET_CHILD(partyInfoCtrlSet, "buffList", "ui::CSlotSet");
                local debuffListSlotSet = GET_CHILD(partyInfoCtrlSet, "debuffList", "ui::CSlotSet");

                -- 초기화
                for j = 0, buffListSlotSet:GetSlotCount() - 1 do
                    local slot = buffListSlotSet:GetSlotByIndex(j);
                    slot:SetKeyboardSelectable(false);
                    if slot == nil then
                        break
                    end
                    slot:ShowWindow(0);
                end

                for j = 0, debuffListSlotSet:GetSlotCount() - 1 do
                    local slot = debuffListSlotSet:GetSlotByIndex(j);
                    if slot == nil then
                        break
                    end
                    slot:ShowWindow(0);
                end

                -- 아이콘 셋팅
                if buffCount <= 0 then
                    partyMemberInfo:ResetBuff();
                    buffCount = partyMemberInfo:GetBuffCount();
                end

                if buffCount > 0 then
                    local buffIndex = 0;
                    local debuffIndex = 0;
                    for j = 0, buffCount - 1 do
                        local buffID = partyMemberInfo:GetBuffIDByIndex(j);

                        local cls = GetClassByType("Buff", buffID);
                        if cls ~= nil and IS_PARTY_INFO_SHOWICON(cls.ShowIcon) == true and cls.ClassName ~= "TeamLevel" then
                            local buffOver = partyMemberInfo:GetBuffOverByIndex(j);
                            local buffTime = partyMemberInfo:GetBuffTimeByIndex(j);
                            local slot = nil;
                            if cls.Group1 == 'Buff' then

                                if not IsBuffExcluded(cls.ClassID, excludedBuffIDs) then
                                    slot = buffListSlotSet:GetSlotByIndex(buffIndex);
                                    buffIndex = buffIndex + 1;
                                    -- CHAT_SYSTEM(tostring(cls.ClassID))

                                end

                            elseif cls.Group1 == 'Debuff' then
                                slot = debuffListSlotSet:GetSlotByIndex(debuffIndex);
                                debuffIndex = debuffIndex + 1;
                            end

                            if slot ~= nil then
                                local icon = slot:GetIcon();
                                if icon == nil then
                                    icon = CreateIcon(slot);
                                end

                                local handle = 0;
                                if myInfo ~= nil then
                                    if myInfo:GetMapID() == partyMemberInfo:GetMapID() and myInfo:GetChannel() ==
                                        partyMemberInfo:GetChannel() then
                                        handle = partyMemberInfo:GetHandle();
                                    end
                                end

                                handle = tostring(handle);
                                icon:SetDrawCoolTimeText(math.floor(buffTime / 1000));
                                icon:SetTooltipType('buff');
                                icon:SetTooltipArg(handle, buffID, "");

                                local imageName = 'icon_' .. TryGetProp(cls, 'Icon', 'None');
                                if imageName ~= "icon_None" then
                                    icon:Set(imageName, 'BUFF', buffID, 0);
                                end

                                if buffOver > 1 then
                                    slot:SetText('{s13}{ol}{b}' .. buffOver, 'count', ui.RIGHT, ui.BOTTOM, 1, 2);
                                else
                                    slot:SetText("");
                                end

                                slot:ShowWindow(1);
                            end
                        end
                    end
                end
            end
        end
    end
end

function IsBuffExcluded(buffID, excludedBuffIDs)
    for _, id in ipairs(excludedBuffIDs) do
        if buffID == id then
            return true -- 除外リストに含まれる場合、trueを返す
        end
    end
    return false -- 除外リストに含まれない場合、falseを返す
end

function FREEFROMLITTLESTRESS_BUFFLIST_UPDATE(frame)

    local frame = ui.GetFrame("partyinfo")
    frame:Resize(600, 320)
    local list = session.party.GetPartyMemberList();
    local count = list:Count();
    -- CHAT_SYSTEM(tostring(count))
    for i = 0, count - 1 do
        local partyMemberInfo = list:Element(i);
        local partyInfoCtrlSet = frame:GetChild('PTINFO_' .. partyMemberInfo:GetAID());
        AUTO_CAST(partyInfoCtrlSet)
        -- CHAT_SYSTEM(tostring(partyInfoCtrlSet))
        partyInfoCtrlSet:Resize(600, 62)
    end

end

function FREEFROMLITTLESTRESS_PETINFO()

    local summonedPet = session.pet.GetSummonedPet();
    if g.settings.allcall == 1 then
        if summonedPet == nil then
            -- CHAT_SYSTEM("呼び出されていない")
            FREEFROMLITTLESTRESS_ON_OPEN_COMPANIONLIST()
            -- return;
        end
    elseif g.settings.allcall == 0 and g.check == 0 then
        if summonedPet == nil then
            -- CHAT_SYSTEM("呼び出されていない")
            FREEFROMLITTLESTRESS_ON_OPEN_COMPANIONLIST()
            -- return;
        end
    else
        return
    end

end

function FREEFROMLITTLESTRESS_PETLIST_FRAME_INIT()

    -- CHAT_SYSTEM("test")
    local frame = ui.GetFrame("companionlist");

    -- frame:ShowWindow(1);
    -- frame:SetGravity(ui.RIGHT, ui.BOTTOM);
    -- frame:SetMargin(0, 0, 350, 70);
    local title = GET_CHILD_RECURSIVELY(frame, "title")
    title:SetGravity(ui.LEFT, ui.TOP);
    title:SetOffset(10, 10);
    local checkbox = GET_CHILD_RECURSIVELY(frame, "checkbox")
    if checkbox ~= nil then

        frame:RemoveChild("checkbox")
    end

    checkbox = frame:CreateOrGetControl("checkbox", "checkbox", 240, 10, 20, 20)
    AUTO_CAST(checkbox)

    checkbox:SetTextTooltip(
        "{@st59}チェックを入れるとコンパニオンリスト呼び出し機能をオフにします(キャラクター毎に設定){nl}Checking the box turns off the companion list call function (set for each character).")

    checkbox:SetCheck(g.check)

    checkbox:SetEventScript(ui.LBUTTONUP, "FREEFROMLITTLESTRESS_CHECK_PET_AUTO")

    local allcall = GET_CHILD_RECURSIVELY(frame, "allcall")
    if allcall ~= nil then

        frame:RemoveChild("allcall")
    end

    allcall = frame:CreateOrGetControl("checkbox", "allcall", 215, 10, 20, 20)
    AUTO_CAST(allcall)

    allcall:SetTextTooltip(
        "{@st59}チェックを入れるとキャラ毎の設定を無視して{nl}コンパニオンリストを呼び出します(アカウント共通){nl}If checked, the companion list is called up,{nl} ignoring the settings for each character (common to all accounts).")

    allcall:SetCheck(g.settings.allcall)

    allcall:SetEventScript(ui.LBUTTONUP, "FREEFROMLITTLESTRESS_CHECK_PET_AUTO")

    -- UPDATE_COMPANIONLIST(frame);

end

function FREEFROMLITTLESTRESS_ON_OPEN_COMPANIONLIST()
    local frame = ui.GetFrame("companionlist");

    frame:SetOffset(800, 500)

    UPDATE_COMPANIONLIST(frame);
    frame:ShowWindow(1);

    ReserveScript("FREEFROMLITTLESTRESS_CLOSE_COMPANIONLIST()", 10.0)
end

function FREEFROMLITTLESTRESS_CHECK_PET_AUTO(frame)

    local checkbox = GET_CHILD_RECURSIVELY(frame, "checkbox")

    local loginCharID = info.GetCID(session.GetMyHandle())

    if checkbox:IsChecked() == 1 then
        g.settings.charid[loginCharID] = 1
        FREEFROMLITTLESTRESS_SAVE_SETTINGS()
        FREEFROMLITTLESTRESS_LOAD_SETTINGS()

    else

        g.settings.charid[loginCharID] = 0
        FREEFROMLITTLESTRESS_SAVE_SETTINGS()
        FREEFROMLITTLESTRESS_LOAD_SETTINGS()
    end

    local allcall = GET_CHILD_RECURSIVELY(frame, "allcall")
    if allcall:IsChecked() == 1 then
        g.settings.allcall = 1
        FREEFROMLITTLESTRESS_SAVE_SETTINGS()
        FREEFROMLITTLESTRESS_LOAD_SETTINGS()

    else

        g.settings.allcall = 0
        FREEFROMLITTLESTRESS_SAVE_SETTINGS()
        FREEFROMLITTLESTRESS_LOAD_SETTINGS()
    end
end

-- 4人以下制御
function FREEFROMLITTLESTRESS_INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW(parent, ctrl)
    local topFrame = parent:GetTopParentFrame();
    -- perent="indunenter"
    -- ctrl="understaffEnterAllowBtn"
    local useCount = tonumber(topFrame:GetUserValue("multipleCount"));
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

    local withMatchMode = topFrame:GetUserValue('WITHMATCH_MODE');
    if topFrame:GetUserValue('AUTOMATCH_MODE') ~= 'YES' and withMatchMode == 'NO' then
        ui.SysMsg(ScpArgMsg('EnableWhenAutoMatching'));
        return;
    end

    local indunType = topFrame:GetUserIValue('INDUN_TYPE');
    local indunCls = GetClassByType('Indun', indunType);
    local UnderstaffEnterAllowMinMember = TryGetProp(indunCls, 'UnderstaffEnterAllowMinMember');
    if UnderstaffEnterAllowMinMember == nil then
        return;
    end

    -- ??티??과 ??동매칭??경우 처리
    local yesScpStr = '_INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW()';
    local clientMsg = ScpArgMsg('ReallyAllowUnderstaffMatchingWith{MIN_MEMBER}?', 'MIN_MEMBER',
        UnderstaffEnterAllowMinMember);
    if INDUNENTER_CHECK_UNDERSTAFF_MODE_WITH_PARTY(topFrame) == true then
        clientMsg = ClMsg('CancelUnderstaffMatching');
    end
    if withMatchMode == 'NO' then
        _INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW()
        -- INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW_OLD(parent, ctrl)
        return

    elseif withMatchMode == 'YES' then
        yesScpStr = 'ReqUnderstaffEnterAllowModeWithParty(' .. indunType .. ')';
        ui.MsgBox(clientMsg, yesScpStr, "None");
    end
    -- base[INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW](parent, ctrl)
end

-- ダイアログ制御系
function FREEFROMLITTLESTRESS_DIALOG_CHANGE_SELECT(frame, msg, argStr, argNum)
    local frame = ui.GetFrame("dialogselect")
    local dframe = ui.GetFrame("dialog")
    -- CHAT_SYSTEM(argStr)
    -- 倉庫
    if argStr == tostring("WAREHOUSE_DLG") or argStr == tostring("ORSHA_WAREHOUSE_DLG") or argStr ==
        tostring("WAREHOUSE_FEDIMIAN_DLG") and msg == ("DIALOG_CHANGE_SELECT") then
        -- CHAT_SYSTEM(msg)
        local frame = ui.GetFrame("dialogselect")
        session.SetSelectDlgList()
        ui.OpenFrame("dialogselect")
        DialogSelect_index = 2;
        local btn2 = GET_CHILD_RECURSIVELY(frame, 'item2Btn')
        local x, y = GET_SCREEN_XY(btn2)
        mouse.SetPos(x + 190, y);
        return
    end
    -- 住居クポル
    if argStr == "NPC_PERSONAL_HOUSING_MANAGER_DLG_2" then

        session.SetSelectDlgList()
        ui.OpenFrame("dialogselect")
        control.DialogItemSelect(1);
        -- test_norisan_DIALOGSELECT_STRING_ENTER_2(frame, msg, argStr, argNum)
        -- control.DialogOk()
        -- DialogSelect_index = 1
    elseif string.find(argStr, "PERSONAL_HOUSING_POINT_CHECK_MSG_1") ~= nil then

        session.SetSelectDlgList()
        ui.OpenFrame("dialogselect")
        control.DialogItemSelect(1);

    elseif string.find(argStr, "PH_POINT_SHOP_DLG_SEL_1") ~= nil then
        session.SetSelectDlgList()
        ui.CloseFrame("dialog")
        ui.OpenFrame("dialogselect")
        DialogSelect_index = 3
        local btn = GET_CHILD_RECURSIVELY(frame, 'item3Btn')
        local x, y = GET_SCREEN_XY(btn)
        mouse.SetPos(x + 190, y);
        return
    end
    -- 各種レイド
    -- CHAT_SYSTEM(argStr)
    -- print(argStr)
    if argStr == "Goddess_Raid_Rozethemiserable_Start_Npc_Dlg" or argStr == "Goddess_Raid_Spreader_Start_Npc_DLG1" or
        argStr == "Goddess_Raid_Jellyzele_Start_Npc_DLG1" or argStr == "EP14_Raid_Delmore_NPC_DLG1" or argStr ==
        "Legend_Raid_Giltine_ENTER_MSG" then

        session.SetSelectDlgList()
        ui.CloseFrame("dialog")
        ui.OpenFrame("dialogselect")
        DialogSelect_index = 2
        local btn = GET_CHILD_RECURSIVELY(frame, 'item2Btn')
        local x, y = GET_SCREEN_XY(btn)
        mouse.SetPos(x + 190, y);
        return

    end
end

function FREEFROMLITTLESTRESS_CLOSE_COMPANIONLIST()
    local frame = ui.GetFrame("companionlist");
    frame:ShowWindow(0);
end

function FREEFROMLITTLESTRESS_MINIMIZED_CLOSE()
    -- "minimized_pvpmine_shop_button"傭兵団ショップ
    -- "minimized_certificate_shop_button"女神の証ショップ

    -- TP受け取りボタン
    local tp_button = ui.GetFrame("openingameshopbtn")
    if tp_button:IsVisible() then
        -- CHAT_SYSTEM("tp_button" .. "が表示されてる")
        tp_button:ShowWindow(0)
    end

    -- ピルグリムボタン
    local pilgrim_mode = ui.GetFrame("minimized_pilgrim_mode")
    if pilgrim_mode:IsVisible() then
        -- CHAT_SYSTEM("pilgrim_mode" .. "が表示されてる")
        pilgrim_mode:ShowWindow(0)
    end

    -- マーケットとかのボタン
    local total_shop_button = ui.GetFrame("minimized_total_shop_button")
    if total_shop_button:IsVisible() then
        -- CHAT_SYSTEM("total_shop_button" .. "が表示されてる")
        total_shop_button:ShowWindow(0)
    end

    -- パーティー募集ボタン
    local total_party_button = ui.GetFrame("minimized_total_party_button")
    if total_party_button:IsVisible() then
        -- CHAT_SYSTEM("total_party_button" .. "が表示されてる")
        total_party_button:ShowWindow(0)
    end

    -- TPショップボタン
    local tpshop_button = ui.GetFrame("minimized_tp_button")
    if tpshop_button:IsVisible() then
        -- CHAT_SYSTEM("tpshop_button" .. "が表示されてる")
        tpshop_button:ShowWindow(0)
    end

    -- 掲示板
    local total_bord = ui.GetFrame("minimized_total_board_button")
    if total_bord:IsVisible() then
        -- CHAT_SYSTEM("total_bord" .. "が表示されてる")
        total_bord:ShowWindow(0)
    end

    -- なんか冒険者ガイドのやつ
    local guidequest = ui.GetFrame("minimized_guidequest_button")
    if guidequest:IsVisible() then
        -- CHAT_SYSTEM("guidequest" .. "が表示されてる")
        guidequest:ShowWindow(0)
    end

    -- menu
    local menu = ui.GetFrame("minimized_fullscreen_navigation_menu_button")
    if menu:IsVisible() then
        -- CHAT_SYSTEM("guidequest" .. "が表示されてる")
        menu:ShowWindow(0)
    end

end

-- 激動の入り間違いを減らす
function FREEFROMLITTLESTRESS_INDUNINFO_DETAIL_BOSS_SELECT_LBTN_CLICK(ctrl_set, btn, clicked)

    if ctrl_set == nil or btn == nil then
        return;
    end
    local parent = ctrl_set:GetParent();
    if IS_INDUNINFO_DETAIL_BOSS_SELECT_LOCK_STATE(ctrl_set) == true then
        return;
    end
    INDUNINFO_DETAIL_BOSS_SELECT_CHECK_UPDATE(parent, ctrl_set);
    if clicked == "click" then
        imcSound.PlaySoundEvent("button_click_7");
    end
    local frame = parent:GetTopParentFrame();

    -- local framename = frame:GetClassName()
    -- print(framename)
    -- ここから追記
    local indunframe = ui.GetFrame("induninfo")
    local indun_cls_name_ffls = ctrl_set:GetName();
    local indun_cls_ffls = GetClass("Indun", indun_cls_name_ffls);
    if indun_cls_name_ffls == nil then
        return;
    end

    -- local group_id = TryGetProp(indun_cls_name_ffls, "GroupID", "None");
    -- local raid_type = TryGetProp(indun_cls_name_ffls, "RaidType", "None");

    -- print(group_id)
    -- print(raid_type)

    ---if group_id == "TurbulentCore" and raid_type == "AutoNormal" then
    -- print("test1")
    -- print("test1")
    -- 
    local indungbox = frame:CreateOrGetControl("groupbox", "textbox_1", 200, 100, 400, 200)
    indungbox:SetSkinName("None")
    indungbox:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    local msgtexts = indungbox:CreateOrGetControl("richtext", "msgtexts_1", 0, 50, 295, 225)
    msgtexts:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    msgtexts:SetText("{@st55_a}Spreader Select")
    local msgtexts2 = indungbox:CreateOrGetControl("richtext", "msgtexts_2", 0, 0, 295, 225)
    msgtexts2:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    msgtexts2:SetText("{@st55_a}プロパゲ行くんか！？")
    local msgtextf = indungbox:CreateOrGetControl("richtext", "msgtextf_1", 0, 50, 295, 225)
    msgtextf:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    msgtextf:SetText("{@st55_a}Falouros Select")
    local msgtextf2 = indungbox:CreateOrGetControl("richtext", "msgtextf_2", 0, 0, 295, 225)
    msgtextf2:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    msgtextf2:SetText("{@st55_a}ファロ行くんか！？")
    if string.match(indun_cls_name_ffls, "Goddess_Raid_Spreader_Auto") then
        msgtextf:ShowWindow(0)
        msgtexts:ShowWindow(1)
        msgtextf2:ShowWindow(0)
        msgtexts2:ShowWindow(1)
        ReserveScript(string.format('FREEFROMLITTLESTRESS_TEXT_DELETE()'), 5.0)

    elseif string.match(indun_cls_name_ffls, "Goddess_Raid_Falouros_Auto") then
        msgtextf:ShowWindow(1)
        msgtexts:ShowWindow(0)
        msgtextf2:ShowWindow(1)
        msgtexts2:ShowWindow(0)
        ReserveScript(string.format('FREEFROMLITTLESTRESS_TEXT_DELETE()'), 5.0)
    else
        FREEFROMLITTLESTRESS_TEXT_DELETE()
    end
    -- else

    --  ReserveScript(string.format('FREEFROMLITTLESTRESS_TEXT_DELETE()'), 0.1)
    -- end
    -- 追記終わり
    local indun_cls_name = ctrl_set:GetName();
    local indun_cls = GetClass("Indun", indun_cls_name);
    if indun_cls == nil then
        return;
    end
    INDUNFINO_MAKE_DETAIL_COMMON_INFO_BY_CATEGORY_TYPE(frame, indun_cls);
    INDUNFINO_MAKE_DETAIL_DUNGEON_RESTRICT_BY_CATEGORY_TYPE(frame, indun_cls);
    INDUNFINO_MAKE_DETAIL_ITEM_LIST_INFO_SETTING(frame, indun_cls);

end

function FREEFROMLITTLESTRESS_TEXT_DELETE()
    local indunframe = ui.GetFrame("induninfo")
    local indungbox = GET_CHILD_RECURSIVELY(indunframe, "textbox_1")

    indungbox:RemoveAllChild()

    indunframe:Invalidate()
end
-- レイドクリアー時のフレームを移動して場所を覚えさせる。
function FREEFROMLITTLESTRESS_UPDATESETTINGS(frame)
    if g.settings.rrfp_x ~= frame:GetX() or g.settings.rrfp_y ~= frame:GetY() then
        g.settings.rrfp_x = frame:GetX()
        g.settings.rrfp_y = frame:GetY()
        FREEFROMLITTLESTRESS_SAVE_SETTINGS()
    end
end

function FREEFROMLITTLESTRESS_RAID_RECORD_INIT(frame)
    local frame = ui.GetFrame("raid_record")
    frame:SetOffset(g.settings.rrfp_x, g.settings.rrfp_y)
    frame:SetSkinName("shadow_box")
    frame:SetEventScript(ui.LBUTTONUP, "FREEFROMLITTLESTRESS_UPDATESETTINGS")
    frame:SetLayerLevel(5)
    frame:SetTitleBarSkin("None")
    frame:ShowTitleBar(0)
    frame:Resize(550, 260)

    local widgetList = {{
        name = "myInfo",
        font = "white_16_ol"
    }, {
        name = "friendInfo1",
        font = "white_16_ol"
    }, {
        name = "friendInfo2",
        font = "white_16_ol"
    }, {
        name = "friendInfo3",
        font = "white_16_ol"
    }}

    for i, widgetData in ipairs(widgetList) do
        local widget = GET_CHILD_RECURSIVELY(frame, widgetData.name)
        local name = GET_CHILD_RECURSIVELY(widget, "name")
        local time = GET_CHILD_RECURSIVELY(widget, "time")
        name:SetFontName(widgetData.font)
        time:SetFontName(widgetData.font)
    end

    GET_CHILD_RECURSIVELY(frame, "bgIndunClear"):ShowWindow(1)
    GET_CHILD_RECURSIVELY(frame, "textNewRecord"):ShowWindow(0)
end

-- 死んだ時に現れるフレームを移動可能に
function FREEFROMLITTLESTRESS_FRAME_MOVE()

    local rcframe = ui.GetFrame("restart_contents") -- フレームを移動可能に設定する
    rcframe:EnableMove(1)

    -- 多分コロニー時はこっちちゃうかな
    local rframe = ui.GetFrame("restart") -- フレームを移動可能に設定する
    rframe:EnableMove(1)
    rframe:SetSkinName("None")
    local buttonSkin = "chat_window" -- 適用したいスキンの名前
    local buttonNames = {"btn_restart_1", "btn_restart_2", "btn_restart_3", "btn_restart_4", "btn_restart_5"}

    for i, buttonName in ipairs(buttonNames) do
        local button = GET_CHILD_RECURSIVELY(rframe, buttonName)
        if button ~= nil then
            button:SetSkinName(buttonSkin)
        end
    end

end
