-- mythic dungeon
function SCR_MYTHIC_DUNGEON_GET_REGION_RULE()
	local mythic_rule = GetClass("mythic_rule", "myrhic_hard")
	if GetServerNation() == 'GLOBAL' then
		if GetServerGroupID() == 1001 or GetServerGroupID() == 10001 then
			mythic_rule = GetClass("mythic_rule", "myrhic_hard_steam_1001")
		elseif GetServerGroupID() == 1003 or GetServerGroupID() == 10003 then
			mythic_rule = GetClass("mythic_rule", "myrhic_hard_steam_1003")
		elseif GetServerGroupID() == 1004 or GetServerGroupID() == 10004 then
			mythic_rule = GetClass("mythic_rule", "myrhic_hard_steam_1004")
		elseif GetServerGroupID() == 1005 or GetServerGroupID() == 10005 then
			mythic_rule = GetClass("mythic_rule", "myrhic_hard_steam_1005")
		end
	end 
	return mythic_rule;
end