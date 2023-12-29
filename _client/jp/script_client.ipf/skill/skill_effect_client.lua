-- skill_effect_client.lua

function C_PLAY_EFFECT_UNLIMITED_SPEAR(actor, obj, x, y, z)
    local eftName = 'eff_ark_subdue_01' -- 검은색 폭발
    local scl = 1.3
    local lifeTime = 2
    local delay = 0
    effect.PlayGroundEffect(actor, eftName, scl, x, y, z, lifeTime, "None", 0.0, delay);

    eftName = 'eff_ark_judgment_02'
    scl = 1.2
    lifeTime = 1
    delay = 1.5    
    effect.PlayGroundUnityEffect(actor, eftName, scl, x, y + 200, z, lifeTime, "None", 180, 0, 0, delay);

    delay = delay + 1
    local count = 20
    local count_2 = 5
    local time = 4000
    local tick = time / count / 1000 / count_2
    
    eftName = 'eff_ark_judgment_01'        
    scl = 0.3
    lifeTime = 0
    
    for i = 1, count do
        for j = 1, count_2 do
            local x1, y1, z1 = GetRandomPosInRange(nil, x, y, z, 20, 100)            
            delay = delay + tick
            effect.PlayGroundEffect(actor, eftName, scl, x1, y1, z1, lifeTime, "None", 0.0, delay);
        end
    end
end

