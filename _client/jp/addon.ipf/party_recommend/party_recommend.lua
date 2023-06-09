local MAX_SHOW_COUNT = 4;

function PARTY_RECOMMEND_ON_INIT(addon, frame)
    addon:RegisterMsg('OPEN_SELECT_TARGET', 'OPEN_SELECT_TARGET_FROM_PARTY');
    addon:RegisterMsg('OPEN_SELECT_TARGET_SUMMON', 'OPEN_SELECT_TARGET_FROM_SUMMON');
    addon:RegisterMsg('OPEN_SELECT_BUFF', 'OPEN_SELECT_BUFF_FROM_LIST');
    addon:RegisterMsg('OPEN_SELECT_ANCIENT', 'OPEN_SELECT_ANCIENT_FROM_LIST');
end

function PARTY_RECOMMEND_CLOSE(frame)
    local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer")
	timer:Stop()
end

function PARTY_RECOMMEND_BUFF_UPDATE(frame, timer, argStr, argNum, passedTime)
    local ancientList, ancientCnt = GetAncientHandleList()
    if ancientList == nil or ancientCnt <= 0 then
        return
    end

    for i = 1, ancientCnt do
        local memberSet = GET_CHILD_RECURSIVELY(frame, 'memberSet_'..i)
        local ancientHandle = ancientList[i]
        local buffBg = GET_CHILD(memberSet, 'buffBg')
        if buffBg ~= nil then
            local slot = GET_CHILD(buffBg, 'buffSlot')
            local time = GET_CHILD(buffBg, 'buffTime')
            if slot ~= nil and slot:IsVisible() == 1 and time ~= nil then
                local icon = slot:GetIcon()
                local buffName = 'Ancient_Heal_Effect_Buff'
                local targetBuff = info.GetBuffByName(ancientHandle, buffName)
                local buffCls = GetClass('Buff', buffName)
                if buffCls ~= nil and targetBuff ~= nil then
                    SET_BUFF_TIME_TO_TEXT(time, targetBuff.time)
                    if targetBuff.time < 5000 and targetBuff.time ~= 0.0 then
                        if slot:IsBlinking() == 0 then
                            slot:SetBlink(600000, 1.0, "55FFFFFF", 1)
                        end
                    else
                        if slot:IsBlinking() == 1 then
                            slot:ReleaseBlink()
                        end
                    end
                else
                    slot:ClearIcon()
                    time:SetText('')
                end
            end
        end
    end
end

function PARTY_RECOMMEND_DEFAULT_SETTING(frame, skillID)
    -- selected index initialize
    frame:SetUserValue('prev_selected', 0);

    -- skill
    local skillCls = GetClassByType('Skill', skillID);
    if skillCls == nil then
        ui.CloseFrame('party_recommend');
        return;
    end
    
    local skillSlot = GET_CHILD_RECURSIVELY(frame, 'skillSlot');
    local icon = skillSlot:GetIcon();
    if icon == nil then
        icon = CreateIcon(skillSlot);
    end
    icon:SetImage('icon_'..skillCls.Icon);

    -- default init
    for i = 1, MAX_SHOW_COUNT do
        local memberSet = GET_CHILD_RECURSIVELY(frame, 'memberSet_'..i);
        local fan = GET_CHILD_RECURSIVELY(frame, 'fan_'..i);
        memberSet:ShowWindow(0);
        fan:ShowWindow(0);
    end
end

function PARTY_RECOMMEND_CANCEL_SETTING(frame)
    -- cancel key
    local cancelText = GET_CHILD_RECURSIVELY(frame, 'cancelText');
    config.InitHotKeyByCurrentUIMode('Battle');    

    local jumpKeyIdx = config.GetHotKeyElementIndex('ID', 'Jump');
    local jumpKey = config.GetHotKeyElementAttributeForConfig(jumpKeyIdx, 'Key');
    if IsJoyStickMode() == 1 then
        jumpKey = "X";
    end
    
    if string.find(jumpKey, "NUMPAD") ~= nil then
        local find_start, find_end = string.find(jumpKey, "NUMPAD");
        jumpKey = string.sub(jumpKey, find_end + 1, string.len(jumpKey));
    end

    local useShift = config.GetHotKeyElementAttributeForConfig(jumpKeyIdx, "UseShift");
    local useAlt = config.GetHotKeyElementAttributeForConfig(jumpKeyIdx, "UseAlt");
    local useCtrl = config.GetHotKeyElementAttributeForConfig(jumpKeyIdx, "UseCtrl");

    local KEY_IMG_SIZE = tonumber(frame:GetUserConfig('KEY_IMG_SIZE'));
    local imgName = 'key_'..jumpKey;
    local originImgWidth = ui.GetImageWidth(imgName);
    local originImgHeight = ui.GetImageHeight(imgName);
    local sizeAmendCoeff = KEY_IMG_SIZE / originImgWidth;

    local jumpKeyImg = string.format('{img %s %d %d}', imgName, KEY_IMG_SIZE, originImgHeight * sizeAmendCoeff);

    if useShift == 'YES' then
        jumpKeyImg = string.format('{img SHIFT %d %d}', KEY_IMG_SIZE, KEY_IMG_SIZE)..jumpKeyImg;
    end

    if useAlt == 'YES' then
        jumpKeyImg = string.format('{img alt %d %d}', KEY_IMG_SIZE, KEY_IMG_SIZE)..jumpKeyImg;
    end

    if useCtrl == 'YES' then
        jumpKeyImg = string.format('{img ctrl %d %d}', KEY_IMG_SIZE, KEY_IMG_SIZE)..jumpKeyImg;
    end

    if IsJoyStickMode() == 0 then
        cancelText:SetTextByKey('img', jumpKeyImg);
    end

    if IsJoyStickMode() == 1 then
        jumpKeyImg = string.format('{img %s %d %d}', "a_button", KEY_IMG_SIZE, originImgHeight * sizeAmendCoeff);
        cancelText:SetTextByKey('img', jumpKeyImg);
    end
