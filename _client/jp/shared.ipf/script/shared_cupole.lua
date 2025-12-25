-- shared_master_mon.lua

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
-- 1. 데이터를 저장할 새로운 테이블 변수 선언 (기존 변수 대체 또는 추가)
local cupole_candidates_by_grade = nil

-- 2. make_cupole_grade_table 함수 수정
function make_cupole_grade_table()
    if cupole_candidates_by_grade ~= nil then
        return
    end

    cupole_grade_table_list = {}
    cupole_grade_table_list_ratio = {}
    cupole_candidates_by_grade = {} -- 등급별 후보 리스트 초기화

    local cls = GetClass('cupole_ratio', 'grade_ratio')
    table.insert(cupole_grade_table_list, 'UR')
    table.insert(cupole_grade_table_list, 'SR')
    table.insert(cupole_grade_table_list, 'R')
    
    local value = TryGetProp(cls, 'UR', 0)
    table.insert(cupole_grade_table_list_ratio, value)
    value = TryGetProp(cls, 'SR', 0)
    table.insert(cupole_grade_table_list_ratio, value)
    value = TryGetProp(cls, 'R', 0)
    table.insert(cupole_grade_table_list_ratio, value)

    -- 등급별 테이블 초기화
    for i = 1, #cupole_grade_table_list do
        cupole_candidates_by_grade[cupole_grade_table_list[i]] = {}
    end
    
    local list, cnt = GetClassList('cupole_ratio')
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(list, i)
        local grade = TryGetProp(cls, 'Grade', 'None')        
        if grade ~= 'None' then
            -- 이름, 비율, 그룹 정보를 모두 저장
            local info = {
                Name = TryGetProp(cls, 'ClassName', 'None'),
                Ratio = TryGetProp(cls, 'Ratio', 0),
                Group = TryGetProp(cls, 'Group', 'ALL')
            }
            if cupole_candidates_by_grade[grade] ~= nil then
                table.insert(cupole_candidates_by_grade[grade], info)
            end
        end
    end
end
make_cupole_grade_table()


shared_cupole.get_max_friendly = function(grade)
    local max = 0;
    if grade == "UR" then
        max = 7;
    elseif grade =="SR" then
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
function GET_CUPOLE_CLASSNAME(count, group)
    local grade = GET_CUPOLE_GRADE(count)
    
    -- 해당 등급의 전체 후보 리스트 가져오기
    local candidates = cupole_candidates_by_grade[grade]
    if candidates == nil then
        return nil, grade
    end

    local filtered_names = {}
    local filtered_ratios = {}

    -- 그룹에 맞는 아이템만 필터링
    for i = 1, #candidates do
        local info = candidates[i]
        -- 요청한 그룹과 일치하거나, 공통(ALL) 그룹인 경우 포함
        if group == nil or info.Group == 'ALL' or info.Group == group then
            table.insert(filtered_names, info.Name)
            table.insert(filtered_ratios, info.Ratio)
        end
    end

    if #filtered_names == 0 then
        return nil, grade -- 해당 그룹에 아이템이 없는 경우
    end

    -- 필터링된 리스트에서 확률 기반 선택
    local index = GIBBS_SAMPLING(filtered_ratios)
    local name = filtered_names[index]
    
    return name, grade
end

function GET_CUPOLE_RANKUP_ITEM_PREFIX()
    return cupole_rankup_item_prefix
end

-- 큐폴의 cls를 index로 가져온다.
function GET_CUPOLE_CLASS_BY_INDEX(index)
    local list, cnt = GetClassList("cupole_list")
    local cls = GetClassByIndexFromList(list ,index)
    return cls;
end

-- 큐폴의 cls를 groupid로 가져온다.
function GET_CUPOLE_CLASS_BY_GROUPID(groupid)
    local list, cnt = GetClassList("cupole_list")
    for i = 0 , cnt - 1 do
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

    --보유 체크
    local AccProp = TryGetProp(cls, "AccountProperty", "None")
    local CupoleRank = TryGetProp(acc, AccProp, 0);
    if CupoleRank == 0 then
        return false, "NoneHave";
    end

    -- 장착 체크
    for k,v in pairs(EquipList) do
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

--대표 큐폴의 skillinfo를 가져온다.
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

--index 큐폴의 skillinfo를 가져온다.
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


--groupid로 skilllist를 가져온다.
function GET_CUPOLE_SKILL_BY_GROUPID_LIST(group_id)
    if group_id == "None" then
        return nil;
    end
    local cupole_skill, cnt = GetClassList("cupole_skill");
    local skilltable = {}
    for i = 0, cnt -1 do
        local cls = GetClassByIndexFromList(cupole_skill, i)
        local GroupID = TryGetProp(cls, "Group_ID", "None")
        if GroupID == group_id then
            table.insert(skilltable, cls);
        end
    end
    return skilltable;
end

--groupid로 upgradelist를 가져온다.
function GET_CUPOLE_UPGRADE_BY_GROUPID_LIST(group_id)
    local cupole_upgrade, cnt = GetClassList("cupole_upgrade");
    local upgradetable = {}
    for i = 0, cnt -1 do
        local cls = GetClassByIndexFromList(cupole_upgrade, i)
        local GroupID = TryGetProp(cls, "Group_ID", "None")
        if GroupID == group_id then
            table.insert(upgradetable, cls);
        end
    end
    return upgradetable;
