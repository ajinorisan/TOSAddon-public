function SCR_EP13_F_SIAULIAI_3_SQ_02_CITIZEN_1_PRE_DIALOG(pc, dialog, handle)
    local result = SCR_QUEST_CHECK(pc,'EP13_F_SIAULIAI_3_SQ_02')
    local sObj = GetSessionObject(pc, "SSN_EP13_F_SIAULIAI_3_SQ_02")
    local value = 1
    local prop = TryGetProp(sObj, "QuestInfoValue"..value, 0)
    if result == 'PROGRESS' and prop == 0 then
        return 'YES'
    end
    return 'NO'
end


function SCR_EP13_F_SIAULIAI_3_SQ_02_CITIZEN_2_PRE_DIALOG(pc, dialog, handle)
    local result = SCR_QUEST_CHECK(pc,'EP13_F_SIAULIAI_3_SQ_02')
    local sObj = GetSessionObject(pc, "SSN_EP13_F_SIAULIAI_3_SQ_02")
    local value = 2
    local prop = TryGetProp(sObj, "QuestInfoValue"..value, 0)
    if result == 'PROGRESS' and prop == 0 then
        return 'YES'
    end
    return 'NO'
end


function SCR_EP13_F_SIAULIAI_3_SQ_02_CITIZEN_3_PRE_DIALOG(pc, dialog, handle)
    local result = SCR_QUEST_CHECK(pc,'EP13_F_SIAULIAI_3_SQ_02')
    local sObj = GetSessionObject(pc, "SSN_EP13_F_SIAULIAI_3_SQ_02")
    local value = 3
    local prop = TryGetProp(sObj, "QuestInfoValue"..value, 0)
    if result == 'PROGRESS' and prop == 0 then
        return 'YES'
    end
    return 'NO'
end


function SCR_EP13_F_SIAULIAI_3_SQ_02_CITIZEN_3_PRE_DIALOG(pc, dialog, handle)
    local result = SCR_QUEST_CHECK(pc,'EP13_F_SIAULIAI_3_SQ_02')
    local sObj = GetSessionObject(pc, "SSN_EP13_F_SIAULIAI_3_SQ_02")
    local value = 3
    local prop = TryGetProp(sObj, "QuestInfoValue"..value, 0)
    if result == 'PROGRESS' and prop == 0 then
        return 'YES'
    end
    return 'NO'
end


function SCR_EP13_F_SIAULIAI_3_SQ_02_CITIZEN_4_PRE_DIALOG(pc, dialog, handle)
    local result = SCR_QUEST_CHECK(pc,'EP13_F_SIAULIAI_3_SQ_02')
    local sObj = GetSessionObject(pc, "SSN_EP13_F_SIAULIAI_3_SQ_02")
    local value = 4
    local prop = TryGetProp(sObj, "QuestInfoValue"..value, 0)
    if result == 'PROGRESS' and prop == 0 then
        return 'YES'
    end
    return 'NO'
end

function SCR_EP13_F_SIAULIAI_3_SQ_02_CITIZEN_5_PRE_DIALOG(pc, dialog, handle)
    local result = SCR_QUEST_CHECK(pc,'EP13_F_SIAULIAI_3_SQ_02')
    local sObj = GetSessionObject(pc, "SSN_EP13_F_SIAULIAI_3_SQ_02")
    local value = 5
    local prop = TryGetProp(sObj, "QuestInfoValue"..value, 0)
    if result == 'PROGRESS' and prop == 0 then
        return 'YES'
    end
    return 'NO'
end