function MONSKL_C_PLAY_ANIM_DESPERADO_RUSSIANROULETTE(actor, skill, animName, spd, freezeAnim, cancelByHit)
    local pc = GetMyPCObject();
    local exprop = GetExProp(pc,"DESPERADO_ANIM")
    if exprop == 1 then
        
    elseif  exprop == 2 then
        animName = animName.."_FAIL"
    end
    
    local _cancelByHit = false;
    if cancelByHit == 1 then    
        _cancelByHit = true;
    end
    actor:GetAnimation():ResetAnim();
    actor:GetAnimation():PlayFixAnim(animName, spd, freezeAnim, 0, 0, 0, true, 0, _cancelByHit);
end

function C_UNITY_EFFECT_NODE_DESPERADO_ONLY(actor, obj, effect_name)
    local pc = GetMyPCObject();
    local exprop = GetExProp(pc,"DESPERADO_ANIM")
    if exprop == 1 then
        effect_name = "AerialExplosion_PartyPopper_Random_01"
        effect.PlayUnityEffectNode(actor, effect_name, 0.8 ,1.0, 0, 0, 0, "Bip01 Spine","None","None");
    elseif  exprop == 2 then
        effect_name = "AerialExplosion_Fire_Orange_01"
        effect.PlayUnityEffectNode(actor, effect_name, 0.2,1.0, 0, 0, 0, "Dummy_R_HAND","None","None");
    end
end

function C_VOICE_SOUND_DESPERADO_RUSSIANROULETTE(actor, obj, maleVoice, femaleVoice)
    if actor:GetObjType() == GT_MONSTER then
        return;
    end

    local pc = GetMyPCObject();
    local exprop = GetExProp(pc,"DESPERADO_ANIM")    
    if exprop == 1 then

    elseif  exprop == 2 then
        -- fail
        maleVoice  = "voice_cleric_m_omikuji_cast_fail"
        femaleVoice = "voice_cleric_f_omikuji_cast_fail"
    end

    local gender = customize.GetGender( actor:GetHandleVal() );
    
    local isMyPC = true;
    if actor:IsMyPC() == 0 then
        isMyPC = false;
    end

    if gender == 0 then
        return;
    elseif gender == 1 then
        actor:GetEffect():PlaySound(maleVoice, -1, false, isMyPC);
    else
        actor:GetEffect():PlaySound(femaleVoice, -1, false, isMyPC);
    end
end