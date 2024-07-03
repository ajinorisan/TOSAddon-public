-- buffscp.lua
function ShadowUmbrella_ENTER(actor, obj, buff)
    actor:GetAnimation():PlayEquipAni(1, "b-master_umbrella_ani.xsm");
end

function ShadowUmbrella_LEAVE(actor, obj, buff)
    actor:StopEquipAni(1);
end

function Burrow_ENTER(actor, obj, buff)
end

function Burrow_LEAVE(actor, obj, buff)
    actor:GetAnimation():PlayFixAnim("BORN", 1.0, 0);
end

function StopAni_ENTER(actor, obj, buff)
    actor:GetEffect():EnableVibrate(1, 0.5, 0.5, 50.0);
end

function StopAni_LEAVE(actor, obj, buff)
end

function Petrification_ENTER(actor, obj, buff)
    -- actor:GetEffect():EnableVibrate(1, 0.5, 0.5, 50.0); -- 얼굴 깨지는 것 때문에 임시로 주석.
    -- imcSound.PlaySoundItem(cls.Sound);
    -- actor:PlaySound("SOUNDNAME");
end

function Petrification_LEAVE(actor, obj, buff)
end

function ShieldChargeClientScp_ENTER(actor, obj, buff)
    if actor:GetVehicleActor() ~= nil then
        actor:GetAnimation():SetSTDAnim("ASTD_RIDE");
        actor:GetAnimation():SetRUNAnim("SKL_ATAQUE_RUN_RIDE");
        actor:GetAnimation():SetWLKAnim("SKL_ATAQUE_RUN_RIDE");
        actor:GetAnimation():SetTURNAnim("None");
    else
        actor:GetAnimation():SetSTDAnim("ASTD");
        actor:GetAnimation():SetRUNAnim("SKL_ATAQUE_RUN");
        actor:GetAnimation():SetWLKAnim("SKL_ATAQUE_RUN");
        actor:GetAnimation():SetTURNAnim("None");
    end
    actor:SetAlwaysBattleState(true);
end

function ShieldChargeClientScp_LEAVE(actor, obj, buff)
    local buffRamMuay = actor:GetBuff():GetBuff('RamMuay_Buff');
    if buffRamMuay ~= nil then
        actor:GetAnimation():SetSTDAnim("SKL_NAKMUAY_ASTD");
        actor:GetAnimation():SetRUNAnim("SKL_NAKMUAY_ARUN");actor:GetAnimation():SetRAISEAnim("SKL_NAKMUAY_RAISE");
        actor:GetAnimation():SetOnAIRAnim("SKL_NAKMUAY_ONAIR");
        actor:GetAnimation():SetFALLAnim("SKL_NAKMUAY_FALL");   
    else
        actor:GetAnimation():ResetSTDAnim();
        actor:GetAnimation():ResetRUNAnim();
        actor:GetAnimation():ResetWLKAnim();
        actor:GetAnimation():ResetTURNAnim();
    end
    actor:SetAlwaysBattleState(false);
end

function SlitheringClientScp_ENTER(actor, obj, buff)
    actor:GetAnimation():SetSTDAnim("SKL_SLITHERING_ASTD");
    actor:GetAnimation():SetRUNAnim("SKL_SLITHERING_AWLK");
    actor:GetAnimation():SetWLKAnim("SKL_SLITHERING_AWLK");
    actor:GetAnimation():SetTURNAnim("None");
    actor:SetAlwaysBattleState(true);
end

function SlitheringClientScp_LEAVE(actor, obj, buff)
    ScpChangeSwordmanStanceAnimationSet(actor, obj, buff)
    actor:SetAlwaysBattleState(false);
end

function PouncingClientScp_ENTER(actor, obj, buff)
    actor:SetAlwaysBattleState(true);
    actor:GetAnimation():ResetSTDAnim();

    local abil = session.GetAbilityByName("Barbarian41");
    if abil ~= nil then
        local abilObj = GetIES(abil:GetObject());
        if abilObj.ActiveState == 1 then
            actor:GetAnimation():SetRUNAnim("SKL_POUNCING_STAND_ABIL");
            actor:GetAnimation():SetWLKAnim("SKL_POUNCING_STAND_ABIL");
            actor:GetAnimation():SetTURNAnim("None");
            actor:GetAnimation():SetSTDAnim("SKL_POUNCING_STAND_ABIL");
            if actor:GetVehicleActor() ~= nil then
                actor:GetAnimation():SetSTDAnim("SKL_POUNCING_ABIL_RIdE");
            else
                actor:GetAnimation():SetSTDAnim("SKL_POUNCING_STAND_ABIL");
            end
        else
            actor:GetAnimation():SetRUNAnim("SKL_POUNCING");
            actor:GetAnimation():SetWLKAnim("SKL_POUNCING");
            actor:GetAnimation():SetTURNAnim("None");
            if actor:GetVehicleActor() ~= nil then
                actor:GetAnimation():SetSTDAnim("SKL_POUNCING_RIDE");
            else
                actor:GetAnimation():SetSTDAnim("SKL_POUNCING_STAND");
            end
        end
    else
        actor:GetAnimation():SetRUNAnim("SKL_POUNCING");
        actor:GetAnimation():SetWLKAnim("SKL_POUNCING");
        actor:GetAnimation():SetTURNAnim("None");
        if actor:GetVehicleActor() ~= nil then
            actor:GetAnimation():SetSTDAnim("SKL_POUNCING_RIDE");
        else
            actor:GetAnimation():SetSTDAnim("SKL_POUNCING_STAND");
        end        
    end
end

function PouncingClientScp_LEAVE(actor, obj, buff)
    actor:GetAnimation():ResetSTDAnim();
    ScpChangeSwordmanStanceAnimationSet(actor, obj, buff)
    actor:SetAlwaysBattleState(false);
end

function TaglioClientScp_ENTER(actor, obj, buff)
    actor:GetAnimation():SetSTDAnim("SKL_TAGLIO_STAND");
    actor:GetAnimation():SetRUNAnim("SKL_TAGLIO");
    actor:GetAnimation():SetWLKAnim("SKL_TAGLIO");
    actor:GetAnimation():SetTURNAnim("None");
    actor:SetAlwaysBattleState(true);
end

function TaglioClientScp_LEAVE(actor, obj, buff)
    actor:GetAnimation():ResetSTDAnim();
    actor:GetAnimation():ResetRUNAnim();
    actor:GetAnimation():ResetWLKAnim();
    actor:GetAnimation():ResetTURNAnim();
    actor:SetAlwaysBattleState(false);
end

function LimaconClientScp_ENTER(actor, obj, buff)
--    actor:GetAnimation():SetSTDAnim("ASTD");
--    actor:GetAnimation():SetTURNAnim("None");
--    actor:SetMovingShotAnimation("SKL_LIMACON");
--    actor:SetAlwaysBattleState(true);
    ScpChangeMovingShotAnimationSet(actor, obj, buff);
end

function LimaconClientScp_LEAVE(actor, obj, buff)
    actor:GetAnimation():ResetSTDAnim();
    actor:GetAnimation():ResetTURNAnim();    
    actor:SetMovingShot_MainWAnimation("");
    actor:SetMovingShot_SubWAnimation("");
    actor:SetAlwaysBattleState(false);
    ScpChangeMovingShotAnimationSet(actor, obj, buff);
end

function RunningShotClientScp_ENTER(actor, obj, buff)
--    actor:SetMovingShotAnimation("ATKRUN");
    ScpChangeMovingShotAnimationSet(actor, obj, buff)
end

function RunningShotClientScp_LEAVE(actor, obj, buff)
    actor:SetMovingShotAnimation("");
    ScpChangeMovingShotAnimationSet(actor, obj, buff)
end

function SnipersSerenityClientScp_ENTER(actor, obj, buff)
    if pc.IsBuffApplied(actor, "DesperateDefense_Buff") == 0 and (IsPVPField(actor) == 1 or IsPVPServer(actor) == 1) then
        actor:GetAnimation():SetWLKAnim("SKL_SNIPERSSERENITY_AWLK");
        actor:GetAnimation():SetRUNAnim("SKL_SNIPERSSERENITY_AWLK");
    end
end

function SnipersSerenityClientScp_LEAVE(actor, obj, buff)
    actor:GetAnimation():ResetWLKAnim();
    actor:GetAnimation():ResetRUNAnim();
end

function FlutingClientScp_ENTER(actor, obj, buff)
    actor:GetAnimation():SetRUNAnim("SKL_PIEDPIPER_FLUTING");
    actor:GetAnimation():SetWLKAnim("SKL_PIEDPIPER_FLUTING");
    actor:SetAlwaysBattleState(true);
end

function FlutingClientScp_LEAVE(actor, obj, buff)
    actor:GetAnimation():ResetRUNAnim();
    actor:GetAnimation():ResetWLKAnim();
    actor:SetAlwaysBattleState(false);
end

function Murmillo_ChangeStance_ENTER(actor, obj, buff)
    actor:SetAlwaysBattleState(true);
    actor:GetAnimation():SetChangeJumpAnim(true);
    actor:GetAnimation():SetTURNAnim("SKL_MURMILLO_ATURN");
    actor:GetAnimation():SetSTDAnim("SKL_MURMILLO_ASTD");
    actor:GetAnimation():SetRUNAnim("SKL_MURMILLO_ARUN");
    actor:GetAnimation():SetLANDAnim("SKL_MURMILLO_LAND")
    actor:GetAnimation():SetRAISEAnim("SKL_MURMILLO_RAISE")
    actor:GetAnimation():SetOnAIRAnim("SKL_MURMILLO_ONAIR")
    actor:GetAnimation():SetFALLAnim("SKL_MURMILLO_FALL")
end

function Murmillo_ChangeStance_LEAVE(actor, obj, buff)
    actor:SetAlwaysBattleState(false);
    actor:GetAnimation():PlayFixAnim('SKL_MURMILLO_OFF', 1, 0);
    actor:GetAnimation():SetChangeJumpAnim(false);
    actor:GetAnimation():InitJumpAnimation();
    actor:GetAnimation():ResetTURNAnim();
    actor:GetAnimation():ResetSTDAnim();
    actor:GetAnimation():ResetRUNAnim();
    ScpChangeSwordmanStanceAnimationSet(actor, obj, buff)
end

function Dragoon_ChangeStance_ENTER(actor, obj, buff)
    actor:SetAlwaysBattleState(true);
--    actor:GetAnimation():SetChangeJumpAnim(true);
--    actor:GetAnimation():SetTURNAnim("SKL_MURMILLO_ATURN");
--    actor:GetAnimation():SetSTDAnim("SKL_MURMILLO_ASTD");
--    actor:GetAnimation():SetRUNAnim("SKL_MURMILLO_ARUN");
--    actor:GetAnimation():SetLANDAnim("SKL_MURMILLO_LAND")
--    actor:GetAnimation():SetRAISEAnim("SKL_MURMILLO_RAISE")
--    actor:GetAnimation():SetOnAIRAnim("SKL_MURMILLO_ONAIR")
--    actor:GetAnimation():SetFALLAnim("SKL_MURMILLO_FALL")
end

function Dragoon_ChangeStance_LEAVE(actor, obj, buff)
    actor:SetAlwaysBattleState(false);
    actor:GetAnimation():PlayFixAnim('SKL_DRAGOONHELMET_OFF', 1, 0);
--    actor:GetAnimation():SetChangeJumpAnim(false);
--    actor:GetAnimation():InitJumpAnimation();
--    actor:GetAnimation():ResetTURNAnim();
--    actor:GetAnimation():ResetSTDAnim();
--    actor:GetAnimation():ResetRUNAnim();
end

function BeakMask_ENTER(actor, obj, buff)
    actor:SetAlwaysBattleState(true);
end

function BeakMask_LEAVE(actor, obj, buff)
    local anim = "SKL_BEAKMASK_OFF"
    local abil = session.GetAbilityByName("PlagueDoctor23");
    if abil ~= nil then
        local abilObj = GetIES(abil:GetObject());
        if abilObj.ActiveState == 1 then
            anim = "SKL_BEAKMASK_OFF_ABIL"
        end
    end
    actor:SetAlwaysBattleState(false);
    actor:GetAnimation():PlayFixAnim(anim, 1, 0);
end

function Finestra_ENTER(actor, obj, buff)
    actor:SetAlwaysBattleState(true);
    if actor:GetVehicleActor() ~= nil then
    --actor:GetAnimation():SetChangeJumpAnim(true);
    actor:GetAnimation():SetTURNAnim("SKL_FINESTRA_ATURN_RIDE");
    actor:GetAnimation():SetSTDAnim("SKL_FINESTRA_ASTD_RIDE");
    actor:GetAnimation():SetRUNAnim("SKL_FINESTRA_ARUN_RIDE");
    actor:GetAnimation():SetLANDAnim("SKL_FINESTRA_LAND_RIDE")
    actor:GetAnimation():SetRAISEAnim("SKL_FINESTRA_RAISE_RIDE")
    actor:GetAnimation():SetOnAIRAnim("SKL_FINESTRA_ONAIR_RIDE")
    actor:GetAnimation():SetFALLAnim("SKL_FINESTRA_FALL_RIDE")
    else
    --actor:GetAnimation():SetChangeJumpAnim(true);
    actor:GetAnimation():SetTURNAnim("SKL_FINESTRA_ATURN");
    actor:GetAnimation():SetSTDAnim("SKL_FINESTRA_ASTD");
    actor:GetAnimation():SetRUNAnim("SKL_FINESTRA_ARUN");
    actor:GetAnimation():SetLANDAnim("SKL_FINESTRA_LAND")
    actor:GetAnimation():SetRAISEAnim("SKL_FINESTRA_RAISE")
    actor:GetAnimation():SetOnAIRAnim("SKL_FINESTRA_ONAIR")
    actor:GetAnimation():SetFALLAnim("SKL_FINESTRA_FALL")
    end
