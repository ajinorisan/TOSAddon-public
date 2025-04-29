function COMMON_ACC_UPGRADE_ON_INIT(addon, frame)
    addon:RegisterMsg('COMMON_ACC_UPGRADE_RESULT', '_COMMON_ACC_UPGRADE_RESULT');
end


function COMMON_ACC_UPGRADE_OPEN(frame)
    ui.OpenFrame('inventory')
    INVENTORY_SET_CUSTOM_RBTNDOWN('COMMON_ACC_UPGRADE_INV_RBTN')
    REFRESH_COMMON_ACC_UPGRADE()
end

function COMMON_ACC_UPGRADE_CLOSE(frame)
    ui.CloseFrame('inventory')
    INVENTORY_SET_CUSTOM_RBTNDOWN("None")

end

function COMMON_ACC_UPGRADE_INV_RBTN(item_obj,slot)
    local frame = ui.GetFrame('common_acc_upgrade')
    if frame == nil then return end
    REFRESH_COMMON_ACC_UPGRADE()

    local icon      = slot:GetIcon()
    local iconInfo  = icon:GetInfo()
    local Ies_Id    = iconInfo:GetIESID()
    COMMON_ACC_UPGRADE_SET_TARGET_ITEM(frame, Ies_Id)
end


function COMMON_ACC_UPGRADE_SET_TARGET_ITEM(frame,itemID)
    if ui.CheckHoldedUI() == true then return end
    local inv_item = session.GetInvItemByGuid(itemID)
    if inv_item == nil then return end
    local item_obj = GetIES(inv_item:GetObject())
    local item_cls = GetClassByType('Item', inv_item.type)
	if item_obj == nil or item_cls == nil then return end

    local res,clsmsg = shared_upgrade_acc.is_valid_item(item_obj)
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
    COMMON_ACC_UPGRADE_MAT_SET(frame, item_obj)


end

function COMMON_ACC_UPGRADE_MAT_NUM_SET(frame, item_obj)
    local frame     = frame:GetTopParentFrame()
    local bottom_bg = GET_CHILD_RECURSIVELY(frame,"bottom_Bg")
    bottom_bg:RemoveAllChild();

    local height = 72
    local index = 1
    local aObj = GetMyAccountObj()
    
    local mat_list = shared_upgrade_acc.get_cost(item_obj)

    for k,v in pairs(mat_list) do
        local ctrlSet = bottom_bg:CreateOrGetControlSet("mat_required_set", "ENCHANT_MAT_"..index, ui.CENTER_HORZ, ui.TOP,0,height*(index-1) + 25,0,0);
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
        local plus =GET_CHILD_RECURSIVELY(ctrlSet,"plus")
        
        mat_slot:SetEventScriptArgString(ui.LBUTTONUP, mat_cls.ClassName);
        plus:ShowWindow(0)
        local mat_name = GET_CHILD_RECURSIVELY(ctrlSet,"mat_name")
        
        local icon = imcSlot:SetImage(mat_slot,TryGetProp(mat_cls,"Icon","None"))
        mat_name:SetTextByKey("value",TryGetProp(mat_cls,"Name","None"))
        mat_name:SetTextByKey("value2",GET_COMMAED_STRING(tostring(v)))
        index = index +1;
        
        --내 가방에 요구량
        local curr_my_cnt_text = GET_CHILD_RECURSIVELY(ctrlSet,"cnt_in_my_bag")
        curr_my_cnt_text:SetTextByKey("value",GET_COMMAED_STRING(curr_my_cnt))
    end

end

function COMMON_ACC_UPGRADE_MAT_SET(frame,item_obj)

    local frame     = frame:GetTopParentFrame()
    local bottom_bg = GET_CHILD_RECURSIVELY(frame,"bottom_Bg")
    bottom_bg:RemoveAllChild();

    local height = 72
    local index = 1
    local aObj = GetMyAccountObj()
    
    local mat_list = shared_upgrade_acc.get_cost(item_obj)
    for k,v in pairs(mat_list) do
        local ctrlSet = bottom_bg:CreateOrGetControlSet("mat_required_set", "ENCHANT_MAT_"..index, ui.CENTER_HORZ, ui.TOP,0,height*(index-1) + 25,0,0);
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

    local rank = TryGetProp(item_obj, "UpgradeRank", 0)
    COMMON_ACC_UPGRADE_OPTION_SET_UP(frame, rank, 0)
end

