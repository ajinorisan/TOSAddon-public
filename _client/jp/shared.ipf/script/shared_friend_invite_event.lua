-- shared_friend_invite_event.lua

local reward_list = nil

local shared_friend_invite_table = {   
    START_TIME = '2025-04-15 00:00:00',
    END_TIME = '2025-06-04 10:00:00',  
    PAPAYA_START_TIME = '2022-04-15 00:00:00',
    PAPAYA_END_TIME = '2022-05-27 00:00:00'
}

-- 이벤트 종료시에 반환 값을 None으로 한다. (20240812)
function GET_FRIEND_INVITE_EVENT_START_TIME()
    return '20250415'
end

function make_invite_event_reward()
    if reward_list == nil then
        reward_list = {}
        for i = 1, 6 do
            reward_list[i] = {}
        end

        reward_list[1]['JurateCertificateCoin_1000000p'] = 2

        reward_list[2]['Ticket_Golem_Auto_Enter_NoTrade'] = 20

        reward_list[3]['Ticket_Redania_Auto_Enter_NoTrade'] = 20
        
        reward_list[4]['EP12_EXPERT_MODE_MULTIPLE_NoTrade'] = 40

        reward_list[5]['Premium_Enchantchip_high_NoTrade2'] = 20

        reward_list[6]['selectbox_specialclass_allinone'] = 1
    end
end


function get_make_invite_event_reward(num)
    make_invite_event_reward()

    return reward_list[num]
end

function is_between_friend_invite_time()
    local nation = GET_POPOBOOST_SERVER()
    if nation == 1 then
        return date_time.is_between_time(shared_friend_invite_table.PAPAYA_START_TIME, shared_friend_invite_table.PAPAYA_END_TIME);
    else
        return date_time.is_between_time(shared_friend_invite_table.START_TIME, shared_friend_invite_table.END_TIME);
    end
end