end

function Finestra_LEAVE(actor, obj, buff)
    actor:SetAlwaysBattleState(false);
    actor:GetAnimation():SetChangeJumpAnim(false);
    actor:GetAnimation():InitJumpAnimation();
    actor:GetAnimation():ResetTURNAnim();
    actor:GetAnimation():ResetSTDAnim();
    actor:GetAnimation():ResetRUNAnim();
    ScpChangeSwordmanStanceAnimationSet(actor, obj, buff)

    actor:GetAnimation():PlayAnimByFrame("SKL_FINESTRA_SWITCH", 0.7, 1, 1, 0, 15);
    actor:GetAnimation():ReserveAnim("ASTD", 1, 1);
end

function EpeeGarde_ENTER(actor, obj, buff)
    local lhItem = session.GetEquipItemBySpot(item.GetEquipSpotNum("LH"));
    if nil == lhItem then
        return;
    end

    local lhObj = GetIES(lhItem:GetObject());
    if nil == lhObj then
        return;
    end
    actor:SetAlwaysBattleState(true);
    actor:ShowModelByPart('LH', 0, 0, 'EpeeGarde_Buff');
    actor:GetAnimation():SetSTDAnim("SKL_EPEEGARDE_ASTD");
end

function EpeeGarde_LEAVE(actor, obj, buff)
    actor:SetAlwaysBattleState(false);
    actor:GetAnimation():ResetSTDAnim();
    actor:ShowModelByPart('LH', 1, 0, 'EpeeGarde_Buff');
    actor:GetAnimation():UpdateFixAnim();
    ScpChangeSwordmanStanceAnimationSet(actor, obj, buff)
end

function HighGuard_ENTER(actor, obj, buff)
    actor:SetAlwaysBattleState(true);
    if actor:GetVehicleActor() ~= nil then
    actor:GetAnimation():InitJumpAnimation();
    actor:GetAnimation():SetTURNAnim("SKL_HIGHGUARD_ATURN_RIDE");
    actor:GetAnimation():SetSTDAnim("SKL_HIGHGUARD_ASTD_RIDE");
    actor:GetAnimation():SetRUNAnim("SKL_HIGHGUARD_ARUN_RIDE");
    else
    actor:GetAnimation():InitJumpAnimation();
    actor:GetAnimation():SetTURNAnim("SKL_HIGHGUARD_ATURN");
    actor:GetAnimation():SetSTDAnim("SKL_HIGHGUARD_ASTD");
    actor:GetAnimation():SetRUNAnim("SKL_HIGHGUARD_ARUN");
    end
end

function HighGuard_LEAVE(actor, obj, buff)
    actor:SetAlwaysBattleState(false);
    actor:GetAnimation():InitJumpAnimation();
    actor:GetAnimation():ResetTURNAnim();
    actor:GetAnimation():ResetSTDAnim();
    actor:GetAnimation():ResetRUNAnim();
    ScpChangeSwordmanStanceAnimationSet(actor, obj, buff)
end

function CamouflageScp_ENTER(actor, obj, buff)
    actor:SetAlwaysBattleState(true);
    actor:GetAnimation():SetTURNAnim("None");
    actor:GetAnimation():SetSTDAnim("HIDE_STD");
    actor:GetAnimation():SetRUNAnim("HIDE_WLK");
    actor:GetAnimation():SetWLKAnim("HIDE_WLK");
end

function CamouflageScp_LEAVE(actor, obj, buff)
    actor:SetAlwaysBattleState(false);
    actor:GetAnimation():ResetTURNAnim();
    actor:GetAnimation():ResetSTDAnim();
    actor:GetAnimation():ResetRUNAnim();
    actor:GetAnimation():ResetWLKAnim();
end

function Proliferation_ENTER(actor, obj, buff)
    if pc.IsBuffApplied(actor, "Thurisaz_Buff") == 1 then
        return;
    end 

    actor:SetTransfomedNodeScale(1);

    local isEquipDoubleHandItem = false;
    local apc = actor:GetPCApc();
    if apc ~= nil then
        local rhItemType = apc:GetEquipItem(ES_RH);
        local rhItemCls = GetClassByType("Item", rhItemType);
        if rhItemCls ~= nil then
            local eqpType = TryGetProp(rhItemCls, "EqpType");
            if eqpType ~= nil and eqpType == "DH" then
                isEquipDoubleHandItem = true;
            end
        end
    end

    if isEquipDoubleHandItem == true then
        actor:PushSetNodeScale("Proliferation1", "Bip01 L Hand", 1.3);
        actor:PushSetNodeScale("Proliferation2", "Dummy_L_HAND", 1.25);
        actor:PushSetNodeScale("ProliferationRH1", "Bip01 R Hand", 1.3)
        actor:PushSetNodeScale("ProliferationRH2", "Dummy_R_HAND", 1.25)
        actor:PushSetNodeScale("ProliferationRH3", "Dummy_R_dagger", 1.25)
        actor:PushSetNodeScale("ProliferationRH4", "Dummy_R_allebell", 1.25)
        actor:PushSetNodeScale("ProliferationRH5", "Dummy_R_umbrella", 1.25)
        actor:PushSetNodeScale("ProliferationRH6", "Dummy_Shield", 1.25)
    else
        actor:PushSetNodeScale("Proliferation1", "Bip01 L Hand", 2.0);
        actor:PushSetNodeScale("Proliferation2", "Dummy_L_HAND", 1.25);
        actor:PushSetNodeScale("ProliferationRH1", "Bip01 R Hand", 2.0)
        actor:PushSetNodeScale("ProliferationRH2", "Dummy_R_HAND", 1.25)
        actor:PushSetNodeScale("ProliferationRH3", "Dummy_R_dagger", 1.25)
        actor:PushSetNodeScale("ProliferationRH4", "Dummy_R_allebell", 1.25)
        actor:PushSetNodeScale("ProliferationRH5", "Dummy_R_umbrella", 1.25)
        actor:PushSetNodeScale("ProliferationRH6", "Dummy_Shield", 1.25)
    end
end

function Proliferation_LEAVE(actor, obj, buff)
    actor:SetTransfomedNodeScale(0);
	actor:PopSetNodeScale("Proliferation1");
	actor:PopSetNodeScale("Proliferation2");
	actor:PopSetNodeScale("ProliferationRH1");
	actor:PopSetNodeScale("ProliferationRH2");
	actor:PopSetNodeScale("ProliferationRH3");
	actor:PopSetNodeScale("ProliferationRH4");
	actor:PopSetNodeScale("ProliferationRH5");
	actor:PopSetNodeScale("ProliferationRH6");
end

function ProliferationRH_ENTER(actor, obj, buff)
    if pc.IsBuffApplied(actor, "Thurisaz_Buff") == 1 then
        return;
    end

    actor:PushNodeScale("ProliferationRH1", "Bip01 R Hand", 1.0)
    actor:PushNodeScale("ProliferationRH2", "Dummy_R_HAND", 0.25)
    actor:PushNodeScale("ProliferationRH3", "Dummy_R_dagger", 0.25)
    actor:PushNodeScale("ProliferationRH4", "Dummy_R_allebell", 0.25)
    actor:PushNodeScale("ProliferationRH5", "Dummy_R_umbrella", 0.25)
    actor:PushNodeScale("ProliferationRH6", "Dummy_Shield", 0.25)    
end

function ProliferationRH_LEAVE(actor, obj, buff)
	actor:PopNodeScale("ProliferationRH1");
	actor:PopNodeScale("ProliferationRH2");
	actor:PopNodeScale("ProliferationRH3");
	actor:PopNodeScale("ProliferationRH4");
	actor:PopNodeScale("ProliferationRH5");
	actor:PopNodeScale("ProliferationRH6");
end

function Biggle_ENTER(actor, obj, buff, rps, dir)
    actor:SetRotateBillboard(1, 0.5, -1);
end

function Biggle_LEAVE(actor, obj, buff)
    actor:SetRotateBillboard(0, 0.5, -1);
end

function Vasilissa_ENTER(actor, obj, buff)
    actor:GetEffect():EnableVibrate(1, 1, 0.5, 50.0);
    -- imcSound.PlaySoundItem(cls.Sound);
    -- actor:PlaySound("SOUNDNAME");
end

function Vasilissa_LEAVE(actor, obj, buff)
end

-- 버프이펙트 크기설정
function CalcBuffEffScale(radius)
    local scale = 1;        -- 기준. 스몰 m_radius = 12
    if radius >= 50 then
        scale = 2.5;        -- 엑스라지
    elseif radius >= 20 then
        scale = 2;          -- 라지
    elseif radius >= 15 then
        scale = 1.5;        -- 미들
    end
    return scale;
end

-- 텔레키네시스처럼 FSM으로는 ASTD이지만 실제로는 스킬캐스팅중 인것들 등록. (버프로 캐스팅중인것 확인)
function IsSkillStateByBuff(isForGuard)
  -- 텔레키네시스
  if info.GetMyPcBuff('TeleCast') ~= nil then
    return 1;
  end
  -- 임페일러
    if isForGuard == 1 and info.GetMyPcBuff('Impaler_Buff') ~= nil then
      return 1;
    end
  return 0;
end

function IsSkillStateOnCompanionByBuff()
    -- 텔레키네시스
  if info.GetMyPcBuff('TeleCast') ~= nil then
    return 1;
  end

  if info.GetMyPcBuff('Impaler_Buff') ~= nil then
    return 1;
  end
  return 0;
end

function TimeReverseClient_ENTER(actor, obj, buff)
    local reserveTime = buff.arg1 / 2000;
    actor:StartTimeReserveCmd(reserveTime);
end

function TimeReverseClient_LEAVE(actor, obj, buff)
end

function PlantGuard_ENTER(actor, obj, buff)
    geGrassEffect.EnablePlantSurround(actor, 25);
end

function PlantGuard_LEAVE(actor, obj, buff)
    geGrassEffect.EnablePlantSurround(actor, 0);
end

-- 독
function PoisonBlink_ENTER(actor, obj, buff)
  imcSound.PlaySoundEvent("monster_state_2")
    actor:GetEffect():SetColorBlink(0,0.1,0,0,0.05,0.3,0,0, 1.5, 1);
end

function PoisonBlink_LEAVE(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0,0,0.2,0,1, 0, 1);
end

-- 출혈
function WoundBlink_ENTER(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0,0.5,0,0,1, 2.5, 1);
end

function WoundBlink_LEAVE(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0,0.5,0,0,1, 0 , 1);
end

-- 화염
function FireBlink_ENTER(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0,76,50,0,1, 2.5, 1);
end

function FireBlink_LEAVE(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0,0.5,0.2,0,1, 0 , 1);
end

-- 목둔술
function Mokuton_ENTER(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0,0.1,0.11,0.1,0.15, 2.5, 1);
end

function Mokuton_LEAVE(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0,0.5,0.2,0,1, 0 , 1);
end

-- 대박버프
function SuperDrop_Client_ENTER(actor, obj, buff)
    if buff.arg2 == 1 then
        actor:GetEffect():SetColorBlink(0,0,0,0,1,0.8,0.07,1, 1.5, 1);
    else
        actor:GetEffect():SetColorBlink(0,0,0,0,1,1,1,1, 1.5, 1);
    end
end

function SuperDrop_Client_LEAVE(actor, obj, buff)
    if buff.arg2 == 1 then
        actor:GetEffect():SetColorBlink(0,0,0,0,1,0.8,0.07,1, 0, 1);
    else
        actor:GetEffect():SetColorBlink(0,0,0,0,1,1,1,1, 0 , 1);
    end
end

-- Challenge Mode DKP Monster Buff
function ChallengeMode_Client_ENTER(actor, obj, buff)
    if buff.arg2 == 1 then
        actor:GetEffect():SetColorBlink(0,0,0,0,1,0.8,0.07,1, 1.5, 1);
    else
        actor:GetEffect():SetColorBlink(0,0,0,0,180/255,43/255,208/255,1, 1.5, 1);
    end
end

function ChallengeMode_Client_LEAVE(actor, obj, buff)
    if buff.arg2 == 1 then
        actor:GetEffect():SetColorBlink(0,0,0,0,1,3,3,3, 0, 1);
    else
        actor:GetEffect():SetColorBlink(0,0,0,0,1,1,1,1, 0 , 1);
    end
end

function EliteMonster_ENTER(actor, obj, buff)
    actor:SetAuraInfo("EliteBuff");
    actor:GetTitle():UpdateCaption();
end

function EliteMonster_LEAVE(actor, obj, buff)
    actor:SetAuraInfo("None");
end

function Mythic_Boosting_Morale_ENTER(actor, obj, buff)
    actor:SetAuraInfo("Mythic_Boosting_Morale");
    actor:GetTitle():UpdateCaption();
