function CUPOLE_UPGRADE_ON_INIT(addon,frame)
    addon:RegisterMsg('SET_CUPOLE_EXP_UP', 'ON_UPDATE_CUPOLE_UPGRADE_INFO');

end
 
function ON_UPDATE_CUPOLE_UPGRADE_INFO(frame, msg, argStr, argNum)
    local cls = GET_CUPOLE_CLASS_ACCOUNTPROP(argStr)
    local index = TryGetProp(cls, "ClassID", 0) - 1;
    local grade = TryGetProp(cls, "Grade", "R");
    local maxrank = shared_cupole.get_max_friendly(grade)
    if maxrank == argNum then
        local TopParent = frame:GetTopParentFrame();
        local cupole_item = ui.GetFrame("cupole_item")
        local upgradebtn_bg = GET_CHILD_RECURSIVELY(cupole_item,"upgradebtn_bg")
        TOGGLE_CUPOLE_RANKUP_BTN(upgradebtn_bg);
        ui.CloseFrame("cupole_upgrade")
        return;
    end
    SET_CUPOLE_WITH_UPGRADE_MATERIAL(frame, index, argNum)
end

function SCP_OPEN_CUPOLE_UPGRADE(parent, ctrl, argStr, argNum)
    local frame = ui.GetFrame("cupole_upgrade")
    if frame:IsVisible() == 1 then
        frame:ShowWindow(0);
    else
        frame:ShowWindow(1);
    end
    local selc_cupole_index = GET_GLOBAL_SELECT_CUPOLE(frame);
    SET_CUPOLE_WITH_UPGRADE_MATERIAL(frame, selc_cupole_index)
end

function SET_CUPOLE_WITH_UPGRADE_MATERIAL(frame, selc_cupole_index, SpecificRank)
    local pc = GetMyPCObject()
    if not pc then return 0 end
    local acc = GetMyAccountObj(pc)
    if not acc then return 0 end

    local managerTab = GET_CHILD(frame, "managerTab")
    local CupoleBg = GET_CHILD(managerTab, "CupoleBg")
    local SkillBg = GET_CHILD(managerTab, "SkillBg")

    local BeforeBG = GET_CHILD(SkillBg, "BeforeBG")
    local AfterBG = GET_CHILD(SkillBg, "AfterBG")

    local cupole_cls = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(selc_cupole_index);
    if not cupole_cls then return end

    local Group_ID = TryGetProp(cupole_cls,"Group_ID", "None")
    local SkillTable = GET_CUPOLE_SKILL_BY_GROUPID_LIST(Group_ID);
    local UpgradeTable = GET_CUPOLE_UPGRADE_BY_GROUPID_LIST(Group_ID);

    local CupoleRankProp = GET_CUPOLE_PROP_BY_INDEX(selc_cupole_index, "AccountProperty");
    local CupoleCurrentRank = TryGetProp(acc, CupoleRankProp, 0);
    if SpecificRank then
        CupoleCurrentRank = SpecificRank;
    end
    local BeforeCupoleSlot = CupoleBg:CreateOrGetControlSet("cupole_slot", "BeforeCupoleSlot", 300, 0)
    local AfterCupoleSlot = CupoleBg:CreateOrGetControlSet("cupole_slot", "AfterCupoleSlot", -425, 0)
    local CupoleUpgradeMat = CupoleBg:CreateOrGetControlSet("mat_required_cupole", "CupoleUpgradeMat", -150, 0)

    
    SET_SLOT_CUPOLE_INFO(BeforeCupoleSlot, selc_cupole_index)
    SET_SLOT_CUPOLE_INFO(AfterCupoleSlot, selc_cupole_index)

    local Before_equip_img = GET_CHILD_RECURSIVELY(BeforeCupoleSlot, "equip_img")
    local After_equip_img = GET_CHILD_RECURSIVELY(AfterCupoleSlot, "equip_img")

    Before_equip_img:ShowWindow(0)
    After_equip_img:ShowWindow(0)
    BeforeCupoleSlot:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    AfterCupoleSlot:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    CupoleUpgradeMat:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)

    SET_CUPOLE_UPGRADE_MATERIAL(CupoleUpgradeMat, cupole_cls, CupoleCurrentRank)

    SET_CUPOLE_COMPANYEFFECT_INFORMATION(BeforeBG, cupole_cls, CupoleCurrentRank)
    SET_CUPOLE_COMPANYEFFECT_INFORMATION(AfterBG, cupole_cls, CupoleCurrentRank + 1)

    SET_CUPOLE_SKILLEFFECT_INFORMATION(BeforeBG, SkillTable, CupoleCurrentRank)
    SET_CUPOLE_SKILLEFFECT_INFORMATION(AfterBG, SkillTable, CupoleCurrentRank + 1)
end

function SCP_CUPOLE_UPGRADE_PROCESS()

end

