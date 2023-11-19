-- v1.0.0 freefromtrivialsttresからの焼き直し。オートキャスティングをキャラ毎に。機能の有効化無効化を選択出来る様に。
-- v1.0.1 チェック外したら機能しない様に。各キャラ毎のオートキャスティングを直したと思う
-- v1.0.2 ADDONSに表示されない人がいるのでMINIMAP左下ボタンに変更
-- v1.0.3 バフ一覧設定がテレコになっていたのを修正。センスのないボタンを変更
local addonName = "MINI_ADDONS"
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

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

function MINI_ADDONS_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    -- acutil.addSysIcon("mini_addons", "sysmenu_mac", "Mini Addons", "MINI_ADDONS_SETTING_FRAME_INIT")
    MINI_ADDONS_LOAD_SETTINGS()
    -- CHAT_SYSTEM("test")
    g.SetupHook(MINI_ADDONS_INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW, "INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW")

    g.SetupHook(MINI_ADDONS_RAID_RECORD_INIT, "RAID_RECORD_INIT")

    g.SetupHook(MINI_ADDONS_ON_PARTYINFO_BUFFLIST_UPDATE, "ON_PARTYINFO_BUFFLIST_UPDATE")

    g.SetupHook(MINI_ADDONS_CHAT_SYSTEM, "CHAT_SYSTEM")

    g.SetupHook(MINI_ADDONS_UPDATE_CURRENT_CHANNEL_TRAFFIC, "UPDATE_CURRENT_CHANNEL_TRAFFIC")

    g.SetupHook(MINI_ADDONS_CONFIG_ENABLE_AUTO_CASTING, "CONFIG_ENABLE_AUTO_CASTING")

    --[[acutil.setupHook(MINI_ADDONS_INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW, "INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW")

    acutil.setupHook(MINI_ADDONS_RAID_RECORD_INIT, "RAID_RECORD_INIT")

    acutil.setupHook(MINI_ADDONS_ON_PARTYINFO_BUFFLIST_UPDATE, "ON_PARTYINFO_BUFFLIST_UPDATE")

    acutil.setupHook(MINI_ADDONS_CHAT_SYSTEM, "CHAT_SYSTEM")

    acutil.setupHook(MINI_ADDONS_UPDATE_CURRENT_CHANNEL_TRAFFIC, "UPDATE_CURRENT_CHANNEL_TRAFFIC")

    acutil.setupHook(MINI_ADDONS_CONFIG_ENABLE_AUTO_CASTING, "CONFIG_ENABLE_AUTO_CASTING")]]

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if g.settings.mini_btn == 1 then
        -- 右上のミニボタンを消したりする機能

        if mapCls.MapType ~= "Field" and mapCls.MapType ~= "City" then
            addon:RegisterMsg("GAME_START", "MINI_ADDONS_MINIMIZED_CLOSE")
        end
    end

    if g.settings.market_display == 1 then
        if mapCls.MapType == "City" then
            addon:RegisterMsg("GAME_START", "MINIMIZED_TOTAL_SHOP_BUTTON_CLICK")
        end
    end

    if g.settings.restart_move == 1 then
        addon:RegisterMsg("RESTART_HERE", "MINI_ADDONS_FRAME_MOVE")
        addon:RegisterMsg("RESTART_CONTENTS_HERE", "MINI_ADDONS_FRAME_MOVE")
    end

    if g.settings.pet_init == 1 then
        addon:RegisterMsg("GAME_START_3SEC", "MINI_ADDONS_PETLIST_FRAME_INIT")
        addon:RegisterMsg("GAME_START_3SEC", "MINI_ADDONS_PETINFO")
    end

    if g.settings.dialog_ctrl == 1 then
        addon:RegisterMsg("DIALOG_CHANGE_SELECT", "MINI_ADDONS_DIALOG_CHANGE_SELECT")
    end

    if g.settings.auto_cast == 1 then
        addon:RegisterMsg("GAME_START_3SEC", "MINI_ADDONS_SET_ENABLE_AUTO_CASTING_3SEC")
    end

    MINI_ADDONS_NEW_FRAME_INIT()
end