end

function Mythic_Boosting_Morale_LEAVE(actor, obj, buff)
    actor:SetAuraInfo("");
    actor:GetTitle():UpdateCaption();
end

function Mythic_Chain_Lightning_ENTER(actor, obj, buff)
    actor:SetAuraInfo("Mythic_Chain_Lightning");
    actor:GetTitle():UpdateCaption();
end

function Mythic_Chain_Lightning_LEAVE(actor, obj, buff)
    actor:SetAuraInfo("");
    actor:GetTitle():UpdateCaption();
end

function Mythic_Puddle_ENTER(actor, obj, buff)
    actor:SetAuraInfo("Mythic_Puddle");
    actor:GetTitle():UpdateCaption();
end

function Mythic_Puddle_LEAVE(actor, obj, buff)
    actor:SetAuraInfo("");
    actor:GetTitle():UpdateCaption();
end

function Mythic_Bomb_ENTER(actor, obj, buff)
    actor:SetAuraInfo("Mythic_Bomb");
    actor:GetTitle():UpdateCaption();
end

function Mythic_Bomb_LEAVE(actor, obj, buff)
    actor:SetAuraInfo("");
    actor:GetTitle():UpdateCaption();
end

function Mythic_InfectiousDisease_ENTER(actor, obj, buff)
    actor:SetAuraInfo("Mythic_InfectiousDisease");
    actor:GetTitle():UpdateCaption();
end

function Mythic_InfectiousDisease_LEAVE(actor, obj, buff)
    actor:SetAuraInfo("");
    actor:GetTitle():UpdateCaption();
end

function Mythic_Link_ENTER(actor, obj, buff)
    actor:SetAuraInfo("Mythic_Link");
    actor:GetTitle():UpdateCaption();
end

function Mythic_Link_LEAVE(actor, obj, buff)
    actor:SetAuraInfo("");
    actor:GetTitle():UpdateCaption();
end

function Champion_Buff_ENTER(actor, obj, buff)
    actor:SetAuraInfo("Champion_Buff");
    actor:GetTitle():UpdateCaption();
end

function Champion_Buff_LEAVE(actor, obj, buff)
    actor:SetAuraInfo("");
    actor:GetTitle():UpdateCaption();
end

--반짝이 버프: 대박 버프처럼 반짝거리기만 하는 용도
function TwinkleBuff_Client_ENTER(actor, obj, buff)
    if buff.arg2 == 1 then
        actor:GetEffect():SetColorBlink(0,0,0,0,1,0.8,0.07,1, 1.5, 1);
    else
        actor:GetEffect():SetColorBlink(0,0,0,0,1,1,1,1, 1.5, 1);
    end
end

function TwinkleBuff_Client_LEAVE(actor, obj, buff)
    if buff.arg2 == 1 then
        actor:GetEffect():SetColorBlink(0,0,0,0,1,0.8,0.07,1, 0, 1);
    else
        actor:GetEffect():SetColorBlink(0,0,0,0,1,1,1,1, 0 , 1);
    end
end

-- 디바인스티그마 디버프 블링크
function DivineStigma_ENTER(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0,1,0,0,1, 1.5, 1);
end

function DivineStigma_LEAVE(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0,1,0,0,1, 0 , 1);
end

--흰색
function WhiteBlink_ENTER(actor, obj, buff)
    imcSound.PlaySoundEvent("monster_state_1")
    actor:GetEffect():SetColorBlink(0.1,0.1,0.1,0.1,0.3,0.3,0.3,0.3, 1.5, 1);
end

function WhiteBlink_LEAVE(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0,1,0,0,1, 0 , 1);
end

--빨간색
function RedBlink_ENTER(actor, obj, buff)
imcSound.PlaySoundEvent("monster_state_1")
    actor:GetEffect():SetColorBlink(0.2,0,0,0,0.45,0.05,0,0, 1.5, 1);
end

function RedBlink_LEAVE(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0,1,0,0,1, 0 , 1);
end

--파란색
function BlueBlink_ENTER(actor, obj, buff)
imcSound.PlaySoundEvent("monster_state_1")
    actor:GetEffect():SetColorBlink(0,0,0.1,0,0,0.1,0.4,0, 1.5, 1);
end

function BlueBlink_LEAVE(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0,1,0,0,1, 0 , 1);
end

function OrangeBlink_ENTER(actor, obj, buff)
imcSound.PlaySoundEvent("monster_state_1")
    actor:GetEffect():SetColorBlink(0,0,0.1,0,1,0.3,0,0, 1.5, 1);
end

function OrangeBlink_LEAVE(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0,1,0,0,1, 0 , 1);
end

--노란색
function YellowBlink_ENTER(actor, obj, buff)
imcSound.PlaySoundEvent("monster_state_1")
    actor:GetEffect():SetColorBlink(0.2,0.17,0.05,0,0.5,0.4,0.15,0, 1.5, 1);
end

function YellowBlink_LEAVE(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0,1,0,0,1, 0 , 1);
end

--금색
function GoldenBlink_ENTER(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0.3,0.22,0.08,0,0,0,0,0, 2, 1);
end

function GoldenBlink_LEAVE(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0,1,0,0,1, 0 , 1);
end

--핑크
function PinkBlink_ENTER(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0.2,0,0,0,0.58,0.36,0.52,0, 1.5, 1);
end

function PinkBlink_LEAVE(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0,1,0,0,1, 0 , 1);
end

--하늘색
function CyanBlink_ENTER(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0, 0,0.3,0.5,0, 1.5, 1);
end
    
function CyanBlink_LEAVE(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0, 0,0,0,1, 0, 1);
end

-- 포인팅 디버프 블링크
function Pointing_ENTER(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0,1,0,0,1, 3.0, 1);
end

function Pointing_LEAVE(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0,1,0,0,1, 0 , 1);
end

function CollarBombScp_ENTER(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0,1,0,0,1, 3.0, 1);
end

function CollarBombScp_LEAVE(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0,1,0,0,1, 0 , 1);
end

function rottenScp_ENTER(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0,0,0.1,0,0.1, 1, 1);
end

function rottenScp_LEAVE(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0,0,0.1,0,0.1, 0, 1);
end

function DirtyWallScp_ENTER(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0,0,0.3,0,0.6, 1.4, 1);
end

function DirtyWallScp_LEAVE(actor, obj, buff)
    actor:GetEffect():SetColorBlink(0,0,0,0,0,0.3,0,0.6, 0, 1);
end

function LH_VisibleObject_ENTER(actor, obj, buff, rps, dir)
    actor:ShowModelByPart("LH", 0, 0, "LH_VisibleObject");
end

function LH_VisibleObject_LEAVE(actor, obj, buff)
    actor:ShowModelByPart("LH", 1, 0, "LH_VisibleObject");
end

function RH_VisibleObject_ENTER(actor, obj, buff, rps, dir)
    actor:ShowModelByPart("RH", 0, 0, "RH_VisibleObject");  
end

function RH_VisibleObject_LEAVE(actor, obj, buff)
    actor:ShowModelByPart("RH", 1, 0, "RH_VisibleObject");
end

function ThrowObject_Biggle_ENTER(actor, obj, buff, rps, dir)
    actor:SetThrowObject(1, 0.5, -1);
end

function ThrowObject_Biggle_LEAVE(actor, obj, buff)
    actor:SetThrowObject(0, 0.5, -1);
end

function Impaler_Astd_ENTER(actor, obj, buff, rps, dir)
    actor:GetAnimation():SetRUNAnim("SKL_IMPALER_ARUN_RIDE");
    actor:GetAnimation():SetSTDAnim("SKL_IMPALER_ASTD_RIDE");
    actor:SetAlwaysBattleState(true);
end

function Impaler_Astd_LEAVE(actor, obj, buff)
    
    actor:GetAnimation():ResetSTDAnim();
    actor:GetAnimation():ResetRUNAnim();
    actor:SetAlwaysBattleState(false);
end

function EmperorsBane_Astd_ENTER(actor, obj, buff, rps, dir)
    actor:GetAnimation():SetSTDAnim("SKL_MURMILLO_EMPEROR'SBANE_ASTD");
    actor:SetAlwaysBattleState(true);
end

function EmperorsBane_Astd_LEAVE(actor, obj, buff)
    actor:GetAnimation():ResetSTDAnim();
    actor:SetAlwaysBattleState(false);
end

function EMPERORSBANE_STUN_ANI_ENTER(actor, obj, buff, rps, dir)
    actor:GetAnimation():SetSTDAnim("stun");
    actor:GetAnimation():PlayFixAnim('stun', 1, 1);
end

function EMPERORSBANE_STUN_ANI_LEAVE(actor, obj, buff)
    actor:GetAnimation():ResetSTDAnim();
    actor:GetAnimation():PlayFixAnim("ASTD", 1.0, 0);
end

function KneelingShot_ENTER(actor, obj, buff)
    --actor:SetLimitMinTargetRange(50);
    actor:GetAnimation():SetSTDAnim("SKL_KNEELINGSHOT_ASTD");
    actor:SetAlwaysBattleState(true);   
end

function KneelingShot_LEAVE(actor, obj, buff)
    --actor:SetLimitMinTargetRange(0);
    actor:GetAnimation():ResetSTDAnim();
    actor:SetAlwaysBattleState(false);
end

function Bazooka_ENTER(actor, obj, buff)
    actor:SetAlwaysBattleState(true);
    actor:GetAnimation():SetSTDAnim("SKL_BAZOOCA_ASTD");
end

function Bazooka_LEAVE(actor, obj, buff)
    actor:SetAlwaysBattleState(false);
    actor:GetAnimation():ResetSTDAnim();
end

function RetreatShotScp_ENTER(actor, obj, buff)
    ScpChangeMovingShotAnimationSet(actor, obj, buff);
end

function RetreatShotScp_LEAVE(actor, obj, buff)
    actor:GetAnimation():ResetSTDAnim();
    actor:GetAnimation():ResetRUNAnim();
    actor:GetAnimation():ResetWLKAnim();
    actor:GetAnimation():ResetTURNAnim();
    actor:SetAlwaysBattleState(false);
    ScpChangeMovingShotAnimationSet(actor, obj, buff);
end

function AssaultFireScp_ENTER(actor, obj, buff)
    ScpChangeMovingShotAnimationSet(actor, obj, buff);
end

function AssaultFireScp_LEAVE(actor, obj, buff)
    actor:GetAnimation():ResetSTDAnim();
    actor:GetAnimation():ResetRUNAnim();
    actor:GetAnimation():ResetWLKAnim();
    actor:GetAnimation():ResetTURNAnim();
    actor:SetAlwaysBattleState(false);
    actor:GetAnimation():PlayFixAnim("ASTD", 1, 1);
    ScpChangeMovingShotAnimationSet(actor, obj, buff);
end

function OutrageScp_ENTER(actor, obj, buff)
    --ScpChangeMovingShotAnimationSet(actor, obj, buff);
end

function OutrageScp_LEAVE(actor, obj, buff)
    -- actor:GetAnimation():ResetSTDAnim();
    -- actor:GetAnimation():ResetRUNAnim();
    -- actor:GetAnimation():ResetWLKAnim();
    -- actor:GetAnimation():ResetTURNAnim();
    -- actor:SetAlwaysBattleState(false);
    -- actor:GetAnimation():PlayFixAnim("ASTD", 1, 1);
    -- ScpChangeMovingShotAnimationSet(actor, obj, buff);
end

function WebFlyObject_ENTER(actor, obj, buff)
  actor:GetEffect():SetColorBlink(0.1,0.1,0.1,0.1,0.3,0.3,0.3,0.3, 1.5, 1);
    actor:GetEffect():DownModelToGround(true);
end

function WebFlyObject_LEAVE(actor, obj, buff)
  actor:GetEffect():SetColorBlink(0,0,0,0,1,0,0,1, 0 , 1);
    actor:GetEffect():DownModelToGround(false);
end

function Arrest_ENTER(actor, obj, buff)
  actor:GetEffect():SetColorBlink(0.1,0.1,0.1,0.1,0.3,0.3,0.3,0.3, 1.5, 1);
    local caster = buff:GetHandle();
    hardSkill.LinkToObject(actor, caster, "Warrior_Pull", "Dummy_R_HAND", "Bip01 Spine2");

    if actor:GetObjType() == GT_MONSTER then
        local monCls = GetClassByType("Monster", actor:GetType());
        if monCls.MoveType == "Flying" then
            actor:GetEffect():DownModelToGround(true);
        end
    end
end

function Arrest_LEAVE(actor, obj, buff)
  actor:GetEffect():SetColorBlink(0,0,0,0,1,0,0,1, 0 , 1);
    local caster = buff:GetHandle();
    hardSkill.LinkToObject(nil, caster, "Warrior_Pull", "Dummy_R_HAND", "Bip01 Spine2");
    if actor:GetObjType() == GT_MONSTER then
        local monCls = GetClassByType("Monster", actor:GetType());
        if monCls.MoveType == "Flying" then
            actor:GetEffect():DownModelToGround(false);
        end
    end
end

