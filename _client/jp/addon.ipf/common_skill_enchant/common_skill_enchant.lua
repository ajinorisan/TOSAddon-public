--@ common_skill_enchant 2023.1 ~
--@ USERVALUE : IS_READY / 
local MAX_SLOT_CNT = 2
local function PRE_LOAD_COMMON_SKILL_ENCHANT()
    if item_list==nil then
        item_list = GetClassList("Item");
    end
end
PRE_LOAD_COMMON_SKILL_ENCHANT()

function COMMON_SKILL_ENCHANT_ON_INIT(addon,frame)
    addon:RegisterMsg('MSG_SUCCESS_ENCHANT_SKILL', 'SUCCESS_COMMON_SKILL_ENCHANT')
    addon:RegisterMsg('MSG_FAIL_ENCHANT_SKILL', 'FAILED_COMMON_SKILL_ENCHANT')
end

function SUCCESS_COMMON_SKILL_ENCHANT(frame,msg,arg_str,arg_num)
    ui.SetHoldUI(false);
    local frame = ui.GetFrame('common_skill_enchant')
    local slot = GET_CHILD_RECURSIVELY(frame, 'slot', 'ui::CSlot')
    --호출 순서 중요
    local curr_id = slot:GetUserValue("SET_ID")
    REFRESH_COMMON_SKILL_ENCHANT()
    COMMON_SKILL_ENCHANT_SET_TARGET_ITEM(frame,curr_id)
    if arg_num == 1 then

    elseif arg_num == 2 then
        return
    elseif arg_num == 3 then
        
    elseif arg_num == 4 then
        
    end
    
	imcSound.ReleaseSoundEvent("sys_transcend_success");
    imcSound.PlaySoundEvent("sys_transcend_success");
    GET_CHILD_RECURSIVELY(frame,'successBgBox') :ShowWindow(1)
    GET_CHILD_RECURSIVELY(frame,'middle_Bg')    :ShowWindow(0)
    GET_CHILD_RECURSIVELY(frame,'bottom_Bg')    :ShowWindow(0)
    
    ReserveScript('COMMON_SKILL_ENCHANT_END()', 0.8)
end

function COMMON_SKILL_ENCHANT_END()
    local frame = ui.GetFrame('common_skill_enchant')
    GET_CHILD_RECURSIVELY(frame,'successBgBox') :ShowWindow(0)
    GET_CHILD_RECURSIVELY(frame,'middle_Bg')    :ShowWindow(1)
    GET_CHILD_RECURSIVELY(frame,'bottom_Bg')    :ShowWindow(1)
end

function FAILED_COMMON_SKILL_ENCHANT(frame,msg,arg_str,arg_num)
    ui.SetHoldUI(false);
    REFRESH_COMMON_SKILL_ENCHANT()
end

function COMMON_SKILL_ENCHANT_OPEN(frame)
    ui.OpenFrame('inventory')
    INVENTORY_SET_CUSTOM_RBTNDOWN('COMMON_SKILL_ENCHANT_INV_RBTN')
    REFRESH_COMMON_SKILL_ENCHANT()
end

function COMMON_SKILL_ENCHANT_CLOSE(frame)
    if ui.CheckHoldedUI() == true then
		return
    end
    INVENTORY_SET_CUSTOM_RBTNDOWN('None')
    ui.CloseFrame('common_skill_enchant')
    frame:ShowWindow(0)
    control.DialogOk()
    ui.CloseFrame('inventory')
end