g.settings = {
    reword_x = 1100,
    reword_y = 100,
    charid = {},
    allcall = 0,
    under_staff = 1,
    raid_record = 1,
    party_buff = 1,
    chat_system = 1,
    channel_display = 1,
    mini_btn = 1,
    market_display = 1,
    restart_move = 1,
    pet_init = 1,
    dialog_ctrl = 1,
    auto_cast = 1,
    auto_casting = {}
}
-- オートキャスティング制御
function MINI_ADDONS_CONFIG_ENABLE_AUTO_CASTING(parent, ctrl)

    local loginCharID = info.GetCID(session.GetMyHandle())
    local enable = ctrl:IsChecked()

    if g.settings.auto_cast == 1 then
        -- CHAT_SYSTEM("test" .. ":1")
        -- CHAT_SYSTEM(tostring(enable))
        g.settings.auto_casting[loginCharID] = enable
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
        config.SetEnableAutoCasting(enable)
        config.SaveConfig()
    else
        -- CHAT_SYSTEM("test" .. ":0")
        g.settings.auto_casting[loginCharID] = enable
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
        config.SetEnableAutoCasting(enable)
        config.SaveConfig()
    end
end

function MINI_ADDONS_SET_ENABLE_AUTO_CASTING_3SEC()
    local systemoption_frame = ui.GetFrame("systemoption")

    MINI_ADDONS_SET_ENABLE_AUTO_CASTING(systemoption_frame)
end

function MINI_ADDONS_SET_ENABLE_AUTO_CASTING(frame)
    local systemoption_frame = ui.GetFrame("systemoption")
    local Check_EnableAutoCasting =
        GET_CHILD_RECURSIVELY(systemoption_frame, "Check_EnableAutoCasting", "ui::CCheckBox")
    local loginCharID = info.GetCID(session.GetMyHandle())

    for CharID, v in pairs(g.settings.auto_casting) do

        if CharID == loginCharID then
            g.settings.auto_casting[loginCharID] = v -- キャラクターIDに対応する値を取得
            if v == 1 then
                if Check_EnableAutoCasting ~= nil then
                    Check_EnableAutoCasting:SetCheck(tostring(v))
                end
                local enable = Check_EnableAutoCasting:IsChecked()
                config.SetEnableAutoCasting(enable)
                config.SaveConfig()
                -- CHAT_SYSTEM("test" .. tostring(enable))
            else
                if Check_EnableAutoCasting ~= nil then
                    Check_EnableAutoCasting:SetCheck(tostring(v))
                end
                local enable = Check_EnableAutoCasting:IsChecked()
                config.SetEnableAutoCasting(enable)
                config.SaveConfig()
                -- CHAT_SYSTEM("test" .. tostring(enable))
            end
        end
    end

end

function MINI_ADDONS_FRAME_CLOSE(frame)
    local frame = ui.GetFrame("mini_addons")
    frame:ShowWindow(0)

end

function MINI_ADDONS_NEW_FRAME_INIT()

    local newframe = ui.CreateNewFrame("notice_on_pc", "mini_addons_new", 0, 0, 110, 50)
    AUTO_CAST(newframe)

    newframe:SetSkinName('None')
    newframe:Resize(30, 30)
    newframe:SetPos(1580, 305)
    newframe:SetTitleBarSkin("None")

    local btn = newframe:CreateOrGetControl('button', 'mini', 0, 0, 25, 30)
    btn:SetSkinName("None")
    -- btn:SetText("{img mine_pvp_icon_player 30 30}")
    btn:SetText("{img sysmenu_mac 30 30}")
    btn:SetTextTooltip("{@st59}Mini Addons setting{nl}Mini Addons設定{/}")

    btn:SetEventScript(ui.LBUTTONDOWN, "MINI_ADDONS_SETTING_FRAME_INIT")

    newframe:ShowWindow(1)
end

