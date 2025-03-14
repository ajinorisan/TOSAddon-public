local s_skillTreeCache = {};

function is_spearmaster_atk_skill(skill_name)
    local list = {
        'SpearMaster_StanceChange',
        'SpearMaster_WildTigerSpear',
        'SpearMaster_RushSpear',
        'SpearMaster_FlyingSerpentFall',
        'SpearMaster_UniqueSpearDance',
	};
	for i = 1, #list do
		local name = list[i];
		if string.find(skill_name, name) ~= nil then
			return true;
		end
	end
	return false;
end

function GET_SKILLTREE_CLS(skillClsName)
	if #s_skillTreeCache < 1 then
		local clslist, cnt = GetClassList('SkillTree');
		for i = 0, cnt - 1 do
			local cls = GetClassByIndexFromList(clslist, i);
			s_skillTreeCache[cls.SkillName] = cls;
		end
	end
	return s_skillTreeCache[skillClsName];
end

local function GET_JOB_NAME_BY_SKILLTREE_CLS(skillTreeCls)
	local tokList = StringSplit(skillTreeCls.ClassName, '_');
	return tokList[1]..'_'..tokList[2];
end

local function GET_LIMIT_SKILL_LEVEL(pc, targetSkillTreeCls, targetSkillJobName, pcJobLv, pcCurJobName)
	local defMaxLevel = targetSkillTreeCls.MaxLevel;
	if targetSkillJobName ~= pcCurJobName then
		local targetSkillJobCls = GetClass('Job', targetSkillJobName);
		if targetSkillJobCls == nil then
			return 0;			
		end
		
		local jobSeq = 0;
		if IsServerObj(pc) == 1 then
			jobSeq = GetJobSequence(pc, targetSkillJobCls.ClassID);
		else
			local mainSession = session.GetMainSession();			
			local jobHistoryVec = mainSession:GetPCJobInfo();
			local jobInfo = jobHistoryVec:GetJobInfo(targetSkillJobCls.ClassID);
			if jobInfo ~= nil then
				jobSeq = jobInfo.index;
			end
		end
		if jobSeq == 0 then
			return 0;
		end		
		pcJobLv = GetJobMaxLevel(pc, jobSeq);
	end
	local pcCircle = math.floor((pcJobLv - 1) / 15) + 1;
	local sklCircle = math.floor((targetSkillTreeCls.UnlockClassLevel - 1) / 15) + 1;
	local applyCircle = pcCircle - sklCircle + 1;
	return math.min(applyCircle * 5, defMaxLevel);
end

