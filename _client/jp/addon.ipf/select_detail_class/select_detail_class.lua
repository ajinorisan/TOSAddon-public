function SELECT_DETAIL_CLASS_ON_INIT(addon, frame)
    addon:RegisterMsg('START_CHAR_SETTING', 'ON_START_CHAR_SETTING')
    addon:RegisterMsg('SUCCESS_CHAR_SETTING', 'ON_SUCCESS_CHAR_SETTING')
    addon:RegisterMsg('FAILED_CHAR_SETTING', 'ON_FAILED_CHAR_SETTING')
end

local function SELECT_DETAIL_CLASS_SET_PREVIEW_BASE_CHARACTER(apc, equip_list)
	-- 내 캐릭터의 가발 보이기/안보이기 설정에 따라 APC도 보이기/안보이기 설정을 해야 한다.
	local myPCetc = GetMyEtcObject()
	local hairWig_Visible = myPCetc.HAIR_WIG_Visible
	if hairWig_Visible == 1 then
		apc:SetHairWigVisible(true)
	else
		apc:SetHairWigVisible(false)
	end

	-- 기본 장착 아이템 설정
    local frame = ui.GetFrame("select_detail_class")
    local costumeName = frame:GetUserValue('COSTUME_NAME')
    local costumeCls = GetClass('Item', costumeName)
    if costumeName == nil then return end
	
    apc:SetEquipItem(10, TryGetProp(costumeCls, 'ClassID', 0))
end

function SELECT_DETAIL_CLASS_OPEN(frame)
    SELECT_DETAIL_CLASS_PAGE_SHOW(1)
    SELECT_DETAIL_CLASS_CREATE_CLASS_LIST()
end

function SELECT_DETAIL_CLASS_CLOSE(frame)
end

function SELECT_DETAIL_CLASS_CLICK_BTN_CLASS(parent, ctrl)
    if ui.CheckHoldedUI() == true then return end
    
    local ctrlset = ctrl:GetAboveControlset()
    if ctrlset == nil then return end

    local clsID = ctrlset:GetUserValue('CLASSID')
    local cls = GetClassByType('class_tree_recommend', clsID)
    if cls == nil then return end

    SELECT_DETAIL_CLASS_UPDATE_PAGE_SELECT(cls)
end

function SELECT_DETAIL_CLASS_VIDEO_CLICK(parent, ctrl)
    local playImg = GET_CHILD(ctrl, 'play')
    local state = ctrl:GetState()
    if state == 'PLAY' then
        playImg:ShowWindow(1)
        ctrl:Pause()
    else
        playImg:ShowWindow(0)
        ctrl:Play()
    end
end

