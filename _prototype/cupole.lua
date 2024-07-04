-- !cupole_item.lua
Cupole_List = {}

local filter_type = "";
local filterconst = {
    ["UR"] = 3,
    ["SR"] = 2,
    ["R"] = 1
}
local stat_sort_value = {
    ["PATK_BM"] = 1,
    ["MATK_BM"] = 2,
    ["DEF_BM"] = 3,
    ["MDEF_BM"] = 4,
    ["CRTDR_BM"] = 5,
    ["CRTHR_BM"] = 6,
    ["MiddleSize_Atk_BM"] = 7,
    ["MiddleSize_Def_BM"] = 8
}

------------------------------------get function
function GET_CUPOLE_INDEX(ownerHandle, ui_model, isMainCharacter)
    local val = GetCupoleRTTOffsetIndex(ownerHandle, ui_model)
    if val < 0 then
        REMOVE_ALL_CUPOLE_UIMODEL()
        ownerHandle, ui_model = CREATE_CUPOLE_UIMODEL(index, isMainCharacter)
        val = GetCupoleRTTOffsetIndex(ownerHandle, ui_model)
    end
    return val;
end

function GET_KUPOLE_INDEX_BY_CLASSNAME(className)
    local cupole_list, cnt = GetClassList("cupole_list");
    local cls = GetClassByNameFromList(cupole_list, className)
    local id = TryGetProp(cls, "ClassID", 0)
    return id - 1;
end

function GET_KUPOLE_CLS_BY_CLASSNAME(className)
    local cupole_list, cnt = GetClassList("cupole_list");
    local cls = GetClassByNameFromList(cupole_list, className)
    return cls;
end

---Get current Select Cupole Index
function GET_GLOBAL_SELECT_CUPOLE(mainFrame)
    if mainFrame == nil then
        mainFrame = ui.GetFrame("cupole_item")
    end
    mainFrame = ui.GetFrame("cupole_item")
    local selc_cupole = mainFrame:GetUserIValue("Global_Select_Cupole");
    return selc_cupole;
end

---Get current Select Cupole Index
function GET_GLOBAL_SELECT_CUPOLE_ACCOUNTPROP(mainFrame)
    local cupole_index = GET_GLOBAL_SELECT_CUPOLE(mainFrame);
    local cupole_cls = GET_CUPOLE_CLASS_BY_INDEX(cupole_index)
    if cupole_cls == nil then
        return "None";
    end
    local AccProp = TryGetProp(cupole_cls, "AccountProperty", "None")
    return AccProp;
end

-- get cupole current rank
function GET_CUPOLE_RANK(pc, index)
    local pc = GetMyPCObject();
    if pc == nil then
        return 0;
    end
    local acc = GetMyAccountObj(pc);
    if acc == nil then
        return 0;
    end
    local cls = GET_CUPOLE_CLASS_BY_INDEX(index)
    local AccProp = TryGetProp(cls, "AccountProperty", "None")
    local rank = TryGetProp(acc, AccProp, 0)
    return rank;
end

--- 현재 장착한 큐폴의 값들을 가져온다.
function GET_EQUIP_CUPOLE_LIST()
    local etc = GetMyEtcObject();
    local equipstr = TryGetProp(etc, 'Cupole_Equip', "0;0;0");
    local equip_list = StringSplit(equipstr, ';')

    for k, v in pairs(equip_list) do
        if v == nil or v == "nil" then
            equip_list[k] = -1
        end
    end

    local slot_list = {equip_list[1], equip_list[2], equip_list[3]};
    return slot_list;
end

---정렬 된 큐폴 리스트에서 큐폴 오브젝트의 클래스를 받아오는 함수. 
function GET_SELECT_CUPOLE_CLS(index)
    local table = Cupole_List[index + 1];
    if table == nil then
        return nil;
    end
    local cls = table[3]
    return cls;
end

-- 큐폴 리스트를 옵션에 따라 sort한다.
function GET_CUPOLE_SORT_TYPE_FUNCTION(option)
    local Cupole_Filter = ui.GetFrame("cupole_filter");
    local Owing = Cupole_Filter:GetUserIValue("Owing");

    local cupole_list, cnt = GetClassList("cupole_list");
    if option == "Friendly" then
        Cupole_List = SortTableByLevel(cupole_list, cnt, Owing)
    elseif option == "Grade" then
        Cupole_List = SortTableByPropertyName(cupole_list, cnt, "Grade", Owing)
    else
        Cupole_List = SortTableByPropertyName(cupole_list, cnt, "Grade", Owing)
    end
    return Cupole_List;
end

---index로 큐폴 값을 가져오는 함수.
function GET_CUPOLE_BY_INDEX_IN_CLASSLIST(cupole_index)
    if cupole_index == nil or cupole_index == "None" or cupole_index == "nil" then
        return nil;
    end
    index = tonumber(cupole_index);
    local cupole_list, cnt = GetClassList("cupole_list");
    if index > tonumber(cnt) then
        return nil;
    end
    local cls = GetClassByIndexFromList(cupole_list, index);

    return cls
end

---index로 해당 큐폴의 이름을 가져오는 함수.
function GET_CUPOLE_NAME_BY_INDEX(index)
    local cupole_info = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(index);
    if cupole_info == nil then
        return;
    end

    local ClsName = TryGetProp(cupole_info, "ClassName", "None");

    return ClsName;
end

---index로 원하는 큐폴의 설정 가져오기
function GET_CUPOLE_PROP_BY_INDEX(index, Prop)
    local cupole_info = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(index);
    if cupole_info == nil then
        return;
    end

    local Value = TryGetProp(cupole_info, Prop);
    return Value;
end

function GET_CUPOLE_CLS_BY_TYPE(id)
    local cls = GetClassByType("cupole_list", id);
    return cls;
end
----좀 더 유틸리티에 관련 됨

-- 큐폴의 스탯 텍스트를 설정함.
function GET_CUPOLE_STAT_TEXT(Stat, UpgradeValue)
    if Stat == nil or UpgradeValue == nil then
        return "";
    end

    local StatText = ClMsg(Stat)
    local StatInfoStr = string.format("%s + {#ffcc33}%d{/}", StatText, UpgradeValue)

    return StatInfoStr;
end

---오픈시에 초기에 출현할 큐폴의 index정보를 가져온다.
function GET_CHOOSE_INIT_CUPOLE(equip_cupole_list)
    local state = "left"
    for k, v in pairs(equip_cupole_list) do
        if tonumber(v) ~= -1 and v ~= nil and v ~= "nil" then
            return state, v, k;
        end
    end
    state = "right"
    local index = SEARCH_EQUIP_CUPOLE_INDEX(1) - 1;
    return state, index, 0;
end
----정렬된 (우측 슬롯셋) 리스트에서 index로 원하는 큐폴 가져오는 것.
function SEARCH_EQUIP_CUPOLE_INDEX(index)
    GET_CUPOLE_SORT_TYPE_FUNCTION(filter_type)
    local clsId = TryGetProp(Cupole_List[index][3], "ClassID", -1);
    return clsId;
end

------------------sort 관련 함수
function SortTableByPropertyName(classlist, count, propName, Owing)
    local pc = GetMyPCObject();
    if pc == nil then
        return 0;
    end
    local acc = GetMyAccountObj(pc);
    if acc == nil then
        return 0;
    end

    local clsList = {};
    for i = 0, count - 1 do
        local cls = GetClassByIndexFromList(classlist, i);
        local favorite = BoolToNumber(IsFavoriteCupole(i));
        local SortName = nil;
        if propName ~= nil then
            SortName = TryGetProp(cls, propName, "None");
        end
        if cls ~= nil then
            local Use = TryGetProp(cls, "Use", "false");
            if Use == "true" then
                if SortName ~= nil or SortName ~= "None" then
                    if Owing == 1 then
                        local accprop = TryGetProp(cls, "AccountProperty", 0);
                        local CupoleExpProp = TryGetProp(acc, accprop, 0);
                        if CupoleExpProp > 0 then
                            table.insert(clsList, {favorite, SortName, cls});
                        end
                    else
                        table.insert(clsList, {favorite, SortName, cls});
                    end
                end
            end
        end
    end
    -- befor sort
    table.sort(clsList, CupoleTableSort);

    return clsList;
end

function SortTableByLevel(classlist, count, Owing)
    local pc = GetMyPCObject();
    if pc == nil then
        return 0;
    end
    local acc = GetMyAccountObj(pc);
    if acc == nil then
        return 0;
    end

    local clsList = {};
    for i = 0, count - 1 do
        local cls = GetClassByIndexFromList(classlist, i);
        local favorite = BoolToNumber(IsFavoriteCupole(i));

        if cls ~= nil then
            local accprop = TryGetProp(cls, "AccountProperty", 0);
            local CupoleExpProp = TryGetProp(acc, accprop, 0);
            local Use = TryGetProp(cls, "Use", "false");
            if Use == "true" then
                if SortName ~= nil or SortName ~= "None" then
                    if Owing == 1 then
                        if CupoleExpProp > 0 then
                            table.insert(clsList, {favorite, CupoleExpProp, cls});
                        end
                    else
                        table.insert(clsList, {favorite, CupoleExpProp, cls});
                    end
                end
            end
        end
    end
    -- befor sort
    table.sort(clsList, CupoleTableSort);

    return clsList;
end

function CupoleTableSort(left, right)
    if left[1] ~= right[1] then
        return left[1] >= right[1]
    end

    local leftcls = left[3];
    local rightcls = right[3];
    local leftGrade = TryGetProp(leftcls, "Grade", "R");
    local rightGrade = TryGetProp(rightcls, "Grade", "R");
    local leftGradeValue = filterconst[leftGrade]
    local rightGradeValue = filterconst[rightGrade]

    if leftGradeValue == rightGradeValue then
        return left[2] > right[2];
    end
    return leftGradeValue > rightGradeValue
end
-------------------------------------------

-------------------------------------------set

----좌측의 팀편성 큐폴 슬롯을 만드는 함수
function SET_CUPOLE_SLOTS(frame)
    local bg = GET_CHILD_RECURSIVELY_NAME(frame, "managerTab/manageBG/bg")
    if bg == nil then
        return;
    end

    GET_CUPOLE_SORT_TYPE_FUNCTION(filter_type)

    local equip_cupole_list = GET_EQUIP_CUPOLE_LIST()

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

    -- SUMMON_SELECT_LEFT_CUPOLE_SLOT(cupole_slot_box, tonumber(equip_cupole_list[1]))
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

        -- SUMMON_SELECT_LEFT_CUPOLE_SLOT(mini_cupole_slot_box, tonumber(equip_cupole_list[i + 1]))
        SET_SLOT_CUPOLE_INFO(mini_cupole_slot_box, tonumber(equip_cupole_list[i + 1]))

    end
end

---선택된 큐폴의 정보를 좌측 정보 세팅에 설정하고, uimodel을 그린다.
function SET_SELECT_CUPOLE_INFO_WITH_MODEL(frame, cupole_index)
    local selc_cupole = GET_GLOBAL_SELECT_CUPOLE(frame);
    if cupole_index == -1 then
        return;
    end
    if frame:HaveUpdateScript("CUPOLE_UIMODEL_DELAY_CREATE_IN_MAINCHARACTER") == true then
        return;
    else
        REMOVE_ALL_CUPOLE_UIMODEL()
        frame:SetUserValue("Select_Cupole_Index", cupole_index);
        frame:RunUpdateScript("CUPOLE_UIMODEL_DELAY_CREATE_IN_MAINCHARACTER", 0.2)
    end
    SET_SELECT_CUPOLE_INFORMATION(frame, cupole_index);
    -- KUPOLE_UIMODEL_IN_MAINCHARACTER(cupole_index)
    frame:SetUserValue("Global_Select_Cupole", cupole_index);
    SET_BACKGROUND_IMAGE_BY_SELECT_TAB(frame, 0)
    CHECK_ILLUSTRATION_MODE(frame)
end

function CUPOLE_UIMODEL_DELAY_CREATE_IN_MAINCHARACTER(frame, delay)
    local index = frame:GetUserIValue("Select_Cupole_Index");
    local parent = frame:GetTopParentFrame();
    SET_SELECT_CUPOLE_NAME(parent, index)
    KUPOLE_UIMODEL_IN_MAINCHARACTER(index)
end

function SET_SELECT_CUPOLE_NAME(frame, index)
    local CupoleName = GET_CHILD_RECURSIVELY_NAME(frame, "managerTab/manageBG/Name_Pic/CupoleName")

    local cls = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(index)
    local Name = TryGetProp(cls, "Dec_Name", "Name");
    local Grade = TryGetProp(cls, "Grade", "R");
    if cls == nil then
        Name = ClMsg("KupoleURItem")
        Grade = "UR"
    end
    if Grade == "UR" then
        Name = "{img cupole_grade_UR 40 24}" .. Name;
    elseif Grade == "SR" then
        Name = "{img cupole_grade_SR 40 24}" .. Name;
    else
        Name = "{img cupole_grade_R 40 24}" .. Name;
    end
    CupoleName:SetTextByKey("Name", Name)
end

--- 선택된 큐폴의 정보를 좌측 정보 판에 세팅한다.
function SET_SELECT_CUPOLE_INFORMATION(frame, cupole_index)
    if frame == nil then
        return 0;
    end

    local NamelBG = GET_CHILD_RECURSIVELY_NAME(frame, "managerTab/manageBG/InfoBG/NamelBG")
    local ExplainBG = GET_CHILD_RECURSIVELY_NAME(frame, "managerTab/manageBG/InfoBG/ExplainBG")
    local SkillBG = GET_CHILD_RECURSIVELY_NAME(frame, "managerTab/manageBG/InfoBG/SkillBG")
    local PassiveBG = GET_CHILD_RECURSIVELY_NAME(frame, "managerTab/manageBG/InfoBG/PassiveBG")
    local RankBG = GET_CHILD_RECURSIVELY_NAME(frame, "managerTab/manageBG/InfoBG/RankBG")
    local favorites = GET_CHILD_RECURSIVELY_NAME(frame, "managerTab/manageBG/InfoBG/favorites")

    GET_CUPOLE_SORT_TYPE_FUNCTION(filter_type)

    local cupole_cls = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(cupole_index);

    local IconName = TryGetProp(cupole_cls, "Icon", "None");
    local Grade = TryGetProp(cupole_cls, "Grade", "R");
    local CupoleClassName = TryGetProp(cupole_cls, "ClassName", "None");
    local CupoleDecName = TryGetProp(cupole_cls, "Dec_Name", "None");

    local state = IsFavoriteCupole(cupole_index);

    SET_CUPOLE_NAME_INFO(NamelBG, cupole_cls)
    SET_CUPOLE_BUFF_INFO(ExplainBG, cupole_cls)
    SET_CUPOLE_OWNED_EFFECT(ExplainBG, cupole_cls)
    SET_CUPOLE_ACTIVE_SKILL_INFO(SkillBG, cupole_cls);
    SET_CUPOLE_PASSIVE_SKILL_INFO(PassiveBG, cupole_cls);
    SET_CUPOLE_FRIENDLY(frame, cupole_index)
    SET_CUPOLE_FAVORITE_ICON_STATE(favorites, state);
    TOGGLE_CUPOLE_SPECIAL_ADDON(frame, cupole_index)
end

------큐폴의 이름 정보 세팅
function SET_CUPOLE_NAME_INFO(frame, cls)
    local Name = GET_CHILD(frame, "Name")
    local rankPic = GET_CHILD(frame, "rank_pic")

    local Cupole_Name = TryGetProp(cls, "Dec_Name", "None");
    local Grade = TryGetProp(cls, "Grade", "None");
    local RankName = string.format("cupole_grade_%s", Grade)
    if RankName == "cupole_grade_None" then
        RankName = "cupole_grade_R"
    end
    Name:SetTextByKey("value", Cupole_Name)
    rankPic:SetImage(RankName)
end

function SET_CUPOLE_STAT_AT_UI(frame, Stat, Value)
    local StatText = ClMsg(Stat)
    local StatInfoStr = string.format("%s + {#ffcc33}%d{/}", StatText, Value)
    frame:SetTextByKey("value", StatInfoStr)
end

-- 큐폴의 효과 정보 세팅 (동행효과)
function SET_CUPOLE_BUFF_INFO(frame, cls, specifiedRank)
    if cls == nil then
        return;
    end
    local rank = nil;
    if specifiedRank then
        rank = specifiedRank;
    end
    local companyEffect = GET_CHILD(frame, "companyEffect")

    local Grade = TryGetProp(cls, "Grade", "None");

    local Stat, UpgradeValue = GET_CUPOLE_FRIENDLY_RESULT_VALUE_BY_CLS(nil, cls, rank)

    SET_CUPOLE_STAT_AT_UI(companyEffect, Stat, UpgradeValue)
end

