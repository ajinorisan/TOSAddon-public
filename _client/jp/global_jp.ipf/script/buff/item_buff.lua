function SCR_BUFF_UPDATE_item_poison_fast(self, buff, arg1, arg2, over)
    local caster = GetBuffCaster(buff);
    if caster == nil then
    caster = self;
    end
    
    local ZoneClassName = GetZoneName(self) --FLOWER EVENT --
    if ZoneClassName == 'f_whitetrees_56_1_event' then
        TakeDamage(self, self, "None", self.MHP * 0.015, "Poison", "None", "TrueDamage", HIT_POISON, HITRESULT_BLOW, 0, 0);    
    else
        TakeDamage(self, self, "None", arg1, "Poison", "None", "TrueDamage", HIT_POISON, HITRESULT_BLOW, 0, 0);
    end
    return 1;
end

function SCR_BUFF_ENTER_GOOD_STAMP_EFFECT(self, buff, arg1, arg2, over)
    OverrideSurfaceType(self, 'good_stamp')
    PlayEffect(self, "F_pc_welldone_ground_A", 1.5, 1.5, 'BOT')
end

function SCR_BUFF_LEAVE_GOOD_STAMP_EFFECT(self, buff, arg1, arg2, over)
    OverrideSurfaceType(self, 'None')
end

function SCR_BUFF_ENTER_Event_Steam_Drug_RedOx(self, buff, arg1, arg2, over)
    self.SR_BM = self.SR_BM + 1
    self.MSP_BM = self.MSP_BM + 1000;
end

function SCR_BUFF_UPDATE_Event_Steam_Drug_RedOx(self, buff, arg1, arg2, RemainTime, ret, over)
    AddStamina(self, 99999);
    return 1;
end

function SCR_BUFF_LEAVE_Event_Steam_Drug_RedOx(self, buff, arg1, arg2, over)
    self.SR_BM = self.SR_BM - 1
    self.MSP_BM = self.MSP_BM - 1000
end

function SCR_BUFF_ENTER_Event_Steam_Base_Buff(self, buff, arg1, arg2, over)
    self.MSPD_BM = self.MSPD_BM + 2;
end

function SCR_BUFF_LEAVE_Event_Steam_Base_Buff(self, buff, arg1, arg2, over)
    self.MSPD_BM = self.MSPD_BM - 2;
end

function SCR_BUFF_ENTER_Event_Cb_Buff_Item(self, buff, arg1, arg2, over)
    PlayEffect(self, 'F_sys_expcard_normal', 2.5, 1, "BOT", 1);
    self.MHP_BM = self.MHP_BM + 2000;
    self.MSP_BM = self.MSP_BM + 1000;
    self.MSPD_BM = self.MSPD_BM + 1;  
end

function SCR_BUFF_UPDATE_Event_Cb_Buff_Item(self, buff, arg1, arg2, RemainTime, ret, over)

    if RemainTime > 3600000 then
        SetBuffRemainTime(self, buff.ClassName, 3600000)
    end
    return 1

end

function SCR_BUFF_LEAVE_Event_Cb_Buff_Item(self, buff, arg1, arg2, over)
    self.MHP_BM = self.MHP_BM - 2000;
    self.MSP_BM = self.MSP_BM - 1000;
    self.MSPD_BM = self.MSPD_BM - 1;
end

function SCR_BUFF_ENTER_Event_Cb_Buff_Potion(self, buff, arg1, arg2, over)
    PlayEffect(self, 'F_sys_expcard_normal', 2.5, 1, "BOT", 1);
    self.PATK_BM = self.PATK_BM + 500
	self.MATK_BM = self.MATK_BM + 500
end

function SCR_BUFF_UPDATE_Event_Cb_Buff_Potion(self, buff, arg1, arg2, RemainTime, ret, over)

    if RemainTime > 3600000 then
        SetBuffRemainTime(self, buff.ClassName, 3600000)
    end
    return 1

end

function SCR_BUFF_LEAVE_Event_Cb_Buff_Potion(self, buff, arg1, arg2, over)
    self.PATK_BM = self.PATK_BM - 500
	self.MATK_BM = self.MATK_BM - 500
end

function SCR_USE_Event_Returner_Box_JP(pc)
    local tx = TxBegin(pc);
    TxGiveItem(tx, 'Premium_RankReset_14d', 1, 'Event_Returner_Box_JP');
    TxGiveItem(tx, 'Event_Cb_Buff_Potion', 1, 'Event_Returner_Box_JP');
    TxGiveItem(tx, 'Event_Cb_Buff_Item', 5, 'Event_Returner_Box_JP');
    TxGiveItem(tx, 'Drug_Event_Looting_Potion_14d', 5, 'Event_Returner_Box_JP');
    local ret = TxCommit(tx);
