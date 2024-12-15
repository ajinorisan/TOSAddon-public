
function HIDDENABILITY_MAKE_ON_INIT(addon, frame)
    addon:RegisterMsg('HIDDENABILITY_DECOMPOSE_MAKE', 'HIDDENABILITY_MAKE_RESULT_UPDATE');
end

function HIDDENABILITY_MAKE_OPEN_NPC(npcClassName)
    local frame = ui.GetFrame("hiddenability_make")
    
    frame:SetUserValue("NPC_CLASSNAME", npcClassName);
    ui.OpenFrame("hiddenability_make");
end

function HIDDENABILITY_MAKE_OPEN(frame)
    HIDDENABILITY_MAKE_USERVALUE_INIT(frame);

    HIDDENABILITY_MAKE_MATERIAL_INIT(frame);
    HIDDENABILITY_MAKE_JOB_DROPLIST_INIT(frame);
    HIDDENABILITY_MAKE_ARTS_DROPLIST_INIT(frame);
    HIDDENABILITY_MAKE_ARTS_RESET(frame);
    HIDDENABILITY_MAKE_ONCE_COUNT_RESET(frame);
    HIDDENABILITY_MAKE_RESULT_RESET(frame);
    HIDDENABILITY_CONTROL_ENABLE(frame, 1);

    INVENTORY_SET_CUSTOM_RBTNDOWN("HIDDENABILITY_MAKE_ITEM_RBTNDOWN");
    frame:SetUserValue('IsHighAbility', 0)    
	ui.OpenFrame("inventory");	
end

function HIDDENABILITY_MAKE_CLOSE(frame)
    ui.CloseFrame("hiddenability_make")
    ui.CloseFrame("inventory");	
    
    frame:SetUserValue("NPC_CLASSNAME", "None");

    INVENTORY_SET_CUSTOM_RBTNDOWN("None");
end

function HIDDENABILITY_MAKE_USERVALUE_INIT(frame)
    frame:SetUserValue("JOB_NAME", "None");
    frame:SetUserValue("ARTS_CLASSNAME", "None");
    frame:SetUserValue("IS_NOVICE", 0);
    
    local npcClassName = frame:GetUserValue("NPC_CLASSNAME")
    local ctrlType = "";
    if npcClassName == "swordmaster" then
        ctrlType = "Warrior";
    elseif npcClassName == "wizardmaster" then
        ctrlType = "Wizard";
    elseif npcClassName == "npc_ARC_master" then
        ctrlType = "Archer";
    elseif npcClassName == "npc_healer" then
        ctrlType = "Cleric";
    elseif npcClassName == "npc_SCT_master" then
        ctrlType = "Scout";
    end

    frame:SetUserValue("CTRL_TYPE", ctrlType);
end

function HIDDENABILITY_MAKE_JOB_DROPLIST_INIT(frame)
    local main_droplist = GET_CHILD_RECURSIVELY(frame, "main_droplist");
    main_droplist:ClearItems();
    main_droplist:AddItem("", "");
    main_droplist:SetSelectedScp("HIDDENABILITY_MAKE_JOB_DROPLIST_SELECT");
end

