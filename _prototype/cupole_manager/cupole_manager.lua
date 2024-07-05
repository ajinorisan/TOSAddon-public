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
        acutil.setupEvent(addon, "CUPOLE_SLOT_SELECT_BTN", "cupole_manager_CUPOLE_SLOT_SELECT_BTN");

    end
end

function cupole_manager_CUPOLE_SLOT_SELECT_BTN(frame, msg)
    local parent, ctrl, argStr, argNum = acutil.getEventArgs(msg)
    print(tostring(parent:GetParent():GetName()))
    print(tostring(parent:GetName()))
    print(parent:GetUserIValue("SEL_CUPOLE_INDEX"))

end

function cupole_manager_SET_CUPOLE_SLOTS(frame)

    local frame = ui.GetFrame("cupole_item")
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

    local cupole_slot_box = gb_slot:CreateOrGetControlSet('cupole_slot', "Main_Cupole_Slot_0", 0, 0);
    cupole_slot_box:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    local slot_gb = cupole_slot_box:GetChild("gb")
    slot_gb:SetEventScript(ui.LBUTTONUP, "CUPOLE_SLOT_SELECT_BTN")
    cupole_slot_box:SetUserValue("SlotIndex", 0);
    cupole_slot_box:SetUserValue("SEL_CUPOLE_INDEX", -1)

    SUMMON_SELECT_LEFT_CUPOLE_SLOT(cupole_slot_box, tonumber(equip_cupole_list[1]))
    SET_SLOT_CUPOLE_INFO(cupole_slot_box, tonumber(equip_cupole_list[1]))

    local MiniCnt = 2;
    local ctrler = 1;
    local defx = 15;
    local X = 82;
    local Y = 10;
    local cnt = 1;
    for i = 1, MiniCnt do
        local mini_cupole_slot_box = gb_slot:CreateOrGetControlSet('cupole_mini_slot', "Main_Cupole_Slot_" .. i,
            X * ctrler * cnt + defx * ctrler, Y);
        mini_cupole_slot_box:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
        mini_cupole_slot_box:SetUserValue("SEL_CUPOLE_INDEX", -1)
        if i % 2 == 0 then
            cnt = cnt + 1;
        end
        ctrler = ctrler * -1;
        local gb = mini_cupole_slot_box:GetChild("gb")
        gb:SetEventScript(ui.LBUTTONUP, "CUPOLE_SLOT_SELECT_BTN")
        mini_cupole_slot_box:SetUserValue("SlotIndex", i);

        SUMMON_SELECT_LEFT_CUPOLE_SLOT(mini_cupole_slot_box, tonumber(equip_cupole_list[i + 1]))
        -- SET_SLOT_CUPOLE_INFO(mini_cupole_slot_box, tonumber(equip_cupole_list[i + 1]))

    end
    --[[local SlotBG = GET_CHILD(bg, "SlotBG")
    local gb_slot = GET_CHILD(SlotBG, "gb_slot")
    local cupole_slot_box = gb_slot:CreateOrGetControlSet('cupole_slot', "Main_Cupole_Slot_0", 0, 0);
    AUTO_CAST(cupole_slot_box)
    cupole_slot_box:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    local slot_gb = cupole_slot_box:GetChild("gb")

    slot_gb:SetEventScript(ui.LBUTTONUP, "CUPOLE_SLOT_SELECT_BTN")
    cupole_slot_box:SetUserValue("SlotIndex", 0);
    cupole_slot_box:SetUserValue("SEL_CUPOLE_INDEX", tonumber(equip_cupole_list[1]))
    -- SET_SLOT_CUPOLE_INFO(cupole_slot_box, tonumber(equip_cupole_list[1]))
    SUMMON_SELECT_LEFT_CUPOLE_SLOT(cupole_slot_box, tonumber(equip_cupole_list[1]))
    local MiniCnt = 2;
    local ctrler = 1;
    local defx = 15;
    local X = 82;
    local Y = 10;
    local cnt = 1;
    for i = 1, MiniCnt do
        local mini_cupole_slot_box = gb_slot:CreateOrGetControlSet('cupole_mini_slot', "Main_Cupole_Slot_" .. i,
            X * ctrler * cnt + defx * ctrler, Y);
        AUTO_CAST(mini_cupole_slot_box)
        mini_cupole_slot_box:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
        -- mini_cupole_slot_box:SetUserValue("SEL_CUPOLE_INDEX", -1)
        if i % 2 == 0 then
            cnt = cnt + 1;
        end
        ctrler = ctrler * -1;
        local gb = mini_cupole_slot_box:GetChild("gb")
        gb:SetEventScript(ui.LBUTTONUP, "CUPOLE_SLOT_SELECT_BTN")
        mini_cupole_slot_box:SetUserValue("SlotIndex", i);
        print(tostring(equip_cupole_list[i + 1]))
        local SelectBtn = GET_CHILD_RECURSIVELY(frame, "SelectBtn");
        SET_SLOT_CUPOLE_INFO(mini_cupole_slot_box, tonumber(equip_cupole_list[i + 1]))

    end
    ReserveScript(
        string.format("cupole_manager_SUMMON_CUPOLE_BTN('%s',%d,%d)", gb_slot, tonumber(equip_cupole_list[2]), 1), 0.5)
    ReserveScript(
        string.format("cupole_manager_SUMMON_CUPOLE_BTN('%s',%d,%d)", gb_slot, tonumber(equip_cupole_list[3]), 2), 1.0)
    -- local SlotIndex = frame:GetUserIValue("SlotIndex");
    -- SummonCupole(g.settings["1"].id - 1, SlotIndex)]]