function MINI_ADDONS_SETTING_FRAME_INIT()
    local frame = ui.GetFrame("mini_addons")

    -- frame:SetSkinName("test_frame_low")
    frame:SetSkinName("bg")
    frame:SetLayerLevel(93)
    frame:Resize(710, 380)
    frame:SetPos(1150, 400)
    frame:ShowTitleBar(0);
    frame:EnableHittestFrame(1)
    frame:EnableHide(0)
    frame:EnableHitTest(1)
    frame:SetAlpha(100)
    frame:RemoveAllChild()
    frame:ShowWindow(1)

    local close = frame:CreateOrGetControl("button", "close", 670, 10, 25, 25)
    close:SetText("{ol}{#FFFFFF}×")
    close:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_FRAME_CLOSE")

    local under_staff = frame:CreateOrGetControl("richtext", "under_staff", 40, 15)
    under_staff:SetText("{ol}{#FFFFFF}Skip confirmation for admission of 4 or less people")
    under_staff:SetTextTooltip(
        "{@st59}4人以下入場時の確認をスキップ{nl}4인 이하 입장 시 확인 생략")

    local under_staff_checkbox = frame:CreateOrGetControl('checkbox', 'under_staff_checkbox', 10, 10, 25, 25)
    AUTO_CAST(under_staff_checkbox)
    under_staff_checkbox:SetCheck(g.settings.under_staff)
    under_staff_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    under_staff_checkbox:SetTextTooltip(
        "{@st59}チェックすると有効化{nl}Check to enable{nl}체크하면 활성화")

    local raid_record = frame:CreateOrGetControl("richtext", "raid_record", 40, 45)
    raid_record:SetText("{ol}{#FFFFFF}Raid records movable and resizable")
    raid_record:SetTextTooltip(
        "{@st59}レイドレコードを移動可能にしてサイズを変更{nl}레이드 레코드의 이동 및 크기 변경 가능")

    local raid_record_checkbox = frame:CreateOrGetControl('checkbox', 'raid_record_checkbox', 10, 40, 25, 25)
    AUTO_CAST(raid_record_checkbox)
    raid_record_checkbox:SetCheck(g.settings.raid_record)
    raid_record_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    raid_record_checkbox:SetTextTooltip(
        "{@st59}チェックすると有効化{nl}Check to enable{nl}체크하면 활성화")

    local party_buff = frame:CreateOrGetControl("richtext", "party_buff", 40, 75)
    party_buff:SetText("{ol}{#FFFFFF}Ability to reduce the display of buffs for party members")
    party_buff:SetTextTooltip(
        "{@st59}パーティメンバーのバフ表示を減らす機能{nl}파티원의 버프 표시를 줄이는 기능")

    local party_buff_checkbox = frame:CreateOrGetControl('checkbox', 'party_buff_checkbox', 10, 70, 25, 25)
    AUTO_CAST(party_buff_checkbox)
    party_buff_checkbox:SetCheck(g.settings.party_buff)
    party_buff_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    party_buff_checkbox:SetTextTooltip(
        "{@st59}チェックすると有効化{nl}Check to enable{nl}체크하면 활성화")

    local chat_system = frame:CreateOrGetControl("richtext", "chat_system", 40, 105)
    chat_system:SetText("{ol}{#FFFFFF}Perfect effect is not displayed in system chat")
    chat_system:SetTextTooltip(
        "{@st59}パーフェクト効果をシステムチャットに表示しない{nl}시스템 채팅에 퍼펙트 효과를 표시하지 않음")

    local chat_system_checkbox = frame:CreateOrGetControl('checkbox', 'chat_system_checkbox', 10, 100, 25, 25)
    AUTO_CAST(chat_system_checkbox)
    chat_system_checkbox:SetCheck(g.settings.chat_system)
    chat_system_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    chat_system_checkbox:SetTextTooltip(
        "{@st59}チェックすると有効化{nl}Check to enable{nl}체크하면 활성화")

    local channel_display = frame:CreateOrGetControl("richtext", "channel_display", 40, 135)
    channel_display:SetText("{ol}{#FFFFFF}Fixed channel display misalignment")
    channel_display:SetTextTooltip(
        "{@st59}チャンネル表示のズレを修正{nl}채널 표시가 어긋나는 현상 수정")

    local channel_display_checkbox = frame:CreateOrGetControl('checkbox', 'channel_display_checkbox', 10, 130, 25, 25)
    AUTO_CAST(channel_display_checkbox)
    channel_display_checkbox:SetCheck(g.settings.channel_display)
    channel_display_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    channel_display_checkbox:SetTextTooltip(
        "{@st59}チェックすると有効化{nl}Check to enable{nl}체크하면 활성화")

    local mini_btn = frame:CreateOrGetControl("richtext", "mini_btn", 40, 165)
    mini_btn:SetText("{ol}{#FFFFFF}Hide mini-button in upper right corner during raid")
    mini_btn:SetTextTooltip(
        "{@st59}レイド時右上のミニボタン非表示{nl}레이드 시 오른쪽 상단 미니 버튼 숨기기")

    local mini_btn_checkbox = frame:CreateOrGetControl('checkbox', 'mini_btn_checkbox', 10, 160, 25, 25)
    AUTO_CAST(mini_btn_checkbox)
    mini_btn_checkbox:SetCheck(g.settings.mini_btn)
    mini_btn_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    mini_btn_checkbox:SetTextTooltip(
        "{@st59}チェックすると有効化{nl}Check to enable{nl}체크하면 활성화")

    local market_display = frame:CreateOrGetControl("richtext", "market_display", 40, 195)
    market_display:SetText(
        "{ol}{#FFFFFF}When moving into town, the list of stores in the upper right corner should be open.")
    market_display:SetTextTooltip(
        "{@st59}街に移動時、右上の商店一覧を開けた状態にします。{nl}거리로 이동할 때, 오른쪽 상단의 상점 목록이 열린 상태로 만듭니다.")

    local market_display_checkbox = frame:CreateOrGetControl('checkbox', 'market_display_checkbox', 10, 190, 25, 25)
    AUTO_CAST(market_display_checkbox)
    market_display_checkbox:SetCheck(g.settings.market_display)
    market_display_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    market_display_checkbox:SetTextTooltip(
        "{@st59}チェックすると有効化{nl}Check to enable{nl}체크하면 활성화")

    local restart_move = frame:CreateOrGetControl("richtext", "restart_move", 40, 225)
    restart_move:SetText("{ol}{#FFFFFF}Enable to move the choice frame at restart. For colony visits.")
    restart_move:SetTextTooltip(
        "{@st59}リスタート時の選択肢フレームを動かせる様にします。コロニー見学用。{nl}재시작 시 선택 프레임을 움직일 수 있도록 합니다. 식민지 견학용.")

    local restart_move_checkbox = frame:CreateOrGetControl('checkbox', 'restart_move_checkbox', 10, 220, 25, 25)
    AUTO_CAST(restart_move_checkbox)
    restart_move_checkbox:SetCheck(g.settings.restart_move)
    restart_move_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    restart_move_checkbox:SetTextTooltip(
        "{@st59}チェックすると有効化{nl}Check to enable{nl}체크하면 활성화")

    local pet_init = frame:CreateOrGetControl("richtext", "pet_init", 40, 255)
    pet_init:SetText("{ol}{#FFFFFF}Ability to display a pet summoning frame.")
    pet_init:SetTextTooltip(
        "{@st59}ペット召喚フレームを表示する機能。{nl}애완동물 소환 프레임을 표시하는 기능.")

    local pet_init_checkbox = frame:CreateOrGetControl('checkbox', 'pet_init_checkbox', 10, 250, 25, 25)
    AUTO_CAST(pet_init_checkbox)
    pet_init_checkbox:SetCheck(g.settings.pet_init)
    pet_init_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    pet_init_checkbox:SetTextTooltip(
        "{@st59}チェックすると有効化{nl}Check to enable{nl}체크하면 활성화")

    local dialog_ctrl = frame:CreateOrGetControl("richtext", "dialog_ctrl", 40, 285)
    dialog_ctrl:SetText("{ol}{#FFFFFF}Controls various dialogs.")
    dialog_ctrl:SetTextTooltip(
        "{@st59}各種ダイアログをコントロールします。{nl}각종 대화 상자를 제어합니다.")

    local dialog_ctrl_checkbox = frame:CreateOrGetControl('checkbox', 'dialog_ctrl_checkbox', 10, 280, 25, 25)
    AUTO_CAST(dialog_ctrl_checkbox)
    dialog_ctrl_checkbox:SetCheck(g.settings.dialog_ctrl)
    dialog_ctrl_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    dialog_ctrl_checkbox:SetTextTooltip(
        "{@st59}チェックすると有効化{nl}Check to enable{nl}체크하면 활성화")

    local auto_cast = frame:CreateOrGetControl("richtext", "auto_cast", 40, 315)
    auto_cast:SetText("{ol}{#FFFFFF}Autocasting is set up for each character.")
    auto_cast:SetTextTooltip(
        "{@st59}オートキャスティングをキャラ毎に設定。{nl}자동 캐스팅을 캐릭터별로 설정합니다.")

    local auto_cast_checkbox = frame:CreateOrGetControl('checkbox', 'auto_cast_checkbox', 10, 310, 25, 25)
    AUTO_CAST(auto_cast_checkbox)
    auto_cast_checkbox:SetCheck(g.settings.auto_cast)
    auto_cast_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    auto_cast_checkbox:SetTextTooltip(
        "{@st59}チェックすると有効化{nl}Check to enable{nl}체크하면 활성화")

    local description = frame:CreateOrGetControl("richtext", "description", 140, 345)
    description:SetText("{ol}{#FFA500}※Character change is required to enable or disable some functions.")
    description:SetTextTooltip(
        "{@st59}一部の機能の有効化、無効化の切替はキャラクターチェンジが必要です。{nl}일부 기능의 활성화, 비활성화 전환은 캐릭터 변경이 필요합니다.")
