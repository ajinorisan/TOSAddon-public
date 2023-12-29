-- skill_buff_checkcontinue.lua
-- type : handle, type(Move or Stand)
function SCR_BUFF_C_CHECKCONTINUE_HiphopEffect_pre(handle, type)
    local actor = world.GetActor(handle);
    if actor == nil then
        return 0;
    end

    if session.colonywar.GetIsColonyWarMap() == true and seesion. config.GetShowGuildInColonyEffectCostume() == 0 then
        return 0;
    end

    if type == "Stand" and actor:GetEquipItemFlagProp("EFFECTCOSTUME") == 0 then
        effect.AddActorEffectByOffset(actor, "E_pc_effectitem_hiphop", 1, "Ground", false, true);
        actor:SetEquipItemFlagProp("EFFECTCOSTUME", 1);
    elseif type == "Move" then
        effect.DetachActorEffect(actor, "E_pc_effectitem_hiphop", 0);
        actor:SetEquipItemFlagProp("EFFECTCOSTUME", 0);
    end

    return 1;
end

function SCR_BUFF_C_CHECKCONTINUE_EP12TACTICAL_EFFECT02_PRE(handle, type)
    local actor = world.GetActor(handle);
    if actor == nil then
        return 0;
    end

    if session.colonywar.GetIsColonyWarMap() == true and config.GetShowGuildInColonyEffectCostume() == 0 then
        return 0;
    end

    if type == "Stand" and actor:GetEquipItemFlagProp("EFFECTCOSTUME") == 0 then
        effect.AddActorEffectByOffset(actor, "I_policeline001_mesh", 1, "Middle", true, true);
        actor:SetEquipItemFlagProp("EFFECTCOSTUME", 1);
    elseif type == "Move" then
        effect.DetachActorEffect(actor, "I_policeline001_mesh", 0);
        actor:SetEquipItemFlagProp("EFFECTCOSTUME", 0);
    end

    return 1;
end
-- 끼룩끼룩 갈매기
function SCR_BUFF_C_CHECKCONTINUE_ITEM_EP12FLYINGSEAGULL_EFFECT_PRE(handle, type)
    local actor = world.GetActor(handle);
    if actor == nil then
        return 0;
    end

    if session.colonywar.GetIsColonyWarMap() == true and config.GetShowGuildInColonyEffectCostume() == 0 then
        return 0;
    end

    if type == "Stand" and actor:GetEquipItemFlagProp("EFFECTCOSTUME") == 0 then
        effect.AddActorEffectByOffset(actor, "I_pc_effectitem_flyingseagull", 1.35, "BOT", true, true);
        actor:SetEquipItemFlagProp("EFFECTCOSTUME", 1);
    elseif type == "Move" then
        effect.DetachActorEffect(actor, "I_pc_effectitem_flyingseagull", 0);
        actor:SetEquipItemFlagProp("EFFECTCOSTUME", 0);
    end

    return 1;
end-- 주변을 맴도는 상어
function SCR_BUFF_C_CHECKCONTINUE_ITEM_EP12TWINSHARK_EFFECT_PRE(handle, type)
    local actor = world.GetActor(handle);
    if actor == nil then
        return 0;
    end

    if session.colonywar.GetIsColonyWarMap() == true and config.GetShowGuildInColonyEffectCostume() == 0 then
        return 0;
    end

    if type == "Stand" and actor:GetEquipItemFlagProp("EFFECTCOSTUME") == 0 then
        effect.AddActorEffectByOffset(actor, "E_effect_twinshark", 1.35, "BOT", true, true);
        actor:SetEquipItemFlagProp("EFFECTCOSTUME", 1);
    elseif type == "Move" then
        effect.DetachActorEffect(actor, "E_effect_twinshark", 0);
        actor:SetEquipItemFlagProp("EFFECTCOSTUME", 0);
    end

    return 1;
end

function SCR_BUFF_C_CHECKCONTINUE_EP12DEMONLORD_EFFECT_PRE(handle, type)
    local actor = world.GetActor(handle);
    if actor == nil then
        return 0;
    end

    if session.colonywar.GetIsColonyWarMap() == true and config.GetShowGuildInColonyEffectCostume() == 0 then
        return 0;
    end

    if type == "Move" and actor:GetEquipItemFlagProp("EFFECTCOSTUME") == 0 then
        effect.AddActorEffectByOffset(actor, "I_spread_out015_light_orange", 2, "MID", true, true);
        actor:SetEquipItemFlagProp("EFFECTCOSTUME", 1);
    elseif type == "Stand" or type == "None" then
        effect.DetachActorEffect(actor, "I_spread_out015_light_orange", 0.7);
        actor:SetEquipItemFlagProp("EFFECTCOSTUME", 0);
    end

    return 1;
end

function SCR_BUFF_C_CHECKCONTINUE_EP12DEMONLORD_VIOLET_EFFECT_PRE(handle, type)
    local actor = world.GetActor(handle);
    if actor == nil then
        return 0;
    end

    if session.colonywar.GetIsColonyWarMap() == true and config.GetShowGuildInColonyEffectCostume() == 0 then
        return 0;
    end

    if type == "Move" and actor:GetEquipItemFlagProp("EFFECTCOSTUME") == 0 then
        effect.AddActorEffectByOffset(actor, "I_spread_out015_light_blue_violet", 2, "MID", true, true);
        actor:SetEquipItemFlagProp("EFFECTCOSTUME", 1);
    elseif type == "Stand" or type == "None" then
        effect.DetachActorEffect(actor, "I_spread_out015_light_blue_violet", 0.7);
        actor:SetEquipItemFlagProp("EFFECTCOSTUME", 0);
    end

    return 1;
end

function SCR_BUFF_C_CHECKCONTINUE_SwellHands_Buff(handle, type)
    local actor = world.GetActor(handle);
    if actor == nil then
        return 0;
    end

    if type == "Move" and pc.IsBuffApplied(actor, "Limacon_Buff") == 1 then
        local lh_item = session.GetEquipItemBySpot(item.GetEquipSpotNum("LH"));
        if lh_item ~= nil then
            local lh_obj = GetIES(lh_item:GetObject());
            if lh_obj ~= nil then
                local pc = GetMyPCObject();
                if IsBattleState(pc) == 1 then
                    actor:ShowModelByPart("LH", 0, 0, "SwellHands_Buff"); 
                else
                    actor:ShowModelByPart("LH", 1, 0, "SwellHands_Buff"); 
                end
            end
        end
    else
        actor:ShowModelByPart("LH", 1, 0, "SwellHands_Buff"); 
    end
    return 1;
end

function SCR_BUFF_C_CHECKCONTINUE_TOY_EP14ZEMINA_OWNER(handle, type)
    local actor = world.GetActor(handle);
    if actor == nil then return 0; end
    if type == "Move" then return 0; end
    return 1;
end