end

function cupole_manager_SUMMON_CUPOLE_BTN(frame, argNum, SlotIndex)

    local pc = GetMyPCObject();
    if pc == nil then
        return;
    end
    print("num" .. argNum)
    local etc = GetMyEtcObject(pc);

    if etc == nil then

        return;
    end

    print(tostring(SlotIndex))
    SummonCupole(argNum, SlotIndex)

end

function cupole_manager_SET_SLOT_CUPOLE_INFO(frame, cupole_index, isEquip)
    if frame == nil or cupole_index == nil then
        return;
    end
    local cupolecls = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(cupole_index);
    local Gb = GET_CHILD(frame, "gb");
    local revert = GET_CHILD_RECURSIVELY(frame, "revert");
    local grade_img = GET_CHILD_RECURSIVELY(frame, "grade_img");
    local Cupole_Slot = GET_CHILD(frame, "cupole_slot");
    print(tostring(Cupole_Slot))
    local equip_img = GET_CHILD_RECURSIVELY(frame, "equip_img");
    if equip_img ~= nil then
        equip_img = AUTO_CAST(equip_img)
    end
    if Cupole_Slot == nil then
        return;
    end

    if cupolecls ~= nil then
        frame:SetUserValue("SEL_CUPOLE_INDEX", cupole_index)
    end

    local Grade = TryGetProp(cupolecls, "Grade", "R");
    local RankFrameName = string.format("cupole_grade_frame_%s", Grade);
    local RankName = string.format("cupole_grade_%s", Grade);
    local RevertFramaName = string.format("cupole_revert_%s", Grade);
    local Cupole_Icon = Cupole_Slot:GetIcon();

    if Gb ~= nil then
        Gb:SetImage(RankFrameName)
    end
    if grade_img ~= nil then
        grade_img:SetImage(RankName);
    end
    if revert ~= nil then
        revert:SetImage(RevertFramaName)
    end

    if cupolecls == nil then
        grade_img:SetImage("")
    end
    if Cupole_Icon == nil then
        Cupole_Icon = CreateIcon(Cupole_Slot);
    end
    print("test4")
    if cupolecls ~= nil then
        local IconImage = TryGetProp(cupolecls, "Icon", "None");
        if IconImage ~= "None" then
            Cupole_Icon:SetImage(IconImage);
            print("test1")
        end
    end
    local index = tonumber(cupole_index)
    print("test3")
    if equip_img ~= nil then
        if index >= 0 then
            print("test2")
            equip_img:ShowWindow(1);
        else
            equip_img:ShowWindow(0);
        end
    end
    print("test5")
end

