-- skill_effect_client.lua

function Illusionist_IllusionSword_Sound(actor, obj, name, after)    
    local handle = actor:GetHandleVal()
    local func = string.format('Illusionist_play_sound(%d, "%s")', handle, name)    

    local time = 0
    for i = 1, 10, 1 do
        time = (0.1 * (i - 1))
        ReserveScript(func, time)
    end

    name = 'arrow_mid_3'
    local func = string.format('Illusionist_play_sound(%d, "%s")', handle, name)
    ReserveScript(func, time + after)
end


function Illusionist_play_sound(handle, name)    
    local actor = world.GetActor(handle);
    if actor ~= nil then
        actor:GetEffect():PlaySound(name);    
    end
end

function Illusionist_Nightmare_Sound(actor, obj, name, start)
    local handle = actor:GetHandleVal()
    local func = string.format('Illusionist_play_sound(%d, "%s")', handle, name)    

    local pivot = start
    local time = 0
    for i = 1, 28, 1 do
        time = pivot + (0.3 * (i - 1))        
        ReserveScript(func, time)
    end
    name = 'skl_eff_katon_no_jutsu_hit'
    func = string.format('Illusionist_play_sound(%d, "%s")', handle, name)    
    ReserveScript(func, time - 0.5)

    name = 'skl_eff_kasiwade_hit'
    func = string.format('Illusionist_play_sound(%d, "%s")', handle, name)    
    ReserveScript(func, time)
end

function Illusionist_Nightmare_Sound_2(actor, obj, name, start)
    local handle = actor:GetHandleVal()
    local func = string.format('Illusionist_play_sound(%d, "%s")', handle, name)    

    local pivot = start
    local time = 0
    for i = 1, 9, 1 do
        time = pivot + (0.1 * (i - 1))        
        ReserveScript(func, time)
    end

    name = 'skl_eff_kasiwade_hit'
    func = string.format('Illusionist_play_sound(%d, "%s")', handle, name)    
    ReserveScript(func, time)
end