function SELECT_DETAIL_CLASS_CREATE_CLASS_LIST()
    local frame = ui.GetFrame('select_detail_class')
    if frame == nil then return end

    local gFrame = GET_CHILD(frame, "gFrame")
    if gFrame == nil then return end

    local gbox = GET_CHILD(gFrame, "gbox")
    if gbox == nil then return end

    local gbPageMain = GET_CHILD(gbox, "gbPageMain")
    if gbPageMain == nil then return end
    
    local gbListClass = GET_CHILD(gbPageMain, "gbListClass", "ui::CGroupBox")
    if gbListClass == nil then return end

    local jobClassID = 0
    local etc = GetMyEtcObject()
    if etc.RepresentationClassID ~= 'None' then
        local repreJobCls = GetClassByType('Job', etc.RepresentationClassID)
        if repreJobCls ~= nil then
            jobClassID = repreJobCls.ClassID
        end
    end
    
    local jobCls = GetClassByType('Job', jobClassID)
    if jobCls == nil then return end

    local jobType = TryGetProp(jobCls, "CtrlType", "None")
    if jobType == "None" then return end

    -- Get List
    local jobClsList = {}
    local clsList, cnt = GetClassList('class_tree_recommend')
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(clsList, i)
        local baseClassType = TryGetProp(cls, "CtrlType", 0)
        local CtrlType = TryGetProp(GetClassByType("Job", baseClassType), "CtrlType", "None")
        if CtrlType == jobType then
            jobClsList[#jobClsList + 1] = cls
        end
    end
    if #jobClsList <= 0 then return end

    -- Create Control
    gbListClass:RemoveAllChild()
    
    local x = 0
    for i = 1, #jobClsList do
        local cls = jobClsList[i]
        local ctrlSet = gbListClass:CreateOrGetControlSet('selectdetailclass_class', 'list_class_' .. i, ui.LEFT, ui.TOP, x, 0, 0, 0)
        SELECT_DETAIL_CLASS_UPDATE_CLASS_LIST(ctrlSet, cls, i)
        x = x + ctrlSet:GetWidth() + 2
    end
    
end

function SELECT_DETAIL_CLASS_UPDATE_CLASS_LIST(ctrlSet, cls, i)
    if ctrlSet == nil then return end
    if cls == nil then return end

    local gender = GETMYPCGENDER()
    local desc = GET_CHILD(ctrlSet, "desc")
    local class_pic = GET_CHILD(ctrlSet, "class_pic")
    local char_pic = GET_CHILD(ctrlSet, "char_pic")
    local abbr = GET_CHILD_RECURSIVELY(ctrlSet, "class_abbr")
    local abbr_bg = GET_CHILD_RECURSIVELY(ctrlSet, "abbr_bg")

    -- Set Control
    desc:SetTextByKey('value', ClMsg(TryGetProp(cls, 'Concept', 'None')))
    local tail = 'm'
    if gender == 1 then
        tail = 'm'
    elseif gender == 2 then
        tail = 'f'
    end
    class_pic:SetImage(TryGetProp(cls, 'ClassCompImage', 'None'))
    local charImgName = string.format(TryGetProp(cls, 'ClassCharImage', 'None'), tail)
    char_pic:SetImage(charImgName)
    abbr:SetTextByKey('value', ClMsg(TryGetProp(cls, 'Name', 'None')))
    abbr_bg:SetTextTooltip(ClMsg('SelectClass_Summary_' .. cls.ClassID))

    -- Set Uservalue
    ctrlSet:SetUserValue('CLASSID', cls.ClassID)
end

-- 1: main
-- 2: select
function SELECT_DETAIL_CLASS_PAGE_SHOW(page)
    local frame = ui.GetFrame("select_detail_class")
    if frame == nil then return end

    local gFrame = GET_CHILD(frame, "gFrame")
    if gFrame == nil then return end

    local gbox = GET_CHILD(gFrame, "gbox")
    if gbox == nil then return end

    local titlegbox = GET_CHILD(gFrame, "titlegbox", "ui::CGroupBox")
    if titlegbox == nil then return end

    local gbPageMain = GET_CHILD(gbox, "gbPageMain", "ui::CGroupBox")
    if gbPageMain == nil then return end

    local gbPageSelect = GET_CHILD(gbox, "gbPageSelect", "ui::CGroupBox")
    if gbPageSelect == nil then return end

    if page == 1 then
        local width = tonumber(frame:GetUserConfig("TITLE_WIDTH_MAIN"))
        titlegbox:Resize(width, titlegbox:GetHeight())
        gbPageMain:ShowWindow(1)
        gbPageSelect:ShowWindow(0)
    elseif page == 2 then
        local width = tonumber(frame:GetUserConfig("TITLE_WIDTH_SELECT"))
        titlegbox:Resize(width, titlegbox:GetHeight())
        gbPageMain:ShowWindow(0)
        gbPageSelect:ShowWindow(1)
    end
end

function SELECT_DETAIL_CLASS_UPDATE_PAGE_SELECT(cls)
    if cls == nil then return end

    local frame = ui.GetFrame("select_detail_class")
    if frame == nil then return end

    local gFrame = GET_CHILD(frame, 'gFrame', 'ui::CGroupBox')
    if gFrame == nil then return end

    local gbox = GET_CHILD(gFrame, 'gbox', 'ui::CGroupBox')
    if gbox == nil then return end
    
    local titlegbox = GET_CHILD(gFrame, "titlegbox", "ui::CGroupBox")
    if titlegbox == nil then return end

    local gbPageMain = GET_CHILD(gbox, 'gbPageMain', 'ui::CGroupBox')
    if gbPageMain == nil then return end

    local gbPageSelect = GET_CHILD(gbox, 'gbPageSelect', 'ui::CGroupBox')
    if gbPageSelect == nil then return end

    local gbClassAbbr = GET_CHILD_RECURSIVELY(gbPageSelect, 'gbClassAbbr')
    local textClassAbbr = GET_CHILD_RECURSIVELY(gbPageSelect, 'textClassAbbr')
    local textDescAbbr = GET_CHILD_RECURSIVELY(gbPageSelect, 'textDescAbbr')
    if textDescAbbr == nil then return end

    local width = tonumber(frame:GetUserConfig("TITLE_WIDTH_SELECT"))
    titlegbox:Resize(width, titlegbox:GetHeight())

    if gbClassAbbr ~= nil then
        gbClassAbbr:SetTextTooltip(ClMsg('SelectClass_Summary_' .. cls.ClassID))
    end

    if textClassAbbr ~= nil then
        textClassAbbr:SetTextByKey("value", ClMsg(TryGetProp(cls, "Name", "None")))
    end
    
    if textDescAbbr ~= nil then
        textDescAbbr:SetTextByKey("value", ClMsg(TryGetProp(cls, "Desc", "None")))
    end
    
    local video = GET_CHILD_RECURSIVELY(gbPageSelect, 'video')
    local playImg = GET_CHILD(video, 'play')
    if video ~= nil then
        video:Stop()
        local gender = GETMYPCGENDER()
        if gender == 1 then
            video:SetVideoName(TryGetProp(cls, "Movie"))
        elseif gender == 2 then
            video:SetVideoName(TryGetProp(cls, "Movie"))
        end
        playImg:ShowWindow(0)
        video:Play()
    end

    for i = 1, 4 do
        local class_ctrlset = GET_CHILD_RECURSIVELY(gbPageSelect, 'class' .. i)
        local jobClassID = TryGetProp(cls, 'CtrlType', 0)
        if i > 1 then
            jobClassID = TryGetProp(cls, 'Tree_' .. (i - 1), 0)
        end

        SELECT_DETAIL_CLASS_FILL_SELECT_CLASSINFO(class_ctrlset, jobClassID, i)

        local costume_btn = GET_CHILD_RECURSIVELY(class_ctrlset, 'costume_btn')
        if i == 1 then
            costume_btn:SetImage('js_preview_btn_check')
        else
            costume_btn:SetImage('js_preview_btn')
        end
    end

    local gbPreview = GET_CHILD_RECURSIVELY(frame, 'gbPreview')
    if gbPreview ~= nil then
        local ctrlTypeID = TryGetProp(cls, "CtrlType", 0)
        local defCostume = TryGetProp(GetClassByType("Job", ctrlTypeID), "DefaultCostume", "None")
        frame:SetUserValue('COSTUME_NAME', defCostume)
        for i = 1, 4 do
            local poseBtn = GET_CHILD_RECURSIVELY(frame, 'btnPreviewAction' .. i)
            local imageName = 'js_motion_btn_0' .. i
            if i == 1 then
                imageName = 'js_motion_btn_check_0' .. i
            end
    
            poseBtn:SetImage(imageName)
        end
        frame:SetUserValue('ANIM_NAME', 'STD')
        
        SELECT_DETAIL_CLASS_SET_APC(frame, 0)
    end

    gbPageMain:ShowWindow(0)
    gbPageSelect:ShowWindow(1)

    frame:SetUserValue("SELECT_CLASS", TryGetProp(cls, "ClassName", "None"))
end

function SELECT_DETAIL_CLASS_FILL_SELECT_CLASSINFO(ctrlSet, jobClassID, index)
    if ctrlSet == nil then return end

    local class_icon = GET_CHILD_RECURSIVELY(ctrlSet, "class_icon", "ui::CPicture")
    if class_icon == nil then return end

    local class_name = GET_CHILD_RECURSIVELY(ctrlSet, "class_name", "ui::CRichText")
    if class_name == nil then return end

    local costume_btn = GET_CHILD_RECURSIVELY(ctrlSet, "costume_btn", "ui::CButton")
    if costume_btn == nil then return end

    local jobCls = GetClassByType("Job", jobClassID)
    if jobCls == nil then return end

    local jobName = TryGetProp(jobCls, "Name", "None")
    if index == 1 then
        jobName = string.format('{@st41}{s18}%s{/}{/}', jobName)
    end

    class_icon:SetImage(TryGetProp(jobCls, "Icon", "None"))
    class_name:SetTextByKey("value", jobName)
    costume_btn:SetEventScript(ui.LBUTTONUP, "SELECT_DETAIL_CLASS_CLICK_COSTUME_BTN")
    costume_btn:SetEventScriptArgString(ui.LBUTTONUP, TryGetProp(jobCls, "DefaultCostume", "None"))
    costume_btn:SetEventScriptArgNumber(ui.LBUTTONUP, index)
end

function SELECT_DETAIL_CLASS_CLICK_BTN_COMPLETE()
    if ui.CheckHoldedUI() == true then return end

    local frame = ui.GetFrame("select_detail_class")
    local selectClass = frame:GetUserValue("SELECT_CLASS")
    local cls = GetClass("class_tree_recommend", selectClass)
    if cls == nil then return end

    local yesScp = 'SELECT_DETAIL_CLASS_SELECT_EXCUTE()'
    ui.MsgBox_NonNested(ScpArgMsg('SelectClass_ConfirmPopup{JOBNAME}', 'JOBNAME', ClMsg(TryGetProp(cls, 'Name', 'None'))), frame:GetName(), yesScp, 'None')
end

function SELECT_DETAIL_CLASS_SELECT_EXCUTE()
    local frame = ui.GetFrame("select_detail_class")
    local selectClass = frame:GetUserValue("SELECT_CLASS")
    local cls = GetClass("class_tree_recommend", selectClass)
    if cls == nil then
        ui.SysMsg(ClMsg('PlzSelectClassComp'))
        return
    end
    
    -- if CHECK_SELECT_DETAIL_CLASS(GetMyPCObject()) == false then
    --     return false
    -- end

    ui.SetHoldUI(true)

	control.CustomCommand("REQ_CHAR_SETTING", cls.ClassID)
end

function SELECT_DETAIL_CLASS_CLICK_BTN_RETURN(parent, btn)
    if ui.CheckHoldedUI() == true then return end

    local frame = parent:GetTopParentFrame()
    frame:SetUserValue('SELECT_CLASS', 'None')
    SELECT_DETAIL_CLASS_PAGE_SHOW(1)
end

function SELECT_DETAIL_CLASS_SET_APC(frame, dir)
    local pcSession = session.GetMySession()
    if pcSession == nil then
        return
    end

    -- 직업 코스튬 끼우기.
    local apc = pcSession:GetPCDummyApc()
    SELECT_DETAIL_CLASS_SET_PREVIEW_BASE_CHARACTER(apc)

    -- 갱신
    local shihouette = GET_CHILD_RECURSIVELY(frame, "picSilhouette")
    local imgName = "None"
    local animName = frame:GetUserValue('ANIM_NAME')
    -- rotDir은 1, 2 밖에 없고 0을 던질 경우 정면 이름을 반환한다. (1,2는 회전)
    -- 제자리를 그리려면 1로 넘겨서 이름을 받고 다시 2를 넘겨서 받아야 한다.
    -- rotDir이 99로 넘어오면 제자리를 보여주는 것으로 판단하고 두번 조작한다.
    if dir == 99 then
        imgName = ui.CaptureMyFullStdImageByAPC(apc, 1, 0, animName)
        imgName = ui.CaptureMyFullStdImageByAPC(apc, 2, 0, animName)
    else 
        imgName = ui.CaptureMyFullStdImageByAPC(apc, dir, 0, animName)
    end

    shihouette:SetImage(imgName)
    frame:Invalidate()
end

-- strArg: costume classname
function SELECT_DETAIL_CLASS_CLICK_COSTUME_BTN(parent, ctrl, strArg, numArg)
    if ui.CheckHoldedUI() == true then return end
    
    local frame = parent:GetTopParentFrame()
    if frame == nil then return end

    for i = 1, 4 do
        local jobCtrlset = GET_CHILD_RECURSIVELY(frame, 'class' .. i)
        local costume_btn = GET_CHILD_RECURSIVELY(jobCtrlset, 'costume_btn')
        local imageName = 'js_preview_btn'
        if i == numArg then
            imageName = 'js_preview_btn_check'
        end

        costume_btn:SetImage(imageName)
    end

    frame:SetUserValue('COSTUME_NAME', strArg)

    SELECT_DETAIL_CLASS_SET_APC(frame, 99)
end

function SELECT_DETAIL_CLASS_CLICK_TURN_BTN(parent, ctrl, strArg, numArg)
    if ui.CheckHoldedUI() == true then return end
    
    local frame = parent:GetTopParentFrame()
    local dir = 0
    if strArg == 'right' then
        dir = 1
    elseif strArg == 'left' then
        dir = 2
    end

    SELECT_DETAIL_CLASS_SET_APC(frame, dir)
end

-- numArg: 1~4
function SELECT_DETAIL_CLASS_CLICK_BTN_PREVIEW_ACTION(parent, ctrl, strArg, numArg)
    local frame = parent:GetTopParentFrame()
    if frame == nil then return end

    for i = 1, 4 do
        local poseBtn = GET_CHILD_RECURSIVELY(frame, 'btnPreviewAction' .. i)
        local imageName = 'js_motion_btn_0' .. i
        if i == numArg then
            imageName = 'js_motion_btn_check_0' .. i
        end

        poseBtn:SetImage(imageName)
    end

    frame:SetUserValue('ANIM_NAME', strArg)

    SELECT_DETAIL_CLASS_SET_APC(frame, 99)
end

function UPDATE_CHAR_SETTING_MSG(frame, elapsedTime)
    frame = frame:GetTopParentFrame()
    local sec_before = frame:GetUserIValue('MSG_UPDATE_SEC')
    local cur_sec, time_remainder = math.modf(elapsedTime)
    if cur_sec > sec_before then
        local msgStr = ClMsg('DoingCharacterSettingNow')
        local cnt = cur_sec % 3
        for i = 1, cnt do
            msgStr = msgStr .. '.'
        end
        INFO_MSG_BOX_SET_TXT(msgStr)
        frame:SetUserValue('MSG_UPDATE_SEC', cur_sec)
    end
    return 1
end

function ON_START_CHAR_SETTING(frame, msg, argStr, argNum)
    ui.OpenFrame('info_msg_box')
    local msg_frame = ui.GetFrame('info_msg_box')
    msg_frame:RunUpdateScript('UPDATE_CHAR_SETTING_MSG', 0, 0, 0, 1)
end

function ON_SUCCESS_CHAR_SETTING(frame, msg, argStr, argNum)
    local msg_frame = ui.GetFrame('info_msg_box')
    msg_frame:StopUpdateScript('UPDATE_CHAR_SETTING_MSG')
    INFO_MSG_BOX_CLOSE()
    ui.SetHoldUI(false)
    frame:ShowWindow(0)
end

function ON_FAILED_CHAR_SETTING(frame, msg, argStr, argNum)
    ui.SetHoldUI(false)
end

function SELECT_DETAIL_CLASS_DISCARD_SELECT(parent, ctrl)
    local yesscp = '_SELECT_DETAIL_CLASS_DISCARD_SELECT'
    local option = {}
	option.ChangeTitle = nil
	option.CompareTextColor = "{#ffa200}"
	option.CompareTextDesc = nil
    WARNINGMSGBOX_EX_FRAME_OPEN(frame, nil, 'ReallyDiscardSpecialCreateTicket' .. ';AgreeDiscardSpecialCreateTicket/' .. yesscp, 0, option)
end

function _SELECT_DETAIL_CLASS_DISCARD_SELECT()
    ui.CloseFrame('select_detail_class')
    control.CustomCommand('RESUME_FIRSTPLAY_TUTORIAL', 1)
end