function cupole_manager_SUMMON_SELECT_LEFT_CUPOLE_SLOT(frame, cupole_index)
    local cupolecls = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(cupole_index);
    print(tostring(cupolecls))
    if cupolecls == nil then
        frame:SetUserValue("SEL_CUPOLE_INDEX", -1)
        return;
    end
    local grand_parent = frame:GetTopParentFrame();

    if cupolecls ~= nil then
        frame:SetUserValue("SEL_CUPOLE_INDEX", cupole_index)
    end

    local SlotIndex = frame:GetUserIValue("SlotIndex");
    print(tostring(SlotIndex))
    if SlotIndex ~= nil then
        SUMMON_CUPOLE_BTN(frame, cupole_index, SlotIndex);
        SET_SLOT_CUPOLE_INFO(frame, cupole_index)
        if tonumber(SlotIndex) == 0 then
            SET_SELECT_CUPOLE_INFO_WITH_MODEL(grand_parent, cupole_index)
        end
    end
end

function cupole_manager_CUPOLE_SLOT_SELECT_BTN(parent, ctrl, argStr, argNum)
    local frame = parent:GetTopParentFrame();
    local rightslotset = GET_CHILD_RECURSIVELY(frame, "slotsetBG")
    local SlotBG = GET_CHILD_RECURSIVELY(frame, "SlotBG")
    local gb_slot = GET_CHILD(SlotBG, "gb_slot")

    local bg = parent:GetParent();
    FRAME_CHILD_COLORTONE_CLEAR(bg)
    FRAME_CHILD_COLORTONE_CLEAR(rightslotset)
    gb_slot:SetUserValue("LEFT_SEL_SLOT", parent:GetName());

    local SEL_CUPOLE_INDEX = tostring(argNum + 1)

    local SelectBtn = GET_CHILD_RECURSIVELY(frame, "SelectBtn");

    if SEL_CUPOLE_INDEX == -1 then
        SelectBtn:ShowWindow(0);
    else
        SelectBtn:ShowWindow(1);
    end
    print(tostring(SEL_CUPOLE_INDEX))
    SET_SLOT_SELECT_STATE(parent, SelectBtn, "CUPOLE_RIGHT_SLOT_EQUIP", "equipment", SEL_CUPOLE_INDEX);
end

function cupole_manager_CUPOLE_RIGHT_SLOT_EQUIP(parent, ctrl, argStr, argNum)
    local cupole_select_state = "right";
    local frame = parent:GetTopParentFrame();
    if frame == nil then
        return;
    end

    if IS_IN_CITY() == 0 then
        ui.SysMsg(ClMsg('AllowedInTown'));
        return;
    end

    local SlotBG = GET_CHILD_RECURSIVELY(frame, "SlotBG")
    local gb_slot = GET_CHILD(SlotBG, "gb_slot")
    local slot_name = gb_slot:GetUserValue("RIGHT_SEL_SLOT");

    SET_CUPOLE_SLOT_SET_FUNCTION(frame, "left_slotset_cupole_set_func");

    local ignore_list = {slot_name}

    CUPOLE_SELECT_MODE(frame, 0, "FF222222", ignore_list);
end