end

function MINI_ADDONS_ISCHECK(frame, ctrl, argStr, argNum)

    local ischeck = ctrl:IsChecked();
    local ctrlname = ctrl:GetName()

    if ischeck == 1 and ctrlname == "under_staff_checkbox" then
        g.settings.under_staff = 1
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    elseif ischeck == 0 and ctrlname == "under_staff_checkbox" then
        g.settings.under_staff = 0
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    end

    if ischeck == 1 and ctrlname == "raid_record_checkbox" then
        g.settings.raid_record = 1
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    elseif ischeck == 0 and ctrlname == "raid_record_checkbox" then
        g.settings.raid_record = 0
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    end

    if ischeck == 1 and ctrlname == "party_buff_checkbox" then
        g.settings.party_buff = 1
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    elseif ischeck == 0 and ctrlname == "party_buff_checkbox" then
        g.settings.party_buff = 0
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    end

    if ischeck == 1 and ctrlname == "chat_system_checkbox" then
        g.settings.chat_system = 1
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    elseif ischeck == 0 and ctrlname == "chat_system_checkbox" then
        g.settings.chat_system = 0
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    end

    if ischeck == 1 and ctrlname == "channel_display_checkbox" then
        g.settings.channel_display = 1
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    elseif ischeck == 0 and ctrlname == "channel_display_checkbox" then
        g.settings.channel_display = 0
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    end

    if ischeck == 1 and ctrlname == "mini_btn_checkbox" then
        g.settings.mini_btn = 1
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    elseif ischeck == 0 and ctrlname == "mini_btn_checkbox" then
        g.settings.mini_btn = 0
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    end

    if ischeck == 1 and ctrlname == "market_display_checkbox" then
        g.settings.market_display = 1
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    elseif ischeck == 0 and ctrlname == "market_display_checkbox" then
        g.settings.market_display = 0
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    end

    if ischeck == 1 and ctrlname == "restart_move_checkbox" then
        g.settings.restart_move = 1
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    elseif ischeck == 0 and ctrlname == "restart_move_checkbox" then
        g.settings.restart_move = 0
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    end

    if ischeck == 1 and ctrlname == "pet_init_checkbox" then
        g.settings.pet_init = 1
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    elseif ischeck == 0 and ctrlname == "pet_init_checkbox" then
        g.settings.pet_init = 0
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    end

    if ischeck == 1 and ctrlname == "dialog_ctrl_checkbox" then
        g.settings.dialog_ctrl = 1
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    elseif ischeck == 0 and ctrlname == "dialog_ctrl_checkbox" then
        g.settings.dialog_ctrl = 0
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    end

    if ischeck == 1 and ctrlname == "auto_cast_checkbox" then
        g.settings.auto_cast = 1
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    elseif ischeck == 0 and ctrlname == "auto_cast_checkbox" then
        g.settings.auto_cast = 0
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    end

