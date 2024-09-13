-- shared_friend_invite_event.lua

local reward_list = nil

-- 이벤트 종료시에 반환 값을 None으로 한다.
function GET_FRIEND_INVITE_EVENT_START_TIME()
    return 'None'
end

function make_invite_event_reward()
    if reward_list == nil then
        reward_list = {}
        for i = 1, 5 do
            reward_list[i] = {}
        end

        reward_list[1]['RadaCertificateCoin_1000000p'] = 2

        reward_list[2]['Ticket_AbyssalObserver_Auto_Enter_NoTrade'] = 25
        reward_list[2]['Ticket_DreamyForest_Auto_Enter_NoTrade'] = 25
        
        reward_list[3]['Ticket_AbyssalObserver_Party_Enter_NoTrade'] = 2
        reward_list[3]['Ticket_DreamyForest_Party_Enter_NoTrade'] = 2

        reward_list[4]['Event_ChallengeModeReset_6'] = 100

        reward_list[5]['Premium_Enchantchip_high_NoTrade2'] = 20        
    end
end


function get_make_invite_event_reward(num)
    make_invite_event_reward()

    return reward_list[num]
end
