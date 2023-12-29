---- lib_ENCHANTCHIP.lua

function ENCHANTCHIP_ABLIE(item)
	
	if item.GroupName ~= "Armor" then
		return 0;
	end

	if item.ClassType ~= 'Hat' then
		return 0;
	end

	return 1;
end

function IS_ENCHANT_ITEM(item)
	if item.ClassName == "Premium_Enchantchip" or item.ClassName == "Premium_Enchantchip14" or item.ClassName == "Premium_Enchantchip_CT" or
	   item.ClassName == "TeamBat_Enchantchip" or item.ClassName == "Adventure_Enchantchip" or item.ClassName == "Premium_Enchantchip14_Team" or
	   item.ClassName == "STEAM_MASTER_Premium_Enchantchip" or item.ClassName == "Event_Enchantchip_1" or item.ClassName == "Event_Enchantchip_2"
	   or item.ClassName == "Event_Enchantchip_3" or item.ClassName == "Event_Enchantchip_4" or item.ClassName == "Premium_Enchantchip14_NoStack"
	   or item.ClassName == "Event_Enchantchip_5" or item.ClassName == "Event_Enchantchip_6" or item.ClassName == "Event_Enchantchip_7"
	   or item.ClassName == "Event_Enchantchip_200" or item.ClassName == "Event_Enchantchip_8" or item.ClassName == "Event_Enchantchip_201"
	   or item.ClassName == "Event_Enchantchip_202" or item.ClassName == "Event_Enchantchip_9" or item.ClassName == "Event_Enchantchip_10" or item.ClassName == "Event_Enchantchip_11"
	   or item.ClassName == "Event_Enchantchip_12" or item.ClassName == "Event_Enchantchip_13" or item.ClassName == "Event_Enchantchip_16" or item.ClassName == "Event_Enchantchip_17"
	   or item.ClassName == "Event_Enchantchip_18" or item.ClassName == "Event_Enchantchip_205" or item.ClassName == "Event_Enchantchip_25" or item.ClassName == "Event_Enchantchip_206"
	   or item.ClassName == "Event_Enchantchip_33" or item.ClassName == "Event_Enchantchip_39" or item.ClassName == "Premium_Enchantchip_NoTrade" or item.ClassName == "Event_Enchantchip_limit"
	   or item.ClassName == "Event_Enchantchip_limit_1" or item.ClassName == "Event_Enchantchip_limit_2" or item.ClassName == "SEASONLETICIA_Premium_Enchantchip" or item.ClassName == "Event_Enchantchip_limit_renew" then
		return 1;
	end

	if TryGetProp(item, 'StringArg', 'None') == 'enchantchip_low' or TryGetProp(item, 'StringArg', 'None') == 'enchantchip_high' then
		return 1
	end

	return 0;
end