end

function MINI_ADDONS_SAVE_SETTINGS()

    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function MINI_ADDONS_LOAD_SETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    local loginCharID = info.GetCID(session.GetMyHandle())

    if not settings then
        g.settings = {

            reword_x = 1100,
            reword_y = 100,
            charid = {
                [loginCharID] = 0
            },
            allcall = 0,
            under_staff = 1,
            raid_record = 1,
            party_buff = 1,
            chat_system = 1,
            channel_display = 1,
            mini_btn = 1,
            market_display = 1,
            restart_move = 1,
            pet_init = 1,
            dialog_ctrl = 1,
            auto_cast = 1,
            auto_casting = {}
        }
        MINI_ADDONS_SAVE_SETTINGS()

        settings = g.settings
    end

    g.settings = settings

    if next(g.settings.auto_casting) == nil then

        g.settings.auto_casting[loginCharID] = 1
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    end

    for CharID, v in pairs(g.settings.auto_casting) do
        if not g.settings.auto_casting[loginCharID] then

            g.settings.auto_casting[loginCharID] = 1
            MINI_ADDONS_SAVE_SETTINGS()
            MINI_ADDONS_LOAD_SETTINGS()

        end
    end

    if next(g.settings.charid) == nil then
        g.settings.charid[loginCharID] = 0
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    end
    -- print(tostring(next(g.settings.charid)))
    for CharID, v in pairs(g.settings.charid) do
        if not g.settings.charid[loginCharID] then
            g.settings.charid[loginCharID] = 0
            MINI_ADDONS_SAVE_SETTINGS()
            MINI_ADDONS_LOAD_SETTINGS()
            return
        end
    end

    -- キャラクターIDごとに設定をチェック
    for CharID, v in pairs(g.settings.charid) do
        if CharID == loginCharID then
            g.settings.charid[loginCharID] = v -- キャラクターIDに対応する値を取得
            if v == 1 then
                g.check = 1

            else
                g.check = 0

            end
        end
    end