function HIDDENABILITY_MAKE_JOB_DROPLIST_UPDATE(frame)
    frame:SetUserValue("JOB_NAME", "None");

    local main_droplist = GET_CHILD_RECURSIVELY(frame, "main_droplist");
    main_droplist:ClearItems();
    main_droplist:AddItem("", "");
    main_droplist:SetSelectedScp("HIDDENABILITY_MAKE_JOB_DROPLIST_SELECT");
    
    local arts_droplist = GET_CHILD_RECURSIVELY(frame, "arts_droplist");

    local slot = GET_CHILD_RECURSIVELY(frame, "matslot_1"); 
    local slot_item = GET_SLOT_ITEM(slot);
    if slot_item == nil then
        return;
    end

    local ctrlType = frame:GetUserValue("CTRL_TYPE");
    local itemObj = GetIES(slot_item:GetObject());
    if IS_HIDDENABILITY_MASTERPIECE_NOVICE(itemObj) == true then
        frame:SetUserValue("IS_NOVICE", 1);

        main_droplist:SetSelectedScp("HIDDENABILITY_MAKE_NOVICE_ARTS_DROPLIST_SELECT");
        arts_droplist:EnableHitTest(0);
        
        local artsList = IS_HIDDENABILITY_MASTERPIECE_NOVICE_LIST(ctrlType);
        for k, v in pairs(artsList) do
            local itemCls = GetClass("Item", v);
            main_droplist:AddItem(v, itemCls.Name);
        end
    else
        frame:SetUserValue("IS_NOVICE", 0);
        arts_droplist:EnableHitTest(1);

        local gender = GETMYPCGENDER();
        local jobList = GET_JOB_CLASS_LIST(ctrlType);
        for k, v in pairs(jobList) do 
            local jobName = GET_JOB_NAME_BY_ENGNAME(v);
            main_droplist:AddItem(v, jobName);
        end
    end

    HIDDENABILITY_MAKE_ARTS_DROPLIST_INIT(frame);    
end

-- 일반 미식별 신비한 서일 경우 직업 SLECT
function HIDDENABILITY_MAKE_JOB_DROPLIST_SELECT(frame, ctrl)   
    local jobName = ctrl:GetSelItemKey();
    frame:SetUserValue("JOB_NAME", jobName);

    HIDDENABILITY_MAKE_ARTS_DROPLIST_INIT(frame);
    HIDDENABILITY_MAKE_ARTS_RESET(frame);
end

-- 에피소드 미식별 신비한 서일 경우 전집 SLECT
function HIDDENABILITY_MAKE_NOVICE_ARTS_DROPLIST_SELECT(frame, ctrl)
    local artsClassName = ctrl:GetSelItemKey();
    if artsClassName == "" then
        return;
    end

    HIDDENABILITY_MAKE_ARTS_UPDATE(frame, artsClassName);
end

-- 각 직업 별 아츠 LIST
function HIDDENABILITY_MAKE_ARTS_DROPLIST_INIT(frame)
    frame:SetUserValue("ARTS_CLASSNAME", "None");

    local arts_droplist = GET_CHILD_RECURSIVELY(frame, "arts_droplist");
    arts_droplist:ClearItems();
    arts_droplist:AddItem("", "");

    local slot = GET_CHILD_RECURSIVELY(frame, "matslot_1"); 
    local slot_item = GET_SLOT_ITEM(slot);
    if slot_item == nil then
        return;
    end
    
    local ctrlType = frame:GetUserValue("CTRL_TYPE");
    local jobName = frame:GetUserValue("JOB_NAME");
    if jobName == "None" or jobName == "" then
        return;
    end

    local artsList = GET_HIDDEN_ABILITY_LIST(ctrlType, jobName);
    for k, v in pairs(artsList) do
        local itemCls = GetClass("Item", v);
        arts_droplist:AddItem(v, itemCls.Name);
    end
end

function HIDDENABILITY_MAKE_ARTS_DROPLIST_SELECT(frame, ctrl)
    local artsClassName = ctrl:GetSelItemKey();
    if artsClassName == "" then
        return;
    end

    HIDDENABILITY_MAKE_ARTS_UPDATE(frame, artsClassName);
end

function HIDDENABILITY_MAKE_ITEM_RBTNDOWN(itemObj, slot)
    local frame = ui.GetFrame("hiddenability_make");

    local icon = slot:GetIcon()
	local iconInfo = icon:GetInfo();
	local guid = iconInfo:GetIESID();

    HIDDENABILITY_MAKE_MASTER_PIECE_REG(frame, guid);
end

function HIDDENABILITY_MAKE_MATERIAL_DROP(frame, ctrl, argStr, argNum)
    if ui.CheckHoldedUI() == true then
		return;
	end

	local liftIcon = ui.GetLiftIcon();
	local FromFrame = liftIcon:GetTopParentFrame();
    frame = frame:GetTopParentFrame();
    
    if FromFrame:GetName() == 'inventory' then
		local iconInfo = liftIcon:GetInfo();
        local guid = iconInfo:GetIESID();
        if argNum == 1 then
            HIDDENABILITY_MAKE_MASTER_PIECE_REG(frame, guid);
        end
    end 