function SCR_ENABLE_GET_SKILL_COMMON(pc, skillClsName, targetLv)
	local skillCls = GetClass('Skill', skillClsName);
	if skillCls == nil then
		return false, 'SkillTreeError';
	end

	if TryGetProp(skillCls, 'CommonType', 'None') ~= 'None' then
		return false, ScpArgMsg('MaxSkillLevel');
	end

	local skillTreeCls = GET_SKILLTREE_CLS(skillClsName);
	if skillTreeCls == nil then
		IMC_LOG('ERROR_LOGIC', 'Skill info not exist in skilltree.xml: skillName['..skillClsName..']');
		return false, 'SkillTreeError';
	end
	
	-- check char job level
	local unlockClassLv = TryGetProp(skillTreeCls, 'UnlockClassLevel', 0);
	local jobClsName = GET_JOB_NAME_BY_SKILLTREE_CLS(skillTreeCls);
	local curJobClsName = pc.JobName;
	local curJobLv = GetJobLevelByName(pc, curJobClsName);
	
	if unlockClassLv > 0 then
		if jobClsName == curJobClsName then -- check only current job. previous job maybe satisfied max level
			if curJobLv < unlockClassLv then
				return false, ScpArgMsg('TooLowClassLevelForGetSkill{Level}', 'Level', unlockClassLv);
			end
		end	
	end	
	
	-- check each skill check
	local EnableGetSkillFunc = _G['SCR_ENABLE_GET_SKILL_'..skillClsName];
	if EnableGetSkillFunc ~= nil then		
		if EnableGetSkillFunc(pc, skillClsName) == false then
			if IsServerSection(pc) == 0 then
				local canNotGetSkillMessage = "CannotGetSkillMessage_" .. skillClsName;
				if GetClass("ClientMessage", canNotGetSkillMessage) ~= nil then
					return false, ScpArgMsg(canNotGetSkillMessage);
				end
			else
				return false, ScpArgMsg('CannotGetSkill{Reason}', 'Reason', ClMsg('PreTraining'));
			end
		end
	end

	-- check max level
	if targetLv > GET_LIMIT_SKILL_LEVEL(pc, skillTreeCls, jobClsName, curJobLv, curJobClsName) then
		return false, ScpArgMsg('MaxSkillLevel');
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Doppelsoeldner_Zucken(pc, skillClsName)
	local ZornhauSkl = nil;
	if IsServerObj(pc) == 1 then
		ZornhauSkl = GetSkill(pc, 'Doppelsoeldner_Zornhau');
	else
		ZornhauSkl = session.GetSkillByName('Doppelsoeldner_Zornhau');
	end

	if ZornhauSkl == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Doppelsoeldner_Redel(pc, skillClsName)
	local ZuckenSkl = nil;
	if IsServerObj(pc) == 1 then
		ZuckenSkl = GetSkill(pc, 'Doppelsoeldner_Zucken');
	else
		ZuckenSkl = session.GetSkillByName('Doppelsoeldner_Zucken');
	end

	if ZuckenSkl == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Monk_HandKnife(pc, skillClsName)
	local palmstrikeSkl = nil;
	if IsServerObj(pc) == 1 then
		palmstrikeSkl = GetSkill(pc, 'Monk_PalmStrike');
	else
		palmstrikeSkl = session.GetSkillByName('Monk_PalmStrike');
	end

	if palmstrikeSkl == nil then
		return false;
	end
	return true;
end