--@ REFRESH ALL THIS UI
function REFRESH_COMMON_SKILL_ENCHANT()
    if ui.CheckHoldedUI() == true then return end
    local frame = ui.GetFrame('common_skill_enchant')

    frame:SetUserValue("IS_READY","FALSE")
    GET_CHILD_RECURSIVELY(frame,'middle_Bg')    :ShowWindow(1)
    GET_CHILD_RECURSIVELY(frame,'bottom_Bg')    :ShowWindow(1)
    -- 1. RESET ITEM SLOT SECTION "START"--
    local slot = GET_CHILD_RECURSIVELY(frame, 'slot', 'ui::CSlot')
    slot:SetSkinName("invenslot_nomal")
    slot:SetUserValue("SET_ID","None")
    slot:ClearIcon()
    GET_CHILD_RECURSIVELY(frame,'text_putonitem')   :ShowWindow(1) 
    GET_CHILD_RECURSIVELY(frame,'text_itemname')    :ShowWindow(0)
    GET_CHILD_RECURSIVELY(frame,'successBgBox')    :ShowWindow(0)
    
    for i=1,MAX_SLOT_CNT do
        local enchant_slot_gb = GET_CHILD_RECURSIVELY(frame,"enchant_slot_gb_"..tostring(i))
        local mat_slot = GET_CHILD_RECURSIVELY(enchant_slot_gb,"mat_slot"..tostring(i))
        local mat_name = GET_CHILD_RECURSIVELY(enchant_slot_gb,"mat_name"..tostring(i))
        local shadow = GET_CHILD_RECURSIVELY(enchant_slot_gb,"shadow"..tostring(i))
        mat_slot:ClearIcon()
        mat_name:SetTextByKey("value","")
        shadow:ShowWindow(1)
    end
    
    GET_CHILD_RECURSIVELY(frame,'selectBtn_Left')    :ShowWindow(0)
    GET_CHILD_RECURSIVELY(frame,'selectBtn_Right')   :ShowWindow(0)
    

    -- 2. RESET ITEM SLOT SECTION "END" --

    -- 3. RESET BOTTOM MAT SECTION "START"--
    local bottom_Bg = GET_CHILD_RECURSIVELY(frame, 'bottom_Bg')
    bottom_Bg:RemoveAllChild();
    -- RESET BOTTOM SECTION "END"--

    -- 4. DISABLE DO ENCHANT BUTTON START -- 
    local do_enchant = GET_CHILD_RECURSIVELY(frame, 'do_enchant')
    do_enchant:SetEnable(0)

    -- DISABLE DO ENCHANT BUTTON END -- 
end


function COMMON_SKILL_ENCHANT_INV_RBTN(item_obj,slot)
    local frame = ui.GetFrame('common_skill_enchant')
    if frame == nil then return end
    REFRESH_COMMON_SKILL_ENCHANT()

    local icon      = slot:GetIcon()
    local iconInfo  = icon:GetInfo()
    local Ies_Id    = iconInfo:GetIESID()
    COMMON_SKILL_ENCHANT_SET_TARGET_ITEM(frame, Ies_Id)
end

--@ MOUSE DROP EVENT
function COMMON_SKILL_ENCHANT_TARGET_ITEM_DROP(parent,self,argStr, argNum)
    local frame = ui.GetFrame('common_skill_enchant')
    if frame == nil then return end
    REFRESH_COMMON_SKILL_ENCHANT()
    local liftIcon = ui.GetLiftIcon()
	local FromFrame = liftIcon:GetTopParentFrame()
	if FromFrame:GetName() == 'inventory' then
        local iconInfo = liftIcon:GetInfo()
		COMMON_SKILL_ENCHANT_SET_TARGET_ITEM(frame, iconInfo:GetIESID())
	end
end

function COMMON_SKILL_ENCHANT_SET_TARGET_ITEM(frame,itemID)
    if ui.CheckHoldedUI() == true then return end
    local inv_item = session.GetInvItemByGuid(itemID)
    if inv_item == nil then return end
    local item_obj = GetIES(inv_item:GetObject())
    local item_cls = GetClassByType('Item', inv_item.type)
	if item_obj == nil or item_cls == nil then return end

    local res,clsmsg = shared_common_skill_enchant.is_valid_item(item_obj)
    if res == false then ui.SysMsg(ClMsg(clsmsg)); return end

    local invframe = ui.GetFrame('inventory')
	if true == inv_item.isLockState or true == IS_TEMP_LOCK(invframe, inv_item) then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
    end
    
    -- TARGET SLOT SET "START"--
    local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
    SET_SLOT_ITEM(slot, inv_item)
    SET_SLOT_BG_BY_ITEMGRADE(slot,item_cls)
    slot:SetUserValue("SET_ID",itemID)
    
    GET_CHILD_RECURSIVELY(frame, 'text_putonitem'):ShowWindow(0)
    local itemText = GET_CHILD_RECURSIVELY(frame, 'text_itemname')
    local item_name = TryGetProp(item_obj,"Name","None")
    if item_name == "None" then return end
    itemText:SetTextByKey('value',item_name)
    itemText:ShowWindow(1)
    -- TARGET SLOT SET "END"--

    local gb1  = GET_CHILD_RECURSIVELY(frame, 'enchant_slot_gb_1')
    local gb2  = GET_CHILD_RECURSIVELY(frame, 'enchant_slot_gb_2')
    
    local skl,lv = shared_common_skill_enchant.get_enchanted_skill(item_obj,1)
    local ret = COMMON_SKILL_ENCHANT_CHECK_EQUIP_STATE(item_obj)
    if ret == 0 then 
        COMMON_SKILL_ENCHANT_MAT_SET(frame,item_obj)
    elseif ret == 1 then
        COMMON_SKILL_ENCHANT_SET_GB(gb1,"1",skl,lv)
        COMMON_SKILL_ENCHANT_MAT_SET(frame,item_obj)
    elseif ret == 2 then
        -- 선택 버튼 보여야함
        local candi_skl,candi_lv = shared_common_skill_enchant.get_canidate_skill(item_obj)
        COMMON_SKILL_ENCHANT_SET_GB(gb1,"1",skl,lv)
        COMMON_SKILL_ENCHANT_SET_GB(gb2,"2",candi_skl,candi_lv)
        GET_CHILD_RECURSIVELY(frame, 'selectBtn_Left'):ShowWindow(1)
        GET_CHILD_RECURSIVELY(frame, 'selectBtn_Right'):ShowWindow(1)
    end
