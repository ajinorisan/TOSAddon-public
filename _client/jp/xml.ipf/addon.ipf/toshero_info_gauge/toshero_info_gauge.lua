function TOSHERO_INFO_GAUGE_ON_INIT(addon, frame)
    addon:RegisterMsg('TOSHERO_STAGE_START', 'ON_TOSHERO_INFO_GAUGE_SET')
    addon:RegisterMsg('TOSHERO_STAGE_REFRESH', 'ON_TOSHERO_INFO_GAUGE_REFRESH')
    addon:RegisterMsg('TOSHERO_STAGE_END', 'ON_TOSHERO_INFO_GAUGE_END')
    addon:RegisterMsg('TOSHERO_GRID_OBJECTHP', 'ON_TOSHERO_INFO_OBJECTHP')
    addon:RegisterMsg('TOSHERO_SHOW_SIMPLE_MSG', 'ON_TOSHERO_SHOW_SIMPLE_MSG')
end

function ON_TOSHERO_INFO_GAUGE_SET(frame, msg, argStr, stage)
    ui.OpenFrame('toshero_info_gauge')

    local frame = ui.GetFrame('toshero_info_gauge')
    if frame == nil then
        return
    end

    GET_CHILD_RECURSIVELY(frame, "gauge_lv"):SetMaxPointWithTime(0, 1, 0.1, 0.5)
    GET_CHILD_RECURSIVELY(frame, "stage_txt"):SetTextByKey("stage", stage)
    GET_CHILD_RECURSIVELY(frame, "pic_max"):ShowWindow(0)
    GET_CHILD_RECURSIVELY(frame, "ObjectHP_gauge"):ShowWindow(0)
    GET_CHILD_RECURSIVELY(frame, "ObjectHP_gauge_lv_left"):ShowWindow(0)
    GET_CHILD_RECURSIVELY(frame, "ObjectHP_gauge_lv_right"):ShowWindow(0)
    GET_CHILD_RECURSIVELY(frame, "hero_object_gauge"):ShowWindow(0)
    GET_CHILD_RECURSIVELY(frame, "text_bosscount"):ShowWindow(0)
    GET_CHILD_RECURSIVELY(frame, "heroimage_bosscountdown"):ShowWindow(0)
    GET_CHILD_RECURSIVELY(frame, "text2_bosscount"):ShowWindow(0)
    GET_CHILD_RECURSIVELY(frame, "text3_bosscount"):ShowWindow(0)

    -- 속성 표기
    local argList = StringSplit(argStr, "/")
    local attribute = GET_CHILD_RECURSIVELY(frame, "attribute")
    local attributeClass = GetClass("TOSHeroAttribute", argList[1])

    attribute:SetImage(attributeClass.Image)
    attribute:SetTextTooltip(attributeClass.ToolTip)

    -- 버프 표기
    for idx = 1, 3 do
        local pic = GET_CHILD_RECURSIVELY(frame, "buff_"..idx)

        if #argList < idx + 1 then
            pic:SetImage("")
            pic:SetTextTooltip("")
        else
            local buffClass = GetClass("Buff", argList[idx + 1])
            
            pic:SetImage("icon_"..buffClass.Icon)
            pic:SetTextTooltip(buffClass.ToolTip)
        end
    end
end

function ON_TOSHERO_INFO_GAUGE_REFRESH(frame, msg, argStr, argNum)
    frame:ShowWindow(1)

    local argList = StringSplit(argStr, "/")

    local killCount = tonumber(argList[1])
    local targetKillCount = tonumber(argList[2])
    local progressGauge = GET_CHILD_RECURSIVELY(frame, "gauge_lv")
    local maxPic = GET_CHILD_RECURSIVELY(frame, "pic_max")

    progressGauge:SetMaxPointWithTime(killCount, targetKillCount, 0.1, 0.5)
    progressGauge:ShowWindow(1)

    if killCount >= targetKillCount then
        maxPic:ShowWindow(1)
    else
        maxPic:ShowWindow(0)
    end
end

function ON_TOSHERO_INFO_GAUGE_END()
    ui.CloseFrame('toshero_info_gauge')
end
function ON_TOSHERO_INFO_OBJECTHP(frame, msg, HP)
    local gauge = GET_CHILD_RECURSIVELY(frame, 'ObjectHP_gauge')
    local gauge_left = GET_CHILD_RECURSIVELY(frame, 'ObjectHP_gauge_lv_left')
    local gauge_right = GET_CHILD_RECURSIVELY(frame, 'ObjectHP_gauge_lv_right')
    local gauge_objectimage = GET_CHILD_RECURSIVELY(frame, 'hero_object_gauge')
    gauge:ShowWindow(1) 
    gauge_left:ShowWindow(1)
    gauge_right:ShowWindow(1)
    gauge_objectimage:ShowWindow(1)
    gauge:SetPoint(HP, 100)
end

function ON_TOSHERO_SHOW_SIMPLE_MSG(frame, msg, msgStr, msgStr2)
    local text = GET_CHILD_RECURSIVELY(frame, "text_bosscount")
    local image = GET_CHILD_RECURSIVELY(frame, "heroimage_bosscountdown")
    local text2 = GET_CHILD_RECURSIVELY(frame, "text2_bosscount")
    local text3 = GET_CHILD_RECURSIVELY(frame, "text3_bosscount")

    image:ShowWindow(1);
    text2:ShowWindow(1);
    text:ShowWindow(1);
    text3:ShowWindow(1);
    text:SetTextByKey("font", "");
    
	local sList = StringSplit(msgStr, "}");
	local number = 0;

    if #sList > 1 then
        number = tonumber(sList[2]);
    end

    local In_text2 = "{#FF0000}(-"..msgStr2.."){/}" 
    if number > 0 then
		text:SetTextByKey("text", msgStr);
		text3:SetTextByKey("text", In_text2);
	else
        text:SetTextByKey("text", "");
        image:ShowWindow(0);
        text2:ShowWindow(0);
        text3:ShowWindow(0);
	end
	frame:SetDuration(120);
end