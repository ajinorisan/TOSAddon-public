function HIDDENABILITY_DECOMPOSE_ON_INIT(addon, frame)
    addon:RegisterMsg('HIDDENABILITY_DECOMPOSE_RESULT', 'HIDDENABILITY_DECOMPOSE_SET_RESULT');
end

function HIDDENABILITY_DECOMPOSE_UI_OPEN()
    ui.OpenFrame("hiddenability_decompose")
end

local function get_material_class_name(item)
    local itemobj = GetIES(item:GetObject());
    return TryGetProp(itemobj, 'ClassName', 'None')
end

function HIDDENABILITY_DECOMPOSE_OPEN(frame)
    HIDDENABILITY_DECOMPOSE_RESET_MATERIAL(frame);
    HIDDENABILITY_DECOMPOSE_RESET_RESULT(frame);

    INVENTORY_SET_CUSTOM_RBTNDOWN("HIDDENABILITY_DECOMPOSE_ITEM_RBTNDOWN");

	ui.OpenFrame("inventory");	
end

function HIDDENABILITY_DECOMPOSE_CLOSE(frame)
    ui.CloseFrame("hiddenability_decompose");
    ui.CloseFrame("inventory");	

    frame:SetUserValue("MATERIAL_GUID", "None");
    frame:SetUserValue("material_class_name", "None")

    INVENTORY_SET_CUSTOM_RBTNDOWN("None");
end

function HIDDENABILITY_DECOMPOSE_ITEM_RBTNDOWN(itemobj,slot)
    local icon = slot:GetIcon()
	local iconInfo = icon:GetInfo();
	local guid = iconInfo:GetIESID();
    local invitem = GET_ITEM_BY_GUID(guid);
    if invitem == nil then
        return;
    end
    
    local frame = ui.GetFrame("hiddenability_decompose")
    local ok_btn = GET_CHILD_RECURSIVELY(frame, "ok_btn");
    if ok_btn:IsVisible() ==  1 then
        return;
    end

    if HIDDENABILITY_DECOMPOSE_MATERIAL_ENABLE(frame, invitem) == true then
	    frame:SetUserValue("MATERIAL_GUID", guid);
        frame:SetUserValue("material_class_name", get_material_class_name(invitem))
		HIDDENABILITY_DECOMPOSE_SET_MATERIAL(frame, invitem);
    end
end

function HIDDENABILITY_DECOMPOSE_ITEM_DROP(frame, ctrl)
    if ui.CheckHoldedUI() == true then
		return;
    end

	local liftIcon = ui.GetLiftIcon();
	local FromFrame = liftIcon:GetTopParentFrame();
    frame = frame:GetTopParentFrame();
    
    if FromFrame:GetName() == 'inventory' then
		local iconInfo = liftIcon:GetInfo();
		local guid = iconInfo:GetIESID();
		local invitem = session.GetInvItemByGuid(guid)
        if invitem == nil then
            return;
        end

        if HIDDENABILITY_DECOMPOSE_MATERIAL_ENABLE(frame, invitem) == false then
            return;
        end

	    frame:SetUserValue("MATERIAL_GUID", guid);
        frame:SetUserValue("material_class_name", get_material_class_name(invitem))
		HIDDENABILITY_DECOMPOSE_SET_MATERIAL(frame, invitem);
    end
end

function HIDDENABILITY_DECOMPOSE_ITEM_POP(frame, ctrl)
    if ui.CheckHoldedUI() == true then
        return;
    end
    
    HIDDENABILITY_DECOMPOSE_RESET_MATERIAL(frame);
end

function HIDDENABILITY_DECOMPOSE_MATERIAL_ENABLE(frame, invitem)
    if invitem.isLockState == true then
        ui.SysMsg(ClMsg("MaterialItemIsLock"));
        return false;
    end
    
    local itemobj = GetIES(invitem:GetObject());
    if IS_HIDDENABILITY_DECOMPOSE_MATERIAL(itemobj) == false and IS_HIDDENABILITY_DECOMPOSE_BOOK_MATERIAL(itemobj) == false then        
        ui.SysMsg(ClMsg("NotEnoughTarget"));
        return false;
    end

    return true;
