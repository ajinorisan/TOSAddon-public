function DLC_BOX1(pc)
    local tx = TxBegin(pc);
    TxGiveItem(tx, 'steam_Premium_tpBox_650', 1, 'DLC_BOX1');
    TxGiveItem(tx, 'steam_PremiumToken_60d', 1, 'DLC_BOX1');
    TxGiveItem(tx, 'steam_JOB_HOGLAN_COUPON', 1, 'DLC_BOX1');
    TxGiveItem(tx, 'steam_Hat_629003', 1, 'DLC_BOX1');
    TxGiveItem(tx, 'steam_Hat_629004', 1, 'DLC_BOX1');
    TxGiveItem(tx, 'Premium_SkillReset', 1, 'DLC_BOX1');
    TxGiveItem(tx, 'steam_Premium_StatReset', 1, 'DLC_BOX1');
    local ret = TxCommit(tx);
end

function DLC_BOX2(pc)
    local tx = TxBegin(pc);
    TxGiveItem(tx, 'steam_Premium_tpBox_380', 1, 'DLC_BOX2');
    TxGiveItem(tx, 'steam_PremiumToken_30day', 1, 'DLC_BOX2');
    TxGiveItem(tx, 'steam_Hat_629004', 1, 'DLC_BOX2');
    local ret = TxCommit(tx);
end

function DLC_BOX3(pc)
    local tx = TxBegin(pc);
    TxGiveItem(tx, 'steam_Premium_tpBox_160', 1, 'DLC_BOX3');
    local ret = TxCommit(tx);
end

function GIVE_MIC_10(pc)
    local tx = TxBegin(pc);
    TxGiveItem(tx, 'Mic', 10, 'TPSHOP_MIC_50');
    local ret = TxCommit(tx);
end

function GIVE_ENCHANTSCROLL_10(pc)
    local tx = TxBegin(pc);
    TxGiveItem(tx, 'Premium_Enchantchip', 10, 'TPSHOP_ENCHANTSCROLL_20');
    local ret = TxCommit(tx);
end

function DLC_BOX4(pc)
    local tx = TxBegin(pc);
    TxGiveItem(tx, 'steam_Premium_tpBox_650', 1, 'DLC_BOX4');
    TxGiveItem(tx, 'steam_PremiumToken_60d', 1, 'DLC_BOX4');
    TxGiveItem(tx, 'steam_JOB_HOGLAN_COUPON', 1, 'DLC_BOX4');
    TxGiveItem(tx, 'steam_Hat_629003', 1, 'DLC_BOX4');
    TxGiveItem(tx, 'steam_Hat_629004', 1, 'DLC_BOX4');
    TxGiveItem(tx, 'Premium_SkillReset', 1, 'DLC_BOX4');
    TxGiveItem(tx, 'steam_Premium_StatReset', 1, 'DLC_BOX4');
    local ret = TxCommit(tx);
end

function DLC_BOX5(pc)
    local tx = TxBegin(pc);
    TxGiveItem(tx, 'steam_Premium_tpBox_380', 1, 'DLC_BOX5');
    TxGiveItem(tx, 'steam_PremiumToken_30day', 1, 'DLC_BOX5');
    TxGiveItem(tx, 'steam_Hat_629004', 1, 'DLC_BOX5');
    local ret = TxCommit(tx);
end

function DLC_BOX6(pc)
    local tx = TxBegin(pc);
    TxGiveItem(tx, 'steam_Premium_tpBox_190', 1, 'DLC_BOX6');
    TxGiveItem(tx, 'PremiumToken_15d', 1, 'DLC_BOX6');
    TxGiveItem(tx, 'RestartCristal', 15, 'DLC_BOX6');
    TxGiveItem(tx, 'Premium_boostToken', 5, 'DLC_BOX6');
    TxGiveItem(tx, 'Mic', 15, 'DLC_BOX6');
    TxGiveItem(tx, 'Premium_WarpScroll', 15, 'DLC_BOX6');
    TxGiveItem(tx, 'Drug_Premium_HP1', 20, 'DLC_BOX6');
    TxGiveItem(tx, 'Drug_Premium_SP1', 20, 'DLC_BOX6');
    local ret = TxCommit(tx);
end

function DLC_BOX7(pc)
    local tx = TxBegin(pc);
    TxGiveItem(tx, 'steam_PremiumToken_30day', 1, 'DLC_BOX7');
    TxGiveItem(tx, 'Premium_Enchantchip_10', 4, 'DLC_BOX7');
    TxGiveItem(tx, 'Premium_indunReset', 5, 'DLC_BOX7');
    local ret = TxCommit(tx);
end

function SCR_USE_GACHA(self, argObj, rewardGroupClsName, arg1, arg2)
    GIVE_REWARD(self, rewardGroupClsName, 'SCR_USE_GACHA')

    if rewardGroupClsName == 'Event_161109_Cube' then
        local aobj = GetAccountObj(self);
        local tx = TxBegin(self);
        TxAddIESProp(tx, aobj, "KepaEventPoint", 1, "KEPA_POINT");
        local ret = TxCommit(tx);
    end