end

function GET_CUPOLE_AUTO_POTION_CLS(index)
    local cupole_cls = GetClassByType('cupole_list', index)
    if cupole_cls then
        local cls = GetClassByStrProp('cupole_auto_potion', "ClassName", cupole_cls.ClassName)
        return cls;
    end
    return nil;
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
    return {prop1, prop2};
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
    local prop = GET_CUPOLE_SPECIAL_ACCOUNTPROPS(index)

    if prop[1] == "None" then
        return -1, -1
    end

    local Item1 = TryGetProp(acc, prop[1], "None")
    local Item2 = TryGetProp(acc, prop[2], "None")

    return Item1, Item2;
end

function GET_CUPOLE_SPECIAL_ITEM_CLSLIST(pc, index)
    local itemid1, itemid2 = GET_CUPOLE_SPECIAL_ITEMS(pc, index)
    local itemCls1 = GetClassByType("Item", itemid1);
    local itemCls2 = GetClassByType("Item", itemid2);
    local itemlist = {itemCls1 , itemCls2};
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

    for k,v in pairs(equip_list) do
        if v == nil then
            equip_list[k] = -1;
        end
    end

    return equip_list;
end


--큐폴의 업그레이드 스텟 관련 정보를 가져옴.
function GET_CUPOLE_UPGRADE_STAT_VALUE(cls)
    local Cupole_Group_ID = TryGetProp(cls, "Group_ID", "None");
    local Cupole_Upgrade_List = GET_CUPOLE_UPGRADE_BY_GROUPID_LIST(Cupole_Group_ID)
    local Cupole_Upgrade_Cls = Cupole_Upgrade_List[1];
    if Cupole_Upgrade_Cls == nil then
        return;
    end

    local Stat = TryGetProp(Cupole_Upgrade_Cls, "Stat_Upgrade", "None")
    local UpgradeValue = TryGetProp(Cupole_Upgrade_Cls, "Upgrade_value", 0)
    return Stat,UpgradeValue;
end

--큐폴의 업그레이드 스텟 관련 정보를 가져옴.
function GET_CUPOLE_OWNED_STAT_VALUE(cls)
    local Cupole_Group_ID = TryGetProp(cls, "Group_ID", "None");
    local Cupole_Upgrade_List = GET_CUPOLE_UPGRADE_BY_GROUPID_LIST(Cupole_Group_ID)
    local Cupole_Upgrade_Cls = Cupole_Upgrade_List[1];
    if Cupole_Upgrade_Cls == nil then
        return;
    end

    local Stat = TryGetProp(Cupole_Upgrade_Cls, "Owned_Stat", "None")
    local UpgradeValue = TryGetProp(Cupole_Upgrade_Cls, "Owned_Value", 0)
    return Stat,UpgradeValue;
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

function GET_CUPOLE_PROBABILITY(group)
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
        local Kupole_Group = TryGetProp(cls, "Group", "ALL");

        if Grade ~= "None" and (group == Kupole_Group or Kupole_Group == "ALL") then
            item_counts[Grade] = item_counts[Grade] + Ratio
        end
    end

    -- 각 등급에서 각 아이템의 확률 구하기
    for i = 0, cnt - 2 do  
        local cls = GetClassByIndexFromList(clslist, i)
        local Grade = TryGetProp(cls, "Grade", "None")
        local name = TryGetProp(cls, "ClassName", "None")
        local Ratio = TryGetProp(cls, "Ratio", 0)
        local Kupole_Group = TryGetProp(cls, "Group", "ALL");
        if Grade ~= "None" and (group == Kupole_Group or Kupole_Group == "ALL") then
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
    --서버
    if IsServerSection(pc) == 1 then
        acc = GetAccountObj(pc)
    else
    --클라
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

    return GET_KUPOLE_UPGRADE_ITEM_COUNT(UpgradeCls , rank);
end

function GET_KUPOLE_UPGRADE_ITEM_COUNT(UpgradeCls, rank)
    local UpgradeItemClassName = TryGetProp(UpgradeCls, "UpgradeItem")
    local UpgradeCount = TryGetProp(UpgradeCls, "UpgradeItemValue")
    
    return UpgradeItemClassName, UpgradeCount + tonumber(rank) - 1
end

function GE_CURRENTE_PICKUP_CUPOLE_ULTRA_RANK_LIST()
    local cupolelist, cupolecnt = GetClassList("cupole_list");
    local ratiolist, ratiocnt = GetClassList("cupole_ratio");

    local URList = {};
    for i = 0, cupolecnt - 1 do
        local cupolecls = GetClassByIndexFromList(cupolelist, i)
        local Grade = TryGetProp(cupolecls, "Grade", "R")
        local ClsName = TryGetProp(cupolecls, "ClassName", "None")
        if Grade == "UR" then
            local RatioItem = GetClassByNameFromList(ratiolist, ClsName);
            if RatioItem then
                table.insert(URList, cupolecls)
            end
        end
    end

    return URList;
end

