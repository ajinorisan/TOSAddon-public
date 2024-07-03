function TOGGLE_CUPOLE_ADDON_FRAME()
    local frame = ui.GetFrame("cupole_addon")
    frame:ShowWindowToggle();
    local atkBG = GET_CHILD(frame,"atkBG")
    local defBG = GET_CHILD(frame,"defBG")
    atkBG:ShowWindow(0)
    defBG:ShowWindow(0)
    local index = GET_GLOBAL_SELECT_CUPOLE();
    -- SET_CUPOLE_ITEM_SLOT(frame)
    CUPOLE_REGISTE_ITEM_PROP(frame, index)
end

function OPEN_CUPOLE_ADDON_FRAME(frame)
    
end

function PRESS_CUPOLE_ADDON_BTN(parent, ctrl, argStr, argNum)
end

--큐폴 선택 시 해당 큐폴이 사용할 수 있는 포션의 종류들을 그려주는 함수
function CUPOLE_REGISTE_ITEM(frame, ctrl, argStr, argNum)
    local parent = frame:GetTopParentFrame();
    local atkBG = GET_CHILD(parent,"atkBG")
    local defBG = GET_CHILD(parent,"defBG")
    local destBG = nil;
    local tag = ""
    local prop = "PotionName"

    local index = GET_GLOBAL_SELECT_CUPOLE();

    local potioncls = GET_CUPOLE_AUTO_POTION_CLS(index + 1)
    local PotionNameList = TryGetProp(potioncls, prop, "None")

    local list = StringSplit(PotionNameList, ';')

    if argNum == 1 then
        defBG:ShowWindowToggle()
        destBG = defBG;
    elseif argNum == 0 then
        atkBG:ShowWindowToggle()
        destBG = atkBG;
    end
    tag = list[argNum + 1]

    SET_CUPOLE_REGISTE_ITEM_LIST(destBG, tag, prop)
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
        imcSlot:SetImage(atkslot,TryGetProp(item1,"Icon","None"))
    end
    if item2 ~= nil then
        imcSlot:SetImage(defslot,TryGetProp(item2,"Icon","None"))
    end
end

--ui에 아이템들을 등록시켜준다.
function SET_CUPOLE_REGISTE_ITEM_LIST(frame, tag, Prop)
    local curr_my_cnt, itemlist = GET_INV_ITEM_COUNT_BY_PROPERTY({
        { Name = Prop, Value = tag }
    }, false)


    if curr_my_cnt < 1 then
        return;
    end

    local childcnt = frame:GetChildCount();
    for i = 0, childcnt -1 do
        local slot = frame:GetChildByIndex(i)
        slot = AUTO_CAST(slot)
        if slot ~= nil then
            local icon = CreateIcon(slot)
            local mat_item_info = itemlist[i + 1];
            if mat_item_info ~= nil then
                local mat_cls = GetIES(mat_item_info:GetObject())
                local icon = imcSlot:SetImage(slot,TryGetProp(mat_cls,"Icon","None"))
                local mat_guid = mat_item_info:GetIESID();

                slot:SetUserValue("mat_guid", mat_guid);
                slot:SetUserValue("itemcount", curr_my_cnt);
                icon:SetTooltipOverlap(1)   
                SET_ITEM_TOOLTIP_BY_NAME(icon, mat_cls.ClassName)
            else
                slot:SetUserValue("mat_guid", "None");
                slot:SetUserValue("itemcount", 0);
                slot:ClearIcon()
            end
        end
    end
end

--아이템 눌렀을떄 동작(등록한다)
function PRESS_CUPOLE_ITEM(frame, ctrl, argStr, argNum)
    local mat_guid = ctrl:GetUserValue("mat_guid");
    local curr_my_cnt = ctrl:GetUserIValue("itemcount");
    local parent = frame:GetTopParentFrame();

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