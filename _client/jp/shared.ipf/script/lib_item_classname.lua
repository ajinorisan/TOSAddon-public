function GET_INDUN_MULTIPLE_ITEM_LIST()
    return {'Premium_dungeoncount_01', 
            'Premium_dungeoncount_Event',
            'Adventure_dungeoncount_01',
            'Event_dungeoncount_1',
            'Event_dungeoncount_2',
            'Event_dungeoncount_3',
            'Event_dungeoncount_4',
            'Event_dungeoncount_5',
            'Event_dungeoncount_6',
            'Event_dungeoncount_7',
            'Event_dungeoncount_8',
            'Event_dungeoncount_9',
            'Tuto_dungeoncount',
            'Event_dungeoncount_10',
            'Event_dungeoncount_11',
            'Event_dungeoncount_12',
            'Event_dungeoncount_13',
            'Event_dungeoncount_14',
            'Event_dungeoncount_15',
            'Event_dungeoncount_18',
            'Event_dungeoncount_19',
            'Event_dungeoncount_20',
            'Event_dungeoncount_25',
             'Event_dungeoncount_30',
             'Event_dungeoncount_31',
             'Event_dungeoncount_32',
            'Event_dungeoncount_33',
            'Event_dungeoncount_34',
            'Event_dungeoncount_36',
            'Event_dungeoncount_37',
            'Event_dungeoncount_38',        
            'Event_dungeoncount_39',
            'Event_dungeoncount_41',
            'Event_dungeoncount_limit',
            'Event_dungeoncount_limit_1',
            'Event_dungeoncount_limit_2',
            'Event_dungeoncount_limit_renew',
        };
end

function IS_INDUN_MULTIPLE_ITEM(itemClassName)
    local itemClass = GetClass('Item', itemClassName)
    if itemClass ~= nil then
        local stringArg = TryGetProp(itemClass, 'StringArg', 'None')
        if stringArg == 'MultipleIndunToken' then
            return 1
        end
    end

    return 0
end

function GET_SWITCHGENDER_MATERIAL_ITEM_NAME()
    return 'misc_TruthMirror';
end

function GET_SWITCHGENDER_SELLER_SPEND_ITEM()
    return 'Drug_holywater', 100; -- 여기 스위치젠더 사용시 판매자가 소모할 아이템 이름이랑 개수요
end

function GET_SEAL_ADDITIONAL_ITEM()
    local t = {}
    table.insert(t, 'misc_0530') -- 인장 강화 재료 아이템
    table.insert(t, 'misc_0530_seal') -- 인장 강화 재료 아이템
    return t
end