end
function SCR_USE_KEPACUBE(pc)
    local reward = {
        {'Moru_Silver', 200},
        {'misc_gemExpStone_randomQuest3', 500},
        {'misc_talt', 2000},
        {'Premium_boostToken_14d', 3000},
        {'misc_gemExpStone_randomQuest2', 4000},
        {'misc_gemExpStone_randomQuest1', 6000},
        {'GIMMICK_Drug_PMATK2', 8000},
        {'GIMMICK_Drug_PMDEF2', 10000}
    }
    local rand = IMCRandom(1, 10000);
    local result = 0;

    for i = 1, table.getn(reward) do

        if reward[i][2] >= rand then
            result = i
            break;
        end
    end

    --local aobj = GetAccountObj(pc);
    local tx = TxBegin(pc);
    --TxAddIESProp(tx, aobj, "KepaEventPoint", 1, "KEPA_POINT");
    TxGiveItem(tx, reward[result][1], 1, 'SCR_USE_KEPACUBE');
    local ret = TxCommit(tx);
end

function SCR_USE_MONCARDBOX_170404(pc)
    local r_item = {
      {'card_Mandala', 20},
      {'card_molich', 20},
      {'card_Merge', 20},
      {'card_TombLord', 20},
      {'card_salamander', 20},
      {'card_stone_whale', 20},
      {'card_Sequoia_blue', 20},
      {'card_Carapace', 20},
      {'card_werewolf', 20},
      {'card_Abomination', 20},
      {'card_Templeshooter', 20},
      {'card_archon', 20},
      {'card_Deathweaver', 20},
      {'card_poata', 20},
      {'card_ellaganos', 20},
      {'card_Glass_mole', 20},
      {'card_Canceril', 20},
      {'card_Golem_gray', 20},
      {'card_Nuaele', 20},
      {'card_Durahan', 20},
      {'card_Glackuman', 20},
      {'card_Flammidus', 20},
      {'card_Manticen', 20},
      {'card_Riteris', 20},
      {'card_Kerberos', 30},
      {'card_Fireload', 30},
      {'card_mineloader', 30},
      {'card_ShadowGaoler', 30},
      {'card_Minotaurs', 40},
      {'card_NetherBovine', 40},
      {'card_Harpeia', 40},
      {'card_Unknocker', 40},
      {'card_Throneweaver', 40},
      {'card_necrovanter', 40},
      {'card_Chapparition', 40},
      {'card_Spector_m', 40},
      {'card_Mummyghast', 40},
      {'card_Strongholder', 40}
    }
    
    local result, sum = 0, 0
    local itemratio = {}
    
    for j = 1, table.getn(r_item) do
        sum = sum + r_item[j][2]
        table.insert(itemratio, sum)
    end
    
    local rand = IMCRandom(1, sum)
    
    for i = 1, table.getn(r_item) do
        if itemratio[i] >= rand then
            result = i;
            break;
        end
    end
    
    local tx = TxBegin(pc);
    TxGiveItem(tx, r_item[result][1], 1, 'SCR_USE_MONCARDBOX_170404');
    local ret = TxCommit(tx);
end

function SCR_USE_BASEITEM_WEPBOX_315(pc)
    local r_item = {
      {'misc_ore10', 25},
      {'misc_ore11', 25},
      {'misc_ore12', 25},
      {'misc_ore16', 15},
      {'misc_0475', 42},
      {'misc_0483', 30},
      {'misc_0480', 61},
      {'misc_0504', 11},
      {'misc_0497', 53},
      {'misc_0485', 19},
      {'misc_0483', 57},
      {'misc_0505', 15},
      {'misc_0487', 44},
      {'misc_0503', 28},
      {'misc_0485', 54},
      {'misc_0506', 18},
      {'misc_0503', 54},
      {'misc_0489', 18},
      {'misc_0491', 41},
      {'misc_0475', 31},
      {'misc_0493', 60},
      {'misc_0491', 12}
    }
    
    local result, sum = 0, 0
    local itemratio = {}
    
    for j = 1, table.getn(r_item) do
        sum = sum + r_item[j][2]
        table.insert(itemratio, sum)
    end
    
    local rand = IMCRandom(1, sum)
    
    for i = 1, table.getn(r_item) do
        if itemratio[i] >= rand then
            result = i;
            break;
        end
    end
    
    local tx = TxBegin(pc);
    TxGiveItem(tx, r_item[result][1], 1, 'SCR_USE_BASEITEM_WEPBOX_315');
    local ret = TxCommit(tx);
end

