function UPDATE_SUMMON_SKILL_TOOLTIP(frame, strarg, numarg1, numarg2, userData, obj)
    local q_frame = ui.GetFrame('quickslotnexpbar')

    local type = q_frame:GetUserValue('before_summon_skill_slot_' .. numarg1)

    DESTROY_CHILD_BYNAME(frame:GetChild('skill_desc'), 'SKILL_CAPTION_');

    local obj = nil;
    local objIsClone = false;
    local tooltipStartLevel = 1;

    obj = GetClassByType("Skill", type);

    if obj == nil then
        return;
    end

    --------------------------- skill description frame ------------------------------------
    local skillFrame = GET_CHILD(frame, "skill_desc", "ui::CGroupBox")
    -- set skill icon and name
    SET_SKILL_TOOLTIP_ICON_AND_NAME(skillFrame, obj, false);    
    
    -- set skill description
    local skillDesc = GET_CHILD(skillFrame, "desc", "ui::CRichText");   	
    SET_SKILL_TOOLTIP_CAPTION(skillFrame, obj.Caption, PARSE_TOOLTIP_CAPTION(obj, obj.Caption, true));    	

    local stateLevel = 0;
    if strarg ~= "quickslot" then
        stateLevel = session.GetUserConfig("SKLUP_" .. obj.ClassName, 0);
    end
    tooltipStartLevel = tooltipStartLevel + stateLevel;    

    local skilltreecls = GetClassByStrProp("SkillTree", "SkillName", obj.ClassName);
    local iconPicture = GET_CHILD(skillFrame, "icon", "ui::CPicture");
    local iconEndPos = iconPicture:GetY() + iconPicture:GetHeight()
    local ypos = skillDesc:GetY() + skillDesc:GetHeight()

    if ypos < iconEndPos then
        ypos = iconEndPos + 10
    end

    -- set weapon info
    local weaponBox = GET_CHILD(skillFrame, "weapon_box", "ui::CGroupBox")
    local stancePic = weaponBox:GetChild("stance_pic")
    stancePic:RemoveAllChild()
    if TryGetProp(obj, 'ReqStance') ~= nil and TryGetProp(obj, 'EnableCompanion') ~= nil then       
        MAKE_STANCE_ICON(stancePic, obj.ReqStance, obj.EnableCompanion, 100, 37)

        local childCount = stancePic:GetChildCount()
        for i=0, childCount-1 do
            local child = stancePic:GetChildByIndex(i);
            child:SetOffset(child:GetWidth() * i + 5, 10)
        end
    end
    
    weaponBox:SetOffset(0, ypos)
    ypos = weaponBox:GetY() + weaponBox:GetHeight() + 5;
    

    -- skill level description controlset
    local skillCaption2 = MAKE_SKILL_CAPTION2(obj.ClassName, obj.Caption2, tooltipStartLevel);    
    local originalText = ""
    local translatedData2 = dictionary.ReplaceDicIDInCompStr(skillCaption2);        
    if skillCaption2 ~= translatedData2 then
        originalText = skillCaption2
    end    

    local skillLvDesc = PARSE_TOOLTIP_CAPTION(obj, skillCaption2, strarg ~= "quickslot");	
    local lvDescStart, lvDescEnd = string.find(skillLvDesc, "Lv.");
    local lv = 1;
    if tooltipStartLevel > 0 then
        lv = tooltipStartLevel;
    end 

    local totalLevel = 0;
    local skl = session.GetSkillByName(obj.ClassName);
    if strarg ~= "Level" then
        if skl ~= nil then
            skillObj = GetIES(skl:GetObject());
            totalLevel = skillObj.Level + stateLevel;
        else
            totalLevel = stateLevel;
        end
    else
        totalLevel = obj.LevelByDB;
    end


    local currLvCtrlSet = nil    
    if totalLevel == 0 and lvDescStart ~= nil then   
        skillLvDesc = string.sub(skillLvDesc, lvDescEnd + 2, string.len(skillLvDesc));
        lvDescStart, lvDescEnd = string.find(skillLvDesc, "Lv.");    
        local lvDesc = string.sub(skillLvDesc, 2, string.len(skillLvDesc));

        ypos = SKILL_LV_DESC_TOOLTIP(skillFrame, obj, totalLevel, lv, lvDesc, ypos, originalText);

        skillFrame:SetTextByKey('level', '');
        skillFrame:SetTextByKey('sp_text', '');
        skillFrame:SetTextByKey('overheat_text', '');

    end            
        

    skillFrame:Resize(frame:GetWidth(), ypos + 10)
    frame:Resize(frame:GetWidth(), skillFrame:GetHeight() + 10)

   
    frame:Invalidate();

end

