function SCR_SSN_KLAPEDA_KillMonster_PARTY(self, party_pc, sObj, msg, argObj, argStr, argNum)
    if SHARE_QUEST_PROP(self, party_pc) == true then
        if GetLayer(self) == GetLayer(party_pc) then
            SCR_SSN_KLAPEDA_KillMonster_Sub(self, sObj, msg, argObj, argStr, argNum)
        end
    end

--    --EVENT_1906_TOTAL_SHOP
--    if GetLayer(self) == GetLayer(party_pc) then
--        SCR_SSN_EVENT_1906_TOTAL_SHOP_KillMonster(self, sObj, msg, argObj, argStr, argNum)
--    end
    -- EVENT_1811_NEWCHARACTER
--    SCR_SSN_EVENT_1811_NEWCHARACTER_KillMonster(self, sObj, msg, argObj, argStr, argNum)
        
    -- EVENT_1811_KUPOLE
--    SCR_SSN_EVENT_1811_KUPOLE_KillMonster(self, sObj, msg, argObj, argStr, argNum)

-- EVENT_1706_MONK
--    SCR_SSN_EVENT_1706_MONK_KillMonster(self, sObj, msg, argObj, argStr, argNum)
    
--WHITEDAY EVENT    
--    if IsSameActor(self, party_pc) ~= "YES" and GetDistance(self, party_pc) < PARTY_SHARE_RANGE then
--        SCR_EVENT_WHITEDAY(self, sObj, msg, argObj, argStr, argNum, "YES")
--    end     
---- ALPHABET_EVENT
--    if IsSameActor(self, party_pc) ~= "YES" and GetDistance(self, party_pc) < PARTY_SHARE_RANGE then
--        SCR_ALPHABET_EVENT(self, sObj, msg, argObj, argStr, argNum, "YES")
--    end
--      if IsSameActor(self, party_pc) ~= "YES" and GetDistance(self, party_pc) < PARTY_SHARE_RANGE then
--        DAYQUEST_TAGETMON_CHECK(self, sObj, msg, argObj, argStr, argNum)
--      end

end

function SCR_SSN_KLAPEDA_KillMonster(self, sObj, msg, argObj, argStr, argNum)
	PC_WIKI_KILLMON(self, argObj, true);
	CHECK_SUPER_DROP(self);
	CHECK_CHALLENGE_MODE(self, argObj);
	
    SCR_SSN_KLAPEDA_KillMonster_Sub(self, sObj, msg, argObj, argStr, argNum)

    if IsIndun(self) == 1 then
		IndunMonKillCountIncrease(self);
    end
    
--    --EVENT_1906_TOTAL_SHOP
--    SCR_SSN_EVENT_1906_TOTAL_SHOP_KillMonster(self, sObj, msg, argObj, argStr, argNum)
	
    -- --EVENT_1905_TOS_CHILD
    --SCR_SSN_EVENT_1905_NEWUSER_KillMonster(self, sObj, msg, argObj, argStr, argNum)
    -- EVENT_1811_NEWCHARACTER
--    SCR_SSN_EVENT_1811_NEWCHARACTER_KillMonster(self, sObj, msg, argObj, argStr, argNum)
    
    -- EVENT_1811_KUPOLE
--    SCR_SSN_EVENT_1811_KUPOLE_KillMonster(self, sObj, msg, argObj, argStr, argNum)
    
--WHITEDAY EVENT	
--	SCR_EVENT_WHITEDAY(self, sObj, msg, argObj, argStr, argNum)
---- ALPHABET_EVENT
--	SCR_ALPHABET_EVENT(self, sObj, msg, argObj, argStr, argNum)

-- CHUSEOK_EVENT
--	SCR_CHUSEOK_EVENT(self, sObj, msg, argObj, argStr, argNum)
--    DAYQUEST_TAGETMON_CHECK(self, sObj, msg, argObj, argStr, argNum)

-- EVENT_1706_MONK
--    SCR_SSN_EVENT_1706_MONK_KillMonster(self, sObj, msg, argObj, argStr, argNum)

---- ID_WHITETREES1
    if GetZoneName(self) == 'id_whitetrees1' then
        if argObj.ClassName == 'ID_umblet' then
            if IMCRandom(1, 10000) < 601 then
                RunScript('GIVE_ITEM_TX', self, 'misc_id_330_gimmick_01', 1, 'INDUN_330')
            end
        elseif argObj.ClassName == 'ID_kucarry_Tot' then
            if IMCRandom(1, 10000) < 601 then
                RunScript('GIVE_ITEM_TX', self, 'misc_id_330_gimmick_02', 1, 'INDUN_330')
            end
        elseif argObj.ClassName == 'ID_kucarry_lioni' then
            if IMCRandom(1, 10000) < 601 then
                RunScript('GIVE_ITEM_TX', self, 'misc_id_330_gimmick_03', 1, 'INDUN_330')
            end
        end
    end
end