function SET_CUPOLE_UPGRADE_MATERIAL(frame, cupole_cls, CupoleCurrentRank)
    local TopParentFrame = frame:GetTopParentFrame();
    local mat_cls = nil	
    local curr_my_cnt = 0;
    local UpgradeItemClassName, UpgradeCount = GET_KUPOLE_UPGRADE_ITEM_COUNT_BY_CLS(pc, cupole_cls);

    -- local SkillUpgradeItemIncreaseCount = TryGetProp(SkillTable[1], "SkillUpgradeItemIncreaseCount")
    
    mat_cls = GetClassByNameFromList(item_list, UpgradeItemClassName)
    curr_my_cnt, itemlist = GET_INV_ITEM_COUNT_BY_PROPERTY({
        { Name = 'ClassName', Value = UpgradeItemClassName }
    }, false)

    local mat_item = itemlist[1];
    if mat_item ~= nil then
        local mat_guid = mat_item:GetIESID();
        TopParentFrame:SetUserValue("mat_guid", mat_guid);
    end

    local mat_slot = GET_CHILD_RECURSIVELY(frame,"mat_slot")    
    mat_slot:SetEventScriptArgString(ui.LBUTTONUP, mat_cls.ClassName);

    local icon = imcSlot:SetImage(mat_slot,TryGetProp(mat_cls,"Icon","None"))
    index = index +1;
    SET_ITEM_TOOLTIP_BY_NAME(icon, mat_cls.ClassName)
    icon:SetTooltipOverlap(1)   

    --내 가방에 요구량
    local curr_my_cnt_text = GET_CHILD_RECURSIVELY(frame,"cnt_in_my_bag")
    if tonumber(curr_my_cnt) < tonumber(UpgradeCount) then
        curr_my_cnt = "{#FF0000}"..curr_my_cnt.."{/}"
    else
        curr_my_cnt = "{#00BBBB}"..curr_my_cnt.."{/}"
    end
    curr_my_cnt_text:SetTextByKey("value",(curr_my_cnt))
    curr_my_cnt_text:SetTextByKey("maxvalue",(UpgradeCount))

    
end

function SET_CUPOLE_COMPANYEFFECT_INFORMATION(frame, cupole_cls, CupoleCurrentRank)
    local WithEffect = GET_CHILD(frame, "WithEffect");
    local haveEffect = GET_CHILD(frame, "haveEffect");

    local Stat, UpgradeValue = GET_CUPOLE_FRIENDLY_RESULT_VALUE_BY_CLS(nil, cupole_cls, CupoleCurrentRank)
    local StatStr = GET_CUPOLE_STAT_TEXT(Stat, UpgradeValue)
    local OwnStat, Ownvalue = GET_CUPOLE_OWNED_RESULT_VALUE_BY_CLS(nil, cupole_cls, CupoleCurrentRank);
    local OwnStr = GET_CUPOLE_STAT_TEXT(OwnStat, Ownvalue)

    WithEffect:SetTextByKey("explain", StatStr);
    haveEffect:SetTextByKey("explain", OwnStr);
end

function SET_CUPOLE_SKILLEFFECT_INFORMATION(frame, SkillTable, CupoleCurrentRank)
    local SkillEffect = GET_CHILD(frame, "SkillEffect");

    local ActiveSkillCls = nil;

    for k,v in pairs(SkillTable) do
        local SkillType = TryGetProp(v, "Skill_Type", "None")
        if SkillType == "Active" then
            ActiveSkillCls = v;
            break; 
        end
    end
    local Name, Explain, Icon = CREATE_CUPOLE_SKILL_RATIO_TEXT(ActiveSkillCls, CupoleCurrentRank);

    SkillEffect:SetTextByKey("explain", Explain)
end


-- --선물을 주는 버튼 눌렀을 때
function EVENT_CUPOLE_RANK_UP_BTN(frame, ctrl, argStr, argNum)
	local pc = GetMyPCObject();

    local TopParentFrame = frame:GetTopParentFrame();
    local mat_guid = TopParentFrame:GetUserValue("mat_guid");

    local managerTab = GET_CHILD(frame,"managerTab");

    local selc_cupole_index = GET_GLOBAL_SELECT_CUPOLE();
    local cupole_cls = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(selc_cupole_index);
    if cupole_cls == nil then
        return;
    end
    local Group_ID = TryGetProp(cupole_cls,"Group_ID", "None")
    local SkillTable = GET_CUPOLE_SKILL_BY_GROUPID_LIST(Group_ID);
    local ItemName, UpgradeCount = GET_KUPOLE_UPGRADE_ITEM_COUNT_BY_CLS(pc, cupole_cls);

    local cur_count = GetInvItemCount(pc, ItemName);

	session.ResetItemList()
    
	if mat_guid == '0' then return end
	if mat_guid == 'None' then return end

	local mat_item = session.GetInvItemByGuid(mat_guid)
	if mat_item == nil then return end
    
	if cur_count ~= nil and cur_count > 0 and cur_count >= UpgradeCount then
	    session.AddItemID(mat_guid, cur_count)
    end

	local msg = ClMsg('Likeability_up')
	local yesScp = '_CUPOLE_EXP_EXEC()'
	local msgbox = ui.MsgBox(msg, yesScp, 'None')
	SET_MODAL_MSGBOX(msgbox)

end

function _CUPOLE_EXP_EXEC()
	local result_list = session.GetItemIDList()
    local arg_list = NewStringList()
    --#kdh 수정 필요
    local AccountProp = GET_GLOBAL_SELECT_CUPOLE_ACCOUNTPROP();
    arg_list:Add(AccountProp);
	item.DialogTransaction('CUPOLE_EXP_UP', result_list, '', arg_list)
end