end

function COMMON_SKILL_ENCHANT_MAT_SET(frame,itemObj)
    local frame     = frame:GetTopParentFrame()
    local bottom_bg = GET_CHILD_RECURSIVELY(frame,"bottom_Bg")
    bottom_bg:RemoveAllChild();

    local height = 72
    local index = 1
    local aObj = GetMyAccountObj()
    
    local cost_table = shared_common_skill_enchant.get_cost(itemObj)
    for k,v in pairs(cost_table) do
        local ctrlSet = bottom_bg:CreateOrGetControlSet("mat_required_set", "ENCHANT_MAT_"..index, ui.CENTER_HORZ, ui.TOP,0,height*(index-1),0,0);
        local mat_cls = nil	
        local curr_my_cnt = 0;
        
        if IS_STRING_COIN(k) == true then
            mat_cls = GetClass('Item', 'dummy_' .. k)
            curr_my_cnt = TryGetProp(aObj,k,0)        
        else
            mat_cls = GetClassByNameFromList(item_list,k)
            curr_my_cnt = GET_INV_ITEM_COUNT_BY_PROPERTY({
                { Name = 'ClassName', Value = k }
            }, false)
        end

        local mat_slot = GET_CHILD_RECURSIVELY(ctrlSet,"mat_slot")
        mat_slot:SetEventScriptArgString(ui.LBUTTONUP, mat_cls.ClassName);
              
        local mat_name = GET_CHILD_RECURSIVELY(ctrlSet,"mat_name")
        
        local icon = imcSlot:SetImage(mat_slot,TryGetProp(mat_cls,"Icon","None"))
        icon:SetColorTone('FFFF0000')
        mat_name:SetTextByKey("value",TryGetProp(mat_cls,"Name","None"))
        mat_name:SetTextByKey("value2",GET_COMMAED_STRING(tostring(v)))
        index = index +1;
        
        --내 가방에 요구량
        local curr_my_cnt_text = GET_CHILD_RECURSIVELY(ctrlSet,"cnt_in_my_bag")
        curr_my_cnt_text:SetTextByKey("value",GET_COMMAED_STRING(curr_my_cnt))

    end
end
-- 슬롯/스킬명/레벨
function COMMON_SKILL_ENCHANT_SET_GB(gb,index,argStr1,argStr2)
    --local cls = GetClass('enchant_skill_list',argStr1)
    local slot = GET_CHILD_RECURSIVELY(gb,"mat_slot"..index)
    slot:EnableHitTest(0)
    local text = GET_CHILD_RECURSIVELY(gb,"mat_name"..index)
    local shadow = GET_CHILD_RECURSIVELY(gb,"shadow"..index)
    shadow:ShowWindow(0)

    local cls = GetClass('Skill',argStr1)
    local icon = TryGetProp(cls,"Icon","None")
    icon = "icon_"..icon
    imcSlot:SetImage(slot,icon)

    local input_str = TryGetProp(cls,"Name","None")
    local lv = "[Lv."..argStr2.."] "
    input_str = lv..input_str
    text:SetTextByKey("value",input_str)
end