function TESTUDO_CLIENT_ENTER(actor, obj, buff)
      actor:GetAnimation():SetTURNAnim("SKL_TESTUDO_ASTD"); 
        actor:GetAnimation():SetSTDAnim("SKL_TESTUDO_ASTD");
        actor:GetAnimation():SetRUNAnim("SKL_TESTUDO_AWLK");
        actor:GetAnimation():SetWLKAnim("SKL_TESTUDO_AWLK");
        actor:SetAlwaysBattleState(true);

    local apc = actor:GetPCApc();
    local lhItemType = apc:GetEquipItem(ES_LH);
    local equipShield = false;
    if item.IsNoneItem(lhItemType) == 1 then
        equipShield = true;
    else
        local itemCls = GetClassByType("Item", lhItemType);
        if itemCls == nil or itemCls.ClassType ~= "Shield" then
            equipShield = true;
        end
    end

    local defShield = GetClass("Item", "SHD01_101");
    if equipShield == true then
        actor:GetSystem():ChangeEquipApperance(ES_LH, defShield.ClassID);
        actor:SetUserValue("TESTUDO_SHIELD", 1);
    end
end

function TESTUDO_CLIENT_LEAVE(actor, obj, buff) 
    actor:GetAnimation():ResetSTDAnim();
    actor:GetAnimation():ResetRUNAnim();
    actor:GetAnimation():ResetWLKAnim();
    actor:GetAnimation():ResetTURNAnim();
  actor:SetAlwaysBattleState(false);
    if actor:GetUserIValue("TESTUDO_SHIELD") == 1 then
        actor:GetSystem():ChangeEquipApperance(ES_LH, 0);
        actor:SetUserValue("TESTUDO_SHIELD", 0);
    end
end

function SCHILTRON_CLIENT_ENTER(actor, obj, buff)
        actor:GetAnimation():SetSTDAnim("SKL_SCHILTRON");
        actor:SetAlwaysBattleState(true);
end

function SCHILTRON_CLIENT_LEAVE(actor, obj, buff)   
    actor:GetAnimation():ResetSTDAnim();
    actor:SetAlwaysBattleState(false);
end

function Burrow_Rogue_CLIENT_ENTER(actor, obj, buff)
    movie.ShowModel(actor:GetHandleVal(), 0);   
end

function Burrow_Rogue_CLIENT_LEAVE(actor, obj, buff)
    movie.ShowModel(actor:GetHandleVal(), 1);
end

function ShadowPool_Buff_CLIENT_ENTER(actor, obj, buff)
    --movie.ShowModel(actor:GetHandleVal(), 0);
    actor:GetEffect():SetColorBlend("ShadowPool", 0, 0, 0, 0, true, 0, false, 0);
end

function ShadowPool_Buff_CLIENT_LEAVE(actor, obj, buff)
    actor:GetEffect():SetColorBlend("ShadowPool", 255, 255, 255, 255, true, 0, false, 0);
    --movie.ShowModel(actor:GetHandleVal(), 1);
end

function IMPALER_STUN_ANI_ENTER(actor, obj, buff, rps, dir)
    actor:GetAnimation():SetSTDAnim("impaler_stun");
    actor:GetAnimation():PlayFixAnim('impaler_stun', 1, 1);
end

function IMPALER_STUN_ANI_LEAVE(actor, obj, buff)
    actor:GetAnimation():ResetSTDAnim();
    actor:GetAnimation():PlayFixAnim("ASTD", 1.0, 0);
end

function GuildBattleObserve_ENTER(actor, obj, buff) 
    actor:GetEffect():SetColorBlend("GuildPVP", 100, 100, 100, 100, true, 0, false, 0);
end

function GuildBattleObserve_LEAVE(actor, obj, buff)
end

function IronMaiden_ENTER(actor, obj, buff)
    local actorPos = actor:GetPos();
    actor:GetClientMonster():ClientMonsterToPos("pcskill_IronMaiden", "BORN", actorPos.x, actorPos.y, actorPos.z, 0, 0);
end

function IronMaiden_LEAVE(actor, obj, buff)
    local actorPos = actor:GetPos();
    actor:GetClientMonster():ClientMonsterToPos("pcskill_IronMaiden", "STD", actorPos.x, actorPos.y, actorPos.z, 0, 1);
end

function Levitation_ENTER(actor, obj, buff)
    actor:SetAlwaysBattleState(true);
    actor:GetAnimation():SetTURNAnim("SKL_LEVITATION_ATURN");
    actor:GetAnimation():SetSTDAnim("SKL_LEVITATION_ASTD");
    actor:GetAnimation():SetRUNAnim("SKL_LEVITATION_ARUN");
    actor:GetAnimation():SetWLKAnim("SKL_LEVITATION_ARUN");
end

function Levitation_LEAVE(actor, obj, buff)
    actor:SetAlwaysBattleState(false);
    actor:GetAnimation():ResetTURNAnim();
    actor:GetAnimation():ResetSTDAnim();
    actor:GetAnimation():ResetRUNAnim();
    actor:GetAnimation():ResetWLKAnim();
end

function HoukiBroom_ENTER(actor, obj, buff)
    actor:SetAlwaysBattleState(true);
    actor:GetAnimation():SetTURNAnim("SKL_HOUKIBROOM_LOOP");
    actor:GetAnimation():SetSTDAnim("SKL_HOUKIBROOM_LOOP");
    actor:GetAnimation():SetRUNAnim("SKL_HOUKIBROOM_WLK");
    actor:GetAnimation():SetWLKAnim("SKL_HOUKIBROOM_WLK");
end

function HoukiBroom_LEAVE(actor, obj, buff)
    actor:SetAlwaysBattleState(false);
    actor:GetAnimation():ResetTURNAnim();
    actor:GetAnimation():ResetSTDAnim();
    actor:GetAnimation():ResetRUNAnim();
    actor:GetAnimation():ResetWLKAnim();
    actor:GetAnimation():PlayFixAnim("ASTD", 1.0, 0);
end

function DashRunBlend_ENTER(actor, obj, buff)
    if actor:GetVehicleActor() ~= nil then
        effect.PlayActorEffect(actor, 'I_warrior_dash_run_line2', 'Dummy_emitter_pet', 2.0, 1.7);
    else
        effect.PlayActorEffect(actor, 'I_warrior_dash_run_line2', 'Dummy_emitter', 2.0, 1.7);
    end
    actor:GetEffect():SetColorBlend("DashRun", 100, 100, 100, 100, true, 0, true, 0.15);
    --local dir = actor:GetHorizonalDir();
    --actor:GetEffect():SetStartDirection("I_warrior_dash_run_line2", -dir.x, 0, -dir.y);
end

function DashRunBlend_LEAVE(actor, obj, buff)
end

function SlitheringDebuffClient_ENTER(actor, obj, buff)
    actor:GetAnimation():SetWLKAnim("RUN");
end

function SlitheringDebuffClient_LEAVE(actor, obj, buff)
    actor:GetAnimation():ResetWLKAnim();
end

function DoubleGunStance_ENTER(actor, obj, buff)
--    actor:ChangeEquipNode(EmAttach.eRHand, "Dummy_Sword");
--    actor:CopyAttachedModel(EmAttach.eLHand, "Dummy_L_HAND");
--    actor:SetAlwaysBattleState(true);
--    actor:SetMovingShotAnimation("DOUBLEGUN_ATKMOVE");
--    
--    actor:GetAnimation():SetTURNAnim("SKL_DOUBLEGUN_ATURN");
--    actor:GetAnimation():SetSTDAnim("SKL_DOUBLEGUN_ASTD");
--    actor:GetAnimation():SetRUNAnim("SKL_DOUBLEGUN_ARUN");
--    actor:GetAnimation():SetLANDAnim("SKL_DOUBLEGUN_LAND")
--    actor:GetAnimation():SetRAISEAnim("SKL_DOUBLEGUN_RAISE")
--    actor:GetAnimation():SetOnAIRAnim("SKL_DOUBLEGUN_ONAIR")
--    actor:GetAnimation():SetFALLAnim("SKL_DOUBLEGUN_FALL")
    ScpChangeMovingShotAnimationSet(actor, obj, buff);    
end

function DoubleGunStance_LEAVE(actor, obj, buff)
    actor:DetachCopiedModel();
    if tonumber(USE_SCOUT_MAINWEAPON) == 1 then
        actor:ChangeEquipNode(EmAttach.eLHand, "Dummy_L_HAND");
    else
        actor:ChangeEquipNode(EmAttach.eRHand, "Dummy_L_HAND");
    end
    actor:SetAlwaysBattleState(false);
    actor:GetAnimation():SetChangeJumpAnim(false);
    actor:SetMovingShotAnimation("");
    actor:GetAnimation():ResetTURNAnim();
    actor:GetAnimation():ResetSTDAnim();
    actor:GetAnimation():ResetRUNAnim();
    ScpChangeMovingShotAnimationSet(actor, obj, buff);
end

function RamMuay_ENTER(actor, obj, buff)
    actor:SetAlwaysBattleState(true);
    actor:GetAnimation():SetChangeJumpAnim(true);
    actor:GetAnimation():SetSTDAnim("SKL_NAKMUAY_ASTD");
    actor:GetAnimation():SetRUNAnim("SKL_NAKMUAY_ARUN");
    actor:GetAnimation():SetTURNAnim("SKL_NAKMUAY_ASTD");
    actor:GetAnimation():SetRAISEAnim("SKL_NAKMUAY_RAISE");
    actor:GetAnimation():SetOnAIRAnim("SKL_NAKMUAY_ONAIR")
    actor:GetAnimation():SetFALLAnim("SKL_NAKMUAY_FALL");
    actor:SetAlwaysBattleState(true);
end

function RamMuay_UPDATE(actor, obj, buff)
    local lhItem = session.GetEquipItemBySpot(item.GetEquipSpotNum("LH"));
    local lhObj = GetIES(lhItem:GetObject());
    if lhObj.ClassType == "Artefact" then
        actor:ShowModelByPart("LH", 0, 0, "RamMuay_Buff");
    end
end

function RamMuay_LEAVE(actor, obj, buff)
    actor:SetAlwaysBattleState(false);
    actor:GetAnimation():SetChangeJumpAnim(false);
    actor:SetMovingShotAnimation("");
    actor:GetAnimation():ResetTURNAnim();
    actor:GetAnimation():ResetSTDAnim();
    actor:GetAnimation():ResetRUNAnim();

    ScpChangeSwordmanStanceAnimationSet(actor, obj, buff)
end