end

function HIDDENABILITY_MAKE_MATERIAL_POP(frame, ctrl, argStr, argNum)
    local frame = ui.GetFrame("hiddenability_make");

    HIDDENABILITY_MAKE_MATERIAL_INIT(frame);
    HIDDENABILITY_MAKE_JOB_DROPLIST_INIT(frame);
    HIDDENABILITY_MAKE_ARTS_DROPLIST_INIT(frame);
    HIDDENABILITY_MAKE_ARTS_RESET(frame);
end

function HIDDENABILITY_MAKE_MASTER_PIECE_REG(frame, guid)
    local invitem = session.GetInvItemByGuid(guid);
    if invitem == nil then return; end

    if invitem.isLockState == true then
        ui.SysMsg(ClMsg("MaterialItemIsLock"));
        return false;
    end

    local itemObj = GetIES(invitem:GetObject());
    if IS_HIDDENABILITY_MATERIAL_MASTER_PIECE(itemObj) == false then
        ui.SysMsg(ClMsg('NotEnoughTarget'));
        return;
    end

    local matslot = GET_CHILD_RECURSIVELY(frame, "matslot_1"); 
    SET_SLOT_ITEM(matslot, invitem);
    frame:SetUserValue("MATERIAL_1_GUID", guid);

    local edit = GET_CHILD_RECURSIVELY(frame, "once_edit");
    edit:SetText('1');

    HIDDENABILITY_MAKE_JOB_DROPLIST_UPDATE(frame);
    HIDDENABILITY_MAKE_NEED_MATERIAL_COUNT_UPDATE(frame);
end

function HIDDENABILITY_MAKE_MATERIAL_INIT(frame)
    frame:SetUserValue("MATERIAL_GUID_1", "None");

    local matslot_1 = GET_CHILD_RECURSIVELY(frame, "matslot_1");
    matslot_1:ClearIcon();

    local itemCls = GetClass("Item", "HiddenAbility_MasterPiece_Fragment");
    local matslot_1_count = GET_CHILD_RECURSIVELY(frame, "matslot_1_count");
    matslot_1_count:ShowWindow(0);

    local matslot_1_text = GET_CHILD_RECURSIVELY(frame, "matslot_1_text");
    matslot_1_text:SetTextByKey("value", itemCls.Name);
    matslot_1_text:ShowWindow(1);
end

function HIDDENABILITY_MAKE_NEED_MATERIAL_COUNT_UPDATE(frame)
    local edit = GET_CHILD_RECURSIVELY(frame, "once_edit");
    if edit:GetText() == nil then return; end

    local slot = GET_CHILD_RECURSIVELY(frame, "matslot_1"); 
    local slot_item = GET_SLOT_ITEM(slot);
    if slot_item == nil then
        HIDDENABILITY_MAKE_MATERIAL_INIT(frame);
        return;
    end

    local isNoevice = frame:GetUserIValue("IS_NOVICE");
    local curCnt = 0;
    if slot_item ~= nil then
        local pc = GetMyPCObject();
        curCnt = GET_TOTAL_HIDDENABILITY_MASTER_PIECE_COUNT(pc, isNoevice);
    end
    
    if frame:GetUserIValue("IsHighAbility") == 0 then
        edit:SetText("1")
    end

    local needCnt = HIDDENABILITY_MAKE_NEED_MASTER_PIECE_COUNT() * tonumber(edit:GetText());
    local style = frame:GetUserConfig("ENOUPH_STYLE");
    if curCnt < needCnt then
        style = frame:GetUserConfig("NOT_ENOUPH_STYLE");
    end
    
    local matslot_1_count = GET_CHILD_RECURSIVELY(frame, "matslot_1_count");
    matslot_1_count:SetTextByKey("style", style);
    matslot_1_count:SetTextByKey("cur", curCnt);
    matslot_1_count:SetTextByKey("need", needCnt);
    matslot_1_count:ShowWindow(1);
