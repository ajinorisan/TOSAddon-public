-- shared_item_jurate_seal.lua

shared_item_jurate_seal = {}

shared_item_jurate_seal.is_valid_item = function(item, item_piece)
    if item == nil or item_piece == nil then
        return false, 'NotValidItem'
    end

    local lv = GET_CURRENT_SEAL_LEVEL(item)    
    if lv < 5 then
        return false, 'NotValidItem'
    end

    local str = TryGetProp(item_piece, 'StringArg', 'None')

    local str2 = TryGetProp(item_piece, 'StringArg2', 'None')
    local give_item = StringSplit(str2, '/')[1]
    local cls = GetClass('Item', give_item)    
    if cls == nil then
        return false, 'NotValidItem'
    end

    local token = StringSplit(str, ';')    
    local seal_item = token[2]    
    if seal_item == nil then
        return false, 'NotValidItem'
    end

    seal_item = StringSplit(seal_item, '/')[1]
    
    if seal_item == nil then
        return false, 'NotValidItem'
    end

    if TryGetProp(item, 'ClassName', 'None') ~= seal_item then
        return false, 'NotValidItem'
    end

    return true, 'None'
end

shared_item_jurate_seal.get_cost = function(item)
    local cls = shared_item_jurate_seal.get_consume_seal_cls(item)

    local name = TryGetProp(cls, 'ClassName', 'None')
    local dic = nil    
    if name == 'Seal_Boruta_Common' then
        dic = {}
        dic['VakarineCertificate'] = 3000000
        return dic, true
    elseif name == 'Seal_jurate' or name == 'Seal_jurate_def' then
        dic = {}
        dic['VakarineCertificate'] = 5000000
        return dic, true
    elseif name == 'Seal_jurate2' or name == 'Seal_jurate2_def' then
        dic = {}
        dic['VakarineCertificate'] = 7000000
        return dic, true
    elseif name == 'Seal_jurate3' or name == 'Seal_jurate3_def' then
        dic = {}
        dic['JurateCertificate'] = 20000000
        return dic, true
    end

    return dic, false
end

shared_item_jurate_seal.get_piece_count = function(item)
    local str = TryGetProp(item, 'StringArg', 'None')
    local token = StringSplit(str, ';')[1]
    return StringSplit(token, '/')[2]
end

shared_item_jurate_seal.get_seal_name = function(item)
    local str = TryGetProp(item, 'StringArg2', 'None')
    local token = StringSplit(str, '/')[1]
    local cls = GetClass('Item', token)
    return TryGetProp(cls, 'Name', 'None')
end
shared_item_jurate_seal.get_seal_cls = function(item)
    local str = TryGetProp(item, 'StringArg2', 'None')
    local token = StringSplit(str, '/')[1]
    return GetClass('Item', token)
end

shared_item_jurate_seal.get_consume_seal_name = function(item)
    local str = TryGetProp(item, 'StringArg', 'None')
    local token = StringSplit(str, ';')[2]
    local name = StringSplit(token, '/')[1]
    local cls = GetClass('Item', name)
    return TryGetProp(cls, 'Name', 'None')
end

shared_item_jurate_seal.get_consume_seal_cls = function(item)
    local str = TryGetProp(item, 'StringArg', 'None')
    local token = StringSplit(str, ';')[2]
    local name = StringSplit(token, '/')[1]    
    return GetClass('Item', name)
end