end

function HIDDENABILITY_DECOMPOSE_SET_MATERIAL(frame, invitem)
    local itemobj = GetIES(invitem:GetObject());
    
    local text = GET_CHILD_RECURSIVELY(frame, "mat_text");
    text:EnableTextOmitByWidth(true)
    text:ShowWindow(1);
    text:SetTextByKey("value", "");
    text:SetTextByKey("value", itemobj.Name);
    text:SetTextTooltip(itemobj.Name)
    
    local matslot = GET_CHILD_RECURSIVELY(frame, "matslot");
    HIDDENABILITY_DECOMPOSE_SET_SLOT(matslot, itemobj);
end

function HIDDENABILITY_DECOMPOSE_ONCE_COUNT_RESET(frame)
    local edit = GET_CHILD_RECURSIVELY(frame, "once_edit");
    edit:SetText("1");
end

function HIDDENABILITY_DECOMPOSE_ONCE_COUNT_TYPING(parent, ctrl)
    local frame = parent:GetTopParentFrame()
    local mat_guid = frame:GetUserValue("MATERIAL_GUID");
    if mat_guid == 'None' then return end

    local mat_item = session.GetInvItemByGuid(mat_guid);
    if mat_item == nil then return end

    if ctrl:GetText() == "" then
        return;
    end

    local curCnt = tonumber(ctrl:GetText());
    if curCnt > mat_item.count then
        curCnt = mat_item.count
    end

    if curCnt < 1 then
        curCnt = 1;
    end

    ctrl:SetText(curCnt);
end

function HIDDENABILITY_DECOMPOSE_ONCE_COUNT_UP_CLICK(parent, ctrl)
    local frame = parent:GetTopParentFrame()
    local mat_guid = frame:GetUserValue("MATERIAL_GUID");
    if mat_guid == 'None' then return end

    local mat_item = session.GetInvItemByGuid(mat_guid);
    if mat_item == nil then return end

    local edit = GET_CHILD(parent, "once_edit");
    local curCnt = tonumber(edit:GetText());
    local upCnt = curCnt + 1;

    if upCnt > mat_item.count then
        upCnt = mat_item.count
    end

    edit:SetText(upCnt);
end

function HIDDENABILITY_DECOMPOSE_ONCE_COUNT_DOWN_CLICK(parent, ctrl)
    local edit = GET_CHILD(parent, "once_edit");

    local curCnt = tonumber(edit:GetText());
    local downCnt = curCnt - 1;
    if downCnt < 1 then
        downCnt = 1;
    end

    edit:SetText(downCnt);
end

-- 분해 완료 후 결과 
function HIDDENABILITY_DECOMPOSE_SET_RESULT(frame, msg, resultstr)
    local frame = ui.GetFrame("hiddenability_decompose");
    imcSound.PlaySoundEvent(frame:GetUserConfig("DECOMPOSE_START_SOUND"));
    imcSound.PlaySoundEvent(frame:GetUserConfig("DECOMPOSE_RESULT_SOUND"));
    
    local itemclassnamelist = StringSplit(resultstr, "/");
    local resultcnt = #itemclassnamelist;

    local result_gb = GET_CHILD_RECURSIVELY(frame, "result_gb")
    result_gb:RemoveAllChild()
    for i = 1, resultcnt do
        local ctrlset = result_gb:CreateOrGetControlSet('hiddenabil_decompose_result', 'RESULT_ITEM_' .. i, 0, 150 * (i - 1))
        local slot = GET_CHILD(ctrlset, "slot")
        local slottext = GET_CHILD(slot, "slot_text")
        local token = StringSplit(itemclassnamelist[i], ';')
        local class_name = token[1]            -- 획득한 아이템 class_name
        local give_count = tonumber(token[2])  -- 획득한 아이템 개수
        local itemobj = GetClass("Item", class_name)
        HIDDENABILITY_DECOMPOSE_SET_SLOT(slot, itemobj)
    
        slottext:SetTextByKey("value", give_count)
        slottext:ShowWindow(1)
    end

    local text_bg = GET_CHILD_RECURSIVELY(frame, "text_bg");
    text_bg:ShowWindow(1);
    
    local ok_btn = GET_CHILD_RECURSIVELY(frame, "ok_btn");
    ok_btn:ShowWindow(1);
    
    local matslot = GET_CHILD_RECURSIVELY(frame, "matslot");
    matslot:EnableDrop(0);
    matslot:EnablePop(0);
	matslot:EnableDrag(0);