end

function OPEN_SELECT_TARGET_FROM_PARTY(frame, msg, argStr, showHPGauge)
    -- skill
    local skillID = geSkillControl.GetSelectTargetFromPartyListSkillID();
    PARTY_RECOMMEND_DEFAULT_SETTING(frame, skillID)
    
    -- party member
    local myMapName = session.GetMapName();
    local myMapCls = GetClass('Map', myMapName);
    local partyList = session.party.GetPartyMemberList(PARTY_NORMAL);    
    local emphasizePic = nil;
    local emphasizeValue = nil;

    if partyList ~= nil then
        local count = partyList:Count();
        local index = 1;
        for i = 0, count - 1 do
            local partyMemberInfo = partyList:Element(i);
            if partyMemberInfo ~= nil and (partyMemberInfo:GetAID() == session.loginInfo.GetAID() or partyMemberInfo:GetName() == 'None') then
            -- 자기 자신일때에는 표시하지 않는다.
            else
                local memberSet = GET_CHILD_RECURSIVELY(frame, 'memberSet_'..index);
                local jobEmblemPic = GET_CHILD(memberSet, 'jobEmblemPic');
                local iconinfo = partyMemberInfo:GetIconInfo();
                local jobCls = GetClassByType("Job", iconinfo.repre_job);
                if nil ~= jobCls and jobEmblemPic ~= nil then
                    jobEmblemPic:SetImage(jobCls.Icon);
                end

                local lvText = GET_CHILD(memberSet, 'lvText');
                if lvText ~= nil then
                    lvText:SetTextByKey('lv', partyMemberInfo:GetLevel());
                end 

                local nameText = GET_CHILD(memberSet, 'nameText');
                if nameText ~= nil then
                    nameText:SetTextByKey('name', partyMemberInfo:GetName());                    
                end 

                local stat = partyMemberInfo:GetInst();
                local hpGauge = GET_CHILD(memberSet, 'hpGauge');
                if hpGauge ~= nil then
                    hpGauge:SetPoint(stat.hp, stat.maxhp);
                    hpGauge:ShowWindow(showHPGauge);
                end

                if showHPGauge == 1 then
                    if emphasizeValue == nil or (stat.hp < stat.maxhp and emphasizeValue < stat.hp) then
                        emphasizeValue = stat.hp;
                        emphasizePic = memberSet;
                    end
                end

                local buffBg = GET_CHILD(memberSet, 'buffBg')
                if buffBg ~= nil then
                    buffBg:ShowWindow(0)
                end

                if memberSet ~= nil then
                    memberSet:ShowWindow(1);
                end
                
                geSkillControl.SetPartyMemberTarget(index, partyMemberInfo:GetAID(), argStr);
                index = index + 1;
            end
        end
    end

    PARTY_RECOMMEND_CANCEL_SETTING(frame);

    frame:ShowWindow(1);
    geSkillControl.CheckDistancePartyMemberTarget();
end