--[[function cupole_manager_ON_SET_EQUIP_CUPOLE_OPTIONS(frame, msgs)
    local parent, msg, argStr, argNum = acutil.getEventArgs(msgs)
  
    local cupole_list, cnt = GetClassList("cupole_list");

    local Statlist = {};
    local pc = GetMyPCObject();
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(cupole_list, i);
        if cls ~= nil then
            local stat, value = GET_CUPOLE_OWNED_RESULT_VALUE_BY_CLS(pc, cls)

            print(tostring(stat))
            print(tostring(value))
        end
    end
end

function cupole_manager_msg(frame, msg)
    print(tostring(msg))
end

function cupole_manager_OPEN_CUPOLE_ITEM()
    local frame = ui.GetFrame("cupole_item");
    frame:ShowWindow(1)
    if frame == nil then

        return;

    end
    local managertab = frame:GetChild("managerTab")
    RESET_CUPOLE_SELECT_MODE(frame)

    local pc = GetMyPCObject();
    if pc == nil then
        return;
    end

    local equip_cupole_list = GET_EQUIP_CUPOLE_LIST()
    print(tostring(equip_cupole_list[1]))
    print(tostring(g.settings["1"].id - 1))
    local equip_cupole_list = {tostring(g.settings["1"].id - 1), tostring(g.settings["2"].id - 1),
                               tostring(g.settings["3"].id - 1)}
    if equip_cupole_list == nil then
        return;
    end

    -- 큐폴 정렬
    local Cupole_Filter = ui.GetFrame("cupole_filter");
    -- filter_type = Cupole_Filter:GetUserValue("Filter");

    -- GET_CUPOLE_SORT_TYPE_FUNCTION(filter_type)

    ---현재 선택되어있는 큐폴 인덱스 가져오기
    local State, ChoosCupoleIndex, SlotIndex = GET_CHOOSE_INIT_CUPOLE(equip_cupole_list);
    frame:SetUserValue("Global_Select_Cupole", ChoosCupoleIndex);
    print(tostring(State) .. ":" .. tostring(ChoosCupoleIndex) .. ":" .. tostring(SlotIndex))
    ---좌측 큐폴 슬롯 세팅
    -- SET_CUPOLE_SLOTS(frame);
    cupole_manager_SET_CUPOLE_SLOTS(frame)
    ---우측 큐폴리스트 생성
    local SlotIndex = frame:GetUserIValue("SlotIndex");
    SummonCupole(g.settings["1"].id - 1, SlotIndex)
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
    -- INIT_SELECT_CUPOLE_STATE(frame, "right", ChoosCupoleIndex, SlotIndex);
    camera.SetRTTCameraDistance(200)
    print("test9")
end

function cupole_manager_RIGHT_CUPOLE_SLOT_SELECT_BTN(frame, msg, str, num)
    -- local parent, ctrl, argStr, argNum = acutil.getEventArgs(msg)
    -- 
    -- 
    -- OPEN_CUPOLE_ITEM()
    local argNum = g.settings["1"].id - 1
    print(argNum)
    -- local cupole = GET_REPRESENT_CUPOLE_INFO()
    -- local clsid = TryGetProp(cupole, "ClassID", 0)

    local frame = ui.GetFrame("cupole_item")
    local rightslotset = GET_CHILD_RECURSIVELY(frame, "slotsetBG")
    print(tostring(rightslotset))
    local SlotBG = GET_CHILD_RECURSIVELY(frame, "SlotBG")
    print(tostring(SlotBG))
    local gb_slot = GET_CHILD(SlotBG, "gb_slot")
    print(tostring(gb_slot))
    rightslotset:SetUserValue("SEL_RIGHT_CUPOLE_IDX", argNum)
    local SelectBtn = GET_CHILD_RECURSIVELY(frame, "SelectBtn");
    print(tostring(SelectBtn))
    local slotsetBG = GET_CHILD_RECURSIVELY(frame, "slotsetBG")
    local parent = GET_CHILD_RECURSIVELY(slotsetBG, "cupole_slot_2")
    print(tostring(parent:GetName()))
    CUPOLE_RIGHT_SLOT_EQUIP(parent, nil, nil, nil)
    SET_SLOT_SELECT_STATE(parent, SelectBtn, "CUPOLE_RIGHT_SLOT_EQUIP", "equipment", argNum);
end

function cupole_manager_CLOSE_CUPOLE_ITEM(frame, msg)
    local etc = GetMyEtcObject();
    local equipstr = TryGetProp(etc, 'Cupole_Equip', "0;0;0");
    local equip_list = StringSplit(equipstr, ';')
    local cupole_list, cnt = GetClassList("cupole_list");
    for k, v in pairs(equip_list) do
        if v == nil or v == "nil" then
            equip_list[k] = -1

        end
    end
    print(tostring(equip_list[1] .. ":" .. equip_list[2] .. ":" .. equip_list[3]))
    local LoginName = session.GetMySession():GetPCApc():GetName()

    local cupole_list, cnt = GetClassList("cupole_list");
    for i = 1, #equip_list do
        local index = tonumber(equip_list[i])
        local cls = GetClassByIndexFromList(cupole_list, index);
        local ClassName = TryGetProp(cls, "ClassName", "None")
        local ClassID = TryGetProp(cls, "ClassID", 0)
        if g.settings[tostring(i)] ~= nil then
            g.settings[tostring(i)] = {}
        end
        g.settings[tostring(i)] = {
            id = ClassID,
            name = ClassName
        }
        if g.personal[tostring(i)] ~= nil then
            g.personal[tostring(i)] = {}
        end
        g.personal[tostring(i)] = {
            id = ClassID,
            name = ClassName
        }

    end
    cupole_manager_save_settings()
    cupole_manager_personal_save_settings()

end]]