function COMMON_ACC_UPGRADE_DROP(parent, ctrl, argStr, argNum)
    local frame = ui.GetFrame('common_acc_upgrade')
    if frame == nil then return end
    REFRESH_COMMON_ACC_UPGRADE()
    local liftIcon = ui.GetLiftIcon()
	local FromFrame = liftIcon:GetTopParentFrame()


	if FromFrame:GetName() == 'inventory' then
        local iconInfo = liftIcon:GetInfo()
        local guid = iconInfo:GetIESID();
        local invItem = session.GetInvItemByGuid(guid)
        local item_obj = GetIES(invItem:GetObject())

        local res,clsmsg = shared_upgrade_acc.is_valid_item(item_obj)
        if res == false then ui.SysMsg(ClMsg(clsmsg)); return end
    
        local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
        SET_SLOT_ITEM(slot, invItem)
        slot:SetUserValue("SET_ID",guid)

		COMMON_ACC_UPGRADE_MAT_SET(frame, item_obj)
	end

end

function COMMON_ACC_UPGRADE_PROGRESS(parent,ctrl,argStr,argNum)
    local frame = parent:GetTopParentFrame();
    local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
    local guid = slot:GetUserValue("SET_ID")
    pc.ReqExecuteTx_Item('UPGRADE_ACC', guid)

    local inv_item = session.GetInvItemByGuid(guid)
    if inv_item == nil then return end
    local item_obj = GetIES(inv_item:GetObject())

    COMMON_ACC_UPGRADE_OPTION_SET_UP(frame, TryGetProp(item_obj, 'UpgradeRank', 0), 0)  
    COMMON_ACC_UPGRADE_MAT_NUM_SET(frame,item_obj)
    --이펙트 추가
end


--@ REFRESH ALL THIS UI
function REFRESH_COMMON_ACC_UPGRADE()
    if ui.CheckHoldedUI() == true then return end
    local frame = ui.GetFrame('common_acc_upgrade')

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
    
    -- for i=1,MAX_SLOT_CNT do
    --     local enchant_slot_gb = GET_CHILD_RECURSIVELY(frame,"enchant_slot_gb_"..tostring(i))
    --     local mat_slot = GET_CHILD_RECURSIVELY(enchant_slot_gb,"mat_slot"..tostring(i))
    --     local mat_name = GET_CHILD_RECURSIVELY(enchant_slot_gb,"mat_name"..tostring(i))
    --     local shadow = GET_CHILD_RECURSIVELY(enchant_slot_gb,"shadow"..tostring(i))
    --     mat_slot:ClearIcon()
    --     mat_name:SetTextByKey("value","")
    --     shadow:ShowWindow(1)
    -- end
    
    -- GET_CHILD_RECURSIVELY(frame,'selectBtn_Left')    :ShowWindow(0)
    -- GET_CHILD_RECURSIVELY(frame,'selectBtn_Right')   :ShowWindow(0)
    

    -- 2. RESET ITEM SLOT SECTION "END" --

    -- 3. RESET BOTTOM MAT SECTION "START"--
    local bottom_Bg = GET_CHILD_RECURSIVELY(frame, 'bottom_Bg')
    bottom_Bg:RemoveAllChild();
    -- RESET BOTTOM SECTION "END"--

    -- 4. DISABLE DO ENCHANT BUTTON START -- 
    local do_enchant = GET_CHILD_RECURSIVELY(frame, 'do_enchant')
    do_enchant:SetEnable(0)

    COMMON_ACC_UPGRADE_OPTION_CLEAR(frame)
    -- DISABLE DO ENCHANT BUTTON END -- 
end
--갱신 추가
--drop추가
--rbtn제거 추가

function COMMON_ACC_UPGRADE_OPTION_CLEAR(frame)
    local option_result = GET_CHILD_RECURSIVELY(frame,"option_result")
    local before_txt = GET_CHILD_RECURSIVELY(option_result,"before_txt")
    local after_txt = GET_CHILD_RECURSIVELY(option_result,"after_txt")
    local slot = GET_CHILD_RECURSIVELY(frame,"slot")

    before_txt:SetTextByKey("value",nil)
    before_txt:SetTextByKey("value2",nil)

    after_txt:SetTextByKey("value",nil)
    after_txt:SetTextByKey("value2",nil)

end

