--@ skill_enchant 2022.10~
local item_list =  nil;
local MAX_SLOT_CNT = 2;

local function PRE_LOAD_SKILL_ENCHANT()
    if item_list==nil then
        item_list = GetClassList("Item");
    end
end
PRE_LOAD_SKILL_ENCHANT()

function SKILL_ENCHANT_ON_INIT(addon,frame)
    addon:RegisterMsg('MSG_SUCCESS_ENCHANT_SKILL', 'SUCCESS_ENCHANT_SKILL')
    addon:RegisterMsg('MSG_FAILED_ENCHANT_SKILL', 'FAILED_ENCHANT_SKILL')
end

function SUCCESS_ENCHANT_SKILL(frame,msg,arg_str,arg_num)
    local frame = ui.GetFrame('skill_enchant')
    if frame:IsVisible() == 0 then return end 
    local do_enchant = GET_CHILD_RECURSIVELY(frame, 'do_enchant')
    if do_enchant ~= nil then do_enchant:ShowWindow(0) end
    ui.SetHoldUI(false)

    session.ResetItemList();
	imcSound.ReleaseSoundEvent("sys_transcend_success");
    imcSound.PlaySoundEvent("sys_transcend_success");
    GET_CHILD_RECURSIVELY(frame,'successBgBox') :ShowWindow(1)
    GET_CHILD_RECURSIVELY(frame,'middle_Bg')    :ShowWindow(0)
    ReserveScript('_SKILL_ENCHANT_END()', 1.0)
end

function FAILED_ENCHANT_SKILL(frame,msg,arg_str,arg_num)
    local frame = ui.GetFrame('skill_enchant')
    if frame:IsVisible() == 0 then return end 
    local do_enchant = GET_CHILD_RECURSIVELY(frame, 'do_enchant')
    if do_enchant ~= nil then do_enchant:ShowWindow(0) end
    ui.SetHoldUI(false)

    ReserveScript('_SKILL_ENCHANT_END()', 1.0)
end

function _SKILL_ENCHANT_END()
    local frame = ui.GetFrame('skill_enchant')
    if frame:IsVisible() == 0 then return end 
    local do_enchant = GET_CHILD_RECURSIVELY(frame, 'do_enchant')
    if do_enchant ~= nil then do_enchant:ShowWindow(1) end
    GET_CHILD_RECURSIVELY(frame,'successBgBox') :ShowWindow(0)
    GET_CHILD_RECURSIVELY(frame,'middle_Bg')    :ShowWindow(1)
    
    SKILL_ENCHANT_REFRESH()
end

function ON_OPEN_DLG_SKILL_ENCHANT(frame)
	frame:ShowWindow(1)
end

function SKILL_ENCHANT_OPEN(frame)
    ui.OpenFrame('inventory')
    INVENTORY_SET_CUSTOM_RBTNDOWN('SKILL_ENCHANT_INV_RBTN')
    SKILL_ENCHANT_REFRESH()    
end

function SKILL_ENCHANT_CLOSE(frame)
    if ui.CheckHoldedUI() == true then
		return
    end
    INVENTORY_SET_CUSTOM_RBTNDOWN('None')
    frame:ShowWindow(0)
    control.DialogOk()
    ui.CloseFrame('inventory')
end

--@ INIT & RESET UI STATE
function SKILL_ENCHANT_REFRESH()
	if ui.CheckHoldedUI() == true then return end
    local frame = ui.GetFrame('skill_enchant')
    frame:SetUserValue("IS_READY","FALSE")
    -- RESET MIDDLE SECTION "START"--
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
        enchant_slot_gb:ShowWindow(0) 
        mat_slot:ClearIcon()
        mat_slot:SetUserValue("SET_ID","None")
        mat_name:SetTextByKey("value","")
    end
    -- -- RESET MIDDLE SECTION "END" --

    -- RESET BOTTOM SECTION "START"--
    local bottom_Bg = GET_CHILD_RECURSIVELY(frame, 'bottom_Bg')
    bottom_Bg:RemoveAllChild();
    -- RESET BOTTOM SECTION "END"--

    local do_enchant = GET_CHILD_RECURSIVELY(frame, 'do_enchant')
    do_enchant:SetEnable(0)
end

