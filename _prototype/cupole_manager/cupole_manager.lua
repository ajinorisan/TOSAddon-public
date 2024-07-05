local addonName = "CUPOLE_MANAGER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")
local json = require('json')
local os = require("os")

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

-- JSONファイルのパスをフォーマット
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

function cupole_manager_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not settings then

        settings = {}

    end
    g.settings = settings
    cupole_manager_save_settings()
end

function cupole_manager_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function cupole_manager_personal_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc)

    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not settings then

        settings = {}

    end
    g.personal = settings
    cupole_manager_personal_save_settings()
end

function cupole_manager_personal_save_settings()

    acutil.saveJSON(g.personalFileLoc, g.personal);

end

function CUPOLE_MANAGER_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    g.settings = g.settings or {}

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)

    if mapCls.MapType == "City" then
        cupole_manager_load_settings()
        addon:RegisterMsg('GAME_START', 'cupole_manager_SET_CUPOLE_SLOTS');

        local cid = info.GetCID(session.GetMyHandle())
        g.personalFileLoc = string.format('../addons/%s/%s.json', addonNameLower, cid)
        cupole_manager_personal_load_settings()
        -- acutil.setupEvent(addon, "CUPOLE_SLOT_SELECT_BTN", "cupole_manager_CUPOLE_SLOT_SELECT_BTN");

    end
end

function cupole_manager_OPEN_CUPOLE_ITEM(frame)
    frame:StopUpdateScript('cupole_manager_OPEN_CUPOLE_ITEM')
    local frame = ui.GetFrame("cupole_item")
    local managertab = frame:GetChild("managerTab")
    RESET_CUPOLE_SELECT_MODE(frame)

    local Cupole_Filter = ui.GetFrame("cupole_filter");
    local filter_type = Cupole_Filter:GetUserValue("Filter");

    GET_CUPOLE_SORT_TYPE_FUNCTION(filter_type)

    local equip_cupole_list = {g.settings["1"].id - 1, g.settings["2"].id - 1, g.settings["3"].id - 1}

    local State, ChoosCupoleIndex, SlotIndex = GET_CHOOSE_INIT_CUPOLE(equip_cupole_list);
    frame:SetUserValue("Global_Select_Cupole", ChoosCupoleIndex);
    SET_CUPOLE_SLOTS(frame);
    ---우측 큐폴리스트 생성
    SET_CUPOLE_LIST(frame);
    ---큐폴 정보중 GAUGE 설정
    SET_CUPOLE_FRIENDLY(frame, ChoosCupoleIndex);
    ----우상단 돈 설정
    CUPOLE_ITEM_MONEY_SET(frame)
    ---큐폴 uimodel 생성
    KUPOLE_UIMODEL_IN_MAINCHARACTER(ChoosCupoleIndex);
    SET_SELECT_CUPOLE_NAME(frame, ChoosCupoleIndex)
    TOGGLE_CUPOLE_SPECIAL_ADDON(frame, ChoosCupoleIndex)
    -- 이걸 해야 매 프레임마다 업데이트 하면서 uimodel을 갱신한다.

    frame:RunUpdateScript("UPDATE_CUPOLE")

    local tabObj = managertab:GetChild('CupoleTab');
    local itembox_tab = tolua.cast(tabObj, "ui::CTabControl");
    itembox_tab:SelectTab(0);
    CUPOLE_TAB_CHANGE(managertab)

    local upgradebtn_bg = GET_CHILD_RECURSIVELY(frame, "upgradebtn_bg")
    SET_MOUSE_OVER_COLOR_CHNAGE_FUNC(upgradebtn_bg)
    ON_SET_EQUIP_CUPOLE_OPTIONS(frame)

    local SlotSetBg = GET_CHILD_RECURSIVELY(frame, "slotsetBG")
    SlotSetBg:SetScrollBarSkinName("verticalscrollbar3")
    -- 초기 선택 설정 한다.
    INIT_SELECT_CUPOLE_STATE(frame, State, ChoosCupoleIndex, SlotIndex);

    camera.SetRTTCameraDistance(200)
end

function cupole_manager_SET_CUPOLE_SLOTS(frame)

    local bg = GET_CHILD_RECURSIVELY_NAME(frame, "managerTab/manageBG/bg")
    local equip_cupole_list

    if g.settings["1"] then
        equip_cupole_list = {g.settings["1"].id - 1, g.settings["2"].id - 1, g.settings["3"].id - 1}
    end
    if equip_cupole_list == nil then
        return;
    end

    local SlotBG = GET_CHILD(bg, "SlotBG")
    local gb_slot = GET_CHILD(SlotBG, "gb_slot")

    local list_index = tonumber(equip_cupole_list[1])

    local cupole_slot_box = gb_slot:CreateOrGetControlSet('cupole_slot', "Main_Cupole_Slot_0", 0, 0);
    AUTO_CAST(cupole_slot_box)
    cupole_slot_box:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    local slot_gb = cupole_slot_box:GetChild("gb")
    slot_gb:SetEventScript(ui.LBUTTONUP, "CUPOLE_SLOT_SELECT_BTN")
    cupole_slot_box:SetUserValue("SlotIndex", 0);
    cupole_slot_box:SetUserValue("SEL_CUPOLE_INDEX", list_index)
    SUMMON_SELECT_LEFT_CUPOLE_SLOT(cupole_slot_box, list_index)

    for i = 1, 2 do
        list_index = tonumber(equip_cupole_list[i + 1])
        ReservScript(string.format("cupole_manager_mini_SET_CUPOLE_SLOTS('%s',%d,%d)", gb_slot, list_index, i), i)
    end

    frame:RunUpdateScript("cupole_manager_OPEN_CUPOLE_ITEM", 3.0)
end

function cupole_manager_mini_SET_CUPOLE_SLOTS(gb_slot, list_index, i)
    local X = 97
    if i == 2 then
        X = 15
    end
    local mini_cupole_slot_box = gb_slot:CreateOrGetControlSet('cupole_mini_slot', "Main_Cupole_Slot_" .. i, X, 10)
    AUTO_CAST(mini_cupole_slot_box)
    mini_cupole_slot_box:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    local gb = mini_cupole_slot_box:GetChild("gb")
    gb:SetEventScript(ui.LBUTTONUP, "CUPOLE_SLOT_SELECT_BTN")
    mini_cupole_slot_box:SetUserValue("SlotIndex", i);
    mini_cupole_slot_box:SetUserValue("SEL_CUPOLE_INDEX", list_index)
    -- CUPOLE_SLOT_SELECT_BTN(mini_cupole_slot_box, gb, nil, nil)
    SUMMON_SELECT_LEFT_CUPOLE_SLOT(mini_cupole_slot_box, list_index)
end