-- 큐폴의 사용 스킬 정보 세팅
function SET_CUPOLE_ACTIVE_SKILL_INFO(frame, cls)
    local ctrl = frame:CreateOrGetControlSet("cupole_skil", "cupole_skil0", 0, 0)
    ctrl:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    local SkillIcon = GET_CHILD(ctrl, "SkillIcon")

    local Cupole_Name = TryGetProp(cls, "Dec_Name", "None");
    local Grade = TryGetProp(cls, "Grade", "None");

    local Cupole_Group_ID = TryGetProp(cls, "Group_ID", "None");
    local Cupole_Skill_List = GET_CUPOLE_SKILL_BY_GROUPID_LIST(Cupole_Group_ID)
    local Cupole_Skill_Cls = nil;
    for k, v in pairs(Cupole_Skill_List) do
        local SkillType = TryGetProp(v, "Skill_Type", "None")
        if SkillType == "Active" then
            Cupole_Skill_Cls = v;
        end
    end
    if Cupole_Skill_Cls == nil then
        return;
    end

    local SkillClassID = TryGetProp(Cupole_Skill_Cls, "ClassID", 0);
    local SkillType = TryGetProp(Cupole_Skill_Cls, "Skill_Type", "None");
    local IconName = TryGetProp(Cupole_Skill_Cls, "Skill_Icon", "None");

    SkillIcon:SetImage(IconName);

    SkillIcon:SetEventScript(ui.MOUSEON, "ON_CUPOLE_SKILL_TOOLTIP_OPEN");
    SkillIcon:SetEventScriptArgNumber(ui.MOUSEON, SkillClassID);
    SkillIcon:SetEventScript(ui.MOUSEOFF, "ON_CUPOLE_SKILL_TOOLTIP_CLOSE");
    SET_CUPOLE_SKILL_DESC(frame, Cupole_Skill_Cls)
end

---큐폴의 패시브 스킬 정보 세팅
function SET_CUPOLE_PASSIVE_SKILL_INFO(frame, cls)
    local ctrl = frame:CreateOrGetControlSet("cupole_skil", "cupole_skil1", 0, 0)
    ctrl:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    local SkillIcon = GET_CHILD(ctrl, "SkillIcon")

    local Cupole_Name = TryGetProp(cls, "Dec_Name", "None");
    local Grade = TryGetProp(cls, "Grade", "None");

    local Cupole_Group_ID = TryGetProp(cls, "Group_ID", "None");
    local Cupole_Skill_List = GET_CUPOLE_SKILL_BY_GROUPID_LIST(Cupole_Group_ID)
    local Cupole_Skill_Cls = nil;
    for k, v in pairs(Cupole_Skill_List) do
        local SkillType = TryGetProp(v, "Skill_Type", "None")
        if SkillType == "Passive" then
            Cupole_Skill_Cls = v;
        end
    end
    if Cupole_Skill_Cls == nil then
        frame:ShowWindow(0)
        return;
    end
    frame:ShowWindow(1)

    local SkillClassID = TryGetProp(Cupole_Skill_Cls, "ClassID", 0);
    local SkillType = TryGetProp(Cupole_Skill_Cls, "Skill_Type", "None");

    local IconName = TryGetProp(Cupole_Skill_Cls, "Skill_Icon", "None");
    SkillIcon:SetImage(IconName);

    SkillIcon:SetEventScript(ui.MOUSEON, "ON_CUPOLE_SKILL_TOOLTIP_OPEN");
    SkillIcon:SetEventScriptArgNumber(ui.MOUSEON, SkillClassID);
    SkillIcon:SetEventScript(ui.MOUSEOFF, "ON_CUPOLE_SKILL_TOOLTIP_CLOSE");
end

------보유 효과 세팅
function SET_CUPOLE_SKILL_DESC(frame, cls)
    if cls == nil then
        return;
    end
    local Desc = TryGetProp(cls, "Dec_Skill", "None")

end

------보유 효과 세팅
function SET_CUPOLE_OWNED_EFFECT(frame, cls, specifiedRank)
    local haveEffect = GET_CHILD(frame, "haveEffect")
    local rank = nil;
    if specifiedRank then
        rank = specifiedRank;
    end
    local Stat, Value = GET_CUPOLE_OWNED_RESULT_VALUE_BY_CLS(nil, cls, rank)

    if not Stat or not Value or not haveEffect then
        return;
    end
    SET_CUPOLE_STAT_AT_UI(haveEffect, Stat, Value)
end

-- 큐폴 친밀도 설정
function SET_CUPOLE_FRIENDLY(frame, clsid)
    local pc = GetMyPCObject();
    if pc == nil then
        return;
    end
    local acc = GetMyAccountObj(pc);
    if acc == nil then
        return;
    end
    local AccProp = GET_CUPOLE_PROP_BY_INDEX(clsid, "AccountProperty");
    local CupoleExp = TryGetProp(acc, AccProp, 0);
    SET_CUPOLE_FRIENDLY_RATE(frame, CupoleExp);
end

-- 친밀도 숫자 변경
function SET_CUPOLE_FRIENDLY_RATE(frame, exp)
    local Rate = GET_CHILD_RECURSIVELY_NAME(frame, "managerTab/manageBG/InfoBG/ExplainBG/friendly_pic/Rate")
    Rate:SetTextByKey("value", exp);
end

---큐폴 선택 버튼설정 로직
function SET_CUPOLE_SELECT_BTN(btnframe, funcscp, btnname)
    if btnframe ~= nil then
        btnframe:SetEventScript(ui.LBUTTONUP, funcscp);
        btnframe:SetText(ClMsg(btnname))
    end
end

function SET_CUPOLE_BTN_CITY(frame)
    local SelectBtn = GET_CHILD_RECURSIVELY(frame, "SelectBtn")
    local DisableBtn = GET_CHILD_RECURSIVELY(frame, "DisableBtn")

    if IS_IN_CITY() == 0 then
        SelectBtn:ShowWindow(0)
        DisableBtn:ShowWindow(0)
    end
end

---큐폴 uimodel offset 조절 함수
function SET_CUPOLE_MAINCHARACTERFRAME_BY_INDEX(index)
    local frame = ui.GetFrame("cupole_item")
    if frame == nil then
        return;
    end

    local MainCharacter = GET_CHILD_RECURSIVELY_NAME(frame, "managerTab/manageBG/MainCharacter")
    if MainCharacter == nil then
        return;
    end
    SET_RTT_OFFSET_IN_IMAGE(MainCharacter, index)
end

function SET_CUPOLE_GAHCAFRAME_BY_INDEX(frame, index)
    SET_RTT_OFFSET_IN_IMAGE(frame, index)
end

----특정 index의 offset 조절함수.
function SET_RTT_OFFSET_IN_IMAGE(frame, OffsetIndex)
    if OffsetIndex > 15 or OffsetIndex < 0 then
        print("error!!")
        return;
    end
    local CupoleUV = string.format("cupole_%d", OffsetIndex);
    frame:SetImage(CupoleUV)
end

---- 큐폴을 선택 체크 하는 로직.
function SET_SLOT_SELECT_STATE(SlotFrame, SelectBtnFrame, SelectBtnScp, SelectTextMsg, index)
    local parent = SelectBtnFrame:GetTopParentFrame();
    FRAME_COLOR_CHANGE(SlotFrame, "FF5CFFDF");
    if index == -1 then
        CHANGE_DISABLE_BTN_SHOWSTATE(0, SlotFrame:GetName(), index);
        return;
    end
    if string.find(SlotFrame:GetName(), "cupole_slot_") ~= nil then
        CHANGE_DISABLE_BTN_SHOWSTATE(0, SlotFrame:GetName(), index);
    else
        CHANGE_DISABLE_BTN_SHOWSTATE(1, SlotFrame:GetName(), index);
    end

    SET_CUPOLE_SELECT_BTN(SelectBtnFrame, SelectBtnScp, SelectTextMsg);
    SET_SELECT_CUPOLE_INFO_WITH_MODEL(parent, index);

    local upgradebtn_bg = GET_CHILD_RECURSIVELY(parent, "upgradebtn_bg")
    TOGGLE_CUPOLE_RANKUP_BTN(upgradebtn_bg);
    SET_CUPOLE_BTN_CITY(parent)
end

function SET_CUPOLE_BACKGROUND_IMAGE(frame, image)
    local parent = frame:GetTopParentFrame();
    if parent == nil then
        return;
    end
    local pic = GET_CHILD_RECURSIVELY_NAME(parent, "managerTab/pic")
    if pic == nil then
        return;
    end
    pic:SetImage(image)
end

function SET_BACKGROUND_IMAGE_BY_CUPOLE_INDEX(frame, index)
    local cls = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(index)
    if cls == nil then
        return;
    end
    TOGGLE_CUPOLE_BACKGROUND_IMAGE(frame, true)

    local grade = TryGetProp(cls, "Grade", "R")
    local ImageName = "";
    if grade == "UR" then
        ImageName = "kupole_ur_goddess"
    else
        ImageName = "kupole_r_sr"
    end
    SET_CUPOLE_BACKGROUND_IMAGE(frame, ImageName)
end

function SET_BACKGROUND_IMAGE_BY_PICKUP(frame, pickup)
    local parent = frame:GetTopParentFrame();
    local managerTab = GET_CHILD_RECURSIVELY(parent, "managerTab")
    SET_CUPOLE_BACKGROUND_IMAGE(frame, "back_cacheshop")

    TOGGLE_CUPOLE_BACKGROUND_IMAGE(frame, false)
    CUPOLE_SPINE_ANIMAITON_SET(managerTab, "Cache")
end

function TOGGLE_CUPOLE_BACKGROUND_IMAGE(frame, state)
    local parent = frame:GetTopParentFrame();
    local pic = GET_CHILD_RECURSIVELY_NAME(parent, "managerTab/pic")
    local spinebg = GET_CHILD_RECURSIVELY_NAME(parent, "managerTab/spinepic")

    if state == true then
        pic:ShowWindow(1);
        spinebg:ShowWindow(0);
    else
        pic:ShowWindow(1);
        spinebg:ShowWindow(1);
    end
end

function SET_BACKGROUND_IMAGE_BY_SELECT_TAB(frame, tab)
    if frame == nil or tab == nil then
        return;
    end
    local selc_cupole = GET_GLOBAL_SELECT_CUPOLE(frame);

    if tab == 0 then
        SET_BACKGROUND_IMAGE_BY_CUPOLE_INDEX(frame, selc_cupole)
    elseif tab == 1 then
        SET_BACKGROUND_IMAGE_BY_PICKUP(frame, 0);
    end
end
---get set 끝

-- 큐폴 UI의 기본적인 기능들을 구현해 놓은 것
-- 좌측 우측에서 사용하는  함수같은 경우에는 따로 루아파일을 만들어서 관리한다.
-- 여기서는 통합적인 로직 메인로직등등만을 작성해놓는다.

--------------------default function start

------큐폴 UI버튼 토글
function CUPOLE_ITEM_TOGGLE(parent, ctrl, argStr, argNum)
    local cupole_item = ui.GetFrame("cupole_item")
    cupole_item:ShowWindowToggle();
end

-----큐폴 UI등록
function CUPOLE_ITEM_ON_INIT(addon, frame)
    addon:RegisterMsg('SET_CUPOLE_EXP_UP', 'ON_SET_CUPOLE_EXP_UP');
    addon:RegisterMsg('CUPOLE_EQUIP_COMPLELTE', 'ON_SET_EQUIP_CUPOLE_OPTIONS');
    addon:RegisterMsg('GACHA_CUPOLE_RESULT', 'ON_GACHA_CUPOLE_RESULT');
    addon:RegisterMsg('GACHA_CUPOLE_RESULT', 'ON_GACHA_RESULT_APPLY_IN_CUPOLE_UI');
    addon:RegisterMsg('GACHA_CUPOLE_RESULT', 'ON_SET_EQUIP_CUPOLE_OPTIONS');

    addon:RegisterMsg('CUPOLE_ACTIVATE', 'PICKUP_ON_CUPOLE_ACTIVATE');
    addon:RegisterMsg('TAKE_CUPOLE_RANKUP_ITEM', 'PICKUP_ON_CUPOLE_ACTIVATE');

end

-----큐폴 UI OPEN시의 로직
function OPEN_CUPOLE_ITEM()
    local frame = ui.GetFrame("cupole_item");
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
    if equip_cupole_list == nil then
        return;
    end

    -- 큐폴 정렬
    local Cupole_Filter = ui.GetFrame("cupole_filter");
    filter_type = Cupole_Filter:GetUserValue("Filter");

    GET_CUPOLE_SORT_TYPE_FUNCTION(filter_type)

    ---현재 선택되어있는 큐폴 인덱스 가져오기
    local State, ChoosCupoleIndex, SlotIndex = GET_CHOOSE_INIT_CUPOLE(equip_cupole_list);
    frame:SetUserValue("Global_Select_Cupole", ChoosCupoleIndex);
    ---좌측 큐폴 슬롯 세팅
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

function INIT_SELECT_CUPOLE_STATE(frame, State, index, SlotIndex)
    local rightslotset = GET_CHILD_RECURSIVELY(frame, "slotsetBG")
    local SlotBG = GET_CHILD_RECURSIVELY(frame, "SlotBG")
    local gb_slot = GET_CHILD(SlotBG, "gb_slot")
    local SelectBtn = GET_CHILD_RECURSIVELY(frame, "SelectBtn");

    local SlotFrame = nil;

    local SelFunScp = ""
    local SelBtnTxt = ""
    if State == "left" then
        SelFunScp = "CUPOLE_LEFT_SLOT_EQUIP"
        SelBtnTxt = "swap"
        SlotFrame = gb_slot:GetChildByIndex(SlotIndex - 1)
    else
        SelFunScp = "CUPOLE_RIGHT_SLOT_EQUIP"
        SelBtnTxt = "equipment"
        SlotFrame = GET_CHILD_RECURSIVELY(rightslotset, "cupole_slot_1");
    end
    local Represent_cupole = GET_REPRESENT_CUPOLE_INFO()
    local clsid = TryGetProp(Represent_cupole, "ClassID", 0)
    SET_SLOT_SELECT_STATE(SlotFrame, SelectBtn, SelFunScp, SelBtnTxt, index);
    SelectBtn:ShowWindow(0)
end

---큐폴 UI닫음
function CLOSE_CUPOLE_ITEM(frame)
    CLOSE_RELEATIVE_FRAMES()
    RESET_CUPOLE_UIMODEL_FIX_DIR()
    -- local frame = ui.GetFrame("cupole_item");
    frame:StopUpdateScript('UPDATE_CUPOLE')

    -- 현재 UI모델을 삭제한다.
    local selc_cupole = GET_GLOBAL_SELECT_CUPOLE(frame);
    REMOVE_ALL_CUPOLE_UIMODEL()
end

---- 큐폴 삭제
function REMOVE_ALL_CUPOLE_UIMODEL()
    local cupole_list, cnt = GetClassList("cupole_list");
    for i = 0, cnt - 1 do
        HIDE_CUPOLE_UIMODEL(i);
    end
end

---------------------default function end

---------------------msg function start

-- 큐폴 경험치 갱신되면 게이지 갱신해준다
function ON_SET_CUPOLE_EXP_UP(frame, msg, argStr, argNum)
    -- 큐폴 친밀도 게이지 설정
    local cls = GET_CUPOLE_CLASS_ACCOUNTPROP(argStr)
    local index = TryGetProp(cls, "ClassID", -1);
    local ExplainBG = GET_CHILD_RECURSIVELY(frame, "ExplainBG")
    local companyEffect = GET_CHILD_RECURSIVELY(ExplainBG, "companyEffect")
    local haveEffect = GET_CHILD_RECURSIVELY(ExplainBG, "haveEffect")

    local Grade = TryGetProp(cls, "Grdae", "R");
    local res = 0.2;
    if Grade == "UR" then
        res = 0.5;
    elseif Grade == "SR" then
        res = 0.3;
    end

    local UpgradeStat, UpgradeRes = GET_CUPOLE_FRIENDLY_RESULT_VALUE_BY_CLS(nil, cls, argNum);
    local OwnedStat, OwendRes = GET_CUPOLE_OWNED_RESULT_VALUE_BY_CLS(nil, cls, argNum);

    SET_CUPOLE_STAT_AT_UI(companyEffect, UpgradeStat, UpgradeRes)
    SET_CUPOLE_STAT_AT_UI(haveEffect, OwnedStat, OwendRes)
    SET_CUPOLE_FRIENDLY_RATE(frame, argNum);
    ON_SET_EQUIP_CUPOLE_OPTIONS(frame)
end

-- 큐폴 장착 시 스탯 텍스트 갱신
function ON_SET_EQUIP_CUPOLE_OPTIONS(frame, msg, argStr, argNum)
    local pc = GetMyPCObject();
    if pc == nil then
        return 0;
    end
    local acc = GetMyAccountObj(pc);
    if acc == nil then
        return 0;
    end

    local OptionListBG = GET_CHILD_RECURSIVELY(frame, "OptionListBG")
    OptionListBG:SetScrollBarSkinName("verticalscrollbar3")

    local cupole_list, cnt = GetClassList("cupole_list");
    if cupole_list == nil then
        return;
    end

    local y = 0;
    local offset = 30;
    local defaultoffset = {15, 30};
    local Statlist = {};

    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(cupole_list, i);
        if cls ~= nil then
            local stat, value = GET_CUPOLE_OWNED_RESULT_VALUE_BY_CLS(pc, cls)
            if value > 0 then
                if Statlist[stat] == nil then
                    Statlist[stat] = value;
                else
                    Statlist[stat] = Statlist[stat] + value;
                end
            end
        end
    end

    for k, v in spairs(Statlist, function(t, a, b)
        return stat_sort_value[b] > stat_sort_value[a]
    end) do
        local ctrl = OptionListBG:CreateOrGetControlSet("cupole_stat_slot", k, defaultoffset[1], y * offset);
        local StatBox = GET_CHILD(ctrl, "Stat")
        SET_CUPOLE_STAT_AT_UI(StatBox, k, v)
        y = y + 1;
    end
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do
        keys[#keys + 1] = k
    end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a, b)
            return order(t, a, b)
        end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end
