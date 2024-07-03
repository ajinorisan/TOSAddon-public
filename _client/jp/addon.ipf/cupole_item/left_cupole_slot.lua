
local left_cupole_index;

--param : slot frame
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

--param : slot frame
--        cupole_index
--        cupole_index2
function SET_SWAP_LEFT_CUPOLE_SLOT(fromframe, destframe, fromindex, destindex)
    local pc = GetMyPCObject();
    if pc == nil then
        return;
    end
    local etc = GetMyEtcObject(pc);
    if etc == nil then
        return ;
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
    local equiplist = StringSplit(EquipState,';')
    
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
    local Gb = GET_CHILD(frame,"gb");
    local revert = GET_CHILD_RECURSIVELY(frame, "revert");
    local grade_img = GET_CHILD_RECURSIVELY(frame, "grade_img");
    local Cupole_Slot = GET_CHILD(frame,"cupole_slot");
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
    local RankFrameName = string.format("cupole_grade_frame_%s",Grade);
    local RankName = string.format("cupole_grade_%s",Grade);
    local RevertFramaName = string.format("cupole_revert_%s",Grade);
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
        local gb = GET_CHILD(slot,"gb")
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
        return ;
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

--param : slot frame
function RESET_CUPOLE_SLOT_INFORMATION(frame)
    local gb = GET_CHILD(frame,"gb");
    local revert = GET_CHILD(frame, "revert");
    local cupole_slot = GET_CHILD(frame,"cupole_slot");

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
        UNSUMMON_CUPOLE_BTN(frame,SlotIndex);
    end
end

--선택시 함수(장착 x)
function CUPOLE_SLOT_SELECT_BTN(parent, ctrl, argStr, argNum)
    local frame = parent:GetTopParentFrame();
    local rightslotset = GET_CHILD_RECURSIVELY(frame, "slotsetBG")
    local SlotBG = GET_CHILD_RECURSIVELY(frame, "SlotBG")
    local gb_slot = GET_CHILD(SlotBG, "gb_slot")
    
    local bg = parent:GetParent();
    FRAME_CHILD_COLORTONE_CLEAR(bg)
    FRAME_CHILD_COLORTONE_CLEAR(rightslotset)
    gb_slot:SetUserValue("LEFT_SEL_SLOT",parent:GetName());

    local SEL_CUPOLE_INDEX = parent:GetUserIValue("SEL_CUPOLE_INDEX")
    local SelectBtn = GET_CHILD_RECURSIVELY(frame,"SelectBtn");

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
        return ;
    end

    SET_CUPOLE_LIST_SET_FUNCTION(frame, "right_slotset_cupole_set_func");
    SET_CUPOLE_SLOT_SET_FUNCTION(frame, "left_slotset_cupole_change_func");

    local ignore_list = {
        "managerTab", "SlotBG", "slotsetBG", "manageBG"
    }

    CUPOLE_SELECT_MODE(frame, 0, "FF222222");
end

--좌측 슬롯셋에 정보를 전달하는 함수
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

--좌측 슬롯셋끼리 정보를 교환하게 만드는 함수.
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
        --slot에 정보 세팅 해주면서 왼쪽에 정보도 추가해주도록해야함.
        SET_SWAP_LEFT_CUPOLE_SLOT(from_sel_slot, parent, from_sel_slot_cupole_index, current_sel_slot_cupole_index)
    end

    RESET_RIGHT_CUPOLE_SLOTSET(grand_parent)
    RESET_LEFT_CUPOLE_SLOTSET(grand_parent)
end


--큐폴 소환
function SUMMON_CUPOLE_BTN(frame, argNum, SlotIndex)
    local pc = GetMyPCObject();
    if pc == nil then
        return;
    end
    local etc = GetMyEtcObject(pc);
    if etc == nil then
        return ;
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
    local SelectBtn = GET_CHILD_RECURSIVELY(parent,"SelectBtn");
    local DisableBtn = GET_CHILD_RECURSIVELY(parent,"DisableBtn");
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