function SELECT_TARGET_FROM_PARTY_SET_TARGET(index, outRange)
    local frame = ui.GetFrame('party_recommend');    
    local color = frame:GetUserConfig("NEAR_MEMBER_COLORTONE");

    local prev_selected = frame:GetUserIValue('prev_selected');
    if index ~= prev_selected then
        local select_sound = frame:GetUserConfig('SELECT_SOUND');
        imcSound.PlaySoundEvent(select_sound);
        frame:SetUserValue('prev_selected', index);
    end

    for i = 1, MAX_SHOW_COUNT do
        local fan = GET_CHILD_RECURSIVELY(frame, 'fan_'..i);
        local memberSet = GET_CHILD_RECURSIVELY(frame, 'memberSet_'..i);
        local jobEmblemPic = nil;
        if memberSet ~= nil then
            jobEmblemPic = GET_CHILD_RECURSIVELY(memberSet, 'jobEmblemPic');
        end

        if i == index then
            fan:ShowWindow(1);

            if outRange == true then
                color = frame:GetUserConfig("FAR_MEMBER_COLORTONE");
            end
            
            if fan ~= nil and jobEmblemPic ~= nil then
                fan:SetColorTone(color);
                jobEmblemPic:SetColorTone(color);
            end
        else
            fan:ShowWindow(0);
        end
    end
end

function CHECKDIST_SELECT_TARGET_FROM_PARTY(index, outRange, is_unrecoverState)    
    local frame = ui.GetFrame("party_recommend");
    if frame == nil then return; end

    local color = frame:GetUserConfig("NEAR_MEMBER_COLORTONE");
    local fan = GET_CHILD_RECURSIVELY(frame, "fan_"..index);
    if fan == nil then return; end

    local memberSet = GET_CHILD_RECURSIVELY(frame, "memberSet_"..index);
    if memberSet == nil then return; end

    local jobEmblemPic = GET_CHILD_RECURSIVELY(memberSet, "jobEmblemPic");
    if jobEmblemPic == nil then return; end

    if outRange == true then
        color = frame:GetUserConfig("FAR_MEMBER_COLORTONE");        
    else
        if is_unrecoverState == true then
            color = 'FFFF0000'         
        end
    end

    fan:SetColorTone(color);
    jobEmblemPic:SetColorTone(color);
end

------ set target from summoned monster ------
function OPEN_SELECT_TARGET_FROM_SUMMON(frame, msg, argStr)
    -- skill
    local skillID = geSkillControl.GetSelectSummonTargetSkillID();
    PARTY_RECOMMEND_DEFAULT_SETTING(frame, skillID);
    
    -- summoned monsters
    local emphasizePic = nil;
    local emphasizeValue = nil;
    local index = 1;

    for j = 0, 2 do
        local summonSklID = hardSkill.GetSummonSkillIDByIndex(j);
        local summonList = hardSkill.GetSummonHandleList(summonSklID);
        if summonList ~= nil then
            local count = summonList:Count();
            local memberSet = GET_CHILD_RECURSIVELY(frame, 'memberSet_'..index);
            local skillPic = GET_CHILD(memberSet, 'jobEmblemPic');
            local sklCls = GetClassByType("Skill", summonSklID);
            if nil ~= sklCls and skillPic ~= nil then
                skillPic:SetImage('Icon_' .. sklCls.Icon);
            end
            
            local lvText = GET_CHILD(memberSet, 'lvText');
            if lvText ~= nil then
                lvText:ShowWindow(0);
            end 
            
            local nameText = GET_CHILD(memberSet, 'nameText');
            if nameText ~= nil then
                nameText:SetTextByKey('name', count);
            end
            
            local hpGauge = GET_CHILD(memberSet, 'hpGauge');
            if hpGauge ~= nil then
                hpGauge:ShowWindow(0);
            end

            local buffBg = GET_CHILD(memberSet, 'buffBg')
            if buffBg ~= nil then
                buffBg:ShowWindow(0)
            end
            
            if memberSet ~= nil then
                memberSet:ShowWindow(1);
            end
            
            if count > 0 then
                -- 해당 종류의 해골이 1마리 이상 존재한다면 소환된 순서로 희생시키기 위해 0번째 인덱스의 핸들을 지정함
                local summonHandle = summonList:Element(0);
                geSkillControl.SetSummonTargetHandle(index, summonHandle);
            end
            index = index + 1;
        end
    end

    PARTY_RECOMMEND_CANCEL_SETTING(frame);

    frame:ShowWindow(1);
    geSkillControl.CheckDistanceSummonTarget();
end