---------------------msg function end

---------------------- btn script start

--- 강화 탭 열기
function OPEN_REINFORCE_TAB(frame, ctrl, argStr, argNum)
    ui.OpenFrame('cupole_reinforce');
    local TopParent = frame:GetTopParentFrame()
    RESET_CUPOLE_SELECT_MODE(TopParent)
end

---큐폴 선택, 가챠 탭 전환
function CUPOLE_TAB_CHANGE(parent, ctrl, argStr, argNum)
    local tabObj = parent:GetChild('CupoleTab');
    local itembox_tab = tolua.cast(tabObj, "ui::CTabControl");
    local curtabIndex = itembox_tab:GetSelectItemIndex();
    CUPOLE_TAB_VIEW(parent, curtabIndex);
end

-- 큐폴 탭 전환 처리
function CUPOLE_TAB_VIEW(frame, curtabIndex)
    CLOSE_RELEATIVE_FRAMES()

    local parent = frame:GetTopParentFrame();
    local manageBG = frame:GetChild("manageBG")
    local gachaBG = frame:GetChild("gachaBG")
    local pickUpBG = frame:GetChild("pickUpBG")

    local Sel_Btn = GET_CHILD_RECURSIVELY(frame, "SelectBtn")
    local Dis_Btn = GET_CHILD_RECURSIVELY(frame, "DisableBtn")
    local filtergbox = GET_CHILD_RECURSIVELY(frame, "filtergbox")

    local equip_cupole_list = GET_EQUIP_CUPOLE_LIST()
    local State, ChoosCupoleIndex, SlotIndex = GET_CHOOSE_INIT_CUPOLE(equip_cupole_list);
    REMOVE_ALL_CUPOLE_UIMODEL();

    if curtabIndex == 0 then
        manageBG:ShowWindow(1)
        Sel_Btn:ShowWindow(1);
        Dis_Btn:ShowWindow(1);
        filtergbox:ShowWindow(1);
        gachaBG:ShowWindow(0);
        pickUpBG:ShowWindow(0);
        KUPOLE_UIMODEL_IN_MAINCHARACTER(ChoosCupoleIndex)
        SET_SELECT_CUPOLE_NAME(parent, ChoosCupoleIndex)
        TOGGLE_CUPOLE_SPECIAL_ADDON(parent, ChoosCupoleIndex)
        CHNAGE_ALL_CUPOLE_UIMODEL_STATE(1)
    elseif curtabIndex == 1 then
        manageBG:ShowWindow(0)
        Sel_Btn:ShowWindow(0);
        Dis_Btn:ShowWindow(0);
        filtergbox:ShowWindow(0);
        gachaBG:ShowWindow(0);
        pickUpBG:ShowWindow(1);
        OPEN_CUPOLE_PICKUP_TAB();
        CHNAGE_ALL_CUPOLE_UIMODEL_STATE(0)
        SET_CUPOLE_GACHA_COLOR(frame)
    end
    ON_SET_EQUIP_CUPOLE_OPTIONS(frame)
    LBTNUP_RESET_CUPOLE_SELECT_MODE(frame);
    SET_BACKGROUND_IMAGE_BY_SELECT_TAB(frame, curtabIndex)
end

-- 필터 on 버튼
function CUPOLE_FILTER_BTN(parent, ctrl, argStr, argNum)
    ui.ToggleFrame("cupole_filter")
    local frame = parent:GetTopParentFrame();
    RESET_CUPOLE_SELECT_MODE(frame)
end

function CUPOLE_UIMODEL_ROTATE_BTN(parent, ctrl, argStr, argNum)
    if argNum == 0 then
        CHANGE_CUPOLE_UIMODEL_FIX_DIR(-45)
    else
        CHANGE_CUPOLE_UIMODEL_FIX_DIR(45)
    end
end
---------------------- btn script end

-----------------setter- ---------------------------

---------------------------------------------------
function UPDATE_CUPOLE(frame)
    frame:Invalidate();
    return 1;
end

----maincharater 큐폴 설정 
function KUPOLE_UIMODEL_IN_MAINCHARACTER(index)
    -- REMOVE_ALL_CUPOLE_UIMODEL()
    local ownerHandle, ui_model = CREATE_CUPOLE_UIMODEL(index, true)
    local val = GET_CUPOLE_INDEX(ownerHandle, ui_model, true)
    SET_CUPOLE_MAINCHARACTERFRAME_BY_INDEX(val)
end

function KUPOLE_UIMODEL_IN_GACHA_RESULT(frame, index)
    local pic = GET_CHILD_RECURSIVELY_NAME(frame, "Gacha_GroupBox/Gacha_FrontFrameBox/Character");
    local ownerHandle, ui_model = CREATE_CUPOLE_UIMODEL(index)
    local val = GET_CUPOLE_INDEX(ownerHandle, ui_model)
    if val == -1 then
        ownerHandle, ui_model = CREATE_CUPOLE_UIMODEL(index)
        val = GET_CUPOLE_INDEX(ownerHandle, ui_model)
    end
    SET_CUPOLE_GAHCAFRAME_BY_INDEX(pic, val)
end

function KUPOLE_UIMODEL_IN_PICKUP(frame, index)
    index = GET_CURRENT_CUPOLE_SELECT_INDEX();
    local pic = GET_CHILD_RECURSIVELY_NAME(frame, "managerTab/manageBG/MainCharacter");
    local ownerHandle, ui_model = CREATE_CUPOLE_UIMODEL(index, true)
    local val = GET_CUPOLE_INDEX(ownerHandle, ui_model, true)
    -- if val == -1 then
    --     ownerHandle, ui_model = CREATE_CUPOLE_UIMODEL(index)
    --     val = GET_CUPOLE_INDEX(ownerHandle, ui_model)   
    -- end 
    SET_CUPOLE_GAHCAFRAME_BY_INDEX(pic, val)
end

---uimodel 생성
function CREATE_CUPOLE_UIMODEL(index, isMainCharacter)
    local monName = GET_CUPOLE_NAME_BY_INDEX(index)
    local cupole_info = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(index);
    if cupole_info == nil then
        return nil, nil;
    end
    if monName == "None" or monName == nil then
        return;
    end
    local Scale = TryGetProp(cupole_info, "Scale", 1)
    local FixSize = 1
    local ui_model = monName .. "_Render";
    local ownerHandle = session.GetMyHandle();
    local ownerActor = world.GetActor(ownerHandle);
    local monActor_uimodel = ownerActor:GetClientMonster():GetClientMonsterByName(ui_model);

    if isMainCharacter == true then
        FixSize = 3
    end
    if monActor_uimodel == nil then
        local ownerPos = ownerActor:GetPos();
        ownerActor:GetClientMonster():ClientMonsterToPosUIModel(ui_model, "STD", ownerPos.x, ownerPos.y, ownerPos.z, 0,
                                                                0, FixSize * Scale);
        monActor_uimodel = ownerActor:GetClientMonster():GetClientMonsterByName(ui_model);
        if monActor_uimodel ~= nil then
            local monHandle = monActor_uimodel:GetHandleVal();
            FixUIModelToActor(monHandle, ownerHandle, "None", 0, 100, 0, 1, 0, -1);
            StartCupoleAnimation(monHandle, ownerHandle);
        end
    end
    if isMainCharacter == true then
        SetForceCupoleRTTOffsetIndex(ownerHandle, ui_model, 0)
    end
    SetHideUIModel(ownerHandle, ui_model, false);
    return ownerHandle, ui_model;
end

----uimodel 제거
function HIDE_CUPOLE_UIMODEL(index)
    local monName = GET_CUPOLE_NAME_BY_INDEX(index)
    if monName == "None" or monName == nil then
        return;
    end
    local ownerHandle = session.GetMyHandle();
    local ownerActor = world.GetActor(ownerHandle);
    local ui_model = monName .. "_Render";
    local monActor_uimodel = ownerActor:GetClientMonster():GetClientMonsterByName(ui_model);
    if monActor_uimodel ~= nil then
        SetHideUIModel(ownerHandle, ui_model, true);
    end
end

function CHNAGE_CUPOLE_UIMODEL_STATE(index, state)
    local monName = GET_CUPOLE_NAME_BY_INDEX(index)
    if monName == "None" or monName == nil then
        return;
    end
    local ownerHandle = session.GetMyHandle();
    local ownerActor = world.GetActor(ownerHandle);
    local ui_model = monName .. "_Render";
    local monActor_uimodel = ownerActor:GetClientMonster():GetClientMonsterByName(ui_model);
    local scale = 1;

    if state == 0 then
        scale = 1;
    elseif state == 1 then
        scale = 3;
    elseif state == 2 then
        scale = 2;
    end

    if monActor_uimodel ~= nil then
        monActor_uimodel:ChangeScale(scale, 0, true);
    end
end

function CHNAGE_ALL_CUPOLE_UIMODEL_STATE(State)
    local cupole_list, cnt = GetClassList("cupole_list");
    for i = 0, cnt - 1 do
        CHNAGE_CUPOLE_UIMODEL_STATE(i, State);
    end
end

function CHANGE_CUPOLE_UIMODEL_FIX_DIR(x, y, z)
    local index = GET_GLOBAL_SELECT_CUPOLE();
    local monName = GET_CUPOLE_NAME_BY_INDEX(index)
    local ui_model = monName .. "_Render";

    local ownerHandle = session.GetMyHandle();
    local ownerActor = world.GetActor(ownerHandle);
    local monActor_uimodel = ownerActor:GetClientMonster():GetClientMonsterByName(ui_model);
    local monHandle = monActor_uimodel:GetHandleVal();

    FixUIModelChangeDir(monHandle, ownerHandle, x, y, z);
end

function RESET_CUPOLE_UIMODEL_FIX_DIR()
    local index = GET_GLOBAL_SELECT_CUPOLE();
    local monName = GET_CUPOLE_NAME_BY_INDEX(index)
    local ui_model = monName .. "_Render";

    local ownerHandle = session.GetMyHandle();
    local ownerActor = world.GetActor(ownerHandle);
    local monActor_uimodel = ownerActor:GetClientMonster():GetClientMonsterByName(ui_model);
    if monActor_uimodel ~= nil then
        local monHandle = monActor_uimodel:GetHandleVal();
        ResetUIModelDir(monHandle, ownerHandle);
    end
end

---큐폴 UI내에서 보유중인 돈 표시
function CUPOLE_ITEM_MONEY_SET(frame)
    local invenZeny = GET_CHILD_RECURSIVELY_NAME(frame, "managerTab/moneyGbox/invenZeny")
    local premiumTP = GET_CHILD_RECURSIVELY_NAME(frame, "managerTab/medalGbox_2/premiumTP")
    if invenZeny == nil or premiumTP == nil then
        return;
    end
    local accountObj = GetMyAccountObj();
    if accountObj == nil then
        return;
    end
    local silverAmountStr = GET_TOTAL_MONEY_STR();
    invenZeny:SetTextByKey("medal", GET_COMMAED_STRING(silverAmountStr));
    premiumTP:SetTextByKey("medal", tostring(accountObj.GiftMedal + accountObj.PremiumMedal + accountObj.Medal));
end

---큐폴 장착버튼 누를 시 특정 ui비활성화 
function CUPOLE_SELECT_MODE(frame, hittest, color, custom_ignore_list)
    if frame == nil then
        frame = ui.GetFrame("cupole_item");
    end
    local managerTab = GET_CHILD(frame, "managerTab")
    local manageBG = GET_CHILD(managerTab, "manageBG")
    local InfoBG = GET_CHILD(manageBG, "InfoBG")
    local slotsetBG = GET_CHILD(manageBG, "slotsetBG")

    local ignore_list = {"managerTab", "SlotBG", "slotsetBG", "manageBG", "cupole_manager_top"}
    SELECT_FRAME_CHANGE_STATE(frame, ignore_list, hittest, color);
    SELECT_FRAME_CHANGE_STATE(managerTab, ignore_list, hittest, color);
    SELECT_FRAME_CHANGE_STATE(InfoBG, ignore_list, hittest, color);
    SELECT_FRAME_CHANGE_STATE(slotsetBG, custom_ignore_list, hittest, color);
end

----해당 UI와 하위 자식을 비활성화 처리한다.
function SELECT_FRAME_CHANGE_STATE(frame, ignore_list, HitTestEnable, ColorTone)
    local MainFrameChildCount = frame:GetChildCount()
    for i = 0, MainFrameChildCount - 1 do
        local childframe = frame:GetChildByIndex(i)
        local IsIgnoreFrame = false;
        if ignore_list ~= nil then
            for k, v in pairs(ignore_list) do
                if v == childframe:GetName() then
                    IsIgnoreFrame = true;
                end
            end
        end
        if IsIgnoreFrame == false then
            childframe:EnableHitTest(HitTestEnable);
            FRAME_COLOR_CHANGE(childframe, ColorTone);
        end
    end
end

---큐폴 선택 상태 해체
function LBTNUP_RESET_CUPOLE_SELECT_MODE(parent, ctrl, argStr, argNum)
    local frame = parent:GetTopParentFrame();
    RESET_CUPOLE_SELECT_MODE(frame)
end

---큐폴 선택 상태 해체
function RESET_CUPOLE_SELECT_MODE(frame)
    local grand_parent = frame:GetTopParentFrame();
    local rightslotset = GET_CHILD_RECURSIVELY(frame, "slotsetBG")
    local SlotBG = GET_CHILD_RECURSIVELY(frame, "SlotBG")
    local gb_slot = GET_CHILD(SlotBG, "gb_slot")
    local SelectBtn = GET_CHILD_RECURSIVELY(frame, "SelectBtn");
    -- 색 제거
    FRAME_CHILD_COLORTONE_CLEAR(gb_slot)
    FRAME_CHILD_COLORTONE_CLEAR(rightslotset)

    -- 비활성화 제거
    CUPOLE_SELECT_MODE(frame, 1, "FFFFFFFF");
    CHANGE_DISABLE_BTN_SHOWSTATE(0);

    -- 선택 모드 종료
    gb_slot:SetUserValue("LEFT_SEL_SLOT", "None");
    gb_slot:SetUserValue("RIGHT_SEL_SLOT", "None");
    SET_CUPOLE_SELECT_BTN(SelectBtn, "None", "equipment");
    SET_CUPOLE_BTN_CITY(grand_parent)

    RESET_LEFT_CUPOLE_SLOTSET(grand_parent);
    RESET_RIGHT_CUPOLE_SLOTSET(grand_parent);

end

----해체 버튼 상태 조절.
function CHANGE_DISABLE_BTN_SHOWSTATE(ShowState, SlotName, CupoleIndex)
    local fraem = ui.GetFrame("cupole_item")
    local managerTab = GET_CHILD(fraem, "managerTab")
    local DisableBtn = GET_CHILD(managerTab, "DisableBtn");
    local Numberindex = tonumber(CupoleIndex)
    DisableBtn:ShowWindow(ShowState);
    if ShowState == 1 then
        DisableBtn:SetEventScript(ui.LBUTTONUP, "SELECT_CUPOLE_UNEQUIP");
    else
        DisableBtn:SetEventScript(ui.LBUTTONUP, "None");
    end
    if SlotName ~= nil then
        DisableBtn:SetEventScriptArgString(ui.LBUTTONUP, SlotName);
    end
    if Numberindex ~= nil then
        DisableBtn:SetEventScriptArgNumber(ui.LBUTTONUP, Numberindex);
    end

end

----마우스 오버 시 애니메이션 관련 함수

function SET_MOUSE_OVER_COLOR_CHNAGE_FUNC(frame)
    local btn = GET_CHILD(frame, "btn")

    btn:SetEventScript(ui.MOUSEON, "MOUSE_OVER_COLOR_CHANGE")
    btn:SetEventScript(ui.MOUSEOFF, "MOUSE_OUT_COLOR_CHANGE")

end

function TOGGLE_CUPOLE_RANKUP_BTN(frame)
    local btn = GET_CHILD(frame, "btn")

    local index = GET_GLOBAL_SELECT_CUPOLE();
    local cls = GET_CUPOLE_CLASS_BY_INDEX(index);
    local grade = TryGetProp(cls, "Grade", "None");
    local rank = GET_CUPOLE_RANK(nil, index)
    local maxrank = shared_cupole.get_max_friendly(grade)
    if maxrank == rank then
        btn:ShowWindow(0);
        frame:ShowWindow(0);
    else
        btn:ShowWindow(1);
        frame:ShowWindow(1);
    end

