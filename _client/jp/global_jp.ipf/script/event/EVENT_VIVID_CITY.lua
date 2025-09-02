-- --function SCR_EVENT_VIVID_CITY_ZONEENTER(self)
-- --    local zoneName = GetZoneName(self)
-- --    if zoneName == 'VIVID_c_Klaipe' or zoneName == 'VIVID_c_orsha' or zoneName == 'VIVID_c_fedimian' then
-- --        AddBuff(self,self,'Event_Steam_Vivid_City2', 1, 0, 3600000, 1)
-- --    end
-- --end

-- function SCR_BUFF_ENTER_Event_Steam_Vivid_City(self, buff, arg1, arg2, over)
--     local value = 40
--     if GetZoneName(self) == 'VIVID_c_orsha' then
--         value = 42
--     end
--     self.FIXMSPD_BM = value
--     Invalidate(self, 'MSPD');
-- end

-- function SCR_BUFF_LEAVE_Event_Steam_Vivid_City(self, buff, arg1, arg2, over)
--     self.FIXMSPD_BM = 0
--     Invalidate(self, 'MSPD');
--     local aObj = GetAccountObj(self)
--     local beforeZone = TryGetProp(aObj, 'EVENT_VIVID_BEFORE_ZONE', 'None')
--     if beforeZone == 'c_Klaipe' or beforeZone == 'None' then
--         MoveZone(self, 'c_Klaipe', -5.79, 149.21, 430.98);
--     elseif beforeZone == 'c_orsha' then
--         MoveZone(self, 'c_orsha', -16, 176, 350)
--     elseif beforeZone == 'c_fedimian' then
--         MoveZone(self, 'c_fedimian', -421, 160, -363)
--     end
-- end

-- function SCR_BUFF_ENTER_Event_Steam_Vivid_City2(self, buff, arg1, arg2, over)
--     local value = 40
--     if GetZoneName(self) == 'VIVID_c_orsha' then
--         value = 42
--     end
--     self.FIXMSPD_BM = value
--     Invalidate(self, 'MSPD');
-- end

-- function SCR_BUFF_LEAVE_Event_Steam_Vivid_City2(self, buff, arg1, arg2, over)
--     self.FIXMSPD_BM = 0
--     Invalidate(self, 'MSPD');
--     local aObj = GetAccountObj(self)
--     local beforeZone = TryGetProp(aObj, 'EVENT_VIVID_BEFORE_ZONE', 'None')
--     if beforeZone == 'c_Klaipe' or beforeZone == 'None' then
--         MoveZone(self, 'c_Klaipe', -5.79, 149.21, 430.98);
--     elseif beforeZone == 'c_orsha' then
--         MoveZone(self, 'c_orsha', -16, 176, 350)
--     elseif beforeZone == 'c_fedimian' then
--         MoveZone(self, 'c_fedimian', -421, 160, -363)
--     end
-- end

-- function SCR_EVENT_VIVID_CITY_DIALOG(self,pc)
--     ExecClientScp(pc, "REQ_EVENT_ITEM_SHOP_OPEN()")
-- --    local now_time = os.date('*t')
-- --    local yday = now_time['yday']
-- --    local hour = now_time['hour']
-- --    local min = now_time['min']
-- --    local teamlv = GetTeamLevel(pc)
-- --    local teamName = GetTeamName(pc);
-- --    local aObj = GetAccountObj(pc) 
-- --    local sObj = GetSessionObject(pc, 'ssn_klapeda')

-- --    if aObj.EVENT_VIVID_FINAL_YDAY ~= yday then -- 00 ?�에 10??초기??--
-- --        local tx = TxBegin(pc)
-- --        TxSetIESProp(tx, aObj, 'EVENT_VIVID_FINAL_YDAY', yday);
-- --        TxSetIESProp(tx, aObj, 'EVENT_VIVID_FINAL_COUNT', 0);
-- --        local ret = TxCommit(tx)
-- --    end
-- --
-- --    if aObj.EVENT_VIVID_FINAL_COUNT >= 10 then
-- --        SendAddOnMsg(pc, 'NOTICE_Dm_!', ScpArgMsg("Event_Returner_Desc01"), 5)
-- --        return
-- --    end

-- --    local select = ShowSelDlg(pc, 0, 'NPC_EVENT_VIVID_CITY_DLG1', ScpArgMsg("Event_Steam_YC_3")..' - '..ScpArgMsg("Easy"), ScpArgMsg("Event_Steam_YC_4")..' - '..ScpArgMsg("Normal"), ScpArgMsg("Event_Steam_YC_2")..' - '..ScpArgMsg("Hard"), ScpArgMsg("EventShop"), ScpArgMsg("Cancel")) 
-- --
-- --    if select == 3 then
-- --        if aObj.EVENT_VIVID_ACCOUNT_KLAIPE_POINT4 ~= yday then -- 클라페다 마지막 보상 박스 프로퍼티 --
-- --            local tx = TxBegin(pc)
-- --            TxSetIESProp(tx, aObj, 'EVENT_VIVID_BEFORE_ZONE', GetZoneName(pc));
-- --            local ret = TxCommit(tx)
-- --            MoveZone(pc, 'VIVID_c_Klaipe', -1092.74, -1.06, -643.61);
-- --            IMCLOG_CONTENT("VIVID_EVENT", "CITY_JOIN_Klaipe  ", "PClv:  ", pc.Lv, "TeamLv:  ", teamlv, "TeamName:   ", teamName)
-- --        else
-- --            ShowOkDlg(pc, 'NPC_EVENT_VIVID_CITY_DLG3', 1)
-- --        end
-- --    elseif select == 1 then
-- --        if aObj.EVENT_VIVID_ACCOUNT_ORSHA_POINT4 ~= yday then -- 오르샤 마지막 보상 박스 프로퍼티 --
-- --            local tx = TxBegin(pc)
-- --            TxSetIESProp(tx, aObj, 'EVENT_VIVID_BEFORE_ZONE', GetZoneName(pc));
-- --            local ret = TxCommit(tx)
-- --            MoveZone(pc, 'VIVID_c_orsha', 172.89, 176.78, -1348.16);
-- --            IMCLOG_CONTENT("VIVID_EVENT", "CITY_JOIN_Orsha  ", "PClv:  ", pc.Lv, "TeamLv:  ", teamlv, "TeamName:   ", teamName)
-- --        else
-- --            ShowOkDlg(pc, 'NPC_EVENT_VIVID_CITY_DLG3', 1)
-- --        end
-- --    elseif select == 2 then
-- --        if aObj.EVENT_VIVID_ACCOUNT_FEDIMIAN_POINT4 ~= yday then -- 페디미안 마지막 보상 박스 프로퍼티 --
-- --            local tx = TxBegin(pc)
-- --            TxSetIESProp(tx, aObj, 'EVENT_VIVID_BEFORE_ZONE', GetZoneName(pc));
-- --            local ret = TxCommit(tx)
-- --            MoveZone(pc, 'VIVID_c_fedimian', 801.71, 160.66, -167.73);
-- --            IMCLOG_CONTENT("VIVID_EVENT", "CITY_JOIN_Fedimian  ", "PClv:  ", pc.Lv, "TeamLv:  ", teamlv, "TeamName:   ", teamName)
-- --        else
-- --            ShowOkDlg(pc, 'NPC_EVENT_VIVID_CITY_DLG3', 1)
-- --        end
-- --    elseif select == 4 then
-- --        ExecClientScp(pc, "REQ_EVENT_ITEM_SHOP_OPEN()")
-- --    end
-- end

