-- shared_master_mon.lua

shared_master_mon = {}
local master_mon_exp_table = nil

function make_master_mon_exp_table()
    master_mon_exp_table = {}
    local sum = 0
    sum = sum + 1
    table.insert(master_mon_exp_table, sum)
    sum = sum + 2
    table.insert(master_mon_exp_table, sum)    
    sum = sum + 3
    table.insert(master_mon_exp_table, sum)
    sum = sum + 4
    table.insert(master_mon_exp_table, sum)
    sum = sum + 5
    table.insert(master_mon_exp_table, sum)    
end

shared_master_mon.get_lv = function(exp)
    if master_mon_exp_table == nil then
        make_master_mon_exp_table()        
    end 

    for i = 1, #master_mon_exp_table do
        if master_mon_exp_table[i] > exp then
            return i - 1
        end
    end

    return #master_mon_exp_table
end

-- lv 레벨까지의 필요 경험치
shared_master_mon.get_required_exp_to_lv = function(lv)
    if master_mon_exp_table == nil then
        make_master_mon_exp_table()        
    end 

    local sum = 0
    if lv > #master_mon_exp_table then
        lv = #master_mon_exp_table
    end
        
    for i = 1, lv do
        sum = master_mon_exp_table[i]
    end

    return sum
end

-- currnet / max
shared_master_mon.get_exp_pair = function(current_exp)
    if master_mon_exp_table == nil then
        make_master_mon_exp_table()        
    end 

    local lv = shared_master_mon.get_lv(current_exp)        
    local required_exp = shared_master_mon.get_required_exp_to_lv(lv + 1) - shared_master_mon.get_required_exp_to_lv(lv)    
    local now_exp = current_exp - shared_master_mon.get_required_exp_to_lv(lv)
    return lv, now_exp, required_exp
end

-- master_name : dragoon_master_ex
shared_master_mon.is_valid_coupon = function(master_name, item)
    local str = TryGetProp(item, 'StringArg', 'None')
    if str == master_name then
        return true
    else
        return false
    end
end

shared_master_mon.get_max_mon_level = function()
    if master_mon_exp_table == nil then
        make_master_mon_exp_table()        
    end 

    return #master_mon_exp_table
end