-- shared_character_change.lua
-- character_change.lua

-- 캐릭터 체인지 가능 조건 체크
function CHECK_CHARACTER_CHANGE_CONDITION(pc)
    if IsBuffApplied(pc, "ChangeCharacterState") == "YES" then
        return true;
    else
        if IsServerSection() == 1 then
            local cmd = GetMGameCmd(pc);
            if cmd ~= nil and cmd:IsCharacterChangeState() == true then
                return true;
            end
        end
    end
    SendSysMsg(pc, "CantChangeCharacterState");
    return false;
end

-- 쿨다운 감소 등을 구현할 때 사용됨
function GET_CHARACTER_CHANGE_COOLDOWN(pc)
    local ret = 1
    if IsServerSection() == 1 then
    else
        pc = GetMyPCObject()
    end
    return ret
end

-- 추가 슬롯(덱) 개수를 리턴함
function GET_CHARACTER_CHANGE_SLOT_COUNT(pc, acc)
    local base = 2
    local value = TryGetProp(acc, "CharacterChangeMaxSlotCount", 0);
    local ret = base + value;
    return ret; -- 기본 2개 제공
end

-- 현재 등록 되어 있는 캐릭터인지 체크
function IS_REGISTERED_CHARACTER(pc, slot)
    if IsServerSection() == 1 then
        if pc ~= nil then
            local etc_object = GetETCObject(pc);
            if etc_object ~= nil then
                local prop_name = "CharacterChangeSlot_"..tostring(slot);
                local value = TryGetProp(etc_object, prop_name, "None");
                if value ~= nil and value ~= "None" then
                    return true;
                end
            end
        end
    else
        local etc_object = GetMyEtcObject();
        if etc_object ~= nil then
            local prop_name = "CharacterChangeSlot_"..tostring(slot);
            local value = TryGetProp(etc_object, prop_name, "None");
            if value ~= nil and value ~= "None" then
                return true;
            end
        end
    end
    return false;
end