end

function MOUSE_OVER_COLOR_CHANGE(frame, ctrl, argStr, argNum)
    CHANGE_BTN_COLOR_WITH_FRAME(frame, "FFFFCC33")
end

function MOUSE_OUT_COLOR_CHANGE(frame, ctrl, argStr, argNum)
    CHANGE_BTN_COLOR_WITH_FRAME(frame, "FFFFFFFF")
end

function CHANGE_BTN_COLOR_WITH_FRAME(frame, color)
    FRAME_COLOR_CHANGE(frame, color)
    local btn = GET_CHILD_RECURSIVELY(frame, "btn")
    if btn ~= nil then
        FRAME_COLOR_CHANGE(btn, color)
    end
end

function FRAME_COLOR_CHANGE(frame, color)
    if frame == nil then
        return;
    end
    frame:SetColorTone(color);
end

----마우스 오버 시 애니메이션 관련 함수

function CHECK_ILLUSTRATION_MODE(frame, ctrl, argStr, argNum)
    local TopParent = frame:GetTopParentFrame();
    if ctrl == nil then
        ctrl = GET_CHILD_RECURSIVELY_NAME(TopParent, "managerTab/manageBG/InfoBG/illustration")
    end
    local manageBG = GET_CHILD_RECURSIVELY_NAME(TopParent, "managerTab/manageBG")
    local spinepic = GET_CHILD_RECURSIVELY_NAME(TopParent, "managerTab/manageBG/spinepic")
    local MainCharacter = GET_CHILD_RECURSIVELY_NAME(TopParent, "managerTab/manageBG/MainCharacter")

    local cls = GET_CUPOLE_CLASS_BY_INDEX(index)
    if cls == nil then
        return;
    end
    local illustrationName = TryGetProp(cls, "ClassName", "None")
    local illustrationMode = TryGetProp(cls, "IluustrationMode", "None")
    if illustrationMode == "NO" then
        spinepic:ShowWindow(0);
        MainCharacter:ShowWindow(1);
        ctrl:ShowWindow(0);
        return;
    end
    ctrl:ShowWindow(1);
    if ctrl:IsChecked() == 1 then
        local index = GET_GLOBAL_SELECT_CUPOLE();
        CUPOLE_SPINE_ANIMAITON_SET(manageBG, illustrationName)
        spinepic:ShowWindow(1);
        MainCharacter:ShowWindow(0);
    else
        spinepic:ShowWindow(0);
        MainCharacter:ShowWindow(1);
    end
end

function CUPOLE_SPINE_ANIMAITON_SET(frame, name)
    local spinepic = GET_CHILD(frame, "spinepic")
    local spineInfo = geSpine.GetSpineInfo(name);
    if spineInfo ~= nil then
        spinepic:CreateSpineActor(spineInfo:GetRoot(), spineInfo:GetAtlas(), spineInfo:GetJson(), "",
                                  spineInfo:GetAnimation());
        spinepic:SetIsStopAnim(false)
    end
end

function SET_FAVORITE_CUPOLE(parent, ctrl, argStr, argNum)
    local TopParent = parent:GetTopParentFrame();
    local cupoleindex = GET_GLOBAL_SELECT_CUPOLE();

    if CHECK_CUPOLE_WITHOUT_EQUIP(nil, cupoleindex) == false then
        return;
    end

    local isFavorite = IsFavoriteCupole(cupoleindex)
    SetFavoriteCupole(cupoleindex, not isFavorite);
    SET_CUPOLE_FAVORITE_ICON_STATE(ctrl, not isFavorite);
    SET_CUPOLE_LIST(TopParent)
end

function SET_CUPOLE_FAVORITE_ICON_STATE(frame, state)
    if state == true then
        frame:SetImage("favorite_active")
    else
        frame:SetImage("favorite_inactive")
    end
end

function TOGGLE_CUPOLE_SPECIAL_ADDON(frame, index)
    local cls = GET_CUPOLE_CLASS_BY_INDEX(index)
    local Special = TryGetProp(cls, "Special", "None")

    local PotionBG = GET_CHILD_RECURSIVELY(frame, "PotionBG")

    if Special == "None" then
        PotionBG:ShowWindow(0);
    else
        PotionBG:ShowWindow(1);
    end
end

function CLOSE_RELEATIVE_FRAMES()
    local filter = ui.CloseFrame("cupole_filter")
    local addon = ui.CloseFrame("cupole_addon")
end

function TOGGLE_POTION_AUTO_USE(parent, ctrl, argStr, argNum)
    local self = GetMyPCObject();
    if self == nil then
        return;
    end
    local value = GetExProp(self, "cupole_auto_potion");
    if value == 0 then
        ctrl:SetImage("potionhudoff")
    else
        ctrl:SetImage("potionhudon")
    end

    pc.ReqExecuteTx_Item("CUPOLE_PORITON_AUTO_USE_TOGGLE", 0, 0)
end

function ON_GACHA_RESULT_APPLY_IN_CUPOLE_UI(frame, msg, argStr, argNum)
    CUPOLE_FILTER_SELECT_RESET(frame)
end

function statsortfunc(left, right)
    return stat_sort_value[left[1]] > stat_sort_value[right[1]]
end