-- function SCR_EVENT_VIVID_KLAIPE_BOX_DIALOG(self,pc)
--     local now_time = os.date('*t')
--     local yday = now_time['yday']
--     local hour = now_time['hour']
--     local min = now_time['min']
--     local aObj = GetAccountObj(pc) 
-- --    local sObj = GetSessionObject(pc, 'ssn_klapeda')
--     if aObj.EVENT_VIVID_ACCOUNT_KLAIPE_POINT1 ~= yday then
--         PlayAnimLocal(self,pc,'OPEN')
--         local tx = TxBegin(pc)
--         TxGiveItem(tx, 'Point_Stone_100', 1, "EVENT_VIVID");
--         TxSetIESProp(tx, aObj, 'EVENT_VIVID_ACCOUNT_KLAIPE_POINT1', yday);
--         local ret = TxCommit(tx)
--     else
--         SendAddOnMsg(pc, "NOTICE_Dm_scroll", ScpArgMsg("YouAlreadyPlayedChallengeMode"), 10);
--     end
-- end

-- function SCR_EVENT_VIVID_KLAIPE_BOX2_DIALOG(self,pc)
--     local now_time = os.date('*t')
--     local yday = now_time['yday']
--     local hour = now_time['hour']
--     local min = now_time['min']
--     local aObj = GetAccountObj(pc) 
-- --    local sObj = GetSessionObject(pc, 'ssn_klapeda')
--     if aObj.EVENT_VIVID_ACCOUNT_KLAIPE_POINT2 ~= yday then
--         PlayAnimLocal(self,pc,'OPEN')
--         local tx = TxBegin(pc)
--         TxGiveItem(tx, 'Point_Stone_100', 1, "EVENT_VIVID");
--         TxSetIESProp(tx, aObj, 'EVENT_VIVID_ACCOUNT_KLAIPE_POINT2', yday);
--         local ret = TxCommit(tx)
--     else
--         SendAddOnMsg(pc, "NOTICE_Dm_scroll", ScpArgMsg("YouAlreadyPlayedChallengeMode"), 10);
--     end
-- end

-- function SCR_EVENT_VIVID_KLAIPE_BOX3_DIALOG(self,pc)
--     local now_time = os.date('*t')
--     local yday = now_time['yday']
--     local hour = now_time['hour']
--     local min = now_time['min']
--     local aObj = GetAccountObj(pc) 
-- --    local sObj = GetSessionObject(pc, 'ssn_klapeda')
--     if aObj.EVENT_VIVID_ACCOUNT_KLAIPE_POINT3 ~= yday then
--         PlayAnimLocal(self,pc,'OPEN')
--         local tx = TxBegin(pc)
--         TxGiveItem(tx, 'Point_Stone_100', 1, "EVENT_VIVID");
--         TxSetIESProp(tx, aObj, 'EVENT_VIVID_ACCOUNT_KLAIPE_POINT3', yday);
--         local ret = TxCommit(tx)
--     else
--         SendAddOnMsg(pc, "NOTICE_Dm_scroll", ScpArgMsg("YouAlreadyPlayedChallengeMode"), 10);
--     end
-- end

-- function SCR_EVENT_VIVID_KLAIPE_BOX4_DIALOG(self,pc)
--     local now_time = os.date('*t')
--     local yday = now_time['yday']
--     local hour = now_time['hour']
--     local min = now_time['min']
-- --    local rand = IMCRandom(1, 100);
--     local aObj = GetAccountObj(pc) 
-- --    local sObj = GetSessionObject(pc, 'ssn_klapeda')
--     local buff = GetBuffByName(pc, 'Event_Steam_Vivid_City2')
--     local remainTime = math.floor(GetBuffRemainTime(buff)/1000)
--     local timeCheck = 3600 - remainTime
--     local timecheck_min = math.floor(timeCheck / 60)
--     local timecheck_sec = timeCheck % 60