--@ MOUSE R BUTTON EVENT
function SKILL_ENCHANT_INV_RBTN(item_obj,slot)
	local frame = ui.GetFrame('skill_enchant')
    if frame == nil then return end

    local icon      = slot:GetIcon()
    local iconInfo  = icon:GetInfo()
    local Ies_Id    = iconInfo:GetIESID()
    SKILL_ENCHANT_SET_TARGET_ITEM(frame, Ies_Id)
end

--@ MOUSE DROP EVENT
function SKILL_ENCHANT_TARGET_ITEM_DROP(parent,self,argStr, argNum)
    local frame = ui.GetFrame('skill_enchant')
    if frame == nil then return end

    local liftIcon = ui.GetLiftIcon()
	local FromFrame = liftIcon:GetTopParentFrame()
	if FromFrame:GetName() == 'inventory' then
        local iconInfo = liftIcon:GetInfo()
		SKILL_ENCHANT_SET_TARGET_ITEM(frame, iconInfo:GetIESID())
	end
end

function SKILL_ENCHANT_SET_TARGET_ITEM(frame,itemID)
    if ui.CheckHoldedUI() == true then return end
    
    local inv_item = session.GetInvItemByGuid(itemID)
    if inv_item == nil then return end
    local item_obj = GetIES(inv_item:GetObject())
    local item_cls = GetClassByType('Item', inv_item.type)
	if item_obj == nil or item_cls == nil then return end

    local res,clsmsg = shared_skill_enchant.is_valid_item(item_obj)
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

    SKILL_ENCHANT_SHOW_CURRENT_EQUIP_SLOT_STATE(frame,item_obj)
end

function SKILL_ENCHANT_SHOW_CURRENT_EQUIP_SLOT_STATE(frame,obj)
    local cnt = TryGetProp(obj, 'EnchantSkillSlotCount', 0)
    if cnt < 1 then return end 
    for i=1,cnt do 
        local enchant_slot_gb = GET_CHILD_RECURSIVELY(frame,"enchant_slot_gb_"..tostring(i))
        enchant_slot_gb:ShowWindow(1)
        local mat_name  = GET_CHILD_RECURSIVELY(frame,"mat_name"..tostring(i))
        mat_name:ShowWindow(1)
        
        local shadow    = GET_CHILD_RECURSIVELY(frame,"shadow"..tostring(i))
        shadow:ShowWindow(1)
        shadow:SetEnable(1)
        shadow:SetTextByKey("value",ClMsg("ChooseYourSlot"))
        shadow:SetUserValue("IS_ENCHANTED","FALSE")
        
        local mat_slot = GET_CHILD_RECURSIVELY(enchant_slot_gb,"mat_slot"..tostring(i))
        mat_slot:ClearIcon()
        local n,l = shared_skill_enchant.get_enchanted_skill(obj,i)
        if n~="None" and l~= 0 then
            local scroll_name = shared_skill_enchant.get_enchanted_scroll_name(obj,i)
            local mat_cls = GetClassByNameFromList(item_list,scroll_name)
            imcSlot:SetImage(mat_slot,TryGetProp(mat_cls,"Icon","None"))
            mat_name:SetTextByKey("value",TryGetProp(mat_cls,"Name","None"))
            shadow:SetTextByKey("value","")
            shadow:SetUserValue("IS_ENCHANTED","TRUE")
        else 
            mat_name:SetTextByKey("value",ClMsg("PlzDragEnchantScroll"))
            mat_name:ShowWindow(0)
        end
    end
end

function SKILL_ENCHANT_CANCEL(parent,self)
    local frame = parent:GetTopParentFrame();
    frame:SetUserValue("IS_READY","FALSE")
    local slot = GET_CHILD_RECURSIVELY(frame,"slot")
    local id = slot:GetUserValue("SET_ID")

    for i = 1,MAX_SLOT_CNT do
        local mat_slot = GET_CHILD_RECURSIVELY(frame,"mat_slot"..tostring(i))
        local mat_name = GET_CHILD_RECURSIVELY(frame,"mat_name"..tostring(i))
        mat_slot:ClearIcon()
        mat_slot:SetUserValue("SET_ID","None")
        mat_name:SetTextByKey("value","")
    end

    GET_CHILD_RECURSIVELY(frame,"bottom_Bg"):RemoveAllChild()

    if id ~="None" then
        local inv_item = session.GetInvItemByGuid(id)
        if inv_item == nil then return end
        local item_obj = GetIES(inv_item:GetObject())
        SKILL_ENCHANT_SHOW_CURRENT_EQUIP_SLOT_STATE(frame,item_obj)
    end
