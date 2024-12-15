function WEEKLYBOSS_PATTERNINFO_ON_INIT(addon, frame)
    addon:RegisterMsg('WEEKLY_BOSS_UI_UPDATE', 'WEEKLYBOSS_PATTERNINFO_UI_UPDATE');
    addon:RegisterMsg('FIELD_BOSS_MONSTER_UPDATE', 'FIELDBOSS_PATTERNINFO_UI_UPDATE');
end
function WEEKLYBOSS_PATTERNINFO_UI_OPEN(frame)
	local type = frame:GetUserValue("type")
	if type == "WeeklyBoss" then
		WEEKLYBOSS_PATTERNINFO_MAKE_LIST(frame)
	elseif type == "FieldBoss" then
		FIELDBOSS_PATTERNINFO_MAKE_LIST(frame)
	end
end

function WEEKLYBOSS_PATTERNINFO_UI_CLOSE()
    ui.CloseFrame('weeklyboss_patterninfo');
end

function WEEKLYBOSS_PATTERNINFO_MAKE_LIST(frame)
    local patternListBox = GET_CHILD_RECURSIVELY(frame, 'patternListBox');
    patternListBox:RemoveAllChild()

    local weeklybossInfo = session.weeklyboss.GetPatternInfo()
    local mapPatternCnt = weeklybossInfo:GetMapPatternCount()

    local ctrlSetHeight = 0

    for i = 0,mapPatternCnt-1 do
        local patternID = weeklybossInfo:GetMapPatternIDByIndex(i)
        ctrlSetHeight = PATTERNINFO_SET_INFO(patternListBox,patternID,ctrlSetHeight)
    end

	local patternCnt = weeklybossInfo:GetPatternCount()
    for i = 0,patternCnt-1 do
        local patternID = weeklybossInfo:GetPatternIDByIndex(i)
        ctrlSetHeight = PATTERNINFO_SET_INFO(patternListBox,patternID,ctrlSetHeight)
    end
end

function FIELDBOSS_PATTERNINFO_MAKE_LIST(frame)
    local patternListBox = GET_CHILD_RECURSIVELY(frame, 'patternListBox');
    patternListBox:RemoveAllChild()

    local fieldbossInfo = session.fieldboss.GetPatternInfo()
    local mapPatternCnt = fieldbossInfo:GetMapPatternCount()
    local ctrlSetHeight = 0

    for i = 0,mapPatternCnt-1 do
        local patternID = fieldbossInfo:GetMapPatternIDByIndex(i)
        ctrlSetHeight = PATTERNINFO_SET_INFO(patternListBox,patternID,ctrlSetHeight)
    end

    local patternCnt = fieldbossInfo:GetPatternCount()
    for i = 0,patternCnt-1 do
        local patternID = fieldbossInfo:GetPatternIDByIndex(i)
        ctrlSetHeight = PATTERNINFO_SET_INFO(patternListBox,patternID,ctrlSetHeight)
    end
end

function WEEKLYBOSS_PATTERNINFO_SET_INFO(patternListBox,patternID,ctrlSetHeight)

end

function PATTERNINFO_SET_INFO(patternListBox,patternID,ctrlSetHeight)
	local patternCls = GetClassByType('boss_pattern',patternID)
    local patternCtrl = patternListBox:CreateOrGetControlSet('weekly_boss_pattern', 'PATTERN_CTRL_'..patternID, 0, ctrlSetHeight);
    local patternNameText = GET_CHILD_RECURSIVELY(patternCtrl,'patternName')
    patternNameText:SetText('{@st66b}{s16}'..patternCls.Name)
    local patternPic = GET_CHILD_RECURSIVELY(patternCtrl,'patternPic')
    patternPic:SetImage('icon_'..patternCls.Icon)

    local patternDescText = GET_CHILD_RECURSIVELY(patternCtrl,'patternDesc')
    patternDescText:SetText(patternCls.ToolTip)
    if patternDescText:GetHeight() > patternDescText:GetParent():GetHeight() then
        patternDescText:SetTextTooltip(patternCls.ToolTip)
    end
    return ctrlSetHeight + 99
end


function WEEKLYBOSS_PATTERNINFO_UI_UPDATE(frame,msg)
	frame:SetUserValue("type","WeeklyBoss")
    WEEKLYBOSS_PATTERNINFO_MAKE_LIST(frame)
end

function FIELDBOSS_PATTERNINFO_UI_UPDATE(frame,msg)
	frame:SetUserValue("type","FieldBoss")
    FIELDBOSS_PATTERNINFO_MAKE_LIST(frame)
end