function ScpChangeMovingShotAnimationSet(actor, obj, buff)
    local buffSwiftStep = actor:GetBuff():GetBuff('SwiftStep_Buff');
    local buffDoubleGunStance = actor:GetBuff():GetBuff('DoubleGunStance_Buff');
    local buffLimacon = actor:GetBuff():GetBuff('Limacon_Buff');
    local RetreatShot = actor:GetBuff():GetBuff('RetreatShot');
    local AssaultFire = actor:GetBuff():GetBuff('AssaultFire_Buff');
    local Outrage = actor:GetBuff():GetBuff('Outrage_Buff');
    local buffHakkapeliterAssault = actor:GetBuff():GetBuff('Hakkapeliter_Assault_Buff');
    
    -- Outrage_Buff
    -- elseif Outrage ~= nil and buffDoubleGunStance ~= nil then
    if buffDoubleGunStance ~= nil then
        actor:GetBuff():SetDoubleGunStanceState(actor:GetHandleVal(), true);
    else
        actor:GetBuff():SetDoubleGunStanceState(actor:GetHandleVal(), false);
    end

    if Outrage ~= nil and buffDoubleGunStance ~= nil then
        if tonumber(USE_SCOUT_MAINWEAPON) == 1 then
            actor:CopyAttachedModel(EmAttach.eRHand, "Dummy_L_HAND");
            local apc = actor:GetPCApc();
            local lhItemType = apc:GetEquipItem(ES_LH);
            local lhItemCls = GetClassByType("Item", lhItemType);
            if lhItemCls ~= nil then
                local classType = TryGetProp(lhItemCls, "ClassType", "None");
                if classType == "Sword" then
                    actor:ChangeEquipNode(EmAttach.eLHand, "Dummy_Sword");
                elseif classType == "Shield" then
                    actor:ChangeEquipNode(EmAttach.eLHand, "Dummy_B_Shield");
                end
            end
        else
            actor:CopyAttachedModel(EmAttach.eLHand, "Dummy_L_HAND");
            actor:ChangeEquipNode(EmAttach.eRHand, "Dummy_Sword");
        end
        actor:SetAlwaysBattleState(true);
        actor:SetMovingShotAnimation("DOUBLEGUN_ATKRUN");
        actor:GetAnimation():SetTURNAnim("SKL_DOUBLEGUN_ATURN");
        actor:GetAnimation():SetSTDAnim("SKL_DOUBLEGUN_ASTD");
        actor:GetAnimation():SetRUNAnim("SKL_DOUBLEGUN_ARUN");
        actor:GetAnimation():SetLANDAnim("SKL_DOUBLEGUN_LAND")
        actor:GetAnimation():SetRAISEAnim("SKL_DOUBLEGUN_RAISE")
        actor:GetAnimation():SetFALLAnim("SKL_DOUBLEGUN_FALL")
        --actor:GetAnimation():SetOnAIRAnim("SKL_DOUBLEGUN_AONAIR")
    else
        -- RunningShot_Buff
        if buffSwiftStep ~= nil then
            actor:SetMovingShotAnimation("ATKRUN");
        end
        
        -- DoubleGunStance_Buff
        if buffDoubleGunStance ~= nil then      
            if tonumber(USE_SCOUT_MAINWEAPON) == 1 then
                actor:CopyAttachedModel(EmAttach.eRHand, "Dummy_L_HAND");
                local apc = actor:GetPCApc();
                local lhItemType = apc:GetEquipItem(ES_LH);
                local lhItemCls = GetClassByType("Item", lhItemType);
                if lhItemCls ~= nil then
                    local classType = TryGetProp(lhItemCls, "ClassType", "None");
                    if classType == "Sword" then
                        actor:ChangeEquipNode(EmAttach.eLHand, "Dummy_Sword");
                    elseif classType == "Shield" then
                        actor:ChangeEquipNode(EmAttach.eLHand, "Dummy_B_Shield");
                    end
                end
            else
                actor:CopyAttachedModel(EmAttach.eLHand, "Dummy_L_HAND");
                actor:ChangeEquipNode(EmAttach.eRHand, "Dummy_Sword");
            end
            actor:SetAlwaysBattleState(true);
            actor:SetMovingShotAnimation("DOUBLEGUN_ATKMOVE");
            actor:GetAnimation():SetTURNAnim("SKL_DOUBLEGUN_ATURN");
            actor:GetAnimation():SetSTDAnim("SKL_DOUBLEGUN_ASTD");
            actor:GetAnimation():SetRUNAnim("SKL_DOUBLEGUN_ARUN");
            actor:GetAnimation():SetLANDAnim("SKL_DOUBLEGUN_LAND")
            actor:GetAnimation():SetRAISEAnim("SKL_DOUBLEGUN_RAISE")
            actor:GetAnimation():SetFALLAnim("SKL_DOUBLEGUN_FALL")
            --actor:GetAnimation():SetOnAIRAnim("SKL_DOUBLEGUN_ONAIR")
        end
    end
    
    -- Limacon_Buff
    if buffLimacon ~= nil then
         --actor:SetMovingShotAnimation("SKL_LIMACON");
         actor:GetAnimation():SetSTDAnim("ASTD");
         actor:GetAnimation():SetTURNAnim("None");
         actor:SetMovingShot_MainWAnimation("ATKMOVE");
         actor:SetMovingShot_SubWAnimation("SKL_LIMACON");
         actor:SetAlwaysBattleState(true);
    end
    
    -- RetreatShot --
    if actor:GetVehicleActor() ~= nil and RetreatShot ~= nil then
        actor:GetAnimation():SetRUNAnim("SKL_RETREATSHOT_RIDE");
        actor:GetAnimation():SetWLKAnim("SKL_RETREATSHOT_RIDE");
        actor:GetAnimation():SetTURNAnim("None");
        actor:SetAlwaysBattleState(true);
    end
    
    -- AssaultFire_Buff--
    if actor:GetVehicleActor() ~= nil and AssaultFire ~= nil then
        actor:GetAnimation():SetSTDAnim("SKL_WILDSHOT_LOOP_STD_RIDE");
        actor:GetAnimation():SetRUNAnim("SKL_WILDSHOT_LOOP_RIDE");
        actor:GetAnimation():SetWLKAnim("SKL_WILDSHOT_LOOP_RIDE");
        actor:GetAnimation():SetTURNAnim("None");
        actor:GetAnimation():PlayFixAnim("SKL_WILDSHOT_LOOP_STD_RIDE", 1, 1);
        actor:SetAlwaysBattleState(true);
    end

    -- Hakkapeliter_Assault_Buff
    if actor:GetVehicleActor() ~= nil and buffHakkapeliterAssault ~= nil then
        actor:GetAnimation():SetSTDAnim("SKL_INFINITEASSAULT_LOOP_STD_RIDE");
        actor:GetAnimation():SetRUNAnim("SKL_INFINITEASSAULT_LOOP_RIDE");
        actor:GetAnimation():SetWLKAnim("SKL_INFINITEASSAULT_LOOP_RIDE");
        actor:GetAnimation():SetTURNAnim("None");
        actor:GetAnimation():PlayFixAnim("SKL_INFINITEASSAULT_LOOP_STD_RIDE", 1, 1);
        actor:SetAlwaysBattleState(true);
    end
end

function ScpChangeSwordmanStanceAnimationSet(actor, obj, buff)
    local buffRamMuay = actor:GetBuff():GetBuff('RamMuay_Buff');
    local buffHighGuard = actor:GetBuff():GetBuff('HighGuard_Buff');
    local buffHighGuard_abil = actor:GetBuff():GetBuff('HighGuard_Abil_Buff');
    local buffFinestra= actor:GetBuff():GetBuff('Finestra_Buff');
    local buffEpeeGarde = actor:GetBuff():GetBuff('EpeeGarde_Buff');
    local buffHelmet = actor:GetBuff():GetBuff('murmillo_helmet');
    local buffEnmascarado = actor:GetBuff():GetBuff('Enmascarado_Buff');
    
    if buffRamMuay ~= nil then
        actor:GetAnimation():SetSTDAnim("SKL_NAKMUAY_ASTD");
        actor:GetAnimation():SetRUNAnim("SKL_NAKMUAY_ARUN");
        actor:GetAnimation():SetRAISEAnim("SKL_NAKMUAY_RAISE");
        actor:GetAnimation():SetOnAIRAnim("SKL_NAKMUAY_ONAIR");
        actor:GetAnimation():SetFALLAnim("SKL_NAKMUAY_FALL");
    elseif buffHighGuard ~= nil or buffHighGuard_abil ~= nil then
        if actor:GetVehicleActor() ~= nil then
            actor:GetAnimation():InitJumpAnimation();
            actor:GetAnimation():SetTURNAnim("SKL_HIGHGUARD_ATURN_RIDE");
            actor:GetAnimation():SetSTDAnim("SKL_HIGHGUARD_ASTD_RIDE");
            actor:GetAnimation():SetRUNAnim("SKL_HIGHGUARD_ARUN_RIDE");
        else
            actor:GetAnimation():InitJumpAnimation();
            actor:GetAnimation():SetTURNAnim("SKL_HIGHGUARD_ATURN");
            actor:GetAnimation():SetSTDAnim("SKL_HIGHGUARD_ASTD");
            actor:GetAnimation():SetRUNAnim("SKL_HIGHGUARD_ARUN");
        end
    elseif buffFinestra ~= nil then
        if actor:GetVehicleActor() ~= nil then
            actor:GetAnimation():SetTURNAnim("SKL_FINESTRA_ATURN_RIDE");
            actor:GetAnimation():SetSTDAnim("SKL_FINESTRA_ASTD_RIDE");
            actor:GetAnimation():SetRUNAnim("SKL_FINESTRA_ARUN_RIDE");
            actor:GetAnimation():SetLANDAnim("SKL_FINESTRA_LAND_RIDE")
            actor:GetAnimation():SetRAISEAnim("SKL_FINESTRA_RAISE_RIDE")
            actor:GetAnimation():SetOnAIRAnim("SKL_FINESTRA_ONAIR_RIDE")
            actor:GetAnimation():SetFALLAnim("SKL_FINESTRA_FALL_RIDE")
        else
            actor:GetAnimation():SetTURNAnim("SKL_FINESTRA_ATURN");
            actor:GetAnimation():SetSTDAnim("SKL_FINESTRA_ASTD");
            actor:GetAnimation():SetRUNAnim("SKL_FINESTRA_ARUN");
            actor:GetAnimation():SetLANDAnim("SKL_FINESTRA_LAND")
            actor:GetAnimation():SetRAISEAnim("SKL_FINESTRA_RAISE")
            actor:GetAnimation():SetOnAIRAnim("SKL_FINESTRA_ONAIR")
            actor:GetAnimation():SetFALLAnim("SKL_FINESTRA_FALL")
        end
    elseif buffEpeeGarde ~= nil then
        actor:GetAnimation():SetSTDAnim("SKL_EPEEGARDE_ASTD");
        actor:GetAnimation():ResetRUNAnim();
        actor:GetAnimation():ResetWLKAnim();
        actor:GetAnimation():ResetTURNAnim();
    elseif buffHelmet ~= nil then
        actor:GetAnimation():SetChangeJumpAnim(true);
        actor:GetAnimation():SetTURNAnim("SKL_MURMILLO_ATURN");
        actor:GetAnimation():SetSTDAnim("SKL_MURMILLO_ASTD");
        actor:GetAnimation():SetRUNAnim("SKL_MURMILLO_ARUN");
        actor:GetAnimation():SetLANDAnim("SKL_MURMILLO_LAND")
        actor:GetAnimation():SetRAISEAnim("SKL_MURMILLO_RAISE")
        actor:GetAnimation():SetOnAIRAnim("SKL_MURMILLO_ONAIR")
        actor:GetAnimation():SetFALLAnim("SKL_MURMILLO_FALL")
    elseif buffEnmascarado ~= nil then
        actor:GetAnimation():ResetRUNAnim();
        actor:GetAnimation():SetSTDAnim("SKL_LUCHADOR_ASTD");
        actor:GetAnimation():SetSTDAnim("SKL_LUCHADOR_ASTD");
        actor:GetAnimation():SetTURNAnim("SKL_LUCHADOR_ASTD");
        actor:GetAnimation():SetChangeJumpAnim(true);
        actor:GetAnimation():SetRAISEAnim("SKL_NAKMUAY_RAISE");
        actor:GetAnimation():SetOnAIRAnim("SKL_NAKMUAY_ONAIR");
        actor:GetAnimation():SetFALLAnim("SKL_NAKMUAY_FALL");

        local abil = session.GetAbilityByName("Luchador18");
        if abil ~= nil then
            local abilObj = GetIES(abil:GetObject());
            if abilObj.ActiveState == 1 then
                actor:GetAnimation():SetRUNAnim("DASH_RUN");
            end
        end
    else
        actor:GetAnimation():ResetSTDAnim();
        actor:GetAnimation():ResetRUNAnim();
        actor:GetAnimation():ResetWLKAnim();
        actor:GetAnimation():ResetTURNAnim();
    end
end

function SCR_ANIM_archer_f_bow_aonair(handle)
    local actor = world.GetActor(handle);
    if actor ~= nil then
        local buffDoubleGunStance = actor:GetBuff():GetBuff('DoubleGunStance_Buff');
        if buffDoubleGunStance ~= nil then
            actor:DetachCopiedModel();
            actor:ChangeEquipNode(EmAttach.eRHand, "Dummy_L_HAND");
            
            actor:ChangeEquipNode(EmAttach.eRHand, "Dummy_Sword");
            actor:CopyAttachedModel(EmAttach.eLHand, "Dummy_L_HAND");
        end
    end
end

function WING_GUILTY_FAIRY_BUFF_ENTER(actor, obj, buff)
end

function WING_GUILTY_FAIRY_BUFF_UPDATE(actor, obj, buff)
	SCR_CREATE_FAIRY(actor:GetHandleVal(), "guilty");
end

function WING_GUILTY_FAIRY_BUFF_LEAVE(actor, obj, buff)
	SCR_REMOVE_FAIRY(actor:GetHandleVal(), "guilty");
end

function GET_BUFF_BY_NAME_C(buffName)
    local buffCls = GetClass('Buff', buffName);
    if buffCls == nil then
        return nil;
    end
    local handle = session.GetMyHandle();
    return info.GetBuff(handle, buffCls.ClassID);
end

-- doll_tiny
function DOLL_TINY_BUFF_ENTER(actor, obj, buff)
end

function DOLL_TINY_BUFF_UPDATE(actor, obj, buff)
	SCR_CREATE_FAIRY(actor:GetHandleVal(), "doll_tiny");
end

function DOLL_TINY_BUFF_LEAVE(actor, obj, buff)
	SCR_REMOVE_FAIRY(actor:GetHandleVal(), "doll_tiny");
end

-- doll_lucy
function DOLL_LUCY_BUFF_ENTER(actor, obj, buff)
end

function DOLL_LUCY_BUFF_UPDATE(actor, obj, buff)
	SCR_CREATE_FAIRY(actor:GetHandleVal(), "doll_lucy");
end

function DOLL_LUCY_BUFF_LEAVE(actor, obj, buff)
	SCR_REMOVE_FAIRY(actor:GetHandleVal(), "doll_lucy");
end

-- 2019Halloween_effect / moon effect
function HalloweenMoon_effect_ENTER(actor, obj, buff)
    actor:GetBuff():SetUse2DEffect(false);
end

function HalloweenMoon_effect_LEAVE(actor, obj, buff)
end

-- doll_gabia
function DOLL_GABIA_BUFF_ENTER(actor, obj, buff)
end

function DOLL_GABIA_BUFF_UPDATE(actor, obj, buff)
	SCR_CREATE_FAIRY(actor:GetHandleVal(), "doll_gabia");
end

function DOLL_GABIA_BUFF_LEAVE(actor, obj, buff)
	SCR_REMOVE_FAIRY(actor:GetHandleVal(), "doll_gabia");
end

function DOLL_HAUBERK_BUFF_ENTER(actor, obj, buff)
end

function DOLL_HAUBERK_BUFF_UPDATE(actor, obj, buff)
	SCR_CREATE_FAIRY(actor:GetHandleVal(), "doll_hauberk");
end