-------set option info
function COMMON_ACC_UPGRADE_OPTION_SET_UP(frame, before, after)    
    local option_result = GET_CHILD_RECURSIVELY(frame,"option_result")
    local before_txt = GET_CHILD_RECURSIVELY(option_result,"before_txt")
    local after_txt = GET_CHILD_RECURSIVELY(option_result,"after_txt")
    local slot = GET_CHILD_RECURSIVELY(frame,"slot")
    local icon      = slot:GetIcon()
    local iconInfo  = icon:GetInfo()
    local Ies_Id    = iconInfo:GetIESID()

    local inv_item = session.GetInvItemByGuid(Ies_Id)
    if inv_item == nil then return end
    local item_obj = GetIES(inv_item:GetObject())

    local cur_rank = TryGetProp(item_obj,"UpgradeRank",0)
    local CustomOptDescFunc = TryGetProp(item_obj,"CustomOptDescFunc","None");
    
    if after ~= nil and after ~= 0 then
        cur_rank = after;
    end
    
    local before_val1, before_val2 = shared_upgrade_acc.get_value(item_obj,before);
    local after_val1, after_val2 = shared_upgrade_acc.get_value(item_obj,cur_rank);
    
    CustomOptDescFunc = _G[CustomOptDescFunc]
    local msg1, option1_name = CustomOptDescFunc(item_obj)

    local option1_name1 = "";
    local option1_name2 = "";
    local option2_name1 = "";
    local option2_name2 = "";
        
    if GetClass('upgrade_equip_item', TryGetProp(item_obj, 'ClassName', 'None')) ~= nil then
        option1_name = ClMsg('ALLSTAT')
        -- option1_name2 = ClMsg('ALLSTAT')
        before_val1 = shared_upgrade_equip.get_value(item_obj, before)[1][2]        
        after_val1 = shared_upgrade_equip.get_value(item_obj, cur_rank)[1][2]
    end

    option1_name1 = string.format("%s : +%s",option1_name, before_val1); 
    option1_name2 = string.format("%s : +%s",option1_name, after_val1);
    if option1_name ~= ClMsg("EP16_EFFECT_NAME02") then
        option2_name1 = string.format("%s : +%s",ClMsg("EP16_EFFECT_NAME05"), before_val2);
        option2_name2 = string.format("%s : +%s",ClMsg("EP16_EFFECT_NAME05"), after_val2);

    end

    before_txt:SetTextByKey("value",option1_name1)
    before_txt:SetTextByKey("value2",option2_name1)

    after_txt:SetTextByKey("value",option1_name2)
    after_txt:SetTextByKey("value2",option2_name2)

    if GetClass('upgrade_equip_item', TryGetProp(item_obj, 'ClassName', 'None')) ~= nil then
        before_txt:SetTextByKey("value2",nil)
        after_txt:SetTextByKey("value2",nil)
    end
end

local function _GET_EFFECT_UI_MARGIN()
	local frame = ui.GetFrame('common_acc_upgrade')
	local effect_frame = ui.GetFrame('result_effect_ui')
	local left_margin = math.floor((frame:GetWidth() - effect_frame:GetWidth()) * 0.5)
	local top_margin = math.floor((frame:GetHeight() - effect_frame:GetHeight()) * 0.5)
	local margin = frame:GetMargin()
    local screenWidth 	= ui.GetClientInitialWidth() * 0.5 - effect_frame:GetWidth() * 0.5;

	left_margin = screenWidth;
	top_margin = margin.top

	return left_margin, top_margin
end


function _COMMON_ACC_UPGRADE_RESULT(frame, msg, argStr, argNum)    
    local left, top = _GET_EFFECT_UI_MARGIN()
    local res_scp = ""

    if argStr == 'SUCCESS' then
        local parent = frame:GetTopParentFrame()
        local slot = GET_CHILD_RECURSIVELY(parent, 'slot')
        local icon      = slot:GetIcon()
        local iconimg = "None"
        if icon ~= nil then
            local iconInfo  = icon:GetInfo()
            iconimg = iconInfo:GetImageName();
        end
        COMMON_ACC_UPGRADE_OPTION_SET_UP(frame, argNum)
        res_scp = string.format('RESULT_EFFECT_UI_RUN_SUCCESS(\'%s\', \'%s\', \'%d\', \'%d\', %d)', '_END_REFORGE_REINFORCE_EXEC', iconimg, left, top, 1)
    elseif argStr == 'FAIL' then
        res_scp = string.format('RESULT_EFFECT_UI_RUN_FAILED(\'%s\', \'%d\', \'%d\')', '_END_REFORGE_REINFORCE_EXEC', left, top)
    end

    if res_scp ~= "" or res_scp ~= nil then
        ReserveScript(res_scp, 0)    
    end

end