end

function MINI_ADDONS_UPDATE_CURRENT_CHANNEL_TRAFFIC(frame)
    local curchannel = frame:GetChild("curchannel");

    local channel = session.loginInfo.GetChannel();
    local zoneInst = session.serverState.GetZoneInst(channel);
    if g.settings.channel_display == 1 then
        local langcode = option.GetCurrentCountry()
        if langcode == "Japanese" then
            if zoneInst ~= nil then
                if GET_PRIVATE_CHANNEL_ACTIVE_STATE() == false then
                    local str, stateString = GET_CHANNEL_STRING(zoneInst);
                    curchannel:SetTextByKey("value", str .. "                      " .. stateString);
                else
                    local suffix = GET_SUFFIX_PRIVATE_CHANNEL(zoneInst.mapID, zoneInst.channel + 1)
                    local str, stateString = GET_CHANNEL_STRING(zoneInst, suffix);
                    curchannel:SetTextByKey("value", str .. "                      " .. stateString);
                end
            else
                curchannel:SetTextByKey("value", "");
            end
        else
            if zoneInst ~= nil then
                if GET_PRIVATE_CHANNEL_ACTIVE_STATE() == false then
                    local str, stateString = GET_CHANNEL_STRING(zoneInst);
                    curchannel:SetTextByKey("value", str .. "                                  " .. stateString);
                else
                    local suffix = GET_SUFFIX_PRIVATE_CHANNEL(zoneInst.mapID, zoneInst.channel + 1)
                    local str, stateString = GET_CHANNEL_STRING(zoneInst, suffix);
                    curchannel:SetTextByKey("value", str .. "                                  " .. stateString);
                end
            else
                curchannel:SetTextByKey("value", "");
            end

        end
    else
        if zoneInst ~= nil then
            if GET_PRIVATE_CHANNEL_ACTIVE_STATE() == false then
                local str, stateString = GET_CHANNEL_STRING(zoneInst);
                curchannel:SetTextByKey("value", str .. "                                  " .. stateString);
            else
                local suffix = GET_SUFFIX_PRIVATE_CHANNEL(zoneInst.mapID, zoneInst.channel + 1)
                local str, stateString = GET_CHANNEL_STRING(zoneInst, suffix);
                curchannel:SetTextByKey("value", str .. "                                  " .. stateString);
            end
        else
            curchannel:SetTextByKey("value", "");
        end
    end
end
--[[5014
[__m2util] is loaded
[adjustlayer] is loaded
[extendcharinfo] is loaded]]