function SCR_ENABLE_GET_SKILL_Crusader_HolySmash(pc, skillClsName)
	local palmstrikeSkl = nil;
	if IsServerObj(pc) == 1 then
		palmstrikeSkl = GetSkill(pc, 'Crusader_Chants');
	else
		palmstrikeSkl = session.GetSkillByName('Crusader_Chants');
	end

	if palmstrikeSkl == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Crusader_ProtectionOfGoddess(pc, skillClsName)
	local palmstrikeSkl = nil;
	if IsServerObj(pc) == 1 then
		palmstrikeSkl = GetSkill(pc, 'Crusader_Chants');
	else
		palmstrikeSkl = session.GetSkillByName('Crusader_Chants');
	end

	if palmstrikeSkl == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Crusader_Sacred(pc, skillClsName)
	local palmstrikeSkl = nil;
	if IsServerObj(pc) == 1 then
		palmstrikeSkl = GetSkill(pc, 'Crusader_Chants');
	else
		palmstrikeSkl = session.GetSkillByName('Crusader_Chants');
	end

	if palmstrikeSkl == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Crusader_Retaliation(pc, skillClsName)
	local palmstrikeSkl = nil;
	if IsServerObj(pc) == 1 then
		palmstrikeSkl = GetSkill(pc, 'Crusader_Chants');
	else
		palmstrikeSkl = session.GetSkillByName('Crusader_Chants');
	end

	if palmstrikeSkl == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Crusader_Condemn(pc, skillClsName)
	local palmstrikeSkl = nil;
	if IsServerObj(pc) == 1 then
		palmstrikeSkl = GetSkill(pc, 'Crusader_Chants');
	else
		palmstrikeSkl = session.GetSkillByName('Crusader_Chants');
	end

	if palmstrikeSkl == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Crusader_RingOfLight(pc, skillClsName)
	local palmstrikeSkl = nil;
	if IsServerObj(pc) == 1 then
		palmstrikeSkl = GetSkill(pc, 'Crusader_Chants');
	else
		palmstrikeSkl = session.GetSkillByName('Crusader_Chants');
	end

	if palmstrikeSkl == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Bulletmarker_RestInPeace(pc, skillClsName)
	local palmstrikeSkl = nil;
	if IsServerObj(pc) == 1 then
		palmstrikeSkl = GetSkill(pc, 'Bulletmarker_DoubleGunStance');
	else
		palmstrikeSkl = session.GetSkillByName('Bulletmarker_DoubleGunStance');
	end

	if palmstrikeSkl == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Bulletmarker_BloodyOverdrive(pc, skillClsName)
	local palmstrikeSkl = nil;
	if IsServerObj(pc) == 1 then
		palmstrikeSkl = GetSkill(pc, 'Bulletmarker_DoubleGunStance');
	else
		palmstrikeSkl = session.GetSkillByName('Bulletmarker_DoubleGunStance');
	end

	if palmstrikeSkl == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Bulletmarker_TracerBullet(pc, skillClsName)
	local palmstrikeSkl = nil;
	if IsServerObj(pc) == 1 then
		palmstrikeSkl = GetSkill(pc, 'Bulletmarker_DoubleGunStance');
	else
		palmstrikeSkl = session.GetSkillByName('Bulletmarker_DoubleGunStance');
	end

	if palmstrikeSkl == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Bulletmarker_MozambiqueDrill(pc, skillClsName)
	local palmstrikeSkl = nil;
	if IsServerObj(pc) == 1 then
		palmstrikeSkl = GetSkill(pc, 'Bulletmarker_DoubleGunStance');
	else
		palmstrikeSkl = session.GetSkillByName('Bulletmarker_DoubleGunStance');
	end

	if palmstrikeSkl == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Bulletmarker_FreezeBullet(pc, skillClsName)
	local palmstrikeSkl = nil;
	if IsServerObj(pc) == 1 then
		palmstrikeSkl = GetSkill(pc, 'Bulletmarker_DoubleGunStance');
	else
		palmstrikeSkl = session.GetSkillByName('Bulletmarker_DoubleGunStance');
	end

	if palmstrikeSkl == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Bulletmarker_Outrage(pc, skillClsName)
	local palmstrikeSkl = nil;
	if IsServerObj(pc) == 1 then
		palmstrikeSkl = GetSkill(pc, 'Bulletmarker_DoubleGunStance');
	else
		palmstrikeSkl = session.GetSkillByName('Bulletmarker_DoubleGunStance');
	end

	if palmstrikeSkl == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Bulletmarker_NapalmBullet(pc, skillClsName)
	local palmstrikeSkl = nil;
	if IsServerObj(pc) == 1 then
		palmstrikeSkl = GetSkill(pc, 'Bulletmarker_DoubleGunStance');
	else
		palmstrikeSkl = session.GetSkillByName('Bulletmarker_DoubleGunStance');
	end

	if palmstrikeSkl == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Sadhu_Possession(pc, skillClsName)
	local palmstrikeSkl = nil;
	if IsServerObj(pc) == 1 then
		palmstrikeSkl = GetSkill(pc, 'Sadhu_Soulmaster');
	else
		palmstrikeSkl = session.GetSkillByName('Sadhu_Soulmaster');
	end

	if palmstrikeSkl == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Sadhu_Prakriti(pc, skillClsName)
	local palmstrikeSkl = nil;
	if IsServerObj(pc) == 1 then
		palmstrikeSkl = GetSkill(pc, 'Sadhu_Soulmaster');
	else
		palmstrikeSkl = session.GetSkillByName('Sadhu_Soulmaster');
	end

	if palmstrikeSkl == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Sadhu_Anila(pc, skillClsName)
	local palmstrikeSkl = nil;
	if IsServerObj(pc) == 1 then
		palmstrikeSkl = GetSkill(pc, 'Sadhu_Soulmaster');
	else
		palmstrikeSkl = session.GetSkillByName('Sadhu_Soulmaster');
	end

	if palmstrikeSkl == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Sadhu_Tanoti(pc, skillClsName)
	local palmstrikeSkl = nil;
	if IsServerObj(pc) == 1 then
		palmstrikeSkl = GetSkill(pc, 'Sadhu_Soulmaster');
	else
		palmstrikeSkl = session.GetSkillByName('Sadhu_Soulmaster');
	end

	if palmstrikeSkl == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Sadhu_Patati(pc, skillClsName)
	local palmstrikeSkl = nil;
	if IsServerObj(pc) == 1 then
		palmstrikeSkl = GetSkill(pc, 'Sadhu_Soulmaster');
	else
		palmstrikeSkl = session.GetSkillByName('Sadhu_Soulmaster');
	end

	if palmstrikeSkl == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Sadhu_Moksha(pc, skillClsName)
	local palmstrikeSkl = nil;
	if IsServerObj(pc) == 1 then
		palmstrikeSkl = GetSkill(pc, 'Sadhu_Soulmaster');
	else
		palmstrikeSkl = session.GetSkillByName('Sadhu_Soulmaster');
	end

	if palmstrikeSkl == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Fletcher_BodkinPoint(pc, skillClsName)
	local FletcherArrowShot = nil;
	if IsServerObj(pc) == 1 then
		FletcherArrowShot = GetSkill(pc, 'Fletcher_FletcherArrowShot');
	else
		FletcherArrowShot = session.GetSkillByName('Fletcher_FletcherArrowShot');
	end

	if FletcherArrowShot == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Fletcher_BarbedArrow(pc, skillClsName)
	local FletcherArrowShot = nil;
	if IsServerObj(pc) == 1 then
		FletcherArrowShot = GetSkill(pc, 'Fletcher_FletcherArrowShot');
	else
		FletcherArrowShot = session.GetSkillByName('Fletcher_FletcherArrowShot');
	end

	if FletcherArrowShot == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Fletcher_CrossFire(pc, skillClsName)
	local FletcherArrowShot = nil;
	if IsServerObj(pc) == 1 then
		FletcherArrowShot = GetSkill(pc, 'Fletcher_FletcherArrowShot');
	else
		FletcherArrowShot = session.GetSkillByName('Fletcher_FletcherArrowShot');
	end

	if FletcherArrowShot == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Fletcher_Singijeon(pc, skillClsName)
	local FletcherArrowShot = nil;
	if IsServerObj(pc) == 1 then
		FletcherArrowShot = GetSkill(pc, 'Fletcher_FletcherArrowShot');
	else
		FletcherArrowShot = session.GetSkillByName('Fletcher_FletcherArrowShot');
	end

	if FletcherArrowShot == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Fletcher_CatenaChainArrow(pc, skillClsName)
	local FletcherArrowShot = nil;
	if IsServerObj(pc) == 1 then
		FletcherArrowShot = GetSkill(pc, 'Fletcher_FletcherArrowShot');
	else
		FletcherArrowShot = session.GetSkillByName('Fletcher_FletcherArrowShot');
	end

	if FletcherArrowShot == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_TigerHunter_EyeofBeast(pc, skillClsName)
	local Tracking = nil;
	if IsServerObj(pc) == 1 then
		Tracking = GetSkill(pc, 'TigerHunter_Tracking');
	else
		Tracking = session.GetSkillByName('TigerHunter_Tracking');
	end

	if Tracking == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Lama_StrongfistHanginglegs(pc, skillClsName)
	local Lamapose = nil;
	if IsServerObj(pc) == 1 then
		Lamapose = GetSkill(pc, 'Lama_Lamapose');
	else
		Lamapose = session.GetSkillByName('Lama_Lamapose');
	end

	if Lamapose == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Lama_PointkickEarthshock(pc, skillClsName)
	local Lamapose = nil;
	if IsServerObj(pc) == 1 then
		Lamapose = GetSkill(pc, 'Lama_Lamapose');
	else
		Lamapose = session.GetSkillByName('Lama_Lamapose');
	end

	if Lamapose == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Lama_FlyingkickSuddenkick(pc, skillClsName)
	local Lamapose = nil;
	if IsServerObj(pc) == 1 then
		Lamapose = GetSkill(pc, 'Lama_Lamapose');
	else
		Lamapose = session.GetSkillByName('Lama_Lamapose');
	end

	if Lamapose == nil then
		return false;
	end
	return true;
end

function SCR_ENABLE_GET_SKILL_Lama_Endlessattacks(pc, skillClsName)
	local Lamapose = nil;
	if IsServerObj(pc) == 1 then
		Lamapose = GetSkill(pc, 'Lama_Lamapose');
	else
		Lamapose = session.GetSkillByName('Lama_Lamapose');
	end

	if Lamapose == nil then
		return false;
	end
	return true;
end