--리스트

--1. 리스트 생성
-- 1.1 리스트 생성 후, 채우기
-- 1.2 리스트에 아이템 반응

--2. 유물 경험치
-- 2.1 유물 경험치 비교 및 레벨 적용
-- 2.2 유물 레벨 업 기능
-- ui.OpenFrame("archeology_exhibition")


---구현 된 것

--1. 전시대 장착
--2. 전시대 해체
--3. 효과 추가
--4. 업그레이드
--5. 코스트 
function ARCHEOLOGY_EXHIBITION_ON_INIT(addon, frame)
    addon:RegisterMsg('ARCHEOLOGY_EXHIBITION_ADD_ITEM', 'ON_ARCHEOLOGY_EXHIBITION_ADD_ITEM');
    addon:RegisterMsg('ARCHEOLOGY_EXHIBITION_DELETE_ITEM', 'ON_ARCHEOLOGY_EXHIBITION_DELETE_ITEM');
    addon:RegisterMsg('CLEAR_ALL_EXHIBTTION_SLOT', 'ON_CLEAR_ALL_EXHIBTTION_SLOT');
    addon:RegisterMsg('UPDATE_EXHIBITION_RANK', 'ON_UPDATE_EXHIBITION_RANK');        
end

function OPEN_ARCHEOLOGY_EXHIBITION_UI(frame)
    ui.OpenFrame("archeology_exhibition")
end

function ARCHEOLOGY_EXHIBITION_OPEN(frame)
    CREATE_ARCHEOLOGY_EXHIBITION_LIST(frame)
    ui.OpenFrame("inventory");
    INVENTORY_SET_CUSTOM_RBTNDOWN("INSERT_ARCHEOLOGY_EXHIBITION_ITEM_RBTN")
    UPDATE_EXHIBITION_COST_TEXT(frame)
    UPDATE_EXHIBITION_EFFECT_TEXT(frame)
	SET_EXP_TEXT(frame)

    pc.ReqExecuteTx_Item("ARC_EQUIP_ITEM", "")
end

function ARCHEOLOGY_EXHIBITION_CLOSE(frame)
    ui.EnableSlotMultiSelect(0);
    ui.CloseFrame("inventory");
    INVENTORY_SET_CUSTOM_RBTNDOWN("None");
end

-- top frame이 들어온다는 가정 필요
-- 장착한 아이템을 보여주는 함수
-- 아이템 컨트롤 생성 시 필요 한 것들
-- 현재 장착한 아이템 장착시켜주는 로직
function CREATE_ARCHEOLOGY_EXHIBITION_LIST(frame)
    local archeology_slot_Gbox = GET_CHILD_RECURSIVELY(frame, "archeology_slot_Gbox");
    local max_list = tonumber(frame:GetUserConfig('MAX_SIZE'))
    local slotlist = {GET_ARCEX_SLOT_ITEMS()}
    for i = 1, max_list do 
        local ctrl = archeology_slot_Gbox:CreateOrGetControlSet('archeology_exhibition_item_slot', 'slot'..i, 163 * (i - 1) + 3, 4);
        local itemidx = slotlist[i];
        if ctrl then
            ctrl:SetEventScript(ui.RBUTTONUP, "DELETE_ARCHEOLOGY_EXHIBITION_ITEM_RBTN")
            ctrl:SetEventScriptArgNumber(ui.RBUTTONUP, i)
            --아이템이 존재하면 표현한다.
            --해당 번호는 clslist에 존재하는 clsid기준으로 가져옴.
            if itemidx > 0 then
                local itemcls = GET_ARCEX_ITEM_BY_CLSID(itemidx);
                local itemclsname = TryGetProp(itemcls, "ClassName", "None")
                UPDATE_EXHIBITION_SLOT_ITEM(frame, i, itemclsname);
            else
                UPDATE_EXHIBITION_SLOT_ITEM(frame, i, nil);
            end
        end
    end
end