end

function SCR_BUFF_ENTER_Event_Steam_Carnival_Fire(self, buff, arg1, arg2, over)
    SetMSPDBuffInfo(self,"Event_Steam_Carnival_Fire", 2)
    self.PATK_BM = self.PATK_BM + 50;
    self.MATK_BM = self.MATK_BM + 50;

    local x,y,z = GetPos(self);
    local fndList1, fndCount1 = SelectObjectPos(self, x, y, z, 50, "ALL");
    
    for i = 1, fndCount1 do
        --print(fndList1[i].ClassName)
        if fndList1[i].ClassName == 'Scarecrow' then
            LookAt(self, fndList1[i])
            local EquipOuter = GetEquipItem(self, "OUTER")
            if EquipOuter.ClassName == 'Steam_Event_costume_Com_17' or EquipOuter.ClassName == 'Steam_Event_costume_Com_18' then
                AddBuff(self,self, 'Event_Steam_Carnival_Fire_2', 1, 0, 3600000, 1)
                SendAddOnMsg(self, "NOTICE_Dm_Clear", ScpArgMsg("EVENT_STEAM_CARNIVAL_FIRE_MSG2"), 3);
            elseif IsBuffApplied(self, 'Event_Steam_Carnival_Fire_2') == 'NO' and (EquipOuter.ClassName ~= 'Steam_Event_costume_Com_17' or EquipOuter.ClassName ~= 'Steam_Event_costume_Com_18') then
                SendAddOnMsg(self, "NOTICE_Dm_scroll", ScpArgMsg("EVENT_STEAM_CARNIVAL_FIRE_MSG3"), 3)
                return
            elseif EquipOuter.ClassName ~= 'Steam_Event_costume_Com_17' or EquipOuter.ClassName ~= 'Steam_Event_costume_Com_18' then
                SendAddOnMsg(self, "NOTICE_Dm_scroll", ScpArgMsg("EVENT_STEAM_CARNIVAL_FIRE_MSG3"), 3)
                return            
            end
        end
    end
end

function SCR_BUFF_UPDATE_Event_Steam_Carnival_Fire(self, buff, arg1, arg2, RemainTime, ret, over)
    SCR_BUFF_UPDATE_REMAINTIME_IES_APPLYTIME_SET(self, buff, RemainTime)
    return 1
end

function SCR_BUFF_LEAVE_Event_Steam_Carnival_Fire(self, buff, arg1, arg2, over)
    RemoveMSPDBuffInfo(self,"Event_Steam_Carnival_Fire")
    self.PATK_BM = self.PATK_BM - 50;
    self.MATK_BM = self.MATK_BM - 50;
end

-- Red Apple
function SCR_BUFF_ENTER_Steam_Drug_Heal100HP_Dot(self, buff, arg1, arg2, over)
    local healHp = self.MHP * (arg1 / 100);
    
    if self.HPPotion_BM > 0 then 
        healHp = math.floor(healHp * (1 + self.HPPotion_BM/100));
    end
    Heal(self, healHp, 0);
end

function SCR_BUFF_UPDATE_Steam_Drug_Heal100HP_Dot(self, buff, arg1, arg2, RemainTime, ret, over)
   local healHp = self.MHP * (arg1 / 100);
    
    if self.HPPotion_BM > 0 then 
        healHp = math.floor(healHp * (1 + self.HPPotion_BM/100));
    end

    healHp = healHp / 5
    Heal(self, healHp, 0);
    return 1;
end

function SCR_BUFF_LEAVE_Steam_Drug_Heal100HP_Dot(self, buff, arg1, arg2, over)

end

-- Blue Apple
function SCR_BUFF_ENTER_Steam_Drug_Heal100SP_Dot(self, buff, arg1, arg2, over)
    local healSp = self.MSP * (arg1 / 100);
    
    if self.SPPotion_BM > 0 then
        healSp = math.floor(healSp * (1 + self.SPPotion_BM/100));
    end
    HealSP(self, healSp, 0);
end

function SCR_BUFF_UPDATE_Steam_Drug_Heal100SP_Dot(self, buff, arg1, arg2, RemainTime, ret, over)

    local healSp = self.MSP * (arg1 / 100);
    
    if self.SPPotion_BM > 0 then
        healSp = math.floor(healSp * (1 + self.SPPotion_BM/100));
    end
    
    healSp = math.floor(healSp / 5);
    HealSP(self, healSp, 0);
    return 1;
end

function SCR_BUFF_LEAVE_Steam_Drug_Heal100SP_Dot(self, buff, arg1, arg2, over)

end