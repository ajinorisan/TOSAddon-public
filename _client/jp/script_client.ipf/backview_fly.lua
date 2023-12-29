
function CL_BackViewFly_BEGIN(actor)
    actor:SetAlwaysBattleState(true);
    actor:GetAnimation():SetTURNAnim("SKL_LEVITATION_ATURN");
    actor:GetAnimation():SetSTDAnim("SKL_LEVITATION_ASTD");
    actor:GetAnimation():SetRUNAnim("SKL_LEVITATION_ARUN");
    actor:GetAnimation():SetWLKAnim("SKL_LEVITATION_ARUN");
end

function CL_BackViewFly_END(actor)
    actor:SetAlwaysBattleState(false);
    actor:GetAnimation():ResetTURNAnim();
    actor:GetAnimation():ResetSTDAnim();
    actor:GetAnimation():ResetRUNAnim();
    actor:GetAnimation():ResetWLKAnim();
end

-- Interaction_Ride_GresmeRaven
function CL_BackViewFly_Interaction_Ride_GresmeRaven_BEGIN(actor)
    actor:SetAlwaysBattleState(true);
    actor:GetAnimation():SetTURNAnim("raid_flying");
    actor:GetAnimation():SetSTDAnim("raid_flying");
    actor:GetAnimation():SetRUNAnim("raid_flying");
    actor:GetAnimation():SetWLKAnim("raid_flying");
end

-- Interaction_Ride_GresmeRaven
function CL_BackViewFly_Interaction_Ride_GresmeRaven_END(actor)
    actor:SetAlwaysBattleState(false);
    actor:GetAnimation():ResetTURNAnim();
    actor:GetAnimation():ResetSTDAnim();
    actor:GetAnimation():ResetRUNAnim();
    actor:GetAnimation():ResetWLKAnim();
end