function COMMON_SKILL_ENCHANT_ADD_MAT(parent,ctrl)
    local frame = parent:GetTopParentFrame();
    if frame == nil then return end
    
	local invItemList = session.GetInvItemList();
    local bottom_bg = GET_CHILD_RECURSIVELY(frame,"bottom_Bg")
    local cnt = bottom_bg:GetChildCount();
    local set_ready_count = 0;
    for i = 1, cnt-1 do
        local ctrlSet = bottom_bg:GetChildByIndex(i)
        
        local mat_slot =  GET_CHILD_RECURSIVELY(ctrlSet,"mat_slot")
        local plus = GET_CHILD_RECURSIVELY(ctrlSet,"plus")
        plus:ShowWindow(1)
        local mat_name =  GET_CHILD_RECURSIVELY(ctrlSet,"mat_name")
        local cnt_in_my_bag = GET_CHILD_RECURSIVELY(ctrlSet,"cnt_in_my_bag")
        
        local val_1 = GET_NOT_COMMAED_NUMBER(mat_name:GetTextByKey('value2'))
        local val_2 = GET_NOT_COMMAED_NUMBER(cnt_in_my_bag:GetTextByKey('value'))
        val_1 = tonumber(val_1)
        val_2 = tonumber(val_2)        
        if val_1 <= val_2 then 
            local icon = mat_slot:GetIcon()
            icon:SetColorTone('FFFFFFFF')
            plus:ShowWindow(0);
            set_ready_count = set_ready_count + 1; 
        else
            local msg = string.format("<%s> %s",mat_name:GetTextByKey('value'), ClMsg("NotEnoughMaterial"))
            ui.SysMsg(msg)
        end
    end

    if set_ready_count == (cnt-1) then
        frame:SetUserValue("IS_READY","TRUE")
        GET_CHILD_RECURSIVELY(frame,"do_enchant"):SetEnable(1)
    else
        frame:SetUserValue("IS_READY","FALSE")
    end
end

function COMMON_SKILL_ENCHANT_CHECK_EQUIP_STATE(itemObj)
    local CommonSkillStr = TryGetProp(itemObj,"CommonSkillStr","None")
    local state = 0
    local skl,lv = shared_common_skill_enchant.get_enchanted_skill(itemObj,1)
    if skl ~= "None" then
        -- 재료를 소모하여 새로운 스킬을 획득
        if CommonSkillStr == "None" then
            return 1
        else
            -- 인챈트 된 스킬이 있음, 후보스킬도 있음
            return 2
        end
    end
    return state
end

function COMMON_SKILL_ENCHANT_DO(parent,self)
    local frame =  parent:GetTopParentFrame();
    local isReady = frame:GetUserValue("IS_READY")

    local slot = GET_CHILD_RECURSIVELY(frame,"slot")
    local guid = slot:GetUserValue("SET_ID")
    if guid=="None" then return end

    local inv_item = session.GetInvItemByGuid(guid)
    if inv_item == nil then return end
    local item_obj = GetIES(inv_item:GetObject())
    if item_obj == nil then return end

    local state = COMMON_SKILL_ENCHANT_CHECK_EQUIP_STATE(item_obj)

    if isReady=="TRUE"  then
        if state==0 or state==1 then
            -- 재료 소진이 되는 TX
            ui.SetHoldUI(true);

            pc.ReqExecuteTx_Item('ENCHANT_VAKARINE_SKILL', guid, '1 1')
        end 
    end 
end


function COMMON_SKILL_ENCHANT_SELECT_BTN_LEFT(parent,self)
    local frame = parent:GetTopParentFrame();
    local slot = GET_CHILD_RECURSIVELY(frame,"slot")
    local guid = slot:GetUserValue("SET_ID")
    if guid=="None" then return end

    ui.SetHoldUI(true);

    pc.ReqExecuteTx_Item('ENCHANT_VAKARINE_SKILL', guid, '1 2')
end

function COMMON_SKILL_ENCHANT_SELECT_BTN_RIGHT(parent,self)
    local frame = parent:GetTopParentFrame();
    local slot = GET_CHILD_RECURSIVELY(frame,"slot")
    local guid = slot:GetUserValue("SET_ID")
    if guid=="None" then return end

    ui.SetHoldUI(true);

    pc.ReqExecuteTx_Item('ENCHANT_VAKARINE_SKILL', guid, '1 3')
end