function dumptable(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. '[' .. k .. ']' .. dumptable(v) .. ','
        end
        return s .. '}'
    end
    return tostring(o)
end

function RBTN_CUPOLE_ITEM_EQUIP(parent, ctrl, argStr, argNum)

end

function RBTN_CUPOLE_ITEM_UNEQUIP(parent, ctrl, argStr, argNum)

end

-- !right_cupole_slot.lua
-- 우측 슬롯 초기화
-- 슬롯 초기화에 따른 index변경 필요.
function CUPOLE_FILTER_SELECT_RESET(filter_frame)
    local frame = ui.GetFrame("cupole_item");
    local pc = GetMyPCObject();
    if pc == nil then
        return;
    end

    filter_type = filter_frame:GetUserValue("Filter");
    GET_CUPOLE_SORT_TYPE_FUNCTION(filter_type)

    -- CREATE_CUPOLE_UIMODEL()
    SET_CUPOLE_LIST(frame)
end

-------------slot btn script ----------------

function SELECT_CUPOLE_UNEQUIP(parent, ctrl, argStr, argNum)
    local frame = parent:GetTopParentFrame();
    local rightslotset = GET_CHILD_RECURSIVELY(frame, "slotsetBG")
    local SlotBG = GET_CHILD_RECURSIVELY(frame, "SlotBG")
    local gb_slot = GET_CHILD(SlotBG, "gb_slot")
    local slot = GET_CHILD_RECURSIVELY(gb_slot, argStr)

    if IS_IN_CITY() == 0 then
        ui.SysMsg(ClMsg('AllowedInTown'));
        return;
    end

    RESET_CUPOLE_SLOT_INFORMATION(slot)

    local SelectBtn = GET_CHILD_RECURSIVELY(frame, "SelectBtn");
    SET_CUPOLE_SELECT_BTN(SelectBtn, "CUPOLE_RIGHT_SLOT_EQUIP", "equipment");
    SET_CUPOLE_SLOT_SET_FUNCTION(frame, "None");
    RESET_CUPOLE_SELECT_MODE(frame)
    SET_CUPOLE_BTN_VISIBILITY(frame, 0);
    SET_CUPOLE_BTN_CITY(frame)
end

function UNSUMMON_CUPOLE_BTN(frame, SlotIndex)
    local pc = GetMyPCObject();
    if pc == nil then
        return;
    end
    local etc = GetMyEtcObject(pc);
    if etc == nil then
        return;
    end

    local parent = frame:GetTopParentFrame();

    local CupoleEquipStr = TryGetProp(etc, "Cupole_Equip", "0;0;0");
    local CupoleEquipList = StringSplit(CupoleEquipStr, ';')
    local CupoleIndex = CupoleEquipList[SlotIndex + 1]
    local cls = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(CupoleIndex)
    local index = -1;
    -- if tonumber(cupole_exp) <= 0 then
    --     return;
    -- end
    SummonCupole(index, SlotIndex)
    -- movie.PlayEffect("F_sys_heart")
    -- local buff = AddBuff(pc, pc, BuffName, 1, 0, 0, 1);
    -- SetBuffUpdateTime(buff, 1000);
end

function SET_CUPOLE_LIST(frame)
    local managerTab = GET_CHILD(frame, "managerTab")
    local manageBG = GET_CHILD(managerTab, "manageBG")
    local slotsetBG = GET_CHILD(manageBG, "slotsetBG")
    if slotsetBG == nil then
        return;
    end

    slotsetBG:RemoveAllChild();
    GET_CUPOLE_SORT_TYPE_FUNCTION(filter_type);

    local pc = GetMyPCObject();
    if pc == nil then
        return;
    end
    local acc = GetMyAccountObj(pc);
    if acc == nil then
        return;
    end

    local offsetX = 4;
    local offsetY = 0;
    local posX = 102;
    local posY = 101;

    local row = 0;
    local col = 0;
    local MaxRowCnt = 3;
    for i = 1, #Cupole_List do
        local cupole_cls = Cupole_List[i][3]
        local AccountProp = TryGetProp(cupole_cls, "AccountProperty", "None");
        local Cupole_Exp = TryGetProp(acc, AccountProp, 0);
        local slotName = string.format("cupole_slot_%d", i);
        local cupole_slot_box = slotsetBG:CreateOrGetControlSet('cupole_slot', slotName, offsetX + row * posX,
                                                                offsetY + col * posY);

        local gb = GET_CHILD(cupole_slot_box, "gb");
        local revert = GET_CHILD(cupole_slot_box, "revert");
        local grade_img = GET_CHILD_RECURSIVELY(cupole_slot_box, "grade_img");
        local cupole_slot = GET_CHILD(cupole_slot_box, "cupole_slot");
        local disable_shadow = GET_CHILD(cupole_slot_box, "disable_shadow");
        local equip_img = GET_CHILD(cupole_slot_box, "equip_img")
        if cupole_slot == nil then
            return;
        end
        if gb == nil then
            return;
        end

        local Grade = TryGetProp(cupole_cls, "Grade", "R");
        local RankFrameName = string.format("cupole_grade_frame_%s", Grade);
        local RankName = string.format("cupole_grade_%s", Grade);
        local RevertFramaName = string.format("cupole_revert_%s", Grade);
        gb:SetImage(RankFrameName)
        grade_img:SetImage(RankName);
        revert:SetImage(RevertFramaName)

        local cupole_clsid = TryGetProp(cupole_cls, "ClassID", 0);

        gb:SetEventScript(ui.LBUTTONUP, "RIGHT_CUPOLE_SLOT_SELECT_BTN");
        gb:SetEventScriptArgString(ui.LBUTTONUP, slotName);
        gb:SetEventScriptArgNumber(ui.LBUTTONUP, tonumber(cupole_clsid - 1));

        local cupole_icon = cupole_slot:GetIcon();
        if cupole_icon == nil then
            cupole_icon = CreateIcon(cupole_slot);
        end
        if cupole_cls ~= nil then
            local IconImage = TryGetProp(cupole_cls, "Icon", "None");
            cupole_icon:SetImage(IconImage);
        end

        if Cupole_Exp <= 0 then
            disable_shadow:ShowWindow(1);
            disable_shadow:EnableDrawFrame(1);
        else
            disable_shadow:ShowWindow(0);
            disable_shadow:EnableDrawFrame(0);
        end
        equip_img:ShowWindow(0)
        row = row + 1;
        if row >= MaxRowCnt then
            row = 0;
            col = col + 1;
        end
    end
end

---우측 slotset 버튼 이벤트 함수 설정
function SET_CUPOLE_LIST_SET_FUNCTION(frame, funcName)
    local slotsetBG = GET_CHILD_RECURSIVELY(frame, "slotsetBG")
    local cupolecnt = slotsetBG:GetChildCount();

    GET_CUPOLE_SORT_TYPE_FUNCTION(filter_type);

    local offsetX = 4;
    local offsetY = 0;
    local posX = 102;
    local posY = 101;

    local row = 0;
    local col = 0;
    local MaxRowCnt = 3;

    for i = 1, #Cupole_List do
        local cupole_cls = Cupole_List[i][3]

        local slotName = string.format("cupole_slot_%d", i);
        local slot =
            slotsetBG:CreateOrGetControlSet('cupole_slot', slotName, offsetX + row * posX, offsetY + col * posY);

        local gb = GET_CHILD(slot, "gb");
        local cupole_clsid = TryGetProp(cupole_cls, "ClassID", 0);
        gb:SetEventScript(ui.LBUTTONUP, funcName);
        gb:SetEventScriptArgNumber(ui.LBUTTONUP, tonumber(cupole_clsid - 1));
        gb:SetEventScriptArgString(ui.LBUTTONUP, slotName)
        row = row + 1;
        if row >= MaxRowCnt then
            row = 0;
            col = col + 1;
        end
    end
end

-- 우측 슬롯셋에서 장착 버튼을 누르면 작동하는 함수 
-- 선택시 함수(장착 x)
function RIGHT_CUPOLE_SLOT_SELECT_BTN(parent, ctrl, argStr, argNum)
    local cupole = GET_REPRESENT_CUPOLE_INFO()
    local clsid = TryGetProp(cupole, "ClassID", 0)
    local frame = parent:GetTopParentFrame();
    local rightslotset = GET_CHILD_RECURSIVELY(frame, "slotsetBG")
    local SlotBG = GET_CHILD_RECURSIVELY(frame, "SlotBG")
    local gb_slot = GET_CHILD(SlotBG, "gb_slot")

    RESET_CUPOLE_UIMODEL_FIX_DIR();

    FRAME_CHILD_COLORTONE_CLEAR(gb_slot)
    FRAME_CHILD_COLORTONE_CLEAR(rightslotset)
    gb_slot:SetUserValue("RIGHT_SEL_SLOT", parent:GetName());

    rightslotset:SetUserValue("SEL_RIGHT_CUPOLE_IDX", argNum)
    local SelectBtn = GET_CHILD_RECURSIVELY(frame, "SelectBtn");
    SelectBtn:ShowWindow(1);

    SET_SLOT_SELECT_STATE(parent, SelectBtn, "CUPOLE_RIGHT_SLOT_EQUIP", "equipment", argNum);
    if clsid == argNum + 1 then
        SelectBtn:ShowWindow(0)
    end
end

-------장착 버튼 스크립트
function CUPOLE_RIGHT_SLOT_EQUIP(parent, ctrl, argStr, argNum)
    cupole_select_state = "right";
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

-- 우측 슬롯셋에서 큐폴을 선택하면 좌측에 정보를 이전하는 함수
function right_slotset_cupole_set_func(parent, ctrl, argStr, argNum)
    local grand_parent = parent:GetTopParentFrame();
    local SlotBG = GET_CHILD_RECURSIVELY(grand_parent, "SlotBG")
    local left_gb_slot = GET_CHILD(SlotBG, "gb_slot")
    local managerTab = GET_CHILD(grand_parent, "managerTab")

    local left_sel_slot_name = left_gb_slot:GetUserValue("LEFT_SEL_SLOT")
    local left_sel_slot = GET_CHILD_RECURSIVELY(grand_parent, left_sel_slot_name)
    -- slot에 정보 세팅 해주면서 왼쪽에 정보도 추가해주도록해야함.

    local IsDuplicateCupole = CHECK_IS_EQUIP_CUPOLE(nil, argNum)
    if IsDuplicateCupole == false then
        return;
    end

    SUMMON_SELECT_LEFT_CUPOLE_SLOT(left_sel_slot, argNum)
    -- 선택 세팅 후에 원상복구 시키는 로직.
    RESET_LEFT_CUPOLE_SLOTSET(grand_parent);
    RESET_RIGHT_CUPOLE_SLOTSET(grand_parent);
    CHANGE_DISABLE_BTN_SHOWSTATE(0);
end

function RESET_RIGHT_CUPOLE_SLOTSET(frame)
    local rightslotset = GET_CHILD_RECURSIVELY(frame, "slotsetBG")

    FRAME_CHILD_COLORTONE_CLEAR(rightslotset);
    SET_CUPOLE_SLOT_SET_FUNCTION(frame, "CUPOLE_SLOT_SELECT_BTN");
    rightslotset:SetUserValue("SEL_RIGHT_CUPOLE_IDX", -1);

    CUPOLE_SELECT_MODE(frame, 1, "FFFFFFFF");
end

-- left_cupole_slot.lua
local left_cupole_index;

-- param : slot frame
--        cupole_index
function SUMMON_SELECT_LEFT_CUPOLE_SLOT(frame, cupole_index)
    local cupolecls = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(cupole_index);
    if cupolecls == nil then
        frame:SetUserValue("SEL_CUPOLE_INDEX", -1)
        return;
    end
    local grand_parent = frame:GetTopParentFrame();

    if cupolecls ~= nil then
        frame:SetUserValue("SEL_CUPOLE_INDEX", cupole_index)
    end

    local SlotIndex = frame:GetUserIValue("SlotIndex");
    if SlotIndex ~= nil then
        SUMMON_CUPOLE_BTN(frame, cupole_index, SlotIndex);
        SET_SLOT_CUPOLE_INFO(frame, cupole_index)
        if SlotIndex == 0 then
            SET_SELECT_CUPOLE_INFO_WITH_MODEL(grand_parent, cupole_index)
        end
    end
end

-- param : slot frame
--        cupole_index
--        cupole_index2
function SET_SWAP_LEFT_CUPOLE_SLOT(fromframe, destframe, fromindex, destindex)
    local pc = GetMyPCObject();
    if pc == nil then
        return;
    end
    local etc = GetMyEtcObject(pc);
    if etc == nil then
        return;
    end

    local fromcls = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(fromindex);
    local destcls = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(destindex);

    if fromcls == nil or destcls == nil then
        return;
    end
    local grand_parent = fromframe:GetTopParentFrame();

    ----------------------------------------------------------------------
    SET_SLOT_CUPOLE_INFO(fromframe, destindex)
    SET_SLOT_CUPOLE_INFO(destframe, fromindex)
    ----------------------------------------------------------------------

    local FromSlotIndex = fromframe:GetUserIValue("SlotIndex")
    local DestSlotIndex = destframe:GetUserIValue("SlotIndex")

    local EquipState = TryGetProp(etc, "Cupole_Equip", "-1;-1;-1");
    local equiplist = StringSplit(EquipState, ';')

    equiplist[FromSlotIndex + 1] = destindex;
    equiplist[DestSlotIndex + 1] = fromindex;

    if FromSlotIndex ~= nil and DestSlotIndex ~= nil then
        SET_CUPOLE_SLOTS_BY_INDEX(tonumber(equiplist[1]), tonumber(equiplist[2]), tonumber(equiplist[3]));
        SET_SELECT_CUPOLE_INFO_WITH_MODEL(grand_parent, tonumber(equiplist[1]))
    end

    SET_CUPOLE_BTN_VISIBILITY(grand_parent, 0);
end

function SET_SLOT_CUPOLE_INFO(frame, cupole_index, isEquip)
    if frame == nil or cupole_index == nil then
        return;
    end
    local cupolecls = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(cupole_index);
    local Gb = GET_CHILD(frame, "gb");
    local revert = GET_CHILD_RECURSIVELY(frame, "revert");
    local grade_img = GET_CHILD_RECURSIVELY(frame, "grade_img");
    local Cupole_Slot = GET_CHILD(frame, "cupole_slot");
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
    if cupolecls ~= nil then
        local IconImage = TryGetProp(cupolecls, "Icon", "None");
        if IconImage ~= "None" then
            Cupole_Icon:SetImage(IconImage);
        end
    end
    local index = tonumber(cupole_index)
    if equip_img ~= nil then
        if index >= 0 then
            equip_img:ShowWindow(1);
        else
            equip_img:ShowWindow(0);
        end
    end
end

---좌측 미니 슬롯 이벤트 설정.
function SET_CUPOLE_SLOT_SET_FUNCTION(frame, funcName)
    local SlotBG = GET_CHILD_RECURSIVELY(frame, "SlotBG")
    local left_gb_slot = GET_CHILD(SlotBG, "gb_slot")
    local cupolecnt = left_gb_slot:GetChildCount();

    GET_CUPOLE_SORT_TYPE_FUNCTION(filter_type);
    for i = 0, cupolecnt - 1 do
        local slot = left_gb_slot:GetChildByIndex(i);
        local gb = GET_CHILD(slot, "gb")
        gb:SetEventScript(ui.LBUTTONUP, funcName)
    end
end

function SET_CUPOLE_SLOTS_BY_INDEX(left, center, right)
    local pc = GetMyPCObject();
    if pc == nil then
        return;
    end
    local etc = GetMyEtcObject(pc);
    if etc == nil then
        return;
    end
    local leftcls = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(left)
    local centercls = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(center)
    local rightcls = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(right)

    local leftetcProp = TryGetProp(leftcls, "AccountProperty", "None")
    local centeretcProp = TryGetProp(centercls, "AccountProperty", "None")
    local rightetcProp = TryGetProp(rightcls, "AccountProperty", "None")

    local left_cupole_exp = TryGetProp(etc, leftetcProp, 0);
    local center_cupole_exp = TryGetProp(etc, centeretcProp, 0);
    local right_cupole_exp = TryGetProp(etc, rightetcProp, 0);

    SwapCupoleSlot(left, center, right)
end

-- param : slot frame
function RESET_CUPOLE_SLOT_INFORMATION(frame)
    local gb = GET_CHILD(frame, "gb");
    local revert = GET_CHILD(frame, "revert");
    local cupole_slot = GET_CHILD(frame, "cupole_slot");

    if cupole_slot == nil then
        return;
    end
    if gb == nil then
        return;
    end

    local equip_img = GET_CHILD_RECURSIVELY(frame, "equip_img");
    equip_img = AUTO_CAST(equip_img)
    local grade_img = GET_CHILD_RECURSIVELY(frame, "grade_img");

    local RankFrameName = "cupole_grade_frame_R"
    gb:SetImage(RankFrameName)
    revert:SetImage("")
    grade_img:SetImage("")
    local cupole_icon = cupole_slot:GetIcon();
    if cupole_icon == nil then
        cupole_icon = CreateIcon(cupole_slot);
    end
    cupole_icon:SetImage(nil);
    frame:SetUserValue("SEL_CUPOLE_INDEX", -1)
    equip_img:ShowWindow(0);
    local SlotIndex = frame:GetUserIValue("SlotIndex");
    if SlotIndex ~= nil then
        UNSUMMON_CUPOLE_BTN(frame, SlotIndex);
    end
end

-- 선택시 함수(장착 x)
function CUPOLE_SLOT_SELECT_BTN(parent, ctrl, argStr, argNum)
    local frame = parent:GetTopParentFrame();
    local rightslotset = GET_CHILD_RECURSIVELY(frame, "slotsetBG")
    local SlotBG = GET_CHILD_RECURSIVELY(frame, "SlotBG")
    local gb_slot = GET_CHILD(SlotBG, "gb_slot")

    local bg = parent:GetParent();
    FRAME_CHILD_COLORTONE_CLEAR(bg)
    FRAME_CHILD_COLORTONE_CLEAR(rightslotset)
    gb_slot:SetUserValue("LEFT_SEL_SLOT", parent:GetName());

    local SEL_CUPOLE_INDEX = parent:GetUserIValue("SEL_CUPOLE_INDEX")
    local SelectBtn = GET_CHILD_RECURSIVELY(frame, "SelectBtn");

    if SEL_CUPOLE_INDEX == -1 then
        SelectBtn:ShowWindow(0);
    else
        SelectBtn:ShowWindow(1);
    end
    SET_SLOT_SELECT_STATE(parent, SelectBtn, "CUPOLE_LEFT_SLOT_EQUIP", "swap", SEL_CUPOLE_INDEX);
end

-------장착 버튼 스크립트
function CUPOLE_LEFT_SLOT_EQUIP(parent, ctrl, argStr, argNum)
    cupole_select_state = "left";
    local frame = parent:GetTopParentFrame();
    if frame == nil then
        return;
    end

    if IS_IN_CITY() == 0 then
        ui.SysMsg(ClMsg('AllowedInTown'));
        return;
    end

    SET_CUPOLE_LIST_SET_FUNCTION(frame, "right_slotset_cupole_set_func");
    SET_CUPOLE_SLOT_SET_FUNCTION(frame, "left_slotset_cupole_change_func");

    local ignore_list = {"managerTab", "SlotBG", "slotsetBG", "manageBG"}

    CUPOLE_SELECT_MODE(frame, 0, "FF222222");
end

-- 좌측 슬롯셋에 정보를 전달하는 함수
function left_slotset_cupole_set_func(parent, ctrl, argStr, argNum)
    local grand_parent = parent:GetTopParentFrame();
    local rightslotset = GET_CHILD_RECURSIVELY(grand_parent, "slotsetBG")

    local cupoleidx = rightslotset:GetUserValue("SEL_RIGHT_CUPOLE_IDX")
    local current_sel_slot_name = parent:GetName();

    cupoleidx = tonumber(cupoleidx)
    local IsDuplicateCupole = CHECK_IS_EQUIP_CUPOLE(nil, cupoleidx)
    if IsDuplicateCupole == false then
        return;
    end

    SUMMON_SELECT_LEFT_CUPOLE_SLOT(parent, cupoleidx)

    RESET_RIGHT_CUPOLE_SLOTSET(grand_parent)
    RESET_LEFT_CUPOLE_SLOTSET(grand_parent)

    SET_CUPOLE_BTN_VISIBILITY(grand_parent, 0)
end

-- 좌측 슬롯셋끼리 정보를 교환하게 만드는 함수.
function left_slotset_cupole_change_func(parent, ctrl, argStr, argNum)
    local grand_parent = parent:GetTopParentFrame();
    local SlotBG = GET_CHILD_RECURSIVELY(grand_parent, "SlotBG")
    local left_gb_slot = GET_CHILD(SlotBG, "gb_slot")

    local from_sel_slot_name = left_gb_slot:GetUserValue("LEFT_SEL_SLOT")
    local current_sel_slot_name = parent:GetName();
    if from_sel_slot_name ~= current_sel_slot_name then
        local from_sel_slot = GET_CHILD_RECURSIVELY(grand_parent, from_sel_slot_name)

        local from_sel_slot_cupole_index = from_sel_slot:GetUserIValue("SEL_CUPOLE_INDEX")
        local current_sel_slot_cupole_index = parent:GetUserIValue("SEL_CUPOLE_INDEX")
        -- slot에 정보 세팅 해주면서 왼쪽에 정보도 추가해주도록해야함.
        SET_SWAP_LEFT_CUPOLE_SLOT(from_sel_slot, parent, from_sel_slot_cupole_index, current_sel_slot_cupole_index)
    end

    RESET_RIGHT_CUPOLE_SLOTSET(grand_parent)
    RESET_LEFT_CUPOLE_SLOTSET(grand_parent)
end

-- 큐폴 소환
function SUMMON_CUPOLE_BTN(frame, argNum, SlotIndex)
    local pc = GetMyPCObject();
    if pc == nil then
        return;
    end
    local etc = GetMyEtcObject(pc);
    if etc == nil then
        return;
    end
    local parent = frame:GetTopParentFrame();
    local cls = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(argNum)
    local etcProp = TryGetProp(cls, "AccountProperty", "None")
    local cupole_exp = TryGetProp(etc, etcProp, 0);
    if cls ~= nil then
        SummonCupole(argNum, SlotIndex)
    end
end

function RESET_LEFT_CUPOLE_SLOTSET(frame)
    local SlotBG = GET_CHILD_RECURSIVELY(frame, "SlotBG")
    local left_gb_slot = GET_CHILD(SlotBG, "gb_slot")

    SET_CUPOLE_LIST_SET_FUNCTION(frame, "RIGHT_CUPOLE_SLOT_SELECT_BTN");
    left_gb_slot:SetUserValue("LEFT_SEL_SLOT", "None");

    CUPOLE_SELECT_MODE(frame, 1, "FFFFFFFF");
end

function SET_CUPOLE_BTN_VISIBILITY(parent, visible)
    local SelectBtn = GET_CHILD_RECURSIVELY(parent, "SelectBtn");
    local DisableBtn = GET_CHILD_RECURSIVELY(parent, "DisableBtn");
    SelectBtn:ShowWindow(visible)
    DisableBtn:ShowWindow(visible)

    if IS_IN_CITY() == 0 then
        SelectBtn:ShowWindow(0)
        DisableBtn:ShowWindow(0)
    else
        SelectBtn:ShowWindow(1)
        DisableBtn:ShowWindow(1)
    end
end

-- !shared_cupole.lua
shared_cupole = {}
local cupole_exp_table = nil

-- 등급별 확률
local cupole_grade_table_list = nil
local cupole_grade_table_list_ratio = nil

local cupole_name_list_by_grade = nil
local cupole_name_ratio_list_by_grade = nil
-- 확정영입
local cupole_recruit_item_name = 'Premium_cupole_recruit_ticket'
local cupole_pickup_prop_name = 'cupole_pick_up'
local cupole_pickup_count = 300
local cupole_rankup_item_prefix = 'cupole_rankup_'

function make_cupole_grade_table()
    if cupole_grade_table_list ~= nil then
        return
    end

    cupole_grade_table_list = {}
    cupole_grade_table_list_ratio = {}

    local cls = GetClass('cupole_ratio', 'grade_ratio')
    table.insert(cupole_grade_table_list, 'UR')
    table.insert(cupole_grade_table_list, 'SR')
    table.insert(cupole_grade_table_list, 'R')

    local value = TryGetProp(cls, 'UR', 0)
    if value == 0 then
        print('cupole ratio error')
    end
    table.insert(cupole_grade_table_list_ratio, value)
    value = TryGetProp(cls, 'SR', 0)
    if value == 0 then
        print('cupole ratio error')
    end
    table.insert(cupole_grade_table_list_ratio, value)
    value = TryGetProp(cls, 'R', 0)
    if value == 0 then
        print('cupole ratio error')
    end
    table.insert(cupole_grade_table_list_ratio, value)

    cupole_name_list_by_grade = {}
    cupole_name_ratio_list_by_grade = {}
    for i = 1, #cupole_grade_table_list do
        cupole_name_list_by_grade[cupole_grade_table_list[i]] = {}
        cupole_name_ratio_list_by_grade[cupole_grade_table_list[i]] = {}
    end

    local list, cnt = GetClassList('cupole_ratio')
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(list, i)
        local grade = TryGetProp(cls, 'Grade', 'None')
        if grade ~= 'None' then
            table.insert(cupole_name_list_by_grade[grade], TryGetProp(cls, 'ClassName', 'None'))
            table.insert(cupole_name_ratio_list_by_grade[grade], TryGetProp(cls, 'Ratio', 0))
        end
    end
end
make_cupole_grade_table()

shared_cupole.get_max_friendly = function(grade)
    local max = 0;
    if grade == "UR" then
        max = 7;
    elseif grade == "SR" then
        max = 6;
    else
        max = 5;
    end
    return max
end

function get_cupole_recruit_item_name()
    return cupole_recruit_item_name
end
function get_cupole_pickup_propname()
    return cupole_pickup_prop_name
end
function get_cupole_pickup_count()
    return cupole_pickup_count
end

function GET_CUPOLE_PICKUP_PROP_COUNT(pc)
    if pc == nil then
        if IsServerSection(pc) == 1 then
            return 0;
        else
            pc = GetMyPCObject();
        end
    end
    local acc = nil;
    if IsServerSection() == 1 then
        acc = GetAccountObj(pc);
    else
        acc = GetMyAccountObj(pc);
    end

    local accprop = get_cupole_pickup_propname()

    local accCnt = TryGetProp(acc, accprop, 0)
    return accCnt;
end

-- count = 회차 정보
function GET_CUPOLE_GRADE(count)
    local index = GIBBS_SAMPLING(cupole_grade_table_list_ratio)
    local grade = cupole_grade_table_list[index]
    if count == 11 then
        if grade == 'R' then
            grade = 'SR'
        end
    end

    return grade
end
-- count = 회차 정보
function GET_CUPOLE_CLASSNAME(count)
    local grade = GET_CUPOLE_GRADE(count)
    local index = GIBBS_SAMPLING(cupole_name_ratio_list_by_grade[grade])
    local name = cupole_name_list_by_grade[grade][index]
    return name, grade
end
function GET_CUPOLE_RANKUP_ITEM_PREFIX()
    return cupole_rankup_item_prefix
end

-- 큐폴의 cls를 index로 가져온다.
function GET_CUPOLE_CLASS_BY_INDEX(index)
    local list, cnt = GetClassList("cupole_list")
    local cls = GetClassByIndexFromList(list, index)
    return cls;
end

-- 큐폴의 cls를 groupid로 가져온다.
function GET_CUPOLE_CLASS_BY_GROUPID(groupid)
    local list, cnt = GetClassList("cupole_list")
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(list, i);
        if cls ~= nil then
            local TargetGroupID = TryGetProp(cls, "Group_ID", "None");
            if TargetGroupID == groupid then
                return cls;
            end
        end
    end
    return nil;
end

---이미 착용한 큐폴인지 체크한다.
function CHECK_IS_EQUIP_CUPOLE(pc, index)
    local res, state = CHECK_CUPOLE_VALID(pc, index);
    return res;
end

function CHECK_CUPOLE_WITHOUT_EQUIP(pc, index)
    local res, state = CHECK_CUPOLE_VALID(pc, index);
    if res == false and state ~= "Equip" then
        return false;
    end
    return true;
end

-- 유효한 큐폴인지 확인한다
function CHECK_CUPOLE_VALID(pc, index)
    if index == nil then
        return false;
    end
    if pc == nil then
        if IsServerSection(pc) == 1 then
            return 0;
        else
            pc = GetMyPCObject();
        end
    end
    local acc = nil;
    if IsServerSection() == 1 then
        acc = GetAccountObj(pc);
    else
        acc = GetMyAccountObj(pc);
    end
    local list, cnt = GetClassList("cupole_list")
    local EquipList = GET_CUPOLE_EQUIP_INFO(pc)

    -- 유효 체크
    local cls = GetClassByIndexFromList(list, index)
    if cls == nil then
        return false, "None";
    end

    -- 보유 체크
    local AccProp = TryGetProp(cls, "AccountProperty", "None")
    local CupoleRank = TryGetProp(acc, AccProp, 0);
    if CupoleRank == 0 then
        return false, "NoneHave";
    end

    -- 장착 체크
    for k, v in pairs(EquipList) do
        if tonumber(v) == index then
            return false, "Equip";
        end
    end

    local usestate = TryGetProp(cls, "Use", "false");
    if usestate == "false" then
        return false, "Useless"
    end
    return true;
end

-- 대표 큐폴의 cls를 가져온다
function GET_REPRESENT_CUPOLE_INFO(pc)
    local EquipList = GET_CUPOLE_EQUIP_INFO(pc)

    local list, cnt = GetClassList("cupole_list")

    if list ~= nil and cnt > 0 then
        local cls = GetClassByIndexFromList(list, tonumber(EquipList[1]));
        if cls == nil then
            return nil;
        end
        return cls;
    end

    return nil;
end

-- 대표 큐폴의 skillinfo를 가져온다.
function GET_REPRESENT_CUPOLE_SKILL_INFO(pc, SkillType)
    if pc == nil then
        if IsServerSection(pc) == 1 then
            return nil, 'R', -1;
        else
            pc = GetMyPCObject();
        end
    end
    local acc = nil;
    if IsServerSection() == 1 then
        acc = GetAccountObj(pc);
    else
        acc = GetMyAccountObj(pc);
    end
    if acc == nil then
        return nil, 'R', -1;
    end

    local cls = GET_REPRESENT_CUPOLE_INFO(pc);
    if cls == nil then
        return;
    end
    local GroupID = TryGetProp(cls, "Group_ID", "None")
    local SkillTable = GET_CUPOLE_SKILL_BY_GROUPID_LIST(GroupID)
    if SkillTable == nil then
        return;
    end
    local SkillCls = nil;
    for k, v in pairs(SkillTable) do
        local Type = TryGetProp(v, "Skill_Type", "None")
        if Type == SkillType then
            SkillCls = v;
        end
    end

    local Grade = TryGetProp(cls, "Grade", "R");
    local accprop = TryGetProp(cls, "AccountProperty", "None");
    local Rank = TryGetProp(acc, accprop, 0)
    return SkillCls, Grade, Rank;
end

-- index 큐폴의 skillinfo를 가져온다.
function GET_CUPOLE_SKILL_INFO(pc, index, skilltype)
    if pc == nil then
        if IsServerSection(pc) == 1 then
            return nil, 'R', -1;
        else
            pc = GetMyPCObject();
        end
    end
    local acc = nil;
    if IsServerSection() == 1 then
        acc = GetAccountObj(pc);
    else
        acc = GetMyAccountObj(pc);
    end
    if acc == nil then
        return nil, 'R', -1;
    end

    local cls = GET_CUPOLE_CLASS_BY_INDEX(index);
    if cls == nil then
        return nil, 'R', -1;
    end
    local GroupID = TryGetProp(cls, "Group_ID", "None")
    local SkillTable = GET_CUPOLE_SKILL_BY_GROUPID_LIST(GroupID)
    if SkillTable == nil then
        return nil, 'R', -1;
    end
    local SkillCls = nil;
    for _, v in pairs(SkillTable) do
        local Type = TryGetProp(v, "Skill_Type", "None")
        if Type == skilltype then
            SkillCls = v;
        end
    end

    local Grade = TryGetProp(cls, "Grade", "R");
    local accprop = TryGetProp(cls, "AccountProperty", "None");
    local Rank = TryGetProp(acc, accprop, 0)
    return SkillCls, Grade, Rank;
end

-- groupid로 skilllist를 가져온다.
function GET_CUPOLE_SKILL_BY_GROUPID_LIST(group_id)
    if group_id == "None" then
        return nil;
    end
    local cupole_skill, cnt = GetClassList("cupole_skill");
    local skilltable = {}
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(cupole_skill, i)
        local GroupID = TryGetProp(cls, "Group_ID", "None")
        if GroupID == group_id then
            table.insert(skilltable, cls);
        end
    end
    return skilltable;
end

-- groupid로 upgradelist를 가져온다.
function GET_CUPOLE_UPGRADE_BY_GROUPID_LIST(group_id)
    local cupole_upgrade, cnt = GetClassList("cupole_upgrade");
    local upgradetable = {}
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(cupole_upgrade, i)
        local GroupID = TryGetProp(cls, "Group_ID", "None")
        if GroupID == group_id then
            table.insert(upgradetable, cls);
        end
    end
    return upgradetable;
end

function GET_CUPOLE_AUTO_POTION_CLS(index)
    local cls = GetClassByType('cupole_auto_potion', index)
    return cls;
end

function GET_CUPOLE_CLASS_ACCOUNTPROP(accprop)
    local list, cnt = GetClassList("cupole_list")
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(list, i)
        local acc = TryGetProp(cls, "AccountProperty", "None");
        if acc == accprop then
            return cls;
        end
    end
    return nil;
end

function GET_CUPOLE_SPECIAL_ACCOUNTPROPS(index)
    local cls = GET_CUPOLE_CLASS_BY_INDEX(index)
    local prop1 = TryGetProp(cls, "SpecialProp1", "None")
    local prop2 = TryGetProp(cls, "SpecialProp2", "None")
    return prop1, prop2;
end

function GET_CUPOLE_SPECIAL_ITEMS(pc, index)
    if pc == nil then
        if IsServerSection(pc) == 1 then
            return 0;
        else
            pc = GetMyPCObject();
        end
    end
    local acc = nil;
    if IsServerSection() == 1 then
        acc = GetAccountObj(pc);
    else
        acc = GetMyAccountObj(pc);
    end
    if acc == nil then
        return 0;
    end
    local prop1, prop2 = GET_CUPOLE_SPECIAL_ACCOUNTPROPS(index)

    local Item1 = TryGetProp(acc, prop1, "None")
    local Item2 = TryGetProp(acc, prop2, "None")

    return Item1, Item2;
end

function GET_CUPOLE_SPECIAL_ITEM_CLSLIST(pc, index)
    local itemid1, itemid2 = GET_CUPOLE_SPECIAL_ITEMS(pc, index)
    local itemCls1 = GetClassByType("Item", itemid1);
    local itemCls2 = GetClassByType("Item", itemid2);
    local itemlist = {itemCls1, itemCls2};
    return itemlist
end

function SET_CUPOLE_EQUIP_INFO(pc, index)

end

function GET_CUPOLE_EQUIP_INFO(pc)
    local etcObj = nil
    if IsServerSection(pc) == 1 then
        etcObj = GetETCObject(pc);
    else
        etcObj = GetMyEtcObject();
    end
    if etcObj == nil then
        return 0;
    end

    local equipstr = TryGetProp(etcObj, "Cupole_Equip", "-1;-1;-1");
    local equip_list = StringSplit(equipstr, ';')

    for k, v in pairs(equip_list) do
        if v == nil then
            equip_list[k] = -1;
        end
    end

    return equip_list;
end

-- 큐폴의 업그레이드 스텟 관련 정보를 가져옴.
function GET_CUPOLE_UPGRADE_STAT_VALUE(cls)
    local Cupole_Group_ID = TryGetProp(cls, "Group_ID", "None");
    local Cupole_Upgrade_List = GET_CUPOLE_UPGRADE_BY_GROUPID_LIST(Cupole_Group_ID)
    local Cupole_Upgrade_Cls = Cupole_Upgrade_List[1];
    if Cupole_Upgrade_Cls == nil then
        return;
    end

    local Stat = TryGetProp(Cupole_Upgrade_Cls, "Stat_Upgrade", "None")
    local UpgradeValue = TryGetProp(Cupole_Upgrade_Cls, "Upgrade_value", 0)
    return Stat, UpgradeValue;
end

-- 큐폴의 업그레이드 스텟 관련 정보를 가져옴.
function GET_CUPOLE_OWNED_STAT_VALUE(cls)
    local Cupole_Group_ID = TryGetProp(cls, "Group_ID", "None");
    local Cupole_Upgrade_List = GET_CUPOLE_UPGRADE_BY_GROUPID_LIST(Cupole_Group_ID)
    local Cupole_Upgrade_Cls = Cupole_Upgrade_List[1];
    if Cupole_Upgrade_Cls == nil then
        return;
    end

    local Stat = TryGetProp(Cupole_Upgrade_Cls, "Owned_Stat", "None")
    local UpgradeValue = TryGetProp(Cupole_Upgrade_Cls, "Owned_Value", 0)
    return Stat, UpgradeValue;
end

function GET_CUPOLE_OWNED_VALUE(pc, index)
    local cls = GET_CUPOLE_CLASS_BY_INDEX(index)
    if cls == nil then
        return;
    end
    GET_CUPOLE_OWNED_RESULT_VALUE_BY_CLS(pc, cls)
end

function GET_CUPOLE_OWNED_RESULT_VALUE_BY_CLS(pc, cls, specifiedRank)
    if cls == nil then
        return 0;
    end

    if pc == nil then
        if IsServerSection(pc) == 1 then
            return 0;
        else
            pc = GetMyPCObject();
        end
    end
    local acc = nil;
    if IsServerSection() == 1 then
        acc = GetAccountObj(pc);
    else
        acc = GetMyAccountObj(pc);
    end
    if acc == nil then
        return 0;
    end

    local AccountProp = TryGetProp(cls, "AccountProperty", "None");
    local CupoleRank = TryGetProp(acc, AccountProp, 0)
    local Stat, OwnedValue = GET_CUPOLE_OWNED_STAT_VALUE(cls);
    if specifiedRank ~= nil then
        CupoleRank = specifiedRank;
    end
    if CupoleRank == 0 then
        return Stat, 0;
    end
    local res = GET_CUPOLE_STAT_RECURRENCE_RELATION(OwnedValue, 0.2, CupoleRank);
    return Stat, res;
end

function GET_CUPOLE_FRIENDLY_VALUE(pc, index)
    local cls = GET_CUPOLE_CLASS_BY_INDEX(index)
    if cls == nil then
        return;
    end
    GET_CUPOLE_FRIENDLY_RESULT_VALUE_BY_CLS(pc, cls)
end

function GET_CUPOLE_FRIENDLY_RESULT_VALUE_BY_CLS(pc, cls, specifiedRank)
    if cls == nil then
        return 0;
    end

    if pc == nil then
        if IsServerSection(pc) == 1 then
            return 0;
        else
            pc = GetMyPCObject();
        end
    end
    local acc = nil;
    if IsServerSection() == 1 then
        acc = GetAccountObj(pc);
    else
        acc = GetMyAccountObj(pc);
    end
    if acc == nil then
        return 0;
    end

    local AccountProp = TryGetProp(cls, "AccountProperty", "None");
    local Grade = TryGetProp(cls, "Grade", "R");
    local CupoleRank = TryGetProp(acc, AccountProp, 0)
    if specifiedRank then
        CupoleRank = specifiedRank;
    end
    local Stat, UpgradeValue = GET_CUPOLE_UPGRADE_STAT_VALUE(cls);
    if CupoleRank == 0 then
        return Stat, 0;
    end
    local res = 0.2;
    if Grade == "UR" then
        res = 0.5;
    elseif Grade == "SR" then
        res = 0.3;
    end
    local val = GET_CUPOLE_STAT_RECURRENCE_RELATION(UpgradeValue, res, CupoleRank);
    return Stat, val
end

function GET_CUPOLE_RANK_BY_CLS(cls)
    if cls == nil then
        return 0;
    end

    if pc == nil then
        if IsServerSection(pc) == 1 then
            return 0;
        else
            pc = GetMyPCObject();
        end
    end
    local acc = nil;
    if IsServerSection() == 1 then
        acc = GetAccountObj(pc);
    else
        acc = GetMyAccountObj(pc);
    end
    if acc == nil then
        return 0;
    end

    local AccountProp = TryGetProp(cls, "AccountProperty", "None");
    local CupoleRank = TryGetProp(acc, AccountProp, 0)
    return CupoleRank;
end

function GET_CUPOLE_STAT_RECURRENCE_RELATION(Value, Ratio, RankValue)
    if RankValue <= 0 then
        return 0;
    end
    return Value + (Value * Ratio) * (RankValue - 1);
end

function SCR_GET_SPEND_ITEM_BY_CUPOLE(pc, index)
    local item1, item2 = GET_CUPOLE_SPECIAL_ITEMS(pc, index)
    return GetClassByType('Item', item1), GetClassByType('Item', item2);
end

function GET_CUPOLE_PROBABILITY()
    local total = 0
    local probabilities = {}
    local xmlname = 'cupole_ratio'

    if config.GetServiceNation() == 'PAPAYA' then
        xmlname = 'cupole_ratio'
    end

    local clslist, cnt = GetClassList(xmlname)
    local grade_totals = {}
    local item_counts = {}
    local ratiocls = GetClassByIndexFromList(clslist, cnt - 1)

    -- 초기값 설정
    grade_totals["UR"] = TryGetProp(ratiocls, "UR", -1)
    grade_totals["SR"] = TryGetProp(ratiocls, "SR", -1)
    grade_totals["R"] = TryGetProp(ratiocls, "R", -1)
    item_counts["UR"] = 0
    item_counts["SR"] = 0
    item_counts["R"] = 0

    -- 총 확률 계산
    for _, v in pairs(grade_totals) do
        total = total + tonumber(v)
    end

    -- 각 등급의 확률 계산
    for k, v in pairs(grade_totals) do
        grade_totals[k] = (v / total) * 100
    end

    -- 각 등급의 아이템 개수 구하기
    for i = 0, cnt - 2 do
        local cls = GetClassByIndexFromList(clslist, i)
        local Grade = TryGetProp(cls, "Grade", "None")
        local Ratio = TryGetProp(cls, "Ratio", 0)
        if Grade ~= "None" then
            item_counts[Grade] = item_counts[Grade] + Ratio
        end
    end

    -- 각 등급에서 각 아이템의 확률 구하기
    for i = 0, cnt - 2 do
        local cls = GetClassByIndexFromList(clslist, i)
        local Grade = TryGetProp(cls, "Grade", "None")
        local name = TryGetProp(cls, "ClassName", "None")
        local Ratio = TryGetProp(cls, "Ratio", 0)
        if Grade ~= "None" then
            local totalGradeProbability = grade_totals[Grade]
            local totalGradeCount = item_counts[Grade]
            local probability = totalGradeProbability * (Ratio / totalGradeCount)
            table.insert(probabilities, {name, string.format('%.5f', probability), Grade})
        end
    end

    return probabilities
end

function GET_CUPOLE_RATIO_INFO_BY_INDEX(index)
    local cls = GetClassByType("cupole_list", index + 1)
    local clsname = TryGetProp(cls, "ClassName", "None")
    local ratiocls = GET_CUPOLE_RATIO_INFO_BY_CLASSNAME(clsname)
    return ratiocls
end

function GET_CUPOLE_RATIO_INFO_BY_CLASSNAME(clsname)
    local ratiolist, cnt = GetClassList("cupole_ratio")
    local ratiocls = GetClassByNameFromList(ratiolist, clsname)
    return ratiocls
end

function GET_KUPOLE_SKILL_RATE(pc, cupolecls, skillcls)
    local acc = nil;
    -- 서버
    if IsServerSection(pc) == 1 then
        acc = GetAccountObj(pc)
    else
        -- 클라
        acc = GetMyAccountObj(pc)
    end

    local AccountProperty = TryGetProp(cupolecls, "AccountProperty", "None");
    local Rank = TryGetProp(acc, AccountProperty, 0);
    local Rate = GET_KUPOLE_SKILL_RATE_VALUE(skillcls, Rank)
    return Rate;
end

function GET_KUPOLE_SKILL_RATE_VALUE(skillcls, rank)
    if skillcls == nil then
        return 0;
    end
    local Skill_Ratio = TryGetProp(skillcls, "Skill_Ratio", "None")
    local Skill_Ratio_Factor = TryGetProp(skillcls, "Skill_Ratio_Factor", "None")
    local Rate = tonumber(Skill_Ratio) + ((tonumber(rank) * tonumber(Skill_Ratio_Factor)) * tonumber(Skill_Ratio));
    return Rate;
end

function GET_KUPOLE_UPGRADE_ITEM_COUNT_BY_CLS(pc, kupolecls, rank)
    if pc == nil then
        if IsServerSection(pc) == 1 then
            return 0;
        else
            pc = GetMyPCObject();
        end
    end
    local acc = nil;
    if IsServerSection() == 1 then
        acc = GetAccountObj(pc);
    else
        acc = GetMyAccountObj(pc);
    end
    local accprop = TryGetProp(kupolecls, "AccountProperty", "None")
    local Group_ID = TryGetProp(kupolecls, "Group_ID", "None");
    local UpgradeCls = GET_CUPOLE_UPGRADE_BY_GROUPID_LIST(Group_ID)[1];

    if rank == nil then
        rank = TryGetProp(acc, accprop, 0);
    end

    return GET_KUPOLE_UPGRADE_ITEM_COUNT(UpgradeCls, rank);
end

function GET_KUPOLE_UPGRADE_ITEM_COUNT(UpgradeCls, rank)
    local UpgradeItemClassName = TryGetProp(UpgradeCls, "UpgradeItem")
    local UpgradeCount = TryGetProp(UpgradeCls, "UpgradeItemValue")

    return UpgradeItemClassName, UpgradeCount + tonumber(rank) - 1
end

-- !cupole_addon.lua
function TOGGLE_CUPOLE_ADDON_FRAME()
    local frame = ui.GetFrame("cupole_addon")
    frame:ShowWindowToggle();
    local atkBG = GET_CHILD(frame, "atkBG")
    local defBG = GET_CHILD(frame, "defBG")
    atkBG:ShowWindow(0)
    defBG:ShowWindow(0)
    local index = GET_GLOBAL_SELECT_CUPOLE();
    -- SET_CUPOLE_ITEM_SLOT(frame)
    CUPOLE_REGISTE_ITEM_PROP(frame, index)
end

function OPEN_CUPOLE_ADDON_FRAME(frame)

end

function PRESS_CUPOLE_ADDON_BTN(parent, ctrl, argStr, argNum)
end

-- 큐폴 선택 시 해당 큐폴이 사용할 수 있는 포션의 종류들을 그려주는 함수
function CUPOLE_REGISTE_ITEM(frame, ctrl, argStr, argNum)
    local parent = frame:GetTopParentFrame();
    local atkBG = GET_CHILD(parent, "atkBG")
    local defBG = GET_CHILD(parent, "defBG")
    local destBG = nil;
    local tag = ""
    local prop = "PotionName"

    local index = GET_GLOBAL_SELECT_CUPOLE();

    local potioncls = GET_CUPOLE_AUTO_POTION_CLS(index + 1)
    local PotionNameList = TryGetProp(potioncls, prop, "None")

    local list = StringSplit(PotionNameList, ';')

    if argNum == 1 then
        defBG:ShowWindowToggle()
        destBG = defBG;
    elseif argNum == 0 then
        atkBG:ShowWindowToggle()
        destBG = atkBG;
    end
    tag = list[argNum + 1]

    SET_CUPOLE_REGISTE_ITEM_LIST(destBG, tag, prop)
end

--- 큐폴 addon ui의 물약슬롯을 account prop 값에 따라 설정해준다
function CUPOLE_REGISTE_ITEM_PROP(frame, index)
    local pc = GetMyPCObject();
    local acc = GetMyAccountObj(pc);

    local itemid1, itemid2 = GET_CUPOLE_SPECIAL_ITEMS(nil, index)

    local atkslot = GET_CHILD_RECURSIVELY(frame, "atkslot")
    local defslot = GET_CHILD_RECURSIVELY(frame, "defslot")

    local item1 = GetClassByType('Item', tonumber(itemid1))
    local item2 = GetClassByType('Item', tonumber(itemid2))

    if item1 ~= nil then
        imcSlot:SetImage(atkslot, TryGetProp(item1, "Icon", "None"))
    end
    if item2 ~= nil then
        imcSlot:SetImage(defslot, TryGetProp(item2, "Icon", "None"))
    end
end

-- ui에 아이템들을 등록시켜준다.
function SET_CUPOLE_REGISTE_ITEM_LIST(frame, tag, Prop)
    local curr_my_cnt, itemlist = GET_INV_ITEM_COUNT_BY_PROPERTY({{
        Name = Prop,
        Value = tag
    }}, false)

    if curr_my_cnt < 1 then
        return;
    end

    local childcnt = frame:GetChildCount();
    for i = 0, childcnt - 1 do
        local slot = frame:GetChildByIndex(i)
        slot = AUTO_CAST(slot)
        if slot ~= nil then
            local icon = CreateIcon(slot)
            local mat_item_info = itemlist[i + 1];
            if mat_item_info ~= nil then
                local mat_cls = GetIES(mat_item_info:GetObject())
                local icon = imcSlot:SetImage(slot, TryGetProp(mat_cls, "Icon", "None"))
                local mat_guid = mat_item_info:GetIESID();

                slot:SetUserValue("mat_guid", mat_guid);
                slot:SetUserValue("itemcount", curr_my_cnt);
                icon:SetTooltipOverlap(1)
                SET_ITEM_TOOLTIP_BY_NAME(icon, mat_cls.ClassName)
            else
                slot:SetUserValue("mat_guid", "None");
                slot:SetUserValue("itemcount", 0);
                slot:ClearIcon()
            end
        end
    end
end

-- 아이템 눌렀을떄 동작(등록한다)
function PRESS_CUPOLE_ITEM(frame, ctrl, argStr, argNum)
    local mat_guid = ctrl:GetUserValue("mat_guid");
    local curr_my_cnt = ctrl:GetUserIValue("itemcount");
    local parent = frame:GetTopParentFrame();

    session.ResetItemList()

    if mat_guid == '0' then
        return
    end
    if mat_guid == 'None' then
        return
    end
    if curr_my_cnt == 0 then
        return
    end

    local mat_item = session.GetInvItemByGuid(mat_guid)
    if mat_item == nil then
        return
    end
    local index = GET_GLOBAL_SELECT_CUPOLE();

    local destslot = nil;
    if argNum == 0 then
        local atkslot = GET_CHILD_RECURSIVELY(parent, "atkslot")
        destslot = atkslot;
    elseif argNum == 1 then
        local defslot = GET_CHILD_RECURSIVELY(parent, "defslot")
        destslot = defslot;
    end
    local mat_cls = GetIES(mat_item:GetObject())
    local icon = imcSlot:SetImage(destslot, TryGetProp(mat_cls, "Icon", "None"))
    local mat_guid = mat_item:GetIESID();

    icon:SetTooltipOverlap(1)
    destslot:SetUserValue("mat_guid", mat_guid);
    SET_ITEM_TOOLTIP_BY_NAME(icon, mat_cls.ClassName)

    if curr_my_cnt ~= nil and curr_my_cnt > 0 then
        SCP_CUPOLE_ADDON_REGISTE_ITEM(mat_cls, index, argNum)
    end
end

-- 우클릭 시의 함수
function CUPOLE_CLEAR_REGISTE_ITEM(frame, ctrl, argStr, argNum)
    ctrl:ClearIcon();
    ctrl:SetUserValue("mat_guid", "None");
    local index = GET_GLOBAL_SELECT_CUPOLE();

    local types = index .. '\t' .. argNum;
    pc.ReqExecuteTx_Item("CUPOLE_ITEM_ADDON", 0, types)
end

-- 아이템 선택 시 tx 
function SCP_CUPOLE_ADDON_REGISTE_ITEM(item, cupoleindex, propnum)
    local clsID = TryGetProp(item, "ClassID", "None")
    local types = cupoleindex .. '\t' .. propnum;
    pc.ReqExecuteTx_Item("CUPOLE_ITEM_ADDON", clsID, types)
end

-- !cupole_pickup.lua
local MAX_COUNT = get_cupole_pickup_count();
local DEFAULT_INDEX = 25
local OFFSET_X = -10
local OFFSET_Y = 105
local EMPTY_INDEX = -1;
function CUPOLE_PICKUP_ON_INIT(addon, frame)
    addon:RegisterMsg('CUPOLE_ACTIVATE', 'PICKUP_ON_CUPOLE_ACTIVATE');
    addon:RegisterMsg('TAKE_CUPOLE_RANKUP_ITEM', 'PICKUP_ON_CUPOLE_ACTIVATE');
end

-- 서버에서 응답을 받으면 pickup accountprop 갱신하기.
function PICKUP_ON_CUPOLE_ACTIVATE(frame, msg, argStr, argNum)
    SET_CURRENT_CUPOLE_PICKUP_ITEM_VALUE(frame, argNum, MAX_COUNT)
    if frame:GetName() == "cupole_item" then
        SET_CUPOLE_GACHA_COLOR(frame)
    end
end

function TOGGLE_CUPOLE_PICKUP_ADDON(parent, ctrl, argStr, argNum)
    ui.ToggleFrame("cupole_pickup");
end

function OPEN_CUPOLE_PICKUP(frame)
    SET_CURRENT_CUPOLE_SELECT_INDEX(DEFAULT_INDEX)
    local InfoBG = GET_CHILD_RECURSIVELY(frame, "InfoBG")
    CUPOLE_INFO_SELECT(InfoBG, nil, nil, 0)
    CREATE_PICKUP_CUPOLE_LIST(frame)
    SET_CURRENT_CUPOLE_PICKUP_ITEM_VALUE_COLOR(frame)
    frame:RunUpdateScript("UPDATE_CUPOLE")
    PICKUP_CUPOLE_SELECT(InfoBG, nil, nil, DEFAULT_INDEX)
    CHNAGE_ALL_CUPOLE_UIMODEL_STATE(1)

    local PickupListBG = GET_CHILD_RECURSIVELY(frame, "PickupListBG")
    PickupListBG:SetScrollBarSkinName("verticalscrollbar3")
end

function CLOSE_CUPOLE_PICKUP(frame)
    frame:StopUpdateScript("UPDATE_CUPOLE")
    CHNAGE_ALL_CUPOLE_UIMODEL_STATE(0)
end

function CREATE_PICKUP_CUPOLE_LIST(frame)
    local Pickuplist = {}
    local cupolelist, cnt = GetClassList("cupole_list")
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(cupolelist, i)
        if cls and TryGetProp(cls, "Grade", "R") == "UR" and TryGetProp(cls, "Use", "false") == "true" then
            table.insert(Pickuplist, cls)
        end
    end

    local PickupListBG = GET_CHILD_RECURSIVELY(frame, "PickupListBG")
    local offset = {OFFSET_X, OFFSET_Y}
    for k, v in pairs(Pickuplist) do
        local clsname = TryGetProp(v, "ClassName", "None")
        local index = TryGetProp(v, "ClassID", '0') - 1
        local cupole_slot_box = PickupListBG:CreateOrGetControlSet('cupole_pickup_slot', clsname, offset[1],
                                                                   (k - 1) * offset[2] + 5)
        cupole_slot_box:SetGravity(ui.CENTER_HORZ, ui.TOP)
        SET_SLOT_CUPOLE_INFO(cupole_slot_box, index)

        local slot_gb = cupole_slot_box:GetChild("gb")
        slot_gb:SetEventScript(ui.LBUTTONUP, "PICKUP_CUPOLE_SELECT")
        slot_gb:SetEventScriptArgNumber(ui.LBUTTONUP, index)
        local res, state = CHECK_CUPOLE_VALID(nil, index)
        local disable_shadow = GET_CHILD(cupole_slot_box, "disable_shadow")
        local haven = GET_CHILD(cupole_slot_box, "haven")
        local havenbg = GET_CHILD(cupole_slot_box, "havenbg")

        local visibility = (res or (not res and state == "Equip")) and 1 or 0
        SET_UI_ELEMENT(disable_shadow, nil, visibility)
        SET_UI_ELEMENT(haven, nil, visibility)
        SET_UI_ELEMENT(havenbg, nil, visibility)
    end

    -- 마지막 아이템 추가
    local itemCtrl = PickupListBG:CreateOrGetControlSet('cupole_pickup_slot', "UR", offset[1],
                                                        (#Pickuplist) * offset[2] + 5)
    itemCtrl:SetGravity(ui.CENTER_HORZ, ui.TOP)
    local slotGB = GET_CHILD(itemCtrl, "gb")
    slotGB:SetEventScript(ui.LBUTTONUP, "PICKUP_CUPOLE_SELECT")
    slotGB:SetEventScriptArgNumber(ui.LBUTTONUP, -1)

    local disableShadow = GET_CHILD(itemCtrl, "disable_shadow")
    local haven = GET_CHILD(itemCtrl, "haven")
    local havenBG = GET_CHILD(itemCtrl, "havenbg")
    SET_UI_ELEMENT(disableShadow, nil, 0)
    SET_UI_ELEMENT(haven, nil, 0)
    SET_UI_ELEMENT(havenBG, nil, 0)

    local revert = GET_CHILD_RECURSIVELY(itemCtrl, "revert")
    local gradeImg = GET_CHILD_RECURSIVELY(itemCtrl, "grade_img")
    local cupoleSlot = GET_CHILD(itemCtrl, "cupole_slot")
    local equipImg = GET_CHILD_RECURSIVELY(itemCtrl, "equip_img")

    local grade = "UR"
    local rankFrameName = string.format("cupole_grade_frame_%s", grade)
    local rankName = string.format("cupole_grade_%s", grade)
    local revertFrameName = string.format("cupole_revert_%s", grade)
    local cupoleIcon = cupoleSlot:GetIcon()

    SET_UI_ELEMENT(slotGB, rankFrameName, 1)
    SET_UI_ELEMENT(gradeImg, rankName, 1)
    SET_UI_ELEMENT(revert, revertFrameName, 1)

    local matCls = GetClassByNameFromList(item_list, "cupole_rankup_UR")
    slotGB:SetEventScriptArgString(ui.LBUTTONUP, matCls.ClassName)

    local icon = imcSlot:SetImage(cupoleSlot, TryGetProp(matCls, "Icon", "None"))
    SET_ITEM_TOOLTIP_BY_NAME(icon, matCls.ClassName)
    icon:SetTooltipOverlap(1)
end

function SET_CURRENT_CUPOLE_SELECT_INDEX(index)
    local frame = ui.GetFrame("cupole_pickup");
    frame:SetUserValue("curindex", index);
end

function GET_CURRENT_CUPOLE_SELECT_INDEX()
    local frame = ui.GetFrame("cupole_pickup");
    local index = frame:GetUserIValue("curindex");
    return index;
end

function SET_CURRENT_CUPOLE_PICKUP_ITEM_VALUE_COLOR(frame, max)
    local cost = GET_CUPOLE_PICKUP_PROP_COUNT()
    local maxcount = MAX_COUNT;
    if max then
        maxcount = max;
    end
    SET_CURRENT_CUPOLE_PICKUP_ITEM_VALUE(frame, cost, maxcount)
end

function SET_CURRENT_CUPOLE_PICKUP_ITEM_VALUE(frame, cost, max)
    local count = 0;
    if cost < max then
        count = "{#FF0000}" .. cost .. "{/}";
    else
        count = "{#00BBBB}" .. cost .. "{/}";
    end

    SET_CUPOLE_PIKCUP_COUNT(frame, count, max)
end

function SET_CUPOLE_PIKCUP_COUNT(frame, count, max)
    local SelectGacha = GET_CHILD_RECURSIVELY(frame, "SelectGacha")
    local gachacnt0 = GET_CHILD(SelectGacha, "gachacnt0")
    gachacnt0:SetTextByKey("count", count);
    gachacnt0:SetTextByKey("max", max);
end

function PICKUP_CUPOLE_SELECT(parent, ctrl, argStr, argNum)
    local frame = parent:GetTopParentFrame();
    local bg = parent:GetParent();
    FRAME_CHILD_COLORTONE_CLEAR(bg)
    FRAME_COLOR_CHANGE(parent, "FF5CFFD1");
    REMOVE_ALL_CUPOLE_UIMODEL()
    local ItemPic = GET_CHILD_RECURSIVELY(frame, "ItemPic")
    local MainCharacter = GET_CHILD_RECURSIVELY(frame, "MainCharacter")

    if argNum > 0 then
        SET_CURRENT_CUPOLE_SELECT_INDEX(argNum)
        frame:RunUpdateScript("KUPOLE_UIMODEL_IN_PICKUP", 0.2)
        local cls = GET_CUPOLE_CLASS_BY_INDEX(argNum)
        SET_SELECT_CUPOLE_NAME(frame, argNum)
        CUPOLE_INFO_SELECT(bg, nil, nil, 0)
        MainCharacter:ShowWindow(1)
        ItemPic:ShowWindow(0)
        SET_CURRENT_CUPOLE_PICKUP_ITEM_VALUE_COLOR(frame, MAX_COUNT)
    elseif argStr == "cupole_rankup_UR" then
        SET_CURRENT_CUPOLE_PICKUP_ITEM_VALUE_COLOR(frame, MAX_COUNT / 3)
        SET_CURRENT_CUPOLE_SELECT_INDEX(EMPTY_INDEX);
        SET_SELECT_CUPOLE_NAME(frame, -1);
        CUPOLE_INFO_SELECT(bg, nil, nil, 2)
        MainCharacter:ShowWindow(0)
        ItemPic:ShowWindow(1)
    end
end

function CUPOLE_INFO_SELECT(frame, ctrl, argStr, argNum)
    local parent = frame:GetParent();
    local grand_parent = parent:GetParent();
    local SkillBG = GET_CHILD_RECURSIVELY(grand_parent, "SkillBG")
    local EffectBG = GET_CHILD_RECURSIVELY(grand_parent, "EffectBG")
    local SelectBG = GET_CHILD_RECURSIVELY(grand_parent, "SelectBG")
    local ItemBG = GET_CHILD_RECURSIVELY(grand_parent, "ItemBG")
    local Skill = GET_CHILD(SelectBG, "Skill")
    local Effect = GET_CHILD(SelectBG, "Effect")
    local Item = GET_CHILD(SelectBG, "Item")
    local Skl_light = GET_CHILD(SelectBG, "Skl_light")
    local Eft_light = GET_CHILD(SelectBG, "Eft_light")

    local skilltxt = ClMsg("KupoleSkill")
    local effecttxt = ClMsg("KupoleEffect")
    local itemtext = ClMsg("KupoleURExplain")

    Skill:ShowWindow(1)
    Effect:ShowWindow(1)

    local index = GET_CURRENT_CUPOLE_SELECT_INDEX();
    if argNum == 0 then
        SkillBG:ShowWindow(1)
        EffectBG:ShowWindow(0)
        Skl_light:ShowWindow(1)
        Eft_light:ShowWindow(0)
        Item:ShowWindow(0)
        ItemBG:ShowWindow(0)
        SET_CUPOLE_SKILL_INFO(SkillBG, index)
        skilltxt = "{@st66d}{s22}" .. skilltxt .. "{/}";
        effecttxt = "{@st66d}{s22}{#6B6889}" .. effecttxt;

    elseif argNum == 1 then
        SkillBG:ShowWindow(0)
        EffectBG:ShowWindow(1)
        Skl_light:ShowWindow(0)
        Eft_light:ShowWindow(1)
        Item:ShowWindow(0)
        ItemBG:ShowWindow(0)
        SET_CUPOLE_EFFECT_INFO(EffectBG, index)
        skilltxt = "{@st66d}{s22}{#6B6889}" .. skilltxt;
        effecttxt = "{@st66d}{s22}" .. effecttxt .. "{/}";
    elseif argNum == 2 then
        SkillBG:ShowWindow(0)
        EffectBG:ShowWindow(0)
        Skl_light:ShowWindow(0)
        Eft_light:ShowWindow(0)
        Item:ShowWindow(1)
        ItemBG:ShowWindow(1)
        Skill:ShowWindow(0)
        Effect:ShowWindow(0)
    end
    Skill:SetText(skilltxt)
    Effect:SetText(effecttxt)

    local Itemexp = GET_CHILD(ItemBG, "Itemexp")
    Itemexp:SetTextByKey("explan", itemtext)
end

function EARN_PICKUP_CUPOLE(frame, ctrl, argStr, argNum)
    local index = GET_CURRENT_CUPOLE_SELECT_INDEX();
    if index == -1 then
        local count = GET_CUPOLE_PICKUP_PROP_COUNT()
        if count < (get_cupole_pickup_count() / 3) then
            return;
        end
        pc.ReqExecuteTx_Item("CUPOLE_RANKUPITEM_RQEUST", 0, 0)
    else
        local count = GET_CUPOLE_PICKUP_PROP_COUNT()
        if count < get_cupole_pickup_count() then
            return;
        end
        local cls = GET_CUPOLE_RATIO_INFO_BY_INDEX(index)
        local ratioindex = TryGetProp(cls, "ClassID", 0)
        local type = 2 -- 0:단차 1:10연차 2:픽업
        type = type .. ' ' .. ratioindex;
        pc.ReqExecuteTx_Item("CUPOLE_RECRUIT", 0, type)
    end
end

function SET_CUPOLE_SKILL_INFO(frame, index)
    local cupole_cls = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(index);
    if cupole_cls == nil then
        return;
    end

    local Group_ID = TryGetProp(cupole_cls, "Group_ID", "None")
    local SkillTable = GET_CUPOLE_SKILL_BY_GROUPID_LIST(Group_ID);
    local Name, Explain, Icon = CREATE_CUPOLE_SKILL_RATIO_TEXT(SkillTable[2]);

    local SkillIcon = GET_CHILD(frame, "SkillIcon")
    local SkillName = GET_CHILD(frame, "SkillName")
    local SkillExplan = GET_CHILD(frame, "SkillExplan")

    SkillName:SetTextByKey("name", Name)
    SkillExplan:SetTextByKey("explan", Explain)
    SkillIcon:SetImage(Icon);
end

function SET_CUPOLE_EFFECT_INFO(frame, index)
    local cupole_cls = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(index);
    if cupole_cls == nil then
        return;
    end
    local CEBG = GET_CHILD_RECURSIVELY(frame, "CEBG")
    local OEBG = GET_CHILD_RECURSIVELY(frame, "OEBG")
    SET_CUPOLE_OWNED_EFFECT(OEBG, cupole_cls, 1)
    SET_CUPOLE_BUFF_INFO(CEBG, cupole_cls, 1)
end

function SET_UI_ELEMENT(element, image, visibility)
    if element then
        if image then
            element:SetImage(image)
        end
        if type(visibility) == 'boolean' then
            visibility = BoolToNumber(visibility);
        end
        element:ShowWindow(visibility)
    end
end

function SAFE_CALL(func, ...)
    local status, result = pcall(func, ...)
    if not status then
        print("Error: " .. result)
    end
    return status, result
end

-- cupole_ratio_open.lua
function TOGGLE_CUPOLE_RATIO(frame, ctrl, argStr, argNum)
    ui.ToggleFrame("cupole_ratio_open")
end

function OPEN_CUPOLE_RATIO_TABLE(frame)
    local table = GET_CUPOLE_PROBABILITY()
    CREATE_CUPOLE_RATIO_LIST(frame, table)
end

function CREATE_CUPOLE_RATIO_LIST(frame, table)
    local ctrlBG = GET_CHILD_RECURSIVELY(frame, "ctrlBG")
    ctrlBG:SetScrollBarSkinName("verticalscrollbar3")
    local URBG = GET_CHILD_RECURSIVELY(ctrlBG, "URBG")
    local SRBG = GET_CHILD_RECURSIVELY(ctrlBG, "SRBG")
    local RBG = GET_CHILD_RECURSIVELY(ctrlBG, "RBG")

    local offset = {495, 55};

    URBG:SetUserValue("x", 0);
    SRBG:SetUserValue("x", 0);
    RBG:SetUserValue("x", 0);
    URBG:SetUserValue("y", 0);
    SRBG:SetUserValue("y", 0);
    RBG:SetUserValue("y", 0);

    local cupolelist, cnt = GetClassList("cupole_list");

    for k, v in pairs(table) do
        local clsname = v[1]
        local ratio = v[2]
        local grade = v[3]
        local bg = nil;
        local cls = GetClassByNameFromList(cupolelist, clsname);

        if grade == "UR" then
            bg = URBG;
        elseif grade == "SR" then
            bg = SRBG;
        elseif grade == "R" then
            bg = RBG;
        else
            return;
        end

        local x = bg:GetUserIValue("x");
        local y = bg:GetUserIValue("y");
        local ctrl = bg:CreateOrGetControlSet("cupole_probalilty_slot", clsname, x * offset[1], y * offset[2] + 50);
        if ctrl == nil then
            return;
        end
        local rich_name = GET_CHILD_RECURSIVELY(ctrl, "Name")
        local rich_ratio = GET_CHILD_RECURSIVELY(ctrl, "ratio")
        local Cupole_Slot = GET_CHILD_RECURSIVELY(ctrl, "cupole_slot");
        local Gb = GET_CHILD_RECURSIVELY(ctrl, "gb");

        rich_name:SetTextByKey("name", cls.Dec_Name)
        rich_ratio:SetTextByKey("ratio", ratio)

        local RankFrameName = string.format("cupole_grade_frame_%s", grade);
        Gb:SetImage(RankFrameName)
        local Cupole_Icon = Cupole_Slot:GetIcon();
        if Cupole_Icon == nil then
            Cupole_Icon = CreateIcon(Cupole_Slot);
        end
        if cls ~= nil then
            local IconImage = TryGetProp(cls, "Icon", "None");
            if IconImage ~= "None" then
                Cupole_Icon:SetImage(IconImage);
            end
        end

        x = x + 1;
        if x > 1 then
            x = 0;
            y = y + 1;
        end
        bg:SetUserValue("x", x);
        bg:SetUserValue("y", y);
    end

    local URpos = URBG:GetUserIValue("y");
    local SRpos = SRBG:GetUserIValue("y");
    local Rpos = RBG:GetUserIValue("y");

    local y = 0;

    URBG:Resize(URBG:GetWidth(), (URpos + 2) * 55);
    SRBG:Resize(SRBG:GetWidth(), (SRpos + 1) * 55);
    RBG:Resize(RBG:GetWidth(), (Rpos + 2) * 55)

    SRBG:SetOffset(URBG:GetX(), (URpos + 3) * 55);
    RBG:SetOffset(URBG:GetX(), (URpos + SRpos + 5) * 55);
end

function GET_CURRENT_PICKUP_KUPOLE()
    local table = GET_CUPOLE_PROBABILITY()
    local cupolelist, cnt = GetClassList("cupole_list");

    local pickuplist = {};
    local maxratio = 0;
    for k, v in pairs(table) do
        local clsname = v[1]
        local ratio = tonumber(v[2])
        local grade = v[3]
        local cls = GetClassByNameFromList(cupolelist, clsname);
        if grade == "UR" and ratio > maxratio then
            maxratio = ratio;
            pickuplist = {}
            pickuplist[#pickuplist + 1] = cls;
        elseif grade == "UR" and ratio == maxratio then
            pickuplist[#pickuplist + 1] = cls;
        end
    end

    return pickuplist;
end

-- cupole_gacha.lua
function CUPOLE_RESULT_SKIL_BTN(parent, ctrl, argStr, argNum)
    ui.CloseFrame("cupole_gacha");
end

function OPEN_CUPOLE_GACHA(frame)
    frame:RunUpdateScript("UPDATE_CUPOLE")
    frame:SetUserValue("GachaCnt", 0);
    SET_CUPOLE_RECURIT_CHECK_BTN_VISIBLILITY(frame, 0);
    BLOCK_ESCAPE_BTN();
    imcSound.PlaySoundEvent("sys_card_eff_3")
end

function CLOSE_CUPOLE_GACHA(frame)
    frame:StopUpdateScript('UPDATE_CUPOLE')
    END_CUPOLE_GACHA()
end

function END_CUPOLE_GACHA()
    local cupole_gacha = ui.GetFrame("cupole_gacha")
    TOGGLE_CUPOLE_GACHA_STATE(false)
    RESET_CUPOLE_GACHA_COUNT(cupole_gacha)
    UNBLOCK_ESCAPE_BTN();
end

function CHECK_MAX_COUNT()
    local cupole_gacha = ui.GetFrame("cupole_gacha")
    local maxval = cupole_gacha:GetUserIValue("MAXCnt");
    local count = cupole_gacha:GetUserIValue("curCnt");

    if maxval <= count then
        SET_CUPOLE_RECURIT_CHECK_BTN_VISIBLILITY(cupole_gacha, 1);
        return true;
    end
    return false;
end

function RESET_CUPOLE_GACHA_COUNT(frame)
    frame:SetUserValue("GachaCnt", 0)
    frame:SetUserValue("MAXCnt", 0)
    frame:SetUserValue("curCnt", 0)
    frame:SetUserValue("IsSkip", 0);
    ui.FlushGachaDelayPacket();
    SET_CUPOLE_RECURIT_CHECK_BTN_VISIBLILITY(frame, 0)
end

function SET_CUPOLOE_GACHA_COUNT()
    local cupole_gacha = ui.GetFrame("cupole_gacha")
    local count = cupole_gacha:GetUserIValue("GachaCnt");
    cupole_gacha:SetUserValue("GachaCnt", count + 1);
end

function SET_CUPOLE_GACHA_MAX_COUNT(count)
    local cupole_gacha = ui.GetFrame("cupole_gacha")
    cupole_gacha:SetUserValue("MAXCnt", count);
end

function GET_CUPOLE_GACHA_MAX_COUNT()
    local cupole_gacha = ui.GetFrame("cupole_gacha")
    local count = cupole_gacha:GetUserIValue("MAXCnt");
    return count;
end

function SET_CUPOLE_GACHA_CUR_OPEN_COUNT()
    local cupole_gacha = ui.GetFrame("cupole_gacha")
    local count = cupole_gacha:GetUserIValue("curCnt");
    cupole_gacha:SetUserValue("curCnt", count + 1);
end

function GET_CUPOLE_GACHA_CUR_COUNT()
    local cupole_gacha = ui.GetFrame("cupole_gacha")
    local count = cupole_gacha:GetUserIValue("GachaCnt");
    return count;
end

function GET_CUPOLE_GACHA_CUR_OPEN_COUNT()
    local cupole_gacha = ui.GetFrame("cupole_gacha")
    local count = cupole_gacha:GetUserIValue("curCnt");
    return count;
end

function SET_CUPOLE_RECRUIT_COUNT(frame)
    local onemore = GET_CHILD_RECURSIVELY(frame, "onemore")
    local invItem = session.GetInvItemByName("Premium_cupole_recruit_ticket")
    local max = GET_CUPOLE_GACHA_MAX_COUNT()
    if max == 11 then
        max = max - 1;
    end
    local count = nil;
    if invItem == nil then
        count = 0;
    else
        count = invItem:GetAmountStr();
    end
    local text = count;
    if tonumber(count) < max then
        text = "{#FF0000}" .. text .. "{/}";
    end
    onemore:SetTextByKey("count", text);
    onemore:SetTextByKey("max", max);
end

function SET_CUPOLE_RECURIT_CHECK_BTN_VISIBLILITY(frame, visible)
    local onemore = GET_CHILD_RECURSIVELY(frame, "onemore")
    local cancle = GET_CHILD_RECURSIVELY(frame, "cancle")

    onemore:ShowWindow(visible)
    cancle:ShowWindow(visible)
end

function RE_RECRUIT_CUPOLE_GACHA()
    local cupole_gacha = ui.GetFrame("cupole_gacha")
    local maxcount = GET_CUPOLE_GACHA_MAX_COUNT();
    local types = 0;
    if maxcount == 11 then
        types = 1;
    elseif maxcount == 1 then
        types = 0;
    end
    END_CUPOLE_GACHA()
    RE_MRESSAGEBOX_CANCLE_BTN("END_CUPOLE_GACHA", 0, '0');
    RESET_CUPOLE_GACHA_COUNT(cupole_gacha);
    GACHA_CUPOLE_START_ON(cupole_gacha, nil, nil, types);
    -- CUPOLE_GACHA_START(types)
end

function BLOCK_ESCAPE_BTN()
    ui.SetEscapeScp("BLOCKING_FUNC()")
end

function UNBLOCK_ESCAPE_BTN()
    ui.SetEscapeScp("")
end

function BLOCKING_FUNC()

end

-- cupole_emotion.lua
local cupole_animlist = {"born", "run", "select_born", "select_std", "skl1", "skl2", "std"};

function OPEN_EMOTION_BTN(frame, ctrl, argStr, argNum)
    local cupole_emotion = ui.OpenFrame("cupole_emotion")
    local cupole_item = ui.GetFrame("cupole_item")
    local TopParent = frame:GetTopParentFrame()
    RESET_CUPOLE_SELECT_MODE(TopParent)
end

function OPEN_CUPOLE_EMOTION(frame)
    SET_CUPOLE_EMOTION(frame)
end

function SET_CUPOLE_EMOTION(frame)
    local csetwidth = ui.GetControlSetAttribute("pose_icon", 'width');
    local csetheight = ui.GetControlSetAttribute("pose_icon", 'height');
    local x = 20;
    local y = 20;
    local xmargin = 20;
    local ymargin = 20;
    local controlIndex = 0;
    local maxIndex = 3;

    local managerTab = GET_CHILD(frame, "managerTab");
    local mainFrame = ui.GetFrame("cupole_item")
    for k, v in pairs(cupole_animlist) do
        local eachcontrol = managerTab:CreateOrGetControlSet('pose_icon', 'pose_icon' .. v, x, y)

        local each_pose_name = GET_CHILD(eachcontrol, 'pose_name', 'ui::CRichText');
        local each_pose_slot = GET_CHILD(eachcontrol, 'pose_slot', 'ui::CSlot');
        -- 임시 
        local selc_cupole = GET_GLOBAL_SELECT_CUPOLE();
        local monName = GET_CUPOLE_NAME_BY_INDEX(selc_cupole)

        each_pose_slot:SetEventScript(ui.LBUTTONDOWN, 'CUPOLE_POSE');
        each_pose_slot:SetEventScriptArgNumber(ui.LBUTTONDOWN, k);
        each_pose_slot:SetEventScriptArgString(ui.LBUTTONDOWN, monName);

        SET_SLOT_IMG(each_pose_slot, "icon_gesture_love");
        each_pose_name:SetTextByKey('posename', v);
        each_pose_slot:SetTextByKey('posename', v);
        local icon = each_pose_slot:GetIcon();
        icon:SetUserValue('POSEID', v);

        controlIndex = controlIndex + 1;
        x = xmargin + (controlIndex % maxIndex) * csetwidth
        y = ymargin + math.floor(controlIndex / maxIndex) * csetheight

    end

end

function CUPOLE_POSE(monName, animname)
    local myHandle = session.GetMyHandle();
    local ownerActor = world.GetActor(myHandle);
    local monActor = ownerActor:GetClientMonster():GetClientMonsterByName(monName);
    local monHandle = monActor:GetHandleVal();

    CupoleAnimPlay(monHandle, animname)
end

