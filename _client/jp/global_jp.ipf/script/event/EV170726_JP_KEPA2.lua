function SCR_JP_KEPA2_MISSION_EVENT_JOIN(self, pc)        
    if GetServerNation() ~= 'JP' then
        return
    end
    if pc.Lv < 70 then
        return
    end
    local aObj = GetAccountObj(pc);
    local now_time = os.date('*t')
    local yday = now_time['yday']
    
    
    if aObj.EV170726_KEPA2_2 ~= yday then           
        local tx = TxBegin(pc)
        TxSetIESProp(tx, aObj, 'EV170726_KEPA2_2', yday);
        TxSetIESProp(tx, aObj, 'EV170726_KEPA2_1', 0);
        local ret = TxCommit(tx)
    end
    if IsBuffApplied(pc, 'Premium_Token') == 'YES' and aObj.EV170726_KEPA2_2 == yday and aObj.EV170726_KEPA2_1 <= 1 then
        AUTOMATCH_INDUN_DIALOG(pc, nil, 'KepaEventMission')
        local tx = TxBegin(pc)
        TxSetIESProp(tx, aObj, 'EV170726_KEPA2_3', 0);
        local ret = TxCommit(tx)    
    elseif IsBuffApplied(pc, 'Premium_Token') == 'YES' and aObj.EV170726_KEPA2_2 == yday and aObj.EV170726_KEPA2_1 > 1 then
        ShowOkDlg(pc, 'NPC_EVENT_TODAY_NUMBER_5', 1)
        return
    elseif aObj.EV170726_KEPA2_1 == 0 and aObj.EV170726_KEPA2_2 == yday then
        AUTOMATCH_INDUN_DIALOG(pc, nil, 'KepaEventMission')
        local tx = TxBegin(pc)
        TxSetIESProp(tx, aObj, 'EV170726_KEPA2_3', 0);
        local ret = TxCommit(tx)
    elseif aObj.EV170726_KEPA2_1 > 0 and aObj.EV170726_KEPA2_2 == yday then
        ShowOkDlg(pc, 'NPC_EVENT_TODAY_NUMBER_5', 1)
        return
    end
end

function SCR_JP_KEPA2_MISSION_EVENT_CHECK(self, pc)
    if GetServerNation() ~= 'JP' then
        return
    end
    local kepaTicket = GetInvItemCount(pc, "Event_Kepa2_Ticket")
    
    if kepaTicket >= 5 then
        local tx = TxBegin(pc)
        TxGiveItem(tx, 'Moru_Silver', 1, 'Kepa2_EventMission');
        TxTakeItem(tx, 'Event_Kepa2_Ticket', 5, 'Kepa2_EventMission');
        local ret = TxCommit(tx)
    else
        ShowOkDlg(pc, 'NPC_EVENT_KEPA2', 1)
        return    
    end           
end   

function SCR_JP_KEPA2_MISSION_EVENT_REWARD(self)
    local aObj = GetAccountObj(self);
        if aObj.EV170726_KEPA2_3 == 0 then
            RunScript('GIVE_ITEM_TX', self, 'Event_Kepa2_Ticket', 1, "Kepa2_EventMission")
            RunScript('ACCOUNT_EV170726_KEPA2_3_TX', self, 1)
            RunScript('ACCOUNT_EV170726_KEPA2_1_TX', self, 1)
        end
end

function ACCOUNT_EV170726_KEPA2_1_TX(self, count)
    local aObj = GetAccountObj(self);
    	local tx = TxBegin(self);
    	TxEnableInIntegrateIndun(tx);
        TxSetIESProp(tx, aObj, 'EV170726_KEPA2_1', aObj.EV170726_KEPA2_1 + count)
    	local ret = TxCommit(tx);
	return ret
end


function ACCOUNT_EV170726_KEPA2_3_TX(self, count)
    local aObj = GetAccountObj(self);
    	local tx = TxBegin(self);
    	TxEnableInIntegrateIndun(tx);
        TxSetIESProp(tx, aObj, 'EV170726_KEPA2_3', count)
    	local ret = TxCommit(tx);
	return ret
end