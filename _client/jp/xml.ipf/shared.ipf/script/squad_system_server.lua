-- squad_system_server.lua

function SCR_CREATE_SQUAD(pc, squad_name, type)
    if IsRunningScript(pc, 'TX_CREATE_SQUAD') == 1 then
        return
    end

    if IsEnableToCreateSquad(pc, squad_name, type) == false then
        return
    end

    local have_cnt = GetInvItemCountStr(pc, MONEY_NAME);    
    local required_silver = 1000000
    if required_silver ~= 0 and IsGreaterThanForBigNumber(required_silver ,have_cnt) == 1 then
        SendSysMsg(pc, 'Auto_SilBeoKa_BuJogHapNiDa.')
        return
    end

    RunScript('TX_CREATE_SQUAD', pc, squad_name, type)
end

function TX_CREATE_SQUAD(pc, squad_name, type)

    local tx = TxBegin(pc)
    
    TxCreateSquad(tx, pc, squad_name, type)
    TxTakeItem(tx, 'Vis', 1000000, 'TX_CREATE_SQUAD')

    local ret = TxCommit(tx)
    
    if ret == 'SUCCESS' then
        -- mongo log
        local log_list = {}
        table.insert(log_list, 'Type')
        table.insert(log_list, 'Create')
        table.insert(log_list, 'Name')
        table.insert(log_list, squad_name)
        table.insert(log_list, 'SquadType')
        table.insert(log_list, tostring(type))

        CustomMongoLog_WithList(pc, 'SquadSystem', log_list) 
    end
end

function SCR_DISBAND_SQUAD(pc, type)
    if IsRunningScript(pc, 'TX_DISBAND_SQUAD') == 1 then
        return
    end

    if IsEnableToDisbandSquad(pc, type) == false then
        return
    end

    RunScript('TX_DISBAND_SQUAD', pc,type)
end

function TX_DISBAND_SQUAD(pc, type)

    local tx = TxBegin(pc)
    
    TxDisbandSquad(tx, pc, type)

    local ret = TxCommit(tx)
    
    if ret == 'SUCCESS' then
        -- mongo log
        local log_list = {}
        table.insert(log_list, 'Type')
        table.insert(log_list, 'Disband')        
        table.insert(log_list, 'SquadType')
        table.insert(log_list, tostring(type))

        CustomMongoLog_WithList(pc, 'SquadSystem', log_list) 
    end
end