function DOLL_HAUBERK_BUFF_LEAVE(actor, obj, buff)
	SCR_REMOVE_FAIRY(actor:GetHandleVal(), "doll_hauberk");
end

function DOLL_VAKARINE_BUFF_ENTER(actor, obj, buff)
end

function DOLL_VAKARINE_BUFF_UPDATE(actor, obj, buff)
	SCR_CREATE_FAIRY(actor:GetHandleVal(), "doll_vakarine");
end

function DOLL_VAKARINE_BUFF_LEAVE(actor, obj, buff)
	SCR_REMOVE_FAIRY(actor:GetHandleVal(), "doll_vakarine");
end

-- santa guilty
function DOLL_SANTA_GUILTY_BUFF_ENTER(actor, obj, buff)
end

function DOLL_SANTA_GUILTY_BUFF_UPDATE(actor, obj, buff)
	SCR_CREATE_FAIRY(actor:GetHandleVal(), "doll_santa_guilty");
end

function DOLL_SANTA_GUILTY_BUFF_LEAVE(actor, obj, buff)
	SCR_REMOVE_FAIRY(actor:GetHandleVal(), "doll_santa_guilty");
end

-- doll_succubus
function DOLL_SUCCUBUS_BUFF_ENTER(actor, obj, buff)
end

function DOLL_SUCCUBUS_BUFF_UPDATE(actor, obj, buff)
	SCR_CREATE_FAIRY(actor:GetHandleVal(), "doll_succubus");
end

function DOLL_SUCCUBUS_BUFF_LEAVE(actor, obj, buff)
	SCR_REMOVE_FAIRY(actor:GetHandleVal(), "doll_succubus");
end

-- doll_paulius
function DOLL_PAULIUS_BUFF_ENTER(actor, obj, buff)
end

function DOLL_PAULIUS_BUFF_UPDATE(actor, obj, buff)
	SCR_CREATE_FAIRY(actor:GetHandleVal(), "doll_paulius");
end

function DOLL_PAULIUS_BUFF_LEAVE(actor, obj, buff)
	SCR_REMOVE_FAIRY(actor:GetHandleVal(), "doll_paulius");
end

-- furry guilty
function DOLL_FURRY_GUILTY_BUFF_ENTER(actor, obj, buff)
end

function DOLL_FURRY_GUILTY_BUFF_UPDATE(actor, obj, buff)
	SCR_CREATE_FAIRY(actor:GetHandleVal(), "doll_furry_guilty");
end

function DOLL_FURRY_GUILTY_BUFF_LEAVE(actor, obj, buff)
	SCR_REMOVE_FAIRY(actor:GetHandleVal(), "doll_furry_guilty");
end

-- jellyzele
function DOLL_JELLYZELE_BUFF_ENTER(actor, obj, buff)
end

function DOLL_JELLYZELE_BUFF_UPDATE(actor, obj, buff)
	SCR_CREATE_FAIRY(actor:GetHandleVal(), "doll_jellyzele");
end

function DOLL_JELLYZELE_BUFF_LEAVE(actor, obj, buff)
	SCR_REMOVE_FAIRY(actor:GetHandleVal(), "doll_jellyzele");
end

-- little_gaicier
function DOLL_LITTLE_GLAICIER_BUFF_ENTER(actor, obj, buff)
end

function DOLL_LITTLE_GLAICIER_BUFF_UPDATE(actor, obj, buff)
	SCR_CREATE_FAIRY(actor:GetHandleVal(), "doll_little_glacier");
end

function DOLL_LITTLE_GLAICIER_BUFF_LEAVE(actor, obj, buff)
	SCR_REMOVE_FAIRY(actor:GetHandleVal(), "doll_little_glacier");
end

-- boruta
function BORUTA_BUFF_ENTER(actor, obj, buff)
end

function BORUTA_BUFF_UPDATE(actor, obj, buff)
	SCR_CREATE_FAIRY(actor:GetHandleVal(), "doll_boruta");
end

function BORUTA_BUFF_LEAVE(actor, obj, buff)
	SCR_REMOVE_FAIRY(actor:GetHandleVal(), "doll_boruta");
end

function XMAS_EFFECT_2019_ENTER(actor, obj, buff)
    effect.AddActorEffectByOffset(actor, "E_effectitem_whitebird", 0.4, "BOT", false, true);
end

function XMAS_EFFECT_2019_LEAVE(actor, obj, buff)
    effect.DetachActorEffect(actor, "E_effectitem_whitebird", 0.0);
end

function WEEKLY_MIRTIS_EFFECT_ENTER(actor, obj, buff)
    effect.AddActorEffectByOffset(actor, "E_effectitem_mirtis", 1, "BOT", false, true);
end

function WEEKLY_MIRTIS_EFFECT_LEAVE(actor, obj, buff)
    effect.DetachActorEffect(actor, "E_effectitem_mirtis", 0.0);
end

function WEEKLY_WARPULIS_EFFECT_ENTER(actor, obj, buff)
    effect.AddActorEffectByOffset(actor, "E_effect_item_warpulis", 0.8, "BOT", false, true);
end

function WEEKLY_WARPULIS_EFFECT_LEAVE(actor, obj, buff)
    effect.DetachActorEffect(actor, "E_effect_item_warpulis", 0.0);
end

function HiphopEffect_pre_ENTER(actor, obj, buff)
end

function HiphopEffect_pre_LEAVE(actor, obj, buff)
    effect.DetachActorEffect(actor, "E_pc_effectitem_hiphop", 0);
end

function ITEM_EFFECT_LITTLEPRINCE_ENTER(actor, obj, buff)
    effect.AddActorEffectByOffset(actor, "E_effectitem_littleprince", 0.4, "MID", false, true)
end

function ITEM_EFFECT_LITTLEPRINCE_LEAVE(actor, obj, buff)
    effect.DetachActorEffect(actor, "E_effectitem_littleprince", 0)
end

function Bunsin_Mijinhide_Buff_CLIENT_ENTER(actor, obj, buff)
    local value = actor:GetEffect():SetColorBlend("Bunsin_Mijinhide_Buff", 0, 0, 0, 0, true, 0, false, 0);
end

function Bunsin_Mijinhide_Buff_CLIENT_LEAVE(actor, obj, buff)
    actor:GetEffect():SetColorBlend("Bunsin_Mijinhide_Buff", 255, 255, 255, 255, false, 0)
end

function EP12TACTICAL_EFFECT02_PRE_ENTER(actor, obj, buff)
    effect.AddActorEffectByOffset(actor, "I_policeline001_mesh", 1, "Middle", true, true);
    actor:SetEquipItemFlagProp("EFFECTCOSTUME", 1);
end

function EP12TACTICAL_EFFECT02_PRE_LEAVE(actor, obj, buff)
    effect.DetachActorEffect(actor, "I_policeline001_mesh", 0);
    actor:SetEquipItemFlagProp("EFFECTCOSTUME", 0);
end

-- Friedenslied_Debuff
function FRIEDENSLIED_DANCE_ENTER(actor, obj, buff)
    if actor:GetVehicleActor() ~= nil then
        actor:GetAnimation():SetSTDAnim("FRIEDENSLIED_DANCE_RIDE");
    else
        actor:GetAnimation():SetSTDAnim("FRIEDENSLIED_DANCE");
    end
    actor:SetAlwaysBattleState(true);
end

function FRIEDENSLIED_DANCE_LEAVE(actor, obj, buff)
    actor:GetAnimation():ResetSTDAnim();
    actor:SetAlwaysBattleState(false);
end

-- Friedenslied_AbilDance_Debuff
function FRIEDENSLIED_ABILDANCE_ENTER(actor, obj, buff)
    if actor:GetVehicleActor() ~= nil then
        actor:GetAnimation():SetSTDAnim("FRIEDENSLIED_DANCE_ABIL_RIDE");
    else
        actor:GetAnimation():SetSTDAnim("FRIEDENSLIED_DANCE_ABIL");
    end
    actor:SetAlwaysBattleState(true);
end

function FRIEDENSLIED_ABILDANCE_LEAVE(actor, obj, buff)
    actor:GetAnimation():ResetSTDAnim();
    actor:SetAlwaysBattleState(false);
end
-- 끼룩끼룩 갈매기 떼
function ITEM_EP12FLYINGSEAGULL_EFFECT_PRE_ENTER(actor, obj, buff)
    effect.AddActorEffectByOffset(actor, "I_pc_effectitem_flyingseagull", 1.35, "BOT", true, true);
    actor:SetEquipItemFlagProp("EFFECTCOSTUME", 1);
end

function ITEM_EP12FLYINGSEAGULL_EFFECT_PRE_LEAVE(actor, obj, buff)
    effect.DetachActorEffect(actor, "I_pc_effectitem_flyingseagull", 0);
    actor:SetEquipItemFlagProp("EFFECTCOSTUME", 0);
end

-- 주변을 맴도는 상어 떼
function ITEM_EP12TWINSHARK_EFFECT_PRE_ENTER(actor, obj, buff)
    effect.AddActorEffectByOffset(actor, "E_effect_twinshark", 1.35, "BOT", true, true);
    actor:SetEquipItemFlagProp("EFFECTCOSTUME", 1);
end

function ITEM_EP12TWINSHARK_EFFECT_PRE_LEAVE(actor, obj, buff)
    effect.DetachActorEffect(actor, "E_effect_twinshark", 0);
    actor:SetEquipItemFlagProp("EFFECTCOSTUME", 0);
end

function StereaTrofhClientScp_ENTER(actor, obj, buff)
    local actorPos = actor:GetPos();
    effect.AddActorEffect(actor, "F_cleric_StereaTrofh_buff", 2.5, actorPos.x, actorPos.y + 55, actorPos.z, -1)
end

function StereaTrofhClientScp_LEAVE(actor, obj, buff)
    effect.DetachActorEffect(actor, "F_cleric_StereaTrofh_buff", 0.0);
end

function EP12DEMONLORD_EFFECT_PRE_ENTER(actor, obj, buff)
    actor:SetEquipItemFlagProp("EFFECTCOSTUME", 1);
end

function EP12DEMONLORD_EFFECT_PRE_LEAVE(actor, obj, buff)
    effect.DetachActorEffect(actor, "I_spread_out015_light_orange", 0.7);
    actor:SetEquipItemFlagProp("EFFECTCOSTUME", 0);
end

function EP12DEMONLORD_VIOLET_EFFECT_PRE_ENTER(actor, obj, buff)
    actor:SetEquipItemFlagProp("EFFECTCOSTUME", 1);
end

function EP12DEMONLORD_VIOLET_EFFECT_PRE_LEAVE(actor, obj, buff)
    effect.DetachActorEffect(actor, "I_spread_out015_light_blue_violet", 0.7);
    actor:SetEquipItemFlagProp("EFFECTCOSTUME", 0);
end

function DesperateDefenseClientScp_ENTER(actor, obj, buff)
    if pc.IsBuffApplied(actor, "SnipersSerenity_Buff") == 1 then
        actor:GetAnimation():ResetWLKAnim();
        actor:GetAnimation():ResetRUNAnim();
    end
end

function DesperateDefenseClientScp_LEAVE(actor, obj, buff)
    if pc.IsBuffApplied(actor, "SnipersSerenity_Buff") == 1 then
        actor:GetAnimation():SetWLKAnim("SKL_SNIPERSSERENITY_AWLK");
        actor:GetAnimation():SetRUNAnim("SKL_SNIPERSSERENITY_AWLK");
    end
end

function EP13STEM_EFFECT_2106_ENTER(actor, obj, buff)
    effect.AddActorEffectByOffset(actor, "E_effect_ep13stem", 1.2, "MID", false, true);
end

function EP13STEM_EFFECT_2106_LEAVE(actor, obj, buff)
    effect.DetachActorEffect(actor, "E_effect_ep13stem", 0.0);
end

function VASILISSA_BORN_CLIENT_ENTER(actor, obj, buff)
    actor:GetAnimation():SetSTDAnim("std_spear");
    actor:GetAnimation():SetRUNAnim("run_spear");
    actor:GetAnimation():SetWLKAnim("wlk_spear");
    -- actor:GetAnimation():SetDEADAnim("dead_spear");
end

function VASILISSA_BORN_CLIENT_LEAVE(actor, obj, buff)
    actor:GetAnimation():ResetWLKAnim();
    actor:GetAnimation():ResetRUNAnim();
    actor:GetAnimation():ResetSTDAnim();
end

-- 바실리사 창 스탠스 전환 --
-- stun -> stun_spear
function Vasilissa_SpearStance_ENTER(actor, obj, buff)
    local buffSpearStance = actor:GetBuff():GetBuff("VASILISSA_SPEARSTANCE_BUFF");
    if buffSpearStance ~= nil then
        actor:GetAnimation():SetSTDAnim("std_spear", "astd_spear");
        actor:GetAnimation():SetWLKAnim("wlk_spear");
        actor:GetAnimation():SetRUNAnim("run_spear");
    end
end

function Vasilissa_SpearStance_LEAVE(actor, obj, buff)
    actor:GetAnimation():ResetSTDAnim();
    actor:GetAnimation():ResetWLKAnim();
    actor:GetAnimation():ResetRUNAnim();
end

