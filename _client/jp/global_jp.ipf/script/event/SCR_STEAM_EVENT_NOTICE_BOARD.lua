function SCR_STEAM_TREASURE_EVENT_DIALOG(self,pc)

    ShowOkDlg(pc, 'GLOBAL_EVENT_BOARD_NO_EVENT', 1) -- 현재 이벤트 알림판에서 진행중인 이벤트가 없습니다. --
    
    -- local select = ShowSelDlg(pc, 0, 'EV_DAILYBOX_SEL', ScpArgMsg("EVENT_1805_NEWCLASS_RESET_MSG1"), ScpArgMsg("NPC_EVENT_VIVID_CITY_SEL1"), ScpArgMsg("Cancel"))

    -- if select == 1 then
    --     SCR_EVENT_1812_STEAM_RESET_NPC_DIALOG(self, pc)
    -- elseif select == 2 then
    --     SCR_EVENT_VIVID_CITY_DIALOG(self,pc)
    -- end
end

function SCR_STEAM_TREASURE_EVENT_1902_WEEKEND_DIALOG(self, pc) -- 버전업 기년 특별 접속 보상 이벤트 해외 전용 보상용 NPC -- 
    local aObj = GetAccountObj(pc);
    local now_time = os.date('*t')
    local month = now_time['month']
    local year = now_time['year']
    local day = now_time['day']
    local wday = now_time['wday']
	local nowbasicyday = SCR_DATE_TO_YDAY_BASIC_2000(year, month, day)
    local dayCheckReward = {
        {3, 'Ability_Point_Stone_1000_14d_Team', 5},
        {4, 'EVENT_190124_RankReset_Point_Lv2', 1},
        {10, 'Moru_Gold_14d_Team', 2},
        {11, 'Ability_Point_Stone_1000_14d_Team', 5},
        {12, 'EVENT_190124_RankReset_Point_Lv2', 1},
        {17, 'Moru_Gold_14d_Team', 2},
        {18, 'Ability_Point_Stone_1000_14d_Team', 5},
        {24, 'EVENT_190124_RankReset_Point_Lv2', 1},
        {25, 'Moru_Gold_14d_Team', 2}
    }
    --print(day)

    if pc.Lv < 50 then
        SendAddOnMsg(pc, "NOTICE_Dm_scroll", ScpArgMsg("EVENT_1801_ORB_MSG8","LV",50), 10);
        return
    end
    
    if nowbasicyday <= SCR_DATE_TO_YDAY_BASIC_2000(2019, 8, 29) then
        if (wday == 1 or wday == 7) or (day == 12) then
            local select = ShowSelDlg(pc,0, 'STEAM_TREASURE_EVENT_1902_WEEKEND_NPC_DLG1', ScpArgMsg("Receieve"), ScpArgMsg("Cancel"))
            --ShowOkDlg(pc, 'STEAM_TREASURE_EVENT_1902_WEEKEND_NPC_DLG1', 1)
            if select == 1 then 
                if aObj.STEAM_TREASURE_EVENT_1902_WEEKEND ~= day then
                    for i = 1, #dayCheckReward do
                        local tx = TxBegin(pc);
                        local result = i
                        --print(result)
                        if dayCheckReward[result][1] == day then
                            for j = 2, #dayCheckReward[result], 2 do
                                --print(j)
                                --print(dayCheckReward[result][j]..'/'..dayCheckReward[result][j+1])
                                TxSetIESProp(tx, aObj, 'STEAM_TREASURE_EVENT_1902_WEEKEND', day)
                                TxGiveItem(tx, dayCheckReward[result][j], dayCheckReward[result][j+1], "STEAM_TREASURE_EVENT_1902_WEEKEND")
                            end
                        --else
                            --SendAddOnMsg(pc, "NOTICE_Dm_scroll", ScpArgMsg("EVENT_STEAM_1903_CHOCO_REWARD_SEL2"), 5);
                        end
                        local ret = TxCommit(tx);
                        --print(aObj.STEAM_TREASURE_EVENT_1902_WEEKEND)
                    end
                else
                    SendAddOnMsg(pc, "NOTICE_Dm_Clear", ScpArgMsg("UNDER301_EVENT1_REWARD_TAKE"), 5); -- 이미 보상을 받았습니다. -- 
                end
            end
        else
            SendAddOnMsg(pc, "NOTICE_Dm_scroll", ScpArgMsg("EVENT_STEAM_1903_CHOCO_REWARD_SEL2"), 5);        
        end
    else
        SendAddOnMsg(pc, "NOTICE_Dm_scroll", ScpArgMsg("EVENT_STEAM_1903_CHOCO_REWARD_SEL2"), 5);
    end
end