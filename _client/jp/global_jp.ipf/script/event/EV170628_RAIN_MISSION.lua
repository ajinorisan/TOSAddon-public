function SCR_JP_RAINMISSION_EVENT_CHECK(self)
    local aObj = GetAccountObj(self);
    local checkTable = {
    {1, 60}, {2, 70}, {3, 80}, {4, 90}, {5, 100}, {6, 110}, {7, 120}
    }
    
    if aObj.EVENT_170628_RAIN_MISSION_1 == 10 then
        local tx = TxBegin(self)
        TxEnableInIntegrate(tx) 
        TxGiveItem(tx, 'Event_Umbrella_Box_1', 1, "JP_RAIN")
        local ret = TxCommit(tx)
    elseif aObj.EVENT_170628_RAIN_MISSION_1 == 20 then
        local tx = TxBegin(self)
        TxEnableInIntegrate(tx) 
        TxGiveItem(tx, 'Event_Umbrella_Box_2', 1, "JP_RAIN")
        local ret = TxCommit(tx)
    elseif aObj.EVENT_170628_RAIN_MISSION_1 == 30 then
        local tx = TxBegin(self)
        TxEnableInIntegrate(tx)
        TxGiveItem(tx, 'Event_Umbrella_Box_3', 1, "JP_RAIN")
        local ret = TxCommit(tx)
    elseif aObj.EVENT_170628_RAIN_MISSION_1 == 40 then
        local tx = TxBegin(self)
        TxEnableInIntegrate(tx)
        TxGiveItem(tx, 'Event_Umbrella_Box_4', 1, "JP_RAIN")
        local ret = TxCommit(tx)
    elseif aObj.EVENT_170628_RAIN_MISSION_1 == 50 then
        local tx = TxBegin(self)
        TxEnableInIntegrate(tx)
        TxGiveItem(tx, 'Event_Umbrella_Box_5', 1, "JP_RAIN")
        local ret = TxCommit(tx)
    end
    
    for i = 1, table.getn(checkTable) do
        if aObj.EVENT_170628_RAIN_MISSION_1 == checkTable[i][2] then
            local tx = TxBegin(self)
            TxEnableInIntegrate(tx)
            TxGiveItem(tx, 'misc_talt', 5, "JP_RAIN")
            local ret = TxCommit(tx)
        end
    end
end

--Event JP Rain
function SCR_BUFF_ENTER_Event_Umbrella_1(self, buff, arg1, arg2, over)
    self.MSPD_BM = self.MSPD_BM + 1;
end

function SCR_BUFF_UPDATE_Event_Umbrella_1(self, buff, arg1, arg2, RemainTime, ret, over)
    if RemainTime > 1800000 then
        SetBuffRemainTime(self, buff.ClassName, 1800000)
    end
    return 1
end

function SCR_BUFF_LEAVE_Event_Umbrella_1(self, buff, arg1, arg2, over)
    self.MSPD_BM = self.MSPD_BM - 1;
end

-- 2
function SCR_BUFF_ENTER_Event_Umbrella_2(self, buff, arg1, arg2, over)
    self.MSPD_BM = self.MSPD_BM + 2;
end

function SCR_BUFF_UPDATE_Event_Umbrella_2(self, buff, arg1, arg2, RemainTime, ret, over)
    if RemainTime > 1800000 then
        SetBuffRemainTime(self, buff.ClassName, 1800000)
    end
    return 1
end

function SCR_BUFF_LEAVE_Event_Umbrella_2(self, buff, arg1, arg2, over)
    self.MSPD_BM = self.MSPD_BM - 2;
end

-- 3
function SCR_BUFF_ENTER_Event_Umbrella_3(self, buff, arg1, arg2, over)
    self.MSPD_BM = self.MSPD_BM + 3;
end

function SCR_BUFF_UPDATE_Event_Umbrella_3(self, buff, arg1, arg2, RemainTime, ret, over)
    if RemainTime > 1800000 then
        SetBuffRemainTime(self, buff.ClassName, 1800000)
    end
    return 1
end

function SCR_BUFF_LEAVE_Event_Umbrella_3(self, buff, arg1, arg2, over)
    self.MSPD_BM = self.MSPD_BM - 3;
end

-- 4
function SCR_BUFF_ENTER_Event_Umbrella_4(self, buff, arg1, arg2, over)
    self.MSPD_BM = self.MSPD_BM + 4;
end

function SCR_BUFF_UPDATE_Event_Umbrella_4(self, buff, arg1, arg2, RemainTime, ret, over)
    if RemainTime > 1800000 then
        SetBuffRemainTime(self, buff.ClassName, 1800000)
    end
    return 1
end

function SCR_BUFF_LEAVE_Event_Umbrella_4(self, buff, arg1, arg2, over)
    self.MSPD_BM = self.MSPD_BM - 4;
end

-- 5
function SCR_BUFF_ENTER_Event_Umbrella_5(self, buff, arg1, arg2, over)
    self.MSPD_BM = self.MSPD_BM + 5;
end

function SCR_BUFF_UPDATE_Event_Umbrella_5(self, buff, arg1, arg2, RemainTime, ret, over)
    if RemainTime > 1800000 then
        SetBuffRemainTime(self, buff.ClassName, 1800000)
    end
    return 1
end

function SCR_BUFF_LEAVE_Event_Umbrella_5(self, buff, arg1, arg2, over)
    self.MSPD_BM = self.MSPD_BM - 5;
end