--     if aObj.EVENT_VIVID_ACCOUNT_KLAIPE_POINT4 ~= yday then
--         local select_time = ShowSelDlg(pc, 0, 'NPC_EVENT_VIVID_TIMECHECK', ScpArgMsg('EVENT_VIVID_TIME_CHECK_SEL1','MIN',timecheck_min, "SEC", timecheck_sec))
--         PlayAnimLocal(self,pc,'OPEN')
--         local tx = TxBegin(pc)
--         TxGiveItem(tx, 'indunReset_1add_14d_NoStack', 1, "EVENT_VIVID");
--         TxGiveItem(tx, 'Premium_dungeoncount_Event', 1, "EVENT_VIVID");
--         TxGiveItem(tx, 'EVENT_1808_VIVID_POWDER', 3, "EVENT_VIVID");
-- --        if rand > 90 then
-- --            TxGiveItem(tx, 'Moru_Gold_14d', 1, "EVENT_VIVID");
-- --            TxGiveItem(tx, 'misc_BlessedStone', 1, "EVENT_VIVID");
-- --            TxGiveItem(tx, 'Premium_Enchantchip14', 2, "EVENT_VIVID");
-- --        else
-- --            TxGiveItem(tx, 'misc_BlessedStone', 1, "EVENT_VIVID");
-- --            TxGiveItem(tx, 'Premium_Enchantchip14', 2, "EVENT_VIVID");
-- --        end
--         TxSetIESProp(tx, aObj, 'EVENT_VIVID_ACCOUNT_KLAIPE_POINT4', yday);
-- --        TxSetIESProp(tx, aObj, 'EVENT_VIVID_FINAL_COUNT', aObj.EVENT_VIVID_FINAL_COUNT + 1); -- 10�??�한 ?��??�청 --
--         local ret = TxCommit(tx)
--         if ret == "SUCCESS" then
--             local teamlv = GetTeamLevel(pc)
--             local teamName = GetTeamName(pc);
--             IMCLOG_CONTENT("VIVID_EVENT", "CITY_Clear_Klaipe  ", "PClv:  ", pc.Lv, "TeamLv:  ", teamlv, "TeamName:   ", teamName)
            
--             sleep(3000)
--             local aObj = GetAccountObj(pc)
--             local beforeZone = TryGetProp(aObj, 'EVENT_VIVID_BEFORE_ZONE', 'None')
--             if beforeZone == 'c_Klaipe' or beforeZone == 'None' then
--                 MoveZone(pc, 'c_Klaipe', -5.79, 149.21, 430.98);
--             elseif beforeZone == 'c_orsha' then
--                 MoveZone(pc, 'c_orsha', -16, 176, 350)
--             elseif beforeZone == 'c_fedimian' then
--                 MoveZone(pc, 'c_fedimian', -421, 160, -363)
--             end
--         end
--     else
--         SendAddOnMsg(pc, "NOTICE_Dm_scroll", ScpArgMsg("YouAlreadyPlayedChallengeMode"), 10);
--     end
-- end

-- function SCR_EVENT_VIVID_ORSHA_BOX_DIALOG(self,pc)
--     local now_time = os.date('*t')
--     local yday = now_time['yday']
--     local hour = now_time['hour']
--     local min = now_time['min']
--     local aObj = GetAccountObj(pc) 
-- --    local sObj = GetSessionObject(pc, 'ssn_klapeda')
--     if aObj.EVENT_VIVID_ACCOUNT_ORSHA_POINT1 ~= yday then
--         PlayAnimLocal(self,pc,'OPEN')
--         local tx = TxBegin(pc)
--         TxGiveItem(tx, 'Point_Stone_100', 1, "EVENT_VIVID");
--         TxSetIESProp(tx, aObj, 'EVENT_VIVID_ACCOUNT_ORSHA_POINT1', yday);
--         local ret = TxCommit(tx)
--     else
--         SendAddOnMsg(pc, "NOTICE_Dm_scroll", ScpArgMsg("YouAlreadyPlayedChallengeMode"), 10);
--     end
-- end

-- function SCR_EVENT_VIVID_ORSHA_BOX2_DIALOG(self,pc)
--     local now_time = os.date('*t')
--     local yday = now_time['yday']
--     local hour = now_time['hour']
--     local min = now_time['min']
--     local aObj = GetAccountObj(pc) 
-- --    local sObj = GetSessionObject(pc, 'ssn_klapeda')
--     if aObj.EVENT_VIVID_ACCOUNT_ORSHA_POINT2 ~= yday then
--         PlayAnimLocal(self,pc,'OPEN')
--         local tx = TxBegin(pc)
--         TxGiveItem(tx, 'Point_Stone_100', 1, "EVENT_VIVID");
--         TxSetIESProp(tx, aObj, 'EVENT_VIVID_ACCOUNT_ORSHA_POINT2', yday);
--         local ret = TxCommit(tx)
--     else
--         SendAddOnMsg(pc, "NOTICE_Dm_scroll", ScpArgMsg("YouAlreadyPlayedChallengeMode"), 10);
--     end
-- end

-- function SCR_EVENT_VIVID_ORSHA_BOX3_DIALOG(self,pc)
--     local now_time = os.date('*t')
--     local yday = now_time['yday']
--     local hour = now_time['hour']
--     local min = now_time['min']
--     local aObj = GetAccountObj(pc) 
-- --    local sObj = GetSessionObject(pc, 'ssn_klapeda')
--     if aObj.EVENT_VIVID_ACCOUNT_ORSHA_POINT3 ~= yday then
--         PlayAnimLocal(self,pc,'OPEN')
--         local tx = TxBegin(pc)
--         TxGiveItem(tx, 'Point_Stone_100', 1, "EVENT_VIVID");
--         TxSetIESProp(tx, aObj, 'EVENT_VIVID_ACCOUNT_ORSHA_POINT3', yday);
--         local ret = TxCommit(tx)
--     else
--         SendAddOnMsg(pc, "NOTICE_Dm_scroll", ScpArgMsg("YouAlreadyPlayedChallengeMode"), 10);
--     end
-- end

-- function SCR_EVENT_VIVID_ORSHA_BOX4_DIALOG(self,pc)
--     local now_time = os.date('*t')
--     local yday = now_time['yday']
--     local hour = now_time['hour']
--     local min = now_time['min']
--     local aObj = GetAccountObj(pc) 
-- --    local sObj = GetSessionObject(pc, 'ssn_klapeda')
--     local rand = IMCRandom(1, 100); 
--     local buff = GetBuffByName(pc, 'Event_Steam_Vivid_City2')
--     local remainTime = math.floor(GetBuffRemainTime(buff)/1000)
--     local timeCheck = 3600 - remainTime
--     local timecheck_min = math.floor(timeCheck / 60)
--     local timecheck_sec = timeCheck % 60