function SCR_USE_LETICIA_MONSTERGEM_2RANK(pc)
    local r_gem = {
      'Gem_Highlander_WagonWheel',
      'Gem_Highlander_CartarStroke',
      'Gem_Highlander_Crown',
      'Gem_Highlander_CrossGuard',
      'Gem_Highlander_Moulinet',
      'Gem_Highlander_SkyLiner',
      'Gem_Highlander_CrossCut',
      'Gem_Highlander_ScullSwing',
      'Gem_Highlander_VerticalSlash',
      'Gem_Peltasta_UmboBlow',
      'Gem_Peltasta_RimBlow',
      'Gem_Peltasta_SwashBuckling',
      'Gem_Peltasta_Guardian',
      'Gem_Peltasta_ShieldLob',
      'Gem_Peltasta_HighGuard',
      'Gem_Peltasta_ButterFly',
      'Gem_Peltasta_UmboThrust',
      'Gem_Pyromancer_FireBall',
      'Gem_Pyromancer_FireWall',
      'Gem_Pyromancer_EnchantFire',
      'Gem_Pyromancer_Flare',
      'Gem_Pyromancer_FlameGround',
      'Gem_Pyromancer_FirePillar',
      'Gem_Pyromancer_HellBreath',
      'Gem_Cryomancer_IceBolt',
      'Gem_Cryomancer_IciclePike',
      'Gem_Cryomancer_IceWall',
      'Gem_Cryomancer_IceBlast',
      'Gem_Cryomancer_Gust',
      'Gem_Cryomancer_SnowRolling',
      'Gem_Cryomancer_FrostPillar',
      'Gem_QuarrelShooter_DeployPavise',
      'Gem_QuarrelShooter_ScatterCaltrop',
      'Gem_QuarrelShooter_StoneShot',
      'Gem_QuarrelShooter_RapidFire',
      'Gem_QuarrelShooter_Teardown',
      'Gem_QuarrelShooter_RunningShot',
      'Gem_Ranger_Barrage',
      'Gem_Ranger_HighAnchoring',
      'Gem_Ranger_CriticalShot',
      'Gem_Ranger_SteadyAim',
      'Gem_Ranger_TimeBombArrow',
      'Gem_Ranger_BounceShot',
      'Gem_Ranger_SpiralArrow',
      'Gem_Priest_Aspersion',
      'Gem_Priest_Monstrance',
      'Gem_Priest_Blessing',
      'Gem_Priest_Sacrament',
      'Gem_Priest_Revive',
      'Gem_Priest_MassHeal',
      'Gem_Priest_Exorcise',
      'Gem_Priest_StoneSkin',
      'Gem_Kriwi_Aukuras',
      'Gem_Kriwi_Zalciai',
      'Gem_Kriwi_Daino',
      'Gem_Kriwi_Zaibas',
      'Gem_Kriwi_DivineStigma',
      'Gem_Kriwi_Melstis'
    }
    
    local rand = IMCRandom(1, table.getn(r_gem))
    
    local tx = TxBegin(pc);
    TxGiveItem(tx, r_gem[rand], 1, 'LETICIA_MONSTERGEM_2RANK');
    local ret = TxCommit(tx);
end

function ACHIEVE_GIVINGSHADE(pc)
   AddAchievePoint(pc, "Event_170823_Fanart_Steam", 1); 
end


function SCR_USE_CS_IndunReset_Mission10(self)
    if IS_BASIC_FIELD_DUNGEON(self) == 'YES' or GetClassString('Map', GetZoneName(self), 'MapType') == 'City' then
        local pcetc = GetETCObject(self)
        if pcetc ~= nil then
            if pcetc.InDunCountType_500 > 0 then
                local tx = TxBegin(self);
                TxSetIESProp(tx, pcetc, 'InDunCountType_500', pcetc.InDunCountType_500 - 1)
                local ret = TxCommit(tx);
                if ret == 'SUCCESS' then
                    SendAddOnMsg(self, "NOTICE_Dm_scroll", ScpArgMsg("CS_IndunReset_Mission10_MSG1"), 10)
                end
            end
        end
    end
end

function SCR_USE_CS_IndunReset_M_Past_FantasyLibrary_1(self)
    if IS_BASIC_FIELD_DUNGEON(self) == 'YES' or GetClassString('Map', GetZoneName(self), 'MapType') == 'City' then
        local pcetc = GetETCObject(self)
        if pcetc ~= nil then
            if pcetc.InDunCountType_800 > 0 then
                local tx = TxBegin(self);
                TxSetIESProp(tx, pcetc, 'InDunCountType_800', pcetc.InDunCountType_800 - 1)
                local ret = TxCommit(tx);
                if ret == 'SUCCESS' then
                    SendAddOnMsg(self, "NOTICE_Dm_scroll", ScpArgMsg("CS_IndunReset_M_Past_FantasyLibrary_1_MSG1"), 10)
                end
            end
        end
    end
end

function SCR_USE_THI_OBT_PACK(pc)
    local tx = TxBegin(pc);
    TxGiveItem(tx, 'egg_012', 1, 'THI_OBT_PACK');
    TxGiveItem(tx, 'PremiumToken_1d', 1, 'THI_OBT_PACK');
    TxGiveItem(tx, 'Event_drug_160218', 10, 'THI_OBT_PACK');
    TxGiveItem(tx, 'Premium_boostToken', 5, 'THI_OBT_PACK');
    TxGiveItem(tx, 'RestartCristal', 10, 'THI_OBT_PACK');
    TxGiveItem(tx, 'Mic', 10, 'THI_OBT_PACK');
    TxGiveItem(tx, 'Scroll_WarpKlaipe', 10, 'THI_OBT_PACK');
    local ret = TxCommit(tx);
end

function SCR_USE_THI_CBT01_PACK(pc)
    local tx = TxBegin(pc);
    TxGiveItem(tx, 'Premium_boostToken02', 4, 'THI_CBT01_PACK');
    TxGiveItem(tx, 'Scroll_WarpKlaipe', 5, 'THI_CBT01_PACK');
    TxGiveItem(tx, 'RestartCristal', 5, 'THI_CBT01_PACK');
    TxGiveItem(tx, 'Premium_indunReset', 2, 'THI_CBT01_PACK');
    TxGiveItem(tx, 'E_HAIR_M_116', 1, 'THI_CBT01_PACK');
    TxGiveItem(tx, 'E_HAIR_F_117', 1, 'THI_CBT01_PACK');
    TxGiveItem(tx, 'E_costume_Com_4', 1, 'THI_CBT01_PACK');
    TxGiveItem(tx, 'Event_THI_OBT01', 1, 'THI_CBT01_PACK');
    local ret = TxCommit(tx);
end

