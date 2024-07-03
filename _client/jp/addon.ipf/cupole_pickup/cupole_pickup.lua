local MAX_COUNT = get_cupole_pickup_count();
local DEFAULT_INDEX = 25
local OFFSET_X = -10
local OFFSET_Y = 105
local EMPTY_INDEX = -1;
function CUPOLE_PICKUP_ON_INIT(addon,frame)
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
    CUPOLE_INFO_SELECT(InfoBG,nil,nil,0)
    CREATE_PICKUP_CUPOLE_LIST(frame)
    SET_CURRENT_CUPOLE_PICKUP_ITEM_VALUE_COLOR(frame)
    frame:RunUpdateScript("UPDATE_CUPOLE")
    PICKUP_CUPOLE_SELECT(InfoBG,nil,nil,DEFAULT_INDEX)
    CHNAGE_ALL_CUPOLE_UIMODEL_STATE(1)
    
    local PickupListBG = GET_CHILD_RECURSIVELY(frame,"PickupListBG")
    PickupListBG:SetScrollBarSkinName("verticalscrollbar3")
end

function CLOSE_CUPOLE_PICKUP(frame)
    frame:StopUpdateScript("UPDATE_CUPOLE")
    CHNAGE_ALL_CUPOLE_UIMODEL_STATE(0)
end

function CREATE_PICKUP_CUPOLE_LIST(frame)
    local Pickuplist = {}
    local cupolelist, cnt = GetClassList("cupole_list")
    for i = 0 , cnt - 1 do
        local cls = GetClassByIndexFromList(cupolelist, i)
        if cls and TryGetProp(cls, "Grade", "R") == "UR" and TryGetProp(cls, "Use", "false") == "true" then
            table.insert(Pickuplist, cls)
        end
    end

    local PickupListBG = GET_CHILD_RECURSIVELY(frame, "PickupListBG")
    local offset = {OFFSET_X, OFFSET_Y}
    for k,v in pairs(Pickuplist) do
       local clsname = TryGetProp(v, "ClassName", "None")
        local index = TryGetProp(v, "ClassID", '0') - 1
        local cupole_slot_box = PickupListBG:CreateOrGetControlSet('cupole_pickup_slot', clsname, offset[1], (k - 1) * offset[2] + 5)
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
    local itemCtrl = PickupListBG:CreateOrGetControlSet('cupole_pickup_slot', "UR", offset[1], (#Pickuplist) * offset[2] + 5)
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
        count = "{#FF0000}"..cost.."{/}";
    else
        count = "{#00BBBB}"..cost.."{/}";
    end

    SET_CUPOLE_PIKCUP_COUNT(frame, count , max)
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
        frame:RunUpdateScript("KUPOLE_UIMODEL_IN_PICKUP",0.2)
        local cls = GET_CUPOLE_CLASS_BY_INDEX(argNum)
        SET_SELECT_CUPOLE_NAME(frame, argNum)
        CUPOLE_INFO_SELECT(bg, nil, nil ,0)    
        MainCharacter:ShowWindow(1)
        ItemPic:ShowWindow(0)
        SET_CURRENT_CUPOLE_PICKUP_ITEM_VALUE_COLOR(frame, MAX_COUNT)
    elseif argStr =="cupole_rankup_UR" then
        SET_CURRENT_CUPOLE_PICKUP_ITEM_VALUE_COLOR(frame, MAX_COUNT / 3)
        SET_CURRENT_CUPOLE_SELECT_INDEX(EMPTY_INDEX);
        SET_SELECT_CUPOLE_NAME(frame, -1);
        CUPOLE_INFO_SELECT(bg, nil, nil ,2)    
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
    local Skl_light= GET_CHILD(SelectBG, "Skl_light")
    local Eft_light= GET_CHILD(SelectBG, "Eft_light")

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

    local Itemexp = GET_CHILD(ItemBG,"Itemexp")
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

    local Group_ID = TryGetProp(cupole_cls,"Group_ID", "None")
    local SkillTable = GET_CUPOLE_SKILL_BY_GROUPID_LIST(Group_ID);
    local Name, Explain, Icon = CREATE_CUPOLE_SKILL_RATIO_TEXT(SkillTable[2]);

    local SkillIcon = GET_CHILD(frame,"SkillIcon")
    local SkillName = GET_CHILD(frame,"SkillName")
    local SkillExplan = GET_CHILD(frame,"SkillExplan")

    SkillName:SetTextByKey("name",Name)
    SkillExplan:SetTextByKey("explan",Explain)
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