--     if aObj.EVENT_VIVID_ACCOUNT_ORSHA_POINT4 ~= yday then
--         local select_time = ShowSelDlg(pc, 0, 'NPC_EVENT_VIVID_TIMECHECK', ScpArgMsg('EVENT_VIVID_TIME_CHECK_SEL1','MIN',timecheck_min, "SEC", timecheck_sec))
--         PlayAnimLocal(self,pc,'OPEN')
--         local tx = TxBegin(pc)
--         TxGiveItem(tx, 'indunReset_1add_14d_NoStack', 1, "EVENT_VIVID");
--         TxGiveItem(tx, 'Premium_dungeoncount_Event', 1, "EVENT_VIVID");
--         TxGiveItem(tx, 'EVENT_1808_VIVID_POWDER', 3, "EVENT_VIVID");
-- --        if rand > 90 then
-- --            TxGiveItem(tx, 'Ability_Point_Stone_500_14d', 2, "EVENT_VIVID");
-- --            TxGiveItem(tx, 'misc_BlessedStone', 1, "EVENT_VIVID");
-- --            TxGiveItem(tx, 'Premium_Enchantchip14', 2, "EVENT_VIVID");
-- --        else
-- --            TxGiveItem(tx, 'misc_BlessedStone', 1, "EVENT_VIVID");
-- --            TxGiveItem(tx, 'Premium_Enchantchip14', 2, "EVENT_VIVID");
-- --        end
--         TxSetIESProp(tx, aObj, 'EVENT_VIVID_ACCOUNT_ORSHA_POINT4', yday);
-- --        TxSetIESProp(tx, aObj, 'EVENT_VIVID_FINAL_COUNT', aObj.EVENT_VIVID_FINAL_COUNT + 1); -- 10�??�한 ?��??�청 --
--         local ret = TxCommit(tx)
--         if ret == "SUCCESS" then
--             local teamlv = GetTeamLevel(pc)
--             local teamName = GetTeamName(pc);
--             IMCLOG_CONTENT("VIVID_EVENT", "CITY_Clear_Orsha  ", "PClv:  ", pc.Lv, "TeamLv:  ", teamlv, "TeamName:   ", teamName)
            
--             sleep(3000)
--             local aObj = GetAccountObj(pc)
--             local beforeZone = TryGetProp(aObj, 'EVENT_VIVID_BEFORE_ZONE', 'None')
--             if beforeZone == 'c_Klaipe' or beforeZone == 'None' then
--                 MoveZone(pc, 'c_Klaipe', -5.79, 149.21, 430.98);
--             elseif beforeZone == 'c_orsha' then
--                 MoveZone(pc, 'c_orsha', -16, 176, 350)
--             elseif beforeZone == 'c_fedimian' then
--                 MoveZone(pc, 'c_fedimian', -421, 160, -363)
--             end
--         end
--     else
--         SendAddOnMsg(pc, "NOTICE_Dm_scroll", ScpArgMsg("YouAlreadyPlayedChallengeMode"), 10);
--     end
-- end

-- function SCR_EVENT_VIVID_FEDIMIAN_BOX_DIALOG(self,pc)
--     local now_time = os.date('*t')
--     local yday = now_time['yday']
--     local hour = now_time['hour']
--     local min = now_time['min']
--     local aObj = GetAccountObj(pc) 
-- --    local sObj = GetSessionObject(pc, 'ssn_klapeda')
--     if aObj.EVENT_VIVID_ACCOUNT_FEDIMIAN_POINT1 ~= yday then
--         PlayAnimLocal(self,pc,'OPEN')
--         local tx = TxBegin(pc)
--         TxGiveItem(tx, 'Point_Stone_100', 1, "EVENT_VIVID");
--         TxSetIESProp(tx, aObj, 'EVENT_VIVID_ACCOUNT_FEDIMIAN_POINT1', yday);
--         local ret = TxCommit(tx)
--     else
--         SendAddOnMsg(pc, "NOTICE_Dm_scroll", ScpArgMsg("YouAlreadyPlayedChallengeMode"), 10);
--     end
-- end

-- function SCR_EVENT_VIVID_FEDIMIAN_BOX2_DIALOG(self,pc)
--     local now_time = os.date('*t')
--     local yday = now_time['yday']
--     local hour = now_time['hour']
--     local min = now_time['min']
--     local aObj = GetAccountObj(pc) 
-- --    local sObj = GetSessionObject(pc, 'ssn_klapeda')
--     if aObj.EVENT_VIVID_ACCOUNT_FEDIMIAN_POINT2 ~= yday then
--         PlayAnimLocal(self,pc,'OPEN')
--         local tx = TxBegin(pc)
--         TxGiveItem(tx, 'Point_Stone_100', 1, "EVENT_VIVID");
--         TxSetIESProp(tx, aObj, 'EVENT_VIVID_ACCOUNT_FEDIMIAN_POINT2', yday);
--         local ret = TxCommit(tx)
--     else
--         SendAddOnMsg(pc, "NOTICE_Dm_scroll", ScpArgMsg("YouAlreadyPlayedChallengeMode"), 10);
--     end
-- end

-- function SCR_EVENT_VIVID_FEDIMIAN_BOX3_DIALOG(self,pc)
--     local now_time = os.date('*t')
--     local yday = now_time['yday']
--     local hour = now_time['hour']
--     local min = now_time['min']
--     local aObj = GetAccountObj(pc) 
-- --    local sObj = GetSessionObject(pc, 'ssn_klapeda')
--     if aObj.EVENT_VIVID_ACCOUNT_FEDIMIAN_POINT3 ~= yday then
--         PlayAnimLocal(self,pc,'OPEN')
--         local tx = TxBegin(pc)
--         TxGiveItem(tx, 'Point_Stone_100', 1, "EVENT_VIVID");
--         TxSetIESProp(tx, aObj, 'EVENT_VIVID_ACCOUNT_FEDIMIAN_POINT3', yday);
--         local ret = TxCommit(tx)
--     else
--         SendAddOnMsg(pc, "NOTICE_Dm_scroll", ScpArgMsg("YouAlreadyPlayedChallengeMode"), 10);
--     end
-- end