end

function SKILL_ENCHANT_SELECT_THIS(parent,self,argStr,argNum)
    local frame = parent:GetTopParentFrame();
    local is_enchanted = self:GetUserValue("IS_ENCHANTED")
    
    if is_enchanted=="TRUE" then
        local msg =  ScpArgMsg('ReallyOverWriteSkillScroll');
        local yesScp = string.format('CONTINUE_SKILL_ENCHANT("%s","%s")',self:GetName() ,tostring(argNum))
        WARNINGMSGBOX_FRAME_OPEN(msg,yesScp,"None")
    else
        GET_CHILD_RECURSIVELY(frame,"mat_name"..tostring(argNum)):SetTextByKey("value",ClMsg('PlzDragEnchantScroll'))
        -- Shadow Off -- 
        self:ShowWindow(0)
        if argNum == 1 then
            local enchant_slot_gb = GET_CHILD_RECURSIVELY(frame,"enchant_slot_gb_2")
            enchant_slot_gb:ShowWindow(0)
            GET_CHILD_RECURSIVELY(frame,"mat_name"..tostring(argNum)):ShowWindow(1)
        elseif argNum == 2 then
            local enchant_slot_gb = GET_CHILD_RECURSIVELY(frame,"enchant_slot_gb_1")
            enchant_slot_gb:ShowWindow(0)
            GET_CHILD_RECURSIVELY(frame,"mat_name"..tostring(argNum)):ShowWindow(1)
        end
    end
end

function CONTINUE_SKILL_ENCHANT(ctrl_name,index)
    local frame = ui.GetFrame('skill_enchant')
    GET_CHILD_RECURSIVELY(frame,"mat_name"..index):SetTextByKey("value",ClMsg('PlzDragEnchantScroll'))
    GET_CHILD_RECURSIVELY(frame,ctrl_name):ShowWindow(0)
    if index == "1" then
        local enchant_slot_gb = GET_CHILD_RECURSIVELY(frame,"enchant_slot_gb_2")
        enchant_slot_gb:ShowWindow(0)
        GET_CHILD_RECURSIVELY(frame,"mat_name"..index):ShowWindow(1)
    elseif index == "2" then
        local enchant_slot_gb = GET_CHILD_RECURSIVELY(frame,"enchant_slot_gb_1")
        enchant_slot_gb:ShowWindow(0)
        GET_CHILD_RECURSIVELY(frame,"mat_name"..index):ShowWindow(1)
    end
end

function SKILL_ENCHANT_ITEM_DROP_SCROLL(parent,self,argStr, argNum)
    local frame =  parent:GetTopParentFrame();
    local liftIcon = ui.GetLiftIcon()
	local FromFrame = liftIcon:GetTopParentFrame()

    if FromFrame:GetName() == 'inventory' then
        local iconInfo = liftIcon:GetInfo()
		SKILL_ENCHANT_SET_SCROLL(frame, iconInfo:GetIESID(),argNum)
	end
end

function SKILL_ENCHANT_SET_SCROLL(frame,itemID,argNum)
    if ui.CheckHoldedUI() == true then return end
    local inv_item = session.GetInvItemByGuid(itemID)
	if inv_item == nil then return end
    local item_obj = GetIES(inv_item:GetObject())
    local item_cls = GetClassByType('Item', inv_item.type)
	
    if item_obj == nil or item_cls == nil then return end

    local invframe = ui.GetFrame('inventory')
	if true == inv_item.isLockState or true == IS_TEMP_LOCK(invframe, inv_item) then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
    end
    local mat_slot = GET_CHILD_RECURSIVELY(frame,"mat_slot"..tostring(argNum))
    local mat_name = GET_CHILD_RECURSIVELY(frame,"mat_name"..tostring(argNum))
    mat_slot:SetUserValue("SET_ID",itemID)
    
    if shared_skill_enchant.is_common_skill_scroll(item_obj) == false then
        ui.SysMsg(ClMsg('IsNotEnchantSkillScroll'))
        return 
    end
    
    -- TARGET SLOT SET "START"--
    SET_SLOT_ITEM(mat_slot, inv_item)
    mat_name:SetTextByKey("value",item_obj.Name)
    SKILL_ENCHANT_MAKE_REQUIRE_MAT_SET(frame,item_obj)
end

