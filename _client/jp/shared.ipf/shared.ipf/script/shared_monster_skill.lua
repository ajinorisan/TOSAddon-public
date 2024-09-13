-- shared_monster_skill.lua

shared_monster_skill = {}
local monster_exp_table = nil

function make_monster_exp_table()
    monster_exp_table = {}
    local sum = 0
    sum = sum + 10
    table.insert(monster_exp_table, sum)
    sum = sum + 20
    table.insert(monster_exp_table, sum)    
    sum = sum + 30
    table.insert(monster_exp_table, sum)
    sum = sum + 40
    table.insert(monster_exp_table, sum)
    sum = sum + 50
    table.insert(monster_exp_table, sum)
    sum = sum + 60
    table.insert(monster_exp_table, sum)
    sum = sum + 70
    table.insert(monster_exp_table, sum)
    sum = sum + 80
    table.insert(monster_exp_table, sum) 
    sum = sum + 90
    table.insert(monster_exp_table, sum)
    sum = sum + 100
    table.insert(monster_exp_table, sum)
end

make_monster_exp_table()

shared_monster_skill.get_lv = function(exp)
    for i = 1, #monster_exp_table do
        if monster_exp_table[i] > exp then
            return i - 1
        end
    end

    return #monster_exp_table
end

-- lv 레벨까지의 필요 경험치
shared_monster_skill.get_required_exp_to_lv = function(lv)
    local sum = 0
    if lv > #monster_exp_table then
        lv = #monster_exp_table
    end
        
    for i = 1, lv do
        sum = monster_exp_table[i]
    end

    return sum
end

-- currnet / max
shared_monster_skill.get_exp_pair = function(current_exp)
    local lv = shared_monster_skill.get_lv(current_exp)
        
    local required_exp = shared_monster_skill.get_required_exp_to_lv(lv + 1) - shared_monster_skill.get_required_exp_to_lv(lv)
    local now_exp = current_exp - shared_monster_skill.get_required_exp_to_lv(lv)
    return now_exp, required_exp
end
