-- mythic_dungeon_info.lua
function MYTHIC_DUNGEON_INFO_ON_INIT(addon, frame)
    addon:RegisterMsg('UPDATE_MYTHIC_DUNGEON_SEASON', 'ON_UPDATE_MYTHIC_DUNGEON_SEASON');    
	mythic_dungeon.RequestCurrentSeason();
end

function ON_UPDATE_MYTHIC_DUNGEON_SEASON(frame,msg,argStr,argNum)
	mythic_dungeon.RequestPattern(mythic_dungeon.GetCurrentSeason());
end