------ set buff from custom list ------
function OPEN_SELECT_BUFF_FROM_LIST(frame, msg, argStr)
    -- skill
    local skillID = geSkillControl.GetSelectBuffSkillID();
    PARTY_RECOMMEND_DEFAULT_SETTING(frame, skillID);
    -- buff setting
    for j = 1, MAX_SHOW_COUNT do
        local memberSet = GET_CHILD_RECURSIVELY(frame, 'memberSet_'..j);
        local buffID = geSkillControl.GetBuffIDByIndex(j);
        local buffCls = GetClassByType("Buff", buffID);
        if buffCls ~= nil then
            local buffName = TryGetProp(buffCls, "Name");
            local buffPic = GET_CHILD(memberSet, 'jobEmblemPic');
            if buffPic ~= nil then
                -- 버프 선택 커맨드는 Check dist를 돌리지 않으므로 여기서 밝은 톤으로 세팅 해줘야 함
                local nearColor = frame:GetUserConfig("NEAR_MEMBER_COLORTONE");
                buffPic:SetImage('Icon_' .. buffCls.Icon);
                buffPic:SetColorTone(nearColor);
            end

            local lvText = GET_CHILD(memberSet, 'lvText');
            if lvText ~= nil then
                lvText:ShowWindow(0);
            end 

            local nameText = GET_CHILD(memberSet, 'nameText');
            if nameText ~= nil then
                nameText:SetTextByKey('name', buffName);
            end

            local hpGauge = GET_CHILD(memberSet, 'hpGauge');
            if hpGauge ~= nil then
                hpGauge:ShowWindow(0);
            end

            local buffBg = GET_CHILD(memberSet, 'buffBg')
            if buffBg ~= nil then
                buffBg:ShowWindow(0)
            end

            if memberSet ~= nil then
                memberSet:ShowWindow(1);
            end
        end
    end

    PARTY_RECOMMEND_CANCEL_SETTING(frame);

    frame:ShowWindow(1);
end

------ set target from ancient ------
function OPEN_SELECT_ANCIENT_FROM_LIST(frame, msg, argStr, showHPGauge)
    if frame ~= nil then
        local timer = GET_CHILD_RECURSIVELY(frame, "addontimer")
        tolua.cast(timer, "ui::CAddOnTimer")
        timer:SetUpdateScript("PARTY_RECOMMEND_BUFF_UPDATE")
        timer:Start(0.45)
    end
    -- skill
    local skillID = geSkillControl.GetSelectAncientTargetSkillID()
    PARTY_RECOMMEND_DEFAULT_SETTING(frame, skillID)
    
    local emphasizePic = nil
    local emphasizeValue = nil
    local index = 1

    local ancientList, ancientCnt = GetAncientHandleList()
    for i = 1, ancientCnt do
        local ancientHandle = ancientList[i]
        local ancientInfo = session.ancient.GetMonsterByHandle(ancientHandle)
        if ancientInfo ~= nil then
            local ancientMon = GetClassByType('Monster', ancientInfo.classID)
            local ancientCard = session.ancient.GetAncientCardBySlot(ancientInfo.slot)
            if ancientMon ~= nil and ancientCard ~= nil then
                local memberSet = GET_CHILD_RECURSIVELY(frame, 'memberSet_'..index)

                if memberSet ~= nil then
                    memberSet:ShowWindow(1)
                end

                local iconPic = GET_CHILD(memberSet, 'jobEmblemPic')
                if iconPic ~= nil then
                    iconPic:SetImage(ancientMon.Icon)
                end
                
                local lvText = GET_CHILD(memberSet, 'lvText')
                if lvText ~= nil then
                    local exp = ancientCard:GetStrExp()
                    local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
                    local level = xpInfo.level
                    lvText:SetTextByKey('lv', level)
                end 
                
                local nameText = GET_CHILD(memberSet, 'nameText')
                if nameText ~= nil then
                    nameText:SetTextByKey('name', dic.getTranslatedStr(ancientMon.Name))
                end
                
                local hpGauge = GET_CHILD(memberSet, 'hpGauge')
                if hpGauge ~= nil then
                    local stat = info.GetStat(ancientHandle)
                    if stat == nil then
                        hpGauge:ShowWindow(0)
                    else
                        hpGauge:SetPoint(stat.HP, stat.maxHP)
                        hpGauge:ShowWindow(showHPGauge)
                    end
                end

                local buffBg = GET_CHILD(memberSet, 'buffBg')
                if buffBg ~= nil then
                    buffBg:ShowWindow(1)

                    local buffSlot = GET_CHILD(buffBg, 'buffSlot')
                    local buffTime = GET_CHILD(buffBg, 'buffTime')
                    if buffSlot ~= nil and buffTime ~= nil then
                        buffSlot:ShowWindow(1)
                        CreateIcon(buffSlot)
                        buffTime:ShowWindow(1)
                        local buffName = 'Ancient_Heal_Effect_Buff'
                        local buffCls = GetClass('Buff', buffName)
                        local targetBuff = info.GetBuffByName(ancientHandle, buffName)
                        if buffCls ~= nil and targetBuff ~= nil then
                            SET_BUFF_SLOT(buffSlot, buffTime, buffCls, TryGetProp(buffCls, 'ClassID', 0), ancientHandle, nil, 0, false)
                        end
                    end
                end

                geSkillControl.SetAncientTargetHandle(index, ancientHandle, argStr)
                
                index = index + 1
            end
        end
    end

    PARTY_RECOMMEND_CANCEL_SETTING(frame)

    frame:ShowWindow(1)
    geSkillControl.CheckDistanceAncientTarget()
end