function SCR_USE_THI_CBT02_PACK(pc)
    local tx = TxBegin(pc);
    TxGiveItem(tx, 'Ability_Point_Stone', 2, 'THI_CBT02_PACK');
    TxGiveItem(tx, 'NECK99_107', 1, 'THI_CBT02_PACK');
    TxGiveItem(tx, 'Scroll_WarpKlaipe', 10, 'THI_CBT02_PACK');
    TxGiveItem(tx, 'Premium_boostToken02', 4, 'THI_CBT02_PACK');
    TxGiveItem(tx, 'RestartCristal', 10, 'THI_CBT02_PACK');
    TxGiveItem(tx, 'Event_THI_OBT01', 1, 'THI_CBT01_PACK');
    TxGiveItem(tx, 'Event_THI_CBT01', 1, 'THI_CBT01_PACK');
    local ret = TxCommit(tx);
end

function ACHIEVE_FANART_JP_01(pc)
    local tx = TxBegin(pc);
    TxAddAchievePoint(tx, 'Event_Fanart_JP_01', 1)
    local ret = TxCommit(tx);
end

function SCR_USE_ITEM_AddBuff_Item(self,argObj,BuffName,arg1,arg2)
    local aObj = GetAccountObj(self);

    if IsBuffApplied(self, 'Premium_Fortunecookie_1') == 'YES' then
        BuffName = 'Premium_Fortunecookie_2'
    elseif IsBuffApplied(self, 'Premium_Fortunecookie_2') == 'YES' then
        BuffName = 'Premium_Fortunecookie_3'
    elseif IsBuffApplied(self, 'Premium_Fortunecookie_3') == 'YES' then
        BuffName = 'Premium_Fortunecookie_4'
    elseif IsBuffApplied(self, 'Premium_Fortunecookie_4') == 'YES' then
        BuffName = 'Premium_Fortunecookie_5'
    elseif IsBuffApplied(self, 'Premium_Fortunecookie_5') == 'YES' then
        BuffName = 'Premium_Fortunecookie_5'
    else
        BuffName = 'Premium_Fortunecookie_1'
    end

	AddBuff(self, self, BuffName, arg1, 0, arg2, 1);
end

function SCR_USE_Adventurebook_HighRank_Reward_1d(pc, target, string1, arg1, arg2, itemID)
    local tx = TxBegin(pc);
    TxGiveItem(tx, 'Companion_Exchange_Ticket', 12, 'Adventurebook_HighRank_Reward_1d');
    TxGiveItem(tx, 'Vis', 500000, 'Adventurebook_HighRank_Reward_1d');
    TxGiveItem(tx, 'Premium_boostToken02', 3, 'Adventurebook_HighRank_Reward_1d');
    TxGiveItem(tx, 'Adventure_Point_Stone',2, 'Adventurebook_HighRank_Reward_1d');
    TxGiveItem(tx, 'Adventure_dungeoncount_01',3, 'Adventurebook_HighRank_Reward_1d');
    local ret = TxCommit(tx);
end

function SCR_USE_Adventurebook_ThirdRank_Reward_1d(pc, target, string1, arg1, arg2, itemID)
    local tx = TxBegin(pc);
    TxGiveItem(tx, 'Companion_Exchange_Ticket', 7, 'Adventurebook_ThirdRank_Reward_1d');
    TxGiveItem(tx, 'Vis', 300000, 'Adventurebook_ThirdRank_Reward_1d');
    TxGiveItem(tx, 'Premium_boostToken02', 3, 'Adventurebook_ThirdRank_Reward_1d');
    TxGiveItem(tx, 'Adventure_Point_Stone',1, 'Adventurebook_ThirdRank_Reward_1d');
    TxGiveItem(tx, 'Adventure_dungeoncount_01',3, 'Adventurebook_ThirdRank_Reward_1d');
    local ret = TxCommit(tx);
end

function SCR_USE_Adventurebook_FourthRank_Reward_1d(pc, target, string1, arg1, arg2, itemID)
    local tx = TxBegin(pc);
    TxGiveItem(tx, 'Companion_Exchange_Ticket', 5, 'Adventurebook_FourthRank_Reward_1d');
    TxGiveItem(tx, 'Vis', 200000, 'Adventurebook_FourthRank_Reward_1d');
    TxGiveItem(tx, 'Premium_boostToken02', 2, 'Adventurebook_FourthRank_Reward_1d');
    TxGiveItem(tx, 'Adventure_Point_Stone3',1, 'Adventurebook_FourthRank_Reward_1d');
    TxGiveItem(tx, 'Adventure_dungeoncount_01',2, 'Adventurebook_FourthRank_Reward_1d');
    local ret = TxCommit(tx);
end

function SCR_USE_Adventurebook_FifthRank_Reward_1d(pc, target, string1, arg1, arg2, itemID)
    local tx = TxBegin(pc);
    TxGiveItem(tx, 'Companion_Exchange_Ticket', 4, 'Adventurebook_FifthRank_Reward_1d');
    TxGiveItem(tx, 'Vis', 100000, 'Adventurebook_FifthRank_Reward_1d');
    TxGiveItem(tx, 'Premium_boostToken02', 1, 'Adventurebook_FifthRank_Reward_1d');
    TxGiveItem(tx, 'Adventure_Point_Stone2',3, 'Adventurebook_FifthRank_Reward_1d');
    local ret = TxCommit(tx);
end

function SCR_JP_OFFLINE_EVENT_CUBE_2(pc)
    local tx = TxBegin(pc);
    TxGiveItem(tx, 'Transcendence_Stone_Box_10', 1, 'JP_OFFLINE_EVENT');
    TxGiveItem(tx, 'Drung_Box_Elixer_Premium', 1, 'JP_OFFLINE_EVENT');
    TxGiveItem(tx, 'Recycle_Box_500', 1, 'JP_OFFLINE_EVENT');
    local ret = TxCommit(tx);
