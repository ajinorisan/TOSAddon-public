--cube option
function SCR_USE_ITEM_WHITECUBE(pc)
    local tx = TxBegin(pc) 
    TxGiveItem(tx, "Hat_628297", 1, "WHITE_HAIRACC")
    local ret = TxCommit(tx)
end

--cany option
function SCR_BUFF_ENTER_Event_WhiteDay_Candy_1(self, buff, arg1, arg2, over)
    self.PATK_BM = self.PATK_BM + 100
	self.MATK_BM = self.MATK_BM + 100
end

function SCR_BUFF_UPDATE_Event_WhiteDay_Candy_1(self, buff, arg1, arg2, RemainTime, ret, over)
    if RemainTime > 300000 then
        SetBuffRemainTime(self, buff.ClassName, 300000)
    end
    return 1
end

function SCR_BUFF_LEAVE_Event_WhiteDay_Candy_1(self, buff, arg1, arg2, over)
    self.PATK_BM = self.PATK_BM - 100
	self.MATK_BM = self.MATK_BM - 100
end

function SCR_BUFF_ENTER_Event_WhiteDay_Candy_2(self, buff, arg1, arg2, over)
    self.DEF_BM = self.DEF_BM + 100
	self.MDEF_BM = self.MDEF_BM + 100
end

function SCR_BUFF_UPDATE_Event_WhiteDay_Candy_2(self, buff, arg1, arg2, RemainTime, ret, over)
    if RemainTime > 300000 then
        SetBuffRemainTime(self, buff.ClassName, 300000)
    end
    return 1
end

function SCR_BUFF_LEAVE_Event_WhiteDay_Candy_2(self, buff, arg1, arg2, over)
    self.DEF_BM = self.DEF_BM - 100
	self.MDEF_BM = self.MDEF_BM - 100
end

function SCR_BUFF_ENTER_Event_WhiteDay_Candy_4(self, buff, arg1, arg2, over)
    self.MSPD_BM = self.MSPD_BM + 3
end

function SCR_BUFF_UPDATE_Event_WhiteDay_Candy_4(self, buff, arg1, arg2, RemainTime, ret, over)
    if RemainTime > 300000 then
        SetBuffRemainTime(self, buff.ClassName, 300000)
    end
    return 1
end

function SCR_BUFF_LEAVE_Event_WhiteDay_Candy_4(self, buff, arg1, arg2, over)
    self.MSPD_BM = self.MSPD_BM - 3
end

--set item option
function SCR_set_044_WHITE2_ENTER(pc)
    pc.DEF_BM = pc.DEF_BM + 50
    pc.MDEF_BM = pc.MDEF_BM + 50
end

function SCR_set_044_WHITE2_LEAVE(pc)
    pc.DEF_BM = pc.DEF_BM - 50
    pc.MDEF_BM = pc.MDEF_BM - 50
end

function SCR_set_044_WHITE3_ENTER(pc)
    pc.LargeSize_Atk_BM = pc.LargeSize_Atk_BM + 200
    pc.SR_BM = pc.SR_BM + 1;
end

function SCR_set_044_WHITE3_LEAVE(pc)
    pc.LargeSize_Atk_BM = pc.LargeSize_Atk_BM - 200
    pc.SR_BM = pc.SR_BM - 1
end

