local SkinList = {
    [32] = "alchemist_ui2_slot;alchemist_ui3_slot",
    [27] = "alchemist_ui4_slot;alchemist_ui5_slot"
}
function TOGGLE_CUPOLE_ADDON_FRAME()
    local frame = ui.GetFrame("cupole_addon")
    frame:ShowWindowToggle();
    local atkBG = GET_CHILD(frame,"atkBG")
    local defBG = GET_CHILD(frame,"defBG")
    atkBG:ShowWindow(0)
    defBG:ShowWindow(0)
    local index = GET_GLOBAL_SELECT_CUPOLE();
    
    CUPOLE_REGISTE_ITEM_PROP(frame, index)
    SET_PORTION_TOOLTIP(frame, index)
end


function CUPOLE_ADDON_ON_INIT(addon,frame)
    addon:RegisterMsg('KUPOLE_USE_ITEM_RESET', 'RESET_CUPOLE_ITEM_RESET');
end

function RESET_CUPOLE_ITEM_RESET(frame, msg, argStr, argNum)
    CUPOLE_REGISTE_ITEM(frame, nil, "", 0)
    CUPOLE_REGISTE_ITEM(frame, nil, "", 1)
end

--큐폴 선택 시 해당 큐폴이 사용할 수 있는 포션의 종류들을 그려주는 함수
function CUPOLE_REGISTE_ITEM(frame, ctrl, argStr, argNum)
    local parent = frame:GetTopParentFrame();
    local atkBG = GET_CHILD(parent,"atkBG")
    local defBG = GET_CHILD(parent,"defBG")
    local destBG = nil;
    local tag = "PotionName"
    local prop = "ClassName"

    local index = GET_GLOBAL_SELECT_CUPOLE();

    local potioncls = GET_CUPOLE_AUTO_POTION_CLS(index + 1)

    if argNum == 1 then
        defBG:ShowWindowToggle()
        destBG = defBG;
        tag = tag.."2"
    elseif argNum == 0 then
        atkBG:ShowWindowToggle()
        destBG = atkBG;
        tag = tag.."1"
    end

    local PotionNameList = TryGetProp(potioncls, tag, "None")
    local list = StringSplit(PotionNameList, ';')
    SET_CUPOLE_REGISTE_ITEM_LIST(destBG, list, prop)
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
        local TargetItemCount = session.GetInvItemCountByType(item1.ClassID)
        if TargetItemCount > 0 then
            imcSlot:SetImage(atkslot, TryGetProp(item1, "Icon", "None"))
        else
            atkslot:ClearIcon();
        end
    else
        atkslot:ClearIcon();
    end
    if item2 ~= nil then
        local TargetItemCount = session.GetInvItemCountByType(item2.ClassID)
        if TargetItemCount > 0 then
            imcSlot:SetImage(defslot, TryGetProp(item2, "Icon", "None"))
        else
            defslot:ClearIcon();
        end
    else
        defslot:ClearIcon();
    end

end

--ui에 아이템들을 등록시켜준다.
function SET_CUPOLE_REGISTE_ITEM_LIST(frame, tag, Prop)
    -- 슬롯 최대 개수를 2개로 제한
    local max_slots = 2
    local filled_slots = 0

    -- tag 리스트를 순회하며 아이템을 찾고 슬롯에 추가
    for i = 1, #tag do
        -- 아이템이 존재하는지 확인
        local curr_my_cnt, itemlist = GET_INV_ITEM_COUNT_BY_PROPERTY({
            { Name = Prop, Value = tag[i] }
        }, false)
        if curr_my_cnt > 0 then
            local mat_item_info = itemlist[1]
            local mat_cls = GetIES(mat_item_info:GetObject())
            -- 동일한 아이템이 슬롯에 없을 때만 추가
            local slot = frame:GetChildByIndex(filled_slots + 2)
            slot = AUTO_CAST(slot)
            if slot and slot:GetClassString() == "ui::CSlot" then
                slot:ClearIcon()
                slot:SetUserValue("mat_guid", "None")
                slot:SetUserValue("itemcount", 0)
                if FIND_SAME_ITEM_IN_SLOT(frame, mat_cls.ClassName) == false then
                    local icon = imcSlot:SetImage(slot, TryGetProp(mat_cls, "Icon", "None"))
                    local iconinfo = icon:GetInfo()
                    local mat_guid = mat_item_info:GetIESID()
                    slot:SetUserValue("mat_guid", mat_guid)
                    slot:SetUserValue("itemcount", curr_my_cnt)
                    icon:SetTooltipOverlap(1)
                    SET_ITEM_TOOLTIP_BY_NAME(icon, mat_cls.ClassName)
    
                    -- 슬롯을 채웠으므로 filled_slots를 증가
                    filled_slots = filled_slots + 1
    
                    -- 슬롯이 최대 개수에 도달하면 종료
                    if filled_slots >= max_slots then
                        break
                    end
                end
            end
        end
    end

    -- 채우지 못한 나머지 슬롯을 초기화
    for i = filled_slots + 1, max_slots do
        local slot = frame:GetChildByIndex(i + 1)
        slot = AUTO_CAST(slot)
        if slot and slot:GetClassString() == "ui::CSlot" then
            slot:ClearIcon()
            slot:SetUserValue("mat_guid", "None")
            slot:SetUserValue("itemcount", 0)
        end
    end
