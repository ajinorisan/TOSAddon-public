-- 바이보라 합성 레벨 제한
function GET_EVENT_2101_SUPPLY_VIBORA_COMPOSITE_LEVEL()
    return 450;
end

-- 바이보라 합성에 필요한 티켓 수량
function GET_EVENT_2101_SUPPLY_VIBORA_COMPOSITE_TICKET_NEED_COUNT()
    return 1;
end

-- 왕국 재건단 보급관 NPC 생성 및 입구로 돌아가는 시간 늘리는 인던 
local npcmgamelist = {"ID_ZACHA_MINI", "ID_CMINE_MINI", "ID_HUEVILLAGE_MINI", "ID_CATACOMB_MINI", 
"ID_CASTLE_03_MINI", "ID_SIAULIAI_MINI", "ID_ROKAS_MINI", "CHALLENGE_AUTO_HARD", "LEGEND_RAID_GILTINE_AUTO", "UNDERAQUEDUCT_MGAME", "IRREDIAN1131_SRAID_C",
"MYTHIC_STARTOWER_MINI_AUTO","MYTHIC_FIRETOWER_MINI_AUTO","MYTHIC_CASTLE_MINI_AUTO", "Goddess_Raid_Delmore_Auto", "Goddess_Raid_Vasilissa_Auto"
};
function IS_EVENT_2101_SUPPLY_NPC_CREATE_CONTENT(mgameName)
    for k, v in pairs(npcmgamelist) do 
        if v == mgameName then
            return true;
        end
    end

    return false;
end

local stagelist = {"END", "SUCCESS", "clear", "Success", "success", "Succ", "OUT", "End"}
function IS_EVENT_2101_SUPPLY_NPC_STAGE(curStage)
    for k, v in pairs(stagelist) do 
        if v == curStage then
            return true;
        end
    end

    return false;
end

-- npc 생성 했을 경우 마을 이동 제한시간, 초 단위 
function GET_EVENT_2101_SUPPLY_CONTENT_NPC_TIME()
    return 180;
end

function IS_EVENT_2101_SUPPLY_CONTENT_NPC(className)
    if className == "Event_supply_NPC_1" or className == "Event_supply_NPC_7" then
        return true;
    end

    return false;
end