--npc option
function SCR_NPC_EVENT_WHITE01_DIALOG(self, pc)
    local select = ShowSelDlg(pc, 0, 'NPC_EVENT_WHITE01_DLG1', ScpArgMsg("Wihte_Select"), ScpArgMsg("Wihte_Select1"), ScpArgMsg("Wihte_Select2"), ScpArgMsg("Wihte_Select3"), ScpArgMsg("GT_LUTHA_NPC_SELECT_CLOSE"))
    local CandySet = GetInvItemCount(pc, "Event_WhiteDay_Candy_Set")
    local aObj = GetAccountObj(pc);          
        if select == 1 then
            local input = ShowTextInputDlg(pc, 0, 'NPC_EVENT_WHITE01_DLG6')
                local price = 100
                local count = GetInvItemCount(pc, 'Vis')
                local value = price * input       
                input = tonumber(input)
                    if input ~= nil and input > 0 then
                        if count >= value then
                            GIVE_TAKE_ITEM_TX(pc, 'R_WHITE_01/'..input, 'Vis/'..value, 'WHITE_R')
                            ShowOkDlg(pc, 'NPC_EVENT_WHITE01_DLG7', 1)
                        else
                            SendSysMsg(pc,"Auto_SilBeoKa_BuJogHapNiDa.", 1)
                        end
                    else
                        ShowOkDlg(pc,dlgTable[3], 1)
                    end
        end
        if select == 2 then
            if CandySet >= 1 then
                ShowOkDlg(pc,'NPC_EVENT_WHITE01_DLG2', 1)
                local select2 = ShowSelDlg(pc, 0, 'NPC_EVENT_WHITE01_DLG3', ScpArgMsg("Wihte_Select1_4"), ScpArgMsg("Wihte_Select1_1"), ScpArgMsg("Wihte_Select1_2"), ScpArgMsg("Wihte_Select1_3"))
                    if select2 == 1 then
                        return 0;
                    end
                    if select2 == 2 then
                        local tx = TxBegin(pc) 
                        TxTakeItem(tx, "Event_WhiteDay_Candy_Set", 1, "WHITE1")
                        TxGiveItem(tx, "NECK99_110", 1, "WHITE_NECK")
                        TxSetIESProp(tx, aObj, 'EVENT_WHITE_R1', aObj.EVENT_WHITE_R1 + 1)
                        local ret = TxCommit(tx)
                    elseif select2 == 3 then
                        local tx = TxBegin(pc) 
                        TxTakeItem(tx, "Event_WhiteDay_Candy_Set", 1, "WHITE1")
                        TxGiveItem(tx, "BRC99_114", 1, "WHITE_RING1")
                        TxSetIESProp(tx, aObj, 'EVENT_WHITE_R1', aObj.EVENT_WHITE_R1 + 1)
                        local ret = TxCommit(tx)
                    elseif select2 == 4 then
                        local tx = TxBegin(pc) 
                        TxTakeItem(tx, "Event_WhiteDay_Candy_Set", 1, "WHITE1")
                        TxGiveItem(tx, "BRC99_115", 1, "WHITE_RING2")
                        TxSetIESProp(tx, aObj, 'EVENT_WHITE_R1', aObj.EVENT_WHITE_R1 + 1)
                        local ret = TxCommit(tx)
                    end
            elseif CandySet < 1 then
                ShowOkDlg(pc,'NPC_EVENT_WHITE01_DLG4', 1)                                      
            end
        end
        if select == 3 then
            if CandySet >= 1 then
                ShowOkDlg(pc,'NPC_EVENT_WHITE01_DLG2', 1)
                local tx = TxBegin(pc) 
                TxTakeItem(tx, "Event_WhiteDay_Candy_Set", 1, "WHITE1")
                TxSetIESProp(tx, aObj, 'EVENT_WHITE_R1', aObj.EVENT_WHITE_R1 + 1)
                local ret = TxCommit(tx)
                if ret == "SUCCESS" then
                    AddBuff(self, pc, 'Event_WhiteDay_Buff', 1, 0, 1800000, 1)
                end
            elseif CandySet < 1 then
                ShowOkDlg(pc,'NPC_EVENT_WHITE01_DLG4', 1)                
            end
        end
        if aObj.EVENT_WHITE_R1 == 3 then            
            if aObj.EVENT_WHITE_R2 == 0 then 
                ShowOkDlg(pc,'NPC_EVENT_WHITE01_DLG5', 1)
                local tx = TxBegin(pc)
                TxGiveItem(tx, "Event_WhiteDay_Cube_1", 1, "WHITE_CUBE")
                TxSetIESProp(tx, aObj, 'EVENT_WHITE_R2', aObj.EVENT_WHITE_R2 + 1)
                local ret = TxCommit(tx)
            end
        end
        if select == 4 then
            SendAddOnMsg(pc, 'NOTICE_Dm_!', ScpArgMsg("Wihte_Select3_1", "WHITECOUNT", aObj.EVENT_WHITE_R1), 5)
        end
end

--drop option
function SCR_EVENT_WHITEDAY(self, sObj, msg, argObj, argStr, argNum, partyFlag)	
	local rand = IMCRandom(1, 30)--350/0.28   200/0.5
	if partyFlag == 'YES' then
	    local rand = IMCRandom(1, 150)
	end
    local randCanyList = IMCRandom(1, 4)
    local monIES = GetClass('Monster', argObj.ClassName)
    local dropItem = {
            {1,'Event_WhiteDay_Candy_1'},{2,'Event_WhiteDay_Candy_2'},{3,'Event_WhiteDay_Candy_3'},{4,'Event_WhiteDay_Candy_4'}
        }
        if rand == 1 then    
            if argObj ~= nil and argObj.ClassName ~= 'PC' then       
                if GetCurrentFaction(argObj) == 'Monster' and monIES.Faction == 'Monster' and self.Lv - 20 <= argObj.Lv then  
                    local pcLayer = GetLayer(self)
                
                if pcLayer > 0 then
                    local obj = GetLayerObject(GetZoneInstID(self), pcLayer);
                    local flag = 'NO'
                    if obj ~= nil then
                        if obj.EventName ~= nil and obj.EventName ~= "None" then
                            local etc = GetETCObject(self)
        				    if GetPropType(etc, obj.EventName..'_TRACK') ~= nil then
        				        local trackInitCount = etc[obj.EventName..'_TRACK']
        				        if trackInitCount <= 1 then
        				            flag = 'YES'
        				        end
        				    end
                        end
                    end
       			    if flag == 'NO' then
       			        return
       			    end
                end          
                    local tx = TxBegin(self);
        			TxGiveItem(tx, dropItem[randCanyList][2], 1, "WHITE_DROPCANDY");
        			local ret = TxCommit(tx);      		
                end
            end
        end
end

  