end

function SET_PORTION_TOOLTIP(frame, index)
    local atkslot= GET_CHILD_RECURSIVELY(frame, "atkslot")
    local defslot= GET_CHILD_RECURSIVELY(frame, "defslot")

    SET_TOOLTIP_TEXT(atkslot, index, "PotionName1")
    SET_TOOLTIP_TEXT(defslot, index, "PotionName2")
end

function SET_TOOLTIP_TEXT(ctrl, index, tag)
    local potioncls = GET_CUPOLE_AUTO_POTION_CLS(index + 1)
    local list = TryGetProp(potioncls, tag, "None")
    local tokens = StringSplit(list, ';')
    local text = ""
    for i = 1, #tokens do
        local ItemClassName = tokens[i];
        local cls = GetClass("Item", ItemClassName);
        if cls then
            local Name = cls.Name;
            text = text.." - "..Name.."{nl}";
        end
    end
    local tooltip = ScpArgMsg('Kupole_Portion_Tooltip{LIST}',"LIST",  text);

    if ctrl then
        ctrl:SetTextTooltip(tooltip);
    end
end

--아이템 눌렀을떄 동작(등록한다)
function PRESS_CUPOLE_ITEM(frame, ctrl, argStr, argNum)
    local mat_guid = ctrl:GetUserValue("mat_guid");
    local curr_my_cnt = ctrl:GetUserIValue("itemcount");
    local parent = frame:GetTopParentFrame();
    local parentgb = frame:GetParent()
	session.ResetItemList()
    
	if mat_guid == '0' then return end
	if mat_guid == 'None' then return end
    if curr_my_cnt == 0 then return end

	local mat_item = session.GetInvItemByGuid(mat_guid)
	if mat_item == nil then return end
    local index = GET_GLOBAL_SELECT_CUPOLE();

    local destslot = nil;
    if argNum == 0 then 
        local atkslot = GET_CHILD_RECURSIVELY(parent, "atkslot")
        destslot = atkslot;
    elseif argNum== 1 then
        local defslot = GET_CHILD_RECURSIVELY(parent, "defslot")
        destslot = defslot;
    end
    local mat_cls = GetIES(mat_item:GetObject())
    local icon = imcSlot:SetImage(destslot,TryGetProp(mat_cls,"Icon","None"))
    local mat_guid = mat_item:GetIESID();

    icon:SetTooltipOverlap(1)   
    destslot:SetUserValue("mat_guid", mat_guid);
    SET_ITEM_TOOLTIP_BY_NAME(icon, mat_cls.ClassName)

	if curr_my_cnt ~= nil and curr_my_cnt > 0 then
        SCP_CUPOLE_ADDON_REGISTE_ITEM(mat_cls, index, argNum)
    end
    parentgb:ShowWindow(0);
end

--우클릭 시의 함수
function CUPOLE_CLEAR_REGISTE_ITEM(frame, ctrl, argStr, argNum)
    ctrl:ClearIcon();
    ctrl:SetUserValue("mat_guid", "None");
    local index = GET_GLOBAL_SELECT_CUPOLE();

    local types = index..'\t'..argNum;
    pc.ReqExecuteTx_Item("CUPOLE_ITEM_ADDON", 0, types)
end


--아이템 선택 시 tx 
function SCP_CUPOLE_ADDON_REGISTE_ITEM(item, cupoleindex, propnum)
    local clsID = TryGetProp(item, "ClassID", "None")
    local types = cupoleindex..'\t'..propnum;
    pc.ReqExecuteTx_Item("CUPOLE_ITEM_ADDON", clsID, types)
end

--중복 아이템 체크
function FIND_SAME_ITEM_IN_SLOT(frame, itemClassName)
    if not frame  then
        return true;
    end
    local childcnt = frame:GetChildCount();
    for i = 0, (childcnt - 1) do
        local slot = frame:GetChildByIndex(i)
        if slot ~= nil and slot:GetClassString() == "ui::CSlot" then
            slot = AUTO_CAST(slot)
            local guid = slot:GetUserValue("mat_guid");
            local cleaned_name = itemClassName;
            if guid == "None" then
                return false;
            end
            local invitem = session.GetInvItemByGuid(guid)
            if invitem then
                local item_object = GetIES(invitem:GetObject());
                local slot_item_ClsName = item_object.ClassName;
            
                local pattern = "_NoTrade" .. "$"
                cleaned_name = string.gsub(slot_item_ClsName, pattern, "")    
            end
            if cleaned_name == itemClassName then
                return true;
            end
        end
    end
    return false;
end