end

function HIDDENABILITY_MAKE_ONCE_COUNT_RESET(frame)    
    local edit = GET_CHILD_RECURSIVELY(frame, "once_edit");
    edit:SetText("1");
end

function HIDDENABILITY_MAKE_ONCE_COUNT_TYPING(parent, ctrl)
    if ctrl:GetText() == "" then
        return;
    end

    local frame = parent:GetTopParentFrame();
    HIDDENABILITY_MAKE_NEED_MATERIAL_COUNT_UPDATE(frame);
end

function HIDDENABILITY_MAKE_ONCE_COUNT_UP_CLICK(parent, ctrl)
    local edit = GET_CHILD(parent, "once_edit");
    local curCnt = tonumber(edit:GetText());
    local upCnt = curCnt + 1;

    local frame = ui.GetFrame("hiddenability_make");
    if frame:GetUserIValue('IsHighAbility') == 0 then
        edit:SetText("1");
    else
        edit:SetText(upCnt);
    end

    local frame = parent:GetTopParentFrame();
    HIDDENABILITY_MAKE_NEED_MATERIAL_COUNT_UPDATE(frame);
end

function HIDDENABILITY_MAKE_ONCE_COUNT_DOWN_CLICK(parent, ctrl)
    local edit = GET_CHILD(parent, "once_edit");

    local curCnt = tonumber(edit:GetText());
    local downCnt = curCnt - 1;
    if downCnt < 1 then
        downCnt = 1;
    end

    if downCnt < 1 then
        downCnt = 1
    end

    edit:SetText(downCnt);

    local frame = parent:GetTopParentFrame();
    HIDDENABILITY_MAKE_NEED_MATERIAL_COUNT_UPDATE(frame);
end

function HIDDENABILITY_MAKE_ARTS_RESET(frame)
    local slot = GET_CHILD_RECURSIVELY(frame, "arts_slot");
    slot:ClearIcon();

    local arts_text = GET_CHILD_RECURSIVELY(frame, "arts_text");
    arts_text:ShowWindow(0);
end

function HIDDENABILITY_MAKE_ARTS_UPDATE(frame, artsClassName)    
    frame:SetUserValue("ARTS_CLASSNAME", artsClassName);

    local cls = GetClass("Item", artsClassName);
    if cls == nil then
        HIDDENABILITY_MAKE_ARTS_RESET(frame);
        return;
    end

    local slot = GET_CHILD_RECURSIVELY(frame, "arts_slot");
	SET_SLOT_ITEM_CLS(slot, cls);    

    local arts_text = GET_CHILD_RECURSIVELY(frame, "arts_text");
    arts_text:SetTextByKey("value", "");
    arts_text:SetTextByKey("value", cls.Name);
    arts_text:ShowWindow(1);
    
    if IS_HIGH_HIDDENABILITY(artsClassName) == true then
        frame:SetUserValue('IsHighAbility', 1)    
    else
        frame:SetUserValue('IsHighAbility', 0)
        HIDDENABILITY_MAKE_NEED_MATERIAL_COUNT_UPDATE(frame)        
    end
end

function HIDDENABILITY_CONTROL_ENABLE(frame, isenable)
    local frame = ui.GetFrame("hiddenability_make")
    local matslot_1 = GET_CHILD_RECURSIVELY(frame, "matslot_1");
    matslot_1:EnableHitTest(isenable);

    local matslot_2 = GET_CHILD_RECURSIVELY(frame, "matslot_2");
    matslot_2:EnableHitTest(isenable);
        
    local main_droplist = GET_CHILD_RECURSIVELY(frame, "main_droplist");
    main_droplist:EnableHitTest(isenable);

    local arts_droplist = GET_CHILD_RECURSIVELY(frame, "arts_droplist");
    arts_droplist:EnableHitTest(isenable);
end