function MINI_ADDONS_CHAT_SYSTEM(msg, color)

    if g.settings.chat_system == 1 then
        if msg == "@dicID_^*$ETC_20220830_069434$*^" or msg == "@dicID_^*$ETC_20220830_069435$*^" or msg ==
            "[__m2util] is loaded" or msg == "[adjustlayer] is loaded" or msg == "[extendcharinfo] is loaded" or msg ==
            "[ICC]Attempt to CC." then
            return
        end
    end
    session.ui.GetChatMsg():AddSystemMsg(msg, true, 'System', color)
end

-- パーティーバフ欄に必要ないバフID
local excludedBuffIDs = {4732, 4733, 4736, 4735, 4737, 70002, 4731, 4734, 7574, 358, 359, 360, 370, 4136, 4023, 4087,
                         4021, 4024, 3128, 4022, 70056, 70037, 14132, 7771, 7774, 7775, 7776, 7763, 7764, 7765, 7766,
                         7767, 4740, 170005, 80015, 80016, 80017, 80018, 80019, 80020, 80021, 80022, 80023, 80024,
                         80025, 80026, 80027, 80030, 80031, 14115, 70065, 14125, 4256, 157, 67, 36, 375, 452, 70053,
                         3127, 3137, 3145, 330, 138, 30002, 4206, 4207, 4211, 4753, 690017, 690018, 70042, 1011, 419,
                         468, 6008, 100017, 110016, 2132, 5173, 620021, 640041, 693008, 696107, 99000, 99900, 99917,
                         14128, 691, 647, 646, 3129, 3133, 3147, 3127, 3137, 3145, 7014, 7031}

function MINI_ADDONS_ON_PARTYINFO_BUFFLIST_UPDATE(frame)
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
                                if g.settings.party_buff == 1 then
                                    if not MINI_ADDONS_IsBuffExcluded(cls.ClassID, excludedBuffIDs) then
                                        slot = buffListSlotSet:GetSlotByIndex(buffIndex);
                                        buffIndex = buffIndex + 1;

                                    end
                                else
                                    slot = buffListSlotSet:GetSlotByIndex(buffIndex);
                                    buffIndex = buffIndex + 1;
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

function MINI_ADDONS_IsBuffExcluded(buffID, excludedBuffIDs)
    for _, id in ipairs(excludedBuffIDs) do
        if buffID == id then
            return true -- 除外リストに含まれる場合、trueを返す
        end
    end
    return false -- 除外リストに含まれない場合、falseを返す
end

--[[function MINI_ADDONS_BUFFLIST_UPDATE(frame)

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

end]]

function MINI_ADDONS_PETINFO()

    local summonedPet = session.pet.GetSummonedPet();
    if g.settings.allcall == 1 then
        if summonedPet == nil then
            -- CHAT_SYSTEM("呼び出されていない")
            MINI_ADDONS_ON_OPEN_COMPANIONLIST()
            -- return;
        end
    elseif g.settings.allcall == 0 and g.check == 0 then
        if summonedPet == nil then
            -- CHAT_SYSTEM("呼び出されていない")
            MINI_ADDONS_ON_OPEN_COMPANIONLIST()
            -- return;
        end
    else
        return
    end

end

function MINI_ADDONS_PETLIST_FRAME_INIT()

    local frame = ui.GetFrame("companionlist");

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

    checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_CHECK_PET_AUTO")

    local allcall = GET_CHILD_RECURSIVELY(frame, "allcall")
    if allcall ~= nil then

        frame:RemoveChild("allcall")
    end

    allcall = frame:CreateOrGetControl("checkbox", "allcall", 215, 10, 20, 20)
    AUTO_CAST(allcall)

    allcall:SetTextTooltip(
        "{@st59}チェックを入れるとキャラ毎の設定を無視して{nl}コンパニオンリストを呼び出します(アカウント共通){nl}If checked, the companion list is called up,{nl} ignoring the settings for each character (common to all accounts).")

    allcall:SetCheck(g.settings.allcall)

    allcall:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_CHECK_PET_AUTO")

    -- UPDATE_COMPANIONLIST(frame);

end

function MINI_ADDONS_ON_OPEN_COMPANIONLIST()
    local frame = ui.GetFrame("companionlist");

    frame:SetOffset(800, 500)

    UPDATE_COMPANIONLIST(frame);
    frame:ShowWindow(1);

    ReserveScript("MINI_ADDONS_CLOSE_COMPANIONLIST()", 10.0)
end