end

function HIDDENABILITY_DECOMPOSE_SET_SLOT(slot, itemcls)
    local icon = slot:GetIcon();
    if icon == nil then
		icon = CreateIcon(slot);
    end
    
    itemicon = TryGetProp(itemcls, "Icon", "None");

    if itemicon ~= "None" then
        icon:SetImage(itemicon);
        SET_ITEM_TOOLTIP_BY_TYPE(icon, itemcls.ClassID);
    end	
end

-- 확인 버튼 클릭
function HIDDENABILITY_DECOMPOST_OK_CLLICK(frame, ctrl)
    if ui.CheckHoldedUI() == true then
        return;
    end
    
    local class_name = frame:GetUserValue("material_class_name")
    if class_name ~= 'HiddenAbility_Piece' then
        HIDDENABILITY_DECOMPOSE_RESET_MATERIAL(frame);
    end
    HIDDENABILITY_DECOMPOSE_RESET_RESULT(frame);
end

-- 분해하기 버튼 클릭
function HIDDENABILITY_DECOMPOST_BUTTON_CLLICK(frame, ctrl)
    if ui.CheckHoldedUI() == true then
        return;
    end
    
    local guid = frame:GetUserValue("MATERIAL_GUID");
    if guid == "None" then
        ui.SysMsg(ClMsg("Arts_Please_Decompose_material"));
        return;        
    end

    local invitem = session.GetInvItemByGuid(guid)
    if invitem.isLockState == true then
        ui.SysMsg(ClMsg("MaterialItemIsLock"));
        return;
    end

    local edit = GET_CHILD_RECURSIVELY(frame, "once_edit");
    local decompose_cnt = tonumber(edit:GetText());
    if decompose_cnt > invitem.count then
        ui.SysMsg(ClMsg('NotEnoughRecipe'));
        return;
    end

    -- 분해하기 로직 추가
    session.ResetItemList();
    session.AddItemID(guid, decompose_cnt);
	local resultlist = session.GetItemIDList()
    item.DialogTransaction("HIDDENABILITY_DECOMPOSE", resultlist)

	ui.SetHoldUI(true);
    ReserveScript("HIDDENABILITY_DECOMPOSE_BUTTON_UNFREEZE()", 2);    
end

function HIDDENABILITY_DECOMPOSE_BUTTON_UNFREEZE()
    ui.SetHoldUI(false);
 end 

function HIDDENABILITY_DECOMPOSE_RESET_MATERIAL(frame)
    frame = frame:GetTopParentFrame();
    frame:SetUserValue("MATERIAL_GUID", "None");
    frame:SetUserValue("material_class_name", 'None')
    local matslot = GET_CHILD_RECURSIVELY(frame, "matslot");
    matslot:ClearIcon();

    local mat_text = GET_CHILD_RECURSIVELY(frame, "mat_text");
    mat_text:ShowWindow(0);
end

function HIDDENABILITY_DECOMPOSE_RESET_RESULT(frame)
    local result_gb = GET_CHILD_RECURSIVELY(frame, "result_gb")
    result_gb:RemoveAllChild()
    
    local text_bg = GET_CHILD_RECURSIVELY(frame, "text_bg");
    text_bg:ShowWindow(0);
    
    local ok_btn = GET_CHILD_RECURSIVELY(frame, "ok_btn");
    ok_btn:ShowWindow(0);
    
    local matslot = GET_CHILD_RECURSIVELY(frame, "matslot");
    matslot:EnableDrop(1);
    matslot:EnablePop(1);
    matslot:EnableDrag(1);
    
    HIDDENABILITY_DECOMPOSE_ONCE_COUNT_RESET(frame);
end