function ScpChangeVasilissaStanceAnimationSet(actor, obj, buff)
    local buffSpearStance = actor:GetBuff():GetBuff("VASILISSA_SPEARSTANCE_BUFF");
    if buffSpearStance ~= nil then
        actor:GetAnimation():SetSTDAnim("std_spear", "astd_spear");
        actor:GetAnimation():SetWLKAnim("wlk_spear");
        actor:GetAnimation():SetRUNAnim("run_spear");
    end
end

-- 바실리사 창 스텐스 특정 애니메이션 설정
function SCR_BUFF_ANIM_CONVERT_boss_Vasilissa(actor, buff_anim)
    if buff_anim ~= nil and buff_anim ~= "None" then
        if buff_anim == "STUN" then
            local stance_buff = actor:GetBuff():GetBuff("VASILISSA_SPEARSTANCE_BUFF");
            if stance_buff ~= nil then
                local convert_anim = buff_anim.."_SPEAR";
                return convert_anim;
            end
        end
    end
    return buff_anim;
end

function SCR_BUFF_ANIM_CONVERT_boss_Vasilissa_Auto(actor, buff_anim)
    if buff_anim ~= nil and buff_anim ~= "None" then
        if buff_anim == "STUN" then
            local stance_buff = actor:GetBuff():GetBuff("VASILISSA_SPEARSTANCE_BUFF");
            if stance_buff ~= nil then
                local convert_anim = buff_anim.."_SPEAR";
                return convert_anim;
            end
        end
    end
    return buff_anim;
end

-- 바실리사 소환수 석화 버프 --
-- HitEffect 보이지 않도록 처리.
function Vasilissa_Petrify_Mon_ENTER(actor, obj, buff)
    actor:GetEffect():OffShowDamageByBuff();
end

function Vasilissa_Petrify_Mon_LEAVE(actor, obj, buff)
    actor:GetEffect():OnShowDamageByBuff();
end

function EP13STEM_EFFECT_2106_ENTER(actor, obj, buff)
    effect.AddActorEffectByOffset(actor, "E_effect_ep13stem", 1.2, "MID", false, true);
    actor:SetEquipItemFlagProp("EFFECTCOSTUME", 1);
end

function EP13STEM_EFFECT_2106_LEAVE(actor, obj, buff)
    effect.DetachActorEffect(actor, "E_effect_ep13stem", 0.0);
    actor:SetEquipItemFlagProp("EFFECTCOSTUME", 0);
end

-- 둥실 둥실 오리 가족
function EFFECT_EP13RAINCOAT_BUFF_ENTER(actor, obj, buff)
end

function EFFECT_EP13RAINCOAT_BUFF_UPDATE(actor, obj, buff)
    SCR_CREATE_FAIRY_GROUND(actor:GetHandleVal(), "effect_ep13raincoat");
end

function EFFECT_EP13RAINCOAT_BUFF_LEAVE(actor, obj, buff)
	SCR_REMOVE_FAIRY_GROUND(actor:GetHandleVal(), "effect_ep13raincoat");
end

function DragonoidClientScp_ENTER(actor, obj, buff)
    actor:SetAuraInfo("Dragonoid_Color");
end

function DragonoidClientScp_LEAVE(actor, obj, buff)
    actor:SetAuraInfo("None");
end

function TOSHero_Buff_Overwhelm_ClientScp_ENTER(actor, obj, buff)
    print(actor, obj, buff)
    actor:GetEffect():ActorColorBlend(0, 0, 0, 0, 1, 1);
end

function EP13RETRO_EFFECT_ENTER(actor, obj, buff)
    effect.AddActorEffectByOffset(actor, "I_Effect_ep13retro_mesh", 1, "Dummy_emitter", true, true);
    effect.AddActorEffectByOffset(actor, "F_light195_loop", 1, "Dummy_emitter", true, true);
    effect.AddActorEffectByOffset(actor, "F_light196_loop", 1, "Dummy_emitter", true, true);
    actor:SetEquipItemFlagProp("EFFECTCOSTUME", 1);
end

function EP13RETRO_EFFECT_LEAVE(actor, obj, buff)
    effect.DetachActorEffect(actor, "I_Effect_ep13retro_mesh", 0.2);
    effect.DetachActorEffect(actor, "F_light195_loop", 0.2);
    effect.DetachActorEffect(actor, "F_light196_loop", 0.2);
    actor:SetEquipItemFlagProp("EFFECTCOSTUME", 0);
end

function Luchador_ChangeStance_ENTER(actor, obj, buff)
    actor:SetAlwaysBattleState(true);
    actor:GetAnimation():SetSTDAnim("SKL_LUCHADOR_ASTD");
    actor:GetAnimation():SetTURNAnim("SKL_LUCHADOR_ASTD");
    actor:GetAnimation():SetChangeJumpAnim(true);
    actor:GetAnimation():SetRAISEAnim("SKL_NAKMUAY_RAISE");
    actor:GetAnimation():SetOnAIRAnim("SKL_NAKMUAY_ONAIR");
    actor:GetAnimation():SetFALLAnim("SKL_NAKMUAY_FALL");

    local abil = session.GetAbilityByName("Luchador18");
    if abil ~= nil then
        local abilObj = GetIES(abil:GetObject());
        if abilObj.ActiveState == 1 then
            actor:GetAnimation():SetRUNAnim("DASH_RUN");
        end
    end
end

function Luchador_ChangeStance_LEAVE(actor, obj, buff)
    actor:SetAlwaysBattleState(false);
    actor:GetAnimation():ResetSTDAnim();
    actor:GetAnimation():ResetRUNAnim();
    actor:GetAnimation():ResetTURNAnim();
    actor:GetAnimation():SetChangeJumpAnim(false);

    ScpChangeSwordmanStanceAnimationSet(actor, obj, buff)
end

function GolpearClientScp_ENTER(actor, obj, buff)
    actor:GetAnimation():SetRUNAnim("SKL_LUCHADOR_GOLPEAR");
    actor:GetAnimation():SetWLKAnim("SKL_LUCHADOR_GOLPEAR");
    actor:GetAnimation():SetSTDAnim("SKL_LUCHADOR_GOLPEAR_STAND"); 

    actor:SetAlwaysBattleState(true);
end

function GolpearClientScp_LEAVE(actor, obj, buff)
    actor:GetAnimation():ResetRUNAnim();
    actor:GetAnimation():ResetWLKAnim();
    actor:GetAnimation():ResetSTDAnim();
    ScpChangeSwordmanStanceAnimationSet(actor, obj, buff)
    actor:SetAlwaysBattleState(false);
end

function LuchadorComboClientScp_ENTER(actor, obj, buff)
    actor:SetAuraInfo("EliteBuff");
end

function LuchadorComboClientScp_LEAVE(actor, obj, buff)
    actor:SetAuraInfo("None");
end

function PyeonJeonClientScp_ENTER(actor, obj, buff)
    actor:GetAnimation():SetSTDAnim("skl_PyeonJeon_loop");
    actor:GetAnimation():SetRUNAnim("skl_PyeonJeon_move");
    actor:GetAnimation():SetWLKAnim("skl_PyeonJeon_move");
    actor:GetAnimation():SetTURNAnim("None");
    actor:SetAlwaysBattleState(true);
end

function PyeonJeonClientScp_LEAVE(actor, obj, buff)
    actor:GetAnimation():ResetSTDAnim();
    actor:GetAnimation():ResetRUNAnim();
    actor:GetAnimation():ResetWLKAnim();
    actor:GetAnimation():ResetTURNAnim();
    actor:SetAlwaysBattleState(false);
end

function BowMaster_FocusFire_Buff_ENTER(actor, obj, buff)
    actor:GetAnimation():SetSTDAnim("skl_PyeonJeon_loop");
    actor:GetAnimation():SetRUNAnim("skl_PyeonJeon_move");
    actor:GetAnimation():SetWLKAnim("skl_PyeonJeon_move");
    actor:GetAnimation():SetTURNAnim("None");
    actor:SetAlwaysBattleState(true);    
    actor:GetEffect():ActorColorBlend(1, 163/255, 73/255, 164/255, 1, 0);        
end

function BowMaster_FocusFire_Buff_LEAVE(actor, obj, buff)
    actor:GetAnimation():ResetSTDAnim();
    actor:GetAnimation():ResetRUNAnim();
    actor:GetAnimation():ResetWLKAnim();
    actor:GetAnimation():ResetTURNAnim();
    actor:SetAlwaysBattleState(false);
    actor:GetEffect():ActorColorBlend(1, 1, 1, 1, 1, 0);
end



function DOLL_LAIMA_BUFF_ENTER(actor, obj, buff)
end

function DOLL_LAIMA_BUFF_UPDATE(actor, obj, buff)
	SCR_CREATE_FAIRY(actor:GetHandleVal(), "doll_laima");
end

function DOLL_LAIMA_BUFF_LEAVE(actor, obj, buff)
	SCR_REMOVE_FAIRY(actor:GetHandleVal(), "doll_laima");
end

function DOLL_MEDEINA_BUFF_ENTER(actor, obj, buff)
end

function DOLL_MEDEINA_BUFF_UPDATE(actor, obj, buff)
	SCR_CREATE_FAIRY(actor:GetHandleVal(), "doll_medeina");
end

function DOLL_MEDEINA_BUFF_LEAVE(actor, obj, buff)
	SCR_REMOVE_FAIRY(actor:GetHandleVal(), "doll_medeina");
end

function DOLL_ZEMINA_BUFF_ENTER(actor, obj, buff)
end

function DOLL_ZEMINA_BUFF_UPDATE(actor, obj, buff)
	SCR_CREATE_FAIRY(actor:GetHandleVal(), "doll_zemina");
end

function DOLL_ZEMINA_BUFF_LEAVE(actor, obj, buff)
	SCR_REMOVE_FAIRY(actor:GetHandleVal(), "doll_zemina");
end

function DOLL_ZANAS_BUFF_ENTER(actor, obj, buff)
end

function DOLL_ZANAS_BUFF_UPDATE(actor, obj, buff)
	SCR_CREATE_FAIRY(actor:GetHandleVal(), "doll_zanas");
end

function DOLL_ZANAS_BUFF_LEAVE(actor, obj, buff)
	SCR_REMOVE_FAIRY(actor:GetHandleVal(), "doll_zanas");
end


function OOBE_Possession_Buff_LEAVE(actor, obj, buff)
    -- actor:GetAnimation():ResetAnim();
    -- actor:GetAnimation():PlayFixAnim('SKL_OOBE_READY', 1.8, 0);
    local maleVoice = "voice_cleric_m_possession_shot"
    local femaleVoice = "voice_cleric_f_possession_shot"
    C_VOICE_SOUND(actor, obj, maleVoice, femaleVoice)
end

function OOBE_Prakriti_Buff_ENTER(actor, obj, buff)

end

function OOBE_Prakriti_Buff_LEAVE(actor, obj, buff)
    -- actor:GetAnimation():ResetAnim();
    -- actor:GetAnimation():PlayFixAnim('SKL_OOBE_READY', 1.8, 0);
    local maleVoice = "voice_cleric_m_prakriti_shot"
    local femaleVoice = "voice_cleric_f_prakriti_shot"
    C_VOICE_SOUND(actor, obj, maleVoice, femaleVoice)
end

function OOBE_Anila_Buff_ENTER(actor, obj, buff)

end

function OOBE_Anila_Buff_LEAVE(actor, obj, buff)
    -- actor:GetAnimation():ResetAnim();
    -- actor:GetAnimation():PlayFixAnim('SKL_OOBE_READY', 1.8, 0);
    local maleVoice = "voice_cleric_m_anila_shot"
    local femaleVoice = "voice_cleric_f_anila_shot"
    C_VOICE_SOUND(actor, obj, maleVoice, femaleVoice)
end

function OOBE_Tanoti_Buff_ENTER(actor, obj, buff)

end

function OOBE_Tanoti_Buff_LEAVE(actor, obj, buff)
    -- actor:GetAnimation():ResetAnim();
    -- actor:GetAnimation():PlayFixAnim('SKL_OOBE_READY', 1.8, 0);
    local maleVoice = "voice_cleric_m_tanoti_shot"
    local femaleVoice = "voice_cleric_f_tanoti_shot"
    C_VOICE_SOUND(actor, obj, maleVoice, femaleVoice)
end

function OOBE_Patati_Buff_ENTER(actor, obj, buff)

end

function OOBE_Patati_Buff_LEAVE(actor, obj, buff)
    -- actor:GetAnimation():ResetAnim();
    -- actor:GetAnimation():PlayFixAnim('SKL_OOBE_READY', 1.8, 0);
    local maleVoice = "voice_cleric_m_patati_shot"
    local femaleVoice = "voice_cleric_f_patati_shot"
    C_VOICE_SOUND(actor, obj, maleVoice, femaleVoice)
end

function OOBE_Moksha_Buff_ENTER(actor, obj, buff)

end

function OOBE_Moksha_Buff_LEAVE(actor, obj, buff)
    -- actor:GetAnimation():ResetAnim();
    -- actor:GetAnimation():PlayFixAnim('SKL_OOBE_READY', 1.8, 0);
    local maleVoice = "voice_cleric_m_moksha_shot"
    local femaleVoice = "voice_cleric_f_moksha_shot"
    C_VOICE_SOUND(actor, obj, maleVoice, femaleVoice)
end