end

function SCR_USE_HiddenJobUnlock(self,argObj, StringArg, Numarg1, Numarg2)
    local hiddenjob_ClassName = {
        {'Char5_6', "シノビ"},
        {'Char2_17', "ルーンキャスター"},
        {'Char3_13', "アプレイサー"},
        {'Char4_18', "巫女"},
        {'Char1_20', "ムエタイ"}
    }
    local jobNameKOR = GetClassString('Job', StringArg, 'EngName')

    for i = 1, table.getn(hiddenjob_ClassName) do
        if StringArg == hiddenjob_ClassName[i][1] then
            jobNameKOR = hiddenjob_ClassName[i][2]
            break;
        end
    end

    local select_1 = ShowSelDlg(self, 0, 'HIDDEN_JOB_UNLOCK_ITEM_DLG1\\'..ScpArgMsg('HIDDEN_JOB_UNLOCK_VIEW_MSG6','JOBNAME', jobNameKOR), ScpArgMsg('Yes'), ScpArgMsg('No'))
    if select_1 == 1 then
        local result = SCR_HIDDEN_JOB_UNLOCK(self, StringArg)
        if result == 'SUCCESS' then
            if StringArg == 'Char4_18' then
                if isHideNPC(self, 'MIKO_MASTER') == 'YES' then
                    SCR_NPC_HIDE_UNHIDE_NPC_HANDLER(self, nil, nil, 'MIKO_MASTER/MIKO_SOUL_SPIRIT')
                end
            elseif StringArg == 'Char3_13' then
                SCR_NPC_HIDE_UNHIDE_NPC_HANDLER(self, nil, 'FEDIMIAN_APPRAISER', 'FEDIMIAN_APPRAISER_NPC')
            elseif StringArg == 'Char2_17' then
                if isHideNPC(self, 'RUNECASTER_MASTER') == 'YES' then
                    SCR_NPC_HIDE_UNHIDE_NPC_HANDLER(self, nil, nil, 'RUNECASTER_MASTER')
                end
            elseif StringArg == 'Char5_6' then
                if isHideNPC(self, 'SHINOBI_MASTER') == 'YES' then
                    SCR_NPC_HIDE_UNHIDE_NPC_HANDLER(self, nil, nil, 'SHINOBI_MASTER')
                end
            end
            SCR_SEND_NOTIFY_REWARD(self, ScpArgMsg('HIDDEN_JOB_UNLOCK_VIEW_MSG4','JOBNAME', jobNameKOR), ScpArgMsg('HIDDEN_JOB_UNLOCK_VIEW_MSG5','RANK', Numarg1,'JOBNAME', jobNameKOR))
        end
    end
end

function SCR_USE_LEVELUP_REWARD_EV(pc)
	local nextLv = 0
	local nextlv_group = {280, 235, 185, 135, 85, 45, 1}
	local sObj = GetSessionObject(pc, 'ssn_klapeda')

	if sObj.EVENT_VALUE_SOBJ01 >= 330 then
	    SendAddOnMsg(pc, 'NOTICE_Dm_!', ScpArgMsg("BLACK_HOLE_CLEAR_BOX_MSG2"), 5)
	    return;
	end
	
	if sObj.EVENT_VALUE_SOBJ01 <= pc.Lv then -- succ
	    local reward = {
	        {'Event_drug_steam_1h', 10, 'NECK99_102', 1},
	        {'Drug_Fortunecookie', 2, 'Premium_indunReset_1add_14d', 2},
	        {'Drug_Fortunecookie', 3, 'Premium_indunReset_1add_14d', 2},
	        {'Drug_Fortunecookie', 4, 'Premium_indunReset_1add_14d', 2},
	        {'Drug_Fortunecookie', 5, 'Event_Goddess_Statue', 1}, -- 5
	        {'Premium_dungeoncount_Event', 3, 'Event_Goddess_Statue', 1},
	        {'Drug_Fortunecookie', 3, 'Premium_indunReset_14d', 2},
	        {'Drug_Fortunecookie', 5, 'Premium_indunReset_14d', 2},
	        {'Premium_SkillReset_14d', 1, 'misc_gemExpStone_randomQuest4_14d', 5},
	        {'Premium_StatReset14', 1, 'Moru_Silver', 1}
	    }
	    
	    for i = 1, table.getn(nextlv_group) do
    	    if pc.Lv >= nextlv_group[i] then
    	        nextLv = i + pc.Lv
    	        break
    	    end
    	end

    	local tx = TxBegin(pc)
    	for j = 1,4, 2 do
            TxGiveItem(tx, reward[sObj.EVENT_VALUE_SOBJ02 + 1][j], reward[sObj.EVENT_VALUE_SOBJ02 + 1][j + 1], 'LEVELUP_REWARD_EV')
        end
        TxSetIESProp(tx, sObj, 'EVENT_VALUE_SOBJ01', nextLv)
        TxSetIESProp(tx, sObj, 'EVENT_VALUE_SOBJ02', sObj.EVENT_VALUE_SOBJ02 + 1)
        local ret = TxCommit(tx)
        if ret == 'SUCCESS' then
            SendAddOnMsg(pc, 'NOTICE_Dm_Clear', ScpArgMsg("LevelUp_Event_Desc01", "REWARD", sObj.EVENT_VALUE_SOBJ02), 5)
        end
	else -- fail
	    SendAddOnMsg(pc, 'NOTICE_Dm_!', ScpArgMsg("LevelUp_Event_Desc02", "NEXTLV", sObj.EVENT_VALUE_SOBJ01), 5)
	end