--아이템 장착 하는 로직 (드랍 버전)
function INSERT_ARCHEOLOGY_EXHIBITION_ITEM_DROP(parent, ctrl)
    local frame	= parent:GetTopParentFrame()
	local liftIcon = ui.GetLiftIcon()
	local slot = tolua.cast(ctrl, 'ui::CSlot')
	local iconInfo = liftIcon:GetInfo()
	local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID())
	
	if nil == invItem then return end

    INSERT_ARCHEOLOGY_EXHIBITION_ITEM(frame, iconInfo:GetIESID())
end

--아이템 장착 하는 로직 (우클릭 버전)
function INSERT_ARCHEOLOGY_EXHIBITION_ITEM_RBTN(itemObj, slot)
    local frame = ui.GetFrame("archeology_exhibition");
    local icon = slot:GetIcon();
    local iconInfo = icon:GetInfo();
    local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());
    local obj = GetIES(invItem:GetObject());

    local fromFrame = slot:GetTopParentFrame();
    if fromFrame:GetName() == "inventory" then
        -- INSERT_ARCHEOLOGY_EXHIBITION_ITEM(frame, invItem, nil, fromFrame
        INSERT_ARCHEOLOGY_EXHIBITION_ITEM(frame, iconInfo:GetIESID())
    end
end

--아이템 해체 로직
function DELETE_ARCHEOLOGY_EXHIBITION_ITEM_RBTN(frame, parent, argStr, argNum)
    pc.ReqExecuteTx_Item("ARC_UNEQUIP_ITEM", argNum)
end

-- 서버에 정보 보내기
-- 완성 되면 받아서 ui처리
-- 그 동안 입력 block해야함.
function INSERT_ARCHEOLOGY_EXHIBITION_ITEM(frame, itemGuid)

    pc.ReqExecuteTx_Item("ARC_EQUIP_ITEM", itemGuid)
end


--아이콘 고민
--1. 기본적인 borad와 화살표 아이콘
--2. 아이템이 들어가면, 화살표 아이콘 제거 
--3. 아이템의 기준에 따라 배경 및 등급 이미지 정보 넣어야 한다.
function ON_ARCHEOLOGY_EXHIBITION_ADD_ITEM(frame,msg, itemName, SlotIdx)
    UPDATE_EXHIBITION_SLOT_ITEM(frame, SlotIdx, itemName);
    UPDATE_EXHIBITION_COST_TEXT(frame)
    UPDATE_EXHIBITION_EFFECT_TEXT(frame)
end

function ON_ARCHEOLOGY_EXHIBITION_DELETE_ITEM(frame, msg, itemName, SlotIdx)
    UPDATE_EXHIBITION_SLOT_ITEM(frame, SlotIdx, itemName);
    UPDATE_EXHIBITION_COST_TEXT(frame)
    UPDATE_EXHIBITION_EFFECT_TEXT(frame)
end

function ALL_UNEQUIP_EXHIBITION_ITEM(parent, ctrl, item, slot)
    pc.ReqExecuteTx_Item("ARC_UNEQUIP_ITEM", 4)
end

function UPDATE_EXHIBITION_SLOT_ITEM(frame, slotidx, itemName)
    local archeology_slot_Gbox = GET_CHILD_RECURSIVELY(frame, "archeology_slot_Gbox");
    if not archeology_slot_Gbox then
        return;
    end
    local child_slot = archeology_slot_Gbox:GetChild("slot"..slotidx)
    if not child_slot then
        return;
    end
    local target_item = GetClass("Item", itemName)
    local archeology_exhibition_slot = GET_CHILD_RECURSIVELY(child_slot, "archeology_exhibition_slot") 
    local default_image = GET_CHILD_RECURSIVELY(child_slot, "default_image")
    local gold_border = GET_CHILD_RECURSIVELY(child_slot, "gold_border")
    local archeology_exhibition_gauge = GET_CHILD_RECURSIVELY(child_slot, "archeology_exhibition_gauge")

    

    --아이템이 nil이면 제거하는 방향
    if not target_item then
        archeology_exhibition_slot:ClearIcon()    
        default_image:ShowWindow(1)
        gold_border:ShowWindow(1)
        return;
    end 

	local icon = imcSlot:SetImage(archeology_exhibition_slot, target_item.Icon);
    default_image:ShowWindow(0)
    gold_border:ShowWindow(0)

    
end

function ON_CLEAR_ALL_EXHIBTTION_SLOT(frame)
    for i = 1, 3 do 
        UPDATE_EXHIBITION_SLOT_ITEM(frame, i , nil)
    end
    UPDATE_EXHIBITION_EFFECT_TEXT(frame)
    UPDATE_EXHIBITION_COST_TEXT(frame)
end

function UPDATE_EXHIBITION_COST_TEXT(frame)
    local archeology_cost = GET_CHILD_RECURSIVELY(frame, "archeology_cost");
    local curCost = GET_CURRENT_AREX_COST();
    local lv, maxCost = GET_ARCHEOLOGY_EXHIBITION_INFO();
    archeology_cost:SetTextByKey("use", curCost)    
    archeology_cost:SetTextByKey("max", maxCost)
end

function UPDATE_EXHIBITION_EFFECT_TEXT(frame)
    local archeology_effect_Gbox = GET_CHILD_RECURSIVELY(frame, "archeology_effect_Gbox")
    local archeology_effect_text_Gbox = GET_CHILD_RECURSIVELY(frame, "archeology_effect_text_Gbox");
    archeology_effect_text_Gbox:RemoveAllChild()

    local apply_effect_list = GET_CURRENT_APPLY_EFFECT_LIST()
    local index = 0;
    local offset = 51
    for effect_name, effect_value in pairs(apply_effect_list) do
        local text_ctrlset = archeology_effect_text_Gbox:CreateOrGetControlSet("archeology_exhibition_effect", effect_name, 3, index * offset + 3);
        local archeology_exhibition_effect_tooltip= GET_CHILD_RECURSIVELY(text_ctrlset, "archeology_exhibition_effect_tooltip")

        local value_str = GET_ARCHEOLOGY_STAT_DESC(effect_name, effect_value)
        archeology_exhibition_effect_tooltip:SetText(string.format("{@st42}%s{/}", value_str))        
        index = index + 1;
    end
    if index > 3 then
        index = 3;
    end

    archeology_effect_Gbox:Resize(archeology_effect_Gbox:GetWidth(), 53 * index)
    archeology_effect_text_Gbox:Resize(archeology_effect_text_Gbox:GetWidth(), 53 * index)
end

function EXCUTE_EXHIBITION_RANKUP(frame, ctrl, argStr, argNum)
    local aObj = GetMyAccountObj()
    local curCointCnt = session.GetInvItemCountByType(11200475);
    local maxExp = GET_EXHIBITION_GOAL_EXP();
    local curExp = TryGetProp(aObj, 'ARCHEOLOGY_EXP', 0);
    local nextExp = maxExp - curExp > 0 and maxExp - curExp or 0
    local minCnt = math.min(curCointCnt, nextExp)  

    local titleText = ScpArgMsg("INPUT_CNT_D_D", "Auto_1", 1, "Auto_2", minCnt);
    local inputstringframe = ui.GetFrame("inputstring");
	INPUT_NUMBER_BOX(inputstringframe, titleText, "SEND_EXHIBITION_RANKUP", 1, 1, minCnt, 1);	
end

function SEND_EXHIBITION_RANKUP(paernt, count)
    pc.ReqExecuteTx_Item("ARC_UPGRADE", count)
end

function ON_UPDATE_EXHIBITION_RANK(frame)
    UPDATE_EXHIBITION_COST_TEXT(frame)
    SET_EXP_TEXT(frame)
end

function SET_EXP_TEXT(frame)
    local aObj = GetMyAccountObj()
	local total_exp = TryGetProp(aObj, "ARCHEOLOGY_EXP", 0)
	local max_level = 7;
	local remain_exp = 0;
	for i = 1, max_level do
		local cls = GetClass('archeology_exhibition_exp', tostring(i))        
		local _exp = TryGetProp(cls, 'Exp', 0)        
		if total_exp < _exp then  
			remain_exp = _exp - total_exp;         
            break; 
		end
	end

	local levelt_text = GET_CHILD_RECURSIVELY(frame, "levelt_text")
	levelt_text:SetTextByKey("val", remain_exp)
end