-- function SCR_EVENT_VIVID_FEDIMIAN_BOX4_DIALOG(self,pc)
--     local now_time = os.date('*t')
--     local yday = now_time['yday']
--     local hour = now_time['hour']
--     local min = now_time['min']
--     local aObj = GetAccountObj(pc) 
-- --    local sObj = GetSessionObject(pc, 'ssn_klapeda')
--     local rand = IMCRandom(1, 100); 
--     local buff = GetBuffByName(pc, 'Event_Steam_Vivid_City2')
--     local remainTime = math.floor(GetBuffRemainTime(buff)/1000)
--     local timeCheck = 3600 - remainTime
--     local timecheck_min = math.floor(timeCheck / 60)
--     local timecheck_sec = timeCheck % 60

--     if aObj.EVENT_VIVID_ACCOUNT_FEDIMIAN_POINT4 ~= yday then
--         local select_time = ShowSelDlg(pc, 0, 'NPC_EVENT_VIVID_TIMECHECK', ScpArgMsg('EVENT_VIVID_TIME_CHECK_SEL1','MIN',timecheck_min, "SEC", timecheck_sec))
--         PlayAnimLocal(self,pc,'OPEN')
--         local tx = TxBegin(pc)
--         TxGiveItem(tx, 'indunReset_1add_14d_NoStack', 1, "EVENT_VIVID");
--         TxGiveItem(tx, 'Premium_dungeoncount_Event', 1, "EVENT_VIVID");
--         TxGiveItem(tx, 'EVENT_1808_VIVID_POWDER', 3, "EVENT_VIVID");
-- --        if rand > 90 then
-- --            TxGiveItem(tx, 'ChallengeModeReset_14d', 1, "EVENT_VIVID");
-- --            TxGiveItem(tx, 'misc_BlessedStone', 1, "EVENT_VIVID");
-- --            TxGiveItem(tx, 'Premium_Enchantchip14', 2, "EVENT_VIVID");
-- --        else
-- --            TxGiveItem(tx, 'misc_BlessedStone', 1, "EVENT_VIVID");
-- --            TxGiveItem(tx, 'Premium_Enchantchip14', 2, "EVENT_VIVID");
-- --        end
--         TxSetIESProp(tx, aObj, 'EVENT_VIVID_ACCOUNT_FEDIMIAN_POINT4', yday);
-- --        TxSetIESProp(tx, aObj, 'EVENT_VIVID_FINAL_COUNT', aObj.EVENT_VIVID_FINAL_COUNT + 1); -- 10�??�한 ?��??�청 --
--         local ret = TxCommit(tx)
--         if ret == "SUCCESS" then
--             local teamlv = GetTeamLevel(pc)
--             local teamName = GetTeamName(pc);
--             IMCLOG_CONTENT("VIVID_EVENT", "CITY_Clear_Fedimian  ", "PClv:  ", pc.Lv, "TeamLv:  ", teamlv, "TeamName:   ", teamName)
            
--             sleep(3000)
--             local aObj = GetAccountObj(pc)
--             local beforeZone = TryGetProp(aObj, 'EVENT_VIVID_BEFORE_ZONE', 'None')
--             if beforeZone == 'c_Klaipe' or beforeZone == 'None' then
--                 MoveZone(pc, 'c_Klaipe', -5.79, 149.21, 430.98);
--             elseif beforeZone == 'c_orsha' then
--                 MoveZone(pc, 'c_orsha', -16, 176, 350)
--             elseif beforeZone == 'c_fedimian' then
--                 MoveZone(pc, 'c_fedimian', -421, 160, -363)
--             end
--         end
--     else
--         SendAddOnMsg(pc, "NOTICE_Dm_scroll", ScpArgMsg("YouAlreadyPlayedChallengeMode"), 10);
--     end
-- end

-- -- Klaipe Warp
-- function SCR_EVENT_VIVID_KLAIPE_WARP1_DIALOG(self, pc)
--     MoveZone(pc, 'VIVID_c_Klaipe', -1042.70, -1.06, -593.57);
-- end

-- function SCR_EVENT_VIVID_KLAIPE_WARP2_DIALOG(self, pc)
--     MoveZone(pc, 'VIVID_c_Klaipe', 323.59, 79.96, 238.96);
-- end

-- function SCR_EVENT_VIVID_KLAIPE_WARP3_DIALOG(self, pc)
--     MoveZone(pc, 'VIVID_c_Klaipe', 87.98, 149.17, 133.09);
-- end

-- -- Orsha Warp
-- function SCR_EVENT_VIVID_ORSHA_WARP1_DIALOG(self, pc)
--     MoveZone(pc, 'VIVID_c_orsha', 172.89, 176.78, -1348.16);
-- end

-- function SCR_EVENT_VIVID_ORSHA_WARP2_DIALOG(self, pc)
--     MoveZone(pc, 'VIVID_c_orsha', -265.15, 186.65, -464.89);
-- end

-- function SCR_EVENT_VIVID_ORSHA_WARP3_DIALOG(self, pc)
--     MoveZone(pc, 'VIVID_c_orsha', -405.20, 443.52, 84.26);
-- end

-- function SCR_EVENT_VIVID_ORSHA_WARP4_DIALOG(self, pc)
--     MoveZone(pc, 'VIVID_c_orsha', 728.48, 178.29, -625.39);
-- end

-- function SCR_EVENT_VIVID_ORSHA_POTAL_DIALOG(self, pc)
--     MoveZone(pc, 'VIVID_c_orsha', 728.48, 178.29, -625.39);
-- end

-- -- Fedimian Warp
-- function SCR_EVENT_VIVID_FEDIMIAN_WARP1_DIALOG(self, pc)
--     MoveZone(pc, 'VIVID_c_fedimian', 801.71, 160.66, -167.73);
-- end

