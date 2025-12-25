function GET_USE_ROULETTE_TYPE(num)
    if num == 1 then
        return "GODDESS_ROULETTE";
    elseif num == 2 then
        return "GODDESS_COSTUME_ROULETTE";
    elseif num == 3 then
        return "GODDESS_RAINBOW_ROULETTE";
    elseif num == 4 then
        return "POPO_ROULETTE";
    elseif num == 5 then
        return "POPO_ROULETTE_PAPAYA";
    end
end
function GET_USE_ROULETTE_COUNT(type, accObj)
	if accObj == nil then return;	end

    local table = 
    {
        ["GODDESS_ROULETTE"] = TryGetProp(accObj, "GODDESS_ROULETTE_USE_ROULETTE_COUNT2"),
        ["GODDESS_COSTUME_ROULETTE"] = TryGetProp(accObj, "GODDESS_COSTUME_ROULETTE_USE_ROULETTE_COUNT"),
        ["GODDESS_RAINBOW_ROULETTE"] = TryGetProp(accObj, "GODDESS_RAINBOW_ROULETTE_USE_ROULETTE_COUNT"),
        ["POPO_ROULETTE"] = TryGetProp(accObj, "POPO_ROULETTE_USE_ROULETTE_COUNT"),
        ["POPO_ROULETTE_PAPAYA"] = TryGetProp(accObj, "POPO_ROULETTE_USE_ROULETTE_COUNT"),
    }

	return table[type];
end

function GET_MAX_ROULETTE_COUNT(type)
    local table = 
    {
        ["GODDESS_ROULETTE"] = GODDESS_ROULETTE_MAX_COUNT,
        ["GODDESS_COSTUME_ROULETTE"] = GODDESS_COSTUME_ROULETTE_MAX_COUNT,
        ["GODDESS_RAINBOW_ROULETTE"] = GODDESS_RAINBOW_ROULETTE_MAX_COUNT,
        ["POPO_ROULETTE"] = POPO_ROULETTE_MAX_COUNT,
        ["POPO_ROULETTE_PAPAYA"] = POPO_ROULETTE_MAX_COUNT
    }

	return table[type];
end

function GET_ROULETTE_COIN_CLASSNAME(type)
    local table = 
    {
        ["GODDESS_ROULETTE"] = "Event_Roulette_Coin_3",
        ["GODDESS_COSTUME_ROULETTE"] = "Event_Roulette_Coin_4",
        ["GODDESS_RAINBOW_ROULETTE"] = "Event_Roulette_Coin_3",
        ["POPO_ROULETTE"] = "Event_Roulette_Coin_PoPo_2512",
        ["POPO_ROULETTE_PAPAYA"] = "Event_Roulette_Coin_PoPo_2503"
    }

	return table[type];
end

function GET_ROULETTE_PROP(type)
    local table = 
    {
        ["GODDESS_ROULETTE"] = "GODDESS_ROULETTE_USE_ROULETTE_COUNT2",
        ["GODDESS_COSTUME_ROULETTE"] = "GODDESS_COSTUME_ROULETTE_USE_ROULETTE_COUNT",
        ["GODDESS_RAINBOW_ROULETTE"] = "GODDESS_RAINBOW_ROULETTE_USE_ROULETTE_COUNT",
        ["POPO_ROULETTE"] = "POPO_ROULETTE_USE_ROULETTE_COUNT",
        ["POPO_ROULETTE_PAPAYA"] = "POPO_ROULETTE_USE_ROULETTE_COUNT"
    }

	return table[type];
end

function GET_ROULETTE_TITLE(type)
    local table = 
    {
        ["GODDESS_ROULETTE"] = "GODDESS_ROULETTE",
        ["GODDESS_COSTUME_ROULETTE"] = "GODDESS_COSTUME_ROULETTE",
        ["GODDESS_RAINBOW_ROULETTE"] = "GODDESS_RAINBOW_ROULETTE",
        ["POPO_ROULETTE"] = "POPO_ROULETTE",
        ["POPO_ROULETTE_PAPAYA"] = "POPO_ROULETTE"
    }

	return table[type];
end

function GET_ROULETTE_DIALOG(type)
    local table = 
    {
        ["GODDESS_ROULETTE"] = "GODDESS_ROULETTE_DLG_3",
        ["GODDESS_COSTUME_ROULETTE"] = "GODDESS_ROULETTE_DLG_4",
        ["GODDESS_RAINBOW_ROULETTE"] = "GODDESS_ROULETTE_DLG_3",
        ["POPO_ROULETTE"] = "POPO_ROULETTE_DLG_2",
        ["POPO_ROULETTE_PAPAYA"] = "POPO_ROULETTE_DLG_2",
    }

	return table[type];
end