function CatenaChainArrow_ENTER(actor, obj, buff)
    local caster = buff:GetHandle();
    hardSkill.LinkToObject(actor, caster, "Linker_blue", "Bip01 Spine2", "Dummy_emitter");
end

function CatenaChainArrow_LEAVE(actor, obj, buff)
    local caster = buff:GetHandle();
    hardSkill.LinkToObject(nil, caster, "Linker_blue", "Bip01 Spine2", "Dummy_emitter");
    local myactor = world.GetActor(caster);

    effect.DetachActorEffect(myactor, "I_emo_bound", 0.0);
end

function CatenaChainArrow_UPDATE(actor, obj, buff)
    local handle = actor:GetHandleVal();
    local dist = info.GetDistance(handle);
    local caster = buff:GetHandle();
    local myactor = world.GetActor(caster);

    if dist >= 250 and myactor:GetUserIValue("CatenaChainArrow_UPDATE") == 0 then
        local actorPos = myactor:GetPos();
        effect.AddActorEffect(myactor, "I_emo_bound", 3.3, actorPos.x, actorPos.y + 45, actorPos.z, -1)
        myactor:SetUserValue('CatenaChainArrow_UPDATE', 1)
    elseif dist <= 250 and myactor:GetUserIValue("CatenaChainArrow_UPDATE") == 1 then
        effect.DetachActorEffect(myactor, "I_emo_bound", 0.0);
        myactor:SetUserValue("CatenaChainArrow_UPDATE", 0)
    end
end


function DoNotRetreat_Arts_UPDATE(actor, obj, buff)
    local pc = GetMyPCObject()
    local my_angle = fsmactor.GetAngle(actor)
    local caster_angle = GetExProp(pc, 'DoNotRetreat_CASTER_ANGLE')

    local calc_angle = my_angle - caster_angle
    calc_angle = math.floor(calc_angle)

    local angle = 60
    local revAngle = angle * -1
    local relativeAngle = math.floor(calc_angle)

    if (angle/2 >= relativeAngle and 0 <= relativeAngle) or (revAngle/2 <= relativeAngle and 0 >= relativeAngle) then
        if actor:GetUserIValue("DoNotRetreat_UPDATE") == 0 then
            local actorPos = actor:GetPos();
            actor:SetUserValue('DoNotRetreat_UPDATE', 1)
            actor:GetEffect():SetColorBlink(0,0,0,0,0,0,0.5,0, 2, 1);
        end
    else
        actor:SetUserValue('DoNotRetreat_UPDATE', 0)
        actor:GetEffect():SetColorBlink(0,0,0,0,0,0,0,0, 0 , 1);
    end

end

function DoNotRetreat_Arts_LEAVE(actor, obj, buff)
    actor:SetUserValue('DoNotRetreat_UPDATE', 0)
    actor:GetEffect():SetColorBlink(0,0,0,0,0,0,0,0, 0 , 1);
end

---- EarringRaid PartyLeaderSkill Buff
function PartyLeaderBuff_NoDamage_ENTER(actor, obj, buff)
    actor:SetAuraInfo("Champion_Buff");
end

function PartyLeaderBuff_NoDamage_LEAVE(actor, obj, buff)
    actor:SetAuraInfo("");
end

function PartyLeaderBuff_CoolDown_ENTER(actor, obj, buff)
    actor:SetAuraInfo("Dragonoid_Color");
end

function PartyLeaderBuff_CoolDown_LEAVE(actor, obj, buff)
    actor:SetAuraInfo("");
end

function PartyLeaderBuff_DamageUp_ENTER(actor, obj, buff)
    actor:SetAuraInfo("Mythic_Link");
end

function PartyLeaderBuff_DamageUp_LEAVE(actor, obj, buff)
    actor:SetAuraInfo("");
end

---- DelmoreCatleGate Raid
function Gresme_Raven_FlyBuff_ENTER(actor, obj, buff)
    if actor ~= nil then
        actor:SetAuraInfo("EliteBuff");
        actor:GetAnimation():SetSTDAnim("raid_flying");
        actor:GetAnimation():SetWLKAnim("raid_flying");
        actor:GetAnimation():SetRUNAnim("raid_flying");
    end
end

function Gresme_Raven_FlyBuff_LEAVE(actor, obj, buff)
    if actor ~= nil then
        actor:SetAuraInfo("");
        actor:GetAnimation():ResetSTDAnim();
        actor:GetAnimation():ResetWLKAnim();
        actor:GetAnimation():ResetRUNAnim();
    end
end

function DelmoreCastleGate_colorblend_clear_ENTER(actor, obj, buff)
    if actor ~= nil then
        C_COLORBLEND_ACTOR(actor, obj, 1, 0, 0, 0, 0, 0, 1)
    end
end
function DelmoreCastleGate_colorblend_clear_LEAVE(actor, obj, buff)
    if actor ~= nil then
        C_COLORBLEND_ACTOR(actor, obj, 1, 0, 0, 0, 0, 0, 1)
    end
end

-- EarringRaid Party Buff 여신의 전언 파티 버프 스킬-- 
function PartyLeaderBuff_NoDamage_ENTER(actor, obj, buff)
    imcSound.PlaySoundEvent("monster_state_1")
    actor:GetEffect():SetColorBlink(0,0,0.1,0,0,0.1,0.4,0, 1.5, 1);
    actor:SetAuraInfo("PartyLeaderBuff_NoDamage");
    actor:GetTitle():UpdateCaption();
end

function PartyLeaderBuff_NoDamage_LEAVE(actor, obj, buff)
    actor:SetAuraInfo("");
    actor:GetTitle():UpdateCaption();
    actor:GetEffect():SetColorBlink(0,0,0,0,1,0,0,1, 0 , 1);
end

function PartyLeaderBuff_CoolDown_ENTER(actor, obj, buff)
    imcSound.PlaySoundEvent("monster_state_1")
    actor:GetEffect():SetColorBlink(0.2,0.17,0.05,0,0.5,0.4,0.15,0, 1.5, 1);
    actor:SetAuraInfo("PartyLeaderBuff_CoolDown");
    actor:GetTitle():UpdateCaption();
end

function PartyLeaderBuff_CoolDown_LEAVE(actor, obj, buff)
    actor:SetAuraInfo("");
    actor:GetTitle():UpdateCaption();
    actor:GetEffect():SetColorBlink(0,0,0,0,1,0,0,1, 0 , 1);
end

function PartyLeaderBuff_DamageUp_ENTER(actor, obj, buff)
    imcSound.PlaySoundEvent("monster_state_1")
    actor:GetEffect():SetColorBlink(0.2,0,0,0,0.45,0.05,0,0, 1.5, 1);
    actor:SetAuraInfo("PartyLeaderBuff_DamageUp");
    actor:GetTitle():UpdateCaption();
end

function PartyLeaderBuff_DamageUp_LEAVE(actor, obj, buff)
    actor:SetAuraInfo("");
    actor:GetTitle():UpdateCaption();
    actor:GetEffect():SetColorBlink(0,0,0,0,1,0,0,1, 0 , 1);
end

function Hakkapeliter_Assault_ClientScp_ENTER(actor, obj, buff)
    ScpChangeMovingShotAnimationSet(actor, obj, buff);

    actor:SetAlwaysBattleState(true);
end

function Hakkapeliter_Assault_ClientScp_LEAVE(actor, obj, buff)
    actor:GetAnimation():ResetSTDAnim();
    actor:GetAnimation():ResetRUNAnim();
    actor:GetAnimation():ResetWLKAnim();
    actor:GetAnimation():ResetTURNAnim();
    actor:SetAlwaysBattleState(false);
    actor:GetAnimation():PlayFixAnim("ASTD", 1, 1);
    ScpChangeMovingShotAnimationSet(actor, obj, buff);
end

function Lamapose_Buff_ENTER(actor, obj, buff)
    actor:ShowModelByPart("LH", 0, 0, "Lamapose_Buff")
    actor:ShowModelByPart("RH", 0, 0, "Lamapose_Buff")
end

function Lamapose_Buff_LEAVE(actor, obj, buff)
    actor:ShowModelByPart("LH", 1, 0, "Lamapose_Buff")
    actor:ShowModelByPart("RH", 1, 0, "Lamapose_Buff")
end

-- 챌린지 모드 엘리트 보스
function EliteBossBuff_ENTER(actor, obj, buff)
    actor:SetAuraInfo("Elite_Boss_Buff");
end

function EliteBossBuff_LEAVE(actor, obj, buff)
    actor:SetAuraInfo("");
end

function JaguarStance_ENTER(actor, obj, buff)
    actor:ShowModelByPart("RH", 0, 0, "JaguarStance_Buff")
    actor:ShowModelByPart("LH", 0, 0, "JaguarStance_Buff")

    local abilJaguar22 = info.GetBuffByName(actor:GetHandleVal(), 'Jaguar22_Hidden_Buff')
    if abilJaguar22 == nil then
        actor:SetAuraInfo("Dragonoid_Color")
    end

    actor:SetAlwaysBattleState(true)
    actor:GetAnimation():SetSTDAnim("SKL_JAGUAR_ASTD")
end

function JaguarStance_LEAVE(actor, obj, buff)
    actor:ShowModelByPart("RH", 1, 0, "JaguarStance_Buff")
    actor:ShowModelByPart("LH", 1, 0, "JaguarStance_Buff")

    actor:SetAuraInfo("None")

    actor:GetAnimation():ResetSTDAnim()
    actor:SetAlwaysBattleState(false)
end

function BW_MINEHELL_BOMB_COLOR(data)
    local actor = world.GetActor(tonumber(data));
    if actor ~= nil then
        actor:SetAuraInfo("EliteBuff");
    end
end

function BW_MINEHELL_POSION_COLOR(data)
    local actor = world.GetActor(tonumber(data));
    if actor ~= nil then
        actor:SetAuraInfo("Elite_Boss_Buff");
    end
end

-- 이펙트 코스튬 및 costume_buff_effect.xml 에 존재하는 이펙트 offset 조정 함수
function SCR_COSTUME_BUFF_EFFECT_OFFSET(effect_name, x, y, z)
    if effect_name ~= nil then
        if effect_name == "F_pc_effectitem_12animal" then
            return 8.0, -4.0, -8.0;
        elseif effect_name == "F_pc_ep15snowknight02" then
            return 8.0, 0.0, -8.0;
        elseif effect_name == "F_pc_item_wing_unicorn_heart_loop" then
            return -3.0, -18.0, 3.0;
        elseif effect_name == "F_pc_effectitem_moon" then
            return 8.0, 23.0, -8.0;
        elseif effect_name == "F_pc_effectitem_police_light_loop" then
            return 8.0, y, -8.0;
        elseif effect_name == "F_pc_effectitem_ep12wedding" then
            return x, 23, z;
        elseif effect_name == "F_pc_effectitem_ep12wedding_green" then
            return x, 23, z;
        elseif effect_name == "F_pc_effectitem_ep12wedding_violet" then
            return x, 23, z;        
        elseif effect_name == "I_leaf007_effect_item4" then
            return x, 30, z;    
        end
    end
    return x, y, z;
end

-- 슬로거티스 2페이즈
function SLOGUTIS_SECOND_PHASE_BUFF_ENTER(actor, obj, buff)
    actor:GetAnimation():SetSTDAnim("std_weapon", "astd_weapon");
    actor:GetAnimation():SetRUNAnim("run_weapon");
    actor:GetAnimation():SetWLKAnim("run_weapon");
    actor:GetAnimation():SetDEADAnim("dead_weapon");
end

function SLOGUTIS_SECOND_PHASE_BUFF_LEAVE(actor, obj, buff)
    actor:GetAnimation():ResetSTDAnim();
    actor:GetAnimation():ResetRUNAnim();
    actor:GetAnimation():ResetWLKAnim();
    actor:GetAnimation():ResetDEADAnim();
end

-- 슬로거티스 스턴
function SCR_BUFF_ANIM_CONVERT_boss_Slogutis(actor, buff_anim)
    if buff_anim ~= nil and buff_anim ~= "None" then
        if buff_anim == "STUN" then
            local stance_buff = actor:GetBuff():GetBuff("SLOGUTIS_SECOND_PHASE_BUFF");
            if stance_buff ~= nil then
                local convert_anim = buff_anim.."_WEAPON";
                return convert_anim;
            end
        end
    end
    return buff_anim;
end

function SCR_BUFF_ANIM_CONVERT_boss_Slogutis_Auto(actor, buff_anim)
    if buff_anim ~= nil and buff_anim ~= "None" then
        if buff_anim == "STUN" then
            local stance_buff = actor:GetBuff():GetBuff("SLOGUTIS_SECOND_PHASE_BUFF");
            if stance_buff ~= nil then
                local convert_anim = buff_anim.."_WEAPON";
                return convert_anim;
            end
        end
    end
    return buff_anim;
end

function SCR_BUFF_ANIM_CONVERT_boss_Slogutis_Solo(actor, buff_anim)
    if buff_anim ~= nil and buff_anim ~= "None" then
        if buff_anim == "STUN" then
            local stance_buff = actor:GetBuff():GetBuff("SLOGUTIS_SECOND_PHASE_BUFF");
            if stance_buff ~= nil then
                local convert_anim = buff_anim.."_WEAPON";
                return convert_anim;
            end
        end
    end
    return buff_anim;
end