-- 확인 버튼 클릭
function HIDDENABILITY_MAKE_OK_CLLICK(frame, ctrl)
    if ui.CheckHoldedUI() == true then
        return;
    end
    
    HIDDENABILITY_MAKE_MATERIAL_INIT(frame);
    HIDDENABILITY_MAKE_JOB_DROPLIST_INIT(frame);
    HIDDENABILITY_MAKE_ARTS_DROPLIST_INIT(frame);
    HIDDENABILITY_MAKE_RESULT_RESET(frame);
    HIDDENABILITY_CONTROL_ENABLE(frame, 1);    
end

-- 제작 버튼 클릭
function HIDDENABILITY_MAKE_CREATE_CLICK(frame, ctrl)
    if ui.CheckHoldedUI() == true then
        return;
    end

    local frame = ui.GetFrame("hiddenability_make");
    
    local artsClassName = frame:GetUserValue("ARTS_CLASSNAME");
    if artsClassName == "None" or artsClassName == "" then
        ui.SysMsg(ClMsg("Arts_Please_Select_HiddenabilityItem"));
        return;
    end

    local matslot_1 = GET_CHILD_RECURSIVELY(frame, "matslot_1");
    local matslot_1_item = GET_SLOT_ITEM(matslot_1);
    if matslot_1_item == nil then return; end
	local matslot_1_itemObj = GetIES(matslot_1_item:GetObject());
    
    local ctrlType = frame:GetUserValue("CTRL_TYPE");
    local jobName = frame:GetUserValue("JOB_NAME");
    local isNoevice = frame:GetUserIValue("IS_NOVICE");

    local pc = GetMyPCObject();
    local curCnt = GET_TOTAL_HIDDENABILITY_MASTER_PIECE_COUNT(pc, isNoevice);
    
    local edit = GET_CHILD_RECURSIVELY(frame, "once_edit");    
    local makeCnt = tonumber(edit:GetText());
    local needCnt = HIDDENABILITY_MAKE_NEED_MASTER_PIECE_COUNT() * makeCnt;

    if curCnt < needCnt then
        ui.SysMsg(ClMsg('NotEnoughRecipe'));
        return;
    end

    -- 신비한 서 제작 함수 호출
    local nameList = NewStringList();
    nameList:Add(ctrlType);
    nameList:Add(jobName);
    nameList:Add(artsClassName);
    nameList:Add(makeCnt);
    session.ResetItemList();
    session.AddItemID(matslot_1_item:GetIESID(), needCnt);
    local resultlist = session.GetItemIDList();

    item.DialogTransaction('HIDDENABILITY_MAKE', resultlist, "", nameList);
    
	ui.SetHoldUI(true);
    ReserveScript("HIDDENABILITY_MAKE_BUTTON_UNFREEZE()", 1.5);
end

function HIDDENABILITY_MAKE_BUTTON_UNFREEZE()
   ui.SetHoldUI(false);
end

function HIDDENABILITY_MAKE_RESULT_RESET(frame)
    local issuccess_gb = GET_CHILD_RECURSIVELY(frame, "issuccess_gb");
    issuccess_gb:ShowWindow(0);

    local Btn = GET_CHILD_RECURSIVELY(frame, "Btn");
    Btn:ShowWindow(1);

    local ok_Btn = GET_CHILD_RECURSIVELY(frame, "ok_Btn");
    ok_Btn:ShowWindow(0);
end

function HIDDENABILITY_MAKE_RESULT_UPDATE(frame, msg)
    local frame = ui.GetFrame("hiddenability_make")
    imcSound.PlaySoundEvent(frame:GetUserConfig("MAKE_START_SOUND"));
    imcSound.PlaySoundEvent(frame:GetUserConfig("MAKE_RESULT_SOUND"));
    
    local Btn = GET_CHILD_RECURSIVELY(frame, "Btn");
    Btn:ShowWindow(0);
    
    local ok_Btn = GET_CHILD_RECURSIVELY(frame, "ok_Btn");
    ok_Btn:ShowWindow(1);

    local issuccess_gb = GET_CHILD_RECURSIVELY(frame, "issuccess_gb");
    local issuccess_pic = GET_CHILD_RECURSIVELY(frame, "issuccess_pic");
    issuccess_gb:ShowWindow(1);

    HIDDENABILITY_CONTROL_ENABLE(frame, 0);
end
