function _TEAM_BATTLE_ALARM_MSG(msg, countdownSec)
	if msg ~= nil and msg ~= "None" then
		if msg == "COUNT" then
			if config.GetServiceNation() == 'KOR' then
				imcSound.PlaySoundEvent('countdown_'..countdownSec);
			else
				if config.GetServiceNation() ~= 'GLOBAL_JP' then
					imcSound.PlaySoundEvent('S1_countdown_'..countdownSec);
				end
			end
        elseif msg == "START" then
            if config.GetServiceNation() == 'KOR' then
                imcSound.PlaySoundEvent('battle_start');
            else
                if config.GetServiceNation() ~= 'GLOBAL_JP' then
                    imcSound.PlaySoundEvent('S1_battle_start');
                end
            end
        elseif msg == "END" then
            if config.GetServiceNation() == 'KOR' then
                imcSound.PlaySoundEvent('battle_end');
            else
                if config.GetServiceNation() ~= 'GLOBAL_JP' then
                    imcSound.PlaySoundEvent('S1_battle_end');
                end
            end
		end
	end
end