-- function SCR_EVENT_VIVID_FEDIMIAN_WARP2_DIALOG(self, pc)
--     MoveZone(pc, 'VIVID_c_fedimian', -256.20, 310.80, -84.32);
-- end

-- function SCR_EVENT_VIVID_FEDIMIAN_WARP3_DIALOG(self, pc)
--     MoveZone(pc, 'VIVID_c_fedimian', -60, 504, 176);
-- end

-- function SCR_EVENT_VIVID_FEDIMIAN_WARP4_DIALOG(self, pc)
--     MoveZone(pc, 'VIVID_c_fedimian', 502, 496, 414);
-- end

-- function SCR_EVENT_VIVID_FEDIMIAN_POTAL_DIALOG(self, pc)
--     MoveZone(pc, 'VIVID_c_fedimian', 713, 291, 108);
-- end

-- -- 30 --
-- function SCR_EVENT_VIVID_WHITE_30_TS_BORN_ENTER(self)
--     FlyMath(self, 30, 0, 0);
--     AttachEffect(self, 'F_ground008_blue', 3, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_WHITE_30_TS_BORN_UPDATE(self)
--     --AttachEffect(self, 'E_buff_gungho', 1, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_WHITE_30_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_WHITE_30_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_WHITE_30_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_WHITE_30_TS_DEAD_LEAVE(self)
-- end

-- -- 60 --
-- function SCR_EVENT_VIVID_WHITE_60_TS_BORN_ENTER(self)
--     FlyMath(self, 60, 0, 0);
--     AttachEffect(self, 'F_ground008_blue', 3, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_WHITE_60_TS_BORN_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_WHITE_60_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_WHITE_60_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_WHITE_60_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_WHITE_60_TS_DEAD_LEAVE(self)
-- end

-- --yellow --
-- function SCR_EVENT_VIVID_YELLOW_60_TS_BORN_ENTER(self)
--     FlyMath(self, 60, 0, 0);
--     AttachEffect(self, 'F_ground008_yellow', 3, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_YELLOW_60_TS_BORN_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_YELLOW_60_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_YELLOW_60_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_YELLOW_60_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_YELLOW_60_TS_DEAD_LEAVE(self)
-- end

-- --green --
-- function SCR_EVENT_VIVID_GREEN_60_TS_BORN_ENTER(self)
--     FlyMath(self, 60, 0, 0);
--     AttachEffect(self, 'F_ground008_green', 3, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_GREEN_60_TS_BORN_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_GREEN_60_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_GREEN_60_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_GREEN_60_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_GREEN_60_TS_DEAD_LEAVE(self)
-- end

-- --blue --
-- function SCR_EVENT_VIVID_BLUE_60_TS_BORN_ENTER(self)
--     FlyMath(self, 60, 0, 0);
--     AttachEffect(self, 'F_ground008_blue', 3, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_BLUE_60_TS_BORN_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_BLUE_60_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_BLUE_60_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_BLUE_60_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_BLUE_60_TS_DEAD_LEAVE(self)
-- end

-- --90 yellow --
-- function SCR_EVENT_VIVID_YELLOW_90_TS_BORN_ENTER(self)
--     FlyMath(self, 90, 0, 0);
--     AttachEffect(self, 'F_ground008_yellow', 3, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_YELLOW_90_TS_BORN_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_YELLOW_90_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_YELLOW_90_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_YELLOW_90_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_YELLOW_90_TS_DEAD_LEAVE(self)
-- end

-- -- 90 blue--
-- function SCR_EVENT_VIVID_BLUE_90_TS_BORN_ENTER(self)
--     FlyMath(self, 90, 0, 0);
--     AttachEffect(self, 'F_ground008_blue', 3, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_BLUE_90_TS_BORN_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_BLUE_90_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_BLUE_90_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_BLUE_90_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_BLUE_90_TS_DEAD_LEAVE(self)
-- end


-- --90 green --
-- function SCR_EVENT_VIVID_GREEN_90_TS_BORN_ENTER(self)
--     FlyMath(self, 90, 0, 0);
--     AttachEffect(self, 'F_ground008_green', 3, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_GREEN_90_TS_BORN_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_GREEN_90_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_GREEN_90_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_GREEN_90_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_GREEN_90_TS_DEAD_LEAVE(self)
-- end

-- --90 red --
-- function SCR_EVENT_VIVID_RED_90_TS_BORN_ENTER(self)
--     FlyMath(self, 90, 0, 0);
--     AttachEffect(self, 'F_ground008_red', 3, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_RED_90_TS_BORN_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_RED_90_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_RED_90_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_RED_90_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_RED_90_TS_DEAD_LEAVE(self)
-- end

-- --120 red --
-- function SCR_EVENT_VIVID_RED_120_TS_BORN_ENTER(self)
--     FlyMath(self, 120, 0, 0);
--     AttachEffect(self, 'F_ground008_red', 3, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_RED_120_TS_BORN_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_RED_120_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_RED_120_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_RED_120_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_RED_120_TS_DEAD_LEAVE(self)
-- end

-- --120 yellow --
-- function SCR_EVENT_VIVID_YELLOW_120_TS_BORN_ENTER(self)
--     FlyMath(self, 120, 0, 0);
--     AttachEffect(self, 'F_ground008_yellow', 3, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_YELLOW_120_TS_BORN_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_YELLOW_120_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_YELLOW_120_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_YELLOW_120_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_YELLOW_120_TS_DEAD_LEAVE(self)
-- end

-- --120 green --
-- function SCR_EVENT_VIVID_GREEN_120_TS_BORN_ENTER(self)
--     FlyMath(self, 120, 0, 0);
--     AttachEffect(self, 'F_ground008_green', 3, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_GREEN_120_TS_BORN_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_GREEN_120_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_GREEN_120_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_GREEN_120_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_GREEN_120_TS_DEAD_LEAVE(self)
-- end

-- --120 blue --
-- function SCR_EVENT_VIVID_BLUE_120_TS_BORN_ENTER(self)
--     FlyMath(self, 120, 0, 0);
--     AttachEffect(self, 'F_ground008_blue', 3, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_BLUE_120_TS_BORN_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_BLUE_120_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_BLUE_120_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_BLUE_120_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_BLUE_120_TS_DEAD_LEAVE(self)
-- end

-- --150 yellow --
-- function SCR_EVENT_VIVID_YELLOW_150_TS_BORN_ENTER(self)
--     FlyMath(self, 150, 0, 0);
--     AttachEffect(self, 'F_ground008_yellow', 3, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_YELLOW_150_TS_BORN_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_YELLOW_150_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_YELLOW_150_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_YELLOW_150_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_YELLOW_150_TS_DEAD_LEAVE(self)
-- end

-- --150 blue --
-- function SCR_EVENT_VIVID_BLUE_150_TS_BORN_ENTER(self)
--     FlyMath(self, 150, 0, 0);
--     AttachEffect(self, 'F_ground008_blue', 3, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_BLUE_150_TS_BORN_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_BLUE_150_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_BLUE_150_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_BLUE_150_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_BLUE_150_TS_DEAD_LEAVE(self)
-- end

-- --150 green --
-- function SCR_EVENT_VIVID_GREEN_150_TS_BORN_ENTER(self)
--     FlyMath(self, 150, 0, 0);
--     AttachEffect(self, 'F_ground008_green', 3, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_GREEN_150_TS_BORN_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_GREEN_150_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_GREEN_150_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_GREEN_150_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_GREEN_150_TS_DEAD_LEAVE(self)
-- end

-- --150 red --
-- function SCR_EVENT_VIVID_RED_150_TS_BORN_ENTER(self)
--     FlyMath(self, 150, 0, 0);
--     AttachEffect(self, 'F_ground008_red', 3, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_RED_150_TS_BORN_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_RED_150_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_RED_150_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_RED_150_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_RED_150_TS_DEAD_LEAVE(self)
-- end

-- --160 blue --
-- function SCR_EVENT_VIVID_BLUE_160_TS_BORN_ENTER(self)
--     FlyMath(self, 160, 0, 0);
--     AttachEffect(self, 'F_ground008_blue', 3, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_BLUE_160_TS_BORN_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_BLUE_160_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_BLUE_160_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_BLUE_160_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_BLUE_160_TS_DEAD_LEAVE(self)
-- end

-- --180 red --
-- function SCR_EVENT_VIVID_RED_180_TS_BORN_ENTER(self)
--     FlyMath(self, 180, 0, 0);
--     AttachEffect(self, 'F_ground008_red', 3, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_RED_180_TS_BORN_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_RED_180_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_RED_180_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_RED_180_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_RED_180_TS_DEAD_LEAVE(self)
-- end

-- --210 green --
-- function SCR_EVENT_VIVID_GREEN_210_TS_BORN_ENTER(self)
--     FlyMath(self, 210, 0, 0);
--     AttachEffect(self, 'F_ground008_green', 3, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_GREEN_210_TS_BORN_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_GREEN_210_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_GREEN_210_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_GREEN_210_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_GREEN_210_TS_DEAD_LEAVE(self)
-- end

-- --240 red --
-- function SCR_EVENT_VIVID_BLUE_240_TS_BORN_ENTER(self)
--     FlyMath(self, 240, 0, 0);
--     AttachEffect(self, 'F_ground008_blue', 3, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_BLUE_240_TS_BORN_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_BLUE_240_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_BLUE_240_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_BLUE_240_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_BLUE_240_TS_DEAD_LEAVE(self)
-- end

-- --270 RED --
-- function SCR_EVENT_VIVID_RED_270_TS_BORN_ENTER(self)
--     FlyMath(self, 270, 0, 0);
--     AttachEffect(self, 'F_ground008_red', 3, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_RED_270_TS_BORN_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_RED_270_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_RED_270_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_RED_270_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_RED_270_TS_DEAD_LEAVE(self)
-- end

-- --300 RED --
-- function SCR_EVENT_VIVID_RED_300_TS_BORN_ENTER(self)
--     FlyMath(self, 300, 0, 0);
--     AttachEffect(self, 'F_ground008_red', 3, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_RED_300_TS_BORN_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_RED_300_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_RED_300_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_RED_300_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_RED_300_TS_DEAD_LEAVE(self)
-- end

-- function VIVID_UPDOWN5(self)
--     local now_time = os.date('*t')
--     local sec = now_time['sec']
    
--     if sec%12 == 0 then
--         if sec ~= self.NumArg1 then
--             self.NumArg1 = sec;
--             local _height = GetFlyHeight(self)
--             local _max = 300;
--             local _min = 90;
            
--             if _height >= _max then
--                 FlyMath(self, _min, 3, 1)
--             elseif _height <= _min then
--                 FlyMath(self, _max, 3, 1)
--             end
--         end
--     end
-- end

-- function VIVID_UPDOWN6(self)
--     local now_time = os.date('*t')
--     local sec = now_time['sec']
    
--     if sec%4 == 0 then
--         if sec ~= self.NumArg1 then
--             self.NumArg1 = sec;
--             local _height = GetFlyHeight(self)
--             local _max = 150;
--             local _min = 30;
            
--             if _height >= _max then
--                 FlyMath(self, _min, 3, 1)
--             elseif _height <= _min then
--                 FlyMath(self, _max, 3, 1)
--             end
--         end
--     end
-- end

-- function VIVID_UPDOWN(self)
--     local now_time = os.date('*t')
--     local sec = now_time['sec']
    
--     if sec%4 == 0 then
--         if sec ~= self.NumArg1 then
--             self.NumArg1 = sec;
--             local _height = GetFlyHeight(self)
--             local _max = 60;
--             local _min = 30;
            
--             if _height >= _max then
--                 FlyMath(self, _min, 3, 1)
--             elseif _height <= _min then
--                 FlyMath(self, _max, 3, 1)
--             end
--         end
--     end
-- end

-- function VIVID_CITY_RED_HIDE(self)
--     local now_time = os.date('*t')
--     local sec = now_time['sec']
    
--     if sec%4 == 0 then
--         RemoveEffect(self, "F_ground008_red", 1)
--     elseif sec%2 == 0 then
--         AttachEffect(self, 'F_ground008_red', 3, "BOT");
--     end
-- end

-- function VIVID_CITY_BLUE_HIDE(self)
--     local now_time = os.date('*t')
--     local sec = now_time['sec']
    
--     if sec%4 == 0 then
--         RemoveEffect(self, "F_ground008_blue", 1)
--     elseif sec%2 == 0 then
--         AttachEffect(self, 'F_ground008_blue', 3, "BOT");
--     end
-- end

-- function VIVID_CITY_YELLOW_HIDE(self)
--     local now_time = os.date('*t')
--     local sec = now_time['sec']
    
--     if sec%4 == 0 then
--         RemoveEffect(self, "F_ground008_yellow", 1)
--     elseif sec%2 == 0 then
--         AttachEffect(self, 'F_ground008_yellow', 3, "BOT");
--     end
-- end

-- function VIVID_CITY_GREEN_HIDE(self)
--     local now_time = os.date('*t')
--     local sec = now_time['sec']
    
--     if sec%4 == 0 then
--         RemoveEffect(self, "F_ground008_green", 1)
--     elseif sec%2 == 0 then
--         AttachEffect(self, 'F_ground008_green', 3, "BOT");
--     end
-- end

-- function VIVID_CITY_30(self)
--     FlyMath(self, 30, 0, 0);
-- end

-- function VIVID_CITY_60(self)
--     FlyMath(self, 60, 0, 0);
-- end

-- function VIVID_CITY_90(self)
--     FlyMath(self, 90, 0, 0);
-- end

-- function VIVID_CITY_120(self)
--     FlyMath(self, 120, 0, 0);
-- end

-- function VIVID_CITY_150(self)
--     FlyMath(self, 150, 0, 0);
-- end

-- function VIVID_CITY_160(self)
--     FlyMath(self, 150, 0, 0);
-- end

-- function VIVID_CITY_180(self)
--     FlyMath(self, 180, 0, 0);
-- end

-- function VIVID_CITY_200(self)
--     FlyMath(self, 200, 0, 0);
-- end

-- function VIVID_CITY_210(self)
--     FlyMath(self, 210, 0, 0);
-- end

-- function VIVID_CITY_300(self)
--     FlyMath(self, 300, 0, 0);
-- end

-- function VIVID_UPDOWN2(self)
--     local now_time = os.date('*t')
--     local sec = now_time['sec']
    
--     if sec%4 == 0 then
--         if sec ~= self.NumArg1 then
--             self.NumArg1 = sec;
--             local _height = GetFlyHeight(self)
--             local _max = 150;
--             local _min = 120;
            
--             if _height >= _max then
--                 FlyMath(self, _min, 3, 1)
--             elseif _height <= _min then
--                 FlyMath(self, _max, 3, 1)
--             end
--         end
--     end
-- end

-- function VIVID_UPDOWN3(self)
--     local now_time = os.date('*t')
--     local sec = now_time['sec']
    
--     if sec%4 == 0 then
--         if sec ~= self.NumArg1 then
--             self.NumArg1 = sec;
--             local _height = GetFlyHeight(self)
--             local _max = 210;
--             local _min = 180;
            
--             if _height >= _max then
--                 FlyMath(self, _min, 3, 1)
--             elseif _height <= _min then
--                 FlyMath(self, _max, 3, 1)
--             end
--         end
--     end
-- end

-- function VIVID_UPDOWN4(self)
--     local now_time = os.date('*t')
--     local sec = now_time['sec']
    
--     if sec%6 == 0 then
--         if sec ~= self.NumArg1 then
--             self.NumArg1 = sec;
--             local _height = GetFlyHeight(self)
--             local _max = 230;
--             local _min = 160;
            
--             if _height >= _max then
--                 FlyMath(self, _min, 3, 1)
--             elseif _height <= _min then
--                 FlyMath(self, _max, 3, 1)
--             end
--         end
--     end
-- end

-- function VIVID_UPDOWN7(self)
--     local now_time = os.date('*t')
--     local sec = now_time['sec']
    
--     if sec%4 == 0 then
--         if sec ~= self.NumArg1 then
--             self.NumArg1 = sec;
--             local _height = GetFlyHeight(self)
--             local _max = 210;
--             local _min = 180;
            
--             if _height >= _max then
--                 FlyMath(self, _min, 3, 1)
--             elseif _height <= _min then
--                 FlyMath(self, _max, 3, 1)
--             end
--         end
--     end
-- end

-- function SCR_EVENT_VIVID_LINE_TS_BORN_ENTER(self)
--     AttachEffect(self, 'I_laser003_loop', 1, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_LINE_TS_BORN_UPDATE(self)
--     --AttachEffect(self, 'I_laser003_violet', 1, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_LINE_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_LINE_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_LINE_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_LINE_TS_DEAD_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_SHOT_LINE_TS_BORN_ENTER(self)
--     AttachEffect(self, 'I_laser003_shot_loop', 1, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_SHOT_LINE_TS_BORN_UPDATE(self)
--     --AttachEffect(self, 'I_laser003_violet', 1, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_SHOT_LINE_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_SHOT_LINE_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_SHOT_LINE_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_SHOT_LINE_TS_DEAD_LEAVE(self)
-- end


-- function SCR_EVENT_VIVID_GUNGHO_TS_BORN_ENTER(self)
--     AttachEffect(self, 'E_buff_gungho', 1, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_GUNGHO_TS_BORN_UPDATE(self)
--     --AttachEffect(self, 'I_laser003_violet', 1, 'BOT', 0, 0, 0, 0)
-- end

-- function SCR_EVENT_VIVID_GUNGHO_TS_BORN_LEAVE(self)
-- end

-- function SCR_EVENT_VIVID_GUNGHO_TS_DEAD_ENTER(self)
-- end

-- function SCR_EVENT_VIVID_GUNGHO_TS_DEAD_UPDATE(self)
-- end

-- function SCR_EVENT_VIVID_GUNGHO_TS_DEAD_LEAVE(self)
-- end