end

function SCR_USE_DAYQUEST_RAND(pc)
  local sObj = GetSessionObject(pc, 'ssn_klapeda')
  local attribute = {'Dark', 'Poison', 'Fire', 'Lightning', 'Ice', 'Earth'} -- EVENT_VALUE_SOBJ07
  local RaceType = {'Forester', 'Klaida', 'Widling', 'Paramune', 'Velnias'} -- EVENT_VALUE_SOBJ08
  
  ShowOkDlg(pc, ScpArgMsg('DayQuest_Rand_Desc01', 'RACE', ScpArgMsg(sObj.EVENT_STRING_SOBJ02), 'LV', sObj.EVENT_VALUE_SOBJ09), 1)
end

function SCR_USE_VALENTINE_CHOCO_2018(pc)
    local aObj = GetAccountObj(pc);
    local mapclass = GetClass('Map', aObj.EV180206_VALENTINE_MAP)

    local choco_sel = ShowSelDlg(pc, 0, ScpArgMsg('EVENT_2018VALEN_SEL3', 'MAP', mapclass.Name), ScpArgMsg("No"), ScpArgMsg("Yes"))

    if choco_sel == 1 then
        return;
    elseif choco_sel == 2 then
        local tx = TxBegin(pc);
        TxSetIESProp(tx, aObj, 'EV180206_VALENTINE_MAP', 'None')
        local ret = TxCommit(tx);

        if ret == 'SUCCESS' then
            AddBuff(pc, pc, 'EVENT_1708_JURATE_1', arg1, 0, '3600000', 1);
            local teamlv = GetTeamLevel(pc)
            local teamName = GetTeamName(pc);
            IMCLOG_CONTENT("180206_VALENTINE_EVENT", "PClv:  ", pc.Lv, "TeamLv:  ", teamlv, "TeamName:   ", teamName)
        end
    end
end

function SCR_USE_ITEM_AddBuff(self,argObj,BuffName,arg1,arg2)
    if BuffName == 'EVENT_1708_JURATE_1' then
        local teamlv = GetTeamLevel(self)
        local teamName = GetTeamName(self);
        IMCLOG_CONTENT("180206_VALENTINE_EVENT", "PClv:  ", self.Lv, "TeamLv:  ", teamlv, "TeamName:   ", teamName)
    end
	AddBuff(self, self, BuffName, arg1, 0, arg2, 1);
	AddAchievePoint(self, "Potion", 1);

end

function SCR_USE_SPECIAL_TOKENBOX_JP(pc)
    local tx = TxBegin(pc);
    TxGiveItem(tx, 'PremiumToken', 1, 'SPECIAL_TOKENBOX_JP');
    TxGiveItem(tx, 'Magic_Scroll_Box4', 1, 'SPECIAL_TOKENBOX_JP');
    local ret = TxCommit(tx);
end

function SCR_USE_ITEM_Event_Steam_Night_Market_RedOxBuff(self,argObj,BuffName,arg1,arg2)
    AddBuff(self, self, 'Event_Steam_Drug_RedOx');
end

function SCR_USE_Adventurebook_HighRank_Reward2_1d(pc, target, string1, arg1, arg2, itemID)
    local tx = TxBegin(pc);
    TxGiveItem(tx, 'Companion_Exchange_Ticket2', 12, 'Adventurebook_HighRank_Reward_1d');
    TxGiveItem(tx, 'Vis', 500000, 'Adventurebook_HighRank_Reward_1d');
    TxGiveItem(tx, 'Premium_boostToken02', 3, 'Adventurebook_HighRank_Reward_1d');
    TxGiveItem(tx, 'Adventure_Point_Stone',2, 'Adventurebook_HighRank_Reward_1d');
    TxGiveItem(tx, 'Adventure_dungeoncount_01',3, 'Adventurebook_HighRank_Reward_1d');
    local ret = TxCommit(tx);
end

function SCR_USE_Adventurebook_ThirdRank_Reward2_1d(pc, target, string1, arg1, arg2, itemID)
    local tx = TxBegin(pc);
    TxGiveItem(tx, 'Companion_Exchange_Ticket2', 7, 'Adventurebook_ThirdRank_Reward_1d');
    TxGiveItem(tx, 'Vis', 300000, 'Adventurebook_ThirdRank_Reward_1d');
    TxGiveItem(tx, 'Premium_boostToken02', 3, 'Adventurebook_ThirdRank_Reward_1d');
    TxGiveItem(tx, 'Adventure_Point_Stone',1, 'Adventurebook_ThirdRank_Reward_1d');
    TxGiveItem(tx, 'Adventure_dungeoncount_01',3, 'Adventurebook_ThirdRank_Reward_1d');
    local ret = TxCommit(tx);
end

function SCR_USE_Adventurebook_FourthRank_Reward2_1d(pc, target, string1, arg1, arg2, itemID)
    local tx = TxBegin(pc);
    TxGiveItem(tx, 'Companion_Exchange_Ticket2', 5, 'Adventurebook_FourthRank_Reward_1d');
    TxGiveItem(tx, 'Vis', 200000, 'Adventurebook_FourthRank_Reward_1d');
    TxGiveItem(tx, 'Premium_boostToken02', 2, 'Adventurebook_FourthRank_Reward_1d');
    TxGiveItem(tx, 'Adventure_Point_Stone3',1, 'Adventurebook_FourthRank_Reward_1d');
    TxGiveItem(tx, 'Adventure_dungeoncount_01',2, 'Adventurebook_FourthRank_Reward_1d');
    local ret = TxCommit(tx);