function SKILL_ENCHANT_MAKE_REQUIRE_MAT_SET(frame,item_obj,itemID)
    local frame     = frame:GetTopParentFrame()
    local bottom_bg = GET_CHILD_RECURSIVELY(frame,"bottom_Bg")
    bottom_bg:RemoveAllChild();
    local height = 72
    local index = 1
    local aObj = GetMyAccountObj()
    local mat_table = shared_skill_enchant.get_cost(item_obj,item_obj.Name)
    for k ,v in pairs(mat_table) do
        -- k Mat Name / v cnt 
        local ctrlSet = bottom_bg:CreateOrGetControlSet("mat_required_set", "ENCHANT_MAT_"..index, ui.CENTER_HORZ, ui.TOP,0,height*(index-1),0,0);
        local mat_cls = nil	
        local curr_my_cnt = 0;
        if IS_STRING_COIN(k) == true then
            mat_cls = GetClass('Item', 'dummy_' .. k)
            curr_my_cnt = TryGetProp(aObj,k,0)
        else
            mat_cls = GetClassByNameFromList(item_list,k)
            curr_my_cnt = GET_INV_ITEM_COUNT_BY_PROPERTY({
                { Name = 'ClassName', Value = k}
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

-- function SKILL_ENCHANT_ADD_MAT()
--     local frame = ui.GetFrame('skill_enchant')
--     if frame == nil then return end
    
-- 	local invItemList = session.GetInvItemList();
--     local bottom_bg = GET_CHILD_RECURSIVELY(frame,"bottom_Bg")
--     local cnt = bottom_bg:GetChildCount();
--     local set_ready_count = 0;
--     for i = 1, cnt-1 do
--         local ctrlSet = bottom_bg:GetChildByIndex(i)
        
--         local mat_slot =  GET_CHILD_RECURSIVELY(ctrlSet,"mat_slot")
--         local plus = GET_CHILD_RECURSIVELY(ctrlSet,"plus")
--         plus:ShowWindow(1)
--         local mat_name =  GET_CHILD_RECURSIVELY(ctrlSet,"mat_name")
--         local cnt_in_my_bag = GET_CHILD_RECURSIVELY(ctrlSet,"cnt_in_my_bag")
        
--         local val_1 = GET_NOT_COMMAED_NUMBER(mat_name:GetTextByKey('value2'))
--         local val_2 = GET_NOT_COMMAED_NUMBER(cnt_in_my_bag:GetTextByKey('value'))
--         val_1 = tonumber(val_1)
--         val_2 = tonumber(val_2)
--         if val_1 < val_2 then 
--             local icon = mat_slot:GetIcon()
--             icon:SetColorTone('FFFFFFFF')
--             plus:ShowWindow(0);
--             set_ready_count = set_ready_count + 1; 
--         else
--             local msg = string.format("<%s> %s",mat_name:GetTextByKey('value'), ClMsg("NotEnoughMaterial"))
--             ui.SysMsg(msg)
--         end
--     end


--     if set_ready_count == (cnt-1) then
--         frame:SetUserValue("IS_READY","TRUE")
--         GET_CHILD_RECURSIVELY(frame,"do_enchant"):SetEnable(1)
--     else
--         frame:SetUserValue("IS_READY","FALSE")
--     end
-- end



function SKILL_ENCHANT_DO_ENCHANT(parent,self)
    local frame =  parent:GetTopParentFrame();
    local isReady = frame:GetUserValue("IS_READY")
    session.ResetItemList()
        
    if isReady=="TRUE" then
        local slot = GET_CHILD_RECURSIVELY(frame,"slot")
        local guid = slot:GetUserValue("SET_ID")
        if guid~="None" then 
            session.AddItemID(guid, 1)
        else
            return 
        end
        
        for i = 1,MAX_SLOT_CNT do
            local mat_slot = GET_CHILD_RECURSIVELY(frame,"mat_slot"..tostring(i))
            guid = mat_slot:GetUserValue("SET_ID")
            if guid~="None" then 
                session.AddItemID(guid, 1)
                _SKILL_ENCHANT_DO_ENCHANT(i)
            end
        end
    end 
end

function _SKILL_ENCHANT_DO_ENCHANT(index)
    local result_list = session.GetItemIDList()
    local argStrList = NewStringList();
    argStrList:Add(tostring(index))
    ui.SetHoldUI(true)
    item.DialogTransaction("ENCHANT_COMMON_SKILL", result_list, '', argStrList);
end