function MINI_ADDONS_CHECK_PET_AUTO(frame)

    local checkbox = GET_CHILD_RECURSIVELY(frame, "checkbox")

    local loginCharID = info.GetCID(session.GetMyHandle())

    if checkbox:IsChecked() == 1 then
        g.settings.charid[loginCharID] = 1
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()

    else

        g.settings.charid[loginCharID] = 0
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    end

    local allcall = GET_CHILD_RECURSIVELY(frame, "allcall")
    if allcall:IsChecked() == 1 then
        g.settings.allcall = 1
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()

    else

        g.settings.allcall = 0
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    end
end

-- 4人以下制御
function MINI_ADDONS_INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW(parent, ctrl)
    local topFrame = parent:GetTopParentFrame();
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

    if withMatchMode == 'YES' then
        yesScpStr = 'ReqUnderstaffEnterAllowModeWithParty(' .. indunType .. ')';
    end

    if g.settings.under_staff == 1 then
        if withMatchMode == 'NO' then
            _INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW()
            -- INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW_OLD(parent, ctrl)
            return
        end
    end

    ui.MsgBox(clientMsg, yesScpStr, "None");

    -- base[INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW](parent, ctrl)
end

-- ダイアログ制御系
function MINI_ADDONS_DIALOG_CHANGE_SELECT(frame, msg, argStr, argNum)
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
    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    if argStr == "Goddess_Raid_Rozethemiserable_Start_Npc_Dlg" or argStr == "Goddess_Raid_Spreader_Start_Npc_DLG1" or
        argStr == "Goddess_Raid_Jellyzele_Start_Npc_DLG1" or argStr == "EP14_Raid_Delmore_NPC_DLG1" or
        (argStr == "Legend_Raid_Giltine_ENTER_MSG" and curMap == "raid_dcapital_108") then

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

function MINI_ADDONS_CLOSE_COMPANIONLIST()
    local frame = ui.GetFrame("companionlist");
    frame:ShowWindow(0);
end

function MINI_ADDONS_MINIMIZED_CLOSE()
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

-- レイドクリアー時のフレームを移動して場所を覚えさせる。
function MINI_ADDONS_UPDATESETTINGS(frame)
    if g.settings.reword_x ~= frame:GetX() or g.settings.reword_y ~= frame:GetY() then
        g.settings.reword_x = frame:GetX()
        g.settings.reword_y = frame:GetY()
        MINI_ADDONS_SAVE_SETTINGS()
    end
end

function MINI_ADDONS_RAID_RECORD_INIT(frame)
    if g.settings.raid_record == 1 then
        local frame = ui.GetFrame("raid_record")
        frame:SetOffset(g.settings.reword_x, g.settings.reword_y)
        frame:SetSkinName("shadow_box")
        frame:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_UPDATESETTINGS")
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
    end

    local frame = ui.GetFrame("raid_record")
    GET_CHILD_RECURSIVELY(frame, "bgIndunClear"):ShowWindow(1)
    GET_CHILD_RECURSIVELY(frame, "textNewRecord"):ShowWindow(0)
end

-- 死んだ時に現れるフレームを移動可能に
function MINI_ADDONS_FRAME_MOVE()

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

--[[ 激動の入り間違いを減らす
function MINI_ADDONS_INDUNINFO_DETAIL_BOSS_SELECT_LBTN_CLICK(ctrl_set, btn, clicked)

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
        ReserveScript(string.format('MINI_ADDONS_TEXT_DELETE()'), 5.0)

    elseif string.match(indun_cls_name_ffls, "Goddess_Raid_Falouros_Auto") then
        msgtextf:ShowWindow(1)
        msgtexts:ShowWindow(0)
        msgtextf2:ShowWindow(1)
        msgtexts2:ShowWindow(0)
        ReserveScript(string.format('MINI_ADDONS_TEXT_DELETE()'), 5.0)
    else
        MINI_ADDONS_TEXT_DELETE()
    end
    -- else

    --  ReserveScript(string.format('MINI_ADDONS_TEXT_DELETE()'), 0.1)
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

function MINI_ADDONS_TEXT_DELETE()
    local indunframe = ui.GetFrame("induninfo")
    local indungbox = GET_CHILD_RECURSIVELY(indunframe, "textbox_1")

    indungbox:RemoveAllChild()

    indunframe:Invalidate()
end]]