end

function SCR_USE_Adventurebook_FifthRank_Reward2_1d(pc, target, string1, arg1, arg2, itemID)
    local tx = TxBegin(pc);
    TxGiveItem(tx, 'Companion_Exchange_Ticket2', 4, 'Adventurebook_FifthRank_Reward_1d');
    TxGiveItem(tx, 'Vis', 100000, 'Adventurebook_FifthRank_Reward_1d');
    TxGiveItem(tx, 'Premium_boostToken02', 1, 'Adventurebook_FifthRank_Reward_1d');
    TxGiveItem(tx, 'Adventure_Point_Stone2',3, 'Adventurebook_FifthRank_Reward_1d');
    local ret = TxCommit(tx);
end

function SCR_USE_ROCKSODON_PACK(pc)
    local tx = TxBegin(pc) 
    TxGiveItem(tx, 'egg_010', 1, "ROCKSODON_PACK")
    TxGiveItem(tx, 'Premium_Enchantchip', 10, "ROCKSODON_PACK")
    TxGiveItem(tx, 'misc_gemExpStone_randomQuest4', 1, "ROCKSODON_PACK")
    TxGiveItem(tx, 'Ability_Point_Stone', 1, "ROCKSODON_PACK")
    TxGiveItem(tx, 'Moru_Silver_TA', 1, "ROCKSODON_PACK")
    TxGiveItem(tx, 'Premium_indunReset', 1, "ROCKSODON_PACK")
    local ret = TxCommit(tx)
end

function ACHIEVE_FANART_JP_02(pc)
    local tx = TxBegin(pc);
    TxAddAchievePoint(tx, 'Event_Fanart_JP_02', 1)
    local ret = TxCommit(tx);
end

function SCR_USE_2YEARS_BOX(pc)
    local tx = TxBegin(pc);
    TxGiveItem(tx, 'Hat_628313', 1, '2YEARS_PACKAGE');
    TxGiveItem(tx, 'Hat_628314', 1, '2YEARS_PACKAGE');
    TxGiveItem(tx, 'Hat_628315', 1, '2YEARS_PACKAGE');
    local ret = TxCommit(tx);
end

function Achieve_Event_Happy_Ever_After(pc)
    local tx = TxBegin(pc);
    TxAddAchievePoint(tx, 'Achieve_Event_Happy_Ever_After', 1)
    local ret = TxCommit(tx);
end

function Achieve_Event_Wonderful_ToS_life(pc)
    local tx = TxBegin(pc);
    TxAddAchievePoint(tx, 'Achieve_Event_Wonderful_ToS_life', 1)
    local ret = TxCommit(tx);
end

function Achieve_Event_Gold_Pig_JP(pc)
    local tx = TxBegin(pc);
    TxAddAchievePoint(tx, 'Achieve_Event_Gold_Pig_JP', 1)
    local ret = TxCommit(tx);
end

function Achieve_Event_KePa_JP(pc)
    local tx = TxBegin(pc);
    TxAddAchievePoint(tx, 'Achieve_Event_KePa_JP', 1)
    local ret = TxCommit(tx);
end

function Achieve_Event_JP_GILTINE(pc)
    local tx = TxBegin(pc);
    TxAddAchievePoint(tx, 'Achieve_Event_JP_GILTINE', 1)
    local ret = TxCommit(tx);
end

function SCR_USE_EVENT_KOR_Fortunecookie(self,argObj,argstr,arg1,arg2)
    -- local list = {
    --     {10, 'PremiumToken_1d', 1},
    --     {20, 'Event_drug_steam', 10},
    --     {30, 'card_Xpupkit01_event', 1},
    --     {40, 'misc_gemExpStone_randomQuest4_14d', 1},
    --     {50, 'Moru_Silver', 1},
    --     {60, 'Hat_628290', 1}
    -- }
    
    local aObj = GetAccountObj(self);
    local result = 0;
    local BuffName

    if IsBuffApplied(self, 'Premium_Fortunecookie_1') == 'YES' then
        BuffName = 'Premium_Fortunecookie_2'
    elseif IsBuffApplied(self, 'Premium_Fortunecookie_2') == 'YES' then
        BuffName = 'Premium_Fortunecookie_3'
    elseif IsBuffApplied(self, 'Premium_Fortunecookie_3') == 'YES' then
        BuffName = 'Premium_Fortunecookie_4'
    elseif IsBuffApplied(self, 'Premium_Fortunecookie_4') == 'YES' then
        BuffName = 'Premium_Fortunecookie_5'
    elseif IsBuffApplied(self, 'Premium_Fortunecookie_5') == 'YES' then
        BuffName = 'Premium_Fortunecookie_5'
    else
        BuffName = 'Premium_Fortunecookie_1'
    end

	--EVENT_PROPERTY_RESET(self, aObj, sObj)

	-- for i = 1, table.getn(list) do
    --     if aObj.EVENT_KOR_Fortunecookie_COUNT + 1 == list[i][1] then
    --         result = i
    --         break;
    --     end
    -- end

	local tx = TxBegin(self);
    TxAddIESProp(tx, aObj, 'EVENT_KOR_Fortunecookie_COUNT', 1);
    -- if result ~= 0 then
    --     TxGiveItem(tx, list[result][2], list[result][3], 'EVENT_KOR_Fortunecookie');
    -- end
    local ret = TxCommit(tx);
    if ret == 'SUCCESS' then
        AddBuff(self, self, BuffName, 0, 0, 1800000, 1);
        -- local msg = ScpArgMsg("Fortunecookie_Count","COUNT", aObj.EVENT_KOR_Fortunecookie_COUNT)
        -- SendAddOnMsg(self, "NOTICE_Dm_scroll",msg, 10)
    end
