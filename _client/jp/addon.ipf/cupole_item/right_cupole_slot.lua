--우측 슬롯 초기화
--슬롯 초기화에 따른 index변경 필요.
function CUPOLE_FILTER_SELECT_RESET(filter_frame)
    local frame = ui.GetFrame("cupole_item");
    local pc = GetMyPCObject();
    if pc == nil then
        return;
    end

    filter_type = filter_frame:GetUserValue("Filter");
    GET_CUPOLE_SORT_TYPE_FUNCTION(filter_type)

    --CREATE_CUPOLE_UIMODEL()
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
        return ;
    end

    RESET_CUPOLE_SLOT_INFORMATION(slot)

    local SelectBtn = GET_CHILD_RECURSIVELY(frame,"SelectBtn");
    SET_CUPOLE_SELECT_BTN(SelectBtn,"CUPOLE_RIGHT_SLOT_EQUIP","equipment");
    SET_CUPOLE_SLOT_SET_FUNCTION(frame,"None");
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
        return ;
    end

    local parent = frame:GetTopParentFrame();

    local CupoleEquipStr = TryGetProp(etc, "Cupole_Equip", "0;0;0");
    local CupoleEquipList =  StringSplit(CupoleEquipStr,';')
    local CupoleIndex = CupoleEquipList[SlotIndex + 1]
    local cls = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(CupoleIndex)
    local index = -1;
    -- if tonumber(cupole_exp) <= 0 then
    --     return;
    -- end
    SummonCupole(index, SlotIndex)
    --movie.PlayEffect("F_sys_heart")
    -- local buff = AddBuff(pc, pc, BuffName, 1, 0, 0, 1);
    -- SetBuffUpdateTime(buff, 1000);
end

function SET_CUPOLE_LIST(frame)
    local managerTab = GET_CHILD(frame,"managerTab")
    local manageBG = GET_CHILD(managerTab,"manageBG")
    local slotsetBG = GET_CHILD(manageBG,"slotsetBG")
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
        local cupole_slot_box = slotsetBG:CreateOrGetControlSet('cupole_slot', slotName, offsetX + row * posX, offsetY + col * posY);
    
        local gb = GET_CHILD(cupole_slot_box,"gb");
        local revert = GET_CHILD(cupole_slot_box,"revert");
        local grade_img = GET_CHILD_RECURSIVELY(cupole_slot_box, "grade_img");
        local cupole_slot = GET_CHILD(cupole_slot_box,"cupole_slot");
        local disable_shadow = GET_CHILD(cupole_slot_box,"disable_shadow");
        local equip_img = GET_CHILD(cupole_slot_box, "equip_img")
        if cupole_slot == nil then
            return;
        end
        if gb == nil then
            return;
        end
    
        local Grade = TryGetProp(cupole_cls, "Grade", "R");
        local RankFrameName = string.format("cupole_grade_frame_%s",Grade);
        local RankName = string.format("cupole_grade_%s",Grade);
        local RevertFramaName = string.format("cupole_revert_%s",Grade);
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
        local slot = slotsetBG:CreateOrGetControlSet('cupole_slot', slotName, offsetX + row * posX, offsetY + col * posY);
        
        local gb = GET_CHILD(slot,"gb");
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

--우측 슬롯셋에서 장착 버튼을 누르면 작동하는 함수 
--선택시 함수(장착 x)
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
    gb_slot:SetUserValue("RIGHT_SEL_SLOT",parent:GetName());

    rightslotset:SetUserValue("SEL_RIGHT_CUPOLE_IDX", argNum)
    local SelectBtn = GET_CHILD_RECURSIVELY(frame,"SelectBtn");
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
        return ;
    end

    local SlotBG = GET_CHILD_RECURSIVELY(frame, "SlotBG")
    local gb_slot = GET_CHILD(SlotBG, "gb_slot")
    local slot_name = gb_slot:GetUserValue("RIGHT_SEL_SLOT");


    SET_CUPOLE_SLOT_SET_FUNCTION(frame, "left_slotset_cupole_set_func");
    
    local ignore_list = {slot_name}

    CUPOLE_SELECT_MODE(frame, 0, "FF222222", ignore_list);
end

--우측 슬롯셋에서 큐폴을 선택하면 좌측에 정보를 이전하는 함수
function right_slotset_cupole_set_func(parent, ctrl, argStr, argNum)
    local grand_parent = parent:GetTopParentFrame();
    local SlotBG = GET_CHILD_RECURSIVELY(grand_parent, "SlotBG")
    local left_gb_slot = GET_CHILD(SlotBG, "gb_slot")
    local managerTab = GET_CHILD(grand_parent, "managerTab")

    local left_sel_slot_name = left_gb_slot:GetUserValue("LEFT_SEL_SLOT")
    local left_sel_slot = GET_CHILD_RECURSIVELY(grand_parent, left_sel_slot_name)
    --slot에 정보 세팅 해주면서 왼쪽에 정보도 추가해주도록해야함.

    local IsDuplicateCupole = CHECK_IS_EQUIP_CUPOLE(nil, argNum)
    if IsDuplicateCupole == false then
        return;
    end

    SUMMON_SELECT_LEFT_CUPOLE_SLOT(left_sel_slot, argNum)
    --선택 세팅 후에 원상복구 시키는 로직.
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