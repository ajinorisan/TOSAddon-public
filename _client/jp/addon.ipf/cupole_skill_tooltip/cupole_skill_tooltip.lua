function OPEN_CUPOLE_FILTER_FRAME(frame)
end

function ON_CUPOLE_SKILL_TOOLTIP_OPEN(parent, ctrl, argStr, argNum)
    local frame = ui.GetFrame("cupole_skill_tooltip")
    frame:ShowWindow(1);

    local managerTab = GET_CHILD(frame, "managerTab")
	local skillicon = GET_CHILD_RECURSIVELY(frame, "skillicon");
	local skillname = GET_CHILD_RECURSIVELY(frame, "skillname");
	local explain = GET_CHILD_RECURSIVELY(frame, "explain");
    local skillcls = GetClassByType("cupole_skill", argNum);
    if skillcls == nil then
        return;
    end

    local Name, Explain, Icon = CREATE_CUPOLE_SKILL_RATIO_TEXT(skillcls);

    skillname:SetTextByKey("name",Name)
    explain:SetTextByKey("explain",Explain)
    skillicon:SetImage(Icon);
    
    local height = explain:GetLastTextYPos() + 200;
    managerTab:Resize(managerTab:GetWidth(), height);
end


function ON_CUPOLE_SKILL_TOOLTIP_CLOSE(parent, ctrl, argStr, argNum)
    local frame = ui.GetFrame("cupole_skill_tooltip")
    frame:ShowWindow(0);

end

function CREATE_CUPOLE_SKILL_RATIO_TEXT(SKillClass, Rank)
	local pc = GetMyPCObject()
    if pc == nil then
        return ;
    end
    local acc = GetMyAccountObj(pc)
    if acc == nil then
        return;
    end
    if SKillClass == nil then
        return;
    end

    local Dec_Name = TryGetProp(SKillClass, "Dec_Name", "None")
    local Dec_Skill = TryGetProp(SKillClass, "Dec_Skill", "None")
    local Skill_Icon = TryGetProp(SKillClass, "Skill_Icon", "None")
    
    local Group_ID = TryGetProp(SKillClass, "Group_ID", "None")

    local Cls = GET_CUPOLE_CLASS_BY_GROUPID(Group_ID);

    local Ratio = GET_KUPOLE_SKILL_RATE(pc, Cls , SKillClass)
    Ratio = string.format("%.f", Ratio);

    Dec_Skill = dic.getTranslatedStr(Dec_Skill)
    local resultString, numReplacements = string.gsub(Dec_Skill, "{Ratio}", Ratio);
    return Dec_Name, resultString, Skill_Icon;
end