end

--NEW YEAR PACKAGE 2019

function SCR_USE_ITEM_1902_NEWYEAR_PACKAGE_01(pc, target, string1, arg1, arg2, itemID)
    local tx = TxBegin(pc);
    TxGiveItem(tx, "Select_Weapon_NewYear_Box", 1, '1902_NEW_YEAR_PACKAGE_01')
    TxGiveItem(tx, "NewYear_Weapon_Reinforce_11", 1, '1902_NEW_YEAR_PACKAGE_01')
    TxGiveItem(tx, "NewYear_Weapon_Transcend_5", 1, '1902_NEW_YEAR_PACKAGE_01')
    TxGiveItem(tx, "Event_drug_steam_1h_Premium", 30, '1902_NEW_YEAR_PACKAGE_01')
    TxGiveItem(tx, "Event_Drug_Alche_HP15_Premium", 200, '1902_NEW_YEAR_PACKAGE_01')
    TxGiveItem(tx, "Event_Drug_Alche_SP15_Premium", 200, '1902_NEW_YEAR_PACKAGE_01')
    TxGiveItem(tx, "Ability_Point_Stone_10000", 5, '1902_NEW_YEAR_PACKAGE_01')
    TxGiveItem(tx, "PremiumToken_New_Return", 1, '1902_NEW_YEAR_PACKAGE_01')
    -- TxGiveItem(tx, "R_Steam_HP_Potion_1Day", 3, '1902_NEW_YEAR_PACKAGE_01') -- steam add -- 
    -- TxGiveItem(tx, "R_Steam_SP_Potion_1Day", 3, '1902_NEW_YEAR_PACKAGE_01') -- steam add -- 
    local ret = TxCommit(tx);
end

function SCR_USE_ITEM_1902_NEWYEAR_PACKAGE_03(pc, target, string1, arg1, arg2, itemID)
    local tx = TxBegin(pc);
        TxGiveItem(tx, "Moru_Silver_Team_Trade", 10, '1902_NEW_YEAR_PACKAGE_03') -- steam count change -- 
        TxGiveItem(tx, "Moru_Gold_Team_Trade", 5, '1902_NEW_YEAR_PACKAGE_03') -- steam count change -- 
        TxGiveItem(tx, "Transcend_Scroll_8", 1, '1902_NEW_YEAR_PACKAGE_03')
        -- TxGiveItem(tx, "R_Steam_HP_Potion_1Day", 3, '1902_NEW_YEAR_PACKAGE_03') -- steam add -- 
        -- TxGiveItem(tx, "R_Steam_SP_Potion_1Day", 3, '1902_NEW_YEAR_PACKAGE_03') -- steam add -- 
        for i = 1, 2 do
            local cmdidx = TxGiveItem(tx, 'Unique_Enchant_Jewel_Team', 1, "1902_NEW_YEAR_PACKAGE_03");
            TxAppendProperty(tx, cmdidx, 'Level', 390);
        end
    local ret = TxCommit(tx);
end


function SCR_USE_ITEM_1902_NEWYEAR_PACKAGE_ALL(pc, target, string1, arg1, arg2, itemID)
    local tx = TxBegin(pc);
    TxGiveItem(tx, "1902_NewYear_Package_01", 1, '1902_NEW_YEAR_PACKAGE_ALL')
    TxGiveItem(tx, "1902_NewYear_Package_03", 1, '1902_NEW_YEAR_PACKAGE_ALL')
    TxGiveItem(tx, "Legend_Card_Box", 1, '1902_NEW_YEAR_PACKAGE_ALL')
    -- TxGiveItem(tx, "R_Steam_HP_Potion_7Day", 1, '1902_NEW_YEAR_PACKAGE_ALL') -- steam add -- 
    -- TxGiveItem(tx, "R_Steam_SP_Potion_7Day", 1, '1902_NEW_YEAR_PACKAGE_ALL') -- steam add -- 
    local ret = TxCommit(tx);
end

function SCR_USE_LEGEND_CARD_BOX_GIVE_ITEM(pc, target, string1, arg1, arg2, itemID)
    local tx = TxBegin(pc);
        TxGiveItem(tx, 'Legend_SlotOpen_Card_JP', 1, 'USE_LEGEND_CARD_BOX');
        TxGiveItem(tx, 'Legend_Card_Envelope_JP', 1, 'USE_LEGEND_CARD_BOX');
    local ret = TxCommit(tx);
end

function SCR_USE_Steam_Darkness_Package_all(pc, target, string1, arg1, arg2, itemID)
    local tx = TxBegin(pc);
    TxGiveItem(tx, "Steam_Darkness_Package", 1, 'SCR_USE_Steam_Darkness_Package_all')
    TxGiveItem(tx, "Steam_Darkness_Package_Card_Gem", 1, 'SCR_USE_Steam_Darkness_Package_all')
    TxGiveItem(tx, "Legend_Card_Box", 1, 'SCR_USE_Steam_Darkness_Package_all')
    local ret = TxCommit(tx);
end